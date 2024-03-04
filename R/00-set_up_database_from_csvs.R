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

con <- dbConnect(duckdb(dbdir = here::here("data", "db", "derived_tables3.duckdb")))
dbListTables(con)

dbSendQuery(con, "CREATE TABLE tree_raw AS SELECT * FROM 'data/rawdat/state/*_TREE.csv'") # started at 3:19
dbSendQuery(con, "CREATE TABLE plot_raw AS SELECT * FROM 'data/rawdat/state/*_PLOT.csv'")
dbSendQuery(con, "CREATE TABLE cond_raw AS SELECT * FROM 'data/rawdat/state/*_COND.csv'")

dbDisconnect(con, shutdown = T)
