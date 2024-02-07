library("duckdb")
library("dplyr")
con <- dbConnect(duckdb(dbdir = here::here("use_cases", "interact_as_database", "forestTIME.duckdb")))
dbListTables(con)

trees_all <- tbl(con, "tree_raw") |> collect()
unique(trees_all$STATECD)
