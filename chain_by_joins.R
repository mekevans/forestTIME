chain_by_joins <- function(tree_table) {
  
  
  
  cycles <- tree_table |> select(CYCLE) |> distinct() |> arrange(CYCLE) |> compute()
  
  cycle_trees <- tree_table |>
    select(CN, PREV_TRE_CN, CYCLE) |>
    compute()
  
  known_trees <- cycle_trees |> 
    select(CN, CYCLE) |>
    mutate(TREE_FIRST_CN = ifelse(CYCLE == cycles$CYCLE[1], CN, NA)) |>
    select(-CYCLE) |>
    compute()
  
  for(i in 2:nrow(cycles)) {
    
    thiscycle_trees <- cycle_trees |>
      filter(CYCLE == cycles$CYCLE[i]) |>
      select(-CYCLE) |>
      left_join(select(known_trees, CN, TREE_FIRST_CN), by = c("PREV_TRE_CN" = "CN")) |>
      mutate(TREE_FIRST_CN = ifelse(is.na(TREE_FIRST_CN), CN, TREE_FIRST_CN)) |>
      compute()
    
    known_trees <- known_trees |>
      left_join(thiscycle_trees |> select(-PREV_TRE_CN), by = c("CN")) |>
      mutate(TREE_FIRST_CN = ifelse(is.na(TREE_FIRST_CN.x), ifelse(is.na(TREE_FIRST_CN.y), NA, TREE_FIRST_CN.y), TREE_FIRST_CN.x)) |>
      select(CN, TREE_FIRST_CN) |> 
      compute()
    
  }
  
  known_trees <- known_trees |>
    left_join(tree_table |> select(CN, STATECD, COUNTYCD))
  
  known_trees
}
