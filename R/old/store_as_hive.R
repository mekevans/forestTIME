raw_hive <-
  function(state_to_use = "MN",
           rawdat_dir = "data/rawdat/state",
           arrow_dir = "data/arrow",
           tables = c("TREE", "PLOT", "COND")) {
    if ("TREE" %in% tables) {
      trees <-
        read_csv(
          here::here(rawdat_dir, paste0(state_to_use, "_TREE.csv")),
          col_types = cols(
            .default = "d",
            STATECD = "i",
            COUNTYCD = "i",
            CREATED_BY = "c",
            CREATED_DATE = "c",
            MODIFIED_BY = "c",
            MODIFIED_DATE = "c",
            P2A_GRM_FLG = "c"
          )
        ) |>
        filter(INVYR >= 2000) |>
        mutate(
          TREE_UNIQUE_ID = paste(STATECD, UNITCD, COUNTYCD, PLOT, SUBP, TREE, sep = "_"),
          PLOT_UNIQUE_ID = paste(STATECD, UNITCD, COUNTYCD, PLOT, sep = "_")
        )
      
      write_dataset(
        trees,
        here::here(arrow_dir, "TREE_RAW", state_to_use),
        format = "csv",
        partitioning = c("STATECD", "COUNTYCD")
      )
    }
    
    if ("PLOT" %in% tables) {
      plots <-
        read_csv(
          here::here(rawdat_dir, paste0(state_to_use, "_PLOT.csv")),
          col_types = cols(
            .default = "d",
            STATECD = "i",
            COUNTYCD = "i",
            ECOSUBCD = "c",
            CREATED_BY = "c",
            CREATED_DATE = "c",
            MODIFIED_BY = "c",
            MODIFIED_DATE = "c",
            MICROPLOT_LOC = "c",
            PREV_MICROPLOT_LOC_RMRS = "c"
          )
        ) |>
        filter(INVYR >= 2000) |>
        mutate(PLOT_UNIQUE_ID = paste(STATECD, UNITCD, COUNTYCD, PLOT, sep = "_"))
      
      write_dataset(
        plots,
        here::here(arrow_dir, "PLOT_RAW", state_to_use),
        format = "csv",
        partitioning = c("STATECD", "COUNTYCD")
      )
    }
    
    if ("COND" %in% tables) {
      cond <-
        read_csv(
          here::here(rawdat_dir, paste0(state_to_use, "_COND.csv")),
          col_types = cols(
            .default = "d",
            PROP_BASIS = "c",
            STATECD = "i",
            COUNTYCD = "i",
            VOL_LOC_GRP = 'c',
            CREATED_BY = 'c',
            CREATED_DATE = 'c',
            MODIFIED_BY = 'c',
            MODIFIED_DATE = 'c',
            NVCS_LEVEL_2_CD = 'c',
            NVCS_LEVEL_8_CD = 'c',
            NVCS_LEVEL_6_CD = 'c',
            NVCS_LEVEL_7_CD = 'c',
            NVCS_PRIMARY_CLASS = 'c',
            NVCS_LEVEL_3_CD = 'c',
            NVCS_LEVEL_4_CD = 'c',
            NVCS_LEVEL_5_CD = 'c',
            SIEQN_REF_CD_FVS = 'c',
            HABTYPCD1 ='c', HABTYPCD2 = 'c'
          )
        ) |>
      filter(INVYR >= 2000) |>
        mutate(PLOT_UNIQUE_ID = paste(STATECD, UNITCD, COUNTYCD, PLOT, sep = "_"))
      
      write_dataset(
        cond,
        here::here(arrow_dir, "COND_RAW", state_to_use),
        format = "csv",
        partitioning = c("STATECD", "COUNTYCD")
      )
    }
  }
