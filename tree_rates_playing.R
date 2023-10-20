library(dplyr)
library(ggplot2)

ct_dat <- readr::read_csv(here::here("processed_dat", "CT", "CT_tree.csv"))
sp_dat <- readr::read_csv(here::here("fia_dat_downloads", "species", "REF_SPECIES.csv"))

## Compute lagged rates

tree_lags <- ct_dat |> 
  #filter(PLOT == 112) |>
  group_by(TREE_FIRST_CN) |>
  arrange(TREE_FIRST_CN, INVYR) |>
  mutate(n_surveys = sum(STATUSCD == 1),
         DIADIF = DIA - lag(DIA, default = NA),
         DIARAT = DIA / lag(DIA, default = NA),
         HTDIF = HT - lag(HT, default = NA),
         HTRAT = HT / lag(HT, default = NA),
         TIMEDIF = INVYR - lag(INVYR, default = NA)) |>
  select(PLOT, TREE_FIRST_CN, SPCD, INVYR, DIA, DIADIF, DIARAT, HT, HTDIF, HTRAT, TIMEDIF, n_surveys) |>
  mutate(TREE_FIRST_CN = as.character(TREE_FIRST_CN)) |>
  left_join(select(sp_dat, SPCD, GENUS, SPECIES, COMMON_NAME)) |>
  mutate(SCINAME = paste(GENUS, SPECIES, sep = "_"))



ggplot(tree_lags |> filter( n_surveys > 1), aes(INVYR, DIA, group = TREE_FIRST_CN, color = as.factor(SCINAME))) +
  geom_line() +
  geom_point() +
  theme_bw() +
  facet_wrap(vars(SCINAME)) +
  theme(legend.position = "none")


ggplot(tree_lags |> filter( n_surveys > 1), aes(DIARAT)) +
  geom_histogram() +
  geom_vline(xintercept = 1) +
  theme_bw() +
  facet_wrap(vars(SCINAME), scales = "free") +
  theme(legend.position = "none")



ggplot(tree_lags |> filter( n_surveys > 1), aes(INVYR, HT, group = TREE_FIRST_CN, color = as.factor(SCINAME))) +
  geom_line() +
  geom_point() +
  theme_bw() +
  facet_wrap(vars(SCINAME)) +
  theme(legend.position = "none")


