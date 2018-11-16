# download data and packages here -----------------------------------------------------
#install.packages(c('REDCapR','RCurl','dummies','redcapAPI','rJava','WriteXLS','readxl','xlsx','dplyr','plyr','tidyverse','tableone','DescTools','ggplot2','plotly','zoo','DataCombine'))

library(REDCapR)
library(RCurl)
library(dummies)
library(redcapAPI)
library(rJava) 
library(WriteXLS) # Writing Excel files
library(readxl) # Excel file reading
library(xlsx) # Writing Excel files
library(dplyr)
library(plyr)
library(tidyverse)
library(tableone)
library(DescTools)
library(ggplot2)
library(plotly)
library(zoo)
library(DataCombine)
library(lubridate)

setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/melisa shah")

Redcap.token <- readLines("Redcap.token.R01.txt") #Read API token from folder
REDcap.URL <- 'https://redcap.stanford.edu/api/'
rcon <- redcapConnection(url=REDcap.URL, token=Redcap.token)

#export data from redcap to R (must be connected via cisco VPN)
R01_lab_results <- redcap_read(redcap_uri  = REDcap.URL, token= Redcap.token, batch_size = 300)$data

# making a backup file
R01_lab_results.backup<-R01_lab_results
save(R01_lab_results.backup, file="R01_lab_results.backup.rda") # done 10/23/18
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/melisa shah")
Redcap.token <- readLines("vector api token.txt") #Read API token from folder
REDcap.URL  <- 'https://redcap.stanford.edu/api/'
rcon <- redcapConnection(url=REDcap.URL, token=Redcap.token)
redcap_clim_vec <- redcap_read(redcap_uri  = REDcap.URL, token = Redcap.token, batch_size = 100)$data

# making a backup file
save(redcap_clim_vec, file="redcap_clim_vec.rda") # done 10/17/18


# start analysis here -----------------------------------------------------
############# START HERE #########################
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/melisa shah")
#setwd("/Users/melisashah/Documents/Malaria Stanford/Rdata")
load("R01_lab_results.backup.rda")
R01_lab_results<-R01_lab_results.backup

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
table(aic_wide$id_site_A, useNA="ifany") 
table(aic_wide$id_site_P, useNA="ifany") 
table(aic_wide$result_microscopy_malaria_kenya_A, useNA="ifany") 
head(aic_wide$date_of_birth_aic_A, n=10)
head(aic_wide$interview_date_aic_A, n=10)

cdna <- aic_wide
save(cdna, file="cdna.rda")

############Trimming based on Microscopy######################################
#subset of the variables to only AIC with data for malaria microscopy - called aicmalaria, this cuts aic_wide from 5600 observations to 4721 study ids
table(aic_wide$result_microscopy_malaria_kenya_A, useNA="ifany") #1435 missings
aicmalaria <- aic_wide[which(!is.na(aic_wide$result_microscopy_malaria_kenya_A)), ]
aicmalaria <- aicmalaria[which(aicmalaria$result_microscopy_malaria_kenya_A!="98"), ]
addmargins (table(aicmalaria$result_microscopy_malaria_kenya_A, useNA="ifany"))
addmargins (table(aicmalaria$result_microscopy_malaria_kenya_A, aicmalaria$result_microscopy_malaria_kenya_B, useNA="ifany"))
addmargins (table(aicmalaria$result_microscopy_malaria_kenya_A, aicmalaria$id_site_A, useNA="ifany"))

# further trimming aicmalaria to exclude 61 patients with microscopy but no interview date
table(aicmalaria$interview_date_aic_A=="", aicmalaria$result_microscopy_malaria_kenya_A)
aicmalaria <- aicmalaria[which(aicmalaria$interview_date_aic_A!=""), ]

# fixing the missing calculated ages
summary(aicmalaria$aic_calculated_age_A) #111 missings
aicmalaria$bday <- as.Date(aicmalaria$date_of_birth_aic_A, "%Y-%m-%d")

############# TRIMMING BASED ON FEVER ##############################################
# creating a variable called docfever for temp >38.0
aicmalaria$docfever_A<-NA
aicmalaria <- within (aicmalaria, docfever_A[aicmalaria$temp_A <38.0] <- 0)
aicmalaria <- within (aicmalaria, docfever_A[aicmalaria$temp_A >=38.0 & aicmalaria$temp_A < 42.7] <- 1) #removes an erroneous numbers as missing
table(aicmalaria$result_microscopy_malaria_kenya_A, aicmalaria$docfever_A, useNA="ifany")
table(aicmalaria$docfever_A, useNA="ifany")

# creating another variable for whether someone has a reported fever
aicmalaria$symptomscomb_A <- paste(aicmalaria$symptoms_aic_A, aicmalaria$oth_symptoms_aic_A, sep=" ") 
aicmalaria$reportfever_A <- ifelse(grepl("fever", aicmalaria$symptomscomb_A, ignore.case=T), "1","0" )

# creating a third variable for whether someone has a documented OR reported fever
aicmalaria$anyfever_A <-NA
aicmalaria <- within(aicmalaria, anyfever_A[aicmalaria$docfever_A=="1" | aicmalaria$reportfever_A =="1"] <- 1) 
aicmalaria <- within(aicmalaria, anyfever_A[aicmalaria$docfever_A=="0" & aicmalaria$reportfever_A =="0"] <- 0)
aicmalaria <- aicmalaria[which(aicmalaria$anyfever_A=="1"), ] #removes 10 ids

##########################Done with the Fever Part of it#############################
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

################################################################
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

# Creating variables for microscopy positive
aicmalaria$microA <- aicmalaria$result_microscopy_malaria_kenya_A

#limiting aic malaria to ages 0-17
aicmalaria<-aicmalaria[which(aicmalaria$aic_calculated_age_A>=0 & aicmalaria$aic_calculated_age_A<=17),]

#ses variable
ses<-(aicmalaria[, grepl("telephone|radio|television|bicycle|motor_vehicle|domestic_worker", names(aicmalaria))])
aicmalaria$ses_sum<-rowSums(aicmalaria[, c("telephone_A","radio_A","television_A","bicycle_A","motor_vehicle_A", "domestic_worker_A")], na.rm = TRUE)
table(aicmalaria$ses_sum, aicmalaria$id_site_A)

table(aicmalaria$ses_sum, useNA="ifany")
aicmalaria$poorses <- 0
aicmalaria <- within(aicmalaria, poorses[aicmalaria$ses_sum < 3] <- 1)
table(aicmalaria$poorses, useNA="ifany")

#fixing mosquito net aic A, creating a 0 and 1 variable, 1=always, 2=sometimes, 3=Rarely, 4=Never. 
table(aicmalaria$mosquito_net_aic_A, useNA="ifany")
aicmalaria$net <- 0
aicmalaria <- within(aicmalaria, net[aicmalaria$mosquito_net_aic_A=="1"] <- 1)
table(aicmalaria$net, useNA="ifany")

# making a date variable
aicmalaria$date <- as.Date(aicmalaria$interview_date_aic_A, "%Y-%m-%d")

aicmalaria_u<-aicmalaria[which(aicmalaria$id_site_A=="Ukunda"),]
aicmalaria_m<-aicmalaria[which(aicmalaria$id_site_A=="Msambweni"),]
aicmalaria_c<-aicmalaria[which(aicmalaria$id_site_A=="Chulaimbo"),]
aicmalaria_k<-aicmalaria[which(aicmalaria$id_site_A=="Kisumu"),]

# Saving aic malaria making a backup file
save(aicmalaria, file="aicmalaria.rda") #done 10/1/18

summary(aicmalaria$date)
summary(aicmalaria_c$date)
summary(aicmalaria_k$date)
summary(aicmalaria_m$date)
summary(aicmalaria_u$date)

########### start here ##################
load("redcap_clim_vec.rda")
climate<-redcap_clim_vec           
climate$date <- as.Date(climate$date_collected, "%Y-%m-%d")
save(climate,file="climate.rda")

# pulling in Jamie's gap filled climate data -----------------------------------------------------------------
newgapfilled<-read.csv("newgapfilled.csv")
temp<-newgapfilled[,c("Date", "meanTemp.CH","meanTemp.KI","meanTemp.MS", "meanTemp.UK")]
temp$Date <- as.Date(temp$Date,, "%Y-%m-%d")
summary(temp$Date)
plot(temp$Date, (temp$meanTemp.CH), exclude=NULL)
plot(temp$Date, (temp$meanTemp.KI), exclude=NULL)
plot(temp$Date, (temp$meanTemp.MS), exclude=NULL)
plot(temp$Date, (temp$meanTemp.UK), exclude=NULL)

temp.long<-reshape(temp, varying=c("meanTemp.CH","meanTemp.KI","meanTemp.MS", "meanTemp.UK"), direction="long", idvar="Date", sep=".",timevar ="site")
colnames(temp.long)[1] <- "date_collected"

temp.long$date_collected <- as.Date(temp.long$date_collected, "%Y-%m-%d")
temp.long <- within (temp.long, site[temp.long$site=="UK"] <-"Ukunda")
temp.long <- within (temp.long, site[temp.long$site=="MS"] <-"Msambweni")
temp.long <- within (temp.long, site[temp.long$site=="KI"] <-"Kisumu")
temp.long <- within (temp.long, site[temp.long$site=="CH"] <-"Chulaimbo")
plot(temp.long$date_collected, round(temp.long$meanTemp), exclude=NULL)
#temp long is now a list of daily dates x 4 for each site followed by mean temp
#Now lets add a few columns with the 1, 2, 3,4 week lags. 

# make rolling means for temperature over time -----------------------------------
library(dplyr)
library(zoo)
temp.long=temp.long %>%
  group_by(site) %>%
  arrange(site, date_collected) %>%
  mutate(
    temp_mean_30 = rollmean(x = meanTemp, 30, align = "right", fill = NA)
  )

temp.long=temp.long %>%
  mutate(temp.lag1 = lag(meanTemp, n=7)) %>%
  mutate(temp_mean_30_1 = rollapply(data=temp.lag1,
                                    width=30,
                                    FUN=mean,
                                    align="right",
                                    fill=NA,
                                    nr.rm=T))

temp.long=temp.long %>%
  mutate(temp.lag2 = lag(meanTemp, n=14)) %>%
  mutate(temp_mean_30_2 = rollapply(data=temp.lag2,
                                    width=30,
                                    FUN=mean,
                                    align="right",
                                    fill=NA,
                                    nr.rm=T))

temp.long=temp.long %>%
  mutate(temp.lag3 = lag(meanTemp, n=21)) %>%
  mutate(temp_mean_30_3 = rollapply(data=temp.lag3,
                                    width=30,
                                    FUN=mean,
                                    align="right",
                                    fill=NA,
                                    nr.rm=T))


temp.long=temp.long %>%
  mutate(temp.lag4 = lag(meanTemp, n=28)) %>%
  mutate(temp_mean_30_4 = rollapply(data=temp.lag4,
                                    width=30,
                                    FUN=mean,
                                    align="right",
                                    fill=NA,
                                    nr.rm=T))

temp.long=temp.long %>%
  mutate(temp.lag5 = lag(meanTemp, n=30)) %>%
  mutate(temp_mean_30_30dlag = rollapply(data=temp.lag5,
                                         width=30,
                                         FUN=mean,
                                         align="right",
                                         fill=NA,
                                         nr.rm=T))


# rain climate -----------------------------------------------------------------
library(zoo)
library(lubridate)
climate$month_collected <- as.yearmon(climate$date_collected)
climate$date_collected<-as.Date(climate$date_collected)
climate$date_collected<-ymd(climate$date_collected)

library(plyr)
ch.hosp.clim<-subset(climate, redcap_event_name=="chulaimbo_hospital_arm_1")
ch.vill.clim<-subset(climate, redcap_event_name=="chulaimbo_village_arm_1")
ch.clim<-merge(ch.hosp.clim, ch.vill.clim, by=c("date_collected"), all=T)
ch.clim$daily_rainfall <- round(rowMeans(ch.clim[,c("daily_rainfall.x", "daily_rainfall.y")], na.rm=TRUE), 1)
chulaimbo.clim <- ch.clim[,c("date_collected", "daily_rainfall", "redcap_event_name.x")]
colnames(chulaimbo.clim)[3] <- "redcap_event_name"
chulaimbo.clim$redcap_event_name<-as.character(chulaimbo.clim$redcap_event_name)
table(chulaimbo.clim$redcap_event_name)
climate<-climate[which(climate$redcap_event_name=="ukunda_arm_1"|climate$redcap_event_name=="obama_arm_1"|climate$redcap_event_name=="msambweni_arm_1"),]
climate<-rbind.fill(climate,chulaimbo.clim)

climate$site<-NA
climate <- within (climate, site[climate$redcap_event_name=="chulaimbo_hospital_arm_1"] <-"Chulaimbo")
climate <- within (climate, site[climate$redcap_event_name=="ukunda_arm_1"] <-"Ukunda")
climate <- within (climate, site[climate$redcap_event_name=="obama_arm_1"] <-"Kisumu")
climate <- within (climate, site[climate$redcap_event_name=="msambweni_arm_1"] <-"Msambweni")
climate <-climate[!sapply(climate, function (x) all(is.na(x) ))]
time.min <-as.Date(as.character("2013/01/01"))
time.max <-as.Date(as.character("2018/08/31"))

table(climate$site)
climate<-climate[,c("date_collected","daily_rainfall","rainfall_hobo","site","daily_rainfall_long_term_mean")]
all.dates<-seq(as.Date('2013/01/01'), as.Date('2018/08/31'), by = 'day')
all.dates.frame <- data.frame(list(date_collected=all.dates))

# Chulaimbo Rain Lags
climate.c<-climate[which(climate$site=="Chulaimbo"),]
climate.c <- merge(all.dates.frame, climate.c, all.x=T, by=c("date_collected"))
climate.c=climate.c %>%
  group_by(site) %>%
  arrange(site, date_collected) %>%
  mutate(
    rain_sum_30 = rollsum(x = daily_rainfall, 30, align = "right", fill = NA)
  )

climate.c=climate.c %>%
  mutate(rain.lag1 = lag(daily_rainfall, n=7)) %>%
  mutate(rain_sum_30_1 = rollapply(data=rain.lag1,
                                   width=30,
                                   FUN=sum,
                                   align="right",
                                   fill=NA,
                                   nr.rm=T))
climate.c=climate.c %>%
  mutate(rain.lag2 = lag(daily_rainfall, n=14)) %>%
  mutate(rain_sum_30_2 = rollapply(data=rain.lag2,
                                   width=30,
                                   FUN=sum,
                                   align="right",
                                   fill=NA,
                                   nr.rm=T))

climate.c=climate.c %>%
  mutate(rain.lag3 = lag(daily_rainfall, n=21)) %>%
  mutate(rain_sum_30_3 = rollapply(data=rain.lag3,
                                   width=30,
                                   FUN=sum,
                                   align="right",
                                   fill=NA,
                                   nr.rm=T))

climate.c=climate.c %>%
  mutate(rain.lag4 = lag(daily_rainfall, n=28)) %>%
  mutate(rain_sum_30_4 = rollapply(data=rain.lag4,
                                   width=30,
                                   FUN=sum,
                                   align="right",
                                   fill=NA,
                                   nr.rm=T))
climate.c=climate.c %>%
  mutate(rain.lag30d = lag(daily_rainfall, n=30)) %>%
  mutate(rain_sum_30_30dlag = rollapply(data=rain.lag30d,
                                        width=30,
                                        FUN=sum,
                                        align="right",
                                        fill=NA,
                                        nr.rm=T))


# Kisumu Rain Lags
climate.k<-climate[which(climate$site=="Kisumu"),]
climate.k <- merge(all.dates.frame, climate.k, all.x=T, by=c("date_collected"))
climate.k=climate.k %>%
  group_by(site) %>%
  arrange(site, date_collected) %>%
  mutate(
    rain_sum_30 = rollsum(x = daily_rainfall, 30, align = "right", fill = NA)
  )

climate.k=climate.k %>%
  mutate(rain.lag1 = lag(daily_rainfall, n=7)) %>%
  mutate(rain_sum_30_1 = rollapply(data=rain.lag1,
                                   width=30,
                                   FUN=sum,
                                   align="right",
                                   fill=NA,
                                   nr.rm=T))
climate.k=climate.k %>%
  mutate(rain.lag2 = lag(daily_rainfall, n=14)) %>%
  mutate(rain_sum_30_2 = rollapply(data=rain.lag2,
                                   width=30,
                                   FUN=sum,
                                   align="right",
                                   fill=NA,
                                   nr.rm=T))

climate.k=climate.k %>%
  mutate(rain.lag3 = lag(daily_rainfall, n=21)) %>%
  mutate(rain_sum_30_3 = rollapply(data=rain.lag3,
                                   width=30,
                                   FUN=sum,
                                   align="right",
                                   fill=NA,
                                   nr.rm=T))

climate.k=climate.k %>%
  mutate(rain.lag4 = lag(daily_rainfall, n=28)) %>%
  mutate(rain_sum_30_4 = rollapply(data=rain.lag4,
                                   width=30,
                                   FUN=sum,
                                   align="right",
                                   fill=NA,
                                   nr.rm=T))
climate.k=climate.k %>%
  mutate(rain.lag30d = lag(daily_rainfall, n=30)) %>%
  mutate(rain_sum_30_30dlag = rollapply(data=rain.lag30d,
                                        width=30,
                                        FUN=sum,
                                        align="right",
                                        fill=NA,
                                        nr.rm=T))

#Msambweni Rain Logs
climate.m<-climate[which(climate$site=="Msambweni"),]
climate.m <- merge(all.dates.frame, climate.m, all.x=T, by=c("date_collected"))
climate.m=climate.m %>%
  group_by(site) %>%
  arrange(site, date_collected) %>%
  mutate(
    rain_sum_30 = rollsum(x = daily_rainfall, 30, align = "right", fill = NA)
  )

climate.m=climate.m %>%
  mutate(rain.lag1 = lag(daily_rainfall, n=7)) %>%
  mutate(rain_sum_30_1 = rollapply(data=rain.lag1,
                                   width=30,
                                   FUN=sum,
                                   align="right",
                                   fill=NA,
                                   nr.rm=T))
climate.m=climate.m %>%
  mutate(rain.lag2 = lag(daily_rainfall, n=14)) %>%
  mutate(rain_sum_30_2 = rollapply(data=rain.lag2,
                                   width=30,
                                   FUN=sum,
                                   align="right",
                                   fill=NA,
                                   nr.rm=T))

climate.m=climate.m %>%
  mutate(rain.lag3 = lag(daily_rainfall, n=21)) %>%
  mutate(rain_sum_30_3 = rollapply(data=rain.lag3,
                                   width=30,
                                   FUN=sum,
                                   align="right",
                                   fill=NA,
                                   nr.rm=T))

climate.m=climate.m %>%
  mutate(rain.lag4 = lag(daily_rainfall, n=28)) %>%
  mutate(rain_sum_30_4 = rollapply(data=rain.lag4,
                                   width=30,
                                   FUN=sum,
                                   align="right",
                                   fill=NA,
                                   nr.rm=T))
climate.m=climate.m %>%
  mutate(rain.lag30d = lag(daily_rainfall, n=30)) %>%
  mutate(rain_sum_30_30dlag = rollapply(data=rain.lag30d,
                                        width=30,
                                        FUN=sum,
                                        align="right",
                                        fill=NA,
                                        nr.rm=T))

#Ukunda Rain Lags
climate.u<-climate[which(climate$site=="Ukunda"),]
climate.u <- merge(all.dates.frame, climate.u, all.x=T, by=c("date_collected"))
climate.u=climate.u %>%
  group_by(site) %>%
  arrange(site, date_collected) %>%
  mutate(
    rain_sum_30 = rollsum(x = daily_rainfall, 30, align = "right", fill = NA)
  )

climate.u=climate.u %>%
  mutate(rain.lag1 = lag(daily_rainfall, n=7)) %>%
  mutate(rain_sum_30_1 = rollapply(data=rain.lag1,
                                   width=30,
                                   FUN=sum,
                                   align="right",
                                   fill=NA,
                                   nr.rm=T))
climate.u=climate.u %>%
  mutate(rain.lag2 = lag(daily_rainfall, n=14)) %>%
  mutate(rain_sum_30_2 = rollapply(data=rain.lag2,
                                   width=30,
                                   FUN=sum,
                                   align="right",
                                   fill=NA,
                                   nr.rm=T))

climate.u=climate.u %>%
  mutate(rain.lag3 = lag(daily_rainfall, n=21)) %>%
  mutate(rain_sum_30_3 = rollapply(data=rain.lag3,
                                   width=30,
                                   FUN=sum,
                                   align="right",
                                   fill=NA,
                                   nr.rm=T))

climate.u=climate.u %>%
  mutate(rain.lag4 = lag(daily_rainfall, n=28)) %>%
  mutate(rain_sum_30_4 = rollapply(data=rain.lag4,
                                   width=30,
                                   FUN=sum,
                                   align="right",
                                   fill=NA,
                                   nr.rm=T))
climate.u=climate.u %>%
  mutate(rain.lag30d = lag(daily_rainfall, n=30)) %>%
  mutate(rain_sum_30_30dlag = rollapply(data=rain.lag30d,
                                        width=30,
                                        FUN=sum,
                                        align="right",
                                        fill=NA,
                                        nr.rm=T))





climate<-rbind(climate.c,climate.k,climate.m,climate.u)
rain<-climate[,c("date_collected","daily_rainfall","rainfall_hobo","site","daily_rainfall_long_term_mean", "rain_sum_30", "rain_sum_30_1", "rain_sum_30_2", "rain_sum_30_3", "rain_sum_30_4", "rain_sum_30_30dlag")]

plot(rain$date_collected, round(rain$daily_rainfall), exclude=NULL)



# merge temperature and rain together----------------
temp.long <- merge(all.dates.frame, temp.long, all.x=T, by=c("date_collected"))
climate<-merge(rain, temp.long, by = c("date_collected", "site") )
climate <- climate[which(!is.na(climate$site)), ]

library(ggplot2)
plot(climate$date_collected, climate$meanTemp)
ggplot(data=climate, aes(x=date_collected)) +
  geom_line(aes(y=meanTemp, col=site))
+ labs(title="Temperature across time", subtitle="by site", 
       caption="Source RO1", y="Temperature in Celcius", color=NULL) +
  scale_x_date(labels=lbls, breaks=brks)+
  scale_color_manual(labels = c("Chulaimbo", "Kisumu", "Msambweni", "Ukunda"), 
                     values = c("Chulaimbo"="#00ba38", "Kisumu"="#f8766d")) +  # line color
  theme(axis.text.x = element_text(angle = 90, vjust=0.5, size = 8),  # rotate x axis text
        panel.grid.minor = element_blank())

# plot rolling means and sums over time -----------------------------------
library(ggplot2)
ggplot (climate, aes (x = date_collected, y = temp_mean_30, colour = site)) +geom_line(linetype = "solid",size=2) +scale_x_date(date_breaks = "1 month", date_labels =  "%b %Y") +theme(axis.text.x=element_text(angle=60, hjust=1),legend.position="none",text = element_text(size = 20)) + facet_grid(site ~ .)+xlab("Month-Year") + ylab("Average Temperature (C) in last 30 days") 
ggplot (climate, aes (x = date_collected, y = rain_mean_30, colour = site)) +geom_line(linetype = "solid",size=2) +scale_x_date(date_breaks = "1 month", date_labels =  "%b %Y") +theme(axis.text.x=element_text(angle=60, hjust=1),legend.position="none",text = element_text(size = 20)) + facet_grid(site ~ .)+xlab("Month-Year") + ylab("Cummulative Precipitation (mm) in last 30 days") 

# malaria climate merge-----------------------------------------------------------------
load("aicmalaria.rda")
aicmalaria <- aicmalaria[ , grepl("person_id|redcap_event|id_site|interview_date_aic_A|result_microscopy_malaria_kenya_A|aic_calculated_age_A|temp_A|roof_type_A|latrine_type_A|floor_type_A|drinking_water_source_A|number_windows_A|gender_aic_A|fever_contact_A|mosquito_bites_aic_A|mosquito_net_aic_A|telephone|radio|television|bicycle|motor_vehicle|domestic_worker|poorses|net|report", names(aicmalaria) ) ]
aicmalaria$interview_date_aic_A<-as.Date(aicmalaria$interview_date_aic_A)
malaria_climate<-merge(aicmalaria, climate, by.x = c("interview_date_aic_A","id_site_A"), by.y = c("date_collected","site"), all.x = T) 

malaria_climate <-malaria_climate[ , !grepl("$_D|$_C|$_B|$_F|$_G|$_H" , names(malaria_climate) ) ]
malaria_climate<-malaria_climate[order((grepl('date', names(malaria_climate)))+1L)]
save(malaria_climate, file="malaria_climate.rda") #done 11/5/18
#checking data daterange

dates <- subset(malaria_climate_c, select=c("person_id", "id_site_A", "interview_date_aic_A"))



# fixing some variables--------
malaria_climate$id_site_A<-as.factor(malaria_climate$id_site_A)
malaria_climate$drinking_water_source_A<-as.factor(malaria_climate$drinking_water_source_A)
malaria_climate$gender_aic_A<-as.factor(malaria_climate$gender_aic_A)
malaria_climate$fever_contact_A<-as.factor(malaria_climate$fever_contact_A)
malaria_climate$mosquito_net_aic_A<-as.factor(malaria_climate$mosquito_net_aic_A)

# I am creating a new age category called agecat in 5 year increments
malaria_climate$agecat<- NA
malaria_climate <- within(malaria_climate, agecat[malaria_climate$aic_calculated_age_A>0 & malaria_climate$aic_calculated_age_A<=4] <- 1)
malaria_climate <- within(malaria_climate, agecat[malaria_climate$aic_calculated_age_A>4 & malaria_climate$aic_calculated_age_A<=8] <- 2)
malaria_climate <- within(malaria_climate, agecat[malaria_climate$aic_calculated_age_A>8 & malaria_climate$aic_calculated_age_A<=12] <- 3)
malaria_climate <- within(malaria_climate, agecat[malaria_climate$aic_calculated_age_A>12 & malaria_climate$aic_calculated_age_A<=20] <- 4)
addmargins(table(malaria_climate$agecat))
addmargins(table(malaria_climate$aic_calculated_age_A))
malaria_climate$agecat <- as.factor(malaria_climate$agecat)

#making a complete case analysis for odds ratio estimates from gams. 
malaria_climate<-malaria_climate[complete.cases(malaria_climate[c("result_microscopy_malaria_kenya_A","temp_mean_30_30dlag","rain_sum_30_30dlag","agecat","net","poorses")]), ] 

# making subsets by site--------
malaria_climate_u<-malaria_climate[which(malaria_climate$id_site_A=="Ukunda"),]
malaria_climate_c<-malaria_climate[which(malaria_climate$id_site_A=="Chulaimbo"),]
malaria_climate_k<-malaria_climate[which(malaria_climate$id_site_A=="Kisumu"),]
malaria_climate_m<-malaria_climate[which(malaria_climate$id_site_A=="Msambweni"),]

# Making the plot with Rknot superimposed on our data--------------
# load data
load("malaria_R0.Rsave")
Aedes.R0.out = read.csv("AedesR0Out.csv", header = T)
malaria.R0.out = data.frame("temp" = Aedes.R0.out$temperature, "malaria" = malaria)

malaria_climate$temp_mean_30r <- round(malaria_climate$temp_mean_30)
malaria_climate$temp_mean_30_1r <- round(malaria_climate$temp_mean_30_1)
malaria_climate$temp_mean_30_2r <- round(malaria_climate$temp_mean_30_2)
malaria_climate$temp_mean_30_3r <- round(malaria_climate$temp_mean_30_3)
malaria_climate$temp_mean_30_4r <- round(malaria_climate$temp_mean_30_4)
malaria_climate$temp_mean_30_30dlagr <- round(malaria_climate$temp_mean_30_30dlag)

# summarize malaria positivity by site and temperature
malaria.summary <- ddply(malaria_climate, .(id_site_A, temp_mean_30_30dlagr), summarize, perc.pos = sum(result_microscopy_malaria_kenya_A == 1)/length(result_microscopy_malaria_kenya_A))
malaria.summary <- malaria.summary[complete.cases(malaria.summary),]

# set colors for each site
# color = rep(NA, length=length(malaria.summary$id_site_A))
color = length(malaria.summary$id_site_A)
color[which(malaria.summary$id_site_A=="Chulaimbo")] = "mediumslateblue"
color[which(malaria.summary$id_site_A=="Kisumu")] = "mediumturquoise"
color[which(malaria.summary$id_site_A=="Msambweni")] = "mediumvioletred"
color[which(malaria.summary$id_site_A=="Ukunda")] = "lightsalmon2"
# color_easy = c("mediumslateblue", "mediumturquoise", "mediumvioletred", "lightsalmon2")[malaria.summary$id_site_A]

# set x-limits
minx <- 15
maxx <- 36

# plot
plot(malaria.summary$temp_mean_30_30dlagr, malaria.summary$perc.pos, col=color, pch=16, xlab = expression(paste("Temperature (",degree,"C)")), ylab="Malaria Smear Positivity", xlim = c(minx, maxx), ylim=c(0,1), cex.axis = 1.2, cex.lab = 1.2)
par(new = T)
plot(malaria / max(malaria) ~ temp, xlim = c(minx, maxx), lwd = 2, lty = 1, type = "l", xlab = "", ylab="", main = "", malaria.R0.out, cex.lab = 1.2, col = "black", axes=F)
axis(4, cex.axis = 1.2)
mtext(expression(paste("Relative R"[0])), 4, line = 3, cex = 1.2)
legend("topright", legend=c("Chulaimbo", "Kisumu", "Msambweni", "Ukunda"), col=c("mediumslateblue", "mediumturquoise", "mediumvioletred", "lightsalmon2"), lty=1:1, cex=0.5, bty="n")

# Analysis via GAMS-------------
library(mgcv)
# chulaimbo ------------------------------------------------------------------
gamc<-gam(malaria_climate_c$result_microscopy_malaria_kenya_A~s(temp_mean_30_30dlag,rain_sum_30_30dlag,bs='ts') + agecat + net + poorses, sp=c(2,2), family="binomial", data = malaria_climate_c, method="REML")
summary(gamc, shade=TRUE)#interaction not sig. temp by itself is significant. 
plot(gamc, scale=0, main="Temp Effect on Malaria Transmission",sub="Chulaimbo",ylab="Log odds of Plasmodium Positive Microscopy", xlab="Mean Temperature 30 days prior")
vis.gam(gamc,view = c("temp_mean_30_30dlag","rain_sum_30_30dlag"),color = 'topo',xlab="Temp (C)",ylab="Rain (cm)",plot.type = 'contour',main="Log odds of Malaria Positivity",sub="Chulaimbo")
vis.gam(gamc,view = c("temp_mean_30_30dlag","rain_sum_30_30dlag"),color = 'topo',xlab="Temp (C)",ylab="Rain (cm)",plot.type = 'persp',main="Log odds of Malaria Positivity",sub="Chulaimbo",theta=-50)
library(oddsratio)
summary(malaria_climate_c$temp_mean_30_30dlag)
or_gam(data = malaria_climate_c, model = gamc, pred = "temp_mean_30_30dlag", values = c(23.22,25))#1st quartile to 25.
#not enough data to calculate or for 25+

summary(malaria_climate_c$rain_sum_30_30dlag)
or_gam(data = malaria_climate_c, model = gamc, pred = "rain_sum_30_30dlag", values = c(153,285))#1st quartile to 25.

# kisumu ------------------------------------------------------------------
gamk<-gam(malaria_climate_k$result_microscopy_malaria_kenya_A~s(temp_mean_30_30dlag,rain_sum_30_30dlag,bs='ts') + agecat + net + poorses, sp=c(2,2), family="binomial", data = malaria_climate_k, method="REML")
summary(gamk, shade=TRUE)
plot(gamk, scale=0, main="Temp Effect on Malaria Transmission",sub="Kisumu",ylab="Log odds of Plasmodium Positive Microscopy", xlab="Mean Temperature 30 days prior")
vis.gam(gamk,view = c("temp_mean_30_30dlag","rain_sum_30_30dlag"),color = 'topo',xlab="Temp (C)",ylab="Rain (cm)",plot.type = 'contour',main="Log odds of Malaria Positivity", sub="Kisumu")
vis.gam(gamk,view = c("temp_mean_30_30dlag","rain_sum_30_30dlag"),color = 'topo',xlab="Temp (C)",ylab="Rain (cm)",zlab="Malaria",plot.type = 'persp',theta=50, main="Log odds of Malaria Positivity", sub="Kisumu")

summary(malaria_climate_k$temp_mean_30_30dlag)
#not enough data to calculate 25-
or_gam(data = malaria_climate_k, model = gamk, pred = "temp_mean_30_30dlag",values = c(25,26.66))#or 25+

summary(malaria_climate_k$rain_sum_30_30dlag)
or_gam(data = malaria_climate_k, model = gamk, pred = "rain_sum_30_30dlag",values = c(162,281))#rain 1st to 3rd quartile

# msambweni -----------------------------------------------------------------------
gamm<-gam(result_microscopy_malaria_kenya_A~s(temp_mean_30_30dlag,rain_sum_30_30dlag,bs='ts') +  agecat + net + poorses, sp=c(2,2), family="binomial", data = malaria_climate_m, method="REML")
summary(gamm, shade=TRUE)
gam.check(gamm)
#plot(gamm, scale=0, main="Temp Effect on Malaria Transmission",sub="Msambweni",ylab="Log odds of Plasmodium Positive Microscopy", xlab="Mean Temperature 30 days prior")
vis.gam(gamm,view = c("temp_mean_30_30dlag","rain_sum_30_30dlag"),color = 'topo',xlab="Temp (C)",ylab="Rain (cm)",plot.type = 'contour',main="Log odds of Malaria Positivity",sub="Msambweni")
vis.gam(gamm,view = c("temp_mean_30_30dlag","rain_sum_30_30dlag"),color = 'topo',xlab="Temp (C)",ylab="Rain (cm)",zlab='Malaria',plot.type = 'persp',theta=50,,main="Log odds of Malaria Positivity", sub="Msambweni")

#not enough data to calculate below 25.
summary(malaria_climate_m$temp_mean_30_30dlag)
or_gam(data = malaria_climate_m, model = gamm, pred = "temp_mean_30_30dlag",values = c(25,28.60))#25+

summary(malaria_climate_m$rain_sum_30_30dlag)
or_gam(data = malaria_climate_m, model = gamm, pred = "rain_sum_30_30dlag",values = c(29,156))#rain 1st to 3rd quartile
or_gam(data = malaria_climate_m, model = gamm, pred = "rain_sum_30_30dlag",values = c(100,150))#rain from 100 to 150
or_gam(data = malaria_climate_m, model = gamm, pred = "rain_sum_30_30dlag",values = c(150,200))#rain from 150 to 200

# Ukunda ------------------------------------------------------------------
gamu<-gam(malaria_climate_u$result_microscopy_malaria_kenya_A~s(temp_mean_30_30dlag,rain_sum_30_30dlag,bs='ts')  + agecat + net + poorses, sp=c(2,2), family="binomial", data = malaria_climate_u, method="REML")
summary(gamu, shade=TRUE)#interaction not sig. temp by itself is significant. 
plot(gamu, scale=0, main="Temp Effect on Malaria Transmission",sub="Chulaimbo",ylab="Log odds of Plasmodium Positive Microscopy", xlab="Mean Temperature 30 days prior")

vis.gam(gamu,view = c("temp_mean_30_30dlag","rain_sum_30_30dlag"),color = 'topo',xlab="Temp (C)",ylab="Rain (cm)",plot.type = 'contour',main="Log odds of Malaria Positivity",sub="Ukunda")
vis.gam(gamu,view = c("temp_mean_30_30dlag","rain_sum_30_30dlag"),color = 'topo',xlab="Temp (C)",ylab="Rain (cm)",plot.type = 'persp',main="Log odds of Malaria Positivity",sub="Ukunda",theta=50)
summary(malaria_climate_u$temp_mean_30_30dlag)
or_gam(data = malaria_climate_u, model = gamu, pred = c("temp_mean_30_30dlag"), values=c(25,28.58))#25 to 3rd q.
#not enough data to calculate or for 25-

summary(malaria_climate_c$rain_sum_30_30dlag)
or_gam(data = malaria_climate_c, model = gamc, pred = c("rain_sum_30_30dlag"), values = c(153,285))#1st quartile to 25.

