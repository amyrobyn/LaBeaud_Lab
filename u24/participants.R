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

vars<-grep("person_id|name|withdrew_why|funny|cohort|site|child_number|participant_status|city|patient_info|name|phonenumber|u24_village_other|u24_when_hospitalized|other|date", names(u24_results), value = TRUE, invert = TRUE)

library(tableone)

tableOne<-CreateTableOne(data=u24_results, vars=vars, strata = "u24_exposure_strata")
table1 <- print(tableOne, quote = FALSE, noSpaces = TRUE, printToggle = FALSE)

setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/secure- u24 participants/data")
write.csv(table1, file = "table1.csv")

# subjects lists. ------------------------------------------------------------
load("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long/R01_lab_results.clean.rda")
R01_lab_results[R01_lab_results==98]<-NA
R01_lab_results$result_microscopy_malaria_kenya
R01_lab_results$malaria_results
  R01_lab_results$id_cohort<-substr(R01_lab_results$person_id, 2, 2)
  R01_lab_results$id_city<-substr(R01_lab_results$person_id, 1, 1)
  R01_lab_results$date_tested_pcr_chikv_kenya<-as.Date(as.character(as.factor(R01_lab_results$date_tested_pcr_chikv_kenya)),"%Y-%m-%d")
  

# those exposed in msambweni. we had so many with any exposure that i cut it down to those with documented incident infection. ---------------------------------------------------------------
table(R01_lab_results$u24_participant)
  
      u24_all<- R01_lab_results[, !grepl("u24", names(R01_lab_results))]
      u24_all<- u24_all[which(u24_all$id_city =="M"|u24_all$id_city =="G"|u24_all$id_city=="L")  , ]
      u24_all$chikv_outbreak<-NA
      u24_all <- within(u24_all, chikv_outbreak[u24_all$site=="C" & (u24_all$int_date>="2017-10-01"|u24_all$date_tested_pcr_chikv_kenya>="2017-10-01")&u24_all$infected_chikv_stfd] <-1)
      ggplot (u24_all, aes (x = int_date, y = chikv_outbreak)) +geom_point() +scale_x_date(date_breaks = "1 month", date_labels =  "%b %Y") +theme(axis.text.x=element_text(angle=60, hjust=1),text = element_text(size = 20)) + xlab("Month-Year") + ylab("CHIKV Outbreak") 

#      u24_all<-u24_all %>%remove_empty_cols()
      u24_all_wide<-reshape(u24_all, direction = "wide", idvar = "person_id", timevar = "redcap_event_name", sep = ".")
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
      u24_all_wide$pcr_chikv_exposure_sum<-rowSums(u24_all_wide[, grep("result_pcr_chikv|chikv_result_ufi", names(u24_all_wide))], na.rm = TRUE)
      table(u24_all_wide$pcr_chikv_exposure_sum)
      
      

#u24_all_wide<-    u24_all_wide %>%        remove_empty_cols()
    u24_all_wide<- u24_all_wide[, grepl("person_id|age|gender|prnt_result_chikv|prnt_result_denv|infected|exposure|prnt_interpretation_flavi___1|prnt_interpretation_alpha___2|result_igg_denv_stfd|infected_denv_stfd|infected_chikv_stfd|result_igg_chikv_stfd|result_igg_denv_stfd|name|dob|phone|village|date_of_birth|interview_date|result_pcr_|result_ufi|chikv_outbreak", names(u24_all_wide))]
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
u24_all_wide_matched<- u24_all_wide_matched[, grepl("person_id|redcap_event_name|prnt_confirmed|exposure|result_|interview_date|u24_strata|case_control", names(u24_all_wide_matched))]
u24_all_wide_matched<-u24_all_wide_matched[order(-(grepl('person_id|redcap_event_name|prnt_confirmed|exposure|result_|interview_date', names(u24_all_wide_matched)))+1L)]
u24_all_wide_matched<-u24_all_wide_matched[order(-(grepl('u24_strata|case_control', names(u24_all_wide_matched)))+1L)]
#u24_all_wide_matched<-u24_all_wide_matched %>%remove_empty_cols()

u24_all_wide_matched2<-u24_all_wide_matched[,order(colnames(u24_all_wide_matched))]

u24_all_wide_matched2<-u24_all_wide_matched2[order(-(grepl('_visit_g_arm_1|_visit_h_arm_1|_visit_f_arm_1|_visit_e_arm_1|_visit_d_arm_1|_visit_c_arm_1|_visit_b_arm_1|_visit_a_arm_1', names(u24_all_wide_matched2)))+1L)]
u24_all_wide_matched2<-u24_all_wide_matched2[order(-(grepl('person_id|case_control|incident_prnt_u24_strata|u24_strata|denv_exposure_sum|incident_prnt_chikv_exposure_sum|incident_prnt_denv_exposure_sum|pcr_chikv_exposure_sum|pcr_denv_exposure_sum|exposure_sum|prnt_confirmed|chikv_outbreak', names(u24_all_wide_matched2)))+1L)]

times = c("visit_a_arm_1", "visit_b_arm_1", "visit_c_arm_1", "visit_d_arm_1", "visit_e_arm_1", "visit_f_arm_1", "visit_g_arm_1", "visit_h_arm_1")
u24_all_matched2<-reshape(u24_all_wide_matched2, idvar = "person_id", varying=c(14:205),  direction = "long", timevar = "redcap_event_name", times = times)

u24_all_matched2$int_date = u24_all_matched2$interview_date
u24_all_matched2$int_date[!is.na(u24_all_matched2$interview_date_aic)] = u24_all_matched2$interview_date_aic[!is.na(u24_all_matched2$interview_date_aic)]

u24_all<-merge(u24_all_matched2,u24_results, by = "person_id", all = TRUE)

u24_all<-u24_all[order(-(grepl('result_pcr|int_date|u24_interview_date', names(u24_all)))+1L)]
u24_all<-u24_all[order(-(grepl('person_id|redcap_event_name', names(u24_all)))+1L)]

table(u24_all$result_pcr_chikv_kenya)

write.csv(as.data.frame(u24_all), "u24_all.csv", na = "")

# old  --------------------------------------------------------------------
u24_all_wide_matched$id_cohort<-substr(u24_all_wide_matched$person_id, 2, 2)

u24_all_wide_matched_aic<- u24_all_wide_matched[which(u24_all_wide_matched$id_cohort=="F" )  , ]
u24_all_wide_matched_hcc<- u24_all_wide_matched[which(u24_all_wide_matched$id_cohort=="C" )  , ]

#merge with names from francis.
u24_aic<-readxl::read_xls("C:/Users/amykr/Box Sync/Amy Krystosik's Files/secure- u24 participants/U24_AIC_participants_edited.xls")
u24_hcc<-readxl::read_xls("C:/Users/amykr/Box Sync/Amy Krystosik's Files/secure- u24 participants/U24_HCC_participants.xls")
u24_aic<-merge(u24_aic, u24_all_wide_matched_aic, by ="person_id", all.y =  TRUE)
u24_hcc<-merge(u24_hcc, u24_all_wide_matched_hcc, by ="person_id", all.y = TRUE)

u24_hcc<-u24_hcc[order(-(grepl('u24_strata|prnt_confirmed|case_control|exposure_sum', names(u24_hcc)))+1L)]
u24_aic<-u24_aic[order(-(grepl('u24_strata|prnt_confirmed|case_control|exposure_sum', names(u24_aic)))+1L)]

#export list with id's
write.csv(as.data.frame(u24_hcc), "u24_hcc_participant_list.csv", na = "")
write.csv(as.data.frame(u24_aic), "u24_aic_participant_list.csv", na = "")
