library(redcapAPI)
library(REDCapR)

setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long")
Redcap.token <- readLines("Redcap.token.R01.txt") # Read API token from folder
#Redcap.token <- "82F1C4081DEF007B8D4DE287426046E1"
REDcap.URL  <- 'https://redcap.stanford.edu/api/'
rcon <- redcapConnection(url=REDcap.URL, token=Redcap.token)

#export data from redcap to R (must be connected via cisco VPN)
R01_lab_results <- redcap_read(
  redcap_uri  = REDcap.URL,
  token       = Redcap.token,
  batch_size = 300
)$data


# Your REDCap issued token, I read mine from a text file
Redcap.token <- readLines("C:/Users/amykr/Box Sync/Amy Krystosik's Files/redcap.api.u24.txt") # Read API token from folder
# REDCAp site API-URL, will most likely be the REDCap site where you normally login + api
REDcap.URL  <- 'https://redcap.stanford.edu/api/'
rcon <- redcapConnection(url=REDcap.URL, token=Redcap.token)


#change date vars to posixct
date_vars<-c('date_tested_pcr_denv_stfd', 'date_tested_pcr_chikv_stfd', 'date_tested_igm_denv_kenya', 'date_tested_igm_chikv_kenya', 'date_tested_igm_denv_stfd', 'date_tested_igm_chikv_stfd', 'date_collected_rdt_denv_kenya', 'date_tested_rdt_denv_kenya', 'date_collected_rdt_malaria_kenya', 'date_tested_rdt_malaria_kenya', 'date_tested_other_kenya', 'date_collected_other_kenya', 'date_tested_other_stfd', 'date_collected_other_stfd', 'submissiondate', 'when_vaccinated_japenceph', 'when_hospitalized_2', 'when_hospitalized_3', 'when_hospitalized_4', 'when_hospitalized_5')
R01_lab_results[c('date_tested_pcr_denv_stfd', 'date_tested_pcr_chikv_stfd', 'date_tested_igm_denv_kenya', 'date_tested_igm_chikv_kenya', 'date_tested_igm_denv_stfd', 'date_tested_igm_chikv_stfd', 'date_collected_rdt_denv_kenya', 'date_tested_rdt_denv_kenya', 'date_collected_rdt_malaria_kenya', 'date_tested_rdt_malaria_kenya', 'date_tested_other_kenya', 'date_collected_other_kenya', 'date_tested_other_stfd', 'date_collected_other_stfd', 'submissiondate', 'when_vaccinated_japenceph', 'when_hospitalized_2', 'when_hospitalized_3', 'when_hospitalized_4', 'when_hospitalized_5')] <- lapply(R01_lab_results[c('date_tested_pcr_denv_stfd', 'date_tested_pcr_chikv_stfd', 'date_tested_igm_denv_kenya', 'date_tested_igm_chikv_kenya', 'date_tested_igm_denv_stfd', 'date_tested_igm_chikv_stfd', 'date_collected_rdt_denv_kenya', 'date_tested_rdt_denv_kenya', 'date_collected_rdt_malaria_kenya', 'date_tested_rdt_malaria_kenya', 'date_tested_other_kenya', 'date_collected_other_kenya', 'date_tested_other_stfd', 'date_collected_other_stfd', 'submissiondate', 'when_vaccinated_japenceph', 'when_hospitalized_2', 'when_hospitalized_3', 'when_hospitalized_4', 'when_hospitalized_5')], function(x) as.POSIXct(x) )
class(R01_lab_results$when_hospitalized_5)

##import data to redcap from R
#S3 method for class 'redcapApiConnection'

importRecords(rcon, R01_lab_results, overwriteBehavior = "normal", returnContent = c("count", "ids", "nothing"), 
              returnData = FALSE, logfile = "", proj = NULL,
              batch.size = -1)
