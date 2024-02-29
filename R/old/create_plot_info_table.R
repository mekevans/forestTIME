create_plot_info <- function(state_to_use = "AL", arrow_dir = "data/arrow") {
  
  plots <- open_dataset(
    here::here(arrow_dir, "PLOT_RAW", state_to_use),
    partitioning = c("STATECD", "COUNTYCD"),
    format = "csv",
    hive_style = T) |>
    select(PLOT_UNIQUE_ID, 
           PLOT,
           STATECD,
           COUNTYCD,
           UNITCD,
           INVYR,
           LAT,
           LON,
           ELEV) |>
    compute()
  
  plot_info <- plots |>
    group_by(PLOT_UNIQUE_ID,
             PLOT,
             STATECD,
             COUNTYCD,
             UNITCD) |>
    summarize(NYEARS = dplyr::n(),
              FIRSTYR = min(INVYR),
              LASTYR = max(INVYR),
              LAT = min(LAT),
              LON = min(LON),
              ELEV = min(ELEV),
              LATS = n_distinct(LAT),
              LONS = n_distinct(LON),
              ELEVS = n_distinct(ELEV)) |>
    ungroup() |>
    filter(LATS == 1,
           LONS == 1,
           ELEVS == 1) |>
    compute()
  
  
  write_dataset(plot_info, path = here::here(arrow_dir, "PLOT_INFO", state_to_use), 
                format = "csv",
                partitioning = c("STATECD", "COUNTYCD"))
}