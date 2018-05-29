# get data -----------------------------------------------------------------

library(REDCapR)
Redcap.token <- readLines("Redcap.token.R01.txt") # Read API token from folder
REDcap.URL  <- 'https://redcap.stanford.edu/api/'
#R01_lab_results <- redcap_read(redcap_uri  = REDcap.URL, token = Redcap.token, batch_size = 300)$data#export data from redcap to R (must be connected via cisco VPN)


setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long")
currentDate <- Sys.Date() 
FileName <- paste("R01_lab_results",currentDate,".rda",sep=" ") 
#save(R01_lab_results,file=FileName)
load("R01_lab_results 2018-05-25 .rda")
load("aic_symptoms.rda")
R01_lab_results <- merge(aic_symptoms, R01_lab_results, by=c("person_id", "redcap_event_name"), all = TRUE)  #merge symptoms to redcap data
#parse the id 
R01_lab_results$id_cohort<-substr(R01_lab_results$person_id, 2, 2)
R01_lab_results$id_city<-substr(R01_lab_results$person_id, 1, 1)

n_distinct(R01_lab_results$person_id)
table(R01_lab_results$id_cohort, R01_lab_results$redcap_event_name)

R01_lab_results$id_visit<-as.integer(factor(R01_lab_results$redcap_event_name))
R01_lab_results$id_visit<-R01_lab_results$id_visit-1

#create acute variable
R01_lab_results$acute<-NA
R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$visit_type==1] <- 1)
R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$visit_type==2] <- 1)
R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$visit_type==3] <- 0)
R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$visit_type==4] <- 1)
R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$visit_type==5] <- 0)
#if they ask an initial survey question (see odk aic inital and follow up forms), it is an initial visit.
R01_lab_results <- within(R01_lab_results, acute[!is.na(R01_lab_results$kid_highest_level_education_aic)] <- 1)

R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$occupation_aic!=""] <- 1)
R01_lab_results <- within(R01_lab_results, acute[!is.na(R01_lab_results$occupation_aic)] <- 1)

R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$mom_highest_level_education_aic!=""] <- 1)
R01_lab_results <- within(R01_lab_results, acute[!is.na(R01_lab_results$mom_highest_level_education_aic)] <- 1)
R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$roof_type!=""] <- 1)
R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$pregnant!=""] <- 1)
#if it is visit a,call it acute


R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$redcap_event=="visit_a_arm_1" & id_cohort=="F"] <- 1)#nienke skipped
table(R01_lab_results$acute,exclude = NULL)

#if they have fever, call it acute
table(R01_lab_results$aic_symptom_fever.y)
R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$aic_symptom_fever.y==1] <- 1)#nienke skipped
R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$temp>=38] <- 1)
#otherwise, it is not acute
R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$acute!=1 & !is.na(R01_lab_results$gender_aic) ] <- 0)
table(R01_lab_results$acute)



# make pairs --------------------------------------------------------------
library(lubridate)
R01_lab_results$int_date <-ymd(R01_lab_results$interview_date_aic)
class(R01_lab_results$int_date)
r01_wide<-reshape(R01_lab_results, direction = "wide", idvar = "person_id", timevar = "redcap_event_name", sep = "_")

r01_wide$elapsed.time_patient_informatio_arm_1 <- NA
r01_wide$elapsed.time_visit_a_arm_1 <- NA
r01_wide$elapsed.time_visit_a_arm_1 <- as.numeric(r01_wide$int_date_visit_b_arm_1 - r01_wide$int_date_visit_a_arm_1)
r01_wide$elapsed.time_visit_b_arm_1 <- as.numeric(r01_wide$int_date_visit_c_arm_1 - r01_wide$int_date_visit_b_arm_1)
r01_wide$elapsed.time_visit_c_arm_1 <- as.numeric(r01_wide$int_date_visit_d_arm_1 - r01_wide$int_date_visit_c_arm_1)
r01_wide$elapsed.time_visit_d_arm_1 <- as.numeric(r01_wide$int_date_visit_e_arm_1 -   r01_wide$int_date_visit_d_arm_1)
r01_wide$elapsed.time_visit_e_arm_1 <- as.numeric(r01_wide$int_date_visit_f_arm_1 - r01_wide$int_date_visit_e_arm_1)
r01_wide$elapsed.time_visit_f_arm_1 <- as.numeric(r01_wide$int_date_visit_g_arm_1 -  r01_wide$int_date_visit_f_arm_1)
r01_wide$elapsed.time_visit_g_arm_1 <- as.numeric(r01_wide$int_date_visit_h_arm_1 -  r01_wide$int_date_visit_g_arm_1)
r01_wide$elapsed.time_visit_h_arm_1 <- NA

r01_wide<-r01_wide[order(-(grepl('elapsed.time|int_date', names(r01_wide)))+1L)]

hist(r01_wide$elapsed.time_visit_a_arm_1, breaks = 100)
hist(r01_wide$elapsed.time_visit_b_arm_1, breaks = 100)
hist(r01_wide$elapsed.time_visit_c_arm_1, breaks = 100)
hist(r01_wide$elapsed.time_visit_d_arm_1, breaks = 100)
hist(r01_wide$elapsed.time_visit_e_arm_1, breaks = 100)
hist(r01_wide$elapsed.time_visit_f_arm_1, breaks = 100)
hist(r01_wide$elapsed.time_visit_g_arm_1, breaks = 100)


table(r01_wide$pairs_ab)
r01_wide$pairs_ab<-ifelse(r01_wide$elapsed.time_visit_a_arm_1>=14 & r01_wide$elapsed.time_visit_a_arm_1<=84 & r01_wide$acute_visit_a_arm_1 ==1  & r01_wide$acute_visit_b_arm_1==0, 1, 0)    

table(r01_wide$person_id[r01_wide$pairs_ab==1],r01_wide$pairs_ab[r01_wide$pairs_ab==1])
summary(r01_wide$elapsed.time_visit_b_arm_1)
r01_wide[r01_wide$elapsed.time_visit_b_arm_1<1 , c("person_id","acute_visit_a_arm_1","acute_visit_b_arm_1","elapsed.time_visit_b_arm_1")]
negative<-r01_wide[which(r01_wide$elapsed.time_visit_b_arm_1<1),]
write.csv(negative,"neg.csv")

table(r01_wide$person_id[r01_wide$pairs_ab==1],r01_wide$pairs_ab[r01_wide$pairs_ab==1])
r01_wide$pairs_bc<-ifelse(r01_wide$elapsed.time_visit_b_arm_1>=14 & r01_wide$elapsed.time_visit_b_arm_1<=84 & r01_wide$acute_visit_b_arm_1==1 & r01_wide$acute_visit_c_arm_1==0, 1, 0)    
r01_wide$pairs_cd<-ifelse(r01_wide$elapsed.time_visit_c_arm_1>=14 & r01_wide$elapsed.time_visit_c_arm_1<=84 & r01_wide$acute_visit_c_arm_1==1 & r01_wide$acute_visit_d_arm_1==0, 1, 0)    
r01_wide$pairs_de<-ifelse(r01_wide$elapsed.time_visit_d_arm_1>=14 & r01_wide$elapsed.time_visit_d_arm_1<=84 & r01_wide$acute_visit_d_arm_1==1 & r01_wide$acute_visit_e_arm_1==0, 1, 0)    
r01_wide$pairs_ef<-ifelse(r01_wide$elapsed.time_visit_e_arm_1>=14 & r01_wide$elapsed.time_visit_e_arm_1<=84 & r01_wide$acute_visit_e_arm_1==1 & r01_wide$acute_visit_f_arm_1==0, 1, 0)    
r01_wide$pairs_fg<-ifelse(r01_wide$elapsed.time_visit_f_arm_1>=14 & r01_wide$elapsed.time_visit_f_arm_1<=84 & r01_wide$acute_visit_f_arm_1==1 & r01_wide$acute_visit_g_arm_1==0, 1, 0)    
r01_wide$pairs_gh<-ifelse(r01_wide$elapsed.time_visit_g_arm_1>=14 & r01_wide$elapsed.time_visit_g_arm_1<=84 & r01_wide$acute_visit_g_arm_1==1 & r01_wide$acute_visit_h_arm_1==0, 1, 0)    

table(r01_wide$pairs_ab)
table(r01_wide$pairs_bc)
table(r01_wide$pairs_cd)
table(r01_wide$pairs_de)
table(r01_wide$pairs_ef)
table(r01_wide$pairs_fg)
table(r01_wide$pairs_gh)

