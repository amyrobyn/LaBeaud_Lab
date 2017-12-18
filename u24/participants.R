#U24 participants
#install.packages(c("REDCapR", "mlr"))
#install.packages(c("dummies"))
library(dplyr)
library(plyr)
library(redcapAPI)
library(REDCapR)

setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long")
Redcap.token <- readLines("Redcap.token.R01.txt") # Read API token from folder
REDcap.URL  <- 'https://redcap.stanford.edu/api/'
rcon <- redcapConnection(url=REDcap.URL, token=Redcap.token)

#export data from redcap to R (must be connected via cisco VPN)
#R01_lab_results <- redcap_read(redcap_uri  = REDcap.URL, token = Redcap.token, batch_size = 300)$data
#R01_lab_results.backup<-R01_lab_results
#save(R01_lab_results.backup,file="R01_lab_results.backup.rda")
load("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long/R01_lab_results.clean.rda")

R01_lab_results<- R01_lab_results[which(!is.na(R01_lab_results$redcap_event_name))  , ]

R01_lab_results$id_cohort<-substr(R01_lab_results$person_id, 2, 2)
R01_lab_results$id_city<-substr(R01_lab_results$person_id, 1, 1)
# msambweni ---------------------------------------------------------------
  chikv_exposed_msambweni<- R01_lab_results[which((R01_lab_results$result_igg_chikv_stfd==1|R01_lab_results$infected_chikv_stfd==1) & (R01_lab_results$id_city=="M"|R01_lab_results$id_city=="G"|R01_lab_results$id_city=="L"))  ,c("person_id", "redcap_event_name", "result_igg_chikv_stfd", "id_city") ]
  n_distinct(chikv_exposed_msambweni$person_id)
  
  denv_exposed_msambweni<- R01_lab_results[which((R01_lab_results$result_igg_denv_stfd==1|R01_lab_results$infected_denv_stfd==1) & (R01_lab_results$id_city=="M"|R01_lab_results$id_city=="G"|R01_lab_results$id_city=="L"))  ,c("person_id", "redcap_event_name", "result_igg_denv_stfd", "id_city", "result_pcr_denv_kenya", "result_pcr_denv_stfd") ]
  n_distinct(denv_exposed_msambweni$person_id)
  
  coinfected_exposed_msambweni<- R01_lab_results[which((R01_lab_results$result_igg_denv_stfd==1|R01_lab_results$infected_denv_stfd==1) &(R01_lab_results$result_igg_chikv_stfd==1|R01_lab_results$infected_chikv_stfd==1)  & (R01_lab_results$id_city=="M"|R01_lab_results$id_city=="G"|R01_lab_results$id_city=="L") & (R01_lab_results$result_igg_chikv_stfd==1) )  ,c("person_id", "redcap_event_name", "result_igg_denv_stfd", "id_city", "result_pcr_denv_kenya", "result_pcr_denv_stfd") ]
  n_distinct(coinfected_exposed_msambweni$person_id)
  
  # n total
  n_distinct(denv_exposed_msambweni$person_id) +  n_distinct(chikv_exposed_msambweni$person_id) - n_distinct(coinfected_exposed_msambweni$person_id)

# ukunda ---------------------------------------------------------------
  chikv_exposed_ukunda<- R01_lab_results[which((R01_lab_results$result_igg_chikv_stfd==1|R01_lab_results$infected_chikv_stfd==1) & (R01_lab_results$id_city=="U"))  ,c("person_id", "redcap_event_name", "result_igg_chikv_stfd", "id_city") ]
  n_distinct(chikv_exposed_ukunda$person_id)
  
  denv_exposed_ukunda<- R01_lab_results[which((R01_lab_results$result_igg_denv_stfd==1|R01_lab_results$infected_denv_stfd==1) & (R01_lab_results$id_city=="U"))  ,c("person_id", "redcap_event_name", "result_igg_denv_stfd", "id_city", "result_pcr_denv_kenya", "result_pcr_denv_stfd") ]
  n_distinct(denv_exposed_ukunda$person_id)
  
  coinfected_exposed_ukunda<- R01_lab_results[which((R01_lab_results$result_igg_denv_stfd==1|R01_lab_results$infected_denv_stfd==1) &(R01_lab_results$result_igg_chikv_stfd==1|R01_lab_results$infected_chikv_stfd==1)  & (R01_lab_results$id_city=="U") & (R01_lab_results$result_igg_chikv_stfd==1) )  ,c("person_id", "redcap_event_name", "result_igg_denv_stfd", "id_city", "result_pcr_denv_kenya", "result_pcr_denv_stfd") ]
  n_distinct(coinfected_exposed_ukunda$person_id)
  
  # n total
  n_distinct(denv_exposed_ukunda$person_id) +  n_distinct(chikv_exposed_ukunda$person_id) - n_distinct(coinfected_exposed_ukunda$person_id)
  
