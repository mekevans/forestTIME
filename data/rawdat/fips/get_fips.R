fips <- read.delim("https://www2.census.gov/geo/docs/reference/codes2020/national_state2020.txt",
                  sep = "|")
write.csv(fips, here::here("data", "rawdat", "fips", "fips.csv"))
