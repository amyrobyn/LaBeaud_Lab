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
attach(ds)

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
mom <-mom[!sapply(mom, function (x) all(is.na(x) | x == ""))]

child<-subset(ds, redcap_event_name=="child_arm_1")
child <-child[!sapply(child, function (x) all(is.na(x) | x == ""))]
ds <- merge(mom, child, by="mother_record_id")

#merge with results from preg cohort
preg_cohort <- read.csv("Zika Results.csv")
preg_cohort$ID.Code<-as.factor(preg_cohort$ID.Code)
table(preg_cohort$Results)
names(preg_cohort) <- sub('Symtomatic.Asymtomatic','symptomatic',names(preg_cohort))
names(preg_cohort) <- sub('ï..ID.Code','mom_id_orig_study',names(preg_cohort))
ds <- join(ds, preg_cohort, by='mom_id_orig_study', type='left', match='all')
table(ds$Results, exclude=NULL)


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
ds$symptomatic<-NA
ds <- within(ds, symptomatic[ds$symptom_sum>0] <- 1)
ds <- within(ds, symptomatic[ds$symptom_sum==0] <- 0)
table(ds$symptomatic, exclude=NULL)

table(ds$symptomatic, ds$pregnant) # symptomatic & pregnant n = 7; non-sympomatic & pregnant n = 1

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

#code the results
ds$Randy_code<-NA
ds<-within(ds, Randy_code[ds$Results==  "Presumptive recent Zika virus infection"]<-1)
ds<-within(ds, Randy_code[ds$Results==  "Negative flavivirus/arbovirus infection"]<-2)
ds<-within(ds, Randy_code[ds$Results==  "No evidence of recent flavivirus or arbovirus infection"]<-2)
ds<-within(ds, Randy_code[ds$Results==  "Possible recent flavivirus infection"]<-3)
ds<-within(ds, Randy_code[ds$Results==  "Possible Cross-reactive arboviral IgM "]<-4)
ds<-within(ds, Randy_code[ds$Results==  "Presumptive recent flavivirus infection"]<-5)
ds<-within(ds, Randy_code[ds$Results==  "Possible recent Zika virus infection"]<-6)
ds<-within(ds, Randy_code[ds$Results==  "Possible recent CHIKV infection"]<-7)
table(ds$Randy_code)
ds$Randy_collapsed_code<-ds$Randy_code

ds<-within(ds, Randy_collapsed_code[ds$Randy_code== 1]<-1)
ds<-within(ds, Randy_collapsed_code[ds$Randy_code== 5]<-2)
ds<-within(ds, Randy_collapsed_code[ds$Randy_code== 3]<-3)
ds<-within(ds, Randy_collapsed_code[ds$Randy_code== 4]<-3)
ds<-within(ds, Randy_collapsed_code[ds$Randy_code== 6]<-3)
ds<-within(ds, Randy_collapsed_code[ds$Randy_code== 2]<-4)
ds<-within(ds, Randy_collapsed_code[ds$Randy_code== 7]<-5)
table(ds$Randy_code, ds$Randy_collapsed_code)
table(ds$Results, ds$Randy_code)
table(ds$Results, ds$Randy_collapsed_code, exclude = NULL)

## Create a variable list. Use dput(names(pbc))
vars <- c("mean_weight","mean_length","mean_hc","temperature","heart_rate","resp_rate", "parish","race", "gender", "apgar_one", "apgar_ten", "opv_vaccine", "vac_utd", "color___1", "color___2", "color___3", "color___4", "color___5", "color___6", "cry", "tone", "moving_limbs", "ant_fontanelle", "sutures", "facial_dysmoph", "cleft", "red_reflex", "cap_refill", "heart_sounds", "murmur", "breath_sounds", "breath_noises___1", "breath_noises___2", "breath_noises___3", "breath_noises___0", "breath_noises___99", "resp_effort___0", "resp_effort___1", "resp_effort___2", "resp_effort___99", "bowel_sounds", "hernia", "organomegaly___0", "organomegaly___1", "organomegaly___2", "organomegaly___99", "testes", "patent_anus", "hip_manouver", "hip_creases", "femoral_pulse", "scoliosis", "sacral_dimple", "moro", "grasp", "suck", "plantar_reflex", "galant_reflex", "ever_had_dengue")
table(ds$Results, ds$pregnant, exclude = NULL)
cases<-subset(ds, pregnant=="1" | Results =="Possible recent flavivirus infection"|Results =="Possible Cross-reactive arboviral IgM"|Results =="Possible recent zika virus infection")

## Create Table 1 stratified by trt (omit strata argument for overall table)
tableOne <- CreateTableOne(vars = vars, factorVars = factorVars, strata = "symptomatic", data = cases)
## Just typing the object name will invoke the print.TableOne method
## Tests are by oneway.test/t.test for continuous, chisq.test for categorical
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
attach(ds)
table(ds$Results)
table(Results, symptomatic)
table(pregnant, symptomatic, exclude = NULL)

f <- "zika_grenada_results.csv"
write.csv(as.data.frame(ds), f )