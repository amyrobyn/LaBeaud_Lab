setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long")

load("R01_lab_results.clean.rda")    
#How often do the kids in HCC have fever in the previous 6 months? All of them? Half?
hist(R01_lab_results$number_illnesses)
summary(R01_lab_results$number_illnesses)

last6months<-NA
R01_lab_results <- within(R01_lab_results, last6months[R01_lab_results$number_illnesses==0] <- 0)
R01_lab_results <- within(R01_lab_results, last6months[R01_lab_results$number_illnesses>0] <- 1)
table(R01_lab_results$last6months)
11794/(2078 +11794) 
