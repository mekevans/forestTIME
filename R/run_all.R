# This script makes the whole database. 
# It may be more efficient still to run in series and disconnect each time to keep memory use low.

library(duckdb)
library(DBI)
library(dplyr)

con <- dbConnect(duckdb(dbdir = here::here("data", "db", "derived_tables3.duckdb")))
dbListTables(con)

source("R/01-set_up_database_from_csvs.R")
# Here one could insert different step 1s to set up the database from another database or over HTTPS
source("R/02-generate_cns.R")
source("R/03-generate-qa-table.R")
source("R/04-generate_info_tables.R")
source("R/05-generate-annualized_table.R")
source("R/06-generate-sapling-tables.R")

dbListTables(con)
dbDisconnect(con, shutdown = TRUE)
