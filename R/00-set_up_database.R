# At the end of the day you need to have a raw_tables.duckdb containing the TREE, PLOT, and CONDITION tables,
# named "tree_raw", "plot_raw", and "cond_raw".
# You could get this from NIMS or an internal access to the DataMart db.
# You can also do it with the CLI, or using httpfs as in this script: 

# run these once
# install.packages("duckdb")
# install.packages("DBI")

library(duckdb)
library(DBI)
library(dplyr)

# states = c("CT", "AZ", "MN", "WV", "MO", "ID", "VA") # expand to list of desired states

fipses <- read.csv(here::here("data", "rawdat", "fips", "fips.csv"))

not_states <- c(11, 60, 66, 69, 72, 74, 78)

fipses <- fipses |>
  filter(!(STATEFP %in% not_states))

states <- fipses$STATE

con <- dbConnect(duckdb(dbdir = here::here("data", "db", "raw_tables2.duckdb")))
dbListTables(con)

# dbExecute(con, "INSTALL httpfs;") # uncomment if httpfs is not installed
dbExecute(con, "LOAD httpfs;")
# began at 9:34 
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
