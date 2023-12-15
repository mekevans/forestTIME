if(FALSE) {
  install.packages("duckdbfs")
}

library(duckdb)
library(duckdbfs)

mn_cns <- duckdbfs::open_dataset(sources = "https://github.com/diazrenata/in-the-trees/raw/demo/static_data/processed_tables/mn_cns.csv",
                                 format = "csv")

mn_info <- duckdbfs::open_dataset(sources = "https://github.com/diazrenata/in-the-trees/raw/demo/static_data/processed_tables/mn_info.csv",
                                 format = "csv")

# Connecting directly to FIADB via DataMart was really slow and crashed my R a few times.
# Interfacing with a partitioned version hosted (for testing!!!) on my GH is much much faster.

counties <- list.files(here::here("static_data", "processed_tables", "STATECD=27")) |>
  stringr::str_remove("COUNTYCD=")

tree_paths <- paste0("https://github.com/diazrenata/in-the-trees/raw/demo/static_data/processed_tables/STATECD=27/COUNTYCD=", 
counties, "/part-0.csv")

system.time(mn_trees <- duckdbfs::open_dataset(sources = tree_paths,
                                  hive_style = T,
                                   format = "csv")) # 4.3 seconds

library(dplyr)

mn_maples <- mn_info |>
  filter(SPCD == 316,
         PLOT == 20010)

mn_maple_cns <- mn_maples |>
  left_join(mn_cns) 

mn_maple_cn_measurements <- mn_maple_cns |>
  inner_join(mn_trees) |>
  select(CN, INVYR, TREE_FIRST_CN, DIA, HT, STATUSCD)

system.time(maple_measurements <- collect(mn_maple_cn_measurements)) # 23.39 seconds



