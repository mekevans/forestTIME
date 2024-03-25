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
- useful_information
  - Some quarto docs containing information that it can be useful to refer to. Species codes and the columns of forestTIME tables.
    
# How to use

1. Clone this repo to your computer.
1. Open forestTIME.Rproj in RStudio.
1. (Once per computer) Run `scripts/00-forestTIME_setup.R`.
1. Obtain a forestTIME database either from box or by creating it yourself. See `scripts/README.md` for options.
1. Run query functions. You can work from the use cases in the `use_cases` directory, or freestyle based on the examples in `use_cases/new_packaging`. 