library(readr)
redcap <- read_csv("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/MissingELISAs.csv")
redcap<-redcap[which(redcap$redcap_event_name!="patient_informatio_arm_1"&redcap$redcap_event_name!="visit_u24_arm_1"),]
redcap<-redcap[which(is.na(redcap$result_igg_chikv_stfd_redcap) | is.na(redcap$result_igg_chikv_stfd_redcap)),]
redcap<-redcap[which(!is.na(redcap$interview_date_aic_redcap) | !is.na(redcap$interview_date_aic_redcap)| (redcap$serum_sample_num_redcap>0 & !is.na(redcap$serum_sample_num_redcap)) ),]


googledoc <- read_csv("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/MissingELISACleanUp.csv")

redcap_google<-merge(googledoc,redcap, by=c("person_id","redcap_event_name"))

redcap_google$chikv_missed<-ifelse(!is.na(redcap_google$result_igg_chikv_stfd_google)&is.na(redcap_google$result_igg_chikv_stfd_redcap),1,0 )
table(redcap_google$chikv_missed)
redcap_google$denv_missed<-ifelse(!is.na(redcap_google$result_igg_denv_stfd_google)&is.na(redcap_google$result_igg_denv_stfd_redcap),1,0 )
table(redcap_google$denv_missed)

redcap_google_missed<-redcap_google[which(redcap_google$denv_missed==1|redcap_google$chikv_missed==1)  , ]
write.csv(redcap_google_missed,"C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/redcap_google_missed.csv")
