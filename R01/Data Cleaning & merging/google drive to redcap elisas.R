library(readr)
MissingELISAs <- read_csv("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/MissingELISAs.csv")
MissingELISAs<-MissingELISAs[which(MissingELISAs$redcap_event_name!="patient_informatio_arm_1"&MissingELISAs$redcap_event_name!="visit_u24_arm_1"),]
MissingELISAs<-MissingELISAs[which(is.na(MissingELISAs$result_igg_chikv_stfd) | is.na(MissingELISAs$result_igg_chikv_stfd)),]
MissingELISAs<-MissingELISAs[which(!is.na(MissingELISAs$interview_date) | !is.na(MissingELISAs$interview_date_aic)| (MissingELISAs$serum_sample_num>0 & !is.na(MissingELISAs$serum_sample_num)) ),]
