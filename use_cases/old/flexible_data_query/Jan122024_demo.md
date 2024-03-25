# Extracting FIA timeseries

# `get_timeseries`

The `get_timeseries` function takes a *list of conditions* and a *list
of variables* and returns a timeseries of the requested variables for
the trees/surveys that meet the supplied conditions.

“Conditions” can include location (PLOT, COUNTYCD, STATECD), tree
attributes (SPCD, number of years measured), or survey attributes
(STATUSCD, DIA, CONDID). These conditions can come from any of the TREE,
PLOT, or CONDITION tables in the FIA database.

“Variables” can include any of the columns from the TREE, PLOT, or
CONDITION tables.

The resulting timeseries identify individual trees using the
TREE_UNIQUE_ID field, which is a composite of STATE, COUNTY, UNIT, PLOT,
SUBPLOT, and TREE. (There is also the option of daisy-chaining, but in
my tests with MN and AZ, the two methods are either identical, or the
daisy-chain method is more prone to breaks/apparent errors.)

## Examples

Extract all variables red maples in county 65:

``` r
ts <- get_timeseries(
  conditions = list(SPCD = list("==", 316),
                    COUNTYCD = list("==", 65))
)
```

    Joining with `by = join_by(PLT_CN, INVYR, UNITCD, PLOT, PLOT_UNIQUE_ID, COUNTYCD, STATECD)`
    Joining with `by = join_by(PLT_CN, INVYR, UNITCD, PLOT, PLOT_UNIQUE_ID, COUNTYCD, STATECD)`

``` r
knitr::kable(head(ts))
```

| TREE_UNIQUE_ID    | PLOT_UNIQUE_ID |      TREE_CN |  PREV_TRE_CN |       PLT_CN | INVYR | UNITCD | SUBP | TREE |  PLOT | STATUSCD | DIA |  HT | ACTUALHT | SPCD | CYCLE | COUNTYCD | STATECD |  PREV_PLT_CN | PLOT_STATUS_CD | PLOT_NONSAMPLE_REASN_CD | MEASYEAR | MEASMON | MEASDAY | REMPER | KINDCD | DESIGNCD | RDDISTCD | WATERCD |      LAT |       LON | ELEV |           CN | CONDID | COND_STATUS_CD | COND_NONSAMPLE_REASN_CD |
|:------------------|:---------------|-------------:|-------------:|-------------:|------:|-------:|-----:|-----:|------:|---------:|----:|----:|---------:|-----:|------:|---------:|--------:|-------------:|---------------:|------------------------:|---------:|--------:|--------:|-------:|-------:|---------:|---------:|--------:|---------:|----------:|-----:|-------------:|-------:|---------------:|------------------------:|
| 27_3_65_20010_3_6 | 27_3_65_20010  | 2.458825e+14 |           NA | 1.691023e+14 |  2010 |      3 |    3 |    6 | 20010 |        1 | 5.2 |  36 |       36 |  316 |    14 |       65 |      27 | 9.891769e+13 |              1 |                      NA |     2010 |       6 |       9 |    5.3 |      2 |        1 |        7 |       1 | 46.14329 | -93.24641 | 1160 | 2.458824e+14 |      1 |              1 |                      NA |
| 27_3_65_20010_3_6 | 27_3_65_20010  | 3.666293e+14 | 2.458825e+14 | 2.317350e+14 |  2015 |      3 |    3 |    6 | 20010 |        1 | 6.4 |  41 |       41 |  316 |    15 |       65 |      27 | 1.691023e+14 |              1 |                      NA |     2015 |       4 |      28 |    4.9 |      2 |        1 |        7 |       2 | 46.14329 | -93.24641 | 1160 | 3.666293e+14 |      1 |              1 |                      NA |
| 27_3_65_20010_3_6 | 27_3_65_20010  | 1.210969e+15 | 3.666293e+14 | 6.105529e+14 |  2020 |      3 |    3 |    6 | 20010 |        1 | 7.4 |  43 |       43 |  316 |    16 |       65 |      27 | 2.317350e+14 |              1 |                      NA |     2020 |       3 |       4 |    4.9 |      2 |        1 |        7 |       2 | 46.14329 | -93.24641 | 1160 | 1.210969e+15 |      1 |              1 |                      NA |
| 27_3_65_20010_3_7 | 27_3_65_20010  | 3.666293e+14 |           NA | 2.317350e+14 |  2015 |      3 |    3 |    7 | 20010 |        1 | 6.1 |  55 |       55 |  316 |    15 |       65 |      27 | 1.691023e+14 |              1 |                      NA |     2015 |       4 |      28 |    4.9 |      2 |        1 |        7 |       2 | 46.14329 | -93.24641 | 1160 | 3.666293e+14 |      1 |              1 |                      NA |
| 27_3_65_20010_3_7 | 27_3_65_20010  | 1.210969e+15 | 3.666293e+14 | 6.105529e+14 |  2020 |      3 |    3 |    7 | 20010 |        1 | 7.5 |  53 |       53 |  316 |    16 |       65 |      27 | 2.317350e+14 |              1 |                      NA |     2020 |       3 |       4 |    4.9 |      2 |        1 |        7 |       2 | 46.14329 | -93.24641 | 1160 | 1.210969e+15 |      1 |              1 |                      NA |
| 27_3_65_20010_3_9 | 27_3_65_20010  | 1.210969e+15 |           NA | 6.105529e+14 |  2020 |      3 |    3 |    9 | 20010 |        1 | 1.1 |  18 |       18 |  316 |    16 |       65 |      27 | 2.317350e+14 |              1 |                      NA |     2020 |       3 |       4 |    4.9 |      2 |        1 |        7 |       2 | 46.14329 | -93.24641 | 1160 | 1.210969e+15 |      1 |              1 |                      NA |

Extract DIA, HT, CONDID and MEASYEAR for red maples in county 65:

``` r
ts2 <- get_timeseries(
  conditions = list(SPCD = list("==", 316),
                    COUNTYCD = list("==", 65)),
  variables = c("MEASYEAR", "DIA", "HT", "CONDID")
)
```

    Joining with `by = join_by(PLT_CN, INVYR, UNITCD, PLOT, PLOT_UNIQUE_ID, COUNTYCD, STATECD)`
    Joining with `by = join_by(PLT_CN, INVYR, UNITCD, PLOT, PLOT_UNIQUE_ID, COUNTYCD, STATECD)`

``` r
knitr::kable(head(ts2))
```

| TREE_UNIQUE_ID    | PLOT_UNIQUE_ID |           CN | INVYR | STATECD | COUNTYCD | UNITCD |  PLOT | SUBP | TREE | SPCD | MEASYEAR | DIA |  HT | CONDID |
|:------------------|:---------------|-------------:|------:|--------:|---------:|-------:|------:|-----:|-----:|-----:|---------:|----:|----:|-------:|
| 27_3_65_20010_3_6 | 27_3_65_20010  | 2.458824e+14 |  2010 |      27 |       65 |      3 | 20010 |    3 |    6 |  316 |     2010 | 5.2 |  36 |      1 |
| 27_3_65_20010_3_6 | 27_3_65_20010  | 3.666293e+14 |  2015 |      27 |       65 |      3 | 20010 |    3 |    6 |  316 |     2015 | 6.4 |  41 |      1 |
| 27_3_65_20010_3_6 | 27_3_65_20010  | 1.210969e+15 |  2020 |      27 |       65 |      3 | 20010 |    3 |    6 |  316 |     2020 | 7.4 |  43 |      1 |
| 27_3_65_20010_3_7 | 27_3_65_20010  | 3.666293e+14 |  2015 |      27 |       65 |      3 | 20010 |    3 |    7 |  316 |     2015 | 6.1 |  55 |      1 |
| 27_3_65_20010_3_7 | 27_3_65_20010  | 1.210969e+15 |  2020 |      27 |       65 |      3 | 20010 |    3 |    7 |  316 |     2020 | 7.5 |  53 |      1 |
| 27_3_65_20010_3_9 | 27_3_65_20010  | 1.210969e+15 |  2020 |      27 |       65 |      3 | 20010 |    3 |    9 |  316 |     2020 | 1.1 |  18 |      1 |

Extract those same measurements for plot 27_3_65_20042, for a few
species:

``` r
ts3 <- get_timeseries(
  conditions = list(COUNTYCD = list("==", 65),
                    PLOT_UNIQUE_ID = list("==", "27_3_65_20042"),
                    SPCD = list("%in%", c(316, 701, 833, 375))),
  variables = c("MEASYEAR", "DIA", "HT", "CONDID")
)
```

    Joining with `by = join_by(PLT_CN, INVYR, UNITCD, PLOT, PLOT_UNIQUE_ID, COUNTYCD, STATECD)`
    Joining with `by = join_by(PLT_CN, INVYR, UNITCD, PLOT, PLOT_UNIQUE_ID, COUNTYCD, STATECD)`

``` r
knitr::kable(head(ts3))
```

| TREE_UNIQUE_ID     | PLOT_UNIQUE_ID |           CN | INVYR | STATECD | COUNTYCD | UNITCD |  PLOT | SUBP | TREE | SPCD | MEASYEAR |  DIA |  HT | CONDID |
|:-------------------|:---------------|-------------:|------:|--------:|---------:|-------:|------:|-----:|-----:|-----:|---------:|-----:|----:|-------:|
| 27_3_65_20042_1_1  | 27_3_65_20042  | 9.227136e+13 |  2004 |      27 |       65 |      3 | 20042 |    1 |    1 |  316 |     2004 | 12.3 |  62 |      1 |
| 27_3_65_20042_1_1  | 27_3_65_20042  | 2.264175e+14 |  2009 |      27 |       65 |      3 | 20042 |    1 |    1 |  316 |     2009 | 13.0 |  58 |      1 |
| 27_3_65_20042_1_1  | 27_3_65_20042  | 3.011724e+14 |  2014 |      27 |       65 |      3 | 20042 |    1 |    1 |  316 |     2014 | 13.4 |  59 |      1 |
| 27_3_65_20042_1_1  | 27_3_65_20042  | 7.205273e+14 |  2019 |      27 |       65 |      3 | 20042 |    1 |    1 |  316 |     2019 | 13.6 |  59 |      1 |
| 27_3_65_20042_1_10 | 27_3_65_20042  | 9.227136e+13 |  2004 |      27 |       65 |      3 | 20042 |    1 |   10 |  375 |     2004 | 10.4 |  58 |      1 |
| 27_3_65_20042_1_10 | 27_3_65_20042  | 2.264175e+14 |  2009 |      27 |       65 |      3 | 20042 |    1 |   10 |  375 |     2009 |   NA |  NA |      1 |

Plotting the results:

``` r
ggplot(ts3, aes(MEASYEAR, DIA, group = TREE_UNIQUE_ID, color = as.factor(SPCD))) +
  geom_point() +
  geom_line() +
  theme_bw() +
  scale_color_viridis_d("SPCD", end = .8) +
  facet_wrap(vars(SPCD), scales = "free")
```

    Warning: Removed 9 rows containing missing values (`geom_point()`).

    Warning: Removed 9 rows containing missing values (`geom_line()`).

![](Jan122024_demo_files/figure-commonmark/unnamed-chunk-5-1.png)
