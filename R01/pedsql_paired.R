#2 weeks -10 weeks  is a convalescent visit to pair with acute. 
# packages -----------------------------------------------------------------
#install.packages(c("REDCapR", "mlr"))
#install.packages(c("dummies"))
library(dplyr)
library(plyr)
library(redcapAPI)
library(REDCapR)
library(ggplot2)

# get data -----------------------------------------------------------------
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long")
load("R01_lab_results 2017-12-01 .rda")
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
pedsql_child<-pedsql_child[, !grepl("parent", names(pedsql))]

#total child score
  pedsql_child_total<- pedsql_child[, grepl("person_id|redcap_event_name|walk|run|play|lift|work|fear|scared|angry|sad|agreement|rejected|bullied|understand|forget|schoolhomework", names(pedsql_child))]
  pedsql_child_total$not_missing_child<-rowSums(!is.na(pedsql_child_total))
  pedsql_child_total$not_missing_child<-pedsql_child_total$not_missing_child-2
  table(pedsql_child_total$not_missing_child)
  pedsql_child_total$pedsql_child_total_sum<-rowSums(pedsql_child_total[, grep("walk|run|play|lift|work|fear|scared|angry|sad|agreement|rejected|bullied|understand|forget|schoolhomework", names(pedsql_child_total))], na.rm = TRUE)
  pedsql_child_total$pedsql_child_total_mean<-round(pedsql_child_total$pedsql_child_total_sum/pedsql_child_total$not_missing_child)
  pedsql_child_total<- within(pedsql_child_total, pedsql_child_total_mean[pedsql_child_total$not_missing_child<(15/2)] <- NA)
  table(pedsql_child_total$pedsql_child_total_mean)
  
  #merge back to database
    pedsql_child_total<-pedsql_child_total[, grepl("person_id|redcap_event_name|mean|missing|sum", names(pedsql_child_total))]
    pedsql_merge<-pedsql
    pedsql_merge <- merge(pedsql_child_total, pedsql_merge,  by=c("person_id", "redcap_event_name"), all = TRUE)
    hist(pedsql_child_total$pedsql_child_total_mean, breaks=110)
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

#total parent score
  pedsql_parent_total<- pedsql_parent[, grepl("person_id|redcap_event_name|walk|run|play|lift|work|fear|scared|angry|sad|agreement|rejected|bullied|understand|forget|schoolhomework", names(pedsql_parent))]
  pedsql_parent_total$not_missing_parent<-rowSums(!is.na(pedsql_parent_total))
  pedsql_parent_total$not_missing_parent<-pedsql_parent_total$not_missing_parent-2
  table(pedsql_parent_total$not_missing_parent)
  pedsql_parent_total$pedsql_parent_total_sum<-rowSums(pedsql_parent_total[, grep("walk|run|play|lift|work|fear|scared|angry|sad|agreement|rejected|bullied|understand|forget|schoolhomework", names(pedsql_parent_total))], na.rm = TRUE)
  pedsql_parent_total$pedsql_parent_total_mean<-round(pedsql_parent_total$pedsql_parent_total_sum/pedsql_parent_total$not_missing_parent)
  pedsql_parent_total<- within(pedsql_parent_total, pedsql_parent_total_mean[pedsql_parent_total$not_missing_parent<(15/2)] <- NA)
  table(pedsql_parent_total$pedsql_parent_total_mean)
  
  #merge back to database
    pedsql_parent_total<-pedsql_parent_total[, grepl("person_id|redcap_event_name|mean|missing|sum", names(pedsql_parent_total))]
    pedsql_merge <- merge(pedsql_parent_total, pedsql_merge,  by=c("person_id", "redcap_event_name"), all = TRUE)
    hist(pedsql_parent_total$pedsql_parent_total_mean, breaks = 110)
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
#create acute variable
      R01_lab_results$acute<-NA
      R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$visit_type==1] <- 1)
      R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$visit_type==2] <- 1)
      R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$visit_type==3] <- 0)
      R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$visit_type==4] <- 1)
      R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$visit_type==5] <- 0)
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
      
      pedsql_wide<-reshape(pedsql, direction = "wide", idvar = "person_id", timevar = "redcap_event", sep = "_")
      pedsql_wide$pairs_ab<-ifelse(pedsql_wide$acute_visit_a_arm_1 ==1 & !is.na(pedsql_wide$pedsql_date_visit_a_arm_1) & pedsql_wide$acute_visit_b_arm_1==0 & !is.na(pedsql_wide$pedsql_date_visit_b_arm_1), 1, 0)    
      pedsql_wide$pairs_bc<-ifelse(pedsql_wide$acute_visit_b_arm_1==1 & !is.na(pedsql_wide$pedsql_date_visit_b_arm_1) & pedsql_wide$acute_visit_c_arm_1==0 & !is.na(pedsql_wide$pedsql_date_visit_c_arm_1), 1, 0)    
      pedsql_wide$pairs_cd<-ifelse(pedsql_wide$acute_visit_c_arm_1==1 & !is.na(pedsql_wide$pedsql_date_visit_c_arm_1) & pedsql_wide$acute_visit_d_arm_1==0 & !is.na(pedsql_wide$pedsql_date_visit_d_arm_1), 1, 0)    
      pedsql_wide$pairs_de<-ifelse(pedsql_wide$acute_visit_d_arm_1==1 & !is.na(pedsql_wide$pedsql_date_visit_d_arm_1) & pedsql_wide$acute_visit_e_arm_1==0 & !is.na(pedsql_wide$pedsql_date_visit_e_arm_1), 1, 0)    
      pedsql_wide$pairs_ef<-ifelse(pedsql_wide$acute_visit_e_arm_1==1 & !is.na(pedsql_wide$pedsql_date_visit_e_arm_1) & pedsql_wide$acute_visit_f_arm_1==0 & !is.na(pedsql_wide$pedsql_date_visit_f_arm_1), 1, 0)    
      pedsql_wide$pairs_fg<-ifelse(pedsql_wide$acute_visit_f_arm_1==1 & !is.na(pedsql_wide$pedsql_date_visit_f_arm_1) & pedsql_wide$acute_visit_g_arm_1==0 & !is.na(pedsql_wide$pedsql_date_visit_g_arm_1), 1, 0)    
      pedsql_wide$pairs_gh<-ifelse(pedsql_wide$acute_visit_g_arm_1==1 & !is.na(pedsql_wide$pedsql_date_visit_g_arm_1) & pedsql_wide$acute_visit_h_arm_1==0 & !is.na(pedsql_wide$pedsql_date_visit_h_arm_1), 1, 0)    
      table(pedsql_wide$pairs_ab)
      table(pedsql_wide$pairs_bc)
      table(pedsql_wide$pairs_cd)
      table(pedsql_wide$pairs_de)
      table(pedsql_wide$pairs_ef)
      table(pedsql_wide$pairs_fg)
      table(pedsql_wide$pairs_gh)
      table(pedsql_wide$pedsql_child_school_mean_visit_a_arm_1, pedsql_wide$pedsql_child_school_mean_visit_b_arm_1, pedsql_wide$pairs_ab)
      pedsql_wide_ab<-pedsql_wide[which(pedsql_wide$pairs_ab==1)  , ]
      plot(pedsql_wide_ab$pedsql_child_school_mean_visit_a_arm_1, pedsql_wide_ab$pedsql_child_school_mean_visit_b_arm_1, type ="p") 
#make var for acute and follow up measures at acute visit  based on acute. 
      pedsql_pairs<- pedsql_wide[, grepl("person_id|pairs|mean|acute", names(pedsql_wide) ) ]
      pedsql_pairs<- pedsql_pairs[, !grepl("u24", names(pedsql_pairs) ) ]
      pedsql_pairs$pair_sum <- as.integer(rowSums(pedsql_pairs[ , grep("pairs" , names(pedsql_pairs))], na.rm =TRUE))
      table(pedsql_pairs$pair_sum)
#order
      pedsql_pairs<-pedsql_pairs[,order(colnames(pedsql_pairs))]

      pedsql_pairs<-pedsql_pairs[order(-(grepl('visit_h_arm_1', names(pedsql_pairs)))+1L)]
      pedsql_pairs<-pedsql_pairs[order(-(grepl('visit_g_arm_1', names(pedsql_pairs)))+1L)]
      pedsql_pairs<-pedsql_pairs[order(-(grepl('visit_f_arm_1', names(pedsql_pairs)))+1L)]
      pedsql_pairs<-pedsql_pairs[order(-(grepl('visit_e_arm_1', names(pedsql_pairs)))+1L)]
      pedsql_pairs<-pedsql_pairs[order(-(grepl('visit_d_arm_1', names(pedsql_pairs)))+1L)]
      pedsql_pairs<-pedsql_pairs[order(-(grepl('visit_c_arm_1', names(pedsql_pairs)))+1L)]
      pedsql_pairs<-pedsql_pairs[order(-(grepl('visit_b_arm_1', names(pedsql_pairs)))+1L)]
      pedsql_pairs<-pedsql_pairs[order(-(grepl('visit_a_arm_1', names(pedsql_pairs)))+1L)]
      pedsql_pairs<-pedsql_pairs[order(-(grepl('patient_informatio_arm_1', names(pedsql_pairs)))+1L)]
      

#remove acute and put in seperate data frame
      acute<- as.data.frame(pedsql_pairs[, grepl("person_id|acute", names(pedsql_pairs) ) ])
      pedsql_pairs<- pedsql_pairs[, !grepl("acute", names(pedsql_pairs) ) ]
      
#reshape
      nameVec <- names(pedsql_pairs)
      v.names=c("pedsql_child_emotional_mean", "pedsql_child_physical_mean", "pedsql_child_school_mean", "pedsql_child_social_mean", "pedsql_child_total_mean", "pedsql_parent_emotional_mean", "pedsql_parent_physical_mean", "pedsql_parent_school_mean", "pedsql_parent_social_mean", "pedsql_parent_total_mean") 
      times = c("patient_informatio_arm_1", "visit_a_arm_1", "visit_b_arm_1", "visit_c_arm_1", "visit_d_arm_1", "visit_e_arm_1", "visit_f_arm_1", "visit_g_arm_1", "visit_h_arm_1")
      
      pedsql_pairs_long<-reshape(pedsql_pairs, idvar = "person_id", varying=c(1:90),  direction = "long", timevar = "redcap_event_name", times = times,       v.names=v.names )
      acute_long<-reshape(acute, idvar = "person_id", varying=c(1:9),  direction = "long", timevar = "redcap_event_name", times =times, v.names="acute")
      
#merge back to database
        pedsql_pairs_long <- merge(acute_long, pedsql_pairs_long,  by=c("person_id", "redcap_event_name"), all = TRUE)
        table(acute_long$acute)
        table(pedsql_pairs_long$acute, exclude = NULL)
        
      pedsql_pairs_long_ab<-pedsql_pairs_long[which((pedsql_pairs_long$pairs_ab==1 & pedsql_pairs_long$redcap_event_name=="visit_a_arm_1")| (pedsql_pairs_long$pairs_ab==1 & pedsql_pairs_long$redcap_event_name=="visit_b_arm_1")),]
      pedsql_pairs_long_ab <- pedsql_pairs_long_ab[, grepl("person_id|redcap|mean|acute|_ab", names(pedsql_pairs_long_ab) ) ]
      table(pedsql_pairs_long_ab$redcap_event_name)

      pedsql_pairs_long_bc<-pedsql_pairs_long[which((pedsql_pairs_long$pairs_bc==1 & pedsql_pairs_long$redcap_event_name=="visit_b_arm_1")|(pedsql_pairs_long$pairs_bc==1 & pedsql_pairs_long$redcap_event_name=="visit_c_arm_1")),]
      pedsql_pairs_long_bc <- pedsql_pairs_long_bc[, grepl("person_id|redcap|mean|acute|_bc", names(pedsql_pairs_long_bc) ) ]
      table(pedsql_pairs_long_bc$redcap_event_name)
      
      pedsql_pairs_long_cd<-pedsql_pairs_long[which((pedsql_pairs_long$pairs_cd==1 & pedsql_pairs_long$redcap_event_name=="visit_c_arm_1")|(pedsql_pairs_long$pairs_cd==1 & pedsql_pairs_long$redcap_event_name=="visit_d_arm_1")),]
      pedsql_pairs_long_cd <- pedsql_pairs_long_cd[, grepl("person_id|redcap|mean|acute|_cd", names(pedsql_pairs_long_cd ) ) ]
      table(pedsql_pairs_long_cd$redcap_event_name)

      pedsql_pairs_long_de<-pedsql_pairs_long[which((pedsql_pairs_long$pairs_de==1 & pedsql_pairs_long$redcap_event_name=="visit_d_arm_1")|(pedsql_pairs_long$pairs_de==1 & pedsql_pairs_long$redcap_event_name=="visit_e_arm_1")),]
      pedsql_pairs_long_de <- pedsql_pairs_long_de[, grepl("person_id|redcap|mean|acute|_de", names(pedsql_pairs_long_de ) ) ]
      table(pedsql_pairs_long_de$redcap_event_name)

      pedsql_pairs_long_ef<-pedsql_pairs_long[which((pedsql_pairs_long$pairs_ef==1 & pedsql_pairs_long$redcap_event_name=="visit_e_arm_1")|(pedsql_pairs_long$pairs_ef==1 & pedsql_pairs_long$redcap_event_name=="visit_f_arm_1")),]
      pedsql_pairs_long_ef <- pedsql_pairs_long_ef[, grepl("person_id|redcap|mean|acute|_ef", names(pedsql_pairs_long_ef ) ) ]
      table(pedsql_pairs_long_ef$redcap_event_name)
      
      pedsql_pairs_long_fg<-pedsql_pairs_long[which((pedsql_pairs_long$pairs_fg==1 & pedsql_pairs_long$redcap_event_name=="visit_f_arm_1")|(pedsql_pairs_long$pairs_fg==1 & pedsql_pairs_long$redcap_event_name=="visit_g_arm_1")),]
      pedsql_pairs_long_fg <- pedsql_pairs_long_fg[, grepl("person_id|redcap|mean|acute|_fg", names(pedsql_pairs_long_fg ) ) ]
      table(pedsql_pairs_long_fg$redcap_event_name)

      pedsql_pairs_long_gh<-pedsql_pairs_long[which((pedsql_pairs_long$pairs_gh==1 & pedsql_pairs_long$redcap_event_name=="visit_g_arm_1")|(pedsql_pairs_long$pairs_gh==1 & pedsql_pairs_long$redcap_event_name=="visit_h_arm_1")),]
      pedsql_pairs_long_gh <- pedsql_pairs_long_gh[, grepl("person_id|redcap|mean|acute|_gh", names(pedsql_pairs_long_gh ) ) ]
      table(pedsql_pairs_long_gh$redcap_event_name)

      pedsql_pairs_long_bind<-rbind.fill(pedsql_pairs_long_ab, pedsql_pairs_long_bc, pedsql_pairs_long_cd , pedsql_pairs_long_de, pedsql_pairs_long_ef, pedsql_pairs_long_fg, pedsql_pairs_long_gh)      
      #keep unique person ids and event names.> df[!duplicated(df[1:3]),]
        pedsql_pairs_long_bind<-pedsql_pairs_long_bind[!duplicated(pedsql_pairs_long_bind[1:2]), ]
        n_distinct(pedsql_pairs_long_bind$person_id, pedsql_pairs_long_bind$redcap_event_name)
        n_distinct(pedsql_pairs_long_bind$person_id)
        
#acute and convalescent
      pedsql_pairs_long_bind<- within(pedsql_pairs_long_bind, acute[acute ==1] <- "acute_paired")
      pedsql_pairs_long_bind<- within(pedsql_pairs_long_bind, acute[acute==0] <- "conv_paired")

#count repeat patients
      pedsql_pairs_long_bind$count<-with(pedsql_pairs_long_bind, ave(as.character(person_id), person_id, FUN = seq_along))
      pedsql_pairs_long_bind<- within(pedsql_pairs_long_bind, count[count==2] <- 1)
      pedsql_pairs_long_bind<- within(pedsql_pairs_long_bind, count[count==3] <- 2)
      pedsql_pairs_long_bind<- within(pedsql_pairs_long_bind, count[count==4] <- 2)
      pedsql_pairs_long_bind<- within(pedsql_pairs_long_bind, count[count==5] <- 3)
      pedsql_pairs_long_bind<- within(pedsql_pairs_long_bind, count[count==6] <- 3)
      table(pedsql_pairs_long_bind$count)
      
#cast to wide with acute and convalesent as the "time"
      pedsql_pairs_acute<-reshape(pedsql_pairs_long_bind, direction = "wide", idvar = c("person_id", "count"), timevar = "acute", sep = "_")

#save for use in others
      save(pedsql_pairs_acute,file="pedsql_pairs_acute.rda")
      
#export to csv
      setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/david coinfectin paper/data")
      f <- "paired_pedsql.csv"
      write.csv(as.data.frame(pedsql_pairs_acute), f)