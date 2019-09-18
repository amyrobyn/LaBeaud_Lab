rm(list=ls()) #remove previous variable assignments

#devtools::install_github("nutterb/redcapAPI") # install API from here instead of inside R
# install VPN network if not set up: https://uit.stanford.edu/service/vpn
# connect to VPN network before starting this code

# install libraries
library(redcapAPI)
library(REDCapR)
library(RCurl)
library(plyr)

# make connection to REDCap
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/vector") # get redcap token from folder
REDcap.URL  <- 'https://redcap.stanford.edu/api/'
clim.vec.token <- readLines("api.key.txt") # Read API token from folder

# import all data frome redcap
vectorData <- redcap_read(redcap_uri  = REDcap.URL, token = clim.vec.token, batch_size = 300)$data
rcon <- redcapConnection(url=REDcap.URL, token=clim.vec.token)