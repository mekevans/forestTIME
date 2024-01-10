library(duckdbfs)

flexfilter <- function(conditions = list("kitten_color == tortie")) {
  
  mydata <-
    duckdbfs::open_dataset(
      sources = here::here("flexfilter", "flexdata.csv"),
      hive_style = F,
      format = "csv"
    ) 
  
  calls = lapply(conditions, construct_call) 
  
  dplyr::filter(mydata, 
         !!!calls)
}

construct_call <- function(one_condition) {
  
  splitcond = strsplit(one_condition, " ")[[1]]
  
  variable = splitcond[1]
  op = splitcond[2]
  
  # Values
  values = splitcond[3]
  
  # List of characters
  
 if(grepl("c\\(\\'", splitcond[3])){
   
   values <- unlist(splitcond[3:length(splitcond)])
   values <- gsub(x =  values, "c\\(\\'", "",)
   values <- gsub(x = values, "\\'", "")
   values <- gsub(x = values, "\\)", "")
   values <- gsub(x = values, "\\,", "")
   
   
   # List of numbers
 } else if(grepl("c\\(", splitcond[3])){
    
    values <- unlist(splitcond[3:length(splitcond)])
    values <- gsub(x =  values, "c\\(", "",)
    values <- gsub(x = values, "\\'", "")
    values <- gsub(x = values, "\\)", "")
    values <- gsub(x = values, "\\,", "")
    values <- as.numeric(values)
  }
  
  call(op, as.name(variable), values)
  
}

flexfilter(conditions = list(("kitten_color %in% c('tortie', 'void')")))
flexfilter(conditions = list("kitten_state %in% c(12, 18)",
                             "kitten_color %in% c('tortie', 'tabby')"))
construct_call(("kitten_color %in% c('tortie', 'void')"))
construct_call("kitten_age < 10")

flexfilter("kitten_age != 8")

kitten_ages = c(8,6)

flexfilter(paste0("kitten_age %in% ", enquote(kitten_ages)[2]))

flexfilter((paste0("kitten_age %in% c(", paste(kitten_ages, collapse = ", "), ")")))
flexfilter((paste0("kitten_age == c(", paste(kitten_ages[1], collapse = ", "), ")")))

# I bet you can construct conditions out of lists, which would open up this flexibility.

construct_list_condition = function(condition_list = list(kitten_age = list("%in%", c(8, 6)))) {
  
  calls <- list()
  
  for(i in 1:length(condition_list)) {
  
  calls[[i]] <- call(unlist(condition_list[[i]][1]),
       as.name(names(condition_list)[i]),
       unlist(condition_list[[i]][2]))
  
  }
  calls
}

flexfilter_list <- function(condition_list = list(kitten_age = list(operator = "<", 
                                                                    values = 7),
                                                  kitten_color = list(operator = "%in%", 
                                                                      values = c("tortie", "void")))) {
  
  mydata <-
    duckdbfs::open_dataset(
      sources = here::here("flexfilter", "flexdata.csv"),
      hive_style = F,
      format = "csv"
    ) 
  
  calls = construct_list_condition(condition_list) 
  
  dplyr::filter(mydata, 
                !!!calls)
}

construct_list_condition(list(kitten_color = list("%in%", c("tortie", "void"))))
construct_list_condition(list(kitten_age = list("<", 50)))

flexfilter_list()
