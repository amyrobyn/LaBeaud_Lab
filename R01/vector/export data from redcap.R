library(redcapAPI)
library(REDCapR)
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/vector")
Redcap.token <- readLines("api.key.txt") # Read API token from folder
REDcap.URL  <- 'https://redcap.stanford.edu/api/'
rcon <- redcapConnection(url=REDcap.URL, token=Redcap.token)

#export data from redcap to R (must be connected via cisco VPN)
vector <- redcap_read(redcap_uri  = REDcap.URL, token = Redcap.token, batch_size = 300)$data
gps<-vector[ , grepl( "house_id|latit|long|altit|acuracy|repeat" , names(vector) ) ]
