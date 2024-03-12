download_species_table <- function(rawdat_dir = "data/rawdat") {
  
  if(!dir.exists(here::here(rawdat_dir, "species"))) {
    dir.create(here::here(rawdat_dir, "species"), recursive = T)
  }
  
  download.file("https://apps.fs.usda.gov/fia/datamart/CSV/FIADB_REFERENCE.zip", here::here(rawdat_dir, "species", "DB_REFERENCE.zip"))
  
  unzip(here::here(rawdat_dir, "species", "DB_REFERENCE.zip"), files = "REF_SPECIES.csv", exdir = here::here(rawdat_dir, "species"))
  
}