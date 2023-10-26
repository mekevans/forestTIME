create_tree_change<- function(states_to_include = NULL, arrow_dir = "data/arrow") {
  
  if(is.null(states_to_include)) {
    states_to_include = 1:56
  }

  cns <-
    open_dataset(
      here::here(arrow_dir, "TREE_CNS"),
      partitioning = c("STATECD", "COUNTYCD"),
      format = "csv",
      hive_style = T,
      col_types = schema(
        CN = float64(),
        TREE_FIRST_CN = float64()
      )) |>
    filter(STATECD %in% states_to_include) 
  
  trees <- open_dataset(
    here::here(arrow_dir, "TREE_RAW"),
    partitioning = c("STATECD", "COUNTYCD"),
    format = "csv",
    hive_style = T) |>
    filter(STATECD %in% states_to_include)
  
  remeasured_trees <-  open_dataset(
    here::here(arrow_dir, "TREE_INFO"),
    partitioning = c("STATECD", "COUNTYCD"),
    format = "csv",
    hive_style = T,
    col_types = schema(TREE_FIRST_CN = float64())) |>
    filter(STATECD %in% states_to_include,
           NYEARS_MEASURED > 1) |>
    select(TREE_FIRST_CN) |>
    compute()
  
  remeasured_tree_measurements <- cns |>
    filter(TREE_FIRST_CN %in% remeasured_trees$TREE_FIRST_CN) |> 
    left_join(trees) |>
    compute()
  
  # I think this join works but check it when fresh
  new_measures <-
    inner_join(
      remeasured_tree_measurements,
      remeasured_tree_measurements,
      by = c(
        "TREE_FIRST_CN" = "TREE_FIRST_CN",
        "STATECD" = "STATECD",
        "COUNTYCD" = "COUNTYCD",
        "PLOT" = "PLOT",
        "SPCD" = "SPCD",
        "PREV_TRE_CN" = "CN"
      ),
      suffix = c("_CURRENT", "_PREV")
    ) |>
    rename(CN_CURRENT = CN,
           CN_PREV = PREV_TRE_CN_CURRENT) |>
    select(-PREV_TRE_CN_PREV)
  
  write_dataset(new_measures,
                here::here(arrow_dir, "TREE_CHANGE"),
                format = "csv",
                partitioning = c("STATECD", "COUNTYCD"))
}