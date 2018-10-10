# packages -----------------------------------------------------------------
#install.packages(c("REDCapR", "mlr"))
#install.packages(c("dummies"))
library(janitor)
library(tidyverse)
library(redcapAPI)
library(REDCapR)
library(ggplot2)
# get data -----------------------------------------------------------------
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long")
  
load("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long/R01_lab_results 2018-09-28 .rda")
u24_results<-R01_lab_results
u24_results<-u24_results[,order(colnames(u24_results))]
u24_results<-u24_results[order(-(grepl('interview_date|person_id|redcap_event_name|u24_participant', names(u24_results)))+1L)]
u24_results$interview_date_aic<-as.character(u24_results$interview_date_aic)
u24_results$interview_date_aic[is.na(u24_results$interview_date_aic)] <- ""

u24_results$interview_date<-as.character(u24_results$interview_date)
u24_results$interview_date[is.na(u24_results$interview_date)] <- ""

u24_results<-tidyr::unite(u24_results, int_date, interview_date_aic:interview_date, sep='')
library(data.table)
setDT(u24_results)[, u24_participant:= u24_participant[!is.na(u24_participant)][1L] , by = person_id]
setDT(u24_results)[, u24_interview_date:= u24_interview_date[!is.na(u24_interview_date)][1L] , by = person_id]
table(u24_results$redcap_event_name,u24_results$u24_participant)
table(u24_results$u24_participant)

# all u24 participant visits (aic + hcc) before the u24 visit count towards exposure --------
u24_results<- as.data.frame(u24_results[which(u24_results$u24_participant==1 & (u24_results$int_date<=u24_results$u24_interview_date|is.na(u24_results$int_date))), ])
table(u24_results$redcap_event_name,u24_results$u24_participant,exclude = NULL)


u24_results<-u24_results[c("person_id", "redcap_event_name", "int_date","fever_contact","u24_participant","u24_interview_date","age_calc","age_calc_rc"
                                     , "child_travel", "where_travel_aic", "stay_overnight_aic","u24_when_dengue","pedsql_date_parent"                                      , "fever_contact", "result_igg_denv_stfd", "result_igm_denv_stfd"
                                     , "result_pcr_denv_kenya", "result_pcr_denv_stfd", "denv_result_ufi"
                                     , "result_igg_chikv_stfd", "result_igm_chikv_stfd","pedsql_date"
                                     , "result_pcr_chikv_kenya", "result_pcr_chikv_stfd", "chikv_result_ufi","time_blood_drawn"
                                     , "serotype_pcr_denv_kenya___1", "serotype_pcr_denv_kenya___2"
                                     , "serotype_pcr_denv_kenya___3", "serotype_pcr_denv_kenya___4","time_on_machine"
                                     , "serotype_pcr_denv_stfd___1", "serotype_pcr_denv_stfd___2"
                                     , "serotype_pcr_denv_stfd___3", "serotype_pcr_denv_stfd___4"
                                     , "ab_denv_stfd_igg", "bc_denv_stfd_igg","time_off_machine"
                                     , "cd_denv_stfd_igg", "de_denv_stfd_igg", "ef_denv_stfd_igg"
                                     , "fg_denv_stfd_igg", "gh_denv_stfd_igg", "ab_chikv_stfd_igg"
                                     , "bc_chikv_stfd_igg", "cd_chikv_stfd_igg", "de_chikv_stfd_igg"
                                     , "ef_chikv_stfd_igg", "fg_chikv_stfd_igg", "gh_chikv_stfd_igg", "result_microscopy_malaria_kenya", "microscopy_malaria_pf_kenya___1"
                                     , "microscopy_malaria_po_kenya___1", "microscopy_malaria_pm_kenya___1", "microscopy_malaria_pv_kenya___1"
                                     , "microscopy_malaria_ni_kenya___1", "result_stool_test_", "result_stool_test_2"
                                     , "result_stool_test_3", "result_stool_test_4", "result_stool_test_5", "result_stool_test_6"
                                     , "result_urine_test_kenya", "schistosoma_a", "schistosoma_b","u24_date_of_birth","u24_gender","u24_exposure_strata", "child_w_freq_white_tubers_and_roots","child_w_freq_eggs","child_w_freq_fish","child_w_freq_organ_meat_iron_rich","child_w_freq_beverages_condiments","child_w_freq_breads_cereals","child_w_freq_other","child_w_freq_other_fruits","child_w_freq_vitamin_a_rich_fruits","child_w_freq_milk_milk_products","child_w_freq_red_palm_products","child_w_freq_flesh_meats","child_w_freq_legumes_nuts_seeds","child_w_freq_oils_and_fats","child_w_freq_sweets","child_w_freq_other_vegetables","child_w_freq_dark_leafy_vegetables","child_w_freq_vitamin_a_rich_vegetables"
                                     ,"rely_on_lowcost_food","balanced_meal","not_eat_enough","cut_meal_size","first_food_age"
                           ,"child_hungry","skip_meals","skip_meals_3_months","no_food_entire_day","breastfed","bf_other","bf_formula","bf_animal_milk","dietary_slate","pica_child","child_eats_freq_day","child_eats_freq_day","child_nutrition_complete","first_food_what","first_food_age")]

#source("C:/Users/amykr/Documents/GitHub/lebeaud_lab/u24/u24 exposure strata.R")
load("C:/Users/amykr/Box Sync/Amy Krystosik's Files/secure- u24 participants/data/u24_exposure.rds")

u24_results<-merge(u24_all_wide,u24_results,by=c("person_id"), all.y=T)

# combined exposure and incidence -----------------------------------------
table(u24_results$u24_participant,u24_results$incident_prnt_u24_strata,u24_results$redcap_event_name,exclude=NULL)
u24_results <- within(u24_results, incident_prnt_u24_strata[u24_results$incident_prnt_u24_strata=="chikv"] <-"Recent CHIKV")
u24_results <- within(u24_results, incident_prnt_u24_strata[u24_results$incident_prnt_u24_strata=="denv"] <-"Recent DENV")
u24_results <- within(u24_results, incident_prnt_u24_strata[u24_results$incident_prnt_u24_strata=="both"] <-"Recent Co-Exposure")

u24_results <- within(u24_results, u24_strata[u24_results$u24_strata=="chikv"] <-"CHIKV")
u24_results <- within(u24_results, u24_strata[u24_results$u24_strata=="denv"] <-"DENV")
u24_results <- within(u24_results, u24_strata[u24_results$u24_strata=="both"] <-"Co-Exposure")

u24_results$combined_strata = ifelse(is.na(u24_results$incident_prnt_u24_strata), 
                                     u24_results$u24_strata,u24_results$incident_prnt_u24_strata) 
table(u24_results$combined_strata,u24_results$redcap_event_name)

u24_results<-u24_results[!is.na(u24_results$combined_strata),]

# #merge to z-score ------------------------------------------------------
#source("C:/Users/amykr/Documents/GitHub/lebeaud_lab/u24/igrowup_longitudinal.R")
fiveplus<-read.csv("C:/Users/amykr/Box Sync/Amy Krystosik's Files/secure- u24 participants/data/z_scores_5plus_long_z.csv")
lessthan5<-read.csv("C:/Users/amykr/Box Sync/Amy Krystosik's Files/secure- u24 participants/data/z_scores_under5_long_z_st.csv")
z<-plyr::rbind.fill(fiveplus,lessthan5)

u24_results<-merge(u24_results,z,by=c("person_id","redcap_event_name"),all.x=T)

plot(u24_results$zwfa,u24_results$zhfa)
u24_results$incident_prnt_u24_strata<-as.factor(u24_results$incident_prnt_u24_strata)
ggplot(u24_results,aes(x=zwfa, y=zhfa,color=incident_prnt_u24_strata))+geom_point(size=7)+scale_y_continuous(breaks=c(-9:9))+scale_x_continuous(breaks=c(-9:9))



# merge u24 data to who standards for weight for age and height for age by age and sex --------------------------------------
load("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long/who_height.Rda")
summary(height.length.age$age.month)
u24_results$sex<-as.character(u24_results$sex)
u24_results$sex[u24_results$sex=="f"] <-2
u24_results$sex[u24_results$sex=="m"] <-1
u24_results$sex<-as.numeric(u24_results$sex)

u24_results<-u24_results[order(-(grepl('interview_date|person_id|redcap_event_name|u24_participant|sex|age|int_date', names(u24_results)))+1L)]
u24_results<- as.data.frame(u24_results[which(u24_results$redcap_event_name!="patient_informatio_arm_1"&!is.na(u24_results$height)), ])
names(u24_results)[names(u24_results) == 'agemonth'] <- 'age.month'
u24_results$age.month<-round(u24_results$age.month,0)
u24_results<-merge(u24_results,height.length.age,by=c("sex","age.month"), all.x=T)

u24_results<-u24_results[!is.na(u24_results$sex),]
u24_results$sex<-as.character(u24_results$sex)
u24_results$sex <- factor(u24_results$sex, levels = c(2,1),labels = c("FEMALE", "MALE"))

height.length.age<-height.length.age[!is.na(height.length.age$sex),]
height.length.age$sex<-as.character(height.length.age$sex)
height.length.age$sex <- factor(height.length.age$sex, levels = c(2,1),labels = c("FEMALE", "MALE"))

smoothed.ribbon.med.3sd<-ggplot(data=height.length.age)+
  facet_grid(.~sex)+
  stat_smooth(aes(age.month,m, colour="median"),size=2,alpha=.5, method = "loess", se = FALSE ) +
  stat_smooth(aes(age.month,who_height.3sd, colour="-3sd"),size=2 ,alpha=.5, method = "loess", se = FALSE) 

# build plot object for rendering 
gg1 <- ggplot_build(smoothed.ribbon.med.3sd)
# extract data for the loess lines from the 'data' slot
df2 <- data.frame(x = gg1$data[[1]]$x,
                  ymin = gg1$data[[1]]$y,
                  ymax = gg1$data[[2]]$y)

library("extrafont")
table(u24_results$combined_strata)
u24_results$incident<-ifelse(grepl("Recent",u24_results$combined_strata),'Incident','Ever')
table(u24_results$incident)
u24_results$strata<-gsub("Recent ","",u24_results$combined_strata)
u24_results$strata<-gsub("control","Control",u24_results$strata)
table(u24_results$strata)

height.age<-ggplot()+ 
  geom_ribbon(data = df2, aes(x = x, ymin = ymin, ymax = ymax,fill = "grey"), alpha = 0.2)+
  geom_smooth(data =u24_results,aes(age.month,height, color="Cohort\nLoess Regression\n& 95% CI", linetype="Cohort\nLoess Regression\n& 95% CI"),level=.95,size=1,formula=y~x,method="loess",alpha=.9) +
  geom_line(data =height.length.age,aes(age.month,who_height.2sd,color="WHO -2SD", linetype="WHO -2SD"),size=1,alpha=.9) +
  geom_jitter(data =u24_results,mapping=aes(x=age.month,y=height,shape=strata,color=incident),alpha=.5,size=3,position = "jitter")+
  facet_grid(.~sex)+
  labs(title ="", x = "Age (months)", y = "Height (cm)")+ 
  theme_classic(base_size = 12, base_family="Arial")+ theme(legend.position = "bottom") + guides(color=guide_legend(override.aes=list(fill=NA)))+
  scale_color_manual(name = "", values = c("Cohort\nLoess Regression\n& 95% CI"="black",Incident="red",Ever="black","WHO -2SD" = "black"), labels = c("Cohort\nLoess Regression\n& 95% CI","Incident","Ever","WHO -2SD"))+
  scale_fill_identity(name = '', guide = FALSE,labels = c('grey'='WHO median to -3SD')) +
  scale_linetype_manual(name = "",values = c("Cohort\nLoess Regression\n& 95% CI"=1, "WHO -2SD" = 3))+
  scale_shape_manual("Exposure Categories",values=1:7)+
  theme(legend.text	= element_text(colour = "black",size= 12, family="Arial"),
        strip.text = element_text(colour = "black",size= 12),
        strip.background = element_rect(fill="transparent",colour=NA),
  )

setwd(  "C:/Users/amykr/Box Sync/Amy Krystosik's Files/secure- u24 participants/data")
tiff(file = "anthro_exposed.tiff", width = 8000, height = 3200, units = "px", res = 600)
height.age
dev.off()

# only the u24 visit ------------------------------------------------------
u24_results<-u24_results[which(u24_results$redcap_event_name=="visit_u24_arm_1"&u24_results$u24_participant==1),]

# nutrtion scores ---------------------------------------------------------
food_groups<-names(u24_results[grep("child_w_freq_",names(u24_results))])
for(i in food_groups ){
  u24_results[[i]][u24_results[[i]]==0]   <-0
  u24_results[[i]][u24_results[[i]]==1] <-2
  u24_results[[i]][u24_results[[i]]==2] <-5
  u24_results[[i]][u24_results[[i]]==3] <-8
  u24_results[[i]][u24_results[[i]]==4] <-10
  u24_results[[i]][u24_results[[i]]==99] <-NA
}

for(i in food_groups ){
  var<-paste(i,"bin",sep="_")
  u24_results[[var]][u24_results[[i]]==0] <-0
  u24_results[[var]][u24_results[[i]]>0] <-1
}

u24_results$flesh<-rowSums(u24_results[c("child_w_freq_fish","child_w_freq_organ_meat_iron_rich","child_w_freq_flesh_meats")],na.rm=T)
u24_results$grains_tubers<-rowSums(u24_results[c("child_w_freq_white_tubers_and_roots","child_w_freq_breads_cereals")],na.rm=T)
u24_results$vit_a_fruit_veg<-rowSums(u24_results[c("child_w_freq_vitamin_a_rich_vegetables","child_w_freq_vitamin_a_rich_fruits")],na.rm=T)
u24_results$other_fruit_veg<-rowSums(u24_results[c("child_w_freq_dark_leafy_vegetables","child_w_freq_other_fruits","child_w_freq_other_vegetables")],na.rm=T)

who_food_groups<-c("flesh", "grains_tubers", "vit_a_fruit_veg", "other_fruit_veg")

for(i in who_food_groups){
  var<-paste(i,"bin",sep="_")
  u24_results[[var]][u24_results[[i]]==0] <-0
  u24_results[[var]][u24_results[[i]]>0] <-1
}

who_food_groups_bin<-c("flesh_bin", "child_w_freq_milk_milk_products_bin", "child_w_freq_eggs_bin", "grains_tubers_bin" , "child_w_freq_legumes_nuts_seeds_bin", "vit_a_fruit_veg_bin", "other_fruit_veg_bin")
u24_results$diet_diversity_score<-rowSums(u24_results[who_food_groups_bin])
table(u24_results$diet_diversity_score)

u24_results$animal_protein<-rowSums(u24_results[c("flesh_bin", "child_w_freq_milk_milk_products_bin", "child_w_freq_eggs_bin")])
table(u24_results$animal_protein)

u24_results_nutrition<-u24_results[ , grepl( "redcap_event_name|bin|child_w_freq_|strata|z|height|weight|diet_diversity|animal_protein|flesh|grains_tubers|vit_a_fruit_veg|other_fruit_veg" , names(u24_results) ) ]
u24_results_nutrition<-u24_results_nutrition[ , !grepl( "aic|zone|trizol|hospitaliz|history|immunizations|complete" , names(u24_results_nutrition) ) ]
write.csv(u24_results_nutrition,file="u24_results_nutrition.csv",na="")

# pedsql ------------------------------------------------------------------

# dates --------------------------------------------------------------------
u24_results$u24_date_of_birth<-lubridate::as_date(u24_results$u24_date_of_birth)
u24_results$u24_interview_date<-as.Date(u24_results$u24_interview_date)
u24_results$u24_when_dengue<-lubridate::as_date(u24_results$u24_when_dengue)
u24_results$pedsql_date_parent<-lubridate::as_date(u24_results$pedsql_date_parent)
u24_results$pedsql_date<-lubridate::as_date(u24_results$pedsql_date)
u24_results$pedsql_date<-lubridate::as_date(u24_results$pedsql_date)


u24_results$time_blood_drawn <- strptime(u24_results$time_blood_drawn, "%Y-%m-%d %H:%M")
u24_results$time_on_machine <- strptime(u24_results$time_on_machine, "%Y-%m-%d %H:%M")
u24_results$time_off_machine <- strptime(u24_results$time_off_machine, "%Y-%m-%d %H:%M")

u24_results$time_to_machine<-u24_results$time_on_machine-u24_results$time_blood_drawn
table(u24_results$time_to_machine)

vars<-grep("person_id|name|withdrew_why|funny|cohort|site|child_number|participant_status|city|patient_info|name|phonenumber|u24_village_other|u24_when_hospitalized|other|date|aliquot|photo", names(u24_results), value = TRUE, invert = TRUE)

# variable v1 is coded 1, 2 or 3
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

tableOne<-CreateTableOne(data=u24_results, vars=vars, strata = "incident_prnt_u24_strata")
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
