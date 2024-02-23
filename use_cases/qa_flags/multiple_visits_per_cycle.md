# Trees with multiple visits per cycle

``` r
repeat_trees <- tbl(con, "tree_raw") |>
  group_by(TREE_UNIQUE_ID, CYCLE) |>
  tally() |> 
  ungroup() |>
  filter(n > 1) |>
  collect()

repeat_tree_ids <- repeat_trees$TREE_UNIQUE_ID

repeat_tree_records <- query_tables_db(con, conditions = create_conditions(TREE_UNIQUE_ID %in% repeat_tree_ids), variables = c("MANUAL", "PREV_TRE_CN")) |>
  right_join(repeat_trees)
```

    Joining with `by = join_by(TREE_UNIQUE_ID, PLOT_UNIQUE_ID, PLOT, STATECD, COUNTYCD)`
    Joining with `by = join_by(PLOT_UNIQUE_ID, PLOT, STATECD, COUNTYCD, PLT_CN, INVYR, UNITCD, CYCLE, SUBCYCLE)`
    Joining with `by = join_by(PLOT_UNIQUE_ID, PLOT, STATECD, COUNTYCD, PLT_CN, INVYR, UNITCD, CONDID, CYCLE, SUBCYCLE)`
    Joining with `by = join_by(TREE_UNIQUE_ID, CYCLE)`

``` r
repeat_tree_records <- repeat_tree_records |>
  arrange(TREE_UNIQUE_ID, CYCLE, INVYR)
```

There are 18436 trees with 2 visits in one cycle. They’re distributed
over 8 states. All have MANUAL \> 1. Most, except for records in TN and
NC, have PREV_TRE_CN as NA. The records are saved in
`multiple_visits_per_cycle.csv` for more digging.
