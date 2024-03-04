library("duckdb")
library("dplyr")
raw_con <-
  dbConnect(duckdb(
    dbdir = here::here("data", "db", "raw_tables.duckdb")
  ))

derived_con <- 
  dbConnect(duckdb(
    dbdir = here::here("data", "db", "derived_tables.duckdb")
  ))

dbListTables(raw_con)

tbl(raw_con, "tree_raw") |>
  filter(INVYR >= 2000) |>
  mutate(TREE_COMPOSITE_ID = paste(STATECD, UNITCD, COUNTYCD, PLOT, SUBP, TREE, sep = "_"),
         PLOT_COMPOSITE_ID = paste(STATECD, UNITCD, COUNTYCD, PLOT, sep = "_")) |>
  rename(TREE_CN = CN) |>
  select(-c(CREATED_BY, CREATED_DATE, CREATED_IN_INSTANCE, MODIFIED_BY, MODIFIED_DATE, MODIFIED_IN_INSTANCE)) |>
  collect() |>
  arrow::to_duckdb(table_name = "tree", con = derived_con)

tbl(raw_con, "plot_raw") |>
  filter(INVYR >= 2000) |>
  mutate(PLOT_COMPOSITE_ID = paste(STATECD, UNITCD, COUNTYCD, PLOT, sep = "_")) |>
  rename(PLOT_CN = CN) |>
  select(-c(CREATED_BY, CREATED_DATE, CREATED_IN_INSTANCE, MODIFIED_BY, MODIFIED_DATE, MODIFIED_IN_INSTANCE)) |>
  collect() |>
  arrow::to_duckdb(table_name = "plot", con = derived_con)


tbl(raw_con, "cond_raw")|>
  filter(INVYR >= 2000) |>
  mutate(PLOT_COMPOSITE_ID = paste(STATECD, UNITCD, COUNTYCD, PLOT, sep = "_")) |>
  rename(COND_CN = CN) |>
  select(-c(CREATED_BY, CREATED_DATE, CREATED_IN_INSTANCE, MODIFIED_BY, MODIFIED_DATE, MODIFIED_IN_INSTANCE)) |>
  collect() |>
  arrow::to_duckdb(table_name = "cond", con = derived_con)

dbSendQuery(derived_con, "CREATE TABLE tree AS SELECT * FROM tree")
dbSendQuery(derived_con, "CREATE TABLE plot AS SELECT * FROM plot")
dbSendQuery(derived_con, "CREATE TABLE cond AS SELECT * FROM cond")


dbDisconnect(raw_con, shutdown = TRUE)
dbDisconnect(derived_con, shutdown = TRUE)

