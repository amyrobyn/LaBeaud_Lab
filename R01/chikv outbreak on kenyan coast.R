#chikv outbreak in kenyan coast
#last updated march 6 2019

# import data -------------------------------------------------------------
setwd("C:/Users/amykr/Box Sync/Amy's Externally Shareable Files/chikv outbreak")
load("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long/R01_lab_results.clean.rda")    
R01_lab_results<-R01_lab_results[, !grepl("pedsql", names(R01_lab_results))]
R01_lab_results<- R01_lab_results[-which(R01_lab_results$int_date<"2013-01-01"),]

##plot cases per month----------------------------------------------------------------------
cases_month<-as.data.frame(table(R01_lab_results$infected_chikv_stfd, R01_lab_results$month_year))
plot(cases_month$Var2,cases_month$Freq,col=cases_month$Var1)
library(ggplot2)
R01_lab_results$epi_week<-epiweek(R01_lab_results$int_date)

# define acute febrile illness------------------------------------------------------------------------
R01_lab_results <- R01_lab_results[, !grepl("u24|sample", names(R01_lab_results) ) ]
R01_lab_results$acute<-NA
#if they have fever, call it acute
R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$R01_lab_results_symptom_fever==1] <- 1)
table(R01_lab_results$acute,R01_lab_results$redcap_event_name,exclude = NULL)
R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$temp>=38] <- 1)
table(R01_lab_results$acute,R01_lab_results$redcap_event_name,exclude = NULL)
#if they ask an initial survey question (see odk R01_lab_results inital and follow up forms), it is an initial visit.
R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$kid_highest_level_education_R01_lab_results!=""] <- 1)
R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$occupation_R01_lab_results!=""] <- 1)

#otherwise, it is not acute
R01_lab_results <- within(R01_lab_results, acute[is.na(R01_lab_results$acute)] <- 0)
table(R01_lab_results$acute,R01_lab_results$redcap_event_name,exclude = NULL)

### from July 2017 to June 2018?-----------------------------------------------------------------------
coast_oubreak<-R01_lab_results[R01_lab_results$int_date>="2017-07-01" & R01_lab_results$int_date<"2018-06-01"& !is.na(R01_lab_results$int_date)&(R01_lab_results$City=="M"|R01_lab_results$City=="U") & R01_lab_results$acute==1, ]

### define malaria-----------------------------------------------------------------------
coast_oubreak$malaria<-NA
coast_oubreak <- within(coast_oubreak, malaria[coast_oubreak$result_rdt_malaria_keny==0] <- 0)#rdt
coast_oubreak <- within(coast_oubreak, malaria[coast_oubreak$rdt_result==0] <- 0)#rdt
coast_oubreak <- within(coast_oubreak, malaria[coast_oubreak$malaria_results==0] <- 0)# Results of malaria blood smear	(+++ system)
coast_oubreak <- within(coast_oubreak, malaria[coast_oubreak$result_microscopy_malaria_kenya==0] <- 0)#microscopy. this goes last so that it overwrites all the other's if it exists.

coast_oubreak <- within(coast_oubreak, malaria[coast_oubreak$result_microscopy_malaria_kenya==1] <- 1) #this goes first. only use the others if this is missing.
coast_oubreak <- within(coast_oubreak, malaria[coast_oubreak$malaria_results>0 & is.na(result_microscopy_malaria_kenya)] <- 1)# Results of malaria blood smear	(+++ system)
coast_oubreak <- within(coast_oubreak, malaria[coast_oubreak$rdt_results==1 & is.na(result_microscopy_malaria_kenya)] <- 1)#rdt
table(coast_oubreak$malaria)

### #create strata: 1 = malaria+ & chikv + | 2 = malaria+ chikv - | 3= malaria- & chikv - | 4= malaria- & chikv + -----------------------------------------------------------------------
coast_oubreak$strata_chikv_malaria<-NA
coast_oubreak <- within(coast_oubreak, strata_chikv_malaria[coast_oubreak$malaria==1 & coast_oubreak$infected_chikv_stfd==1] <- "malaria_pos_&_chikv_pos")
coast_oubreak <- within(coast_oubreak, strata_chikv_malaria[coast_oubreak$malaria==1 & coast_oubreak$infected_chikv_stfd==0] <- "malaria_pos_&_chikv_neg")
coast_oubreak <- within(coast_oubreak, strata_chikv_malaria[coast_oubreak$malaria==0 & coast_oubreak$infected_chikv_stfd==0] <- "malaria_neg_&_chikv neg")
coast_oubreak <- within(coast_oubreak, strata_chikv_malaria[coast_oubreak$malaria==0 & coast_oubreak$infected_chikv_stfd==1] <- "malaria_neg_&_chikv_pos")
table(coast_oubreak$strata_chikv_malaria,exclude = NULL)
table(coast_oubreak$infected_chikv_stfd,coast_oubreak$malaria,exclude = NULL)

### export to csv for enrollment graphs-----------------------------------------------------------------------
library(zoo)
coast_oubreak$month_year<-as.yearmon(coast_oubreak$int_date)
coast_oubreak$year<-format(as.Date(coast_oubreak$int_date, format="%d/%m/%Y"),"%Y")

coast_oubreak.csv<-coast_oubreak[c("person_id","redcap_event_name","int_date","month_year","City","infected_chikv_stfd","result_pcr_chikv_kenya","chikv_result_ufi","chikv_result_ufi2","seroc_chikv_stfd_igg","malaria","strata_chikv_malaria")]
write.csv(coast_oubreak.csv, "enrolled.csv")

# data managemnet- exclude those without testing ------------------------------------------------------------------
table(coast_oubreak$infected_chikv_stfd,coast_oubreak$malaria,exclude = NULL)
table(coast_oubreak$infected_chikv_stfd,exclude = NULL)
table(coast_oubreak$malaria,exclude = NULL)

coast_oubreak<-coast_oubreak[ !is.na(coast_oubreak$strata_chikv_malaria),]

library(plyr)
coast_oubreak$City<-revalue(coast_oubreak$City, c("M"="Rural", "U"="Urban"))
coast_oubreak$infected_chikv_stfd<-as.factor(coast_oubreak$infected_chikv_stfd)
coast_oubreak$infected_chikv_stfd<-revalue(coast_oubreak$infected_chikv_stfd, c("0"="Negative", "1"="Positive"))
coast_oubreak$infected_chikv_stfd <- factor(coast_oubreak$infected_chikv_stfd, levels = c("Positive", "Negative"))
coast_oubreak$City <- factor(coast_oubreak$City, levels = c("Urban", "Rural"))

prop.table(table(coast_oubreak$infected_chikv_stfd,coast_oubreak$City), margin=2)
table(coast_oubreak$infected_chikv_stfd,coast_oubreak$City)
fisher.test(coast_oubreak$infected_chikv_stfd,coast_oubreak$City,or = 1, alternative = "two.sided",conf.int = TRUE, conf.level = 0.95)

prop.table(table(coast_oubreak$infected_chikv_stfd,coast_oubreak$gender_all), margin=2)
table(coast_oubreak$infected_chikv_stfd,coast_oubreak$gender_all)
fisher.test(coast_oubreak$infected_chikv_stfd,coast_oubreak$gender_all,or = 1, alternative = "two.sided",conf.int = TRUE, conf.level = 0.95)
summary(coast_oubreak$age)
library(ggpubr)
coast_oubreak$int_date_my<-format(as.Date(coast_oubreak$int_date), "%Y-%m")
coast_oubreak$int_date_week<-format(as.Date(coast_oubreak$int_date), "%Y-%W")

# plot cases over time ------------------------------------------------------------------
p<-ggplot(coast_oubreak, aes(x = int_date_week,fill=infected_chikv_stfd)) + 
#  scale_x_date(date_breaks = "1 month", date_labels =  "%b %Y") +
  theme(axis.text.x=element_text(angle=60, hjust=1),text = element_text(size = 20,color="black")) + 
  xlab("Time, Year-Epidemiological Week") + ylab("# Cases") +
  geom_bar(stat="count",position = "identity") + theme(strip.text.y = element_text(angle = 0))+ 
  facet_grid(City~.)+
  guides(fill = guide_legend(title = "PCR Result", title.position = "left",direction="horizontal"))

color="black"
p <- p +
  theme(
    panel.background = element_rect(fill = "transparent") # bg of the panel
    , plot.background = element_rect(fill = "transparent", color = NA) # bg of the plot
    , panel.grid.major = element_blank() # get rid of major grid
    , panel.grid.minor = element_blank() # get rid of minor grid
    , legend.background = element_rect(fill = "transparent") # get rid of legend bg
    , legend.box.background = element_rect(fill = "transparent") # get rid of legend panel bg
    , strip.background=element_rect(fill="transparent")
    , strip.text.y = element_text(angle =-90,color=color)
    , axis.text.x = element_text(colour = color)
    , axis.text.y = element_text(colour = color)
    ,legend.position="bottom left"
  )
p
ggsave(p, filename = "C:/Users/amykr/Box Sync/Amy Krystosik's Files/ASTMH/2018/chikv outbreak/chikv_time.png",  bg = "transparent",width = 10, height = 4, dpi = 600, units = "in", device='png')

cases_month<-as.data.frame(table(R01_lab_results$infected_chikv_stfd, R01_lab_results$month_year,R01_lab_results$City))
ggplot(cases_month, aes (x = Var2,y=Freq,fill=Var1)) + theme(axis.text.x=element_text(angle=60, hjust=1),text = element_text(size = 20)) + xlab("Months") + ylab("PCR Positive Cases") +  geom_bar(stat="identity") +theme(strip.text.y = element_text(angle = 0))+ facet_grid(Var3~.)

# malaria species------------------------------------------------------------------------
coast_oubreak$malaria_species<-NA
table(coast_oubreak$malaria)
coast_oubreak_malariawide<- coast_oubreak[, grepl("person_id|redcap_event_name|microscopy_malaria_p|microscopy_malaria_n", names(coast_oubreak) ) ]
coast_oubreak_malariawide<-coast_oubreak_malariawide[,order(colnames(coast_oubreak_malariawide))]
coast_oubreak_malariawide<-as.data.frame(coast_oubreak_malariawide)
coast_oubreak_malariawide<-reshape(coast_oubreak_malariawide, idvar = c("person_id", "redcap_event_name"), varying = 1:5,  direction = "long", timevar = "species", times=c("ni", "pf","pm","po","pv"), v.names=c("microscopy_malaria"))

coast_oubreak_malariawide<- within(coast_oubreak_malariawide, species[microscopy_malaria!=1] <- NA)
coast_oubreak_malariawide<-coast_oubreak_malariawide[which(!is.na(coast_oubreak_malariawide$species)),]
library(dplyr)
coast_oubreak_malariawide<-coast_oubreak_malariawide %>% group_by(person_id,redcap_event_name) %>% mutate(malaria_coinfection = n())
coast_oubreak_malariawide<-aggregate( .~ person_id+redcap_event_name, coast_oubreak_malariawide, function(x) toString(unique(x)))

table(coast_oubreak_malariawide$species)

# ses ---------------------------------------------------------------------
coast_oubreak$ses_sum<-rowSums(coast_oubreak[, c("telephone","radio","television","bicycle","motor_vehicle", "domestic_worker")], na.rm = TRUE)
table(coast_oubreak$ses_sum)
#   #mosquito tables ------------------------------------------------------------------
coast_oubreak$mosquito_bites_aic<-as.numeric(as.character(coast_oubreak$mosquito_bites_aic))
coast_oubreak <- within(coast_oubreak, mosquito_bites_aic[coast_oubreak$mosquito_bites_aic==8] <-NA )

coast_oubreak$mosquito_coil_aic<-as.numeric(as.character(coast_oubreak$mosquito_coil_aic))
coast_oubreak <- within(coast_oubreak, mosquito_coil_aic[coast_oubreak$mosquito_coil_aic==8] <-NA )

coast_oubreak$outdoor_activity_aic<-as.numeric(as.character(coast_oubreak$outdoor_activity_aic))
coast_oubreak <- within(coast_oubreak, outdoor_activity_aic[coast_oubreak$outdoor_activity_aic==8] <-NA )

coast_oubreak$mosquito_net_aic<-as.numeric(as.character(coast_oubreak$mosquito_net_aic))
coast_oubreak <- within(coast_oubreak, mosquito_net_aic[coast_oubreak$mosquito_net_aic==8] <-NA )
# hospitalized ------------------------------------------------------------
coast_oubreak$outcome_hospitalized<-as.numeric(as.character(coast_oubreak$outcome_hospitalized))
coast_oubreak <- within(coast_oubreak, outcome_hospitalized[outcome_hospitalized==8] <-1 )

table(coast_oubreak$outcome_hospitalized,coast_oubreak$outcome, exclude = NULL)
table(coast_oubreak$outcome)
table(coast_oubreak$outcome_hospitalized)
coast_oubreak$med_antipyretic

# merge with pedsql data ------------------------------------------------------------------
library(tableone)
load("C:/Users/amykr/Box Sync/Amy Krystosik's Files/david coinfection paper/data/pedsql_pairs_acute_a.rda")
table(pedsql_pairs_acute$pedsql_parent_physical_mean_change)
coast_oubreak <- join(coast_oubreak, pedsql_pairs_acute, by=c("person_id", "redcap_event_name"), match = "first" , type="left")

load("C:/Users/amykr/Box Sync/Amy Krystosik's Files/david coinfection paper/data/pedsql_unpaired.rda")
names(pedsql_unpaired)[names(pedsql_unpaired) == 'redcap_event'] <- 'redcap_event_name'
pedsql_unpaired_a<-pedsql_unpaired[which(pedsql_unpaired$redcap_event_name=="visit_a_arm_1"),grepl("mean|sum|person_id|redcap", names(pedsql_unpaired))]
coast_oubreak <- join(coast_oubreak, pedsql_unpaired_a, by=c("person_id", "redcap_event_name"), match = "first" , type="left")
table(coast_oubreak$pedsql_parent_physical_mean)

# create tables by chikv exposure and chikv/malaria strata ------------------------------------------------------------------
library(tableone)
vars=c("City", "gender_all","aic_calculated_age","ses_sum","mosquito_bites_aic", "mosquito_coil_aic", "outdoor_activity_aic", "mosquito_net_aic","outcome_hospitalized","aic_symptom_abdominal_pain", "aic_symptom_chills", "aic_symptom_cough", "aic_symptom_vomiting", "aic_symptom_headache", "aic_symptom_loss_of_appetite", "aic_symptom_diarrhea", "aic_symptom_sick_feeling",  "aic_symptom_general_body_ache", "aic_symptom_joint_pains", "aic_symptom_dizziness", "aic_symptom_runny_nose", "aic_symptom_sore_throat", "aic_symptom_rash", "aic_symptom_shortness_of_breath", "aic_symptom_nausea", "aic_symptom_fever", "aic_symptom_funny_taste", "aic_symptom_red_eyes", "aic_symptom_earache", "aic_symptom_stiff_neck", "aic_symptom_pain_behind_eyes", "aic_symptom_itchiness", "aic_symptom_impaired_mental_status", "aic_symptom_eyes_sensitive_to_light", "bleeding", "body_ache", "temp", "heart_rate", "nausea_vomitting","symptomatic","number_meds","med_antibacterial", "med_antihelmenthic","med_antimalarial","med_antipyretic","med_antifungal","med_allergy","med_painmed","med_bronchospasm","med_ors","pedsql_parent_total_mean","pedsql_child_total_mean","pedsql_child_school_mean","pedsql_child_social_mean", "pedsql_parent_school_mean",  "pedsql_parent_social_mean",  "pedsql_child_physical_mean", "pedsql_parent_physical_mean", "pedsql_child_emotional_mean", "pedsql_parent_emotional_mean","pedsql_child_psych_mean","pedsql_parent_psych_mean")
factorVars <- c("City","mosquito_bites_aic", "mosquito_coil_aic", "outdoor_activity_aic", "mosquito_net_aic","outcome_hospitalized","aic_symptom_abdominal_pain", "aic_symptom_chills", "aic_symptom_cough", "aic_symptom_vomiting", "aic_symptom_headache", "aic_symptom_loss_of_appetite", "aic_symptom_diarrhea", "aic_symptom_sick_feeling",  "aic_symptom_general_body_ache", "aic_symptom_joint_pains", "aic_symptom_dizziness", "aic_symptom_runny_nose", "aic_symptom_sore_throat", "aic_symptom_rash", "aic_symptom_shortness_of_breath", "aic_symptom_nausea", "aic_symptom_fever", "aic_symptom_funny_taste", "aic_symptom_red_eyes", "aic_symptom_earache", "aic_symptom_stiff_neck", "aic_symptom_pain_behind_eyes", "aic_symptom_itchiness", "aic_symptom_impaired_mental_status", "aic_symptom_eyes_sensitive_to_light", "bleeding", "body_ache","nausea_vomitting","symptomatic","med_antibacterial", "med_antihelmenthic","med_antimalarial","med_antipyretic")
nonnormal<-c("pedsql_parent_total_mean","pedsql_child_total_mean","pedsql_child_school_mean", "pedsql_child_school_mean", "pedsql_child_social_mean", "pedsql_child_social_mean", "pedsql_parent_school_mean", "pedsql_parent_school_mean", "pedsql_parent_social_mean", "pedsql_parent_social_mean", "pedsql_child_physical_mean", "pedsql_child_physical_mean", "pedsql_parent_physical_mean", "pedsql_parent_physical_mean", "pedsql_child_emotional_mean", "pedsql_child_emotional_mean", "pedsql_parent_emotional_mean", "pedsql_parent_emotional_mean","pedsql_child_psych_mean","pedsql_parent_psych_mean")

tableOne_strata <- CreateTableOne(vars = vars, factorVars = factorVars, strata = "strata_chikv_malaria", data = coast_oubreak)
tableOne_strata.csv <-print(tableOne_strata, exact = c("mosquito_bites_aic", "mosquito_coil_aic", "outdoor_activity_aic", "mosquito_net_aic"), quote = F, noSpaces = TRUE, includeNA=TRUE,, printToggle = FALSE)
write.csv(tableOne_strata.csv, file = "tableOne_strata.csv")

tableOne_chikv <- CreateTableOne(vars = vars, factorVars = factorVars, strata = "infected_chikv_stfd", data = coast_oubreak)
tableOne_chikv.csv <-print(tableOne_chikv, exact = c("mosquito_bites_aic", "mosquito_coil_aic", "outdoor_activity_aic", "mosquito_net_aic"), quote = F, noSpaces = TRUE, includeNA=TRUE,, printToggle = FALSE)
write.csv(tableOne_chikv.csv, file = "tableOne_chikv.csv")

##print inventory for lab-----------------------------------------------------------------------
chikv_outbreak_ids<-coast_oubreak[, grepl("person_id|redcap_event_name|int_date|infected_chikv|result_pcr|date_tested_pcr_chikv_kenya|village|travel|cdna|date_extracted|inventory_comments", names(coast_oubreak))]
chikv_outbreak_ids<-chikv_outbreak_ids[, !grepl("u24|other", names(chikv_outbreak_ids))]
chikv_outbreak_ids<- chikv_outbreak_ids[which(chikv_outbreak_ids$infected_chikv_stfd==1)  , ]

chikv_outbreak_ids_inventory<-merge(R01_lab_results_inventory,chikv_outbreak_ids,by=c("person_id","redcap_event_name"),all.y=TRUE)
write.csv(chikv_outbreak_ids_inventory,"chikv_outbreak_ids.csv", na="",row.names = F)

##glm-----------------------------------------------------------------------
summary(pedsql_child_total_mean <- glm(pedsql_child_total_mean ~ strata_chikv_malaria, data = coast_oubreak, family = "gaussian" ))
exp(cbind(OR = coef(hospitalized), confint(hospitalized)))
exp(cbind(OR = coef(pedsql_child_total_mean), confint(pedsql_child_total_mean)))