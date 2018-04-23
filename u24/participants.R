# packages -----------------------------------------------------------------
#install.packages(c("REDCapR", "mlr"))
#install.packages(c("dummies"))
library(janitor)
library(dplyr)
library(plyr)
library(redcapAPI)
library(REDCapR)
library(ggplot2)
# get data -----------------------------------------------------------------
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long")
Redcap.token <- readLines("Redcap.token.R01.txt") # Read API token from folder
REDcap.URL  <- 'https://redcap.stanford.edu/api/'
rcon <- redcapConnection(url=REDcap.URL, token=Redcap.token)

#export data from redcap to R (must be connected via cisco VPN)
#u24_results_labels <- redcap_read(redcap_uri  = REDcap.URL, token = Redcap.token, batch_size = 300,raw_or_label="label")$data
#u24_results <- redcap_read(redcap_uri  = REDcap.URL, token = Redcap.token, batch_size = 300)$data
#u24_results<- u24_results[which(u24_results$redcap_event_name=="visit_u24_arm_1"& u24_results$u24_participant==1)  , ]
#u24_results<-u24_results %>%remove_empty_cols()
#table(u24_results$redcap_event_name)
#library(beepr)
#beep(sound=4)

currentDate <- Sys.Date() 
FileName <- paste("u24_results",currentDate,".rda",sep=" ") 
#save(u24_results,file=FileName)
load(FileName)


u24_results$u24_date_of_birth<-as.Date(u24_results$u24_date_of_birth)
u24_results$u24_interview_date<-as.Date(u24_results$u24_interview_date)
u24_results$u24_when_dengue<-as.Date(u24_results$u24_when_dengue)
u24_results$pedsql_date_parent<-as.Date(u24_results$pedsql_date_parent)
u24_results$pedsql_date<-as.Date(u24_results$pedsql_date)
u24_results$pedsql_date<-as.Date(u24_results$pedsql_date)

u24_results$time_blood_drawn <- strptime(u24_results$time_blood_drawn, "%Y-%m-%d %H:%M")
u24_results$time_on_machine <- strptime(u24_results$time_on_machine, "%Y-%m-%d %H:%M")
u24_results$time_off_machine <- strptime(u24_results$time_off_machine, "%Y-%m-%d %H:%M")

u24_results$time_to_machine<-u24_results$time_blood_drawn-u24_results$time_on_machine

#u24_results<-    u24_results %>%        remove_empty_cols()
vars<-grep("person_id|name|withdrew_why|funny|cohort|site|child_number|participant_status|city|patient_info|name|phonenumber|u24_village_other|u24_when_hospitalized|other|date|aliquot|photo", names(u24_results), value = TRUE, invert = TRUE)

# variable v1 is coded 1, 2 or 3
# we want to attach value labels 1=red, 2=blue, 3=green

u24_results$u24_gender <- factor(u24_results$u24_gender, levels = c(0,1), labels = c("male", "female"))
u24_results$result_stool_test_ <- factor(u24_results$result_stool_test_, levels = c(0,1,98,99), labels = c("Absent", "Present","Repeat","Not Performed"))
u24_results$result_stool_test_2 <- factor(u24_results$result_stool_test_2, levels = c(0,1,98,99), labels = c("Absent", "Present","Repeat","Not Performed"))
u24_results$result_stool_test_3 <- factor(u24_results$result_stool_test_3, levels = c(0,1,98,99), labels = c("Absent", "Present","Repeat","Not Performed"))
u24_results$result_stool_test_4 <- factor(u24_results$result_stool_test_4, levels = c(0,1,98,99), labels = c("Absent", "Present","Repeat","Not Performed"))
u24_results$result_stool_test_5 <- factor(u24_results$result_stool_test_5, levels = c(0,1,98,99), labels = c("Absent", "Present","Repeat","Not Performed"))
u24_results$result_stool_test_6 <- factor(u24_results$result_stool_test_6, levels = c(0,1,98,99), labels = c("Absent", "Present","Repeat","Not Performed"))
u24_results$result_urine_test_kenya <- factor(u24_results$result_urine_test_kenya, levels = c(0,1,98,99), labels = c("Negative", "Positive","Repeat","Not Performed"))
u24_results$result_microscopy_malaria_kenya <- factor(u24_results$result_microscopy_malaria_kenya, levels = c(0,1,98,99), labels = c("Negative", "Positive","Repeat","Not Performed"))
u24_results$u24_exposure_strata <- ordered(u24_results$u24_exposure_strata, levels = c(0,1,2,3), labels = c("control", "chikv","denv", "both"))

library(expss)
u24_results = apply_labels(u24_results,
                      result_stool_test_ = "Hookworm",
                      result_stool_test_2 = "Trichuris trichiura",
                      result_stool_test_3 = "Ascaris lumbricoides",
                      result_stool_test_4 = "E. histolytica",
                      result_stool_test_5 = "Giardia lamblia",
                      result_stool_test_6 = "Strongyloides",
                      result_urine_test_kenya = "Result Schistosoma haematobium"
                      )

library(tableone)
use_labels(u24_results, {tableOne<-CreateTableOne(data=u24_results, vars=vars, strata = "u24_exposure_strata")})
table1 <- print(tableOne, quote = FALSE, exact=vars, nonnormal=vars,noSpaces = TRUE, printToggle = FALSE)

setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/secure- u24 participants/data")
write.csv(table1, file = "u24_table1.csv")

# subjects lists. ------------------------------------------------------------
load("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long/R01_lab_results.clean.rda")
R01_lab_results[R01_lab_results==98]<-NA
R01_lab_results$result_microscopy_malaria_kenya
R01_lab_results$malaria_results
  R01_lab_results$id_cohort<-substr(R01_lab_results$person_id, 2, 2)
  R01_lab_results$id_city<-substr(R01_lab_results$person_id, 1, 1)
  R01_lab_results$date_tested_pcr_chikv_kenya<-as.Date(as.character(as.factor(R01_lab_results$date_tested_pcr_chikv_kenya)),"%Y-%m-%d")
table(R01_lab_results$id_city)
  R01_lab_results$chikv_outbreak<-NA
  R01_lab_results <- within(R01_lab_results, chikv_outbreak[(R01_lab_results$id_city=="G"|R01_lab_results$id_city=="L"|R01_lab_results$id_city=="M") & (R01_lab_results$int_date>="2017-10-01"|R01_lab_results$date_tested_pcr_chikv_kenya>="2017-10-01")&R01_lab_results$infected_chikv_stfd] <-1)
  ggplot(R01_lab_results, aes (x = int_date, y = chikv_outbreak)) +geom_point() +scale_x_date(date_breaks = "1 month", date_labels =  "%b %Y") +theme(axis.text.x=element_text(angle=60, hjust=1),text = element_text(size = 20)) + xlab("Month-Year") + ylab("CHIKV Outbreak") 
  

# those exposed in msambweni. we had so many with any exposure that i cut it down to those with documented incident infection. ---------------------------------------------------------------
      u24_all_wide<-reshape(R01_lab_results, direction = "wide", idvar = "person_id", timevar = "redcap_event_name", sep = ".")
#all visits must be negative to be a control.
      u24_all_wide$exposure_sum<-rowSums(u24_all_wide[, grep("prnt_interpretation_flavi___1|prnt_interpretation_alpha___2|result_igg_denv_stfd|infected_denv_stfd|infected_chikv_stfd|result_igg_chikv_stfd|result_igg_denv_stfd", names(u24_all_wide))], na.rm = TRUE)
      u24_all_wide$incident_prnt_denv_exposure_sum<-rowSums(u24_all_wide[, grep("prnt_interpretation_flavi___1|infected_denv_stfd", names(u24_all_wide))], na.rm = TRUE)
      u24_all_wide$incident_prnt_chikv_exposure_sum<-rowSums(u24_all_wide[, grep("prnt_interpretation_alpha___2|infected_chikv_stfd", names(u24_all_wide))], na.rm = TRUE)
      table(u24_all_wide$incident_prnt_chikv_exposure_sum)
      table(u24_all_wide$incident_prnt_denv_exposure_sum)
      
      u24_all_wide$denv_exposure_sum<-rowSums(u24_all_wide[, grep("prnt_interpretation_flavi___1|infected_denv_stfd|result_igg_denv_stfd", names(u24_all_wide))], na.rm = TRUE)
      u24_all_wide$chikv_exposure_sum<-rowSums(u24_all_wide[, grep("prnt_interpretation_alpha___2|infected_chikv_stfd|result_igg_chikv_stfd", names(u24_all_wide))], na.rm = TRUE)
      table(u24_all_wide$denv_exposure_sum,u24_all_wide$chikv_exposure_sum)
      table(u24_all_wide$chikv_exposure_sum)
      table(u24_all_wide$denv_exposure_sum)

      u24_all_wide$pcr_denv_exposure_sum<-rowSums(u24_all_wide[, grep("result_pcr_denv|denv_result_ufi", names(u24_all_wide))], na.rm = TRUE)
      table(u24_all_wide$pcr_denv_exposure_sum)
      u24_all_wide$pcr_chikv_exposure_sum<-rowSums(u24_all_wide[, grep("result_pcr_chikv|$chikv_result_ufi", names(u24_all_wide))], na.rm = TRUE)
      table(u24_all_wide$pcr_chikv_exposure_sum)
      u24_all_wide$chikv_outbreak_sum<-rowSums(u24_all_wide[, grep("chikv_outbreak", names(u24_all_wide))], na.rm = TRUE)
      table(u24_all_wide$chikv_outbreak_sum)
      
      

#u24_all_wide<-    u24_all_wide %>%        remove_empty_cols()
    u24_all_wide<- u24_all_wide[, grepl("person_id|age|gender|prnt_result_chikv|prnt_result_denv|infected|exposure|prnt_interpretation_flavi___1|prnt_interpretation_alpha___2|result_igg_denv_stfd|infected_denv_stfd|infected_chikv_stfd|result_igg_chikv_stfd|result_igg_denv_stfd|name|dob|phone|village|date_of_birth|interview_date|result_pcr_|result_ufi|chikv_outbreak|sum", names(u24_all_wide))]
    u24_all_wide$incident_prnt_u24_strata<-NA
    u24_all_wide <- within(u24_all_wide, incident_prnt_u24_strata[u24_all_wide$exposure_sum ==0] <- "control")
    u24_all_wide <- within(u24_all_wide, incident_prnt_u24_strata[u24_all_wide$incident_prnt_chikv_exposure_sum >=1] <- "chikv")
    u24_all_wide <- within(u24_all_wide, incident_prnt_u24_strata[u24_all_wide$incident_prnt_denv_exposure_sum >=1] <- "denv")
    u24_all_wide <- within(u24_all_wide, incident_prnt_u24_strata[u24_all_wide$incident_prnt_chikv_exposure_sum>=1 & u24_all_wide$incident_prnt_denv_exposure_sum ==1] <- "both")
    table(u24_all_wide$incident_prnt_u24_strata)

    u24_all_wide$u24_strata<-NA
    u24_all_wide <- within(u24_all_wide, u24_strata[u24_all_wide$exposure_sum ==0] <- "control")
    u24_all_wide <- within(u24_all_wide, u24_strata[u24_all_wide$chikv_exposure_sum >=1] <- "chikv")
    u24_all_wide <- within(u24_all_wide, u24_strata[u24_all_wide$denv_exposure_sum >=1] <- "denv")
    u24_all_wide <- within(u24_all_wide, u24_strata[u24_all_wide$chikv_exposure_sum>=1 & u24_all_wide$denv_exposure_sum >=1] <- "both")
    table(u24_all_wide$u24_strata)

        
    u24_all_wide$case_control<-NA
    u24_all_wide <- within(u24_all_wide, case_control[u24_all_wide$u24_strata =="control" & !is.na(u24_all_wide$age.visit_a_arm_1) & !is.na(u24_all_wide$gender_all.visit_a_arm_1)] <- "control")
    u24_all_wide <- within(u24_all_wide, case_control[(u24_all_wide$u24_strata =="chikv"|u24_all_wide$u24_strata =="denv"|u24_all_wide$u24_strata =="both") & (!is.na(u24_all_wide$age.visit_a_arm_1) & !is.na(u24_all_wide$gender_all.visit_a_arm_1))] <- "case")
    table(u24_all_wide$case_control, u24_all_wide$u24_strata, exclude = NULL)

## now look at the group properties:
  boxplot(u24_all_wide$age.visit_a_arm_1 ~ u24_all_wide$u24_strata)
  boxplot(u24_all_wide$age.visit_a_arm_1 ~ u24_all_wide$case_control)
  barplot(table(u24_all_wide$gender_all.visit_a_arm_1, u24_all_wide$u24_strata), beside = TRUE)
  barplot(table(u24_all_wide$gender_all.visit_a_arm_1, u24_all_wide$case_control))

#install.packages("e1071")
matchControls<- u24_all_wide[which(!is.na(u24_all_wide$gender_all.visit_a_arm_1)&!is.na(u24_all_wide$age.visit_a_arm_1)&!is.na(u24_all_wide$case_control))  , ]

matchControls<- matchControls[c("gender_all.visit_a_arm_1","age.visit_a_arm_1","case_control","person_id")]
library("MatchIt")
set.seed(1234)
matchControls <- within(matchControls, case_control[case_control =="control"] <- 0)
matchControls <- within(matchControls, case_control[case_control =="case"] <- 1)
matchControls$case_control<-as.numeric(matchControls$case_control)

    match.it <- matchit(matchControls$case_control ~ matchControls$gender_all.visit_a_arm_1 + matchControls$age.visit_a_arm_1, data = matchControls, method="nearest", ratio=1)
    a <- summary(match.it)
    library("knitr")
    kable(a$sum.matched[c(1,2,4)], digits = 2, align = 'c', 
          caption = 'Table 3: Summary of balance for matched data')
    plot(match.it, type = 'jitter', interactive = FALSE)
    df.match <- match.data(match.it)[1:ncol(matchControls)]
    df.match<-as.data.frame(df.match)
boxplot(df.match$age.visit_a_arm_1 ~ df.match$case_control)
barplot(table(df.match$gender_all.visit_a_arm_1, df.match$case_control))

u24_all_wide_matched<-merge(df.match, u24_all_wide, by ="person_id", all.x = TRUE)

u24_all_wide_matched$prnt_confirmed<-rowSums(u24_all_wide_matched[, grep("prnt_interpretation_flavi___1|prnt_interpretation_alpha___2", names(u24_all_wide_matched))], na.rm = TRUE)
table(u24_all_wide_matched$u24_strata,u24_all_wide_matched$prnt_confirmed)
u24_all_wide_matched<- u24_all_wide_matched[, !grepl("patient_informatio_arm_1", names(u24_all_wide_matched))]
u24_all_wide_matched<- u24_all_wide_matched[, grepl("person_id|redcap_event_name|prnt_confirmed|exposure|result_|interview_date|u24_strata|case_control|outbreak_sum|age|gender", names(u24_all_wide_matched))]
u24_all_wide_matched<-u24_all_wide_matched[order(-(grepl('person_id|redcap_event_name|prnt_confirmed|exposure|result_|interview_date', names(u24_all_wide_matched)))+1L)]
u24_all_wide_matched<-u24_all_wide_matched[order(-(grepl('u24_strata|case_control', names(u24_all_wide_matched)))+1L)]

# merge with u24 current results ------------------------------------------
u24_all<-merge(u24_all_wide_matched, u24_results, by = "person_id", all = TRUE)

u24_all<-u24_all[order(-(grepl('result_pcr_chikv|result_pcr_denv|int_date|u24_interview_date', names(u24_all)))+1L)]
u24_all<-u24_all[order(-(grepl('sum', names(u24_all)))+1L)]
u24_all<-u24_all[order(-(grepl('strata|priority|outbreak', names(u24_all)))+1L)]
u24_all<-u24_all[order(-(grepl('person_id|redcap_event_name|u24_participant', names(u24_all)))+1L)]
write.csv(as.data.frame(u24_all), "u24_all.csv", na = "")

u24_all$id_city<-substr(u24_all$person_id, 1, 1)
u24_priority_list<- u24_all[which(!is.na(u24_all$u24_strata) & is.na(u24_all$u24_participant) & (u24_all$id_city=="M"|u24_all$id_city=="L"|u24_all$id_city=="G"||u24_all$id_city=="U"))  , ]

u24_priority_list<-u24_priority_list %>%remove_empty_cols()
u24_priority_list$new_priority_list<-NA
u24_priority_list$new_priority_list
u24_priority_list <- within(u24_priority_list, new_priority_list[u24_priority_list$chikv_outbreak_sum==1] <- 1)

write.csv(as.data.frame(u24_priority_list), "u24_priority_list_ukunda.csv", na = "")
prioritized_list<-read.csv("prioritized list.csv")
list<-read.csv("list by strata and village.csv")

prioritized_list_names<-merge(list,prioritized_list, by="person_id",all.y = T)
write.csv(as.data.frame(prioritized_list_names), "prioritized_list_names.csv", na = "")

table(u24_all$chikv_outbreak_sum,u24_all$u24_participant)
u24_participant<- u24_all[which(u24_all$u24_participant==1)  , ]
vars=c("sample_completed_protocol","chikv_outbreak_sum","pcr_denv_exposure_sum","pcr_chikv_exposure_sum","u24_strata","result_stool_test_","result_stool_test_2","result_stool_test_3","result_stool_test_4","result_stool_test_5","result_stool_test_6","u24_age_calc","u24_gender","result_urine_test_kenya","incident_prnt_denv_exposure_sum","incident_prnt_chikv_exposure_sum")
factorvars=c("sample_completed_protocol","chikv_outbreak_sum","pcr_denv_exposure_sum","pcr_chikv_exposure_sum","u24_strata","result_stool_test_","result_stool_test_2","result_stool_test_3","result_stool_test_4","result_stool_test_5","result_stool_test_6","u24_gender","result_urine_test_kenya","incident_prnt_denv_exposure_sum","incident_prnt_chikv_exposure_sum")

tableOne_u24<-CreateTableOne(data=u24_participant, vars=vars, factorVars=factorvars, strata = "sample_completed_protocol")
tableOne_u24_enrolled <- print(tableOne_u24, quote = FALSE, exact=vars, nonnormal=vars,noSpaces = TRUE, printToggle = FALSE)
write.csv(tableOne_u24_enrolled, file = "tableOne_u24_enrolled.csv")

u24_participant_complete<- u24_all[which(u24_all$sample_completed_protocol==1)  , ]
use_labels(u24_results, {tableOne<-CreateTableOne(data=u24_results, vars=vars, strata = "u24_exposure_strata")})
use_labels(u24_participant_complete, table(result_stool_test_4, result_stool_test_5)) 
cro(u24_participant_complete$result_stool_test_4, u24_participant_complete$result_stool_test_5)

tableOne_u24_complete<-CreateTableOne(data=u24_participant_complete, vars=vars, factorVars=factorvars, strata = "u24_strata")
tableOne_u24_complete <- print(tableOne_u24_complete, quote = FALSE, exact=vars, nonnormal=vars,noSpaces = TRUE, printToggle = FALSE)
write.csv(tableOne_u24_complete, file = "tableOne_u24_complete.csv")