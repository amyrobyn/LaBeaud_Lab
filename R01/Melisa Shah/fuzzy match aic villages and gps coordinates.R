#install.packages(c("REDCapR", "mlr"))
#install.packages(c("dummies"))
library(dplyr)
library(plyr)
library(redcapAPI)
library(REDCapR)
#install.packages("fuzzyjoin")
library(fuzzyjoin)

setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long")
Redcap.token <- readLines("Redcap.token.R01.txt") # Read API token from folder
REDcap.URL  <- 'https://redcap.stanford.edu/api/'
rcon <- redcapConnection(url=REDcap.URL, token=Redcap.token)

#export data from redcap to R (must be connected via cisco VPN)
#R01_lab_results <- redcap_read(redcap_uri  = REDcap.URL, token = Redcap.token, batch_size = 300)$data
#R01_lab_results.backup<-R01_lab_results
#save(R01_lab_results.backup,file="R01_lab_results.backup.rda")
#import redcap data
  load("R01_lab_results.backup.rda")
  R01_lab_results<-R01_lab_results.backup
  R01_lab_results<- R01_lab_results[which(!is.na(R01_lab_results$redcap_event_name))  , ]
  R01_lab_results_village_aic<-R01_lab_results[which(R01_lab_results$village_aic !=""), c("person_id", "redcap_event_name", "village_aic")]

#import all the aic gps data we have
  aic_gps_1<-read.csv("C:/Users/amykr/Box Sync/DENV CHIKV project DEIDENTIFIED/gps/village gps points/village gps points.csv")
  colnames(aic_gps_1)[1] <- "village_aic"
  colnames(aic_gps_1)[2] <- "aic_village_gps_longitude"
  colnames(aic_gps_1)[3] <- "aic_village_gps_lattitude"
  
  aic_gps_2<-read.csv("C:/Users/amykr/Box Sync/DENV CHIKV project DEIDENTIFIED/gps/village gps points/aic village points-R01CHIKVDENVProject_DATA_2017-08-29_1106.csv")
  aic_gps_2<-aic_gps_2[which(aic_gps_2$aic_village_gps_lattitude !="" | aic_gps_2$aic_village_gps_longitude!="" ), ]
  aic_gps<-rbind.fill(aic_gps_1, aic_gps_2)

  aic_gps<-aic_gps[, c("village_aic", "aic_village_gps_altitude", "aic_village_gps_longitude", "aic_village_gps_lattitude")]
#merge redcap data and aic gps data
  aic_village_merge<-stringdist_full_join(aic_gps, R01_lab_results_village_aic, by="village_aic", distance_col = "distance", ignore_case = TRUE)
#export to csv
setwd("C:/Users/amykr/Box Sync/DENV CHIKV project DEIDENTIFIED/gps/village gps points")
f <- "aic_village_merge.csv"
write.csv(as.data.frame(aic_village_merge), f )