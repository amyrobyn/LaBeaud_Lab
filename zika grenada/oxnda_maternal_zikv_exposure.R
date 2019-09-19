# oxnda -----------------------------------------------------------------------
#  oxnda<-read.csv("C:/Users/amykr/Box Sync/Amy Krystosik's Files/zika study- grenada/oxnda and internda data/oxnda_copy.csv")

ds2 <- within(ds2, redcap_repeat_instance[ds2$redcap_repeat_instance=="C1"] <- 1)
ds2 <- within(ds2, redcap_repeat_instance[ds2$redcap_repeat_instance== "C2"] <-2)

ds2$zikv_exposed_mom<-  as.factor(ds2$zikv_exposed_mom)
levels(ds2$zikv_exposed_mom)[levels(ds2$zikv_exposed_mom)=="mom_ZIKV_Exposed_during_pregnancy"] <- "Probably ZIKV Infected During Pregnancy"
levels(ds2$zikv_exposed_mom)[levels(ds2$zikv_exposed_mom)=="mom_ZIKV_Exposure_possible_during_pregnancy"] <- "Possibly ZIKV Infected During Pregnancy"
levels(ds2$zikv_exposed_mom)[levels(ds2$zikv_exposed_mom)=="mom_zikv_Unexposed_during_pregnancy"] <- "Not ZIKV Infected"

oxnda<-read.csv("C:/Users/amykr/Box Sync/Amy Krystosik's Files/zika study- grenada/oxnda and internda data/OX-NDA Data_August 2019 _rescored.csv")
#replace all 'X' in oxnda with NA
#oxnda[oxnda=="X"]<-NA
oxnda$age.at.visit_months<-oxnda$Chronological_age_in_days/30
hist(oxnda$Chronological_age_in_days)
hist(oxnda$age.at.visit_months)
hist(oxnda$perc_responses_completed)
#oxnda<-sapply(oxnda,as.numeric)
ds2_oxnda <- merge(ds2, oxnda, by = c("mother_record_id","redcap_repeat_instance"),all.x = T)
library(Hmisc)
#label(ds2_oxnda$perc_responses_completed) <- "Percent Of Responses Completed" 

table(ds2_oxnda$zikv_exposed_mom,ds2_oxnda$perc_responses_completed>=50,exclude = NA)

#age
ds2_oxnda_all<-ds2_oxnda[ds2_oxnda$perc_responses_completed>=50,]
ds2_oxnda_10_14<-ds2_oxnda[ds2_oxnda$age.at.visit_months<=14 & ds2_oxnda$age.at.visit_months>=10 & ds2_oxnda$perc_responses_completed>=50,]
ds2_oxnda_10_18<-ds2_oxnda[ds2_oxnda$age.at.visit_months<=18 & ds2_oxnda$age.at.visit_months>=10 & ds2_oxnda$perc_responses_completed>=50,]
library(ggplot2)

ggplot(data=ds2_oxnda_all[!is.na(ds2_oxnda_all$zikv_exposed_mom),], aes(x=age.at.visit_months, y=Mean_OXNDA_score_rescaled,color=perc_responses_completed)) + 
  geom_point() + 
  stat_smooth(method="lm", se=FALSE)+ 
  facet_wrap("zikv_exposed_mom" )+ 
#  theme(legend.position = "bottom") + 
  theme_classic()+
#  guides(colour=guide_colourbar(barwidth=30,label.position="bottom"))+
  labs(title = "Plot of mean oxnda score by age:10-25 months\n", 
       x = "Child age (months) at assessment", y = "Mean Total OXNDA Score", 
       color = "Percent Responses Completed\n")

table(ds2_oxnda_all$age.at.visit_months<18,ds2_oxnda_all$zikv_exposed_mom)

#  install.packages("ggpmisc")
library(ggpmisc)
tiff("oxnda_mean_byage_byprec.tiff",width = 4500,height = 2000,units = "px")
ggplot(data=ds2_oxnda_10_18[!is.na(ds2_oxnda_10_18$zikv_exposed_mom),], 
       aes(x=age.at.visit_months, y=Mean_OXNDA_score_rescaled,color=perc_responses_completed)) + 
  geom_point(size=20) + 
  stat_smooth(method="lm", se=FALSE)+ 
  facet_wrap("zikv_exposed_mom" )+ 
  guides(colour=guide_colourbar(barwidth=10,barheight = 100))+
  labs(title = "Plot of mean oxnda score by age:10-18 months\n", 
       x = "Child age (months) at assessment", y = "Mean Total OXNDA Score", 
       color = "Percent Responses Completed\n")+
  theme_set(theme_gray(base_size = 60))
dev.off()

tiff("oxnda_mean_byage_byprec_all.tiff",width = 4500,height = 2000,units = "px")
ggplot(data=ds2_oxnda_10_18[!is.na(ds2_oxnda_10_18$zikv_exposed_mom),], 
       aes(x=age.at.visit_months, y=Mean_OXNDA_score_rescaled,color=perc_responses_completed)) + 
  geom_point(size=20) + 
  stat_smooth(method="lm", se=FALSE)+ 
  #facet_wrap("zikv_exposed_mom" )+ 
  guides(colour=guide_colourbar(barwidth=10,barheight = 100))+
  labs(title = "Plot of mean oxnda score by age:10-18 months\n", 
       x = "Child age (months) at assessment", y = "Mean Total OXNDA Score", 
       color = "Percent Responses Completed\n")+
  theme_set(theme_gray(base_size = 60))
dev.off()

#parental income, education, as well as bar charts for categorical variables such as gender, Parish, etc. 
#install.packages("ggpubr")
library(ggpubr)
ggplot(data=ds2_oxnda_10_18[!is.na(ds2_oxnda_10_18$z_alcohol.24),], aes(x=z_alcohol.24, y=Mean_OXNDA_score_rescaled)) + geom_boxplot() + stat_smooth(method="lm", se=FALSE)+ ggtitle("Plot of mean oxnda score \n by alcohol use\n (10-18 months)")+ stat_compare_means() +   theme_set(theme_gray(base_size = 10))
ggplot(data=ds2_oxnda_10_18, aes(x=z_alcohol_amount.24, y=Mean_OXNDA_score_rescaled)) + geom_boxplot() + stat_smooth(method="lm", se=FALSE)+ ggtitle("Plot of mean oxnda score \n by alcohol use amount \n (10-18 months)")+ stat_compare_means() + theme(axis.text.x = element_text(angle = 45, hjust = 1))+ stat_compare_means() + theme(axis.text.x = element_text(angle = 45, hjust = 1))
ggplot(data=ds2_oxnda_10_18, aes(x=z_smoking.24, y=Mean_OXNDA_score_rescaled)) + geom_boxplot() + stat_smooth(method="lm", se=FALSE)+ ggtitle("Plot of mean oxnda score \n by tobacco use \n (10-18 months)")+ stat_compare_means() + theme(axis.text.x = element_text(angle = 45, hjust = 1))+ stat_compare_means() + theme(axis.text.x = element_text(angle = 45, hjust = 1))
ggplot(data=ds2_oxnda_10_18, aes(x=z_drugs.24, y=Mean_OXNDA_score_rescaled)) + geom_boxplot() + stat_smooth(method="lm", se=FALSE)+ ggtitle("Plot of mean oxnda score \n by drug use \n (10-18 months)")+ stat_compare_means() + theme(axis.text.x = element_text(angle = 45, hjust = 1))+ stat_compare_means() + theme(axis.text.x = element_text(angle = 45, hjust = 1))
ggplot(data=ds2_oxnda_10_18[!is.na(ds2_oxnda_10_18$breastfeed.12),], aes(x=breastfeed.12, y=Mean_OXNDA_score_rescaled)) + geom_boxplot() + stat_smooth(method="lm", se=FALSE)+ ggtitle("Plot of mean oxnda score \n by breastfeed \n (10-18 months)")+ stat_compare_means() + theme(axis.text.x = element_text(angle = 45, hjust = 1))+ stat_compare_means() + theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggplot(data=ds2_oxnda_10_18, aes(x=education.mom.cat, y=Mean_OXNDA_score_rescaled)) + geom_boxplot() + stat_smooth(method="lm", se=FALSE)+ ggtitle("Plot of mean oxnda score \n by maternal highest education category \n (10-18 months)")+ stat_compare_means()

ds2_oxnda_10_18 <- within(ds2_oxnda_10_18, monthly_income.mom[ds2_oxnda_10_18$monthly_income.mom=="Refused/Don't know"] <- NA)
ds2_oxnda_10_18$monthly_income.mom <- ordered(ds2_oxnda_10_18$monthly_income.mom, levels = c("Under $1000 EC", "$1,001-2,000 EC","$2,001-3000 EC", "Over $3000 EC"))
ggplot(data=ds2_oxnda_10_18, aes(x=monthly_income.mom, y=Mean_OXNDA_score_rescaled)) + geom_boxplot() + stat_smooth(method="lm", se=FALSE)+ ggtitle("Plot of mean oxnda score \n by household monthly income category \n (10-18 months)")+ stat_compare_means() + theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggplot(data=ds2_oxnda_10_18, aes(x=gender.pn, y=Mean_OXNDA_score_rescaled)) + geom_boxplot() + stat_smooth(method="lm", se=FALSE)+ ggtitle("Plot of mean oxnda score \n by child gender \n (10-18 months)")+ stat_compare_means() + theme(axis.text.x = element_text(angle = 45, hjust = 1))+ stat_compare_means() + theme(axis.text.x = element_text(angle = 45, hjust = 1))
ggplot(data=ds2_oxnda_10_18, aes(x=parish.mom, y=Mean_OXNDA_score_rescaled)) + geom_boxplot() + stat_smooth(method="lm", se=FALSE)+ ggtitle("Plot of mean oxnda score \n by parish \n (10-18 months)")+ stat_compare_means() + theme(axis.text.x = element_text(angle = 45, hjust = 1))
ggplot(data=ds2_oxnda_10_18, aes(x=latrine_type.mom, y=Mean_OXNDA_score_rescaled)) + geom_boxplot() + stat_smooth(method="lm", se=FALSE)+ ggtitle("Plot of mean oxnda score \n by latrine type as proxy of wealth \n (10-18 months)")+ stat_compare_means() + theme(axis.text.x = element_text(angle = 45, hjust = 1))
ggplot(data=ds2_oxnda_10_18, aes(x=occupation.mom, y=Mean_OXNDA_score_rescaled)) + geom_boxplot() + stat_smooth(method="lm", se=FALSE)+ ggtitle("Plot of mean oxnda score \n by maternal occupation \n (10-18 months)")+ stat_compare_means() + theme(axis.text.x = element_text(angle = 45, hjust = 1))

tiff("oxnda_mean_bygroup.tiff",width = 6000,height = 3000,units = "px")
ggplot(data=ds2_oxnda_10_18[!is.na(ds2_oxnda_10_18$zikv_exposed_mom),], 
       aes(zikv_exposed_mom, Mean_OXNDA_score_rescaled)) +
  geom_boxplot(size=3) +
  stat_smooth(method="lm", se=FALSE)+ 
  stat_compare_means(size=30,bracket.size = 4,comparisons = list(c("Not ZIKV Infected","Possibly ZIKV Infected During Pregnancy"),
                                                                 c("Possibly ZIKV Infected During Pregnancy","Probably ZIKV Infected During Pregnancy"),
                                                                 c("Probably ZIKV Infected During Pregnancy","Not ZIKV Infected") )) + 
  stat_compare_means(size=30,label.y = 95)+
  labs(title = "Mean OX-NDA score\nBy Maternal Exposure Category\n", 
       x = "", y = "Mean Total OXNDA Score")+
  theme_set(theme_gray(base_size = 100))
dev.off()

hist(ds2_oxnda_10_18$Mean_OXNDA_score_rescaled,breaks = 50)

ggplot(ds2_oxnda_10_18,aes(x=Mean_OXNDA_score_rescaled))+geom_histogram(bins=100)+facet_wrap(~zikv_exposed_mom)+theme_bw()

#table one of oxnda outcomes all.
#  install.packages("tableone")
#  install.packages("haven")
library(tableone)
library(haven)

child_outcomes_vars<-names(oxnda[11:99])
child_outcomes_vars_non_normal<-names(sapply(oxnda, is.numeric))

child_outcomes <- CreateTableOne(vars = child_outcomes_vars, data = ds2_oxnda_10_18, strata = "zikv_exposed_mom")
child_outcomes<-print(child_outcomes,quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE,smd=T)
write.csv(child_outcomes, file = "oxnda_normal.csv")
child_outcomes <- CreateTableOne(vars = child_outcomes_vars, data = ds2_oxnda_10_18, strata = "zikv_exposed_mom")
child_outcomes<-print(child_outcomes,quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE,smd=T,nonnormal=child_outcomes_vars_non_normal)
write.csv(child_outcomes, file = "oxnda_non_normal2.csv")

#ds2_oxnda_10_18$perc_responses_completed<-  as.integer(ds2_oxnda_10_18$perc_responses_completed)
#class(ds2_oxnda_10_18$perc_responses_completed)
#ds2[ds2$zikv_exposed_child=="child ZIKV Exposed","mother_record_id"]
#table(ds2$mother_record_id)
library("PerformanceAnalytics")

continous <- ds2_oxnda_10_18[, c("Mean_OXNDA_score_rescaled","mom_age_delivery","gestational_weeks_2_2.12","age.at.visit_months","perc_responses_completed")]
cat <- c("zikv_exposed_mom","breastfeed.12","z_alcohol.24.x","monthly_income.mom","gender.pn","parish.mom", "occupation.mom","latrine_type.mom","education.mom.cat")
catcorrm <- function(vars, dat) sapply(vars, function(y) sapply(vars, function(x) assocstats(table(dat[,x], dat[,y]))$cramer))
ds2_oxnda_10_18$

mydata <- ds2_oxnda_10_18[, c("Mean_OXNDA_score_rescaled","mom_age_delivery","gestational_weeks_2_2.12","age.at.visit_months","zikv_exposed_mom","breastfeed.12","z_alcohol.24.x","monthly_income.mom","gender.pn","parish.mom", "occupation.mom","latrine_type.mom","education.mom.cat","perc_responses_completed")]
mydata[,cat] <- lapply(mydata[,cat],as.factor)
mydata[,cat] <- lapply(mydata[,cat],as.numeric)
cor(mydata,use="pairwise.complete.obs",method = "pearson")
chart.Correlation(mydata, histogram=TRUE, pch=19,method ="pearson")

tiff("correlations.png",width = 2000,height = 2000,units = "px")
chart.Correlation(mydata, histogram=TRUE, pch=19,method ="pearson")
dev.off()