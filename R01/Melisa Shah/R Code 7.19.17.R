#install.packages(c("REDCapR", "RCurl", "dplyr", 'redcapAPI', 'rJava', 'WriteXLS', 'readxl', 'xlsx'))

library(REDCapR)
library(RCurl)
library(dplyr)
library(redcapAPI)
library(rJava) 
library(WriteXLS) # Writing Excel files
library(readxl) # Excel file reading
library(xlsx) # Writing Excel files

setwd("/Users/melisashah/Documents/Malaria Stanford/Rdata")
Redcap.token <- readLines("Redcap.token.R01.txt") # Read API token from folder
REDcap.URL <- 'https://redcap.stanford.edu/api/'
rcon <- redcapConnection(url=REDcap.URL, token=Redcap.token)

#export data from redcap to R (must be connected via cisco VPN)
R01_lab_results <- redcap_read(
  redcap_uri  = REDcap.URL,
  token       = Redcap.token,
  batch_size = 300
)$data

#creating the cohort and village and visit variables for each visit. 
R01_lab_results$id_cohort<-substr(R01_lab_results$person_id, 2, 2)
R01_lab_results$id_city<-substr(R01_lab_results$person_id, 1, 1)

# subset of the variables
aic<-R01_lab_results[which(R01_lab_results$id_cohort=="F"), c("person_id", "redcap_event_name","symptoms", "symptoms_aic", "id_cohort", "id_city")]

save(aic, file="aic.rda")

