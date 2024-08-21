# forestTIME 

## Setup 

1. Clone this repo to your computer.
1. You will need the following packages installed: DBI, duckdb, arrow, here, dplyr, stringr, tidyr. You can install them the usual way: `install.packages(c("DBI", "duckdb", "here", "arrow", "dplyr", "stringr", "tidyr"))`
1. Open forestTIME.Rproj on your computer.

## Getting a database

1. Download a database (whole US) from this link: https://arizona.box.com/s/usl7pcprwdytbit926ceb3t6lxsldndz. 
Store it in `data/db/`. 

## Accessing data

1. The three .qmd/.md files in `use_cases/new_packaging` contain examples of pulling survey timeseries, annualized timeseries, and sapling transition tables from this database. 
1. You can modify them to pull different subsets of data or different variables. For a list of the columns available to filter on/import, see: https://viz.datascience.arizona.edu/foresttime-tables/ 
1. They are currently set up to pull from the database at the Box link above, stored in `data/db`. If you stored the database somewhere else, named it differently, or made your own, you might have to modify them to point to wherever the database is stored on your computer. 

## Generating your own database

To *generate* the database, use the scripts in `diazrenata/automatic-trees`. 