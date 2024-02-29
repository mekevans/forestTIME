# At the end of the day you need to have a raw_tables.duckdb containing the TREE, PLOT, and CONDITION tables,
# named "tree_raw", "plot_raw", and "cond_raw".
# You could get this from NIMS or an internal access to the DataMart db.
# You can also do it with the CLI, or using httpfs as in this script: 

# run these once
# install.packages("duckdb")
# install.packages("DBI")

library(duckdb)
library(DBI)

states = c("CT", "AZ", "MN", "WV", "MO", "ID") # expand to list of desired states

con <- dbConnect(duckdb(dbdir = here::here("use_cases", "get_tables_from_datamart", "raw_tables.duckdb")))
dbListTables(con)

# dbExecute(con, "INSTALL httpfs;") # uncomment if httpfs is not installed
dbExecute(con, "LOAD httpfs;")

for(i in 1:length(states)) {
  
  if(i == 1) {
    system.time(dbSendQuery(con, paste0("CREATE TABLE tree_raw AS SELECT * FROM 'https://apps.fs.usda.gov/fia/datamart/CSV/", states[i], "_TREE.csv'")))
    system.time(dbSendQuery(con, paste0("CREATE TABLE plot_raw AS SELECT * FROM 'https://apps.fs.usda.gov/fia/datamart/CSV/", states[i], "_PLOT.csv'")))
    system.time(dbSendQuery(con, paste0("CREATE TABLE cond_raw AS SELECT * FROM 'https://apps.fs.usda.gov/fia/datamart/CSV/", states[i], "_COND.csv'")))
  } else {
    system.time(dbSendQuery(con, paste0("INSERT INTO tree_raw SELECT * FROM 'https://apps.fs.usda.gov/fia/datamart/CSV/", states[i], "_TREE.csv'")))
    system.time(dbSendQuery(con, paste0("INSERT INTO plot_raw SELECT * FROM 'https://apps.fs.usda.gov/fia/datamart/CSV/", states[i], "_PLOT.csv'")))
    system.time(dbSendQuery(con, paste0("INSERT INTO cond_raw SELECT * FROM 'https://apps.fs.usda.gov/fia/datamart/CSV/", states[i], "_COND.csv'")))
  }
}

dbDisconnect(con, shutdown = T)
