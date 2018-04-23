#Hi Amy, I just rewrote this paragraph for the paper. Can you read and see if it makes sense? Returning subjects with AFI could be considered as a new AFI visit if >=3 months had elapsed. I am calling this the "illness wash out period". Can you reclassify visits based on these new criteria? Thanks -D
#For the present analysis, we classified the enrollment AFI visits and new AFI visits by returning subjects after a minimum 3-month "illness wash out" period, as acute visits. We applied this wash out period due to concern for misclassifying visits from subjects who returned for follow up due to continuing fevers or symptoms that may have been associated with the preceeding acute AFI visit, instead of being an entirely new illness. These ill follow up visits were not part of the original study design and are therefore described separately from analysis of the study.
#We classified return visits, from subjects who returned for the expressed purpose of participating in our study at the planned one-month follow up, as convalescent visits. We excluded any study follow up visits from subjects who had fever at the time of follow up, due to concern for confounding due to potential interim development of a new illness. Per protocol, the follow up visit was to occur at one month after the preceding AFI visit. We included as convalescent visits follow up visits that occurred between two to ten weeks after the acute visit. 

# packages -----------------------------------------------------------------
library(dplyr)
library(plyr)
library(redcapAPI)
library(REDCapR)
library(ggplot2)

# get data -----------------------------------------------------------------
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long")
load("R01_lab_results 2018-04-11 .rda")

R01_lab_results<- R01_lab_results[which(!is.na(R01_lab_results$redcap_event_name))  , ]
R01_lab_results<- R01_lab_results[which(R01_lab_results$redcap_event_name!="visit_a2_arm_1"&R01_lab_results$redcap_event_name!="visit_b2_arm_1"&R01_lab_results$redcap_event_name!="visit_c2_arm_1"&R01_lab_results$redcap_event_name!="visit_d2_arm_1"&R01_lab_results$redcap_event_name!="visit_c2_arm_1"&R01_lab_results$redcap_event_name!="visit_u24_arm_1")  , ]
table(R01_lab_results$redcap_event_name)
  R01_lab_results$id_cohort<-substr(R01_lab_results$person_id, 2, 2)
  R01_lab_results$id_city<-substr(R01_lab_results$person_id, 1, 1)
pedsql<-R01_lab_results[which(!is.na(R01_lab_results$interview_date_aic)&!is.na(R01_lab_results$result_igg_denv_kenya)&R01_lab_results$redcap_event_name!="patient_informatio_arm_1"&R01_lab_results$id_cohort=="F")  , ]
#children
#select child vars

pedsql_child<- pedsql[, grepl("person_id|redcap_event_name|pedsql|interview_date_aic|result_igg_denv_kenya|id_city|aic_calculated_age", names(pedsql))]
pedsql_child<-pedsql_child[, !grepl("parent", names(pedsql_child))]

#total child score
  pedsql_child_total<- pedsql_child[, grepl("person_id|redcap_event_name|walk|run|play|lift|work|fear|scared|angry|sad|agreement|rejected|bullied|understand|forget|schoolhomework|interview_date_aic|result_igg_denv_kenya|id_city|aic_calculated_age", names(pedsql_child))]
  pedsql_child_total$not_missing_child<-rowSums(!is.na(pedsql_child_total))
  pedsql_child_total$not_missing_child<-pedsql_child_total$not_missing_child-6
  table(pedsql_child_total$not_missing_child, pedsql$redcap_event_name,pedsql$id_city)
  
  
  pedsql_child_total$pedsql_child_total_sum<-rowSums(pedsql_child_total[, grep("walk|run|play|lift|work|fear|scared|angry|sad|agreement|rejected|bullied|understand|forget|schoolhomework", names(pedsql_child_total))], na.rm = TRUE)
  table(pedsql_child_total$pedsql_child_total_sum)
  pedsql_child_total$pedsql_child_total_mean<-round(pedsql_child_total$pedsql_child_total_sum/pedsql_child_total$not_missing_child)
  table(pedsql_child_total$pedsql_child_total_mean)
  
  table(pedsql_child_total$pedsql_child_total_mean)
  hist(pedsql_child_total$pedsql_child_total_mean)
write.csv(pedsql_child_total, "C:/Users/amykr/Box Sync/Amy Krystosik's Files/david coinfectin paper/pedsql_child_total.csv")  

#parents
#select partent variables from pedsql

pedsql_parent<- pedsql[, grepl("person_id|redcap_event_name|pedsql|interview_date_aic|result_igg_denv_kenya|id_city", names(pedsql))]
pedsql_parent<-pedsql_parent[, !grepl("parent", names(pedsql_parent))]

#total parent score
pedsql_parent_total<- pedsql_parent[, grepl("person_id|redcap_event_name|walk|run|play|lift|work|fear|scared|angry|sad|agreement|rejected|bullied|understand|forget|schoolhomework|interview_date_aic|result_igg_denv_kenya|id_city", names(pedsql_parent))]
pedsql_parent_total$not_missing_parent<-rowSums(!is.na(pedsql_parent_total))
pedsql_parent_total$not_missing_parent<-pedsql_parent_total$not_missing_parent-5
table(pedsql_parent_total$not_missing_parent, pedsql$redcap_event_name,pedsql$id_city)


pedsql_parent_total$pedsql_parent_total_sum<-rowSums(pedsql_parent_total[, grep("walk|run|play|lift|work|fear|scared|angry|sad|agreement|rejected|bullied|understand|forget|schoolhomework", names(pedsql_parent_total))], na.rm = TRUE)
table(pedsql_parent_total$pedsql_parent_total_sum)
pedsql_parent_total$pedsql_parent_total_mean<-round(pedsql_parent_total$pedsql_parent_total_sum/pedsql_parent_total$not_missing_parent)
table(pedsql_parent_total$pedsql_parent_total_mean)

table(pedsql_parent_total$pedsql_parent_total_mean)
hist(pedsql_parent_total$pedsql_parent_total_mean)
write.csv(pedsql_parent_total, "C:/Users/amykr/Box Sync/Amy Krystosik's Files/david coinfectin paper/pedsql_parent_total.csv")



library(doBy)
summaryBy(pedsql_parent_total_mean ~ gender_all + strata_all, data=pedsql_parent_total , FUN=c(length,mean,sd))
