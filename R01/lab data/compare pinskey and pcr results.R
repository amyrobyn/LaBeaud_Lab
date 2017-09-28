library(sensitivity)
library(caret)
library(tibble)

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
#save(R01_lab_results,file="R01_lab_results.backup.rda")
load("aic_dummy_symptoms.clean.rda") #load the data from your local directory (this will save you time later rather than always downolading from redcap.)
R01_lab_results<-aic_dummy_symptoms

#convert to factor for sensitivity packages
#UFI CHIKV
    R01_lab_results$chikv_result_ufi_pos<-NA
    R01_lab_results$chikv_result_ufi_pos[R01_lab_results$chikv_result_ufi == 1 & R01_lab_results$ufiresult_ufi___14!=1 ] <- "positive"
    R01_lab_results$chikv_result_ufi_pos[R01_lab_results$chikv_result_ufi == 0 & R01_lab_results$ufiresult_ufi___14!=1 ] <- "negative"
    R01_lab_results$chikv_result_ufi_pos<-as.factor(R01_lab_results$chikv_result_ufi_pos)
#UFI DENV
    R01_lab_results$denv_result_ufi[R01_lab_results$denv_result_ufi == 1] <- "positive"
    R01_lab_results$denv_result_ufi[R01_lab_results$denv_result_ufi == 0] <- "negative"
    R01_lab_results$denv_result_ufi<-as.factor(R01_lab_results$denv_result_ufi)
#PCR DENV    
    R01_lab_results$pcr_denv<-NA
    R01_lab_results <- within(R01_lab_results, pcr_denv[R01_lab_results$result_pcr_denv_kenya==0|R01_lab_results$result_pcr_denv_stfd==0] <- 0)
    R01_lab_results <- within(R01_lab_results, pcr_denv[R01_lab_results$result_pcr_denv_kenya==1|R01_lab_results$result_pcr_denv_stfd==1] <- 1)

    R01_lab_results$pcr_denv[R01_lab_results$pcr_denv == 1] <- "positive"
    R01_lab_results$pcr_denv[R01_lab_results$pcr_denv == 0] <- "negative"
    R01_lab_results$pcr_denv<-as.factor(R01_lab_results$pcr_denv)
#PCR CHIKV
    R01_lab_results$pcr_chikv<-NA
    R01_lab_results <- within(R01_lab_results, pcr_chikv[R01_lab_results$result_pcr_chikv_kenya==0|R01_lab_results$result_pcr_chikv_stfd==0] <- 0)
    R01_lab_results <- within(R01_lab_results, pcr_chikv[R01_lab_results$result_pcr_chikv_kenya==1|R01_lab_results$result_pcr_chikv_stfd==1] <- 1)
    
    R01_lab_results$pcr_chikv[R01_lab_results$pcr_chikv == 1] <- "positive"
    R01_lab_results$pcr_chikv[R01_lab_results$pcr_chikv == 0] <- "negative"
    R01_lab_results$pcr_chikv<-as.factor(R01_lab_results$pcr_chikv)
    
#create vectors of true and predicted values
  #chikv 9/99
    truth_chikv<-R01_lab_results$chikv_result_ufi_pos
    predicted_chikv<-R01_lab_results$pcr_chikv
  #denv  2/(36+130+  51)
    truth_denv<-R01_lab_results$denv_result_ufi
    predicted_denv<-R01_lab_results$pcr_denv
#matrix
  confusionMatrix(predicted_chikv,truth_chikv,  positive="positive")
  
  confusionMatrix(predicted_denv,truth_denv,  positive="positive")
  