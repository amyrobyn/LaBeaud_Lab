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
#ds <- redcap_read(  redcap_uri  = REDcap.URL,  token   = Redcap.token,  batch_size = 100)$data
attach(ds)
preg_cohort<-ds
#preg_cohort <- read.csv("Zika Results .csv")
preg_cohort$ID.Code<-as.factor(preg_cohort$ID.Code)
preg_cohort$mom_id_orig_study
table(preg_cohort$interpreted_colors.1)

merged<-data.table(ds, key="mom_id_orig_study")[
  data.table(preg_cohort, key="ID.Code"),
  allow.cartesian=TRUE
  ]

delivery_date <- ymd(as.character(ds$delivery_date ))
delivery_date[ds$delivery_date=="2007-01-15"]<-"2017-01-15"
prenancy_date<-ds$delivery_date - 280

duration <- 280
zika_start<- ymd(as.character("2016-06-12"))
zika_end <- ymd(as.character("2016-10-01"))

f <- "REDCap_export_june19.csv"
write.csv(as.data.frame(ds), f )
table(redcap_event_name)
#split data into mom and child then remerge by id
mom<-subset(ds, redcap_event_name=="mother_arm_1")
mom <- Filter(function(mom)!all(is.na(mom)), mom)

child<-subset(ds, redcap_event_name=="child_arm_1")
child <- Filter(function(child)!all(is.na(child)), child)
total <- merge(mom, child, by="mother_record_id")
ds<-total
attach(ds)
#We will want to know how many kids were Zika exposed (8/206. 7/8 confirmed) 
table(ever_had_zikv, confirmed_blood_test)
table(pregnant, confirmed_blood_test) #kids were Zika exposed (8/206. 7/8 confirmed) 

# what the child outcomes were in asymptomatic and symptomatic pregnant cases. 
#By child outcome I mean child anthropometrics and PE findings.
symptom_sum<-rowSums(ds[, grep("\\bsymptoms___.", names(ds))])
table(symptom_sum)
symptoms<-ds[ , grepl( "symptoms___" , names(ds) ) ]
ds$symptom_sum <- as.integer(rowSums(ds[ , grep("symptoms___" , names(ds))]))
table(ds$symptom_sum)

symptomatic<-NA
ds <- within(ds, symptomatic[ds$symptom_sum>0] <- 1)
ds <- within(ds, symptomatic[ds$symptom_sum==0] <- 0)
table(ds$symptomatic, ds$pregnant) # symptomatic & pregnant n = 7; non-sympomatic & pregnant n = 1
t<-with(ds, table(ds$symptomatic, ds$pregnant))
t <- prop.table(t, margin = 1)
t
write.table(t, file = "test.txt", sep = ",", quote = FALSE, row.names = F)

## List numerically coded categorical variables
ds$parish<-as.factor(ds$parish)
ds$race<-as.factor(ds$race)
ds$race<-as.factor(ds$gender)
factorVars <- c("parish","race", "gender",  "child_delivery", "delivery_type", "outcome_of_delivery",
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

## Create a variable list. Use dput(names(pbc))
vars <- c("mean_weight","mean_length","mean_hc","temperature","heart_rate","resp_rate", "parish","race", "gender", "apgar_one", "apgar_ten", "opv_vaccine", "vac_utd",  "temperature", "heart_rate", "resp_rate", "color___1", "color___2", "color___3", "color___4", "color___5", "color___6", "cry", "tone", "moving_limbs", "ant_fontanelle", "sutures", "facial_dysmoph", "cleft", "red_reflex", "cap_refill", "heart_sounds", "murmur", "breath_sounds", "breath_noises___1", "breath_noises___2", "breath_noises___3", "breath_noises___0", "breath_noises___99", "resp_effort___0", "resp_effort___1", "resp_effort___2", "resp_effort___99", "bowel_sounds", "hernia", "organomegaly___0", "organomegaly___1", "organomegaly___2", "organomegaly___99", "testes", "patent_anus", "hip_manouver", "hip_creases", "femoral_pulse", "scoliosis", "sacral_dimple", "moro", "grasp", "suck", "plantar_reflex", "galant_reflex", "ever_had_dengue")

cases<-subset(ds, pregnant=="1")
## Create Table 1 stratified by trt (omit strata argument for overall table)
tableOne <- CreateTableOne(vars = vars, factorVars = factorVars, strata = "symptomatic", data = cases)
## Just typing the object name will invoke the print.TableOne method
## Tests are by oneway.test/t.test for continuous, chisq.test for categorical
tableOne
tableOne$CatTable
summary(tableOne)
print(tableOne, 
      nonnormal = c("mean_weight","mean_length","mean_hc","temperature","heart_rate","resp_rate",  "neonatal_resusitation", "cong_abnormal",  "maternal_resusitation", "child_referred",  "apgar_one", "apgar_ten"),
      exact = c("ever_had_dengue", "parish","race", "gender",  "child_delivery", "delivery_type", "outcome_of_delivery",  "opv_vaccine", "vac_utd", "color___1", "color___2", "color___3", "color___4", "color___5", "color___6", "cry", "tone", "moving_limbs", "ant_fontanelle", "sutures", "facial_dysmoph", "cleft", "red_reflex", "cap_refill", "heart_sounds", "murmur", "breath_sounds", "bowel_sounds", "hernia", "color___1", "color___2", "color___3", "color___4", "color___5", "color___6",  "breath_noises___1", "breath_noises___2", "breath_noises___3", "breath_noises___0", "breath_noises___99", "resp_effort___0", "resp_effort___1", "resp_effort___2", "resp_effort___99",  "organomegaly___0", "organomegaly___1", "organomegaly___2", "organomegaly___99",  "testes",  "patent_anus", "hip_manouver", "hip_creases", "femoral_pulse", "scoliosis", "sacral_dimple", "moro", "grasp", "suck", "plantar_reflex", "galant_reflex"),
      cramVars = "neonatal_resusitation, cong_abnormal,  maternal_resusitation, child_referred,  opv_vaccine, vac_utd, color___1, color___2, color___3, color___4, color___5, color___6,  breath_noises___1, breath_noises___2, breath_noises___3, breath_noises___0, breath_noises___99, resp_effort___0, resp_effort___1, resp_effort___2, resp_effort___99,  organomegaly___0, organomegaly___1, organomegaly___2, organomegaly___99", quote = TRUE)


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
                                                                                                                                                                                                   
f <- "ds.csv"
write.csv(as.data.frame(ds), f )


tetracore
pos
maybe
neg
