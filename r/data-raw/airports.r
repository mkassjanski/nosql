library(dplyr)
library(readr)
library(purrr)
library(ggplot2)

if (!file.exists("data-raw/airports.dat")) {
  download.file(
    "https://raw.githubusercontent.com/jpatokal/openflights/master/data/airports.dat",
    "data-raw/airports.dat"
  )
}

# see also docs/airports.r and http://openflights.org/data.html for file format
#
# the last three fields:
#   tz -- hours offset from UTC
#               fractional hours are expressed as decimals,
#               eg. India is 5.5
#   dst -- daylight savings time
#          one of E (Europe), A (US/Canada), S (South America), O (Australia),
#          Z (New Zealand), N (None) or U (Unknown)
#   tzone database time zone -- tz Olson format

raw <- read_csv("data-raw/airports.dat",
  col_names = c("id", "name", "city", "country", "faa", "icao", "lat", "lon", "alt", "tz", "dst", "tzone")
)

airports <- raw %>%
  filter(country == "United States", faa != "") %>%
  select(faa, name, lat, lon, alt, tz, dst, tzone) %>%
  group_by(faa) %>% slice(1) %>% ungroup() # take first if duplicated

# verify the results: possibly misaligned Charleston or Savannach
airports %>%
  filter(lon < 0) %>%
  ggplot(aes(lon, lat)) +
    geom_point(aes(colour = factor(tz)), show.legend = FALSE) +
    coord_quickmap()

# write_csv(airports, bzfile("data-raw/airports.csv.bz2"))         -- does not work
# write_csv(airports, "data-raw/airports.csv", compress = "bzip2")
write.csv(airports, bzfile("data-raw/airports.csv.gz"))
save(airports, file = "data/airports.rda", compress = "bzip2")

# read PL & Russia airports

# TODO
