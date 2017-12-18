# import data -------------------------------------------------------------
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long")
#load data that has been cleaned previously
  load("R01_lab_results.david.coinfection.dataset.rda") #load the data from your local directory (this will save you time later rather than always downolading from redcap.)
  
# subset our data to david's cohort of aic west ---------------------------
  R01_lab_results<- R01_lab_results[which(R01_lab_results$redcap_event_name!="visit_a2_arm_1" & R01_lab_results$redcap_event_name!="visit_b2_arm_1"&R01_lab_results$redcap_event_name!="visit_c2_arm_1"&R01_lab_results$redcap_event_name!="visit_d2_arm_1"&R01_lab_results$redcap_event_name!="visit_c2_arm_1"&R01_lab_results$redcap_event_name!="visit_u24_arm_1")  , ]
  cases<-R01_lab_results[which(R01_lab_results$Cohort=="F" | R01_lab_results$Cohort=="M" ), ]
  cases <- as.data.frame(cases)
  cases<-cases[which(cases$site=="W"), ]
  cases<-cases[which(cases$redcap_event!="patient_informatio_arm_1"), ]
  cases <- cases[, !grepl("u24|sample", names(cases) ) ]


# #create acute variable  ------------------------------------------------------------------------
  cases$acute<-NA
    cases <- within(cases, acute[cases$visit_type==1] <- 1)
    cases <- within(cases, acute[cases$visit_type==2] <- 1)
    cases <- within(cases, acute[cases$visit_type==3] <- 0)
    cases <- within(cases, acute[cases$visit_type==4] <- 1)
    cases <- within(cases, acute[cases$visit_type==5] <- 0)

  #if they ask an initial survey question (see odk aic inital and follow up forms), it is an initial visit.
    cases <- within(cases, acute[cases$kid_highest_level_education_aic!=""] <- 1)
    cases <- within(cases, acute[cases$occupation_aic!=""] <- 1)
    cases <- within(cases, acute[cases$oth_educ_level_aic!=""] <- 1)
    cases <- within(cases, acute[cases$mom_highest_level_education_aic!=""] <- 1)
    cases <- within(cases, acute[cases$roof_type!=""] <- 1)
    cases <- within(cases, acute[cases$pregnant!=""] <- 1)
  #if it is visit a,call it acute
    cases <- within(cases, acute[cases$redcap_event=="visit_a_arm_1" & cases$Cohort=="F"] <- 1)
  
  #if they have fever, call it acute
    cases <- within(cases, acute[cases$aic_symptom_fever==1] <- 1)
    cases <- within(cases, acute[cases$temp>=38] <- 1)
  
  #otherwise, it is not acute
    cases <- within(cases, acute[cases$acute!=1] <- 0)
    table(cases$acute)

# count number per group for subject diagram------------------------------------------------------------------------
library("dplyr")
  n<-sum(n_distinct(R01_lab_results$person_id, na.rm = FALSE)) #9772 patients reviewed
  aic_n<-sum(n_distinct(cases$person_id, na.rm = FALSE)) #2011 patients included in study (aic, west)
  afi<-  sum(cases$acute==1, na.rm = TRUE)#2775 afi's
#denv  case defination------------------------------------------------------------------------
  #redefine infected_denv_stfd to exclude ufi. 
  #stfd denv igg seroconverters or PCR positives as infected.
    cases$infected_denv_stfd<-NA
    cases$infected_denv_stfd[cases$tested_denv_stfd_igg ==1 |cases$result_pcr_denv_kenya==0|cases$result_pcr_denv_stfd==0]<-0
    cases$infected_denv_stfd[cases$seroc_denv_stfd_igg==1|cases$result_pcr_denv_kenya==1|cases$result_pcr_denv_stfd==1]<-1
      table(cases$seroc_denv_stfd_igg)
      table(cases$infected_denv_stfd)  
    
  #table of denv at acute visit. 
    denv_acute<-  sum(cases$infected_denv_stfd==1 & cases$acute==1, na.rm = TRUE)#126 denv infected (seroconverter or PCR +)
#malaria case defination------------------------------------------------------------------------
#Malaria: positive by result_microscopy_malaria_kenya, or if NA, then positive by malaria_result
    cases$malaria<-NA
    cases <- within(cases, malaria[cases$result_rdt_malaria_keny==0] <- 0)#rdt
    cases <- within(cases, malaria[cases$rdt_result==0] <- 0)#rdt
    cases <- within(cases, malaria[cases$malaria_results==0] <- 0)# Results of malaria blood smear	(+++ system)
    cases <- within(cases, malaria[cases$result_microscopy_malaria_kenya==0] <- 0)#microscopy. this goes last so that it overwrites all the other's if it exists.

    cases <- within(cases, malaria[cases$result_microscopy_malaria_kenya==1] <- 1) #this goes first. only use the others if this is missing.
    cases <- within(cases, malaria[cases$malaria_results>0 & is.na(result_microscopy_malaria_kenya)] <- 1)# Results of malaria blood smear	(+++ system)
    cases <- within(cases, malaria[cases$rdt_results==1 & is.na(result_microscopy_malaria_kenya)] <- 1)#rdt
    table(cases$malaria)
#denv by pcr or serology ------------------------------------------------------------------------
    cases$pcr_denv<-NA
    cases <- within(cases, pcr_denv[cases$result_pcr_denv_kenya==0] <- 0)
    cases <- within(cases, pcr_denv[cases$result_pcr_denv_stfd==0] <- 0)
    cases <- within(cases, pcr_denv[cases$result_pcr_denv_kenya==1] <- 1)
    cases <- within(cases, pcr_denv[cases$result_pcr_denv_stfd==1] <- 1)
    table(cases$pcr_denv)
    table(cases$seroc_denv_stfd_igg)
  table(cases$seroc_denv_stfd_igg, cases$pcr_denv, exclude = NULL)#87 by pcr, 6 by igg seroconversion.
  table(cases$infected_denv_stfd, cases$malaria, exclude = NULL)
  table(cases$infected_denv_stfd, exclude = NULL)
#  #some need to be malaria tested to be included in sample ------------------------------------------------------------------------
    not_malaria_tested<-cases[which(is.na(cases$malaria) & cases$infected_denv_stfd==1), ]
    table(is.na(cases$malaria) & cases$infected_denv_stfd==1)
    table(not_malaria_tested$person_id, not_malaria_tested$redcap_event_name)
#  keep acute only ------------------------------------------------------------------------
  cases<-cases[which(cases$acute==1), ]

#  keep only those tested for both denv and malaria ------------------------------------------------------------------------
    #define denv testing as pcr or paired igg.
    cases$tested_malaria<-NA
    cases <- within(cases, tested_malaria[!is.na(cases$malaria)] <- 1)
    cases <- within(cases, tested_denv_stfd_igg[!is.na(cases$infected_denv_stfd) |cases$tested_denv_stfd_igg==1] <- 1)
    cases <- within(cases, tested_denv_stfd_igg[cases$tested_denv_stfd_igg==0 ] <- NA)
#count just tested for denv not malaria  #just tested for malaria not denv
    table(cases$tested_malaria, exclude = NULL)#malaria tested = 2189 NA = 586
    table(cases$tested_denv_stfd_igg, exclude = NULL)#denv tested = 1812 NA = 963
    table(cases$tested_denv_stfd_igg, cases$tested_malaria, exclude = NULL)# 166 not malaria tested but denv tested. 321 malaria tested but not denv tested. 582 tested for neither. 1625 tested for both
    denv_tested_malaria_tested <-  sum(!is.na(cases$infected_denv_stfd) & !is.na(cases$malaria), na.rm = TRUE)#1761 teste for both
    denv_not_tested_malaria_not_tested  <-  sum(is.na(cases$infected_denv_stfd) & is.na(cases$malaria), na.rm = TRUE)#538
    denv_not_tested_malaria_tested <-  sum(is.na(cases$infected_denv_stfd) & !is.na(cases$malaria), na.rm = TRUE)#351
    denv_tested_malaria_not_tested <-  sum(!is.na(cases$infected_denv_stfd) & is.na(cases$malaria), na.rm = TRUE)#52
    
  #keep only those tested for both
    cases<-cases[which(!is.na(cases$malaria) & cases$tested_denv_stfd_igg==1  & cases$acute==1), ]
#flow chart of subjects.    
  n_events_tested<-  sum(length(cases$person_id))#1761 acute visits tested for both denv and malaria.
  n_subjects_tested<-  sum(n_distinct(cases$person_id), na.rm = TRUE)#1680 unique subjects.
  
#  strata for malaria and denv------------------------------------------------------------------------
  #denv and any malaria  
#Can you then create a DENV/malaria where all episodes can be defined as DENV/malaria pos, DENV pos, malaria pos, or DENV/malaria neg?
  #What I would like is the cases defined as follows:
  #DENV: positive by RT-PCR, or IgG seroconversion (I've run your code but there are symptoms variables that give me errors.says they don't exist). Can you also query how many seroconverted bc, de, fg?
  #this is the same way i have defined infection for desiree.
  
  table(cases$malaria, cases$infected_denv_stfd, exclude = NULL)
  denv_pos_malaria_neg <-  sum(cases$infected_denv_stfd==1 & cases$malaria==0, na.rm = TRUE)#42
  denv_pos_malaria_pos <-  sum(cases$infected_denv_stfd==1 & cases$malaria==1, na.rm = TRUE)#48
  denv_neg_malaria_neg <-  sum(cases$infected_denv_stfd==0 & cases$malaria==0, na.rm = TRUE)#695
  denv_neg_malaria_pos <-  sum(cases$infected_denv_stfd==0 & cases$malaria==1, na.rm = TRUE)#976
  
# malaria species------------------------------------------------------------------------
  cases$malaria_species<-NA
  
  cases_malariawide<- cases[, grepl("person_id|redcap_event_name|microscopy_malaria_p|microscopy_malaria_n", names(cases) ) ]
  cases_malariawide<-cases_malariawide[,order(colnames(cases_malariawide))]
  cases_malariawide<-as.data.frame(cases_malariawide)
  cases_malariawide<-reshape(cases_malariawide, idvar = c("person_id", "redcap_event_name"), varying = 1:5,  direction = "long", timevar = "species", times=c("ni", "pf","pm","po","pv"), v.names=c("microscopy_malaria"))
  
  cases_malariawide<- within(cases_malariawide, species[microscopy_malaria!=1] <- NA)
  cases_malariawide<-cases_malariawide[which(!is.na(cases_malariawide$species)),]
  
  cases_malariawide<-cases_malariawide %>% group_by(person_id,redcap_event_name) %>% mutate(malaria_coinfection = n())
  cases_malariawide<-aggregate( .~ person_id+redcap_event_name, cases_malariawide, function(x) toString(unique(x)))
  
  table(cases_malariawide$species)
  ((764+2+5)/(976+48))*100
  
  cases$malaria_pf<-NA
  cases <- within(cases, malaria_pf[cases$result_rdt_malaria_keny==0 & cases$malaria!=1] <- 0)#rdt
  cases <- within(cases, malaria_pf[cases$result_rdt_malaria_keny==1] <- 1)#rdt

  cases <- within(cases, malaria_pf[cases$microscopy_malaria_pf_kenya___1==0 & !is.na(cases$result_microscopy_malaria_kenya) & cases$malaria!=1] <- 0)#rdt
  cases <- within(cases, malaria_pf[cases$microscopy_malaria_pf_kenya___1==1] <- 1)#rdt
  
  table(cases$malaria_pf)#pf pos/neg
  table(cases$malaria)#malaria pos/neg
  
# pf malaria strata------------------------------------------------------------------------
  table(cases$malaria_pf, cases$infected_denv_stfd)
  denv_pf_tested_events<-sum(!is.na(cases$infected_denv_stfd) & !is.na(cases$malaria_pf), na.rm = TRUE)
  denv_pos_pf_neg <-  sum(cases$infected_denv_stfd==1 & cases$malaria_pf==0, na.rm = TRUE)#35
  denv_pos_pf_pos <-  sum(cases$infected_denv_stfd==1 & cases$malaria_pf==1, na.rm = TRUE)#40
  denv_neg_pf_neg <-  sum(cases$infected_denv_stfd==0 & cases$malaria_pf==0, na.rm = TRUE)#497
  denv_neg_pf_pos <-  sum(cases$infected_denv_stfd==0 & cases$malaria_pf==1, na.rm = TRUE)#719
  

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
      cases <- within(cases, strata[cases$result_rdt_malaria_kenya==1 & cases$infected_denv_stfd==1] <- "pf_pos_&_denv_pos")
      
      cases <- within(cases, strata[cases$microscopy_malaria_pf_kenya___1==1 & cases$infected_denv_stfd==0] <- "pf_pos_&_denv_neg")
      cases <- within(cases, strata[cases$result_rdt_malaria_kenya==1 & cases$infected_denv_stfd==0] <- "pf_pos_&_denv_neg")
      
      cases <- within(cases, strata[cases$malaria==0 & cases$infected_denv_stfd==0] <- "pf_neg_&_denv_neg")

      cases <- within(cases, strata[cases$malaria==0 & cases$infected_denv_stfd==1] <- "pf_neg_&_denv_pos")
      table(cases$strata)  
#save dataset------------------------------------------------------------------------
      
save(cases,file="cases.rda")
load("cases.rda")
names(cases)[names(cases) == 'redcap_event'] <- 'redcap_event_name'

##merge with paired pedsql data (acute and convalescent)-----------------------------------------------------------------------
library("plyr")
  load("pedsql_pairs_acute.rda")

  names(pedsql_pairs_acute)[names(pedsql_pairs_acute) == 'redcap_event_name_acute_paired'] <- 'redcap_event_name'
  cases_pedsql <- join(cases, pedsql_pairs_acute,  by=c("person_id", "redcap_event_name"), match = "all" , type="full")
  cases_pedsql<-cases_pedsql[order(-(grepl('person_id|redcap|pedsql_', names(cases_pedsql)))+1L)]

  table(cases_pedsql$pedsql_parent_social_mean_acute_paired,cases_pedsql$pedsql_parent_social_mean_conv_paired)

  cases<-cases_pedsql
  cases<-cases[order(-(grepl('person_id|redcap|pedsql_', names(cases)))+1L)]
##how to merge  with unpaired pedsql data?? if we don't know when the convalescent visit is, and we are only looking at acute visits, then what is the unpaired data?-----------------------------------------------------------------------

# outcome hospitalized ----------------------------------------------------
  cases$outcome_hospitalized<-as.numeric(as.character(cases$outcome_hospitalized))
  cases <- within(cases, outcome_hospitalized[outcome_hospitalized==8] <-1 )
  table(cases$outcome_hospitalized)
# demographics ------------------------------------------------------------

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
    
# demography tables ------------------------------------------------------------------
    ## Create Table 1 stratified by denv/pf status.
    ## Tests are by oneway.test/t.test for continuous, chisq.test for categorical
    library("tableone")
    
    dem_factorVars <- c("City")
    dem_vars=c("City", "gender_all","aic_calculated_age","ses_sum")
    dem_tableOne <- CreateTableOne(vars = dem_vars, factorVars = dem_factorVars, strata = "strata", data = cases)
    #summary(dem_tableOne)
    print(dem_tableOne, exact = c("id_city", "gender_all"), nonnormal=c("aic_calculated_age"), quote = TRUE, includeNA=TRUE)
    
#   #mosquito tables ------------------------------------------------------------------
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

# pedsql paired data ------------------------------------------------------
    table(cases_pedsql$pedsql_parent_social_mean_conv_paired,cases_pedsql$pedsql_parent_social_mean_acute_paired)

    pedsql_paired_vars <- c("pedsql_child_school_mean_acute_paired", "pedsql_child_school_mean_conv_paired", "pedsql_child_social_mean_acute_paired", "pedsql_child_social_mean_conv_paired", "pedsql_parent_school_mean_acute_paired", "pedsql_parent_school_mean_conv_paired", "pedsql_parent_social_mean_acute_paired", "pedsql_parent_social_mean_conv_paired", "pedsql_child_physical_mean_acute_paired", "pedsql_child_physical_mean_conv_paired", "pedsql_parent_physical_mean_acute_paired", "pedsql_parent_physical_mean_conv_paired", "pedsql_child_emotional_mean_acute_paired", "pedsql_child_emotional_mean_conv_paired", "pedsql_parent_emotional_mean_acute_paired", "pedsql_parent_emotional_mean_conv_paired")
    pedsql_unpaired_tableOne <- CreateTableOne(vars = pedsql_paired_vars, strata = "strata", data = cases)
    summary(pedsql_unpaired_tableOne)
    #print table one (assume non normal distribution)
      print(pedsql_unpaired_tableOne, 
            exact = c(),
            nonnormal=c("pedsql_child_school_mean_acute_paired", "pedsql_child_school_mean_conv_paired", "pedsql_child_social_mean_acute_paired", "pedsql_child_social_mean_conv_paired", "pedsql_parent_school_mean_acute_paired", "pedsql_parent_school_mean_conv_paired", "pedsql_parent_social_mean_acute_paired", "pedsql_parent_social_mean_conv_paired", "pedsql_child_physical_mean_acute_paired", "pedsql_child_physical_mean_conv_paired", "pedsql_parent_physical_mean_acute_paired", "pedsql_parent_physical_mean_conv_paired", "pedsql_child_emotional_mean_acute_paired", "pedsql_child_emotional_mean_conv_paired", "pedsql_parent_emotional_mean_acute_paired", "pedsql_parent_emotional_mean_conv_paired")
            , quote = TRUE, includeNA=TRUE)
    #print table one (assume normal distribution)
      print(pedsql_unpaired_tableOne, 
            exact = c(),
            quote = TRUE, includeNA=TRUE)
      
      pedsql<-cases[, grepl("person_id|pedsql|strata|hospitalized", names(cases))]

      write.csv(as.data.frame(pedsql), "C:/Users/amykr/Box Sync/Amy Krystosik's Files/david coinfectin paper/data/pedsql.csv" )
      
# symptoms table ----------------------------------------------------------
      #fix the bleeding and body_ache variables to replace NA with zero.
      
      #bleeding
      cases <- within(cases, bleeding[cases$aic_symptom_bleeding_gums==0] <- 0)
      cases <- within(cases, bleeding[cases$aic_symptom_bleeding_gums==0] <- 0)
      cases <- within(cases, bleeding[cases$aic_symptom_bloody_nose==0] <- 0)
      cases <- within(cases, bleeding[cases$aic_symptom_bloody_urine==0] <- 0)
      cases <- within(cases, bleeding[cases$aic_symptom_bloody_stool==0] <- 0)
      cases <- within(cases, bleeding[cases$aic_symptom_bloody_vomit==0] <- 0)
      cases <- within(cases, bleeding[cases$aic_symptom_bruises==0] <- 0)

      cases <- within(cases, bleeding[cases$aic_symptom_bleeding_gums==1] <- 1)
      cases <- within(cases, bleeding[cases$aic_symptom_bleeding_gums==1] <- 1)
      cases <- within(cases, bleeding[cases$aic_symptom_bloody_nose==1] <- 1)
      cases <- within(cases, bleeding[cases$aic_symptom_bloody_urine==1] <- 1)
      cases <- within(cases, bleeding[cases$aic_symptom_bloody_stool==1] <- 1)
      cases <- within(cases, bleeding[cases$aic_symptom_bloody_vomit==1] <- 1)
      cases <- within(cases, bleeding[cases$aic_symptom_bruises==1] <- 1)
      table(cases$bleeding)  
      
      #nausea_vomitting
      cases <- within(cases, nausea_vomitting[cases$aic_symptom_nausea==0|cases$aic_symptom_vomiting==0| cases$aic_symptom_bloody_vomit==0] <- 0)
      cases <- within(cases, nausea_vomitting[cases$aic_symptom_nausea==1|cases$aic_symptom_vomiting==1| cases$aic_symptom_bloody_vomit==1] <- 1)
      table(cases$nausea_vomitting)
      
      #ims
      symptoms <- within(symptoms, aic_symptom_impaired_mental_status[symptoms$aic_symptom_fits==0|symptoms$aic_symptom_seizures==0] <- 0)
      symptoms <- within(symptoms, aic_symptom_impaired_mental_status[symptoms$aic_symptom_fits==1|symptoms$aic_symptom_seizures==1] <- 1)
      
      #bodyache
      cases <- within(cases, body_ache[cases$aic_symptom_general_body_ache==0] <- 0)
      cases <- within(cases, body_ache[cases$aic_symptom_muscle_pains==0] <- 0)
      cases <- within(cases, body_ache[cases$aic_symptom_bone_pains==0] <- 0)

      cases <- within(cases, body_ache[cases$aic_symptom_general_body_ache==1] <- 1)
      cases <- within(cases, body_ache[cases$aic_symptom_muscle_pains==1] <- 1)
      cases <- within(cases, body_ache[cases$aic_symptom_bone_pains==1] <- 1)
      table(cases$body_ache)      
  
      ses$heart_rate<-    as.numeric(as.character(cases$heart_rate))
    cases$temp<-    as.numeric(as.character(cases$temp))
    symptom_vars <- c("aic_symptom_abdominal_pain", "aic_symptom_chills", "aic_symptom_cough", "aic_symptom_vomiting", "aic_symptom_headache", "aic_symptom_loss_of_appetite", "aic_symptom_diarrhea", "aic_symptom_sick_feeling",  "aic_symptom_general_body_ache", "aic_symptom_joint_pains", "aic_symptom_dizziness", "aic_symptom_runny_nose", "aic_symptom_sore_throat", "aic_symptom_rash", "aic_symptom_shortness_of_breath", "aic_symptom_nausea", "aic_symptom_fever", "aic_symptom_funny_taste", "aic_symptom_red_eyes", "aic_symptom_earache", "aic_symptom_stiff_neck", "aic_symptom_pain_behind_eyes", "aic_symptom_itchiness", "aic_symptom_impaired_mental_status", "aic_symptom_eyes_sensitive_to_light", "bleeding", "body_ache", "temp", "heart_rate", "nausea_vomitting")
    symptom_factorVars <- c("aic_symptom_abdominal_pain", "aic_symptom_chills", "aic_symptom_cough", "aic_symptom_vomiting", "aic_symptom_headache", "aic_symptom_loss_of_appetite", "aic_symptom_diarrhea", "aic_symptom_sick_feeling",  "aic_symptom_general_body_ache", "aic_symptom_joint_pains", "aic_symptom_dizziness", "aic_symptom_runny_nose", "aic_symptom_sore_throat", "aic_symptom_rash", "aic_symptom_shortness_of_breath", "aic_symptom_nausea", "aic_symptom_fever", "aic_symptom_funny_taste", "aic_symptom_red_eyes", "aic_symptom_earache", "aic_symptom_stiff_neck", "aic_symptom_pain_behind_eyes", "aic_symptom_itchiness", "aic_symptom_impaired_mental_status", "aic_symptom_eyes_sensitive_to_light", "bleeding", "body_ache","nausea_vomitting")
    
    symptoms_tableOne <- CreateTableOne(vars = symptom_vars, factorVars = symptom_factorVars, strata = "strata", data = cases)
    #summary(symptoms_tableOne)
    print(symptoms_tableOne, 
          exact = c(
            "aic_symptom_abdominal_pain", "aic_symptom_chills", "aic_symptom_cough", "aic_symptom_vomiting", "aic_symptom_headache", "aic_symptom_loss_of_appetite", "aic_symptom_diarrhea", "aic_symptom_sick_feeling",  "aic_symptom_general_body_ache", "aic_symptom_joint_pains", "aic_symptom_dizziness", "aic_symptom_runny_nose", "aic_symptom_sore_throat", "aic_symptom_rash", "aic_symptom_shortness_of_breath", "aic_symptom_nausea", "aic_symptom_fever", "aic_symptom_funny_taste", "aic_symptom_red_eyes", "aic_symptom_earache", "aic_symptom_stiff_neck", "aic_symptom_pain_behind_eyes", "aic_symptom_itchiness", "aic_symptom_impaired_mental_status", "aic_symptom_eyes_sensitive_to_light", "bleeding", "body_ache", "temp", "heart_rate", "temp", "outcome_hospitalized","nausea_vomitting"
          ),
          nonnormal=c("heart_rate", "temp")
          , quote = TRUE, includeNA=TRUE)


# save and export data ----------------------------------------------------
    save(cases,file="david_denv_pf_cohort.rda")
#export to csv
    setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/david coinfectin paper/data")
    f <- "david_denv_pf_cohort.csv"
    write.csv(as.data.frame(cases), f )
# save and export strata and hospitalization data ----------------------------------------------------
    david_coinfection_strata_hospitalization<-cases[, grepl("person_id|redcap_event_name|strata|outcome_hospitalized|outcome", names(cases))]
    save(david_coinfection_strata_hospitalization,file="david_coinfection_strata_hospitalization.rda")
    
    
