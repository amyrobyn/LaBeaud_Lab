#install.packages("sensitivity")
library(sensitivity)
library(caret)


setwd("C:/Users/amykr/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/redcap reports/rdt vs microscopy")
rdt_micro <- read.csv("R01CHIKVDENVProject_DATA_2017-06-29_1021.csv")
rdt_micro$rdt_results[rdt_micro$rdt_results == "negative"] <- 0
rdt_micro$rdt_results[rdt_micro$rdt_results == "positive"] <- 1
rdt_micro$rdt_results[rdt_micro$rdt_results == ""] <- NA
rdt_micro$rdt_results<-as.integer(rdt_micro$rdt_results)
rdt_micro$rdt_results[rdt_micro$rdt_results == 2] <- 1
rdt_micro$rdt_results[rdt_micro$rdt_results == 3] <- 0
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
