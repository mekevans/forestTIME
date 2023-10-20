# daisy_chain_demo

``` r
library(tidyFIA)
library(ggplot2)
library(dplyr)
```


    Attaching package: 'dplyr'

    The following objects are masked from 'package:stats':

        filter, lag

    The following objects are masked from 'package:base':

        intersect, setdiff, setequal, union

``` r
library(purrr)

source(here::here("daisy_chain.R"))
```

``` r
dat2 <- download_by_state("CT", file_dir = here::here("fia_dat_downloads", "CT"))
```

``` r
state_files <- list.files(here::here("fia_dat_downloads", "CT"), pattern = ".csv", full.names = T)
state_files_names <- list.files(here::here("fia_dat_downloads", "CT"), pattern = ".csv", full.names = F) |>
  stringr::str_remove( "CT_") |>
  stringr::str_remove(".csv")


state_dat <- map(state_files, readr::read_csv)

names(state_dat) <- state_files_names
```

``` r
annual_trees <- state_dat$TREE |>
  filter(INVYR >= 2000)
```

``` r
system.time(annual_trees_cn <- add_persistent_cns(annual_trees))
```

       user  system elapsed 
      36.98    1.00  162.83 

``` r
ggplot(annual_trees_cn |> filter(PLOT %in% unique(PLOT)[1:10]), aes(INVYR, as.factor(TREE_FIRST_CN))) +
  geom_point() +
  theme_minimal() +
  facet_wrap(vars(PLOT), scales = "free_y") +
  theme(axis.text.y = element_blank())
```

![](daisy_chain_demo_files/figure-commonmark/unnamed-chunk-6-1.png)

## Commentary

- This appears to work as long as the current and previous tree CNs line
  up.
- The `add_persistent_cns` function increases in time nonlinearly with
  the size of the TREE table. I can get it to run for all of CT, but not
  for VT, AZ, or CO (many more trees).
  - This could be sped up by slicing by plot (as long as a tree stays in
    one plot for its whole life, which appears to be the case with the
    `PLOT` column for `INVYR >= 2000`).
  - It can also be sped up by only passing necessary columns (`INVYR`,
    `CN`, and `PREV_TRE_CN`).
