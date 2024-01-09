create_tree_info <- function(states_to_include = NULL, arrow_dir = "data/arrow") {
  
  if(is.null(states_to_include)) {
    states_to_include = 1:56
  }
  # 
  # cns <-
  #   open_dataset(
  #     here::here(arrow_dir, "TREE_CN_JOIN"),
  #     partitioning = c("STATECD", "COUNTYCD"),
  #     format = "csv",
  #     hive_style = T,
  #     col_types = schema(
  #       CN = float64(),
  #       TREE_FIRST_CN = float64()
  #     )) |>
  #   filter(STATECD %in% states_to_include)
  
  trees <- open_dataset(
    here::here(arrow_dir, "TREE_RAW"),
    partitioning = c("STATECD", "COUNTYCD"),
    format = "csv",
    hive_style = T) |>
    filter(STATECD %in% states_to_include)
  
  trees_info <- trees |>
    group_by(TREE_UNIQUE_ID,
             PLOT_UNIQUE_ID) |>
    summarize(NYEARS = dplyr::n(),
              NYEARS_MEASURED = sum(STATUSCD != 0),
              FIRSTYR = min(INVYR),
              LASTYR = max(INVYR),
              SPCD = min(SPCD),
              PLOT = min(PLOT),
              SUBPLOT = min(SUBP),
              STATECD = min(STATECD),
              COUNTYCD = min(COUNTYCD),
              SPCDS = n_distinct(SPCD)) |>
    ungroup() |>
    # Removes trees with multiple species codes recorded.
    filter(SPCDS == 1)
  
  write_dataset(trees_info, path = here::here(arrow_dir, "TREE_INFO"), 
                format = "csv",
                partitioning = c("STATECD", "COUNTYCD"))
}