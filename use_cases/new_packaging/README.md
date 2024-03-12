# New workflow

0. You will need the following packages installed: DBI, duckdb, arrow, dplyr, stringr. You can install them the usual way.
1. If you're setting up on a new computer, you can either get a foresttime database from Renata *or* run `scripts/create_database_from_scratch.R` to set yourself up with a database. This will download .csvs from DataMart and create all the derived tables. You can change which states you download or get them all (which will take a while to download!). You can choose what to name your database and where to put it.
    1. TODO: set up alternate workflow to import data from other sources, e.g. direct from the FIADB internal database. This is definitely doable but Renata will need to work with someone connected to such a database to get it sorted out.
2. The three .qmd/.md files in this folder contain examples of pulling survey timeseries, annualized timeseries, and sapling transition tables from this database. You might have to modify them to point to wherever the database is stored on your computer. You can then also play with them to pull data for different states/with different conditions and variables.
3. See https://viz.datascience.arizona.edu/foresttime-tables/ for a description of the tables and columns in this database. 
