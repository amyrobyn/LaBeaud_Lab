# define acute febrile illness------------------------------------------------------------------------
AIC <- AIC[, !grepl("u24|sample", names(AIC) ) ]
AIC$acute<-NA
AIC <- within(AIC, acute[AIC$visit_type==1] <- 1)
AIC <- within(AIC, acute[AIC$visit_type==2] <- 1)
AIC <- within(AIC, acute[AIC$visit_type==3] <- 0)
AIC <- within(AIC, acute[AIC$visit_type==4] <- 1)
AIC <- within(AIC, acute[AIC$visit_type==5] <- 0)

#if they ask an initial survey question (see odk aic inital and follow up forms), it is an initial visit.
AIC <- within(AIC, acute[AIC$kid_highest_level_education_aic!=""] <- 1)
AIC <- within(AIC, acute[AIC$occupation_aic!=""] <- 1)
AIC <- within(AIC, acute[AIC$oth_educ_level_aic!=""] <- 1)
AIC <- within(AIC, acute[AIC$mom_highest_level_education_aic!=""] <- 1)
AIC <- within(AIC, acute[AIC$roof_type!=""] <- 1)
AIC <- within(AIC, acute[AIC$pregnant!=""] <- 1)
#if it is visit a,call it acute
AIC <- within(AIC, acute[AIC$redcap_event=="visit_a_arm_1" & AIC$Cohort=="F"] <- 1)

#if they have fever, call it acute
AIC <- within(AIC, acute[AIC$aic_symptom_fever==1] <- 1)
AIC <- within(AIC, acute[AIC$temp>=38] <- 1)

#otherwise, it is not acute
AIC <- within(AIC, acute[AIC$acute!=1] <- 0)
table(AIC$redcap_event_name, AIC$acute)