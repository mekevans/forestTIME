library("duckdb")
library("dplyr")
con <-
  dbConnect(duckdb(
    dbdir = here::here("use_cases", "interact_as_database", "forestTIME.duckdb")
  ))
dbListTables(con)

trees <- tbl(con, "tree_raw") |> compute()

plots <-
  tbl(con, "plot_raw") |> rename(PLT_CN = CN) |> select(-any_of(
    c(
      "CREATED_BY",
      "CREATED_DATE",
      "CREATED_IN_INSTANCE",
      "MODIFIED_BY",
      "MODIFIED_DATE",
      "MODIFIED_IN_INSTANCE"
    )
  )) |>
  compute()

cond <-
  tbl(con, "cond_raw") |> rename(COND_CN = CN) |> select(-any_of(
    c(
      "CREATED_BY",
      "CREATED_DATE",
      "CREATED_IN_INSTANCE",
      "MODIFIED_BY",
      "MODIFIED_DATE",
      "MODIFIED_IN_INSTANCE"
    )
  )) |>  compute()

variables <-
  c(
    "STATUSCD",
    "DIA",
    "HT",
    "COND_STATUS_CD",
    "LAT",
    "LON",
    "BALIVE",
    "SICOND",
    "SISP",
    "SIBASE",
    "DSTRBCD1",
    "DSTRBYR1",
    "DSTRBCD2",
    "DSTRBYR2",
    "DSTRBCD3",
    "DSTRBYR3",
    "SDIMAX_RMRS",
    "SDI_RMRS",
    "SLOPE",
    "ASPECT",
    "CONDPROP_UNADJ",
    "RECONCILECD")

needed_variables <- c('TREE_UNIQUE_ID',
                      'PLOT_UNIQUE_ID',
                      'SPCD',
                      'PLOT',
                      'SUBPLOT',
                      'SPCDS',
                      'COUNTYCD',
                      'STATECD',
                      'PLT_CN',
                      'INVYR',
                      'CYCLE',
                      'MEASYEAR',
                      'CN',
                      'COND_CN',
                      'CONDID',
                      'TREE_FIRST_CNS')


## Get whitebark pine for ID, MT, WY (16, 30, 56)
## Use TREE_UNIQUE_ID

selected_trees <- tbl(con, "tree_info_composite_id") |>
  filter(STATECD %in% c(16, 30, 56),
         SPCD == 101,
         SPCDS == 1) |>
  compute()

tree_timeseries <- selected_trees |>
  left_join(trees) |>
  left_join(plots) |>
  left_join(cond) |>
  select(all_of(c(needed_variables, variables))) |>
  collect()

tree_timeseries |>
  group_by(STATECD, TREE_UNIQUE_ID) |>
  summarize(n_records = dplyr::n()) |>
  ungroup() |>
  group_by(STATECD, n_records) |>
  tally()
