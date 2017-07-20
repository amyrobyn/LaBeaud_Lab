#install packages
#attach libraries 

setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/melisa shah")

#method downloading report from redcap
R01_lab_results<-load("R01_lab_results.backup.rda")

#download from api.

#creating the cohort and village and visit variables for each visit. 
R01_lab_results$id_cohort<-substr(R01_lab_results$person_id, 2, 2)
table(R01_lab_results$id_cohort)
R01_lab_results$id_city<-substr(R01_lab_results$person_id, 1, 1)


#subsetting the data for just aic
#change and put your vars here.
aic<-R01_lab_results[which(R01_lab_results$ id_cohort=="F"), c("person_id", "redcap_event_name","symptoms", "symptoms_aic", "id_cohort", "id_city", "id_visit")]

#describe 


#exporting to csv
f <- "aic_dummy_symptoms_de_identified.csv"
write.csv(as.data.frame(aic), f )
