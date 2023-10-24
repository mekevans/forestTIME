
library(arrow)
library(tidyverse)
source(here::here("daisy_chain.R"))


#### Download data ####

# tidyFIA::download_by_state("CT", file_dir = here::here("ct_demo", "raw_dat", "CT")) #this is very fast
# 
# download.file("https://apps.fs.usda.gov/fia/datamart/CSV/FIADB_REFERENCE.zip", here::here("ct_demo", "raw_dat", "species", "DB_REFERENCE.zip"))
# 
# unzip(here::here("ct_demo", "raw_dat", "species", "DB_REFERENCE.zip"), files = "REF_SPECIES.csv", exdir = here::here("ct_demo", "raw_dat", "species"))

#### Store TREE data in a hive ####
# 
# ct_trees <- read_csv(here::here("ct_demo", "raw_dat", "CT", "CT_TREE.csv")) |>
#   filter(INVYR >= 2000) |>
#   select(CN, PREV_TRE_CN, INVYR, COUNTYCD, STATECD)
# 
# write_dataset(ct_trees, here::here("ct_demo", "arrow_dat", "TREE_RAW"), format = "csv",
#               partitioning = c("STATECD", "COUNTYCD"))

#### Create CN tables and store in a hive of the same structure ####

# sliced_pipeline <- function(ds_path) {
#   
#   dir.create(str_replace(ds_path, "TREE_RAW", "TREE_CNS") |> str_remove("/part-0.csv"), recursive = T)
#   
#   read_csv(ds_path) |>
#     add_persistent_cns() |>
#     write.csv(str_replace(ds_path, "TREE_RAW", "TREE_CNS"), row.names = F)
#   
# }
# 
# ds_paths <- list.files(here::here("ct_demo", "arrow_dat", "TREE_RAW"), full.names = T, recursive = T)
# 
# system.time(map(ds_paths, sliced_pipeline))
# the above takes 82 seconds

#### Create TREE INFO table ####

#### Create TREE CHANGES table ####

#### Set up as DuckDB? ####