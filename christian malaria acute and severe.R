setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long")
load("R01_lab_results.clean.rda")


#Malaria: positive by result_microscopy_malaria_kenya, or if NA, then positive by malaria_result
R01_lab_results$malaria<-NA
R01_lab_results <- within(R01_lab_results, malaria[R01_lab_results$result_rdt_malaria_keny==0] <- 0)#rdt
R01_lab_results <- within(R01_lab_results, malaria[R01_lab_results$rdt_result==0] <- 0)#rdt
R01_lab_results <- within(R01_lab_results, malaria[R01_lab_results$malaria_results==0] <- 0)# Results of malaria blood smear	(+++ system)
R01_lab_results <- within(R01_lab_results, malaria[R01_lab_results$ufi_plasmodium_species___1 ==0] <- 0)# Results of malaria blood smear	(+++ system)
R01_lab_results <- within(R01_lab_results, malaria[R01_lab_results$ufi_plasmodium_species___2 ==0] <- 0)# Results of malaria blood smear	(+++ system)
R01_lab_results <- within(R01_lab_results, malaria[R01_lab_results$ufi_plasmodium_species___3 ==0] <- 0)# Results of malaria blood smear	(+++ system)
R01_lab_results <- within(R01_lab_results, malaria[R01_lab_results$ufi_plasmodium_species___4 ==0] <- 0)# Results of malaria blood smear	(+++ system)
R01_lab_results <- within(R01_lab_results, malaria[R01_lab_results$ufi_plasmodium_species___98 ==0] <- 0)# Results of malaria blood smear	(+++ system)
R01_lab_results <- within(R01_lab_results, malaria[R01_lab_results$result_microscopy_malaria_kenya==0] <- 0)#microscopy. this goes last so that it overwrites all the other's if it exists.

R01_lab_results <- within(R01_lab_results, malaria[R01_lab_results$result_microscopy_malaria_kenya==1] <- 1) #this goes first. only use the others if this is missing.
R01_lab_results <- within(R01_lab_results, malaria[R01_lab_results$malaria_results>0 & is.na(result_microscopy_malaria_kenya)] <- 1)# Results of malaria blood smear	(+++ system)
R01_lab_results <- within(R01_lab_results, malaria[R01_lab_results$rdt_results==1 & is.na(result_microscopy_malaria_kenya)] <- 1)#rdt
R01_lab_results <- within(R01_lab_results, malaria[R01_lab_results$ufi_plasmodium_species___1 ==1 & is.na(result_microscopy_malaria_kenya)] <- 1)# Results of malaria blood smear	(+++ system)
R01_lab_results <- within(R01_lab_results, malaria[R01_lab_results$ufi_plasmodium_species___2 ==1 & is.na(result_microscopy_malaria_kenya)] <- 1)# Results of malaria blood smear	(+++ system)
R01_lab_results <- within(R01_lab_results, malaria[R01_lab_results$ufi_plasmodium_species___3 ==1 & is.na(result_microscopy_malaria_kenya)] <- 1)# Results of malaria blood smear	(+++ system)
R01_lab_results <- within(R01_lab_results, malaria[R01_lab_results$ufi_plasmodium_species___4 ==1 & is.na(result_microscopy_malaria_kenya)] <- 1)# Results of malaria blood smear	(+++ system)
R01_lab_results <- within(R01_lab_results, malaria[R01_lab_results$ufi_plasmodium_species___98 ==1 & is.na(result_microscopy_malaria_kenya)] <- 1)# Results of malaria blood smear	(+++ system)
table(R01_lab_results$malaria)


# outcome hospitalized ----------------------------------------------------
R01_lab_results$outcome_hospitalized<-as.numeric(as.character(R01_lab_results$outcome_hospitalized))
R01_lab_results <- within(R01_lab_results, outcome_hospitalized[outcome_hospitalized==8] <-1 )
table(R01_lab_results$outcome_hospitalized)


# #create acute variable  ------------------------------------------------------------------------
R01_lab_results$acute<-NA
R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$visit_type==1] <- 1)
R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$visit_type==2] <- 1)
R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$visit_type==3] <- 0)
R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$visit_type==4] <- 1)
R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$visit_type==5] <- 0)

#if they ask an initial survey question (see odk aic inital and follow up forms), it is an initial visit.
R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$kid_highest_level_education_aic!=""] <- 1)
R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$occupation_aic!=""] <- 1)
R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$oth_educ_level_aic!=""] <- 1)
R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$mom_highest_level_education_aic!=""] <- 1)
R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$roof_type!=""] <- 1)
R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$pregnant!=""] <- 1)
#if it is visit a,call it acute
R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$redcap_event=="visit_a_arm_1" & R01_lab_results$Cohort=="F"] <- 1)

#if they have fever, call it acute
R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$aic_symptom_fever==1] <- 1)
R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$temp>=38] <- 1)

#otherwise, it is not acute
R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$acute!=1] <- 0)
table(R01_lab_results$acute)
table(R01_lab_results$outcome, R01_lab_results$outcome_hospitalized)
table(R01_lab_results$malaria,R01_lab_results$outcome_hospitalized)

#malaria
christian_malaria_database<-R01_lab_results[which(R01_lab_results$acute==1 & R01_lab_results$malaria==1), ]
christian_malaria_database<-christian_malaria_database[, grepl("person_id|redcap_event_name|hb|malaria|rdt|outcome|hospitalized|age|gender|sex|sickle|aic_symptoms|symptom|aic_pe|exam|site|city|result_igg|result_pcr|infected_chikv_stfd|infected_denvv_stfd|cohort|result_ufi|result_prnt", names(christian_malaria_database))]
christian_malaria_database<-christian_malaria_database[order(-(grepl('malaria|outcome', names(christian_malaria_database)))+1L)]
write.csv(as.data.frame(christian_malaria_database), "christian_malaria_database.csv", row.names = F )

#healthy
christian_non_acute_non_malaria_database<-R01_lab_results[which(R01_lab_results$acute!=1 & R01_lab_results$malaria!=1), ]
christian_non_acute_non_malaria_database<-christian_non_acute_non_malaria_database[, grepl("person_id|redcap_event_name|hb|malaria|rdt|outcome|hospitalized|age|gender|sex|sickle|aic_symptoms|symptom|aic_pe|exam|site|city|result_igg|result_pcr|infected_chikv_stfd|infected_denvv_stfd|cohort|result_ufi|result_prnt", names(christian_non_acute_non_malaria_database))]
christian_non_acute_non_malaria_database<-christian_non_acute_non_malaria_database[order(-(grepl('malaria|outcome', names(christian_non_acute_non_malaria_database)))+1L)]
write.csv(as.data.frame(christian_non_acute_non_malaria_database), "christian_non_acute_non_malaria_database.csv", row.names = F )
