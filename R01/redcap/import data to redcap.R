library(redcapAPI)
# Your REDCap issued token, I read mine from a text file
Redcap.token <- readLines("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long/Redcap.token.txt") # Read API token from folder
# REDCAp site API-URL, will most likely be the REDCap site where you normally login + api
REDcap.URL  <- 'https://redcap.stanford.edu/api/'
rcon <- redcapConnection(url=REDcap.URL, token=Redcap.token)


## S3 method for class 'redcapApiConnection'
importRecords(rcon, df, overwriteBehavior = "normal", returnContent = c("count", "ids", "nothing"), 
              returnData = FALSE, logfile = "", proj = NULL,
              batch.size = -1)

