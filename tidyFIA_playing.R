library(tidyFIA)
library(tidyverse)


# dat <- tidy_fia(states = "CT", postgis = FALSE, table_names = c("plot", "tree")) # fails and I bet this relates to temp directories

dat2 <- download_by_state("CT") #this is very fast

names(dat2) # returns a list of file names

dat3 <- map(dat2, read_csv)
names(dat3)

trees <- dat3$TREE |>
  filter(INVYR >= 2000)


one_plot <- trees |>
  filter(PLOT == unique(trees$PLOT)[2]) |>
  mutate(across(ends_with("CN"), as.character))

plots <- dat3$PLOT |>
  filter(INVYR >= 2000)

unique(plots$PLOT)

plots_by_plot <- plots |> 
  group_by(PLOT) |>
  summarize(nctrlnbs = length(unique(CN)),
            ninvyrs = length(unique(INVYR)))
filter(plots, PLOT == 725) |> select(CN, PREV_PLT_CN, INVYR) 

# From this spot-check it looks to me like:
# 1. PLOTS$PLOT is a persistent identifier for plot - at least from 2000 onward?
# 2. PLOTS$CN is a unique identifier for a plot x survey combination
# 3. PLOTS$CN reliably links up with PLOTS$PREV_PLT_CN based on PLOTS$PLOT

### rough daisy-chain code

daisy_chain <- function(CN, PREV_TRE_CN, dat, ...) {
  
  if(PREV_TRE_CN %in% dat$CN) {
    return()
  }
  
  CNS <- c(CN)
  
  for(i in 1:length(unique(dat$INVYR))) { # this could be made faster if set to a hard upper limit of the max nb of times we imagine a tree has ever been visited
    
    CNS <- c(CNS, dat[which(dat$PREV_TRE_CN == tail(CNS, n = 1)), "CN"])
    
  }
  
  CNS <- unlist(CNS)
  
  dat |> filter(CN %in% CNS) |>
    mutate(TREE_FIRST_CN = CNS[1]) 
  
}

one_plot_bound <- pmap(one_plot, daisy_chain, dat = one_plot) |>
  compact() |>
  bind_rows() |>
  select(TREE_FIRST_CN, INVYR, CN, PREV_TRE_CN) |>
  arrange(TREE_FIRST_CN, INVYR) 

library(ggplot2)

ggplot(one_plot_bound, aes(INVYR, TREE_FIRST_CN)) +
  geom_point() +
  theme_minimal()

# kk now I'm curious

twenty_plots <- trees |>
  filter(PLOT %in% unique(PLOT)[1:200])

Sys.time()
twenty_plots_bound <- pmap(twenty_plots, daisy_chain, dat = twenty_plots) |>
  compact() |>
  bind_rows() |>
  select(TREE_FIRST_CN, INVYR, CN, PREV_TRE_CN, PLOT) |>
  arrange(TREE_FIRST_CN, INVYR) 
Sys.time()



ggplot(twenty_plots_bound , aes(INVYR, as.factor(TREE_FIRST_CN))) +
  geom_point() +
  theme_minimal() +
  theme(axis.text.y = element_blank()) +
  facet_wrap(vars(PLOT), scales = "free_y")


# Depending on the state this can be impossibly slow; def doesn't scale linearly. CT was about 2m, AZ, CO would not finish within my attention span. 
# If plots are truly unique, I suggest batching this by plot
# arrow can do that
# Sys.time()
# all_plots_bound <- pmap(trees, daisy_chain, dat = trees) |>
#   compact() |>
#   bind_rows() |>
#   select(TREE_FIRST_CN, INVYR, CN, PREV_TRE_CN, PLOT) |>
#   arrange(TREE_FIRST_CN, INVYR) 
# Sys.time()


# Curious about going further back in time

trees_old <- dat3$TREE

old_plots <- trees_old |>
  filter(PLOT %in% unique(PLOT)[1:10])

Sys.time()
old_plots <- pmap(old_plots, daisy_chain, dat = old_plots) |>
  compact() |>
  bind_rows() |>
  select(TREE_FIRST_CN, INVYR, CN, PREV_TRE_CN, PLOT) |>
  arrange(TREE_FIRST_CN, INVYR) 
Sys.time()


ggplot(old_plots , aes(INVYR, as.factor(TREE_FIRST_CN))) +
  geom_point() +
  theme_minimal() +
  theme(axis.text.y = element_blank()) +
  facet_wrap(vars(PLOT), scales = "free_y")

yrsm <- old_plots |> group_by(TREE_FIRST_CN) |>
  summarize(nyears = length(INVYR),
            nyrs_pre_2000 = sum(INVYR <= 2000),
            nyrs_pst_2000 = sum(INVYR >= 2000)) |>
  filter(nyears > 1)

# At least for this section of Vermont (and i also tried CT), the trees surveyed prior to 2000 don't have CNs that daisy-chain up with the new ones. 


# I wonder if there's a quicker way to do this with left joins
# Somehow failing to grok this
# dat = one_plot
# 
# 
# dat_vars <- dat |>
#   select(INVYR, CN, PREV_TRE_CN)
# 
# INVYRS <- sort(unique(dat_vars$INVYR))
# 
# this_year <- dat_vars |>
#   filter(INVYR == INVYRS[1])
# 
# for(i in 1:length(INVYRS)) {
#   all_sub_years <- dat_vars |> 
#     filter(INVYR > INVYRS[i])
#   
#   this_year <- left_join(this_year, all_sub_years, by = join_by(CN == PREV_TRE_CN))
# }


