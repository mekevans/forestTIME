library(duckdbfs)
library(dplyr)

select_trees <-
  function(conditions = list(NYEARS_MEASURED = list(">=", 1)),
           connection = "local",
           local_dir = here::here("data", "arrow")) {
    if (connection == "local") {
      tree_sources = list.files(
        here::here(local_dir, "TREE_INFO"),
        recursive = T,
        full.names = T
      )
      tree_hive = T
    } 
    else {
      stop("Sorry, I haven't set up remote yet!")
      # tree_sources = "https://github.com/diazrenata/in-the-trees/raw/demo/static_data/processed_tables/mn_info.csv"
      # tree_hive = F
    }
    
    calls <- construct_list_condition(conditions)
    
    tree_info <-  duckdbfs::open_dataset(
      sources = tree_sources,
      hive_style = tree_hive,
      format = "csv",
      schema = schema(STATECD = float64())
    ) |>
      dplyr::mutate(STATECD = as.numeric(STATECD),
                    COUNTYCD = as.numeric(COUNTYCD)) |>
      dplyr::filter(!!!calls) |>
      collect()
    
  }

get_temporal_data <- function(selected_trees,
                                  conditions = list(STATUSCD = list("==", "1")),
                                  variables = "all",
                                  connection = "local",
                                  local_dir = here::here("data", "arrow")) {
  if (connection == "local") {
    #  cn_sources = list.files(here::here(local_dir, "TREE_CN_JOIN"), recursive = T, full.names = T)
    raw_tree_sources = list.files(
      here::here(local_dir, "TREE_RAW"),
      recursive = T,
      full.names = T
    )
    raw_plot_sources = list.files(
      here::here(local_dir, "PLOT_RAW"),
      recursive = T,
      full.names = T
    )
    raw_cond_sources = list.files(
      here::here(local_dir, "COND_RAW"),
      recursive = T,
      full.names = T
    )
    
    #  cn_hive = T
  } else {
    ## cn_sources = "https://github.com/diazrenata/in-the-trees/raw/demo/static_data/processed_tables/mn_cns.csv"
    
    # counties <-
    #   c(
    #     "1",
    #     "101",
    #     "103",
    #     "107",
    #     "109",
    #     "11",
    #     "111",
    #     "113",
    #     "115",
    #     "119",
    #     "121",
    #     "123",
    #     "125",
    #     "127",
    #     "129",
    #     "13",
    #     "131",
    #     "135",
    #     "137",
    #     "139",
    #     "141",
    #     "143",
    #     "145",
    #     "147",
    #     "149",
    #     "15",
    #     "151",
    #     "153",
    #     "155",
    #     "157",
    #     "159",
    #     "161",
    #     "163",
    #     "165",
    #     "167",
    #     "169",
    #     "17",
    #     "171",
    #     "173",
    #     "19",
    #     "21",
    #     "23",
    #     "25",
    #     "27",
    #     "29",
    #     "3",
    #     "31",
    #     "33",
    #     "35",
    #     "37",
    #     "39",
    #     "41",
    #     "43",
    #     "45",
    #     "47",
    #     "49",
    #     "5",
    #     "51",
    #     "53",
    #     "55",
    #     "57",
    #     "59",
    #     "61",
    #     "63",
    #     "65",
    #     "67",
    #     "69",
    #     "7",
    #     "71",
    #     "73",
    #     "75",
    #     "77",
    #     "79",
    #     "81",
    #     "83",
    #     "85",
    #     "87",
    #     "89",
    #     "9",
    #     "91",
    #     "93",
    #     "95",
    #     "97",
    #     "99"
    #   )
    # raw_sources <-
    #   paste0(
    #     "https://github.com/diazrenata/in-the-trees/raw/demo/static_data/processed_tables/STATECD=27/COUNTYCD=",
    #     counties,
    #     "/part-0.csv"
    #   )
    ##  cn_hive = F
    stop("Sorry, I haven't set up remote yet!")
  }
  
  selected_tree_ids <- selected_trees$TREE_UNIQUE_ID
  
  calls <- construct_list_condition(condition_list = conditions)
  
  # selected_cns <- selected_trees$TREE_FIRST_CN
  #
  # cns <-
  #   duckdbfs::open_dataset(
  #     sources = cn_sources,
  #     hive_style = cn_hive,
  #     format = "csv"
  #   ) |>
  #   dplyr::filter(TREE_FIRST_CN %in% selected_cns) |>
  #   compute()
  
  plot_raw <-
    duckdbfs::open_dataset(sources = raw_plot_sources,
                           hive_style = T,
                           format = "csv") |>
    rename(PLT_CN = CN)
  cond_raw <-
    duckdbfs::open_dataset(sources = raw_cond_sources,
                           hive_style = T,
                           format = "csv")
  
  
  tree_timeseries <-
    duckdbfs::open_dataset(sources = raw_tree_sources,
                           hive_style = T,
                           format = "csv") |>
    rename(TREE_CN = CN) |>
    left_join(plot_raw) |>
    left_join(cond_raw) |>
    dplyr::mutate(STATECD = as.numeric(STATECD),
                  COUNTYCD = as.numeric(COUNTYCD)) |>
    filter(TREE_UNIQUE_ID %in% selected_tree_ids) |>
    filter(!!!calls) |>
    compute()
  
  if (any(variables != "all")) {
    report_cols <- c(
      c(
        "TREE_UNIQUE_ID",
        "PLOT_UNIQUE_ID",
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
    
    tree_timeseries <- tree_timeseries |>
      select(all_of(report_cols)) |>
      compute()
  }
  
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
           connection = "local",
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
    
    selected_trees <-
      select_trees(
        conditions = static_conditions,
        connection = connection,
        local_dir = local_dir
      )
    
    timeseries <-
      get_temporal_data(selected_trees,
        conditions = changing_conditions,
        variables = variables,
        connection = connection,
        local_dir = local_dir
      )
    
    return(timeseries)
    
  }
