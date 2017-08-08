#install.packages(c("REDCapR", "RCurl", "dplyr", 'redcapAPI', 'rJava', 'WriteXLS', 'readxl', 'xlsx'))

library(REDCapR)
library(RCurl)
library(dplyr)
library(redcapAPI)
library(rJava) 
library(WriteXLS) # Writing Excel files
library(readxl) # Excel file reading
library(xlsx) # Writing Excel files

setwd("/Users/melisashah/Documents/Malaria Stanford/Rdata")
Redcap.token <- readLines("Redcap.token.R01.txt") # Read API token from folder
REDcap.URL <- 'https://redcap.stanford.edu/api/'
rcon <- redcapConnection(url=REDcap.URL, token=Redcap.token)

#export data from redcap to R (must be connected via cisco VPN)
R01_lab_results <- redcap_read(redcap_uri  = REDcap.URL, token= Redcap.token, batch_size = 300)$data

#creating the cohort and village and visit variables for each visit. 
R01_lab_results$id_cohort<-substr(R01_lab_results$person_id, 2, 2)
R01_lab_results$id_city<-substr(R01_lab_results$person_id, 1, 1)

# subset of the variables
aic<-R01_lab_results[which(R01_lab_results$id_cohort=="F"), c("person_id", "id_cohort", "id_city", "date_collected_rdt_malaria_kenya", "antigen_used_rdt_malaria_kenya","result_rdt_malaria_kenya","study_id_aic"   ,"visit_type", "village_aic", "aic_calculated_age", "gender_aic", "occupation_aic", "mom_highest_level_education_aic", "roof_type", "latrine_type", "floor_type", "drinking_water_source", "light_source", "windows", "number_windows", "rooms_in_house", "number_siblings_aic", "telephone","radio", "television", "bicycle", "motor_vehicle", "domestic_worker", "fever_contact", "mosquito_bites_aic", "mosquito_coil_aic", "mosquito_net_aic", "child_travel", "ever_hospitalized_aic", "term", "breast_fed", "currently_taking_medications", "current_medications", "currently_sick", "date_symptom_onset", "symptoms_aic", "temp", "child_height_aic", "child_weight_aic", "head_circumference", "heart_rate", "resp_rate", "bp_available", "systolic_pressure", "disastolic_pressure", "pulse_ox","head_neck_exam","clinician_notes_headneck", "nodes", "oth_nodes", "clinician_notes_nodes", "joints", "joint_location", "clinician_notes_joints", "skin", "oth_skin", "mal_test", "oth_mal_test", "malaria_results", "rdt_results", "labs_ordered", "oth_labs_ordered", "wbc", "neutrophils", "lymphocytes", "monocytes", "eosinophils", "hb_hemogram", "mcv", "hb_result", "hiv_result", "ua_result", "stool_result", "primary_diagnosis", "oth_primary_diagnosis", "meds_prescribed", "outcome", "outcome_hospitalized", "outcome_where_hospitalized", "dem_village", "name_tech_microscopy_malaria_kenya", "sample_microscopy_malaria_kenya", "aliquot_id_microscopy_malaria_kenya", "result_microscopy_malaria_kenya", "microscopy_malaria_po_kenya___1", "microscopy_malaria_pf_kenya___1", "microscopy_malaria_pm_kenya___1", "microscopy_malaria_pv_kenya___1", "microscopy_malaria_ni_kenya___1","antigen_used_microscopy_malaria_kenya___1","antigen_used_microscopy_malaria_kenya___2","antigen_used_microscopy_malaria_kenya___3","antigen_used_microscopy_malaria_kenya___4" , "antigen_used_microscopy_malaria_kenya___5", "antigen_used_microscopy_malaria_kenya___6", "antigen_used_microscopy_malaria_kenya___98", "antigen_used_microscopy_malaria_kenya___99", "antigen_used_microscopy_malaria_kenya___100", "quant_microscpy_pf_kenya", "quant_microscpy_pf_kenya", "gametocytes_microscpy_pf_kenya", "density_microscpy_po_kenya", "quant_microscpy_po_kenya", "gametocytes_microscpy_po_kenya", "density_microscpy_pm_kenya", "quant_microscpy_pm_kenya", "gametocytes_microscpy_pm_kenya", "density_microscpy_pv_kenya", "quant_microscpy_pv_kenya", "gametocytes_microscpy_pv_kenya", "density_microscpy_ni_kenya","quant_microscpy_ni_kenya", "gametocytes_microscpy_ni_kenya", "malaria_treatment_kenya___1", "malaria_treatment_kenya___2", "malaria_treatment_kenya___3", "malaria_treatment_kenya___4", "malaria_treatment_kenya___5", "malaria_treatment_kenya___98", "malaria_treatment_other_kenya", "notes_microscopy_malaria_kenya", "microscopy_malaria_kenya_complete")]
save(aic, file="aic.rda")


village_table<-table(R01_lab_results$village_aic, R01_lab_results$result_microscopy_malaria_kenya )
villages<-as.data.frame(village_table)