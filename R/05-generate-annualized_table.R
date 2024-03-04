library(duckdb)
library(dplyr)
library(stringr)

con <- dbConnect(duckdb(
  dbdir = here::here("data", "db", "derived_tables.duckdb")
))

dbListTables(con)

trees <- tbl(con, "tree") |>
  filter(!is.na(DIA), !is.na(HT)) |>
  select(TREE_COMPOSITE_ID, INVYR, DIA, HT) |> 
  group_by(TREE_COMPOSITE_ID) |>
  mutate(next_INVYR = lead(INVYR, order_by = INVYR),
         next_DIA = lead(DIA, order_by = INVYR)) |>
  mutate(next_INVYR = next_INVYR - 1) |>
  mutate(
    next_INVYR = ifelse(is.na(next_INVYR), INVYR, next_INVYR),
    next_DIA = ifelse(is.na(next_DIA), DIA, next_DIA)) |>
  mutate(DIA_slope = (next_DIA - DIA) / ((next_INVYR + 1) - INVYR)) 

all_years <- tbl(con, "tree") |>
  select(INVYR, TREE_COMPOSITE_ID) |>
  tidyr::expand(INVYR, TREE_COMPOSITE_ID) |>
  arrange(TREE_COMPOSITE_ID, INVYR) |>
  rename(YEAR = INVYR)

by <- join_by(TREE_COMPOSITE_ID, between(YEAR, INVYR, next_INVYR, bounds = "[]"))

trees_annual_measures <- all_years |> 
  inner_join(trees, by) |>
  mutate(DIA_run = YEAR - INVYR,
         DIA_start = DIA) |>
  mutate(DIA_est = DIA_start + (DIA_slope * DIA_run)) |>
  arrange(TREE_COMPOSITE_ID, YEAR) |>
  select(TREE_COMPOSITE_ID, YEAR, DIA_est) |>
  collect()

arrow::to_duckdb(trees_annual_measures, table_name = "tree_annualized", con = con)
dbSendQuery(con, "CREATE TABLE tree_annualized AS SELECT * FROM tree_annualized")
dbDisconnect(con, shutdown = TRUE)
