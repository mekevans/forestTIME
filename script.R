library(arrow)
library(tidyverse)
library(furrr)
source(here::here("R", "daisy_chain.R"))
source(here::here("R", "download_state_data.R"))
source(here::here("R", "store_as_hive.R"))
source(here::here("R", "cns_on_hive.R"))
source(here::here("R", "create_trees_info_table.R"))
source(here::here("R", "create_tree_change_table.R"))
source(here::here("R", "chain_by_joins.R"))


state_to_use = "MN"
state_number = 27 # for now, lookup here: https://www.census.gov/library/reference/code-lists/ansi/ansi-codes-for-states.html. These are FIPS codes, not too hard to download eventually.
raw_dir <- "data/rawdat/state"
arrow_dir <- "data/arrow"

#### Download data ####

# Note that this fxn fails if the download takes more than 60 seconds.

#download_state_data(state_to_use, "data/rawdat/state")



# #### Store TREE data in a hive ####
# 
raw_trees_hive(state_to_use = "MN",
              rawdat_dir = raw_dir,
              arrow_dir = arrow_dir)

#### Create CN tables and store in a hive of the same structure ####

#system.time(create_cn_tables(state_number = 12, arrow_dir = arrow_dir))

system.time(create_cn_tables_join(state_number = 27, arrow_dir = arrow_dir))

#### Create TREE INFO table ####

system.time(create_tree_info(arrow_dir = arrow_dir))
# less than a second

#### Create TREE CHANGE table ####
system.time(create_tree_change( arrow_dir = arrow_dir))
# 1.25 seconds

#### Set up as DuckDB? ####