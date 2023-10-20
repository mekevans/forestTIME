download.file("https://apps.fs.usda.gov/fia/datamart/CSV/FIADB_REFERENCE.zip", here::here("fia_dat_downloads", "species", "DB_REFERENCE.zip"))

unzip(here::here("fia_dat_downloads", "species", "DB_REFERENCE.zip"), files = "REF_SPECIES.csv", exdir = here::here("fia_dat_downloads", "species"))
