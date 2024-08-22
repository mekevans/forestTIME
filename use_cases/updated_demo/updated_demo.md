# Extracting FIA timeseries


``` r
library(ggplot2)

source(here::here("R", "query_tables_db_fxns.R"))
```

    Loading required package: DBI


    Attaching package: 'dplyr'

    The following objects are masked from 'package:stats':

        filter, lag

    The following objects are masked from 'package:base':

        intersect, setdiff, setequal, union

``` r
con <- connect_to_tables(here::here("data", "db", "foresttime-from-state-parquet.duckdb"))
```

## Examples

Extract red maples in county 65:

``` r
ts <- query_tree_surveys(
  con = con,
  conditions = create_conditions(
    STATECD == 27,
    COUNTYCD == 65,
    SPCD == 316,
    ANY_SPCD_FLAG == FALSE
  ),
  variables = c("MEASYEAR", "DIA", "HT", "CONDID")
)
```

    Joining with `by = join_by(TREE_COMPOSITE_ID, PLOT_COMPOSITE_ID, PLOT, SUBP, STATECD, COUNTYCD)`
    Joining with `by = join_by(TREE_COMPOSITE_ID, SPCD_CORR, TREE_CN, INVYR, STATUSCD, SPCD, CYCLE)`
    Joining with `by = join_by(PLOT_COMPOSITE_ID, PLOT, STATECD, COUNTYCD, PLT_CN, INVYR, UNITCD, CYCLE, SUBCYCLE)`
    Joining with `by = join_by(PLOT_COMPOSITE_ID, PLOT, STATECD, COUNTYCD, PLT_CN, INVYR, UNITCD, CONDID, CYCLE, SUBCYCLE)`

``` r
knitr::kable(head(ts))
```

| TREE_COMPOSITE_ID  | PLOT_COMPOSITE_ID | SPCD |  PLOT | SUBP | COUNTYCD | STATECD |       PLT_CN | INVYR | CYCLE | MEASYEAR |      TREE_CN |      COND_CN | CONDID |  DIA |  HT |
|:-------------------|:------------------|-----:|------:|-----:|---------:|--------:|-------------:|------:|------:|---------:|-------------:|-------------:|-------:|-----:|----:|
| 27_3_65_20292_2_4  | 27_3_65_20292     |  316 | 20292 |    2 |       65 |      27 | 6.881069e+13 |  2003 |    12 |     2003 | 6.881072e+13 | 6.881070e+13 |      1 | 10.9 |  65 |
| 27_3_65_20191_1_12 | 27_3_65_20191     |  316 | 20191 |    1 |       65 |      27 | 6.880866e+13 |  2003 |    12 |     2003 | 6.880869e+13 | 6.880866e+13 |      1 |  5.7 |  35 |
| 27_3_65_20292_2_5  | 27_3_65_20292     |  316 | 20292 |    2 |       65 |      27 | 6.881069e+13 |  2003 |    12 |     2003 | 6.881072e+13 | 6.881070e+13 |      1 | 11.7 |  65 |
| 27_3_65_20191_1_14 | 27_3_65_20191     |  316 | 20191 |    1 |       65 |      27 | 6.880866e+13 |  2003 |    12 |     2003 | 6.880869e+13 | 6.880866e+13 |      1 |  6.9 |  35 |
| 27_3_65_20292_1_4  | 27_3_65_20292     |  316 | 20292 |    1 |       65 |      27 | 6.881069e+13 |  2003 |    12 |     2003 | 6.881074e+13 | 6.881070e+13 |      1 |  7.7 |  55 |
| 27_3_65_20191_1_13 | 27_3_65_20191     |  316 | 20191 |    1 |       65 |      27 | 6.880866e+13 |  2003 |    12 |     2003 | 6.880869e+13 | 6.880866e+13 |      1 | 12.2 |  70 |

Extract those same measurements for plot 27_3_65_20042, for a few
species:

``` r
ts2 <- query_tree_surveys(
  con = con,
  conditions = create_conditions(
    STATECD == 27,
    COUNTYCD == 65,
    PLOT_COMPOSITE_ID == "27_3_65_20042",
    SPCD %in% c(316, 701, 833, 375),
    ANY_SPCD_FLAG == FALSE
  ),
  variables = c("MEASYEAR", "DIA", "HT", "CONDID")
)
```

    Joining with `by = join_by(TREE_COMPOSITE_ID, PLOT_COMPOSITE_ID, PLOT, SUBP, STATECD, COUNTYCD)`
    Joining with `by = join_by(TREE_COMPOSITE_ID, SPCD_CORR, TREE_CN, INVYR, STATUSCD, SPCD, CYCLE)`
    Joining with `by = join_by(PLOT_COMPOSITE_ID, PLOT, STATECD, COUNTYCD, PLT_CN, INVYR, UNITCD, CYCLE, SUBCYCLE)`
    Joining with `by = join_by(PLOT_COMPOSITE_ID, PLOT, STATECD, COUNTYCD, PLT_CN, INVYR, UNITCD, CONDID, CYCLE, SUBCYCLE)`

``` r
knitr::kable(head(ts2))
```

| TREE_COMPOSITE_ID  | PLOT_COMPOSITE_ID | SPCD |  PLOT | SUBP | COUNTYCD | STATECD |       PLT_CN | INVYR | CYCLE | MEASYEAR |      TREE_CN |      COND_CN | CONDID |  DIA |  HT |
|:-------------------|:------------------|-----:|------:|-----:|---------:|--------:|-------------:|------:|------:|---------:|-------------:|-------------:|-------:|-----:|----:|
| 27_3_65_20042_3_13 | 27_3_65_20042     |  316 | 20042 |    3 |       65 |      27 | 5.140781e+14 |  2019 |    16 |     2019 | 7.205274e+14 | 7.205273e+14 |      1 |  5.3 |  55 |
| 27_3_65_20042_1_5  | 27_3_65_20042     |  316 | 20042 |    1 |       65 |      27 | 1.082962e+14 |  2009 |    14 |     2009 | 2.264175e+14 | 2.264175e+14 |      1 | 11.4 |  77 |
| 27_3_65_20042_1_5  | 27_3_65_20042     |  316 | 20042 |    1 |       65 |      27 | 5.140781e+14 |  2019 |    16 |     2019 | 7.205273e+14 | 7.205273e+14 |      1 | 12.4 |  63 |
| 27_3_65_20042_1_8  | 27_3_65_20042     |  316 | 20042 |    1 |       65 |      27 | 1.712551e+14 |  2014 |    15 |     2014 | 3.011725e+14 | 3.011724e+14 |      1 |  6.5 |  53 |
| 27_3_65_20042_3_1  | 27_3_65_20042     |  833 | 20042 |    3 |       65 |      27 | 1.712551e+14 |  2014 |    15 |     2014 | 3.011725e+14 | 3.011724e+14 |      1 |  8.4 |  73 |
| 27_3_65_20042_3_1  | 27_3_65_20042     |  833 | 20042 |    3 |       65 |      27 | 1.082962e+14 |  2009 |    14 |     2009 | 2.264175e+14 | 2.264175e+14 |      1 |  8.1 |  71 |

Plotting the results:

``` r
ggplot(ts2, aes(MEASYEAR, DIA, group = TREE_COMPOSITE_ID, color = as.factor(SPCD))) +
  geom_point() +
  geom_line() +
  theme_bw() +
  scale_color_viridis_d("SPCD", end = .8) +
  facet_wrap(vars(SPCD), scales = "free")
```

    Warning: Removed 9 rows containing missing values or values outside the scale range
    (`geom_point()`).

    Warning: Removed 9 rows containing missing values or values outside the scale range
    (`geom_line()`).

![](updated_demo_files/figure-commonmark/unnamed-chunk-4-1.png)

``` r
dbDisconnect(con, shutdown = TRUE)
```
