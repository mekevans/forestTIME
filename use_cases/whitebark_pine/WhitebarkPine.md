# Extracting FIA timeseries

``` r
library(duckdb)
library(dplyr)
library(ggplot2)


source(here::here("R", "query_tables_db_fxns.R"))

con <- connect_to_tables(here::here("data", "db", "foresttime-to-share.duckdb"))

theme_set(theme_bw())
```

# Whitebark pine for Montana, Idaho, and Wyoming

SPCD = 101

STATECD = 16, 30, 56

``` r
whitebark_pine  <- query_tree_surveys(
  con = con,
  conditions = create_conditions(STATECD %in% c(16, 30, 56),
                                 SPCD == 101,
                                  ANY_SPCD_FLAG == FALSE), # This filters out trees with changing SPCD over time
  variables = c("STATUSCD", 
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
)
```

    Joining with `by = join_by(TREE_COMPOSITE_ID, PLOT_COMPOSITE_ID, PLOT, SUBP, STATECD, COUNTYCD)`
    Joining with `by = join_by(TREE_COMPOSITE_ID, SPCD_CORR, TREE_CN, INVYR, STATUSCD, SPCD, CYCLE)`
    Joining with `by = join_by(PLOT_COMPOSITE_ID, PLOT, STATECD, COUNTYCD, PLT_CN, INVYR, UNITCD, CYCLE, SUBCYCLE)`
    Joining with `by = join_by(PLOT_COMPOSITE_ID, PLOT, STATECD, COUNTYCD, PLT_CN, INVYR, UNITCD, CONDID, CYCLE, SUBCYCLE)`

``` r
knitr::kable(head(whitebark_pine))
```

| TREE_COMPOSITE_ID | PLOT_COMPOSITE_ID | SPCD | PLOT | SUBP | COUNTYCD | STATECD |       PLT_CN | INVYR | CYCLE | MEASYEAR |      TREE_CN |      COND_CN | CONDID | STATUSCD |  DIA |  HT | COND_STATUS_CD |      LAT |       LON |   BALIVE | SICOND | SISP | SIBASE | DSTRBCD1 | DSTRBYR1 | DSTRBCD2 | DSTRBYR2 | DSTRBCD3 | DSTRBYR3 | SDIMAX_RMRS | SDI_RMRS | SLOPE | ASPECT | CONDPROP_UNADJ | RECONCILECD |
|:------------------|:------------------|-----:|-----:|-----:|---------:|--------:|-------------:|------:|------:|---------:|-------------:|-------------:|-------:|---------:|-----:|----:|---------------:|---------:|----------:|---------:|-------:|-----:|-------:|---------:|---------:|---------:|---------:|---------:|:---------|:------------|:---------|------:|-------:|---------------:|:------------|
| 56_1_39_316_2_25  | 56_1_39_316       |  101 |  316 |    2 |       39 |      56 | 2.836371e+12 |  2000 |     2 |     2000 | 2.836427e+12 | 2.836372e+12 |      1 |        1 | 15.3 |  77 |              1 | 43.66349 | -110.2008 | 177.6492 |     35 |  108 |     50 |       20 |       NA |       NA |       NA |       NA | NA       | NA          | NA       |    45 |    360 |           1.00 | NA          |
| 56_1_39_317_1_3   | 56_1_39_317       |  101 |  317 |    1 |       39 |      56 | 2.836500e+12 |  2000 |     2 |     2000 | 2.836508e+12 | 2.836501e+12 |      1 |        1 | 18.6 |  65 |              1 | 43.68012 | -110.1348 | 142.0166 |     37 |   93 |     50 |       20 |       NA |       NA |       NA |       NA | NA       | NA          | NA       |    60 |    230 |           1.00 | NA          |
| 56_1_39_330_3_13  | 56_1_39_330       |  101 |  330 |    3 |       39 |      56 | 2.836885e+12 |  2000 |     2 |     2000 | 2.836925e+12 | 2.836886e+12 |      1 |        1 | 10.0 |  35 |              1 | 43.62557 | -110.3252 | 106.6849 |     46 |   93 |     50 |        0 |       NA |       NA |       NA |       NA | NA       | NA          | NA       |    22 |    225 |           1.00 | NA          |
| 56_1_39_331_3_8   | 56_1_39_331       |  101 |  331 |    3 |       39 |      56 | 2.836948e+12 |  2000 |     2 |     2000 | 2.836985e+12 | 2.836949e+12 |      1 |        2 |  9.1 |  52 |              1 | 43.61086 | -110.2746 |  96.6655 |     30 |   93 |     50 |       30 |     1985 |       NA |       NA |       NA | NA       | NA          | NA       |    50 |    150 |           0.75 | NA          |
| 56_1_39_332_3_2   | 56_1_39_332       |  101 |  332 |    3 |       39 |      56 | 2.837018e+12 |  2000 |     2 |     2000 | 2.837091e+12 | 2.837019e+12 |      1 |        2 | 10.5 |  58 |              1 | 43.62125 | -110.2125 |   0.0000 |     37 |  108 |     50 |       30 |     1991 |       NA |       NA |       NA | NA       | NA          | NA       |    40 |    268 |           1.00 | NA          |
| 56_1_39_171_4_6   | 56_1_39_171       |  101 |  171 |    4 |       39 |      56 | 2.830572e+12 |  2000 |     2 |     1999 | 2.830606e+12 | 2.830573e+12 |      1 |        1 |  5.7 |  22 |              1 | 44.08164 | -110.2551 |  50.9865 |     31 |   93 |     50 |       30 |     1975 |       NA |       NA |       NA | NA       | NA          | NA       |    14 |    125 |           1.00 | NA          |

## How many trees have been surveyed how many times in each state?

| STATECD | n_measures | n_trees |
|--------:|-----------:|--------:|
|      16 |          1 |    1190 |
|      16 |          2 |    2065 |
|      16 |          3 |       1 |
|      30 |          1 |    2607 |
|      30 |          2 |    5882 |
|      30 |          3 |     199 |
|      56 |          1 |    8094 |

**Notably, zero trees in Wyoming (STATECD = 56) have been surveyed more
than one time.**

## Plotting DIA, HT of trees with repeated measurements

![](WhitebarkPine_files/figure-commonmark/unnamed-chunk-4-1.png)

![](WhitebarkPine_files/figure-commonmark/unnamed-chunk-4-2.png)

## Saving data to share

``` r
write.csv(whitebark_pine, here::here("use_cases", "whitebark_pine", "whitebark_pine.csv"))
```

## Clean up

``` r
dbDisconnect(con, shutdown = TRUE)
```

The saved file is 6 MB.
