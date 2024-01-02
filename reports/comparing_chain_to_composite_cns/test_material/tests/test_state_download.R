source(here::here("R", "download_state_data.R"))
library(tinytest)
library(readr)

download_state_data("CT", "test_material/tests/temp/state")

files_downloaded <- list.files(here::here("test_material", "tests", "temp", "state"))

expect_true(length(files_downloaded) == 10)

ctt <- read_csv(here::here("test_material", "tests", "temp", "state", "CT_TREE.csv"))

expect_true(nrow(ctt) == 50520)
expect_true(ncol(ctt) == 201)

to_remove <- list.files(here::here("test_material", "tests", "temp", "state"), full.names = T, recursive = T)
file.remove(to_remove)

expect_error(ctt <- read_csv(here::here("test_material", "tests", "temp", "state", "CT_TREE.csv")))

files_downloaded <- list.files(here::here("test_material", "tests", "temp", "state"))

expect_true(length(files_downloaded) == 0)
