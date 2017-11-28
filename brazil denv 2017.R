library(dplyr)
library(plyr)
library(redcapAPI)
library(REDCapR)
library(ggplot2)

# get data -----------------------------------------------------------------
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/brazil hospital surveillance denv")
Redcap.token <- readLines("Redcap.token.txt") # Read API token from folder
REDcap.URL  <- 'https://redcap.stanford.edu/api/'
rcon <- redcapConnection(url=REDcap.URL, token=Redcap.token)

#export data from redcap to R (must be connected via cisco VPN)
df <- redcap_read(redcap_uri  = REDcap.URL, token = Redcap.token, batch_size = 300)$data
library(beepr)
beep(sound=4)

currentDate <- Sys.Date() 
FileName <- paste("df.backup",currentDate,".rda",sep=" ") 
save(df,file=FileName)
load(FileName)

summary(df)

