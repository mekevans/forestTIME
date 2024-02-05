library(arrow)
library(tidyverse)
source(here::here("R", "download_state_data.R"))
source(here::here("R", "store_as_hive.R"))
source(here::here("R", "create_trees_info_table.R"))
source(here::here("R", "create_plot_info_table.R"))
source(here::here("R", "chain_by_joins.R"))
source(here::here("R", "cns_on_hive.R"))

# start downloading at PA
# 
# state_to_use = "WY"
# state_number = 56 # for now, lookup here: https://www.census.gov/library/reference/code-lists/ansi/ansi-codes-for-states.html. These are FIPS codes, not too hard to download eventually.
# raw_dir <- "data/rawdat/state"
# arrow_dir <- "data/arrow"

mega_tables_function <- function(state_to_use, raw_dir = "data/rawdat/state", arrow_dir = "data/arrow") {
  
  #### Download data ####
  
 # download_state_data(state_to_use, "data/rawdat/state")
  
  #### Store data in a hive ####
  
  raw_hive(state_to_use = state_to_use,
           rawdat_dir = raw_dir,
           arrow_dir = arrow_dir)
  
  #### Create CN tables and store in a hive of the same structure ####
  
  system.time(create_cn_tables_join(state_to_use = state_to_use, arrow_dir = arrow_dir))
  
  #### Create PLOT INFO table ####
  
  system.time(create_plot_info(state_to_use = state_to_use, arrow_dir = arrow_dir))
  
  #### Create TREE INFO table ####
  
  system.time(create_tree_info(state_to_use = state_to_use, arrow_dir = arrow_dir))
}
