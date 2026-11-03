library(httr2)
library(jsonlite)
library(httr)
library(tidyverse)



# ------------------- Fetch prices from Hvakosterstrømmen -------------------

#Prisen er opprinnelig i EURO, med vekslingskurs fra Norges Bank på samme dag. 

req <- GET("https://www.hvakosterstrommen.no/api/v1/prices/2026/10-06_NO1.json")

stop_for_status(req)

prices <- fromJSON(content(req, as = "text", encoding = "UTF-8"))
head(prices)

daily_average <- mean(prices$NOK_per_kWh)




get_daily_average <- function(date, zone){
  url <- sprintf("https://www.hvakosterstrommen.no/api/v1/prices/%d/%02d-%02d_%s.json", year(date), month(date), day(date), zone)
  
  prices <- request(url) |>
    req_perform() |>
    resp_body_json(simplifyVector = TRUE)

  mean(prices$NOK_per_kwh)
}

today <- today()
daily_average <- get_daily_average(today, "NO1")


# the API uses ISO8601 formatting, so readr will automatically recognize it. 

# One approach is to try fetching the data for up to 31 days each months, then just append the months that worked, and rule out days with 
# an error code that suggest the date didn't exist. Although, there ought to be a better way. 


# Use lubridate days_in_month. 

dates <- seq(ymd("2021-12-01"), today(), by = "day")

# This takes approximately 20 minutes, instead load the rds file
price_frame <- tibble(
    Dates = dates,
    NO1 = map_dbl(dates, get_daily_average, "NO1"),
    NO2 = map_dbl(dates, get_daily_average, "NO2"),
    NO3 = map_dbl(dates, get_daily_average, "NO3"),
    NO4 = map_dbl(dates, get_daily_average, "NO4"),
    NO5 = map_dbl(dates, get_daily_average, "NO5")
)

#Save the price_frame object as it took like 10 minutes to run
saveRDS(price_frame, "price_frame.rds")

# --------------------------- Make monthly averages ----------------------------


price_frame <- readr::read_rds("price_frame.rds")

price_frame <- price_frame |> mutate(
    month = month(Dates),
    year = year(Dates)
)


monthly_prices_kr <- price_frame |> 
  group_by(year, month) |>
  summarize(across(NO1:NO5, mean), .groups = "drop")


#To compare against nordpool data (from slipper),
#We add NVA, and convert from kr to øre. 

monthly_prices_øre_mva <- monthly_prices_øre |> mutate(
    across(c(NO1:NO3, NO5), \(x) x*125),
    NO4 = NO4*100
)


# I used Claude to scrape nordnet's montly price data from slipper's website
# Slipper's data is in øre and includes the mva, except for NO4. 
slipper_data <- read.csv("slipper_monthly_prices.csv", header = TRUE, sep = ",")





# --------------------------- Find grid tariffs -------------------------

#https://www.nve.no/reguleringsmyndigheten/publikasjoner-og-data/statistikk/nettleiestatistikk/
# Here, you can find the grid tariffs for every region. 
# We should probably focus on some key cities in order to avoid too much work. 