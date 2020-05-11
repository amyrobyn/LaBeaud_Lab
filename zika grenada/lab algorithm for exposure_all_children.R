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

load("zika 2020-01-20 .rda")
#load("zika 2019-12-02 .rda")
#load("zika 2019-09-29 .rda")
#load(FileName)
#ds<-read.csv("ZikaPregnancyCohort_DATA_2019-11-29_1743.csv")
ds<-dplyr::filter(ds, !grepl("--",mother_record_id))
ds <-ds %>% mutate_all(na_if,"")

library(Hmisc)
Hmisc::describe(ds$z_mainsurvey_date_dmy)
write.csv(ds,"ds.csv",na='')

# merge -------------------------------------------------------------------
library(dplyr)
table(ds$redcap_event_name)
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

child <- merge(child, data27, by = c("mother_record_id","redcap_repeat_instance"), all.x=T)
child <- merge(child, data30, by = c("mother_record_id","redcap_repeat_instance"), all.x=T)

#depending on if you want only one row per mother or a row per child, use the first or the second...
  #for all children
    ds2 <- merge(dataMoms, child, by = "mother_record_id", suffixes = c("",""))
  #for only one row per mom
    #ds2 <- merge(dataMoms, child[child$redcap_repeat_instance==1,], by = "mother_record_id", suffixes = c("",""))
    table(ds2$redcap_repeat_instance)

# subset to non missing collumns-------------------------------------------------------------------
ds2 <- Filter(function(x)!all(is.na(x)), ds2)
ds2 <- Filter(function(x)!all(x==""), ds2)

# tables -------------------------------------------------------------------
#zikv exposure
    ds2$pcr_positive_zikv_mom<-NA
    ds2 <- within(ds2, pcr_positive_zikv_mom[ds2$result_zikv_urine_mom.mom=="Negative"|ds2$result_zikv_serum_mom.mom=="Negative"] <- "Negative")
    ds2 <- within(ds2, pcr_positive_zikv_mom[ds2$result_zikv_urine_mom.mom=="Positive"|ds2$result_zikv_serum_mom.mom=="Positive"] <- "Positive")

    source("C:/Users/amykr/Documents/GitHub/LaBeaud_lab/zika grenada/maternal_exposure_strata_3.R")#change to maternal_exposure_strata_2.R to switch strata for total analysis.

    #check mother PZ182.
    subset(ds2, pcr_positive_zikv_mom == 'Positive', c(mom_id_orig_study_2.mom,mom_id_orig_study.mom,mother_record_id,zikv_exposed_mom,pcr_positive_zikv_mom,result_zikv_igg_pgold.mom,result_zikv_igg_pgold_fu.mom))
    table(ds2$mom_id_orig_study_2.mom)
    
    table(ds2$zikv_exposed_mom,ds2$result_zikv_igg_pgold.pn, exclude = NULL)
    table(ds2$zikv_exposed_mom,ds2$result_zikv_igg_pgold.12, exclude = NULL)
    ds2$date_assessment.pn<-as.Date(ds2$date_assessment.pn,format='%Y-%m-%d')
    ds2$date_assessment_2.12<-as.Date(ds2$date_assessment_2.12,format='%Y-%m-%d')
    
    ds2$days_pn_12<-as.numeric(round((as.Date(as.character(ds2$date_assessment_2.12))-as.Date(as.character(ds2$date_assessment.pn)))/31,1))
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
    
    table(ds2$result_zikv_igg_pgold.pn)
    table(ds2$result_zikv_igg_pgold.12)
    
    addmargins(table(ds2$zikv_exposed_child, ds2$zikv_exposed_mom, ds2$redcap_repeat_instance, exclude = NULL))
    addmargins(table(ds2$zikv_exposed_child, ds2$zikv_exposed_mom, ds2$cohort, exclude = NULL))
    addmargins(table(ds2$zikv_exposed_child, ds2$zikv_exposed_mom))
    
    #vertical transmission
      library(DescTools)
      MultinomCI(table( ds2[ ds2$zikv_exposed_mom == "mom_ZIKV_Exposed_during_pregnancy" , c("zikv_exposed_child") ] ))
      MultinomCI(table( ds2[ ds2$zikv_exposed_mom == "mom_ZIKV_Exposure_possible_during_pregnancy" , c("zikv_exposed_child") ] ))
      MultinomCI(table( ds2[ ds2$zikv_exposed_mom == "mom_zikv_Unexposed_during_pregnancy" , c("zikv_exposed_child") ] ))

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
    table(ds2$zikv_exposed_mom)
    
#child denv exposure
    ds2$denv_exposed_child<-NA
    ds2 <- within(ds2, denv_exposed_child[ds2$result_denv_igg_pgold.pn=="Negative"|ds2$result_denv_igg_pgold.12=="Negative"] <- "child denv Unexposed")
    ds2 <- within(ds2, denv_exposed_child[ds2$result_denv_igg_pgold.pn=="Positive"|ds2$result_denv_igg_pgold.12=="Positive"] <- "child denv Exposed")
    table(ds2$redcap_repeat_instance)
    
#review the lab assays and algorithms
#source("C:/Users/amykr/Documents/GitHub/LaBeaud_lab/zika grenada/pgold testing child.R")