# Pulling timeseries of surveys

``` r
source(here::here("R", "query_tables_db_fxns.R"))
```

    Loading required package: DBI

    Warning: package 'DBI' was built under R version 4.3.2

    Warning: package 'dplyr' was built under R version 4.3.2


    Attaching package: 'dplyr'

    The following objects are masked from 'package:stats':

        filter, lag

    The following objects are masked from 'package:base':

        intersect, setdiff, setequal, union

``` r
con <- connect_to_tables(here::here("data", "db", "derived_tables3.duckdb"))
```

Here’s an unmodified query for whitebark pine in MT:

``` r
wb_pine_raw <- query_tree_surveys(
  con,
  conditions = create_conditions(STATECD == 30,
                                 SPCD == 101),
  variables = c(
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
    "RECONCILECD"
  )
)
```

    Joining with `by = join_by(TREE_COMPOSITE_ID, PLOT_COMPOSITE_ID, PLOT, SUBP, STATECD, COUNTYCD)`
    Joining with `by = join_by(TREE_COMPOSITE_ID, SPCD_CORR, TREE_CN, INVYR, STATUSCD, SPCD, CYCLE)`
    Joining with `by = join_by(PLOT_COMPOSITE_ID, PLOT, STATECD, COUNTYCD, PLT_CN, INVYR, UNITCD, CYCLE, SUBCYCLE)`
    Joining with `by = join_by(PLOT_COMPOSITE_ID, PLOT, STATECD, COUNTYCD, PLT_CN, INVYR, UNITCD, CONDID, CYCLE, SUBCYCLE)`

``` r
qa_d_wb_pine <- query_tree_surveys(
  con = con,
  conditions = create_conditions(
    STATECD == 30,
    SPCD == 101,
    ANY_SPCD_FLAG == FALSE
  ),
  variables = c(
    "STATUSCD",
    "STATUSCD_CORR",
    "STATUSCD_FLAG",
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
    "RECONCILECD"
  )
)
```

    Joining with `by = join_by(TREE_COMPOSITE_ID, PLOT_COMPOSITE_ID, PLOT, SUBP, STATECD, COUNTYCD)`
    Joining with `by = join_by(TREE_COMPOSITE_ID, SPCD_CORR, TREE_CN, INVYR, STATUSCD, SPCD, CYCLE)`
    Joining with `by = join_by(PLOT_COMPOSITE_ID, PLOT, STATECD, COUNTYCD, PLT_CN, INVYR, UNITCD, CYCLE, SUBCYCLE)`
    Joining with `by = join_by(PLOT_COMPOSITE_ID, PLOT, STATECD, COUNTYCD, PLT_CN, INVYR, UNITCD, CONDID, CYCLE, SUBCYCLE)`

``` r
dbDisconnect(con, shutdown = TRUE)
```
