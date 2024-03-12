create_tree_info <- function(state_to_use = "AL" , arrow_dir = "data/arrow") {
  
  
  trees <- open_dataset(
    here::here(arrow_dir, "TREE_RAW", state_to_use),
    partitioning = c("STATECD", "COUNTYCD"),
    format = "csv",
    hive_style = T) |>
    select(TREE_UNIQUE_ID,
           PLOT_UNIQUE_ID,
           STATUSCD,
           INVYR,
           SPCD,
           PLOT,
           SUBP,
           STATECD,
           COUNTYCD) |>
    compute()
  
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
  
  write_dataset(trees_info, path = here::here(arrow_dir, "TREE_INFO", state_to_use), 
                format = "csv",
                partitioning = c("STATECD", "COUNTYCD"))
}