#install.packages("REDCapR")
library(REDCapR)
library(RCurl)
library(dplyr)
library(redcapAPI)
library(rJava) 
library(WriteXLS) # Writing Excel files
library(readxl) # Excel file reading
library(xlsx) # Writing Excel files

setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long")
Redcap.token <- readLines("Redcap.token.R01.txt") # Read API token from folder
REDcap.URL  <- 'https://redcap.stanford.edu/api/'
rcon <- redcapConnection(url=REDcap.URL, token=Redcap.token)


#export data from redcap to R (must be connected via cisco VPN)
R01_lab_results <- redcap_read(
  redcap_uri  = REDcap.URL,
  token       = Redcap.token
)$data

save(R01_lab_results,file=paste("R01_lab_results",Sys.Date(),sep = "_"))
load("R01_lab_results")

aic<-subset(R01_lab_results, redcap_event_name!="patient_informatio_arm_1", select=c(person_id, redcap_event_name, submissiondate:durationhospitalized5))
aic <- Filter(function(aic)!all(is.na(aic)), aic)
aic <- within(aic, version <- NA)
table(aic$version)
demography<-R01_lab_results %>% select(matches(matchExpression))
glimpse(demography)

myVectorOfStrings <- c("person_id", "redcap", "house_number", "child_number")
matchExpression <- paste(myVectorOfStrings, collapse = "|")
house<-R01_lab_results %>% select(matches(matchExpression))
house <- house[ which(house$redcap_event_name =='patient_informatio_arm_1' ), ]
glimpse(house)
table(house$house_number)
table(house$child_number)

setwd("C:/Users/amykr/Box Sync/DENV CHIKV project/West Cleaned/Demography/Demography Latest")
Demography_Data29mar2017 <- read_excel("Demography_Data29mar2017.xls")
glimpse(Demography_Data29mar2017)

# based on variable values
coast <- R01_lab_results[ which(R01_lab_results$site=='1' ), ]

# export data frame to Stata binary format 
library(foreign)
write.csv(coast, file = "coast.csv")
write.table(coast, "coast.txt", sep="\t")
write.dta(coast, "coast.dta")
table(coast$city)
table(coast$result_igg_denv_stfd)
n_distinct(R01_lab_results$person_id, na.rm = FALSE)

#if patient doesn't have form patient information, create the row

patient_information<- subset(R01_lab_results, redcap_event_name == "patient_informatio_arm_1",select = c(person_id, redcap_event_name, cohort, site, city, house_number, child_number, participant_status, patient_information_complete))
glimpse(patient_information)
patient_information <- within(patient_information, site[city==1] <- 2)
patient_information <- within(patient_information, site[city==2] <- 2)
patient_information <- within(patient_information, site[city==3] <- 1)
patient_information <- within(patient_information, site[city==4] <- 1)
glimpse(patient_information)


f <- "no_patient_information.xls"
write.xlsx(as.data.frame(no_patient_information), f, sheetName = "Chulaimbo", col.names = TRUE,
           row.names = FALSE, append = FALSE, showNA = TRUE)


R01_lab_results <- within(R01_lab_results, sample_igg_denv_stfd[!is.na(result_igg_denv_stfd)] <- 1)
R01_lab_results <- within(R01_lab_results, sample_igg_chikv_stfd[!is.na(result_igg_chikv_stfd)] <- 1)
R01_lab_results <- within(R01_lab_results, sample_igg_chikv_kenya[!is.na(result_igg_chikv_kenya)] <- 1)

R01_lab_results <- within(R01_lab_results, sample_igg_denv_kenya[!is.na(result_igg_denv_kenya)] <- 1)


R01_lab_results <- within(R01_lab_results, sample_pcr_denv_kenya[!is.na(result_pcr_denv_kenya)] <- 1)

R01_lab_results <- within(R01_lab_results, sample_pcr_chikv_kenya[!is.na(result_pcr_chikv_kenya)] <- 1)

R01_lab_results <- within(R01_lab_results, sample_pcr_denv_stfd[!is.na(result_pcr_denv_stfd)] <- 1)

R01_lab_results <- within(R01_lab_results, sample_pcr_chikv_stfd[!is.na(result_pcr_chikv_stfd)] <- 1)

R01_lab_results <- within(R01_lab_results, sample_microscopy_malaria_kenya[!is.na(result_microscopy_malaria_kenya)] <- 1)

myVectorOfStrings <- c("person_id", "redcap", "complete", "result")
matchExpression <- paste(myVectorOfStrings, collapse = "|")
form_complete<-R01_lab_results %>% select(matches(matchExpression))

form_complete <- within(form_complete, igg_chikv_kenya_complete[!is.na(result_igg_chikv_kenya)] <- 1)
form_complete <- within(form_complete, igg_chikv_kenya_complete[igg_chikv_kenya_complete==0] <- "")

form_complete <- within(form_complete, igg_denv_kenya_complete[!is.na(result_igg_denv_kenya)] <- 1)
form_complete <- within(form_complete, igg_denv_kenya_complete[igg_denv_kenya_complete==0] <- "")

form_complete <- within(form_complete, igg_denv_stanford_complete[!is.na(result_igg_denv_stfd)] <- 1)
form_complete <- within(form_complete, igg_denv_stanford_complete[igg_denv_stanford_complete==0] <- "")

form_complete <- within(form_complete, igg_chikv_stanford_complete[!is.na(result_igg_chikv_stfd)] <- 1)
form_complete <- within(form_complete, igg_chikv_stanford_complete[igg_chikv_stanford_complete==0] <- "")

form_complete <- within(form_complete, pcr_chikv_stanford_complete[!is.na(result_pcr_chikv_stfd)] <- 1)
form_complete <- within(form_complete, pcr_chikv_stanford_complete[pcr_chikv_stanford_complete==0] <- "")

form_complete <- within(form_complete, pcr_denv_stanford_complete[!is.na(result_pcr_denv_stfd)] <- 1)
form_complete <- within(form_complete, pcr_denv_stanford_complete[pcr_denv_stanford_complete==0] <- "")

form_complete <- within(form_complete, microscopy_malaria_kenya_complete[!is.na(result_microscopy_malaria_kenya)] <- 1)
form_complete <- within(form_complete, microscopy_malaria_kenya_complete[microscopy_malaria_kenya_complete==0] <- "")

form_complete2 <- form_complete[c ("person_id", "redcap_event_name","microscopy_malaria_kenya_complete","pcr_denv_stanford_complete" , "pcr_chikv_stanford_complete", "igg_chikv_stanford_complete", "igg_denv_stanford_complete", "igg_denv_kenya_complete", "igg_chikv_kenya_complete") ] 

## S3 method for class 'redcapApiConnection' THis method will require reformatting all the dates to meet redcap standards.
importRecords(rcon, aic, overwriteBehavior = "overwrite", returnContent = c("count", "ids", "nothing"), 
              returnData = FALSE, logfile = "", proj = NULL,
              batch.size = -1)
