#install.packages("REDCapR")
library(REDCapR)
library(RCurl)
library(dplyr)
library(redcapAPI)
library(rJava) 
library(WriteXLS) # Writing Excel files
library(readxl) # Excel file reading
library(xlsx) # Writing Excel files

setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/greneda chikv")
Redcap.token <- readLines("redcap.token.chikvnd.txt") # Read API token from folder
REDcap.URL  <- 'https://redcap.stanford.edu/api/'
rcon <- redcapConnection(url=REDcap.URL, token=Redcap.token)

#export data from redcap to R (must be connected via cisco VPN)
chikvnd <- redcap_read(
  redcap_uri  = REDcap.URL,
  token       = Redcap.token
)$data

save(chikvnd,file=paste("chikvnd",Sys.Date(),sep = "_"))
load("chikvnd_2017-05-26")
glimpse("chikvnd_2017-05-26")
n_distinct(chikvnd$participant_id, na.rm = FALSE)

participant_id<-c("GB0048", "GB0049", "GB0082", "GB0083", "GB0088", "GA0033", "GA0034", "GA0035", "GO0051", "SD0044", "SD0045", "SG0063", "SG0064", "GB0060", "GB0066", "GB0077", "GB0078", "GB0079", "GB0080", "GB0081", "GO0030", "GO0035", "GO0036", "SA0038", "SG0075", "SG0077", "SG0086", "SG0087", "SG0089", "SG0090", "SG0091", "TI0050", "TI0051")
nikita_upload<-as.data.frame(participant_id)
in_redcap <- chikvnd[match(nikita_upload$participant_id, chikvnd$participant_id, nomatch=0),]

#install.packages("dtplyr")
library(dtplyr)
fwrite(in_redcap, "chikv_nd_nikita_upload_in_redcap_may26_2017.xls.csv")



## S3 method for class 'redcapApiConnection' THis method will require reformatting all the dates to meet redcap standards.
importRecords(rcon, chikvnd_height, overwriteBehavior = "normal", returnContent = c("count", "ids", "nothing"), 
              returnData = FALSE, logfile = "", proj = NULL,
              batch.size = -1)