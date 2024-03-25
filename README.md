# forestTIME 

Workshopping scripts related to the FIA timeseries project.


# Structure

- data/rawdat/state
  - Contains data files downloaded from FIADB/DataMart. Not in git.
- data/db
  - Directory for storing database (as a duckdb file)
- R/
  - Contains functions called by scripts and examples.
- scripts/
  - Contains scripts for setting up the database.
- use_cases/
  - Contains .qmd documents and occasional helper functions executing various tasks. These documents call functions in R/.
  - Contents:
    - tree_ring
    - nfs
    - ingrowth
    - whitebark_pine
    - old
  - Some quarto docs containing information that it can be useful to refer to. Species codes and the columns of forestTIME tables.
    



