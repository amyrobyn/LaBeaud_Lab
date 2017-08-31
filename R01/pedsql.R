#U24 participants
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
#R01_lab_results.backup<-R01_lab_results
#save(R01_lab_results.backup,file="R01_lab_results.backup.rda")
load("R01_lab_results.backup.rda")
R01_lab_results<-R01_lab_results.backup

pedsql<- R01_lab_results[, grepl("person_id|redcap_event_name|pedsql", names(R01_lab_results))]
#remove missing
  pedsql[pedsql=="99" ] <- NA
  pedsql[pedsql=="98" ] <- NA
#reverse scoring: Step 1: Transform Score.
  #Items are reversed scored and linearly transformed to a 0-100 scale as
  #follows: 0=100, 1=75, 2=50, 3=25, 4=0.
  
    pedsql[pedsql=="0" ] <- 100
    pedsql[pedsql=="1" ] <- 75
    pedsql[pedsql=="2" ] <- 50
    pedsql[pedsql=="3" ] <- 25
    pedsql[pedsql=="4" ] <- 0

#children
    #select child vars
      pedsql_child<- pedsql[, grepl("person_id|redcap_event_name|pedsql", names(pedsql))]
      pedsql_child<- pedsql[, !grepl("parent", names(pedsql))]
  #physical vars
  #Mean score = Sum of the items over the number of items answered
    pedsql_child_physical<- pedsql_child[, grepl("person_id|redcap_event_name|walk|run|play|lift|work", names(pedsql_child))]
    pedsql_child_physical<- pedsql_child_physical[, !grepl("school", names(pedsql_child_physical))]
    pedsql_child_physical$not_missing<-rowSums(!is.na(pedsql_child_physical))
    pedsql_child_physical$not_missing<-pedsql_child_physical$not_missing-2
    table(pedsql_child_physical$not_missing)
    pedsql_child_physical$pedsql_physical_sum<-rowSums(pedsql_child_physical[, grep("walk|run|play|lift|work", names(pedsql_child_physical))], na.rm = TRUE)
    pedsql_child_physical$pedsql_physical_mean<-round(pedsql_child_physical$pedsql_physical_sum/pedsql_child_physical$not_missing)
    pedsql_child_physical<- within(pedsql_child_physical, pedsql_physical_mean[pedsql_child_physical$not_missing<2.5] <- NA)
    
    table(pedsql_child_physical$pedsql_physical_mean, pedsql_child_physical$not_missing)
    hist(pedsql_child_physical$pedsql_physical_mean, breaks=110)

    #emotional vars
    #Mean score = Sum of the items over the number of items answered
      pedsql_child_emotional<- pedsql_child[, grepl("person_id|redcap_event_name|agreement|rejected|bullied", names(pedsql_child))]
      pedsql_child_emotional$not_missing<-rowSums(!is.na(pedsql_child_emotional))
      pedsql_child_emotional$not_missing<-pedsql_child_emotional$not_missing-2
      table(pedsql_child_emotional$not_missing)
      pedsql_child_emotional$pedsql_emotional_sum<-rowSums(pedsql_child_emotional[, grep("agreement|rejected|bullied", names(pedsql_child_emotional))], na.rm = TRUE)
      pedsql_child_emotional$pedsql_emotional_mean<-round(pedsql_child_emotional$pedsql_emotional_sum/pedsql_child_emotional$not_missing)
      pedsql_child_emotional<- within(pedsql_child_emotional, pedsql_emotional_mean[pedsql_child_emotional$not_missing<1.5] <- NA)
      
      table(pedsql_child_emotional$pedsql_emotional_mean, pedsql_child_emotional$not_missing)
      hist(pedsql_child_emotional$pedsql_emotional_mean, breaks=110)
    
    #school vars
  #Mean score = Sum of the items over the number of items answered
    pedsql_child$pedsql_school_sum<-rowSums(pedsql_child[, grep("understand|forget|schoolhomework", names(pedsql_child))], na.rm = TRUE)
    table(pedsql_child$pedsql_social_sum, exclude=NULL)
    
#parents
  #select partent variables from pedsql
    pedsql_parent<- pedsql[, grepl("person_id|redcap_event_name|_parent", names(pedsql))]
