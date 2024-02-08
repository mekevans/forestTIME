source(here::here("use_cases", "interact_as_database", "query_tables_db_fxns.R"))

con <- connect_to_tables(here::here("use_cases", "interact_as_database", "forestTIME.duckdb"))

attempt <- query_tables_db(con, conditions = create_conditions(STATECD %in% c(16 , 30, 56), SPCD == 101, INVYR > 2000, SPCDS == 1), variables = c("DIA", "RECONCILECD", "TREE_FIRST_CNS"))
attempt2 <- query_tables_db(con, tree_id_method = "first_cn", conditions = create_conditions(STATECD %in% c(16 , 30, 56), SPCD == 101, INVYR > 2000, SPCDS == 1), variables = c("DIA", "RECONCILECD","TREE_UNIQUE_IDS"))
