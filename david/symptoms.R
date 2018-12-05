# symptoms table ----------------------------------------------------------
#fix the bleeding and body_ache variables to replace NA with zero.

#bleeding
AIC <- within(AIC, bleeding[AIC$aic_symptom_bleeding_gums==0] <- 0)
AIC <- within(AIC, bleeding[AIC$aic_symptom_bleeding_gums==0] <- 0)
AIC <- within(AIC, bleeding[AIC$aic_symptom_bloody_nose==0] <- 0)
AIC <- within(AIC, bleeding[AIC$aic_symptom_bloody_urine==0] <- 0)
AIC <- within(AIC, bleeding[AIC$aic_symptom_bloody_stool==0] <- 0)
AIC <- within(AIC, bleeding[AIC$aic_symptom_bloody_vomit==0] <- 0)
AIC <- within(AIC, bleeding[AIC$aic_symptom_bruises==0] <- 0)

AIC <- within(AIC, bleeding[AIC$aic_symptom_bleeding_gums==1] <- 1)
AIC <- within(AIC, bleeding[AIC$aic_symptom_bleeding_gums==1] <- 1)
AIC <- within(AIC, bleeding[AIC$aic_symptom_bloody_nose==1] <- 1)
AIC <- within(AIC, bleeding[AIC$aic_symptom_bloody_urine==1] <- 1)
AIC <- within(AIC, bleeding[AIC$aic_symptom_bloody_stool==1] <- 1)
AIC <- within(AIC, bleeding[AIC$aic_symptom_bloody_vomit==1] <- 1)
AIC <- within(AIC, bleeding[AIC$aic_symptom_bruises==1] <- 1)
table(AIC$bleeding)  

#nausea_vomitting
AIC <- within(AIC, nausea_vomitting[AIC$aic_symptom_nausea==0|AIC$aic_symptom_vomiting==0| AIC$aic_symptom_bloody_vomit==0] <- 0)
AIC <- within(AIC, nausea_vomitting[AIC$aic_symptom_nausea==1|AIC$aic_symptom_vomiting==1| AIC$aic_symptom_bloody_vomit==1] <- 1)
table(AIC$nausea_vomitting)

#ims
AIC <- within(AIC, aic_symptom_impaired_mental_status[aic_symptom_fits==0|aic_symptom_seizures==0] <- 0)
AIC <- within(AIC, aic_symptom_impaired_mental_status[aic_symptom_fits==1|aic_symptom_seizures==1] <- 1)

#bodyache
AIC <- within(AIC, body_ache[AIC$aic_symptom_general_body_ache==0] <- 0)
AIC <- within(AIC, body_ache[AIC$aic_symptom_muscle_pains==0] <- 0)
AIC <- within(AIC, body_ache[AIC$aic_symptom_bone_pains==0] <- 0)

AIC <- within(AIC, body_ache[AIC$aic_symptom_general_body_ache==1] <- 1)
AIC <- within(AIC, body_ache[AIC$aic_symptom_muscle_pains==1] <- 1)
AIC <- within(AIC, body_ache[AIC$aic_symptom_bone_pains==1] <- 1)
table(AIC$body_ache)      

AIC$heart_rate<-    as.numeric(as.character(AIC$heart_rate))
AIC$temp<-    as.numeric(as.character(AIC$temp))
symptom_vars <- c("aic_symptom_abdominal_pain", "aic_symptom_chills", "aic_symptom_cough", "aic_symptom_vomiting", "aic_symptom_headache", "aic_symptom_loss_of_appetite", "aic_symptom_diarrhea", "aic_symptom_sick_feeling",  "aic_symptom_general_body_ache", "aic_symptom_joint_pains", "aic_symptom_dizziness", "aic_symptom_runny_nose", "aic_symptom_sore_throat", "aic_symptom_rash", "aic_symptom_shortness_of_breath", "aic_symptom_nausea", "aic_symptom_fever", "aic_symptom_funny_taste", "aic_symptom_red_eyes", "aic_symptom_earache", "aic_symptom_stiff_neck", "aic_symptom_pain_behind_eyes", "aic_symptom_itchiness", "aic_symptom_impaired_mental_status", "aic_symptom_eyes_sensitive_to_light", "bleeding", "body_ache", "temp", "heart_rate", "nausea_vomitting")
symptom_factorVars <- c("aic_symptom_abdominal_pain", "aic_symptom_chills", "aic_symptom_cough", "aic_symptom_vomiting", "aic_symptom_headache", "aic_symptom_loss_of_appetite", "aic_symptom_diarrhea", "aic_symptom_sick_feeling",  "aic_symptom_general_body_ache", "aic_symptom_joint_pains", "aic_symptom_dizziness", "aic_symptom_runny_nose", "aic_symptom_sore_throat", "aic_symptom_rash", "aic_symptom_shortness_of_breath", "aic_symptom_nausea", "aic_symptom_fever", "aic_symptom_funny_taste", "aic_symptom_red_eyes", "aic_symptom_earache", "aic_symptom_stiff_neck", "aic_symptom_pain_behind_eyes", "aic_symptom_itchiness", "aic_symptom_impaired_mental_status", "aic_symptom_eyes_sensitive_to_light", "bleeding", "body_ache","nausea_vomitting")

symptoms_tableOne_strata_all <- CreateTableOne(vars = symptom_vars, factorVars = symptom_factorVars, strata = "strata_all", data = AIC)
#summary(symptoms_tableOne)
symptoms_tableOne_strata_all.csv<-print(symptoms_tableOne_strata_all, 
                                        exact = c("aic_symptom_abdominal_pain", "aic_symptom_chills", "aic_symptom_cough", "aic_symptom_vomiting", "aic_symptom_headache", "aic_symptom_loss_of_appetite", "aic_symptom_diarrhea", "aic_symptom_sick_feeling",  "aic_symptom_general_body_ache", "aic_symptom_joint_pains", "aic_symptom_dizziness", "aic_symptom_runny_nose", "aic_symptom_sore_throat", "aic_symptom_rash", "aic_symptom_shortness_of_breath", "aic_symptom_nausea", "aic_symptom_fever", "aic_symptom_funny_taste", "aic_symptom_red_eyes", "aic_symptom_earache", "aic_symptom_stiff_neck", "aic_symptom_pain_behind_eyes", "aic_symptom_itchiness", "aic_symptom_impaired_mental_status", "aic_symptom_eyes_sensitive_to_light", "bleeding", "body_ache", "temp", "heart_rate", "temp", "outcome_hospitalized","nausea_vomitting"),
                                        nonnormal=c("heart_rate", "temp"),
                                        quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE)

write.csv(symptoms_tableOne_strata_all.csv, file = "symptoms_tableOne_strata_all_dec4.csv")


#Table 2, OR of symptom/sign in reference to co-infection 
vars <-c("aic_symptom_abdominal_pain", "aic_symptom_chills", "aic_symptom_cough", "aic_symptom_vomiting", "aic_symptom_headache", "aic_symptom_loss_of_appetite", "aic_symptom_diarrhea", "aic_symptom_sick_feeling",  "aic_symptom_general_body_ache", "aic_symptom_joint_pains", "aic_symptom_dizziness", "aic_symptom_runny_nose", "aic_symptom_sore_throat", "aic_symptom_rash", "aic_symptom_shortness_of_breath", "aic_symptom_nausea", "aic_symptom_fever", "aic_symptom_funny_taste", "aic_symptom_red_eyes", "aic_symptom_earache", "aic_symptom_stiff_neck", "aic_symptom_pain_behind_eyes", "aic_symptom_itchiness", "aic_symptom_impaired_mental_status", "aic_symptom_eyes_sensitive_to_light", "bleeding", "body_ache", "nausea_vomitting")
#AIC <- fastDummies::dummy_cols(AIC, select_columns = "strata_all")
table(AIC$strata_all)

test<-glm(aic_symptom_abdominal_pain~factor(strata_all), family="binomial", data = AIC)
fits <- lapply(vars, function(x) {glm(substitute(i~factor(strata_all), list(i = as.name(x))), family="binomial", data = AIC)})
exp(coefficients(test))
exp(confint(test))

coef<-lapply(fits, coefficients)
coef<-lapply(fits, function(x) {exp(cbind("Odds ratio" = coef(x), confint(x, level = 0.95, parallel="multicore", ncpus=4)))})

lapply(coef, function(x) write.table( data.frame(x), 'symptoms_or.ci_dec5.csv'  , append= T, sep=',' ))

#https://stats.stackexchange.com/questions/63222/getting-p-values-for-multinom-in-r-nnet-package
#install.packages("afex")
library(afex)
set_sum_contrasts() # use sum coding, necessary to make type III LR tests valid
library(car)
#install.packages("AER")
library(AER)
p<-lapply(fits, coeftest)
library(broom)
ptable<-lapply(p, tidy)
lapply(ptable, function(x) write.table( data.frame(x), 'symtoms_acute_OR_dec5.csv'  , append= T, sep=',' ))
