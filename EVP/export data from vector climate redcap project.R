library(plyr)
library(dplyr)
library(tidyr)
library(zoo)
library(lubridate)
library(stringr)
library(redcapAPI)
library(REDCapR)
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/vector")

#download data from redcap ## S3 method for class 'redcapApiConnection' THis method will require reformatting all the dates to meet redcap standards.
Redcap.token <- readLines("api.key.txt") # Read API token from folder
REDcap.URL  <- 'https://redcap.stanford.edu/api/'
rcon <- redcapConnection(url=REDcap.URL, token=Redcap.token)
  vector_climate <- redcap_read(redcap_uri  = REDcap.URL, token = Redcap.token, batch_size = 200)$data#export data from redcap to R (must be connected via cisco VPN)
  #beep when finishes.
    library(beepr)
    beep(sound=4)

#save backup from today
  currentDate <- Sys.Date() 
  FileName <- paste("vector_climate",currentDate,".rda",sep=" ") 
  save(vector_climate,file=FileName)
#load most recent backup
  load(FileName)
#describe data.  
    fivenum(vector_climate)
  library(Hmisc)
    describe(vector_climate) 
  library(pastecs)
    stat.desc(vector_climate) 
  library(psych)
    describe(vector_climate)
    describe.by(vector_climate,vector_climate$study_site )
  
  