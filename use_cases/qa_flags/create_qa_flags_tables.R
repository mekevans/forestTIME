library(duckdb)
library(dplyr)

source(here::here("R", "query_tables_db_fxns.R"))

con <- connect_to_tables(here::here("data", "db", "forestTIME-cli.duckdb"))

trees <- tbl(con, "tree_raw")

# TREE_UNIQUE_ID 

tree_latest_species <- trees |>
  #filter(STATECD == 9) |>
  select(CN, TREE_UNIQUE_ID, INVYR, SPCD) |>
  distinct() |>
  group_by(TREE_UNIQUE_ID) |>
  mutate(last_invyr = max(INVYR)) |>
  mutate(SPCD_CORR = ifelse(INVYR == last_invyr, SPCD, NA)) |>
  mutate(SPCD_CORR = max(SPCD_CORR)) |>
  ungroup() |>
  mutate(SPCD_FLAG = SPCD != SPCD_CORR) |>
  select(-last_invyr) 

trees_last_dead <- trees |>
  #filter(STATECD == 9) |>
  select(CN, TREE_UNIQUE_ID, INVYR, STATUSCD) |>
  mutate(isdead = (STATUSCD %in% c(2, 3)))|> 
  group_by(TREE_UNIQUE_ID) |>
  mutate(dead_invyr = ifelse(isdead, (INVYR), NA),
         live_invyr = ifelse(STATUSCD == 1, INVYR, NA)) |>
  mutate(first_dead_invyr = min(dead_invyr, na.rm = T),
         last_live_invyr = max(live_invyr, na.rm = T)) |>
  ungroup() |>
  mutate(zombie = last_live_invyr > first_dead_invyr) |>
  mutate(STATUSCD_CORR = ifelse(is.na(zombie), 
                                STATUSCD,
                                ifelse(zombie, 
                                       ifelse(INVYR <= last_live_invyr,
                                              ifelse(isdead, 
                                                     5, 
                                                     STATUSCD),
                                              STATUSCD),
                                       STATUSCD))) |>
  mutate(STATUSCD_FLAG = (STATUSCD != STATUSCD_CORR)) |>
  select(CN, TREE_UNIQUE_ID, INVYR, STATUSCD, STATUSCD_CORR, STATUSCD_FLAG) 

qa_flag_table <- left_join(trees_last_dead, tree_latest_species) |>
  collect()


arrow::to_duckdb(qa_flag_table, table_name = "qa_flag_table_composite", con = con)
dbSendQuery(con, "CREATE TABLE qa_flag_table_composite AS SELECT * FROM qa_flag_table_composite")

dbDisconnect(con, shutdown = TRUE)


