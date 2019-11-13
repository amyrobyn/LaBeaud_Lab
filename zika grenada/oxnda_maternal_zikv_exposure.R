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
oxnda[oxnda=="X"]<-NA
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
  theme_set(theme_gray(base_size = 100))
dev.off()

ds2_oxnda_10_18$Mean_cognitive_score_rescaled<-ds2_oxnda_10_18$Mean_cognitive_score*25
ds2_oxnda_10_18$Mean_overall_language_score_rescaled<-ds2_oxnda_10_18$Mean_overall_language_score*25
ds2_oxnda_10_18$Mean_Positive_Behaviour_score_rescaled<-ds2_oxnda_10_18$Mean_Positive_Behaviour_score*25
ds2_oxnda_10_18$Mean_Negative_Behaviour_rescaled<-ds2_oxnda_10_18$Mean_Negative_Behaviour*25

summary(ds2_oxnda_10_18$Mean_OXNDA_score_rescaled)
summary(ds2_oxnda_10_18$Mean_cognitive_score_rescaled)
summary(ds2_oxnda_10_18$Mean_overall_language_score_rescaled)
summary(ds2_oxnda_10_18$Mean_Positive_Behaviour_score_rescaled)
summary(ds2_oxnda_10_18$Mean_Negative_Behaviour_rescaled)
summary(ds2_oxnda_10_18$Mean_overall_motor_score_rescaled)

library(ggplot2)
ggplot(ds2_oxnda_10_18[!is.na(ds2_oxnda_10_18$zikv_exposed_mom),], aes(age.at.visit_months, y = value, color = variable)) + 
  geom_point(aes(y = Mean_overall_motor_score_rescaled, col = "Mean_overall_motor_score_rescaled")) + 
  geom_smooth(aes(y = Mean_overall_motor_score_rescaled, col = "Mean_overall_motor_score_rescaled"),method=glm) + 
  geom_point(aes(y = Mean_cognitive_score_rescaled, col = "Mean_cognitive_score_rescaled")) + 
  geom_smooth(aes(y = Mean_cognitive_score_rescaled, col = "Mean_cognitive_score_rescaled"),method=glm) + 
  geom_point(aes(y = Mean_overall_language_score_rescaled, col = "Mean_overall_language_score_rescaled")) + 
  geom_smooth(aes(y = Mean_overall_language_score_rescaled, col = "Mean_overall_language_score_rescaled"),method=glm) + 
  geom_point(aes(y = Mean_Positive_Behaviour_score_rescaled, col = "Mean_Positive_Behaviour_score_rescaled")) + 
  geom_smooth(aes(y = Mean_Positive_Behaviour_score_rescaled, col = "Mean_Positive_Behaviour_score_rescaled"),method=glm) + 
  geom_point(aes(y = Mean_Negative_Behaviour_rescaled, col = "Mean_Negative_Behaviour_rescaled")) + 
  geom_smooth(aes(y = Mean_Negative_Behaviour_rescaled, col = "Mean_Negative_Behaviour_rescaled"),method=glm) + 
  facet_wrap("zikv_exposed_mom" )+ 
  theme_set(theme_gray(base_size = 10))

library(reshape2)
long_oxnda<-melt(ds2_oxnda_10_18, id.vars = c("zikv_exposed_mom","age.at.visit_months"), measure.vars = c("Mean_OXNDA_score_rescaled","Mean_Negative_Behaviour_rescaled","Mean_Positive_Behaviour_score_rescaled","Mean_overall_language_score_rescaled","Mean_overall_motor_score_rescaled","Mean_cognitive_score_rescaled"))

levels(long_oxnda$variable)[levels(long_oxnda$variable) == "Mean_OXNDA_score_rescaled"] <- "Total"
levels(long_oxnda$variable)[levels(long_oxnda$variable) == "Mean_Negative_Behaviour_rescaled"] <- "Negative Behavior"
levels(long_oxnda$variable)[levels(long_oxnda$variable) == "Mean_Positive_Behaviour_score_rescaled"] <- "Positive Behavior"
levels(long_oxnda$variable)[levels(long_oxnda$variable) == "Mean_overall_language_score_rescaled"] <- "Language"
levels(long_oxnda$variable)[levels(long_oxnda$variable) == "Mean_overall_motor_score_rescaled"] <- "Motor"
levels(long_oxnda$variable)[levels(long_oxnda$variable) == "Mean_cognitive_score_rescaled"] <- "Cognitive"

tiff("oxnda_mean_domains_byage_strata.tiff",width = 4500,height = 2000,units = "px")
transparent.plot=ggplot(long_oxnda[!is.na(long_oxnda$zikv_exposed_mom),], aes(round(age.at.visit_months,0), y = value, color = zikv_exposed_mom)) + 
    geom_smooth(method=glm,size=10) + 
    geom_point(size = 20) + 
    facet_wrap("variable" )+
    labs(x = "Child age (months) at assessment", y = "Mean Score", color = "Maternal Exposure: \n")+
    theme(
      text = element_text(size = 100,color ='white'),
      legend.position = 'top',
      #panel.background = element_rect(fill = "transparent"), # bg of the panel
      plot.background = element_rect(fill = "transparent", color = NA), # bg of the plot
      panel.grid.major = element_blank(), # get rid of major grid
      panel.grid.minor = element_blank(), # get rid of minor grid
      legend.background = element_rect(fill = "transparent"), # get rid of legend bg
      legend.box.background = element_rect(fill = "transparent"), # get rid of legend panel bg,
      axis.title = element_text(colour = 'white'),
      axis.ticks =element_line(colour = 'white',size=10),
      axis.text = element_text(colour = 'white'),
      axis.ticks.length = unit(0.25, "cm"),
      axis.line.x = element_line(color='white')
    )+
    guides(color = guide_legend(override.aes = list(size=30),nrow=3))+
    scale_x_continuous(breaks = seq(10, 18, by = 2))

dev.off()  

ggsave(filename = "oxnda-transparent-background.png",
       plot = transparent.plot,
       bg = "transparent", 
       width = 45, height = 25, units = "in", limitsize = FALSE)

ggplot(data=ds2_oxnda_10_18[!is.na(ds2_oxnda_10_18$zikv_exposed_mom),], 
       aes(x=age.at.visit_months, y=Mean_OXNDA_score_rescaled,color=perc_responses_completed)) + 
  
  
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

child_outcomes_vars<-names(oxnda[11:102])
child_outcomes_vars_non_normal<-names(sapply(oxnda, is.numeric))

child_outcomes <- CreateTableOne(vars = child_outcomes_vars, data = ds2_oxnda_10_18, strata = "zikv_exposed_mom")
child_outcomes<-print(child_outcomes,quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE,smd=T)
write.csv(child_outcomes, file = "oxnda_normal.csv")
child_outcomes <- CreateTableOne(vars = child_outcomes_vars, data = ds2_oxnda_10_18, strata = "zikv_exposed_mom")
child_outcomes<-print(child_outcomes,quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE,smd=T,nonnormal=child_outcomes_vars_non_normal)
write.csv(child_outcomes, file = "oxnda_non_normal2.csv")

##The OX-NDA was designed for 10 to 14 months. I see that in this dataset we have children aged up to 18 months.
#It might be worth to run a sensitivity analysis to see if the scores of children aged 10 to 14 months differ 
#systematically from the 14 to 18 month age group, and also to check whether the socio-demographic and 
#ZIKV profile of these two groups differ. These could be included as SI in the paper.
ds2_oxnda_10_18$age_group<-NA
ds2_oxnda_10_18 <- within(ds2_oxnda_10_18, age_group[ds2_oxnda_10_18$age.at.visit_months<18] <- "14-18")
ds2_oxnda_10_18 <- within(ds2_oxnda_10_18, age_group[ds2_oxnda_10_18$age.at.visit_months<14] <- "10-<14")
table(ds2_oxnda_10_18$age_group)

child_outcomes_vars<-names(oxnda[11:99])
child_outcomes_vars<-append(child_outcomes_vars,tab1vars)
child_outcomes_vars[105]<-"zikv_exposed_mom"

child_outcomes <- CreateTableOne(vars = child_outcomes_vars, data = ds2_oxnda_10_18[!is.na(ds2_oxnda_10_18$zikv_exposed_mom),], strata = "age_group")
child_outcomes<-print(child_outcomes,quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE,smd=T)
write.csv(child_outcomes, file = "oxnda_normal_10_14_10_18.csv")

#Following on from this comment, it would be good if we could run age-band scores as well; i.e. 10-11 months, 11-12 months and so on; and present this as a 
#table (the scatter plots illustrate this nicely but a tabulated version of the data with actual values could also go into the SI) - again checking whether age 
#at assessment contributes to systematic differences. I wouldn't have suggested this for older age groups but 12 months +/- 2 weeks is still quite young and a 
#10 month old child performs very differently from a 14 or an 18 month old child. 
ds2_oxnda_10_18$age_group2<-NA
ds2_oxnda_10_18 <- within(ds2_oxnda_10_18, age_group2[ds2_oxnda_10_18$age.at.visit_months<=18] <- "18")
ds2_oxnda_10_18 <- within(ds2_oxnda_10_18, age_group2[ds2_oxnda_10_18$age.at.visit_months<=17] <- "17")
ds2_oxnda_10_18 <- within(ds2_oxnda_10_18, age_group2[ds2_oxnda_10_18$age.at.visit_months<=16] <- "16")
ds2_oxnda_10_18 <- within(ds2_oxnda_10_18, age_group2[ds2_oxnda_10_18$age.at.visit_months<=15] <- "15")
ds2_oxnda_10_18 <- within(ds2_oxnda_10_18, age_group2[ds2_oxnda_10_18$age.at.visit_months<=14] <- "14")
ds2_oxnda_10_18 <- within(ds2_oxnda_10_18, age_group2[ds2_oxnda_10_18$age.at.visit_months<=13] <- "13")
ds2_oxnda_10_18 <- within(ds2_oxnda_10_18, age_group2[ds2_oxnda_10_18$age.at.visit_months<=12] <- "12")
ds2_oxnda_10_18 <- within(ds2_oxnda_10_18, age_group2[ds2_oxnda_10_18$age.at.visit_months<=11] <- "11")
ds2_oxnda_10_18 <- within(ds2_oxnda_10_18, age_group2[ds2_oxnda_10_18$age.at.visit_months<=10] <- "10")


ds2_oxnda_10_18 %>%
  group_by(age_group2) %>%
  summarise(Mean_OXNDA_score_rescaled_avg = mean(Mean_OXNDA_score_rescaled),Mean_OXNDA_score_rescaled_sd = sd(Mean_OXNDA_score_rescaled,na.rm=TRUE),n=n())

pivot <- ds2_oxnda_10_18 %>%
  #select(age_group, zikv_exposed_mom, Mean_OXNDA_score_rescaled)%>%
  filter(!is.na(zikv_exposed_mom))%>%
  group_by(age_group, zikv_exposed_mom)%>%
  summarise(Mean_OXNDA_score_rescaled_group_mean = mean(Mean_OXNDA_score_rescaled, na.rm = T), n = n(), sd = sd(as.numeric(Mean_OXNDA_score_rescaled), na.rm = TRUE))
write.csv(pivot, file = 'oxnda_group.csv')

pivot2 <- ds2_oxnda_10_18 %>%
  #select(age_group, zikv_exposed_mom, Mean_OXNDA_score_rescaled)%>%
  filter(!is.na(zikv_exposed_mom))%>%
  group_by(age_group2, zikv_exposed_mom)%>%
  summarise(Mean_OXNDA_score_rescaled_group_mean = mean(Mean_OXNDA_score_rescaled, na.rm = T), n = n(), sd = sd(as.numeric(Mean_OXNDA_score_rescaled), na.rm = TRUE))
write.csv(pivot2, file = 'oxnda_group2.csv')

pivot3 <- ds2_oxnda_10_18 %>%
  #select(age_group, zikv_exposed_mom, Mean_OXNDA_score_rescaled)%>%
  filter(!is.na(zikv_exposed_mom))%>%
  group_by(zikv_exposed_mom)%>%
  summarise(Mean_OXNDA_score_rescaled_group_mean = mean(Mean_OXNDA_score_rescaled, na.rm = T), n = n(), sd = sd(as.numeric(Mean_OXNDA_score_rescaled), na.rm = TRUE))
write.csv(pivot3, file = 'oxnda.csv')

kruskal.test(Mean_OXNDA_score_rescaled ~ zikv_exposed_mom, data = ds2_oxnda_10_18[ds2_oxnda_10_18$age_group2=='18',])


ds2_oxnda_10_18$age_group2<-as.factor(ds2_oxnda_10_18$age_group2)
for (cat in levels(ds2_oxnda_10_18$age_group2)){
  d <- subset(ds2_oxnda_10_18, age_group2 != cat)
  #plot(d$age_group2, d$Mean_OXNDA_score_2)
  tiff(paste('oxnda_age_sensitivity_analysis_exclude',cat,'.tif',sep = ''),width = 2000,height = 2000,units = "px")
  print(ggplot(d,aes(d$age_group2,d$Mean_OXNDA_score_rescaled))+geom_boxplot()+facet_wrap("zikv_exposed_mom")+theme_set(theme_gray(base_size = 100)))
  dev.off()
  child_outcomes <- CreateTableOne(vars = child_outcomes_vars, data = d, strata = "zikv_exposed_mom")
  child_outcomes<-print(child_outcomes,quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE,smd=T)
  write.csv(child_outcomes, file = paste('oxnda_age_sensitivity_analysis_exclude',cat,'.csv',sep = ''))
}

  tiff('oxnda_age_sensitivity_analysis_10-18.tif',width = 4000,height = 2000,units = "px")
  print(ggplot(ds2_oxnda_10_18,aes(factor(round(age.at.visit_months,0)),Mean_OXNDA_score_rescaled))+geom_boxplot()+facet_wrap("zikv_exposed_mom")+theme_set(theme_gray(base_size = 100)))
  dev.off()
  child_outcomes <- CreateTableOne(vars = child_outcomes_vars, data = ds2_oxnda_10_18, strata = "zikv_exposed_mom")
  child_outcomes<-print(child_outcomes,quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE,smd=T)
  write.csv(child_outcomes, file = 'oxnda_age_sensitivity_analysis_10-18.csv')

  tiff('oxnda_age_sensitivity_analysis_10-14.tif',width = 4000,height = 2000,units = "px")
  print(ggplot(ds2_oxnda_10_14,aes(factor(round(age.at.visit_months,0)),Mean_OXNDA_score_rescaled))+geom_boxplot()+facet_wrap("zikv_exposed_mom")+theme_set(theme_gray(base_size = 100)))
  dev.off()
  child_outcomes <- CreateTableOne(vars = child_outcomes_vars, data = ds2_oxnda_10_14, strata = "zikv_exposed_mom")
  child_outcomes<-print(child_outcomes,quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE,smd=T)
  write.csv(child_outcomes, file = 'oxnda_age_sensitivity_analysis_10-14.csv')
  

table(ds2_oxnda_10_18$age_group2,ds2_oxnda_10_18$Mean_OXNDA_score_rescaled)
#ds2_oxnda_10_18$perc_responses_completed<-  as.integer(ds2_oxnda_10_18$perc_responses_completed)
#class(ds2_oxnda_10_18$perc_responses_completed)
#ds2[ds2$zikv_exposed_child=="child ZIKV Exposed","mother_record_id"]
#table(ds2$mother_record_id)
library("PerformanceAnalytics")


continous <- ds2_oxnda_10_18[, c("Mean_OXNDA_score_rescaled","Mean_Negative_Behaviour_rescaled","Mean_Positive_Behaviour_score_rescaled","Mean_overall_language_score_rescaled","Mean_overall_motor_score_rescaled","Mean_cognitive_score_rescaled","mom_age_delivery","gestational_weeks_2_2.12","age.at.visit_months","perc_responses_completed")]
cat <- c("zikv_exposed_mom","breastfeed.12","z_alcohol.24.x","monthly_income.mom","gender.pn","parish.mom", "occupation.mom","latrine_type.mom","education.mom.cat")
catcorrm <- function(vars, dat) sapply(vars, function(y) sapply(vars, function(x) assocstats(table(dat[,x], dat[,y]))$cramer))

mydata <- ds2_oxnda_10_18[, c("Mean_OXNDA_score_rescaled","Mean_Negative_Behaviour_rescaled","Mean_Positive_Behaviour_score_rescaled","Mean_overall_language_score_rescaled","Mean_overall_motor_score_rescaled","Mean_cognitive_score_rescaled","mom_age_delivery","gestational_weeks_2_2.12","age.at.visit_months","zikv_exposed_mom","breastfeed.12","z_alcohol.24.x","monthly_income.mom","gender.pn","parish.mom", "occupation.mom","latrine_type.mom","education.mom.cat","perc_responses_completed")]
mydata[,cat] <- lapply(mydata[,cat],as.factor)
mydata[,cat] <- lapply(mydata[,cat],as.numeric)
cor(mydata,use="pairwise.complete.obs",method = "pearson")
chart.Correlation(mydata, histogram=TRUE, pch=19,method ="pearson")

tiff("correlations.png",width = 2000,height = 2000,units = "px")
chart.Correlation(mydata, histogram=TRUE, pch=19,method ="pearson")
dev.off()