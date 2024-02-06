raw_hive <-
  function(state_to_use = "MN",
           rawdat_dir = "data/rawdat/state",
           arrow_dir = "data/arrow",
           tables = c("TREE", "PLOT", "COND")) {
    if ("TREE" %in% tables) {
      trees <-
        read_csv(
          here::here(rawdat_dir, paste0(state_to_use, "_TREE.csv")),
          # here would be where to select additional columns from the TREE table used either for QC or for computing variables for the derived tables
          # here also note that some of the included columns in the TREE table (DAM-related ones for example) confuse arrow's assumed data types
          # can specify col types with col_types and schema(), but that is labor intensive. For now I am avoiding this problem by retaining only necessary cols.
          # col_select = c(
          #   CN,
          #   PREV_TRE_CN,
          #   PLT_CN,
          #   INVYR,
          #   STATECD,
          #   UNITCD,
          #   COUNTYCD,
          #   SUBP,
          #   TREE,
          #   PLOT,
          #   STATUSCD,
          #   DIA,
          #   HT,
          #   ACTUALHT,
          #   SPCD,
          #   CYCLE,
          #   CONDID,
          #   DIAHTCD,
          #   HTCD,
          #   MORTYR,
          #   MORTCD,
          #   SUBCYCLE,
          #   RECONCILED
          # ),
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
          # col_select = c(
          #   CN,
          #   PREV_PLT_CN,
          #   INVYR,
          #   STATECD,
          #   UNITCD,
          #   COUNTYCD,
          #   PLOT,
          #   PLOT_STATUS_CD,
          #   PLOT_NONSAMPLE_REASN_CD,
          #   MEASYEAR,
          #   MEASMON,
          #   MEASDAY,
          #   REMPER,
          #   KINDCD,
          #   DESIGNCD,
          #   RDDISTCD,
          #   WATERCD,
          #   LAT,
          #   LON,
          #   ELEV,
          #   CYCLE,
          #   SUBCYCLE
          # ),
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
          # col_select = c(
          #   CN,
          #   PLT_CN,
          #   INVYR,
          #   STATECD,
          #   UNITCD,
          #   COUNTYCD,
          #   PLOT,
          #   CONDID,
          #   COND_STATUS_CD,
          #   COND_NONSAMPLE_REASN_CD,
          #   OWNCD,
          #   ADFORCD,
          #   BALIVE,
          #   SICOND,
          #   SISP,
          #   SIBASE,
          #   PROP_BASIS,
          #   CONDPROP_UNADJ,
          #   MICRPROP_UNADJ,
          #   SUBPPROP_UNADJ,
          #   MACRPROP_UNADJ,
          #   SLOPE,
          #   ASPECT,
          #   DSTRBCD1,
          #   DSTRBYR1,
          #   DSTRBCD2,
          #   DSTRBYR2,
          #   DSTRBCD3,
          #   DSTRBYR3,
          #   CYCLE,
          #   SUBCYCLE,
          #   SDI_RMRS,
          #   SDIMAX_RMRS,
          #   SDIPCT_RMRS
          # ),
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
