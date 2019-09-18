library(readr)
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/fogarty chikv")
cohort <- read_csv("C:/Users/amykr/Box Sync/Amy Krystosik's Files/fogarty chikv/FogartyNDCHIKV_DATA_2019-02-07_1043.csv")
# duration of jp ----------------------------------------------------------
cohort$dd<-as.numeric(cohort$primary_date-cohort$when)

cohort$duration<-ifelse(cohort$joint_pain_since!=1,cohort$dd,NA)
cohort$duration<-ifelse(cohort$joint_pain_last_month==1,cohort$dd-30,NA)
cohort$duration<-ifelse(cohort$joint_pain_last_week==1,cohort$dd-7,cohort$duration)
cohort$duration<-ifelse(cohort$joint_pain_today==1,cohort$dd,cohort$duration)

cohort$pregnant<-as.factor(cohort$pregnant)
library(ggplot2)
ggplot<-ggplot(cohort,aes(x=pregnant,y=duration))
ggplot + geom_boxplot()

library(statar)
cohort$dd_cat<-xtile(cohort$dd, n = 10)
table(cohort$dd_cat)
hist(cohort$dd)
library(plyr)
library(tidyverse)
fig <- ddply(cohort, .(pregnant,dd_cat),
             summarise, 
             joint_pain_today_mean = mean(joint_pain_today, na.rm = TRUE),
             joint_pain_last_week_mean = mean(joint_pain_last_week, na.rm = TRUE),
             joint_pain_last_month_mean = mean(joint_pain_last_month, na.rm = TRUE),
             joint_pain_today_sd = sd(joint_pain_today, na.rm = TRUE),
             joint_pain_last_week_sd = sd(joint_pain_last_week, na.rm = TRUE),
             joint_pain_last_month_sd = sd(joint_pain_last_month, na.rm = TRUE)
)

# survival analysis -------------------------------------------------------
cohort$today<-cohort$primary_date
cohort$last_week<-cohort$primary_date-7
cohort$last_month<-cohort$primary_date-30
cohort$onset<-cohort$when

cohort_covariates<-cohort[c("participant_id","mother_age","race")]
names(cohort_covariates)<-c("id", "mother_age","race")
cohort_covariates<-subset(cohort_covariates,!duplicated(cohort_covariates$participant_id))
cohort_long<-cohort[c("participant_id","pregnant","onset","joint_pain_today", "joint_pain_last_week", "joint_pain_last_month","last_week","last_month","today")]
names(cohort_long)<-c("id", "pregnant","onset","jp_today","jp_lastweek","jp_lastmonth", "date_lastweek","date_lastmonth","date_today")
cohort_long<-as.data.frame(subset(cohort_long,!duplicated(cohort_long$id)))

cohort_long<-reshape(cohort_long, varying = 4:9, timevar = "when", idvar = "id", direction="long",sep="_")
cohort_long<-merge(cohort_long,cohort_covariates,by="id")

library(survival)
#install.packages("survminer")
library(survminer)
library(dplyr)
cohort_long$fu<-as.numeric(cohort_long$date-cohort_long$onset)
cohort_long <- within(cohort_long, pregnant[pregnant==99] <- NA)
cohort_long$jp_cure<-NA
cohort_long <- within(cohort_long, jp_cure[jp==0] <- 1)
cohort_long <- within(cohort_long, jp_cure[jp==1] <- 0)
table(cohort_long$jp_cure)
require("survival")
fit <-survfit(Surv(fu, jp)~pregnant, data=cohort_long)
tiff(filename = "joint_paint_preg.tiff",width = 5200, height = 4200, units = "px", res = 800)
plot<-ggsurvplot(fit, data = cohort_long, legend = "top", surv.median.line = "hv", legend.title = "CHIKV Infection Timing", legend.labs = c("Not pregnant", "Pregnant"), pval = TRUE, conf.int = TRUE, risk.table = TRUE, tables.height = 0.2, tables.theme = theme_cleantable(), palette = c("#E7B800", "#2E9FDF"), ggtheme = theme_bw())+xlab("Time (days from acute infection)")+ylab("Persistance of joint pain")
plot+guides(fill=guide_legend(nrow=2,byrow=TRUE))

dev.off()   
write.csv(cohort_long,"joint_point_duration_days.csv")
cohort_jp<-cohort[,c("pregnant","joint_pain_today","joint_pain_last_week","joint_pain_last_month","onset","joint_pain_since","participant_id")]
write.csv(cohort_jp,"joint_point.csv")

fit <-survfit(Surv(fu, jp)~pregnant, data=cohort_long)
summary( coxph(Surv(fu, jp) ~ pregnant+ mother_age , cohort_long),na.action="omit")

cox<-coxph(fit, data=cohort_long,na.action="omit")
      
      , init, control, 
      ties=c("efron","breslow","exact"), 
      singular.ok=TRUE, robust=FALSE, 
      model=FALSE, x=FALSE, y=TRUE, tt, method, ...)