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
    library(beepr)
    beep(sound=4)  #beep when finishes.


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
  
  #save to csv those that i am going to change to 0/1
    vector_climate_01<-vector_climate[ , grepl( "date_collected|redcap|firewood_use_in_the_house|insecticide_sprayed|mosquito_coil_burn|bed_net_present|eaves_open|rooms_with_ceilings|bushes_around_the_house_prokopack|tall_grass_around_the_house_prokopack" , names(vector_climate) ) ]
    vector_climate_01<-vector_climate_01[!(is.na(vector_climate_01$firewood_use_in_the_house))|!(is.na(vector_climate_01$insecticide_sprayed))|!(is.na(vector_climate_01$mosquito_coil_burn))|!(is.na(vector_climate_01$bed_net_present))|!(is.na(vector_climate_01$eaves_open))|!(is.na(vector_climate_01$rooms_with_ceilings))|!(is.na(vector_climate_01$bushes_around_the_house_prokopack))|!(is.na(vector_climate_01$tall_grass_around_the_house_prokopack)),]

    View(vector_climate_01)
    write.csv(as.data.frame(vector_climate_01), "vector_climate_01.csv", na="", row.names = F)
    