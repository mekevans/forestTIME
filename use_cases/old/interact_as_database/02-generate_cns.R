library("duckdb")
library("dplyr")
con <-
  dbConnect(duckdb(
    dbdir = here::here("foresttime-cli.duckdb")
  ))
dbListTables(con)

trees <- tbl(con, "tree_raw") 

chain_by_joins <- function(tree_table) {
  cycles <-
    tree_table |>
    select(INVYR) |>
    distinct() |>
    arrange(INVYR) |>
    collect()
  
  cycle_trees <- tree_table |>
    select(CN, PREV_TRE_CN, INVYR) |> compute()
  
  known_trees <- cycle_trees |>
    select(CN, INVYR) |>
    mutate(TREE_FIRST_CN = ifelse(INVYR == !!cycles$INVYR[1], CN, NA)) |>
    select(-INVYR) |>
    compute()
  
  for (i in 2:nrow(cycles)) {
    thiscycle_trees <- cycle_trees |>
      filter(INVYR == !!cycles$INVYR[i]) |>
      select(-INVYR) |>
      left_join(select(known_trees, CN, TREE_FIRST_CN),
                by = c("PREV_TRE_CN" = "CN")) |>
      mutate(TREE_FIRST_CN = 
               ifelse(is.na(TREE_FIRST_CN), 
                      CN, TREE_FIRST_CN)) |>
      compute()
    
    known_trees <- known_trees |>
      left_join(thiscycle_trees |> 
                  select(-PREV_TRE_CN), by = c("CN")) |>
      mutate(TREE_FIRST_CN = ifelse(
        is.na(TREE_FIRST_CN.x),
        ifelse(is.na(TREE_FIRST_CN.y), NA, TREE_FIRST_CN.y),
        TREE_FIRST_CN.x
      )) |>
      select(CN, TREE_FIRST_CN) |>
      compute()
    
  }
  
  known_trees <- known_trees |>
    left_join(tree_table) |>
    select(CN, TREE_FIRST_CN, STATECD, COUNTYCD)
  
  known_trees
}

tree_cns <- chain_by_joins(trees) |>
  collect() 

arrow::to_duckdb(tree_cns, table_name = "tree_cns", con = con)
dbSendQuery(con, "CREATE TABLE tree_cns AS SELECT * FROM tree_cns")

dbDisconnect(con, shutdown = TRUE)
