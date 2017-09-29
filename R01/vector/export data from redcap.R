library(redcapAPI)
library(REDCapR)
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/vector")
Redcap.token <- readLines("api.key.txt") # Read API token from folder
REDcap.URL  <- 'https://redcap.stanford.edu/api/'
rcon <- redcapConnection(url=REDcap.URL, token=Redcap.token)

#export data from redcap to R (must be connected via cisco VPN)
#  vector <- redcap_read(redcap_uri  = REDcap.URL, token = Redcap.token, batch_size = 2)$data
#save(vector,file="vector.rda")
load(file="vector.rda")

  gps<-vector[ , grepl( "house_id|latit|long|altit|acuracy|repeat" , names(vector) ) ]
  larva<-vector[ , grepl( "house_id|larva|repeat" , names(vector) ) ]
  bg<-vector[ , grepl( "house_id|bg|repeat" , names(vector) ) ]
  ovi<-vector[ , grepl( "house_id|ovi|repeat" , names(vector) ) ]
  hlc<-vector[ , grepl( "house_id|hlc|repeat" , names(vector) ) ]
  
#export to csv
  #f <- "gps_vector_house.csv"
  #write.csv(as.data.frame(gps), f , na="")
