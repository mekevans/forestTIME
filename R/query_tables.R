library(duckdbfs)
library(dplyr)

select_trees <-
  function(conditions = list(NYEARS_MEASURED = list(">=", 1)),
           states_to_use = NULL,
           local_dir = here::here("data", "arrow")) {
    tree_sources = list.files(here::here(local_dir, "TREE_INFO"),
                              recursive = T,
                              full.names = T)
    tree_hive = T
    

    if (length(conditions) < 1) {
      calls <- NULL
    } else {
      calls <- construct_list_condition(conditions)
    }
    
    if (!is.null(states_to_use)) {
      tree_sources_states <- tree_sources |>
        strsplit("STATECD=") |>
        lapply(purrr::pluck, 2) |>
        unlist() |>
        strsplit("/COUNTYCD") |>
        lapply(purrr::pluck, 1) |>
        as.numeric()
      
      tree_sources = tree_sources[which(tree_sources_states %in% states_to_use)]
      
    }
    
    tree_info <-  duckdbfs::open_dataset(
      sources = tree_sources,
      hive_style = tree_hive,
      format = "csv"
    ) |>
      dplyr::mutate(STATECD = as.numeric(STATECD),
                    COUNTYCD = as.numeric(COUNTYCD)) |>
      dplyr::filter(!!!calls) |>
      collect()
    tree_info
    
  }

get_temporal_data <- function(selected_trees,
                              states_to_use = NULL,
                              conditions = list(STATUSCD = list("==", "1")),
                              variables = "all",
                              local_dir = here::here("data", "arrow")) {
  raw_tree_sources = list.files(here::here(local_dir, "TREE_RAW"),
                                recursive = T,
                                full.names = T)
  raw_plot_sources = list.files(here::here(local_dir, "PLOT_RAW"),
                                recursive = T,
                                full.names = T)
  raw_cond_sources = list.files(here::here(local_dir, "COND_RAW"),
                                recursive = T,
                                full.names = T)

  selected_tree_ids <- selected_trees$TREE_UNIQUE_ID
  
  if (length(conditions) < 1) {
    calls <- NULL
  } else {
    calls <- construct_list_condition(conditions)
  }
  
  if (!is.null(states_to_use)) {
    raw_tree_sources_states <- raw_tree_sources |>
      strsplit("STATECD=") |>
      lapply(purrr::pluck, 2) |>
      unlist() |>
      strsplit("/COUNTYCD") |>
      lapply(purrr::pluck, 1) |>
      as.numeric()
    
    raw_tree_sources = raw_tree_sources[which(raw_tree_sources_states %in% states_to_use)]
    
    raw_plot_sources_states <- raw_plot_sources |>
      strsplit("STATECD=") |>
      lapply(purrr::pluck, 2) |>
      unlist() |>
      strsplit("/COUNTYCD") |>
      lapply(purrr::pluck, 1) |>
      as.numeric()
    
    raw_plot_sources = raw_plot_sources[which(raw_plot_sources_states %in% states_to_use)]
    
    raw_cond_sources_states <- raw_cond_sources |>
      strsplit("STATECD=") |>
      lapply(purrr::pluck, 2) |>
      unlist() |>
      strsplit("/COUNTYCD") |>
      lapply(purrr::pluck, 1) |>
      as.numeric()
    
    raw_cond_sources = raw_cond_sources[which(raw_cond_sources_states %in% states_to_use)]
    
  }
  
  needed_variables <- c('TREE_UNIQUE_ID',
                        'PLOT_UNIQUE_ID',
                        'SPCD',
                        'PLOT',
                        'SUBPLOT',
                        'SPCDS',
                        'COUNTYCD',
                        'STATECD',
                        'PLT_CN',
                        'INVYR',
                        'CYCLE',
                        'MEASYEAR',
                        'CN',
                        'COND_CN',
                        'CONDID')
  
  plot_raw <-
    duckdbfs::open_dataset(sources = raw_plot_sources,
                           hive_style = T,
                           format = "csv") |>
    rename(PLT_CN = CN) |>
    select(-any_of(c("CREATED_BY", "CREATED_DATE", "CREATED_IN_INSTANCE", "MODIFIED_BY", "MODIFIED_DATE", "MODIFIED_IN_INSTANCE")))
  
  cond_raw <-
    duckdbfs::open_dataset(sources = raw_cond_sources,
                           hive_style = T,
                           format = "csv")|>
    select(-HABTYPCD1) |>
    rename(COND_CN = CN) |>
    select(-any_of(c("CREATED_BY", "CREATED_DATE", "CREATED_IN_INSTANCE", "MODIFIED_BY", "MODIFIED_DATE", "MODIFIED_IN_INSTANCE")))

  
  tree_timeseries <-
    duckdbfs::open_dataset(sources = raw_tree_sources,
                           hive_style = T,
                           format = "csv") |>
    rename(TREE_CN = CN) |>
    filter(TREE_UNIQUE_ID %in% selected_tree_ids) |>
    left_join(plot_raw) |>
    left_join(cond_raw) |>
    dplyr::mutate(STATECD = as.numeric(STATECD),
                  COUNTYCD = as.numeric(COUNTYCD)) |>
    filter(!!!calls) |>
    arrange(PLOT_UNIQUE_ID, TREE_UNIQUE_ID, INVYR) |>
    compute()
  
  if (any(variables != "all")) {
    report_cols <- c(
      needed_variables,
      variables
    )
  } else {
    report_cols <- colnames(tree_timeseries)
  }
  
  tree_timeseries <- tree_timeseries |>
    select(any_of(report_cols)) |>
    compute()
  
  tree_timeseries |>
    collect()
  
}

construct_list_condition = function(condition_list = list(kitten_age = list("%in%", c(8, 6)))) {
  calls <- list()
  
  for (i in 1:length(condition_list)) {
    calls[[i]] <- call(unlist(condition_list[[i]][1]),
                       as.name(names(condition_list)[i]),
                       unlist(condition_list[[i]][2]))
    
  }
  calls
}

get_timeseries <-
  function(conditions = list(STATECD = list("==", 27),
                             STATUSCD = list("==", 1)),
           variables = "all",
           local_dir = here::here("data", "arrow")) {
    static_names <-
      c(
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
    
    static_conditions = conditions[which(names(conditions) %in% static_names)]
    changing_conditions = conditions[which(!(names(conditions) %in% static_names))]
    
    if ("STATECD" %in% names(conditions)) {
      states_to_use = conditions$STATECD[[2]]
    } else {
      states_to_use = NULL
    }
    
    selected_trees <-
      select_trees(
        conditions = static_conditions,
        states_to_use = states_to_use,
        local_dir = local_dir
      )
    
    timeseries <-
      get_temporal_data(
        selected_trees,
        states_to_use = states_to_use,
        conditions = changing_conditions,
        variables = variables,
        local_dir = local_dir
      )
    
    return(timeseries)
    
  }
