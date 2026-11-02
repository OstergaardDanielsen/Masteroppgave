library(httr2)
library(jsonlite)
library(httr)
library(tidyverse)

#Prisen er opprinnelig i EURO, med vekslingskurs fra Norges Bank på samme dag. 

req <- GET("https://www.hvakosterstrommen.no/api/v1/prices/2026/10-06_NO1.json")

stop_for_status(req)

prices <- fromJSON(content(req, as = "text", encoding = "UTF-8"))
head(prices)

daily_average <- mean(prices$NOK_per_kWh)




get_daily_average <- function(date, zone){
  reqchar <- sprintf("https://www.hvakosterstrommen.no/api/v1/prices/%d/%02d-%02d_%s.json", year(date), month(date), day(date), zone)
  
  req <- GET(reqchar)

  stop_for_status(req)

  prices <- fromJSON(content(req, as  = "text", encoding = "UTF-8"))

  daily_average <- mean(prices$NOK_per_kWh)

  daily_average
}


daily_average <- get_daily_average(01,01,2022, "NO1")


# the API uses ISO8601 formatting, so readr will automatically recognize it. 

# One approach is to try fetching the data for up to 31 days each months, then just append the months that worked, and rule out days with 
# an error code that suggest the date didn't exist. Although, there ought to be a better way. 


# Use lubridate days_in_month. 

dates <- seq(ymd("2021-12-01"), today(), by = "day")


price_frame <- tibble(
    Dates = dates,
    NO1 = map(dates, get_daily_average, "NO1"),
    NO2 = map(dates, get_daily_average, "NO2"),
    NO3 = map(dates, get_daily_average, "NO3"),
    NO4 = map(dates, get_daily_average, "NO4"),
    NO5 = map(dates, get_daily_average, "NO5")
)

price_frame$Dates = dates

#Saved the price_frame object as it took like 10 minutes to run
saveRDS(price_frame, ".rds")


price_frame <- price_frame |> mutate(
    month = floor_date(Dates, "month"),
    year = floor_date(Dates, "year")
)


monthly_prices <- price_frame |> group_by()
    