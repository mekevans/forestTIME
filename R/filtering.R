open_arrow_table_with_duck <- function(table = "TREE_INFO", 
                                       local_dir = here::here("data", "arrow"),
                                       connection = "local") {
  
  if(table == "TREE_INFO") {
    
    if(connection == "local") {
      tree_info_sources = list.files(here::here(local_dir, "TREE_INFO"), recursive = T, full.names = T)
      tree_info_hive = T
    } else {
      tree_info_sources = "https://github.com/diazrenata/in-the-trees/raw/demo/static_data/processed_tables/mn_info.csv"
      tree_info_hive = F
    }
    
    tree_info <-  duckdbfs::open_dataset(
      sources = tree_info_sources,
      hive_style = tree_info_hive,
      format = "csv",
      schema = schema(STATECD = float64())
    ) |>
      dplyr::mutate(STATECD = as.numeric(STATECD),
                    COUNTYCD = as.numeric(COUNTYCD)) 
    return(tree_info)
    
  }
  
  if(table == "TREE") {
    if(connection == "local") {
      raw_sources = list.files(here::here(local_dir, "TREE_RAW"), recursive = T, full.names = T)
    } else {
      counties <- c("1", "101", "103", "107", "109", "11", "111", "113", "115", "119", "121", "123", "125", "127", "129", "13", "131", "135", "137", "139", "141", "143", "145", "147", "149", "15", "151", "153", "155", "157", "159", "161", "163", "165", "167", "169", "17", "171", "173", "19", "21", "23", "25", "27", "29", "3", "31", "33", "35", "37", "39", "41", "43", "45", "47", "49", "5", "51", "53", "55", "57", "59", "61", "63", "65", "67", "69", "7", "71", "73", "75", "77", "79", "81", "83", "85", "87", "89", "9", "91", "93", "95", "97", "99")
      raw_sources <- paste0("https://github.com/diazrenata/in-the-trees/raw/demo/static_data/processed_tables/STATECD=27/COUNTYCD=", 
                            counties, "/part-0.csv")
    }
    
    tree <-
      duckdbfs::open_dataset(
        sources = raw_sources,
        hive_style = T,
        format = "csv"
      ) |>
      dplyr::mutate(STATECD = as.numeric(STATECD),
                    COUNTYCD = as.numeric(COUNTYCD)) 
    
    return(tree)
  }
  
  if(table == "PLOT_INFO") {
    
    if(connection == "local") {
      raw_sources = list.files(here::here(local_dir, "PLOT_INFO"), recursive = T, full.names = T)
    } else {
      stop("No plot info table online yet")
    }
    
    plot_info <-
      duckdbfs::open_dataset(
        sources = raw_sources,
        hive_style = T,
        format = "csv"
      ) |>
      dplyr::mutate(STATECD = as.numeric(STATECD),
                    COUNTYCD = as.numeric(COUNTYCD)) 
    
    return(plot_info)
  }
  
  if(table == "PLOT") {
    if(connection == "local") {
      raw_sources = list.files(here::here(local_dir, "PLOT_RAW"), recursive = T, full.names = T)
    } else {
      stop("No plot table online yet")
    }
    
    plot_raw <-
      duckdbfs::open_dataset(
        sources = raw_sources,
        hive_style = T,
        format = "csv"
      ) |>
      dplyr::mutate(STATECD = as.numeric(STATECD),
                    COUNTYCD = as.numeric(COUNTYCD)) 
    
    return(plot_raw)
  }
}


filter_by_location <- function() {}