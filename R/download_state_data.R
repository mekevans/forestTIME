download_state_data <- function(state = "CT", rawdat_dir = "rawdat/state") {
  
  if(!dir.exists(here::here(rawdat_dir))) {
    
    dir.create(here::here(rawdat_dir), recursive = T)
    
  }
  
  tidyFIA::download_by_state(state, file_dir = here::here(rawdat_dir)) #this is very fast
  
}
