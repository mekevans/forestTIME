# You can download a pre-generated forestTIME database here:
# https://arizona.box.com/s/z59u6gjm8g91ioyechs4vwqbc3krnor3

# Store it in `data/db/`. 

library(boxr)

box_auth()

box_dl("1520429085544", local_dir = here::here("data", "db"), overwrite = T)
