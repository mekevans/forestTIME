#' Daisy chain
#'
#' @param CN tree control number
#' @param PREV_TRE_CN previous tree control number
#' @param dat a FIA TREES table
#' @param ... additional args; used for compatibility with additional cols that may be passed via purr::pmap 
#'
#' @return data frame with `CN`, `PREV_TRE_CN`, all columns from `dat`, and an added column `TREE_FIRST_CN` that acts a persistent identifier for a single tree
#' @export
#'
#' @importFrom dplyr filter mutate
daisy_chain <- function(CN, PREV_TRE_CN, dat, ...) {
  
  if(PREV_TRE_CN %in% dat$CN) {
    return()
  }
  
  CNS <- c(CN)
  
  for(i in 1:5) {
    
    CNS <- c(CNS, dat[which(dat$PREV_TRE_CN == tail(CNS, n = 1)), "CN"])
    
  }
  
  CNS <- unlist(CNS)
  
  dat |> 
    dplyr::filter(CN %in% CNS) |>
    dplyr::mutate(TREE_FIRST_CN = CNS[1]) 
  
}

#' Add persistent CNs to TREES table
#'
#' @param TREES_table a FIA TREES table
#'
#' @return TREES_table with `TREE_FIRST_CN` added, persistent ID for each tree
#' @export
#'
#' @importFrom purrr pmap compact
#' @importFrom dplyr bind_rows
add_persistent_cns <- function(TREES_table) {
  
  purrr::pmap(TREES_table, daisy_chain, dat = TREES_table) |>
    purrr::compact() |>
    dplyr::bind_rows() 
  
}