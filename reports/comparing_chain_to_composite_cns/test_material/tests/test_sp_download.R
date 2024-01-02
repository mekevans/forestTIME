source(here::here("R", "download_species_table.R"))
library(tinytest)
library(readr)

download_species_table("test_material/tests/temp")

spt <- read_csv(here::here("test_material", "tests", "temp", "species", "REF_SPECIES.csv"))

expect_true(ncol(spt) == 82)
expect_true(nrow(spt) == 2677)

to_remove <- list.files(here::here("test_material", "tests", "temp"), full.names = T, recursive = T)
file.remove(to_remove)

expect_error(spt <- read_csv(here::here("test_material", "tests", "temp", "species", "REF_SPECIES.csv")))
