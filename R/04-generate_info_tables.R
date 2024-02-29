library("duckdb")
library("dplyr")
con <- dbConnect(duckdb(dbdir = here::here("forestTIME-cli.duckdb")))
dbListTables(con)

tree_info_composite_id <- tbl(con, "tree_raw") |>
  left_join(tbl(con, "tree_cns")) |>
  group_by(TREE_UNIQUE_ID,
           PLOT_UNIQUE_ID) |>
  summarize(NYEARS = dplyr::n(),
            FIRSTYR = min(INVYR),
            LASTYR = max(INVYR),
            SPCD = min(SPCD),
            PLOT = min(PLOT),
            SUBPLOT = min(SUBP),
            STATECD = min(STATECD),
            COUNTYCD = min(COUNTYCD),
            SPCDS = n_distinct(SPCD),
            TREE_FIRST_CNS = n_distinct(TREE_FIRST_CN)) |>
  ungroup() |>
  collect()


arrow::to_duckdb(tree_info_composite_id, table_name = "tree_info_composite_id", con = con)
dbSendQuery(con, "CREATE TABLE tree_info_composite_id AS SELECT * FROM tree_info_composite_id")

rm(tree_info_composite_id)

tree_info_first_cn <- tbl(con, "tree_cns") |>
  left_join(tbl(con, "tree_raw")) |>
  group_by(TREE_FIRST_CN) |>
  summarize(NYEARS = dplyr::n(),
            FIRSTYR = min(INVYR),
            LASTYR = max(INVYR),
            SPCD = min(SPCD),
            PLOT = min(PLOT),
            SUBPLOT = min(SUBP),
            STATECD = min(STATECD),
            COUNTYCD = min(COUNTYCD),
            PLOTS = n_distinct(PLOT),
            STATES = n_distinct(STATECD),
            COUNTIES = n_distinct(COUNTYCD),
            UNITS = n_distinct(UNITCD),
            SPCDS = n_distinct(SPCD),
            TREE_UNIQUE_IDS = n_distinct(TREE_UNIQUE_ID)) |>
  ungroup() |>
  collect()


arrow::to_duckdb(tree_info_first_cn, table_name = "tree_info_first_cn", con = con)
dbSendQuery(con, "CREATE TABLE tree_info_first_cn AS SELECT * FROM tree_info_first_cn")


dbListTables(con)
dbDisconnect(con, shutdown = TRUE)
