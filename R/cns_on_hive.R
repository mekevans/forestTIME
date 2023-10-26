# These functions apply the daisy-chaining function to files split by *county*.
# You could further split it to slices by *plot*.
# Running in parallel might also give speed gains.
# Parallelization would probably be most beneficial at the slice level. 
# As in, at the map function in create_cn_tables.

# Note also that these functions are making use of the arrow hive structure,
# but not the other arrow functions for manipulating objects without loading them into memory.
# This is bc the daisy chaining operation is tricky and I don't know that there's a way (or a robust way that I trust)
# to accomplish it using arrow tools rather than in-memory. 

sliced_cns_pipeline <- function(ds_path) {
  
  if(!dir.exists(str_replace(ds_path, "TREE_RAW", "TREE_CNS") |> str_remove("/part-0.csv"))) {
    dir.create(str_replace(ds_path, "TREE_RAW", "TREE_CNS") |> str_remove("/part-0.csv"), recursive = T)
  }
  
  read_csv(ds_path, col_types = "ddiccdddd") |>
    add_persistent_cns() |>
    select(CN, TREE_FIRST_CN) |>
    write.csv(str_replace(ds_path, "TREE_RAW", "TREE_CNS"), row.names = F)
  
}

create_cn_tables <- function(state_number = 9,
                             arrow_dir = "data/arrow") {
  
  ds_paths <- list.files(here::here(arrow_dir, "TREE_RAW", paste0("STATECD=", state_number)), full.names = T, recursive = T)
  
  plan(multisession, workers = 4)
  
  furrr::future_map(ds_paths, sliced_cns_pipeline)
  
}