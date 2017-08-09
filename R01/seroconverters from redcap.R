#make list of seroconverters and pcr positives
#get data from redcap
  library(redcapAPI)
  library(REDCapR)
  
  setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long")
  Redcap.token <- readLines("Redcap.token.R01.txt") # Read API token from folder
  REDcap.URL  <- 'https://redcap.stanford.edu/api/'
  rcon <- redcapConnection(url=REDcap.URL, token=Redcap.token)
  
  #export data from redcap to R (must be connected via cisco VPN)
  #R01_lab_results <- redcap_read(redcap_uri  = REDcap.URL, token = Redcap.token, batch_size = 300)$data
  load("R01_lab_results.backup.rda")
  R01_lab_results<-R01_lab_results.backup
  R01_lab_results$child_number
  
#reshape data to wide. 
  R01_lab_results_wide<-reshape(R01_lab_results, direction = "wide", idvar = "person_id", timevar = "redcap_event_name", sep = "_")

  nameVec <- names(R01_lab_results_wide)
  nameVec <- gsub("_patient_informatio_arm_1","_p",nameVec)
  nameVec <- gsub("_arm_1","",nameVec)
  nameVec <- gsub("_visit","",nameVec)
  names(R01_lab_results_wide) <- nameVec
  attach(R01_lab_results_wide)

#function to find positives
  isPos <- function(x) {
    (x > 0) & (!is.na(x)) * 1
  }
  
#denv_stfd igg seroconverters or pcr positives

R01_lab_results_wide$ab_denv_stfd_igg<- ifelse(!isPos(result_igg_denv_stfd_a) & isPos(result_igg_denv_stfd_b)| isPos(result_pcr_denv_kenya_a) | isPos(result_pcr_denv_stfd_a), 1, 0)

R01_lab_results_wide$bc_denv_stfd_igg<- ifelse(!isPos(result_igg_denv_stfd_b) & isPos(result_igg_denv_stfd_c)| isPos(result_pcr_denv_kenya_b) | isPos(result_pcr_denv_stfd_b), 1, 0)

R01_lab_results_wide$cd_denv_stfd_igg<- ifelse(!isPos(result_igg_denv_stfd_c) & isPos(result_igg_denv_stfd_d)| isPos(result_pcr_denv_kenya_c) | isPos(result_pcr_denv_stfd_c), 1, 0)

R01_lab_results_wide$de_denv_stfd_igg<- ifelse(!isPos(result_igg_denv_stfd_d) & isPos(result_igg_denv_stfd_e)| isPos(result_pcr_denv_kenya_d) | isPos(result_pcr_denv_stfd_d), 1, 0)

R01_lab_results_wide$ef_denv_stfd_igg<- ifelse(!isPos(result_igg_denv_stfd_e) & isPos(result_igg_denv_stfd_f)| isPos(result_pcr_denv_kenya_e) | isPos(result_pcr_denv_stfd_e), 1, 0)

R01_lab_results_wide$fg_denv_stfd_igg<- ifelse(!isPos(result_igg_denv_stfd_f) & isPos(result_igg_denv_stfd_g)| isPos(result_pcr_denv_kenya_f) | isPos(result_pcr_denv_stfd_f), 1, 0)

R01_lab_results_wide$gh_denv_stfd_igg<- ifelse(!isPos(result_igg_denv_stfd_g) & isPos(result_igg_denv_stfd_h)| isPos(result_pcr_denv_kenya_g) | isPos(result_pcr_denv_stfd_g), 1, 0)


#chikv_stfd igg seroconverters or pcr positives

R01_lab_results_wide$ab_chikv_stfd_igg<- ifelse(!isPos(result_igg_chikv_stfd_a) & isPos(result_igg_chikv_stfd_b)| isPos(result_pcr_chikv_kenya_a) | isPos(result_pcr_chikv_stfd_a), 1, 0)

R01_lab_results_wide$bc_chikv_stfd_igg<- ifelse(!isPos(result_igg_chikv_stfd_b) & isPos(result_igg_chikv_stfd_c)| isPos(result_pcr_chikv_kenya_b) | isPos(result_pcr_chikv_stfd_b), 1, 0)

R01_lab_results_wide$cd_chikv_stfd_igg<- ifelse(!isPos(result_igg_chikv_stfd_c) & isPos(result_igg_chikv_stfd_d)| isPos(result_pcr_chikv_kenya_c) | isPos(result_pcr_chikv_stfd_c), 1, 0)

R01_lab_results_wide$de_chikv_stfd_igg<- ifelse(!isPos(result_igg_chikv_stfd_d) & isPos(result_igg_chikv_stfd_e)| isPos(result_pcr_chikv_kenya_d) | isPos(result_pcr_chikv_stfd_d), 1, 0)

R01_lab_results_wide$ef_chikv_stfd_igg<- ifelse(!isPos(result_igg_chikv_stfd_e) & isPos(result_igg_chikv_stfd_f)| isPos(result_pcr_chikv_kenya_e) | isPos(result_pcr_chikv_stfd_e), 1, 0)

R01_lab_results_wide$fg_chikv_stfd_igg<- ifelse(!isPos(result_igg_chikv_stfd_f) & isPos(result_igg_chikv_stfd_g)| isPos(result_pcr_chikv_kenya_f) | isPos(result_pcr_chikv_stfd_f), 1, 0)

R01_lab_results_wide$gh_chikv_stfd_igg<- ifelse(!isPos(result_igg_chikv_stfd_g) & isPos(result_igg_chikv_stfd_h)| isPos(result_pcr_chikv_kenya_g) | isPos(result_pcr_chikv_stfd_g), 1, 0)

#chikv_kenya igg seroconverters or pcr positives

R01_lab_results_wide$ab_chikv_kenya_igg<- ifelse(!isPos(result_igg_chikv_kenya_a) & isPos(result_igg_chikv_kenya_b)| isPos(result_pcr_chikv_kenya_a) | isPos(result_pcr_chikv_kenya_a), 1, 0)

R01_lab_results_wide$bc_chikv_kenya_igg<- ifelse(!isPos(result_igg_chikv_kenya_b) & isPos(result_igg_chikv_kenya_c)| isPos(result_pcr_chikv_kenya_b) | isPos(result_pcr_chikv_kenya_b), 1, 0)

R01_lab_results_wide$cd_chikv_kenya_igg<- ifelse(!isPos(result_igg_chikv_kenya_c) & isPos(result_igg_chikv_kenya_d)| isPos(result_pcr_chikv_kenya_c) | isPos(result_pcr_chikv_kenya_c), 1, 0)

R01_lab_results_wide$de_chikv_kenya_igg<- ifelse(!isPos(result_igg_chikv_kenya_d) & isPos(result_igg_chikv_kenya_e)| isPos(result_pcr_chikv_kenya_d) | isPos(result_pcr_chikv_kenya_d), 1, 0)

R01_lab_results_wide$ef_chikv_kenya_igg<- ifelse(!isPos(result_igg_chikv_kenya_e) & isPos(result_igg_chikv_kenya_f)| isPos(result_pcr_chikv_kenya_e) | isPos(result_pcr_chikv_kenya_e), 1, 0)

R01_lab_results_wide$fg_chikv_kenya_igg<- ifelse(!isPos(result_igg_chikv_kenya_f) & isPos(result_igg_chikv_kenya_g)| isPos(result_pcr_chikv_kenya_f) | isPos(result_pcr_chikv_kenya_f), 1, 0)

R01_lab_results_wide$gh_chikv_kenya_igg<- ifelse(!isPos(result_igg_chikv_kenya_g) & isPos(result_igg_chikv_kenya_h)| isPos(result_pcr_chikv_kenya_g) | isPos(result_pcr_chikv_kenya_g), 1, 0)

#denv_kenya igg seroconverters or pcr positives

R01_lab_results_wide$ab_denv_kenya_igg<- ifelse(!isPos(result_igg_denv_kenya_a) & isPos(result_igg_denv_kenya_b)| isPos(result_pcr_denv_kenya_a) | isPos(result_pcr_denv_kenya_a), 1, 0)

R01_lab_results_wide$bc_denv_kenya_igg<- ifelse(!isPos(result_igg_denv_kenya_b) & isPos(result_igg_denv_kenya_c)| isPos(result_pcr_denv_kenya_b) | isPos(result_pcr_denv_kenya_b), 1, 0)

R01_lab_results_wide$cd_denv_kenya_igg<- ifelse(!isPos(result_igg_denv_kenya_c) & isPos(result_igg_denv_kenya_d)| isPos(result_pcr_denv_kenya_c) | isPos(result_pcr_denv_kenya_c), 1, 0)

R01_lab_results_wide$de_denv_kenya_igg<- ifelse(!isPos(result_igg_denv_kenya_d) & isPos(result_igg_denv_kenya_e)| isPos(result_pcr_denv_kenya_d) | isPos(result_pcr_denv_kenya_d), 1, 0)

R01_lab_results_wide$ef_denv_kenya_igg<- ifelse(!isPos(result_igg_denv_kenya_e) & isPos(result_igg_denv_kenya_f)| isPos(result_pcr_denv_kenya_e) | isPos(result_pcr_denv_kenya_e), 1, 0)

R01_lab_results_wide$fg_denv_kenya_igg<- ifelse(!isPos(result_igg_denv_kenya_f) & isPos(result_igg_denv_kenya_g)| isPos(result_pcr_denv_kenya_f) | isPos(result_pcr_denv_kenya_f), 1, 0)

R01_lab_results_wide$gh_denv_kenya_igg<- ifelse(!isPos(result_igg_denv_kenya_g) & isPos(result_igg_denv_kenya_h)| isPos(result_pcr_denv_kenya_g) | isPos(result_pcr_denv_kenya_g), 1, 0)

#save dataframe.
saveRDS(R01_lab_results_wide, file="seroc.rds")
R01_lab_results_wide_seroc <- readRDS("seroc.rds")
