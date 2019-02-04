#chikv outbreak in kenyan coast
# import data -------------------------------------------------------------
setwd("C:/Users/amykr/Box Sync/Amy's Externally Shareable Files/chikv outbreak")

load("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long/R01_lab_results.clean.rda")    
table(R01_lab_results$infected_chikv_stfd,R01_lab_results$City,R01_lab_results$Cohort)

R01_lab_results<-R01_lab_results[, !grepl("pedsql", names(R01_lab_results))]
R01_lab_results<- R01_lab_results[-which(R01_lab_results$int_date<"2013-01-01"),]
R01_lab_results<- R01_lab_results[-which(is.na(R01_lab_results$infected_chikv_stfd)),]
R01_lab_results$infected_chikv_stfd<-as.factor(R01_lab_results$infected_chikv_stfd)
cases_month<-as.data.frame(table(R01_lab_results$infected_chikv_stfd, R01_lab_results$month_year))
plot(cases_month$Var2,cases_month$Freq,col=cases_month$Var1)
library(ggplot2)
R01_lab_results$int_date_my<-format(as.Date(R01_lab_results$int_date), "%Y-%m")
R01_lab_results$int_date_week<-format(as.Date(R01_lab_results$int_date), "%Y-%W")

R01_lab_results$epi_week<-epiweek(R01_lab_results$int_date)
#Is it possible for you to kindly run the same analyses you ran last time on Coast CHIKV and malaria cases, but this time from July 2017 to June 2018?
coast_oubreak<-R01_lab_results[R01_lab_results$int_date>="2017-07-01" & R01_lab_results$int_date<"2018-06-01"& !is.na(R01_lab_results$int_date)&(R01_lab_results$City=="M"|R01_lab_results$City=="U") & !is.na(R01_lab_results$infected_chikv_stfd), ]
enrolled<-R01_lab_results[R01_lab_results$int_date>="2017-07-01" & R01_lab_results$int_date<"2018-06-01"& !is.na(R01_lab_results$int_date)&(R01_lab_results$City=="M"|R01_lab_results$City=="U"), ]

enrolled$malaria<-NA
enrolled <- within(enrolled, malaria[enrolled$result_rdt_malaria_keny==0] <- 0)#rdt
enrolled <- within(enrolled, malaria[enrolled$rdt_result==0] <- 0)#rdt
enrolled <- within(enrolled, malaria[enrolled$malaria_results==0] <- 0)# Results of malaria blood smear	(+++ system)
enrolled <- within(enrolled, malaria[enrolled$result_microscopy_malaria_kenya==0] <- 0)#microscopy. this goes last so that it overwrites all the other's if it exists.

enrolled <- within(enrolled, malaria[enrolled$result_microscopy_malaria_kenya==1] <- 1) #this goes first. only use the others if this is missing.
enrolled <- within(enrolled, malaria[enrolled$malaria_results>0 & is.na(result_microscopy_malaria_kenya)] <- 1)# Results of malaria blood smear	(+++ system)
enrolled <- within(enrolled, malaria[enrolled$rdt_results==1 & is.na(result_microscopy_malaria_kenya)] <- 1)#rdt
table(enrolled$malaria)

table(enrolled$malaria)

#create strata: 1 = malaria+ & chikv + | 2 = malaria+ chikv - | 3= malaria- & chikv - | 4= malaria- & chikv + 
enrolled$strata_chikv_malaria<-NA
enrolled <- within(enrolled, strata_chikv_malaria[enrolled$malaria==1 & enrolled$infected_chikv_stfd==1] <- "malaria_pos_&_chikv_pos")
enrolled <- within(enrolled, strata_chikv_malaria[enrolled$malaria==1 & enrolled$infected_chikv_stfd==0] <- "malaria_pos_&_chikv_neg")
enrolled <- within(enrolled, strata_chikv_malaria[enrolled$malaria==0 & enrolled$infected_chikv_stfd==0] <- "malaria_neg_&_chikv neg")
enrolled <- within(enrolled, strata_chikv_malaria[enrolled$malaria==0 & enrolled$infected_chikv_stfd==1] <- "malaria_neg_&_chikv_pos")
table(enrolled$strata_chikv_malaria)

enrolled$month_year<-as.yearmon(enrolled$int_date)
table(enrolled$City,enrolled$month_year)
enrolled<-enrolled[c("person_id","redcap_event_name","int_date","month_year","City","infected_chikv_stfd","result_pcr_chikv_kenya","chikv_result_ufi","chikv_result_ufi2","seroc_chikv_stfd_igg","malaria","strata_chikv_malaria")]
write.csv(enrolled, "enrolled.csv")

# stop --------------------------------------------------------------------


coast_oubreak<-coast_oubreak[!is.na(coast_oubreak$infected_chikv_stfd),]
table(coast_oubreak$infected_chikv_stfd,exclude=NULL)
coast_oubreak<-as.data.frame(coast_oubreak)
library(tableone)
CreateTableOne(vars = c("child_travel","mombasa_travel"),factorVars = c("child_travel","mombasa_travel"), data=coast_nov_2017_present, strata = "strata_chikv_malaria")
table(coast_nov_2017_present$child_travel, coast_nov_2017_present$strata_chikv_malaria)
coast_nov_2017_present$mombasa_travel<-ifelse(coast_nov_2017_present$where_travel_aic=="Mombasa",1,0)
table(coast_nov_2017_present$mombasa_travel,coast_nov_2017_present$strata_chikv_malaria)

library(plyr)
coast_oubreak$City<-revalue(coast_oubreak$City, c("M"="Rural", "U"="Urban"))
coast_oubreak$infected_chikv_stfd<-revalue(coast_oubreak$infected_chikv_stfd, c("0"="Negative", "1"="Positive"))
table(coast_oubreak$infected_chikv_stfd)
library(ggpubr)
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

# chikv --------------------------------------------------------------------
R01_lab_results$date_tested_pcr_chikv_kenya<-as.Date(as.character(as.factor(R01_lab_results$date_tested_pcr_chikv_kenya)),"%Y-%m-%d")
coast_nov_2017_present<- R01_lab_results[which(R01_lab_results$site=="C" & 
  (R01_lab_results$int_date<"2018-05-01") &
  (R01_lab_results$int_date>="2017-11-01"|R01_lab_results$date_tested_pcr_chikv_kenya>="2017-11-01")),]
coast_nov_2017_present<- coast_nov_2017_present[-which(coast_nov_2017_present$int_date<"2017-09-30"),]
table(R01_lab_results$infected_chikv_kenya)
table(coast_nov_2017_present$infected_chikv_kenya)
186+254
191+253
length(unique(coast_nov_2017_present$person_id))
table(coast_nov_2017_present$site,coast_nov_2017_present$City,exclude=NULL)
#load("pedsql_pairs_acute.rda")
#load("pedsql_merge.rda")
load("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long/pedsql_all.rda")

coast_nov_2017_present <- merge(coast_nov_2017_present, pedsql,  by.x=c("person_id", "redcap_event_name"),  by.y=c("person_id", "redcap_event"), all.x = T)

count(coast_nov_2017_present$pedsql_agreement)

#coast_nov_2017_present<-coast_nov_2017_present[, grepl("person_id|redcap_event_name|int_date|interview_date|infected_chikv|aic_symptom_joint_pains|result_pcr_chikv|result", names(coast_nov_2017_present))]

table(coast_nov_2017_present$infected_chikv_stfd, coast_nov_2017_present$aic_symptom_joint_pains)
table(coast_nov_2017_present$result_pcr_chikv_kenya)
barplot(table(coast_nov_2017_present$infected_chikv_stfd, coast_nov_2017_present$aic_symptom_joint_pains))
table(coast_nov_2017_present$infected_chikv_stfd, coast_nov_2017_present$aic_symptom_joint_pains)

table(coast_nov_2017_present$result_pcr_chikv_kenya, coast_nov_2017_present$result_microscopy_malaria_kenya, exclude = NULL)
barplot(table(coast_nov_2017_present$result_pcr_chikv_kenya, coast_nov_2017_present$result_microscopy_malaria_kenya))

#malaria
coast_nov_2017_present$malaria<-NA
coast_nov_2017_present <- within(coast_nov_2017_present, malaria[coast_nov_2017_present$result_rdt_malaria_keny==0] <- 0)#rdt
coast_nov_2017_present <- within(coast_nov_2017_present, malaria[coast_nov_2017_present$rdt_result==0] <- 0)#rdt
coast_nov_2017_present <- within(coast_nov_2017_present, malaria[coast_nov_2017_present$malaria_results==0] <- 0)# Results of malaria blood smear	(+++ system)
coast_nov_2017_present <- within(coast_nov_2017_present, malaria[coast_nov_2017_present$result_microscopy_malaria_kenya==0] <- 0)#microscopy. this goes last so that it overwrites all the other's if it exists.


coast_nov_2017_present <- within(coast_nov_2017_present, malaria[coast_nov_2017_present$result_microscopy_malaria_kenya==1] <- 1) #this goes first. only use the others if this is missing.
coast_nov_2017_present <- within(coast_nov_2017_present, malaria[coast_nov_2017_present$malaria_results>0 & is.na(result_microscopy_malaria_kenya)] <- 1)# Results of malaria blood smear	(+++ system)
coast_nov_2017_present <- within(coast_nov_2017_present, malaria[coast_nov_2017_present$rdt_results==1 & is.na(result_microscopy_malaria_kenya)] <- 1)#rdt
table(coast_nov_2017_present$malaria)
coast_nov_2017_present<- coast_nov_2017_present[which(!is.na(coast_nov_2017_present$result_pcr_chikv_kenya) & !is.na(coast_nov_2017_present$malaria)),]
table(coast_nov_2017_present$result_pcr_chikv_kenya, coast_nov_2017_present$malaria)


# species -----------------------------------------------------------------

# malaria species------------------------------------------------------------------------
coast_nov_2017_present$malaria_species<-NA
table(coast_nov_2017_present$malaria)
coast_nov_2017_present_malariawide<- coast_nov_2017_present[, grepl("person_id|redcap_event_name|microscopy_malaria_p|microscopy_malaria_n", names(coast_nov_2017_present) ) ]
coast_nov_2017_present_malariawide<-coast_nov_2017_present_malariawide[,order(colnames(coast_nov_2017_present_malariawide))]
coast_nov_2017_present_malariawide<-as.data.frame(coast_nov_2017_present_malariawide)
coast_nov_2017_present_malariawide<-reshape(coast_nov_2017_present_malariawide, idvar = c("person_id", "redcap_event_name"), varying = 1:5,  direction = "long", timevar = "species", times=c("ni", "pf","pm","po","pv"), v.names=c("microscopy_malaria"))

coast_nov_2017_present_malariawide<- within(coast_nov_2017_present_malariawide, species[microscopy_malaria!=1] <- NA)
coast_nov_2017_present_malariawide<-coast_nov_2017_present_malariawide[which(!is.na(coast_nov_2017_present_malariawide$species)),]
library(dplyr)
coast_nov_2017_present_malariawide<-coast_nov_2017_present_malariawide %>% group_by(person_id,redcap_event_name) %>% mutate(malaria_coinfection = n())
coast_nov_2017_present_malariawide<-aggregate( .~ person_id+redcap_event_name, coast_nov_2017_present_malariawide, function(x) toString(unique(x)))

table(coast_nov_2017_present_malariawide$species)
((764+2+5)/(976+48))*100

#create strata: 1 = malaria+ & chikv + | 2 = malaria+ chikv - | 3= malaria- & chikv - | 4= malaria- & chikv + 
coast_nov_2017_present$strata_chikv_malaria<-NA
coast_nov_2017_present <- within(coast_nov_2017_present, strata_chikv_malaria[coast_nov_2017_present$malaria==1 & coast_nov_2017_present$infected_chikv_stfd==1] <- "malaria_pos_&_chikv_pos")
coast_nov_2017_present <- within(coast_nov_2017_present, strata_chikv_malaria[coast_nov_2017_present$malaria==1 & coast_nov_2017_present$infected_chikv_stfd==0] <- "malaria_pos_&_chikv_neg")
coast_nov_2017_present <- within(coast_nov_2017_present, strata_chikv_malaria[coast_nov_2017_present$malaria==0 & coast_nov_2017_present$infected_chikv_stfd==0] <- "malaria_neg_&_chikv neg")
coast_nov_2017_present <- within(coast_nov_2017_present, strata_chikv_malaria[coast_nov_2017_present$malaria==0 & coast_nov_2017_present$infected_chikv_stfd==1] <- "malaria_neg_&_chikv_pos")
table(coast_nov_2017_present$strata_chikv_malaria)


coast_nov_2017_present$strata_chikv_malaria_pos<-NA
coast_nov_2017_present <- within(coast_nov_2017_present, strata_chikv_malaria_pos[coast_nov_2017_present$malaria==1 & coast_nov_2017_present$infected_chikv_stfd==1] <- "malaria_pos_&_chikv_pos")
coast_nov_2017_present <- within(coast_nov_2017_present, strata_chikv_malaria_pos[coast_nov_2017_present$malaria==1 & coast_nov_2017_present$infected_chikv_stfd==0] <- "malaria_pos_&_chikv_neg")
table(coast_nov_2017_present$strata_chikv_malaria_pos)

# ses ---------------------------------------------------------------------
coast_nov_2017_present$ses_sum<-rowSums(coast_nov_2017_present[, c("telephone","radio","television","bicycle","motor_vehicle", "domestic_worker")], na.rm = TRUE)
table(coast_nov_2017_present$ses_sum)
#   #mosquito tables ------------------------------------------------------------------
coast_nov_2017_present$mosquito_bites_aic<-as.numeric(as.character(coast_nov_2017_present$mosquito_bites_aic))
coast_nov_2017_present <- within(coast_nov_2017_present, mosquito_bites_aic[coast_nov_2017_present$mosquito_bites_aic==8] <-NA )

coast_nov_2017_present$mosquito_coil_aic<-as.numeric(as.character(coast_nov_2017_present$mosquito_coil_aic))
coast_nov_2017_present <- within(coast_nov_2017_present, mosquito_coil_aic[coast_nov_2017_present$mosquito_coil_aic==8] <-NA )

coast_nov_2017_present$outdoor_activity_aic<-as.numeric(as.character(coast_nov_2017_present$outdoor_activity_aic))
coast_nov_2017_present <- within(coast_nov_2017_present, outdoor_activity_aic[coast_nov_2017_present$outdoor_activity_aic==8] <-NA )

coast_nov_2017_present$mosquito_net_aic<-as.numeric(as.character(coast_nov_2017_present$mosquito_net_aic))
coast_nov_2017_present <- within(coast_nov_2017_present, mosquito_net_aic[coast_nov_2017_present$mosquito_net_aic==8] <-NA )
# hospitalized ------------------------------------------------------------
coast_nov_2017_present$outcome_hospitalized<-as.numeric(as.character(coast_nov_2017_present$outcome_hospitalized))
coast_nov_2017_present <- within(coast_nov_2017_present, outcome_hospitalized[outcome_hospitalized==8] <-1 )

table(coast_nov_2017_present$outcome_hospitalized,coast_nov_2017_present$outcome, exclude = NULL)
table(coast_nov_2017_present$outcome)
table(coast_nov_2017_present$outcome_hospitalized)
coast_nov_2017_present$med_antipyretic


# travel to mombasa -------------------------------------------------------
coast_nov_2017_present$travel_mb<-grepl(coast_nov_2017_present$travel, "chars")

table(coast_nov_2017_present$child_travel, coast_nov_2017_present$strata_chikv_malaria)

table(coast_nov_2017_present$where_travel_aic, coast_nov_2017_present$travel)

table(coast_nov_2017_present$aic_symptom_joint_pains, coast_nov_2017_present$strata_chikv_malaria)
#tables
vars=c("City", "gender_all","aic_calculated_age","ses_sum","mosquito_bites_aic", "mosquito_coil_aic", "outdoor_activity_aic", "mosquito_net_aic","outcome_hospitalized","aic_symptom_abdominal_pain", "aic_symptom_chills", "aic_symptom_cough", "aic_symptom_vomiting", "aic_symptom_headache", "aic_symptom_loss_of_appetite", "aic_symptom_diarrhea", "aic_symptom_sick_feeling",  "aic_symptom_general_body_ache", "aic_symptom_joint_pains", "aic_symptom_dizziness", "aic_symptom_runny_nose", "aic_symptom_sore_throat", "aic_symptom_rash", "aic_symptom_shortness_of_breath", "aic_symptom_nausea", "aic_symptom_fever", "aic_symptom_funny_taste", "aic_symptom_red_eyes", "aic_symptom_earache", "aic_symptom_stiff_neck", "aic_symptom_pain_behind_eyes", "aic_symptom_itchiness", "aic_symptom_impaired_mental_status", "aic_symptom_eyes_sensitive_to_light", "bleeding", "body_ache", "temp", "heart_rate", "nausea_vomitting","symptom_sum","symptomatic","number_meds","med_antibacterial", "med_antihelmenthic","med_antimalarial","med_antipyretic","med_antifungal","med_allergy","med_painmed","med_bronchospasm","med_ors","symptom_sum") 
factorVars <- c("City","mosquito_bites_aic", "mosquito_coil_aic", "outdoor_activity_aic", "mosquito_net_aic","outcome_hospitalized","aic_symptom_abdominal_pain", "aic_symptom_chills", "aic_symptom_cough", "aic_symptom_vomiting", "aic_symptom_headache", "aic_symptom_loss_of_appetite", "aic_symptom_diarrhea", "aic_symptom_sick_feeling",  "aic_symptom_general_body_ache", "aic_symptom_joint_pains", "aic_symptom_dizziness", "aic_symptom_runny_nose", "aic_symptom_sore_throat", "aic_symptom_rash", "aic_symptom_shortness_of_breath", "aic_symptom_nausea", "aic_symptom_fever", "aic_symptom_funny_taste", "aic_symptom_red_eyes", "aic_symptom_earache", "aic_symptom_stiff_neck", "aic_symptom_pain_behind_eyes", "aic_symptom_itchiness", "aic_symptom_impaired_mental_status", "aic_symptom_eyes_sensitive_to_light", "bleeding", "body_ache","nausea_vomitting","symptomatic","med_antibacterial", "med_antihelmenthic","med_antimalarial","med_antipyretic")
library(tableone)

tableOne_strata <- CreateTableOne(vars = vars, factorVars = factorVars, strata = "strata_chikv_malaria", data = coast_nov_2017_present)
tableOne_strata.csv <-print(tableOne_strata, exact = c("mosquito_bites_aic", "mosquito_coil_aic", "outdoor_activity_aic", "mosquito_net_aic"), quote = F, noSpaces = TRUE, includeNA=TRUE,, printToggle = FALSE)
write.csv(tableOne_strata.csv, file = "tableOne_strata.csv")
table(coast_nov_2017_present$result_pcr_chikv_kenya)
tableOne_chikv <- CreateTableOne(vars = vars, factorVars = factorVars, strata = "result_pcr_chikv_kenya", data = coast_nov_2017_present)
tableOne_chikv.csv <-print(tableOne_chikv, exact = c("mosquito_bites_aic", "mosquito_coil_aic", "outdoor_activity_aic", "mosquito_net_aic"), quote = F, noSpaces = TRUE, includeNA=TRUE,, printToggle = FALSE)
write.csv(tableOne_chikv.csv, file = "tableOne_chikv.csv")


pedsql_vars <- c("pedsql_parent_total_mean","pedsql_child_total_mean","pedsql_child_school_mean","pedsql_child_social_mean", "pedsql_parent_school_mean",  "pedsql_parent_social_mean",  "pedsql_child_physical_mean", "pedsql_parent_physical_mean", "pedsql_child_emotional_mean", "pedsql_parent_emotional_mean","pedsql_child_psych_mean","pedsql_parent_psych_mean")
pedsql_tableOne_strata <- CreateTableOne(vars = pedsql_vars, strata = "strata_chikv_malaria", data = coast_nov_2017_present)

#print table one (assume non normal distribution)
pedsql_tableOne_strata.csv <-print(pedsql_tableOne_strata, 
                                              nonnormal=c("pedsql_parent_total_mean","pedsql_child_total_mean","pedsql_child_school_mean", "pedsql_child_school_mean", "pedsql_child_social_mean", "pedsql_child_social_mean", "pedsql_parent_school_mean", "pedsql_parent_school_mean", "pedsql_parent_social_mean", "pedsql_parent_social_mean", "pedsql_child_physical_mean", "pedsql_child_physical_mean", "pedsql_parent_physical_mean", "pedsql_parent_physical_mean", "pedsql_child_emotional_mean", "pedsql_child_emotional_mean", "pedsql_parent_emotional_mean", "pedsql_parent_emotional_mean","pedsql_child_psych_mean","pedsql_parent_psych_mean"), 
                                              quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE)
write.csv(pedsql_tableOne_strata.csv, file = "pedsql_tableOne_strata.csv")

pedsql_tableOne_strata.csv <-print(pedsql_tableOne_strata, 
                                   quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE)
write.csv(pedsql_tableOne_strata.csv, file = "pedsql_tableOne_strata_normal.csv")

pedsql<-coast_nov_2017_present[, grepl("person_id|redcap_event_name|int_date|infected_chikv|result_pcr|date_tested_pcr_chikv_kenya|pedsql|strata_chikv_malaria", names(coast_nov_2017_present))]
write.csv(pedsql, file = "pedsql.csv")

#get cdna samples to sequence at stfd.
#over time
library(zoo)
library(plyr)
coast_nov_2017_present$month_year <- as.yearmon(coast_nov_2017_present$int_date)
table(coast_nov_2017_present$City, exclude = NULL)

colours <- c("blue", "red")
table(coast_nov_2017_present$int_date, coast_nov_2017_present$infected_chikv_stfd)

barplot(table(coast_nov_2017_present$infected_chikv_stfd),beside=T,col=colours, main="CHIKV Outbreak on Coast of Kenya", ylab = "Subjects")

barplot(table(coast_nov_2017_present$infected_chikv_stfd, coast_nov_2017_present$month_year),beside=T,col=colours, main="CHIKV Outbreak on Coast of Kenya", ylab = "Number of Subjects", xlab = "Date of Febrile Visit")
legend("topleft", c("Negative","Positive"), cex=1.3, bty="n", fill=colours)

coast_nov_2017_present$malaria_factor<-coast_nov_2017_present$malaria
coast_nov_2017_present <- within(coast_nov_2017_present, malaria_factor[coast_nov_2017_present$malaria==0] <- "Malaria Negative")
coast_nov_2017_present <- within(coast_nov_2017_present, malaria_factor[coast_nov_2017_present$malaria==1] <- "Malaria Positive")

ggplot(coast_nov_2017_present,aes(x=int_date.x, y=infected_chikv_stfd))+geom_bar(stat="identity")+ theme_bw(base_size = 50)+  labs(title ="", x = "week", y = "Number of \ncases positive") + scale_x_date(date_breaks = "1 week", date_labels =  "%d %m %Y") +theme(axis.text.x=element_text(angle=60, hjust=1),text = element_text(size = 20))
ggplot(coast_nov_2017_present,aes(x=int_date.x, y=infected_chikv_stfd))+geom_smooth()+ theme_bw(base_size = 50)+  labs(title ="", x = "week", y = "Proportion of \ncases positive") + scale_x_date(date_breaks = "1 week", date_labels =  "%d %m %Y") +theme(axis.text.x=element_text(angle=60, hjust=1),text = element_text(size = 20))
ggplot(coast_nov_2017_present,aes(x=int_date.x, y=infected_chikv_stfd))+geom_smooth()+ theme_bw(base_size = 50)+  labs(title ="", x = "week", y = "Proportion of \ncases positive") + scale_x_date(date_breaks = "1 week", date_labels =  "%d %m %Y") +theme(axis.text.x=element_text(angle=60, hjust=1),text = element_text(size = 20))+facet_grid(malaria_factor~., scales = "free")+theme(strip.text.y = element_text(angle = 0))

barplot(table(coast_nov_2017_present$infected_chikv_stfd, coast_nov_2017_present$aic_symptom_joint_pains ),beside=T,col=colours, main="CHIKV Outbreak on Coast of Kenya", ylab = "Number of PCR Positive Cases", xlab = "Date of Febrile Visit")
legend("topleft", c("None","Joint Pain"), cex=1.3, bty="n", fill=colours)

table(coast_nov_2017_present$strata_chikv_malaria)

monthly_infection <- ddply(coast_nov_2017_present, .(month_year, City),
                           summarise, 
                           infected_denv_stfd_sum = sum(infected_denv_stfd, na.rm = TRUE),
                           infected_chikv_stfd_sum = sum(infected_chikv_stfd, na.rm = TRUE),
                           infected_denv_stfd_inc = mean(infected_denv_stfd, na.rm = TRUE),
                           infected_chikv_stfd_inc = mean(infected_chikv_stfd, na.rm = TRUE),
                           infected_denv_stfd_sd = sd(infected_denv_stfd, na.rm = TRUE),
                           infected_chikv_stfd_sd = sd(infected_chikv_stfd, na.rm = TRUE))
##merge with paired pedsql data (acute and convalescent)-----------------------------------------------------------------------
write.csv(coast_nov_2017_present,"coast_nov_2017_present.csv")

chikv_outbreak_ids<-coast_nov_2017_present[, grepl("person_id|redcap_event_name|int_date|infected_chikv|result_pcr|date_tested_pcr_chikv_kenya|village|travel|cdna|date_extracted|inventory_comments", names(coast_nov_2017_present))]
chikv_outbreak_ids<-chikv_outbreak_ids[, !grepl("u24|other", names(chikv_outbreak_ids))]
chikv_outbreak_ids<- chikv_outbreak_ids[which(chikv_outbreak_ids$infected_chikv_stfd==1)  , ]

chikv_outbreak_ids_inventory<-merge(R01_lab_results_inventory,chikv_outbreak_ids,by=c("person_id","redcap_event_name"),all.y=TRUE)

write.csv(chikv_outbreak_ids_inventory,"chikv_outbreak_ids.csv", na="",row.names = F)
table(coast_nov_2017_present$outcome)

table(coast_nov_2017_present$outcome_hospitalized,coast_nov_2017_present$strata_chikv_malaria_pos)
table(coast_nov_2017_present$outcome_hospitalized,coast_nov_2017_present$strata_chikv_malaria)
coast_nov_2017_present$symptom_sum
coast_nov_2017_present$pedsql_child_total_mean
table(coast_nov_2017_present$symptom_sum, coast_nov_2017_present$strata_chikv_malaria)
table(coast_nov_2017_present$outcome_hospitalized, coast_nov_2017_present$strata_chikv_malaria)
coast_nov_2017_present$strata_chikv_malaria<-as.factor(coast_nov_2017_present$strata_chikv_malaria)
class(coast_nov_2017_present$strata_chikv_malaria)


summary(pedsql_child_total_mean <- glm(pedsql_child_total_mean ~ strata_chikv_malaria, data = coast_nov_2017_present, family = "gaussian" ))

exp(cbind(OR = coef(hospitalized), confint(hospitalized)))
exp(cbind(OR = coef(pedsql_child_total_mean), confint(pedsql_child_total_mean)))


# match to village gis points ---------------------------------------------
table<-table(coast_nov_2017_present$village_aic,coast_nov_2017_present$int_date.x ,coast_nov_2017_present$strata_chikv_malaria)
write.csv(table,"table3.csv")

table(coast_nov_2017_present$infected_chikv_stfd, exclude=NULL)
table(coast_nov_2017_present$village_aic,coast_nov_2017_present$infected_chikv_stfd, exclude=NULL)

load("aic.gps.name.t.rds")
library(fuzzyjoin)
coast_nov_2017_present.gps<-coast_nov_2017_present[, grepl("person_id|redcap_event_name|village_aic|int_date.x|infected_chikv|result_pcr|date_tested_pcr_chikv_kenya|travel|cdna|date_extracted|inventory_comments|strata_chikv_malaria", names(coast_nov_2017_present))]
coast_nov_2017_present.gps<-stringdist_right_join(aic.gps.name.t,coast_nov_2017_present.gps, by = "village_aic", distance_col = "dist", ignore_case=T)
library(dplyr)
coast_nov_2017_present.gps<-coast_nov_2017_present.gps %>% 
  arrange(dist) %>% 
  distinct(person_id,redcap_event_name, .keep_all = TRUE)

table(coast_nov_2017_present.gps$strata_chikv_malaria)
table(coast_nov_2017_present.gps$infected_chikv_stfd)
table(coast_nov_2017_present.gps$village_aic.y,coast_nov_2017_present.gps$infected_chikv_stfd, exclude=NULL)
table4<-table(coast_nov_2017_present.gps$village_aic.y,coast_nov_2017_present.gps$village_aic.x, coast_nov_2017_present.gps$infected_chikv_stfd, exclude=NULL)
write.csv(table4,"table4.csv")
cols.num<- c("aic_village_gps_lattitude","aic_village_gps_longitude")
coast_nov_2017_present.gps[cols.num]<-sapply(coast_nov_2017_present.gps[cols.num], as.numeric) 

df.SP<-coast_nov_2017_present.gps[which(!is.na(coast_nov_2017_present.gps$aic_village_gps_longitude)),]

library(rgdal)
df.SP.37s<-df.SP[which((df.SP$aic_village_gps_data_type==1)),]
write.csv(df.SP.37s,"df.SP.37s.csv")
ggplot() +  geom_point(data=df.SP.37s, aes(x=aic_village_gps_longitude, y=aic_village_gps_lattitude,color=int_date.x))+facet_grid(infected_chikv_kenya~.)
coordinates(df.SP.37s) <- ~aic_village_gps_lattitude+aic_village_gps_longitude
sputm.37s <- SpatialPoints(df.SP.37s, proj4string=CRS("+proj=utm +zone=37s +datum=WGS84")  )
spgeo.37s <- spTransform(sputm.37s, CRS("+proj=longlat +datum=WGS84"))
spplot(spgeo.37s,"village_aic.x")

df.SP.36s<-df.SP[which(is.na(df.SP$aic_village_gps_data_type)),]
write.csv(df.SP.36s,"df.SP.36s.csv")
ggplot() +  geom_point(data=df.SP.36s, aes(x=aic_village_gps_longitude, y=aic_village_gps_lattitude,color=int_date.x))+facet_grid(infected_chikv_kenya~.)
coordinates(df.SP.36s) <- ~aic_village_gps_lattitude+aic_village_gps_longitude
sputm.36s <- SpatialPoints(df.SP.36s, proj4string=CRS("+proj=utm +zone=36s +datum=WGS84")  )
spgeo.36s <- spTransform(sputm.36s, CRS("+proj=longlat +datum=WGS84"))
spplot(df.SP.36s,c("village_aic.x"))