raw_trees_hive <- function(state_to_use = "CT", rawdat_dir = "data/rawdat/state", arrow_dir = "data/arrow") {
  
  trees <-
    read_csv(here::here(rawdat_dir, paste0(state_to_use, "_TREE.csv")),
             # here would be where to select additional columns from the TREE table used either for QC or for computing variables for the derived tables
             # here also note that some of the included columns in the TREE table (DAM-related ones for example) confuse arrow's assumed data types
             # can specify col types with col_types and schema(), but that is labor intensive. For now I am avoiding this problem by retaining only necessary cols.
             col_select = c(CN,
                            PREV_TRE_CN,
                            INVYR,
                            STATECD,
                            COUNTYCD,
                            PLOT,
                            STATUSCD,
                            DIA,
                            HT,
                            ACTUALHT,
                            SPCD)) |>
    filter(INVYR >= 2000) 
  
  write_dataset(
    trees,
    here::here(arrow_dir, "TREE_RAW"),
    format = "csv",
    partitioning = c("STATECD", "COUNTYCD")
  )
}