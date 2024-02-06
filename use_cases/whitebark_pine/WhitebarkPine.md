# Extracting FIA timeseries

# Whitebark pine for Montana, Idaho, and Wyoming

SPCD = 101

STATECD = 16, 30, 56

``` r
whitebark_pine <- get_timeseries(
  conditions = list(STATECD = list("%in%", c(16, 30, 56)),
                    SPCD = list("==", 101)),
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
                "RECONCILED")
)
```

    Joining with `by = join_by(PLT_CN, INVYR, UNITCD, PLOT, CYCLE, SUBCYCLE, PLOT_UNIQUE_ID, COUNTYCD, STATECD)`
    Joining with `by = join_by(PLT_CN, INVYR, UNITCD, PLOT, CONDID, CYCLE, SUBCYCLE, PLOT_UNIQUE_ID, COUNTYCD, STATECD)`

``` r
knitr::kable(head(whitebark_pine))
```

| TREE_UNIQUE_ID     | PLOT_UNIQUE_ID | SPCD |  PLOT | COUNTYCD | STATECD |       PLT_CN | INVYR | CYCLE | MEASYEAR |      COND_CN | CONDID | STATUSCD |  DIA |  HT | COND_STATUS_CD |      LAT |       LON |  BALIVE | SICOND | SISP | SIBASE | DSTRBCD1 | DSTRBYR1 | DSTRBCD2 | DSTRBYR2 | DSTRBCD3 | DSTRBYR3 | SDIMAX_RMRS | SDI_RMRS | SLOPE | ASPECT | CONDPROP_UNADJ |
|:-------------------|:---------------|-----:|------:|---------:|--------:|-------------:|------:|------:|---------:|-------------:|-------:|---------:|-----:|----:|---------------:|---------:|----------:|--------:|-------:|-----:|-------:|---------:|:---------|---------:|:---------|---------:|:---------|------------:|---------:|------:|-------:|---------------:|
| 16_1_17_81594_1_4  | 16_1_17_81594  |  101 | 81594 |       17 |      16 | 3.727554e+13 |  2010 |     2 |     2010 | 4.249793e+13 |      1 |        1 | 16.7 |  47 |              1 | 48.39234 | -116.1243 | 53.7843 |     16 |   93 |     50 |        0 | NA       |        0 | NA       |        0 | NA       |         735 | 117.7294 |    48 |    246 |              1 |
| 16_1_17_81594_1_7  | 16_1_17_81594  |  101 | 81594 |       17 |      16 | 3.727554e+13 |  2010 |     2 |     2010 | 4.249793e+13 |      1 |        2 | 13.8 |  36 |              1 | 48.39234 | -116.1243 | 53.7843 |     16 |   93 |     50 |        0 | NA       |        0 | NA       |        0 | NA       |         735 | 117.7294 |    48 |    246 |              1 |
| 16_1_17_81594_3_11 | 16_1_17_81594  |  101 | 81594 |       17 |      16 | 3.727554e+13 |  2010 |     2 |     2010 | 4.249793e+13 |      1 |        2 |  9.0 |  28 |              1 | 48.39234 | -116.1243 | 53.7843 |     16 |   93 |     50 |        0 | NA       |        0 | NA       |        0 | NA       |         735 | 117.7294 |    48 |    246 |              1 |
| 16_1_17_81594_3_15 | 16_1_17_81594  |  101 | 81594 |       17 |      16 | 3.727554e+13 |  2010 |     2 |     2010 | 4.249793e+13 |      1 |        2 | 10.5 |  32 |              1 | 48.39234 | -116.1243 | 53.7843 |     16 |   93 |     50 |        0 | NA       |        0 | NA       |        0 | NA       |         735 | 117.7294 |    48 |    246 |              1 |
| 16_1_17_81594_3_18 | 16_1_17_81594  |  101 | 81594 |       17 |      16 | 3.727554e+13 |  2010 |     2 |     2010 | 4.249793e+13 |      1 |        2 |  7.7 |  32 |              1 | 48.39234 | -116.1243 | 53.7843 |     16 |   93 |     50 |        0 | NA       |        0 | NA       |        0 | NA       |         735 | 117.7294 |    48 |    246 |              1 |
| 16_1_17_81594_3_19 | 16_1_17_81594  |  101 | 81594 |       17 |      16 | 3.727554e+13 |  2010 |     2 |     2010 | 4.249793e+13 |      1 |        2 |  6.9 |  22 |              1 | 48.39234 | -116.1243 | 53.7843 |     16 |   93 |     50 |        0 | NA       |        0 | NA       |        0 | NA       |         735 | 117.7294 |    48 |    246 |              1 |

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

The saved file is 5 MB.
