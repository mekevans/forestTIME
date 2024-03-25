# This script installs R package dependencies and sets up the folder structure for foresTIME.
# It is intended to be run once per computer.

# Install packages #### 

install.packages(c("DBI", "duckdb", "here", "arrow", "dplyr", "stringr", "tidyr"))

# Set up folder structure ####

if(!dir.exists(here::here("data", "db"))) {
  dir.create(here::here("data", "db"), recursive = T)
}

