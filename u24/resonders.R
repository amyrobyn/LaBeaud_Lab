setwd("C:/Users/amykr/Box Sync/U24 Project/")
load("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long/R01_lab_results.clean.rda")    
u24_responders<-R01_lab_results[R01_lab_results$person_id=="MF0598"|R01_lab_results$person_id=="MF1896"|R01_lab_results$person_id=="MF1910"|R01_lab_results$person_id=="MF1945",c("person_id","redcap_event_name","infected_chikv_stfd","infected_denv_stfd","symptoms_aic","int_date","result_pcr_chikv_kenya","result_pcr_denv_kenya","seroc_chikv_stfd_igg","seroc_denv_stfd_igg","gender_all","age_calc")]
write.csv(u24_responders,"responders.csv",na="")
R01_lab_results[R01_lab_results$person_id=="MF1945",c("person_id","redcap_event_name","gender_all","age_calc","age")]
