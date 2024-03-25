source(here::here("use_cases", "generate_tables", "create_forestTIME_tables.R"))

fipses <- read.csv(here::here("data", "rawdat", "fips", "fips.csv"))

not_states <- c(11, 60, 66, 69, 72, 74, 78)

fipses <- fipses |>
  filter(!(STATEFP %in% not_states))

# for(i in c(3, 7, 13, 24, 27)) {
#   
#   mega_tables_function(state_to_use = fipses$STATE[i])
#   
# }
mega_tables_function("ID")
