#install.packages(c("REDCapR", "mlr"))
#install.packages(c("dummies"))
library(redcapAPI)
library(REDCapR)

setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long")
Redcap.token <- readLines("Redcap.token.R01.txt") # Read API token from folder
#Redcap.token <- "82F1C4081DEF007B8D4DE287426046E1"
REDcap.URL  <- 'https://redcap.stanford.edu/api/'
rcon <- redcapConnection(url=REDcap.URL, token=Redcap.token)

#export data from redcap to R (must be connected via cisco VPN)
#R01_lab_results <- redcap_read(redcap_uri  = REDcap.URL, token = Redcap.token, batch_size = 300)$data
#R01_lab_results.backup<-R01_lab_results
R01_lab_results<-R01_lab_results.backup
R01_lab_results$id_cohort<-substr(R01_lab_results$person_id, 2, 2)
table(R01_lab_results$id_cohort)
R01_lab_results$id_city<-substr(R01_lab_results$person_id, 1, 1)
table(R01_lab_results$id_city)
R01_lab_results$id_visit<-as.integer(factor(R01_lab_results$redcap_event_name))
R01_lab_results$id_visit<-R01_lab_results$id_visit-1
table(R01_lab_results$redcap_event_name, R01_lab_results$id_visit)

symptoms<-R01_lab_results[which(R01_lab_results$visit > 0), c("person_id", "redcap_event_name","symptoms", "symptoms_aic", "id_cohort", "id_city", "id_visit")]
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
mnames <- gsub(" ", "_", paste("aic_symptom", lev, sep = "."))
result <- matrix(data = "0", nrow = length(symptoms$all_symptoms), ncol = length(lev))
char.aic_symptom <- as.character(symptoms$all_symptoms)
for (i in 1:length(lev)) {
  result[grep(lev[i], char.aic_symptom, fixed = TRUE), i] <- "1"
}
result <- data.frame(result, stringsAsFactors = TRUE)
colnames(result) <- mnames
symptoms <- cbind(symptoms,result)

as.numeric.factor <- function(x) {as.numeric(levels(x))[x]}
symptoms<-symptoms[c(1:8, 10:42)]

symptoms[, c(9:41)] <- sapply(symptoms[, c(9:41)], as.numeric.factor)

attach(symptoms)
symptom_sum<-rowSums(symptoms[, grep("\\baic_symptom", names(symptoms))])
table(symptom_sum)
symptoms<-symptoms[ , grepl( "aic_symptom" , names(symptoms) ) ]
symptoms$symptom_sum <- as.integer(rowSums(symptoms[ , grep("aic_symptom" , names(symptoms))]))
table(symptoms$symptom_sum)

symptoms$symptomatic<-NA
symptoms <- within(symptoms, symptomatic[symptoms$symptom_sum>0] <- 1)
symptoms <- within(symptoms, symptomatic[symptoms$symptom_sum==0] <- 0)
table(symptoms$symptomatic, exclude=NULL)

