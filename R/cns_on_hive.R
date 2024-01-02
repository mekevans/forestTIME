# Uses joins to create a CN table
create_cn_tables_join <- function(state_number = 9,
                             arrow_dir = "data/arrow") {
  
  raw_trees <- open_dataset(
    here::here(arrow_dir, "TREE_RAW"),
    partitioning = c("STATECD", "COUNTYCD"),
    format = "csv",
    hive_style = T,
    col_types = schema(
      CN = float64(),
      TREE_FIRST_CN = float64()
    )) |>
    filter(STATECD %in% state_number)  

  trees_cns <- chain_by_joins(raw_trees) 
  
  write_dataset(trees_cns,
                here::here(arrow_dir, "TREE_CN_JOIN"),
                format = "csv",
                partitioning = c("STATECD", "COUNTYCD"))
  
}