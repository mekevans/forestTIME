library(duckdb)
library(dplyr)

source(here::here("use_cases", "interact_as_database", "query_tables_db_fxns.R"))

sp_kelly <-
  c(316, 318, 832, 833, 802, 621, 531, 400, 129, 97, 762, 261, 837, 541, 12)
states_kelly <-
  read.csv(here::here("data", "rawdat", "fips", "fips.csv")) |>
  filter(STATE %in% c(
    "WV",
    "MD",
    "OH",
    "PA",
    "NY",
    "CT",
    "RI",
    "MA",
    "DE",
    "VT",
    "NH",
    "ME"
  ))
states_kelly <- states_kelly$STATEFP

con <- connect_to_tables(here::here("data", "db", "forestTIME-cli.duckdb"))
con2 <- connect_to_tables(here::here("data", "db", "forestTIME-treering.duckdb"))

tree <- tbl(con, "tree_raw") |>
  filter(STATECD %in% states_kelly,
         SPCD %in% sp_kelly) |>
  collect()

arrow::to_duckdb(tree, table_name = "tree_raw", con = con2)
dbSendQuery(con2, "CREATE TABLE tree_raw AS SELECT * FROM tree_raw")

plot <- tbl(con, "plot_raw") |>
  filter(STATECD %in% states_kelly) |>
  collect()

arrow::to_duckdb(plot, table_name = "plot_raw", con = con2)
dbSendQuery(con2, "CREATE TABLE plot_raw AS SELECT * FROM plot_raw")

cond <- tbl(con, "cond_raw") |>
  filter(STATECD %in% states_kelly) |>
  collect()

arrow::to_duckdb(cond, table_name = "cond_raw", con = con2)
dbSendQuery(con2, "CREATE TABLE cond_raw AS SELECT * FROM cond_raw")

tree_info_composite_id <- tbl(con, "tree_info_composite_id") |>
  filter(STATECD %in% states_kelly,
         SPCD %in% sp_kelly) |>
  collect()

arrow::to_duckdb(tree_info_composite_id, table_name = "tree_info_composite_id", con = con2)
dbSendQuery(con2, "CREATE TABLE tree_info_composite_id AS SELECT * FROM tree_info_composite_id")

tree_info_first_cn <- tbl(con, "tree_info_first_cn") |>
  filter(STATECD %in% states_kelly,
         SPCD %in% sp_kelly) |>
  collect()

arrow::to_duckdb(tree_info_first_cn, table_name = "tree_info_first_cn", con = con2)
dbSendQuery(con2, "CREATE TABLE tree_info_first_cn AS SELECT * FROM tree_info_first_cn")

tree_cns <- tbl(con, "tree_cns") |>
  filter(STATECD %in% states_kelly) |>
  collect()

arrow::to_duckdb(tree_cns, table_name = "tree_cns", con = con2)
dbSendQuery(con2, "CREATE TABLE tree_cns AS SELECT * FROM tree_cns")

dbDisconnect(con, shutdown = TRUE)
dbDisconnect(con2, shutdown = TRUE)
