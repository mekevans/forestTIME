library(palmerpenguins)

forestTIME_filters <- function(...) {
  rlang::enquos(...)
}

forestTIME_filter <- function(some_data, filter_criteria = forestTIME_filters(...)) {
  
  filter_args <- filter_critera |>
    lapply(rlang::as_label) |>
    unlist() |>
    strsplit(split = " ") |>
    lapply(purrr::pluck, 1) |>
    unlist()
  
  static_variables <- c(
    'TREE_UNIQUE_ID',
    'PLOT_UNIQUE_ID',
    'NYEARS',
    'NYEARS_MEASURED',
    'FIRSTYR',
    'LASTYR',
    'SPCD',
    'PLOT',
    'SUBPLOT',
    'SPCDS',
    'COUNTYCD',
    'STATECD'
  )
  
  static_filters <- filter_criteria[[ which(filter_args %in% static_variables)]]
  
  dynamic_filters <- filter_criteria[[ which(!(filter_args %in% static_variables))]]
  
  
  selected_trees <-
    select_trees(connection = connection,
                 local_dir = local_dir,
                 filters = static_filters)
  
  timeseries <-
    get_temporal_data(
      selected_trees,
      filters = dynamic_filters,
      variables = variables,
      connection = connection,
      local_dir = local_dir
    )
  
  return(timeseries)
}
