source(here::here("use_cases", "interact_as_database", "query_tables_db_fxns.R"))

con <- connect_to_tables(here::here("use_cases", "interact_as_database", "forestTIME.duckdb"))

attempt <- query_tables_db(con, conditions = create_conditions(STATECD %in% c(16 , 30, 56), SPCD == 101, INVYR > 2000, SPCDS == 1), variables = c("DIA", "RECONCILECD", "TREE_FIRST_CNS"))
attempt2 <- query_tables_db(con, tree_id_method = "first_cn", conditions = create_conditions(STATECD %in% c(16 , 30, 56), SPCD == 101, INVYR > 2000, SPCDS == 1), variables = c("DIA", "RECONCILECD","TREE_UNIQUE_IDS"))

sp_kelly <- c(316, 318, 832, 833, 802, 621, 531, 400, 129, 97, 762, 261, 837, 541, 12)
states_kelly <- read.csv(here::here("data", "rawdat", "fips", "fips.csv")) |>
                           filter(STATE %in% c("WV", "MD", "OH", "PA", "NY","CT", "RI", "MA", "DE", "VT", "NH", "ME"))
states_kelly <- states_kelly$STATEFP


kelly <- query_tables_db(con,  conditions = create_conditions(STATECD %in% states_kelly, SPCD %in% sp_kelly, INVYR > 2000, SPCDS == 1), variables = c("DIA"))
