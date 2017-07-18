#install.packages("REDCapR")
library(tidyr)
library(dplyr)
library(tableone)
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
#Redcap.token <- "82F1C4081DEF007B8D4DE287426046E1"
REDcap.URL  <- 'https://redcap.stanford.edu/api/'
rcon <- redcapConnection(url=REDcap.URL, token=Redcap.token)

#export data from redcap to R (must be connected via cisco VPN)
R01_lab_results <- redcap_read(
  redcap_uri  = REDcap.URL,
  token       = Redcap.token,
  batch_size = 300
)$data


R01_lab_results$cohort_id<-substr(R01_lab_results$person_id, 2, 2)

funny_ids<-subset(R01_lab_results, R01_lab_results$cohort_id=="0"|R01_lab_results$cohort_id=="D"|R01_lab_results$cohort_id=="M")
funny_ids <-funny_ids[!sapply(funny_ids, function (x) all(is.na(x) | x == ""| x == "NA"))]
f <- "funny_ids.csv"
write.csv(as.data.frame(funny_ids), f )

data<-subset(R01_lab_results, R01_lab_results$cohort_id!="0" & R01_lab_results$cohort_id!="D" & R01_lab_results$cohort_id!="M")

data$visit<-NA
data <- within(data, visit <- 1)

data$time<-NA
data <- within(data, time [redcap_event_name=="patient_informatio_arm_1"]<- NA)
data <- within(data, time [redcap_event_name=="visit_a_arm_1"]<- 1)
data <- within(data, time [redcap_event_name=="visit_b_arm_1"]<- 2)
data <- within(data, time [redcap_event_name=="visit_c_arm_1"]<- 3)
data <- within(data, time [redcap_event_name=="visit_d_arm_1"]<- 4)
data <- within(data, time [redcap_event_name=="visit_e_arm_1"]<- 5)
table(data$time)
class(data$time)

table(R01_lab_results$cohort_id)
table(data$cohort_id)
glimpse(data)


aic<-subset(data, cohort_id == "F")
hcc<-subset(data, cohort_id == "C")

table(aic$site)
table(aic$cohort)
table(hcc$redcap_event_name)
table(R01_lab_results$redcap_event_name)
table(hcc$site)
table(hcc$cohort)
vars <- c("site", "city", "visit_type", "follow_up_visit_num", "redcap_event_name", "gender", "gender_aic", "age_calc", "pedsql_agegroup")
factorVars <- c("site", "city", "visit_type", "follow_up_visit_num", "redcap_event_name", "gender", "gender_aic", "pedsql_agegroup")
data$visit_type<-as.factor(data$visit_type)
table(data$cohort)
table(data$cohort_id)

table(R01_lab_results$visit_type)
table(R01_lab_results$follow_up_visit_num)

## Create Table 1 stratified by trt (omit strata argument for overall table)
tableOne <- CreateTableOne(vars = vars, factorVars = factorVars, strata = "cohort_id", data = data)
print(tableOne, quote = TRUE)


# based on variable values
coast <- R01_lab_results[ which(R01_lab_results$site=='1' ), ]
table(coast$city)
table(coast$result_igg_denv_stfd)
n_distinct(coast$person_id, na.rm = FALSE)



west <- R01_lab_results[ which(R01_lab_results$site=='2' ), ]
table(west$city)
table(west$result_igg_denv_stfd)
n_distinct(west$person_id, west$cohort, na.rm = FALSE)



#survival
library(survival)
library(dplyr)
library(OIsurv) # Aumatically loads KMsurv
library(ranger)
library(ggplot2)

table(hcc$participant_status, hcc$redcap_event_name)

table(hcc$visit)
table(hcc$redcap_event_name)
class(hcc$time)
class(hcc$visit)

library(survival)
data$visit
data$event
data$time
table(data$time)
table(data$visit)

plot(survfit(Surv(time, visit) ~ 1, data=data), 
     conf.int=FALSE, mark.time=FALSE)

y_hcc <- Surv(hcc$time, hcc$visit)
fit1_hcc <- survfit(y_hcc~ 1)
summary(fit1_hcc)

cb <- confBands(y_hcc, type = "hall")
plot(fit1_hcc,
     main = 'Kaplan Meyer Plot of HCC participant visits')
lines(cb, col = "red",lty = 3)
legend(1000, 0.99, legend = c('K-M survival estimate',
                              'pointwise intervals', 'Hall-Werner conf bands'), lty = 1:3)

table(R01_lab_results$hcc_participant)
R01_lab_results$pedsql_agegroup
