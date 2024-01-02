library(arrow)
library(dplyr)

state_number <- c(9, 27)
arrow_dir <- "data/arrow"

tree_unique_number <- open_dataset(
  here::here(arrow_dir, "TREE_RAW"),
  partitioning = c("STATECD", "COUNTYCD"),
  format = "csv",
  hive_style = T,
  col_types = schema(
    CN = float64(),
    TREE_FIRST_CN = float64()
  )) |>
  filter(STATECD %in% state_number) |>
  mutate(TREE_UNIQUE_NUM = paste(STATECD,
                                 UNITCD,
                                 COUNTYCD,
                                 PLOT,
                                 SUBP,
                                 TREE, 
                                 sep = "_")) |>
  compute()

join_cns <-  open_dataset(
  here::here(arrow_dir, "TREE_CN_JOIN"),
  partitioning = c("STATECD", "COUNTYCD"),
  format = "csv",
  hive_style = T,
  col_types = schema(
    CN = float64(),
    TREE_FIRST_CN = float64()
  )) |>
  filter(STATECD %in% state_number) |>
  compute()

unmatched_cns <- join_cns |>
  left_join(tree_unique_number) |>
  select(TREE_FIRST_CN, TREE_UNIQUE_NUM) |> 
  distinct() |>
  collect() |> 
  group_by(TREE_FIRST_CN) |>
  mutate(n_NUM = n()) |>
  group_by(TREE_UNIQUE_NUM) |>
  mutate(n_FIRST_CN = n()) |>
  ungroup() |>
  filter(n_NUM > 1 |
           n_FIRST_CN > 1) 
