library(httr2)
library(jsonlite)
library(httr)
library(tidyverse)

#Fetching energy consumption data (price area)
response <- request("api.elhub.no/energy-data/v0/price-areas?") |>
  req_perform()