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
  R01_lab_results<- R01_lab_results[which(!is.na(R01_lab_results$redcap_event_name))  , ]
  
  R01_lab_results$id_cohort<-substr(R01_lab_results$person_id, 2, 2)
  R01_lab_results$id_city<-substr(R01_lab_results$person_id, 1, 1)
  

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
    pedsql_child_physical$not_missing_child_physical<-rowSums(!is.na(pedsql_child_physical))
    pedsql_child_physical$not_missing_child_physical<-pedsql_child_physical$not_missing_child_physical-2
    table(pedsql_child_physical$not_missing_child_physical)
    pedsql_child_physical$pedsql_child_physical_sum<-rowSums(pedsql_child_physical[, grep("walk|run|play|lift|work", names(pedsql_child_physical))], na.rm = TRUE)
    pedsql_child_physical$pedsql_child_physical_mean<-round(pedsql_child_physical$pedsql_child_physical_sum/pedsql_child_physical$not_missing_child_physical)
    pedsql_child_physical<- within(pedsql_child_physical, pedsql_child_physical_mean[pedsql_child_physical$not_missing_child_physical<2.5] <- NA)
    
    table(pedsql_child_physical$pedsql_child_physical_mean, pedsql_child_physical$not_missing_child_physical)
    hist(pedsql_child_physical$pedsql_child_physical_mean, breaks=110)
#merge back to database
    pedsql_child_physical<-pedsql_child_physical[, grepl("person_id|redcap_event_name|mean|missing|sum", names(pedsql_child_physical))]
    pedsql_merge<-pedsql
    pedsql_merge <- merge(pedsql_child_physical, pedsql_merge,  by=c("person_id", "redcap_event_name"), all = TRUE)
    
#emotional vars
#Mean score = Sum of the items over the number of items answered
    pedsql_child_emotional<- pedsql_child[, grepl("person_id|redcap_event_name|fear|scared|angry|sad", names(pedsql_child))]
    pedsql_child_emotional$not_missing_child_emotional<-rowSums(!is.na(pedsql_child_emotional))
    pedsql_child_emotional$not_missing_child_emotional<-pedsql_child_emotional$not_missing_child_emotional-2
    table(pedsql_child_emotional$not_missing_child_emotional)
    pedsql_child_emotional$pedsql_child_emotional_sum<-rowSums(pedsql_child_emotional[, grep("fear|scared|angry|sad", names(pedsql_child_emotional))], na.rm = TRUE)
    pedsql_child_emotional$pedsql_child_emotional_mean<-round(pedsql_child_emotional$pedsql_child_emotional_sum/pedsql_child_emotional$not_missing_child_emotional)
    pedsql_child_emotional<- within(pedsql_child_emotional, pedsql_child_emotional_mean[pedsql_child_emotional$not_missing_child_emotional<1.5] <- NA)
    
    table(pedsql_child_emotional$pedsql_child_emotional_mean, pedsql_child_emotional$not_missing_child_emotional)
    hist(pedsql_child_emotional$pedsql_child_emotional_mean, breaks=110)
#merge back to database
    pedsql_child_emotional<-pedsql_child_emotional[, grepl("person_id|redcap_event_name|mean|missing|sum", names(pedsql_child_emotional))]
    pedsql_merge <- merge(pedsql_child_emotional, pedsql_merge,  by=c("person_id", "redcap_event_name"), all = TRUE)
    
#social vars
#Mean score = Sum of the items over the number of items answered
    pedsql_child_social<- pedsql_child[, grepl("person_id|redcap_event_name|agreement|rejected|bullied", names(pedsql_child))]
    pedsql_child_social$not_missing_child_social<-rowSums(!is.na(pedsql_child_social))
    pedsql_child_social$not_missing_child_social<-pedsql_child_social$not_missing_child_social-2
    table(pedsql_child_social$not_missing_child_social)
    pedsql_child_social$pedsql_child_social_sum<-rowSums(pedsql_child_social[, grep("agreement|rejected|bullied", names(pedsql_child_social))], na.rm = TRUE)
    pedsql_child_social$pedsql_child_social_mean<-round(pedsql_child_social$pedsql_child_social_sum/pedsql_child_social$not_missing_child_social)
    pedsql_child_social<- within(pedsql_child_social, pedsql_child_social_mean[pedsql_child_social$not_missing_child_social<1.5] <- NA)
    
    table(pedsql_child_social$pedsql_child_social_mean, pedsql_child_social$not_missing_child_social)
    hist(pedsql_child_social$pedsql_child_social_mean, breaks=110)
#merge back to database
    pedsql_child_social<-pedsql_child_social[, grepl("person_id|redcap_event_name|mean|missing|sum", names(pedsql_child_social))]
    pedsql_merge <- merge(pedsql_child_social, pedsql_merge,  by=c("person_id", "redcap_event_name"), all = TRUE)
    
#school vars
#Mean score = Sum of the items over the number of items answered
    pedsql_child_school<- pedsql_child[, grepl("person_id|redcap_event_name|understand|forget|schoolhomework", names(pedsql_child))]
    pedsql_child_school$not_missing_child_school<-rowSums(!is.na(pedsql_child_school))
    pedsql_child_school$not_missing_child_school<-pedsql_child_school$not_missing_child_school-2
    table(pedsql_child_school$not_missing_child_school)
    pedsql_child_school$pedsql_child_school_sum<-rowSums(pedsql_child_school[, grep("understand|forget|schoolhomework", names(pedsql_child_school))], na.rm = TRUE)
    pedsql_child_school$pedsql_child_school_mean<-round(pedsql_child_school$pedsql_child_school_sum/pedsql_child_school$not_missing_child_school)
    pedsql_child_school<- within(pedsql_child_school, pedsql_child_school_mean[pedsql_child_school$not_missing_child_school<1.5] <- NA)
    
    table(pedsql_child_school$pedsql_child_school_mean, pedsql_child_school$not_missing_child_school)
    hist(pedsql_child_school$pedsql_child_school_mean, breaks=110)
#merge back to database
    pedsql_child_school<-pedsql_child_school[, grepl("person_id|redcap_event_name|mean|missing|sum", names(pedsql_child_school))]
    pedsql_merge <- merge(pedsql_child_school, pedsql_merge,  by=c("person_id", "redcap_event_name"), all = TRUE)
    
#parents
#select partent variables from pedsql
pedsql_parent<- pedsql[, grepl("person_id|redcap_event_name|_parent", names(pedsql))]
#physical vars
#Mean score = Sum of the items over the number of items answered
    pedsql_parent_physical<- pedsql_parent[, grepl("person_id|redcap_event_name|walk|run|play|lift|work", names(pedsql_parent))]
    pedsql_parent_physical<- pedsql_parent_physical[, !grepl("school", names(pedsql_parent_physical))]
    pedsql_parent_physical$not_missing_parent_physical<-rowSums(!is.na(pedsql_parent_physical))
    pedsql_parent_physical$not_missing_parent_physical<-pedsql_parent_physical$not_missing_parent_physical-2
    table(pedsql_parent_physical$not_missing_parent_physical)
    pedsql_parent_physical$pedsql_parent_physical_sum<-rowSums(pedsql_parent_physical[, grep("walk|run|play|lift|work", names(pedsql_parent_physical))], na.rm = TRUE)
    pedsql_parent_physical$pedsql_parent_physical_mean<-round(pedsql_parent_physical$pedsql_parent_physical_sum/pedsql_parent_physical$not_missing_parent_physical)
    pedsql_parent_physical<- within(pedsql_parent_physical, pedsql_parent_physical_mean[pedsql_parent_physical$not_missing_parent_physical<2.5] <- NA)
    
    table(pedsql_parent_physical$pedsql_parent_physical_mean, pedsql_parent_physical$not_missing_parent_physical)
    hist(pedsql_parent_physical$pedsql_parent_physical_mean, breaks=110)
#merge back to database
    pedsql_parent_physical<-pedsql_parent_physical[, grepl("person_id|redcap_event_name|mean|missing|sum", names(pedsql_parent_physical))]
    pedsql_merge <- merge(pedsql_parent_physical, pedsql_merge,  by=c("person_id", "redcap_event_name"), all = TRUE)
    
    
#emotional vars
#Mean score = Sum of the items over the number of items answered
    pedsql_parent_emotional<- pedsql_parent[, grepl("person_id|redcap_event_name|fear|scared|angry|sad", names(pedsql_parent))]
    pedsql_parent_emotional$not_missing_parent_emotional<-rowSums(!is.na(pedsql_parent_emotional))
    pedsql_parent_emotional$not_missing_parent_emotional<-pedsql_parent_emotional$not_missing_parent_emotional-2
    table(pedsql_parent_emotional$not_missing_parent_emotional)
    pedsql_parent_emotional$pedsql_parent_emotional_sum<-rowSums(pedsql_parent_emotional[, grep("fear|scared|angry|sad", names(pedsql_parent_emotional))], na.rm = TRUE)
    pedsql_parent_emotional$pedsql_parent_emotional_mean<-round(pedsql_parent_emotional$pedsql_parent_emotional_sum/pedsql_parent_emotional$not_missing_parent_emotional)
    pedsql_parent_emotional<- within(pedsql_parent_emotional, pedsql_parent_emotional_mean[pedsql_parent_emotional$not_missing_parent_emotional<1.5] <- NA)
    
    table(pedsql_parent_emotional$pedsql_parent_emotional_mean, pedsql_parent_emotional$not_missing_parent_emotional)
    hist(pedsql_parent_emotional$pedsql_parent_emotional_mean, breaks=110)
#merge back to database
    pedsql_parent_emotional<-pedsql_parent_emotional[, grepl("person_id|redcap_event_name|mean|missing|sum", names(pedsql_parent_emotional))]
    pedsql_merge <- merge(pedsql_parent_emotional, pedsql_merge,  by=c("person_id", "redcap_event_name"), all = TRUE)
    
#social vars
#Mean score = Sum of the items over the number of items answered
    pedsql_parent_social<- pedsql_parent[, grepl("person_id|redcap_event_name|agreement|rejected|bullied", names(pedsql_parent))]
    pedsql_parent_social$not_missing_parent_social<-rowSums(!is.na(pedsql_parent_social))
    pedsql_parent_social$not_missing_parent_social<-pedsql_parent_social$not_missing_parent_social-2
    table(pedsql_parent_social$not_missing_parent_social)
    pedsql_parent_social$pedsql_parent_social_sum<-rowSums(pedsql_parent_social[, grep("agreement|rejected|bullied", names(pedsql_parent_social))], na.rm = TRUE)
    pedsql_parent_social$pedsql_parent_social_mean<-round(pedsql_parent_social$pedsql_parent_social_sum/pedsql_parent_social$not_missing_parent_social)
    pedsql_parent_social<- within(pedsql_parent_social, pedsql_parent_social_mean[pedsql_parent_social$not_missing_parent_social<1.5] <- NA)
    
    table(pedsql_parent_social$pedsql_parent_social_mean, pedsql_parent_social$not_missing_parent_social)
    hist(pedsql_parent_social$pedsql_parent_social_mean, breaks=110)
#merge back to database
    pedsql_parent_social<-pedsql_parent_social[, grepl("person_id|redcap_event_name|mean|missing|sum", names(pedsql_parent_social))]
    pedsql_merge <- merge(pedsql_parent_social, pedsql_merge,  by=c("person_id", "redcap_event_name"), all = TRUE)

#school vars
#Mean score = Sum of the items over the number of items answered
    pedsql_parent_school<- pedsql_parent[, grepl("person_id|redcap_event_name|understand|forget|schoolhomework", names(pedsql_parent))]
    pedsql_parent_school$not_missing_parent_school<-rowSums(!is.na(pedsql_parent_school))
    pedsql_parent_school$not_missing_parent_school<-pedsql_parent_school$not_missing_parent_school-2
    table(pedsql_parent_school$not_missing_parent_school)
    pedsql_parent_school$pedsql_parent_school_sum<-rowSums(pedsql_parent_school[, grep("understand|forget|schoolhomework", names(pedsql_parent_school))], na.rm = TRUE)
    pedsql_parent_school$pedsql_parent_school_mean<-round(pedsql_parent_school$pedsql_parent_school_sum/pedsql_parent_school$not_missing_parent_school)
    pedsql_parent_school<- within(pedsql_parent_school, pedsql_parent_school_mean[pedsql_parent_school$not_missing_parent_school<1.5] <- NA)
    
    table(pedsql_parent_school$pedsql_parent_school_mean, pedsql_parent_school$not_missing_parent_school)
    hist(pedsql_parent_school$pedsql_parent_school_mean, breaks=110)
#merge back to database
    pedsql_parent_school<-pedsql_parent_school[, grepl("person_id|redcap_event_name|mean|missing|sum", names(pedsql_parent_school))]
    pedsql_merge <- merge(pedsql_parent_school, pedsql_merge,  by=c("person_id", "redcap_event_name"), all = TRUE)
#remove all missing collumns
      pedsql_merge <-pedsql_merge[!sapply(pedsql_merge, function (x) all(is.na(x) | x == ""| x == "NA"))]
      pedsql_merge<-pedsql_merge[, !grepl("complete|comments", names(pedsql_merge))]
      save(pedsql_merge,file="pedsql_merge.rda")
#merge pedsql_merge back to any R01_lab_results database
      
      R01_lab_results_no_pedsql<-R01_lab_results[, !grepl("pedsql", names(R01_lab_results))]
      names(R01_lab_results_no_pedsql)[names(R01_lab_results_no_pedsql) == 'redcap_event_name'] <- 'redcap_event'
      names(pedsql_merge)[names(pedsql_merge) == 'redcap_event_name'] <- 'redcap_event'
      
      R01_lab_results <- merge(R01_lab_results_no_pedsql, pedsql_merge,  by=c("person_id", "redcap_event"), all = TRUE)
      glimpse(R01_lab_results)  
#create acute variable
      R01_lab_results$acute<-NA
      R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$visit_type==1] <- 1)
      R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$visit_type==2] <- 1)
      R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$visit_type==3] <- 0)
      R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$visit_type==4] <- 1)
      R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$visit_type==5] <- 1)
      #if they ask an initial survey question (see odk aic inital and follow up forms), it is an initial visit.
      R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$kid_highest_level_education_aic!=""] <- 1)
      R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$occupation_aic!=""] <- 1)
      R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$oth_educ_level_aic!=""] <- 1)
      R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$mom_highest_level_education_aic!=""] <- 1)
      R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$roof_type!=""] <- 1)
      R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$pregnant!=""] <- 1)
      #if it is visit a,call it acute
      R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$redcap_event=="visit_a_arm_1" & id_cohort=="F"] <- 1)
      #if they have fever, call it acute
      R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$aic_symptom_fever==1] <- 1)
      R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$temp>=38] <- 1)
      #otherwise, it is not acute
      R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$acute!=1 & !is.na(R01_lab_results$gender_aic) ] <- 0)
      
      table(R01_lab_results$acute)
#make pairs of acute and convalescent pedsql visits.       
      pedsql <- R01_lab_results[, grepl("person_id|redcap_event|pedsql|acute", names(R01_lab_results) ) ]
      pedsql<- pedsql[which(pedsql$redcap_event!="patient_informatio_arm_1"), ]
#save for use in other projects
      save(pedsql,file="pedsql.rda")
      
