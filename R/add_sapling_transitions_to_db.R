#' Add sapling_transitions table to database
#'
#' @param con database connection
#'
#' @return nothing
#' @export
#' @importFrom DBI dbListTables dbSendStatement
#' @importFrom dplyr collect select distinct arrange group_by mutate ungroup left_join summarize n filter cross_join join_by lag across inner_join contains
#' @importFrom arrow to_duckdb
add_saplings_to_db <- function(con) {
  
  existing_tables <- dbListTables(con)
  
  if("sapling_transitions" %in% existing_tables) {
    message("sapling_transitions table already present in database!")
    return()
  }
  
  if(!(all(c("tree", "cond") %in% existing_tables))) {
    message("At least one of tree, cond tables not present in database; needed for sapling_transitions!")
    return()
  }
  
  saplings_ever <- tbl(con, "tree") |> 
    filter(DIA < 5, STATUSCD == 1) |>
    select(TREE_COMPOSITE_ID) |>
    distinct() |>
    left_join(tbl(con, "tree")) |>
    select(TREE_COMPOSITE_ID,
           PLOT_COMPOSITE_ID,
           PLT_CN,
           DIA,
           HT,
           ACTUALHT,
           TPA_UNADJ,
           STATUSCD,
           INVYR,
           CYCLE, 
           CONDID) |>
    left_join(tbl(con, "cond") |>
                select(PLT_CN, CONDID, COND_STATUS_CD))
  
  sapling_changes <- saplings_ever |>
    arrange(TREE_COMPOSITE_ID, INVYR) |>
    group_by(TREE_COMPOSITE_ID) |>
    mutate(
      PREV_INVYR = lag(INVYR, 1, default = -1989, order_by = INVYR),
      PREV_STATUSCD = lag(STATUSCD, 1, default = -1989, order_by = INVYR),
      PREV_DIA = lag(DIA, 1, default = -1989, order_by = INVYR),
      NEXT_INVYR = lead(INVYR, 1, default = -1989, order_by = INVYR),
      FIRST_INVYR = min(INVYR, na.rm = T),
      LAST_INVYR = max(INVYR, na.rm = T)
    ) |>
    group_by_all() |>
    mutate(
      live_sapling = DIA < 5 && STATUSCD == 1,
      new_sapling = PREV_INVYR == -1989 &&
        PREV_STATUSCD == -1989 &&
        PREV_DIA == -1989 && STATUSCD == 1 && DIA < 5,
      sapling_sapling = DIA < 5 &&
        STATUSCD == 1 && PREV_DIA < 5 && PREV_STATUSCD == 1,
      sapling_tree = PREV_DIA < 5 &&
        PREV_STATUSCD == 1 && DIA >= 5 && STATUSCD == 1,
      sapling_dead = PREV_DIA < 5 &&
        PREV_STATUSCD == 1 && STATUSCD == 2,
      sapling_removed = PREV_DIA < 5 &&
        PREV_STATUSCD == 1 && STATUSCD == 3,
      sapling_not_sampled = PREV_DIA < 5 &&
        PREV_STATUSCD == 1 && STATUSCD == 0,
      sapling_missing_data = PREV_DIA < 5 &&
        PREV_STATUSCD == 1 && STATUSCD == 1 && is.na(DIA),
      sapling_vanishes_next_year = DIA < 5 &&
        STATUSCD == 1 && NEXT_INVYR == -1989
    ) |>
    mutate(across(contains("sapling"), as.numeric)) |>
    ungroup() 
  
  sapling_tallies <- sapling_changes |>
    group_by(PLOT_COMPOSITE_ID, INVYR) |>
    summarize(across(contains("sapling"), .fns = (\(
      x
    ) sum(
      x, na.rm = T
    )))) |>
    ungroup() |>
    arrange(PLOT_COMPOSITE_ID, INVYR) |>
    group_by(PLOT_COMPOSITE_ID) |>
    mutate(
      PREV_live_sapling = lag(live_sapling, default = -1989, order_by = INVYR),
      sapling_vanished = lag(sapling_vanishes_next_year, default = -1989, order_by = INVYR),
      PREV_INVYR = lag(INVYR, default = -1989, order_by = INVYR)
    ) |>
    ungroup() 
  
  sapling_transitions <- sapling_tallies |>
    filter(PREV_INVYR != -1989) |>
    mutate(presumed_dead = sapling_dead + sapling_vanished,
           timespan = INVYR - PREV_INVYR) |>
    mutate(across(c(sapling_sapling,
                    sapling_tree,
                    sapling_removed,
                    presumed_dead,
                    sapling_not_sampled,
                    sapling_missing_data),
                  .f = c(prop = (\(x) x / PREV_live_sapling)))) |>
    collect()
  
  
  arrow::to_duckdb(sapling_transitions, table_name = "sapling_transitions", con = con)
  dbExecute(con, "CREATE TABLE sapling_transitions AS SELECT * FROM sapling_transitions")
  
  return() 
  
}