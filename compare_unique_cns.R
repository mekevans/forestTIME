library(arrow)
library(dplyr)

state_number <- 27
arrow_dir <- "data/arrow"

raw_trees <- open_dataset(
  here::here(arrow_dir, "TREE_RAW"),
  partitioning = c("STATECD", "COUNTYCD"),
  format = "csv",
  hive_style = T,
  col_types = schema(
    CN = float64(),
    TREE_FIRST_CN = float64()
  )) |>
  filter(STATECD %in% state_number) |>
  collect()

tree_unique_number <- raw_trees |>
  mutate(TREE_UNIQUE_NUM = paste(STATECD,
                                 UNITCD,
                                 COUNTYCD,
                                 PLOT,
                                 SUBP,
                                 TREE, 
                                 sep = "_")) |>
  select(CN, TREE_UNIQUE_NUM)

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
  collect()

comparison_cns <- join_cns |>
  left_join(tree_unique_number) |>
  group_by(TREE_FIRST_CN) |>
  mutate(number_of_unique_numbers = length(unique(TREE_UNIQUE_NUM))) |>
  ungroup() |>
  group_by(TREE_UNIQUE_NUM) |>
  mutate(number_of_unique_first_cns = length(unique(TREE_FIRST_CN)))

unmatched_cns <- comparison_cns |>
  filter(number_of_unique_first_cns > 1 |
           number_of_unique_numbers > 1)

distincts <- comparison_cns |>
  select(TREE_FIRST_CN, TREE_UNIQUE_NUM) |> distinct()

length(unique(join_cns$TREE_FIRST_CN))
length(unique(tree_unique_number$TREE_UNIQUE_NUM))
