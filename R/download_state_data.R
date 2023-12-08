download_state_data <- function(state = "CT", rawdat_dir = "rawdat/state", max_time = 300) {
  
  if(!dir.exists(here::here(rawdat_dir))) {
    
    dir.create(here::here(rawdat_dir), recursive = T)
    
  }
  
  download_from_datamart(state, file_dir = here::here(rawdat_dir), max_time = max_time) #this is very fast
  
}


download_from_datamart <- function(state, file_dir, max_time = 300) {
  
  url <- paste0("https://apps.fs.usda.gov/fia/datamart/CSV/", state, "_TREE.zip")
  
  zip_file <- file.path(file_dir, basename(url))
  
  options(timeout = max_time)
  
  system.time(downloaded <- try(utils::download.file(url, destfile = zip_file)))
  
  if ("try-error" %in% class(downloaded)) {
    stop("Download failed")
  }
  
  utils::unzip(zipfile = zip_file, exdir = file_dir)
 
  on.exit(options(timeout = 60))
   
}