#install.packages(c("REDCapR", "mlr"))
#install.packages(c("dummies"))
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
load("R01_lab_results.backup.rda")
R01_lab_results<-R01_lab_results.backup
R01_lab_results$id_cohort<-substr(R01_lab_results$person_id, 2, 2)
table(R01_lab_results$id_cohort)
R01_lab_results$id_city<-substr(R01_lab_results$person_id, 1, 1)
table(R01_lab_results$id_city)
R01_lab_results$id_visit<-as.integer(factor(R01_lab_results$redcap_event_name))
R01_lab_results$id_visit<-R01_lab_results$id_visit-1
table(R01_lab_results$redcap_event_name, R01_lab_results$id_visit)
symptoms <- R01_lab_results[, grepl("person_id|redcap_event|chikv_stfd_igg|chikv_kenya_igg|denv_kenya_igg|denv_stfd_igg|symptoms|id_c|id_v|visit_type", names(R01_lab_results))]
symptoms <- symptoms[, !grepl("u24|aliquot", names( symptoms ) ) ]
glimpse(symptoms)

#work with symptoms
  symptoms<-R01_lab_results[which(R01_lab_results$id_visit > 0), c("person_id", "redcap_event_name","symptoms", "symptoms_aic", "id_cohort", "id_city", "id_visit", "visit_type")]
#symptoms<-R01_lab_results[which(R01_lab_results$visit > 0), c("person_id", "redcap_event_name","symptoms", "symptoms_aic")]
symptoms<-as.data.frame(symptoms)
table(symptoms$redcap_event_name, symptoms$id_visit)
symptoms$all_symptoms<-paste(symptoms$symptoms, symptoms$symptoms_aic , sep=" ")
symptoms <- lapply(symptoms, function(x) {
  gsub(",NA", "", x)
})
symptoms <- lapply(symptoms, function(x) {
  gsub("NA", "", x)
})
symptoms <- lapply(symptoms, function(x) {
  gsub(",none", "", x)
})
symptoms <- lapply(symptoms, function(x) {
  gsub("none", "", x)
})
symptoms<-as.data.frame(symptoms)

#create dummy vars for all symptoms
symptoms<-as.data.frame(symptoms)
#symptoms <-symptoms[!(is.na(symptoms$all_symptoms) | symptoms$all_symptoms==" "), ]
lev <- levels(factor(symptoms$all_symptoms))
lev <- unique(unlist(strsplit(lev, " ")))
mnames <- gsub(" ", "_", paste("aic_symptom", lev, sep = "_"))
result <- matrix(data = "0", nrow = length(symptoms$all_symptoms), ncol = length(lev))
char.aic_symptom <- as.character(symptoms$all_symptoms)
for (i in 1:length(lev)) {
  result[grep(lev[i], char.aic_symptom, fixed = TRUE), i] <- "1"
}
result <- data.frame(result, stringsAsFactors = TRUE)
colnames(result) <- mnames
symptoms <- cbind(symptoms,result)

as.numeric.factor <- function(x) {as.numeric(levels(x))[x]}
ids <- c("person_id", "redcap_event_name", "symptoms", "symptoms_aic", "id_cohort", "id_city", "id_visit", "all_symptoms", "visit_type")
ids <- symptoms[ids]
symptoms<-symptoms[ , !(names(symptoms) %in% "aic_symptom_")]
aic_symptom_<-grep("aic_symptom_", names(symptoms), value = TRUE)
symptoms<-symptoms[ , (names(symptoms) %in% aic_symptom_)]
symptoms <-as.data.frame(sapply(symptoms, as.numeric.factor))

symptom_sum<-rowSums(symptoms[, grep("\\baic_symptom", names(symptoms))])
table(symptom_sum)
symptoms<-symptoms[ , grepl( "aic_symptom" , names(symptoms) ) ]
symptoms$symptom_sum <- as.integer(rowSums(symptoms[ , grep("aic_symptom" , names(symptoms))]))
table(symptoms$symptom_sum)
symptoms$symptomatic<-NA
symptoms <- within(symptoms, symptomatic[symptoms$symptom_sum>0] <- 1)
symptoms <- within(symptoms, symptomatic[symptoms$symptom_sum==0] <- 0)

#how much of our acute DENV was symptomatic vs. mildly/asymptomatic, etc.
table(symptoms$symptomatic, exclude=NULL)
#export to box.
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/reports")
symptoms<-as.data.frame(cbind(ids, symptoms))

table(symptoms$symptomatic, symptoms$redcap_event_name, symptoms$id_cohort, exclude=NULL)
table(symptoms$symptomatic, symptoms$visit_type, symptoms$id_cohort, exclude=NULL)

table(symptoms$symptomatic, symptoms$visit_type, symptoms$id_cohort, exclude=NULL)

aic_symptoms<-subset(symptoms, id_cohort=="F")
aic_symptoms <-aic_symptoms[!sapply(aic_symptoms, function (x) all(is.na(x) | x == ""))]
#reshape symptoms to wide
#reshape data to wide. 
  aic_symptoms_wide<-reshape(aic_symptoms, direction = "wide", idvar = "person_id", timevar = "redcap_event_name", sep = "_")
  nameVec <- names(aic_symptoms_wide)
  nameVec <- gsub("_patient_informatio_arm_1","_p",nameVec)
  nameVec <- gsub("_arm_1","",nameVec)
  nameVec <- gsub("_visit","",nameVec)
  names(aic_symptoms_wide) <- nameVec


#import wide data from seroconverters function
  setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long")
  R01_lab_results_wide <- readRDS("seroc.rds")
  table(R01_lab_results_wide$cohort_p, exclude=NULL)
aic_R01_lab_results_wide<-subset(R01_lab_results_wide, cohort_p=="1")
aic_R01_lab_results_wide <-aic_R01_lab_results_wide[!sapply(aic_R01_lab_results_wide, function (x) all(is.na(x) | x == ""))]

aic_dummy_symptoms <- merge(aic_R01_lab_results_wide, aic_symptoms_wide,  by=c("person_id"), all = TRUE)
#seroc sum
  aic_dummy_symptoms$chikv_kenya_igg_seroc<-rowSums(aic_dummy_symptoms[, grep("chikv_kenya_igg", names(aic_dummy_symptoms))])
  aic_dummy_symptoms$denv_kenya_igg_seroc<-rowSums(aic_dummy_symptoms[, grep("denv_kenya_igg", names(aic_dummy_symptoms))])
  aic_dummy_symptoms$denv_stfd_igg_seroc<-rowSums(aic_dummy_symptoms[, grep("denv_stfd_igg", names(aic_dummy_symptoms))])
  aic_dummy_symptoms$chikv_stfd_igg_seroc<-rowSums(aic_dummy_symptoms[, grep("chikv_stfd_igg", names(aic_dummy_symptoms))])

#double check to de-identify data
identifiers<-grep("name|gps", names(aic_dummy_symptoms), value = TRUE)
aic_dummy_symptoms_de_identified<-aic_dummy_symptoms[ , !(names(aic_dummy_symptoms) %in% identifiers)]

f <- "aic_dummy_symptoms_de_identified.csv"
write.csv(as.data.frame(aic_dummy_symptoms_de_identified), f )

#symptomatic vs not for seroconveters or pcr positives
#chikv kenya
epitab(aic_dummy_symptoms$symptomatic_a, aic_dummy_symptoms$ab_chikv_kenya_igg)
epitab(aic_dummy_symptoms$symptomatic_b, aic_dummy_symptoms$bc_chikv_kenya_igg)
epitab(aic_dummy_symptoms$symptomatic_c, aic_dummy_symptoms$cd_chikv_kenya_igg)
epitab(aic_dummy_symptoms$symptomatic_d, aic_dummy_symptoms$de_chikv_kenya_igg)
epitab(aic_dummy_symptoms$symptomatic_e, aic_dummy_symptoms$ef_chikv_kenya_igg)
epitab(aic_dummy_symptoms$symptomatic_f, aic_dummy_symptoms$fg_chikv_kenya_igg)
epitab(aic_dummy_symptoms$symptomatic_g, aic_dummy_symptoms$gh_chikv_kenya_igg)

#denv kenya
epitab(aic_dummy_symptoms$symptomatic_a, aic_dummy_symptoms$ab_denv_kenya_igg)
epitab(aic_dummy_symptoms$symptomatic_b, aic_dummy_symptoms$bc_denv_kenya_igg)
epitab(aic_dummy_symptoms$symptomatic_c, aic_dummy_symptoms$cd_denv_kenya_igg)
epitab(aic_dummy_symptoms$symptomatic_d, aic_dummy_symptoms$de_denv_kenya_igg)
epitab(aic_dummy_symptoms$symptomatic_e, aic_dummy_symptoms$ef_denv_kenya_igg)
epitab(aic_dummy_symptoms$symptomatic_f, aic_dummy_symptoms$fg_denv_kenya_igg)
epitab(aic_dummy_symptoms$symptomatic_g, aic_dummy_symptoms$gh_denv_kenya_igg)
#denv stfd
epitab(aic_dummy_symptoms$symptomatic_a, aic_dummy_symptoms$ab_denv_stfd_igg)
epitab(aic_dummy_symptoms$symptomatic_b, aic_dummy_symptoms$bc_denv_stfd_igg)
epitab(aic_dummy_symptoms$symptomatic_c, aic_dummy_symptoms$cd_denv_stfd_igg)
epitab(aic_dummy_symptoms$symptomatic_d, aic_dummy_symptoms$de_denv_stfd_igg)
epitab(aic_dummy_symptoms$symptomatic_e, aic_dummy_symptoms$ef_denv_stfd_igg)
epitab(aic_dummy_symptoms$symptomatic_f, aic_dummy_symptoms$fg_denv_stfd_igg)
epitab(aic_dummy_symptoms$symptomatic_g, aic_dummy_symptoms$gh_denv_stfd_igg)
#chikv stfd
epitab(aic_dummy_symptoms$symptomatic_a, aic_dummy_symptoms$ab_chikv_stfd_igg)
epitab(aic_dummy_symptoms$symptomatic_b, aic_dummy_symptoms$bc_chikv_stfd_igg)
epitab(aic_dummy_symptoms$symptomatic_c, aic_dummy_symptoms$cd_chikv_stfd_igg)
epitab(aic_dummy_symptoms$symptomatic_d, aic_dummy_symptoms$de_chikv_stfd_igg)
epitab(aic_dummy_symptoms$symptomatic_e, aic_dummy_symptoms$ef_chikv_stfd_igg)
epitab(aic_dummy_symptoms$symptomatic_f, aic_dummy_symptoms$fg_chikv_stfd_igg)
epitab(aic_dummy_symptoms$symptomatic_g, aic_dummy_symptoms$gh_chikv_stfd_igg)