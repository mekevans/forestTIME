source(here::here("chain_by_joins.R"))
library(arrow)
library(tidyverse)
library(furrr)



state_to_use = "FL"
state_number = 9 # for now, lookup here: https://www.census.gov/library/reference/code-lists/ansi/ansi-codes-for-states.html. These are FIPS codes, not too hard to download eventually.
raw_dir <- "data/rawdat/state"
arrow_dir <- "data/arrow"
states_to_include = 9

raw_trees <-
  open_dataset(
    here::here(arrow_dir, "TREE_RAW"),
    partitioning = c("STATECD", "COUNTYCD"),
    format = "csv",
    hive_style = T,
    col_types = schema(
      CN = float64(),
      TREE_FIRST_CN = float64()
    )) |>
  filter(STATECD %in% states_to_include) 

ct_chained <- chain_by_joins(raw_trees)


write_dataset(ct_chained, path = here::here(arrow_dir, "TREE_CN_CHAIN"), 
              format = "csv",
              partitioning = c("STATECD", "COUNTYCD"))


ctc <- collect(ct_chained)


daisy <-
  open_dataset(
    here::here(arrow_dir, "TREE_CNS"),
    partitioning = c("STATECD", "COUNTYCD"),
    format = "csv",
    hive_style = T,
    col_types = schema(
      CN = float64(),
      TREE_FIRST_CN = float64()
    )) |>
  filter(STATECD %in% states_to_include) |>
  collect()

str(daisy)
str(ctc)


ctc <- ctc |> rename(chain_first_cn = TREE_FIRST_CN)

daisy_check <- left_join(daisy, ctc) |>
  mutate(diff = TREE_FIRST_CN == chain_first_cn)
