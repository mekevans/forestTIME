# Extracting FIA timeseries

# Whitebark pine for Montana, Idaho, and Wyoming

SPCD = 101

STATECD = 16, 30, 56

``` r
whitebark_pine <- get_timeseries(
  conditions = list(STATECD = list("%in%", c(16, 30)),
                    SPCD = list("==", 101)),
  variables = c("STATUSCD", "DIA", "HT")
)
```

    Joining with `by = join_by(PLT_CN, INVYR, UNITCD, PLOT, PLOT_UNIQUE_ID, COUNTYCD, STATECD)`
    Joining with `by = join_by(PLT_CN, INVYR, UNITCD, PLOT, CONDID, PLOT_UNIQUE_ID, COUNTYCD, STATECD)`

``` r
knitr::kable(head(whitebark_pine))
```

| TREE_UNIQUE_ID     | PLOT_UNIQUE_ID |           CN | INVYR | STATECD | COUNTYCD | UNITCD |  PLOT | SUBP | TREE | SPCD | STATUSCD |  DIA |  HT |
|:-------------------|:---------------|-------------:|------:|--------:|---------:|-------:|------:|-----:|-----:|-----:|---------:|-----:|----:|
| 16_1_17_81594_1_4  | 16_1_17_81594  | 4.249793e+13 |  2010 |      16 |       17 |      1 | 81594 |    1 |    4 |  101 |        1 | 16.7 |  47 |
| 16_1_17_81594_1_7  | 16_1_17_81594  | 4.249793e+13 |  2010 |      16 |       17 |      1 | 81594 |    1 |    7 |  101 |        2 | 13.8 |  36 |
| 16_1_17_81594_3_11 | 16_1_17_81594  | 4.249793e+13 |  2010 |      16 |       17 |      1 | 81594 |    3 |   11 |  101 |        2 |  9.0 |  28 |
| 16_1_17_81594_3_15 | 16_1_17_81594  | 4.249793e+13 |  2010 |      16 |       17 |      1 | 81594 |    3 |   15 |  101 |        2 | 10.5 |  32 |
| 16_1_17_81594_3_18 | 16_1_17_81594  | 4.249793e+13 |  2010 |      16 |       17 |      1 | 81594 |    3 |   18 |  101 |        2 |  7.7 |  32 |
| 16_1_17_81594_3_19 | 16_1_17_81594  | 4.249793e+13 |  2010 |      16 |       17 |      1 | 81594 |    3 |   19 |  101 |        2 |  6.9 |  22 |

## How many trees have been surveyed how many times in each state?

| STATECD | n_measures | n_trees |
|--------:|-----------:|--------:|
|      16 |          1 |    1190 |
|      16 |          2 |    2065 |
|      16 |          3 |       1 |
|      30 |          1 |    2607 |
|      30 |          2 |    5882 |
|      30 |          3 |     199 |

**Notably, zero trees in Wyoming (STATECD = 56) have been surveyed more
than one time.**

## Plotting DIA, HT of trees with repeated measurements

![](WhitebarkPine_files/figure-commonmark/unnamed-chunk-4-1.png)

![](WhitebarkPine_files/figure-commonmark/unnamed-chunk-4-2.png)

## Saving data to share

``` r
write.csv(whitebark_pine, here::here("use_cases", "whitebark_pine", "whitebark_pine.csv"))
```

The saved file is 1 MB.
