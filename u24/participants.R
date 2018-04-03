library(janitor)
library(dplyr)
library(plyr)
load("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long/R01_lab_results.clean.rda")
R01_lab_results[R01_lab_results==98]<-NA
R01_lab_results$result_microscopy_malaria_kenya
R01_lab_results$malaria_results



R01_lab_results[R01_lab_results$person_id=="UF0413",  "malaria_results"]
R01_lab_results[R01_lab_results$person_id=="UF0413",  "result_microscopy_malaria_kenya"]

R01_lab_results[R01_lab_results$person_id=="MF0061",  "date_of_birth_aic"]

R01_lab_results[R01_lab_results$person_id=="MF0006",  "date_of_birth"]

  R01_lab_results$id_cohort<-substr(R01_lab_results$person_id, 2, 2)
  R01_lab_results$id_city<-substr(R01_lab_results$person_id, 1, 1)

# those exposed in msambweni. we had so many with any exposure that i cut it down to those with documented incident infection. ---------------------------------------------------------------
      u24_all<- R01_lab_results[, !grepl("date|dob|u24", names(R01_lab_results))]
      u24_all<- u24_all[which(u24_all$id_city =="M"|u24_all$id_city =="G"|u24_all$id_city=="L")  , ]
      u24_all<-    u24_all %>%
        remove_empty_cols()
      u24_all_wide<-reshape(u24_all, direction = "wide", idvar = "person_id", timevar = "redcap_event_name", sep = "_")
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
      
      u24_all_wide<-    u24_all_wide %>%
        remove_empty_cols()
      u24_all_wide<- u24_all_wide[, grepl("person_id|age|gender|prnt_result_chikv|prnt_result_denv|infected|exposure|prnt_interpretation_flavi___1|prnt_interpretation_alpha___2|result_igg_denv_stfd|infected_denv_stfd|infected_chikv_stfd|result_igg_chikv_stfd|result_igg_denv_stfd|name|dob|phone|village|date_of_birth", names(u24_all_wide))]
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
    u24_all_wide <- within(u24_all_wide, case_control[u24_all_wide$u24_strata =="control" & !is.na(u24_all_wide$age_visit_a_arm_1) & !is.na(u24_all_wide$gender_all_visit_a_arm_1)] <- "control")
    u24_all_wide <- within(u24_all_wide, case_control[(u24_all_wide$u24_strata =="chikv"|u24_all_wide$u24_strata =="denv"|u24_all_wide$u24_strata =="both") & (!is.na(u24_all_wide$age_visit_a_arm_1) & !is.na(u24_all_wide$gender_all_visit_a_arm_1))] <- "case")
    table(u24_all_wide$case_control, u24_all_wide$u24_strata, exclude = NULL)

## now look at the group properties:
boxplot(u24_all_wide$age_visit_a_arm_1 ~ u24_all_wide$u24_strata)
boxplot(u24_all_wide$age_visit_a_arm_1 ~ u24_all_wide$case_control)
barplot(table(u24_all_wide$gender_all_visit_a_arm_1, u24_all_wide$u24_strata), beside = TRUE)
barplot(table(u24_all_wide$gender_all_visit_a_arm_1, u24_all_wide$case_control))
#install.packages("e1071")
matchControls<- u24_all_wide[which(!is.na(u24_all_wide$gender_all_visit_a_arm_1)&!is.na(u24_all_wide$age_visit_a_arm_1)&!is.na(u24_all_wide$case_control))  , ]
matchControls<- matchControls[c("gender_all_visit_a_arm_1","age_visit_a_arm_1","case_control","person_id")]
library("MatchIt")
set.seed(1234)
matchControls <- within(matchControls, case_control[case_control =="control"] <- 0)
matchControls <- within(matchControls, case_control[case_control =="case"] <- 1)
matchControls$case_control<-as.numeric(matchControls$case_control)

    match.it <- matchit(matchControls$case_control ~ matchControls$gender_all_visit_a_arm_1 + matchControls$age_visit_a_arm_1, data = matchControls, method="nearest", ratio=1)
    a <- summary(match.it)
    library("knitr")
    kable(a$sum.matched[c(1,2,4)], digits = 2, align = 'c', 
          caption = 'Table 3: Summary of balance for matched data')
    plot(match.it, type = 'jitter', interactive = FALSE)
    df.match <- match.data(match.it)[1:ncol(matchControls)]
    df.match<-as.data.frame(df.match)
boxplot(df.match$age_visit_a_arm_1 ~ df.match$case_control)
barplot(table(df.match$gender_all_visit_a_arm_1, df.match$case_control))

u24_all_wide_matched<-merge(df.match, u24_all_wide, by ="person_id", all.x = TRUE)

u24_all_wide_matched$prnt_confirmed<-rowSums(u24_all_wide_matched[, grep("prnt_interpretation_flavi___1|prnt_interpretation_alpha___2", names(u24_all_wide_matched))], na.rm = TRUE)
table(u24_all_wide_matched$u24_strata,u24_all_wide_matched$prnt_confirmed)

u24_all_wide_matched<-u24_all_wide_matched[order(-(grepl('person_id|redcap_event_name|prnt_confirmed|exposure|result_', names(u24_all_wide_matched)))+1L)]
u24_all_wide_matched<-u24_all_wide_matched[order(-(grepl('u24_strata|case_control', names(u24_all_wide_matched)))+1L)]

u24_all_wide_matched<-u24_all_wide_matched %>%remove_empty_cols()
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
write.csv(as.data.frame(u24_hcc), "C:/Users/amykr/Box Sync/Amy Krystosik's Files/secure- u24 participants/data/u24_hcc_participant_list.csv", na = "")
write.csv(as.data.frame(u24_aic), "C:/Users/amykr/Box Sync/Amy Krystosik's Files/secure- u24 participants/data/u24_aic_participant_list.csv", na = "")
