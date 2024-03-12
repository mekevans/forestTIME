library(duckdb)
library(DBI)
library(dplyr)

# path to where raw .csv files from DataMart are or are to be downloaded
csv_dir <- here::here("data", "csv") 

# path to .duckdb file for database
database_dir <- here::here("data", "db", "foresttime-tiny.duckdb")

# set up or connect to database
con <- dbConnect(duckdb(dbdir = database_dir))
dbListTables(con)

# download .csvs from datamart
# if the .csvs are already present, and overwrite = FALSE, they will not be overwritten
source(here::here("R", "download_csv_wrapper.R"))
fips <- read.csv(here::here("data", "rawdat", "fips", "fips.csv")) |>
  filter(!(STATEFP %in% c(11, 60, 66, 69, 72, 74, 78)))

download_csv_from_datamart(states = c("CT", "MA"),
                          rawdat_dir = csv_dir,
                          overwrite = FALSE)

# create database tables 
source(here::here("R", "create_all_tables.R"))
create_all_tables(con, rawdat_dir = csv_dir)

# clean up
dbDisconnect(con, shutdown = TRUE)
