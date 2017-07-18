#install.packages("REDCapR")
library(REDCapR)
library(sensitivity)
library(caret)
library("tibble")

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

R01_lab_results$result_igg_denv_stfd
R01_lab_results$result_igg_denv_kenya


#create vectors of true and predicted values
R01_lab_results <- within(R01_lab_results, result_igg_chikv_stfd[R01_lab_results$result_igg_chikv_stfd==98] <- NA)
R01_lab_results <- within(R01_lab_results, result_igg_denv_stfd[R01_lab_results$result_igg_denv_stfd==98] <- NA)

R01_lab_results <- within(R01_lab_results, result_igg_chikv_stfd[R01_lab_results$result_igg_chikv_stfd==1] <- "positive")
R01_lab_results <- within(R01_lab_results, result_igg_denv_stfd[R01_lab_results$result_igg_denv_stfd==1] <- "positive")

R01_lab_results <- within(R01_lab_results, result_igg_chikv_stfd[R01_lab_results$result_igg_chikv_stfd==0] <- "negative")
R01_lab_results <- within(R01_lab_results, result_igg_denv_stfd[R01_lab_results$result_igg_denv_stfd==0] <- "negative")


R01_lab_results <- within(R01_lab_results, result_igg_chikv_kenya[R01_lab_results$result_igg_chikv_kenya==98] <- NA)
R01_lab_results <- within(R01_lab_results, result_igg_denv_kenya[R01_lab_results$result_igg_denv_kenya==98] <- NA)

R01_lab_results <- within(R01_lab_results, result_igg_chikv_kenya[R01_lab_results$result_igg_chikv_kenya==1] <- "positive")
R01_lab_results <- within(R01_lab_results, result_igg_denv_kenya[R01_lab_results$result_igg_denv_kenya==1] <- "positive")

R01_lab_results <- within(R01_lab_results, result_igg_chikv_kenya[R01_lab_results$result_igg_chikv_kenya==0] <- "negative")
R01_lab_results <- within(R01_lab_results, result_igg_denv_kenya[R01_lab_results$result_igg_denv_kenya==0] <- "negative")

#chikv
truth_chikv<-R01_lab_results$result_igg_chikv_stfd
predicted_chikv<-R01_lab_results$result_igg_chikv_kenya

table(R01_lab_results$result_igg_chikv_kenya, R01_lab_results$result_igg_chikv_stfd, exclude=NULL) #table of predicted (RDT) and true (microscopy) values 
table(predicted_chikv, truth_chikv,  exclude=NULL) #table of predicted (RDT) and true (microscopy) values 

confusionMatrix(predicted_chikv,truth_chikv,  positive="positive")

#denv
truth_denv<-R01_lab_results$result_igg_denv_stfd
predicted_denv<-R01_lab_results$result_igg_denv_kenya

table(R01_lab_results$result_igg_denv_kenya, R01_lab_results$result_igg_denv_stfd, exclude=NULL) #table of predicted (RDT) and true (microscopy) values 
table(predicted_denv, truth_denv,  exclude=NULL) #table of predicted (RDT) and true (microscopy) values 

confusionMatrix(predicted_denv,truth_denv,  positive="positive")
