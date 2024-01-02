# Following FM's post here: https://francoismichonneau.net/2023/06/duckdb-r-remote-data/

library(DBI)
library(duckdb)
library(dplyr)

con <- dbConnect(duckdb())

dbExecute(con, "INSTALL httpfs;")
dbExecute(con, "LOAD httpfs;")

dbExecute(con,
          "CREATE view cns AS
          SELECT * FROM read_csv_auto('https://raw.githubusercontent.com/diazrenata/in-the-trees/main/static_data/processed_tables/join_cns.csv')
          ")

dbListTables(con)

tbl(con, "cns") |>
  filter(STATECD == 9)

dbGetQuery(con, "SELECT * FROM cns WHERE STATECD == 9")

# These ^^ Work but aren't fast.
