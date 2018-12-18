memory.limit(size = 7500000)
library(lubridate)
library(tidyverse)
library(dplyr)
library(janitor)
library(plyr)
# get data -----------------------------------------------------------------
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/david coinfection paper/data")
load("R01_lab_results 2018-11-16 .rda")
load("aic_symptoms.rda")
aic_symptoms<-aic_symptoms[,c("person_id","redcap_event_name","aic_symptom_fever")]
AIC<-merge(aic_symptoms,R01_lab_results,by=c("person_id","redcap_event_name"))
# format data -----------------------------------------------------------------
AIC$person_id<-as.character(AIC$person_id)
AIC$redcap_event_name<-as.character(AIC$redcap_event_name)
AIC$id_cohort<-substr(AIC$person_id, 2, 2)
AIC$id_city<-substr(AIC$person_id, 1, 1)
AIC$int_date <-ymd(AIC$interview_date_aic)
AIC<- AIC[which(AIC$id_cohort=="F"&AIC$redcap_event_name!="patient_informatio_arm_1"&AIC$redcap_event_name!="visit_a2_arm_1"&AIC$redcap_event_name!="visit_b2_arm_1"&AIC$redcap_event_name!="visit_c2_arm_1"&AIC$redcap_event_name!="visit_d2_arm_1"&AIC$redcap_event_name!="visit_u24_arm_1"),]
table(AIC$redcap_event)

# define acute febrile illness ------------------------------------------------------------------------
source("C:/Users/amykr/Documents/GitHub/lebeaud_lab/david/define acute febrile illness.r")
AIC<-AIC[ , !(names(AIC) %in% c("aic_symptom_fever"))]

# pedsql ------------------------------------------------------------------
AIC<-AIC[order(-(grepl('pedsql', names(AIC)))+1L)]
AIC_no_pedsql<-AIC[, !grepl("pedsql", names(AIC))]
names(AIC_no_pedsql)[names(AIC_no_pedsql) == 'redcap_event_name'] <- 'redcap_event'
pedsql<-as.data.frame(AIC[, grepl("person_id|redcap_event|pedsql|acute|int_date", names(AIC))])
pedsql<-as.data.frame(pedsql[, !grepl("sum", names(pedsql))])
colnamespedsql<-colnames(pedsql[, grepl("pedsql", names(pedsql))])

require(dplyr)
pedsql<-pedsql %>%
  select(person_id,redcap_event_name, everything())

unique_id <- function(x, ...) {
  id_set <- x %>% select(...)
  id_set_dist <- id_set %>% distinct
  if (nrow(id_set) == nrow(id_set_dist)) {
    TRUE
  } else {
    non_unique_ids <- id_set %>% 
      filter(id_set %>% duplicated()) %>% 
      distinct()
    suppressMessages(
      inner_join(non_unique_ids, x) %>% arrange(...)
    )
  }
}
pedsql$id<-paste(pedsql$person_id,pedsql$redcap_event_name,sep ="")
nonU<-pedsql %>% unique_id(c(id))
pedsql = pedsql[!pedsql$person_id=="OF0009",]
nonU2<-pedsql %>% unique_id(c(id))

#reverse scoring: Step 1: Transform Score. Items are reversed scored and linearly transformed to a 0-100 scale as follows: 0=100, 1=75, 2=50, 3=25, 4=0.
#remove missing
pedsql[pedsql==99 ] <- NA#refused
pedsql[pedsql==98 ] <- NA#other

pedsql[pedsql==0 ] <- 100#there has never been a problem
pedsql[pedsql==1 ] <- 75#almost no problems
pedsql[pedsql==2 ] <- 50#sometimes there are problems
pedsql[pedsql==3 ] <- 25#each time there is a problem
pedsql[pedsql==4 ] <- 0#problems all the time

#keep acute as is.
pedsql$acute[pedsql$acute==100 ] <- 0
pedsql$acute[pedsql$acute==75 ] <- 1

#children
#select child vars
pedsql_child<- pedsql[, grepl("person_id|redcap_event_name|pedsql", names(pedsql))]
pedsql_child<-pedsql_child[, !grepl("parent", names(pedsql_child))]

#total child score
pedsql_child_total<- pedsql_child[, grepl("person_id|redcap_event_name|walk|run|play|lift|work|fear|scared|angry|sad|agreement|rejected|bullied|understand|forget|schoolhomework", names(pedsql_child))]
pedsql_child_total$not_missing_child<-rowSums(!is.na(pedsql_child_total))
pedsql_child_total$not_missing_child<-pedsql_child_total$not_missing_child-2
table(pedsql_child_total$not_missing_child)
pedsql_child_total$pedsql_child_total_sum<-rowSums(pedsql_child_total[, grep("walk|run|play|lift|work|fear|scared|angry|sad|agreement|rejected|bullied|understand|forget|schoolhomework", names(pedsql_child_total))], na.rm = TRUE)
pedsql_child_total$pedsql_child_total_mean<-round(pedsql_child_total$pedsql_child_total_sum/pedsql_child_total$not_missing_child)


pedsql_child_total<- within(pedsql_child_total, pedsql_child_total_mean[pedsql_child_total$not_missing_child<(15/2)] <- NA)
pedsql_child_total<-pedsql_child_total[order(-(grepl('pedsql_child_total_mean', names(pedsql_child_total)))+1L)]
plyr::count(!is.na(pedsql_child_total$pedsql_child_total_mean))
pedsql_child_total<-as.data.frame(pedsql_child_total[, grepl("person_id|redcap_event_name|mean|missing|sum", names(pedsql_child_total))])

#physical vars
#Mean score = Sum of the items over the number of items answered
pedsql_child_physical<- pedsql_child[, grepl("person_id|redcap_event_name|walk|run|play|lift|work", names(pedsql_child))]
pedsql_child_physical<- pedsql_child_physical[, !grepl("school", names(pedsql_child_physical))]
pedsql_child_physical$not_missing_child_physical<-rowSums(!is.na(pedsql_child_physical))
pedsql_child_physical$not_missing_child_physical<-pedsql_child_physical$not_missing_child_physical-2
pedsql_child_physical$pedsql_child_physical_sum<-rowSums(pedsql_child_physical[, grep("walk|run|play|lift|work", names(pedsql_child_physical))], na.rm = TRUE)
pedsql_child_physical$pedsql_child_physical_mean<-round(pedsql_child_physical$pedsql_child_physical_sum/pedsql_child_physical$not_missing_child_physical)
pedsql_child_physical<- within(pedsql_child_physical, pedsql_child_physical_mean[pedsql_child_physical$not_missing_child_physical<2.5] <- NA)

plyr::count(!is.na(pedsql_child_physical$pedsql_child_physical_mean))

pedsql_child_physical<-pedsql_child_physical[, grepl("person_id|redcap_event_name|mean|missing|sum", names(pedsql_child_physical))]

# emotion vars ------------------------------------------------------------
#Mean score = Sum of the items over the number of items answered
pedsql_child_emotional<- pedsql_child[, grepl("person_id|redcap_event_name|fear|scared|angry|sad", names(pedsql_child))]
pedsql_child_emotional$not_missing_child_emotional<-rowSums(!is.na(pedsql_child_emotional))
pedsql_child_emotional$not_missing_child_emotional<-pedsql_child_emotional$not_missing_child_emotional-2
pedsql_child_emotional$pedsql_child_emotional_sum<-rowSums(pedsql_child_emotional[, grep("fear|scared|angry|sad", names(pedsql_child_emotional))], na.rm = TRUE)
pedsql_child_emotional$pedsql_child_emotional_mean<-round(pedsql_child_emotional$pedsql_child_emotional_sum/pedsql_child_emotional$not_missing_child_emotional)
pedsql_child_emotional<- within(pedsql_child_emotional, pedsql_child_emotional_mean[pedsql_child_emotional$not_missing_child_emotional<1.5] <- NA)

plyr::count(!is.na(pedsql_child_emotional$pedsql_child_emotional_mean))
pedsql_child_emotional<-pedsql_child_emotional[, grepl("person_id|redcap_event_name|mean|missing|sum", names(pedsql_child_emotional))]

# social vars ------------------------------------------------------------
#Mean score = Sum of the items over the number of items answered
pedsql_child_social<- pedsql_child[, grepl("person_id|redcap_event_name|agreement|rejected|bullied", names(pedsql_child))]
pedsql_child_social$not_missing_child_social<-rowSums(!is.na(pedsql_child_social))
pedsql_child_social$not_missing_child_social<-pedsql_child_social$not_missing_child_social-2
pedsql_child_social$pedsql_child_social_sum<-rowSums(pedsql_child_social[, grep("agreement|rejected|bullied", names(pedsql_child_social))], na.rm = TRUE)
pedsql_child_social$pedsql_child_social_mean<-round(pedsql_child_social$pedsql_child_social_sum/pedsql_child_social$not_missing_child_social)
pedsql_child_social<- within(pedsql_child_social, pedsql_child_social_mean[pedsql_child_social$not_missing_child_social<1.5] <- NA)

plyr::count(!is.na(pedsql_child_social$pedsql_child_social_mean))
pedsql_child_social<-pedsql_child_social[, grepl("person_id|redcap_event_name|mean|missing|sum", names(pedsql_child_social))]

# school vars ------------------------------------------------------------
#Mean score = Sum of the items over the number of items answered
pedsql_child_school<- pedsql_child[, grepl("person_id|redcap_event_name|understand|forget|schoolhomework", names(pedsql_child))]
pedsql_child_school$not_missing_child_school<-rowSums(!is.na(pedsql_child_school))
pedsql_child_school$not_missing_child_school<-pedsql_child_school$not_missing_child_school-2
pedsql_child_school$pedsql_child_school_sum<-rowSums(pedsql_child_school[, grep("understand|forget|schoolhomework", names(pedsql_child_school))], na.rm = TRUE)
pedsql_child_school$pedsql_child_school_mean<-round(pedsql_child_school$pedsql_child_school_sum/pedsql_child_school$not_missing_child_school)
pedsql_child_school<- within(pedsql_child_school, pedsql_child_school_mean[pedsql_child_school$not_missing_child_school<1.5] <- NA)

plyr::count(!is.na(pedsql_child_school$pedsql_child_school_mean))
pedsql_child_school<-pedsql_child_school[, grepl("person_id|redcap_event_name|mean|missing|sum", names(pedsql_child_school))]

# psychosocial vars ------------------------------------------------------------
#Mean score = Sum of the items over the number of items answered
pedsql_child_psych<- pedsql_child[, grepl("person_id|redcap_event_name|understand|forget|schoolhomework|agreement|rejected|bullied|fear|scared|angry|sad", names(pedsql_child))]
pedsql_child_psych$not_missing_child_psych<-rowSums(!is.na(pedsql_child_psych))
pedsql_child_psych$not_missing_child_psych<-pedsql_child_psych$not_missing_child_psych-2
pedsql_child_psych$pedsql_child_psych_sum<-rowSums(pedsql_child_psych[, grep("understand|forget|schoolhomework|agreement|rejected|bullied|fear|scared|angry|sad", names(pedsql_child_psych))], na.rm = TRUE)
pedsql_child_psych$pedsql_child_psych_mean<-round(pedsql_child_psych$pedsql_child_psych_sum/pedsql_child_psych$not_missing_child_psych)
pedsql_child_psych<- within(pedsql_child_psych, pedsql_child_psych_mean[pedsql_child_psych$not_missing_child_psych<5] <- NA)

plyr::count(!is.na(pedsql_child_psych$pedsql_child_psych_mean))
pedsql_child_psych<-pedsql_child_psych[, grepl("person_id|redcap_event_name|mean|missing|sum", names(pedsql_child_psych))]

# parents vars ------------------------------------------------------------
pedsql_parent<- pedsql[, grepl("person_id|redcap_event_name|_parent", names(pedsql))]
#total parent score
pedsql_parent_total<- pedsql_parent[, grepl("person_id|redcap_event_name|walk|run|play|lift|work|fear|scared|angry|sad|agreement|rejected|bullied|understand|forget|schoolhomework", names(pedsql_parent))]
pedsql_parent_total$not_missing_parent<-rowSums(!is.na(pedsql_parent_total))
pedsql_parent_total$not_missing_parent<-pedsql_parent_total$not_missing_parent-2
pedsql_parent_total$pedsql_parent_total_sum<-rowSums(pedsql_parent_total[, grep("walk|run|play|lift|work|fear|scared|angry|sad|agreement|rejected|bullied|understand|forget|schoolhomework", names(pedsql_parent_total))], na.rm = TRUE)
pedsql_parent_total$pedsql_parent_total_mean<-round(pedsql_parent_total$pedsql_parent_total_sum/pedsql_parent_total$not_missing_parent)
pedsql_parent_total<- within(pedsql_parent_total, pedsql_parent_total_mean[pedsql_parent_total$not_missing_parent<(15/2)] <- NA)

pedsql_parent_total<-pedsql_parent_total[, grepl("person_id|redcap_event_name|mean|missing|sum", names(pedsql_parent_total))]
plyr::count(!is.na(pedsql_parent_total$pedsql_parent_total_mean))

# physical vars ------------------------------------------------------------
#Mean score = Sum of the items over the number of items answered
pedsql_parent_physical<- pedsql_parent[, grepl("person_id|redcap_event_name|walk|run|play|lift|work", names(pedsql_parent))]
pedsql_parent_physical<- pedsql_parent_physical[, !grepl("school", names(pedsql_parent_physical))]
pedsql_parent_physical$not_missing_parent_physical<-rowSums(!is.na(pedsql_parent_physical))
pedsql_parent_physical$not_missing_parent_physical<-pedsql_parent_physical$not_missing_parent_physical-2
pedsql_parent_physical$pedsql_parent_physical_sum<-rowSums(pedsql_parent_physical[, grep("walk|run|play|lift|work", names(pedsql_parent_physical))], na.rm = TRUE)
pedsql_parent_physical$pedsql_parent_physical_mean<-round(pedsql_parent_physical$pedsql_parent_physical_sum/pedsql_parent_physical$not_missing_parent_physical)
pedsql_parent_physical<- within(pedsql_parent_physical, pedsql_parent_physical_mean[pedsql_parent_physical$not_missing_parent_physical<2.5] <- NA)
pedsql_parent_physical<-pedsql_parent_physical[, grepl("person_id|redcap_event_name|mean|missing|sum", names(pedsql_parent_physical))]


# emotional vars ------------------------------------------------------------
#Mean score = Sum of the items over the number of items answered
pedsql_parent_emotional<- pedsql_parent[, grepl("person_id|redcap_event_name|fear|scared|angry|sad", names(pedsql_parent))]
pedsql_parent_emotional$not_missing_parent_emotional<-rowSums(!is.na(pedsql_parent_emotional))
pedsql_parent_emotional$not_missing_parent_emotional<-pedsql_parent_emotional$not_missing_parent_emotional-2
pedsql_parent_emotional$pedsql_parent_emotional_sum<-rowSums(pedsql_parent_emotional[, grep("fear|scared|angry|sad", names(pedsql_parent_emotional))], na.rm = TRUE)
pedsql_parent_emotional$pedsql_parent_emotional_mean<-round(pedsql_parent_emotional$pedsql_parent_emotional_sum/pedsql_parent_emotional$not_missing_parent_emotional)
pedsql_parent_emotional<- within(pedsql_parent_emotional, pedsql_parent_emotional_mean[pedsql_parent_emotional$not_missing_parent_emotional<1.5] <- NA)
pedsql_parent_emotional<-pedsql_parent_emotional[, grepl("person_id|redcap_event_name|mean|missing|sum", names(pedsql_parent_emotional))]

# social vars ------------------------------------------------------------
#Mean score = Sum of the items over the number of items answered
pedsql_parent_social<- pedsql_parent[, grepl("person_id|redcap_event_name|agreement|rejected|bullied", names(pedsql_parent))]
pedsql_parent_social$not_missing_parent_social<-rowSums(!is.na(pedsql_parent_social))
pedsql_parent_social$not_missing_parent_social<-pedsql_parent_social$not_missing_parent_social-2
pedsql_parent_social$pedsql_parent_social_sum<-rowSums(pedsql_parent_social[, grep("agreement|rejected|bullied", names(pedsql_parent_social))], na.rm = TRUE)
pedsql_parent_social$pedsql_parent_social_mean<-round(pedsql_parent_social$pedsql_parent_social_sum/pedsql_parent_social$not_missing_parent_social)
pedsql_parent_social<- within(pedsql_parent_social, pedsql_parent_social_mean[pedsql_parent_social$not_missing_parent_social<1.5] <- NA)
pedsql_parent_social<-pedsql_parent_social[, grepl("person_id|redcap_event_name|mean|missing|sum", names(pedsql_parent_social))]

# school vars ------------------------------------------------------------
#Mean score = Sum of the items over the number of items answered
pedsql_parent_school<- pedsql_parent[, grepl("person_id|redcap_event_name|understand|forget|schoolhomework", names(pedsql_parent))]
pedsql_parent_school$not_missing_parent_school<-rowSums(!is.na(pedsql_parent_school))
pedsql_parent_school$not_missing_parent_school<-pedsql_parent_school$not_missing_parent_school-2
pedsql_parent_school$pedsql_parent_school_sum<-rowSums(pedsql_parent_school[, grep("understand|forget|schoolhomework", names(pedsql_parent_school))], na.rm = TRUE)
pedsql_parent_school$pedsql_parent_school_mean<-round(pedsql_parent_school$pedsql_parent_school_sum/pedsql_parent_school$not_missing_parent_school)
pedsql_parent_school<- within(pedsql_parent_school, pedsql_parent_school_mean[pedsql_parent_school$not_missing_parent_school<1.5] <- NA)
pedsql_parent_school<-pedsql_parent_school[, grepl("person_id|redcap_event_name|mean|missing|sum", names(pedsql_parent_school))]

# psychosocial vars ------------------------------------------------------------
#Mean score = Sum of the items over the number of items answered
pedsql_parent_psych<- pedsql_parent[, grepl("person_id|redcap_event_name|understand|forget|schoolhomework|agreement|rejected|bullied|fear|scared|angry|sad", names(pedsql_parent))]
pedsql_parent_psych$not_missing_parent_psych<-rowSums(!is.na(pedsql_parent_psych))
pedsql_parent_psych$not_missing_parent_psych<-pedsql_parent_psych$not_missing_parent_psych-2
pedsql_parent_psych$pedsql_parent_psych_sum<-rowSums(pedsql_parent_psych[, grep("understand|forget|schoolhomework|agreement|rejected|bullied|fear|scared|angry|sad", names(pedsql_parent_psych))], na.rm = TRUE)
pedsql_parent_psych$pedsql_parent_psych_mean<-round(pedsql_parent_psych$pedsql_parent_psych_sum/pedsql_parent_psych$not_missing_parent_psych)
pedsql_parent_psych<- within(pedsql_parent_psych, pedsql_parent_psych_mean[pedsql_parent_psych$not_missing_parent_psych<5] <- NA)
pedsql_parent_psych<-pedsql_parent_psych[, grepl("person_id|redcap_event_name|mean|missing|sum", names(pedsql_parent_psych))]

# merge subscores back to raw data ----------------------------------------
pedsql<-list(pedsql, pedsql_child_total,pedsql_child_physical,pedsql_child_emotional,pedsql_child_social,pedsql_child_school,pedsql_child_psych,pedsql_parent_total,pedsql_parent_physical,pedsql_parent_emotional,pedsql_parent_social,pedsql_parent_school,pedsql_parent_psych) %>% reduce(full_join, by = c("person_id","redcap_event_name"))

# remove all missing collumns ------------------------------------------------------------
pedsql<-pedsql[, !grepl("complete|comments", names(pedsql))]
names(pedsql)[names(pedsql) == 'redcap_event_name'] <- 'redcap_event'
pedsql_unpaired<-pedsql
save(pedsql_unpaired,file="pedsql_unpaired.rda")

# merge back to aic data  ------------------------------------------------------------
AIC_no_pedsql <- AIC_no_pedsql[, grepl("person_id|redcap_event", names(AIC_no_pedsql) ) ]

pedsql <- merge(AIC_no_pedsql, pedsql,  by=c("person_id", "redcap_event"), all = TRUE)
pedsql <- pedsql[, grepl("person_id|redcap_event|pedsql|acute|int_date|strata_all", names(pedsql) ) ]
save(pedsql,file="pedsql_all.rda")

pedsql_b<-pedsql[which(pedsql$redcap_event=="visit_b_arm_1"), ]
save(pedsql_b,file="pedsql_b.rda")

# unpaired pedsql by strata -----------------------------------------------
#merge pedsql_all with david_coinfection_strata_hospitalization.rda      
load("C:/Users/amykr/Box Sync/Amy Krystosik's Files/david coinfection paper/data/david_coinfection_strata_hospitalization.rda")
colnames(david_coinfection_strata_hospitalization)[colnames(david_coinfection_strata_hospitalization)=="redcap_event_name"] <- "redcap_event"

pedsql_all_coinfection <- join(pedsql, david_coinfection_strata_hospitalization,  by=c("person_id", "redcap_event"), match = "all" , type="full")
pedsql_all_coinfection$id<-paste(pedsql_all_coinfection$person_id, pedsql_all_coinfection$redcap_event, sep="_")
pedsql_all_coinfection<-pedsql_all_coinfection[,order(colnames(pedsql_all_coinfection))]
pedsql_all_coinfection<-pedsql_all_coinfection[order(-(grepl('outcome', names(pedsql_all_coinfection)))+1L)]
pedsql_all_coinfection<-pedsql_all_coinfection[order(-(grepl('strata', names(pedsql_all_coinfection)))+1L)]
pedsql_all_coinfection<-pedsql_all_coinfection[order(-(grepl('redcap', names(pedsql_all_coinfection)))+1L)]
pedsql_all_coinfection<-pedsql_all_coinfection[order(-(grepl('person_id', names(pedsql_all_coinfection)))+1L)]
# make david a table of unpaired data -------------------------------------
pedsqlvar<-grep("mean|sum", names(pedsql_all_coinfection), value = TRUE)

pedsql_all_coinfection$strata_acute<-paste(pedsql_all_coinfection$strata, pedsql_all_coinfection$acute, sep="")
pedsql_all_coinfection<- within(pedsql_all_coinfection, strata_acute[strata_acute =="NA1"|strata_acute =="NA0"|strata_acute =="NANA"] <- NA)
pedsql_all_coinfection_acute<-pedsql_all_coinfection[which(pedsql_all_coinfection$acute==1)  , ]
# #make pairs of acute and convalescent pedsql visits. #2 weeks -12 weeks  is a convalescent visit to pair with acute. --------
pedsql_wide<-reshape(pedsql, direction = "wide", idvar = "person_id", timevar = "redcap_event", sep = "_")
pedsql_wide$elapsed.time_visit_a_arm_1 <- NA
pedsql_wide$elapsed.time_visit_b_arm_1 <- as.numeric(pedsql_wide$int_date_visit_b_arm_1 - pedsql_wide$int_date_visit_a_arm_1)
pedsql_wide$elapsed.time_visit_c_arm_1 <- as.numeric(pedsql_wide$int_date_visit_c_arm_1 - pedsql_wide$int_date_visit_b_arm_1)
pedsql_wide$elapsed.time_visit_d_arm_1 <- as.numeric(pedsql_wide$int_date_visit_d_arm_1 - pedsql_wide$int_date_visit_c_arm_1)
pedsql_wide$elapsed.time_visit_e_arm_1 <- as.numeric(pedsql_wide$int_date_visit_e_arm_1 - pedsql_wide$int_date_visit_d_arm_1)
pedsql_wide$elapsed.time_visit_f_arm_1 <- as.numeric(pedsql_wide$int_date_visit_f_arm_1 - pedsql_wide$int_date_visit_e_arm_1)
pedsql_wide$elapsed.time_visit_g_arm_1 <- as.numeric(pedsql_wide$int_date_visit_g_arm_1 - pedsql_wide$int_date_visit_f_arm_1)
pedsql_wide$elapsed.time_visit_h_arm_1 <- as.numeric(pedsql_wide$int_date_visit_h_arm_1 - pedsql_wide$int_date_visit_g_arm_1)
pedsql_wide<-pedsql_wide[order(-(grepl('elapsed.time|int_date', names(pedsql_wide)))+1L)]

pedsql_wide$pairs_ab<-ifelse(pedsql_wide$elapsed.time_visit_b_arm_1>=14 & pedsql_wide$elapsed.time_visit_b_arm_1<=84 & pedsql_wide$acute_visit_a_arm_1 ==1 & !is.na(pedsql_wide$pedsql_date_visit_a_arm_1) & pedsql_wide$acute_visit_b_arm_1==0 & !is.na(pedsql_wide$pedsql_date_visit_b_arm_1), 1, 0)    
pedsql_wide$pairs_bc<-ifelse(pedsql_wide$elapsed.time_visit_c_arm_1>=14 & pedsql_wide$elapsed.time_visit_c_arm_1<=84 & pedsql_wide$acute_visit_b_arm_1==1 & !is.na(pedsql_wide$pedsql_date_visit_b_arm_1) & pedsql_wide$acute_visit_c_arm_1==0 & !is.na(pedsql_wide$pedsql_date_visit_c_arm_1), 1, 0)    
pedsql_wide$pairs_cd<-ifelse(pedsql_wide$elapsed.time_visit_d_arm_1>=14 & pedsql_wide$elapsed.time_visit_d_arm_1<=84 & pedsql_wide$acute_visit_c_arm_1==1 & !is.na(pedsql_wide$pedsql_date_visit_c_arm_1) & pedsql_wide$acute_visit_d_arm_1==0 & !is.na(pedsql_wide$pedsql_date_visit_d_arm_1), 1, 0)    
pedsql_wide$pairs_de<-ifelse(pedsql_wide$elapsed.time_visit_e_arm_1>=14 & pedsql_wide$elapsed.time_visit_e_arm_1<=84 & pedsql_wide$acute_visit_d_arm_1==1 & !is.na(pedsql_wide$pedsql_date_visit_d_arm_1) & pedsql_wide$acute_visit_e_arm_1==0 & !is.na(pedsql_wide$pedsql_date_visit_e_arm_1), 1, 0)    
pedsql_wide$pairs_ef<-ifelse(pedsql_wide$elapsed.time_visit_f_arm_1>=14 & pedsql_wide$elapsed.time_visit_f_arm_1<=84 & pedsql_wide$acute_visit_e_arm_1==1 & !is.na(pedsql_wide$pedsql_date_visit_e_arm_1) & pedsql_wide$acute_visit_f_arm_1==0 & !is.na(pedsql_wide$pedsql_date_visit_f_arm_1), 1, 0)    
pedsql_wide$pairs_fg<-ifelse(pedsql_wide$elapsed.time_visit_g_arm_1>=14 & pedsql_wide$elapsed.time_visit_g_arm_1<=84 & pedsql_wide$acute_visit_f_arm_1==1 & !is.na(pedsql_wide$pedsql_date_visit_f_arm_1) & pedsql_wide$acute_visit_g_arm_1==0 & !is.na(pedsql_wide$pedsql_date_visit_g_arm_1), 1, 0)    
pedsql_wide$pairs_gh<-ifelse(pedsql_wide$elapsed.time_visit_h_arm_1>=14 & pedsql_wide$elapsed.time_visit_h_arm_1<=84 & pedsql_wide$acute_visit_g_arm_1==1 & !is.na(pedsql_wide$pedsql_date_visit_g_arm_1) & pedsql_wide$acute_visit_h_arm_1==0 & !is.na(pedsql_wide$pedsql_date_visit_h_arm_1), 1, 0)    

#make var for acute and follow up measures at acute visit  based on acute. 
pedsql_pairs<- pedsql_wide[, grepl("person_id|pairs|mean|acute|elapsed.time|int_date", names(pedsql_wide) ) ]
pedsql_pairs<- pedsql_pairs[, !grepl("u24", names(pedsql_pairs))]
pedsql_pairs$pair_sum <- as.integer(rowSums(pedsql_pairs[ , grep("pairs" , names(pedsql_pairs))], na.rm =TRUE))
#remove acute and put in seperate data frame
acute<- as.data.frame(pedsql_pairs[, grepl("person_id|acute", names(pedsql_pairs) ) ])
pedsql_pairs<- pedsql_pairs[, !grepl("acute", names(pedsql_pairs) ) ]

# reshape to long ---------------------------------------------------------
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
table(pedsql_pairs$pair_sum)
#reshape
#v.names=c("elapsed.time","int_date","pedsql_child_emotional_mean", "pedsql_child_physical_mean","pedsql_child_psych_mean", "pedsql_child_school_mean", "pedsql_child_social_mean", "pedsql_child_total_mean", "pedsql_parent_emotional_mean", "pedsql_parent_physical_mean","pedsql_parent_psych_mean", "pedsql_parent_school_mean", "pedsql_parent_social_mean", "pedsql_parent_total_mean") 
v.names=c("elapsed.time","int_date","pedsql_child_emotional_mean", "pedsql_child_physical_mean", "pedsql_child_psych_mean", "pedsql_child_school_mean", "pedsql_child_social_mean","pedsql_child_total_mean","pedsql_parent_emotional_mean","pedsql_parent_physical_mean", "pedsql_parent_psych_mean","pedsql_parent_school_mean", "pedsql_parent_social_mean", "pedsql_parent_total_mean")
times = c("visit_a_arm_1", "visit_b_arm_1", "visit_c_arm_1", "visit_d_arm_1", "visit_e_arm_1", "visit_f_arm_1", "visit_g_arm_1", "visit_h_arm_1")
pedsql_pairs_long<-reshape(pedsql_pairs, idvar = "person_id", varying=c(1:112),  direction = "long", timevar = "redcap_event_name", times = times, v.names=v.names )
colnames<-colnames(pedsql_pairs)

# #merge acute id's back to database -------------------------------------------------------------------
      acute_long<-reshape(acute, idvar = "person_id", varying=c(2:9),  direction = "long", timevar = "redcap_event_name", times =times, v.names="acute")
      pedsql_pairs_long <- merge(acute_long, pedsql_pairs_long,  by=c("person_id", "redcap_event_name"), all = TRUE)
      table(pedsql_pairs_long$pairs_ab==1)


      pedsql_pairs_long_ab<-pedsql_pairs_long[which((pedsql_pairs_long$pairs_ab==1 & pedsql_pairs_long$redcap_event_name=="visit_a_arm_1")| (pedsql_pairs_long$pairs_ab==1 & pedsql_pairs_long$redcap_event_name=="visit_b_arm_1")),]
      pedsql_pairs_long_ab <- pedsql_pairs_long_ab[, grepl("person_id|redcap|mean|acute|_ab|elapsed.time", names(pedsql_pairs_long_ab) ) ]

      pedsql_pairs_long_bc<-pedsql_pairs_long[which((pedsql_pairs_long$pairs_bc==1 & pedsql_pairs_long$redcap_event_name=="visit_b_arm_1")|(pedsql_pairs_long$pairs_bc==1 & pedsql_pairs_long$redcap_event_name=="visit_c_arm_1")),]
      pedsql_pairs_long_bc <- pedsql_pairs_long_bc[, grepl("person_id|redcap|mean|acute|_bc|elapsed.time", names(pedsql_pairs_long_bc) ) ]

      pedsql_pairs_long_cd<-pedsql_pairs_long[which((pedsql_pairs_long$pairs_cd==1 & pedsql_pairs_long$redcap_event_name=="visit_c_arm_1")|(pedsql_pairs_long$pairs_cd==1 & pedsql_pairs_long$redcap_event_name=="visit_d_arm_1")),]
      pedsql_pairs_long_cd <- pedsql_pairs_long_cd[, grepl("person_id|redcap|mean|acute|_cd|elapsed.time", names(pedsql_pairs_long_cd ) ) ]

      pedsql_pairs_long_de<-pedsql_pairs_long[which((pedsql_pairs_long$pairs_de==1 & pedsql_pairs_long$redcap_event_name=="visit_d_arm_1")|(pedsql_pairs_long$pairs_de==1 & pedsql_pairs_long$redcap_event_name=="visit_e_arm_1")),]
      pedsql_pairs_long_de <- pedsql_pairs_long_de[, grepl("person_id|redcap|mean|acute|_de|elapsed.time", names(pedsql_pairs_long_de ) ) ]

      pedsql_pairs_long_ef<-pedsql_pairs_long[which((pedsql_pairs_long$pairs_ef==1 & pedsql_pairs_long$redcap_event_name=="visit_e_arm_1")|(pedsql_pairs_long$pairs_ef==1 & pedsql_pairs_long$redcap_event_name=="visit_f_arm_1")),]
      pedsql_pairs_long_ef <- pedsql_pairs_long_ef[, grepl("person_id|redcap|mean|acute|_ef|elapsed.time", names(pedsql_pairs_long_ef ) ) ]

      pedsql_pairs_long_fg<-pedsql_pairs_long[which((pedsql_pairs_long$pairs_fg==1 & pedsql_pairs_long$redcap_event_name=="visit_f_arm_1")|(pedsql_pairs_long$pairs_fg==1 & pedsql_pairs_long$redcap_event_name=="visit_g_arm_1")),]
      pedsql_pairs_long_fg <- pedsql_pairs_long_fg[, grepl("person_id|redcap|mean|acute|_fg|elapsed.time", names(pedsql_pairs_long_fg ) ) ]

      pedsql_pairs_long_gh<-pedsql_pairs_long[which((pedsql_pairs_long$pairs_gh==1 & pedsql_pairs_long$redcap_event_name=="visit_g_arm_1")|(pedsql_pairs_long$pairs_gh==1 & pedsql_pairs_long$redcap_event_name=="visit_h_arm_1")),]
      pedsql_pairs_long_gh <- pedsql_pairs_long_gh[, grepl("person_id|redcap|mean|acute|_gh|elapsed.time", names(pedsql_pairs_long_gh ) ) ]
# pair the acute and conv data -------------------------------------------------------------
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
# pedsql total score at fu by time to fu. ---------------------------------
#cast to wide with acute and convalesent as the time
      pedsql_pairs_acute<-reshape(pedsql_pairs_long_bind, direction = "wide", idvar = c("person_id", "count"), timevar = "acute", sep = "_")
# change score Child ------------------------------------------------------------
      pedsql_pairs_acute$pedsql_child_total_mean_change <- pedsql_pairs_acute$pedsql_child_total_mean_conv_paired - pedsql_pairs_acute$pedsql_child_total_mean_acute_paired
      pedsql_pairs_acute$pedsql_child_total_mean_z<-(pedsql_pairs_acute$pedsql_child_total_mean_change-mean(pedsql_pairs_acute$pedsql_child_total_mean_change, na.rm = T))/sd(pedsql_pairs_acute$pedsql_child_total_mean_change, na.rm = TRUE)

      pedsql_pairs_acute$pedsql_child_school_mean_change<-pedsql_pairs_acute$pedsql_child_school_mean_conv_paired - pedsql_pairs_acute$pedsql_child_school_mean_acute_paired
      pedsql_pairs_acute$pedsql_child_school_mean_z<-(pedsql_pairs_acute$pedsql_child_school_mean_change-mean(pedsql_pairs_acute$pedsql_child_school_mean_change, na.rm = TRUE))/sd(pedsql_pairs_acute$pedsql_child_school_mean_change, na.rm = TRUE)

      pedsql_pairs_acute$pedsql_child_social_mean_change<-pedsql_pairs_acute$pedsql_child_social_mean_conv_paired - pedsql_pairs_acute$pedsql_child_social_mean_acute_paired
      pedsql_pairs_acute$pedsql_child_social_mean_z<-(pedsql_pairs_acute$pedsql_child_social_mean_change-mean(pedsql_pairs_acute$pedsql_child_social_mean_change, na.rm = TRUE))/sd(pedsql_pairs_acute$pedsql_child_social_mean_change, na.rm = TRUE)

      pedsql_pairs_acute$pedsql_child_physical_mean_change<-pedsql_pairs_acute$pedsql_child_physical_mean_conv_paired - pedsql_pairs_acute$pedsql_child_physical_mean_acute_paired
      pedsql_pairs_acute$pedsql_child_physical_mean_z<-(pedsql_pairs_acute$pedsql_child_physical_mean_change-mean(pedsql_pairs_acute$pedsql_child_physical_mean_change, na.rm = TRUE))/sd(pedsql_pairs_acute$pedsql_child_physical_mean_change, na.rm = TRUE)

      pedsql_pairs_acute$pedsql_child_emotional_mean_change<-pedsql_pairs_acute$pedsql_child_emotional_mean_conv_paired - pedsql_pairs_acute$pedsql_child_emotional_mean_acute_paired
      pedsql_pairs_acute$pedsql_child_emotional_mean_z<-(pedsql_pairs_acute$pedsql_child_emotional_mean_change-mean(pedsql_pairs_acute$pedsql_child_emotional_mean_change, na.rm = TRUE))/sd(pedsql_pairs_acute$pedsql_child_emotional_mean_change, na.rm = TRUE)

      pedsql_pairs_acute$pedsql_child_psych_mean_change<-pedsql_pairs_acute$pedsql_child_psych_mean_conv_paired - pedsql_pairs_acute$pedsql_child_psych_mean_acute_paired
      pedsql_pairs_acute$pedsql_child_psych_mean_z<-(pedsql_pairs_acute$pedsql_child_psych_mean_change-mean(pedsql_pairs_acute$pedsql_child_psych_mean_change, na.rm = TRUE))/sd(pedsql_pairs_acute$pedsql_child_psych_mean_change, na.rm = TRUE)

# change score parent ------------------------------------------------------------
      pedsql_pairs_acute$pedsql_parent_total_mean_change<-pedsql_pairs_acute$pedsql_parent_total_mean_conv_paired - pedsql_pairs_acute$pedsql_parent_total_mean_acute_paired
      pedsql_pairs_acute$pedsql_parent_total_mean_z<-(pedsql_pairs_acute$pedsql_parent_total_mean_change-mean(pedsql_pairs_acute$pedsql_parent_total_mean_change, na.rm = TRUE))/sd(pedsql_pairs_acute$pedsql_parent_total_mean_change, na.rm = TRUE)

      pedsql_pairs_acute$pedsql_parent_school_mean_change<-pedsql_pairs_acute$pedsql_parent_school_mean_conv_paired - pedsql_pairs_acute$pedsql_parent_school_mean_acute_paired
      pedsql_pairs_acute$pedsql_parent_school_mean_z<-(pedsql_pairs_acute$pedsql_parent_school_mean_change-mean(pedsql_pairs_acute$pedsql_parent_school_mean_change, na.rm = TRUE))/sd(pedsql_pairs_acute$pedsql_parent_school_mean_change, na.rm = TRUE)
 
      pedsql_pairs_acute$pedsql_parent_social_mean_change<-pedsql_pairs_acute$pedsql_parent_social_mean_conv_paired - pedsql_pairs_acute$pedsql_parent_social_mean_acute_paired
      pedsql_pairs_acute$pedsql_parent_social_mean_z<-(pedsql_pairs_acute$pedsql_parent_social_mean_change-mean(pedsql_pairs_acute$pedsql_parent_social_mean_change, na.rm = TRUE))/sd(pedsql_pairs_acute$pedsql_parent_social_mean_change, na.rm = TRUE)

      pedsql_pairs_acute$pedsql_parent_physical_mean_change<-pedsql_pairs_acute$pedsql_parent_physical_mean_conv_paired - pedsql_pairs_acute$pedsql_parent_physical_mean_acute_paired
      pedsql_pairs_acute$pedsql_parent_physical_mean_z<-(pedsql_pairs_acute$pedsql_parent_physical_mean_change-mean(pedsql_pairs_acute$pedsql_parent_physical_mean_change, na.rm = TRUE))/sd(pedsql_pairs_acute$pedsql_parent_physical_mean_change, na.rm = TRUE)

      pedsql_pairs_acute$pedsql_parent_emotional_mean_change<-pedsql_pairs_acute$pedsql_parent_emotional_mean_conv_paired - pedsql_pairs_acute$pedsql_parent_emotional_mean_acute_paired
      pedsql_pairs_acute$pedsql_parent_emotional_mean_z<-(pedsql_pairs_acute$pedsql_parent_emotional_mean_change-mean(pedsql_pairs_acute$pedsql_parent_emotional_mean_change, na.rm = TRUE))/sd(pedsql_pairs_acute$pedsql_parent_emotional_mean_change, na.rm = TRUE)

      pedsql_pairs_acute$pedsql_parent_psych_mean_change<-pedsql_pairs_acute$pedsql_parent_psych_mean_conv_paired - pedsql_pairs_acute$pedsql_parent_psych_mean_acute_paired
      pedsql_pairs_acute$pedsql_parent_psych_mean_z<-(pedsql_pairs_acute$pedsql_parent_psych_mean_change-mean(pedsql_pairs_acute$pedsql_parent_psych_mean_change, na.rm = TRUE))/sd(pedsql_pairs_acute$pedsql_parent_psych_mean_change, na.rm = TRUE)
      
      summary(pedsql_pairs_acute$pedsql_parent_psych_mean_z)
      plyr::count(!is.na(pedsql_pairs_acute$pedsql_parent_psych_mean_z))
      save(pedsql_pairs_acute,file="C:/Users/amykr/Box Sync/Amy Krystosik's Files/david coinfection paper/data/pedsql_pairs_acute.rda")#save for use in others