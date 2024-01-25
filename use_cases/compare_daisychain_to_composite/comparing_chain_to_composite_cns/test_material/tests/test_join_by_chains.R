library(tinytest)

source(here::here("R/daisy_chain.R"))

test_trees <- read.csv(here::here("test_material", "trees_test_cycle.csv"))

tt <- add_persistent_cns(test_trees)

expect_true(!anyNA(tt$TREE_FIRST_CN))
expect_true(all(tt$TREE_FIRST_CN == c(1,1,1,1,7,7,9,10,12,12,12)))

source(here::here("R/chain_by_joins.R"))

tt_j <- chain_by_joins(test_trees)

expect_true(!anyNA(tt_j$TREE_FIRST_CN))
expect_true(all(tt_j$TREE_FIRST_CN == c(1,1,1,1,7,7,9,10,12,12,12)))
