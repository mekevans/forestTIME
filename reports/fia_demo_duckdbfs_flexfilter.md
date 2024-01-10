# Extracting FIA timeseries

## 1. `select_trees`

`select_trees()` extracts persistent IDs for all trees that meet
user-supplied criteria.

By default, `select_trees` returns all trees:

``` r
my_trees <- select_trees_list(connection = "local")

nrow(my_trees)
```

    [1] 341631

``` r
knitr::kable(head(my_trees))
```

| TREE_UNIQUE_ID   | PLOT_UNIQUE_ID | NYEARS | NYEARS_MEASURED | FIRSTYR | LASTYR | SPCD |  PLOT | SUBPLOT | SPCDS | COUNTYCD | STATECD |
|:-----------------|:---------------|-------:|----------------:|--------:|-------:|-----:|------:|--------:|------:|---------:|--------:|
| 27_2_1_20058_1_1 | 27_2_1_20058   |      5 |               5 |    2000 |   2020 |  375 | 20058 |       1 |     1 |        1 |      27 |
| 27_2_1_20058_2_1 | 27_2_1_20058   |      4 |               4 |    2000 |   2015 |  746 | 20058 |       2 |     1 |        1 |      27 |
| 27_2_1_20058_2_2 | 27_2_1_20058   |      3 |               3 |    2000 |   2010 |  746 | 20058 |       2 |     1 |        1 |      27 |
| 27_2_1_20058_2_3 | 27_2_1_20058   |      4 |               4 |    2000 |   2015 |  746 | 20058 |       2 |     1 |        1 |      27 |
| 27_2_1_20058_2_4 | 27_2_1_20058   |      4 |               4 |    2000 |   2015 |  746 | 20058 |       2 |     1 |        1 |      27 |
| 27_2_1_20058_2_5 | 27_2_1_20058   |      4 |               4 |    2000 |   2015 |  746 | 20058 |       2 |     1 |        1 |      27 |

Passing additional options filters the trees:

``` r
# Extract all red maples (SPCD = 316)

my_red_maples <- select_trees_list(condition_list = list(
  SPCD = list("==", 316)
))

nrow(my_red_maples)
```

    [1] 12313

``` r
knitr::kable(head(my_red_maples))
```

| TREE_UNIQUE_ID     | PLOT_UNIQUE_ID | NYEARS | NYEARS_MEASURED | FIRSTYR | LASTYR | SPCD |  PLOT | SUBPLOT | SPCDS | COUNTYCD | STATECD |
|:-------------------|:---------------|-------:|----------------:|--------:|-------:|-----:|------:|--------:|------:|---------:|--------:|
| 27_2_1_20081_102_4 | 27_2_1_20081   |      1 |               1 |    2000 |   2000 |  316 | 20081 |     102 |     1 |        1 |      27 |
| 27_2_1_20081_102_7 | 27_2_1_20081   |      1 |               1 |    2000 |   2000 |  316 | 20081 |     102 |     1 |        1 |      27 |
| 27_2_1_20138_2_5   | 27_2_1_20138   |      5 |               5 |    2000 |   2020 |  316 | 20138 |       2 |     1 |        1 |      27 |
| 27_2_1_20151_2_3   | 27_2_1_20151   |      5 |               5 |    2000 |   2020 |  316 | 20151 |       2 |     1 |        1 |      27 |
| 27_2_1_20151_3_3   | 27_2_1_20151   |      5 |               5 |    2000 |   2020 |  316 | 20151 |       3 |     1 |        1 |      27 |
| 27_2_1_20174_1_21  | 27_2_1_20174   |      5 |               5 |    2000 |   2020 |  316 | 20174 |       1 |     1 |        1 |      27 |

``` r
# Extract red maples on plot 27_3_65_20067

my_red_maples_one_plot <- select_trees_list(condition_list = list(
  SPCD = list("==", 316),
  PLOT_UNIQUE_ID = list("==", "27_3_65_20067")))

nrow(my_red_maples_one_plot)
```

    [1] 9

``` r
knitr::kable(head(my_red_maples_one_plot))
```

| TREE_UNIQUE_ID     | PLOT_UNIQUE_ID | NYEARS | NYEARS_MEASURED | FIRSTYR | LASTYR | SPCD |  PLOT | SUBPLOT | SPCDS | COUNTYCD | STATECD |
|:-------------------|:---------------|-------:|----------------:|--------:|-------:|-----:|------:|--------:|------:|---------:|--------:|
| 27_3_65_20067_3_7  | 27_3_65_20067  |      5 |               5 |    2000 |   2020 |  316 | 20067 |       3 |     1 |       65 |      27 |
| 27_3_65_20067_3_13 | 27_3_65_20067  |      4 |               4 |    2005 |   2020 |  316 | 20067 |       3 |     1 |       65 |      27 |
| 27_3_65_20067_3_14 | 27_3_65_20067  |      3 |               3 |    2010 |   2020 |  316 | 20067 |       3 |     1 |       65 |      27 |
| 27_3_65_20067_3_15 | 27_3_65_20067  |      3 |               3 |    2010 |   2020 |  316 | 20067 |       3 |     1 |       65 |      27 |
| 27_3_65_20067_3_17 | 27_3_65_20067  |      2 |               2 |    2015 |   2020 |  316 | 20067 |       3 |     1 |       65 |      27 |
| 27_3_65_20067_3_18 | 27_3_65_20067  |      2 |               2 |    2015 |   2020 |  316 | 20067 |       3 |     1 |       65 |      27 |

``` r
my_red_maples_one_county <- select_trees_list(list(
  SPCD = list("==", 316),
  STATECD = list("==", 27),
  COUNTYCD = list("==", 65)
))

nrow(my_red_maples_one_county)
```

    [1] 210

``` r
knitr::kable(head(my_red_maples_one_county))
```

| TREE_UNIQUE_ID    | PLOT_UNIQUE_ID | NYEARS | NYEARS_MEASURED | FIRSTYR | LASTYR | SPCD |  PLOT | SUBPLOT | SPCDS | COUNTYCD | STATECD |
|:------------------|:---------------|-------:|----------------:|--------:|-------:|-----:|------:|--------:|------:|---------:|--------:|
| 27_3_65_20067_3_7 | 27_3_65_20067  |      5 |               5 |    2000 |   2020 |  316 | 20067 |       3 |     1 |       65 |      27 |
| 27_3_65_20089_2_5 | 27_3_65_20089  |      2 |               2 |    2000 |   2005 |  316 | 20089 |       2 |     1 |       65 |      27 |
| 27_3_65_20089_3_3 | 27_3_65_20089  |      3 |               3 |    2000 |   2010 |  316 | 20089 |       3 |     1 |       65 |      27 |
| 27_3_65_20012_2_1 | 27_3_65_20012  |      3 |               3 |    2001 |   2011 |  316 | 20012 |       2 |     1 |       65 |      27 |
| 27_3_65_20012_2_2 | 27_3_65_20012  |      3 |               3 |    2001 |   2011 |  316 | 20012 |       2 |     1 |       65 |      27 |
| 27_3_65_20012_4_9 | 27_3_65_20012  |      5 |               5 |    2001 |   2021 |  316 | 20012 |       4 |     1 |       65 |      27 |

## 2. `get_timeseries`

``` r
my_maple_timeseries <- filter_on_passed_vars(my_red_maples_one_county, connection = 'local')
```

    Joining with `by = join_by(PLT_CN, INVYR, UNITCD, PLOT, PLOT_UNIQUE_ID, COUNTYCD, STATECD)`
    Joining with `by = join_by(PLT_CN, INVYR, UNITCD, PLOT, PLOT_UNIQUE_ID, COUNTYCD, STATECD)`

``` r
nrow(my_maple_timeseries)
```

    [1] 773

``` r
knitr::kable(head(my_maple_timeseries))
```

|      TREE_CN | PREV_TRE_CN |       PLT_CN | INVYR | UNITCD | SUBP | TREE |  PLOT | STATUSCD |  DIA |  HT | ACTUALHT | SPCD | CYCLE | TREE_UNIQUE_ID     | PLOT_UNIQUE_ID | COUNTYCD | STATECD |  PREV_PLT_CN | PLOT_STATUS_CD | PLOT_NONSAMPLE_REASN_CD | MEASYEAR | MEASMON | MEASDAY | REMPER | KINDCD | DESIGNCD | RDDISTCD | WATERCD |      LAT |       LON | ELEV |           CN | CONDID | COND_STATUS_CD | COND_NONSAMPLE_REASN_CD |
|-------------:|------------:|-------------:|------:|-------:|-----:|-----:|------:|---------:|-----:|----:|---------:|-----:|------:|:-------------------|:---------------|---------:|--------:|-------------:|---------------:|------------------------:|---------:|--------:|--------:|-------:|-------:|---------:|---------:|--------:|---------:|----------:|-----:|-------------:|-------:|---------------:|------------------------:|
| 6.512366e+13 |          NA | 6.512362e+13 |  2000 |      3 |    3 |    7 | 20067 |        1 |  7.4 |  46 |       46 |  316 |    12 | 27_3_65_20067_3_7  | 27_3_65_20067  |       65 |      27 |           NA |              1 |                      NA |     2000 |       9 |      11 |     NA |      1 |      314 |        4 |       1 | 46.06519 | -93.27359 | 1120 | 6.512363e+13 |      2 |              1 |                      NA |
| 6.568210e+13 |          NA | 6.568205e+13 |  2001 |      3 |    1 |    2 | 20062 |        1 | 11.2 |  63 |       63 |  316 |    12 | 27_3_65_20062_1_2  | 27_3_65_20062  |       65 |      27 | 2.765377e+13 |              1 |                      NA |     2001 |       2 |      18 |     10 |      1 |      321 |        5 |       0 | 46.15622 | -93.21842 | 1260 | 6.568206e+13 |      2 |              1 |                      NA |
| 6.568211e+13 |          NA | 6.568205e+13 |  2001 |      3 |    1 |    5 | 20062 |        1 |  6.6 |  55 |       55 |  316 |    12 | 27_3_65_20062_1_5  | 27_3_65_20062  |       65 |      27 | 2.765377e+13 |              1 |                      NA |     2001 |       2 |      18 |     10 |      1 |      321 |        5 |       0 | 46.15622 | -93.21842 | 1260 | 6.568206e+13 |      2 |              1 |                      NA |
| 6.568211e+13 |          NA | 6.568205e+13 |  2001 |      3 |    1 |    6 | 20062 |        1 |  5.6 |  55 |       55 |  316 |    12 | 27_3_65_20062_1_6  | 27_3_65_20062  |       65 |      27 | 2.765377e+13 |              1 |                      NA |     2001 |       2 |      18 |     10 |      1 |      321 |        5 |       0 | 46.15622 | -93.21842 | 1260 | 6.568206e+13 |      2 |              1 |                      NA |
| 6.568210e+13 |          NA | 6.568205e+13 |  2001 |      3 |    1 |   10 | 20062 |        1 |  7.5 |  60 |       60 |  316 |    12 | 27_3_65_20062_1_10 | 27_3_65_20062  |       65 |      27 | 2.765377e+13 |              1 |                      NA |     2001 |       2 |      18 |     10 |      1 |      321 |        5 |       0 | 46.15622 | -93.21842 | 1260 | 6.568206e+13 |      2 |              1 |                      NA |
| 6.568180e+13 |          NA | 6.568176e+13 |  2001 |      3 |    3 |    1 | 20167 |        1 |  5.6 |  36 |       36 |  316 |    12 | 27_3_65_20167_3_1  | 27_3_65_20167  |       65 |      27 | 2.765376e+13 |              1 |                      NA |     2001 |       3 |      11 |     10 |      1 |      319 |        5 |       2 | 46.13712 | -93.36355 | 1260 | 6.568177e+13 |      2 |              1 |                      NA |

Modifying the time window and variables to return:

``` r
my_maple_timeseries2 <- filter_on_passed_vars(my_red_maples_one_plot, 
                                       conditions = list(STATUSCD = list("==", 1),
                                                         INVYR = list("%in%", 2005:2024),
                                                         CONDID = list("==", 2)),
                                       variables = c("DIA", "HT", "ACTUALHT", "CONDID"),
                                       connection = "local")
```

    Joining with `by = join_by(PLT_CN, INVYR, UNITCD, PLOT, PLOT_UNIQUE_ID, COUNTYCD, STATECD)`
    Joining with `by = join_by(PLT_CN, INVYR, UNITCD, PLOT, PLOT_UNIQUE_ID, COUNTYCD, STATECD)`

``` r
nrow(my_maple_timeseries2)
```

    [1] 23

``` r
knitr::kable(head(my_maple_timeseries2))
```

| TREE_UNIQUE_ID     | PLOT_UNIQUE_ID |           CN | INVYR | STATECD | COUNTYCD | UNITCD |  PLOT | SUBP | TREE | DIA |  HT | ACTUALHT | CONDID |
|:-------------------|:---------------|-------------:|------:|--------:|---------:|-------:|------:|-----:|-----:|----:|----:|---------:|-------:|
| 27_3_65_20067_3_7  | 27_3_65_20067  | 9.891795e+13 |  2005 |      27 |       65 |      3 | 20067 |    3 |    7 | 7.7 |  48 |       48 |      2 |
| 27_3_65_20067_3_13 | 27_3_65_20067  | 9.891795e+13 |  2005 |      27 |       65 |      3 | 20067 |    3 |   13 | 5.7 |  50 |       50 |      2 |
| 27_3_65_20067_3_7  | 27_3_65_20067  | 2.458826e+14 |  2010 |      27 |       65 |      3 | 20067 |    3 |    7 | 7.9 |  53 |       53 |      2 |
| 27_3_65_20067_3_13 | 27_3_65_20067  | 2.458826e+14 |  2010 |      27 |       65 |      3 | 20067 |    3 |   13 | 6.4 |  55 |       55 |      2 |
| 27_3_65_20067_3_14 | 27_3_65_20067  | 2.458826e+14 |  2010 |      27 |       65 |      3 | 20067 |    3 |   14 | 1.0 |  14 |       NA |      2 |
| 27_3_65_20067_3_15 | 27_3_65_20067  | 2.458826e+14 |  2010 |      27 |       65 |      3 | 20067 |    3 |   15 | 1.2 |  16 |       NA |      2 |

Here is a plot of how individual maple trees’ diameters have changed
over time:

<img
src="fia_demo_duckdbfs_flexfilter_files/figure-commonmark/fig-mapledia-1.png"
id="fig-mapledia"
alt="Figure 1: Diameters of red maple trees on plot 20010 over time. Individual lines represent individual trees." />
