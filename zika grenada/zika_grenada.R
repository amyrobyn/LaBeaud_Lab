# packages ----------------------------------------------------------------
library(tableone)
library(REDCapR)
# get data ----------------------------------------------------------------

setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/zika study- grenada")
Redcap.token <- readLines("Redcap.token.zika.txt") # Read API token from folder
REDcap.URL  <- 'https://redcap.stanford.edu/api/'
#ds <- redcap_read(  redcap_uri  = REDcap.URL,  token   = Redcap.token,  batch_size = 100)$data
table(ds$redcap_event_name)
# #split data into mom and child then remerge by id ----------------------------------------------------------------
mom<-subset(ds, redcap_event_name=="mother_arm_1")
mom <- Filter(function(mom)!all(is.na(mom)), mom)

child<-subset(ds, redcap_event_name=="child_arm_1")
child <- Filter(function(child)!all(is.na(child)), child)
total <- merge(mom, child, by="mother_record_id")
table(total$redcap_event_name.x)
table(total$redcap_event_name.y)

# pregnant and symptomatic ------------------------------------------------
# what the child outcomes were in asymptomatic and symptomatic pregnant cases. 
#By child outcome I mean child anthropometrics and PE findings.
total$symptom_sum <- as.integer(rowSums(total[ , grep("symptoms___" , names(total))]))
table(total$symptom_sum)

table(total$preg_f.x)
table(total$pregnant)
total$pregnant_cat<-ifelse(is.na(total$preg_f.x),1,total$pregnant)
table(total$pregnant_cat)

total <- within(total, symptomatic[total$symptom_sum>0] <- 1)
total <- within(total, symptomatic[total$symptom_sum==0] <- 0)
table(total$symptomatic, total$pregnant) # symptomatic & pregnant n = 31; non-sympomatic & pregnant n = 2
table(total$symptomatic, total$pregnant_cat) # symptomatic & pregnant n = 31; non-sympomatic & pregnant n = 2
table(total$symptomatic) # symptomatic & pregnant n = 7; non-sympomatic & pregnant n = 1
table(total$pregnant) # symptomatic & pregnant n = 7; non-sympomatic & pregnant n = 1
table(total$pregnant) # symptomatic & pregnant n = 7; non-sympomatic & pregnant n = 1
table(total$trimester)

library(expss)
cro(total$pregnant, total$trimester)
cro_cpct(total$trimester, list(total()))

# pgold results baby -----------------------------------------------------------
cro(total$result_zikv_igg_pgold.y)
(3/388)*100
cro(total$result_denv_igg_pgold.y)
(31/388)*100
cro(total$result_denv_igg_pgold.y,total$result_zikv_igg_pgold.y)

# microcephaly ------------------------------------------------------------
total$microcephaly <- ifelse(total$zhc < -3.0, 2, ifelse(total$zhc < -2.0, 1, 0))
table(total$microcephaly)

# pcr moms ----------------------------------------------------------------
total$result_denv_pcr_mom<-NA
total <- within(total, result_denv_pcr_mom[total$result_denv_urine_mom==0] <- 0)
total <- within(total, result_denv_pcr_mom[total$result_denv_serum_mom==0] <- 0)
total <- within(total, result_denv_pcr_mom[total$result_denv_urine_mom==1] <- 1)
total <- within(total, result_denv_pcr_mom[total$result_denv_serum_mom==1] <- 1)
cro(total$result_denv_pcr_mom)
cro(total$result_denv_pcr_mom, total$symptomatic)


# pgold moms ----------------------------------------------------------------
cro(total$result_zikv_igg_pgold.x)
cro(total$result_denv_igg_pgold.x)
cro(total$result_denv_igg_pgold.x,total$result_zikv_igg_pgold.x)

cro(total$result_zikv_igg_pgold.x)
cro(total$result_denv_igg_pgold.x)

cro(total$result_denv_pcr_mom, total$result_denv_igg_pgold.x)

cro(total$result_denv_pcr_mom, total$result_denv_igg_pgold.x)

cro(result_avidity_zikv_igg_pgold)
cro(result_avidity_denv_igg_pgold)


# mother baby exopsure ----------------------------------------------------
cro(total$result_zikv_igg_pgold.x,total$result_zikv_igg_pgold.y)

cro(total$result_denv_igg_pgold.x,total$result_denv_igg_pgold.y)





# old code not used. ----------------------------------------------------


## List numerically coded categorical variables
total$parish<-as.factor(total$parish)
total$race<-as.factor(total$race)
total$race<-as.factor(total$gender)
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

cases<-subset(total, pregnant=="1")
## Create Table 1 stratified by trt (omit strata argument for overall table)
tableOne <- CreateTableOne(vars = vars, factorVars = factorVars, strata = "symptomatic", data = cases)
## Just typing the object name will invoke the print.TableOne method
## Tests are by oneway.test/t.test for continuous, chisq.test for categorical
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
table(total$hospitalized_chikv)
table(total$hospitalized_dengue)

#we don't have have the mtct lab results yet. can't do this. 

#For Aim 2, we will test whether the MTCT for asymptomatic ZIKV infected mothers 
#is different from that for symptomatic mothers by testing for a difference in binomial proportions.  
#Assuming 250 (50%) of the 500 of the pregnant women will be ZIKV infected, 
#20% of whom will be symptomatic with an estimated 50% MTCT rate, we will have power of 90% to detect 
#a difference if the rate is 25% for asymptomatic mothers and 75% if the rate is 30% for asymptomatics.
write.csv(total, "total.csv")