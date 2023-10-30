create_tree_info <- function(states_to_include = NULL, arrow_dir = "data/arrow") {
  
  if(is.null(states_to_include)) {
    states_to_include = 1:56
  }
  
  cns <-
    open_dataset(
      here::here(arrow_dir, "TREE_CN_JOIN"),
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
  
  trees_info <- trees |>
    left_join(cns) |>
    group_by(TREE_FIRST_CN) |>
    summarize(NYEARS = dplyr::n(),
              NYEARS_MEASURED = sum(STATUSCD != 0),
              FIRSTYR = min(INVYR),
              LASTYR = max(INVYR),
              SPCD = min(SPCD),
              PLOT = min(PLOT),
              STATECD = min(STATECD),
              COUNTYCD = min(COUNTYCD),
              SPCDS = n_distinct(SPCD),
              PLOTS = n_distinct(PLOT),
              STATES = n_distinct(STATECD),
              COUNTIES = n_distinct(COUNTYCD)) |>
    ungroup() |>
    # Removes trees with multiple species codes, plots, states, or counties recorded.
    # This is a big decision, probably one to run by an FIA expert and/or allow a user to modify.
    filter(SPCDS == 1,
           PLOTS == 1,
           STATES == 1,
           COUNTIES == 1) |> 
    select(-c(SPCDS, PLOTS, STATES, COUNTIES)) 
  
  write_dataset(trees_info, path = here::here(arrow_dir, "TREE_INFO"), 
                format = "csv",
                partitioning = c("STATECD", "COUNTYCD"))
}