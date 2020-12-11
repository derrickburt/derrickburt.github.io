# load libraries
library(tidyverse)
library(sp)
library(rgdal)
library(stringr)
library(rvest)
library(dplyr)
library(leaflet)
library(geojsonio)
library(ggplot2)
library(RColorBrewer)

# data
setwd("~/Desktop/MATH0216/final/VTparcels/")
vtParcels <- read_csv("parcelData.csv")

### parcel data ------
# join county + population data to parcel data
county.url <- "https://en.wikipedia.org/wiki/List_of_towns_in_Vermont"

county.list <- county.url %>% 
  read_html() %>% 
  html_nodes(xpath = '//*[@id="mw-content-text"]/div[1]/table') %>% 
  html_table(fill = TRUE)

counties <- county.list[[1]]

counties <- select(counties,
                   c("Town",
                     "County",
                     "Pop" = "2010 Population[1]"))

vtParcels.join <- full_join(vtParcels,
                            counties,
                            by = c("TNAME" = "Town"))



# remove parcels that are 0 acres, normalize price per acre, remove parcels that are 0$/acre
vtParcels.filter <- vtParcels.join %>% 
  filter(ACRESGL > 0) %>% 
  mutate(lp.acre = (REAL_FLV/ACRESGL)) %>% 
  filter(lp.acre > 0)

vtParcels.clean <- select(vtParcels.filter,
                      c("town" = "TNAME",
                        "county" = "County",
                        "pop" = "Pop",
                        "address" = "ADDRGL1",
                        "city" = "CITYGL",
                        "zip" = "ZIPGL",
                        "propdescr" = "DESCPROP",
                        "CAT" = "CAT",
                        "rescode" =  "RESCODE",
                        "tot.acres" = "ACRESGL",
                        "re.val" = "REAL_FLV",
                        "nonres.val" =  "NRES_FLV",
                        "land.val" = "LAND_LV",
                        "lv.acre" = "lp.acre",
                      ))

#simplify parcel categories
vtParcels.clean <- vtParcels.clean %>% 
  mutate(category = ifelse(CAT %in% "Residential-1" | CAT %in% "Residential-2",
                           "Residential",
                           ifelse(CAT %in% "Woodland",
                                  "Woodland",
                                  ifelse(CAT %in% "Seasonal-1" |CAT %in% "Seasonal-2",
                                         "Seasonal",
                                         ifelse(CAT %in% "Farm",
                                                "Farm",
                                                ifelse(CAT %in% "Mobile Home/la" | CAT %in% "Mobile Home/un",
                                                       "Mobile Home",
                                                       ifelse(CAT %in% "Commercial" | CAT %in% "Commercial Apt",
                                                              "Commercial",
                                                              ifelse(CAT %in% "Industrial",
                                                                     "Industrial",
                                                                     ifelse(CAT %in% "Utilities Elec" | CAT %in% "Utilities Other",
                                                                            "Utilities",
                                                                            ifelse(CAT %in% "Miscellaneous" | CAT %in% "Other",
                                                                                   "Miscellaneous",
                                                                                   "Other"
                                                                            )
                                                                     )
                                                              )
                                                       )
                                                )
                                         )
                                  )
                                  
                           )
                           
  )
  )

# export cleaned file
write.csv(vtParcels.clean, 
          "~/Desktop/MATH0216/final/VTparcels/parcelsFinal.csv", 
          row.names = FALSE)

# read back in
vtParcels <- read_csv("parcelsFinal.csv")

unique(vtParcels.clean$CAT)

# remove outlier
vtParcels.clean.1 <- vtParcels.clean %>% 
  filter(lv.acre > 5 & lv.acre < 10000000)

vtParcels.no.outliers <- vtParcels.clean %>% 
  filter(lv.acre > 5 & lv.acre < 1150000)

vtParcels.clean.3 <- vtParcels.clean %>% 
  filter(lv.acre > 5 & lv.acre < 100000)

vtParcels.no.outliers %>% 
  ggplot(aes(x = re.val,
             y = tot.acres)) +
  geom_point(aes(color = county)) +
  scale_x_continuous(trans = 'log10') +
  scale_y_continuous(trans = 'log10')

vtParcels.no.outliers %>% 
  ggplot() +
  geom_histogram(aes(x = lv.acre),
                 color = "gray",
                 bins = 50) + 
  scale_x_continuous(trans = 'log10')
             
### geo data --------

# load data
vtCounties <- geojson_read("vtCounties_nojoin.geojson",
                           what = "sp")

vtTowns <- geojson_read("vtTowns_nojoin.geojson",
                        what = "sp")

### join aggregated parcel values to town level geojson
# summarize
vtParcels.town <- vtParcels %>% 
  group_by(town) %>% 
  summarise(median.val = median(lv.acre)) 

# join to geojson
vtTowns@data <- left_join(vtTowns@data,
                          vtParcels.town,
                          by = c("TOWNNAMEMC" = "town"))

vtTowns@data <- vtTowns@data %>% 
  mutate_at(vars(starts_with("median")), funs(round(., 2)))

# export to folder
writeOGR(vtTowns, 
         dsn="/Users/derrickburt/Desktop/MATH0216/final/VTparcels/vtTowns.geojson", 
         layer="vtTowns", 
         driver="GeoJSON")

### join aggregated parcel values to county level geojson
# summarize
vtParcels.cty <- vtParcels %>% 
  group_by(county) %>% 
  summarise(median.val = median(lv.acre)) 

# clean franklin county name
vtCounties$name <- str_replace_all(vtCounties$name,
                                   "Franklin County, VT",
                                   "Franklin")

# join to geojson
vtCounties@data <- left_join(vtCounties@data,
                          vtParcels.cty,
                          by = c("name" = "county"))

vtCounties@data <- vtCounties@data %>% 
  mutate_at(vars(starts_with("median")), funs(round(., 2)))

# export to folder
writeOGR(vtCounties, 
         dsn="/Users/derrickburt/Desktop/MATH0216/final/VTparcels/vtCounties.geojson", 
         layer="vtTowns", 
         driver="GeoJSON")
