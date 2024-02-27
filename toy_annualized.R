library(dplyr)

# As toy

toy_data <- data.frame(TREE_UNIQUE_ID = "foo",
                       INVYR = c(2005, 2010, 2015),
                       DIA = c(5, 7, 10))

toy_data_windows <- toy_data |> 
  group_by(TREE_UNIQUE_ID) |>
  mutate(next_INVYR = lead(INVYR, 1, max(INVYR) + 1) - 1,
         next_DIA = lead(DIA, 1, last(DIA))) |>
  mutate(DIA_slope = (next_DIA - DIA) / ((next_INVYR + 1) - INVYR))

toy_data_annual <- expand.grid(YEAR = 2000:2020,
                               TREE_UNIQUE_ID = "foo")

by <- join_by(TREE_UNIQUE_ID, between(YEAR, INVYR, next_INVYR, bounds = "[]"))

toy_data_annual_measures <- toy_data_annual |> 
  inner_join(toy_data_windows, by) |>
  mutate(DIA_run = YEAR - INVYR,
         DIA_start = DIA) |>
  mutate(DIA_est = DIA_start + (DIA_slope * DIA_run))

# On a bigger df

az_nfs <- query_tables_db(
  con = con,
  conditions = create_conditions(OWNCD == 11),
  variables = c("DIA", "HT")
) |>
  filter(!is.na(DIA), !is.na(HT))

az_nfs_windows <- az_nfs |> 
  group_by(TREE_UNIQUE_ID) |>
  mutate(next_INVYR = lead(INVYR, 1, max(INVYR) + 1) - 1,
         next_DIA = lead(DIA, 1, last(DIA))) |>
  mutate(DIA_slope = (next_DIA - DIA) / ((next_INVYR + 1) - INVYR))

az_nfs_annual <- expand.grid(YEAR = min(az_nfs$INVYR):max(az_nfs$INVYR),
                               TREE_UNIQUE_ID = unique(az_nfs$TREE_UNIQUE_ID))

by <- join_by(TREE_UNIQUE_ID, between(YEAR, INVYR, next_INVYR, bounds = "[]"))

az_nfs_annual_measures <- az_nfs_annual |> 
  inner_join(az_nfs_windows, by) |>
  mutate(DIA_run = YEAR - INVYR,
         DIA_start = DIA) |>
  mutate(DIA_est = DIA_start + (DIA_slope * DIA_run))


# As con

source(here::here("R", "query_tables_db_fxns.R"))
con <- connect_to_tables(here::here("data", "db", "forestTIME-cli.duckdb"))

trees <- tbl(con, "tree_raw") |>
  filter(!is.na(DIA), !is.na(HT)) |>
  select(TREE_UNIQUE_ID, INVYR, DIA, HT) |> 
  group_by(TREE_UNIQUE_ID) |>
  mutate(next_INVYR = lead(INVYR, order_by = INVYR),
         next_DIA = lead(DIA, order_by = INVYR)) |>
  mutate(next_INVYR = next_INVYR - 1) |>
  mutate(
         next_INVYR = ifelse(is.na(next_INVYR), INVYR, next_INVYR),
         next_DIA = ifelse(is.na(next_DIA), DIA, next_DIA)) |>
  mutate(DIA_slope = (next_DIA - DIA) / ((next_INVYR + 1) - INVYR)) 

all_years <- tbl(con, "tree_raw") |>
  select(INVYR, TREE_UNIQUE_ID) |>
  tidyr::expand(INVYR, TREE_UNIQUE_ID) |>
  arrange(TREE_UNIQUE_ID, INVYR) |>
  rename(YEAR = INVYR)

by <- join_by(TREE_UNIQUE_ID, between(YEAR, INVYR, next_INVYR, bounds = "[]"))

trees_annual_measures <- all_years |> 
  inner_join(trees, by) |>
  mutate(DIA_run = YEAR - INVYR,
         DIA_start = DIA) |>
  mutate(DIA_est = DIA_start + (DIA_slope * DIA_run)) |>
  arrange(TREE_UNIQUE_ID, YEAR) |>
  collect()

head(trees_annual_measures)

save(trees_annual_measures, file = "trees_annual_measures.RDS")

dbDisconnect(con)

