raw_hive <-
  function(state_to_use = "MN",
           rawdat_dir = "data/rawdat/state",
           arrow_dir = "data/arrow",
           tables = c("TREE", "PLOT", "COND")) {
    
    if("TREE" %in% tables) {
    trees <-
      read_csv(
        here::here(rawdat_dir, paste0(state_to_use, "_TREE.csv")),
        # here would be where to select additional columns from the TREE table used either for QC or for computing variables for the derived tables
        # here also note that some of the included columns in the TREE table (DAM-related ones for example) confuse arrow's assumed data types
        # can specify col types with col_types and schema(), but that is labor intensive. For now I am avoiding this problem by retaining only necessary cols.
        col_select = c(
          CN,
          PREV_TRE_CN,
          PLT_CN,
          INVYR,
          STATECD,
          UNITCD,
          COUNTYCD,
          SUBP,
          TREE,
          PLOT,
          STATUSCD,
          CONDID,
          DIA,
          HT,
          ACTUALHT,
          SPCD,
          CYCLE
        )
      ) |>
      filter(INVYR >= 2000) |>
      mutate(TREE_UNIQUE_ID = paste(STATECD, UNITCD, COUNTYCD, PLOT, SUBP, TREE, sep = "_"),
             PLOT_UNIQUE_ID = paste(STATECD, UNITCD, COUNTYCD, PLOT, sep = "_"))
    
    write_dataset(
      trees,
      here::here(arrow_dir, "TREE_RAW"),
      format = "csv",
      partitioning = c("STATECD", "COUNTYCD")
    )
    }
    
    if("PLOT" %in% tables) {
      
      plots <-
        read_csv(
          here::here(rawdat_dir, paste0(state_to_use, "_PLOT.csv")),
         col_select = c(
           CN,
           PREV_PLT_CN,
           INVYR,
           STATECD,
           UNITCD,
           COUNTYCD,
           PLOT,
           PLOT_STATUS_CD,
           PLOT_NONSAMPLE_REASN_CD,
           MEASYEAR,
           MEASMON,
           MEASDAY,
           REMPER,
           KINDCD,
           DESIGNCD,
           RDDISTCD,
           WATERCD,
           LAT,
           LON,
           ELEV
         )
        ) |>
        filter(INVYR >= 2000) |>
        mutate(PLOT_UNIQUE_ID = paste(STATECD, UNITCD, COUNTYCD, PLOT, sep = "_"))
      
      write_dataset(
        plots,
        here::here(arrow_dir, "PLOT_RAW"),
        format = "csv",
        partitioning = c("STATECD", "COUNTYCD")
      )
    }
    
    if("COND" %in% tables) {
      
      cond <-
        read_csv(
          here::here(rawdat_dir, paste0(state_to_use, "_COND.csv")),
          col_select = c(
            CN,
            PLT_CN,
            INVYR,
            STATECD,
            UNITCD,
            COUNTYCD,
            PLOT,
           CONDID,
           COND_STATUS_CD,
           COND_NONSAMPLE_REASN_CD,
           OWNCD
          )
        ) |>
        filter(INVYR >= 2000) |>
        mutate(PLOT_UNIQUE_ID = paste(STATECD, UNITCD, COUNTYCD, PLOT, sep = "_"))
      
      write_dataset(
        cond,
        here::here(arrow_dir, "COND_RAW"),
        format = "csv",
        partitioning = c("STATECD", "COUNTYCD")
      )
    }
  }