# import data ---------------------------------------------------------------------
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long")
load("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long/R01_lab_results 2018-09-28 .rda")
growth.over.time<-R01_lab_results
list<-c("u24_weight","child_weight","child_weight","child_weight_aic", 
        "u24_height_stad","u24_height_mt","u24_height","child_height","child_height_aic",
        "gender","gender_aic","u24_gender", "age_calc","age_calc_rc","u24_child_age","u24_age_calc","aic_calculated_age","person_id","redcap_event_name")
growth.over.time<-as.data.frame(growth.over.time[list])
growth.over.time$weight <- rowMeans(growth.over.time[, c("u24_weight","child_weight","child_weight","child_weight_aic")], na.rm=TRUE) 
growth.over.time$height <- rowMeans(growth.over.time[, c("u24_height_stad","u24_height_mt","u24_height","child_height","child_height_aic")], na.rm=TRUE) 
growth.over.time$sex <- rowMeans(growth.over.time[, c("gender","gender_aic","u24_gender")], na.rm=TRUE) 
growth.over.time$age <- rowMeans(growth.over.time[,c("age_calc","age_calc_rc","u24_child_age","u24_age_calc","aic_calculated_age")], na.rm=TRUE) 

#growth.over.time<-readxl::read_excel("C:/Users/amykr/Box Sync/U24 Project/nutrition/growth over time.xlsx")

growth.over.time <- within(growth.over.time, sex[growth.over.time$sex==1] <-"f")
growth.over.time <- within(growth.over.time, sex[growth.over.time$sex==0] <-"m")
z_scores<-growth.over.time[c("person_id","redcap_event_name","height","sex","weight","age")]

library(tidyr)
z_scores<-z_scores %>% drop_na(height,age,sex,weight)
z_scores$agemonth<-as.numeric(round(z_scores$age*12,1))
z_scores$age<-as.numeric(round(z_scores$age,1))

# 0-5 ---------------------------------------------------------------------
setwd("C:/Program Files/R/R-3.3.2/library/igrowup_R/")
weianthro<-read.table("weianthro.txt",header=T,sep="",skip=0)
lenanthro<-read.table("lenanthro.txt",header=T,sep="",skip=0)
bmianthro<-read.table("bmianthro.txt",header=T,sep="",skip=0)
hcanthro<-read.table("hcanthro.txt",header=T,sep="",skip=0)
acanthro<-read.table("acanthro.txt",header=T,sep="",skip=0)
ssanthro<-read.table("ssanthro.txt",header=T,sep="",skip=0)
tsanthro<-read.table("tsanthro.txt",header=T,sep="",skip=0)
wflanthro<-read.table("wflanthro.txt",header=T,sep="",skip=0)
wfhanthro<-read.table("wfhanthro.txt",header=T,sep="",skip=0)

source("igrowup_standard.r")
source("igrowup_restricted.r")

lessthan5<-as.data.frame(z_scores[which(z_scores$age<=5),])
igrowup.standard(mydf=lessthan5, sex=sex, age = agemonth, age.month=T, weight=weight, lenhei=height, FilePath = "C:/Users/amykr/Box Sync/Amy Krystosik's Files/secure- u24 participants/data",FileLab="z_scores_under5_long")

# 5-19 --------------------------------------------------------------------
setwd("C:/Program Files/R/R-3.3.2/library/who2007_R/")
wfawho2007<-read.table("wfawho2007.txt",header=T,sep="",skip=0)
hfawho2007<-read.table("hfawho2007.txt",header=T,sep="",skip=0)
bfawho2007<-read.table("bfawho2007.txt",header=T,sep="",skip=0)
source("who2007.r")
fiveplus<-as.data.frame(z_scores[which(z_scores$age>5),])
who2007(mydf=fiveplus, sex=sex, age=agemonth, weight=weight,height=height, FilePath = "C:/Users/amykr/Box Sync/Amy Krystosik's Files/secure- u24 participants/data",FileLab="z_scores_5plus_long")
