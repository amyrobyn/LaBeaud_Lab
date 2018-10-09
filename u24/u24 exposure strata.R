# bin by exposure and incidence -------------------------------------------
load("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long/R01_lab_results.clean.rda")
R01_lab_results[R01_lab_results==98]<-NA
u24_all_wide<-reshape(R01_lab_results, direction = "wide", idvar = "person_id", timevar = "redcap_event_name", sep = ".")
u24_all_wide$person_id<-as.character(as.factor(u24_all_wide$person_id))
u24_all_wide<-as.data.frame(u24_all_wide)

#all visits must be negative to be a control.
u24_all_wide$exposure_sum<-rowSums(u24_all_wide[, grep("prnt_interpretation_flavi___1|prnt_interpretation_alpha___2|result_igg_denv_stfd|infected_denv_stfd|infected_chikv_stfd|result_igg_chikv_stfd|result_igg_denv_stfd", names(u24_all_wide))], na.rm = TRUE)
u24_all_wide$incident_prnt_denv_exposure_sum<-rowSums(u24_all_wide[, grep("prnt_interpretation_flavi___1|infected_denv_stfd", names(u24_all_wide))], na.rm = TRUE)
u24_all_wide$incident_prnt_chikv_exposure_sum<-rowSums(u24_all_wide[, grep("prnt_interpretation_alpha___2|infected_chikv_stfd", names(u24_all_wide))], na.rm = TRUE)
table(u24_all_wide$incident_prnt_chikv_exposure_sum)
table(u24_all_wide$incident_prnt_denv_exposure_sum)

u24_all_wide$denv_exposure_sum<-rowSums(u24_all_wide[, grep("prnt_interpretation_flavi___1|infected_denv_stfd|result_igg_denv_stfd", names(u24_all_wide))], na.rm = TRUE)
u24_all_wide$chikv_exposure_sum<-rowSums(u24_all_wide[, grep("prnt_interpretation_alpha___2|infected_chikv_stfd|result_igg_chikv_stfd", names(u24_all_wide))], na.rm = TRUE)
u24_all_wide$denv_pcr_sum<-rowSums(u24_all_wide[, grep("infected_denv_stfd", names(u24_all_wide))], na.rm = TRUE)
u24_all_wide$chikv_pcr_sum<-rowSums(u24_all_wide[, grep("infected_chikv_stfd", names(u24_all_wide))], na.rm = TRUE)
u24_all_wide$denv_prnt_sum<-rowSums(u24_all_wide[, grep("prnt_interpretation_flavi___1", names(u24_all_wide))], na.rm = TRUE)
u24_all_wide$chikv_prnt_sum<-rowSums(u24_all_wide[, grep("prnt_interpretation_alpha___2", names(u24_all_wide))], na.rm = TRUE)
table(u24_all_wide$denv_exposure_sum,u24_all_wide$chikv_exposure_sum)
table(u24_all_wide$chikv_exposure_sum)
table(u24_all_wide$denv_exposure_sum)

u24_all_wide$pcr_denv_exposure_sum<-rowSums(u24_all_wide[, grep("result_pcr_denv|denv_result_ufi", names(u24_all_wide))], na.rm = TRUE)
table(u24_all_wide$pcr_denv_exposure_sum)
u24_all_wide$pcr_chikv_exposure_sum<-rowSums(u24_all_wide[, grep("result_pcr_chikv|$chikv_result_ufi", names(u24_all_wide))], na.rm = TRUE)
table(u24_all_wide$pcr_chikv_exposure_sum)


#u24_all_wide<-    u24_all_wide %>%        remove_empty_cols()
u24_all_wide<- u24_all_wide[, grepl("person_id|age|gender|prnt_result_chikv|prnt_result_denv|infected|exposure|prnt_interpretation_flavi___1|prnt_interpretation_alpha___2|result_igg_denv_stfd|infected_denv_stfd|infected_chikv_stfd|result_igg_chikv_stfd|result_igg_denv_stfd|name|dob|phone|village|date_of_birth|interview_date|result_pcr_|result_ufi|chikv_outbreak|sum|participant|chikv_prnt_sum|denv_prnt_sum|denv_pcr_sum|chikv_pcr_sum|u24_age_calc", names(u24_all_wide))]
u24_all_wide$incident_prnt_u24_strata<-NA

u24_all_wide <- within(u24_all_wide, incident_prnt_u24_strata[u24_all_wide$exposure_sum ==0] <- "control")
u24_all_wide <- within(u24_all_wide, incident_prnt_u24_strata[u24_all_wide$incident_prnt_chikv_exposure_sum >=1 ] <- "chikv")
u24_all_wide <- within(u24_all_wide, incident_prnt_u24_strata[u24_all_wide$incident_prnt_denv_exposure_sum >=1] <- "denv")
u24_all_wide <- within(u24_all_wide, incident_prnt_u24_strata[u24_all_wide$incident_prnt_chikv_exposure_sum>=1 & u24_all_wide$incident_prnt_denv_exposure_sum ==1] <- "both")
u24_all_wide$id_city<-substr(u24_all_wide$person_id, 1, 1)
table(u24_all_wide$incident_prnt_u24_strata,u24_all_wide$id_city)

u24_all_wide$u24_strata<-NA
u24_all_wide <- within(u24_all_wide, u24_strata[u24_all_wide$exposure_sum ==0] <- "control")
u24_all_wide <- within(u24_all_wide, u24_strata[u24_all_wide$chikv_exposure_sum >=1] <- "chikv")
u24_all_wide <- within(u24_all_wide, u24_strata[u24_all_wide$denv_exposure_sum >=1] <- "denv")
u24_all_wide <- within(u24_all_wide, u24_strata[u24_all_wide$chikv_exposure_sum>=1 & u24_all_wide$denv_exposure_sum >=1] <- "both")
table(u24_all_wide$u24_strata)

u24_all_wide$id_city<-substr(u24_all_wide$person_id, 1, 1)
table(u24_all_wide$id_city)
u24_all_wide <- u24_all_wide[ which((u24_all_wide$id_city=="M"|u24_all_wide$id_city=="L"|u24_all_wide$id_city=="G")), ]
u24_all_wide<-u24_all_wide[c("u24_strata","incident_prnt_u24_strata","person_id")]
save(u24_all_wide,file="C:/Users/amykr/Box Sync/Amy Krystosik's Files/secure- u24 participants/data/u24_exposure.rds")
