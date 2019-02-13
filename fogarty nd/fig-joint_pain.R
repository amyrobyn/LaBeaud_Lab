library(readr)
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/fogarty chikv")
ds <- read_csv("C:/Users/amykr/Box Sync/Amy Krystosik's Files/fogarty chikv/FogartyNDCHIKV_DATA_2019-02-07_1043.csv")
# duration of jp ----------------------------------------------------------
ds$dd<-as.numeric(ds$primary_date-ds$when)
ds$duration<-ifelse(ds$joint_pain_since!=1,ds$dd,NA)
ds$duration<-ifelse(ds$joint_pain_last_month==1,ds$dd-30,NA)
ds$duration<-ifelse(ds$joint_pain_last_week==1,ds$dd-7,ds$duration)
ds$duration<-ifelse(ds$joint_pain_today==1,ds$dd,ds$duration)

ds$pregnant<-as.factor(ds$pregnant)
library(ggplot2)
ggplot<-ggplot(ds,aes(x=pregnant,y=duration))
ggplot + geom_boxplot()

library(statar)
ds$dd_cat<-xtile(ds$dd, n = 10)
table(ds$dd_cat)
hist(ds$dd)
library(plyr)
library(tidyverse)
fig <- ddply(ds, .(pregnant,dd_cat),
             summarise, 
             joint_pain_today_mean = mean(joint_pain_today, na.rm = TRUE),
             joint_pain_last_week_mean = mean(joint_pain_last_week, na.rm = TRUE),
             joint_pain_last_month_mean = mean(joint_pain_last_month, na.rm = TRUE),
             joint_pain_today_sd = sd(joint_pain_today, na.rm = TRUE),
             joint_pain_last_week_sd = sd(joint_pain_last_week, na.rm = TRUE),
             joint_pain_last_month_sd = sd(joint_pain_last_month, na.rm = TRUE)
)

# survival analysis -------------------------------------------------------
ds$today<-ds$primary_date
ds$last_week<-ds$primary_date-7
ds$last_month<-ds$primary_date-30
ds$onset<-ds$when
ds_long<-ds[c("participant_id","pregnant","onset","joint_pain_today", "joint_pain_last_week", "joint_pain_last_month","last_week","last_month","today")]
names(ds_long)<-c("id", "pregnant","onset","jp_today","jp_lastweek","jp_lastmonth", "date_lastweek","date_lastmonth","date_today")
ds_long<-subset(ds_long,!duplicated(ds_long$id))
ds_long<-as.data.frame(ds_long)

ds_long<-reshape(ds_long, varying = 4:9, timevar = "when", idvar = "id", direction="long",sep="_")
library(survival)
#install.packages("survminer")
library(survminer)
library(dplyr)
ds_long$fu<-as.numeric(ds_long$date-ds_long$onset)
ds_long <- within(ds_long, pregnant[pregnant==99] <- NA)
ds_long$jp_cure<-NA
ds_long <- within(ds_long, jp_cure[jp==0] <- 1)
ds_long <- within(ds_long, jp_cure[jp==1] <- 0)
table(ds_long$jp_cure)
require("survival")
fit <-survfit(Surv(fu, jp)~pregnant, data=ds_long)
tiff(filename = "joint_paint_preg.tiff",width = 5200, height = 4200, units = "px", res = 800)
ggsurvplot(fit, data = ds_long, legend = "bottom", surv.median.line = "hv", legend.title = "CHIKV Infection Timing", legend.labs = c("Outside of Prenancy", "During Pregnancy"), pval = TRUE, conf.int = TRUE, risk.table = TRUE, tables.height = 0.2, tables.theme = theme_cleantable(), palette = c("#E7B800", "#2E9FDF"), ggtheme = theme_bw())+xlab("Days of Follow Up Time")+ylab("Probability of Not Reporting Joint Pain")
dev.off()   
write.csv(ds_long,"joint_point_duration_days.csv")
ds_jp<-ds[,c("pregnant","joint_pain_today","joint_pain_last_week","joint_pain_last_month","onset","joint_pain_since","participant_id")]
write.csv(ds_jp,"joint_point.csv")
