library(shiny)
library(leaflet)
library(dplyr)
library(ggplot2)


prop_sales_prepped <- readRDS(here::here('data/appData/prepped_sales.RDS')) %>%
  sf::st_as_sf() %>%
  filter(is.na(multi_with_structure))

neighborhoods <- sfarrow::st_read_parquet(here::here("data/appData/nbrhoods.par"))
neighborhood_list <- neighborhoods$nhood_name

prop_sales_prepped[!is.na(prop_sales_prepped$multi_with_structure),]


