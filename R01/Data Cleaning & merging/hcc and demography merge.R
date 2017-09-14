#install.packages(c("REDCapR", "mlr"))
#install.packages(c("dummies"))
library(dplyr)
library(plyr)
library(redcapAPI)
library(REDCapR)

setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long")
Redcap.token <- readLines("Redcap.token.R01.txt") # Read API token from folder
REDcap.URL  <- 'https://redcap.stanford.edu/api/'
rcon <- redcapConnection(url=REDcap.URL, token=Redcap.token)

#export data from redcap to R (must be connected via cisco VPN)
#R01_lab_results <- redcap_read(redcap_uri  = REDcap.URL, token = Redcap.token, batch_size = 300)$data
#save(R01_lab_results,file="R01_lab_results.backup.rda")
load("R01_lab_results.backup.rda")
#look for discordant gender
  table(R01_lab_results$gender)
  table(R01_lab_results$dem_child_gender)
  table(R01_lab_results$gender, R01_lab_results$dem_child_gender, exclude = NULL)
  R01_lab_results$gender_discordant<-ifelse(R01_lab_results$gender == R01_lab_results$dem_child_gender, 1, 0)
  table(R01_lab_results$gender_discordant)
#look for discordant gender
  table(R01_lab_results$result_microscopy_malaria_kenya, R01_lab_results$redcap_event_name, exclude = NULL)
  
  