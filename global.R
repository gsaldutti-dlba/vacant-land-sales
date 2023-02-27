library(shiny)
library(leaflet)
library(dplyr)
library(ggplot2)


prop_sales_prepped <- readRDS(gzcon(url("https://github.com/gsaldutti-dlba/vacant-land-sales/blob/main/appData/prepped_sales.RDS?raw=true"))) %>%
  sf::st_as_sf() %>%
  filter(is.na(multi_with_structure))

neighborhoods <- sfarrow::st_read_parquet(gzcon(url("https://github.com/gsaldutti-dlba/vacant-land-sales/blob/main/appData/nbrhoods.par?raw=true")))
neighborhood_list <- neighborhoods$nhood_name

prop_sales_prepped[!is.na(prop_sales_prepped$multi_with_structure),]


