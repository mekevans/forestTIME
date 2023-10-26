library(arrow)
library(tidyverse)
source(here::here("daisy_chain.R"))

ct_trees <- read_csv(here::here("fia_dat_downloads", "CT", "CT_TREE.csv")) |>
  filter(INVYR >= 2000) |>
  mutate(across(ends_with("CN"), as.character)) |>
  select(CN, PLT_CN, PREV_TRE_CN, INVYR, STATECD, UNITCD, COUNTYCD, PLOT, SUBP, TREE, DIA) # Some of the other columns have caused me problems I believe are related to data types. 

write_dataset(ct_trees, here::here("arrow_dat", "CT", "TREE_NOTHIVE"), format = "csv",
              partitioning = "COUNTYCD", hive_style = F)

ct_pq <- open_dataset(here::here("arrow_dat", "CT", "TREE"), format = "csv")

ct_pq %>%
  collect() |> 
  print()


system.time(mapped_ct <- map_batches(ct_pq,~ add_persistent_cns(as.data.frame(.))) |>
              collect())

system.time(noarrow_ct <- add_persistent_cns(ct_trees))


system.time(mapped_ct_noc <- map_batches(ct_pq,~ add_persistent_cns(as.data.frame(.))) |>
              write_dataset(path = here::here("arrow_dat", "CT", "TREE_CNS"), format = "csv", partitioning = "COUNTYCD")) # OMG this is so fast


system.time(write_dataset(mapped_ct_noc, path = here::here("arrow_dat", "CT", "TREE_CNS"), format = "csv", partitioning = "COUNTYCD"))

collected <- open_dataset(here::here("arrow_dat", "CT", "TREE_CNS"), format = "csv") |> collect()

system.time(write_dataset(mapped_ct,path = here::here("arrow_dat", "CT", "TREE_CNS2"), format = "csv", partitioning = "COUNTYCD"))

sliced_pipeline <- function(ds_path) {
  
  dir.create(str_replace(ds_path, "TREE", "TREE_CNS3") |> str_remove("/part-0.csv"), recursive = T)
  
    read_csv(ds_path) |>
   add_persistent_cns() |>
    write.csv(str_replace(ds_path, "TREE", "TREE_CNS3"), row.names = F)
  
}

ds_paths <- list.files(here::here("arrow_dat", "CT", "TREE"), full.names = T, recursive = T)

system.time(map(ds_paths, sliced_pipeline))

trees_mapped <- open_dataset(here::here("arrow_dat", "CT", "TREE_CNS3"), format = "csv", partitioning = "COUNTYCD") |>
  collect()


# So consider

#download data for a state
#save the trees table as an arrow dataset partitioned by county
#use sliced_pipeline or similar to iterate over partitions and add tree cns, creating new tables
#you could create these within a hive partitioned data structure that would allow for state to be an additional high partitioning variable
#then it would be possible in principle to search all trees by cn