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

load("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long/u24_results 2018-06-22 .rda")
u24_results$sex<-u24_results$u24_gender
u24_results <- within(u24_results, sex[u24_results$u24_gender==1] <-"f")
u24_results <- within(u24_results, sex[u24_results$u24_gender==0] <-"m")
u24_results <- within(u24_results, u24_height_stad[is.na(u24_results$u24_height_stad)] <-u24_results$u24_height_mt)
z_scores<-u24_results[c("person_id","u24_height_stad","sex","u24_weight","u24_child_age")]
library(tidyr)
table(z_scores$u24_child_age)
z_scores<-z_scores %>% drop_na(u24_height_stad,u24_age_month,sex,u24_weight)
z_scores$u24_age_month<-round(z_scores$u24_child_age*12,0)
table(z_scores$u24_age_month,exclude = NULL)
table(z_scores$u24_height_stad,exclude = NULL)
lessthan5<-z_scores[which(z_scores$u24_child_age<5),]

igrowup.standard(mydf=lessthan5, sex=sex, age=u24_age_month, age.month=T, weight=u24_weight,lenhei=u24_height_stad,FilePath = "C:/Users/amykr/Box Sync/Amy Krystosik's Files/secure- u24 participants/data",FileLab="u24_z_scores_under5")

# 5-19 --------------------------------------------------------------------
setwd("C:/Program Files/R/R-3.3.2/library/who2007_R/")
wfawho2007<-read.table("wfawho2007.txt",header=T,sep="",skip=0)
hfawho2007<-read.table("hfawho2007.txt",header=T,sep="",skip=0)
bfawho2007<-read.table("bfawho2007.txt",header=T,sep="",skip=0)
source("who2007.r")
fiveplus<-z_scores[which(z_scores$u24_child_age>=5),]
who2007(mydf=fiveplus, sex=sex, age=u24_age_month, weight=u24_weight,height=u24_height_stad,FilePath = "C:/Users/amykr/Box Sync/Amy Krystosik's Files/secure- u24 participants/data",FileLab="u24_z_scores_5plus")
