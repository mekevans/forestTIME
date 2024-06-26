library(dplyr)
library(ggplot2)
source(here::here("R", "query_tables.R"))

ct_trees <- get_timeseries(conditions = list(
  STATECD = list("==", "9")
))


# Pull out timeseries of trees that have ever been recorded as saplings.
# For now, dropping the duplicated CYCLES with changing CONDIDS.
ct_saplings <- ct_trees |>
  filter(DIA < 5) |>
  select(TREE_UNIQUE_ID) |>
  distinct() |>
  left_join(ct_trees |> select(-COND_STATUS_CD, -CONDID, -OWNCD, -CN) |> distinct())

ct_sapling_fates <- ct_saplings |>
  arrange(TREE_UNIQUE_ID, MEASYEAR) |>
  group_by(TREE_UNIQUE_ID) |>
  mutate(
    last_meas_year = lag(MEASYEAR, default = NA),
    last_status = lag(STATUSCD, default = NA),
    last_DIA = lag(DIA, default = NA)
  ) |>
  group_by_all() |>
  mutate(
    is_sapling = STATUSCD == 1 && DIA < 5,
    new_sapling = is.na(last_meas_year) && is.na(last_status)  && is.na(last_DIA) && STATUSCD == 1,
    sapling_sapling = last_status ==1 && STATUSCD == 1 && DIA < 5 && last_DIA < 5,
    sapling_tree = last_status == 1 && STATUSCD == 1 && DIA >= 5 && last_DIA < 5,
    sapling_dead = last_status == 1 && STATUSCD == 2 && last_DIA < 5,
    sapling_removed = last_status == 1 && STATUSCD == 3 && last_DIA < 5
  )

ct_sapling_transitions <- ct_sapling_fates |>
  group_by(PLOT_UNIQUE_ID, CYCLE, MEASYEAR) |>
  summarize(
    n_saplings = sum(is_sapling, na.rm = T),
    n_new_saplings = sum(new_sapling, na.rm = T),
    n_sapling_saplings = sum(sapling_sapling, na.rm = T),
    n_saplings_to_trees = sum(sapling_tree, na.rm = T),
    n_saplings_died = sum(sapling_dead, na.rm = T),
    n_saplings_removed = sum(sapling_removed, na.rm = T)
  ) |>
  ungroup() |>
  arrange(PLOT_UNIQUE_ID, CYCLE, MEASYEAR) |> 
  group_by(PLOT_UNIQUE_ID) |> 
  mutate(n_saplings_previous = lag(n_saplings, default = NA),
         prev_measyear = lag(MEASYEAR),
         first_measyear = min(MEASYEAR)) |>
  group_by_all() |>
  mutate(is_first_measyear = MEASYEAR == first_measyear) |>
  ungroup()


ct_transition_probabilities <- ct_sapling_transitions |>
  filter(!is_first_measyear) |>
  mutate(across(all_of(c('n_sapling_saplings',
                'n_saplings_to_trees',
                'n_saplings_died',
                'n_saplings_removed')),
                .fns = list(prop = (\(x) x / n_saplings_previous))))

hist(ct_transition_probabilities$n_saplings_to_trees_prop)
hist(ct_transition_probabilities$n_saplings_died_prop)
