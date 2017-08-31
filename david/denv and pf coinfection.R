setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long")
#load data that has been cleaned previously
  load("aic_dummy_symptoms.clean.rda") #load the data from your local directory (this will save you time later rather than always downolading from redcap.)
  R01_lab_results<-aic_dummy_symptoms

R01_lab_results$site <-NA
R01_lab_results <- within(R01_lab_results, site[R01_lab_results$id_city=="C"] <-"west")
R01_lab_results <- within(R01_lab_results, site[R01_lab_results$id_city=="G"] <- "coast")
R01_lab_results <- within(R01_lab_results, site[R01_lab_results$id_city=="K"] <- "west")
R01_lab_results <- within(R01_lab_results, site[R01_lab_results$id_city=="L"] <- "coast")
R01_lab_results <- within(R01_lab_results, site[R01_lab_results$id_city=="M"] <- "coast")
R01_lab_results <- within(R01_lab_results, site[R01_lab_results$id_city=="R"] <- "west")
R01_lab_results <- within(R01_lab_results, site[R01_lab_results$id_city=="U"] <- "west")
table(R01_lab_results$site)

# subset of the variables
  cases<-R01_lab_results[which(R01_lab_results$id_cohort=="F" | R01_lab_results$id_cohort=="M" ), ]
  cases<-cases[which(cases$site=="west"), ]
  cases<-cases[which(cases$redcap_event!="patient_informatio_arm_1"), ]
  cases <- cases[, !grepl("u24|sample", names(cases) ) ]

#create diagram of patients
  cases$acute<-NA
  cases <- within(cases, acute[cases$visit_type==1] <- 1)
  cases <- within(cases, acute[cases$visit_type==2] <- 1)
  cases <- within(cases, acute[cases$visit_type==3] <- 0)
  cases <- within(cases, acute[cases$visit_type==4] <- 1)
  cases <- within(cases, acute[cases$visit_type==5] <- 1)
  #if they ask an initial survey question (see odk aic inital and follow up forms), it is an initial visit.
    cases <- within(cases, acute[cases$kid_highest_level_education_aic!=""] <- 1)
    cases <- within(cases, acute[cases$occupation_aic!=""] <- 1)
    cases <- within(cases, acute[cases$oth_educ_level_aic!=""] <- 1)
    cases <- within(cases, acute[cases$mom_highest_level_education_aic!=""] <- 1)
    cases <- within(cases, acute[cases$roof_type!=""] <- 1)
    cases <- within(cases, acute[cases$pregnant!=""] <- 1)
#if it is visit a,call it acute
    cases <- within(cases, acute[cases$redcap_event=="visit_a_arm_1"] <- 1)
#if they have fever, call it acute
    cases <- within(cases, acute[cases$aic_symptom_fever==1] <- 1)

#create diagram of patients
library(dplyr)
    n_distinct(R01_lab_results$person_id, na.rm = FALSE) #9479 patients reviewed
    n_distinct(cases$person_id, na.rm = FALSE) #3734 patients included in study (aic, west)
    table(cases$acute, exclude = NULL)#3972 acute visits
#table of denv at acute visit. 
  table(cases$infected_denv_stfd, cases$acute, exclude=NULL) #93 denv infected (seroconverter or PCR +)
  #malaria by rdt or microscopy ?
  cases$malaria<-NA
  cases <- within(cases, malaria[cases$malaria_results==0] <- 0)
  cases <- within(cases, malaria[cases$result_rdt_malaria_keny==0] <- 0)
  cases <- within(cases, malaria[cases$rdt_result==0] <- 0)
  cases <- within(cases, malaria[cases$result_microscopy_malaria_kenya==0] <- 0)

  cases <- within(cases, malaria[cases$malaria_results>0] <- 1)
  cases <- within(cases, malaria[cases$result_rdt_malaria_kenya==1] <- 1)
  cases <- within(cases, malaria[cases$rdt_result==1] <- 1)
  cases <- within(cases, malaria[cases$result_microscopy_malaria_kenya==1] <- 1)
  table(cases$malaria)

  #by pcr or igg seroc?
    cases$pcr_denv<-NA
    cases <- within(cases, pcr_denv[cases$result_pcr_denv_kenya==0] <- 0)
    cases <- within(cases, pcr_denv[cases$result_pcr_denv_stfd==0] <- 0)
    cases <- within(cases, pcr_denv[cases$result_pcr_denv_kenya==1] <- 1)
    cases <- within(cases, pcr_denv[cases$result_pcr_denv_stfd==1] <- 1)
    table(cases$pcr_denv)
    
    table(cases$seroc_denv_stfd_igg, cases$pcr_denv)#87 by pcr, 6 by igg seroconversion.
  table(cases$infected_denv_stfd, cases$malaria)
#keep only those tested for both malaria and denv.
  cases <- within(cases, tested_denv_stfd_igg[cases$infected_denv_stfd==1 |cases$tested_denv_stfd_igg==1 | cases$pcr_denv!=""] <- 1)
  cases<-cases[which(cases$malaria!="" & cases$tested_denv_stfd_igg==1), ]
  cases<-cases[which(cases$malaria!="" & cases$tested_denv_stfd_igg==1 & cases$acute==1), ]
    #some need to be malaria tested to be included in sample
    not_malaria_tested<-cases[which(is.na(cases$malaria) & cases$infected_denv_stfd==1), ]
    not_malaria_tested$person_id
#flow chart of subjects.    
  length(cases$person_id)#1480 acute visits tested for both denv and malaria.
  n_distinct(cases$person_id)#1457 unique subjects.
#denv and any malaria  
  table(cases$malaria, cases$infected_denv_stfd)#689 negative for both; 40 positive for both; 83 positive for denv; 748 malaria positive.
#denv and pf malaria
  table(cases$microscopy_malaria_pf_kenya___1, cases$infected_denv_stfd)
  489+24 # pf malaria
#denv and non pf.
  non_pf_malaria<-NA
  cases <- within(cases, non_pf_malaria[cases$malaria==1 &cases$microscopy_malaria_pf_kenya___1 !=1] <- 1)
  table(cases$non_pf_malaria, cases$infected_denv_stfd)
  22+312 #non pf malaria +
  
#create strata: 1 = pf+ & denv + | 2 = pf + denv - | 3= pf- & denv - | 4= pf - & denv + 
cases$strata<-NA
cases <- within(cases, strata[cases$microscopy_malaria_pf_kenya___1==1 & cases$infected_denv_stfd==1] <- 1)
cases <- within(cases, strata[cases$microscopy_malaria_pf_kenya___1==1 & cases$infected_denv_stfd==0] <- 2)
cases <- within(cases, strata[cases$microscopy_malaria_pf_kenya___1==0 & cases$infected_denv_stfd==0] <- 3)
cases <- within(cases, strata[cases$microscopy_malaria_pf_kenya___1==0 & cases$infected_denv_stfd==1] <- 4)
table(cases$strata)

## Create Table 1 stratified by denv/pf status.
symptoms <- cases[, grepl("aic_symptom_", names(cases) ) ]
summary(symptoms)
nameVec <- names(symptoms)
cases <- within(cases, outcome_hospitalized[cases$outcome_hospitalized==8] <-NA )

vars <- c("acute", "aic_calculated_age", "gender_aic", "aic_symptom_abdominal_pain", "aic_symptom_bone_pains", "aic_symptom_chiils", "aic_symptom_cough", "aic_symptom_vomiting", "aic_symptom_headache", "aic_symptom_loss_of_appetite" , "aic_symptom_diarrhea", "aic_symptom_sick_feeling", "aic_symptom_general_body_ache" , "aic_symptom_joint_pains", "aic_symptom_dizziness", "aic_symptom_runny_nose", "aic_symptom_sore_throat", "aic_symptom_rash", "aic_symptom_other", "aic_symptom_shortness_of_breath" , "aic_symptom_nausea", "aic_symptom_fever", "aic_symptom_bloody_urine", "aic_symptom_bloody_stool", "aic_symptom_funny_taste", "aic_symptom_red_eyes", "aic_symptom_earache", "aic_symptom_fits", "aic_symptom_muscle_pains", "aic_symptom_stiff_neck", "aic_symptom_pain_behind_eyes" , "aic_symptom_itchiness", "aic_symptom_bruises", "aic_symptom_impaired_mental_status", "aic_symptom_bloody_nose", "aic_symptom_bleeding_gums", "aic_symptom_eyes_sensitive_to_light", "aic_symptom_bloody_vomit", "aic_symptom_seizures", "aic_symptom_CHIILS", "aic_symptom_RUNNY_NOSE", "aic_symptom_LOSS_OF_APPETITE", "aic_symptom_DIARRHEA", "aic_symptom_COUGH", "aic_symptom_VOMITING", "aic_symptom_FEVER", "aic_symptom_OTHER", "aic_symptom_BONE_PAINS", "aic_symptom_HEADACHE", "aic_symptom_RED_EYES", "aic_symptom_BLOODY_URINE", "aic_symptom_GENERAL_BODY_ACHE" , "aic_symptom_DIZZINESS", "aic_symptom_JOINT_PAINS", "aic_symptom_SORE_THROAT", "aic_symptom_USEA",  "aic_symptom_99", "aic_symptom_RASH",  "aic_symptom_SICK_FEELING", "aic_symptom_ITCHINESS", "aic_symptom_SHORTNESS_OF_BREATH" , "aic_symptom_EARACHE", "aic_symptom_BLOODY_STOOL", "aic_symptom_PAIN_BEHIND_EYES", "aic_symptom_SEIZURES", "aic_symptom_IMPAIRED_MENTAL_STATUS" , "aic_symptom_MUSCLE_PAINS", "aic_symptom_diarrh",  "temp", "outcome_hospitalized", "heart_rate")
factorVars <- c("gender_aic", "acute", "aic_symptom_abdominal_pain", "aic_symptom_bone_pains", "aic_symptom_chiils", "aic_symptom_cough", "aic_symptom_vomiting", "aic_symptom_headache", "aic_symptom_loss_of_appetite" , "aic_symptom_diarrhea", "aic_symptom_sick_feeling", "aic_symptom_general_body_ache" , "aic_symptom_joint_pains", "aic_symptom_dizziness", "aic_symptom_runny_nose", "aic_symptom_sore_throat", "aic_symptom_rash", "aic_symptom_other", "aic_symptom_shortness_of_breath" , "aic_symptom_nausea", "aic_symptom_fever", "aic_symptom_bloody_urine", "aic_symptom_bloody_stool", "aic_symptom_funny_taste", "aic_symptom_red_eyes", "aic_symptom_earache", "aic_symptom_fits", "aic_symptom_muscle_pains", "aic_symptom_stiff_neck", "aic_symptom_pain_behind_eyes" , "aic_symptom_itchiness", "aic_symptom_bruises", "aic_symptom_impaired_mental_status", "aic_symptom_bloody_nose", "aic_symptom_bleeding_gums", "aic_symptom_eyes_sensitive_to_light", "aic_symptom_bloody_vomit", "aic_symptom_seizures", "aic_symptom_CHIILS", "aic_symptom_RUNNY_NOSE", "aic_symptom_LOSS_OF_APPETITE", "aic_symptom_DIARRHEA", "aic_symptom_ABDOMIL_PAIN", "aic_symptom_COUGH", "aic_symptom_VOMITING", "aic_symptom_FEVER", "aic_symptom_OTHER", "aic_symptom_BONE_PAINS", "aic_symptom_HEADACHE", "aic_symptom_RED_EYES", "aic_symptom_BLOODY_URINE", "aic_symptom_GENERAL_BODY_ACHE" , "aic_symptom_DIZZINESS", "aic_symptom_JOINT_PAINS", "aic_symptom_SORE_THROAT", "aic_symptom_USEA",  "aic_symptom_99", "aic_symptom_RASH",  "aic_symptom_SICK_FEELING", "aic_symptom_ITCHINESS", "aic_symptom_SHORTNESS_OF_BREATH" , "aic_symptom_EARACHE", "aic_symptom_abdomina", "aic_symptom_BLOODY_STOOL", "aic_symptom_PAIN_BEHIND_EYES", "aic_symptom_SEIZURES", "aic_symptom_IMPAIRED_MENTAL_STATUS" , "aic_symptom_MUSCLE_PAINS", "aic_symptom_EYES_SENSITIVE_TO_LIGHT" ,"aic_symptom_abdominal_pa", "aic_symptom_abd", "aic_symptom_abdominal_p", "aic_symptom_abdominal_pai", "aic_symptom_diarrh", "aic_symptom_abdo", "aic_symptom_ras", "aic_symptom_a", "aic_symptom_abdomin", "outcome_hospitalized")
tableOne <- CreateTableOne(vars = vars, factorVars = factorVars, strata = "strata", data = cases)
## Tests are by oneway.test/t.test for continuous, chisq.test for categorical

tableOne
summary(tableOne)
print(tableOne, 
      exact = c(
        "aic_symptom_abdominal_pain", "aic_symptom_bone_pains", "aic_symptom_chiils", "aic_symptom_cough", "aic_symptom_vomiting", "aic_symptom_headache", "aic_symptom_loss_of_appetite" , "aic_symptom_diarrhea", "aic_symptom_sick_feeling", "aic_symptom_general_body_ache" , "aic_symptom_joint_pains", "aic_symptom_dizziness", "aic_symptom_runny_nose", "aic_symptom_sore_throat", "aic_symptom_rash", "aic_symptom_other", "aic_symptom_shortness_of_breath" , "aic_symptom_nausea", "aic_symptom_fever", "aic_symptom_bloody_urine", "aic_symptom_bloody_stool", "aic_symptom_funny_taste", "aic_symptom_red_eyes", "aic_symptom_earache", "aic_symptom_fits", "aic_symptom_muscle_pains", "aic_symptom_stiff_neck", "aic_symptom_pain_behind_eyes" , "aic_symptom_itchiness", "aic_symptom_bruises", "aic_symptom_impaired_mental_status", "aic_symptom_bloody_nose", "aic_symptom_bleeding_gums", "aic_symptom_eyes_sensitive_to_light", "aic_symptom_bloody_vomit", "aic_symptom_seizures", "aic_symptom_CHIILS", "aic_symptom_RUNNY_NOSE", "aic_symptom_LOSS_OF_APPETITE", "aic_symptom_DIARRHEA", "aic_symptom_ABDOMIL_PAIN", "aic_symptom_COUGH", "aic_symptom_VOMITING", "aic_symptom_FEVER", "aic_symptom_OTHER", "aic_symptom_BONE_PAINS", "aic_symptom_HEADACHE", "aic_symptom_RED_EYES", "aic_symptom_BLOODY_URINE", "aic_symptom_GENERAL_BODY_ACHE" , "aic_symptom_DIZZINESS", "aic_symptom_JOINT_PAINS", "aic_symptom_SORE_THROAT", "aic_symptom_USEA",  "aic_symptom_99", "aic_symptom_RASH",  "aic_symptom_SICK_FEELING", "aic_symptom_ITCHINESS", "aic_symptom_SHORTNESS_OF_BREATH" , "aic_symptom_EARACHE", "aic_symptom_abdomina", "aic_symptom_BLOODY_STOOL", "aic_symptom_PAIN_BEHIND_EYES", "aic_symptom_SEIZURES", "aic_symptom_IMPAIRED_MENTAL_STATUS" , "aic_symptom_MUSCLE_PAINS", "aic_symptom_EYES_SENSITIVE_TO_LIGHT" ,"aic_symptom_abdominal_pa", "aic_symptom_abd", "aic_symptom_abdominal_p", "aic_symptom_abdominal_pai", "aic_symptom_diarrh", "aic_symptom_abdo", "aic_symptom_ras", "aic_symptom_a", "aic_symptom_abdomin", "temp", "outcome_hospitalized", "heart_rate", "gender_aic", "acute"
        ),
      nonnormal=c("heart_rate", "temp", "aic_calculated_age")
    , quote = TRUE)
#export to csv
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/david coinfectin paper/data")
f <- "cases.csv"
write.csv(as.data.frame(cases), f )
