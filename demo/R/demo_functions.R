library(arrow)

select_trees <- function(state = 27,
                         county = 0:1000,
                         plot = 0:100000,
                         spcd = 0:10000,
                         min_years = 1,
                         min_measurements = 1) {
  tree_info <-  open_dataset(
    here::here("data", "arrow", "TREE_INFO"),
    partitioning = c("STATECD", "COUNTYCD"),
    format = "csv",
    hive_style = T,
    col_types = schema(TREE_FIRST_CN = float64())
  ) |>
    dplyr::filter(
      STATECD %in% state,
      COUNTYCD %in% county,
      PLOT %in% plot,
      SPCD %in% spcd,
      NYEARS_MEASURED >= min_measurements,
      LASTYR - FIRSTYR >= min_years
    ) |>
    collect()
  
  tree_info
  
}


get_timeseries <- function(selected_trees,
                           min_year = 1900,
                           max_year = 2100,
                           variables = c("DIA",
                                         "HT",
                                         "STATUSCD")) {
  arrow_dir <- here::here("data", "arrow")
  
  report_cols <-
    c(
      c(
        "TREE_FIRST_CN",
        "CN",
        "INVYR",
        "STATECD",
        "COUNTYCD",
        "UNITCD",
        "PLOT",
        "SUBP",
        "TREE"
      ),
      variables
    )
  cns <-
    open_dataset(
      here::here(arrow_dir, "TREE_CN_JOIN"),
      partitioning = c("STATECD", "COUNTYCD"),
      format = "csv",
      hive_style = T,
      col_types = schema(CN = float64(),
                         TREE_FIRST_CN = float64())
    ) |>
    filter(TREE_FIRST_CN %in% selected_trees$TREE_FIRST_CN) |>
    compute()
  
  timeseries <-
    open_dataset(
      here::here(arrow_dir, "TREE_RAW"),
      partitioning = c("STATECD", "COUNTYCD"),
      format = "csv",
      hive_style = T,
      col_types = schema(CN = float64(),
                         TREE_FIRST_CN = float64())
    ) |>
    inner_join(cns) |>
    select(all_of(report_cols)) |>
    filter(INVYR >= min_year,
           INVYR <= max_year) |>
    collect()
  
  timeseries
  
  
}
