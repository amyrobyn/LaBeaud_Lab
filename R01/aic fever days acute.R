#install.packages("psych")
library(psych)
#Can you query the AIC initial data and give me the range, median, and mean for days of fever at presentation? 
setwd("C:/Users/amykr/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/redcap reports/aic fever days")
aic_fever_days <- read.csv("R01CHIKVDENVProject_DATA_2017-07-03_0955.csv")
attach(aic_fever_days)
visita<-subset(aic_fever_days, redcap_event_name=="visit_a_arm_1")
describe(visita$date_symptom_onset) 

aic_fever_days$fever[aic_fever_days$temp < 38] <- 0
aic_fever_days$fever[aic_fever_days$temp > 38] <- 1
aic_fever_days$fever[aic_fever_days$temp = NA] <- NA

aic_fever_days$symptomatic[is.na(aic_fever_days$symptoms_aic) ] <- 0
aic_fever_days$symptomatic[!is.na(aic_fever_days$symptoms_aic) ] <- 1
table(aic_fever_days$symptomatic)

table(aic_fever_days$visit_type, aic_fever_days$fever, exclude = NULL)

describeBy(aic_fever_days$date_symptom_onset, aic_fever_days$fever, mat = TRUE) 
table(aic_fever_days$visit_type, aic_fever_days$redcap_event_name, exclude = NULL)
unknown <- subset(aic_fever_days,  is.na(visit_type) & redcap_event_name !="visit_a_arm_1")
table(unknown$fever, exclude = NULL)
table(unknown$currently_sick, exclude = NULL)
table(unknown$symptomatic, exclude = NULL)

n_distinct(aic_fever_days$person_id)
n_distinct(aic_fever_days$person_id, redcap_event_name, na.rm = FALSE)

describe(aic_fever_days$date_symptom_onset) 
