library("dplyr")
library("zoo")
setwd("C:/Users/amykr/Box Sync/DENV CHIKV project DEIDENTIFIED/Vector Data")
vector<-read.csv("20180326092026_pid11751_uzhH8t.csv")
vector<- vector[which(vector$redcap_event_name!="chulaimbo_hospital_arm_1"& vector$redcap_event_name!="chulaimbo_village_arm_1"& vector$redcap_event_name!="kisumu_estate_arm_1"&vector$redcap_event_name!="msambweni_arm_1"&vector$redcap_event_name!="obama_arm_1"&vector$redcap_event_name!="ukunda_arm_1")  , ]

vector<-vector %>% group_by(redcap_event_name) %>% mutate(study_site=na.locf(study_site, na.rm=FALSE))
vector<-vector %>% group_by(redcap_event_name) %>% mutate(study_site=na.locf(study_site, na.rm=FALSE,fromLast=TRUE))
table(vector$study_site, exclude = NULL)

class(vector$date_collected)
head(vector$date_collected)
vector$date_collected_time<-vector$date_collected
vector$date_collected<-as.Date(as.character(as.factor(vector$date_collected)),"%Y-%m-%d %H:%M")
#vector_coast_subset<- vector[which((vector$date_collected>="2017-09-01"& vector$date_collected<"2017-10-01")|(vector$date_collected>="2017-12-01"& vector$date_collected<"2018-01-01")|(vector$date_collected>="2018-03-01"& vector$date_collected<"2018-04-01")),]
vector_coast_subset<- vector[which(vector$date_collected>="2017-06-01"),]
vector_coast_subset<-vector_coast_subset[, grepl("date_collected|redcap_event|hlc|study_site|_1|_2|_3|_4|_5|_6|_7|_8|_9", names(vector_coast_subset))]

vector_coast_subset<-vector_coast_subset[, !grepl("collector_name|proko|ovi|bg|house|larva", names(vector_coast_subset))]

table(vector_coast_subset$study_site, exclude = NULL)

vector_coast_subset <- vector_coast_subset[!is.na(vector_coast_subset$hlc_complete)|!is.na(vector_coast_subset$survey_hlc), ]

#write.csv(vector_coast_subset,"vector_coast_subset.csv", na="")

table(vector_coast_subset$date_collected)

