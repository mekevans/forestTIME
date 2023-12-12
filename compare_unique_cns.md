# Comparison of daisy chain and tree number

## Context

The “daisy chain” method is to link backwards in time using
`PREV_TRE_CN` and `CN`. The “tree number” method is to concatenate
columns `STATECD`, `UNITCD`, `COUNTYCD`, `PLOT`, `SUBP`, and `TREE` to
get a unique tree number for each tree. In principle these *should* give
equivalent outcomes, but we don’t know if they really always do!

## Code

``` r
library(arrow)
```


    Attaching package: 'arrow'

    The following object is masked from 'package:utils':

        timestamp

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

state_number <- c(4, 9, 27)
arrow_dir <- "data/arrow"
```

``` r
tree_unique_number <- open_dataset(
  here::here(arrow_dir, "TREE_RAW"),
  partitioning = c("STATECD", "COUNTYCD"),
  format = "csv",
  hive_style = T,
  col_types = schema(
    CN = float64(),
    TREE_FIRST_CN = float64()
  )) |>
  filter(STATECD %in% state_number) |>
  mutate(TREE_UNIQUE_NUM = paste(STATECD,
                                 UNITCD,
                                 COUNTYCD,
                                 PLOT,
                                 SUBP,
                                 TREE, 
                                 sep = "_")) |>
  compute()
```

``` r
join_cns <-  open_dataset(
  here::here(arrow_dir, "TREE_CN_JOIN"),
  partitioning = c("STATECD", "COUNTYCD"),
  format = "csv",
  hive_style = T,
  col_types = schema(
    CN = float64(),
    TREE_FIRST_CN = float64()
  )) |>
  filter(STATECD %in% state_number) |>
  compute()
```

``` r
unmatched_cns <- join_cns |>
  left_join(tree_unique_number) |>
  select(TREE_FIRST_CN, TREE_UNIQUE_NUM) |> 
  distinct() |>
  collect() |> 
  group_by(TREE_FIRST_CN) |>
  mutate(n_NUM = n()) |>
  group_by(TREE_UNIQUE_NUM) |>
  mutate(n_FIRST_CN = n()) |>
  ungroup() |>
  filter(n_NUM > 1 |
           n_FIRST_CN > 1)

unmatched_deeper_dives <- join_cns |>
  left_join(tree_unique_number) |>
  filter(TREE_UNIQUE_NUM %in% unmatched_cns$TREE_UNIQUE_NUM) |>
  arrange(TREE_UNIQUE_NUM, CYCLE) |>
  collect() |>
  mutate(TREE_FIRST_CN = as.character(TREE_FIRST_CN),
         CN = as.character(CN),
         PREV_TRE_CN = as.character(PREV_TRE_CN)) |>
  group_by(TREE_UNIQUE_NUM) |>
  mutate(CN_break = TREE_FIRST_CN != CN[1]) |>
  mutate(prev_break = lag(CN_break),
         prev_status = lag(STATUSCD)) |>
  mutate(is_break_point = ifelse(CN_break, ifelse(prev_break, FALSE, TRUE), FALSE)) 
```

There are 3288 instances where there isn’t a perfect 1-1 matching of one
TREE_UNIQUE_NUM to TREE_FIRST_CN. For these, it’s always that 1
TREE_UNIQUE_NUM has matched to multiple TREE_FIRST_CNs.

## Mismatches

### CT

CT has no mismatches.

### MN

In MN, each of these instances occurred when a tree had a `STATUSCD = 0`
in one cycle and then received a new `CN` and a `PREV_TRE_CN = NA` in
the following cycle. That is, in the following cycle, the previous tree
CN was forgotten and the chain was broken.

`STATUSCD = 0` means a tree is not part of the current sample, e.g. due
to being incorrectly tallied or on a dangerous or inaccessible
condition.

In MN, *all* of the breaks occurred on plot 21085, subplots 1 and 2, in
2012. Perhaps something was the matter with those plots in 2012?

Below is tables showing this.

``` r
mn_deeper_dives <- unmatched_deeper_dives |>
  filter(STATECD == 27)

knitr::kable(mn_deeper_dives)
```

| CN              | TREE_FIRST_CN   | STATECD | COUNTYCD | PREV_TRE_CN     | INVYR | UNITCD | SUBP | TREE |  PLOT | STATUSCD |  DIA |  HT | ACTUALHT | SPCD | CYCLE | TREE_UNIQUE_NUM   | CN_break | prev_break | prev_status | is_break_point |
|:----------------|:----------------|--------:|---------:|:----------------|------:|-------:|-----:|-----:|------:|---------:|-----:|----:|---------:|-----:|------:|:------------------|:---------|:-----------|------------:|:---------------|
| 65979844010661  | 65979844010661  |      27 |        7 | NA              |  2002 |      2 |    1 |   10 | 21085 |        1 |  5.7 |  56 |       56 |  746 |    12 | 27_2_7_21085_1_10 | FALSE    | NA         |          NA | FALSE          |
| 156048332010661 | 65979844010661  |      27 |        7 | 65979844010661  |  2007 |      2 |    1 |   10 | 21085 |        0 |   NA |  NA |       NA |  746 |    13 | 27_2_7_21085_1_10 | FALSE    | FALSE      |           1 | FALSE          |
| 167064488020004 | 167064488020004 |      27 |        7 | NA              |  2012 |      2 |    1 |   10 | 21085 |        1 |  7.1 |  57 |       57 |  746 |    14 | 27_2_7_21085_1_10 | TRUE     | FALSE      |           0 | TRUE           |
| 499615923126144 | 167064488020004 |      27 |        7 | 167064488020004 |  2017 |      2 |    1 |   10 | 21085 |        1 |  7.6 |  55 |       55 |  746 |    15 | 27_2_7_21085_1_10 | TRUE     | TRUE       |           1 | FALSE          |
| 65979846010661  | 65979846010661  |      27 |        7 | NA              |  2002 |      2 |    1 |   11 | 21085 |        1 |  5.8 |  56 |       56 |  746 |    12 | 27_2_7_21085_1_11 | FALSE    | NA         |          NA | FALSE          |
| 156048333010661 | 65979846010661  |      27 |        7 | 65979846010661  |  2007 |      2 |    1 |   11 | 21085 |        0 |   NA |  NA |       NA |  746 |    13 | 27_2_7_21085_1_11 | FALSE    | FALSE      |           1 | FALSE          |
| 167064489020004 | 167064489020004 |      27 |        7 | NA              |  2012 |      2 |    1 |   11 | 21085 |        1 |  7.6 |  61 |       61 |  746 |    14 | 27_2_7_21085_1_11 | TRUE     | FALSE      |           0 | TRUE           |
| 499615924126144 | 167064489020004 |      27 |        7 | 167064489020004 |  2017 |      2 |    1 |   11 | 21085 |        1 |  8.3 |  58 |       58 |  746 |    15 | 27_2_7_21085_1_11 | TRUE     | TRUE       |           1 | FALSE          |
| 65979848010661  | 65979848010661  |      27 |        7 | NA              |  2002 |      2 |    1 |   12 | 21085 |        1 |  5.1 |  51 |       51 |  746 |    12 | 27_2_7_21085_1_12 | FALSE    | NA         |          NA | FALSE          |
| 156048334010661 | 65979848010661  |      27 |        7 | 65979848010661  |  2007 |      2 |    1 |   12 | 21085 |        0 |   NA |  NA |       NA |  746 |    13 | 27_2_7_21085_1_12 | FALSE    | FALSE      |           1 | FALSE          |
| 167064490020004 | 167064490020004 |      27 |        7 | NA              |  2012 |      2 |    1 |   12 | 21085 |        1 |  6.9 |  57 |       57 |  746 |    14 | 27_2_7_21085_1_12 | TRUE     | FALSE      |           0 | TRUE           |
| 499615925126144 | 167064490020004 |      27 |        7 | 167064490020004 |  2017 |      2 |    1 |   12 | 21085 |        1 |  7.9 |  60 |       60 |  746 |    15 | 27_2_7_21085_1_12 | TRUE     | TRUE       |           1 | FALSE          |
| 65979850010661  | 65979850010661  |      27 |        7 | NA              |  2002 |      2 |    1 |   13 | 21085 |        1 |  9.8 |  56 |       56 |  746 |    12 | 27_2_7_21085_1_13 | FALSE    | NA         |          NA | FALSE          |
| 156048335010661 | 65979850010661  |      27 |        7 | 65979850010661  |  2007 |      2 |    1 |   13 | 21085 |        0 |   NA |  NA |       NA |  746 |    13 | 27_2_7_21085_1_13 | FALSE    | FALSE      |           1 | FALSE          |
| 167064491020004 | 167064491020004 |      27 |        7 | NA              |  2012 |      2 |    1 |   13 | 21085 |        1 | 11.5 |  65 |       65 |  746 |    14 | 27_2_7_21085_1_13 | TRUE     | FALSE      |           0 | TRUE           |
| 499615926126144 | 167064491020004 |      27 |        7 | 167064491020004 |  2017 |      2 |    1 |   13 | 21085 |        1 | 12.2 |  70 |       70 |  746 |    15 | 27_2_7_21085_1_13 | TRUE     | TRUE       |           1 | FALSE          |
| 65979852010661  | 65979852010661  |      27 |        7 | NA              |  2002 |      2 |    1 |   14 | 21085 |        1 |  4.5 |  38 |       NA |  746 |    12 | 27_2_7_21085_1_14 | FALSE    | NA         |          NA | FALSE          |
| 156048336010661 | 65979852010661  |      27 |        7 | 65979852010661  |  2007 |      2 |    1 |   14 | 21085 |        0 |   NA |  NA |       NA |  746 |    13 | 27_2_7_21085_1_14 | FALSE    | FALSE      |           1 | FALSE          |
| 167064492020004 | 167064492020004 |      27 |        7 | NA              |  2012 |      2 |    1 |   14 | 21085 |        1 |  6.4 |  48 |       48 |  746 |    14 | 27_2_7_21085_1_14 | TRUE     | FALSE      |           0 | TRUE           |
| 499615927126144 | 167064492020004 |      27 |        7 | 167064492020004 |  2017 |      2 |    1 |   14 | 21085 |        1 |  7.2 |  55 |       55 |  746 |    15 | 27_2_7_21085_1_14 | TRUE     | TRUE       |           1 | FALSE          |
| 65979834010661  | 65979834010661  |      27 |        7 | NA              |  2002 |      2 |    1 |    5 | 21085 |        2 |  6.1 |  42 |        5 |  746 |    12 | 27_2_7_21085_1_5  | FALSE    | NA         |          NA | FALSE          |
| 156048327010661 | 65979834010661  |      27 |        7 | 65979834010661  |  2007 |      2 |    1 |    5 | 21085 |        0 |   NA |  NA |       NA |  746 |    13 | 27_2_7_21085_1_5  | FALSE    | FALSE      |           2 | FALSE          |
| 167064483020004 | 167064483020004 |      27 |        7 | NA              |  2012 |      2 |    1 |    5 | 21085 |        2 |  5.7 |  41 |        5 |  746 |    14 | 27_2_7_21085_1_5  | TRUE     | FALSE      |           0 | TRUE           |
| 499615918126144 | 167064483020004 |      27 |        7 | 167064483020004 |  2017 |      2 |    1 |    5 | 21085 |        2 |   NA |  NA |       NA |  746 |    15 | 27_2_7_21085_1_5  | TRUE     | TRUE       |           2 | FALSE          |
| 65979836010661  | 65979836010661  |      27 |        7 | NA              |  2002 |      2 |    1 |    6 | 21085 |        1 |  8.8 |  68 |       68 |  746 |    12 | 27_2_7_21085_1_6  | FALSE    | NA         |          NA | FALSE          |
| 156048328010661 | 65979836010661  |      27 |        7 | 65979836010661  |  2007 |      2 |    1 |    6 | 21085 |        0 |   NA |  NA |       NA |  746 |    13 | 27_2_7_21085_1_6  | FALSE    | FALSE      |           1 | FALSE          |
| 167064484020004 | 167064484020004 |      27 |        7 | NA              |  2012 |      2 |    1 |    6 | 21085 |        1 | 10.2 |  67 |       67 |  746 |    14 | 27_2_7_21085_1_6  | TRUE     | FALSE      |           0 | TRUE           |
| 499615919126144 | 167064484020004 |      27 |        7 | 167064484020004 |  2017 |      2 |    1 |    6 | 21085 |        1 | 11.0 |  70 |       70 |  746 |    15 | 27_2_7_21085_1_6  | TRUE     | TRUE       |           1 | FALSE          |
| 65979838010661  | 65979838010661  |      27 |        7 | NA              |  2002 |      2 |    1 |    7 | 21085 |        1 |  6.2 |  64 |       64 |  746 |    12 | 27_2_7_21085_1_7  | FALSE    | NA         |          NA | FALSE          |
| 156048329010661 | 65979838010661  |      27 |        7 | 65979838010661  |  2007 |      2 |    1 |    7 | 21085 |        0 |   NA |  NA |       NA |  746 |    13 | 27_2_7_21085_1_7  | FALSE    | FALSE      |           1 | FALSE          |
| 167064485020004 | 167064485020004 |      27 |        7 | NA              |  2012 |      2 |    1 |    7 | 21085 |        1 |  8.1 |  58 |       58 |  746 |    14 | 27_2_7_21085_1_7  | TRUE     | FALSE      |           0 | TRUE           |
| 499615920126144 | 167064485020004 |      27 |        7 | 167064485020004 |  2017 |      2 |    1 |    7 | 21085 |        1 |  9.0 |  62 |       62 |  746 |    15 | 27_2_7_21085_1_7  | TRUE     | TRUE       |           1 | FALSE          |
| 65979840010661  | 65979840010661  |      27 |        7 | NA              |  2002 |      2 |    1 |    8 | 21085 |        1 |  5.4 |  40 |       40 |  105 |    12 | 27_2_7_21085_1_8  | FALSE    | NA         |          NA | FALSE          |
| 156048330010661 | 65979840010661  |      27 |        7 | 65979840010661  |  2007 |      2 |    1 |    8 | 21085 |        0 |   NA |  NA |       NA |  105 |    13 | 27_2_7_21085_1_8  | FALSE    | FALSE      |           1 | FALSE          |
| 167064486020004 | 167064486020004 |      27 |        7 | NA              |  2012 |      2 |    1 |    8 | 21085 |        1 |  6.3 |  34 |       34 |  105 |    14 | 27_2_7_21085_1_8  | TRUE     | FALSE      |           0 | TRUE           |
| 499615921126144 | 167064486020004 |      27 |        7 | 167064486020004 |  2017 |      2 |    1 |    8 | 21085 |        1 |  6.5 |  30 |       30 |  105 |    15 | 27_2_7_21085_1_8  | TRUE     | TRUE       |           1 | FALSE          |
| 65979842010661  | 65979842010661  |      27 |        7 | NA              |  2002 |      2 |    1 |    9 | 21085 |        1 | 10.2 |  69 |       69 |  746 |    12 | 27_2_7_21085_1_9  | FALSE    | NA         |          NA | FALSE          |
| 156048331010661 | 65979842010661  |      27 |        7 | 65979842010661  |  2007 |      2 |    1 |    9 | 21085 |        0 |   NA |  NA |       NA |  746 |    13 | 27_2_7_21085_1_9  | FALSE    | FALSE      |           1 | FALSE          |
| 167064487020004 | 167064487020004 |      27 |        7 | NA              |  2012 |      2 |    1 |    9 | 21085 |        1 | 12.0 |  72 |       72 |  746 |    14 | 27_2_7_21085_1_9  | TRUE     | FALSE      |           0 | TRUE           |
| 499615922126144 | 167064487020004 |      27 |        7 | 167064487020004 |  2017 |      2 |    1 |    9 | 21085 |        1 | 12.8 |  70 |       70 |  746 |    15 | 27_2_7_21085_1_9  | TRUE     | TRUE       |           1 | FALSE          |
| 65979854010661  | 65979854010661  |      27 |        7 | NA              |  2002 |      2 |    2 |    1 | 21085 |        1 | 14.1 |  70 |       70 |  746 |    12 | 27_2_7_21085_2_1  | FALSE    | NA         |          NA | FALSE          |
| 156048337010661 | 65979854010661  |      27 |        7 | 65979854010661  |  2007 |      2 |    2 |    1 | 21085 |        0 |   NA |  NA |       NA |  746 |    13 | 27_2_7_21085_2_1  | FALSE    | FALSE      |           1 | FALSE          |
| 167064497020004 | 167064497020004 |      27 |        7 | NA              |  2012 |      2 |    2 |    1 | 21085 |        1 | 16.4 |  60 |       60 |  746 |    14 | 27_2_7_21085_2_1  | TRUE     | FALSE      |           0 | TRUE           |
| 499615933126144 | 167064497020004 |      27 |        7 | 167064497020004 |  2017 |      2 |    2 |    1 | 21085 |        1 | 17.3 |  81 |       81 |  746 |    15 | 27_2_7_21085_2_1  | TRUE     | TRUE       |           1 | FALSE          |
| 65979856010661  | 65979856010661  |      27 |        7 | NA              |  2002 |      2 |    2 |    2 | 21085 |        1 | 11.8 |  40 |       40 |  746 |    12 | 27_2_7_21085_2_2  | FALSE    | NA         |          NA | FALSE          |
| 156048338010661 | 65979856010661  |      27 |        7 | 65979856010661  |  2007 |      2 |    2 |    2 | 21085 |        0 |   NA |  NA |       NA |  746 |    13 | 27_2_7_21085_2_2  | FALSE    | FALSE      |           1 | FALSE          |
| 167064498020004 | 167064498020004 |      27 |        7 | NA              |  2012 |      2 |    2 |    2 | 21085 |        2 | 11.9 |  62 |       18 |  746 |    14 | 27_2_7_21085_2_2  | TRUE     | FALSE      |           0 | TRUE           |
| 499615934126144 | 167064498020004 |      27 |        7 | 167064498020004 |  2017 |      2 |    2 |    2 | 21085 |        2 | 11.7 |  65 |       14 |  746 |    15 | 27_2_7_21085_2_2  | TRUE     | TRUE       |           2 | FALSE          |
| 65979858010661  | 65979858010661  |      27 |        7 | NA              |  2002 |      2 |    2 |    3 | 21085 |        1 |  5.8 |  40 |       40 |  746 |    12 | 27_2_7_21085_2_3  | FALSE    | NA         |          NA | FALSE          |
| 156048339010661 | 65979858010661  |      27 |        7 | 65979858010661  |  2007 |      2 |    2 |    3 | 21085 |        0 |   NA |  NA |       NA |  746 |    13 | 27_2_7_21085_2_3  | FALSE    | FALSE      |           1 | FALSE          |
| 167064499020004 | 167064499020004 |      27 |        7 | NA              |  2012 |      2 |    2 |    3 | 21085 |        1 |  6.6 |  27 |       27 |  746 |    14 | 27_2_7_21085_2_3  | TRUE     | FALSE      |           0 | TRUE           |
| 499615935126144 | 167064499020004 |      27 |        7 | 167064499020004 |  2017 |      2 |    2 |    3 | 21085 |        1 |  6.9 |  40 |       40 |  746 |    15 | 27_2_7_21085_2_3  | TRUE     | TRUE       |           1 | FALSE          |
| 65979860010661  | 65979860010661  |      27 |        7 | NA              |  2002 |      2 |    2 |    4 | 21085 |        1 | 11.9 |  68 |       68 |  746 |    12 | 27_2_7_21085_2_4  | FALSE    | NA         |          NA | FALSE          |
| 156048340010661 | 65979860010661  |      27 |        7 | 65979860010661  |  2007 |      2 |    2 |    4 | 21085 |        0 |   NA |  NA |       NA |  746 |    13 | 27_2_7_21085_2_4  | FALSE    | FALSE      |           1 | FALSE          |
| 167064500020004 | 167064500020004 |      27 |        7 | NA              |  2012 |      2 |    2 |    4 | 21085 |        1 | 12.9 |  67 |       67 |  746 |    14 | 27_2_7_21085_2_4  | TRUE     | FALSE      |           0 | TRUE           |
| 499615936126144 | 167064500020004 |      27 |        7 | 167064500020004 |  2017 |      2 |    2 |    4 | 21085 |        1 | 13.4 |  65 |       65 |  746 |    15 | 27_2_7_21085_2_4  | TRUE     | TRUE       |           1 | FALSE          |
| 65979862010661  | 65979862010661  |      27 |        7 | NA              |  2002 |      2 |    2 |    5 | 21085 |        1 |  1.4 |  17 |       NA |  746 |    12 | 27_2_7_21085_2_5  | FALSE    | NA         |          NA | FALSE          |
| 156048341010661 | 65979862010661  |      27 |        7 | 65979862010661  |  2007 |      2 |    2 |    5 | 21085 |        0 |   NA |  NA |       NA |  746 |    13 | 27_2_7_21085_2_5  | FALSE    | FALSE      |           1 | FALSE          |
| 167064501020004 | 167064501020004 |      27 |        7 | NA              |  2012 |      2 |    2 |    5 | 21085 |        1 |  2.6 |  27 |       NA |  746 |    14 | 27_2_7_21085_2_5  | TRUE     | FALSE      |           0 | TRUE           |
| 499615937126144 | 167064501020004 |      27 |        7 | 167064501020004 |  2017 |      2 |    2 |    5 | 21085 |        1 |  3.0 |  24 |       24 |  746 |    15 | 27_2_7_21085_2_5  | TRUE     | TRUE       |           1 | FALSE          |
| 65979864010661  | 65979864010661  |      27 |        7 | NA              |  2002 |      2 |    2 |    6 | 21085 |        1 |  3.1 |  30 |       NA |  746 |    12 | 27_2_7_21085_2_6  | FALSE    | NA         |          NA | FALSE          |
| 156048342010661 | 65979864010661  |      27 |        7 | 65979864010661  |  2007 |      2 |    2 |    6 | 21085 |        0 |   NA |  NA |       NA |  746 |    13 | 27_2_7_21085_2_6  | FALSE    | FALSE      |           1 | FALSE          |
| 167064502020004 | 167064502020004 |      27 |        7 | NA              |  2012 |      2 |    2 |    6 | 21085 |        1 |  3.8 |  34 |       NA |  746 |    14 | 27_2_7_21085_2_6  | TRUE     | FALSE      |           0 | TRUE           |
| 499615938126144 | 167064502020004 |      27 |        7 | 167064502020004 |  2017 |      2 |    2 |    6 | 21085 |        1 |  4.5 |  34 |       34 |  746 |    15 | 27_2_7_21085_2_6  | TRUE     | TRUE       |           1 | FALSE          |
| 65979866010661  | 65979866010661  |      27 |        7 | NA              |  2002 |      2 |    2 |    7 | 21085 |        1 |  1.4 |  17 |       NA |  746 |    12 | 27_2_7_21085_2_7  | FALSE    | NA         |          NA | FALSE          |
| 156048343010661 | 65979866010661  |      27 |        7 | 65979866010661  |  2007 |      2 |    2 |    7 | 21085 |        0 |   NA |  NA |       NA |  746 |    13 | 27_2_7_21085_2_7  | FALSE    | FALSE      |           1 | FALSE          |
| 167064503020004 | 167064503020004 |      27 |        7 | NA              |  2012 |      2 |    2 |    7 | 21085 |        1 |  2.5 |  26 |       NA |  746 |    14 | 27_2_7_21085_2_7  | TRUE     | FALSE      |           0 | TRUE           |
| 499615939126144 | 167064503020004 |      27 |        7 | 167064503020004 |  2017 |      2 |    2 |    7 | 21085 |        1 |  2.5 |  28 |       28 |  746 |    15 | 27_2_7_21085_2_7  | TRUE     | TRUE       |           1 | FALSE          |
| 65979868010661  | 65979868010661  |      27 |        7 | NA              |  2002 |      2 |    2 |    8 | 21085 |        1 |  1.9 |  21 |       NA |  746 |    12 | 27_2_7_21085_2_8  | FALSE    | NA         |          NA | FALSE          |
| 156048344010661 | 65979868010661  |      27 |        7 | 65979868010661  |  2007 |      2 |    2 |    8 | 21085 |        0 |   NA |  NA |       NA |  746 |    13 | 27_2_7_21085_2_8  | FALSE    | FALSE      |           1 | FALSE          |
| 167064504020004 | 167064504020004 |      27 |        7 | NA              |  2012 |      2 |    2 |    8 | 21085 |        1 |  2.1 |  23 |       NA |  746 |    14 | 27_2_7_21085_2_8  | TRUE     | FALSE      |           0 | TRUE           |
| 499615940126144 | 167064504020004 |      27 |        7 | 167064504020004 |  2017 |      2 |    2 |    8 | 21085 |        1 |  3.0 |  35 |       35 |  746 |    15 | 27_2_7_21085_2_8  | TRUE     | TRUE       |           1 | FALSE          |

``` r
knitr::kable(mn_deeper_dives |>
  filter(is_break_point)
)
```

| CN              | TREE_FIRST_CN   | STATECD | COUNTYCD | PREV_TRE_CN | INVYR | UNITCD | SUBP | TREE |  PLOT | STATUSCD |  DIA |  HT | ACTUALHT | SPCD | CYCLE | TREE_UNIQUE_NUM   | CN_break | prev_break | prev_status | is_break_point |
|:----------------|:----------------|--------:|---------:|:------------|------:|-------:|-----:|-----:|------:|---------:|-----:|----:|---------:|-----:|------:|:------------------|:---------|:-----------|------------:|:---------------|
| 167064488020004 | 167064488020004 |      27 |        7 | NA          |  2012 |      2 |    1 |   10 | 21085 |        1 |  7.1 |  57 |       57 |  746 |    14 | 27_2_7_21085_1_10 | TRUE     | FALSE      |           0 | TRUE           |
| 167064489020004 | 167064489020004 |      27 |        7 | NA          |  2012 |      2 |    1 |   11 | 21085 |        1 |  7.6 |  61 |       61 |  746 |    14 | 27_2_7_21085_1_11 | TRUE     | FALSE      |           0 | TRUE           |
| 167064490020004 | 167064490020004 |      27 |        7 | NA          |  2012 |      2 |    1 |   12 | 21085 |        1 |  6.9 |  57 |       57 |  746 |    14 | 27_2_7_21085_1_12 | TRUE     | FALSE      |           0 | TRUE           |
| 167064491020004 | 167064491020004 |      27 |        7 | NA          |  2012 |      2 |    1 |   13 | 21085 |        1 | 11.5 |  65 |       65 |  746 |    14 | 27_2_7_21085_1_13 | TRUE     | FALSE      |           0 | TRUE           |
| 167064492020004 | 167064492020004 |      27 |        7 | NA          |  2012 |      2 |    1 |   14 | 21085 |        1 |  6.4 |  48 |       48 |  746 |    14 | 27_2_7_21085_1_14 | TRUE     | FALSE      |           0 | TRUE           |
| 167064483020004 | 167064483020004 |      27 |        7 | NA          |  2012 |      2 |    1 |    5 | 21085 |        2 |  5.7 |  41 |        5 |  746 |    14 | 27_2_7_21085_1_5  | TRUE     | FALSE      |           0 | TRUE           |
| 167064484020004 | 167064484020004 |      27 |        7 | NA          |  2012 |      2 |    1 |    6 | 21085 |        1 | 10.2 |  67 |       67 |  746 |    14 | 27_2_7_21085_1_6  | TRUE     | FALSE      |           0 | TRUE           |
| 167064485020004 | 167064485020004 |      27 |        7 | NA          |  2012 |      2 |    1 |    7 | 21085 |        1 |  8.1 |  58 |       58 |  746 |    14 | 27_2_7_21085_1_7  | TRUE     | FALSE      |           0 | TRUE           |
| 167064486020004 | 167064486020004 |      27 |        7 | NA          |  2012 |      2 |    1 |    8 | 21085 |        1 |  6.3 |  34 |       34 |  105 |    14 | 27_2_7_21085_1_8  | TRUE     | FALSE      |           0 | TRUE           |
| 167064487020004 | 167064487020004 |      27 |        7 | NA          |  2012 |      2 |    1 |    9 | 21085 |        1 | 12.0 |  72 |       72 |  746 |    14 | 27_2_7_21085_1_9  | TRUE     | FALSE      |           0 | TRUE           |
| 167064497020004 | 167064497020004 |      27 |        7 | NA          |  2012 |      2 |    2 |    1 | 21085 |        1 | 16.4 |  60 |       60 |  746 |    14 | 27_2_7_21085_2_1  | TRUE     | FALSE      |           0 | TRUE           |
| 167064498020004 | 167064498020004 |      27 |        7 | NA          |  2012 |      2 |    2 |    2 | 21085 |        2 | 11.9 |  62 |       18 |  746 |    14 | 27_2_7_21085_2_2  | TRUE     | FALSE      |           0 | TRUE           |
| 167064499020004 | 167064499020004 |      27 |        7 | NA          |  2012 |      2 |    2 |    3 | 21085 |        1 |  6.6 |  27 |       27 |  746 |    14 | 27_2_7_21085_2_3  | TRUE     | FALSE      |           0 | TRUE           |
| 167064500020004 | 167064500020004 |      27 |        7 | NA          |  2012 |      2 |    2 |    4 | 21085 |        1 | 12.9 |  67 |       67 |  746 |    14 | 27_2_7_21085_2_4  | TRUE     | FALSE      |           0 | TRUE           |
| 167064501020004 | 167064501020004 |      27 |        7 | NA          |  2012 |      2 |    2 |    5 | 21085 |        1 |  2.6 |  27 |       NA |  746 |    14 | 27_2_7_21085_2_5  | TRUE     | FALSE      |           0 | TRUE           |
| 167064502020004 | 167064502020004 |      27 |        7 | NA          |  2012 |      2 |    2 |    6 | 21085 |        1 |  3.8 |  34 |       NA |  746 |    14 | 27_2_7_21085_2_6  | TRUE     | FALSE      |           0 | TRUE           |
| 167064503020004 | 167064503020004 |      27 |        7 | NA          |  2012 |      2 |    2 |    7 | 21085 |        1 |  2.5 |  26 |       NA |  746 |    14 | 27_2_7_21085_2_7  | TRUE     | FALSE      |           0 | TRUE           |
| 167064504020004 | 167064504020004 |      27 |        7 | NA          |  2012 |      2 |    2 |    8 | 21085 |        1 |  2.1 |  23 |       NA |  746 |    14 | 27_2_7_21085_2_8  | TRUE     | FALSE      |           0 | TRUE           |

### AZ

The Arizona mismatches (approx. 1600 trees, of 71000 total) do not
follow the same pattern as MN. All but 5 of these instances occur in
CYCLE 3 between 2001-2005 when there are 2 visits to a tree within the
same cycle. For those trees, the second visit to the tree has
`PREV_TRE_CN = NA`, so there is no link to the first visit. To my
understanding, the sampling methodology only calls for one visit per
tree per cycle.

Of the remaining 5 instances, I have no explanation. But, I’ll note that
in 4 of those 5, the second record for a tree is of a different species
than the first, suggesting some error somewhere.

``` r
#| arizona

az_deeper_dives <- unmatched_deeper_dives |>
  filter(STATECD == 4)

az_repeat_visits <- tree_unique_number |>
  filter(STATECD == 4) |>
  group_by(CYCLE, TREE_UNIQUE_NUM) |>
  arrange(INVYR) |>
  mutate(NVISITS = n(),
         VISIT_NUMBER = row_number(),
         CN = as.character(CN)) |>
  filter(NVISITS > 1,
         VISIT_NUMBER == 1) |>
  collect()
```

    Warning: window functions not currently supported in Arrow; pulling data into R

``` r
all(az_repeat_visits$CN %in% az_deeper_dives$CN)
```

    [1] TRUE

``` r
no_repeats <- az_deeper_dives |> 
  anti_join(az_repeat_visits, by = "CN") |>
  group_by(TREE_UNIQUE_NUM) |>
  mutate(N_CNS = length(unique(TREE_FIRST_CN))) |>
  filter(N_CNS > 1)

knitr::kable(no_repeats)
```

| CN              | TREE_FIRST_CN   | STATECD | COUNTYCD | PREV_TRE_CN | INVYR | UNITCD | SUBP | TREE |  PLOT | STATUSCD |  DIA |  HT | ACTUALHT | SPCD | CYCLE | TREE_UNIQUE_NUM   | CN_break | prev_break | prev_status | is_break_point | N_CNS |
|:----------------|:----------------|--------:|---------:|:------------|------:|-------:|-----:|-----:|------:|---------:|-----:|----:|---------:|-----:|------:|:------------------|:---------|:-----------|------------:|:---------------|------:|
| 31611900010690  | 31611900010690  |       4 |       19 | NA          |  2002 |      1 |    1 |   12 | 85432 |        1 |  1.1 |   6 |        6 |  847 |     3 | 4_1_19_85432_1_12 | FALSE    | NA         |          NA | FALSE          |     2 |
| 550230872126144 | 550230872126144 |       4 |       19 | NA          |  2017 |      1 |    1 |   12 | 85432 |        1 |  9.6 |  16 |       16 |  843 |     4 | 4_1_19_85432_1_12 | TRUE     | FALSE      |           1 | TRUE           |     2 |
| 31611933010690  | 31611933010690  |       4 |       19 | NA          |  2002 |      1 |    3 |   24 | 85432 |        1 |  3.1 |  16 |       16 |  134 |     3 | 4_1_19_85432_3_24 | FALSE    | NA         |          NA | FALSE          |     2 |
| 550230904126144 | 550230904126144 |       4 |       19 | NA          |  2017 |      1 |    3 |   24 | 85432 |        1 |  5.6 |  11 |       11 |  843 |     4 | 4_1_19_85432_3_24 | TRUE     | FALSE      |           1 | TRUE           |     2 |
| 31611441010690  | 31611441010690  |       4 |       17 | NA          |  2004 |      2 |    2 |   11 | 82938 |        1 |  3.5 |  12 |       12 |  106 |     3 | 4_2_17_82938_2_11 | FALSE    | NA         |          NA | FALSE          |     2 |
| 742145365290487 | 742145365290487 |       4 |       17 | NA          |  2019 |      2 |    2 |   11 | 82938 |        1 |  5.4 |   7 |        7 |   69 |     4 | 4_2_17_82938_2_11 | TRUE     | FALSE      |           1 | TRUE           |     2 |
| 31610116010690  | 31610116010690  |       4 |        5 | NA          |  2001 |      2 |    4 |    3 | 82983 |        1 |  5.8 |  22 |       22 |  122 |     3 | 4_2_5_82983_4_3   | FALSE    | NA         |          NA | FALSE          |     2 |
| 469481960489998 | 469481960489998 |       4 |        5 | NA          |  2016 |      2 |    4 |    3 | 82983 |        1 |  5.6 |  21 |       21 |  122 |     4 | 4_2_5_82983_4_3   | TRUE     | FALSE      |           1 | TRUE           |     2 |
| 31610690010690  | 31610690010690  |       4 |        7 | NA          |  2003 |      2 |    3 |   10 | 83683 |        1 |  2.7 |   6 |        6 |  810 |     3 | 4_2_7_83683_3_10  | FALSE    | NA         |          NA | FALSE          |     2 |
| 687317132126144 | 687317132126144 |       4 |        7 | NA          |  2018 |      2 |    3 |   10 | 83683 |        2 | 17.6 |  18 |        7 |  803 |     4 | 4_2_7_83683_3_10  | TRUE     | FALSE      |           1 | TRUE           |     2 |
