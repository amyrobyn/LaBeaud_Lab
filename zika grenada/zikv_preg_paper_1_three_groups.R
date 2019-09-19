### packages
library(REDCapR)
library(tidyr)
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/zika study- grenada")

# load data -------------------------------------------------------------------
Redcap.token <- readLines("Redcap.token.zika.txt") # Read API token from folder
REDcap.URL  <- 'https://redcap.stanford.edu/api/'
#ds <- redcap_read(  redcap_uri  = REDcap.URL, token = Redcap.token,  batch_size = 100,raw_or_label="label")$data
currentDate <- Sys.Date() 
FileName <- paste("zika",currentDate,".rda",sep=" ") 
#save(ds,file=FileName)

load("zika 2019-08-28 .rda")
#load(FileName)
ds<-dplyr::filter(ds, !grepl("--",mother_record_id))

# merge -------------------------------------------------------------------
library(dplyr)
dataMoms <- ds[ds$redcap_event_name=="Mother",]
dataMoms <- Filter(function(x)!all(is.na(x)), dataMoms)
colnames(dataMoms) <- paste(colnames(dataMoms),"mom", sep = ".")
names(dataMoms)[names(dataMoms) == 'mother_record_id.mom'] <- 'mother_record_id'
names(dataMoms)[names(dataMoms) == 'redcap_repeat_instance.mom'] <- 'redcap_repeat_instance'
datainfant <- ds[ds$redcap_event_name=="Child post partum",]
datainfant <- Filter(function(x)!all(is.na(x)), datainfant)
colnames(datainfant) <- paste(colnames(datainfant),"pn", sep = ".")
names(datainfant)[names(datainfant) == 'mother_record_id.pn'] <- 'mother_record_id'
names(datainfant)[names(datainfant) == 'redcap_repeat_instance.pn'] <- 'redcap_repeat_instance'

data12 <- ds[ds$redcap_event_name=="12m fu",]
data12 <- Filter(function(x)!all(is.na(x)), data12)
colnames(data12) <- paste(colnames(data12),"12", sep = ".")
names(data12)[names(data12) == 'mother_record_id.12'] <- 'mother_record_id'
names(data12)[names(data12) == 'redcap_repeat_instance.12'] <- 'redcap_repeat_instance'

data24 <- ds[ds$redcap_event_name=="24m fu",]
data24 <- Filter(function(x)!all(is.na(x)), data24)
colnames(data24) <- paste(colnames(data24),"24", sep = ".")
names(data24)[names(data24) == 'mother_record_id.24'] <- 'mother_record_id'
names(data24)[names(data24) == 'redcap_repeat_instance.24'] <- 'redcap_repeat_instance'

data27 <- ds[ds$redcap_event_name=="27m fu",]
data27 <- Filter(function(x)!all(is.na(x)), data27)
colnames(data27) <- paste(colnames(data27),"27", sep = ".")
names(data27)[names(data27) == 'mother_record_id.27'] <- 'mother_record_id'
names(data27)[names(data27) == 'redcap_repeat_instance.27'] <- 'redcap_repeat_instance'

data30 <- ds[ds$redcap_event_name=="30m fu",]
data30 <- Filter(function(x)!all(is.na(x)), data30)
colnames(data30) <- paste(colnames(data30),"30", sep = ".")
names(data30)[names(data30) == 'mother_record_id.30'] <- 'mother_record_id'
names(data30)[names(data30) == 'redcap_repeat_instance.30'] <- 'redcap_repeat_instance'

child <- merge(datainfant, data12, by = c("mother_record_id","redcap_repeat_instance"), all.x=T)
child <- merge(child, data24, by = c("mother_record_id","redcap_repeat_instance"), all.x=T)
child <- merge(child, data24, by = c("mother_record_id","redcap_repeat_instance"), all.x=T)

#child <- merge(child, data27, by = c("mother_record_id","redcap_repeat_instance"), all.x=T)
#child <- merge(child, data30, by = c("mother_record_id","redcap_repeat_instance"), all.x=T)
ds2 <- merge(dataMoms, child, by = "mother_record_id", suffixes = c("",""))
ds2[ds2==""]<-NA

write.csv(ds2[,grepl("mother_record_id|mom_id_orig_study|redcap_repeat_instance|redcap_event_name|pgold",colnames(ds2))],"pgold_testing.csv",na="")
ds2602<-ds2[ds2$mom_id_orig_study_2.mom==2602&!is.na(ds2$mom_id_orig_study_2.mom),c("date.mom","mother_record_id","mom_id_orig_study_2.mom")]

deidentify<-ds
write.csv(deidentify,"zikv.csv")

# #make sure the child # didn't change over visits. -------------------------------------------------------------------
twin_ids<-ds[ds$redcap_repeat_instance>1&!is.na(ds$redcap_repeat_instance),"mother_record_id"]
twins<-subset(ds, (c(mother_record_id) %in% twin_ids))
twins<-twins[,grepl("name|mother_record_id|redcap_repeat_instance|redcap_event_name",colnames(twins))]
twins<-twins[,grepl("child|mother_record_id|redcap_repeat_instance|redcap_event_name",colnames(twins))]
twins<-tidyr::unite(twins, child_surname, child_surname,child_surname_2, sep='')
twins<-tidyr::unite(twins, child_firstname, child_firstname,child_firstname_2, sep='')
twins<-tidyr::unite(twins, child_secondname, child_secondname,child_secondname_2, sep='')
twins<-twins[twins$redcap_event_name!="mother_arm_1",]

# subset to vars we use-------------------------------------------------------------------
ds2 <- Filter(function(x)!all(is.na(x)), ds2)
ds2 <- Filter(function(x)!all(x==""), ds2)

# tables -------------------------------------------------------------------
#zikv exposure
    ds2$pcr_positive_zikv_mom<-NA
    ds2 <- within(ds2, pcr_positive_zikv_mom[ds2$result_zikv_urine_mom.mom=="Negative"|ds2$result_zikv_serum_mom.mom=="Negative"] <- "Negative")
    ds2 <- within(ds2, pcr_positive_zikv_mom[ds2$result_zikv_urine_mom.mom=="Positive"|ds2$result_zikv_serum_mom.mom=="Positive"] <- "Positive")

    source("C:/Users/amykr/Documents/GitHub/LaBeaud_lab/zika grenada/maternal_exposure_strata_3.R")#change to maternal_exposure_strata_2.R to switch strata for total analysis.
    
    table(ds2$zikv_exposed_mom,ds2$result_zikv_igg_pgold.pn, exclude = NULL)
    table(ds2$zikv_exposed_mom,ds2$result_zikv_igg_pgold.12, exclude = NULL)
    
    ds2$days_pn_12<-as.numeric(round((as.Date(ds2$date_assessment_2.12)-as.Date(ds2$date_assessment.pn))/31,1))
    
    mom_avidity<-subset(ds2, is.na(ds2$result_zikv_igg_pgold.mom)&ds2$result_zikv_igg_pgold_fu.mom=="Positive"&ds2$result_avidity_zikv_igg_pgold_fu.mom=="less than 6 months", select=c(mother_record_id,redcap_repeat_instance,days_pn_12,date_assessment_2.12,date_assessment.pn,result_avidity_zikv_igg_pgold_fu.mom,result_zikv_igg_pgold.mom,result_zikv_igg_pgold_fu.mom,pcr_positive_zikv_mom))
    write.csv(mom_avidity,"avidity.csv")
    
    mom_postnatal<-subset(ds2, ds2$result_zikv_igg_pgold.mom=="Negative", select=c(mother_record_id,redcap_repeat_instance,days_pn_12,date_assessment_2.12,date_assessment.pn,result_avidity_zikv_igg_pgold_fu.mom,result_zikv_igg_pgold.mom,result_zikv_igg_pgold_fu.mom,pcr_positive_zikv_mom))
    write.csv(mom_postnatal,"mom_postnatal.csv")
    table(ds2$result_zikv_igg_pgold.mom,ds2$result_zikv_igg_pgold_fu.mom,exclude = NULL)
    
    table(ds2$zikv_exposed_mom,ds2$result_avidity_zikv_igg_pgold.mom,exclude=NULL)
    table(ds2$zikv_exposed_mom,ds2$result_avidity_zikv_igg_pgold_fu.mom,exclude=NULL)
    
    table(ds2$result_zikv_igg_pgold_fu.mom,ds2$result_zikv_igg_pgold.mom,exclude = NULL)
    
    table(ds2$zikv_exposed_mom,ds2$redcap_repeat_instance, exclude = NULL)
    table(ds2$pcr_positive_zikv_mom=="Positive"|ds2$result_zikv_igg_pgold.mom=="Positive",ds2$cohort___1.mom,ds2$redcap_repeat_instance, exclude = NULL)
    table(ds2$pcr_positive_zikv_mom=="Positive"|ds2$result_zikv_igg_pgold.mom=="Positive",ds2$cohort___2.mom,ds2$redcap_repeat_instance, exclude = NULL)
    
#child zikv exposure
    ds2$zikv_exposed_child<-NA
    ds2 <- within(ds2, zikv_exposed_child[ds2$result_zikv_igg_pgold.pn=="Negative"|ds2$result_zikv_igg_pgold.12=="Negative"] <- "child ZIKV Unexposed")
    ds2 <- within(ds2, zikv_exposed_child[ds2$result_zikv_igg_pgold.pn=="Positive"|ds2$result_zikv_igg_pgold.12=="Positive"] <- "child ZIKV Exposed")
    
    ds2$cohort<-NA
    ds2 <- within(ds2, cohort[ds2$cohort___3.mom=="Checked"] <- "Zika Follow Up")
    ds2 <- within(ds2, cohort[ds2$cohort___1.mom=="Checked"] <- "Original Pregnancy")
    ds2 <- within(ds2, cohort[ds2$cohort___2.mom=="Checked"] <- "Febrile Zika")
    
    table(ds2$child_delivery,ds2$redcap_repeat_instance,ds2$cohort,ds2$zikv_exposed_mom,exclude = NULL)
    #drop PZ349, accidentally entered 2x in redcap. jonathan and nikita will merge. 
    ds2<-ds2[!(ds2$child_delivery=="Singleton" & ds2$redcap_repeat_instance==2),]
    table(ds2$child_delivery,ds2$redcap_repeat_instance,ds2$cohort,ds2$zikv_exposed_mom,exclude = NULL)
    
    table(ds2$zikv_exposed_mom,ds2$result_zikv_igg_pgold.pn,exclude = NULL)
    table(ds2$zikv_exposed_mom,ds2$result_zikv_igg_pgold.12,exclude = NULL)

    addmargins(table(round(ds2$child_calculated_age.pn,0)))
    addmargins(table(round(ds2$child_calculated_age_2.12,0)))

    addmargins(table(round(ds2$child_age_2_2.12,0),ds2$zikv_exposed_mom))
    addmargins(table(ds2$gender.pn,ds2$zikv_exposed_mom,exclude = NULL))
    addmargins(table(ds2$gender_2.12,ds2$zikv_exposed_mom))
#denv exposure mom
    ds2$pcr_positive_denv_mom<-NA
    ds2 <- within(ds2, pcr_positive_denv_mom[ds2$result_denv_urine_mom.mom=="Negative"|ds2$result_denv_serum_mom.mom=="Negative"] <- "Negative")
    ds2 <- within(ds2, pcr_positive_denv_mom[ds2$result_denv_urine_mom.mom=="Positive"|ds2$result_denv_serum_mom.mom=="Positive"] <- "Positive")
    
    ds2$denv_exposed_mom<-NA
    ds2 <- within(ds2, denv_exposed_mom[ds2$result_denv_igg_pgold.mom=="Negative"|result_denv_igg_pgold_fu.mom=="Negative"] <- "Mom denv Unexposed")
    ds2 <- within(ds2, denv_exposed_mom[ds2$pcr_positive_denv_mom=="Positive"|ds2$result_denv_igg_pgold.mom=="Positive"|result_denv_igg_pgold_fu.mom=="Positive"] <- "mom denv Exposed")
    
    table(ds2$denv_exposed_mom,ds2$redcap_repeat_instance, exclude = NULL)
    table(ds2$cohort,ds2$zikv_exposed_mom,ds2$redcap_repeat_instance)
    
#child denv exposure
    ds2$denv_exposed_child<-NA
    ds2 <- within(ds2, denv_exposed_child[ds2$result_denv_igg_pgold.pn=="Negative"|ds2$result_denv_igg_pgold.12=="Negative"] <- "child denv Unexposed")
    ds2 <- within(ds2, denv_exposed_child[ds2$result_denv_igg_pgold.pn=="Positive"|ds2$result_denv_igg_pgold.12=="Positive"] <- "child denv Exposed")
    
write.csv(ds2[,c("cohort","redcap_repeat_instance","mother_record_id","mom_id_orig_study.mom","mom_id_orig_study_2.mom","result_denv_igg_pgold.mom","result_denv_igg_pgold_fu.mom","result_denv_urine_mom.mom","result_denv_serum_mom.mom","result_zikv_igg_pgold.mom","result_zikv_igg_pgold_fu.mom","result_zikv_urine_mom.mom","result_zikv_serum_mom.mom","result_zikv_igg_pgold.pn", "result_zikv_igg_pgold.12", "result_zikv_igg_pgold.24", "result_zikv_igg_pgold.27","result_denv_igg_pgold.pn", "result_denv_igg_pgold.12", "result_denv_igg_pgold.24", "result_denv_igg_pgold.27","zikv_exposed_child","denv_exposed_child","zikv_exposed_mom","denv_exposed_mom")],file="zikv_exposure.csv",row.names = F,na="")
addmargins(table(ds2$cohort,ds2$redcap_repeat_instance,is.na(ds2$zikv_exposed_mom),exclude = NULL))

addmargins(table(ds2$zikv_exposed_child, ds2$denv_exposed_child,is.na(ds2$zikv_exposed_mom),exclude = NULL))
vars<-c("zikv_exposed_child","denv_exposed_child","result_avidity_denv_igg_pgold.pn","result_avidity_zikv_igg_pgold.pn")
CreateTableOne(vars,"zikv_exposed_child",ds2[!is.na(ds2$zikv_exposed_mom),],includeNA = T)
CreateTableOne(vars,data=ds2[!is.na(ds2$zikv_exposed_mom),],includeNA = T)
CreateTableOne(vars,data=ds2[!is.na(ds2$zikv_exposed_mom),],includeNA = F)

#calculate mom age at deliery and remove outliers over 50 and under 15
    ds2$mom_age_delivery<-as.numeric(round((as.Date(ds2$delivery_date.pn)-as.Date(ds2$dob.mom))/365,1))
    ds2[ds2$dob.mom>"2001-01-29"|ds2$dob.mom=="",c("mother_record_id","dob.mom","delivery_date.pn","mom_age_delivery","mothers_age_calc.mom","date.mom")]
    ds2 <- within(ds2, mom_age_delivery[ds2$mom_age_delivery<15|ds2$mom_age_delivery>50] <- NA)
    ds2$mom_40plus<-ifelse(ds2$mom_age_delivery >=40, 1, ifelse(ds2$mom_age_delivery<40,0,NA))

#calculate dad age at deliery and remove outliers over 80 and under 15
  ds2$dad_age_delivery<-as.numeric(round((as.Date(ds2$delivery_date.pn)-lubridate::as_date(ds2$partner_dob.mom))/365,1))
  ds2 <- within(ds2, dad_age_delivery[ds2$dad_age_delivery<15|ds2$dad_age_delivery>80] <- NA)
  ds2$dad_40plus<-ifelse(ds2$dad_age_delivery >=40, 1, ifelse(ds2$dad_age_delivery<40,0,NA))

#Table 1: Maternal demographics of cohort by exposure status: age, education, income, geography: home parish, medical history, marital status, paternal age, occupation
  ds2$education.mom.cat<-NA
  ds2 <- within(ds2, education.mom.cat[ds2$education.mom=="Primary School"]<- "Primary")
  ds2 <- within(ds2, education.mom.cat[ds2$education.mom=="Secondary School"]<- "Secondary +")
  ds2 <- within(ds2, education.mom.cat[ds2$education.mom=="Bachelor's degree"|ds2$education.mom=="Graduate or Professional degree"]<- "college +")
  table(ds2$education.mom.cat)

  ds2$any_mosquito_protection<-NA
  ds2 <- within(ds2, any_mosquito_protection[ds2$coil.mom=="Never" & ds2$mosquito_screens.mom=="None of them" & ds2$repellent.mom=="Never"]<- "No")
  ds2 <- within(ds2, any_mosquito_protection[ds2$coil.mom=="Always" |ds2$coil.mom=="Sometimes"| ds2$coil.mom=="Ocasionally"|ds2$coil.mom=="Often"|ds2$mosquito_screens.mom=="Some of them"|ds2$mosquito_screens.mom=="Most of them"|ds2$mosquito_screens.mom=="All of them"|ds2$repellent.mom=="Always" |ds2$repellent.mom=="Sometimes"| ds2$repellent.mom=="Ocasionally"|ds2$repellent.mom=="Often"]<- "Yes")

  ds2$parity<-NA
  ds2 <- within(ds2, parity[ds2$previous_pregnancy.mom=="0"]<- "nulliparous")
  ds2 <- within(ds2, parity[ds2$previous_pregnancy.mom=="1" |ds2$previous_pregnancy.mom=="2"| ds2$previous_pregnancy.mom=="3+"]<- "parous")

  ds2$cdv_risk<-NA
  ds2 <- within(ds2, cdv_risk[ds2$medical_conditions___3.mom=="Unchecked" & ds2$medical_conditions___6.mom=="Unchecked" & ds2$medical_conditions___7.mom=="Unchecked" & ds2$medical_conditions___8.mom=="Unchecked"]<- "no risk")
  ds2 <- within(ds2, cdv_risk[ds2$medical_conditions___3.mom=="Checked" | ds2$medical_conditions___6.mom=="Checked" | ds2$medical_conditions___7.mom=="Checked" | ds2$medical_conditions___8.mom=="Checked"]<- "At risk")

ds2$asthma_resp<-NA
  ds2 <- within(ds2, asthma_resp[ds2$medical_conditions___1.mom=="Unchecked" & ds2$medical_conditions___2.mom=="Unchecked"]<- "0")
  ds2 <- within(ds2, asthma_resp[ds2$medical_conditions___1.mom=="Checked" | ds2$medical_conditions___2.mom=="Checked"]<- "1")
    factor <- c("coil.mom","repellent.mom","occupation.mom","marrital_status.mom","education.mom.cat","monthly_income.mom","latrine_type.mom","air_conditioning.mom","delivery_type.pn", "cong_abnormal.pn", "gender.pn","parish.mom","previous_pregnancy.mom","mom_40plus","dad_40plus") 
    ds2[factor] <- lapply(ds2[factor], as.factor) 
    tab1vars <- c("parish.mom","mom_40plus","occupation.mom","asthma_resp","medical_conditions___10.mom","medical_conditions___12.mom","medical_conditions___13.mom","cdv_risk","parity","marrital_status.mom","education.mom.cat","monthly_income.mom","latrine_type.mom","dad_40plus","any_mosquito_protection")
    require(tableone)
    tab1All <- CreateTableOne(vars = tab1vars, data = ds2[ds2$redcap_repeat_instance==1 & !is.na(ds2$zikv_exposed_mom),], factorVars = factor)
    tab1All<-print(tab1All,quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE,cramVars = tab1vars)
    setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/zika study- grenada/ms zika spectrum of disease")
    write.csv(tab1All, file = "Table 1_maternal_demographics.csv")
    
    tab1All <- CreateTableOne(vars = tab1vars, strata = "zikv_exposed_mom" , data = ds2[ds2$redcap_repeat_instance==1,], factorVars = factor)
    tab1All<-print(tab1All,quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE,cramVars = tab1vars,smd=T)
    write.csv(tab1All, file = "Table 1_maternal_demographics_strata.csv")

# figure 1: Frequency boxplots of symptoms amongst zika positive moms: zika symptoms at antenatal visit or recall symptoms during pregnancy.  -----------------------------------------------------------------
source("C:/Users/amykr/Documents/GitHub/LaBeaud_lab/zika grenada/symptoms combined.R")#combine the data from zika_survey "During your Zika illness, what symptoms did you have?" and zika_initial_survey "Did you experience any of the following symptoms during your Zika illness?"
    
ds2<-merge(ds2,symptoms_zika,by=c("mother_record_id","redcap_repeat_instance"),all.x = T)

ds2$cohort<-NA
ds2 <- within(ds2, cohort[ds2$cohort___3.mom=="Checked"] <- "Zika Follow Up")
ds2 <- within(ds2, cohort[ds2$cohort___1.mom=="Checked"] <- "Original Pregnancy")
ds2 <- within(ds2, cohort[ds2$cohort___2.mom=="Checked"] <- "Febrile Zika")

ds2 <- within(ds2, trimester.mom[trimester_2.12=="2nd trimester"] <- "2nd trimester")
ds2 <- within(ds2, trimester.mom[trimester_2.12=="3rd trimester"] <- "3rd trimester")
ds2 <- within(ds2, trimester.mom[is.na(ds2$trimester.mom)|ds2$trimester.mom=="Refused/Don't know"] <- "Refused/Don't know/NA")
ds2 <- within(ds2, trimester.mom[is.na(ds2$trimester.mom)|ds2$trimester.mom=="Refused/Don't know"] <- "Refused/Don't know/NA")

zikv_pos<-subset(ds2,(ds2$zikv_exposed_mom=="mom_ZIKV_Exposed_during_pregnancy"|ds2$zikv_exposed_mom=="mom_ZIKV_Exposure_possible_during_pregnancy"))

symptoms_zika_var<-rlist::list.append(symptoms_zika_var,"trimester.mom")


symptoms_zika <- CreateTableOne(vars = symptoms_zika_var, data = zikv_pos[zikv_pos$redcap_repeat_instance==1,], factorVars = symptoms_zika_var)
symptoms_zika<-print(symptoms_zika,quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE,cramVars = symptoms_zika_var)
write.csv(symptoms_zika, file = "symptoms_zika.csv")#supplementary table

symptoms_zika <- CreateTableOne(vars = symptoms_zika_var, data = zikv_pos[zikv_pos$redcap_repeat_instance==1,],strata="cohort" , factorVars = symptoms_zika_var)
symptoms_zika<-print(symptoms_zika,quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE,cramVars = symptoms_zika_var,smd=T)
write.csv(symptoms_zika, file = "symptoms_zika_strata.csv")#supplementary table.

table(ds2$zikv_exposed_child)

# further collapse zika symptoms table ------------------------------------
source("C:/Users/amykr/Documents/GitHub/LaBeaud_lab/zika grenada/symptoms_combined2.R")#combine the data from zika_survey "During your Zika illness, what symptoms did you have?" and zika_initial_survey "Did you experience any of the following symptoms during your Zika illness?"
ds2<-merge(ds2,symptoms_zika_groups,by=c("mother_record_id","redcap_repeat_instance"),all.x = T)

zikv_pos<-subset(ds2,ds2$zikv_exposed_mom=="mom_ZIKV_Exposed_during_pregnancy"|ds2$zikv_exposed_mom=="mom_ZIKV_Exposure_possible_during_pregnancy")
symptoms_zika_group_var<-rlist::list.append(symptoms_zika_group_var,"trimester.mom")

symptoms_zika <- CreateTableOne(vars = symptoms_zika_group_var, data = zikv_pos[zikv_pos$redcap_repeat_instance==1,], factorVars = symptoms_zika_group_var,includeNA=T)
symptoms_zika<-print(symptoms_zika,quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE,cramVars = symptoms_zika_group_var)
write.csv(symptoms_zika, file = "symptoms_groups_zika.csv")

symptoms_zika <- CreateTableOne(vars = symptoms_zika_group_var, data = zikv_pos,strata="cohort" , factorVars = symptoms_zika_group_var,includeNA=T)
symptoms_zika<-print(symptoms_zika,quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE,cramVars = symptoms_zika_group_var,smd=T)
write.csv(symptoms_zika, file = "symptoms_groups_zika_strata.csv")

#comorbidites maternal

comorbid_vars<-c("pcr_positive_denv_mom","pcr_positive_zikv_mom","denv_exposed_mom","result_avidity_denv_igg_pgold.mom","result_avidity_zikv_igg_pgold.mom")
comorbidites <- CreateTableOne(vars = comorbid_vars, data = ds2[ds2$redcap_repeat_instance==1 & !is.na(ds2$zikv_exposed_mom),], factorVars = comorbid_vars)
comorbidites<-print(comorbidites,quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE,cramVars = comorbid_vars,smd=T)
write.csv(comorbidites, file = "comorbidites.csv")
ds2[ds2$result_avidity_zikv_igg_pgold.mom=="No Infection" &(ds2$zikv_exposed_mom=="mom_ZIKV_Exposure_possible_during_pregnancy"|ds2$zikv_exposed_mom=="mom_ZIKV_Exposed_during_pregnancy"),"mother_record_id"]

comorbidites <- CreateTableOne(vars = comorbid_vars, data = ds2, factorVars = comorbid_vars,strata = "zikv_exposed_mom")
comorbidites<-print(comorbidites,quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE,cramVars = comorbid_vars,smd=T)
write.csv(comorbidites, file = "comorbidites_strata.csv")

# Supplementary table 1: maternal symptoms by denv exposure stat --------
sup.table1 <- CreateTableOne(vars = symptoms_zika_var, data = ds2,factorVars = symptoms_zika_group_var,strata="result_denv_igg_pgold.mom")
print(sup.table1, cramVars = symptoms_zika_var)
sup.table1<-print(sup.table1,quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE)
write.csv(sup.table1, file = "sup.table1.csv")

#define outcomes
#Table 2: a. child birth outcomes nurse assessment form postnatal:anthropometric, birth complication; b. child 12-month outcomes: strength, deep tendon reflexes --------
    ds2<-ds2 %>% select(sort(names(.)))
    child_outcome_vars.delivery<-grep("term_2|gestational_weeks_2_2|delivery_type|apgar_one|apgar_ten|outcome_of_delivery|neonatal_resusitation|ant_fontanelle|sutures|facial_dysmoph|cleft|red_reflex|plantar_reflex|galant_reflex|suck|grasp|moro|cong_abnormal|specify_cong_abnormal|chromosomal_abn|z_seizures|heart_rate|resp_rate|color|cry|tone|moving_limbs|cap_refill|child_referred|gender|muscle_tone_abnormal|resp_rate|temperature",names(ds2),value = T)
    
    child_outcome_vars.delivery<-grep(".pn|.12",child_outcome_vars.delivery,value = T)
    child_outcomes <- CreateTableOne(vars = child_outcome_vars.delivery, data = ds2,strata = "zikv_exposed_mom")
    
    child_outcomes<-print(child_outcomes,quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE,smd=T)
    write.csv(child_outcomes, file = "Delivery_Outcomes_all.csv")

    source("C:/Users/amykr/Documents/GitHub/LaBeaud_lab/zika grenada/child_delivery_outcome_groups.R")
    child_outcome_vars.delivery_all<-rlist::list.append(child_outcome_vars.delivery,c("apgar_one.pn","apgar_ten.pn","sum_delivery_Outcomes_abnormal.pn"))
    child_outcome_vars.delivery_factor<-rlist::list.append(child_outcome_vars.delivery,c("sum_delivery_Outcomes_abnormal.pn"))
    
    child_outcomes <- CreateTableOne(vars = child_outcome_vars.delivery_all, data = ds2,strata = "zikv_exposed_mom",factorVars=child_outcome_vars.delivery_factor)
    child_outcomes<-print(child_outcomes,quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = T,smd=T, nonnormal=c("apgar_one.pn","apgar_ten.pn"),cramVars=child_outcome_vars.delivery)
    write.csv(child_outcomes, file = "Delivery_Outcomes_groups_strata.csv")

    child_outcomes <- CreateTableOne(vars = child_outcome_vars.delivery_all, data = ds2[!is.na(ds2$zikv_exposed_mom),],factorVars=child_outcome_vars.delivery_factor)
    child_outcomes<-print(child_outcomes,quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = T,smd=T, nonnormal=c("apgar_one.pn","apgar_ten.pn"),cramVars=child_outcome_vars.delivery)
    write.csv(child_outcomes, file = "Delivery_Outcomes_groups.csv")
    boxplot(ds2$sum_delivery_Outcomes_abnormal.pn)
    summary(ds2$sum_delivery_Outcomes_abnormal.pn)
# growth --------------------------------------------------------------------
    #Birth: Z-scores for BMI, length, weight, and head circumference and microcephaly
    #12 month visit: Z-scores for BMI, length, weight, and head circumference and microcephaly
    ds2 <- within(ds2, redcap_repeat_instance[ds2$redcap_repeat_instance==1] <- "C1")
    ds2 <- within(ds2, redcap_repeat_instance[ds2$redcap_repeat_instance==2] <- "C2")
#recalculate all the zscores. the nurses did not fill these out each time. 
    
    source("C:/Users/amykr/Documents/GitHub/LaBeaud_lab/zika grenada/igrowup_longitudinal.R")
    
#define substance use generally.
    ds2$substance_use<-NA
    ds2 <- within(ds2, substance_use[ds2$z_alcohol.24=="No"|ds2$z_drugs.24=="No"|ds2$z_smoking.24=="No"] <- "no")
    ds2 <- within(ds2, substance_use[ds2$z_alcohol.24=="Yes"|ds2$z_drugs.24=="Yes"|ds2$z_smoking.24=="Yes"] <- "yes")
    table(ds2$substance_use)
    
# oxnda -------------------------------------------------------------------
    source("C:/Users/amykr/Documents/GitHub/LaBeaud_lab/zika grenada/oxnda_maternal_zikv_exposure.R")
    
#oxnda linear regression model -------------------------------------------------------------------
  #lab <- c("Maternal Exposure Category", "Child age (months)", "Maternal age at delivery (years)", "Child gender", "gestational age at delivery (weeks)","Highest Maternal educaton","Household monthly income","Parish of residence","Child Breastfed")
  #labdep <- c("Mean OXNDA score")  
    ds2_oxnda_10_18$monthly_income.mom <- factor( ds2_oxnda_10_18$monthly_income.mom , ordered = FALSE )
  

  library(sjPlot)
  library(sjlabelled)
  library(sjmisc)
  library(ggplot2)
theme_set(theme_sjplot(base_size = 20,base_family = ""))
set_label(ds2_oxnda_10_18$zikv_exposed_mom) <- "Mean OXNDA score"
set_label(ds2_oxnda_10_18$breastfeed.12) <- "Child Breastfed"
ds2_oxnda_10_18 <- within(ds2_oxnda_10_18, breastfeed.12[ds2_oxnda_10_18$breastfeed.12=="No"] <- "Not Breastfed")
ds2_oxnda_10_18 <- within(ds2_oxnda_10_18, breastfeed.12[ds2_oxnda_10_18$breastfeed.12=="Yes"] <- "Breastfed")
set_label(ds2_oxnda_10_18$monthly_income.mom) <- "HH Monthly Income"
set_label(ds2_oxnda_10_18$gestational_weeks_2_2.12) <- "Gestational Weeks"
set_label(ds2_oxnda_10_18$gender.pn) <- "Gender"
set_label(ds2_oxnda_10_18$parish.mom) <- "Parish of Residence"
set_label(ds2_oxnda_10_18$zikv_exposed_mom) <- "Maternal ZIKV Exposure Strata"
set_label(ds2_oxnda_10_18$education.mom) <- "Maternal Highest Education"
set_label(ds2_oxnda_10_18$age.at.visit_months) <- "Child age (months) at assessment"

model1<-glm(Mean_OXNDA_score_rescaled~zikv_exposed_mom+age.at.visit_months+mom_age_delivery+gender.pn+gestational_weeks_2_2.12+education.mom.cat+monthly_income.mom+parish.mom+breastfeed.12,family = gaussian,data = ds2_oxnda_10_18)
model2<-glm(Mean_OXNDA_score_rescaled~zikv_exposed_mom+age.at.visit_months+mom_age_delivery+parish.mom,family = gaussian,data = ds2_oxnda_10_18)

tiff(filename = "glm_model2_estimates.tif",width = 2500,height=3000,units="px",family = "sans",bg="white",pointsize = 12,res=300)
plot_model(model2,
           vline.color = "red",
           #sort.est = TRUE,
           show.values = TRUE,
           value.offset = .3,
           show.reflvl =T)
dev.off()

tiff(filename = "glm_model1_estimates.tif",width = 2000,height=3000,units="px",family = "sans",bg="white",pointsize = 12,res=300)
plot_model(model1,
           vline.color = "red",
           #sort.est = TRUE,
           show.values = TRUE,
           value.offset = .3,
           type = 'est',
           show.reflvl =T)
dev.off()

plot_model(model1,
           vline.color = "red",
           #sort.est = TRUE,
           show.values = TRUE,
           value.offset = .3,
           type = 'diag',
           show.reflvl =T)

tab_model(model1,model2,show.reflvl =T)
tab_model(model1,show.reflvl =T)

# bivariate analysis ------------------------------------------------------

  #all children with >50% responses? 
  
  #Then, it would be very helpful to see similar plots for mean OXNDA scores from all children with >50% responses plotted against parental income, education, as well as bar charts for categorical variables such as gender, Parish, etc. 
  
  #So far, we know for sure we will need to include age as a covariate when run the group comparison.Agree We can see how the data looks for the others before making the decision to include them or not. Usually, I look at whether there is a correlation with the DV and then whether there are group differences in the potential confound. For example, there were differences in age between the Zika exposure groups when I last checked but this was prior to expanding these groups with the latest testing so you will need to check again with the latest group designations. Others may have a different analytic approach to data exploration but this is usually what I do prior to running the main model. I also make sure the data is normally distributed using Shapiro-Wilks (or something comparable) to justify the use of parametric analyses. We can also gauge this by looking at histogram or whisker plots. It would be good to plot mean OXNDA scores from each exposure group just to make sure they are not too differentially distributed before running the group comparison. 
  
  #I don't believe we systematically collected questionnaire data regarding parental attitudes towards corporal punishment, chaos in the home, etc at the 1-year time point but if this is available, it would also be good to plot those scores against mean OXNDA scores to see if there are any strong effects/confounds we need to consider before running the Zika exposure group comparison.
  
# stop here ---------------------------------------------------------------------


    child_outcome_vars<-grep("pn|12",child_outcome_vars,value = T)
    child_outcomes <- CreateTableOne(vars = child_outcome_vars, data = ds2,strata = "zikv_exposed_mom")
    child_outcomes<-print(child_outcomes,quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE,smd=T)
    write.csv(child_outcomes, file = "Congenital_abnormalities_Complications.csv")


    
  # define normal/abnormal --------------------------------------------------
    ds2$chromosomal_abn.12.abnormal<-ifelse(ds2$chromosomal_abn.12== "Yes", 1, ifelse(ds2$chromosomal_abn.12 =="No",0,NA))
    table(ds2$chromosomal_abn.12.abnormal)
    ds2$cong_abnormal.pn.abnormal<-ifelse(ds2$cong_abnormal.pn== "Yes", 1, ifelse(ds2$cong_abnormal.pn =="No",0,NA))
    table(ds2$cong_abnormal.pn.abnormal)

    ds2$gait.12.abnormal<-ifelse(ds2$gait.12== "Abnormal", 1, ifelse(ds2$gait.12 =="Normal",0,NA))
    table(ds2$gait.12.abnormal)
    
    ds2$red_reflex.pn.abnormal<-ifelse(ds2$red_reflex.pn== "No", 1, ifelse(ds2$red_reflex.pn =="Yes",0,NA))
    table(ds2$red_reflex.pn.abnormal)
    
    ds2$red_reflex_2.12.abnormal<-ifelse(ds2$red_reflex_2.12== "No", 1, ifelse(ds2$red_reflex_2.12 =="Yes",0,NA))
    table(ds2$red_reflex_2.12.abnormal)
    
    
#child changing gender over visits
table(ds2$gender.pn,ds2$gender_2.12,exclude = NULL)
table(ds2$child_referred.pn,ds2$child_referred_2.12,exclude = NULL)
table(ds2$maternal_resusitation.pn,ds2$maternal_resusitation_2.12,exclude = NULL)
table(ds2$delivery_type.pn,ds2$delivery_type_2.12,exclude = NULL)
ds2$zhc.pn
tiff(filename = "hc.tif",width = 3000,height=1600,units="px",family = "sans",bg="white",pointsize = 12,res=300)
boxplot(ds2$head_circ_birth,ds2$mean_hc.pn,ds2$mean_hc_2,ds2$mean_hc_2.24,ylab="Head Circumference, cm",names= c("birth","post","12 m","24 m"),fontsize=24)
dev.off()

factorVars <- c("mir.pn", "result_zikv_igg_pgold", "result_avidity_zikv_igg_pgold", "result_denv_igg_pgold","result_avidity_denv_igg_pgold")
ds2[, factorVars] <- lapply(ds2[, factorVars], factor)

#stop. the sum_growth_Outcomes_abnormal is not included here. it needs to be added back in wide format.

# zika -------------------------------------------------------------------
ds2$sum_outcomes.pn<-rowSums(ds2[,c("sum_delivery_Outcomes_abnormal.pn","sum_growth_Outcomes_abnormal.pn")],na.rm = T)
ds2 <- within(ds2, sum_outcomes.pn[is.na(ds2$sum_delivery_Outcomes_abnormal.pn)&is.na(ds2$sum_growth_Outcomes_abnormal.pn))] <- NA)
table(ds2$sum_outcomes.pn)
ds2$sum_outcomes.12<-rowSums(ds2[,c("sum_delivery_Outcomes_abnormal.12","sum_growth_Outcomes_abnormal.12")],na.rm = T)
ds2 <- within(ds2, sum_outcomes.12[is.na(ds2$sum_delivery_Outcomes_abnormal.12)&is.na(ds2$sum_growth_Outcomes_abnormal.12))] <- NA)
table(ds2$sum_outcomes.12)

ds3<-ds2[complete.cases(ds2[c("zikv_exposed_mom","sum_outcomes.12","sum_outcomes.pn","mom_age_delivery")]), ] 
#ds3<-ds2
save(ds3,file="ds3.rda")

# model outcomes ----------------------------------------------------------
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/zika study- grenada/ms zika spectrum of disease")
load("ds3.rda")
ds2 <- within(ds2, pcr_positive_zikv_mom[ds2$result_zikv_urine_mom.mom=="Negative"|ds2$result_zikv_serum_mom.mom=="Negative"] <- "Negative")

hist(ds3$sum_outcomes.12)
hist(ds3$sum_outcomes.pn)

require(R2BayesX)
require(dplyr)
require(ggplot2)
ggplot(ds3, aes(x = factor(zikv_exposed_mom), y = sum_outcomes.pn)) + geom_boxplot()


m1<-R2BayesX::bayesx(sum_outcomes.pn~0,
                     data=ds3,method="REML", family="poisson",zipdistopt = "zip",criterion = "MSEP")

m2<-R2BayesX::bayesx(sum_outcomes.pn~as.factor(zikv_exposed_mom)+sx(mom_age_delivery)+as.factor(mom_educ_initial.mom)+sx(gestational_weeks_2_2.12),
                     data=ds3,method="REML", family="poisson",zipdistopt = "zip",criterion = "MSEP",na.rm=T)

m3<-R2BayesX::bayesx(sum_outcomes.pn~as.factor(zikv_exposed_mom)+sx(mom_age_delivery)+as.factor(mom_educ_initial.mom)+sx(gestational_weeks_2_2.12),
                     data=ds3,method="STEP", family="poisson",zipdistopt = "zip",criterion = "MSEP",na.rm=T)

summary(c(m1,m2,m3))
exp(coef(m2))

plot(m2)
