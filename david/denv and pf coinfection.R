# import data -------------------------------------------------------------
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/david coinfection paper/data")
load("R01_lab_results.david.coinfection.dataset.rda")#load data that has been cleaned previously#final data set made on 11/16/18 for david conifection paper.
# format data -------------------------------------------------------------
AIC<- R01_lab_results[which(R01_lab_results$redcap_event_name!="patient_informatio_arm_1" & R01_lab_results$redcap_event_name!="visit_a2_arm_1"&R01_lab_results$redcap_event_name!="visit_b2_arm_1"&R01_lab_results$redcap_event_name!="visit_c2_arm_1"&R01_lab_results$redcap_event_name!="visit_d2_arm_1"&R01_lab_results$redcap_event_name!="visit_u24_arm_1"),]
AIC<-AIC[which(AIC$Cohort=="AIC"), ]
patients_reviewed<-sum(n_distinct(AIC$person_id, na.rm = FALSE))
AIC$id_cohort<-substr(AIC$person_id, 2, 2)
AIC$id_city<-substr(AIC$person_id, 1, 1)
AIC$person_id<-as.character(AIC$person_id)
AIC$redcap_event_name<-as.character(AIC$redcap_event_name)
AIC$int_date <-lubridate::ymd(AIC$interview_date_aic)
# define acute febrile illness ------------------------------------------------------------------------
    source("C:/Users/amykr/Documents/GitHub/lebeaud_lab/david/define acute febrile illness.r")
    table(AIC$acute)
#denv case definition------------------------------------------------------------------------
  source("C:/Users/amykr/Documents/GitHub/lebeaud_lab/david/strata definitions.R")
  table(AIC$strata_all,AIC$acute)#this code keeps only acute. i don't remember why we did this.
#save dataset------------------------------------------------------------------------
  save(AIC,file="AIC.rda")
##merge with paired(acute and convalescent) pedsql data -----------------------------------------------------------------------
  source("C:/Users/amykr/Documents/GitHub/lebeaud_lab/david/calculate pedsql scores and pair.r")
  load("AIC.rda")
  names(pedsql_pairs_acute)[names(pedsql_pairs_acute) == 'redcap_event_name_acute_paired'] <- 'redcap_event_name'
  names(AIC)[names(AIC) == 'redcap_event'] <- 'redcap_event_name'
  AIC <- join(AIC, pedsql_pairs_acute,  by=c("person_id", "redcap_event_name"), match = "first" , type="full")
  AIC<-AIC[order(-(grepl('person_id|redcap|pedsql_', names(AIC)))+1L)]
##merge with unpaired pedsql data -----------------------------------------------------------------------
  load("pedsql_unpaired.rda")
  names(pedsql_unpaired)[names(pedsql_unpaired) == 'redcap_event'] <- 'redcap_event_name'
  AIC <- join(AIC, pedsql_unpaired,  by=c("person_id", "redcap_event_name"), match = "first" , type="left")
  
  # outcome hospitalized ----------------------------------------------------
  AIC$outcome_hospitalized<-as.numeric(as.character(AIC$outcome_hospitalized))
  AIC <- within(AIC, outcome_hospitalized[outcome_hospitalized==8] <-1 )
  table(AIC$outcome_hospitalized)
# demographics, ses, and mosquito indices ------------------------------------------------------------
source("C:/Users/amykr/Documents/GitHub/lebeaud_lab/david/demographics, ses, and mosquito indices.r")
# physcial exam -----------------------------------------------------------
source("C:/Users/amykr/Documents/GitHub/lebeaud_lab/david/acute visit outcomes- pe, pedsql.R")
# symptoms table ----------------------------------------------------------
  source("C:/Users/amykr/Documents/GitHub/lebeaud_lab/david/symptoms.R")
# keep only ab visits -----------------------------------------------------
  sum(n_distinct(AIC$person_id, na.rm = FALSE)) #2276
  n<-sum(n_distinct(R01_lab_results$person_id, na.rm = FALSE)) #10,899 patients reviewed
  AIC<-AIC[which((AIC$acute==1&AIC$redcap_event_name=="visit_a_arm_1")|(AIC$acute!=1&AIC$redcap_event_name=="visit_b_arm_1")), ]
  aic_n<-sum(n_distinct(AIC$person_id, na.rm = FALSE)) #2,205 patients included in study (aic, west)
  table(AIC$redcap_event_name)
  afi<-  sum(AIC$acute==1, na.rm = TRUE)#2203 afi's

  AIC<-AIC[which(AIC$acute==1), ]#is this right? we only want the acute visit in here and only the pedsql outcome at conv?
  
# save and export data ----------------------------------------------------
    save(AIC,file="david_denv_malaria_cohort.rda")
# save and export strata and hospitalization data ----------------------------------------------------
    david_coinfection_strata_hospitalization<-AIC[, grepl("person_id|redcap_event_name|strata|outcome_hospitalized|outcome|gender_all|ses_sum|mom_highest_level_education", names(AIC))]
    save(david_coinfection_strata_hospitalization,file="C:/Users/amykr/Box Sync/Amy Krystosik's Files/david coinfection paper/data/david_coinfection_strata_hospitalization.rda")
    table(AIC$strata_all)
# pedsql tables and graphs -------------------------------------------------------
    list<-grep("mean_acute_paired|mean_conv_paired|change|mean_z", names(AIC), value = TRUE)
    pedsqlvar_aic<-pedsqlvar_aic[pedsqlvar_aic != "home_lifestyle_changes"]
    pedsql_paired_tableOne <- CreateTableOne(vars = pedsqlvar_aic, strata = "strata_all", data = AIC)
    pedsql_tableOne_unpaired_acute <- CreateTableOne(vars = pedsqlvar, strata = "strata_all", data = pedsql_all_coinfection_acute,includeNA=T)
    df<-AIC
    source("C:/Users/amykr/Documents/GitHub/lebeaud_lab/david/histograms.R")
    
# demographic tables and graphs -------------------------------------------------------
    dem_vars=c("City", "gender_all","aic_calculated_age","ses_sum","mosquito_bites_aic", "mosquito_coil_aic", "outdoor_activity_aic", "mosquito_net_aic","mom_highest_level_education_aic")
    dem_factorVars <- c("City","mosquito_bites_aic", "mosquito_coil_aic", "outdoor_activity_aic", "mosquito_net_aic") 
    dem_tableOne_site <- CreateTableOne(vars = dem_vars, factorVars = dem_factorVars, strata = "City", data = AIC)
    dem_tableOne_site.csv <-print(dem_tableOne_site, nonnormal=c("aic_calculated_age"), exact = c("id_city", "gender_all",    "mosquito_bites_aic", "mosquito_coil_aic", "outdoor_activity_aic", "mosquito_net_aic"),  quote = F, noSpaces = TRUE, includeNA=TRUE,, printToggle = FALSE)
    write.csv(dem_tableOne_site.csv, file = "dem_tableOne_site.csv")
    
    dem_tableOne_total <- CreateTableOne(vars = dem_vars, factorVars = dem_factorVars,  data = AIC)
    dem_tableOne_total.csv <-print(dem_tableOne_total, nonnormal=c("aic_calculated_age"), exact = c("id_city", "gender_all",    "mosquito_bites_aic", "mosquito_coil_aic", "outdoor_activity_aic", "mosquito_net_aic"),  quote = F, noSpaces = TRUE, includeNA=TRUE,, printToggle = FALSE)
    write.csv(dem_tableOne_total.csv, file = "dem_tableOne_total.csv")
    
    dem_tableOne_strata_all <- CreateTableOne(vars = dem_vars, factorVars = dem_factorVars, strata = "strata_all", data = AIC)
    dem_tableOne_strata_all.csv <-print(dem_tableOne_strata_all, nonnormal=c("aic_calculated_age"), exact = c("id_city", "gender_all",    "mosquito_bites_aic", "mosquito_coil_aic", "outdoor_activity_aic", "mosquito_net_aic"),  quote = F, noSpaces = TRUE, includeNA=TRUE,, printToggle = FALSE)
    write.csv(dem_tableOne_strata_all.csv, file = "dem_tableOne_strata_all.csv")
    
    AIC$pedsql_parent_emotional_mean_acute_paired
    AIC<-AIC[order(-(grepl('pedsql_', names(AIC))))]
    AIC<-AIC[order(-(grepl('person_id|redcap', names(AIC))))]
    AIC[ which(AIC$pairs_ac_acute_paired==1) , c("pairs_ab_acute_paired","person_id","redcap_event_name","pedsql_parent_emotional_mean_acute_paired","pedsql_parent_emotional_mean_conv_paired")]

table(AIC$pairs_ab_acute_paired==1, AIC$strata_all)
table(!is.na(AIC$pedsql_parent_total_mean_acute_paired), AIC$strata_all)
table(!is.na(AIC$pedsql_parent_total_mean_conv_paired), AIC$strata_all)

table(!is.na(AIC$pedsql_child_total_mean_acute_paired), AIC$strata_all)
table(!is.na(AIC$pedsql_child_total_mean_conv_paired), AIC$strata_all)

AIC_complete_c<-AIC[ which(!is.na(AIC$pedsql_parent_total_mean_acute_paired)&!is.na(AIC$pedsql_child_total_mean_acute_paired)&!is.na(AIC$pedsql_parent_total_mean_conv_paired)&!is.na(AIC$pedsql_child_total_mean_conv_paired)) , ]