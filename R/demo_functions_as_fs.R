library(duckdbfs)
library(dplyr)

select_trees <- function(state = 27,
                         county = 0:1000,
                         plot = 0:100000,
                         spcd = 0:10000,
                         min_years = 1,
                         min_measurements = 1,
                         connection = "local",
                         local_dir = here::here("data", "arrow")) {
  if(connection == "local") {
    tree_sources = list.files(here::here(local_dir, "TREE_INFO"), recursive = T, full.names = T)
    tree_hive = T
  } else {
    tree_sources = "https://github.com/diazrenata/in-the-trees/raw/demo/static_data/processed_tables/mn_info.csv"
    tree_hive = F
  }
  
  
  tree_info <-  duckdbfs::open_dataset(
    sources = tree_sources,
    hive_style = tree_hive,
    format = "csv",
    schema = schema(STATECD = float64())
  ) |>
    dplyr::mutate(STATECD = as.numeric(STATECD),
                  COUNTYCD = as.numeric(COUNTYCD)) |> 
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
                                         "STATUSCD"),
                           connection = "local",
                           local_dir = here::here("data", "arrow")) {
  if(connection == "local") {
    cn_sources = list.files(here::here(local_dir, "TREE_CN_JOIN"), recursive = T, full.names = T)
    raw_sources = list.files(here::here(local_dir, "TREE_RAW"), recursive = T, full.names = T)
    cn_hive = T
  } else {
    cn_sources = "https://github.com/diazrenata/in-the-trees/raw/demo/static_data/processed_tables/mn_cns.csv"
    
    counties <- c("1", "101", "103", "107", "109", "11", "111", "113", "115", "119", "121", "123", "125", "127", "129", "13", "131", "135", "137", "139", "141", "143", "145", "147", "149", "15", "151", "153", "155", "157", "159", "161", "163", "165", "167", "169", "17", "171", "173", "19", "21", "23", "25", "27", "29", "3", "31", "33", "35", "37", "39", "41", "43", "45", "47", "49", "5", "51", "53", "55", "57", "59", "61", "63", "65", "67", "69", "7", "71", "73", "75", "77", "79", "81", "83", "85", "87", "89", "9", "91", "93", "95", "97", "99")
    raw_sources <- paste0("https://github.com/diazrenata/in-the-trees/raw/demo/static_data/processed_tables/STATECD=27/COUNTYCD=", 
                         counties, "/part-0.csv")
    cn_hive = F
  }
  

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
  
  selected_cns <- selected_trees$TREE_FIRST_CN
  
  cns <-
    duckdbfs::open_dataset(
      sources = cn_sources,
      hive_style = cn_hive,
      format = "csv"
    ) |>
    dplyr::filter(TREE_FIRST_CN %in% selected_cns) |>
    compute()
  
  timeseries <-
    duckdbfs::open_dataset(
      sources = raw_sources,
      hive_style = T,
      format = "csv"
    ) |>
    dplyr::mutate(STATECD = as.numeric(STATECD),
                  COUNTYCD = as.numeric(COUNTYCD)) |> 
    inner_join(cns) |>
    select(all_of(report_cols)) |>
    filter(INVYR >= min_year,
           INVYR <= max_year) |>
    collect() 
  
  timeseries
  
}
