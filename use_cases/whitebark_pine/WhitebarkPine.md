# Extracting FIA timeseries


``` r
library(duckdb)
library(dplyr)
library(ggplot2)


source(here::here("R", "query_tables_db_fxns.R"))

con <- connect_to_tables(here::here("data", "db", "foresttime-from-state-parquet.duckdb"))

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

| TREE_COMPOSITE_ID  | PLOT_COMPOSITE_ID | SPCD |  PLOT | SUBP | COUNTYCD | STATECD |       PLT_CN | INVYR | CYCLE | MEASYEAR |      TREE_CN |      COND_CN | CONDID | STATUSCD |  DIA |  HT | COND_STATUS_CD |      LAT |       LON |   BALIVE | SICOND | SISP | SIBASE | DSTRBCD1 | DSTRBYR1 | DSTRBCD2 | DSTRBYR2 | DSTRBCD3 | DSTRBYR3 | SDIMAX_RMRS | SDI_RMRS | SLOPE | ASPECT | CONDPROP_UNADJ | RECONCILECD |
|:-------------------|:------------------|-----:|------:|-----:|---------:|--------:|-------------:|------:|------:|---------:|-------------:|-------------:|-------:|---------:|-----:|----:|---------------:|---------:|----------:|---------:|-------:|-----:|-------:|---------:|---------:|---------:|---------:|---------:|:---------|:------------|:---------|------:|-------:|---------------:|:------------|
| 16_1_79_82039_3_7  | 16_1_79_82039     |  101 | 82039 |    3 |       79 |      16 | 3.548450e+14 |  2019 |     3 |     2019 | 7.531892e+14 | 7.531892e+14 |      1 |        1 |  7.8 |  32 |              1 | 47.44512 | -115.7372 | 135.1685 |     45 |  108 |     50 |        0 |       NA |        0 |       NA |        0 | NA       | 700         | 266.1638 |    21 |    359 |              1 | NA          |
| 16_3_59_87801_4_7  | 16_3_59_87801     |  101 | 87801 |    4 |       59 |      16 | 3.548453e+14 |  2019 |     3 |     2019 | 7.532071e+14 | 7.532071e+14 |      1 |        1 |  1.6 |  11 |              1 | 45.53671 | -114.5646 |  82.3427 |     42 |  202 |     50 |       10 |     2011 |        0 |       NA |        0 | NA       | 595         | 153.0173 |    64 |     74 |              1 | NA          |
| 16_3_59_85662_4_1  | 16_3_59_85662     |  101 | 85662 |    4 |       59 |      16 | 3.548453e+14 |  2019 |     3 |     2019 | 7.532072e+14 | 7.532072e+14 |      1 |        2 | 10.3 |  46 |              1 | 45.35415 | -114.5784 |   0.0000 |     NA |   NA |     NA |       30 |     2012 |        0 |       NA |        0 | NA       | 735         | 0.0      |    60 |     74 |              1 | NA          |
| 16_3_59_87970_1_11 | 16_3_59_87970     |  101 | 87970 |    1 |       59 |      16 | 3.548453e+14 |  2019 |     3 |     2019 | 7.532075e+14 | 7.532075e+14 |      1 |        2 |  1.2 |   8 |              1 | 45.03985 | -114.5856 |  44.0302 |     24 |  108 |     50 |       12 |     2012 |        0 |       NA |        0 | NA       | 700         | 84.8999  |    66 |    287 |              1 | NA          |
| 16_3_59_87723_1_1  | 16_3_59_87723     |  101 | 87723 |    1 |       59 |      16 | 3.548453e+14 |  2019 |     3 |     2019 | 7.532078e+14 | 7.532078e+14 |      1 |        1 |  2.5 |  10 |              2 | 44.89673 | -114.2126 |       NA |     NA |   NA |     NA |       95 |     9999 |       NA |       NA |       NA | NA       | 0           | NA       |    NA |     NA |              1 | NA          |
| 16_3_59_88543_4_2  | 16_3_59_88543     |  101 | 88543 |    4 |       59 |      16 | 3.548453e+14 |  2019 |     3 |     2019 | 7.532080e+14 | 7.532080e+14 |      1 |        1 | 21.0 |  59 |              1 | 44.93764 | -113.9177 | 103.5431 |     25 |  202 |     50 |       20 |     9999 |        0 |       NA |        0 | NA       | 595         | 150.9284 |    62 |    265 |              1 | NA          |

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

The saved file is 6 MB.

## Clean up

``` r
dbDisconnect(con, shutdown = TRUE)
```
