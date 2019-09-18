# bin by exposure and incidence -------------------------------------------
load("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long/R01_lab_results.clean.rda")
R01_lab_results[R01_lab_results==98]<-NA

summary(R01_lab_results$int_date)
summary(R01_lab_results$u24_interview_date)
as.Date(R01_lab_results$u24_interview_date)
lubridate::as_date(u24_all_wide$u24_interview_date)

u24_all_wide<-reshape(R01_lab_results, direction = "wide", idvar = "person_id", timevar = "redcap_event_name", sep = ".")
u24_all_wide$person_id<-as.character(as.factor(u24_all_wide$person_id))
u24_all_wide<-as.data.frame(u24_all_wide)

#all visits must be negative to be a control.
u24_all_wide$exposure_sum<-rowSums(u24_all_wide[, grep("prnt_interpretation_flavi___1|prnt_interpretation_alpha___2|result_igg_denv_stfd|infected_denv_stfd|infected_chikv_stfd|result_igg_chikv_stfd|result_igg_denv_stfd", names(u24_all_wide))], na.rm = TRUE)
u24_all_wide$incident_prnt_denv_exposure_sum<-rowSums(u24_all_wide[, grep("prnt_interpretation_flavi___1|infected_denv_stfd", names(u24_all_wide))], na.rm = TRUE)
u24_all_wide$incident_prnt_chikv_exposure_sum<-rowSums(u24_all_wide[, grep("prnt_interpretation_alpha___2|infected_chikv_stfd", names(u24_all_wide))], na.rm = TRUE)
table(u24_all_wide$incident_prnt_chikv_exposure_sum)
table(u24_all_wide$incident_prnt_denv_exposure_sum)
table(u24_all_wide$incident_prnt_denv_exposure_sum,u24_all_wide$incident_prnt_chikv_exposure_sum)

u24_all_wide$denv_exposure_sum<-rowSums(u24_all_wide[, grep("prnt_interpretation_flavi___1|infected_denv_stfd|result_igg_denv_stfd", names(u24_all_wide))], na.rm = TRUE)
u24_all_wide$chikv_exposure_sum<-rowSums(u24_all_wide[, grep("prnt_interpretation_alpha___2|infected_chikv_stfd|result_igg_chikv_stfd", names(u24_all_wide))], na.rm = TRUE)
u24_all_wide$denv_pcr_sum<-rowSums(u24_all_wide[, grep("infected_denv_stfd", names(u24_all_wide))], na.rm = TRUE)
u24_all_wide$chikv_pcr_sum<-rowSums(u24_all_wide[, grep("infected_chikv_stfd", names(u24_all_wide))], na.rm = TRUE)
u24_all_wide$denv_prnt_sum<-rowSums(u24_all_wide[, grep("prnt_interpretation_flavi___1", names(u24_all_wide))], na.rm = TRUE)
u24_all_wide$chikv_prnt_sum<-rowSums(u24_all_wide[, grep("prnt_interpretation_alpha___2", names(u24_all_wide))], na.rm = TRUE)
table(u24_all_wide$denv_exposure_sum,u24_all_wide$chikv_exposure_sum)
table(u24_all_wide$chikv_exposure_sum)
table(u24_all_wide$denv_exposure_sum)
table(u24_all_wide$chikv_exposure_sum,u24_all_wide$denv_exposure_sum)

u24_all_wide$pcr_denv_exposure_sum<-rowSums(u24_all_wide[, grep("result_pcr_denv|denv_result_ufi", names(u24_all_wide))], na.rm = TRUE)
table(u24_all_wide$pcr_denv_exposure_sum)
chikv<-(u24_all_wide[, grep("result_pcr_chikv|chikv_result_ufi", names(u24_all_wide))])
denv<-(u24_all_wide[, grep("result_pcr_denv|denv_result_ufi", names(u24_all_wide))])

u24_all_wide$pcr_chikv_exposure_sum<-rowSums(u24_all_wide[, grep("result_pcr_chikv|chikv_result_ufi", names(u24_all_wide))], na.rm = TRUE)
table(u24_all_wide$pcr_chikv_exposure_sum)
R01_lab_results[R01_lab_results$person_id=="GC0057004" , grep("redcap_event|result_pcr_denv|denv_result_ufi|result_pcr_chikv|$chikv_result_ufi", names(R01_lab_results))]

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
u24_all_wide <- within(u24_all_wide, u24_strata[u24_all_wide$chikv_exposure_sum >=1&!is.na(u24_all_wide$chikv_exposure_sum) ] <- "chikv")
u24_all_wide <- within(u24_all_wide, u24_strata[u24_all_wide$denv_exposure_sum >=1&!is.na(u24_all_wide$denv_exposure_sum)] <- "denv")
u24_all_wide <- within(u24_all_wide, u24_strata[u24_all_wide$chikv_exposure_sum>=1 & u24_all_wide$denv_exposure_sum >=1&!is.na(u24_all_wide$denv_exposure_sum)&!is.na(u24_all_wide$chikv_exposure_sum)] <- "both")
table(u24_all_wide$u24_strata)

u24_all_wide$id_city<-substr(u24_all_wide$person_id, 1, 1)
table(u24_all_wide$id_city)
u24_all_wide <- u24_all_wide[ which((u24_all_wide$id_city=="M"|u24_all_wide$id_city=="L"|u24_all_wide$id_city=="G")), ]
ids<-c("GC0035005","LC0286005","MF1694","MF0010","MF0178","MF0329","MF0345","MF0460","MF0838","MF1890","MF1897","MF1899","MF1931","MF1894","MF1934","MF1290","MF1519","MF0213","MF0227","MF1692","MF1893","GC0008007","GC0016006","GC0024004","GC0024005","GC0043004","GC0057004","GC0114012","GC0145006","GC0228005","GC0237005","GC0312007","LC0033006","LC0144007","LC0147005","LC0199006","LC0210014","LC0210017","LC0210018","LC0302004","LC0519004","LC0616005","LC0644005","MF0015","MF0023","MF0027","MF0035","MF0048","MF0171","MF0173","MF0176","MF0179","MF0186","MF0200","MF0230","MF0364","MF0385","MF0463","MF0490","MF0494","MF0537","MF0551","MF0598","MF0648","MF0703","MF0806","MF0897","MF0933","MF1096","MF1189","MF1245","MF1254","MF1273","MF1305","MF1387","MF1402","MF1427","MF1461","MF1474","MF1509","MF1518","MF1529","MF1572","MF1617","MF1618","MF1653","MF1666","MF1678","MF1688","MF1689","MF1690","MF1691","MF1695","MF1754","MF1763","MF1773","MF1829","MF1883","MF1886","MF1888","MF1889","MF1891","MF1892","MF1896","MF1901","MF1903","MF1905","MF1907","MF1908","MF1910","MF1911","MF1912","MF1913","MF1914","MF1922","MF1926","MF1929","MF1932","MF1933","MF1935","MF1940","MF1945","MF1948","MF2013","LC0607004","GC0061005","LC0215004","MF0224","MF0459","MF1285","MF1306","MF1382","MF1757","MF1918")
u24_all_wide<-subset(u24_all_wide, u24_all_wide$person_id %in% ids) 

u24<-u24_all_wide[c("u24_strata","incident_prnt_u24_strata","person_id")]
save(u24,file="C:/Users/amykr/Box Sync/Amy Krystosik's Files/secure- u24 participants/data/u24_exposure.rds")
write.csv(u24,"u24.csv")
setwd("C:/Users/amykr/Box Sync/U24 Project")
write.csv(u24,"strata.csv")
