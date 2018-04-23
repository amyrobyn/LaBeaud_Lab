#############################################
#install.packages(c('REDCapR', 'RCurl', 'dplyr', 'dummies', 'redcapAPI', 'rJava', 'WriteXLS', 'readxl', 'xlsx'))
#install.packages("tidyverse")
#install.packages('tableone")
#install.packages("DescTools")
library(REDCapR)
library(RCurl)
library(dplyr)
library(redcapAPI)
library(rJava) 
library(WriteXLS) # Writing Excel files
library(readxl) # Excel file reading
library(xlsx) # Writing Excel files
library(tidyverse)
library(tableone)
library(DescTools)

# get data -----------------------------------------------------------------
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long")
Redcap.token <- readLines("Redcap.token.R01.txt") # Read API token from folder
REDcap.URL  <- 'https://redcap.stanford.edu/api/'
rcon <- redcapConnection(url=REDcap.URL, token=Redcap.token)


#export data from redcap to R (must be connected via cisco VPN)
R01_lab_results <- redcap_read(redcap_uri  = REDcap.URL, token= Redcap.token, batch_size = 300)$data

# making a backup file
R01_lab_results.backup<-R01_lab_results
save(R01_lab_results.backup, file="R01_lab_results.backup.rda")

############################################################################
# I can start here if I want to use the file already saved on my desktop
library(REDCapR)
library(RCurl)
library(dplyr)
library(redcapAPI)
library(dummies)
library(rJava) 
library(WriteXLS) # Writing Excel files
library(readxl) # Excel file reading
library(xlsx) # Writing Excel files
library(tidyverse)
library(tableone)

############# START HERE #########################
load("R01_lab_results.backup.rda")
R01_lab_results<-R01_lab_results.backup

setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/melisa shah")

# renaming red cap event name to something shorter called event
R01_lab_results$event<-NA # event p=patient info, a=Visit A, b=Visit B, c=Visit etc 
R01_lab_results <- within (R01_lab_results, event[R01_lab_results$redcap_event_name=="patient_informatio_arm_1"] <- "P")
R01_lab_results <- within (R01_lab_results, event[R01_lab_results$redcap_event_name=="visit_a_arm_1"] <- "A")
R01_lab_results <- within (R01_lab_results, event[R01_lab_results$redcap_event_name=="visit_b_arm_1"] <- "B")
R01_lab_results <- within (R01_lab_results, event[R01_lab_results$redcap_event_name=="visit_c_arm_1"] <- "C")
R01_lab_results <- within (R01_lab_results, event[R01_lab_results$redcap_event_name=="visit_c2_arm_1"] <- "C2")
R01_lab_results <- within (R01_lab_results, event[R01_lab_results$redcap_event_name=="visit_d_arm_1"] <- "D")
R01_lab_results <- within (R01_lab_results, event[R01_lab_results$redcap_event_name=="visit_e_arm_1"] <- "E")
R01_lab_results <- within (R01_lab_results, event[R01_lab_results$redcap_event_name=="visit_f_arm_1"] <- "F")
R01_lab_results <- within (R01_lab_results, event[R01_lab_results$redcap_event_name=="visit_g_arm_1"] <- "G")
R01_lab_results <- within (R01_lab_results, event[R01_lab_results$redcap_event_name=="visit_h_arm_1"] <- "H")
R01_lab_results <- within (R01_lab_results, event[R01_lab_results$redcap_event_name=="visit_u24_arm_1"] <- "U24")

#creating the cohort and village and visit variables for each visit. Colating patient information for subsequent visit.  
R01_lab_results$id_cohort<-substr(R01_lab_results$person_id, 2, 2) #F and M are AIC, 0 C and D are other
R01_lab_results$id_city<-substr(R01_lab_results$person_id, 1, 1) #C is Chulaimbo, K is Kisumu, M is Msambweni, U is Ukunda, one 0 not sure, R is also Chulaimbo, G stands for Nganja (one of the subparts of Msambweni), L is for Mililani (part of Msambweni)

#Creating a new variable by studyID for study site
R01_lab_results$id_site<-NA
R01_lab_results <- within (R01_lab_results, id_site[R01_lab_results$id_city=="C" | R01_lab_results$id_city=="R"] <- "Chulaimbo")
R01_lab_results <- within (R01_lab_results, id_site[R01_lab_results$id_city=="K"] <- "Kisumu")
R01_lab_results <- within (R01_lab_results, id_site[R01_lab_results$id_city=="M" | R01_lab_results$id_city=="G" | R01_lab_results$id_city=="L"] <- "Msambweni")
R01_lab_results <- within (R01_lab_results, id_site[R01_lab_results$id_city=="U" ] <- "Ukunda")
table(R01_lab_results$id_site, useNA="ifany") 

#removing any columns with u24 in it
R01_lab_results <- R01_lab_results[, !grepl("u24|sample", names(R01_lab_results) ) ]

#Removing the one studyID starting with a O
R01_lab_results <- R01_lab_results[which(R01_lab_results$id_city!="O"), ]
table(R01_lab_results$id_city)

# subset of the variables to only AIC
aic<-R01_lab_results[which(R01_lab_results$id_cohort=="F" | R01_lab_results$id_cohort=="M" ), ]

# Saving this file called aic
save(aic, file="aic.rda")

# Changing the shape of AIC so that only one ID per row
aic_wide<-reshape(aic, direction = "wide", idvar = "person_id", timevar = "event", sep = "_")

#Checking to see that aic_wide worked correctly
table(aic_wide$id_site_A, useNA="ifany") #For AIC Visit A, 836 Chulaimbo, 1084 Kisumu, 1814 Msambweni, 1792 Ukunda
table(aic_wide$id_site_P, useNA="ifany") 
table(aic_wide$result_microscopy_malaria_kenya_A, useNA="ifany") 

#the reason why id_site looks different for P and A with missings is that some people have a P, but no A, or vise versa
aictest <- subset(aic_wide, select = c("person_id", "id_site_A", "id_site_P"))
#I need to exclude people with missing id_site_A, these get excluded in the step below anyways

#subset of the variables to only AIC with data for malaria microscopy - called aicmalaria, this cuts aic_wide from 5600 observations to 4721 study ids
table(aic_wide$result_microscopy_malaria_kenya_A, useNA="ifany") #879 missings
aicmalaria <- aic_wide[which(!is.na(aic_wide$result_microscopy_malaria_kenya_A)), ]
addmargins (table(aicmalaria$result_microscopy_malaria_kenya_A, aicmalaria$result_microscopy_malaria_kenya_B, useNA="ifany"))

# further trimming aicmalaria to exclude 112 patients with microscopy but no clinical data for the visit 
aicmalaria <- aicmalaria[which(!is.na(aicmalaria$today_aic_A)), ]
table(aicmalaria$today_aic_A, useNA="ifany")

#note that the A visit are listed on the left column, and the visit B across the top row
#there are 85 visit A's that are microscopy negative AND visit B microscopy negative 
#there are 10 visit As that are microscopy negative and visit B microscopy positive 
#there are 52 visit A's that are microscopy positive and visit B microscopy negative 
#There are 25 visit A's that are microscopy positive and visit B microscopy positive 

#Create new variable abmalaria
aicmalaria$abmalaria <- NA
aicmalaria <- within(aicmalaria, abmalaria[aicmalaria$result_microscopy_malaria_kenya_A=="0" & aicmalaria$result_microscopy_malaria_kenya_B =="0"] <- 0) # for A neg, B negative microscopy
aicmalaria <- within(aicmalaria, abmalaria[aicmalaria$result_microscopy_malaria_kenya_A=="0" & aicmalaria$result_microscopy_malaria_kenya_B =="1"] <- 1) # For A neg, B positive microscopy
aicmalaria <- within(aicmalaria, abmalaria[aicmalaria$result_microscopy_malaria_kenya_A=="1" & aicmalaria$result_microscopy_malaria_kenya_B =="0"] <- 2) # For A Pos, B neg microscopy
aicmalaria <- within(aicmalaria, abmalaria[aicmalaria$result_microscopy_malaria_kenya_A=="1" & aicmalaria$result_microscopy_malaria_kenya_B =="1"] <- 3) # for A pos, B Pos microscopy
aicmalaria <- within(aicmalaria, abmalaria[aicmalaria$result_microscopy_malaria_kenya_A=="1" & is.na(aicmalaria$result_microscopy_malaria_kenya_B)] <- 4) # for A pos, B no microscopy
aicmalaria <- within(aicmalaria, abmalaria[aicmalaria$result_microscopy_malaria_kenya_A=="0" & is.na(aicmalaria$result_microscopy_malaria_kenya_B)] <- 5) # for A neg, B no microscopy
addmargins(table(aicmalaria$abmalaria))
addmargins(table(aicmalaria$abmalaria, aicmalaria$anyfever_B))

# Creating a new variable, yes no for table 3, for comparing abmalaria=3 and abmalaria=2 or 4 and yesvisitB=1 
aicmalaria$repeatmalaria_A <- NA
aicmalaria <- within(aicmalaria, repeatmalaria_A[aicmalaria$abmalaria=="3"] <- 1)
aicmalaria <- within(aicmalaria, repeatmalaria_A[aicmalaria$abmalaria=="2" & aicmalaria$yesvisitB=="1"] <- 0)
aicmalaria <- within(aicmalaria, repeatmalaria_A[aicmalaria$abmalaria=="4" & aicmalaria$yesvisitB=="1"] <- 0)
addmargins(table(aicmalaria$repeatmalaria_A, useNA="ifany"))

# Look at abmalaria=3 (positive positive) and abmalaria=2 (positive, negative) and abmalaria=4 (positive, not tested) by study site 
addmargins(table(aicmalaria$abmalaria,aicmalaria$id_site_A, useNA="ifany"))

# How many people didn't get a Visit B visit at all after having a microscopy done on Visit A? 

# Creating a 0/1 variable for whether someone had a Visit B or not at all based on today_aic_B
aicmalaria$yesvisitB <- 1
aicmalaria <- within(aicmalaria, yesvisitB[is.na(aicmalaria$today_aic_B)] <- 0)
addmargins(table(aicmalaria$yesvisitB, useNA="ifany"))
addmargins(table(aicmalaria$yesvisitB, aicmalaria$id_site_A, useNA="ifany"))

# creating a variable called docfever for temp >38.0
aicmalaria$docfever_A<-NA
aicmalaria <- within (aicmalaria, docfever_A[aicmalaria$temp_A <38.0] <- 0)
aicmalaria <- within (aicmalaria, docfever_A[aicmalaria$temp_A >=38.0 & aicmalaria$temp_A < 42] <- 1) #removes an erroneous numbers as missing
table(aicmalaria$result_microscopy_malaria_kenya_A, aicmalaria$docfever_A, useNA="ifany")
table(aicmalaria$docfever_A, useNA="ifany")

# creating a variable called docfever_B for temp >38.0
aicmalaria$docfever_B<-NA
aicmalaria <- within (aicmalaria, docfever_B[aicmalaria$temp_B <38.0] <- 0)
aicmalaria <- within (aicmalaria, docfever_B[aicmalaria$temp_B >=38.0 & aicmalaria$temp_A < 42] <- 1) #removes an erroneous numbers as missing
table(aicmalaria$result_microscopy_malaria_kenya_B, aicmalaria$docfever_B, useNA="ifany")
table(aicmalaria$docfever_B, useNA="ifany")
table(aicmalaria$temp_B, aicmalaria$result_microscopy_malaria_kenya_B, useNA="ifany")

# There are only 4 people without fevers on Visit A (which I excluded below), and 464 with missing values
nofever <- subset(aicmalaria, docfever_A=="0", select = c("person_id", "id_site_A", "temp_A", "result_microscopy_malaria_kenya_A", "docfever_A"))

# further trimming aicmalaria to exclude 4 patients without documented fever on Visit A
aicmalaria <- aicmalaria[which(aicmalaria$docfever_A=="1" | is.na(aicmalaria$docfever_A)), ]

# analyzing the medications prescribed variable 

# first pasting meds prescribed and other meds prescribed together 
aicmalaria$medscomb_A <- paste(aicmalaria$meds_prescribed_A, aicmalaria$oth_meds_prescribed_A, sep=" ")
table(aicmalaria$medscomb_A)
medscombtest <- subset(aicmalaria, select=c("person_id", "medscomb_A", "meds_prescribed_A", "oth_meds_prescribed_A"))
# okay it worked

aicmalaria$coartem_A <- ifelse(grepl("coartem", aicmalaria$medscomb_A, ignore.case=T), "1","0" )
table(aicmalaria$coartem_A, useNA="ifany")

aicmalaria$quinine_A <- ifelse(grepl("quinine", aicmalaria$medscomb_A, ignore.case=T), "1","0" )
table(aicmalaria$quinine_A, useNA="ifany")

aicmalaria$artesunate_A <- ifelse(grepl("artesunate", aicmalaria$medscomb_A, ignore.case=T), "1","0" )
table(aicmalaria$artesunate_A, useNA="ifany")



# now for the 464 patients with missing temperature data on Visit A, seeing if they have reported fever
# First combining the two symptom columns together (note there is no missing sx data for all the aicmalaria rows)
aicmalaria$symptomscomb_A <- paste(aicmalaria$symptoms_aic_A, aicmalaria$oth_symptoms_aic_A, sep=" ") 
table(aicmalaria$symptomscomb_A)
sxtest <- subset(aicmalaria, select = c("person_id", "symptomscomb_A", "symptoms_aic_A", "oth_symptoms_aic_A"))

# starting with fever, find any string in symptoms_aic or other syptoms aic with the string "fever"
aicmalaria$reportfever_A <- ifelse(grepl("fever", aicmalaria$symptomscomb_A, ignore.case=T), "1","0" )
sxtest1 <- subset(aicmalaria, select = c("person_id", "symptomscomb_A", "reportfever_A", "symptoms_aic_A", "oth_symptoms_aic_A"))
table(aicmalaria$reportfever_A, useNA="ifany") # there are 558 without reported fever, 4047 with reported fever
table(aicmalaria$reportfever_A, aicmalaria$docfever_A, useNA="ifany") 

# doing same for the B visit###
# First combining the two symptom columns together (note there is no missing sx data for all the aicmalaria rows)
aicmalaria$symptomscomb_B <- paste(aicmalaria$symptoms_aic_B, aicmalaria$oth_symptoms_aic_B, sep=" ") 
aicmalaria$reportfever_B <- ifelse(grepl("fever", aicmalaria$symptomscomb_B, ignore.case=T), "1","0" )
table(aicmalaria$symptomscomb_B)
sxtestb <- subset(aicmalaria, select = c("person_id", "symptomscomb_B", "symptoms_aic_B", "oth_symptoms_aic_B", "docfever_B", "temp_B", "reportfever_B", "result_microscopy_malaria_kenya_B"))

# starting with fever, find any string in symptoms_aic or other syptoms aic with the string "fever"
aicmalaria$reportfever_B <- ifelse(grepl("fever", aicmalaria$symptomscomb_B, ignore.case=T), "1","0" )

aicmalaria$anyfever_B <-NA
aicmalaria <- within(aicmalaria, anyfever_B[aicmalaria$docfever_B=="1" | aicmalaria$reportfever_B =="1"] <- 1) 
table(aicmalaria$anyfever_B, aicmalaria$result_microscopy_malaria_kenya_B)

sxtestb2 <- subset(aicmalaria, select = c("person_id", "symptomscomb_B", "symptoms_aic_B", "oth_symptoms_aic_B", "docfever_B", "temp_B", "anyfever_B", "reportfever_B", "result_microscopy_malaria_kenya_B"))
table(aicmalaria$reportfever_B, useNA="ifany") # there are 558 without reported fever, 4047 with reported fever
table(aicmalaria$reportfever_B, aicmalaria$docfever_B, useNA="ifany") 

# Now I need to exclude the 285 without a documented fever OR a reported fever at Visit A, dropping aicmalaria from 4605 to 4320 observations
aicmalaria <- aicmalaria[which(aicmalaria$docfever_A=="1" | aicmalaria$reportfever_A=="1"), ]


#creating an age category variable
aicmalaria$agecat_A<- NA
aicmalaria <- within(aicmalaria, agecat_A[aicmalaria$aic_calculated_age_A>0 & aicmalaria$aic_calculated_age_A<=2] <- 1)
aicmalaria <- within(aicmalaria, agecat_A[aicmalaria$aic_calculated_age_A>2 & aicmalaria$aic_calculated_age_A<=5] <- 2)
aicmalaria <- within(aicmalaria, agecat_A[aicmalaria$aic_calculated_age_A>5 & aicmalaria$aic_calculated_age_A<=10] <- 3)
aicmalaria <- within(aicmalaria, agecat_A[aicmalaria$aic_calculated_age_A>10 & aicmalaria$aic_calculated_age_A<=15] <- 4)
aicmalaria <- within(aicmalaria, agecat_A[aicmalaria$aic_calculated_age_A>15 & aicmalaria$aic_calculated_age_A<=17] <- 5)
addmargins(table(aicmalaria$agecat_A, useNA="ifany"))

# Exploring the 23 missings for agecat
ageprob <- subset(aicmalaria, is.na(agecat_A), select = c("person_id", "aic_calculated_age_A")) # they are 23 people with calculated 

# Removing 23 rows where agecat_A is equal to NA
aicmalaria <- aicmalaria[which(!is.na(aicmalaria$agecat_A)), ]
addmargins(table(aicmalaria$agecat_A, useNA="ifany"))

# for headache, find any string in symptomscomb_A with the string "headache"
aicmalaria$reportheadache_A <- ifelse(grepl("headache", aicmalaria$symptomscomb_A, ignore.case=T), "1","0" )
table(aicmalaria$reportheadache_A, useNA="ifany")

# for joint pain, find any string in symptomscomb_A with the string "joint"
aicmalaria$reportjoint_A <- ifelse(grepl("joint", aicmalaria$symptomscomb_A, ignore.case=T), "1","0" )
table(aicmalaria$reportjoint_A, useNA="ifany")

# for muscle pain, find any string in symptomscomb_A with the string "muscle"
aicmalaria$reportmuscle_A <- ifelse(grepl("muscle", aicmalaria$symptomscomb_A, ignore.case=T), "1","0" )
table(aicmalaria$reportmuscle_A, useNA="ifany")

# for nausea, find any string in symptomscomb_A with the string "nausea"
aicmalaria$reportnausea_A <- ifelse(grepl("nausea", aicmalaria$symptomscomb_A, ignore.case=T), "1","0" )
table(aicmalaria$reportnausea_A, useNA="ifany")

# for vomiting, find any string in symptomscomb_A with the string "vomit"
aicmalaria$reportvomit_A <- ifelse(grepl("vomit", aicmalaria$symptomscomb_A, ignore.case=T), "1","0" )
table(aicmalaria$reportvomit_A, useNA="ifany")

# Creating a variable for nausea or vomiting (1638 positive)
aicmalaria$reportnv_A <- 0
aicmalaria <- within(aicmalaria, reportnv_A[aicmalaria$reportnausea_A=="1" | aicmalaria$reportvomit_A=="1"] <- 1)
table(aicmalaria$reportvomit_A, aicmalaria$reportnausea_A, useNA="ifany")
table(aicmalaria$reportnv_A, useNA="ifany")

# for diarrhea, find any string in symptomscomb_A with the string "diarrhea"
aicmalaria$reportdiarrhea_A <- ifelse(grepl("diarrhea", aicmalaria$symptomscomb_A, ignore.case=T), "1","0" )
table(aicmalaria$reportdiarrhea_A, useNA="ifany")

# for abdominal pain, find any string in symptomscomb_A with the string "abdominal"
aicmalaria$reportabd_A <- ifelse(grepl("abdominal", aicmalaria$symptomscomb_A, ignore.case=T), "1","0" )
table(aicmalaria$reportabd_A, useNA="ifany")

# for cough, find any string in symptomscomb_A with the string "cough"
aicmalaria$reportcough_A <- ifelse(grepl("cough", aicmalaria$symptomscomb_A, ignore.case=T), "1","0" )
table(aicmalaria$reportcough_A, useNA="ifany")

# for loss of appetite, find any string in symptomscomb_A with the string "appetite"
aicmalaria$reportappetite_A <- ifelse(grepl("appetite", aicmalaria$symptomscomb_A, ignore.case=T), "1","0" )
table(aicmalaria$reportappetite_A, useNA="ifany")

# for chills, find any string in symptomscomb_A with the string "chiils"
aicmalaria$reportchills_A <- ifelse(grepl("chiils", aicmalaria$symptomscomb_A, ignore.case=T), "1","0" )
table(aicmalaria$reportchills_A, useNA="ifany")

# for rash, find any string in symptomscomb_A with the string "rash"
aicmalaria$reportrash_A <- ifelse(grepl("rash", aicmalaria$symptomscomb_A, ignore.case=T), "1","0" )
table(aicmalaria$reportrash_A, useNA="ifany")

#exploring 
table(aicmalaria$id_site_A, useNA="ifany")
table(aicmalaria$roof_type_A, useNA="ifany")
table(aicmalaria$latrine_type_A, useNA="ifany")
table(aicmalaria$floor_type_A, useNA="ifany")
table(aicmalaria$drinking_water_source_A, useNA="ifany")
table(aicmalaria$windows_A, useNA="ifany") # exclude for now
table(aicmalaria$mosquito_bites_aic_A, useNA="ifany")
table(aicmalaria$ever_hospitalized_aic_A, useNA="ifany")
table(aicmalaria$primary_diagnosis_A, useNA="ifany")
table(aicmalaria$gender_A, useNA="ifany")

#Figuring out gender, the original data set has patient information visit a with study ID as a column#
#the adjusted dataset has study ID as the first column, with the patient information columns listed with a P#
#and subsequent visits listed as _A etc. I'm trying to gather all the gender information into one spot.#
# I want to get in under gender_aic_A. So I need to find for the people where aic_gender_A is missing#
#is it located under gender_P. So lets make a table with this information"
table(aicmalaria$gender_aic_A, useNA="ifany") #1550 missing
genexplore <- subset(aicmalaria, is.na(gender_aic_A)) #checked these studyIDs and they are missing genders in redcap#

# For all the binary variables with a number 8 for not reported, need to change the 8 to NA
# This won't be the most elegant way, but I'm just going to create new variables for the binary variables.
# There has got to be an easier way to do this.....

aicmalaria <- within(aicmalaria, telephone_A[aicmalaria$telephone_A == 8] <- NA)
table(aicmalaria$telephone_A, useNA="ifany")

aicmalaria <- within(aicmalaria, radio_A[aicmalaria$radio_A == 8] <- NA)
aicmalaria <- within(aicmalaria, television_A[aicmalaria$television_A == 8] <- NA)
aicmalaria <- within(aicmalaria, bicycle_A[aicmalaria$bicycle_A == 8] <- NA)
aicmalaria <- within(aicmalaria, motor_vehicle_A[aicmalaria$motor_vehicle_A == 8] <- NA)
aicmalaria <- within(aicmalaria, domestic_worker_A[aicmalaria$domestic_worker_A == 8] <- NA)
aicmalaria <- within(aicmalaria, fever_contact_A[aicmalaria$fever_contact_A == 8] <- NA)
aicmalaria <- within(aicmalaria, outdoor_activity_A[aicmalaria$outdoor_activity_A == 8] <- NA)
aicmalaria <- within(aicmalaria, mosquito_bites_aic_A[aicmalaria$mosquito_bites_aic_A == 8] <- NA)
aicmalaria <- within(aicmalaria, mosquito_coil_aic_A[aicmalaria$mosquito_coil_aic_A == 8] <- NA)
aicmalaria <- within(aicmalaria, mosquito_net_aic_A[aicmalaria$mosquito_net_aic_A == 9] <- NA)
aicmalaria <- within(aicmalaria, child_travel_A[aicmalaria$child_travel_A == 8] <- NA)
aicmalaria <- within(aicmalaria, stay_overnight_aic_A[aicmalaria$stay_overnight_aic_A == 8] <- NA)
aicmalaria <- within(aicmalaria, ever_hospitalized_aic_A[aicmalaria$ever_hospitalized_aic_A == 8] <- NA)
aicmalaria <- within(aicmalaria, term_A[aicmalaria$term_A == 7] <- NA)
aicmalaria <- within(aicmalaria, breast_fed_A[aicmalaria$breast_fed_A == 8] <- NA)
aicmalaria <- within(aicmalaria, currently_taking_medications_A[aicmalaria$currently_taking_medications_A == 8] <- NA)
aicmalaria <- within(aicmalaria, hiv_result_A[aicmalaria$hiv_result_A == 7] <- NA)
aicmalaria <- within(aicmalaria, hiv_result_A[aicmalaria$hiv_result_A == 8] <- NA)
aicmalaria <- within(aicmalaria, primary_diagnosis_A[aicmalaria$primary_diagnosis_A == 99] <- NA)
aicmalaria <- within(aicmalaria, outcome_hospitalized_A[aicmalaria$outcome_hospitalized_A == 8] <- NA)
aicmalaria <- within(aicmalaria, roof_type_A[aicmalaria$roof_type_A == 9] <- NA)
aicmalaria <- within(aicmalaria, latrine_type_A[aicmalaria$latrine_type_A == 9] <- NA)
aicmalaria <- within(aicmalaria, floor_type_A[aicmalaria$floor_type_A == 9] <- NA)
aicmalaria <- within(aicmalaria, drinking_water_source_A[aicmalaria$drinking_water_source_A == 9] <- NA)
aicmalaria <- within(aicmalaria, light_source_A[aicmalaria$light_source_A == 9] <- NA)
aicmalaria <- within(aicmalaria, outcome_hospitalized_A[aicmalaria$outcome_hospitalized_A == 8] <- NA)

# Exploring the RDT data. 
table(aicmalaria$rdt_results_A, aicmalaria$result_microscopy_malaria_kenya_A, useNA="ifany")

# subset for lat, long, village
longlat <- subset(aicmalaria, select = c("person_id", "id_site_A", "temp_A", "result_microscopy_malaria_kenya_A", "docfever_A", "aic_village_gps_lattitude_A", "aic_village_gps_longitude_A", "village_aic_A"))
write.csv(longlat, file = "longlat.csv")

# subset for travel
travel <- subset(aicmalaria, select = c("person_id", "id_site_A", "temp_A", "result_microscopy_malaria_kenya_A", "docfever_A", "child_travel_A", "where_travel_aic_A", "village_aic_A"))
write.csv(longlat, file = "longlat.csv")

# subset for map2
map2jaime <- subset (aicmalaria, select =c("person_id", "id_site_A", "interview_date_aic_A", "result_microscopy_malaria_kenya_A"))
write.csv(map2jaime, file = "map2jaime.csv")

# subset for malaria visit B 
visitB <- subset(aicmalaria, select = c("person_id", "id_site_B", "temp_B", "docfever_B", "reportfever_B", "anyfever_B", "symptoms_aic_B", "oth_symptoms_aic_B", "result_microscopy_malaria_kenya_B"))
write.csv(visitB, file = "visitB.csv")

as.character(unique(unlist(aicmalaria$current_medications_A)))
as.character(unique(unlist(aicmalaria$oth_current_medications_A)))

# Create Table 1 stratified by malaria status
vars <- c(
  "id_site_A", 
  "aic_calculated_age_A", 
  "agecat_A", 
  "gender_aic_A", 
  "temp_A", 
  "yesvisitb",
  "date_symptom_onset_A", 
  "primary_diagnosis_A", 
  "roof_type_A", 
  "latrine_type_A", 
  "floor_type_A", 
  "drinking_water_source_A", 
  "ever_hospitalized_aic_A", 
  "light_source_A", 
  "number_windows_A", 
  "number_people_in_house_A", 
  "rooms_in_house_A", 
  "number_sleeping_same_room_A", 
  "number_siblings_aic_A", 
  "telephone_A", 
  "radio_A", 
  "television_A", 
  "bicycle_A", 
  "motor_vehicle_A", 
  "domestic_worker_A", 
  "fever_contact_A", 
  "outoor_activity_aic_A", 
  "mosquito_bites_aic_A", 
  "mosquito_coil_aic_A", 
  "mosquito_net_aic_A", 
  "child_travel_A", 
  "stay_overnight_aic_A",
  "ever_hospitalized_aic_A",
  "term_A", 
  "breast_fed_A", 
  "currently_taking_medications_A", 
  "hiv_result_A",
  "outcome_A", 
  "outcome_hospitalized_A")
factorVars <- c(
  "agecat_A", 
  "gender_aic_A", 
  "yesvisitb",
  "primary_diagnosis_A", 
  "roof_type_A", 
  "latrine_type_A", 
  "floor_type_A", 
  "drinking_water_source_A", 
  "ever_hospitalized_aic_A", 
  "light_source_A", 
  "telephone_A", 
  "radio_A", 
  "television_A", 
  "bicycle_A", 
  "motor_vehicle_A", 
  "domestic_worker_A", 
  "fever_contact_A", 
  "outoor_activity_aic_A", 
  "mosquito_bites_aic_A", 
  "mosquito_coil_aic_A", 
  "mosquito_net_aic_A", 
  "child_travel_A", 
  "stay_overnight_aic_A",
  "ever_hospitalized_aic_A",
  "term_A", 
  "breast_fed_A", 
  "currently_taking_medications_A", 
  "hiv_result_A",
  "outcome_A", 
  "outcome_hospitalized_A")
tableOne <- CreateTableOne(vars = vars, factorVars = factorVars, strata = "result_microscopy_malaria_kenya_A", data = aicmalaria)

print(tableOne, nonnormal = "aic_calculated_age_A", exact = "stage", quote = TRUE, noSpaces = TRUE)
table1 <- print(tableOne, nonnormal = "aic_calculated_age_A", exact = "stage", quote = FALSE, noSpaces = TRUE, printToggle = FALSE)
## Save to a CSV file
write.csv(table1, file = "table1.csv")

summary(tableOne)
print(tableOne, 
      exact = c("id_site_A", "aic_calculated_age_A", "gender_aic_A", "gender_A", "doctemp_A", "temp_A", "date_symptom_onset_A", "yesvisitB", "primary_diagnosis_A"),
      nonnormal=c("aic_calculated_age_A", "temp_A"), quote = TRUE)

# Create Table 2 stratified by malaria status
library(tableone)
vars <- c("reportnv_A", "reportfever_A", "reportheadache_A", "reportjoint_A", "reportmuscle_A", "reportnausea_A", "reportvomit_A", "reportdiarrhea_A", "reportabd_A", "reportcough_A", "reportappetite_A", "reportchills_A", "reportrash_A")
factorVars <- c("reportnv_A", "reportfever_A", "reportheadache_A", "reportjoint_A", "reportmuscle_A", "reportnausea_A", "reportvomit_A", "reportdiarrhea_A", "reportabd_A", "reportcough_A", "reportappetite_A", "reportchills_A", "reportrash_A")
tableOne <- CreateTableOne(vars = vars, factorVars = factorVars, strata = "result_microscopy_malaria_kenya_A", data = aicmalaria)
tableOne

print(tableOne, nonnormal = "aic_calculated_age_A", exact = "stage", quote = TRUE, noSpaces = TRUE)
table2 <- print(tableOne, nonnormal = "aic_calculated_age_A", exact = "stage", quote = FALSE, noSpaces = TRUE, printToggle = FALSE)
## Save to a CSV file
write.csv(table2, file = "table2.csv")

#Table 3 Outcomes 
table(aicmalaria$outcome_A)
table(aicmalaria$outcome_hospitalized_A)
table(aicmalaria$meds_prescribed_A)

vars <- c("coartem_A", "quinine_A", "artesunate_A", "outcome_A", "outcome_hospitalized_A")
factorVars <- c("outcome_A", "outcome_hospitalized_A")
tableOne <- CreateTableOne(vars = vars, factorVars = factorVars, strata = "result_microscopy_malaria_kenya_A", data = aicmalaria)
tableOne

print(tableOne, exact = "coartem_A", quote = TRUE, noSpaces = TRUE)
table3 <- print(tableOne, nonnormal = "aic_calculated_age_A", exact = "stage", quote = FALSE, noSpaces = TRUE, printToggle = FALSE)
## Save to a CSV file
write.csv(table3, file = "table3.csv")


# Create Table 4
vars <- c("id_site_A", "aic_calculated_age_A", "agecat_A", "gender_aic_A", "temp_A", "date_symptom_onset_A", "primary_diagnosis_A", "roof_type_A", "latrine_type_A", "floor_type_A", "drinking_water_source_A", "mosquito_bites_aic_A", "ever_hospitalized_aic_A", "coartem_A", "quinine_A", "artesunate_A")
factorVars <- c("agecat_A", "gender_aic_A", "primary_diagnosis_A", "roof_type_A", "latrine_type_A", "floor_type_A", "drinking_water_source_A", "mosquito_bites_aic_A", "ever_hospitalized_aic_A")
tableOne <- CreateTableOne(vars = vars, factorVars = factorVars, strata = "repeatmalaria_A", data = aicmalaria)
tableOne

print(tableOne, nonnormal = "aic_calculated_age_A", exact = "stage", quote = TRUE, noSpaces = TRUE)
table4 <- print(tableOne, nonnormal = "aic_calculated_age_A", exact = "stage", quote = FALSE, noSpaces = TRUE, printToggle = FALSE)
## Save to a CSV file
write.csv(table4, file = "table4.csv")

setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/melisa shah")

write.csv(aicmalaria, file = "aicmalaria.csv")
saveRDS(aicmalaria, file="aicmalaria.rds")

