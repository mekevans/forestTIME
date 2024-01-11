create_plot_info <- function(states_to_include = NULL, arrow_dir = "data/arrow") {
  
  if(is.null(states_to_include)) {
    states_to_include = 1:56
  }
  
  
  plots <- open_dataset(
    here::here(arrow_dir, "PLOT_RAW"),
    partitioning = c("STATECD", "COUNTYCD"),
    format = "csv",
    hive_style = T,
    col_types = schema(PLOT_NONSAMPLE_REASN_CD = float64())) |>
    filter(STATECD %in% states_to_include) |>
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
  
  
  write_dataset(plot_info, path = here::here(arrow_dir, "PLOT_INFO"), 
                format = "csv",
                partitioning = c("STATECD", "COUNTYCD"))
}