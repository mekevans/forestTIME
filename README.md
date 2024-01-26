# forestTIME

Workshopping scripts related to the FIA timeseries project.


# Structure

- data/
  - Contains data files downloaded from FIADB/DataMart. Not included in git; includes some large files and lots of tiny files in hive.
- R/
  - Contains functions for downloading data, storing it in a hive, creating CN tables, flexibly querying data...
- static_data/
  - Contains data files for MN. Used for trial runs of remote data access (duckdb connecting to files stored online). Exposed to git so data files get pushed to the cloud.
- use_cases/
  - Contains .qmd documents and occasional helper functions executing various tasks. These documents call functions in R/.
  - Contents:
    - access_data_remotely/
       - Illustrates querying the forestTIME tables without having to download them, using `duckdbfs`. Some of these scripts may have broken paths but the code is there.
    - compare_daisychain_to_composite/
        - Works through a comparison of persistent tree IDs obtained via stitching ('daisy-chaining') together previous tree CNs, to IDS obtained by combining columns in the TREE table (STATE UNIT COUNTY PLOT SUBPLOT TREE). 
    - flexible_data_query/
        - Demos a set of functions to query forestTIME tables with user-defined criteria.
    - generate_tables/
       - Function and wrapper for loop to do the Whole Pipeline of creating the forestTIME tables. Downloads, stores, adds persistent IDS, adds TREE_INFO. Downloads can be slow; the rest is pretty quick. But you still only really want to do this occasionally.
    - whitebark_pine
        - Pull whitebark pine records from three states for Ceci.
- useful_information/
  - Some quarto docs containing information that it can be useful to refer to. Species codes and the columns of forestTIME tables.
    

# Data citation

Data in the `static-data` directory come from the FIADB TREE table for Minnesota. Data citation:

Forest Inventory and Analysis Database, December 4, 2023. U.S. Department of Agriculture, Forest Service, Northern Research Station. St. Paul, MN. [Available only on internet: https://apps.fs.usda.gov/fia/datamart/datamart.html] 

