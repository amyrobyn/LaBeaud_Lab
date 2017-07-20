setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/melisa shah")

melisa_aic<-load("R01CHIKVDENVProject_R_2017-07-20_1136.rda")


aic<-R01_lab_results[which(R01_lab_results$id_visit > 0), c("person_id", "redcap_event_name","symptoms", "symptoms_aic", "id_cohort", "id_city", "id_visit")]
f <- "aic_dummy_symptoms_de_identified.csv"
write.csv(as.data.frame(aic), f )
