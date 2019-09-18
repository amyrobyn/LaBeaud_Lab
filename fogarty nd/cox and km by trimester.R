library(readr)
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/fogarty chikv")
cohort <- read_csv("C:/Users/amykr/Box Sync/Amy Krystosik's Files/fogarty chikv/FogartyNDCHIKV_DATA_2019-02-07_1043.csv")

cohort$strata5<-NA
cohort<-within(cohort, strata5[result_mother==1 & pregnant==0]<-0)
cohort <- within(cohort, strata5[result_mother==1 & pregnant ==1&symptoms___4==1&(symptoms___1==1|symptoms___3==1|symptoms___5==1|symptoms___6==1|symptoms___25==1)] <- 1)

strata5_excluded<-cohort[which(is.na(cohort$strata5)),]
table(cohort$strata5,exclude = NULL)

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

### survival analysis 
cohort$today<-cohort$primary_date
cohort$last_week<-cohort$primary_date-7
cohort$last_month<-cohort$primary_date-30
cohort$onset<-cohort$when

cohort<-within(cohort, trimester[is.na(trimester)]<-99)
table(cohort$trimester,cohort$pregnant)

cohort<-cohort[!(cohort$pregnant==1 & cohort$trimester==99),]

cohort<-within(cohort, pregnant[pregnant ==99]<-NA)
cohort$pregnant <- droplevels(cohort$pregnant)
cohort$pregnant <- factor(cohort$pregnant, levels=c(0,1),
                          labels=c('Not Pregnant','Pregnant'))
cohort$strata5 <- factor(cohort$strata5, levels=c(0,1),
                         labels=c('Not Pregnant','Pregnant'))

levels(cohort$pregnant)
table(cohort$pregnant,cohort$trimester)

cohort_covariates<-cohort[c("participant_id","mother_age","race","trimester","pregnant")]
names(cohort_covariates)<-c("id", "mother_age","race","trimester","pregnant")
cohort_covariates<-subset(cohort_covariates,!duplicated(cohort_covariates$id))
cohort_long<-cohort[c("participant_id","strata5","onset","joint_pain_today", "joint_pain_last_week", "joint_pain_last_month","last_week","last_month","today")]
names(cohort_long)<-c("id", "strata5","onset","jp_today","jp_lastweek","jp_lastmonth", "date_lastweek","date_lastmonth","date_today")
cohort_long<-as.data.frame(subset(cohort_long,!duplicated(cohort_long$id)))

cohort_long<-reshape(cohort_long, varying = 4:9, timevar = "when", idvar = "id", direction="long",sep="_")
cohort_long<-merge(cohort_long,cohort_covariates,by="id")

library(survival)
#install.packages("survminer")
library(survminer)
library(dplyr)
cohort_long$fu<-as.numeric(cohort_long$date-cohort_long$onset)
cohort_long$jp_cure<-NA
cohort_long <- within(cohort_long, jp_cure[jp==0] <- 1)
cohort_long <- within(cohort_long, jp_cure[jp==1] <- 0)
table(cohort_long$jp_cure)
require("survival")

table(cohort_long$strata5,cohort_long$trimester)


fit <-survfit(Surv(fu, jp) ~ strata5 + trimester, data=cohort_long)
ggsurvplot(fit, data = cohort_long, legend = "top", surv.median.line = "hv", legend.title = "CHIKV Infection Timing",
            pval = TRUE, conf.int = TRUE, risk.table = TRUE, tables.height = 0.2, tables.theme = theme_cleantable(), ggtheme = theme_bw())+xlab("Time (days from acute infection)")+ylab("Persistance of joint pain")

tiff(filename = "joint_paint_preg.tiff",width = 5200, height = 4200, units = "px", res = 800)
ggsurvplot(fit, data = cohort_long, legend = "top", surv.median.line = "hv", legend.title = "CHIKV Infection Timing", legend.labs = c("Exp. Outside Pregnancy", "Exp. T. 1","Exp. T. 2","Exp. T. 3" ), pval = TRUE, conf.int = TRUE, risk.table = TRUE, tables.height = 0.2, tables.theme = theme_cleantable(), ggtheme = theme_bw())+xlab("Time (days from acute infection)")+ylab("Persistance of joint pain")
dev.off()   
cohort_long$strata5<-as.factor(cohort_long$strata5)
cohort_long$trimester<-as.factor(cohort_long$trimester)
### cox ph model of joint pain by group ---------------------------------------------------------------
cohort_long$mother_age<-as.integer(cohort_long$mother_age)
summary(coxph(Surv(fu, jp) ~ strata5 + mother_age + trimester, cohort_long),na.action="na.omit")
