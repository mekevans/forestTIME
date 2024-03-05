# library("duckdb")
# library("dplyr")
# 
# con <- 
#   dbConnect(duckdb(
#     dbdir = here::here("data", "db", "derived_tables3.duckdb")
#   ))

trees <- tbl(con, "tree") 

chain_by_joins <- function(tree_table) {
  cycles <-
    tree_table |>
    select(INVYR) |>
    distinct() |>
    arrange(INVYR) |>
    collect()
  
  cycle_trees <- tree_table |>
    select(TREE_CN, PREV_TRE_CN, INVYR) |> compute()
  
  known_trees <- cycle_trees |>
    select(TREE_CN, INVYR) |>
    mutate(TREE_FIRST_CN = ifelse(INVYR == !!cycles$INVYR[1], TREE_CN, NA)) |>
    select(-INVYR) |>
    compute()
  
  for (i in 2:nrow(cycles)) {
    thiscycle_trees <- cycle_trees |>
      filter(INVYR == !!cycles$INVYR[i]) |>
      select(-INVYR) |>
      left_join(select(known_trees, TREE_CN, TREE_FIRST_CN),
                by = c("PREV_TRE_CN" = "TREE_CN")) |>
      mutate(TREE_FIRST_CN = 
               ifelse(is.na(TREE_FIRST_CN), 
                      TREE_CN, TREE_FIRST_CN)) |>
      compute()
    
    known_trees <- known_trees |>
      left_join(thiscycle_trees |> 
                  select(-PREV_TRE_CN), by = c("TREE_CN")) |>
      mutate(TREE_FIRST_CN = ifelse(
        is.na(TREE_FIRST_CN.x),
        ifelse(is.na(TREE_FIRST_CN.y), NA, TREE_FIRST_CN.y),
        TREE_FIRST_CN.x
      )) |>
      select(TREE_CN, TREE_FIRST_CN) |>
      compute()
    
  }
  
  known_trees <- known_trees |>
    left_join(tree_table) |>
    select(TREE_CN, TREE_FIRST_CN, STATECD, COUNTYCD)
  
  known_trees
}

chain_by_joins(trees) |>
  collect() |>
  arrow::to_duckdb(table_name = "tree_cns", con = con)

dbSendQuery(con, "CREATE TABLE tree_cns AS SELECT * FROM tree_cns")

# dbDisconnect(con, shutdown = TRUE)

