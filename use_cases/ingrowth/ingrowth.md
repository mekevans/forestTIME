# Ingrowth

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

con <- connect_to_tables(here::here("data", "db", "forestTIME-cli.duckdb"))

ct_trees <- query_tables_db(con = con,
  conditions = create_conditions(STATECD  == 9),
  variables = c("STATUSCD", "DIA", "HT", "TPA_UNADJ")
)
```

    Joining with `by = join_by(TREE_UNIQUE_ID, PLOT_UNIQUE_ID, SPCD, PLOT, STATECD,
    COUNTYCD)`

    Joining with `by = join_by(PLOT_UNIQUE_ID, PLOT, STATECD, COUNTYCD, PLT_CN, INVYR, UNITCD, CYCLE, SUBCYCLE)`
    Joining with `by = join_by(PLOT_UNIQUE_ID, PLOT, STATECD, COUNTYCD, PLT_CN, INVYR, UNITCD, CONDID, CYCLE, SUBCYCLE)`

``` r
dbDisconnect(con, shutdown = TRUE)
```

Pull out timeseries of trees that have ever been recorded as saplings.

``` r
ct_saplings <- ct_trees |>
  filter(DIA < 5) |>
  select(TREE_UNIQUE_ID) |>
  distinct() |>
  left_join(ct_trees)
```

    Joining with `by = join_by(TREE_UNIQUE_ID)`

Track saplings’ fates over time (change last measurement to this one).

``` r
ct_sapling_fates <- ct_saplings |>
  arrange(TREE_UNIQUE_ID, MEASYEAR) |>
  group_by(TREE_UNIQUE_ID) |>
  mutate(
    last_meas_year = lag(MEASYEAR, default = NA),
    last_status = lag(STATUSCD, default = NA),
    last_DIA = lag(DIA, default = NA),
    next_meas_year = lead(MEASYEAR, 1, default = NA)
  ) |>
  group_by_all() |>
  mutate(
    is_sapling_measured = STATUSCD == 1 && DIA < 5,
    new_sapling = is.na(last_meas_year) && is.na(last_status)  && is.na(last_DIA) && STATUSCD == 1,
    sapling_sapling = last_status ==1 && STATUSCD == 1 && DIA < 5 && last_DIA < 5,
    sapling_tree = last_status == 1 && STATUSCD == 1 && DIA >= 5 && last_DIA < 5,
    sapling_dead = last_status == 1 && STATUSCD == 2 && last_DIA < 5,
    sapling_removed = last_status == 1 && STATUSCD == 3 && last_DIA < 5,
    sapling_vanishes_next_year = is.na(next_meas_year) && DIA <5,
    sapling_not_sampled = last_status == 1 && STATUSCD == 0 && last_DIA < 5,
    sapling_not_measured = STATUSCD == 1 && last_status == 1 && last_DIA <5 && is.na(DIA)
  )
```

Calculate absolute numbers of trees making each transition, and
calculate these as proportions of the saplings that existed in the most
recent survey.

``` r
ct_sapling_transitions <- ct_sapling_fates |>
  group_by(PLOT_UNIQUE_ID, MEASYEAR) |>
  summarize(
    n_saplings = sum(is_sapling_measured, na.rm = T),
    n_new_saplings = sum(new_sapling, na.rm = T),
    n_sapling_saplings = sum(sapling_sapling, na.rm = T),
    n_saplings_to_trees = sum(sapling_tree, na.rm = T),
    n_saplings_died = sum(sapling_dead, na.rm = T),
    n_saplings_removed = sum(sapling_removed, na.rm = T),
    n_saplings_not_sampled = sum(sapling_not_sampled, na.rm = T),
    n_saplings_vanish_next = sum(sapling_vanishes_next_year, na.rm = T),
    n_saplings_not_measured = sum(sapling_not_measured, na.rm =T)
  ) |>
  ungroup() |>
  arrange(PLOT_UNIQUE_ID, MEASYEAR) |> 
  group_by(PLOT_UNIQUE_ID) |> 
  mutate(n_saplings_previous = lag(n_saplings, default = NA),
         n_saplings_vanished_last = lag(n_saplings_vanish_next, default = NA),
         prev_MEASYEAR = lag(MEASYEAR),
         first_MEASYEAR = min(MEASYEAR),
         last_MEASYEAR = max(MEASYEAR))|>
  group_by_all() |>
  mutate(is_first_MEASYEAR = MEASYEAR == first_MEASYEAR,
         is_last_MEASYEAR = MEASYEAR == last_MEASYEAR) |>
  ungroup() 
```

    `summarise()` has grouped output by 'PLOT_UNIQUE_ID'. You can override using
    the `.groups` argument.

``` r
ct_transition_probabilities <- ct_sapling_transitions |>
  filter(!is_first_MEASYEAR) |>
  mutate(n_saplings_died_or_gone = n_saplings_died+ n_saplings_vanished_last) |> 
  mutate(across(all_of(c('n_sapling_saplings',
                'n_saplings_to_trees',
                'n_saplings_died_or_gone',
                'n_saplings_removed')),
                .fns = list(prop = (\(x) x / n_saplings_previous))),
         saplings_second_total = n_saplings_previous + n_new_saplings - n_saplings_to_trees - n_saplings_died - n_saplings_removed - n_saplings_vanished_last - n_saplings_not_sampled - n_saplings_not_measured) |>
  mutate(prop_sums = n_sapling_saplings_prop + n_saplings_to_trees_prop + n_saplings_died_or_gone_prop + n_saplings_removed_prop)
```

Check out any mismatches:

``` r
ct_mismatches <- ct_transition_probabilities |>
  filter(n_saplings != saplings_second_total)
```

Look at these counts and transition “probabilities”:

``` r
knitr::kable(head(ct_transition_probabilities))
```

| PLOT_UNIQUE_ID | MEASYEAR | n_saplings | n_new_saplings | n_sapling_saplings | n_saplings_to_trees | n_saplings_died | n_saplings_removed | n_saplings_not_sampled | n_saplings_vanish_next | n_saplings_not_measured | n_saplings_previous | n_saplings_vanished_last | prev_MEASYEAR | first_MEASYEAR | last_MEASYEAR | is_first_MEASYEAR | is_last_MEASYEAR | n_saplings_died_or_gone | n_sapling_saplings_prop | n_saplings_to_trees_prop | n_saplings_died_or_gone_prop | n_saplings_removed_prop | saplings_second_total | prop_sums |
|:---------------|---------:|-----------:|---------------:|-------------------:|--------------------:|----------------:|-------------------:|-----------------------:|-----------------------:|------------------------:|--------------------:|-------------------------:|--------------:|---------------:|--------------:|:------------------|:-----------------|------------------------:|------------------------:|-------------------------:|-----------------------------:|------------------------:|----------------------:|----------:|
| 9_1_11_105     |     2016 |          3 |              0 |                  3 |                   0 |               0 |                  0 |                      0 |                      3 |                       0 |                   3 |                        0 |          2010 |           2010 |          2016 | FALSE             | TRUE             |                       0 |                    1.00 |                    0.000 |                        0.000 |                       0 |                     3 |         1 |
| 9_1_11_107     |     2012 |          1 |              0 |                  1 |                   0 |               1 |                  0 |                      0 |                      0 |                       0 |                   4 |                        2 |          2008 |           2008 |          2018 | FALSE             | FALSE            |                       3 |                    0.25 |                    0.000 |                        0.750 |                       0 |                     1 |         1 |
| 9_1_11_107     |     2018 |          2 |              1 |                  1 |                   0 |               0 |                  0 |                      0 |                      2 |                       0 |                   1 |                        0 |          2012 |           2008 |          2018 | FALSE             | TRUE             |                       0 |                    1.00 |                    0.000 |                        0.000 |                       0 |                     2 |         1 |
| 9_1_11_135     |     2008 |          4 |              0 |                  4 |                   1 |               3 |                  0 |                      0 |                      0 |                       0 |                   8 |                        0 |          2003 |           2003 |          2020 | FALSE             | FALSE            |                       3 |                    0.50 |                    0.125 |                        0.375 |                       0 |                     4 |         1 |
| 9_1_11_135     |     2014 |          3 |              0 |                  3 |                   0 |               1 |                  0 |                      0 |                      0 |                       0 |                   4 |                        0 |          2008 |           2003 |          2020 | FALSE             | FALSE            |                       1 |                    0.75 |                    0.000 |                        0.250 |                       0 |                     3 |         1 |
| 9_1_11_135     |     2020 |          3 |              0 |                  3 |                   0 |               0 |                  0 |                      0 |                      3 |                       0 |                   3 |                        0 |          2014 |           2003 |          2020 | FALSE             | TRUE             |                       0 |                    1.00 |                    0.000 |                        0.000 |                       0 |                     3 |         1 |

``` r
hist(ct_transition_probabilities$n_saplings_to_trees_prop)
```

![](ingrowth_files/figure-commonmark/unnamed-chunk-6-1.png)

``` r
hist(ct_transition_probabilities$n_saplings_died_or_gone_prop)
```

![](ingrowth_files/figure-commonmark/unnamed-chunk-6-2.png)

``` r
hist(ct_transition_probabilities$n_saplings_removed_prop)
```

![](ingrowth_files/figure-commonmark/unnamed-chunk-6-3.png)

``` r
hist(ct_transition_probabilities$prop_sums)
```

![](ingrowth_files/figure-commonmark/unnamed-chunk-6-4.png)

Look at the number of saplings on each plot over time:

``` r
ggplot(ct_sapling_transitions, aes(MEASYEAR, n_saplings, group = PLOT_UNIQUE_ID)) + 
  geom_line(alpha = .1) +
  geom_smooth(aes(MEASYEAR, n_saplings), inherit.aes = F) +
  theme_bw()
```

    `geom_smooth()` using method = 'loess' and formula = 'y ~ x'

![](ingrowth_files/figure-commonmark/unnamed-chunk-7-1.png)

Export these tables for sharing:

``` r
write.csv(ct_sapling_fates, here::here("use_cases", "ingrowth", "ct_sapling_fates.csv"), row.names = F)

write.csv(ct_transition_probabilities, here::here("use_cases", "ingrowth", "ct_transition_probabilities.csv"), row.names = F)
```
