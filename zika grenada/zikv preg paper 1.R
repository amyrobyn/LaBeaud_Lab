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

load("zika 2019-06-24 .rda")
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
    ds2 <- within(ds2, zikv_exposed_mom[ds2$result_zikv_igg_pgold.mom=="Negative"|ds2$result_zikv_igg_pgold_fu.mom=="Negative"] <- "mom zikv Unexposed")
    ds2 <- within(ds2, zikv_exposed_mom[ds2$pcr_positive_zikv_mom=="Positive"|ds2$result_zikv_igg_pgold.mom=="Positive"|ds2$result_zikv_igg_pgold_fu.mom=="Positive"] <- "mom ZIKV Exposed")
    
    table(ds2$zikv_exposed_mom,ds2$redcap_repeat_instance, exclude = NULL)
    table(ds2$pcr_positive_zikv_mom=="Positive"|ds2$result_zikv_igg_pgold.mom=="Positive",ds2$cohort___1.mom,ds2$redcap_repeat_instance, exclude = NULL)
    table(ds2$pcr_positive_zikv_mom=="Positive"|ds2$result_zikv_igg_pgold.mom=="Positive",ds2$cohort___2.mom,ds2$redcap_repeat_instance, exclude = NULL)
    
#child zikv exposure
    ds2$zikv_exposed_child<-NA
    ds2 <- within(ds2, zikv_exposed_child[ds2$result_zikv_igg_pgold.pn=="Negative"|ds2$result_zikv_igg_pgold.12=="Negative"|ds2$result_zikv_igg_pgold.24=="Negative"|ds2$result_zikv_igg_pgold.27=="Negative"] <- "child ZIKV Unexposed")
    ds2 <- within(ds2, zikv_exposed_child[ds2$result_zikv_igg_pgold.pn=="Positive"|ds2$result_zikv_igg_pgold.12=="Positive"|ds2$result_zikv_igg_pgold.24=="Positive"|ds2$result_zikv_igg_pgold.27=="Positive"] <- "child ZIKV Exposed")
    
    table(ds2$zikv_exposed_child,ds2$redcap_repeat_instance, exclude = NULL)

    table(ds2$zikv_exposed_child,ds2$zikv_exposed_mom, exclude = NULL)

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
    
#calculate dad age at deliery and remove outliers over 80 and under 15
  ds2$dad_age_delivery<-as.numeric(round((as.Date(ds2$delivery_date.pn)-lubridate::as_date(ds2$partner_dob.mom))/365,1))
  ds2 <- within(ds2, dad_age_delivery[ds2$dad_age_delivery<15|ds2$dad_age_delivery>80] <- NA)
  
#Table 1: Maternal demographics of cohort by exposure status: age, education, income, geography: home parish, medical history, marital status, paternal age, occupation

    factor <- c("coil.mom","repellent.mom","occupation.mom","marrital_status.mom","education.mom","monthly_income.mom","delivery_type.pn", "cong_abnormal.pn", "gender.pn","parish.mom","previous_pregnancy.mom") 
    ds2[factor] <- lapply(ds2[factor], as.factor) 
    tab1vars <- c("parish.mom","mom_age_delivery","occupation.mom","medical_conditions___1.mom","medical_conditions___2.mom","medical_conditions___3.mom","medical_conditions___4.mom","medical_conditions___5.mom","medical_conditions___6.mom","medical_conditions___7.mom","medical_conditions___8.mom","medical_conditions___9.mom","medical_conditions___10.mom","medical_conditions___11.mom","medical_conditions___12.mom","medical_conditions___13.mom","medical_conditions___14.mom","previous_pregnancy.mom","repellent.mom","coil.mom","marrital_status.mom","education.mom","monthly_income.mom","dad_age_delivery")
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
    p.adjust(p, method = p.adjust.methods)
    

# figure 1: Frequency boxplots of symptoms amongst zika positive moms: zika symptoms at antenatal visit or recall symptoms during pregnancy.  -----------------------------------------------------------------
source("C:/Users/amykr/Documents/GitHub/LaBeaud_lab/zika grenada/symptoms combined.R")
ds2<-merge(ds2,symptoms_zika,by="mother_record_id",all.x = T)

ds2$cohort<-NA
ds2 <- within(ds2, cohort[ds2$cohort___3.mom=="Checked"] <- "Zika Follow Up")
ds2 <- within(ds2, cohort[ds2$cohort___1.mom=="Checked"] <- "Original Pregnancy")
ds2 <- within(ds2, cohort[ds2$cohort___2.mom=="Checked"] <- "Febrile Zika")
table(ds2$cohort)

zikv_pos<-subset(ds2,ds2$zikv_exposed_mom=="ZIKV Exposed")

symptoms_zika_var<-names(ds2[,c(1160:1195)])
symptoms_zika_var<-rlist::list.append(symptoms_zika_var,"trimester.mom")

symptoms_zika <- CreateTableOne(vars = symptoms_zika_var, data = zikv_pos , factorVars = symptoms_zika_var)
symptoms_zika<-print(symptoms_zika,quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE,cramVars = symptoms_zika_var)
write.csv(symptoms_zika, file = "symptoms_zika.csv")

symptoms_zika <- CreateTableOne(vars = symptoms_zika_var, data = zikv_pos,strata="cohort" , factorVars = symptoms_zika_var)
symptoms_zika<-print(symptoms_zika,quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE,cramVars = symptoms_zika_var,smd=T)
write.csv(symptoms_zika, file = "symptoms_zika_strata.csv")

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

#define otucomes
#Table 2: a. child birth outcomes nurse assessment form postnatal:anthropometric, birth complication; b. child 12-month outcomes: strength, deep tendon reflexes --------
    ds2<-ds2 %>% select(sort(names(.)))
#    ds2<-ds2[, !(colnames(ds2) %in% c("term_2.pn","gender_2.12","child_bmi.pn"))]
  #Delivery Outcomes, growth parameters, and congenital abnormalities/complications
  #Term Pre-term, Gestational Weeks, Delivery Type, Apgars, Outcome of Delivery - include respiratory distress, meconium aspiration, intrapartum fever; Neonatal Resuscitation required, Clinical parameters (fontanelles, sutures, dysmorphic facial features, cleft lip palate, reflexes). Seizures 
    child_outcome_vars.delivery<-grep("term_2|gestational_weeks_2_2|delivery_type|apgar_one|apgar_five|apgar_ten|outcome_of_delivery|neonatal_resusitation|ant_fontanelle|sutures|facial_dysmoph|cleft|red_reflex|plantar_reflex|galant_reflex|suck|grasp|moro",names(ds2),value = T)
    child_outcomes <- CreateTableOne(vars = child_outcome_vars.delivery, data = ds2,strata = "zikv_exposed_mom")
    child_outcomes<-print(child_outcomes,quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE,smd=T)
    write.csv(child_outcomes, file = "Delivery_Outcomes.csv")
    
    #growth
    #Birth: Z-scores for BMI, length, weight, and head circumference and microcephaly
    #12 month visit: Z-scores for BMI, length, weight, and head circumference and microcephaly
    child_outcome_vars<-grep("zhei|zlen|zhc|zbmi|zwei|zwfl|mic",names(ds2),value = T)
    child_outcome_vars.pn<-grep(".pn",child_outcome_vars,value=T)
    child_outcome_vars.12<-grep(".12",child_outcome_vars,value=T)
    
    child_outcomes <- CreateTableOne(vars = child_outcome_vars, data = ds2,strata = "zikv_exposed_mom")
    child_outcomes<-print(child_outcomes,quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE,smd=T)
    write.csv(child_outcomes, file = "child_growth.csv")

    #Congenital abnormalities/Complications 
    #Ocular, Skeletal, Microcephaly, Seizures, Chromosomal 
    child_outcome_vars<-grep("cong_abnormal|specify_cong_abnormal|chromosomal_abn|gait|z_seizures|red_reflex",names(ds2),value = T)
    child_outcomes <- CreateTableOne(vars = child_outcome_vars, data = ds2,strata = "zikv_exposed_mom")
    child_outcomes<-print(child_outcomes,quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE,smd=T)
    write.csv(child_outcomes, file = "Congenital_abnormalities_Complications.csv")

    
#other 
    child_outcome_vars<-grep("heart_rate|resp_rate|color|cry|tone|moving_limbs|cap_refill|child_referred|gender",names(ds2),value = T)
    child_outcomes <- CreateTableOne(vars = child_outcome_vars, data = ds2,strata = "zikv_exposed_mom")
    child_outcomes<-print(child_outcomes,quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE,smd=T)
    write.csv(child_outcomes, file = "other.csv")
    
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
summary(glm(mir.pn ~ result_zikv_igg_pgold, family = "binomial", data = ds2))

summary(glm(mir.pn ~ mothers_age_calc + result_zikv_igg_pgold, family = "binomial", data = ds2))

summary(glm(mir.pn ~ mothers_age_calc + relevel(result_avidity_zikv_igg_pgold, "0"), family = "binomial", data = ds2))

summary(glm(mir.pn ~ mothers_age_calc + relevel(result_avidity_zikv_igg_pgold, "0") + result_zikv_igg_pgold, family = "binomial", data = ds2))

# denv -------------------------------------------------------------------
summary(glm(mir.pn ~ result_denv_igg_pgold, family = "binomial", data = ds2))

summary(glm(mir.pn ~ mothers_age_calc + result_denv_igg_pgold, family = "binomial", data = ds2))

summary(glm(mir.pn ~ mothers_age_calc + relevel(result_avidity_denv_igg_pgold, "0"), family = "binomial", data = ds2))

summary(glm(mir.pn ~ mothers_age_calc + relevel(result_avidity_denv_igg_pgold, "0") + result_denv_igg_pgold, family = "binomial", data = ds2))

# both -------------------------------------------------------------------
summary(glm(mir.pn ~ mothers_age_calc +result_denv_igg_pgold+ relevel(result_avidity_denv_igg_pgold, "0") + result_zikv_igg_pgold + relevel(result_avidity_zikv_igg_pgold, "0"), family = "binomial", data = ds2))

# tab1 for child descriptive variables -------------------------------------------------------------------
require(tableone)
tab1vars <- c("cohort___1","cohort___2","cohort___3")
tab1_cohort <- CreateTableOne(vars = tab1vars, data = ds2, factorVars = c("delivery_type.pn", "cong_abnormal.pn", "gender.pn"))
tab1_cohort <- CreateTableOne(vars = tab1vars, strata = "mir.pn" , data = ds2, factorVars = c("delivery_type.pn", "cong_abnormal.pn", "gender.pn"))
print(tab1, smd=TRUE)

tab1 <- print(tab1, quote = FALSE, noSpaces = TRUE, printToggle = FALSE, smd=TRUE)
tab1All <- print(tab1All, quote = FALSE, noSpaces = TRUE, printToggle = FALSE, smd=TRUE)

## Save to a CSV file
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/zika study- grenada")
write.csv(tab1, file = "table1zika_20180326.csv")
write.csv(tab1All, "table1zikaOverall_20180326.csv")