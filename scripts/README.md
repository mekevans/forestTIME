This directory holds scripts for setting up the repo and database.
Run them in this order:

- 00-forestTIME_setup.R: Installs packages and sets up directories.

Then you have choices regarding how you create the forestTIME database:

- Download a preexisting database from Box:
  - See 01-download_database.R
- Download raw .csv files from DataMart and create a database from there:
  - 01a-download_files_from_DataMart.R
  - 01b-create_database_from_files.R
- Create the database from files you already have (note they need to be stored as .csvs):
  - 01b-create_database_from_files.R
  
Additional options are WIP!