# packages -----------------------------------------------------------------
#install.packages(c("REDCapR", "mlr"))
#install.packages(c("dummies"))
library(dplyr)
library(plyr)
library(redcapAPI)
library(REDCapR)
library(ggplot2)

# get data -----------------------------------------------------------------
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long")
Redcap.token <- readLines("Redcap.token.R01.txt") # Read API token from folder
REDcap.URL  <- 'https://redcap.stanford.edu/api/'
rcon <- redcapConnection(url=REDcap.URL, token=Redcap.token)

#export data from redcap to R (must be connected via cisco VPN)
R01_lab_results <- redcap_read(redcap_uri  = REDcap.URL, token = Redcap.token, batch_size = 300)$data
library(beepr)
beep(sound=4)

currentDate <- Sys.Date() 
FileName <- paste("R01_lab_results",currentDate,".rda",sep=" ") 
save(R01_lab_results,file=FileName)
load(FileName)
R01_lab_results <- within(R01_lab_results, prnt_80_denv[R01_lab_results$prnt_80_denv==""] <- NA)
table(R01_lab_results$prnt_80_denv, exclude = NULL)
R01_lab_results$prnt_denv<-NA
R01_lab_results <- within(R01_lab_results, prnt_denv[!is.na(R01_lab_results$prnt_80_denv)&R01_lab_results$prnt_80_denv!=" "] <- 0)
R01_lab_results <- within(R01_lab_results, prnt_denv[R01_lab_results$prnt_interpretation_flavi___1==1] <- 1)
table(R01_lab_results$prnt_denv)

table(R01_lab_results$prnt_denv, R01_lab_results$result_igg_denv_kenya, exclude = NULL)
table(R01_lab_results$prnt_denv, R01_lab_results$result_igg_denv_stfd, exclude = NULL)
#convert to factor for confusion matrix
  R01_lab_results$result_igg_denv_kenya[R01_lab_results$result_igg_denv_kenya == 1] <- "positive"
  R01_lab_results$result_igg_denv_kenya[R01_lab_results$result_igg_denv_kenya == 0] <- "negative"
  R01_lab_results$result_igg_denv_kenya[R01_lab_results$result_igg_denv_kenya == 98] <- NA
  R01_lab_results$result_igg_denv_kenya<-as.factor(R01_lab_results$result_igg_denv_kenya)
  table(R01_lab_results$result_igg_denv_kenya)

  R01_lab_results$result_igg_denv_stfd[R01_lab_results$result_igg_denv_stfd == 1] <- "positive"
  R01_lab_results$result_igg_denv_stfd[R01_lab_results$result_igg_denv_stfd == 0] <- "negative"
  R01_lab_results$result_igg_denv_stfd[R01_lab_results$result_igg_denv_stfd == 98] <- NA
  R01_lab_results$result_igg_denv_stfd<-as.factor(R01_lab_results$result_igg_denv_stfd)
  table(R01_lab_results$result_igg_denv_stfd)

  R01_lab_results$prnt_denv[R01_lab_results$prnt_denv == 1] <- "positive"
  R01_lab_results$prnt_denv[R01_lab_results$prnt_denv == 0] <- "negative"
  R01_lab_results$prnt_denv[R01_lab_results$prnt_denv == 98] <- NA
  R01_lab_results$prnt_denv<-as.factor(R01_lab_results$prnt_denv)
  table(R01_lab_results$prnt_denv)
  
#create vectors of true and predicted values
#chikv 9/99
truth_denv<-R01_lab_results$prnt_denv
predicted_denv_stfd<-R01_lab_results$result_igg_denv_stfd
predicted_denv_kenya<-R01_lab_results$result_igg_denv_kenya
#matrix
library(caret)
library(tibble)
confusionMatrix(predicted_denv_stfd,truth_denv,  positive="positive")
confusionMatrix(predicted_denv_kenya,truth_denv,  positive="positive")

#wnv
table(R01_lab_results$prnt_interpretation_flavi___2)

