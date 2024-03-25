generate_sapling_table <- function(con,
                                   tree_id_method = "composite",
                                   conditions = create_conditions(...),
                                   variables = c("DIA", "HT", "ACTUALHT", "TPA_UNADJ")) {
  full_conditions <- c(conditions, create_conditions(DIA < 5))
  
  full_variables <-
    c(
      variables,
      "DIA",
      "HT",
      "ACTUALHT",
      "TPA_UNADJ",
      "STATUSCD",
      "MEASYEAR",
      "INVYR",
      "CYCLE",
      "CONDID",
      "COND_STATUS_CD"
    )
  
  saplings <- query_tables_db(
    con = con,
    tree_id_method = tree_id_method,
    conditions = full_conditions,
    variables = full_variables
  )
  
  saplings
  
}

generate_sapling_transition_table <- function(con,
                                              tree_id_method = "composite",
                                              conditions = create_conditions(...)) {
  relevant_trees <- query_tables_db(
    con = con,
    tree_id_method = tree_id_method,
    conditions = conditions,
    variables = c("DIA", "STATUSCD", "TPA_UNADJ")
  )
  
  saplings_ever <- relevant_trees |>
    filter(DIA < 5, STATUSCD == 1) |>
    select(TREE_UNIQUE_ID) |>
    distinct() |>
    left_join(relevant_trees)
  
  sapling_changes <- saplings_ever |>
    arrange(TREE_UNIQUE_ID, MEASYEAR) |>
    group_by(TREE_UNIQUE_ID) |>
    mutate(
      PREV_MEASYEAR = lag(MEASYEAR, 1, default = -1989),
      PREV_STATUSCD = lag(STATUSCD, 1, default = -1989),
      PREV_DIA = lag(DIA, 1, default = -1989),
      NEXT_MEASYEAR = lead(MEASYEAR, 1, default = -1989),
      FIRST_MEASYEAR = min(MEASYEAR, na.rm = T),
      LAST_MEASYEAR = max(MEASYEAR, na.rm = T)
    ) |>
    group_by_all() |>
    mutate(
      live_sapling = DIA < 5 && STATUSCD == 1,
      new_sapling = PREV_MEASYEAR == -1989 &&
        PREV_STATUSCD == -1989 &&
        PREV_DIA == -1989 && STATUSCD == 1 && DIA < 5,
      sapling_sapling = DIA < 5 &&
        STATUSCD == 1 && PREV_DIA < 5 && PREV_STATUSCD == 1,
      sapling_tree = PREV_DIA < 5 &&
        PREV_STATUSCD == 1 && DIA >= 5 && STATUSCD == 1,
      sapling_dead = PREV_DIA < 5 &&
        PREV_STATUSCD == 1 && STATUSCD == 2,
      sapling_removed = PREV_DIA < 5 &&
        PREV_STATUSCD == 1 && STATUSCD == 3,
      sapling_not_sampled = PREV_DIA < 5 &&
        PREV_STATUSCD == 1 && STATUSCD == 0,
      sapling_missing_data = PREV_DIA < 5 &&
        PREV_STATUSCD == 1 && STATUSCD == 1 && is.na(DIA),
      sapling_vanishes_next_year = DIA < 5 &&
        STATUSCD == 1 && NEXT_MEASYEAR == -1989
    ) |>
    ungroup()
  
  sapling_tallies <- sapling_changes |>
    group_by(PLOT_UNIQUE_ID, MEASYEAR) |>
    summarize(across(contains("sapling"), .f = list(nb = (\(
      x
    ) sum(
      x, na.rm = T
    ))))) |>
    ungroup() |>
    arrange(PLOT_UNIQUE_ID, MEASYEAR) |>
    group_by(PLOT_UNIQUE_ID) |>
    mutate(
    PREV_live_sapling_nb = lag(live_sapling_nb, default = -1989),
    sapling_vanished_nb = lag(sapling_vanishes_next_year_nb, default = -1989),
    PREV_MEASYEAR = lag(MEASYEAR, default = -1989)
  ) |>
    ungroup()
  
  sapling_transitions <- sapling_tallies |>
    filter(PREV_MEASYEAR != -1989) |>
    mutate(presumed_dead_nb = sapling_dead_nb + sapling_vanished_nb,
           timespan = MEASYEAR - PREV_MEASYEAR) |>
    mutate(across(c(sapling_sapling_nb,
                    sapling_tree_nb,
                    sapling_removed_nb,
                    presumed_dead_nb,
                    sapling_not_sampled_nb,
                    sapling_missing_data_nb),
                  .f = c(prop = (\(x) x / PREV_live_sapling_nb))))
  
  sapling_transition_sums <- sapling_transitions |>
    select(contains("prop")) |>
    rowSums(na.rm = T)
  
  if(any(!(sapling_transition_sums %in% c(0, 1)))) {
    message("Transition table includes proportions that sum to not 1!")
  }
  
  sapling_transitions
}
