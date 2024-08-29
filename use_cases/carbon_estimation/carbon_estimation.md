# Carbon estimation


``` r
library(ggplot2)

source(here::here("R", "query_tables_db_fxns.R"))
```

    Loading required package: DBI


    Attaching package: 'dplyr'

    The following objects are masked from 'package:stats':

        filter, lag

    The following objects are masked from 'package:base':

        intersect, setdiff, setequal, union

# Getting some data

This code pulls 6 trees out of Idaho to start working with.

``` r
con <- connect_to_tables(here::here("data", "db", "foresttime-from-state-parquet.duckdb"))

some_trees <- query_tree_surveys(con,
                                 conditions = create_conditions(STATECD == 16,
                                                                !is.na(DIA),
                                                                !is.na(HT),
                                                                STATUSCD == 1,
                                                                !is.na(SPCD)),
                                 variables = c("STANDING_DEAD_CD", "DECAYCD", "DIA", "HT")) |>
  head()

dbDisconnect(con, shutdown = TRUE)

write.csv(some_trees, here::here("use_cases", "carbon_estimation", "toy_tree_data.csv"), row.names = FALSE)
```

``` r
some_trees <- read.csv(here::here("use_cases", "carbon_estimation", "toy_tree_data.csv"))
```

# Step 1 Gross total stem wood volume

## Identify the model for gross total stem wood volume

Identify the right model and coefficients to use based on species code
and division, using Table S1A from the supplement ([download
here](https://www.fs.usda.gov/research/publications/gtr/gtr_wo104/WO-GTR-104-Supp1.zip)).

``` r
table_s1a <- read.csv(here::here("use_cases", 
                                 "carbon_estimation",
                                 "Supplemental_tables",
                                 "Table S1a_volib_coefs_spcd.csv"))
```

First we need to get division. As far as I can tell this is only
available from a map - is there a data table for this?

Also note that not all species have different models across divisions.
Ideally we would create a table that has SPCD, STATE (or PLOT), and
DIVISION. DIVISION should be “” if it doesn’t matter. This will be a
little work to create.

And, not all species are represented in Table S1a. From this sample, we
lose species 231. From the paper:

“For species not included in the spcd tables, the jenkins suffix tables
are used with model 5 and associated coefficients for the Jenkins group
that represents the species of interest. Species assignments to Jenkins
groups are in FIADB REF_SPECIES table as variable name JENKINS_SPGRPCD.
Note that Jenkins group coefficients incorporate the predicted random
effect into the reported coefficients, i.e., in some cases, the value is
a sum of the fixed and random effects.”

Here I get DIVISION-SPCD-model information for the 3 species that happen
to be in this toy dataset.

``` r
table_s1a_models <- table_s1a |>
  filter(SPCD %in% some_trees$SPCD,
         DIVISION %in% c("", "M330")) |>
  # This chunk preferentially pulls the model specific to this division
  # if division is provided at all for each species.
  mutate(DIVISION_nchar = nchar(DIVISION)) |>
  group_by(SPCD) |>
  mutate(longest_division = max(DIVISION_nchar)) |>
  ungroup() |>
  filter(DIVISION_nchar == longest_division) |>
  select(-DIVISION_nchar, -longest_division)
```

And then re-attach it to the tree data dataset:

``` r
some_trees_models <- left_join(some_trees, table_s1a_models)
```

    Joining with `by = join_by(SPCD)`

### Notes

Ideally for this step we would have a table of SPCD \| PLOT \| MODEL \|
coefficients.

To create this we would need:

- a data table of which plots (or other locations) are in which
  divisions - it’s not feasible to get this by manually examining the
  map
- the Jenkins codes table
- some code to join these together appropriately

This would be a great thing to see if Grant and Brian already have.

## Apply the model for gross total stem volume

This table tells us which of the 6 models described in the paper to use
for this species in this location. It makes sense to me to code each
model as a function. Here are functions for the models:

``` r
model1 <- function(DIA, HT, a, b, c) {
  
  a * (DIA ^ b) * (HT^c)
  
}

model2 <- function(DIA, HT, SPCD, a, b, b1, c) {
  
  if(SPCD <300) {
    k <- 9
  } else {
    k <- 11
  }
  
  if(DIA < k) {
    
    a * (DIA^b) * (HT^c)
    
  } else {
    
    a * (k^(b - b1)) * (DIA^b1) * (HT^c)
    
  }
  
}

model3 <- function(DIA, HT, a, a1, b, c, c1) {
  
  a * (DIA ^ (a1 * ((1 - exp(-b*DIA)) ^ c1))) * (HT^c)
  
}

model4 <- function(DIA, HT, a, b, b1, c) {
  
  a * (DIA ^ b) * (HT^c) * exp(-b1 * DIA)
  
}

model5 <- function(DIA, HT, WDSG, a, b, c){
  
  a * (DIA^ b) * (HT^c) * WDSG
  
}
```

Note also that model5 requires species-level wood specific gravity
(WDSG).

``` r
some_trees_gtswv <- some_trees_models |>
  group_by_all() |>
  mutate(gtswv = ifelse(model == 1,
                        model1(DIA = DIA,
                               HT = HT,
                               a = a, 
                               b = b,
                               c = c),
                        ifelse(model == 2,
                           model2(DIA = DIA,
                                  HT = HT,
                                  SPCD = SPCD,
                                  a = a,
                                  b = b,
                                  b1 = b1,
                                  c = c),
                           NA)))

knitr::kable(some_trees_gtswv)
```

| TREE_COMPOSITE_ID | PLOT_COMPOSITE_ID | SPCD | PLOT | SUBP | COUNTYCD | STATECD | PLT_CN | INVYR | CYCLE | MEASYEAR | TREE_CN | COND_CN | CONDID | STANDING_DEAD_CD | DECAYCD | DIA | HT | DIVISION | STDORGCD | model | a | a1 | b | b1 | c | c1 | gtswv |
|:---|:---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|:---|:---|---:|---:|:---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 16_1_17_80110_1_8 | 16_1_17_80110 | 242 | 80110 | 1 | 17 | 16 | 4.038938e+13 | 2013 | 2 | 2013 | 2.735257e+14 | 2.735257e+14 | 1 | NA | NA | 6.3 | 42 | M330 | NA | 2 | 0.0025057 | NA | 1.832658 | 1.641979 | 1.078425 | NA | 4.115228 |
| 16_1_17_80128_1_11 | 16_1_17_80128 | 73 | 80128 | 1 | 17 | 16 | 4.718063e+12 | 2004 | 2 | 2004 | 4.718083e+12 | 4.718066e+12 | 1 | NA | NA | 17.6 | 126 |  | NA | 1 | 0.0038058 | NA | 1.745228 | NA | 1.004542 | NA | 73.124648 |
| 16_1_17_80174_1_3 | 16_1_17_80174 | 202 | 80174 | 1 | 17 | 16 | 1.227033e+13 | 2007 | 2 | 2007 | 1.227034e+13 | 1.227033e+13 | 1 | NA | NA | 9.2 | 74 | M330 | NA | 2 | 0.0024107 | NA | 1.867664 | 1.809698 | 1.041719 | NA | 13.453376 |
| 16_1_17_80174_3_10 | 16_1_17_80174 | 202 | 80174 | 3 | 17 | 16 | 1.227033e+13 | 2007 | 2 | 2007 | 1.227037e+13 | 1.227033e+13 | 1 | NA | NA | 12.2 | 92 | M330 | NA | 2 | 0.0024107 | NA | 1.867664 | 1.809698 | 1.041719 | NA | 28.128759 |
| 16_1_17_80174_4_2 | 16_1_17_80174 | 202 | 80174 | 4 | 17 | 16 | 1.227033e+13 | 2007 | 2 | 2007 | 1.227037e+13 | 1.227033e+13 | 1 | NA | NA | 12.2 | 98 | M330 | NA | 2 | 0.0024107 | NA | 1.867664 | 1.809698 | 1.041719 | NA | 30.042324 |
| 16_1_17_80183_4_2 | 16_1_17_80183 | 242 | 80183 | 4 | 17 | 16 | 4.038937e+13 | 2011 | 2 | 2011 | 5.102369e+13 | 5.102367e+13 | 1 | NA | NA | 12.7 | 67 | M330 | NA | 2 | 0.0025057 | NA | 1.832658 | 1.641979 | 1.078425 | NA | 23.045416 |
