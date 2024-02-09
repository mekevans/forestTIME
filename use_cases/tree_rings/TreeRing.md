# Extracting FIA timeseries for tree rings

# To use

To use this:

1.  Clone this repository and open the `forestTIME.Rproj` R project.
2.  Make sure you have the `duckdb` R package installed
    (`install.packages("duckdb"))`.
3.  Download the file `treering.duckdb` and save it to
    `data/db/treering.duckdb`. [Link here (this will download 800
    MB)](https://arizona.box.com/s/nlykl9rbchlk2bj9npjd8dej5iw06i8a)
4.  Then you should be able to render this document or use the code
    under “Connect to database”, below.

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

theme_set(theme_bw())
```

# States and species

``` r
sp_kelly <-
  c(316, 318, 832, 833, 802, 621, 531, 400, 129, 97, 762, 261, 837, 541, 12)
states_kelly <-
  read.csv(here::here("data", "rawdat", "fips", "fips.csv")) |>
  filter(STATE %in% c(
    "WV",
    "MD",
    "OH",
    "PA",
    "NY",
    "CT",
    "RI",
    "MA",
    "DE",
    "VT",
    "NH",
    "ME"
  ))
states_kelly <- states_kelly$STATEFP
```

# Connect to database

``` r
con <- connect_to_tables(here::here("data", "db", "forestTIME-treering.duckdb"))

tree_ring <-
  query_tables_db(con = con,
                 tree_id_method = "first_cn", # Set this to "first_cn" to identify trees by the chain of control numbers. Set it to "composite" to use the string of STATE_PLOT_etc. 
                  conditions = create_conditions(STATECD %in% states_kelly,
                                                 SPCD %in% sp_kelly,
                                                 SPCDS == 1 # This filters out any trees that have multiple SPCDs recorded over time. 
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

    Joining with `by = join_by(CN, STATECD, COUNTYCD)`
    Joining with `by = join_by(TREE_FIRST_CN, SPCD, PLOT, STATECD, COUNTYCD)`
    Joining with `by = join_by(PLOT, STATECD, COUNTYCD, PLT_CN, INVYR, UNITCD, CYCLE, SUBCYCLE, PLOT_UNIQUE_ID)`
    Joining with `by = join_by(PLOT, STATECD, COUNTYCD, PLT_CN, INVYR, UNITCD, CONDID, CYCLE, SUBCYCLE, PLOT_UNIQUE_ID)`

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
| DE    |      10 |          1 |     427 |
| DE    |      10 |          2 |     929 |
| DE    |      10 |          3 |    1033 |
| DE    |      10 |          4 |     167 |
| ME    |      23 |          1 |   20424 |
| ME    |      23 |          2 |   35576 |
| ME    |      23 |          3 |   30060 |
| ME    |      23 |          4 |   50098 |
| ME    |      23 |          5 |   21564 |
| MD    |      24 |          1 |    2026 |
| MD    |      24 |          2 |    2191 |
| MD    |      24 |          3 |    3878 |
| MD    |      24 |          4 |     504 |
| MA    |      25 |          1 |    2514 |
| MA    |      25 |          2 |    3804 |
| MA    |      25 |          3 |    9595 |
| MA    |      25 |          4 |    2165 |
| NH    |      33 |          1 |   10964 |
| NH    |      33 |          2 |   16828 |
| NH    |      33 |          3 |   16146 |
| NH    |      33 |          4 |    7625 |
| NY    |      36 |          1 |   19249 |
| NY    |      36 |          2 |   23506 |
| NY    |      36 |          3 |   53878 |
| NY    |      36 |          4 |   11061 |
| OH    |      39 |          1 |    4039 |
| OH    |      39 |          2 |    7812 |
| OH    |      39 |          3 |   11649 |
| OH    |      39 |          4 |    6828 |
| PA    |      42 |          1 |   10176 |
| PA    |      42 |          2 |   23611 |
| PA    |      42 |          3 |   15987 |
| PA    |      42 |          4 |   38709 |
| RI    |      44 |          1 |     658 |
| RI    |      44 |          2 |     984 |
| RI    |      44 |          3 |    1222 |
| RI    |      44 |          4 |     752 |
| VT    |      50 |          1 |    8052 |
| VT    |      50 |          2 |    8250 |
| VT    |      50 |          3 |   15083 |
| VT    |      50 |          4 |    5256 |
| WV    |      54 |          1 |   51288 |
| WV    |      54 |          2 |   19145 |
| WV    |      54 |          3 |   25345 |
| WV    |      54 |          4 |    3121 |

## How many trees have been surveyed of each species?

| SPCD |      n |
|-----:|-------:|
|   12 |  88330 |
|   97 |  42455 |
|  129 |  33285 |
|  261 |  40304 |
|  316 | 133133 |
|  318 |  66814 |
|  400 |    216 |
|  531 |  56705 |
|  541 |  27437 |
|  621 |  17778 |
|  762 |  31222 |
|  802 |  19411 |
|  832 |  20855 |
|  833 |  25598 |
|  837 |   8717 |

## Saving data to share

``` r
write.csv(tree_ring, here::here("use_cases", "tree_rings", "tree_ring.csv"))
```

The saved file is 249 MB.
