library(redcapAPI)
library(REDCapR)

setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/ASTMH 2017 abstracts/priyanka- fogarty nd")

Redcap.token <- readLines("api.token.txt") # Read API token from folder
REDcap.URL  <- 'https://redcap.stanford.edu/api/'
rcon <- redcapConnection(url=REDcap.URL, token=Redcap.token)
chikv_nd <- redcap_read(redcap_uri  = REDcap.URL, token = Redcap.token, batch_size = 200)$data#export data from redcap to R (must be connected via cisco VPN)
