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

load("zika 2019-08-13 .rda")
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
child <- merge(child, data27, by = c("mother_record_id","redcap_repeat_instance"), all.x=T)
child <- merge(child, data30, by = c("mother_record_id","redcap_repeat_instance"), all.x=T)
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
    
    ds2$zikv_exposed_mom<-NA
    ds2 <- within(ds2, zikv_exposed_mom[ds2$result_zikv_igg_pgold.mom=="Negative"|ds2$result_zikv_igg_pgold_fu.mom=="Negative"] <- "mom_zikv_Unexposed")
    ds2 <- within(ds2, zikv_exposed_mom[ds2$pcr_positive_zikv_mom=="Positive"|ds2$result_zikv_igg_pgold.mom=="Positive"|ds2$result_zikv_igg_pgold_fu.mom=="Positive"] <- "mom_ZIKV_Exposed")
    
    table(ds2$zikv_exposed_mom,ds2$redcap_repeat_instance, exclude = NULL)
    table(ds2$pcr_positive_zikv_mom=="Positive"|ds2$result_zikv_igg_pgold.mom=="Positive",ds2$cohort___1.mom,ds2$redcap_repeat_instance, exclude = NULL)
    table(ds2$pcr_positive_zikv_mom=="Positive"|ds2$result_zikv_igg_pgold.mom=="Positive",ds2$cohort___2.mom,ds2$redcap_repeat_instance, exclude = NULL)
    
#child zikv exposure
    ds2$zikv_exposed_child<-NA
    ds2 <- within(ds2, zikv_exposed_child[ds2$result_zikv_igg_pgold.pn=="Negative"|ds2$result_zikv_igg_pgold.12=="Negative"|ds2$result_zikv_igg_pgold.24=="Negative"|ds2$result_zikv_igg_pgold.27=="Negative"] <- "child ZIKV Unexposed")
    ds2 <- within(ds2, zikv_exposed_child[ds2$result_zikv_igg_pgold.pn=="Positive"|ds2$result_zikv_igg_pgold.12=="Positive"|ds2$result_zikv_igg_pgold.24=="Positive"|ds2$result_zikv_igg_pgold.27=="Positive"] <- "child ZIKV Exposed")
    
    table(ds2$zikv_exposed_child,ds2$redcap_repeat_instance, exclude = NULL)

    table(ds2$zikv_exposed_child,ds2$zikv_exposed_mom, exclude = NULL)
    table(ds2$zikv_exposed_child,ds2$result_zikv_serum_mom.mom, exclude = NULL)
    table(ds2$zikv_exposed_child,ds2$result_zikv_urine_mom.mom, exclude = NULL)
    
#denv exposure mom
    ds2$pcr_positive_denv_mom<-NA
    ds2 <- within(ds2, pcr_positive_denv_mom[ds2$result_denv_urine_mom.mom=="Negative"|ds2$result_denv_serum_mom.mom=="Negative"] <- "Negative")
    ds2 <- within(ds2, pcr_positive_denv_mom[ds2$result_denv_urine_mom.mom=="Positive"|ds2$result_denv_serum_mom.mom=="Positive"] <- "Positive")
    
    ds2$denv_exposed_mom<-NA
    ds2 <- within(ds2, denv_exposed_mom[ds2$result_denv_igg_pgold.mom=="Negative"|result_denv_igg_pgold_fu.mom=="Negative"] <- "Mom denv Unexposed")
    ds2 <- within(ds2, denv_exposed_mom[ds2$pcr_positive_denv_mom=="Positive"|ds2$result_denv_igg_pgold.mom=="Positive"|result_denv_igg_pgold_fu.mom=="Positive"] <- "mom denv Exposed")
    
    table(ds2$denv_exposed_mom,ds2$redcap_repeat_instance, exclude = NULL)
#child denv exposure
    ds2$denv_exposed_child<-NA
    ds2 <- within(ds2, denv_exposed_child[ds2$result_denv_igg_pgold.pn=="Negative"|ds2$result_denv_igg_pgold.12=="Negative"|ds2$result_denv_igg_pgold.24=="Negative"|ds2$result_denv_igg_pgold.27=="Negative"] <- "child denv Unexposed")
    ds2 <- within(ds2, denv_exposed_child[ds2$result_denv_igg_pgold.pn=="Positive"|ds2$result_denv_igg_pgold.12=="Positive"|ds2$result_denv_igg_pgold.24=="Positive"|ds2$result_denv_igg_pgold.27=="Positive"] <- "child denv Exposed")
    
write.csv(ds2[,c("mother_record_id","mom_id_orig_study.mom","mom_id_orig_study_2.mom","result_denv_igg_pgold.mom","result_denv_igg_pgold_fu.mom","result_denv_urine_mom.mom","result_denv_serum_mom.mom","result_zikv_igg_pgold.mom","result_zikv_igg_pgold_fu.mom","result_zikv_urine_mom.mom","result_zikv_serum_mom.mom","result_zikv_igg_pgold.pn", "result_zikv_igg_pgold.12", "result_zikv_igg_pgold.24", "result_zikv_igg_pgold.27","result_denv_igg_pgold.pn", "result_denv_igg_pgold.12", "result_denv_igg_pgold.24", "result_denv_igg_pgold.27","zikv_exposed_child","denv_exposed_child","zikv_exposed_mom","denv_exposed_mom")],file="zikv_exposure.csv",row.names = F,na="")

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
    factor <- c("coil.mom","repellent.mom","occupation.mom","marrital_status.mom","education.mom.cat","monthly_income.mom","latrine_type.mom","air_conditioning.mom","delivery_type.pn", "cong_abnormal.pn", "gender.pn","parish.mom","previous_pregnancy.mom") 
    ds2[factor] <- lapply(ds2[factor], as.factor) 
    tab1vars <- c("parish.mom","mom_40plus","occupation.mom","asthma_resp","medical_conditions___10.mom","medical_conditions___12.mom","medical_conditions___13.mom","cdv_risk","parity","marrital_status.mom","education.mom.cat","monthly_income.mom","latrine_type.mom","dad_40plus","any_mosquito_protection")
    require(tableone)
    tab1All <- CreateTableOne(vars = tab1vars, data = ds2[ds2$redcap_repeat_instance==1,], factorVars = factor)
    tab1All<-print(tab1All,quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE,cramVars = tab1vars)
    setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/zika study- grenada/ms zika spectrum of disease")
    write.csv(tab1All, file = "Table 1_maternal_demographics.csv")

    tab1All <- CreateTableOne(vars = tab1vars, strata = "zikv_exposed_mom" , data = ds2[ds2$redcap_repeat_instance==1,], factorVars = factor)
    tab1All<-print(tab1All,quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE,cramVars = tab1vars,smd=T)
    write.csv(tab1All, file = "Table 1_maternal_demographics_strata.csv")
    
    p<-as.data.frame(tab1All[,3])
    p<-p[p$p!="",]
    p<-p.adjust(p, method = p.adjust.methods)
    

# figure 1: Frequency boxplots of symptoms amongst zika positive moms: zika symptoms at antenatal visit or recall symptoms during pregnancy.  -----------------------------------------------------------------
source("C:/Users/amykr/Documents/GitHub/LaBeaud_lab/zika grenada/symptoms combined.R")#combine the data from zika_survey "During your Zika illness, what symptoms did you have?" and zika_initial_survey "Did you experience any of the following symptoms during your Zika illness?"
ds2<-merge(ds2,symptoms_zika,by="mother_record_id",all.x = T)

ds2$cohort<-NA
ds2 <- within(ds2, cohort[ds2$cohort___3.mom=="Checked"] <- "Zika Follow Up")
ds2 <- within(ds2, cohort[ds2$cohort___1.mom=="Checked"] <- "Original Pregnancy")
ds2 <- within(ds2, cohort[ds2$cohort___2.mom=="Checked"] <- "Febrile Zika")
zikv_pos<-subset(ds2,ds2$zikv_exposed_mom=="mom_ZIKV_Exposed")

symptoms_zika_var<-rlist::list.append(symptoms_zika_var,"trimester.mom")

symptoms_zika <- CreateTableOne(vars = symptoms_zika_var, data = zikv_pos, factorVars = symptoms_zika_var)
symptoms_zika<-print(symptoms_zika,quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE,cramVars = symptoms_zika_var)
write.csv(symptoms_zika, file = "symptoms_zika.csv")

symptoms_zika <- CreateTableOne(vars = symptoms_zika_var, data = zikv_pos,strata="cohort" , factorVars = symptoms_zika_var)
symptoms_zika<-print(symptoms_zika,quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE,cramVars = symptoms_zika_var,smd=T)
write.csv(symptoms_zika, file = "symptoms_zika_strata.csv")

# further collapse zika symptoms table ------------------------------------
source("C:/Users/amykr/Documents/GitHub/LaBeaud_lab/zika grenada/symptoms_combined2.R")#combine the data from zika_survey "During your Zika illness, what symptoms did you have?" and zika_initial_survey "Did you experience any of the following symptoms during your Zika illness?"
ds2<-merge(ds2,symptoms_zika_groups,by="mother_record_id",all.x = T)
zikv_pos<-subset(ds2,ds2$zikv_exposed_mom=="mom_ZIKV_Exposed")
symptoms_zika_group_var<-rlist::list.append(symptoms_zika_group_var,"trimester.mom")

symptoms_zika <- CreateTableOne(vars = symptoms_zika_group_var, data = zikv_pos, factorVars = symptoms_zika_group_var,includeNA=T)
symptoms_zika<-print(symptoms_zika,quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE,cramVars = symptoms_zika_group_var)
write.csv(symptoms_zika, file = "symptoms_groups_zika.csv")

symptoms_zika <- CreateTableOne(vars = symptoms_zika_group_var, data = zikv_pos,strata="cohort" , factorVars = symptoms_zika_group_var,includeNA=T)
symptoms_zika<-print(symptoms_zika,quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE,cramVars = symptoms_zika_group_var,smd=T)
write.csv(symptoms_zika, file = "symptoms_groups_zika_strata.csv")

#comorbidites maternal
comorbid_vars<-c("denv_exposed_mom","result_avidity_denv_igg_pgold.mom","result_avidity_zikv_igg_pgold.mom")
comorbidites <- CreateTableOne(vars = comorbid_vars, data = ds2, factorVars = comorbid_vars)
comorbidites<-print(comorbidites,quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE,cramVars = comorbid_vars,smd=T)
write.csv(comorbidites, file = "comorbidites.csv")

comorbid_vars<-c("denv_exposed_mom","result_avidity_denv_igg_pgold.mom","result_avidity_zikv_igg_pgold.mom")
comorbidites <- CreateTableOne(vars = comorbid_vars, data = ds2, factorVars = comorbid_vars,strata = "zikv_exposed_mom")
comorbidites<-print(comorbidites,quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE,cramVars = comorbid_vars,smd=T)
write.csv(comorbidites, file = "comorbidites_strata.csv")
p<-as.data.frame(comorbidites[,3])
p<-p[p$p!="",]
p.adjust(p, method = p.adjust.methods)

# Supplementary table 1: maternal symptoms by denv exposure stat --------
sup.table1 <- CreateTableOne(vars = symptoms_zika_var, data = ds2,factorVars = symptoms_zika_var,strata="result_denv_igg_pgold")
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
    write.csv(child_outcomes, file = "Delivery_Outcomes_groups.csv")
    
# growth --------------------------------------------------------------------
    #Birth: Z-scores for BMI, length, weight, and head circumference and microcephaly
    #12 month visit: Z-scores for BMI, length, weight, and head circumference and microcephaly
    ds2 <- within(ds2, redcap_repeat_instance[ds2$redcap_repeat_instance==1] <- "C1")
    ds2 <- within(ds2, redcap_repeat_instance[ds2$redcap_repeat_instance==2] <- "C2")
    
    child_outcome_vars<-grep("zlen|zhc|zwei|zwfl|mean",names(ds2),value = T)
    child_outcome_vars<-grep(".12|.pn",child_outcome_vars,value = T)
    child_outcome_vars<-grep("cognitive|motor|language|height",child_outcome_vars,value = T,invert = T)
    child_outcome_vars2<-c(child_outcome_vars,"mother_record_id","redcap_repeat_instance","zikv_exposed_mom")
    growth<-ds2[,child_outcome_vars2]
    growth<-growth[order(-(grepl('zhc', names(growth)))+1L)]
    growth<-growth[order(-(grepl('mic_nurse', names(growth)))+1L)]
    growth<-growth[order(-(grepl('zwei', names(growth)))+1L)]
    growth<-growth[order(-(grepl('zlen', names(growth)))+1L)]
    growth<-growth[order(-(grepl('zwfl', names(growth)))+1L)]
    growth<-growth[order(-(grepl('mean_hc', names(growth)))+1L)]
    growth<-growth[order(-(grepl('mean_length', names(growth)))+1L)]
    growth<-growth[order(-(grepl('mean_weight', names(growth)))+1L)]
    growth<-growth[order(-(grepl('.pn', names(growth)))+1L)]
    library(ggplot2)
    table(is.na(growth$mean_hc.pn),is.na(growth$mean_hc_2.12))
    hist(growth$mean_hc.pn)
    hist(growth$mean_hc_2.12)
    v.names  <-c("mean_weight","mean_length","mean_hc","zwfl","zlen","zwei","zhc")     
    growth_long<-reshape(growth, idvar = c("mother_record_id","redcap_repeat_instance"), varying = c(1:14),  direction = "long", timevar = "visit", times = c(".pn", ".12"), v.names=v.names)
    table(is.na(growth_long$mean_length),growth_long$visit)
    
    ds2$zlen_pn_12<-ds2$zlen_2.12-ds2$zlen.pn
    plot(as.factor(ds2$zikv_exposed_mom),ds2$zlen_pn_12)
    
    ggplot(data=growth_long,aes(x=visit,y=zlen))+geom_boxplot()+facet_grid("zikv_exposed_mom")
    ggplot(data=growth_long,aes(x=visit,y=zwfl))+geom_boxplot()+facet_grid("zikv_exposed_mom")
    ggplot(data=growth_long,aes(x=visit,y=zhc))+geom_boxplot()+facet_grid("zikv_exposed_mom")
    ggplot(data=growth_long,aes(x=visit,y=zwei))+geom_boxplot()+facet_grid("zikv_exposed_mom")
    
    child_outcomes <- CreateTableOne(vars = child_outcome_vars, data = ds2,strata = "zikv_exposed_mom")
    child_outcomes<-print(child_outcomes,quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE,smd=T)
    write.csv(child_outcomes, file = "child_growth.csv")
    
# define normal/abnormal --------------------------------------------------------------------
    zscores<-grep("zlen|zhc|zbmi|zwei|zwfl",names(ds2),value = T)
    abnormal<-function(x) ifelse(ds2[x] >= 2|ds2[x] <= -2, 1, ifelse(ds2[x] > -2 & ds2[x] < 2,0,NA))
    zscores_matrix<-lapply(zscores, abnormal)
    
    rename<-function(x) paste(x,"abnormal",sep=".")
    zscores<-lapply(zscores, rename)
    zscores_matrix<-as.data.frame(zscores_matrix)
    colnames(zscores_matrix)<-zscores
    ds2<-cbind(ds2,zscores_matrix)
    ds2$zhc_2.12.abnormal
    ds2$zhc.pn.abnormal
    
    zscores_matrix$zhc_2.12.abnormal
    ds2$mic_nurse_2.12<-as.numeric(as.factor(ds2$mic_nurse_2.12))-1
    child_outcomes.12<-grep(".12",names(ds2),value = T)
    child_outcomes.12<-grep("z|mic",child_outcomes.12,value = T)
    child_outcomes.12<-grep("abnormal|mic",child_outcomes.12,value = T)
    ds2$sum_growth_Outcomes_abnormal.12<-rowSums(ds2[child_outcomes.12],na.rm = T)
    table(ds2$sum_growth_Outcomes_abnormal.12)
    ggplot2::ggplot(ds2, aes(x = zikv_exposed_mom, y = sum_growth_Outcomes_abnormal.12)) + geom_boxplot() 

    child_outcomes.pn<-grep(".pn",zscores,value = T)
    child_outcomes.pn<-grep(".abnormal|mic",child_outcomes.pn,value = T)
    ds2$sum_growth_Outcomes_abnormal.pn<-rowSums(ds2[child_outcomes.pn],na.rm = T)
    table(ds2$sum_growth_Outcomes_abnormal.pn)
    ggplot2::ggplot(ds2, aes(x = zikv_exposed_mom, y = sum_growth_Outcomes_abnormal.pn)) + geom_boxplot() 

    child_outcomes<-grep("z|mic|mir|sum_growth_Outcomes_abnormal",names(ds2),value = T)
    child_outcomes<-grep("abnormal|mic|mir|sum_growth_Outcomes_abnormal",child_outcomes,value = T)
    child_outcomes_vars<-grep("pn|12",child_outcomes,value = T)
    
    child_outcomes <- CreateTableOne(vars = child_outcomes_vars, data = ds2,strata = "zikv_exposed_mom",factorVars = child_outcomes_vars)
    child_outcomes<-print(child_outcomes,quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE,smd=T,cramVars=child_outcomes_vars)
    write.csv(child_outcomes, file = "child_growth_abnormal.csv")
    
# oxnda -----------------------------------------------------------------------
#Congenital abnormalities/Complications 
#Ocular, Skeletal, Microcephaly, Seizures, Chromosomal 
#    child_outcome_vars<-grep("cong_abnormal|specify_cong_abnormal|chromosomal_abn|gait|z_seizures|red_reflex",names(ds2),value = T)
  oxnda<-read.csv("C:/Users/amykr/Box Sync/Amy Krystosik's Files/zika study- grenada/oxnda and internda data/oxnda_copy.csv")
  ds2_oxnda <- merge(ds2, oxnda, by = c("mother_record_id","redcap_repeat_instance"),all = T)


  ds2_oxnda_all<-ds2_oxnda[ds2_oxnda$perc_responses_completed>=50,]
  ds2_oxnda_10_14<-ds2_oxnda[ds2_oxnda$age.at.visit<=14 & ds2_oxnda$age.at.visit>=10 & ds2_oxnda$perc_responses_completed>=50,]
  ds2_oxnda_10_18<-ds2_oxnda[ds2_oxnda$age.at.visit<=18 & ds2_oxnda$age.at.visit>=10 & ds2_oxnda$perc_responses_completed>=50,]

  library(ggplot2)
  #age
  ggplot(data=ds2_oxnda_all, aes(x=age.at.visit, y=Mean_OXNDA_score,color=perc_responses_completed)) + geom_point() + stat_smooth(method="lm", se=FALSE)+ ggtitle("Plot of mean oxnda score by age:10-25 months")
  install.packages("ggpmisc")
  library(ggpmisc)
  
  ggplot(data=ds2_oxnda_10_18, aes(x=age.at.visit, y=Mean_OXNDA_score,color=perc_responses_completed)) + geom_point() + stat_smooth(method="lm", se=FALSE)+ ggtitle("Plot of mean oxnda score by age: 10-18 months")+geom_
  
  #parental income, education, as well as bar charts for categorical variables such as gender, Parish, etc. 
  #install.packages("ggpubr")
  library(ggpubr)
  ggplot(data=ds2_oxnda_10_18, aes(x=z_alcohol.24, y=Mean_OXNDA_score)) + geom_boxplot() + stat_smooth(method="lm", se=FALSE)+ ggtitle("Plot of mean oxnda score \n by alcohol use\n (10-18 months)")+ stat_compare_means()
  ggplot(data=ds2_oxnda_10_18, aes(x=z_alcohol_amount.24, y=Mean_OXNDA_score)) + geom_boxplot() + stat_smooth(method="lm", se=FALSE)+ ggtitle("Plot of mean oxnda score \n by alcohol use amount \n (10-18 months)")+ stat_compare_means() + theme(axis.text.x = element_text(angle = 45, hjust = 1))+ stat_compare_means() + theme(axis.text.x = element_text(angle = 45, hjust = 1))
  ggplot(data=ds2_oxnda_10_18, aes(x=z_smoking.24, y=Mean_OXNDA_score)) + geom_boxplot() + stat_smooth(method="lm", se=FALSE)+ ggtitle("Plot of mean oxnda score \n by tobacco use \n (10-18 months)")+ stat_compare_means() + theme(axis.text.x = element_text(angle = 45, hjust = 1))+ stat_compare_means() + theme(axis.text.x = element_text(angle = 45, hjust = 1))
  ggplot(data=ds2_oxnda_10_18, aes(x=z_drugs.24, y=Mean_OXNDA_score)) + geom_boxplot() + stat_smooth(method="lm", se=FALSE)+ ggtitle("Plot of mean oxnda score \n by drug use \n (10-18 months)")+ stat_compare_means() + theme(axis.text.x = element_text(angle = 45, hjust = 1))+ stat_compare_means() + theme(axis.text.x = element_text(angle = 45, hjust = 1))
  ggplot(data=ds2_oxnda_10_18, aes(x=breastfeed.12, y=Mean_OXNDA_score)) + geom_boxplot() + stat_smooth(method="lm", se=FALSE)+ ggtitle("Plot of mean oxnda score \n by breastfeed \n (10-18 months)")+ stat_compare_means() + theme(axis.text.x = element_text(angle = 45, hjust = 1))+ stat_compare_means() + theme(axis.text.x = element_text(angle = 45, hjust = 1))
  
  ggplot(data=ds2_oxnda_10_18, aes(x=education.mom.cat, y=Mean_OXNDA_score)) + geom_boxplot() + stat_smooth(method="lm", se=FALSE)+ ggtitle("Plot of mean oxnda score \n by maternal highest education category \n (10-18 months)")+ stat_compare_means()
  
  ds2_oxnda_10_18 <- within(ds2_oxnda_10_18, monthly_income.mom[ds2_oxnda_10_18$monthly_income.mom=="Refused/Don't know"] <- NA)
  ds2_oxnda_10_18$monthly_income.mom <- ordered(ds2_oxnda_10_18$monthly_income.mom, levels = c("Under $1000 EC", "$1,001-2,000 EC","$2,001-3000 EC", "Over $3000 EC"))
  ggplot(data=ds2_oxnda_10_18, aes(x=monthly_income.mom, y=Mean_OXNDA_score)) + geom_boxplot() + stat_smooth(method="lm", se=FALSE)+ ggtitle("Plot of mean oxnda score \n by household monthly income category \n (10-18 months)")+ stat_compare_means() + theme(axis.text.x = element_text(angle = 45, hjust = 1))
  
  ggplot(data=ds2_oxnda_10_18, aes(x=gender.pn, y=Mean_OXNDA_score)) + geom_boxplot() + stat_smooth(method="lm", se=FALSE)+ ggtitle("Plot of mean oxnda score \n by child gender \n (10-18 months)")+ stat_compare_means() + theme(axis.text.x = element_text(angle = 45, hjust = 1))+ stat_compare_means() + theme(axis.text.x = element_text(angle = 45, hjust = 1))
  ggplot(data=ds2_oxnda_10_18, aes(x=parish.mom, y=Mean_OXNDA_score)) + geom_boxplot() + stat_smooth(method="lm", se=FALSE)+ ggtitle("Plot of mean oxnda score \n by parish \n (10-18 months)")+ stat_compare_means() + theme(axis.text.x = element_text(angle = 45, hjust = 1))
  ggplot(data=ds2_oxnda_10_18, aes(x=latrine_type.mom, y=Mean_OXNDA_score)) + geom_boxplot() + stat_smooth(method="lm", se=FALSE)+ ggtitle("Plot of mean oxnda score \n by latrine type as proxy of wealth \n (10-18 months)")+ stat_compare_means() + theme(axis.text.x = element_text(angle = 45, hjust = 1))
  ggplot(data=ds2_oxnda_10_18, aes(x=occupation.mom, y=Mean_OXNDA_score)) + geom_boxplot() + stat_smooth(method="lm", se=FALSE)+ ggtitle("Plot of mean oxnda score \n by maternal occupation \n (10-18 months)")+ stat_compare_means() + theme(axis.text.x = element_text(angle = 45, hjust = 1))
  
  
  ggplot(data=ds2_oxnda_10_18, aes(x=zikv_exposed_mom, y=Mean_OXNDA_score)) + geom_boxplot() + stat_smooth(method="lm", se=FALSE)+ ggtitle("Plot of mean oxnda score \n by maternal occupation \n (10-18 months)")+ stat_compare_means() + theme(axis.text.x = element_text(angle = 45, hjust = 1))
  hist(ds2_oxnda_10_18$Mean_OXNDA_score,breaks = 50)

  ggplot(data=ds2_oxnda_10_18, aes(x=age.at.visit, y=Mean_OXNDA_score,color=perc_responses_completed)) + geom_point() + stat_smooth(method="lm", se=FALSE)+facet_grid("zikv_exposed_mom")

  child_outcomes_vars<-names(oxnda[6:103])
  child_outcomes <- CreateTableOne(vars = child_outcomes_vars, data = ds2_oxnda, strata = "zikv_exposed_mom")
  child_outcomes<-print(child_outcomes,quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE,smd=T)
  write.csv(child_outcomes, file = "oxnda_normal.csv")

  library("PerformanceAnalytics")

  continous <- ds2_oxnda_10_18[, c("Mean_OXNDA_score","mom_age_delivery","gestational_weeks_2_2.12","age.at.visit","perc_responses_completed")]
  cat <- c("zikv_exposed_mom","breastfeed.12","z_alcohol.24","monthly_income.mom","gender.pn","parish.mom", "occupation.mom","latrine_type.mom","education.mom.cat")
  catcorrm <- function(vars, dat) sapply(vars, function(y) sapply(vars, function(x) assocstats(table(dat[,x], dat[,y]))$cramer))
  mydata <- ds2_oxnda_10_18[, c("Mean_OXNDA_score","mom_age_delivery","gestational_weeks_2_2.12","age.at.visit","zikv_exposed_mom","breastfeed.12","z_alcohol.24","monthly_income.mom","gender.pn","parish.mom", "occupation.mom","latrine_type.mom","education.mom.cat","perc_responses_completed")]
  mydata[,cat] <- lapply(mydata[,cat],as.factor)
  mydata[,cat] <- lapply(mydata[,cat],as.numeric)
  cor(mydata,use="pairwise.complete.obs",method = "pearson")
  chart.Correlation(mydata, histogram=TRUE, pch=19,method ="pearson")
  
  tiff("correlations.png",width = 2000,height = 2000,units = "px")
    chart.Correlation(mydata, histogram=TRUE, pch=19,method ="pearson")
  dev.off()
  
  cat_cor<-catcorrm(cat,ds2_oxnda_10_18)
  chart.Correlation(continous, histogram=TRUE, pch=19)

  oxnda_model1<-R2BayesX::bayesx(Mean_OXNDA_score~as.factor(zikv_exposed_mom)+
                                   perc_responses_completed+
                                   as.factor(breastfeed.12)+
                                   #as.factor(z_alcohol.24)+
                                   monthly_income.mom +
                                   as.factor(gender.pn)+
                                   as.factor(parish.mom)+
                                   as.factor(occupation.mom)+
                                   as.factor(latrine_type.mom)+
                                   mom_age_delivery+
                                   as.factor(education.mom.cat)+
                                   gestational_weeks_2_2.12+
                                   age.at.visit,
                                  data=ds2_oxnda_10_18,
                                 method="REML", 
                                 family="gaussian",
                                 na.rm=T)
  plot(oxnda_model1)
  summary(oxnda_model1)
  
oxnda_model2<-R2BayesX::bayesx(Mean_OXNDA_score~as.factor(zikv_exposed_mom)+
                                  sx(perc_responses_completed,bs="ps")+
                                  as.factor(breastfeed.12)+
                                   #as.factor(z_alcohol.24)+
                                   as.factor(monthly_income.mom)+
                                   as.factor(gender.pn)+
                                   as.factor(parish.mom)+
                                   as.factor(occupation.mom)+
                                   as.factor(latrine_type.mom)+
                                   sx(mom_age_delivery,bs = "ps")+
                                   as.factor(education.mom.cat)+
                                   sx(gestational_weeks_2_2.12,bs = "ps")+
                                   sx(age.at.visit,bs = "ps"),
                                 data=ds2_oxnda_10_18,
                                 method="STEP", 
                                 family="gaussian",
                                 na.rm=T)
  
  plot(oxnda_model2)
  summary(oxnda_model2)
  
  
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
    
    
    child_outcome_vars<-grep("cong_abnormal|specify_cong_abnormal|chromosomal_abn|gait|z_seizures|red_reflex",names(ds2),value = T)
    child_outcome_vars.pn<-grep(".12.abnormal",child_outcome_vars,value = T)
    child_outcome_vars.12<-grep(".12.abnormal",child_outcome_vars,value = T)
    ds2$sum_Congenital_Outcomes_abnormal.12<-rowSums(ds2[child_outcome_vars.12],na.rm = T)
    ds2$sum_Congenital_Outcomes_abnormal.pn<-rowSums(ds2[child_outcome_vars.pn],na.rm = T)
    child_outcome_vars<-grep("cong_abnormal|specify_cong_abnormal|chromosomal_abn|gait|z_seizures|red_reflex|sum_Congenital",names(ds2),value = T)
    child_outcome_vars<-grep(".pn.abnormal|.12.abnormal|sum_Congenital",child_outcome_vars,value = T)
    
    child_outcomes <- CreateTableOne(vars = child_outcome_vars, data = ds2,strata = "zikv_exposed_mom")
    child_outcomes<-print(child_outcomes,quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE,smd=T,test=F)
    write.csv(child_outcomes, file = "Congenital_abnormalities_Complications_abnormal.csv")
    
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

# zika -------------------------------------------------------------------
ds2$sum_outcomes.pn<-rowSums(ds2[,c("sum_delivery_Outcomes_abnormal.pn","sum_Congenital_Outcomes_abnormal.pn","sum_growth_Outcomes_abnormal.pn")],na.rm = T)
table(ds2$sum_outcomes.pn)
ds2$sum_outcomes.12<-rowSums(ds2[,c("sum_delivery_Outcomes_abnormal.12","sum_Congenital_Outcomes_abnormal.12","sum_growth_Outcomes_abnormal.12")],na.rm = T)
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
ggplot(ds3, aes(x = factor(zikv_exposed_mom), y = sum_outcomes)) + geom_boxplot()


m1<-R2BayesX::bayesx(sum_outcomes~0,
                     data=ds3,method="REML", family="poisson",zipdistopt = "zip",criterion = "MSEP")

m2<-R2BayesX::bayesx(sum_outcomes.pn~as.factor(zikv_exposed_mom)+sx(mom_age_delivery)+as.factor(education.mom.cat)+sx(gestational_weeks_2_2.12),
                     data=ds3,method="REML", family="poisson",zipdistopt = "zip",criterion = "MSEP",na.rm=T)

m3<-R2BayesX::bayesx(sum_outcomes.pn~as.factor(zikv_exposed_mom)+sx(mom_age_delivery)+as.factor(education.mom.cat)+sx(gestational_weeks_2_2.12),
                     data=ds3,method="STEP", family="poisson",zipdistopt = "zip",criterion = "MSEP",na.rm=T)

summary(c(m1,m2,m3))
exp(coef(m2))

plot(m2)