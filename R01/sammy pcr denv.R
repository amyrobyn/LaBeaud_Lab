setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long")
load("R01_lab_results 2018-03-06 .rda")
R01_lab_results$id<-paste(R01_lab_results$person_id, R01_lab_results$redcap_event, sep="_")

sammy<-read.csv("C:/Users/amykr/Box Sync/Amy Krystosik's Files/sammy jael/pcr_denv.csv")
colnames(sammy)[1] <- "person_id"
sammy$id<-paste(sammy$person_id, sammy$redcap_event, sep="_")
pcr_denv_sammy<-merge(sammy, R01_lab_results, by="id", all.x=TRUE)
pcr_denv_sammy<- pcr_denv_sammy[, grepl("person_id|redcap_event_name|result_pcr_denv_|denv_result_ufi|Case_control", names( pcr_denv_sammy))]
write.csv(as.data.frame(pcr_denv_sammy), "C:/Users/amykr/Box Sync/Amy Krystosik's Files/sammy jael/pcr_denv_sammy.csv", na = "")
