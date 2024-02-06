# Extract trees from national forests

Here I am attempting to pull records of trees on national forests in
Arizona.

``` r
system.time(az_nfs <- get_timeseries(
  conditions = list(STATECD = list("==", c(4)),
                   OWNCD = list("==", 11)),
  variables = c("STATUSCD", "DIA", "HT", "OWNCD", "LAT", "LON", "OWNCD", "ADFORCD")
))
```

    Joining with `by = join_by(PLT_CN, INVYR, UNITCD, PLOT, CYCLE, SUBCYCLE, PLOT_UNIQUE_ID, COUNTYCD, STATECD)`
    Joining with `by = join_by(PLT_CN, INVYR, UNITCD, PLOT, CONDID, CYCLE, SUBCYCLE, PLOT_UNIQUE_ID, COUNTYCD, STATECD)`

       user  system elapsed 
       2.83    0.70   11.69 

``` r
knitr::kable(head(az_nfs))
```

| TREE_UNIQUE_ID   | PLOT_UNIQUE_ID | SPCD |  PLOT | COUNTYCD | STATECD |       PLT_CN | INVYR | CYCLE | MEASYEAR |      COND_CN | CONDID | STATUSCD |  DIA |  HT | OWNCD |      LAT |       LON | ADFORCD |
|:-----------------|:---------------|-----:|------:|---------:|--------:|-------------:|------:|------:|---------:|-------------:|-------:|---------:|-----:|----:|------:|---------:|----------:|--------:|
| 4_1_11_80122_1_1 | 4_1_11_80122   |   63 | 80122 |       11 |       4 | 3.727196e+13 |  2010 |     3 |     2010 | 4.241832e+13 |      1 |        1 |  9.5 |  19 |    11 | 33.11304 | -109.1213 |     301 |
| 4_1_11_80122_1_2 | 4_1_11_80122   |  810 | 80122 |       11 |       4 | 3.727196e+13 |  2010 |     3 |     2010 | 4.241832e+13 |      1 |        1 |  9.3 |  19 |    11 | 33.11304 | -109.1213 |     301 |
| 4_1_11_80122_1_3 | 4_1_11_80122   |   63 | 80122 |       11 |       4 | 3.727196e+13 |  2010 |     3 |     2010 | 4.241832e+13 |      1 |        1 |  8.8 |  12 |    11 | 33.11304 | -109.1213 |     301 |
| 4_1_11_80122_1_4 | 4_1_11_80122   |  810 | 80122 |       11 |       4 | 3.727196e+13 |  2010 |     3 |     2010 | 4.241832e+13 |      1 |        2 |  9.4 |  12 |    11 | 33.11304 | -109.1213 |     301 |
| 4_1_11_80122_1_5 | 4_1_11_80122   |  810 | 80122 |       11 |       4 | 3.727196e+13 |  2010 |     3 |     2010 | 4.241832e+13 |      1 |        1 |  7.1 |  14 |    11 | 33.11304 | -109.1213 |     301 |
| 4_1_11_80122_1_6 | 4_1_11_80122   |  803 | 80122 |       11 |       4 | 3.727196e+13 |  2010 |     3 |     2010 | 4.241832e+13 |      1 |        1 | 11.8 |  18 |    11 | 33.11304 | -109.1213 |     301 |

Here is a map of where those trees are - although they may be swapped
and fuzzed:

``` r
library(tigris)

az_nfs_trees <- az_nfs |>
  group_by(TREE_UNIQUE_ID, LAT, LON, OWNCD) |>
  summarize(NYEARS = as.factor(length(unique(INVYR))))

az_state <- tigris::states() |>
  filter(STATEFP == "04")
```

``` r
ggplot(az_state) +
  geom_sf() +
  geom_jitter(data = az_nfs_trees, aes(LON, LAT, color = NYEARS)) +
  ggtitle("National forest trees in AZ") +
  scale_color_brewer(palette = "PuBuGn") +
  theme_bw()
```

![](national_forests_az_files/figure-commonmark/unnamed-chunk-4-1.png)

Here is how many trees have been sampled for how many years:

``` r
knitr::kable(az_nfs_trees |> group_by(NYEARS) |> tally() |> rename("Number of trees" = n))
```

| NYEARS | Number of trees |
|:-------|----------------:|
| 1      |            6461 |
| 2      |           26453 |
| 3      |             714 |

Here is how big the data file of all these trees’ measurements is:

``` r
write.csv(az_nfs, here::here("use_cases", "nfs", "arizona_natl_forest_trees.csv"), row.names = F)

file.size(here::here("use_cases", "nfs", "arizona_natl_forest_trees.csv"))/1e6
```

    [1] 7.988192
