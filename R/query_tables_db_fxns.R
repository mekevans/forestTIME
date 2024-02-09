library("duckdb")
library("dplyr")

query_tables_db <- function(con,
                            tree_id_method = "composite",
                            conditions = create_conditions(...),
                            variables = c("DIA")) {
  # Connect to tables
  
  trees <- tbl(con, "tree_raw")# |> compute()
  
  if (tree_id_method == "composite") {
    tree_info <- tbl(con, "tree_info_composite_id")# |> compute()
  } else {
    tree_info <- tbl(con, "tree_info_first_cn")# |> compute()
    
    cns <- tbl(con, "tree_cns")
    
    trees <- left_join(trees, cns)
    
  }
  
  plots <-
    tbl(con, "plot_raw") |> rename(PLT_CN = CN) |> select(-any_of(
      c(
        "CREATED_BY",
        "CREATED_DATE",
        "CREATED_IN_INSTANCE",
        "MODIFIED_BY",
        "MODIFIED_DATE",
        "MODIFIED_IN_INSTANCE"
      )
    ))# |>
  #compute()
  
  cond <-
    tbl(con, "cond_raw") |> rename(COND_CN = CN) |> select(-any_of(
      c(
        "CREATED_BY",
        "CREATED_DATE",
        "CREATED_IN_INSTANCE",
        "MODIFIED_BY",
        "MODIFIED_DATE",
        "MODIFIED_IN_INSTANCE"
      )
    )) #|>  compute()
  
  # Prepare filter args
  
  filter_args <- conditions |>
    lapply(rlang::as_label) |>
    unlist() |>
    strsplit(split = " ") |>
    lapply(purrr::pluck, 1) |>
    unlist()
  
  static_names <-
    c(
      'TREE_UNIQUE_ID',
      'PLOT_UNIQUE_ID',
      'NYEARS',
      'NYEARS_MEASURED',
      'FIRSTYR',
      'LASTYR',
      'SPCD',
      'PLOT',
      'SUBPLOT',
      'SPCDS',
      'COUNTYCD',
      'STATECD'
    )
  
  
  if (any(filter_args %in% static_names)) {
    static_filters <- conditions[which(filter_args %in% static_names)]
  } else {
    static_filters <- NULL
  }
  
  if (!any(filter_args %in% static_names)) {
    dynamic_filters <- NULL
  } else {
    dynamic_filters <-
      conditions[which(!(filter_args %in% static_names))]
  }
  
  # Prepare variables to pull
  
  if (tree_id_method == "composite") {
    needed_variables <- c(
      'TREE_UNIQUE_ID',
      'PLOT_UNIQUE_ID',
      'SPCD',
      'PLOT',
      'SUBPLOT',
      'SPCDS',
      'COUNTYCD',
      'STATECD',
      'PLT_CN',
      'INVYR',
      'CYCLE',
      'MEASYEAR',
      'CN',
      'COND_CN',
      'CONDID'
    )
  } else {
    needed_variables <- c(
      'TREE_FIRST_CN',
      'PLOT_UNIQUE_ID',
      'SPCD',
      'PLOT',
      'SUBPLOT',
      'SPCDS',
      'COUNTYCD',
      'STATECD',
      'PLT_CN',
      'INVYR',
      'CYCLE',
      'MEASYEAR',
      'CN',
      'COND_CN',
      'CONDID'
    )
  }
  
  all_variables <- c(needed_variables, variables)
  
  # Select trees
  
  selected_trees <- tree_info |>
    filter(!!!static_filters) #|>
  # compute()
  
  # Pull timeseries
  
  tree_timeseries <- selected_trees |>
    left_join(trees) |>
    left_join(plots) |>
    left_join(cond) |>
    filter(!!!dynamic_filters) |>
    select(all_of(all_variables)) |>
    collect()
  
  tree_timeseries
}

create_conditions <- function(...) {
  rlang:::enquos(...)
  
}

connect_to_tables <- function(db_path) {
  con <- dbConnect(duckdb(
    dbdir = db_path
  ))
  
  con
  
}

#dbDisconnect(con)
