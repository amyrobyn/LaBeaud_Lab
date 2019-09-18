setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long")
Redcap.token <- readLines("Redcap.token.R01.txt") # Read API token from folder
REDcap.URL  <- 'https://redcap.stanford.edu/api/'
rcon <- redcapConnection(url=REDcap.URL, token=Redcap.token)

#install.packages("redcapAPI")
library(redcapAPI)

aic_villages_missing_lat_and_long <- read_csv("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/R01CHIKVDENVProject_DATA_2018-07-03_1200-aic villages missing lat and long.csv")
table(aic_villages_missing_lat_and_long$aic_village_gps_data_type)

importRecords(rcon, aic_villages_missing_lat_and_long, overwriteBehavior = "normal", returnContent =  "ids", returnData = FALSE, logfile = "", batch.size = 100)
  