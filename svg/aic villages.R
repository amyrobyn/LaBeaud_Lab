# import data -------------------------------------------------------------
setwd("C:/Users/amykr/Box Sync/Amy's Externally Shareable Files/SVG/analysis")
load("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long/R01_lab_results.clean.rda")    

# subset to villages -------------------------------------------------------------
aic<-R01_lab_results[ (!is.na(R01_lab_results$infected_chikv_stfd)|!is.na(R01_lab_results$infected_denv_stfd)) & R01_lab_results$Cohort=="AIC"& R01_lab_results$City=="U",c("person_id","redcap_event_name","aic_village_gps_lattitude","aic_village_gps_longitude","aic_village_gps_data_type","infected_denv_stfd","infected_chikv_stfd","City","village_aic","Cohort")]
write.csv(aic,"aic_gps_u.csv",na="")