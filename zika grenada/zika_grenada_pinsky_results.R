#install.packages(c("REDCapR", "tableone")
library(data.table)
library(tableone)
library(plyr)
library(REDCapR)
library(lubridate)
library(ggplot2)
library(plotly)


setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/zika study- grenada")
ds<-read.csv("ZikaPregnancyCohort_DATA_2018-01-09_1651 (1).csv")


#split data into mom and child then remerge by id
mom<-subset(ds, redcap_event_name=="mother_arm_1")
mom <- Filter(function(mom)!all(is.na(mom)), mom)

child<-subset(ds, redcap_event_name=="child_arm_1")
child <- Filter(function(child)!all(is.na(child)), child)

#women --------------------------------------------------------------
table(mom$cohort___1)#321 preg women
table(mom$cohort___2)#190 febrile women
table(mom$cohort___3)#388 moms in follow up

#women in both cohorts
table(mom$cohort___1,mom$cohort___3)#125 women in both  pregnancy and follow up cohorts
table(mom$cohort___2,mom$cohort___3)#30 women in both  febrile and follow up cohorts


#mom zika outcome. pcr positive by pinsky.
mom$zika_pcr_pos<-NA
mom$result_zikv_serum_mom
mom <- within(mom, zika_pcr_pos[mom$result_zikv_serum_mom  ==0] <- 0)
mom <- within(mom, zika_pcr_pos[mom$result_zikv_urine_mom  ==0] <- 0)
#mom <- within(mom, zika_pcr_pos[mom$denv_ct==0] <- 0)

mom <- within(mom, zika_pcr_pos[mom$result_zikv_serum_mom  ==1] <- 1)
mom <- within(mom, zika_pcr_pos[mom$result_zikv_urine_mom  ==1] <- 1)
#mom <- within(mom, zika_pcr_pos[mom$denv_ct>0] <- 1)
table(mom$zika_pcr_pos)  

#baby's we followed up
table(child$redcap_event_name)#388 children

#how many had fever during preg
table(mom$cohort___1,mom$cohort___2)#1 woman in both febrile and pregnancy cohorts
#-how many zika during preg. zika = pcr pos. serum\urine.
table(mom$zika_pcr_pos,mom$cohort___1)  #7 zikv pcr positives. 4 were in pregnancy cohort.
table(mom$zika_pcr_pos,mom$cohort___2)  #3 zikv pcr positives. 4 were in febrile cohort.
table(mom$zika_pcr_pos,mom$cohort___3)  #4 zikv pcr positives. 4 were in followup cohort.
#-microcephalic kid. look up mom. 
weianthro<-read.table("C:/Users/amykr/Documents/GitHub/igrowup_R//weianthro.txt",header=T,sep="",skip=0)
lenanthro<-read.table("C:/Users/amykr/Documents/GitHub/igrowup_R//lenanthro.txt",header=T,sep="",skip=0)
bmianthro<-read.table("C:/Users/amykr/Documents/GitHub/igrowup_R//bmianthro.txt",header=T,sep="",skip=0)
hcanthro<-read.table("C:/Users/amykr/Documents/GitHub/igrowup_R//hcanthro.txt",header=T,sep="",skip=0)
acanthro<-read.table("C:/Users/amykr/Documents/GitHub/igrowup_R//acanthro.txt",header=T,sep="",skip=0)
ssanthro<-read.table("C:/Users/amykr/Documents/GitHub/igrowup_R//ssanthro.txt",header=T,sep="",skip=0)
tsanthro<-read.table("C:/Users/amykr/Documents/GitHub/igrowup_R//tsanthro.txt",header=T,sep="",skip=0)
wflanthro<-read.table("C:/Users/amykr/Documents/GitHub/igrowup_R//wflanthro.txt",header=T,sep="",skip=0)
wfhanthro<-read.table("C:/Users/amykr/Documents/GitHub/igrowup_R//wfhanthro.txt",header=T,sep="",skip=0)
source("C:/Users/amykr/Documents/GitHub/igrowup_R//igrowup_standard.r")

child$measure="L"
igrowup.standard(FilePath="C:/Users/amykr/Box Sync/Amy Krystosik's Files/zika study- grenada/igrowup", FileLab="anthro-z-scores", mydf=child, sex=gender, age=child_calculated_age, age.month=T, weight=mean_weight,lenhei=mean_length,measure=measure,headc=mean_hc)
child<-read.csv("C:/Users/amykr/Box Sync/Amy Krystosik's Files/zika study- grenada/igrowup/anthro-z-scores_z_st.csv")

ds <- merge(mom, child, by="mother_record_id")
ds$microcephaly<-NA
ds <- within(ds, microcephaly[zhc >= -2] <- "none")
ds <- within(ds, microcephaly[zhc < -2] <- "mild")
ds <- within(ds, microcephaly[zhc < -3] <- "severe")
table(ds$microcephaly)

# table one children ------------------------------------------------------
library("tableone")
vars <- c("zika_pcr_pos","ever_had_zikv","zika_diag","zika_diag_preg","pregnant","confirmed_blood_test","trimester","child_calculated_age","gender","mean_hc")
factorVars <- c("zika_pcr_pos","ever_had_zikv","zika_diag","zika_diag_preg","pregnant","confirmed_blood_test","trimester","gender")
microcephaly_table<-CreateTableOne(vars = vars, factorVars = factorVars, strata = "microcephaly", data = ds)

table_one<-CreateTableOne(vars = vars, factorVars = factorVars, data = ds)
(7/151)*100

# flowchart ---------------------------------------------------------------
library("DiagrammeR")#install.packages("DiagrammeR")

mermaid("
  graph TB;
        A(Pregnancy<br> Cohort)-->B(321)
        C(Febrile Cohort)-->D(190<br> xx%preg)
        D(190<br> xx%preg)--> F(30 Pregnant<br> women<br> 4 PCR ZIKV +)
        B(321)--> E(125 Followed up<br> 3 PCR ZIKV +)
        E(125 Followed up<br> 3 PCR ZIKV +)-->G(383 moms) 
        F(30 Pregnant<br> women)-->G(383 moms) 
        I(228<br> new moms)-->G(383 moms) 
        G(383 moms)-->h(388 babys<br> enrolled)
        h(388 babys<br> enrolled)-->K(23 severe<br> microcephally)
        h(388 babys<br> enrolled)-->L(35 mild<br> microcephally)
        K(23 severe<br> microcephally)-->O(2 diagnosed with<br> Zika virus infection<br> during this pregnancy)
        ")    


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
## Tests are by oneway.test\t.test for continuous, chisq.test for categorical
tableOne
tableOne$CatTable
summary(tableOne)
print(tableOne, 
      nonnormal = c("mean_weight","mean_length","mean_hc","temperature","heart_rate","resp_rate",  "neonatal_resusitation", "cong_abnormal",  "maternal_resusitation", "child_referred",  "apgar_one", "apgar_ten"),
      exact = c("ever_had_dengue", "parish","race", "gender",  "child_delivery", "delivery_type", "outcome_of_delivery",  "opv_vaccine", "vac_utd", "color___1", "color___2", "color___3", "color___4", "color___5", "color___6", "cry", "tone", "moving_limbs", "ant_fontanelle", "sutures", "facial_dysmoph", "cleft", "red_reflex", "cap_refill", "heart_sounds", "murmur", "breath_sounds", "bowel_sounds", "hernia", "color___1", "color___2", "color___3", "color___4", "color___5", "color___6",  "breath_noises___1", "breath_noises___2", "breath_noises___3", "breath_noises___0", "breath_noises___99", "resp_effort___0", "resp_effort___1", "resp_effort___2", "resp_effort___99",  "organomegaly___0", "organomegaly___1", "organomegaly___2", "organomegaly___99",  "testes",  "patent_anus", "hip_manouver", "hip_creases", "femoral_pulse", "scoliosis", "sacral_dimple", "moro", "grasp", "suck", "plantar_reflex", "galant_reflex"),
      cramVars = "neonatal_resusitation, cong_abnormal,  maternal_resusitation, child_referred,  opv_vaccine, vac_utd, color___1, color___2, color___3, color___4, color___5, color___6,  breath_noises___1, breath_noises___2, breath_noises___3, breath_noises___0, breath_noises___99, resp_effort___0, resp_effort___1, resp_effort___2, resp_effort___99,  organomegaly___0, organomegaly___1, organomegaly___2, organomegaly___99", quote = TRUE)


#i don't have the variable for "hospitalization due to ZIKV and\or Guillain-Barré syndrome"

#)1. The primary goal is to understand host factors associated with severe ZIKV disease
#(defined as hospitalization due to ZIKV and\or Guillain-Barré syndrome) and factors associated with MTCT of ZIKV. 
#We will first investigate bivariate relationships for each potential predictor of ZIKV disease severity
#within and between measurement domains (demographic, physical, asymptomatic\symptomatic disease and DENV exposure variables). 
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
