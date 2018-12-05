library(tableone)
# import data -------------------------------------------------------------
  #source("C:/Users/amykr/Documents/GitHub/lebeaud_lab/david/export r01 data from redcap and create binary vars.R")#don't run every time
      setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/david coinfection paper/data")
      load("R01_lab_results.david.coinfection.dataset.rda")#load data that has been cleaned previously#final data set made on 11/16/18 for david conifection paper.

# format data -------------------------------------------------------------
AIC<- R01_lab_results[which(R01_lab_results$redcap_event_name!="patient_informatio_arm_1" & R01_lab_results$redcap_event_name!="visit_a2_arm_1"&R01_lab_results$redcap_event_name!="visit_b2_arm_1"&R01_lab_results$redcap_event_name!="visit_c2_arm_1"&R01_lab_results$redcap_event_name!="visit_d2_arm_1"&R01_lab_results$redcap_event_name!="visit_u24_arm_1"),]
AIC<-AIC[which(AIC$id_cohort=="F"), ]
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
#source("C:/Users/amykr/Documents/GitHub/lebeaud_lab/u24/igrowup_longitudinal.R")
load("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long/z_scores.rda")
zbmi<-z[which(z$zbmi>5|z$zbmi< (-5)),]
zhfa<-z[which(z$zhfa>5|z$zhfa< (-5)),]
write.csv(zhfa,file="height for age out of bounds.csv")
write.csv(zbmi,file="bmi out of bounds.csv")

AIC<-merge(AIC,z,by=c("person_id","redcap_event_name"),all.x=T)
colnames(AIC)[colnames(AIC) == 'age.x'] <- 'age'

# define acute febrile illness ------------------------------------------------------------------------
 source("C:/Users/amykr/Documents/GitHub/lebeaud_lab/david/define acute febrile illness.r")
table(AIC$acute,AIC$redcap_event_name,exclude = NULL)

AIC_B<-AIC[which(AIC$acute!=1 & AIC$redcap_event_name=="visit_b_arm_1"), ]
AIC<-AIC[which(AIC$acute==1&(AIC$redcap_event_name=="visit_a_arm_1")), ]
table(AIC$acute,AIC$redcap_event_name)

var<-c("age","height","sex","zhfa", "zbmi","ses_sum")

acute_by_city <- CreateTableOne(vars = var, strata = "id_city", data = AIC)
print(acute_by_city,nonnormal=c("age"))

acute_by_site <- CreateTableOne(vars = var, strata = "site", data = AIC)
print(acute_by_site,nonnormal=c("age"))
AIC$urban<-NA
AIC <- within(AIC, urban[id_city=="K"|id_city=="U"] <-1 )
AIC <- within(AIC, urban[id_city=="C"|id_city=="M"] <-0 )

acute <- CreateTableOne(vars = var, data = AIC)
print(acute,nonnormal=c("age"))

acute_urban <- CreateTableOne(vars = var, strata = "urban",data = AIC)
print(acute_urban,nonnormal=c("age"))

# demographics, ses, and mosquito indices ------------------------------------------------------------
source("C:/Users/amykr/Documents/GitHub/lebeaud_lab/david/demographics, ses, and mosquito indices.r")

#denv and malaria case definition------------------------------------------------------------------------
source("C:/Users/amykr/Documents/GitHub/lebeaud_lab/david/strata definitions.R")
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

# denv tables -------------------------------------------------
table(!is.na(AIC$infected_denv_stfd))
table(AIC$infected_denv_stfd)
table(AIC$infected_denv_stfd)/sum(table(AIC$infected_denv_stfd))*1000
tapply(AIC$infected_denv_stfd, AIC$year, summary)
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
# ses pca ------------------------------------------------------------
source("C:/Users/amykr/Documents/GitHub/lebeaud_lab/david/ses pca.R")

# outcome hospitalized ----------------------------------------------------
 AIC$outcome_hospitalized<-as.numeric(as.character(AIC$outcome_hospitalized))
 AIC <- within(AIC, outcome_hospitalized[outcome_hospitalized==8] <-1 )
 table(AIC$outcome_hospitalized)
# demographic tables and graphs -------------------------------------------------------
 source("C:/Users/amykr/Documents/GitHub/lebeaud_lab/david/demogarphy or tables.R")

# pe and symptoms table ----------------------------------------------------------
 source("C:/Users/amykr/Documents/GitHub/lebeaud_lab/david/symptoms.R")

##merge with paired(acute and convalescent) pedsql data -----------------------------------------------------------------------
 source("C:/Users/amykr/Documents/GitHub/lebeaud_lab/david/calculate pedsql scores and pair.r")
 load("AIC.rda")
 names(pedsql_pairs_acute)[names(pedsql_pairs_acute) == 'redcap_event_name_acute_paired'] <- 'redcap_event_name'
 names(AIC)[names(AIC) == 'redcap_event'] <- 'redcap_event_name'
 pedsql_pairs_acute<-pedsql_pairs_acute[which(pedsql_pairs_acute$redcap_event_name=="visit_a_arm_1"),]
 table(pedsql_pairs_acute$redcap_event_name)
 
 AIC <- join(AIC, pedsql_pairs_acute, by=c("person_id", "redcap_event_name"), match = "first" , type="left")
 
 AIC<-AIC[order(-(grepl('person_id|redcap|pedsql_', names(AIC)))+1L)]
 
 source("C:/Users/amykr/Documents/GitHub/lebeaud_lab/david/acute visit outcomes- pe, pedsql.R")
 
##merge with unpaired pedsql data -----------------------------------------------------------------------
 load("pedsql_unpaired.rda")
 names(pedsql_unpaired)[names(pedsql_unpaired) == 'redcap_event'] <- 'redcap_event_name'
 pedsql_unpaired<-pedsql_unpaired[which(pedsql_unpaired$redcap_event_name=="visit_a_arm_1"),]
 table(pedsql_unpaired$redcap_event_name)
 AIC <- join(AIC, pedsql_unpaired, by=c("person_id", "redcap_event_name"), match = "first" , type="left")
 nrow(AIC)
# save and export data ----------------------------------------------------
 save(AIC,file="david_denv_malaria_cohort.rda")
# save and export strata and hospitalization data ----------------------------------------------------
 david_coinfection_strata_hospitalization<-AIC[, grepl("person_id|redcap_event_name|strata|outcome_hospitalized|outcome|gender_all|ses_sum|mom_highest_level_education", names(AIC))]
 save(david_coinfection_strata_hospitalization,file="C:/Users/amykr/Box Sync/Amy Krystosik's Files/david coinfection paper/data/david_coinfection_strata_hospitalization.rda")
 table(AIC$strata_all)
# pedsql tables and graphs -------------------------------------------------------
 list<-grep("mean_acute_paired|mean_conv_paired|change|mean_z", names(AIC), value = TRUE)
 pedsqlvar_aic<-pedsqlvar_aic[pedsqlvar_aic != "home_lifestyle_changes"]
 pedsql_paired_tableOne <- CreateTableOne(vars = pedsqlvar_aic, strata = "strata_all", data = AIC)
 pedsql_tableOne_unpaired_acute <- CreateTableOne(vars = pedsqlvar, strata = "strata_all", data = pedsql_all_coinfection_acute,includeNA=T)
 df<-AIC
 source("C:/Users/amykr/Documents/GitHub/lebeaud_lab/david/histograms.R")

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