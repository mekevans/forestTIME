# Uses joins to create a CN table
create_cn_tables_join <- function(state_to_use,
                             arrow_dir = "data/arrow") {
  
  raw_trees <- open_dataset(
    here::here(arrow_dir, "TREE_RAW", state_to_use),
    partitioning = c("STATECD", "COUNTYCD"),
    format = "csv",
    hive_style = T,
    col_types = schema(
      CN = float64(),
      PREV_TRE_CN = float64(),
      MORTCD = float64()
    ))  

  trees_cns <- chain_by_joins(raw_trees) 
  
  write_dataset(trees_cns,
                here::here(arrow_dir, "TREE_CN_JOIN", state_to_use),
                format = "csv",
                partitioning = c("STATECD", "COUNTYCD"))
  
}