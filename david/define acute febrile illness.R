# define acute febrile illness------------------------------------------------------------------------
AIC <- AIC[, !grepl("u24|sample", names(AIC) ) ]
AIC$acute<-NA

#if they have fever, call it acute
AIC <- within(AIC, acute[AIC$aic_symptom_fever==1] <- 1)
table(AIC$acute,AIC$redcap_event_name,exclude = NULL)
AIC <- within(AIC, acute[AIC$temp>=38] <- 1)
table(AIC$acute,AIC$redcap_event_name,exclude = NULL)
#if they ask an initial survey question (see odk aic inital and follow up forms), it is an initial visit.
AIC <- within(AIC, acute[AIC$kid_highest_level_education_aic!=""] <- 1)
table(AIC$acute,AIC$redcap_event_name,exclude = NULL)

#otherwise, it is not acute
AIC <- within(AIC, acute[is.na(AIC$acute)] <- 0)
table(AIC$acute,AIC$redcap_event_name,exclude = NULL)