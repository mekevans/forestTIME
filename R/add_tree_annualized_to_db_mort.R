#' Add tree_annualized table to database
#'
#' @param con database connection
#'
#' @return nothing
#' @export
#' @importFrom DBI dbListTables dbSendStatement
#' @importFrom dplyr collect select distinct arrange group_by mutate ungroup left_join summarize n filter cross_join join_by lead inner_join
#' @importFrom arrow to_duckdb
add_annual_estimates_to_db <- function(con) {
  
  existing_tables <- dbListTables(con)
  
  if("tree_annualized" %in% existing_tables) {
    message("tree_annualized table already present in database!")
    return()
  }
  
  if(!(all(c("tree", "tree_info_composite_id") %in% existing_tables))) {
    message("At least one of tree, tree_info_composite_id tables not present in database; needed for tree_annualized!")
    return()
  }
  
  if(!("all_invyrs" %in% existing_tables)) {
    all_invyrs <- data.frame(INVYR = c(2000:2024))
    
    arrow::to_duckdb(all_invyrs, con, "all_invyrs")
    dbSendStatement(con, "CREATE TABLE all_invyrs AS SELECT * FROM all_invyrs")
  }
  
  trees <- tbl(con, "tree") |>
    mutate(ACTUALHT = as.numeric(ACTUALHT)) |>
    left_join(tbl(con, "tree_info_composite_id")) |>
    filter(NRECORDS > 1) |>
    filter(!is.na(DIA), !is.na(HT), !is.na(ACTUALHT)) |>
    select(TREE_COMPOSITE_ID, INVYR, DIA, HT, ACTUALHT, TREE_CN, PLT_CN, CONDID, STATUSCD, MORTYR) |> 
    group_by(TREE_COMPOSITE_ID) |>
    mutate(NRECORDS_NONA = n(),
           next_INVYR = lead(INVYR, order_by = INVYR),
           next_DIA = lead(DIA, order_by = INVYR),
           next_HT = lead(HT, order_by = INVYR),
           next_ACTUALHT = lead(ACTUALHT, order_by = INVYR)) |>
    filter(NRECORDS_NONA > 1) |>
    mutate(next_INVYR = next_INVYR - 1) |>
    mutate(
      next_INVYR = ifelse(is.na(next_INVYR), INVYR, next_INVYR),
      next_DIA = ifelse(is.na(next_DIA), DIA, next_DIA),
      next_HT = ifelse(is.na(next_HT), HT, next_HT),
      next_ACTUALHT = ifelse(is.na(next_ACTUALHT), ACTUALHT, next_ACTUALHT)) |>
    mutate(DIA_slope = (next_DIA - DIA) / ((next_INVYR + 1) - INVYR),
           HT_slope = (next_HT - HT) / ((next_INVYR + 1) - INVYR),
           ACTUALHT_slope = (next_ACTUALHT - ACTUALHT) / ((next_INVYR + 1) - INVYR)) 
  
  all_years <- tbl(con, "tree") |>
    select(TREE_COMPOSITE_ID) |>
    distinct() |>
    cross_join(tbl(con, "all_invyrs")) |>
    arrange(TREE_COMPOSITE_ID, INVYR) |>
    rename(YEAR = INVYR) 
  
  by <- join_by(TREE_COMPOSITE_ID, between(YEAR, INVYR, next_INVYR, bounds = "[]"))
  
  trees_annual_measures <- all_years |> 
    inner_join(trees, by) |>
    mutate(time_run = YEAR - INVYR,
           DIA_start = DIA,
           HT_start = HT,
           ACTUALHT_start = ACTUALHT) |>
    mutate(DIA_est = DIA_start + (DIA_slope * time_run),
           HT_est = HT_start + (HT_slope * time_run),
           ACTUALHT_est = ACTUALHT_start + (ACTUALHT_slope * time_run)) |>
    arrange(TREE_COMPOSITE_ID, YEAR) |>
    select(TREE_COMPOSITE_ID, TREE_CN, PLT_CN, CONDID, YEAR, DIA_est, HT_est, ACTUALHT_est, STATUSCD, MORTYR)
  
  tree_cns <- trees_annual_measures |>
    select(TREE_CN) |>
    distinct()
  

  trees_with_morts <- tbl(con, "tree") |>
    mutate(MORTYR = as.numeric(MORTYR)) |>
    filter(!is.na(MORTYR)) |>
    inner_join(tree_cns) |>
    select(TREE_CN, TREE_COMPOSITE_ID, INVYR, MORTYR) |> 
    group_by(TREE_COMPOSITE_ID) |>
    summarize(LAST_MORTYR = max(MORTYR)) |>
    ungroup() 
  
  tree_morts <- trees |>
    right_join(trees_with_morts) |>
    arrange(TREE_COMPOSITE_ID, INVYR) |>
    filter(LAST_MORTYR > INVYR,
           LAST_MORTYR < next_INVYR) |>
    mutate(DIA_slope = (next_DIA - DIA)/(LAST_MORTYR - INVYR),
           HT_slope = (next_HT - HT) / (LAST_MORTYR - INVYR),
           ACTUALHT_slope = (next_ACTUALHT - ACTUALHT) / (LAST_MORTYR - INVYR)) 
  
  tree_morts_annual_measures <- all_years |> 
    inner_join(tree_morts, by) |>
    mutate(time_run = YEAR - INVYR,
           DIA_start = DIA,
           HT_start = HT,
           ACTUALHT_start = ACTUALHT,
           DIA_stop = next_DIA,
           HT_stop = next_HT,
           ACTUALHT_stop = next_ACTUALHT) |>
    mutate(DIA_est_mort = ifelse(YEAR <= LAST_MORTYR,
                                 DIA_start + (DIA_slope * time_run),
                                 DIA_stop),
           HT_est_mort = ifelse(YEAR <= LAST_MORTYR,
                                HT_start + (HT_slope * time_run),
                                HT_stop),
           ACTUALHT_est_mort = ifelse(YEAR <= LAST_MORTYR,
                                      ACTUALHT_start + (ACTUALHT_slope * time_run),
                                      ACTUALHT_stop)) |>
    arrange(TREE_COMPOSITE_ID, YEAR) |>
    select(TREE_COMPOSITE_ID, TREE_CN, PLT_CN, CONDID, YEAR, DIA_est_mort, HT_est_mort, ACTUALHT_est_mort) 
  
  trees_annual_measures <- left_join(trees_annual_measures,
                                     tree_morts_annual_measures) |>
    mutate(DIA_est_mort = ifelse(is.na(DIA_est_mort),
                                 DIA_est,
                                 DIA_est_mort),
           HT_est_mort = ifelse(is.na(HT_est_mort),
                                 HT_est,
                                 HT_est_mort),
           ACTUALHT_est_mort = ifelse(is.na(ACTUALHT_est_mort),
                                 ACTUALHT_est,
                                 ACTUALHT_est_mort)) |>
    group_by(TREE_COMPOSITE_ID) |>
    mutate(DIES = any(STATUSCD == 2)) |>
    collect()
  
  arrow::to_duckdb(trees_annual_measures, table_name = "tree_annualized", con = con)
  dbExecute(con, "CREATE TABLE tree_annualized AS SELECT * FROM tree_annualized")
  
  return()
  
}