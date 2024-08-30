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

This code pulls 6 trees out of Idaho to start working with, and adds a
row to match the Douglas fir example worked in the text.

Note that I am pretending Idaho is in DIVISION 240, which is wrong, to
match the worked example.

``` r
con <- connect_to_tables(here::here("data", "db", "foresttime-from-state-parquet.duckdb"))

some_trees <- query_tree_surveys(con,
                                 conditions = create_conditions(STATECD == 16,
                                                                !is.na(DIA),
                                                                !is.na(HT),
                                                                STATUSCD == 1,
                                                                !is.na(SPCD),
                                                                SPCD %in% c(202, 231, 73)),
                                 variables = c("STANDING_DEAD_CD", "DECAYCD", "DIA", "HT")) |>
  group_by(SPCD) |>
  mutate(rowindex = row_number()) |>
  ungroup() |>
  filter(rowindex <= 2) |>
  select(-rowindex) |>
  head() |>
  bind_rows(data.frame(SPCD = 202,
                       HT = 110,
                       DIA = 20))

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
         DIVISION %in% c("", "240")) |>
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

## Apply the model for gross total stem wood volume

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
```

Run the math, and we get the right result for the Doug fir example:

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
| 16_1_49_80298_4_3 | 16_1_49_80298 | 202 | 80298 | 4 | 49 | 16 | 1.227852e+13 | 2007 | 2 | 2007 | 1.227858e+13 | 1.227852e+13 | 1 | NA | NA | 13.3 | 69 | 240 | NA | 2 | 0.0019291 | NA | 2.162413 | 1.6904 | 0.985444 | NA | 28.02924 |
| 16_1_49_80326_4_4 | 16_1_49_80326 | 202 | 80326 | 4 | 49 | 16 | 3.727587e+13 | 2010 | 2 | 2011 | 4.251260e+13 | 4.251255e+13 | 1 | NA | NA | 11.3 | 60 | 240 | NA | 2 | 0.0019291 | NA | 2.162413 | 1.6904 | 0.985444 | NA | 18.54223 |
| 16_1_49_84131_2_6 | 16_1_49_84131 | 73 | 84131 | 2 | 49 | 16 | 5.388385e+12 | 2005 | 2 | 2005 | 3.133625e+13 | 5.388388e+12 | 1 | NA | NA | 6.0 | 31 |  | NA | 1 | 0.0038058 | NA | 1.745228 | NA | 1.004542 | NA | 2.73298 |
| 16_1_49_86700_4_1 | 16_1_49_86700 | 73 | 86700 | 4 | 49 | 16 | 1.180430e+13 | 2006 | 2 | 2006 | 1.180433e+13 | 1.180430e+13 | 1 | NA | NA | 35.4 | 133 |  | NA | 1 | 0.0038058 | NA | 1.745228 | NA | 1.004542 | NA | 261.40379 |
| 16_1_49_88124_2_11 | 16_1_49_88124 | 231 | 88124 | 2 | 49 | 16 | 1.887718e+14 | 2015 | 3 | 2016 | 4.855121e+14 | 4.855121e+14 | 1 | NA | NA | 1.9 | 13 | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA |
| 16_1_49_88124_2_11 | 16_1_49_88124 | 231 | 88124 | 2 | 49 | 16 | 5.390710e+12 | 2005 | 2 | 2008 | 3.133657e+13 | 5.390712e+12 | 1 | NA | NA | 1.9 | 14 | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA |
| NA | NA | 202 | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | 20.0 | 110 | 240 | NA | 2 | 0.0019291 | NA | 2.162413 | 1.6904 | 0.985444 | NA | 88.45229 |

# Step 2 Gross total stem bark volume

We get the models and coefficients from table S2a in the Supplement:

``` r
table_s2a <-  read.csv(here::here("use_cases", 
                                 "carbon_estimation",
                                 "Supplemental_tables",
                                 "Table S2a_volbk_coefs_spcd.csv"))
```

``` r
table_s2a_models <- table_s2a |>
  filter(SPCD %in% some_trees$SPCD,
         DIVISION %in% c("", "240")) |>
  mutate(DIVISION_nchar = nchar(DIVISION)) |>
  group_by(SPCD) |>
  mutate(longest_division = max(DIVISION_nchar)) |>
  ungroup() |>
  filter(DIVISION_nchar == longest_division) |>
  select(-DIVISION_nchar, -longest_division)

gtsbv_models <- left_join(some_trees, table_s2a_models)
```

    Joining with `by = join_by(SPCD)`

``` r
some_trees_gtsbv <- gtsbv_models |>
  group_by_all() |>
  mutate(gtsbv = ifelse(model == 1,
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

knitr::kable(some_trees_gtsbv)
```

| TREE_COMPOSITE_ID | PLOT_COMPOSITE_ID | SPCD | PLOT | SUBP | COUNTYCD | STATECD | PLT_CN | INVYR | CYCLE | MEASYEAR | TREE_CN | COND_CN | CONDID | STANDING_DEAD_CD | DECAYCD | DIA | HT | DIVISION | STDORGCD | model | a | a1 | b | b1 | c | c1 | gtsbv |
|:---|:---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|:---|:---|---:|---:|:---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 16_1_49_80298_4_3 | 16_1_49_80298 | 202 | 80298 | 4 | 49 | 16 | 1.227852e+13 | 2007 | 2 | 2007 | 1.227858e+13 | 1.227852e+13 | 1 | NA | NA | 13.3 | 69 | 240 | NA | 1 | 0.0000319 | NA | 1.212605 | NA | 1.978577 | NA | 3.1980405 |
| 16_1_49_80326_4_4 | 16_1_49_80326 | 202 | 80326 | 4 | 49 | 16 | 3.727587e+13 | 2010 | 2 | 2011 | 4.251260e+13 | 4.251255e+13 | 1 | NA | NA | 11.3 | 60 | 240 | NA | 1 | 0.0000319 | NA | 1.212605 | NA | 1.978577 | NA | 1.9905297 |
| 16_1_49_84131_2_6 | 16_1_49_84131 | 73 | 84131 | 2 | 49 | 16 | 5.388385e+12 | 2005 | 2 | 2005 | 3.133625e+13 | 5.388388e+12 | 1 | NA | NA | 6.0 | 31 |  | NA | 1 | 0.0026974 | NA | 2.073980 | NA | 0.588855 | NA | 0.8375478 |
| 16_1_49_86700_4_1 | 16_1_49_86700 | 73 | 86700 | 4 | 49 | 16 | 1.180430e+13 | 2006 | 2 | 2006 | 1.180433e+13 | 1.180430e+13 | 1 | NA | NA | 35.4 | 133 |  | NA | 1 | 0.0026974 | NA | 2.073980 | NA | 0.588855 | NA | 78.3765016 |
| 16_1_49_88124_2_11 | 16_1_49_88124 | 231 | 88124 | 2 | 49 | 16 | 1.887718e+14 | 2015 | 3 | 2016 | 4.855121e+14 | 4.855121e+14 | 1 | NA | NA | 1.9 | 13 | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA |
| 16_1_49_88124_2_11 | 16_1_49_88124 | 231 | 88124 | 2 | 49 | 16 | 5.390710e+12 | 2005 | 2 | 2008 | 3.133657e+13 | 5.390712e+12 | 1 | NA | NA | 1.9 | 14 | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA |
| NA | NA | 202 | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | 20.0 | 110 | 240 | NA | 1 | 0.0000319 | NA | 1.212605 | NA | 1.978577 | NA | 13.1971301 |

Note that the estimate for the Doug fir example diverges subtly from the
paper (which has 13.191436232306). I think this is because the
coefficients in the paper for SPCD 202/DIVISION 240 differ from those in
table s2a. Specifically, `a` is 0.000031886237 in the paper and
0.000031900 in the table - truncation?

``` r
model1(20, 110, a = 0.000031886237, b = gtsbv_models$b[7], c = gtsbv_models$c[7])
```

    [1] 13.19144

# Step 3 Gross total stem outside-bark volume

This is just a sum:

``` r
some_trees_gtsobv <- some_trees |>
  mutate(gtsobv = some_trees_gtsbv$gtsbv +
                      some_trees_gtswv$gtswv)

knitr::kable(some_trees_gtsobv)
```

| TREE_COMPOSITE_ID | PLOT_COMPOSITE_ID | SPCD | PLOT | SUBP | COUNTYCD | STATECD | PLT_CN | INVYR | CYCLE | MEASYEAR | TREE_CN | COND_CN | CONDID | STANDING_DEAD_CD | DECAYCD | DIA | HT | gtsobv |
|:---|:---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|:---|:---|---:|---:|---:|
| 16_1_49_80298_4_3 | 16_1_49_80298 | 202 | 80298 | 4 | 49 | 16 | 1.227852e+13 | 2007 | 2 | 2007 | 1.227858e+13 | 1.227852e+13 | 1 | NA | NA | 13.3 | 69 | 31.227284 |
| 16_1_49_80326_4_4 | 16_1_49_80326 | 202 | 80326 | 4 | 49 | 16 | 3.727587e+13 | 2010 | 2 | 2011 | 4.251260e+13 | 4.251255e+13 | 1 | NA | NA | 11.3 | 60 | 20.532762 |
| 16_1_49_84131_2_6 | 16_1_49_84131 | 73 | 84131 | 2 | 49 | 16 | 5.388385e+12 | 2005 | 2 | 2005 | 3.133625e+13 | 5.388388e+12 | 1 | NA | NA | 6.0 | 31 | 3.570528 |
| 16_1_49_86700_4_1 | 16_1_49_86700 | 73 | 86700 | 4 | 49 | 16 | 1.180430e+13 | 2006 | 2 | 2006 | 1.180433e+13 | 1.180430e+13 | 1 | NA | NA | 35.4 | 133 | 339.780289 |
| 16_1_49_88124_2_11 | 16_1_49_88124 | 231 | 88124 | 2 | 49 | 16 | 1.887718e+14 | 2015 | 3 | 2016 | 4.855121e+14 | 4.855121e+14 | 1 | NA | NA | 1.9 | 13 | NA |
| 16_1_49_88124_2_11 | 16_1_49_88124 | 231 | 88124 | 2 | 49 | 16 | 5.390710e+12 | 2005 | 2 | 2008 | 3.133657e+13 | 5.390712e+12 | 1 | NA | NA | 1.9 | 14 | NA |
| NA | NA | 202 | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | NA | 20.0 | 110 | 101.649421 |

# Step 4 Heights to merchantable top
