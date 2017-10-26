# packages ----------------------------------------------------------------
library("DiagrammeR")#install.packages("DiagrammeR")
library(plotly)

# get data ----------------------------------------------------------------
load("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long/R01_lab_results.clean.rda")

# exposure=malaria ----------------------------------------------------
#Malaria: positive by result_microscopy_malaria_kenya, or if NA, then positive by malaria_result. EXCLUDE RDT
R01_lab_results$malaria<-NA
#R01_lab_results <- within(R01_lab_results, malaria[R01_lab_results$result_rdt_malaria_keny==0] <- 0)#rdt
#R01_lab_results <- within(R01_lab_results, malaria[R01_lab_results$rdt_result==0] <- 0)#rdt
R01_lab_results <- within(R01_lab_results, malaria[R01_lab_results$malaria_results==0] <- 0)# Results of malaria blood smear	(+++ system)
R01_lab_results <- within(R01_lab_results, malaria[R01_lab_results$result_microscopy_malaria_kenya==0] <- 0)#microscopy. this goes last so that it overwrites all the other's if it exists.

R01_lab_results <- within(R01_lab_results, malaria[R01_lab_results$result_microscopy_malaria_kenya==1] <- 1) #this goes first. only use the others if this is missing.
R01_lab_results <- within(R01_lab_results, malaria[R01_lab_results$malaria_results>0 & is.na(result_microscopy_malaria_kenya)] <- 1)# Results of malaria blood smear	(+++ system)
#R01_lab_results <- within(R01_lab_results, malaria[R01_lab_results$result_rdt_malaria_kenya==1 & is.na(result_microscopy_malaria_kenya)] <- 1)#rdt
#R01_lab_results <- within(R01_lab_results, malaria[R01_lab_results$rdt_result==1 & is.na(result_microscopy_malaria_kenya)] <- 1)#rdt
table(R01_lab_results$malaria)
# cohort=aic febrile + malaria ------------------------------------------------------------------
aic_febrile_malaria<-R01_lab_results[which(R01_lab_results$Cohort=="F"),]
  n_aic<-sum(n_distinct(aic_febrile_malaria$person_id, na.rm = FALSE)) #5715 children presented to clinc
aic_febrile_malaria<-aic_febrile_malaria[which(aic_febrile_malaria$aic_symptom_fever==1|aic_febrile_malaria$temp>=38),]
  n_aic_fever<-sum(n_distinct(aic_febrile_malaria$person_id, na.rm = FALSE)) #5479 with documented fever
aic_febrile_malaria<-aic_febrile_malaria[which(!is.na(aic_febrile_malaria$malaria)),]
  n_aic_fever_malaria_tested<-sum(n_distinct(aic_febrile_malaria$person_id, na.rm = FALSE)) #5453 malaria tested
  table(aic_febrile_malaria$malaria)#incidence malaria 
  3114/(3114+2926)*100

  aic_febrile_malaria<-aic_febrile_malaria[which(aic_febrile_malaria$malaria==1),]
  n_aic_fever_malaria_pos<-sum(n_distinct(aic_febrile_malaria$person_id, na.rm = FALSE)) #2833 with malaria. 2620 neg.

  
# malaria species ---------------------------------------------------------
  aic_febrile_malaria$malaria_species<-NA
  
  aic_febrile_malaria_malariawide<- aic_febrile_malaria[, grepl("person_id|redcap_event_name|microscopy_malaria_p|microscopy_malaria_n", names(aic_febrile_malaria) ) ]
  aic_febrile_malaria_malariawide<-aic_febrile_malaria_malariawide[,order(colnames(aic_febrile_malaria_malariawide))]
  aic_febrile_malaria_malariawide<-reshape(aic_febrile_malaria_malariawide, idvar = c("person_id", "redcap_event_name"), varying = 1:5,  direction = "long", timevar = "species", times=c("ni", "pf","pm","po","pv"), v.names=c("microscopy_malaria"))
  aic_febrile_malaria_malariawide<- within(aic_febrile_malaria_malariawide, species[microscopy_malaria!=1] <- NA)
  table(aic_febrile_malaria_malariawide$species, aic_febrile_malaria_malariawide$microscopy_malaria)
  
  aic_febrile_malaria<-merge(aic_febrile_malaria, aic_febrile_malaria_malariawide, by=c("person_id","redcap_event_name"), all.x=TRUE)
  aic_febrile_malaria <- within(aic_febrile_malaria, species[aic_febrile_malaria$rdt_results==1 & (is.na(aic_febrile_malaria$species)|aic_febrile_malaria$species=="ni")] <- "pf") #rdt is pf specific
  barplot(table(aic_febrile_malaria$species))
  table(aic_febrile_malaria$species)
  8225/(8225+29+9)*100 #pf
  29/(8225+29+9)*100 #pm
  9/(8225+29+9)*100 #po
  9/(8225+29+9)*100 #po
  
#keep first visit in duplicate observations ------------------------------
  aic_febrile_malaria <- aic_febrile_malaria[order(aic_febrile_malaria$person_id, aic_febrile_malaria$int_date),]#order by interview date
  aic_febrile_malaria <- aic_febrile_malaria[!duplicated(aic_febrile_malaria$person_id),]  #keep first febrile event with malaria if duplicate id.

# rdt vs micro ------------------------------------------------------------
  aic_febrile_malaria$test<-NA
  aic_febrile_malaria <- within(aic_febrile_malaria, test[!is.na(aic_febrile_malaria$rdt_results)] <- "RDT")
  aic_febrile_malaria <- within(aic_febrile_malaria, test[!is.na(aic_febrile_malaria$malaria_results)] <- "POC Microscopy")
  aic_febrile_malaria <- within(aic_febrile_malaria, test[!is.na(aic_febrile_malaria$result_microscopy_malaria_kenya)] <- "Lab Microscopy")
  table(aic_febrile_malaria$test, aic_febrile_malaria$priyanka_outcome_hospitalized)

# flow chart of subjects --------------------------------------------------
grViz("
      digraph boxes_and_circles{
      graph[nodesep=2]
      node[shape = oval; color = black; fontsize = 100; fontname=arial; fontcolor=black; penwidth = 6; arrowshape=normal]
      edge[penwidth = 6; arrowhead=normal; arrowsize =4; minlen=4]
      
#n_aic
#n_aic_fever
5715->None  
None->236
#n_aic_fever_malaria_tested
5479->Not
Not->26
#n_aic_fever_malaria_pos
5453->Negative
Negative->2339
3114->No_follow_up->927;
2187->Not_hospitalized->2045

#red
graph[nodesep=2]
node[shape = oval; color = red; fontsize = 100; fontname=arial; fontcolor=red; penwidth = 6; arrowshape=normal]
edge[penwidth = 6; arrowhead=normal; arrowsize =4; minlen=4, color = red]

#n_aic
Children_present_to_clinic->5715
      #n_aic_fever
      5715->Fever;   
      Fever->5479; 
      #n_aic_fever_malaria_tested
      5479->Malaria_tested; 
      Malaria_tested->5453; 
      #n_aic_fever_malaria_pos
      5453->Positive;
      Positive->3114;
      3114->Follow_up;
      Follow_up->2187;
      2187->Hospitalized;
      Hospitalized->142;
      }")
        



# outcome=hospitalized ----------------------------------------------------
table(aic_febrile_malaria$outcome,aic_febrile_malaria$outcome_hospitalized)
aic_febrile_malaria<- within(aic_febrile_malaria, priyanka_outcome_hospitalized[outcome_hospitalized==0 |outcome==1|outcome==2] <- 0)
aic_febrile_malaria<- within(aic_febrile_malaria, priyanka_outcome_hospitalized[outcome_hospitalized==1 |outcome==3|outcome==4] <- 1)
table(aic_febrile_malaria$priyanka_outcome_hospitalized)
1121+116
116/(116+1121)*100
# history of malaria ------------------------------------------------------
aic_febrile_malaria$malaria_history<-grepl("malaria", aic_febrile_malaria$past_medical_history)
table(aic_febrile_malaria$malaria_history)
aic_febrile_malaria$malaria_history <- factor(aic_febrile_malaria$malaria_history,levels = c("FALSE","TRUE"),labels = c("No", "Yes"))


# city --------------------------------------------------------------------
aic_febrile_malaria <- within(aic_febrile_malaria, City[aic_febrile_malaria$City=="R"] <- "C")
table(aic_febrile_malaria$City)
table(aic_febrile_malaria$site,aic_febrile_malaria$City, exclude = NULL)

# graph outcome hospitalized by age ---------------------------------------------------------------
aic_febrile_malaria$hospital_lab <- factor(aic_febrile_malaria$priyanka_outcome_hospitalized,levels = c(0,1),labels = c("No", "Yes"))

hospitalized_age <- ddply(aic_febrile_malaria, .(age_group), summarise, 
                             hospital_p = mean(priyanka_outcome_hospitalized, na.rm = TRUE),
                             hospital_sd = sd(priyanka_outcome_hospitalized, na.rm = TRUE)
)
margin = list(l = 100, r = 50, b = 100, t = 75, pad = 4)
plot_ly(hospitalized_age, y=~hospital_p, x=~age_group, type="bar", error_y = ~list(value = hospital_sd))%>%
layout(title="Malaria aic_febrile_malaria Hospitalized", xaxis=list(title="Age Group"), yaxis=list(title="Subjects", tickformat="%"),font=list(size=28),margin=margin)
# graph outcome hospitalized by MALARIA HISTORY ---------------------------------------------------------------
hospitalized_mal_history <- ddply(aic_febrile_malaria, .(malaria_history), summarise, 
                          hospital_p = mean(priyanka_outcome_hospitalized, na.rm = TRUE),
                          hospital_sd = sd(priyanka_outcome_hospitalized, na.rm = TRUE)
)
plot_ly(hospitalized_mal_history, y=~hospital_p, x=~malaria_history, type="bar", error_y = ~list(value = hospital_sd))%>%
  layout(title="Malaria aic_febrile_malaria Hospitalized", xaxis=list(title="History of Malaria"), yaxis=list(title="Subjects", tickformat="%"),font=list(size=28),margin=margin)
# graph outcome hospitalized by city ---------------------------------------------------------------
hospitalized_City <- ddply(aic_febrile_malaria, .(City), summarise, 
                                  hospital_p = mean(priyanka_outcome_hospitalized, na.rm = TRUE),
                                  hospital_sd = sd(priyanka_outcome_hospitalized, na.rm = TRUE)
)
plot_ly(hospitalized_City, y=~hospital_p, x=~City, type="bar", error_y = ~list(value = hospital_sd))%>%
  layout(title="Malaria aic_febrile_malaria Hospitalized", xaxis=list(title="City"), yaxis=list(title="Subjects", tickformat="%"),font=list(size=28),margin=margin)

# wealth index ------------------------------------------------------------
aic_febrile_malaria <- within(aic_febrile_malaria, kid_highest_level_education_aic[aic_febrile_malaria$kid_highest_level_education_aic==9|aic_febrile_malaria$kid_highest_level_education_aic==5] <- NA)
aic_febrile_malaria <- within(aic_febrile_malaria, mom_highest_level_education_aic[aic_febrile_malaria$mom_highest_level_education_aic==9|aic_febrile_malaria$mom_highest_level_education_aic==5] <- NA)
aic_febrile_malaria <- within(aic_febrile_malaria, roof_type[aic_febrile_malaria$roof_type==9|aic_febrile_malaria$roof_type==4] <- NA)
aic_febrile_malaria <- within(aic_febrile_malaria, latrine_type[aic_febrile_malaria$latrine_type==9|aic_febrile_malaria$latrine_type==6] <- NA)
aic_febrile_malaria <- within(aic_febrile_malaria, floor_type[aic_febrile_malaria$floor_type==9|aic_febrile_malaria$floor_type==5] <- NA)

aic_febrile_malaria <- within(aic_febrile_malaria, drinking_water_source[aic_febrile_malaria$drinking_water_source==9|aic_febrile_malaria$drinking_water_source==6] <- NA)
aic_febrile_malaria$drinking_water_source<-  as.numeric(as.character(aic_febrile_malaria$drinking_water_source))
class(aic_febrile_malaria$drinking_water_source)

class(aic_febrile_malaria$light_source)
table(aic_febrile_malaria$light_source)
aic_febrile_malaria$light_source<-  as.numeric(as.character(aic_febrile_malaria$light_source))

aic_febrile_malaria <- within(aic_febrile_malaria, light_source[aic_febrile_malaria$light_source==9|aic_febrile_malaria$light_source==7] <- NA)
aic_febrile_malaria <- within(aic_febrile_malaria, light_source[aic_febrile_malaria$light_source==1] <- 30)
aic_febrile_malaria <- within(aic_febrile_malaria, light_source[aic_febrile_malaria$light_source==3] <- 20)
aic_febrile_malaria <- within(aic_febrile_malaria, light_source[aic_febrile_malaria$light_source==2|aic_febrile_malaria$light_source==4|aic_febrile_malaria$light_source==5|aic_febrile_malaria$light_source==6] <- 10)
aic_febrile_malaria$light_source <- aic_febrile_malaria$light_source/10 
table(aic_febrile_malaria$light_source)
class(aic_febrile_malaria$light_source)


aic_febrile_malaria$telephone<-  as.numeric(as.character(aic_febrile_malaria$telephone))
aic_febrile_malaria <- within(aic_febrile_malaria, telephone[aic_febrile_malaria$telephone==8] <- NA)
class(aic_febrile_malaria$telephone)


aic_febrile_malaria$radio<-  as.numeric(as.character(aic_febrile_malaria$radio))
aic_febrile_malaria <- within(aic_febrile_malaria, radio[aic_febrile_malaria$radio==8] <- NA)
class(aic_febrile_malaria$radio)


aic_febrile_malaria$television<-  as.numeric(as.character(aic_febrile_malaria$television))
aic_febrile_malaria <- within(aic_febrile_malaria, television[aic_febrile_malaria$television==8] <- NA)
class(aic_febrile_malaria$television)


aic_febrile_malaria$bicycle<-  as.numeric(as.character(aic_febrile_malaria$bicycle))
aic_febrile_malaria <- within(aic_febrile_malaria, bicycle[aic_febrile_malaria$bicycle==8] <- NA)
class(aic_febrile_malaria$bicycle)

aic_febrile_malaria$motor_vehicle<-  as.numeric(as.character(aic_febrile_malaria$motor_vehicle))
aic_febrile_malaria <- within(aic_febrile_malaria, motor_vehicle[aic_febrile_malaria$motor_vehicle==8] <- NA)
class(aic_febrile_malaria$motor_vehicle)

aic_febrile_malaria$domestic_worker<-  as.numeric(as.character(aic_febrile_malaria$domestic_worker))
aic_febrile_malaria <- within(aic_febrile_malaria, domestic_worker[aic_febrile_malaria$domestic_worker==8] <- NA)
class(aic_febrile_malaria$domestic_worker)
table(aic_febrile_malaria$domestic_worker)

ses<-(aic_febrile_malaria[, grepl("telephone|radio|television|bicycle|motor_vehicle|domestic_worker", names(aic_febrile_malaria))])
aic_febrile_malaria$ses_sum<-rowSums(aic_febrile_malaria[, c("telephone","radio","television","bicycle","motor_vehicle", "domestic_worker")], na.rm = TRUE)
table(aic_febrile_malaria$ses_sum)

# demography tables ------------------------------------------------------------------
vars<-c("malaria_history","age_group","site","City","species","ses_sum","mom_highest_level_education_aic","gender_aic")
factorVars<-c("malaria_history","age_group","site","City","mom_educ","species","mom_highest_level_education_aic","gender_aic")
table1 <- CreateTableOne(vars = vars, factorVars = factorVars, strata = "priyanka_outcome_hospitalized", data = aic_febrile_malaria)
print(table1, quote = TRUE)

# mosquito table ----------------------------------------------------------
aic_febrile_malaria$mosquito_bites_aic<-as.numeric(as.character(aic_febrile_malaria$mosquito_bites_aic))
aic_febrile_malaria <- within(aic_febrile_malaria, mosquito_bites_aic[aic_febrile_malaria$mosquito_bites_aic==8] <-NA )

aic_febrile_malaria$mosquito_coil_aic<-as.numeric(as.character(aic_febrile_malaria$mosquito_coil_aic))
aic_febrile_malaria <- within(aic_febrile_malaria, mosquito_coil_aic[aic_febrile_malaria$mosquito_coil_aic==8] <-NA )

aic_febrile_malaria$outdoor_activity_aic<-as.numeric(as.character(aic_febrile_malaria$outdoor_activity_aic))
aic_febrile_malaria <- within(aic_febrile_malaria, outdoor_activity_aic[aic_febrile_malaria$outdoor_activity_aic==8] <-NA )

aic_febrile_malaria$mosquito_net_aic<-as.numeric(as.character(aic_febrile_malaria$mosquito_net_aic))
aic_febrile_malaria <- within(aic_febrile_malaria, mosquito_net_aic[aic_febrile_malaria$mosquito_net_aic==8] <-NA )

mosq_vars <- c("mosquito_bites_aic", "mosquito_coil_aic", "outdoor_activity_aic", "mosquito_net_aic") 
mosq_factorVars <- c("mosquito_bites_aic", "mosquito_coil_aic", "outdoor_activity_aic", "mosquito_net_aic") 

mosq_tableOne <- CreateTableOne(vars = mosq_vars, strata = "priyanka_outcome_hospitalized", factorVars=mosq_factorVars, data = aic_febrile_malaria)
#summary(mosq_tableOne)
print(mosq_tableOne, exact = c("mosquito_bites_aic", "mosquito_coil_aic", "outdoor_activity_aic", "mosquito_net_aic"), quote = TRUE, includeNA=TRUE)


