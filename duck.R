library(duckdb)
library(arrow)
library(dplyr)

arrow_dir <- "data/arrow"


# Store the cns table as a duckdb

join_cns <- open_dataset(
  here::here(arrow_dir, "TREE_CN_JOIN"),
  partitioning = c("STATECD", "COUNTYCD"),
  format = "csv",
  hive_style = T,
  col_types = schema(CN = float64(),
                     TREE_FIRST_CN = float64())
)


tree_info <- open_dataset(
  here::here(arrow_dir, "TREE_INFO"),
  partitioning = c("STATECD", "COUNTYCD"),
  format = "csv",
  hive_style = T,
  col_types = schema(CN = float64(),
                     TREE_FIRST_CN = float64())
)

con <- dbConnect(duckdb::duckdb(), dbdir="cns.duckdb", read_only=FALSE)

arrow::to_duckdb(join_cns, table_name = "cns_dat", con = con)
dbSendQuery(con, "CREATE TABLE cns_dat AS SELECT * FROM cns_dat")

arrow::to_duckdb(tree_info, table_name = "tree_info", con = con)
dbSendQuery(con, "CREATE TABLE tree_info AS SELECT * FROM tree_info")

dbListTables(con)
dbDisconnect(con)


join_cns_df <- collect(join_cns)
tree_info_df <- collect(tree_info)

# For curiousity's sake, also saving as .csvs

write.csv(join_cns_df, here::here("data", "processed_tables", "join_cns.csv"), row.names = F) # 53 MB
write.csv(tree_info_df, here::here("data", "processed_tables", "tree_info.csv"), row.names = F) # 26 MB
