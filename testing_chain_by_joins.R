library(arrow)
library(tidyverse)
library(furrr)



raw_dir <- "data/rawdat/state"
arrow_dir <- "data/arrow"

raw_trees <-
  open_dataset(
    here::here(arrow_dir, "TREE_RAW"),
    partitioning = c("STATECD", "COUNTYCD"),
    format = "csv",
    hive_style = T,
    col_types = schema(CN = float64(),
                       TREE_FIRST_CN = float64())
  ) |>
  compute()


daisy <-
  open_dataset(
    here::here(arrow_dir, "TREE_CNS"),
    partitioning = c("STATECD", "COUNTYCD"),
    format = "csv",
    hive_style = T,
    col_types = schema(CN = float64(),
                       TREE_FIRST_CN = float64())
  ) |>
  compute()


joins <-   open_dataset(
  here::here(arrow_dir, "TREE_CN_JOIN"),
  partitioning = c("STATECD", "COUNTYCD"),
  format = "csv",
  hive_style = T,
  col_types = schema(CN = float64(),
                     TREE_FIRST_CN = float64())
) |>
  rename(TREE_FIRST_CN_JOINS = TREE_FIRST_CN) |>
  compute()

compare <- left_join(daisy, joins) |> collect() |>
  mutate(across(contains("CN"), as.character))

any(compare$TREE_FIRST_CN != compare$TREE_FIRST_CN_JOINS)

compare_errors <-
  filter(compare, TREE_FIRST_CN != TREE_FIRST_CN_JOINS)

weird <- filter(compare, TREE_FIRST_CN == "429552394489998")

weird2 <- filter(raw_trees, CN == 429552394489998) |> collect()

## Daisy and joins give different output...in all instances where this occurs, a tree has been recorded in multiple counties. This results in breaking the chain in daisy-style (daisy runs parallelized broken out by county) but not join-style (join is currently running at the state level).


multi_county <- joins |> collect() |>
  group_by(TREE_FIRST_CN_JOINS) |>
  summarize(nrecords = dplyr::n(),
            ncounties = length(unique(COUNTYCD))) |>
  filter(ncounties > 1)

all(sort(unique(multi_county$TREE_FIRST_CN_JOINS)) == sort(unique(compare_errors$TREE_FIRST_CN_JOINS)))
