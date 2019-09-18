  # packages -----------------------------------------------------------------
#install.packages(c("REDCapR", "mlr"))
#install.packages(c("dummies"))
library(janitor)
library(dplyr)
library(plyr)
library(redcapAPI)
library(REDCapR)
library(ggplot2)
# get data -----------------------------------------------------------------
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long")
  
load("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long/R01_lab_results 2018-09-28 .rda")

u24_results<-R01_lab_results
u24_results<-u24_results[,order(colnames(u24_results))]
u24_results<-u24_results[order(-(grepl('interview_date|person_id', names(u24_results)))+1L)]
u24_results<-unite(u24_results, int_date, interview_date_aic:interview_date, sep='')

library(data.table)
setDT(u24_results)[, u24_participant:= u24_participant[!is.na(u24_participant)][1L] , by = person_id]
setDT(u24_results)[, u24_interview_date:= u24_interview_date[!is.na(u24_interview_date)][1L] , by = person_id]

u24_participants<- as.data.frame(u24_results[which(u24_results$u24_participant==1 & (u24_results$int_date<u24_results$u24_interview_date)), ])
u24_participants<-u24_participants[c("person_id", "id_site", "redcap_event_name", "int_date","fever_contact"
                                     , "child_travel", "where_travel_aic", "stay_overnight_aic", "temp"
                                     , "fever_contact", "result_igg_denv_stfd", "result_igm_denv_stfd"
                                     , "result_pcr_denv_kenya", "result_pcr_denv_stfd", "denv_result_ufi"
                                     , "result_igg_chikv_stfd", "result_igm_chikv_stfd"
                                     , "result_pcr_chikv_kenya", "result_pcr_chikv_stfd", "chikv_result_ufi"
                                     , "serotype_pcr_denv_kenya___1", "serotype_pcr_denv_kenya___2"
                                     , "serotype_pcr_denv_kenya___3", "serotype_pcr_denv_kenya___4"
                                     , "serotype_pcr_denv_stfd___1", "serotype_pcr_denv_stfd___2"
                                     , "serotype_pcr_denv_stfd___3", "serotype_pcr_denv_stfd___4"
                                     , "ab_denv_stfd_igg", "bc_denv_stfd_igg"
                                     , "cd_denv_stfd_igg", "de_denv_stfd_igg", "ef_denv_stfd_igg"
                                     , "fg_denv_stfd_igg", "gh_denv_stfd_igg", "ab_chikv_stfd_igg"
                                     , "bc_chikv_stfd_igg", "cd_chikv_stfd_igg", "de_chikv_stfd_igg"
                                     , "ef_chikv_stfd_igg", "fg_chikv_stfd_igg", "gh_chikv_stfd_igg", "result_microscopy_malaria_kenya", "microscopy_malaria_pf_kenya___1"
                                     , "microscopy_malaria_po_kenya___1", "microscopy_malaria_pm_kenya___1", "microscopy_malaria_pv_kenya___1"
                                     , "microscopy_malaria_ni_kenya___1", "result_stool_test_", "result_stool_test_2"
                                     , "result_stool_test_3", "result_stool_test_4", "result_stool_test_5", "result_stool_test_6"
                                     , "result_urine_test_kenya", "schistosoma_a", "schistosoma_b")]


u24_results<- u24_results[which(u24_results$redcap_event_name=="visit_u24_arm_1"& u24_results$u24_participant==1), ]
table(R01_lab_results$u24_participant,R01_lab_results$redcap_event_name)
table(u24_results$u24_participant)

currentDate <- Sys.Date() 
FileName <- paste("u24_results",currentDate,".rda",sep=" ") 
save(u24_results,file=FileName)

#merge to z-score
fiveplus<-read.csv("C:/Users/amykr/Box Sync/Amy Krystosik's Files/secure- u24 participants/data/u24_z_scores_5plus_z.csv")
lessthan5<-read.csv("C:/Users/amykr/Box Sync/Amy Krystosik's Files/secure- u24 participants/data/u24_z_scores_under5_z_st.csv")

u24_results<-merge(u24_results,fiveplus,by=c("person_id"),all=T)
u24_results<-merge(u24_results,lessthan5,by=c("person_id"),all=T)


u24_results$u24_date_of_birth<-as.Date(u24_results$u24_date_of_birth)
u24_results$u24_interview_date<-as.Date(u24_results$u24_interview_date)
u24_results$u24_when_dengue<-as.Date(u24_results$u24_when_dengue,"%Y-%m-%d")
u24_results$pedsql_date_parent<-as.Date(u24_results$pedsql_date_parent)
u24_results$pedsql_date<-as.Date(u24_results$pedsql_date)
u24_results$pedsql_date<-as.Date(u24_results$pedsql_date)

u24_results$time_blood_drawn <- strptime(u24_results$time_blood_drawn, "%Y-%m-%d %H:%M")
u24_results$time_on_machine <- strptime(u24_results$time_on_machine, "%Y-%m-%d %H:%M")
u24_results$time_off_machine <- strptime(u24_results$time_off_machine, "%Y-%m-%d %H:%M")

u24_results$time_to_machine<-u24_results$time_blood_drawn-u24_results$time_on_machine

#u24_results<-    u24_results %>%        remove_empty_cols()
vars<-grep("person_id|name|withdrew_why|funny|cohort|site|child_number|participant_status|city|patient_info|name|phonenumber|u24_village_other|u24_when_hospitalized|other|date|aliquot|photo", names(u24_results), value = TRUE, invert = TRUE)

# variable v1 is coded 1, 2 or 3
# we want to attach value labels 1=red, 2=blue, 3=green

u24_results$u24_gender <- factor(u24_results$u24_gender, levels = c(0,1), labels = c("male", "female"))
vars2<-c("result_stool_test_","result_stool_test_2","result_stool_test_3","result_stool_test_4","result_stool_test_5","result_stool_test_6","result_urine_test_kenya","result_microscopy_malaria_kenya")
u24_results[vars2] <- lapply(u24_results[vars2], factor, levels=c(0,1,98,99), labels = c("Absent", "Present","Repeat","Not Performed"))
u24_results$u24_exposure_strata <- ordered(u24_results$u24_exposure_strata, levels = c(0,1,2,3), labels = c("control", "chikv","denv", "both"))
vars3<-c("child_w_freq_white_tubers_and_roots","child_w_freq_eggs","child_w_freq_fish","child_w_freq_organ_meat_iron_rich","child_w_freq_beverages_condiments","child_w_freq_breads_cereals","child_w_freq_other","child_w_freq_other_fruits","child_w_freq_vitamin_a_rich_fruits","child_w_freq_milk_milk_products","child_w_freq_red_palm_products","child_w_freq_flesh_meats","child_w_freq_legumes_nuts_seeds","child_w_freq_oils_and_fats","child_w_freq_sweets","child_w_freq_other_vegetables","child_w_freq_dark_leafy_vegetables","child_w_freq_vitamin_a_rich_vegetables")
u24_results[vars3] <- lapply(u24_results[vars3], factor, levels=c(0,1,2,3,4,99), labels = c("0", "1-3","4-6","7-9","10+","NA"))

vars4<-c("rely_on_lowcost_food","balanced_meal","not_eat_enough","cut_meal_size")
u24_results[vars4] <- lapply(u24_results[vars4], factor, levels=c(1,2,3,99), labels = c("Often true", "sometimes true","never true","refused /dont know"))

vars5<-c("child_hungry","skip_meals","skip_meals_3_months","no_food_entire_day","breastfed","bf_other","bf_formula","bf_animal_milk","dietary_slate","pica_child")
u24_results[vars5] <- lapply(u24_results[vars5], factor, levels=c(0,1,99), labels = c("no","yes","refused/dont know"))
u24_results$first_food_age <- ordered(u24_results$first_food_age, levels = c(1,2,3,4,99), labels = c("0-3", "4-6","7-9", "10+","Refused/Don't Know"))

library(tableone)
#install.packages("expss")
library(expss)
u24_results = apply_labels(u24_results,
                      result_stool_test_ = "Hookworm",
                      result_stool_test_2 = "Trichuris trichiura",
                      result_stool_test_3 = "Ascaris lumbricoides",
                      result_stool_test_4 = "E. histolytica",
                      result_stool_test_5 = "Giardia lamblia",
                      result_stool_test_6 = "Strongyloides",
                      result_urine_test_kenya = "Result Schistosoma haematobium"
                      )
tableOne<-CreateTableOne(data=u24_results, vars=vars)
table1 <- print(tableOne, quote = FALSE, exact=vars, nonnormal=vars,noSpaces = TRUE, printToggle = FALSE)
write.csv(table1, file = "C:/Users/amykr/Box Sync/Amy Krystosik's Files/secure- u24 participants/data/u24_table1_cohort.csv")


tableOne<-CreateTableOne(data=u24_results, vars=vars, strata = "u24_exposure_strata")

u24_results$stunting<-NA
u24_results <- within(u24_results, stunting[u24_results$zhfa>-2|u24_results$zlen>-2] <-0)
u24_results <- within(u24_results, stunting[u24_results$zhfa<=-2|u24_results$zlen<=-2] <-1)
table(u24_results$stunting)

u24_results$wasting<-NA
u24_results <- within(u24_results, wasting[u24_results$zwfl>-2|u24_results$zbmi>-2|u24_results$zbfa>-2] <-0)
u24_results <- within(u24_results, wasting[u24_results$zwfl<=-2|u24_results$zbmi<=-2|u24_results$zbfa<=-2] <-1)
table(u24_results$wasting)
u24_results$nutr_outcome<-u24_results$stunting+u24_results$wasting
u24_results$nutr_outcome<-ifelse(u24_results$stunting==1|u24_results$wasting==1,1,0)

tableOne<-CreateTableOne(data=u24_results, vars=vars3, strata = "stunting")
table1 <- print(tableOne, quote = FALSE, exact=vars, nonnormal=vars,noSpaces = TRUE, printToggle = FALSE)
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/secure- u24 participants/data")
write.csv(table1, file = "u24_table1_stunting.csv")

tableOne<-CreateTableOne(data=u24_results, vars=vars3, strata = "wasting")
table1 <- print(tableOne, quote = FALSE, exact=vars, nonnormal=vars,noSpaces = TRUE, printToggle = FALSE)
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/secure- u24 participants/data")
write.csv(table1, file = "u24_table1_wasting.csv")

tableOne<-CreateTableOne(data=u24_results, vars=vars3, strata = "nutr_outcome")
table1 <- print(tableOne, quote = FALSE, exact=vars, nonnormal=vars,noSpaces = TRUE, printToggle = FALSE)
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/secure- u24 participants/data")
write.csv(table1, file = "u24_table1_nutr_outcome.csv")

write.csv(u24_results,"C:/Users/amykr/Box Sync/Amy Krystosik's Files/secure- u24 participants/data/u24_strata_exposure.csv")

# subjects lists. ------------------------------------------------------------
load("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long/R01_lab_results.clean.rda")

R01_lab_results[R01_lab_results==98]<-NA
R01_lab_results$result_microscopy_malaria_kenya
R01_lab_results$malaria_results
  R01_lab_results$id_cohort<-substr(R01_lab_results$person_id, 2, 2)
  R01_lab_results$id_city<-substr(R01_lab_results$person_id, 1, 1)
  R01_lab_results$date_tested_pcr_chikv_kenya<-as.Date(as.character(as.factor(R01_lab_results$date_tested_pcr_chikv_kenya)),"%Y-%m-%d")
table(R01_lab_results$id_city)
  R01_lab_results$chikv_outbreak<-NA
  R01_lab_results <- within(R01_lab_results, chikv_outbreak[(R01_lab_results$id_city=="G"|R01_lab_results$id_city=="L"|R01_lab_results$id_city=="M") & (R01_lab_results$int_date>="2017-10-01"|R01_lab_results$date_tested_pcr_chikv_kenya>="2017-10-01")&R01_lab_results$infected_chikv_stfd] <-1)
  ggplot(R01_lab_results, aes (x = int_date, y = chikv_outbreak)) +geom_point() +scale_x_date(date_breaks = "1 month", date_labels =  "%b %Y") +theme(axis.text.x=element_text(angle=60, hjust=1),text = element_text(size = 20)) + xlab("Month-Year") + ylab("CHIKV Outbreak") 
  

# those exposed in msambweni. we had so many with any exposure that i cut it down to those with documented incident infection. ---------------------------------------------------------------
  u24_all_wide<-reshape(R01_lab_results, direction = "wide", idvar = "person_id", timevar = "redcap_event_name", sep = ".")
  u24_all_wide$person_id<-as.character(as.factor(u24_all_wide$person_id))
  u24_all_wide<-as.data.frame(u24_all_wide)
  u24_results<-  join(u24_all_wide,u24_results, by = "person_id")


#all visits must be negative to be a control.
      u24_all_wide$exposure_sum<-rowSums(u24_all_wide[, grep("prnt_interpretation_flavi___1|prnt_interpretation_alpha___2|result_igg_denv_stfd|infected_denv_stfd|infected_chikv_stfd|result_igg_chikv_stfd|result_igg_denv_stfd", names(u24_all_wide))], na.rm = TRUE)
      u24_all_wide$incident_prnt_denv_exposure_sum<-rowSums(u24_all_wide[, grep("prnt_interpretation_flavi___1|infected_denv_stfd", names(u24_all_wide))], na.rm = TRUE)
      u24_all_wide$incident_prnt_chikv_exposure_sum<-rowSums(u24_all_wide[, grep("prnt_interpretation_alpha___2|infected_chikv_stfd", names(u24_all_wide))], na.rm = TRUE)
      table(u24_all_wide$incident_prnt_chikv_exposure_sum)
      table(u24_all_wide$incident_prnt_denv_exposure_sum)

      u24_all_wide$denv_exposure_sum<-rowSums(u24_all_wide[, grep("prnt_interpretation_flavi___1|infected_denv_stfd|result_igg_denv_stfd", names(u24_all_wide))], na.rm = TRUE)
      u24_all_wide$chikv_exposure_sum<-rowSums(u24_all_wide[, grep("prnt_interpretation_alpha___2|infected_chikv_stfd|result_igg_chikv_stfd", names(u24_all_wide))], na.rm = TRUE)
      u24_all_wide$denv_pcr_sum<-rowSums(u24_all_wide[, grep("infected_denv_stfd", names(u24_all_wide))], na.rm = TRUE)
      u24_all_wide$chikv_pcr_sum<-rowSums(u24_all_wide[, grep("infected_chikv_stfd", names(u24_all_wide))], na.rm = TRUE)
      u24_all_wide$denv_prnt_sum<-rowSums(u24_all_wide[, grep("prnt_interpretation_flavi___1", names(u24_all_wide))], na.rm = TRUE)
      u24_all_wide$chikv_prnt_sum<-rowSums(u24_all_wide[, grep("prnt_interpretation_alpha___2", names(u24_all_wide))], na.rm = TRUE)
      table(u24_all_wide$denv_exposure_sum,u24_all_wide$chikv_exposure_sum)
      table(u24_all_wide$chikv_exposure_sum)
      table(u24_all_wide$denv_exposure_sum)

      u24_all_wide$pcr_denv_exposure_sum<-rowSums(u24_all_wide[, grep("result_pcr_denv|denv_result_ufi", names(u24_all_wide))], na.rm = TRUE)
      table(u24_all_wide$pcr_denv_exposure_sum)
      u24_all_wide$pcr_chikv_exposure_sum<-rowSums(u24_all_wide[, grep("result_pcr_chikv|$chikv_result_ufi", names(u24_all_wide))], na.rm = TRUE)
      table(u24_all_wide$pcr_chikv_exposure_sum)
      u24_all_wide$chikv_outbreak_sum<-rowSums(u24_all_wide[, grep("chikv_outbreak", names(u24_all_wide))], na.rm = TRUE)
      table(u24_all_wide$chikv_outbreak_sum)


#u24_all_wide<-    u24_all_wide %>%        remove_empty_cols()
    u24_all_wide<- u24_all_wide[, grepl("person_id|age|gender|prnt_result_chikv|prnt_result_denv|infected|exposure|prnt_interpretation_flavi___1|prnt_interpretation_alpha___2|result_igg_denv_stfd|infected_denv_stfd|infected_chikv_stfd|result_igg_chikv_stfd|result_igg_denv_stfd|name|dob|phone|village|date_of_birth|interview_date|result_pcr_|result_ufi|chikv_outbreak|sum|participant|chikv_prnt_sum|denv_prnt_sum|denv_pcr_sum|chikv_pcr_sum|u24_age_calc", names(u24_all_wide))]
    u24_all_wide$incident_prnt_u24_strata<-NA
    u24_all_wide$date_of_birth.visit_a_arm_1<-as.Date(u24_all_wide$date_of_birth.visit_a_arm_1)
    u24_all_wide$date_of_birth.visit_a_arm_1<-as.Date(u24_all_wide$date_of_birth.visit_a_arm_1)

    summary(u24_all_wide$date_of_birth.visit_a_arm_1)
    u24_all_wide <- within(u24_all_wide, incident_prnt_u24_strata[u24_all_wide$exposure_sum ==0] <- "control")
    u24_all_wide <- within(u24_all_wide, incident_prnt_u24_strata[u24_all_wide$incident_prnt_chikv_exposure_sum >=1 ] <- "chikv")
    u24_all_wide <- within(u24_all_wide, incident_prnt_u24_strata[u24_all_wide$incident_prnt_denv_exposure_sum >=1] <- "denv")
    u24_all_wide <- within(u24_all_wide, incident_prnt_u24_strata[u24_all_wide$incident_prnt_chikv_exposure_sum>=1 & u24_all_wide$incident_prnt_denv_exposure_sum ==1] <- "both")
    u24_all_wide$id_city<-substr(u24_all_wide$person_id, 1, 1)
    table(u24_all_wide$incident_prnt_u24_strata,u24_all_wide$id_city)

    u24_all_wide$u24_strata<-NA
    u24_all_wide <- within(u24_all_wide, u24_strata[u24_all_wide$exposure_sum ==0] <- "control")
    u24_all_wide <- within(u24_all_wide, u24_strata[u24_all_wide$chikv_exposure_sum >=1] <- "chikv")
    u24_all_wide <- within(u24_all_wide, u24_strata[u24_all_wide$denv_exposure_sum >=1] <- "denv")
    u24_all_wide <- within(u24_all_wide, u24_strata[u24_all_wide$chikv_exposure_sum>=1 & u24_all_wide$denv_exposure_sum >=1] <- "both")
    table(u24_all_wide$u24_strata)
    
u24_all_wide$id_city<-substr(u24_all_wide$person_id, 1, 1)
table(u24_all_wide$id_city)
u24_all_wide <- u24_all_wide[ which((u24_all_wide$id_city=="M"|u24_all_wide$id_city=="L"|u24_all_wide$id_city=="G")), ]
u24_all_wide_m<-merge(u24_all_wide,u24_results,by="person_id")
u24_results_report<-u24_all_wide_m[which(u24_all_wide_m$u24_participant==1),
                                   c("person_id","incident_prnt_u24_strata.x","u24_strata","chikv_prnt_sum","denv_prnt_sum","denv_pcr_sum","chikv_pcr_sum","u24_child_age","u24_age_calc","u24_gender","u24_temp","chikv_outbreak_sum",	"sample_completed_protocol",	"notes_smart_tube", "time_blood_drawn",	"time_on_machine",	"time_off_machine",	"temperature_off_machine","result_urine_test_kenya", "schistosoma_a", "schistosoma_b","result_stool_test_6","result_stool_test_", "value_stool_test_",	"result_stool_test_2",	"value_stool_test_2",	"result_stool_test_3",	"value_stool_test_3",	"result_stool_test_4",	"result_stool_test_5","microscopy_malaria_pf_kenya___1","result_microscopy_malaria_kenya","u24_interview_date","tech_smart_tube","tech_smart_tube_other")]

table(u24_all_wide_m$u24_participant,u24_all_wide_m$u24_strata,exclude=NULL)
18    +54      +32   +30

write.csv(u24_results_report,
          "C:/Users/amykr/Box Sync/Amy Krystosik's Files/secure- u24 participants/data/u24_results_report.csv",
          na="",row.names = F)

table(u24_results_report$incident_prnt_u24_strata.x)
u24<-u24_all_wide[c("person_id", "u24_strata","incident_prnt_u24_strata")]
saveRDS(u24, file = "u24.rds")
write.csv(u24,"C:/Users/amykr/Box Sync/Amy Krystosik's Files/secure- u24 participants/data/u24.csv")

controls<-u24[which(u24$u24_strata=="control"),]
write_rds(controls,"controls.rds")
cases<-u24[which(u24$u24_strata!="control"& !is.na(u24$u24_strata)),]
write_rds(cases,"cases.rds")
    u24_all_wide$case_control<-NA
    u24_all_wide <- within(u24_all_wide, case_control[u24_all_wide$u24_strata =="control" & !is.na(u24_all_wide$age.visit_a_arm_1) & !is.na(u24_all_wide$gender_all.visit_a_arm_1)] <- "control")
    u24_all_wide <- within(u24_all_wide, case_control[(u24_all_wide$u24_strata =="chikv"|u24_all_wide$u24_strata =="denv"|u24_all_wide$u24_strata =="both") & (!is.na(u24_all_wide$age.visit_a_arm_1) & !is.na(u24_all_wide$gender_all.visit_a_arm_1)& u24_all_wide$u24_participant==1 )] <- "case")
    table(u24_all_wide$case_control, u24_all_wide$u24_strata, exclude = NULL)
    
both <- u24_all_wide[ which(u24_all_wide$u24_strata=='both'), ]
write.csv(both,"both.csv")
## now look at the group properties:
  boxplot(u24_all_wide$age.visit_a_arm_1 ~ u24_all_wide$u24_strata)
  barplot(table(u24_all_wide$gender_all.visit_a_arm_1, u24_all_wide$u24_strata), beside = TRUE)
u24_all_wide[which(u24_all_wide$u24_strata=="both"),"person_id"]
u24_all_wide[which(u24_all_wide$u24_strata=="chikv"),"person_id"]
table(u24_all_wide$u24_strata,u24_all_wide$id_city)

U24.Sample.Shipment.inventory.May.2018 <- read.csv("C:/Users/amykr/Box Sync/U24 Project/U24 Sample Shipment inventory May 2018.csv",fileEncoding="UTF-8-BOM", sep=",")
u24_results_report_inventory_may2018<-merge(U24.Sample.Shipment.inventory.May.2018,u24_results_report,all=T)

write.csv(u24_results_report_inventory_may2018,
          "C:/Users/amykr/Box Sync/Amy Krystosik's Files/secure- u24 participants/data/u24_results_report_inventory.csv",
          na="",row.names = F)
