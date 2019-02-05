library(readr)
ds <- read_csv("C:/Users/amykr/Downloads/FogartyNDCHIKV_DATA_2018-07-30_1326.csv")
# duration of jp ----------------------------------------------------------
ds$dd<-as.numeric(ds$primary_date-ds$when)
ds$duration<-ifelse(ds$joint_pain_last_month==1,ds$dd-30,NA)
ds$duration<-ifelse(ds$joint_pain_last_week==1,ds$dd-7,ds$duration)
ds$duration<-ifelse(ds$joint_pain_today==1,ds$dd,ds$duration)
ds$pregnant<-as.factor(ds$pregnant)
ggplot<-ggplot(ds,aes(x=pregnant,y=duration))
ggplot + geom_boxplot()


library(statar)
ds$dd_cat<-xtile(ds$dd, n = 10)
table(ds$dd_cat)
hist(ds$dd)

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
ds<-ds[c("participant_id","pregnant","onset","joint_pain_today", "joint_pain_last_week", "joint_pain_last_month","last_week","last_month","today")]
names(ds)<-c("id", "pregnant","onset","jp_today","jp_lastweek","jp_lastmonth", "date_lastweek","date_lastmonth","date_today")
ds<-subset(ds,!duplicated(ds$id))
ds<-as.data.frame(ds)

ds_long<-reshape(ds, varying = 4:9, timevar = "when", idvar = "id", direction="long",sep="_")
library(survival)
#install.packages("survminer")
library(survminer)
library(dplyr)
ds_long$fu<-as.numeric(ds_long$date-ds_long$onset)
ds_long <- within(ds_long, pregnant[pregnant==99] <- NA)
ds_long <- within(ds_long, jp_cure[jp==0] <- 1)
ds_long <- within(ds_long, jp_cure[jp==1] <- 0)

surv_object <- Surv(time = ds_long$fu, event = ds_long$jp)
fit1 <- survfit(surv_object ~ pregnant, data = ds_long)
summary(fit1)
ggsurvplot(fit1, data = ds_long, pval = TRUE)
