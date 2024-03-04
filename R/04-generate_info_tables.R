library(duckdb)
library(dplyr)
library(stringr)

con <- dbConnect(duckdb(
  dbdir = here::here("data", "db", "derived_tables.duckdb")
))

dbListTables(con)

cns_multiple_locations <- tbl(con, "tree") |>
  left_join(tbl(con, "tree_cns")) |>
  select(TREE_COMPOSITE_ID, TREE_FIRST_CN) |>
  distinct() |>
  group_by(TREE_FIRST_CN) |>
  mutate(N_COMPOSITE_IDS = n()) |>
  ungroup() |>
  mutate(MULTIPLE_LOCATIONS_FLAG = N_COMPOSITE_IDS > 1) |>
  select(TREE_COMPOSITE_ID, MULTIPLE_LOCATIONS_FLAG) |>
  distinct()

multiple_cns <- tbl(con, "tree") |>
  left_join(tbl(con, "tree_cns")) |> 
  select(TREE_COMPOSITE_ID, TREE_FIRST_CN) |>
  distinct() |>
  group_by(TREE_COMPOSITE_ID) |>
  summarize(N_FIRST_CNS = n()) |>
  ungroup() |>
  mutate(MULTIPLE_CNS_FLAG = N_FIRST_CNS > 1) |>
  select(TREE_COMPOSITE_ID, MULTIPLE_CNS_FLAG)

multiple_owners <- tbl(con, "tree") |>
  left_join(tbl(con, "cond")) |>
  select(TREE_COMPOSITE_ID, OWNCD, ADFORCD) |>
  distinct() |>
  group_by(TREE_COMPOSITE_ID, OWNCD) |>
  summarize(n_ADFORCD = n()) |>
  ungroup() |>
  group_by(TREE_COMPOSITE_ID) |>
  summarize(n_OWNCD = n(),
            n_ADFORCD = sum(n_ADFORCD)) |>
  ungroup() |>
  mutate(MULTI_OWNCD_FLAG = n_OWNCD > 1,
         MULTI_ADFORCD_FLAG = n_ADFORCD > 1) |>
  select(TREE_COMPOSITE_ID,
         MULTI_OWNCD_FLAG,
         MULTI_ADFORCD_FLAG)

tree_info_composite_id <- tbl(con, "tree") |>
  left_join(tbl(con, "qa_flags")) |>
  group_by(TREE_COMPOSITE_ID,
           PLOT_COMPOSITE_ID,
           PLOT,
           SUBP,
           STATECD,
           COUNTYCD,
           SPCD_CORR) |>
  summarize(NRECORDS = dplyr::n(),
            FIRSTYR = min(INVYR),
            LASTYR = max(INVYR),
            ANY_SPCD_FLAG = any(SPCD_FLAG),
            ANY_STATUSCD_FLAG = any(STATUSCD_FLAG),
            ANY_CYCLE_VISITS_FLAG = any(CYCLE_MULTIPLE_VISITS)) |>
  ungroup() |>
  left_join(cns_multiple_locations) |>
  left_join(multiple_cns) |>
  left_join(multiple_owners) |>
  collect()

arrow::to_duckdb(tree_info_composite_id, table_name = "tree_info_composite_id", con = con)
dbSendQuery(con, "CREATE TABLE tree_info_composite_id AS SELECT * FROM tree_info_composite_id")

# rm(tree_info_composite_id)
# 
# tree_info_first_cn <- tbl(con, "tree_cns") |>
#   left_join(tbl(con, "tree")) |>
#   group_by(TREE_FIRST_CN) |>
#   summarize(NYEARS = dplyr::n(),
#             FIRSTYR = min(INVYR),
#             LASTYR = max(INVYR),
#             SPCD = min(SPCD),
#             PLOT = min(PLOT),
#             SUBPLOT = min(SUBP),
#             STATECD = min(STATECD),
#             COUNTYCD = min(COUNTYCD),
#             PLOTS = n_distinct(PLOT),
#             STATES = n_distinct(STATECD),
#             COUNTIES = n_distinct(COUNTYCD),
#             UNITS = n_distinct(UNITCD),
#             SPCDS = n_distinct(SPCD),
#             TREE_UNIQUE_IDS = n_distinct(TREE_UNIQUE_ID)) |>
#   ungroup() |>
#   collect()
# 
# 
# arrow::to_duckdb(tree_info_first_cn, table_name = "tree_info_first_cn", con = con)
# dbSendQuery(con, "CREATE TABLE tree_info_first_cn AS SELECT * FROM tree_info_first_cn")
# 

dbListTables(con)
dbDisconnect(con, shutdown = TRUE)
