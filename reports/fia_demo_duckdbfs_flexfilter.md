# Extracting FIA timeseries

## 1. `select_trees`

`select_trees()` extracts persistent IDs for all trees that meet
user-supplied criteria.

In this example, the criteria include:

- `STATECD`
- `COUNTYD`
- `PLOT`
- `SPCD`
- `min_years`, the minimum number of years between the first and last
  measurement
- `min_measurements`, the minimum number of survey visits to that tree

By default, `select_trees` returns all trees:

``` r
my_trees <- select_trees(connection = "local")

nrow(my_trees)
```

    [1] 262304

``` r
knitr::kable(head(my_trees))
```

| TREE_UNIQUE_ID     | PLOT_UNIQUE_ID | NYEARS | NYEARS_MEASURED | FIRSTYR | LASTYR | SPCD |  PLOT | SUBPLOT | SPCDS | COUNTYCD | STATECD |
|:-------------------|:---------------|-------:|----------------:|--------:|-------:|-----:|------:|--------:|------:|---------:|--------:|
| 27_3_111_20191_2_1 | 27_3_111_20191 |      3 |               3 |    2000 |   2010 |  972 | 20191 |       2 |     1 |      111 |      27 |
| 27_3_111_20191_2_2 | 27_3_111_20191 |      3 |               3 |    2000 |   2010 |  972 | 20191 |       2 |     1 |      111 |      27 |
| 27_3_111_20191_2_3 | 27_3_111_20191 |      3 |               3 |    2000 |   2010 |  972 | 20191 |       2 |     1 |      111 |      27 |
| 27_3_111_20191_2_4 | 27_3_111_20191 |      3 |               3 |    2000 |   2010 |  972 | 20191 |       2 |     1 |      111 |      27 |
| 27_3_111_20191_2_5 | 27_3_111_20191 |      3 |               3 |    2000 |   2010 |  972 | 20191 |       2 |     1 |      111 |      27 |
| 27_3_111_20191_2_6 | 27_3_111_20191 |      3 |               3 |    2000 |   2010 |  972 | 20191 |       2 |     1 |      111 |      27 |

Passing additional options filters the trees:

``` r
# Extract all red maples (SPCD = 316)

my_red_maples <- select_trees(spcd = 316, connection = "local")

nrow(my_red_maples)
```

    [1] 9546

``` r
knitr::kable(head(my_red_maples))
```

| TREE_UNIQUE_ID      | PLOT_UNIQUE_ID | NYEARS | NYEARS_MEASURED | FIRSTYR | LASTYR | SPCD |  PLOT | SUBPLOT | SPCDS | COUNTYCD | STATECD |
|:--------------------|:---------------|-------:|----------------:|--------:|-------:|-----:|------:|--------:|------:|---------:|--------:|
| 27_3_157_20194_3_1  | 27_3_157_20194 |      2 |               2 |    2003 |   2008 |  316 | 20194 |       3 |     1 |      157 |      27 |
| 27_3_157_20048_3_11 | 27_3_157_20048 |      3 |               3 |    2010 |   2020 |  316 | 20048 |       3 |     1 |      157 |      27 |
| 27_2_29_20540_4_1   | 27_2_29_20540  |      5 |               5 |    2000 |   2020 |  316 | 20540 |       4 |     1 |       29 |      27 |
| 27_2_29_20540_4_5   | 27_2_29_20540  |      5 |               5 |    2000 |   2020 |  316 | 20540 |       4 |     1 |       29 |      27 |
| 27_2_29_20552_2_1   | 27_2_29_20552  |      5 |               5 |    2000 |   2020 |  316 | 20552 |       2 |     1 |       29 |      27 |
| 27_2_29_20552_2_2   | 27_2_29_20552  |      5 |               5 |    2000 |   2020 |  316 | 20552 |       2 |     1 |       29 |      27 |

``` r
# Extract red maples on plot 27_3_65_20067

my_red_maples_one_plot <- select_trees(spcd = 316,
                                   plot_unique_id = "27_3_65_20067")

nrow(my_red_maples_one_plot)
```

    [1] 8

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
my_red_maples_one_county <- select_trees(spcd = 316,
                                         state = 27,
                                         county = 65)

nrow(my_red_maples_one_county)
```

    [1] 184

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

nrow(my_maple_timeseries)
```

    [1] 569

``` r
knitr::kable(head(my_maple_timeseries))
```

| TREE_UNIQUE_ID    | PLOT_UNIQUE_ID |           CN | INVYR | STATECD | COUNTYCD | UNITCD |  PLOT | SUBP | TREE |  DIA |  HT | STATUSCD |
|:------------------|:---------------|-------------:|------:|--------:|---------:|-------:|------:|-----:|-----:|-----:|----:|---------:|
| 27_3_65_20067_3_7 | 27_3_65_20067  | 6.512366e+13 |  2000 |      27 |       65 |      3 | 20067 |    3 |    7 |  7.4 |  46 |        1 |
| 27_3_65_20012_2_1 | 27_3_65_20012  | 6.568253e+13 |  2001 |      27 |       65 |      3 | 20012 |    2 |    1 |  8.1 |  56 |        1 |
| 27_3_65_20012_2_2 | 27_3_65_20012  | 6.568253e+13 |  2001 |      27 |       65 |      3 | 20012 |    2 |    2 |  5.4 |  37 |        1 |
| 27_3_65_20012_4_9 | 27_3_65_20012  | 6.568256e+13 |  2001 |      27 |       65 |      3 | 20012 |    4 |    9 |  1.0 |  14 |        1 |
| 27_3_65_20062_1_2 | 27_3_65_20062  | 6.568210e+13 |  2001 |      27 |       65 |      3 | 20062 |    1 |    2 | 11.2 |  63 |        1 |
| 27_3_65_20062_1_5 | 27_3_65_20062  | 6.568211e+13 |  2001 |      27 |       65 |      3 | 20062 |    1 |    5 |  6.6 |  55 |        1 |

Modifying the time window and variables to return:

``` r
my_maple_timeseries2 <- filter_on_passed_vars(my_red_maples_one_plot, 
                                       conditions = list(STATUSCD = list("==", 1),
                                                         INVYR = list("%in%", 2005:2024)),
                                       variables = c("DIA", "HT", "ACTUALHT", "STATUSCD"),
                                       connection = "local")

nrow(my_maple_timeseries2)
```

    [1] 22

``` r
knitr::kable(head(my_maple_timeseries2))
```

| TREE_UNIQUE_ID     | PLOT_UNIQUE_ID |           CN | INVYR | STATECD | COUNTYCD | UNITCD |  PLOT | SUBP | TREE | DIA |  HT | ACTUALHT | STATUSCD |
|:-------------------|:---------------|-------------:|------:|--------:|---------:|-------:|------:|-----:|-----:|----:|----:|---------:|---------:|
| 27_3_65_20067_3_7  | 27_3_65_20067  | 9.891798e+13 |  2005 |      27 |       65 |      3 | 20067 |    3 |    7 | 7.7 |  48 |       48 |        1 |
| 27_3_65_20067_3_13 | 27_3_65_20067  | 9.891800e+13 |  2005 |      27 |       65 |      3 | 20067 |    3 |   13 | 5.7 |  50 |       50 |        1 |
| 27_3_65_20067_3_7  | 27_3_65_20067  | 2.458826e+14 |  2010 |      27 |       65 |      3 | 20067 |    3 |    7 | 7.9 |  53 |       53 |        1 |
| 27_3_65_20067_3_13 | 27_3_65_20067  | 2.458826e+14 |  2010 |      27 |       65 |      3 | 20067 |    3 |   13 | 6.4 |  55 |       55 |        1 |
| 27_3_65_20067_3_14 | 27_3_65_20067  | 2.458826e+14 |  2010 |      27 |       65 |      3 | 20067 |    3 |   14 | 1.0 |  14 |       NA |        1 |
| 27_3_65_20067_3_15 | 27_3_65_20067  | 2.458826e+14 |  2010 |      27 |       65 |      3 | 20067 |    3 |   15 | 1.2 |  16 |       NA |        1 |

Here is a plot of how individual maple trees’ diameters have changed
over time:

<img
src="fia_demo_duckdbfs_flexfilter_files/figure-commonmark/fig-mapledia-1.png"
id="fig-mapledia"
alt="Figure 1: Diameters of red maple trees on plot 20010 over time. Individual lines represent individual trees." />
