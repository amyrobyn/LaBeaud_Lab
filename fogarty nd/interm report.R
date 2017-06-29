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
n_distinct(chikvnd$participant_id, chikvnd$redcap_event_name, na.rm = FALSE)

n_occur <- data.frame(table(chikvnd$participant_id))
dup<-chikvnd[chikvnd$participant_id %in% n_occur$Var1[n_occur$Freq > 1],]

table(chikvnd$sex, exclude=NULL)