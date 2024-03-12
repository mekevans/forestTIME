# This script makes the whole database. 
# It may be more efficient still to run in series and disconnect each time to keep memory use low.

library(duckdb)
library(DBI)
library(dplyr)

csv_dir <- here::here("data", "rawdat", "state")

con <- dbConnect(duckdb(dbdir = here::here("data", "db", "foresttime-new2.duckdb")))
dbListTables(con)

source(here::here("R", "download_csv_wrapper.R"))
fips <- read.csv(here::here("data", "rawdat", "fips", "fips.csv")) |>
  filter(!(STATEFP %in% c(11, 60, 66, 69, 72, 74, 78)))

download_csv_from_datamart(states = fips$STATE,
                          rawdat_dir = csv_dir,
                          overwrite = FALSE)

source(here::here("R", "import_tables_from_csvs.R"))
import_tables_from_csvs(con = con,
                        csv_dir = csv_dir)

source("R/02-generate_cns.R")
source("R/03-generate-qa-table.R")
source("R/04-generate_info_tables.R")
source("R/05-generate-annualized_table.R")
source("R/06-generate-sapling-tables.R")

dbListTables(con)
dbDisconnect(con, shutdown = TRUE)
