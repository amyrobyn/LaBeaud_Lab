### packages
library(REDCapR)
library(tidyr)
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/zika study- grenada")
# load data -------------------------------------------------------------------
  #Redcap.token <- readLines("Redcap.token.zika.txt") # Read API token from folder
  #REDcap.URL  <- 'https://redcap.stanford.edu/api/'
  #ds <- redcap_read(  redcap_uri  = REDcap.URL, token = Redcap.token,  batch_size = 100,raw_or_label="label")$data
  #currentDate <- Sys.Date() 
  #FileName <- paste("zika",currentDate,".rda",sep=" ") 
  #save(ds,file=FileName)

load("zika 2020-05-11 .rda")
#load("zika 2020-04-13 .rda")
#load("zika 2020-03-04 .rda")
#load("zika 2020-02-25 .rda")
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
#ds2_c <- merge(dataMoms, child, by = "mother_record_id", suffixes = c("",""))
#for only one row per mom
ds2 <- merge(dataMoms, child[child$redcap_repeat_instance==1,], by = "mother_record_id", suffixes = c("",""))

# subset to non missing collumns-------------------------------------------------------------------
ds2 <- Filter(function(x)!all(is.na(x)), ds2)
ds2 <- Filter(function(x)!all(x==""), ds2)
