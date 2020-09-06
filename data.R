library(sf)
library(poisspatial)
library(dplyr)
library(readr)
library(jsonlite)

# convert to geojson]
x <- st_read("data/Peachland_Trepanier_Harvest.shp")
x <- x %>% transmute(year = PT_Harv_Ye,
                  watershed = tolower(tools::toTitleCase(CW_NAME))) %>%
  st_transform(4326) %>%
  filter(year != 0)
st_write(x, "~/CodeVS/peachland-trepanier-logging-app/data/logging.geojson", delete_dsn = TRUE)

# create logging area summary
x$area_ha <- st_area(x) %>% units::set_units("ha") %>% as.vector()
year_total <- x
year_total$geometry <- NULL

year_total <- year_total %>%
  group_by(year) %>%
  summarise(area = sum(area_ha)) %>%
  ungroup()

writeLines(toJSON(year_total), "~/CodeVS/peachland-trepanier-logging-app/src/year_totals.json")

