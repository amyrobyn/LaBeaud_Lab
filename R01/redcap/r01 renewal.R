#install.packages(c("REDCapR", "epiR", "epitools", "epicalc"))
library(redcapAPI)
library(REDCapR)
library("epiR")
library("epitools")
library("epicalc")
library(dplyr)

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



#The 1-2% of fevers due to CHIKV and DENV- is that per year or is that total? 
#Also, we need to figure out how much of our acute DENV was symptomatic vs. mildly/asymptomatic, etc.

glimpse(R01_lab_results)
attach(R01_lab_results)

epitab(gender, result_igg_chikv_stfd)
epitable(gender, result_igg_chikv_stfd)

epitab(gender, result_igg_denv_stfd)
epitable(gender, result_igg_denv_stfd)


epitab(gender, result_pcr_denv_stfd)
epitable(gender, result_pcr_denv_stfd)

#survival
library(survival)
survival <- R01_lab_results[ , grepl( "result|person_id|redcap_event" , names( R01_lab_results ) ) ]
attach(survival)
survival$time <-NA
survival <- within(survival, time[redcap_event_name=="visit_a_arm_1"] <- 1)
survival <- within(survival, time[redcap_event_name=="visit_b_arm_1"] <- 2)
survival <- within(survival, time[redcap_event_name=="visit_c_arm_1"] <- 3)
survival <- within(survival, time[redcap_event_name=="visit_d_arm_1"] <- 4)
survival <- within(survival, time[redcap_event_name=="visit_e_arm_1"] <- 5)

table(survival$time, survival$redcap_event_name)
table(survival$result_igg_denv_stfd)

plot(survfit(Surv(time, result_igg_denv_stfd) ~ 1, data=survival), 
     conf.int=FALSE, mark.time=FALSE) 

plot(survfit(Surv(time, result_igg_chikv_stfd) ~ 1, data=survival), 
     conf.int=FALSE, mark.time=FALSE) 

survfit<-survfit(Surv(time, result_igg_chikv_stfd) ~ 1, data=survival)
str(survfit)
survfit2<-survfit(Surv(time, result_igg_denv_stfd) ~ 1, data=survival)
str(survfit2)

survfit3<-survfit(Surv(time, result_igg_chikv_kenya) ~ 1, data=survival)
str(survfit3)
survfit4<-survfit(Surv(time, result_igg_denv_kenya) ~ 1, data=survival)
str(survfit4)
