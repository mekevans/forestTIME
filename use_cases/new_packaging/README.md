# New workflow

## Setup 

1. Clone this repo to your computer.
1. You will need the following packages installed: DBI, duckdb, arrow, here, dplyr, stringr, tidyr. You can install them the usual way: `install.packages(c("DBI", "duckdb", "here", "arrow", "dplyr", "stringr", "tidyr"))`
1. Open forestTIME.Rproj on your computer.

## Getting a database

1. For a *quick start*, you can download a database (whole US) from this link: https://arizona.box.com/s/z59u6gjm8g91ioyechs4vwqbc3krnor3. Store it in `data/db/`. 
1. To generate a new database, you can open, modify, and run `scripts/create_database_from_scratch.R` to set yourself up with a database. This will download .csvs from DataMart and create all the derived tables. You can change which states you download or get them all (which will take a while to download!). You can choose what to name your database and where to put it.
    1. TODO: set up alternate workflow to import data from other sources, e.g. direct from the FIADB internal database. This is definitely doable but Renata will need to work with someone connected to such a database to get it sorted out.

## Accessing data

1. The three .qmd/.md files in this folder contain examples of pulling survey timeseries, annualized timeseries, and sapling transition tables from this database. 
1. You can modify them to pull different subsets of data or different variables. For a list of the columns available to filter on/import, see: https://viz.datascience.arizona.edu/foresttime-tables/ 
1. They are currently set up to pull from the database at the Box link above, stored in `data/db`. If you stored the database somewhere else, named it differently, or made your own, you might have to modify them to point to wherever the database is stored on your computer. 

