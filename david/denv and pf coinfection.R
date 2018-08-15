library("tableone")
library("plyr")
library("dplyr")
#install.packages("stringr")
library(stringr)
# import data -------------------------------------------------------------
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/david coinfectin paper/data")
#load("R01_lab_results.david.coinfection.dataset.rda")#load data that has been cleaned previously#final data set made on 8/8/18 for david conifection paper.
cases<- R01_lab_results[which(R01_lab_results$int_date<="2018-06-30")  , ]#subset to visits before june 30.
sum(n_distinct(cases$person_id, na.rm = FALSE)) #9988 patients reviewed

# subset our data to david's cohort of aic west ---------------------------
  cases<-cases[which(cases$Cohort=="F"), ]
  sum(n_distinct(cases$person_id, na.rm = FALSE)) #6489
  cases<-cases[which(cases$site=="W"), ]
  sum(n_distinct(cases$person_id, na.rm = FALSE)) #2277
  cases$id_cohort<-substr(cases$person_id, 2, 2)
  cases$id_city<-substr(cases$person_id, 1, 1)

  
  table(cases$redcap_event_name,cases$id_city)

  # #create acute variable  ------------------------------------------------------------------------
  cases <- cases[, !grepl("u24|sample", names(cases) ) ]
  cases$acute<-NA
  cases <- within(cases, acute[cases$visit_type==1] <- 1)
  cases <- within(cases, acute[cases$visit_type==2] <- 1)
  cases <- within(cases, acute[cases$visit_type==3] <- 0)
  cases <- within(cases, acute[cases$visit_type==4] <- 1)
  cases <- within(cases, acute[cases$visit_type==5] <- 0)
  
  #if they ask an initial survey question (see odk aic inital and follow up forms), it is an initial visit.
  cases <- within(cases, acute[cases$kid_highest_level_education_aic!=""] <- 1)
  cases <- within(cases, acute[cases$occupation_aic!=""] <- 1)
  cases <- within(cases, acute[cases$oth_educ_level_aic!=""] <- 1)
  cases <- within(cases, acute[cases$mom_highest_level_education_aic!=""] <- 1)
  cases <- within(cases, acute[cases$roof_type!=""] <- 1)
  cases <- within(cases, acute[cases$pregnant!=""] <- 1)
  #if it is visit a,call it acute
  cases <- within(cases, acute[cases$redcap_event=="visit_a_arm_1" & cases$Cohort=="F"] <- 1)
  
  #if they have fever, call it acute
  cases <- within(cases, acute[cases$aic_symptom_fever==1] <- 1)
  cases <- within(cases, acute[cases$temp>=38] <- 1)
  
  #otherwise, it is not acute
  cases <- within(cases, acute[cases$acute!=1] <- 0)
  table(cases$redcap_event_name, cases$acute)#3074 afi.2203 at a, 707 at b.

  # count number per group for subject diagram------------------------------------------------------------------------
  cases<- cases[which(cases$redcap_event_name=="visit_a_arm_1"|cases$redcap_event_name=="visit_b_arm_1")  , ]
  sum(n_distinct(cases$person_id, na.rm = FALSE)) #2276
  
  n<-sum(n_distinct(R01_lab_results$person_id, na.rm = FALSE)) #10,899 patients reviewed
  cases<-cases[which((cases$acute==1&cases$redcap_event_name=="visit_a_arm_1")|(cases$acute!=1&cases$redcap_event_name=="visit_b_arm_1")), ]
  aic_n<-sum(n_distinct(cases$person_id, na.rm = FALSE)) #2,205 patients included in study (aic, west)
  table(cases$redcap_event_name)
  afi<-  sum(cases$acute==1, na.rm = TRUE)#2203 afi's

  #denv  case defination------------------------------------------------------------------------
  #redefine infected_denv_stfd to exclude ufi. 
  #stfd denv igg seroconverters or PCR positives as infected.
  cases$infected_denv_stfd<-NA
  cases$infected_denv_stfd[cases$tested_denv_stfd_igg ==1 |cases$result_pcr_denv_kenya==0|cases$result_pcr_denv_stfd==0]<-0
  cases$infected_denv_stfd[cases$seroc_denv_stfd_igg==1|cases$result_pcr_denv_kenya==1|cases$result_pcr_denv_stfd==1]<-1
  table(cases$seroc_denv_stfd_igg)
  table(cases$infected_denv_stfd)  
  
  #table of denv at acute visit. 
  denv_acute<-  sum(cases$infected_denv_stfd==1 & cases$acute==1, na.rm = TRUE)#126 denv infected (seroconverter or PCR +)
  #malaria case defination------------------------------------------------------------------------
  #Malaria: positive by result_microscopy_malaria_kenya, or if NA, then positive by malaria_result
  cases$malaria<-NA
  cases <- within(cases, malaria[cases$result_rdt_malaria_keny==0] <- 0)#rdt
  cases <- within(cases, malaria[cases$rdt_result==0] <- 0)#rdt
  cases <- within(cases, malaria[cases$malaria_results==0] <- 0)# Results of malaria blood smear	(+++ system)
  cases <- within(cases, malaria[cases$result_microscopy_malaria_kenya==0] <- 0)#microscopy. this goes last so that it overwrites all the other's if it exists.
  
  cases <- within(cases, malaria[cases$result_microscopy_malaria_kenya==1] <- 1) #this goes first. only use the others if this is missing.
  cases <- within(cases, malaria[cases$malaria_results>0 & is.na(result_microscopy_malaria_kenya)] <- 1)# Results of malaria blood smear	(+++ system)
  cases <- within(cases, malaria[cases$rdt_results==1 & is.na(result_microscopy_malaria_kenya)] <- 1)#rdt
  table(cases$malaria)
  #denv by pcr or serology ------------------------------------------------------------------------
  cases$pcr_denv<-NA
  cases <- within(cases, pcr_denv[cases$result_pcr_denv_kenya==0] <- 0)
  cases <- within(cases, pcr_denv[cases$result_pcr_denv_stfd==0] <- 0)
  cases <- within(cases, pcr_denv[cases$result_pcr_denv_kenya==1] <- 1)
  cases <- within(cases, pcr_denv[cases$result_pcr_denv_stfd==1] <- 1)
  table(cases$pcr_denv)
  table(cases$seroc_denv_stfd_igg)
  table(cases$seroc_denv_stfd_igg, cases$pcr_denv, exclude = NULL)#87 by pcr, 6 by igg seroconversion.
  table(cases$infected_denv_stfd, cases$malaria, exclude = NULL)
  table(cases$infected_denv_stfd, exclude = NULL)
  #  #some need to be malaria tested to be included in sample ------------------------------------------------------------------------
  not_malaria_tested<-cases[which(is.na(cases$malaria) & cases$infected_denv_stfd==1), ]
  table(is.na(cases$malaria) & cases$infected_denv_stfd==1)
#  table(not_malaria_tested$person_id, not_malaria_tested$redcap_event_name)
  #  keep acute only ------------------------------------------------------------------------
  cases<-cases[which(cases$acute==1), ]
  
  #  keep only those tested for both denv and malaria ------------------------------------------------------------------------
  #define denv testing as pcr or paired igg.
  cases$tested_malaria<-NA
  cases <- within(cases, tested_malaria[!is.na(cases$malaria)] <- 1)
  cases <- within(cases, tested_denv_stfd_igg[!is.na(cases$infected_denv_stfd) |cases$tested_denv_stfd_igg==1] <- 1)
  cases <- within(cases, tested_denv_stfd_igg[cases$tested_denv_stfd_igg==0 ] <- NA)
  #count just tested for denv not malaria  #just tested for malaria not denv
  table(cases$tested_malaria, exclude = NULL)#malaria tested = 2171 NA = 32
  table(cases$tested_denv_stfd_igg, exclude = NULL)#denv tested = 2037 NA = 166
  table(cases$tested_denv_stfd_igg, cases$tested_malaria, exclude = NULL)# 32 not malaria tested but denv tested. 166 malaria tested but not denv tested. 0 tested for neither. 2005 tested for both
  
  denv_tested_malaria_tested <-  sum(!is.na(cases$infected_denv_stfd) & !is.na(cases$malaria), na.rm = TRUE)#1816 tested for both
  
  denv_not_tested_malaria_not_tested  <-  sum(is.na(cases$infected_denv_stfd) & is.na(cases$malaria), na.rm = TRUE)#543
  denv_not_tested_malaria_tested <-  sum(is.na(cases$infected_denv_stfd) & !is.na(cases$malaria), na.rm = TRUE)#88
  denv_tested_malaria_not_tested <-  sum(!is.na(cases$infected_denv_stfd) & is.na(cases$malaria), na.rm = TRUE)#362
  
  #keep only those tested for both
  cases<-cases[which(!is.na(cases$malaria) & cases$tested_denv_stfd_igg==1  & cases$acute==1), ]
  #flow chart of subjects.    
  n_events_tested<-  sum(length(cases$person_id))#1816 acute visits tested for both denv and malaria.
  n_subjects_tested<-  sum(n_distinct(cases$person_id), na.rm = TRUE)#1729 unique subjects.
  
  #  strata for malaria and denv------------------------------------------------------------------------
  #denv and any malaria  
  #Can you then create a DENV/malaria where all episodes can be defined as DENV/malaria pos, DENV pos, malaria pos, or DENV/malaria neg?
  #What I would like is the cases defined as follows:
  #DENV: positive by RT-PCR, or IgG seroconversion (I've run your code but there are symptoms variables that give me errors.says they don't exist). Can you also query how many seroconverted bc, de, fg?
  #this is the same way i have defined infection for desiree.
  
  table(cases$malaria, cases$infected_denv_stfd, exclude = NULL)
  denv_pos_malaria_neg <-  sum(cases$infected_denv_stfd==1 & cases$malaria==0, na.rm = TRUE)#42
  denv_pos_malaria_pos <-  sum(cases$infected_denv_stfd==1 & cases$malaria==1, na.rm = TRUE)#47
  denv_neg_malaria_neg <-  sum(cases$infected_denv_stfd==0 & cases$malaria==0, na.rm = TRUE)#876
  denv_neg_malaria_pos <-  sum(cases$infected_denv_stfd==0 & cases$malaria==1, na.rm = TRUE)#1040
  
  # malaria species------------------------------------------------------------------------
  cases$malaria_pf<-NA
  cases <- within(cases, malaria_pf[cases$result_rdt_malaria_keny==0 & cases$malaria!=1] <- 0)#rdt
  cases <- within(cases, malaria_pf[cases$result_rdt_malaria_keny==1] <- 1)#rdt
  
  cases <- within(cases, malaria_pf[cases$microscopy_malaria_pf_kenya___1==0 & !is.na(cases$result_microscopy_malaria_kenya) & cases$malaria!=1] <- 0)#rdt
  cases <- within(cases, malaria_pf[cases$microscopy_malaria_pf_kenya___1==1] <- 1)#rdt
  
  table(cases$malaria_pf)#pf pos/neg
  table(cases$malaria)#malaria pos/neg
  #1. Of the 1816, what was the distribution of Pf vs other species? Basically, I want to say this: "In our cohort, among the subjects with malaria whose Plasmodium species could be identified by blood smear microscopy, X of Y (%) were identified as Pf. P. malariae was identified in 7 subjects with malaria."
  table(cases$malaria)  
  table(cases$malaria_pf)  
  
  non_id_malaria<-cases[which(cases$malaria==1 & is.na(cases$malaria_pf)), ]
  non_id_malaria <-non_id_malaria[, grepl("person_id|redcap|malaria", names(non_id_malaria) ) ]
  f <- "non_id_malaria.csv"
  write.csv(as.data.frame(non_id_malaria), f )
  
  non_pf<-cases[which(cases$malaria==1 & cases$microscopy_malaria_pm_kenya___1==1& cases$microscopy_malaria_pf_kenya___1==0), ]
  non_pf <-non_pf[, grepl("person_id|redcap|malaria", names(non_pf) ) ]
  f <- "non_pf.csv"
  write.csv(as.data.frame(non_pf), f )

  # pf malaria strata------------------------------------------------------------------------
  table(cases$malaria_pf, cases$infected_denv_stfd)
  denv_pf_tested_events<-sum(!is.na(cases$infected_denv_stfd) & !is.na(cases$malaria_pf), na.rm = TRUE)
  denv_pos_pf_neg <-  sum(cases$infected_denv_stfd==1 & cases$malaria_pf==0, na.rm = TRUE)#1511
  denv_pos_pf_pos <-  sum(cases$infected_denv_stfd==1 & cases$malaria_pf==1, na.rm = TRUE)#27
  denv_neg_pf_neg <-  sum(cases$infected_denv_stfd==0 & cases$malaria_pf==0, na.rm = TRUE)#665
  denv_neg_pf_pos <-  sum(cases$infected_denv_stfd==0 & cases$malaria_pf==1, na.rm = TRUE)#796
  
  #repate analyasis for both pf and malaria
  
  #create strata: 1 = malaria+ & denv + | 2 = malaria+ denv - | 3= malaria- & denv - | 4= malaria- & denv + 
  cases$strata_all<-NA
  cases <- within(cases, strata_all[cases$malaria==1 & cases$infected_denv_stfd==1] <- "malaria_pos_&_denv_pos")
  cases <- within(cases, strata_all[cases$malaria==1 & cases$infected_denv_stfd==0] <- "malaria_pos_&_denv_neg")
  cases <- within(cases, strata_all[cases$malaria==0 & cases$infected_denv_stfd==0] <- "malaria_neg_&_denv neg")
  cases <- within(cases, strata_all[cases$malaria==0 & cases$infected_denv_stfd==1] <- "malaria_neg_&_denv_pos")
  table(cases$strata_all)
  pedsqlnonna<-cases[,c("person_id","redcap_event_name","strata_all","result_pcr_denv_kenya","result_pcr_denv_stfd","result_microscopy_malaria_kenya","density_microscpy_pf_kenya","interview_date_aic","rdt_results","temp","result_igg_denv_kenya","result_igg_denv_stfd")]
  write.csv(pedsqlnonna,"pedsql_denv_malaria_strata_all.csv")
  
  #create strata: 1 = pf+ & denv + | 2 = pf + denv - | 3= pf- & denv - | 4= pf - & denv + 
  #d+, pf+, m+ / d+ pf- m - / d+pf-, m+ / d-p-m+ / d-pf-m- / d-pf+m+
  cases$strata<-NA
  cases <- within(cases, strata[cases$microscopy_malaria_pf_kenya___1==1 & cases$infected_denv_stfd==1] <- "pf_pos_&_denv_pos")
  cases <- within(cases, strata[cases$result_rdt_malaria_kenya==1 & cases$infected_denv_stfd==1] <- "pf_pos_&_denv_pos")
  
  cases <- within(cases, strata[cases$microscopy_malaria_pf_kenya___1==1 & cases$infected_denv_stfd==0] <- "pf_pos_&_denv_neg")
  cases <- within(cases, strata[cases$result_rdt_malaria_kenya==1 & cases$infected_denv_stfd==0] <- "pf_pos_&_denv_neg")
  
  cases <- within(cases, strata[cases$malaria==0 & cases$infected_denv_stfd==0] <- "pf_neg_&_denv_neg")
  
  cases <- within(cases, strata[cases$malaria==0 & cases$infected_denv_stfd==1] <- "pf_neg_&_denv_pos")
  table(cases$strata)  
  table(cases$strata_all)  
  #save dataset------------------------------------------------------------------------
  
  save(cases,file="cases.rda")
  load("cases.rda")
  names(cases)[names(cases) == 'redcap_event'] <- 'redcap_event_name'
  
  ##merge with paired pedsql data (acute and convalescent)-----------------------------------------------------------------------
  load("pedsql_pairs_acute.rda")
  
  names(pedsql_pairs_acute)[names(pedsql_pairs_acute) == 'redcap_event_name_acute_paired'] <- 'redcap_event_name'
  cases_pedsql <- join(cases, pedsql_pairs_acute,  by=c("person_id", "redcap_event_name"), match = "all" , type="left")
  cases_pedsql<-cases_pedsql[order(-(grepl('person_id|redcap|pedsql_', names(cases_pedsql)))+1L)]
  
  #table(cases_pedsql$pedsql_parent_social_mean_acute_paired,cases_pedsql$pedsql_parent_social_mean_conv_paired)
  
  cases<-cases_pedsql
  cases<-cases[order(-(grepl('person_id|redcap|pedsql_', names(cases)))+1L)]
  conv_paired_peds<-cases[which(!is.na(cases$pedsql_parent_total_mean_conv_paired)), ]
  table(cases$pedsql_parent_total_mean_conv_paired)
  ##how to merge  with unpaired pedsql data?? if we don't know when the convalescent visit is, and we are only looking at acute visits, then what is the unpaired data?-----------------------------------------------------------------------
  
  # outcome hospitalized ----------------------------------------------------
  cases$outcome_hospitalized<-as.numeric(as.character(cases$outcome_hospitalized))
  cases <- within(cases, outcome_hospitalized[outcome_hospitalized==8] <-1 )
  table(cases$outcome_hospitalized)
  # demographics ------------------------------------------------------------
  
  #ses- create an index
  cases <- within(cases, kid_highest_level_education_aic[cases$kid_highest_level_education_aic==9|cases$kid_highest_level_education_aic==5] <- NA)
  cases <- within(cases, mom_highest_level_education_aic[cases$mom_highest_level_education_aic==9|cases$mom_highest_level_education_aic==5] <- NA)
  cases <- within(cases, roof_type[cases$roof_type==9|cases$roof_type==4] <- NA)
  cases <- within(cases, latrine_type[cases$latrine_type==9|cases$latrine_type==6] <- NA)
  cases <- within(cases, floor_type[cases$floor_type==9|cases$floor_type==5] <- NA)
  
  
  cases <- within(cases, drinking_water_source[cases$drinking_water_source==9|cases$drinking_water_source==6] <- NA)
  cases$drinking_water_source<-  as.numeric(as.character(cases$drinking_water_source))
  class(cases$drinking_water_source)
  
  class(cases$light_source)
  table(cases$light_source)
  cases$light_source<-  as.numeric(as.character(cases$light_source))
  
  cases <- within(cases, light_source[cases$light_source==9|cases$light_source==7] <- NA)
  cases <- within(cases, light_source[cases$light_source==1] <- 30)
  cases <- within(cases, light_source[cases$light_source==3] <- 20)
  cases <- within(cases, light_source[cases$light_source==2|cases$light_source==4|cases$light_source==5|cases$light_source==6] <- 10)
  cases$light_source <- cases$light_source/10 
  table(cases$light_source)
  class(cases$light_source)
  
  
  cases$telephone<-  as.numeric(as.character(cases$telephone))
  cases <- within(cases, telephone[cases$telephone==8] <- NA)
  class(cases$telephone)
  
  
  cases$radio<-  as.numeric(as.character(cases$radio))
  cases <- within(cases, radio[cases$radio==8] <- NA)
  class(cases$radio)
  
  
  cases$television<-  as.numeric(as.character(cases$television))
  cases <- within(cases, television[cases$television==8] <- NA)
  class(cases$television)
  
  
  cases$bicycle<-  as.numeric(as.character(cases$bicycle))
  cases <- within(cases, bicycle[cases$bicycle==8] <- NA)
  class(cases$bicycle)
  
  cases$motor_vehicle<-  as.numeric(as.character(cases$motor_vehicle))
  cases <- within(cases, motor_vehicle[cases$motor_vehicle==8] <- NA)
  class(cases$motor_vehicle)
  
  cases$domestic_worker<-  as.numeric(as.character(cases$domestic_worker))
  cases <- within(cases, domestic_worker[cases$domestic_worker==8] <- NA)
  class(cases$domestic_worker)
  table(cases$domestic_worker)
  
  ses<-(cases[, grepl("telephone|radio|television|bicycle|motor_vehicle|domestic_worker", names(cases))])
  cases$ses_sum<-rowSums(cases[, c("telephone","radio","television","bicycle","motor_vehicle", "domestic_worker")], na.rm = TRUE)
  table(cases$ses_sum)
  
  class(cases$aic_calculated_age)
  cases$aic_calculated_age<-as.numeric(as.character(cases$aic_calculated_age))
  cases<-cases[order(-(grepl('pedsql_', names(cases)))+1L)]
  cases<-cases[order(-(grepl('_mean', names(cases)))+1L)]
  
# demography tables ------------------------------------------------------------------
  ## 1.	What are risk factors for co-infection (demographics?)
  ##Create Table 1 for demographics stratified by denv/malaria status.
  ## Tests are by oneway.test/t.test for continuous, chisq.test for categorical
#mosquito vars 
  cases$mosquito_bites_aic<-as.numeric(as.character(cases$mosquito_bites_aic))
  cases <- within(cases, mosquito_bites_aic[cases$mosquito_bites_aic==8] <-NA )
  
  cases$mosquito_coil_aic<-as.numeric(as.character(cases$mosquito_coil_aic))
  cases <- within(cases, mosquito_coil_aic[cases$mosquito_coil_aic==8] <-NA )
  
  cases$outdoor_activity_aic<-as.numeric(as.character(cases$outdoor_activity_aic))
  cases <- within(cases, outdoor_activity_aic[cases$outdoor_activity_aic==8] <-NA )
  cases$mosquito_net_aic<-as.numeric(as.character(cases$mosquito_net_aic))
  cases <- within(cases, mosquito_net_aic[cases$mosquito_net_aic==8] <-NA )
#print tables    
    
    dem_vars=c("City", "gender_all","aic_calculated_age","ses_sum","mosquito_bites_aic", "mosquito_coil_aic", "outdoor_activity_aic", "mosquito_net_aic")
    dem_factorVars <- c("City","mosquito_bites_aic", "mosquito_coil_aic", "outdoor_activity_aic", "mosquito_net_aic") 
    dem_tableOne_strata_all <- CreateTableOne(vars = dem_vars, factorVars = dem_factorVars, strata = "strata_all", data = cases)
    dem_tableOne_total <- CreateTableOne(vars = dem_vars, factorVars = dem_factorVars,  data = cases)
    
    setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/david coinfectin paper/data")

    dem_tableOne_strata_all.csv <-print(dem_tableOne_strata_all, nonnormal=c("aic_calculated_age"), exact = c("id_city", "gender_all",    "mosquito_bites_aic", "mosquito_coil_aic", "outdoor_activity_aic", "mosquito_net_aic"),  quote = F, noSpaces = TRUE, includeNA=TRUE,, printToggle = FALSE)
    dem_tableOne_total.csv <-print(dem_tableOne_total, nonnormal=c("aic_calculated_age"), exact = c("id_city", "gender_all",    "mosquito_bites_aic", "mosquito_coil_aic", "outdoor_activity_aic", "mosquito_net_aic"),  quote = F, noSpaces = TRUE, includeNA=TRUE,, printToggle = FALSE)
    write.csv(dem_tableOne_strata_all.csv, file = "dem_tableOne_strata_all.csv")
    write.csv(dem_tableOne_total.csv, file = "dem_tableOne_total.csv")
    

#3.	Table info for PE, and outcomes analysis
#Table 2, OR of symptom/sign in reference to co-infection 
# 2.	Does co-infection present differently clinically than solo-infection (symptoms, signs, pedsQL acute)?
pedsql<- cases[which(cases$redcap_event_name=="visit_a_arm_1")  , ]#acute only.
pedsql<-pedsql[, grepl("pedsql|strata_all", names(pedsql))]
pedsql<-pedsql[, !grepl("child|infant|teen|812|mean|sum|type|group|complete|comments|idno|date|interviewer", names(pedsql))]
pedsql<-pedsql[order(-(grepl('strata', names(pedsql)))+1L)]

pedsql$strata_all<-as.factor(pedsql$strata_all)
pedsql$strata_all = relevel(pedsql$strata_all, ref = "malaria_pos_&_denv_pos")

#median tables
pedsql_vars<-names(pedsql[,-1])
pedsql.tableone <- CreateTableOne(vars = pedsql_vars, factorVars = pedsql_vars, strata = "strata_all", data = pedsql)
  pedsql.tableone.median.cat.csv<-print(pedsql.tableone, nonnormal=pedsql_vars,quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE)
  write.csv(pedsql.tableone.median.cat.csv, file = "pedsql.tableone.median.cat.csv")

pedsql.tableone <- CreateTableOne(vars = pedsql_vars, strata = "strata_all", data = pedsql)
  pedsql.tableone.median.cont.csv<-print(pedsql.tableone, nonnormal=pedsql_vars,quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE)
  write.csv(pedsql.tableone.median.cont.csv, file = "pedsql.tableone.median.cont.csv")


#or tables
library(nnet)

multi1<-lapply( pedsql[,-1], function(x) multinom(pedsql$strata_all ~ factor(x)+0))#remove factor if we decide to use cont.

coef<-lapply(multi1, coefficients)
or<-lapply(coef, exp)
lapply(or, function(x) write.table( data.frame(x), 'or.csv'  , append= T, sep=',' ))
lapply(names(multi1), function(x) write.table( data.frame(x), 'names.csv'  , append= T, sep=',' ))

#https://stats.stackexchange.com/questions/63222/getting-p-values-for-multinom-in-r-nnet-package
#install.packages("afex")
library(afex)
set_sum_contrasts() # use sum coding, necessary to make type III LR tests valid
library(car)
Anova(test,type="III")
#install.packages("AER")
library(AER)
coeftest(test)
p<-lapply(multi1, coeftest)
ptable<-lapply(p, tidy)
lapply(ptable, function(x) write.table( data.frame(x), 'pedsql_acute_OR_cat.csv'  , append= T, sep=',' ))

# pedsql paired data ------------------------------------------------------
    pedsql_paired_tableOne_strata_all <- CreateTableOne(vars = pedsql_paired_vars, strata = "strata_all", data = cases)
    #print table one (assume non normal distribution)
    pedsql_paired_tableOne_strata_all_non.csv <-print(pedsql_paired_tableOne_strata_all, 
                                                      nonnormal=c("pedsql_child_school_mean_acute_paired", "pedsql_child_school_mean_conv_paired", "pedsql_child_social_mean_acute_paired", "pedsql_child_social_mean_conv_paired", "pedsql_parent_school_mean_acute_paired", "pedsql_parent_school_mean_conv_paired", "pedsql_parent_social_mean_acute_paired", "pedsql_parent_social_mean_conv_paired", "pedsql_child_physical_mean_acute_paired", "pedsql_child_physical_mean_conv_paired", "pedsql_parent_physical_mean_acute_paired", "pedsql_parent_physical_mean_conv_paired", "pedsql_child_emotional_mean_acute_paired", "pedsql_child_emotional_mean_conv_paired", "pedsql_parent_emotional_mean_acute_paired", "pedsql_parent_emotional_mean_conv_paired"), 
                                                      quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE)
    write.csv(pedsql_paired_tableOne_strata_all_non.csv, file = "pedsql_paired_tableOne_strata_all_non.csv")
    
    #print table one (assume normal distribution)
    pedsql_paired_tableOne_strata_all_normal.csv <-print(pedsql_paired_tableOne_strata_all, 
                                                         quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE)
    write.csv(pedsql_paired_tableOne_strata_all_normal.csv, file = "pedsql_paired_tableOne_strata_all_normal.csv")
    
    
           
      pedsql<-cases[, grepl("person_id|pedsql|strata|hospitalized", names(cases))]

      write.csv(as.data.frame(pedsql), "C:/Users/amykr/Box Sync/Amy Krystosik's Files/david coinfectin paper/data/pedsql.csv" )
      
# symptoms table ----------------------------------------------------------
      #fix the bleeding and body_ache variables to replace NA with zero.
      
      #bleeding
      cases <- within(cases, bleeding[cases$aic_symptom_bleeding_gums==0] <- 0)
      cases <- within(cases, bleeding[cases$aic_symptom_bleeding_gums==0] <- 0)
      cases <- within(cases, bleeding[cases$aic_symptom_bloody_nose==0] <- 0)
      cases <- within(cases, bleeding[cases$aic_symptom_bloody_urine==0] <- 0)
      cases <- within(cases, bleeding[cases$aic_symptom_bloody_stool==0] <- 0)
      cases <- within(cases, bleeding[cases$aic_symptom_bloody_vomit==0] <- 0)
      cases <- within(cases, bleeding[cases$aic_symptom_bruises==0] <- 0)

      cases <- within(cases, bleeding[cases$aic_symptom_bleeding_gums==1] <- 1)
      cases <- within(cases, bleeding[cases$aic_symptom_bleeding_gums==1] <- 1)
      cases <- within(cases, bleeding[cases$aic_symptom_bloody_nose==1] <- 1)
      cases <- within(cases, bleeding[cases$aic_symptom_bloody_urine==1] <- 1)
      cases <- within(cases, bleeding[cases$aic_symptom_bloody_stool==1] <- 1)
      cases <- within(cases, bleeding[cases$aic_symptom_bloody_vomit==1] <- 1)
      cases <- within(cases, bleeding[cases$aic_symptom_bruises==1] <- 1)
      table(cases$bleeding)  
      
      #nausea_vomitting
      cases <- within(cases, nausea_vomitting[cases$aic_symptom_nausea==0|cases$aic_symptom_vomiting==0| cases$aic_symptom_bloody_vomit==0] <- 0)
      cases <- within(cases, nausea_vomitting[cases$aic_symptom_nausea==1|cases$aic_symptom_vomiting==1| cases$aic_symptom_bloody_vomit==1] <- 1)
      table(cases$nausea_vomitting)
      
      #ims
      cases <- within(cases, aic_symptom_impaired_mental_status[aic_symptom_fits==0|aic_symptom_seizures==0] <- 0)
      cases <- within(cases, aic_symptom_impaired_mental_status[aic_symptom_fits==1|aic_symptom_seizures==1] <- 1)
      
      #bodyache
      cases <- within(cases, body_ache[cases$aic_symptom_general_body_ache==0] <- 0)
      cases <- within(cases, body_ache[cases$aic_symptom_muscle_pains==0] <- 0)
      cases <- within(cases, body_ache[cases$aic_symptom_bone_pains==0] <- 0)

      cases <- within(cases, body_ache[cases$aic_symptom_general_body_ache==1] <- 1)
      cases <- within(cases, body_ache[cases$aic_symptom_muscle_pains==1] <- 1)
      cases <- within(cases, body_ache[cases$aic_symptom_bone_pains==1] <- 1)
      table(cases$body_ache)      
  
    cases$heart_rate<-    as.numeric(as.character(cases$heart_rate))
    cases$temp<-    as.numeric(as.character(cases$temp))
    symptom_vars <- c("aic_symptom_abdominal_pain", "aic_symptom_chills", "aic_symptom_cough", "aic_symptom_vomiting", "aic_symptom_headache", "aic_symptom_loss_of_appetite", "aic_symptom_diarrhea", "aic_symptom_sick_feeling",  "aic_symptom_general_body_ache", "aic_symptom_joint_pains", "aic_symptom_dizziness", "aic_symptom_runny_nose", "aic_symptom_sore_throat", "aic_symptom_rash", "aic_symptom_shortness_of_breath", "aic_symptom_nausea", "aic_symptom_fever", "aic_symptom_funny_taste", "aic_symptom_red_eyes", "aic_symptom_earache", "aic_symptom_stiff_neck", "aic_symptom_pain_behind_eyes", "aic_symptom_itchiness", "aic_symptom_impaired_mental_status", "aic_symptom_eyes_sensitive_to_light", "bleeding", "body_ache", "temp", "heart_rate", "nausea_vomitting")
    symptom_factorVars <- c("aic_symptom_abdominal_pain", "aic_symptom_chills", "aic_symptom_cough", "aic_symptom_vomiting", "aic_symptom_headache", "aic_symptom_loss_of_appetite", "aic_symptom_diarrhea", "aic_symptom_sick_feeling",  "aic_symptom_general_body_ache", "aic_symptom_joint_pains", "aic_symptom_dizziness", "aic_symptom_runny_nose", "aic_symptom_sore_throat", "aic_symptom_rash", "aic_symptom_shortness_of_breath", "aic_symptom_nausea", "aic_symptom_fever", "aic_symptom_funny_taste", "aic_symptom_red_eyes", "aic_symptom_earache", "aic_symptom_stiff_neck", "aic_symptom_pain_behind_eyes", "aic_symptom_itchiness", "aic_symptom_impaired_mental_status", "aic_symptom_eyes_sensitive_to_light", "bleeding", "body_ache","nausea_vomitting")
    
    symptoms_tableOne_strata_all <- CreateTableOne(vars = symptom_vars, factorVars = symptom_factorVars, strata = "strata_all", data = cases)
    #summary(symptoms_tableOne)
    symptoms_tableOne_strata_all.csv<-print(symptoms_tableOne_strata_all, 
                                        exact = c("aic_symptom_abdominal_pain", "aic_symptom_chills", "aic_symptom_cough", "aic_symptom_vomiting", "aic_symptom_headache", "aic_symptom_loss_of_appetite", "aic_symptom_diarrhea", "aic_symptom_sick_feeling",  "aic_symptom_general_body_ache", "aic_symptom_joint_pains", "aic_symptom_dizziness", "aic_symptom_runny_nose", "aic_symptom_sore_throat", "aic_symptom_rash", "aic_symptom_shortness_of_breath", "aic_symptom_nausea", "aic_symptom_fever", "aic_symptom_funny_taste", "aic_symptom_red_eyes", "aic_symptom_earache", "aic_symptom_stiff_neck", "aic_symptom_pain_behind_eyes", "aic_symptom_itchiness", "aic_symptom_impaired_mental_status", "aic_symptom_eyes_sensitive_to_light", "bleeding", "body_ache", "temp", "heart_rate", "temp", "outcome_hospitalized","nausea_vomitting"),
                                        nonnormal=c("heart_rate", "temp"),
                                        quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE)
    
    write.csv(symptoms_tableOne_strata_all.csv, file = "symptoms_tableOne_strata_all.csv")
    
    
#Table 2, OR of symptom/sign in reference to co-infection 
    symptoms <- cases[c("strata_all",symptom_vars)]
    
    multi1<-lapply( symptoms[,-1], function(x) multinom(symptoms$strata_all ~ x+0))#remove factor if we decide to use cont.
    
    coef<-lapply(multi1, coefficients)
    or<-lapply(coef, exp)
    lapply(or, function(x) write.table( data.frame(x), 'symptoms_or.csv'  , append= T, sep=',' ))
    lapply(names(multi1), function(x) write.table( data.frame(x), 'symptoms_names.csv'  , append= T, sep=',' ))
    
    #https://stats.stackexchange.com/questions/63222/getting-p-values-for-multinom-in-r-nnet-package
    #install.packages("afex")
    library(afex)
    set_sum_contrasts() # use sum coding, necessary to make type III LR tests valid
    library(car)
    #install.packages("AER")
    library(AER)
    p<-lapply(multi1, coeftest)
    library(broom)
    ptable<-lapply(p, tidy)
    lapply(ptable, function(x) write.table( data.frame(x), 'symtoms_acute_OR.csv'  , append= T, sep=',' ))
    
    
    # save and export data ----------------------------------------------------
    save(cases,file="david_denv_malaria_cohort.rda")
    #export to csv
    setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/david coinfectin paper/data")
    f <- "david_denv_pf_cohort.csv"
    write.csv(as.data.frame(cases), f )
    # save and export strata and hospitalization data ----------------------------------------------------
    david_coinfection_strata_hospitalization<-cases[, grepl("person_id|redcap_event_name|strata|outcome_hospitalized|outcome|gender_all|age|ses_sum|mom_highest_level_education", names(cases))]
    save(david_coinfection_strata_hospitalization,file="C:/Users/amykr/Box Sync/Amy Krystosik's Files/david coinfectin paper/data/david_coinfection_strata_hospitalization.rda")
