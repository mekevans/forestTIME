# Extracting FIA timeseries

``` r
library(duckdb)
```

    Loading required package: DBI

``` r
library(dplyr)
```

    Warning: package 'dplyr' was built under R version 4.3.2


    Attaching package: 'dplyr'

    The following objects are masked from 'package:stats':

        filter, lag

    The following objects are masked from 'package:base':

        intersect, setdiff, setequal, union

``` r
library(ggplot2)

source(here::here("R", "query_tables_db_fxns.R"))

theme_set(theme_bw())
```

# To use

To use this:

1.  Clone this repository and open the `forestTIME.Rproj` R project.
2.  Make sure you have the `duckdb` R package installed
    (`install.packages("duckdb"))`.
3.  Download the file `whitebark.duckdb` and save it to
    `data/db/whitebark.duckdb`. [Link here (this will download
    300MB)](https://arizona.box.com/s/c6851saedilk8wic0o4z452i365q80c7)
4.  Then you should be able to render this document or use the code
    under “Connect to database”, below.

# Whitebark pine for Montana, Idaho, and Wyoming

SPCD = 101

STATECD = 16, 30, 56

``` r
con <- connect_to_tables(here::here("data", "db", "forestTIME-whitebark.duckdb"))

whitebark_pine <-
  query_tables_db(con = con,
  conditions = create_conditions(STATECD %in% c(16, 30, 56),
                    SPCD == 101,
                    SPCDS == 1),
  variables = c("STATUSCD", "DIA", "HT", "COND_STATUS_CD", "LAT", "LON",
                "BALIVE", "SICOND", "SISP", "SIBASE",
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

    Joining with `by = join_by(TREE_UNIQUE_ID, PLOT_UNIQUE_ID, SPCD, PLOT, STATECD, COUNTYCD)`
    Joining with `by = join_by(PLOT_UNIQUE_ID, PLOT, STATECD, COUNTYCD, PLT_CN, INVYR, UNITCD, CYCLE, SUBCYCLE)`
    Joining with `by = join_by(PLOT_UNIQUE_ID, PLOT, STATECD, COUNTYCD, PLT_CN, INVYR, UNITCD, CONDID, CYCLE, SUBCYCLE)`

``` r
dbDisconnect(con, shutdown = TRUE)

knitr::kable(head(whitebark_pine))
```

| TREE_UNIQUE_ID     | PLOT_UNIQUE_ID | SPCD |  PLOT | SUBPLOT | SPCDS | COUNTYCD | STATECD |       PLT_CN | INVYR | CYCLE | MEASYEAR |           CN |      COND_CN | CONDID | STATUSCD |  DIA |  HT | COND_STATUS_CD |      LAT |       LON |   BALIVE | SICOND | SISP | SIBASE | DSTRBCD1 | DSTRBYR1 | DSTRBCD2 | DSTRBYR2 | DSTRBCD3 | DSTRBYR3 | SDIMAX_RMRS | SDI_RMRS | SLOPE | ASPECT | CONDPROP_UNADJ | RECONCILECD |
|:-------------------|:---------------|-----:|------:|--------:|------:|---------:|--------:|-------------:|------:|------:|---------:|-------------:|-------------:|-------:|---------:|-----:|----:|---------------:|---------:|----------:|---------:|-------:|-----:|-------:|---------:|---------:|---------:|---------:|---------:|---------:|------------:|---------:|------:|-------:|---------------:|------------:|
| 16_2_85_86288_4_5  | 16_2_85_86288  |  101 | 86288 |       4 |     1 |       85 |      16 | 1.887744e+14 |  2018 |     3 |     2018 | 6.722539e+14 | 6.722539e+14 |      1 |        2 | 21.7 |  51 |              2 | 44.96733 | -115.9272 |       NA |     NA |   NA |     NA |        0 |       NA |       NA |       NA |       NA |       NA |           0 |       NA |    NA |     NA |              1 |          NA |
| 16_1_35_87619_1_5  | 16_1_35_87619  |  101 | 87619 |       1 |     1 |       35 |      16 | 1.887740e+14 |  2018 |     3 |     2018 | 6.722669e+14 | 6.722669e+14 |      1 |        2 |  7.5 |  48 |              1 | 46.76348 | -115.3697 | 203.1492 |     23 |  263 |     50 |       22 |     9999 |        0 |       NA |        0 |       NA |         735 | 308.2134 |    51 |    338 |              1 |          NA |
| 16_2_39_81971_1_5  | 16_2_39_81971  |  101 | 81971 |       1 |     1 |       39 |      16 | 1.887740e+14 |  2018 |     3 |     2018 | 6.722670e+14 | 6.722670e+14 |      1 |        1 | 10.2 |  19 |              2 | 43.78530 | -115.0787 |       NA |     NA |   NA |     NA |       92 |     9999 |       NA |       NA |       NA |       NA |           0 |       NA |    NA |     NA |              1 |           3 |
| 16_1_21_82811_3_24 | 16_1_21_82811  |  101 | 82811 |       3 |     1 |       21 |      16 | 1.887743e+14 |  2018 |     3 |     2018 | 6.722486e+14 | 6.722485e+14 |      1 |        2 |  5.6 |  24 |              1 | 48.85808 | -116.6155 | 162.9421 |     31 |   93 |     50 |       22 |     9999 |        0 |       NA |        0 |       NA |         735 | 340.9240 |    70 |    252 |              1 |          NA |
| 16_3_43_84707_4_6  | 16_3_43_84707  |  101 | 84707 |       4 |     1 |       43 |      16 | 1.887747e+14 |  2018 |     3 |     2018 | 6.722612e+14 | 6.722611e+14 |      1 |        2 |  7.8 |  35 |              1 | 44.70547 | -111.3215 |  97.9652 |     39 |   93 |     50 |        0 |       NA |        0 |       NA |        0 |       NA |         670 | 201.6370 |    10 |     38 |              1 |          NA |
| 16_1_49_87401_1_11 | 16_1_49_87401  |  101 | 87401 |       1 |     1 |       49 |      16 | 1.887743e+14 |  2018 |     3 |     2018 | 6.722506e+14 | 6.722506e+14 |      1 |        1 |  6.4 |  24 |              1 | 45.64444 | -115.6534 | 123.0867 |     38 |   93 |     50 |        0 |       NA |        0 |       NA |        0 |       NA |         670 | 221.5113 |    55 |     44 |              1 |          NA |

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

![](WhitebarkPine_db_files/figure-commonmark/unnamed-chunk-4-1.png)

![](WhitebarkPine_db_files/figure-commonmark/unnamed-chunk-4-2.png)

## Saving data to share

``` r
write.csv(whitebark_pine, here::here("use_cases", "whitebark_pine", "whitebark_pine.csv"))
```

The saved file is 6 MB.
