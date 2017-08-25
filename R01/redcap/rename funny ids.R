#install.packages("REDCapR")
library(REDCapR)
library(RCurl)
library(dplyr)
library(redcapAPI)
library(rJava) 
library(WriteXLS) # Writing Excel files
library(readxl) # Excel file reading
library(xlsx) # Writing Excel files

setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long")
Redcap.token <- readLines("Redcap.token.R01.txt") # Read API token from folder
#Redcap.token <- "82F1C4081DEF007B8D4DE287426046E1"
REDcap.URL  <- 'https://redcap.stanford.edu/api/'
rcon <- redcapConnection(url=REDcap.URL, token=Redcap.token)

#export data from redcap to R (must be connected via cisco VPN)
#R01_lab_results <- redcap_read(  redcap_uri  = REDcap.URL,  token       = Redcap.token,  batch_size = 300)$data
load("R01_lab_results.backup.rda")
R01_lab_results<-R01_lab_results.backup
funny_ids<-c("CM0405", "CM0406", "CM0407", "CM0408", "CM0409", "CM0410", "CM0411", "CM0413", "CM0414", "CM0415", "CM0416", "CM0417", "CM0418", "CM0419", "CM0420", "CM0421", "CM0422", "CMA0406", "CMA0407", "CMA0408", "CMA0409", "CMA0410", "CMA0411", "CMA0413", "CMA0414", "CMA0415", "CMA0416", "CMA0417", "CMA0418", "CMA0419", "CMA0420", "CMA0421", "CMA0422", "CMB0406", "CMB0406", "CMB0406", "CMB0407", "CMB0407", "CMB0407", "CMB0408", "CMB0408", "CMB0408", "CMB0409", "CMB0409", "CMB0409", "CMB0410", "CMB0410", "CMB0410", "CMB0411", "CMB0411", "CMB0411", "CMB0413", "CMB0413", "CMB0413", "CMB0414", "CMB0414", "CMB0414", "CMB0415", "CMB0415", "CMB0415", "CMB0416", "CMB0416", "CMB0416", "CMB0417", "CMB0417", "CMB0417", "CMB0418", "CMB0418", "CMB0418", "CMB0419", "CMB0419", "CMB0419", "CMB0420", "CMB0420", "CMB0420", "CMB0421", "CMB0421", "CMB0421", "CMB0422", "CMB0422", "CMB0422", "KD0005003", "KD0005003", "KD0008003", "KD0008003", "KD0008004", "KD0008004", "KD0009003", "KD0009003", "KD0009004", "KD0009004", "KD0011003", "KD0011003", "KD0011004", "KD0011004", "KD0048003", "KD0048003", "KD0048004", "KD0048004", "KD0049003", "KD0049003", "KD0049004", "KD0049004", "KD0065004", "KD0065004", "KD0076003", "KD0076003", "M0102", "M0109", "M0165", "M0172", "M0233", "M0260", "M0305", "M0363", "M0378", "M0380", "M0384", "M0421", "M0425", "M0435", "M0437", "M0450", "M0463", "M0468", "M0490", "M0494", "M0516", "M0523", "M0525", "M0533", "M0557", "M0566", "M0583", "M0587", "M0602", "M0626", "M0639", "M0649", "M0673", "M0674", "M0684", "M0687", "M0690", "M0697", "M0698", "M0699", "M0730", "M0774", "M0784", "M0828", "M0842", "M0872", "M0884", "M0895", "M0924", "CMBA0408", "CMBA0407", "CMBA0406", "CMBA0409", "CMBA0410", "CMBA0411", "CMBA0413", "CMBA0414", "CMBA0421", "CMBA0422", "CMBA0419", "CMBA0416", "CMBA0415", "CMBA0418", "CMBA0417", "CMBA0420")
funny_ids<-subset(R01_lab_results, person_id %in% funny_ids)   
funny_ids$funny_ids<-funny_ids$person_id
funny_ids$person_id <- gsub("CMA", "CF", funny_ids$person_id)
funny_ids$person_id <- gsub("CMB", "CF", funny_ids$person_id)
funny_ids$person_id <- gsub("CMBA", "CF", funny_ids$person_id)
funny_ids$person_id <- gsub("CM", "CF", funny_ids$person_id)
funny_ids$person_id <- gsub("KD", "KC", funny_ids$person_id)
funny_ids$person_id <- gsub("M0", "MF0", funny_ids$person_id)
funny_ids<-funny_ids[ , grepl( "aliquot_id|person_id|funny_ids|redcap_event_name|name|gender|age" , names( funny_ids ) ) ]
funny_ids<-funny_ids[ , !grepl( "name_tech|gender|age_group|village|interviewer|stage" , names( funny_ids ) ) ]

library(dplyr)
funny_ids<-funny_ids %>%
  select(funny_ids, everything())
funny_ids <-funny_ids[!sapply(funny_ids, function (x) all(is.na(x) | x == ""| x == "NA"))]
#export to csv
f <- "funny_ids.csv"
write.csv(as.data.frame(funny_ids), f )

#match new non-funny id's to SOP ids in redcap database to look for matches
  sop_id<-subset(R01_lab_results, person_id %in% funny_ids$person_id)   
  sop_id<-sop_id[ , grepl( "aliquot_id|person_id|funny_ids|redcap_event_name|name|gender|age" , names(sop_id) ) ]
  sop_id<-sop_id[ , !grepl( "name_tech|gender|age_group|village|interviewer|stage" , names(sop_id) ) ]
  sop_id <-sop_id[!sapply(sop_id, function (x) all(is.na(x) | x == ""| x == "NA"))]
  
#merge SOP and funny id's
  funny_ids_merge<-merge(funny_ids,  sop_id, all = TRUE)
  funny_ids_merge_all<-merge(funny_ids, sop_id,  by= c("person_id"), all = TRUE,suffixes = c(".funny_id",".SOP_id"))
  funny_ids_merge<-merge(funny_ids, sop_id,  by= c("person_id", "redcap_event_name"), all = TRUE,suffixes = c(".funny_id",".SOP_id"))
  
#export to csv
  f <- "funny_ids_merged with redcap matching id's.csv"
  write.csv(as.data.frame(funny_ids_merge), f )
#export to csv
  f <- "funny_ids_merged with redcap matching id's_all.csv"
  write.csv(as.data.frame(funny_ids_merge_all), f )
  