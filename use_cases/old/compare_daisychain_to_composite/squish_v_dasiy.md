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

state_number <- c(1,2,4,5,6,8)
arrow_dir <- "data/arrow"
```

``` r
tree <- open_dataset(
  here::here(arrow_dir, "TREE_RAW"),
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
  left_join(tree) |>
  select(STATECD, TREE_FIRST_CN, TREE_UNIQUE_ID) |> 
  distinct() |>
  collect() |> 
  group_by(STATECD, TREE_FIRST_CN) |>
  mutate(n_NUM = n()) |>
  group_by(STATECD, TREE_UNIQUE_ID) |>
  mutate(n_FIRST_CN = n()) |>
  ungroup() |>
  filter(n_NUM > 1 |
           n_FIRST_CN > 1)
# 
# unmatched_deeper_dives <- join_cns |>
#   left_join(tree) |>
#   filter(TREE_UNIQUE_ID %in% unmatched_cns$TREE_UNIQUE_ID) |>
#   arrange(TREE_UNIQUE_ID, CYCLE) |>
#   collect() |>
#   mutate(TREE_FIRST_CN = as.character(TREE_FIRST_CN),
#          CN = as.character(CN),
#          PREV_TRE_CN = as.character(PREV_TRE_CN)) |>
#   group_by(TREE_UNIQUE_ID) |>
#   mutate(CN_break = TREE_FIRST_CN != CN[1]) |>
#   mutate(prev_break = lag(CN_break),
#          prev_status = lag(STATUSCD)) |>
#   mutate(is_break_point = ifelse(CN_break, ifelse(prev_break, FALSE, TRUE), FALSE)) 
```

### AK

``` r
ak <- filter(unmatched_cns, STATECD == 1)
```

All 152 mismatches in Alaska take the form of 2 “TREE_UNIQUE_IDS” per 1
“TREE_FIRST_CN”.

``` r
ak_mismatches <- tree |>
  filter(STATECD == 1,
         TREE_UNIQUE_ID %in% ak$TREE_UNIQUE_ID) |>
  collect() |>
  left_join(ak) |>
  arrange(TREE_FIRST_CN, CYCLE) |>
  mutate(across(contains("CN"), as.character))
```

    Joining with `by = join_by(TREE_UNIQUE_ID, STATECD)`

``` r
ak_nplots <- ak_mismatches |>
  group_by(TREE_FIRST_CN) |>
  summarize(nplots = length(unique(PLOT)))
```

In all of these instances, a PREV_TRE_CN links to a tree previously
found on a different plot. For example, this tree is on plot 93 for 2001
and 2009, and then on plot 133 for 2016. This gives it a new UNIQUE_ID
in 2016.

<div>

> **Note**
>
> Are these accurate, and the plot spatial arrangement changed, or in
> error?

</div>

``` r
head(ak_mismatches |> select(TREE_FIRST_CN, TREE_UNIQUE_ID, INVYR, PLOT), 3)
```

| TREE_FIRST_CN   | TREE_UNIQUE_ID  | INVYR | PLOT |
|:----------------|:----------------|------:|-----:|
| 204687030010854 | 1_2_25_93_3_22  |  2001 |   93 |
| 204687030010854 | 1_2_25_93_3_22  |  2009 |   93 |
| 204687030010854 | 1_2_91_133_3_22 |  2016 |  133 |
