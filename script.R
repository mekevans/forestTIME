library(arrow)
library(tidyverse)
source(here::here("R", "daisy_chain.R"))
source(here::here("R", "download_state_data.R"))

state_to_use = "CT"

#### Download data ####

download_state_data(state_to_use, "data/rawdat/state")

#### Store TREE data in a hive ####

trees <- read_csv(here::here("data", "rawdat", "state", paste0(state_to_use, "_TREE.csv"))) |>
  filter(INVYR >= 2000) |>
  select(CN, PREV_TRE_CN, INVYR, STATECD, COUNTYCD, PLOT, STATUSCD, DIA, HT, ACTUALHT, SPCD) |>
  mutate(CN = as.character(CN),
         PREV_TRE_CN = as.character(PREV_TRE_CN))
write_dataset(ct_trees, here::here("ct_demo", "arrow_dat", "TREE_RAW"), format = "csv",
              partitioning = c("STATECD", "COUNTYCD"))

#### Create CN tables and store in a hive of the same structure ####
# 
# sliced_pipeline <- function(ds_path) {
# 
#   dir.create(str_replace(ds_path, "TREE_RAW", "TREE_CNS") |> str_remove("/part-0.csv"), recursive = T)
# 
#   read_csv(ds_path, col_select = c("CN", "PREV_TRE_CN", "INVYR")) |>
#     add_persistent_cns() |>
#     write.csv(str_replace(ds_path, "TREE_RAW", "TREE_CNS"), row.names = F)
# 
# }
# 
# ds_paths <- list.files(here::here("ct_demo", "arrow_dat", "TREE_RAW"), full.names = T, recursive = T)
# 
# system.time(map(ds_paths, sliced_pipeline))
# the above takes 50-90 seconds


#### Create TREE INFO table ####

cns <-
  open_dataset(
    here::here("ct_demo", "arrow_dat", "TREE_CNS"),
    partitioning = c("STATECD", "COUNTYCD"),
    format = "csv",
    hive_style = T,
    col_types = schema(
      CN = utf8(),
      PREV_TRE_CN = utf8(),
      INVYR = int64(),
      TREE_FIRST_CN = utf8(),
      STATECD = utf8(),
      COUNTYCD = utf8()
    )
  ) |>
  mutate(across(where(is.character), ~ ifelse(. == "NA", "NA", .)))

trees <- open_dataset(
  here::here("ct_demo", "arrow_dat", "TREE_RAW"),
  partitioning = c("STATECD", "COUNTYCD"),
  format = "csv",
  hive_style = T,
  col_types = schema(
    CN = utf8(),
    PREV_TRE_CN = utf8(),
    INVYR = int64(),
    PLOT = utf8(),
    SPCD = utf8(),
    STATECD = utf8(),
    COUNTYCD = utf8(),
    STATUSCD = utf8(),
    DIA = float64(),
    HT = float64(),
    ACTUALHT = float64()
  )) |>
  mutate(across(where(is.character), ~ ifelse(. == "", "NA", .)))


trees_info <- cns |>
  left_join(trees) |>
  group_by(TREE_FIRST_CN, PLOT, STATECD, COUNTYCD, SPCD) |>
  summarize(NYEARS = dplyr::n(),
            NYEARS_MEASURED = sum(STATUSCD != 0),
            FIRSTYR = min(INVYR),
            LASTYR = max(INVYR)) |>
  ungroup() 

dup_cns <- trees_info |> 
  select(TREE_FIRST_CN, SPCD) |> 
  group_by(TREE_FIRST_CN) |> 
  count() |> 
  filter(n > 1) |>
  select(TREE_FIRST_CN) |>
  mutate(SUSPECT_SPECIES = 1)

trees_info <- trees_info |>
  left_join(dup_cns) 

write_dataset(trees_info, here::here("ct_demo", "arrow_dat", "TREE_INFO"), format = "csv", partitioning = c("STATECD", "COUNTYCD"))

#### Create TREE CHANGES table ####


#### Set up as DuckDB? ####