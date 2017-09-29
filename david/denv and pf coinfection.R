setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long")
#load data that has been cleaned previously
  load("aic_dummy_symptoms.clean.rda") #load the data from your local directory (this will save you time later rather than always downolading from redcap.)
  R01_lab_results<-aic_dummy_symptoms
R01_lab_results$site <-NA
  R01_lab_results <- within(R01_lab_results, id_city[R01_lab_results$id_city=="R"] <- "C")
  R01_lab_results <- within(R01_lab_results, site[R01_lab_results$id_city=="C"] <- "west")
  R01_lab_results <- within(R01_lab_results, site[R01_lab_results$id_city=="K"] <- "west")
  
  R01_lab_results <- within(R01_lab_results, site[R01_lab_results$id_city=="G"] <- "coast")
  R01_lab_results <- within(R01_lab_results, site[R01_lab_results$id_city=="L"] <- "coast")
  R01_lab_results <- within(R01_lab_results, site[R01_lab_results$id_city=="M"] <- "coast")
  R01_lab_results <- within(R01_lab_results, site[R01_lab_results$id_city=="U"] <- "coast")
table(R01_lab_results$site)

# subset of the variables
  cases<-R01_lab_results[which(R01_lab_results$id_cohort=="F" | R01_lab_results$id_cohort=="M" ), ]
  cases <- as.data.frame(cases)
  cases<-cases[which(cases$site=="west"), ]
  cases<-cases[which(cases$redcap_event!="patient_informatio_arm_1"), ]
  cases <- cases[, !grepl("u24|sample", names(cases) ) ]

  #create acute variable
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
  cases <- within(cases, acute[cases$redcap_event=="visit_a_arm_1" & id_cohort=="F"] <- 1)
  #if they have fever, call it acute
  cases <- within(cases, acute[cases$aic_symptom_fever==1] <- 1)
  cases <- within(cases, acute[cases$temp>=38] <- 1)
  #otherwise, it is not acute
  cases <- within(cases, acute[cases$acute!=1 & !is.na(cases$gender_aic) ] <- 0)
  table(cases$acute)#2694 acute febrile visits from aic west
  #create diagram of patients
library("dplyr")
    n_distinct(R01_lab_results$person_id, na.rm = FALSE) #9479 patients reviewed
    n_distinct(cases$person_id, na.rm = FALSE) #3734 patients included in study (aic, west)
    table(cases$acute, exclude = NULL)#2694 acute febrile visits
#table of denv at acute visit. 
    table(cases$infected_denv_stfd, cases$acute, exclude=NULL) #93 denv infected (seroconverter or PCR +)
#Malaria: positive by result_microscopy_malaria_kenya, or if NA, then positive by malaria_result
    cases$malaria<-NA
    cases <- within(cases, malaria[cases$result_rdt_malaria_keny==0] <- 0)#rdt
    cases <- within(cases, malaria[cases$rdt_result==0] <- 0)#rdt
    cases <- within(cases, malaria[cases$malaria_results==0] <- 0)# Results of malaria blood smear	(+++ system)
    cases <- within(cases, malaria[cases$result_microscopy_malaria_kenya==0] <- 0)#microscopy. this goes last so that it overwrites all the other's if it exists.

    cases <- within(cases, malaria[cases$result_microscopy_malaria_kenya==1] <- 1) #this goes first. only use the others if this is missing.
    cases <- within(cases, malaria[cases$malaria_results>0 & is.na(result_microscopy_malaria_kenya)] <- 1)# Results of malaria blood smear	(+++ system)
    cases <- within(cases, malaria[cases$result_rdt_malaria_kenya==1 & is.na(result_microscopy_malaria_kenya)] <- 1)#rdt
    cases <- within(cases, malaria[cases$rdt_result==1 & is.na(result_microscopy_malaria_kenya)] <- 1)#rdt
    table(cases$malaria)
  #by pcr or igg seroc?
    cases$pcr_denv<-NA
    cases <- within(cases, pcr_denv[cases$result_pcr_denv_kenya==0] <- 0)
    cases <- within(cases, pcr_denv[cases$result_pcr_denv_stfd==0] <- 0)
    cases <- within(cases, pcr_denv[cases$result_pcr_denv_kenya==1] <- 1)
    cases <- within(cases, pcr_denv[cases$result_pcr_denv_stfd==1] <- 1)
    table(cases$pcr_denv)
    
  table(cases$seroc_denv_stfd_igg, cases$pcr_denv)#87 by pcr, 6 by igg seroconversion.
  table(cases$infected_denv_stfd, cases$malaria, exclude = NULL)
  table(cases$infected_denv_stfd, exclude = NULL)
  #some need to be malaria tested to be included in sample
    not_malaria_tested<-cases[which(is.na(cases$malaria) & cases$infected_denv_stfd==1), ]
    table(is.na(cases$malaria) & cases$infected_denv_stfd==1)
    table(not_malaria_tested$person_id, not_malaria_tested$redcap_event_name)
#keep only acute
  cases<-cases[which(cases$acute==1), ]

#keep only those tested for both malaria and denv.
  #define denv testing as pcr or paired igg.
    cases$tested_malaria<-NA
    cases <- within(cases, tested_malaria[!is.na(cases$malaria)] <- 1)
    cases <- within(cases, tested_denv_stfd_igg[cases$infected_denv_stfd==1 |cases$tested_denv_stfd_igg==1 | !is.na(cases$pcr_denv)] <- 1)
    cases <- within(cases, tested_denv_stfd_igg[cases$tested_denv_stfd_igg==0 ] <- NA)
#count just tested for denv not malaria  #just tested for malaria not denv
    table(cases$tested_malaria, exclude = NULL)#malaria tested = 1946. NA = 748
    table(cases$tested_denv_stfd_igg, exclude = NULL)#denv tested = 1791. NA = 903
    table(cases$tested_denv_stfd_igg, cases$tested_malaria, exclude = NULL)# 166 not malaria tested but denv tested. 321 malaria tested but not denv tested. 582 tested for neither. 1625 tested for both
  #keep only those tested for both
    cases<-cases[which(!is.na(cases$malaria) & cases$tested_denv_stfd_igg==1  & cases$acute==1), ]
#flow chart of subjects.    
  length(cases$person_id)#1625 acute visits tested for both denv and malaria.
  n_distinct(cases$person_id)#1573 unique subjects.
#denv and any malaria  
#Can you then create a DENV/malaria where all episodes can be defined as DENV/malaria pos, DENV pos, malaria pos, or DENV/malaria neg?
  table(cases$malaria, cases$infected_denv_stfd)#662 negative for both; 46 positive for both; 86 positive for denv; 923 malaria positive.
  cases$malaria_species<-NA
  
  cases_malariawide<- cases[, grepl("person_id|redcap_event_name|microscopy_malaria_p|microscopy_malaria_n", names(cases) ) ]
  cases_malariawide<-reshape(cases_malariawide, idvar = c("person_id", "redcap_event_name"), varying = 1:5,  direction = "long", timevar = "species", times=c("pf","pm","pv","po", "ni"), v.names=c("microscopy_malaria"))
  table(cases_malariawide$species, cases_malariawide$microscopy_malaria)
  
#denv and pf malaria
  table(cases$result_microscopy_malaria_kenya, cases$tested_denv_stfd_igg) #1213

microscopy_tested<-cases[which(!is.na(cases$result_microscopy_malaria_kenya) & cases$tested_denv_stfd_igg==1  & cases$acute==1), ]

  table(microscopy_tested$microscopy_malaria_pf_kenya___1, microscopy_tested$infected_denv_stfd)
484+21+25+683  
  table(cases$result_microscopy_malaria_kenya)#502+711
  
  489+24 # pf malaria
#denv and non pf.
  non_pf_malaria<-NA
  cases <- within(cases, non_pf_malaria[cases$malaria==1 &cases$microscopy_malaria_pf_kenya___1 !=1] <- 1)
  table(cases$non_pf_malaria, cases$infected_denv_stfd)
  22+312 #non pf malaria +
#denv and all malaria.
  table(cases$malaria, cases$infected_denv_stfd, exclude = NULL)
  table(cases$malaria)
  table(cases$infected_denv_stfd, exclude = NULL)
  
#What I would like is the cases defined as follows:
#DENV: positive by RT-PCR, or IgG seroconversion (I've run your code but there are symptoms variables that give me errors.says they don't exist). Can you also query how many seroconverted bc, de, fg?
    #this is the same way i have defined infection for desiree.
      table(aic_dummy_symptoms$seroc_denv_stfd_igg, aic_dummy_symptoms$redcap_event_name)    
      table(aic_dummy_symptoms$seroc_chikv_stfd_igg, aic_dummy_symptoms$redcap_event_name)    
    
      table(aic_dummy_symptoms$result_pcr_chikv_kenya, aic_dummy_symptoms$redcap_event_name)    
      table(aic_dummy_symptoms$result_pcr_denv_kenya, aic_dummy_symptoms$redcap_event_name)    
    
      table(aic_dummy_symptoms$result_pcr_chikv_stfd, aic_dummy_symptoms$redcap_event_name)    
      table(aic_dummy_symptoms$result_pcr_denv_stfd, aic_dummy_symptoms$redcap_event_name)    
    
      table(aic_dummy_symptoms$tested_chikv_stfd_igg, aic_dummy_symptoms$redcap_event_name)    
      table(aic_dummy_symptoms$tested_denv_stfd_igg, aic_dummy_symptoms$redcap_event_name)    
#repate analyasis for both pf and malaria
      
    #create strata: 1 = malaria+ & denv + | 2 = malaria+ denv - | 3= malaria- & denv - | 4= malaria- & denv + 
          cases$strata_all<-NA
          cases <- within(cases, strata_all[cases$malaria==1 & cases$infected_denv_stfd==1] <- "malaria_pos_&_denv_pos")
          cases <- within(cases, strata_all[cases$malaria==1 & cases$infected_denv_stfd==0] <- "malaria_pos_&_denv_neg")
          cases <- within(cases, strata_all[cases$malaria==0 & cases$infected_denv_stfd==0] <- "malaria_neg_&_denv neg")
          cases <- within(cases, strata_all[cases$malaria==0 & cases$infected_denv_stfd==1] <- "malaria_neg_&_denv_pos")
          table(cases$strata_all)
          
    #create strata: 1 = pf+ & denv + | 2 = pf + denv - | 3= pf- & denv - | 4= pf - & denv + 
          #d+, pf+, m+ / d+ pf- m - / d+pf-, m+ / d-p-m+ / d-pf-m- / d-pf+m+
    cases$strata<-NA
      cases <- within(cases, strata[cases$microscopy_malaria_pf_kenya___1==1 & cases$infected_denv_stfd==1] <- "pf_pos_&_denv_pos")
      cases <- within(cases, strata[cases$microscopy_malaria_pf_kenya___1==1 & cases$infected_denv_stfd==0] <- "pf_pos_&_denv_neg")
      cases <- within(cases, strata[cases$microscopy_malaria_pf_kenya___1==0 & !is.na(cases$result_microscopy_malaria_kenya) & cases$malaria!=1 & cases$infected_denv_stfd==0] <- "pf_neg_&_denv_neg")
      cases <- within(cases, strata[cases$microscopy_malaria_pf_kenya___1==0 &  !is.na(result_microscopy_malaria_kenya) & cases$malaria!=1 & cases$infected_denv_stfd==1] <- "pf_neg_&_denv_pos")
      table(cases$strata)  

save(cases,file="cases.rda")
load("cases.rda")
names(cases)[names(cases) == 'redcap_event'] <- 'redcap_event_name'

#merge with paired pedsql data (acute and convalescent)
library("plyr")
  load("pedsql_pairs_acute.rda")
  names(pedsql_pairs_acute)[names(pedsql_pairs_acute) == 'redcap_event_name_acute_paired'] <- 'redcap_event_name'
  cases_pedsql <- join(cases, pedsql_pairs_acute,  by=c("person_id", "redcap_event_name"), match = "all" , type="full")
  cases_pedsql<-cases_pedsql[order(-(grepl('person_id|redcap|pedsql_', names(cases_pedsql)))+1L)]

  table(cases_pedsql$pedsql_parent_social_mean_acute_paired,cases_pedsql$pedsql_parent_social_mean_conv_paired)

  cases<-cases_pedsql
  cases<-cases[order(-(grepl('person_id|redcap|pedsql_', names(cases)))+1L)]
  
#merge with unpaired pedsql data
  load("pedsql.rda")
  names(pedsql)[names(pedsql) == 'redcap_event'] <- 'redcap_event_name'
  cases_pedsql <- join(cases, pedsql,  by=c("person_id", "redcap_event_name"), match = "all" , type="full")
  table(cases_pedsql$pedsql_child_social_mean_acute, cases_pedsql$strata)
  cases<-cases_pedsql

#plot paired outcomes over time.
  library("ggplot2")
  ggplot(aes(x = redcap_event_name, y =pedsql_child_emotional_mean_acute, color=strata), data = cases) + geom_point()+geom_line()
  table(cases$pedsql_child_emotional_mean_acute, cases$redcap_event_name) 

## Create Table 1 stratified by denv/pf status.
  ## Tests are by oneway.test/t.test for continuous, chisq.test for categorical
  library("tableone")
  cases <- as.matrix.data.frame(cases)
  cases <- data.frame(cases)
  cases$outcome_hospitalized<-as.numeric(as.character(cases$outcome_hospitalized))
  cases <- within(cases, outcome_hospitalized[outcome_hospitalized==8] <-NA )
  table(cases$outcome_hospitalized)
  #demographics
  
  #ses- create an index
  cases <- within(cases, kid_highest_level_education_aic[cases$kid_highest_level_education_aic==9|cases$kid_highest_level_education_aic==5] <- NA)
  cases <- within(cases, mom_highest_level_education_aic[cases$mom_highest_level_education_aic==9|cases$mom_highest_level_education_aic==5] <- NA)
  cases <- within(cases, roof_type[cases$roof_type==9|cases$roof_type==4] <- NA)
  cases <- within(cases, latrine_type[cases$latrine_type==9|cases$latrine_type==6] <- NA)
  cases <- within(cases, floor_type[cases$floor_type==9|cases$floor_type==5] <- NA)

  cases <- within(cases, drinking_water_source[cases$drinking_water_source==9|cases$drinking_water_source==6] <- NA)
  cases$drinking_water_source<-  as.numeric(as.character(cases$drinking_water_source))
  class(cases$drinking_water_source)
  
  class(cases$light_source)
  table(cases$light_source)
  cases$light_source<-  as.numeric(as.character(cases$light_source))
  
  cases <- within(cases, light_source[cases$light_source==9|cases$light_source==7] <- NA)
  cases <- within(cases, light_source[cases$light_source==1] <- 30)
  cases <- within(cases, light_source[cases$light_source==3] <- 20)
  cases <- within(cases, light_source[cases$light_source==2|cases$light_source==4|cases$light_source==5|cases$light_source==6] <- 10)
  cases$light_source <- cases$light_source/10 
  table(cases$light_source)
  class(cases$light_source)
  
  
  cases$telephone<-  as.numeric(as.character(cases$telephone))
  cases <- within(cases, telephone[cases$telephone==8] <- NA)
  class(cases$telephone)
  
  
  cases$radio<-  as.numeric(as.character(cases$radio))
  cases <- within(cases, radio[cases$radio==8] <- NA)
  class(cases$radio)
  

  cases$television<-  as.numeric(as.character(cases$television))
  cases <- within(cases, television[cases$television==8] <- NA)
  class(cases$television)
  
  
  cases$bicycle<-  as.numeric(as.character(cases$bicycle))
  cases <- within(cases, bicycle[cases$bicycle==8] <- NA)
  class(cases$bicycle)
  
  cases$motor_vehicle<-  as.numeric(as.character(cases$motor_vehicle))
  cases <- within(cases, motor_vehicle[cases$motor_vehicle==8] <- NA)
  class(cases$motor_vehicle)
  
  cases$domestic_worker<-  as.numeric(as.character(cases$domestic_worker))
  cases <- within(cases, domestic_worker[cases$domestic_worker==8] <- NA)
  class(cases$domestic_worker)
  table(cases$domestic_worker)

  ses<-(cases[, grepl("telephone|radio|television|bicycle|motor_vehicle|domestic_worker", names(cases))])
  cases$ses_sum<-rowSums(cases[, c("telephone","radio","television","bicycle","motor_vehicle", "domestic_worker")], na.rm = TRUE)
  table(cases$ses_sum)

    class(cases$aic_calculated_age)
    cases$aic_calculated_age<-as.numeric(as.character(cases$aic_calculated_age))
    library("tableone")
    cases<-cases[order(-(grepl('pedsql_', names(cases)))+1L)]
    cases<-cases[order(-(grepl('_mean', names(cases)))+1L)]
    cases[1:100] <- sapply(cases[1:100], as.numeric)
    cases<-cases[order(-(grepl('person_id|redcap', names(cases)))+1L)]
    
                           
    dem_factorVars <- c("id_city")
    dem_vars=c("id_city", "gender_all","aic_calculated_age","ses_sum")
    dem_tableOne <- CreateTableOne(vars = dem_vars, factorVars = dem_factorVars, strata = "strata", data = cases)
    #summary(dem_tableOne)
    print(dem_tableOne, exact = c("id_city", "gender_all"), nonnormal=c("aic_calculated_age","ses_sum"), quote = TRUE, includeNA=TRUE)

  #mosquito
    cases$mosquito_bites_aic<-as.numeric(as.character(cases$mosquito_bites_aic))
    cases <- within(cases, mosquito_bites_aic[cases$mosquito_bites_aic==8] <-NA )

    cases$mosquito_coil_aic<-as.numeric(as.character(cases$mosquito_coil_aic))
    cases <- within(cases, mosquito_coil_aic[cases$mosquito_coil_aic==8] <-NA )

    cases$outdoor_activity_aic<-as.numeric(as.character(cases$outdoor_activity_aic))
    cases <- within(cases, outdoor_activity_aic[cases$outdoor_activity_aic==8] <-NA )

    cases$mosquito_net_aic<-as.numeric(as.character(cases$mosquito_net_aic))
    cases <- within(cases, mosquito_net_aic[cases$mosquito_net_aic==8] <-NA )

    mosq_vars <- c("mosquito_bites_aic", "mosquito_coil_aic", "outdoor_activity_aic", "mosquito_net_aic") 
    mosq_factorVars <- c("mosquito_bites_aic", "mosquito_coil_aic", "outdoor_activity_aic", "mosquito_net_aic") 
    
    mosq_tableOne <- CreateTableOne(vars = mosq_vars, strata = "strata", factorVars=mosq_factorVars, data = cases)
  #summary(mosq_tableOne)
    print(mosq_tableOne, exact = c("mosquito_bites_aic", "mosquito_coil_aic", "outdoor_activity_aic", "mosquito_net_aic"), quote = TRUE, includeNA=TRUE)

  #pedsql paired
    table(cases_pedsql$pedsql_parent_social_mean_conv_paired,cases_pedsql$pedsql_parent_social_mean_acute_paired)

    pedsql_paired_vars <- c("pedsql_child_school_mean_acute_paired", "pedsql_child_school_mean_conv_paired", "pedsql_child_social_mean_acute_paired", "pedsql_child_social_mean_conv_paired", "pedsql_parent_school_mean_acute_paired", "pedsql_parent_school_mean_conv_paired", "pedsql_parent_social_mean_acute_paired", "pedsql_parent_social_mean_conv_paired", "pedsql_child_physical_mean_acute_paired", "pedsql_child_physical_mean_conv_paired", "pedsql_parent_physical_mean_acute_paired", "pedsql_parent_physical_mean_conv_paired", "pedsql_child_emotional_mean_acute_paired", "pedsql_child_emotional_mean_conv_paired", "pedsql_parent_emotional_mean_acute_paired", "pedsql_parent_emotional_mean_conv_paired")
    pedsql_paired_tableOne <- CreateTableOne(vars = pedsql_paired_vars, strata = "strata", data = cases)
    summary(pedsql_paired_tableOne)
    #print table one (assume non normal distribution)
      print(pedsql_paired_tableOne, 
            exact = c(),
            nonnormal=c("pedsql_child_school_mean_conv_paired", "pedsql_child_social_mean_acute_paired", "pedsql_child_social_mean_conv_paired", "pedsql_parent_school_mean_acute_paired", "pedsql_parent_school_mean_conv_paired", "pedsql_parent_social_mean_aucte", "pedsql_parent_social_conv_paired", "pedsql_child_physical_mean_acute_paired", "pedsql_child_physical_mean_conv_paired", "pedsql_parent_physical_mean_acute_paired", "pedsql_parent_physical_mean_conv_paired", "pedsql_child_emotional_mean_acute_paired", "pedsql_child_emotional_mean_conv_paired", "pedsql_parent_emotional_mean_acute_paired", "pedsql_parent_emotional_mean_conv_paired")
            , quote = TRUE, includeNA=TRUE)
    #print table one (assume normal distribution)
      print(pedsql_paired_tableOne, 
            exact = c(),
            #nonnormal=c("pedsql_child_school_mean_conv", "pedsql_child_social_mean_acute", "pedsql_child_social_mean_conv", "pedsql_parent_school_mean_acute", "pedsql_parent_school_mean_conv", "pedsql_parent_social_mean_aucte", "pedsql_parent_social_conv", "pedsql_child_physical_mean_acute", "pedsql_child_physical_mean_conv", "pedsql_parent_physical_mean_acute", "pedsql_parent_physical_mean_conv", "pedsql_child_emotional_mean_acute", "pedsql_child_emotional_mean_conv", "pedsql_parent_emotional_mean_acute", "pedsql_parent_emotional_mean_conv"),
            quote = TRUE, includeNA=TRUE)
#pedsql unpaired
    cases<-cases[order(-(grepl('_mean', names(cases)))+1L)]
    cases<-cases[order(-(grepl('person_id|redcap|strata', names(cases)))+1L)]
    
    pedsql_vars <- c("pedsql_child_school_mean_acute", "pedsql_child_school_mean_conv", "pedsql_child_social_mean_acute", "pedsql_child_social_mean_conv", "pedsql_parent_school_mean_acute", "pedsql_parent_school_mean_conv", "pedsql_parent_social_mean_aucte", "pedsql_parent_social_conv", "pedsql_child_physical_mean_acute", "pedsql_child_physical_mean_conv", "pedsql_parent_physical_mean_acute", "pedsql_parent_physical_mean_conv", "pedsql_child_emotional_mean_acute", "pedsql_child_emotional_mean_conv", "pedsql_parent_emotional_mean_acute", "pedsql_parent_emotional_mean_conv")
    
    pedsql_tableOne <- CreateTableOne(vars = pedsql_vars, strata = "strata", data = cases)
    summary(pedsql_tableOne)
    #print table one (assume non normal distribution)
    print(pedsql_tableOne, 
          exact = c(),
          nonnormal=c("pedsql_child_school_mean_conv", "pedsql_child_social_mean_acute", "pedsql_child_social_mean_conv", "pedsql_parent_school_mean_acute", "pedsql_parent_school_mean_conv", "pedsql_parent_social_mean_aucte", "pedsql_parent_social_conv", "pedsql_child_physical_mean_acute", "pedsql_child_physical_mean_conv", "pedsql_parent_physical_mean_acute", "pedsql_parent_physical_mean_conv", "pedsql_child_emotional_mean_acute", "pedsql_child_emotional_mean_conv", "pedsql_parent_emotional_mean_acute", "pedsql_parent_emotional_mean_conv")
          , quote = TRUE, includeNA=TRUE)
    #print table one (assume normal distribution)
    
    print(pedsql_tableOne, 
          exact = c(),
          #nonnormal=c("pedsql_child_school_mean", "pedsql_child_social_mean", "pedsql_parent_school_mean",  "pedsql_parent_social_mean_aucte", "pedsql_child_physical_mean", "pedsql_parent_physical_mean", "pedsql_child_emotional_mean", "pedsql_parent_emotional_mean"), 
          quote = TRUE, includeNA=TRUE)
    
    
  #symptoms
    cases$heart_rate<-    as.numeric(as.character(cases$heart_rate))
    cases$temp<-    as.numeric(as.character(cases$temp))
    symptom_vars <- c("aic_symptom_abdominal_pain", "aic_symptom_chills", "aic_symptom_cough", "aic_symptom_vomiting", "aic_symptom_headache", "aic_symptom_loss_of_appetite", "aic_symptom_diarrhea", "aic_symptom_sick_feeling",  "aic_symptom_general_body_ache", "aic_symptom_joint_pains", "aic_symptom_dizziness", "aic_symptom_runny_nose", "aic_symptom_sore_throat", "aic_symptom_rash", "aic_symptom_shortness_of_breath", "aic_symptom_nausea", "aic_symptom_fever", "aic_symptom_funny_taste", "aic_symptom_red_eyes", "aic_symptom_earache", "aic_symptom_stiff_neck", "aic_symptom_pain_behind_eyes", "aic_symptom_itchiness", "aic_symptom_impaired_mental_status", "aic_symptom_eyes_sensitive_to_light", "bleeding", "body_ache", "temp", "heart_rate")
    symptom_factorVars <- c("aic_symptom_abdominal_pain", "aic_symptom_chills", "aic_symptom_cough", "aic_symptom_vomiting", "aic_symptom_headache", "aic_symptom_loss_of_appetite", "aic_symptom_diarrhea", "aic_symptom_sick_feeling",  "aic_symptom_general_body_ache", "aic_symptom_joint_pains", "aic_symptom_dizziness", "aic_symptom_runny_nose", "aic_symptom_sore_throat", "aic_symptom_rash", "aic_symptom_shortness_of_breath", "aic_symptom_nausea", "aic_symptom_fever", "aic_symptom_funny_taste", "aic_symptom_red_eyes", "aic_symptom_earache", "aic_symptom_stiff_neck", "aic_symptom_pain_behind_eyes", "aic_symptom_itchiness", "aic_symptom_impaired_mental_status", "aic_symptom_eyes_sensitive_to_light", "bleeding", "body_ache")
    
    symptoms_tableOne <- CreateTableOne(vars = symptom_vars, factorVars = symptom_factorVars, strata = "strata", data = cases)
    #summary(symptoms_tableOne)
    cases$aic_symp
    print(symptoms_tableOne, 
          exact = c(
            "aic_symptom_abdominal_pain", "aic_symptom_chills", "aic_symptom_cough", "aic_symptom_vomiting", "aic_symptom_headache", "aic_symptom_loss_of_appetite", "aic_symptom_diarrhea", "aic_symptom_sick_feeling",  "aic_symptom_general_body_ache", "aic_symptom_joint_pains", "aic_symptom_dizziness", "aic_symptom_runny_nose", "aic_symptom_sore_throat", "aic_symptom_rash", "aic_symptom_shortness_of_breath", "aic_symptom_nausea", "aic_symptom_fever", "aic_symptom_funny_taste", "aic_symptom_red_eyes", "aic_symptom_earache", "aic_symptom_stiff_neck", "aic_symptom_pain_behind_eyes", "aic_symptom_itchiness", "aic_symptom_impaired_mental_status", "aic_symptom_eyes_sensitive_to_light", "bleeding", "body_ache", "temp", "heart_rate", "temp", "outcome_hospitalized", "heart_rate"
          ),
          nonnormal=c("heart_rate", "temp")
          , quote = TRUE, includeNA=TRUE)

#export to csv
  setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/david coinfectin paper/data")
  f <- "cases.csv"
  write.csv(as.data.frame(cases), f )
#save data frame
  save(cases,file="david_cases.rda")