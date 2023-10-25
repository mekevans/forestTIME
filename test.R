source(here::here("daisy_chain.R"))

test_trees <- read.csv(here::here("trees_test.csv"))

add_persistent_cns(test_trees)
