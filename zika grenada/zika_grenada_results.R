#install.packages(c("REDCapR", "tableone")
library(data.table)
library(tableone)
library(plyr)
library(REDCapR)
library(lubridate)
library(ggplot2)
library(plotly)

setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/zika study- grenada")
Redcap.token <- readLines("Redcap.token.zika.txt") # Read API token from folder
REDcap.URL  <- 'https://redcap.stanford.edu/api/'


#export data from redcap to R (must be connected via cisco VPN)
ds <- redcap_read(
  redcap_uri  = REDcap.URL,
  token       = Redcap.token
)$data
#if result is missing, replace exposed with missing.
  ds <- within(ds, exposed[is.na(result)] <- NA)
#if exposed by navy testing ==1, confirmed by blood test == 1 
  ds <- within(ds, confirmed_blood_test[ds$exposed==1] <- 1)
  ds <- within(ds, exposed[ds$confirmed_blood_test==1] <- 1)
#if reported as having chikv during pregnancy, exposed ==1
  ds <- within(ds, exposed[ds$pregnant==1] <- 1)
  
#delivery data and zika outbreak dates
  delivery_date <- ymd(as.character(ds$delivery_date ))
  delivery_date[ds$delivery_date=="2007-01-15"]<-"2017-01-15"
  prenancy_date<-ds$delivery_date - 280
  
  duration <- 280
  zika_start<- ymd(as.character("2016-06-12"))
  zika_end <- ymd(as.character("2016-10-01"))
#export to csv  
  f <- "REDCap_export_aug30.csv"
  write.csv(as.data.frame(ds), f )

#split data into mom and child then remerge by id
  mom<-subset(ds, redcap_event_name=="mother_arm_1")
  mom <-mom[!sapply(mom, function (x) all(is.na(x) | x == ""))]
  
  child<-subset(ds, redcap_event_name=="child_arm_1")
  child <-child[!sapply(child, function (x) all(is.na(x) | x == ""))]
  ds <- merge(mom, child, by="mother_record_id")


#We will want to know how many kids were Zika exposed (8/206. 7/8 confirmed) 
  table(ds$ever_had_zikv, ds$confirmed_blood_test)
  table(ds$pregnant, ds$confirmed_blood_test) #kids were Zika exposed (8/206. 7/8 confirmed) 

# what the child outcomes were in asymptomatic and symptomatic pregnant cases. 
#By child outcome I mean child anthropometrics and PE findings.
  symptom_sum<-rowSums(ds[, grep("\\bsymptoms___.", names(ds))])
  table(symptom_sum)
  symptoms<-ds[ , grepl( "symptoms___" , names(ds) ) ]
  ds$symptom_sum <- as.integer(rowSums(ds[ , grep("symptoms___" , names(ds))]))
  ds$symptomatic<-NA
  ds <- within(ds, symptomatic[ds$symptom_sum>0] <- 1)
  ds <- within(ds, symptomatic[ds$symptom_sum==0] <- 0)
  table(ds$symptomatic, exclude=NULL)
  
  table(ds$symtomatic_asymtomatic, ds$pregnant) # symptomatic & pregnant n = 7; non-sympomatic & pregnant n = 1
  table(ds$symptomatic, ds$pregnant) # symptomatic & pregnant n = 7; non-sympomatic & pregnant n = 1
  ds$symptomatic_both<-NA
  ds <- within(ds, symptomatic_both[ds$symptomatic==1] <- 1)
  ds <- within(ds, symptomatic_both[ds$symtomatic_asymtomatic==1] <- 1)
  table(ds$symptomatic_both,ds$pregnant, exclude = NULL) #15 symptomatic total (naval or reporting symptoms) and 11 during pregnancy, 1 not pregnant, 3 not reporting.
  
## List numerically coded categorical variables
ds$parish<-as.factor(ds$parish)
ds$race<-as.factor(ds$race)
ds$race<-as.factor(ds$gender)
table(ds$exposed, ds$pregnant, exclude = NULL)
table(ds$pregnant, exclude = NULL)
table(ds$exposed, exclude = NULL)
table(ds$confirmed_blood_test, ds$pregnant, exclude = NULL)
table(ds$pregnant, exclude = NULL)
table(ds$confirmed_blood_test, exclude = NULL)

#cases<-subset(ds, pregnant=="1" | !is.na(exposed))

## Create a variable list. Use dput(names(pbc))
vars <- c("pregnant","confirmed_blood_test","mean_weight","mean_length","mean_hc","temperature","heart_rate","resp_rate", "parish","race", "gender", "apgar_one", "apgar_ten", "opv_vaccine", "vac_utd", "color___1", "color___2", "color___3", "color___4", "color___5", "color___6", "cry", "tone", "moving_limbs", "ant_fontanelle", "sutures", "facial_dysmoph", "cleft", "red_reflex", "cap_refill", "heart_sounds", "murmur", "breath_sounds", "breath_noises___1", "breath_noises___2", "breath_noises___3", "breath_noises___0", "breath_noises___99", "resp_effort___0", "resp_effort___1", "resp_effort___2", "resp_effort___99", "bowel_sounds", "hernia", "organomegaly___0", "organomegaly___1", "organomegaly___2", "organomegaly___99", "testes", "patent_anus", "hip_manouver", "hip_creases", "femoral_pulse", "scoliosis", "sacral_dimple", "moro", "grasp", "suck", "plantar_reflex", "galant_reflex", "ever_had_dengue")
factorVars <- c("pregnant","parish","race", "gender",  "child_delivery", "delivery_type", "outcome_of_delivery",
                "opv_vaccine", "vac_utd", 
                "color___1", "color___2", "color___3", "color___4", "color___5", "color___6",
                "cry", "tone", "moving_limbs", "ant_fontanelle", "sutures", "facial_dysmoph", "cleft",
                "red_reflex", "cap_refill", "heart_sounds", "murmur", "breath_sounds", "bowel_sounds", 
                "hernia", 
                "breath_noises___1", "breath_noises___2", "breath_noises___3", "breath_noises___0", 
                "breath_noises___99", "resp_effort___0", "resp_effort___1", "resp_effort___2", 
                "resp_effort___99",  "organomegaly___0", "organomegaly___1", "organomegaly___2", 
                "organomegaly___99",  "testes",  "patent_anus", "hip_manouver", "hip_creases", 
                "femoral_pulse", "scoliosis", "sacral_dimple", "moro", "grasp", "suck", "plantar_reflex", 
                "galant_reflex")

## Create Table 1 stratified by trt (omit strata argument for overall table)
tableOne <- CreateTableOne(vars = vars, factorVars = factorVars, strata = "exposed", data = ds)
## Just typing the object name will invoke the print.TableOne method
## Tests are by oneway.test/t.test for continuous, chisq.test for categorical
print(tableOne, 
      nonnormal = c("mean_weight","mean_length","mean_hc","temperature","heart_rate","resp_rate",  "neonatal_resusitation", "cong_abnormal",  "maternal_resusitation", "child_referred",  "apgar_one", "apgar_ten"),
      exact = c("confirmed_blood_test","ever_had_dengue", "parish","race", "gender",  "child_delivery", "delivery_type", "outcome_of_delivery",  "opv_vaccine", "vac_utd", "color___1", "color___2", "color___3", "color___4", "color___5", "color___6", "cry", "tone", "moving_limbs", "ant_fontanelle", "sutures", "facial_dysmoph", "cleft", "red_reflex", "cap_refill", "heart_sounds", "murmur", "breath_sounds", "bowel_sounds", "hernia", "color___1", "color___2", "color___3", "color___4", "color___5", "color___6",  "breath_noises___1", "breath_noises___2", "breath_noises___3", "breath_noises___0", "breath_noises___99", "resp_effort___0", "resp_effort___1", "resp_effort___2", "resp_effort___99",  "organomegaly___0", "organomegaly___1", "organomegaly___2", "organomegaly___99",  "testes",  "patent_anus", "hip_manouver", "hip_creases", "femoral_pulse", "scoliosis", "sacral_dimple", "moro", "grasp", "suck", "plantar_reflex", "galant_reflex"),
      cramVars = "neonatal_resusitation, pregnant ,cong_abnormal,  maternal_resusitation, child_referred,  opv_vaccine, vac_utd, color___1, color___2, color___3, color___4, color___5, color___6,  breath_noises___1, breath_noises___2, breath_noises___3, breath_noises___0, breath_noises___99, resp_effort___0, resp_effort___1, resp_effort___2, resp_effort___99,  organomegaly___0, organomegaly___1, organomegaly___2, organomegaly___99", quote = TRUE)


#i don't have the variable for "hospitalization due to ZIKV and/or Guillain-Barré syndrome"

#)1. The primary goal is to understand host factors associated with severe ZIKV disease
#(defined as hospitalization due to ZIKV and/or Guillain-Barré syndrome) and factors associated with MTCT of ZIKV. 
#We will first investigate bivariate relationships for each potential predictor of ZIKV disease severity
#within and between measurement domains (demographic, physical, asymptomatic/symptomatic disease and DENV exposure variables). 
#Multilevel modeling (MLM)[72] will be used to adjust for the effects of multiple host factors. 
#All tests will be two-sided and performed at significance level 0.05. 
#We will test for differences in binomial proportion, use chi-square tests for categorical predictors, and simple logistic regression for numeric predictors.
table(ds$hospitalized_chikv)
table(ds$hospitalized_denv)

#we don't have have the mtct lab results yet. can't do this. 

#For Aim 2, we will test whether the MTCT for asymptomatic ZIKV infected mothers 
#is different from that for symptomatic mothers by testing for a difference in binomial proportions.  
#Assuming 250 (50%) of the 500 of the pregnant women will be ZIKV infected, 
#20% of whom will be symptomatic with an estimated 50% MTCT rate, we will have power of 90% to detect 
#a difference if the rate is 25% for asymptomatic mothers and 75% if the rate is 30% for asymptomatics.

f <- "zika_grenada_results.csv"
write.csv(as.data.frame(ds), f )