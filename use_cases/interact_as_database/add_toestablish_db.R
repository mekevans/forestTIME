library(duckdb)
library(dplyr)
library(arrow)
library(tidyverse)

con <- dbConnect(duckdb::duckdb(), dbdir="use_cases/interact_as_database/forestTIME.duckdb", read_only=FALSE)
dbListTables(con)

dbTrees <- tbl(con, "tree_raw")
dbPlot <- tbl(con, "plot_raw")
dbCond <- tbl(con, "cond_raw")
dbCNs <- tbl(con, "tree_cns")

stateabbrevs <- read.csv(here::here("data", "rawdat", "fips", "fips.csv")) |>
  filter(!(STATE %in% c("DC", "AS", "GU", "MP", "PR", "UM", "VI"))) 

states_to_use <- stateabbrevs$STATE

for(i in 30:50) {
  
  rawdat_dir = "data/rawdat/state"
  state_to_use = states_to_use[i]
  arrow_dir = "data/arrow"
  
  trees <-
    read_csv(
      here::here(rawdat_dir, paste0(state_to_use, "_TREE.csv")),
      col_types = cols(
        .default = "d",
        STATECD = "i",
        COUNTYCD = "i",
        CREATED_BY = "c",
        CREATED_DATE = "c",
        MODIFIED_BY = "c",
        MODIFIED_DATE = "c",
        P2A_GRM_FLG = "c"
      )
    ) |>
    filter(INVYR >= 2000) |>
    mutate(
      TREE_UNIQUE_ID = paste(STATECD, UNITCD, COUNTYCD, PLOT, SUBP, TREE, sep = "_"),
      PLOT_UNIQUE_ID = paste(STATECD, UNITCD, COUNTYCD, PLOT, sep = "_")
    ) |>
    filter(!(CN %in% collect(dbTrees |> select(CN))$CN))
  
  plots <-
    read_csv(
      here::here(rawdat_dir, paste0(state_to_use, "_PLOT.csv")),
      col_types = cols(
        .default = "d",
        STATECD = "i",
        COUNTYCD = "i",
        ECOSUBCD = "c",
        CREATED_BY = "c",
        CREATED_DATE = "c",
        MODIFIED_BY = "c",
        MODIFIED_DATE = "c",
        MICROPLOT_LOC = "c",
        PREV_MICROPLOT_LOC_RMRS = "c"
      )
    ) |>
    filter(INVYR >= 2000) |>
    mutate(PLOT_UNIQUE_ID = paste(STATECD, UNITCD, COUNTYCD, PLOT, sep = "_")) |>
    filter(!(CN %in% collect(dbPlot |> select(CN))$CN))
  
  cond <-
    read_csv(
      here::here(rawdat_dir, paste0(state_to_use, "_COND.csv")),
      col_types = cols(
        .default = "d",
        PROP_BASIS = "c",
        STATECD = "i",
        COUNTYCD = "i",
        VOL_LOC_GRP = 'c',
        CREATED_BY = 'c',
        CREATED_DATE = 'c',
        MODIFIED_BY = 'c',
        MODIFIED_DATE = 'c',
        NVCS_LEVEL_2_CD = 'c',
        NVCS_LEVEL_8_CD = 'c',
        NVCS_LEVEL_6_CD = 'c',
        NVCS_LEVEL_7_CD = 'c',
        NVCS_PRIMARY_CLASS = 'c',
        NVCS_LEVEL_3_CD = 'c',
        NVCS_LEVEL_4_CD = 'c',
        NVCS_LEVEL_5_CD = 'c',
        SIEQN_REF_CD_FVS = 'c',
        HABTYPCD1 ='c', HABTYPCD2 = 'c'
      )
    ) |>
    filter(INVYR >= 2000) |>
    mutate(PLOT_UNIQUE_ID = paste(STATECD, UNITCD, COUNTYCD, PLOT, sep = "_")) |>
    filter(!(CN %in% collect(dbCond |> select(CN))$CN))
  
  
 
  tree_cns  <- arrow::open_dataset(
    here::here(arrow_dir, "TREE_CN_JOIN", state_to_use),
    partitioning = c("STATECD", "COUNTYCD"),
    format = "csv",
    hive_style = T,
    col_types = schema(
      CN = float64(),
      PREV_TRE_CN = float64())) |>
    filter(!(CN %in% collect(dbCNs |> select(CN))$CN)) |>
    compute() 
  
  if(nrow(trees) > 0) {
  arrow::to_duckdb(trees, table_name = "tree_raw_state", con = con)
  dbSendQuery(con, "INSERT INTO tree_raw SELECT * FROM tree_raw_state")
  }
  
  if(nrow(plots) > 0) {
  arrow::to_duckdb(plots, table_name = "plot_raw_state", con = con)
  dbSendQuery(con, "INSERT INTO plot_raw SELECT * FROM plot_raw_state")
  }
  
  if(nrow(cond) > 0) {
  arrow::to_duckdb(cond, table_name = "cond_raw_state", con = con)
  dbSendQuery(con, "INSERT INTO cond_raw SELECT * FROM cond_raw_state")
  }
  
  if(nrow(tree_cns) > 0) {
  arrow::to_duckdb(tree_cns, table_name = "tree_cns_state", con = con)
  dbSendQuery(con, "INSERT INTO tree_cns SELECT * FROM tree_cns_state")
  }
}

dbListTables(con)
dbDisconnect(con)


# pick up tomorrow trying dplyr style operations to generate tree_info, plot_info, unmatched_cns tables from duckdb storage