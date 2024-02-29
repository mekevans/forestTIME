# I did this with the DuckDB CLI.
# Commands:
# D CREATE TABLE tree_raw AS SELECT * FROM read_csv_auto('foresttime/tree_raw.csv', sample_size = 200000);
# D CREATE TABLE plot_raw AS SELECT * FROM read_csv_auto('foresttime/plot_raw.csv', sample_size = 200000);
# D CREATE TABLE cond_raw AS SELECT * FROM read_csv_auto('foresttime/cond_raw.csv', sample_size = 200000);
# The .csv files are from my downloads of FIA data over Jan 2023, stacked into a single .csv for all the states.
# You could also populate this database with .csvs of single/subsets of states,
# or tables drawn from a different database (e.g. NIMS).
# At the end of the day you need to have a .duckdb containing the TREE, PLOT, and CONDITION tables,
# named "tree_raw", "plot_raw", and "cond_raw".
# The path to this duckdb file is used in other scripts + functions. 
# Mine is here::here("foresttime-cli.duckdb").

# Alternatively, see the script in use_cases/get_tables_from_datamart to pull things in from DataMart using httpfs.