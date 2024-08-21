# Extracting FIA timeseries for tree rings


``` r
library(duckdb)
```

    Loading required package: DBI

``` r
library(dplyr)
```


    Attaching package: 'dplyr'

    The following objects are masked from 'package:stats':

        filter, lag

    The following objects are masked from 'package:base':

        intersect, setdiff, setequal, union

``` r
library(ggplot2)

source(here::here("R", "query_tables_db_fxns.R"))

con <- connect_to_tables(here::here("data", "db", "foresttime-from-state-parquet.duckdb"))

theme_set(theme_bw())
```

# States and species

``` r
sp_kelly <-
  c(316, 318, 832, 833, 802, 621, 531, 400, 129, 97, 762, 261, 837, 541, 12)
states_kelly <-
  read.csv(here::here("useful_information", "fips.csv")) |>
  filter(STATE %in% c(
    "OH", "PA", "MD", "MA", "NJ", "VT", "NH", "RI", "ME", "CT", "WV", "NY", "IN", "IA", "IL", "MI", "MO", "WI", "MN"
  ))
states_kelly <- states_kelly$STATEFP
```

# Query database

``` r
tree_ring <-
  query_tree_surveys(con = con,
                 conditions = create_conditions(STATECD %in% states_kelly,
                                                 SPCD %in% sp_kelly,
                                                 ANY_SPCD_FLAG == FALSE # This filters out any trees that have multiple SPCDs recorded over time. 
                  ),
                  variables = c("DIA",
                                "STATUSCD",
                                "CONDID", 
                                "SLOPE",
                                "ASPECT",
                                "MORTCD",
                                "DSTRBCD1",
                                "DSTRBYR1",
                                "DSTRBCD2",
                                "DSTRBYR2",
                                "DSTRBCD3",
                                "DSTRBYR3",
                                "FORTYPCD"
                  ) # You can request any variables from the TREE, CONDITION, or PLOT table (except for the MODIFIED and CREATED_IN_INSTANCE codes). If you want the CNs for the rows from the PLOT or CONDITION tables those are named PLOT_CN and COND_CN, respectively. 
  )
```

    Joining with `by = join_by(TREE_COMPOSITE_ID, PLOT_COMPOSITE_ID, PLOT, SUBP, STATECD, COUNTYCD)`
    Joining with `by = join_by(TREE_COMPOSITE_ID, SPCD_CORR, TREE_CN, INVYR, STATUSCD, SPCD, CYCLE)`
    Joining with `by = join_by(PLOT_COMPOSITE_ID, PLOT, STATECD, COUNTYCD, PLT_CN, INVYR, UNITCD, CYCLE, SUBCYCLE)`
    Joining with `by = join_by(PLOT_COMPOSITE_ID, PLOT, STATECD, COUNTYCD, PLT_CN, INVYR, UNITCD, CONDID, CYCLE, SUBCYCLE)`

``` r
dbDisconnect(con, shutdown = TRUE)
```

## How many trees have been surveyed how many times in each state?

| STATE | STATECD | n_measures | n_trees |
|:------|--------:|-----------:|--------:|
| CT    |       9 |          1 |    1080 |
| CT    |       9 |          2 |    1650 |
| CT    |       9 |          3 |    3780 |
| CT    |       9 |          4 |    1571 |
| IL    |      17 |          1 |    1156 |
| IL    |      17 |          2 |    1962 |
| IL    |      17 |          3 |    1878 |
| IL    |      17 |          4 |    3389 |
| IN    |      18 |          1 |    9272 |
| IN    |      18 |          2 |    5200 |
| IN    |      18 |          3 |    3491 |
| IN    |      18 |          4 |    6664 |
| IA    |      19 |          1 |     767 |
| IA    |      19 |          2 |     406 |
| IA    |      19 |          3 |     435 |
| IA    |      19 |          4 |    1045 |
| IA    |      19 |          5 |      90 |
| ME    |      23 |          1 |   20142 |
| ME    |      23 |          2 |   35433 |
| ME    |      23 |          3 |   30880 |
| ME    |      23 |          4 |   41551 |
| ME    |      23 |          5 |   32835 |
| MD    |      24 |          1 |    2026 |
| MD    |      24 |          2 |    2191 |
| MD    |      24 |          3 |    3878 |
| MD    |      24 |          4 |     504 |
| MA    |      25 |          1 |    2653 |
| MA    |      25 |          2 |    3868 |
| MA    |      25 |          3 |    8244 |
| MA    |      25 |          4 |    3613 |
| MI    |      26 |          1 |   77496 |
| MI    |      26 |          2 |   78643 |
| MI    |      26 |          3 |   16054 |
| MI    |      26 |          4 |   45651 |
| MN    |      27 |          1 |   15358 |
| MN    |      27 |          2 |   14836 |
| MN    |      27 |          3 |   11684 |
| MN    |      27 |          4 |   16186 |
| MN    |      27 |          5 |    6733 |
| MO    |      29 |          1 |   18233 |
| MO    |      29 |          2 |    7366 |
| MO    |      29 |          3 |    6498 |
| MO    |      29 |          4 |   17434 |
| NH    |      33 |          1 |   10839 |
| NH    |      33 |          2 |   16535 |
| NH    |      33 |          3 |   16896 |
| NH    |      33 |          4 |    7625 |
| NJ    |      34 |          1 |    2892 |
| NJ    |      34 |          2 |    3086 |
| NJ    |      34 |          3 |    1930 |
| NJ    |      34 |          4 |    1732 |
| NY    |      36 |          1 |   19226 |
| NY    |      36 |          2 |   23661 |
| NY    |      36 |          3 |   47015 |
| NY    |      36 |          4 |   19104 |
| OH    |      39 |          1 |    3841 |
| OH    |      39 |          2 |    8296 |
| OH    |      39 |          3 |    9954 |
| OH    |      39 |          4 |    8783 |
| PA    |      42 |          1 |   10176 |
| PA    |      42 |          2 |   23611 |
| PA    |      42 |          3 |   15987 |
| PA    |      42 |          4 |   38709 |
| RI    |      44 |          1 |     636 |
| RI    |      44 |          2 |    1035 |
| RI    |      44 |          3 |    1053 |
| RI    |      44 |          4 |     969 |
| VT    |      50 |          1 |    7202 |
| VT    |      50 |          2 |    9296 |
| VT    |      50 |          3 |   12943 |
| VT    |      50 |          4 |    7690 |
| WV    |      54 |          1 |   16664 |
| WV    |      54 |          2 |   17273 |
| WV    |      54 |          3 |   12427 |
| WV    |      54 |          4 |   18283 |
| WV    |      54 |          5 |    2326 |
| WI    |      55 |          1 |   32899 |
| WI    |      55 |          2 |   21481 |
| WI    |      55 |          3 |   21359 |
| WI    |      55 |          4 |   50310 |

## How many trees have been surveyed of each species?

| SPCD |      n |
|-----:|-------:|
|   12 | 187392 |
|   97 |  42861 |
|  129 |  59889 |
|  261 |  51061 |
|  316 | 237842 |
|  318 | 163800 |
|  400 |    174 |
|  531 |  64082 |
|  541 |  42169 |
|  621 |  18001 |
|  762 |  58163 |
|  802 |  54163 |
|  832 |  17741 |
|  833 |  55248 |
|  837 |  34984 |

## Saving data to share

``` r
write.csv(tree_ring, here::here("use_cases", "tree_rings", "tree_ring.csv"))
```

The saved file is 450 MB.

## Clean up

``` r
dbDisconnect(con, shutdown = TRUE)
```

    Warning: Connection already closed.
