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
#ds <- redcap_read(  redcap_uri  = REDcap.URL,   token       = Redcap.token)$data
ds<-read.csv("C:/Users/amykr/Box Sync/Amy Krystosik's Files/zika study- grenada/ZikaPregnancyCohort_DATA_2017-12-06_2217.csv",na.strings=c(""," ","NA"))
# #delivery data and zika outbreak dates ----------------------------------
  ds$delivery_date <- ymd(as.character(ds$delivery_date ))
  ds$delivery_date[ds$delivery_date=="2007-01-15"]<-"2017-01-15"
  ds$prenancy_date<-ds$delivery_date - 280
  
  zika_start<- ymd(as.character("2016-06-12"))
  zika_end <- ymd(as.character("2016-10-01"))


# exposure cats -----------------------------------------------------------
#define the unknown first
  #if result is missing, replace exposed with missing.
    ds <- within(ds, exposed[(is.na(result)|is.na(exposed)|is.na(exposed_2)|exposed_2==99|exposed==99)] <- 98)
#then define negative
  #if exposed by navy testing ==1, confirmed by blood test == 1 
  ds <- within(ds, exposed[ds$confirmed_blood_test==0] <- 0)
  ds <- within(ds, confirmed_blood_test[is.na(exposed==0)|is.na(exposed_2)==0] <- 0)
    table(ds$confirmed_blood_test)
    #if reported as having chikv during pregnancy, exposed ==1
    ds <- within(ds, exposed[ds$pregnant==0] <- 0)
  #ever had zika
    ds <- within(ds, exposed[ds$ever_had_zikv==0] <- 0)
  #pregnant during outbreak
    ds <- within(ds, exposed[ds$delivery_date<zika_start | ds$delivery_date>zika_end] <- 0)
    
#then define positive  
  #if exposed by navy testing ==1, confirmed by blood test == 1 
    ds <- within(ds, exposed[ds$confirmed_blood_test==1] <- 1)
    ds <- within(ds, confirmed_blood_test[!is.na(ds$result)|!is.na(ds$igm_result_urine)] <- 1)
    ds <- within(ds, exposed[ds$exposed_2==1] <- 1)
  #if reported as having chikv during pregnancy, exposed ==1
    ds <- within(ds, exposed[ds$pregnant==1] <- 1)
  #ever had zika
    ds <- within(ds, exposed[ds$ever_had_zikv==1] <- 1)
#pregnant during outbreak
  ds <- within(ds, exposed[ds$delivery_date>zika_start & ds$delivery_date<zika_end  ] <- 1)
  table(ds$exposed, exclude = NULL)
  
# #split data into mom and child then remerge by id -----------------------
  mom<-subset(ds, redcap_event_name=="mother_arm_1")
  mom <-mom[!sapply(mom, function (x) all(is.na(x)))]


  child<-subset(ds, redcap_event_name=="child_arm_1")
  child <-child[!sapply(child, function (x) all(is.na(x)))]
  child<-child[ , !grepl( "exposed" , names(child) ) ]
  ds <- merge(mom, child, by="mother_record_id", all = TRUE)
  table(ds$exposed)
  #initial zika symtpoms
  
  ds[ds==99]<-NA
  ds$symptom_sum_initial<-rowSums(ds[, grep("symptoms_zika___", names(ds))])
  table(ds$symptom_sum_initial)
  x=rnorm(100)
  opar=par(ps=25)
  hist(ds$symptom_sum_initial[ds$symptom_sum_initial!=0], breaks=36,xlab = "Symptom sum at initial survey", main = "Distribution at initial survey \n total number of symptoms")
  
  ds$symptom_sum_fu<-rowSums(ds[, grep("symptoms___", names(ds))])
  table(ds$symptom_sum_fu)
  hist(ds$symptom_sum_fu[ds$symptom_sum_fu!=0], breaks=36,xlab = "Symptom sum at follow up survey", main = "Distribution at follow-up survey \n Total number of symptoms")


  
# symptoms zika -----------------------------------------------------------
  # tables ------------------------------------------------------------------
  vars_symptoms<-c("symptoms_zika___1"	, "symptoms_zika___2",	"symptoms_zika___3",	"symptoms_zika___4",	"symptoms_zika___5",	"symptoms_zika___6",	"symptoms_zika___7",	"symptoms_zika___8",	"symptoms_zika___9",	"symptoms_zika___10",	"symptoms_zika___11",	"symptoms_zika___12",	"symptoms_zika___13",	"symptoms_zika___14",	"symptoms_zika___15",	"symptoms_zika___16",	"symptoms_zika___17",	"symptoms_zika___18",	"symptoms_zika___19",	"symptoms_zika___98",	"symptoms_zika___", "symptoms___1",	"symptoms___2",	"symptoms___3",	"symptoms___4",	"symptoms___5",	"symptoms___6",	"symptoms___7",	"symptoms___8",	"symptoms___9",	"symptoms___10",	"symptoms___11",	"symptoms___12",	"symptoms___13",	"symptoms___14",	"symptoms___15",	"symptoms___16",	"symptoms___17",	"symptoms___18",	"symptoms___19",	"symptoms___20",	"symptoms___21",	"symptoms___22",	"symptoms___23",	"symptoms___24",	"symptoms___25",	"symptoms___26",	"symptoms___27",	"symptoms___28",	"symptoms___29",	"symptoms___30",	"symptoms___31",	"symptoms___32",	"symptoms___33",	"symptoms___34"	)
  table1_symptoms <- CreateTableOne(vars = vars_symptoms, data = ds)
  table1_symptoms
  
  #graphs
  
  
  symptoms_conv<-ds[ , grepl("mother_record_id|symptoms___", names(ds)) ]
  symptoms_conv<-symptoms_conv[ , !grepl("know|chik|denv", names(symptoms_conv)) ]
  names(symptoms_conv)
  
  symptoms_long<-reshape(symptoms_conv, direction = "long", idvar = c("redcap_event_name.y"), sep = "_", varying = 2:35, timevar = "symptom", times = 1:34, v.names="symptoms___")
  table(symptoms_long$symptom)
  
  
  symptoms_long$symptom[symptoms_long$symptom == "1"] <- "Fever"
  symptoms_long$symptom[symptoms_long$symptom == "2"] <- "Chills"
  symptoms_long$symptom[symptoms_long$symptom == "3"] <- "Generalized body ache"
  symptoms_long$symptom[symptoms_long$symptom == "4"] <- "Joint pains"
  symptoms_long$symptom[symptoms_long$symptom == "5"] <- "Muscle pains"
  symptoms_long$symptom[symptoms_long$symptom == "6"] <- "Bone pains"
  symptoms_long$symptom[symptoms_long$symptom == "7"] <- "Itchiness"
  symptoms_long$symptom[symptoms_long$symptom == "8"] <- "Headache"
  symptoms_long$symptom[symptoms_long$symptom == "9"] <- "Pain behind the eyes"
  symptoms_long$symptom[symptoms_long$symptom == "10"] <- "Dizziness"
  symptoms_long$symptom[symptoms_long$symptom == "11"] <- "Eyes sensitive to light"
  symptoms_long$symptom[symptoms_long$symptom == "12"] <- "Stiff neck"
  symptoms_long$symptom[symptoms_long$symptom == "13"] <- "Red eyes"
  symptoms_long$symptom[symptoms_long$symptom == "14"] <- "Runny nose"
  symptoms_long$symptom[symptoms_long$symptom == "15"] <- "Earache"
  symptoms_long$symptom[symptoms_long$symptom == "16"] <- "Sore throat"
  symptoms_long$symptom[symptoms_long$symptom == "17"] <- "Cough"
  symptoms_long$symptom[symptoms_long$symptom == "18"] <- "Shortness of breath"
  symptoms_long$symptom[symptoms_long$symptom == "19"] <- "Loss of appetite"
  symptoms_long$symptom[symptoms_long$symptom == "20"] <- "Funny taste in mouth"
  symptoms_long$symptom[symptoms_long$symptom == "21"] <- "Nausea"
  symptoms_long$symptom[symptoms_long$symptom == "22"] <- "Vomiting"
  symptoms_long$symptom[symptoms_long$symptom == "23"] <- "Diarrhea"
  symptoms_long$symptom[symptoms_long$symptom == "24"] <- "Abdominal pain"
  symptoms_long$symptom[symptoms_long$symptom == "25"] <- "Vomiting"
  symptoms_long$symptom[symptoms_long$symptom == "26"] <- "Rash"
  symptoms_long$symptom[symptoms_long$symptom == "27"] <- "Bloody nose"
  symptoms_long$symptom[symptoms_long$symptom == "28"] <- "Bleeding gums"
  symptoms_long$symptom[symptoms_long$symptom == "29"] <- "Bloody stools"
  symptoms_long$symptom[symptoms_long$symptom == "30"] <- "Bloody vomit"
  symptoms_long$symptom[symptoms_long$symptom == "31"] <- "Bruises"
  symptoms_long$symptom[symptoms_long$symptom == "32"] <- "Impaired mental status"
  symptoms_long$symptom[symptoms_long$symptom == "33"] <- "Seizures"
  symptoms_long$symptom[symptoms_long$symptom == "34"] <- "Hand weakness"
  
  table(symptoms_long$symptom, symptoms_long$symptoms___)
  
  
  
  symptoms_long_sum <-symptoms_long %>% 
    group_by(symptom) %>% 
    summarise(
      symptom_freq = mean(symptoms___),
      symptom_sd = sd(symptoms___),
      symptom_n= n(),
      symptom_error=symptom_sd/symptom_n ,
      lower=symptom_freq-(symptom_error*1.96),
      upper=symptom_freq+(symptom_error*1.96)
    )
  
  #install.packages("ggrepel")
  library("ggrepel")
  
  p<-ggplot(symptoms_long_sum, aes(x = symptom, y = symptom_freq, fill=symptom)) +
    geom_point()+
    geom_bar(data = symptoms_long_sum, stat = "identity", alpha = .3) +
    geom_errorbar(aes(ymin=lower, ymax=upper), width=.2) +
    geom_point() +
    guides(color = "none", fill = "none") +
    theme_bw() +
    labs(
      title = "Frequecy of symptoms in cohort",
      x = "Symptom",
      y = "Frequency"
    )
  p+theme(axis.text=element_text(size=25,face="bold"),
          axis.title=element_text(size=25,face="bold"))+ scale_y_continuous(labels = scales::percent) +theme(axis.text.x=element_text(angle = -90, hjust = 0))
  
  
  ds2<-read.csv("C:/Users/amykr/Box Sync/Amy Krystosik's Files/zika study- grenada/inital zika survey.csv",na.strings=c(""," ","NA"))
  ds2<-ds
  ds2<-ds2[ , -which(names(ds2) %in% c("symptoms_zika___"))]
  table(ds2$symptoms_zika___1)
  symptoms_init<-ds2[ , grepl("mother_record_id|symptoms_zika___", names(ds2)) ]
  names(symptoms_init)
  
  symptoms_long_init<-reshape(symptoms_init, direction = "long", idvar = c("redcap_event_name.y"), sep = "_", varying = 2:21, timevar = "symptom", times = c(1:19, 98), v.names="symptoms_zika___")
  table(symptoms_long_init$symptom, symptoms_long_init$symptoms_zika___)
  
  symptoms_long_init$symptom[symptoms_long_init$symptom == "1"] <- "Fever"
  symptoms_long_init$symptom[symptoms_long_init$symptom == "2"] <- "Conjuntivitis"
  symptoms_long_init$symptom[symptoms_long_init$symptom == "3"] <- "Chills"
  symptoms_long_init$symptom[symptoms_long_init$symptom == "4"] <- "Sick Feeling"
  symptoms_long_init$symptom[symptoms_long_init$symptom == "5"] <- "Generalized Body Ache"
  symptoms_long_init$symptom[symptoms_long_init$symptom == "6"] <- "Joint Pains"
  symptoms_long_init$symptom[symptoms_long_init$symptom == "7"] <- "Muscle Pains"
  symptoms_long_init$symptom[symptoms_long_init$symptom == "8"] <- "Bone Pains"
  symptoms_long_init$symptom[symptoms_long_init$symptom == "9"] <- "Itchiness"
  symptoms_long_init$symptom[symptoms_long_init$symptom == "10"] <- "Headache"
  symptoms_long_init$symptom[symptoms_long_init$symptom == "11"] <- "Pain Behind the Eyes"
  symptoms_long_init$symptom[symptoms_long_init$symptom == "12"] <- "Swollen lymph nodes"
  symptoms_long_init$symptom[symptoms_long_init$symptom == "13"] <- "Dizziness"
  symptoms_long_init$symptom[symptoms_long_init$symptom == "14"] <- "Eyes Sensitive to Light"
  symptoms_long_init$symptom[symptoms_long_init$symptom == "15"] <- "Stiff Neck"
  symptoms_long_init$symptom[symptoms_long_init$symptom == "16"] <- "Red Eyes"
  symptoms_long_init$symptom[symptoms_long_init$symptom == "17"] <- "Rash"
  symptoms_long_init$symptom[symptoms_long_init$symptom == "18"] <- "Hand weakness"
  symptoms_long_init$symptom[symptoms_long_init$symptom == "19"] <- "Seizures"
  symptoms_long_init$symptom[symptoms_long_init$symptom == "98"] <- "Other"
  
  table(symptoms_long_init$symptoms_zika___, symptoms_long_init$symptom)
  
  symptoms_long_init_init_sum <-symptoms_long_init %>% 
    group_by(symptom) %>% 
    summarise(
      symptom_freq = mean(symptoms_zika___),
      symptom_sd = sd(symptoms_zika___),
      symptom_n= n(),
      symptom_error=symptom_sd/symptom_n ,
      lower=symptom_freq-(symptom_error*1.96),
      upper=symptom_freq+(symptom_error*1.96)
    )
  
  symptoms_long_init_init_sum
  
  p<-ggplot(symptoms_long_init_init_sum, aes(x = symptom, y = symptom_freq, fill=symptom, na.rm = TRUE)) +
    geom_point()+
    geom_bar(data = symptoms_long_init_init_sum, stat = "identity", alpha = .3) +
    geom_errorbar(aes(ymin=lower, ymax=upper), width=.2) +
    geom_point() +
    guides(color = "none", fill = "none") +
    theme_bw() +
    labs(
      title = "Frequecy of symptoms in cohort",
      x = "Symptom",
      y = "Frequency"
    )
  p+theme(axis.text=element_text(size=25,face="bold"),
          axis.title=element_text(size=25,face="bold"))+ scale_y_continuous(labels = scales::percent) +theme(axis.text.x=element_text(angle = -90, hjust = 0))
  
  
  
  
  
# keep only fu cohort -----------------------------------------------------------
  ds<- ds[which(ds$cohort___3==1)  , ]#keep only those in fu
  table(ds$redcap_repeat_instance)  

#We will want to know how many kids were Zika exposed (8/206. 7/8 confirmed) 
  table(ds$ever_had_zikv, ds$confirmed_blood_test)
  table(ds$pregnant, ds$confirmed_blood_test) #kids were Zika exposed (8/206. 7/8 confirmed) 

# what the child outcomes were in asymptomatic and symptomatic pregnant cases. 
#By child outcome I mean child anthropometrics and PE findings.

  ds$symptom_sum<-rowSums(ds[, grep("symptoms___|symptoms_zika", names(ds))])
  table(ds$symptom_sum)

  hist(ds$symptom_sum, breaks = 11)
  table
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
ds[ds==99]<-NA
table(ds$plantar_reflex)

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

## Create Table 1 stratified by exposure
tableOne <- CreateTableOne(vars = vars, factorVars = factorVars, data = ds)
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
