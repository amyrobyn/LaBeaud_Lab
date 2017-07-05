#install.packages("sensitivity")
library(sensitivity)
library(caret)
library("tibble")

setwd("C:/Users/amykr/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/redcap reports/rdt vs microscopy")
rdt_micro <- read.csv("R01CHIKVDENVProject_DATA_2017-06-29_1021.csv")
glimpse(rdt_micro)
rdt_micro$hospital<-substr(rdt_micro$person_id, 1, 1)
rdt_micro$hospital[rdt_micro$hospital == "C"] <- "Chulaimbo"
rdt_micro$hospital[rdt_micro$hospital == "G"] <- "Msambweni"
rdt_micro$hospital[rdt_micro$hospital == "K"] <- "Kisumu"
rdt_micro$hospital[rdt_micro$hospital == "L"] <- "Msambweni"
rdt_micro$hospital[rdt_micro$hospital == "M"] <- "Msambweni"
rdt_micro$hospital[rdt_micro$hospital == "R"] <- "Chulaimbo"
rdt_micro$hospital[rdt_micro$hospital == "U"] <- "Ukunda"
table(rdt_micro$hospital)

table(rdt_micro$rdt_results)
rdt_micro$rdt_results[rdt_micro$rdt_results == "negative"] <- 0
rdt_micro$rdt_results[rdt_micro$rdt_results == "positive"] <- 1
rdt_micro$rdt_results[rdt_micro$rdt_results == ""] <- NA
rdt_micro$rdt_results[rdt_micro$rdt_results == "5"] <- NA
rdt_micro$rdt_results<-as.integer(rdt_micro$rdt_results)
table(rdt_micro$rdt_results, rdt_micro$hospital)
rdt_micro$rdt_results[rdt_micro$rdt_results == 2] <- 0
rdt_micro$rdt_results[rdt_micro$rdt_results == 3] <- 1
rdt_micro$rdt_results[rdt_micro$rdt_results == 4] <- NA
table(rdt_micro$rdt_results, exclude=NULL)


#convert to factor for sensitivity packages
rdt_micro$rdt_results[rdt_micro$rdt_results == 1] <- "positive"
rdt_micro$rdt_results[rdt_micro$rdt_results == 0] <- "negative"
rdt_micro$rdt_results<-as.factor(rdt_micro$rdt_results)

rdt_micro$result_microscopy_malaria_kenya[rdt_micro$result_microscopy_malaria_kenya == 1] <- "positive"
rdt_micro$result_microscopy_malaria_kenya[rdt_micro$result_microscopy_malaria_kenya == 0] <- "negative"
rdt_micro$result_microscopy_malaria_kenya<-as.factor(rdt_micro$result_microscopy_malaria_kenya)

#create vectors of true and predicted values
truth<-rdt_micro$result_microscopy_malaria_kenya
predicted<-rdt_micro$rdt_results

table(rdt_micro$rdt_results, rdt_micro$result_microscopy_malaria_kenya, exclude=NULL) #table of predicted (RDT) and true (microscopy) values 
table(predicted, truth,  exclude=NULL) #table of predicted (RDT) and true (microscopy) values 

confusionMatrix(predicted,truth,  positive="positive")

#read about the functions here: 
?confusionMatrix

table(truth)

#by site
Ukunda_truth<-subset(rdt_micro$result_microscopy_malaria_kenya, rdt_micro$hospital == "Ukunda")
Ukunda_predicted<-subset(rdt_micro$rdt_results, rdt_micro$hospital == "Ukunda")
confusionMatrix(Ukunda_predicted, Ukunda_truth,  positive="positive")


Chulaimbo_truth<-subset(rdt_micro$result_microscopy_malaria_kenya, rdt_micro$hospital == "Chulaimbo")
Chulaimbo_predicted<-subset(rdt_micro$rdt_results, rdt_micro$hospital =="Chulaimbo")
confusionMatrix(Chulaimbo_predicted, Chulaimbo_truth,  positive="positive")


Msambweni_truth<-subset(rdt_micro$result_microscopy_malaria_kenya, rdt_micro$hospital == "Msambweni")
Msambweni_predicted<-subset(rdt_micro$rdt_results, rdt_micro$hospital =="Msambweni")
confusionMatrix(Msambweni_predicted, Msambweni_truth,  positive="positive")


Kisumu_truth<-subset(rdt_micro$result_microscopy_malaria_kenya, rdt_micro$hospital == "Kisumu")
Kisumu_predicted<-subset(rdt_micro$rdt_results, rdt_micro$hospital =="Kisumu")
confusionMatrix(Kisumu_predicted, Kisumu_truth,  positive="positive")

table(rdt_micro$hospital)