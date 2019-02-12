library(tidyverse)
library(tableone)
# import data -------------------------------------------------------------
  #source("C:/Users/amykr/Documents/GitHub/labeaud_lab/david/export r01 data from redcap and create binary vars.R")#don't run every time
      setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/david coinfection paper/data")
      load("R01_lab_results.david.coinfection.dataset.rda")#load data that has been cleaned previously#final data set made on 11/16/18 for david conifection paper.

# format data -------------------------------------------------------------
AIC<- R01_lab_results[which(R01_lab_results$redcap_event_name!="patient_informatio_arm_1" & R01_lab_results$redcap_event_name!="visit_a2_arm_1"&R01_lab_results$redcap_event_name!="visit_b2_arm_1"&R01_lab_results$redcap_event_name!="visit_c2_arm_1"&R01_lab_results$redcap_event_name!="visit_d2_arm_1"&R01_lab_results$redcap_event_name!="visit_u24_arm_1"),]
AIC<-AIC[which(AIC$id_cohort=="F"),]
table(AIC$id_cohort)
patients_reviewed<-sum(dplyr::n_distinct(AIC$person_id[AIC$redcap_event_name=="visit_a_arm_1"], na.rm = FALSE))
table(AIC$redcap_event_name)

AIC$id_cohort<-substr(AIC$person_id, 2, 2)
AIC$id_city<-substr(AIC$person_id, 1, 1)

AIC <- within(AIC, id_city[id_city=="R"] <-"C" )

AIC$person_id<-as.character(AIC$person_id)
AIC$redcap_event_name<-as.character(AIC$redcap_event_name)
AIC$int_date <-lubridate::ymd(AIC$interview_date_aic)
AIC$age <- rowMeans(AIC[,c("age_calc","age_calc_rc","aic_calculated_age")], na.rm=TRUE) 
table(AIC$redcap_event_name)

AIC<-AIC[which((AIC$age>=1&AIC$age<=17)|is.na(AIC$age)),]#ages 1-17
patients_reviewed<-sum(dplyr::n_distinct(AIC$person_id[AIC$redcap_event_name=="visit_a_arm_1"], na.rm = FALSE))
tapply(AIC$int_date, AIC$redcap_event_name, summary)

# anthropometrics ------------------------------------------------------------------------
#don't need to run every time
#source("C:/Users/amykr/Documents/GitHub/labeaud_lab/u24/igrowup_longitudinal.R")
load("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long/z_scores.rda")
zbmi<-z[which(z$zbmi>5|z$zbmi< (-5)),]
zhfa<-z[which(z$zhfa>5|z$zhfa< (-5)),]
write.csv(zhfa,file="height for age out of bounds.csv")
write.csv(zbmi,file="bmi out of bounds.csv")

AIC<-merge(AIC,z,by=c("person_id","redcap_event_name"),all.x=T)
colnames(AIC)[colnames(AIC) == 'age.x'] <- 'age'
# demographics, ses, and mosquito indices ------------------------------------------------------------
source("C:/Users/amykr/Documents/GitHub/labeaud_lab/david/demographics, ses, and mosquito indices.r")

# define acute febrile illness ------------------------------------------------------------------------
 source("C:/Users/amykr/Documents/GitHub/labeaud_lab/david/define acute febrile illness.r")
table(AIC$acute,AIC$redcap_event_name,exclude = NULL)

AIC_B<-AIC[which(AIC$redcap_event_name=="visit_b_arm_1"), ]

AIC<-AIC[which(AIC$acute==1&(AIC$redcap_event_name=="visit_a_arm_1")), ]
table(AIC$acute,AIC$redcap_event_name)

var<-c("age","height","sex","zhfa", "zbmi","ses_sum")

acute_by_city <- CreateTableOne(vars = var, strata = "id_city", data = AIC)
print(acute_by_city,nonnormal=c("age"))

acute_by_site <- CreateTableOne(vars = var, strata = "site", data = AIC)
print(acute_by_site,nonnormal=c("age"))
AIC$urban<-NA
AIC <- within(AIC, urban[id_city=="K"|id_city=="U"] <-"urban" )
AIC <- within(AIC, urban[id_city=="C"|id_city=="M"] <-"rural" )

acute <- CreateTableOne(vars = var, data = AIC)
print(acute,nonnormal=c("age"))

acute_urban <- CreateTableOne(vars = var, strata = "urban",data = AIC)
print(acute_urban,nonnormal=c("age"))

boxplot(AIC$age~AIC$id_city)
boxplot(AIC$age~AIC$urban)

library(ggplot2)
ggplot(AIC, aes(x=age, fill=urban, color=urban)) + geom_histogram( position="identity", binwidth=1, alpha=0.5) + geom_density(aes(color=urban))

ggplot(AIC, aes(y=age,x=urban)) + geom_boxplot( position="identity")

boxplot(AIC$age~AIC$site)
boxplot(AIC$age)

#denv and malaria case definition------------------------------------------------------------------------
source("C:/Users/amykr/Documents/GitHub/labeaud_lab/david/strata definitions.R")
AIC$int_date_my<-format(as.Date(AIC$int_date), "%Y-%m")
AIC_nonNA<-AIC[which(!is.na(AIC$denv_strata)),c("denv_strata","int_date_my","int_date")]
write.csv(AIC_nonNA,file="strata_date.csv")
library(ggplot2)
ggplot(AIC_nonNA, aes(x = int_date_my,fill=denv_strata,color=denv_strata)) + 
  scale_fill_manual(values=c("grey", "transparent", "black"))+
  scale_color_manual(values=c("black", "black", "black"))+
#  scale_x_date(date_breaks = "1 month", date_labels =  "%b %Y") +
  theme(axis.text.x=element_text(angle=60, hjust=1),text = element_text(size = 20,color="black")) + 
  xlab("") + ylab("No. Cases") +
  geom_bar(stat="count",position = "identity") + theme(strip.text.y = element_text(angle = 0))+ 
#  facet_grid(City~.)+
  guides(fill = guide_legend(title = "", title.position = "left",direction="vertical"))+ 
  theme(legend.position = c(0.8, 0.9),legend.background=element_blank())+guides(colour=FALSE)

table(AIC$infected_denv_stfd,AIC$result_igg_denv_stfd,exclude = NULL)
AIC$redcap_event_name
PRNT<-AIC[which(AIC$infected_denv_stfd==1 & AIC$result_igg_denv_stfd==1),c("person_id","redcap_event_name","prnt_80_denv","result_igg_denv_stfd","infected_denv_stfd","seroc_denv_stfd_igg","infected_chikv_stfd","seroc_chikv_stfd_igg")]
write.csv(PRNT,"PRNT.csv")

# denv tables -------------------------------------------------
table(!is.na(AIC$infected_denv_stfd))
table(AIC$infected_denv_stfd)
table(AIC$infected_denv_stfd)/sum(table(AIC$infected_denv_stfd))*1000
tapply(AIC$infected_denv_stfd, AIC$year, table)

tapply(AIC$age,is.na(AIC$infected_denv_stfd), summary,na.rm=T)
tapply(AIC$age,is.na(AIC$infected_denv_stfd), summary,na.rm=T)
boxplot(age ~ is.na(AIC$infected_denv_stfd), data = AIC)
wilcox.test(age~is.na(infected_denv_stfd),na.action="na.omit",paired = FALSE,conf.level =0.95,data=AIC)
# malaria tables -------------------------------------------------
table(!is.na(AIC$malaria))
table(AIC$malaria)
table(AIC$malaria)/sum(table(AIC$malaria))*1000
summary(AIC$malaria)*1000
tapply(AIC$malaria, AIC$year, summary)
tapply(AIC$malaria, AIC$id_city, summary)

tapply(AIC$age,is.na(AIC$malaria), summary)
boxplot(age ~ is.na(AIC$malaria), data = AIC)
wilcox.test(AIC$age~is.na(AIC$malaria),na.rm=T)

table(AIC$result_microscopy_malaria_kenya,exclude = NULL)  
table(AIC$microscopy_malaria_pf_kenya___1,exclude = NULL)  
table(AIC$microscopy_malaria_pv_kenya___1,exclude = NULL)  
table(AIC$microscopy_malaria_po_kenya___1,exclude = NULL)  
table(AIC$microscopy_malaria_pm_kenya___1,exclude = NULL)  
table(AIC$microscopy_malaria_ni_kenya___1,exclude = NULL)  

table(AIC$microscopy_malaria_pm_kenya___1,AIC$microscopy_malaria_po_kenya___1,exclude = NULL)  
table(AIC$microscopy_malaria_pm_kenya___1,AIC$microscopy_malaria_pf_kenya___1,exclude = NULL)  
table(AIC$microscopy_malaria_po_kenya___1,AIC$microscopy_malaria_pf_kenya___1,exclude = NULL)  
table(AIC$result_microscopy_malaria_kenya,AIC$microscopy_malaria_pf_kenya___1,exclude = NULL)  

# included vs excluded tables ---------------------------------------------
excluded <- CreateTableOne(vars = var, strata = "excluded",data = AIC)
print(excluded,nonnormal=c("age"))
aic <- CreateTableOne(vars = var, ,data = AIC)
print(aic,nonnormal=c("age"))

# cases tested for both malaria and denv ----------------------------------
AIC<-AIC[which(!is.na(AIC$malaria) & !is.na(AIC$infected_denv_stfd)), ]
save(AIC,file="AIC.rda")
table(AIC$malaria)

# infection strata tables ---------------------------------------------
strata <- CreateTableOne(vars = var, strata = "strata_all",data = AIC)
print(strata,nonnormal=c("age"))
aic <- CreateTableOne(vars = var, ,data = AIC)
print(aic,nonnormal=c("age"))
table(AIC$strata_all)
table(AIC$strata_all,AIC$site)
table(AIC$strata_all,AIC$id_city)
results <- fastDummies::dummy_cols(AIC,select_columns = "strata_all")
strata<-c("strata_all_malaria_pos_denv_pos","strata_all_malaria_pos_denv_neg","strata_all_malaria_neg_denv_neg","strata_all_malaria_neg_denv_pos")
city <-CreateTableOne(vars = strata,factorVars = strata, strata = "id_city", data = results)
urban <-CreateTableOne(vars = strata,factorVars = strata, strata = "urban", data = results)
site <-CreateTableOne(vars = strata,factorVars = strata, strata = "site", data = results)
total <-CreateTableOne(vars = strata,factorVars = strata, data = results)
pairwise.t.test(AIC$age, AIC$strata_all, p.adj = "bonf",paired = FALSE,alternative = "two.sided")

# physical exam -------------------------------------------------------
source("C:/Users/amykr/Documents/GitHub/labeaud_lab/david/physical exam.R")

# demographic tables and graphs -------------------------------------------------------
source("C:/Users/amykr/Documents/GitHub/labeaud_lab/david/demogarphy or tables.R")

# ses pca ------------------------------------------------------------
source("C:/Users/amykr/Documents/GitHub/labeaud_lab/david/ses pca.R")
table(AIC$strata_all)

# outcome hospitalized ----------------------------------------------------
 AIC$outcome_hospitalized<-as.numeric(as.character(AIC$outcome_hospitalized))
 AIC <- within(AIC, outcome_hospitalized[outcome_hospitalized==8] <-1 )
 table(AIC$outcome_hospitalized)

# symptoms table ----------------------------------------------------------
 source("C:/Users/amykr/Documents/GitHub/labeaud_lab/david/symptoms.R")
 source("C:/Users/amykr/Documents/GitHub/labeaud_lab/david/cmh.R")
 
##merge with paired(acute and convalescent) pedsql data -----------------------------------------------------------------------
 source("C:/Users/amykr/Documents/GitHub/labeaud_lab/david/calculate pedsql scores and pair.r")
 load("AIC.rda")
 names(pedsql_pairs_acute)[names(pedsql_pairs_acute) == 'redcap_event_name_acute_paired'] <- 'redcap_event_name'
 names(AIC)[names(AIC) == 'redcap_event'] <- 'redcap_event_name'
 pedsql_pairs_acute<-pedsql_pairs_acute[which(pedsql_pairs_acute$redcap_event_name=="visit_a_arm_1"),]
 table(pedsql_pairs_acute$redcap_event_name)
 library(tidyverse)
 class(pedsql_pairs_acute)
 
 AIC <- join(AIC, pedsql_pairs_acute, by=c("person_id", "redcap_event_name"), match = "first" , type="left")
 AIC<-AIC[order(-(grepl('person_id|redcap|pedsql_', names(AIC)))+1L)]

#relabel levels of strata_all
levels(AIC$strata_all) <- list("Neg"="malaria_neg_denv_neg", "DENV"="malaria_neg_denv_pos", "Malaria"="malaria_pos_denv_neg","Coinfection"="malaria_pos_denv_pos")
 table(AIC$strata_all)
 AIC$strata_all<- revalue(AIC$strata_all, c("malaria_neg_denv_neg"="Neg", "malaria_neg_denv_pos"="DENV", "malaria_pos_denv_neg"="Malaria","malaria_pos_denv_pos"="Coinfection"))

# source("C:/Users/amykr/Documents/GitHub/labeaud_lab/david/acute visit outcomes-pedsql.R")
 
##merge with unpaired pedsql data -----------------------------------------------------------------------
 load("pedsql_unpaired.rda")
 names(pedsql_unpaired)[names(pedsql_unpaired) == 'redcap_event'] <- 'redcap_event_name'
#all a
 pedsql_unpaired_a<-pedsql_unpaired[which(pedsql_unpaired$redcap_event_name=="visit_a_arm_1"),grepl("mean|sum|person_id|redcap", names(pedsql_unpaired))]
 AIC <- merge(AIC, pedsql_unpaired_a, by="person_id",suffix = c("", "_a"),all.x = T)
#all b
 load("pedsql_b.rda")
 pedsql_b<-pedsql_b[,grepl("mean|sum|person_id|redcap", names(pedsql_b))]
 AIC_B<-AIC_B[,!grepl("pedsql", names(AIC_B))]
 AIC_B<-merge(AIC_B,pedsql_b,by="person_id",all.x = T)
 AIC_B<-merge(AIC, AIC_B,all.y = T,by="person_id",suffix=c("","_b"))
 AIC_B_febrile<-AIC_B[which(AIC_B$acute_b==1& !is.na(AIC_B$strata_all)), ]#only keep those that have an a strata
 AIC_B_afebrile<-AIC_B[which(AIC_B$acute_b==0 & !is.na(AIC_B$strata_all)), ]#only keep those that have an a strata
 
 

# save and export data ----------------------------------------------------
 save(AIC,file="david_denv_malaria_cohort.rda")
 setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/david coinfection paper/data")
 load("david_denv_malaria_cohort.rda")
#Table 7. Characteristics of PedsQL data by infection group-----------------------------------------------------------------------
AIC$strata_all <- factor(AIC$strata_all, levels = c("malaria_pos_denv_pos", "malaria_neg_denv_pos", "malaria_pos_denv_neg","malaria_neg_denv_neg"))
 
table(AIC$strata_all)
table(AIC$pairs_ab_conv_paired,AIC$strata_all, exclude = NA)
table(!is.na(AIC$pedsql_parent_total_mean_acute_paired),AIC$strata_all)
table(!is.na(AIC$pedsql_parent_total_mean_conv_paired),AIC$strata_all)

AIC$strata_all<-as.factor(AIC$strata_all)

vars<-c("pedsql_parent_total_mean_acute_paired","pedsql_parent_physical_mean_acute_paired","pedsql_parent_emotional_mean_acute_paired","pedsql_parent_social_mean_acute_paired","pedsql_parent_school_mean_acute_paired","pedsql_parent_total_mean_conv_paired","pedsql_parent_physical_mean_conv_paired","pedsql_parent_emotional_mean_conv_paired","pedsql_parent_social_mean_conv_paired","pedsql_parent_school_mean_conv_paired")

acutevars<-c("pedsql_parent_total_mean_acute_paired","pedsql_parent_physical_mean_acute_paired","pedsql_parent_emotional_mean_acute_paired","pedsql_parent_social_mean_acute_paired","pedsql_parent_school_mean_acute_paired")
convvars<-c("pedsql_parent_total_mean_conv_paired","pedsql_parent_physical_mean_conv_paired","pedsql_parent_emotional_mean_conv_paired","pedsql_parent_social_mean_conv_paired","pedsql_parent_school_mean_conv_paired")
tableone::CreateTableOne(vars,"strata_all",AIC,includeNA=F,test=T)
#acute total
AIC$abnormal_pedsql_parent_total_mean_acute<-ifelse(AIC$pedsql_parent_total_mean_acute_paired<100&!is.na(AIC$pedsql_parent_total_mean_acute_paired),1,0)
prop.table(table(AIC$abnormal_pedsql_parent_total_mean_acute,AIC$strata_all), margin=2)
abnormal_pedsql_parent_total_mean_acute<-AIC[AIC$abnormal_pedsql_parent_total_mean_acute==1,]
tableone::CreateTableOne("pedsql_parent_total_mean_acute_paired","strata_all",abnormal_pedsql_parent_total_mean_acute,includeNA=F,test=T)

#conv total
AIC$abnormal_pedsql_parent_total_mean_conv<-ifelse(AIC$pedsql_parent_total_mean_conv_paired<100&!is.na(AIC$pedsql_parent_total_mean_conv_paired),1,0)
prop.table(table(AIC$abnormal_pedsql_parent_total_mean_conv,AIC$strata_all), margin=2)
abnormal_pedsql_parent_total_mean_conv<-AIC[AIC$abnormal_pedsql_parent_total_mean_conv==1,]
tableone::CreateTableOne("pedsql_parent_total_mean_conv_paired","strata_all",abnormal_pedsql_parent_total_mean_conv,includeNA=F,test=T)

#acute physical
AIC$abnormal_pedsql_parent_physical_mean_acute<-ifelse(AIC$pedsql_parent_physical_mean_acute_paired<100&!is.na(AIC$pedsql_parent_physical_mean_acute_paired),1,0)
prop.table(table(AIC$abnormal_pedsql_parent_physical_mean_acute,AIC$strata_all), margin=2)
abnormal_pedsql_parent_physical_mean_acute<-AIC[AIC$abnormal_pedsql_parent_physical_mean_acute==1,]
tableone::CreateTableOne("pedsql_parent_physical_mean_acute_paired","strata_all",abnormal_pedsql_parent_physical_mean_acute,includeNA=F,test=T)

#conv physical
AIC$abnormal_pedsql_parent_physical_mean_conv<-ifelse(AIC$pedsql_parent_physical_mean_conv_paired<100&!is.na(AIC$pedsql_parent_physical_mean_conv_paired),1,0)
prop.table(table(AIC$abnormal_pedsql_parent_physical_mean_conv,AIC$strata_all), margin=2)
abnormal_pedsql_parent_physical_mean_conv<-AIC[AIC$abnormal_pedsql_parent_physical_mean_conv==1,]
tableone::CreateTableOne("pedsql_parent_physical_mean_conv_paired","strata_all",abnormal_pedsql_parent_physical_mean_conv,includeNA=F,test=T)

#acute social
AIC$abnormal_pedsql_parent_social_mean_acute<-ifelse(AIC$pedsql_parent_social_mean_acute_paired<100&!is.na(AIC$pedsql_parent_social_mean_acute_paired),1,0)
prop.table(table(AIC$abnormal_pedsql_parent_social_mean_acute,AIC$strata_all), margin=2)
abnormal_pedsql_parent_social_mean_acute<-AIC[AIC$abnormal_pedsql_parent_social_mean_acute==1,]
tableone::CreateTableOne("pedsql_parent_social_mean_acute_paired","strata_all",abnormal_pedsql_parent_social_mean_acute,includeNA=F,test=T)

#conv social
AIC$abnormal_pedsql_parent_social_mean_conv<-ifelse(AIC$pedsql_parent_social_mean_conv_paired<100&!is.na(AIC$pedsql_parent_social_mean_conv_paired),1,0)
prop.table(table(AIC$abnormal_pedsql_parent_social_mean_conv,AIC$strata_all), margin=2)
abnormal_pedsql_parent_social_mean_conv<-AIC[AIC$abnormal_pedsql_parent_social_mean_conv==1,]
tableone::CreateTableOne("pedsql_parent_social_mean_conv_paired","strata_all",abnormal_pedsql_parent_social_mean_conv,includeNA=F,test=T)

#acute school
AIC$abnormal_pedsql_parent_school_mean_acute<-ifelse(AIC$pedsql_parent_school_mean_acute_paired<100&!is.na(AIC$pedsql_parent_school_mean_acute_paired),1,0)
prop.table(table(AIC$abnormal_pedsql_parent_school_mean_acute,AIC$strata_all), margin=2)
abnormal_pedsql_parent_school_mean_acute<-AIC[AIC$abnormal_pedsql_parent_school_mean_acute==1,]
tableone::CreateTableOne("pedsql_parent_school_mean_acute_paired","strata_all",abnormal_pedsql_parent_school_mean_acute,includeNA=F,test=T)

#conv school
AIC$abnormal_pedsql_parent_school_mean_conv<-ifelse(AIC$pedsql_parent_school_mean_conv_paired<100&!is.na(AIC$pedsql_parent_school_mean_conv_paired),1,0)
prop.table(table(AIC$abnormal_pedsql_parent_school_mean_conv,AIC$strata_all), margin=2)
abnormal_pedsql_parent_school_mean_conv<-AIC[AIC$abnormal_pedsql_parent_school_mean_conv==1,]
tableone::CreateTableOne("pedsql_parent_school_mean_conv_paired","strata_all",abnormal_pedsql_parent_school_mean_conv,includeNA=F,test=T)

#acute emotional
AIC$abnormal_pedsql_parent_emotional_mean_acute<-ifelse(AIC$pedsql_parent_emotional_mean_acute_paired<100&!is.na(AIC$pedsql_parent_emotional_mean_acute_paired),1,0)
prop.table(table(AIC$abnormal_pedsql_parent_emotional_mean_acute,AIC$strata_all), margin=2)
abnormal_pedsql_parent_emotional_mean_acute<-AIC[AIC$abnormal_pedsql_parent_emotional_mean_acute==1,]
tableone::CreateTableOne("pedsql_parent_emotional_mean_acute_paired","strata_all",abnormal_pedsql_parent_emotional_mean_acute,includeNA=F,test=T)

#conv emotional
AIC$abnormal_pedsql_parent_emotional_mean_conv<-ifelse(AIC$pedsql_parent_emotional_mean_conv_paired<100&!is.na(AIC$pedsql_parent_emotional_mean_conv_paired),1,0)
prop.table(table(AIC$abnormal_pedsql_parent_emotional_mean_conv,AIC$strata_all), margin=2)
abnormal_pedsql_parent_emotional_mean_conv<-AIC[AIC$abnormal_pedsql_parent_emotional_mean_conv==1,]
tableone::CreateTableOne("pedsql_parent_emotional_mean_conv_paired","strata_all",abnormal_pedsql_parent_emotional_mean_conv,includeNA=F,test=T)

# pedsql tables and graphs -------------------------------------------------------
library(ggplot2)

# B_febrile_test ----------------------------------------------------------
B_febrile <- function(i){p <-acute_emotional<-ggplot(AIC_B_febrile,aes(x=strata_all))+ geom_boxplot(aes_string(y=i))+labs(title = i,x = "",y="",tag = "")
return(p)}
pdf("B_febrile_parent.pdf", width = 8, height = 12) # Open a new pdf file
p <- lapply(c("pedsql_parent_total_mean_b","pedsql_parent_emotional_mean_b","pedsql_parent_physical_mean_b","pedsql_parent_school_mean_b","pedsql_parent_social_mean_b","pedsql_parent_psych_mean_b"), B_febrile)
do.call(gridExtra::grid.arrange, c(p, top = "febrile visit B by strata", bottom="Strata"))
dev.off() # Close the file

pdf("B_febrile_child.pdf", width = 8, height = 12) # Open a new pdf file
p <- lapply(c("pedsql_child_total_mean_b","pedsql_child_emotional_mean_b","pedsql_child_physical_mean_b","pedsql_child_school_mean_b","pedsql_child_social_mean_b","pedsql_child_psych_mean_b"), B_febrile)
do.call(gridExtra::grid.arrange, c(p, top = "febrile visit B by strata", bottom="Strata"))
dev.off() # Close the file

# B_afebrile_test ----------------------------------------------------------
B_afebrile_test <- function(i){p <-ggplot(AIC_B_afebrile,aes(x=strata_all))+ geom_boxplot(aes_string(y=i))+labs(title = i,x = "",y="",tag = "")
return(p)}
pdf("B_afebrile_parent.pdf", width = 8, height = 12) # Open a new pdf file
p <- lapply(c("pedsql_parent_total_mean_b","pedsql_parent_emotional_mean_b","pedsql_parent_physical_mean_b","pedsql_parent_school_mean_b","pedsql_parent_social_mean_b","pedsql_parent_psych_mean_b"), B_afebrile_test)
do.call(gridExtra::grid.arrange, c(p, top = "afebrile visit B by strata", bottom="Strata"))
dev.off() # Close the file

pdf("B_afebrile_child.pdf", width = 8, height = 12) # Open a new pdf file
p <- lapply(c("pedsql_child_total_mean_b","pedsql_child_emotional_mean_b","pedsql_child_physical_mean_b","pedsql_child_school_mean_b","pedsql_child_social_mean_b","pedsql_child_psych_mean_b"), B_afebrile_test)
do.call(gridExtra::grid.arrange, c(p, top = "afebrile visit B by strata", bottom="Strata"))
dev.off() # Close the file

# all visit a ----------------------------------------------------------
AIC_plots <- function(i){p <-ggplot(AIC,aes(x=strata_all))+ geom_boxplot(aes_string(y=i))+labs(title = i,x = "",y="",tag = "")
return(p)}
pdf("visit_a_parent.pdf", width = 8, height = 12) # Open a new pdf file
p <- lapply(c("pedsql_parent_total_mean","pedsql_parent_emotional_mean","pedsql_parent_physical_mean","pedsql_parent_school_mean","pedsql_parent_social_mean","pedsql_parent_psych_mean"), AIC_plots)
do.call(gridExtra::grid.arrange, c(p, top = "AIC visit A by strata", bottom="Strata"))
dev.off() # Close the file

pdf("visit_a_child.pdf", width = 8, height = 12) # Open a new pdf file
p <- lapply(c("pedsql_child_total_mean","pedsql_child_emotional_mean","pedsql_child_physical_mean","pedsql_child_school_mean","pedsql_child_social_mean","pedsql_child_psych_mean"), AIC_plots)
do.call(gridExtra::grid.arrange, c(p, top = "AIC visit A by strata", bottom="Strata"))
dev.off() # Close the file

# acute ----------------------------------------------------------
pdf("acute_parent.pdf", width = 8, height = 12) # Open a new pdf file
p <- lapply(c("pedsql_parent_total_mean_acute_paired","pedsql_parent_emotional_mean_acute_paired","pedsql_parent_physical_mean_acute_paired","pedsql_parent_school_mean_acute_paired","pedsql_parent_social_mean_acute_paired","pedsql_parent_psych_mean_acute_paired"), AIC_plots)
do.call(gridExtra::grid.arrange, c(p, top = "acute by Strata", bottom="Strata"))
dev.off() # Close the file

pdf("acute_child.pdf", width = 8, height = 12) # Open a new pdf file
p <- lapply(c("pedsql_child_total_mean_acute_paired","pedsql_child_emotional_mean_acute_paired","pedsql_child_physical_mean_acute_paired","pedsql_child_school_mean_acute_paired","pedsql_child_social_mean_acute_paired","pedsql_child_psych_mean_acute_paired"), AIC_plots)
do.call(gridExtra::grid.arrange, c(p, top = "acute by Strata", bottom="Strata"))
dev.off() # Close the file

# conv ----------------------------------------------------------
pdf("conv_parent.pdf", width = 8, height = 12) # Open a new pdf file
p <- lapply(c("pedsql_parent_total_mean_conv_paired","pedsql_parent_emotional_mean_conv_paired","pedsql_parent_physical_mean_conv_paired","pedsql_parent_school_mean_conv_paired","pedsql_parent_social_mean_conv_paired","pedsql_parent_psych_mean_conv_paired"), AIC_plots)
do.call(gridExtra::grid.arrange, c(p, top = "Convalescent by Strata", bottom="Strata"))
dev.off() # Close the file

pdf("conv_child.pdf", width = 8, height = 12) # Open a new pdf file
p <- lapply(c("pedsql_child_total_mean_conv_paired","pedsql_child_emotional_mean_conv_paired","pedsql_child_physical_mean_conv_paired","pedsql_child_school_mean_conv_paired","pedsql_child_social_mean_conv_paired","pedsql_child_psych_mean_conv_paired"), AIC_plots)
do.call(gridExtra::grid.arrange, c(p, top = "Convalescent by Strata", bottom="Strata"))
dev.off() # Close the file

# paired ----------------------------------------------------------
AIC_plots_fu_time <- function(i){p <-ggplot(AIC,aes(x=elapsed.time_conv_paired,color=strata_all))+geom_point(aes_string(y=i))+geom_smooth(aes_string(y=i))+labs(title = i,x = "Days to FU",y="",tag = "")
return(p)}

pdf("paired_parent.pdf", width = 8, height = 12) # Open a new pdf file
p <- lapply(c("pedsql_parent_total_mean_change","pedsql_parent_emotional_mean_change","pedsql_parent_physical_mean_change","pedsql_parent_school_mean_change","pedsql_parent_social_mean_change","pedsql_parent_psych_mean_change"), AIC_plots_fu_time)
do.call(gridExtra::grid.arrange, c(p, top = "Paired change over time to follow up"))
dev.off() # Close the file

pdf("paired_child.pdf", width = 8, height = 12) # Open a new pdf file
p <- lapply(c("pedsql_child_total_mean_change","pedsql_child_emotional_mean_change","pedsql_child_physical_mean_change","pedsql_child_school_mean_change","pedsql_child_social_mean_change","pedsql_child_psych_mean_change"), AIC_plots_fu_time)
do.call(gridExtra::grid.arrange, c(p, top = "Paired change over time to follow up"))
dev.off() # Close the file

# other -------------------------------------------------------------------
list<-grep("mean_acute_paired|mean_conv_paired|change|mean_z", names(AIC), value = TRUE)
 pedsqlvar_aic<-pedsqlvar_aic[pedsqlvar_aic != "home_lifestyle_changes"]
 pedsql_paired_tableOne <- CreateTableOne(vars = pedsqlvar_aic, strata = "strata_all", data = AIC)
 pedsql_tableOne_unpaired_acute <- CreateTableOne(vars = pedsqlvar, strata = "strata_all", data = pedsql_all_coinfection_acute,includeNA=T)
 df<-AIC
 source("C:/Users/amykr/Documents/GitHub/labeaud_lab/david/histograms.R")

 AIC$pedsql_parent_emotional_mean_acute_paired
 AIC<-AIC[order(-(grepl('pedsql_', names(AIC))))]
 AIC<-AIC[order(-(grepl('person_id|redcap', names(AIC))))]
 AIC[ which(AIC$pairs_ac_acute_paired==1) , c("pairs_ab_acute_paired","person_id","redcap_event_name","pedsql_parent_emotional_mean_acute_paired","pedsql_parent_emotional_mean_conv_paired")]

table(AIC$pairs_ab_acute_paired==1, AIC$strata_all)
table(!is.na(AIC$pedsql_parent_total_mean_acute_paired), AIC$strata_all)
table(!is.na(AIC$pedsql_parent_total_mean_conv_paired), AIC$strata_all)

table(!is.na(AIC$pedsql_child_total_mean_acute_paired), AIC$strata_all)
table(!is.na(AIC$pedsql_child_total_mean_conv_paired), AIC$strata_all)

AIC_complete_c<-AIC[ which(!is.na(AIC$pedsql_parent_total_mean_acute_paired)&!is.na(AIC$pedsql_child_total_mean_acute_paired)&!is.na(AIC$pedsql_parent_total_mean_conv_paired)&!is.na(AIC$pedsql_child_total_mean_conv_paired)) , ]