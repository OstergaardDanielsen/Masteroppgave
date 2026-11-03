library(httr2)
library(jsonlite)
library(tidyverse)


# Hent ut inntekt fra fylke, og map til prissoner (fra SSB)

read_csv("Inntekt_fylker_desiler.csv", delim = ";")













































#median-inntekt, husholdninger, ulike typer 2005-2024, Nasjonalt
url06946 <- "https://data.ssb.no/api/pxwebapi/v2/tables/06946/data"

data06946 <- request(url06946) |>
  req_perform() |>
  resp_body_json(simplifyVector = TRUE)


# Inntekt etter desiler, 2005-2024, husholdninger. Har alle fylker og kommuner. 
url_12558 <-  "https://data.ssb.no/api/pxwebapi/v2/tables/12558/data?lang=no&valueCodes[ContentsCode]=AndelHush,VerdiDesil,AntHush&valueCodes[InntektSkatt]=00,00S&valueCodes[Desiler]=01,02,03,04,05,06,07,08&valueCodes[Tid]=2005,2006,2007,2008,2009,2010,2011,2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022,2023,2024&codelist[Region]=vs_Landet"

data_12558 <- request(url_12558) |>
  req_perform() |>
  resp_body_json(simplifyVector = TRUE)
