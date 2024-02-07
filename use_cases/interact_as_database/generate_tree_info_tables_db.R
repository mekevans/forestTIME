library("duckdb")
library("dplyr")
con <- dbConnect(duckdb(dbdir = here::here("use_cases", "interact_as_database", "forestTIME.duckdb")))
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
  compute()

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
  compute()

copy_to(con, df = tree_info_composite_id, name = "tree_info_composite_id")

copy_to(con, df = tree_info_first_cn, name = "tree_info_first_cn")


dbListTables(con)
dbDisconnect(con)
