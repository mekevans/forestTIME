# This script creates all of the forestTIME tables from .csv files stored on your computer.
# These files need to be the TREE, PLOT, and COND tables stored as .csv files
# with the files named as: AZ_TREE.csv, AZ_PLOT.csv, AZ_COND.csv, etc.
# You can download them from DataMart using 01a-download_files_from_DataMart.R
# If you have them from an alternate source, they need to be in a single directory with
# the files named as described above.

library(duckdb)
library(DBI)
library(dplyr)
source(here::here("R", "create_all_tables.R"))

# Specify the path where the raw .csv files from are stored
csv_dir <- here::here("data", "rawdat", "state")

# Specify the path to .duckdb file for database
database_path <-
  here::here("data", "db", "foresttime-to-share.duckdb")

if (file.exists(database_path)) {
  file.remove(database_path)
}

# Connect to database
con <- dbConnect(duckdb(dbdir = database_path))

# Create database tables
create_all_tables(con, rawdat_dir = csv_dir)

# Clean up
dbDisconnect(con, shutdown = TRUE)