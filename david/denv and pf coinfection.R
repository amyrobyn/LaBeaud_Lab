library("tableone")
library("plyr")
library("dplyr")
#install.packages("stringr")
library(stringr)
# import data -------------------------------------------------------------
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/david coinfection paper/data")
load("R01_lab_results.david.coinfection.dataset.rda")#load data that has been cleaned previously#final data set made on 11/16/18 for david conifection paper.
AIC<- R01_lab_results[which(R01_lab_results$int_date<="2018-11-16")  , ]#subset to visits before (june 30) november 16 2018.
AIC<- AIC[which(AIC$redcap_event_name!="patient_informatio_arm_1"&AIC$redcap_event_name!="visit_a2_arm_1"&AIC$redcap_event_name!="visit_b2_arm_1"&AIC$redcap_event_name!="visit_c2_arm_1"&AIC$redcap_event_name!="visit_d2_arm_1"&AIC$redcap_event_name!="visit_u24_arm_1"),]
AIC<-AIC[which(AIC$Cohort=="AIC"), ]
patients_reviewed<-sum(n_distinct(AIC$person_id, na.rm = FALSE))

  AIC$id_cohort<-substr(AIC$person_id, 2, 2)
  AIC$id_city<-substr(AIC$person_id, 1, 1)
  table(AIC$redcap_event_name,AIC$id_city)

# define acute febrile illness ------------------------------------------------------------------------
    source("C:/Users/amykr/Documents/GitHub/lebeaud_lab/david/define acute febrile illness.r")
    table(AIC$acute)
# count number per group for subject diagram------------------------------------------------------------------------
  AIC<- AIC[which(AIC$redcap_event_name=="visit_a_arm_1"|AIC$redcap_event_name=="visit_b_arm_1")  , ]
  sum(n_distinct(AIC$person_id, na.rm = FALSE)) #2276
  
  n<-sum(n_distinct(R01_lab_results$person_id, na.rm = FALSE)) #10,899 patients reviewed
  AIC<-AIC[which((AIC$acute==1&AIC$redcap_event_name=="visit_a_arm_1")|(AIC$acute!=1&AIC$redcap_event_name=="visit_b_arm_1")), ]
  aic_n<-sum(n_distinct(AIC$person_id, na.rm = FALSE)) #2,205 patients included in study (aic, west)
  table(AIC$redcap_event_name)
  afi<-  sum(AIC$acute==1, na.rm = TRUE)#2203 afi's

#denv case defination------------------------------------------------------------------------
  source("C:/Users/amykr/Documents/GitHub/lebeaud_lab/david/strata definitions.R")
  table(AIC$strata_all)
  
#save dataset------------------------------------------------------------------------
  save(AIC,file="AIC.rda")

##merge with paired pedsql data (acute and convalescent)-----------------------------------------------------------------------
  source("C:/Users/amykr/Documents/GitHub/lebeaud_lab/david/calculate pedsql scores and pair.r")
  table(AIC$outcome_hospitalized)
  
  names(pedsql_pairs_acute)[names(pedsql_pairs_acute) == 'redcap_event_name_acute_paired'] <- 'redcap_event_name'
  names(AIC)[names(AIC) == 'redcap_event'] <- 'redcap_event_name'
  
  AIC_pedsql <- join(AIC, pedsql_pairs_acute,  by=c("person_id", "redcap_event_name"), match = "first" , type="full")
  AIC_pedsql<-AIC_pedsql[order(-(grepl('person_id|redcap|pedsql_', names(AIC_pedsql)))+1L)]
  
  AIC<-AIC_pedsql
  AIC<-AIC[order(-(grepl('person_id|redcap|pedsql_', names(AIC)))+1L)]

  # outcome hospitalized ----------------------------------------------------
  AIC$outcome_hospitalized<-as.numeric(as.character(AIC$outcome_hospitalized))
  AIC <- within(AIC, outcome_hospitalized[outcome_hospitalized==8] <-1 )
  table(AIC$outcome_hospitalized)

# demographics, ses, and mosquito indices ------------------------------------------------------------
source("C:/Users/amykr/Documents/GitHub/lebeaud_lab/david/demographics, ses, and mosquito indices.r")

# physcial exam -----------------------------------------------------------
source("C:/Users/amykr/Documents/GitHub/lebeaud_lab/david/acute visit outcomes- pe, pedsql.R")
  
# symptoms table ----------------------------------------------------------
  source("C:/Users/amykr/Documents/GitHub/lebeaud_lab/david/symptoms.R")

# save and export data ----------------------------------------------------
    save(AIC,file="david_denv_malaria_cohort.rda")
#export to csv
    setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/david coinfection paper/data")
    f <- "david_denv_pf_cohort.csv"
    write.csv(as.data.frame(AIC), f )
# save and export strata and hospitalization data ----------------------------------------------------
    david_coinfection_strata_hospitalization<-AIC[, grepl("person_id|redcap_event_name|strata|outcome_hospitalized|outcome|gender_all|ses_sum|mom_highest_level_education", names(AIC))]
    save(david_coinfection_strata_hospitalization,file="C:/Users/amykr/Box Sync/Amy Krystosik's Files/david coinfection paper/data/david_coinfection_strata_hospitalization.rda")

    table(AIC$strata_all)