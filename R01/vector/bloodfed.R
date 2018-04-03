library("dplyr")
library("zoo")
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/vector")
vector<-read.csv("20180326092026_pid11751_uzhH8t.csv")

vector_blood_fed<-vector[, grepl("redcap_event_name|blood|date_collected|study_site", names(vector))]
vector_blood_fed<-vector_blood_fed[, grepl("redcap_event_name|date_collected|study_site|aedes", names(vector_blood_fed))]
vector_blood_fed<- vector_blood_fed[which(vector_blood_fed$redcap_event_name!="chulaimbo_hospital_arm_1"& vector_blood_fed$redcap_event_name!="chulaimbo_village_arm_1"& vector_blood_fed$redcap_event_name!="kisumu_estate_arm_1"&vector_blood_fed$redcap_event_name!="msambweni_arm_1"&vector_blood_fed$redcap_event_name!="obama_arm_1"&vector_blood_fed$redcap_event_name!="ukunda_arm_1")  , ]

vector_blood_fed<-vector_blood_fed %>% group_by(redcap_event_name) %>% mutate(study_site=na.locf(study_site, na.rm=FALSE))
vector_blood_fed<-vector_blood_fed %>% group_by(redcap_event_name) %>% mutate(study_site=na.locf(study_site, na.rm=FALSE,fromLast=TRUE))

vector_blood_fed<-vector_blood_fed[, !grepl("hlc", names(vector_blood_fed))]

vector_blood_fed$bloodfed_sum <- as.integer(rowSums(vector_blood_fed[ , grep("blood" , names(vector_blood_fed))], na.rm = TRUE))
vector_blood_fed<- vector_blood_fed[which(vector_blood_fed$bloodfed_sum>=1 )  , ]
table(vector_blood_fed$study_site, vector_blood_fed$bloodfed_sum)

write.csv(vector_blood_fed,"vector_blood_fed.csv", na="", row.names = F  )