#install.packages(c("REDCapR", "mlr"))
#install.packages(c("dummies"))
library(dplyr)
library(plyr)
library(redcapAPI)
library(REDCapR)

setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long")
Redcap.token <- readLines("Redcap.token.R01.txt") # Read API token from folder
REDcap.URL  <- 'https://redcap.stanford.edu/api/'
rcon <- redcapConnection(url=REDcap.URL, token=Redcap.token)

#export data from redcap to R (must be connected via cisco VPN)
#R01_lab_results <- redcap_read(redcap_uri  = REDcap.URL, token = Redcap.token, batch_size = 300)$data
#R01_lab_results.backup<-R01_lab_results
#save(R01_lab_results.backup,file="R01_lab_results.backup.rda")
load("R01_lab_results.backup.rda")
R01_lab_results<-R01_lab_results.backup


R01_lab_results<- R01_lab_results[which(!is.na(R01_lab_results$redcap_event_name))  , ]

R01_lab_results$id_cohort<-substr(R01_lab_results$person_id, 2, 2)
R01_lab_results$id_city<-substr(R01_lab_results$person_id, 1, 1)

n_distinct(R01_lab_results$person_id)
table(aic_dummy_symptoms$id_cohort, aic_dummy_symptoms$redcap_event_name, exclude = NULL)

table(aic_dummy_symptoms$id_cohort, exclude = NULL)
table(aic_dummy_symptoms$redcap_event_name, exclude = NULL)


R01_lab_results$id_visit<-as.integer(factor(R01_lab_results$redcap_event_name))
R01_lab_results$id_visit<-R01_lab_results$id_visit-1
symptoms <- R01_lab_results[, grepl("person_id|redcap_event|chikv_stfd_igg|chikv_kenya_igg|denv_kenya_igg|denv_stfd_igg|symptoms|id_c|id_v|visit_type", names(R01_lab_results))]
symptoms <- symptoms[, !grepl("u24|aliquot", names( symptoms ) ) ]

#subset symptoms
symptoms<-R01_lab_results[which(R01_lab_results$id_visit > 0), c("person_id", "redcap_event_name","symptoms", "symptoms_aic", "id_cohort", "id_city", "id_visit", "visit_type")]
symptoms<-as.data.frame(symptoms)
symptoms$all_symptoms<-paste(symptoms$symptoms, symptoms$symptoms_aic , sep=" ")
    symptoms <- lapply(symptoms, function(x) {
      gsub(",NA", "", x)
    })
    symptoms <- lapply(symptoms, function(x) {
      gsub("NA", "", x)
    })
    symptoms <- lapply(symptoms, function(x) {
      gsub(",none", "", x)
    })
    symptoms <- lapply(symptoms, function(x) {
      gsub("none", "", x)
    })
    symptoms<-as.data.frame(symptoms)
    
    #create dummy vars for all symptoms
        symptoms<-as.data.frame(symptoms)
        #symptoms <-symptoms[!(is.na(symptoms$all_symptoms) | symptoms$all_symptoms==" "), ]
        lev <- levels(factor(symptoms$all_symptoms))
        lev <- unique(unlist(strsplit(lev, " ")))
        mnames <- gsub(" ", "_", paste("aic_symptom", lev, sep = "_"))
        result <- matrix(data = "0", nrow = length(symptoms$all_symptoms), ncol = length(lev))
        char.aic_symptom <- as.character(symptoms$all_symptoms)
        for (i in 1:length(lev)) {
          result[grep(lev[i], char.aic_symptom, fixed = TRUE), i] <- "1"
        }
        result <- data.frame(result, stringsAsFactors = TRUE)
        colnames(result) <- mnames
        symptoms <- cbind(symptoms,result)
        
        as.numeric.factor <- function(x) {as.numeric(levels(x))[x]}
        ids <- c("person_id", "redcap_event_name", "symptoms", "symptoms_aic", "id_cohort", "id_city", "id_visit", "all_symptoms", "visit_type")
        ids <- symptoms[ids]
        symptoms<-symptoms[ , !(names(symptoms) %in% "aic_symptom_")]
        aic_symptom_<-grep("aic_symptom_", names(symptoms), value = TRUE)
        symptoms<-symptoms[ , (names(symptoms) %in% aic_symptom_)]
        symptoms <-as.data.frame(sapply(symptoms, as.numeric.factor))
        
        symptom_sum<-rowSums(symptoms[, grep("\\baic_symptom", names(symptoms))])
        symptoms<-symptoms[ , grepl( "aic_symptom" , names(symptoms) ) ]
        symptoms$symptom_sum <- as.integer(rowSums(symptoms[ , grep("aic_symptom" , names(symptoms))]))
        table(symptoms$symptom_sum, exclude=NULL)
        symptoms$symptomatic<-NA
        symptoms <- within(symptoms, symptomatic[symptoms$symptom_sum>0] <- 1)
        symptoms <- within(symptoms, symptomatic[symptoms$symptom_sum==0] <- 0)
        
#how much of our acute DENV was symptomatic vs. mildly/asymptomatic, etc.
  table(symptoms$symptomatic, exclude=NULL)
#export to box.
symptoms<-as.data.frame(cbind(ids, symptoms))


table(symptoms$symptomatic, symptoms$redcap_event_name, symptoms$id_cohort, exclude=NULL)
table(symptoms$symptomatic, symptoms$visit_type, symptoms$id_cohort, exclude=NULL)
table(symptoms$symptomatic, symptoms$visit_type, symptoms$id_cohort, exclude=NULL)

aic_symptoms<-subset(symptoms, id_cohort!="C")

#tested
      tested<-R01_lab_results[, grepl("person_id|redcap_event|tested_", names(R01_lab_results))]
      tested<-tested[, !grepl("date", names(tested))]
      
      tested<-tested[which(tested$redcap_event_name=="patient_informatio_arm_1"),]
      colnames(tested)<-sub("tested_*","", colnames(tested))    
      colnames(tested)<-sub("*_2","", colnames(tested))    
      #order
    tested<-tested[,order(colnames(tested))]
    
    tested<-tested[order(-(grepl('gh_$', names(tested)))+1L)]
    tested<-tested[order(-(grepl('fg_$', names(tested)))+1L)]
    tested<-tested[order(-(grepl('ef_$', names(tested)))+1L)]
    tested<-tested[order(-(grepl('de_$', names(tested)))+1L)]
    tested<-tested[order(-(grepl('cd_$', names(tested)))+1L)]
    tested<-tested[order(-(grepl('bc_$', names(tested)))+1L)]
    tested<-tested[order(-(grepl('ab_$', names(tested)))+1L)]
    
    nameVec <- names(tested)
    v.names=c('chikv_kenya_igg', 'chikv_stfd_igg', 'denv_kenya_igg', 'denv_stfd_igg')
    times = c("ab_", "bc_", "cd_", "de_", "ef_", "fg_", "gh_")    
    tested_long<-reshape(tested, idvar = "person_id", varying = 1:28,  direction = "long", timevar = "visit", times=times, v.names=v.names)
    tested_long <- within(tested_long, visit[visit=="ab_"] <- "visit_a_arm_1")
    tested_long <- within(tested_long, visit[visit=="bc_"] <- "visit_b_arm_1")
    tested_long <- within(tested_long, visit[visit=="cd_"] <- "visit_c_arm_1")
    tested_long <- within(tested_long, visit[visit=="de_"] <- "visit_d_arm_1")
    tested_long <- within(tested_long, visit[visit=="ef_"] <- "visit_e_arm_1")
    tested_long <- within(tested_long, visit[visit=="fg_"] <- "visit_f_arm_1")
    tested_long <- within(tested_long, visit[visit=="gh_"] <- "visit_g_arm_1")
    tested_long$redcap_event_name<-tested_long$visit
    names(tested_long)[names(tested_long) == 'denv_kenya_igg'] <- 'tested_denv_kenya_igg'
    names(tested_long)[names(tested_long) == 'chikv_kenya_igg'] <- 'tested_chikv_kenya_igg'
    names(tested_long)[names(tested_long) == 'denv_stfd_igg'] <- 'tested_denv_stfd_igg'
    names(tested_long)[names(tested_long) == 'chikv_stfd_igg'] <- 'tested_chikv_stfd_igg'
    
    head(tested_long)
    
    
#seroconversion
seroconverter<-R01_lab_results[, grepl("person_id|redcap_event|ab_|bc_|cd_|de_|ef_|fg_|gh_", names(R01_lab_results))]
    seroconverter<-seroconverter[which(seroconverter$redcap_event_name=="patient_informatio_arm_1"),]
    
    #order
      seroconverter<-seroconverter[,order(colnames(seroconverter))]
        
      seroconverter<-seroconverter[order(-(grepl('gh_$', names(seroconverter)))+1L)]
      seroconverter<-seroconverter[order(-(grepl('fg_$', names(seroconverter)))+1L)]
      seroconverter<-seroconverter[order(-(grepl('ef_$', names(seroconverter)))+1L)]
      seroconverter<-seroconverter[order(-(grepl('de_$', names(seroconverter)))+1L)]
      seroconverter<-seroconverter[order(-(grepl('cd_$', names(seroconverter)))+1L)]
      seroconverter<-seroconverter[order(-(grepl('bc_$', names(seroconverter)))+1L)]
      seroconverter<-seroconverter[order(-(grepl('ab_$', names(seroconverter)))+1L)]
  
    nameVec <- names(seroconverter)
    v.names=c('chikv_kenya_igg', 'chikv_stfd_igg', 'denv_kenya_igg', 'denv_stfd_igg')
    times = c("ab_", "bc_", "cd_", "de_", "ef_", "fg_", "gh_")    
    seroconverter_long<-reshape(seroconverter, idvar = "person_id", varying = 1:28,  direction = "long", timevar = "visit", times=times, v.names=v.names)
    seroconverter_long <- within(seroconverter_long, visit[visit=="ab_"] <- "visit_a_arm_1")
    seroconverter_long <- within(seroconverter_long, visit[visit=="bc_"] <- "visit_b_arm_1")
    seroconverter_long <- within(seroconverter_long, visit[visit=="cd_"] <- "visit_c_arm_1")
    seroconverter_long <- within(seroconverter_long, visit[visit=="de_"] <- "visit_d_arm_1")
    seroconverter_long <- within(seroconverter_long, visit[visit=="ef_"] <- "visit_e_arm_1")
    seroconverter_long <- within(seroconverter_long, visit[visit=="fg_"] <- "visit_f_arm_1")
    seroconverter_long <- within(seroconverter_long, visit[visit=="gh_"] <- "visit_g_arm_1")
    seroconverter_long$redcap_event_name<-seroconverter_long$visit
    names(seroconverter_long)[names(seroconverter_long) == 'denv_kenya_igg'] <- 'seroc_denv_kenya_igg'
    names(seroconverter_long)[names(seroconverter_long) == 'chikv_kenya_igg'] <- 'seroc_chikv_kenya_igg'
    names(seroconverter_long)[names(seroconverter_long) == 'denv_stfd_igg'] <- 'seroc_denv_stfd_igg'
    names(seroconverter_long)[names(seroconverter_long) == 'chikv_stfd_igg'] <- 'seroc_chikv_stfd_igg'
    
    head(seroconverter_long)

#merge symptoms to redcap data
  aic_dummy_symptoms <- merge(seroconverter_long, aic_symptoms,  by=c("person_id", "redcap_event_name"), all = TRUE)
  aic_dummy_symptoms<-aic_dummy_symptoms[, grepl("person_id|redcap|visit|symptom|seroc|temp", names(aic_dummy_symptoms))]
#merge pcr results
  pcr<-R01_lab_results[, grepl("person_id|redcap_event_name|result_pcr", names(R01_lab_results))]
  aic_dummy_symptoms <- merge(pcr, aic_dummy_symptoms,  by=c("person_id", "redcap_event_name"), all = TRUE)
#merge tested samples 
  aic_dummy_symptoms <- merge(tested_long, aic_dummy_symptoms,  by=c("person_id", "redcap_event_name"), all = TRUE)
#merge prevalence
  prevalence<-R01_lab_results[, grepl("person_id|redcap_event_name|prev_", names(R01_lab_results))]
  aic_dummy_symptoms <- merge(prevalence, aic_dummy_symptoms,  by=c("person_id", "redcap_event_name"), all = TRUE)
  
  aic_dummy_symptoms <- within(aic_dummy_symptoms, prev_chikv_igg_stfd_all_pcr[prev_chikv_igg_stfd_all_pcr>0] <- 1)
  aic_dummy_symptoms <- within(aic_dummy_symptoms, prev_denv_igg_stfd_all_pcr[prev_denv_igg_stfd_all_pcr>0] <- 1)
#merge malaria results
  malaria<-R01_lab_results[, grepl("person_id|redcap_event_name|malaria", names(R01_lab_results))]
  aic_dummy_symptoms <- merge(malaria, aic_dummy_symptoms,  by=c("person_id", "redcap_event_name"), all = TRUE)
#merge demographics
  demographics<-R01_lab_results[, grepl("person_id|redcap_event_name|gender|age|temp|hospital|heart|rdt", names(R01_lab_results))]
  aic_dummy_symptoms <- merge(demographics, aic_dummy_symptoms,  by=c("person_id", "redcap_event_name"), all = TRUE)
  summary(R01_lab_results$heart_rate)
  summary(aic_dummy_symptoms$heart_rate)
  
  table(aic_dummy_symptoms$microscopy_malaria_pf_kenya___1)
  table(aic_dummy_symptoms$prev_chikv_igg_stfd_all_pcr)
  table(aic_dummy_symptoms$prev_denv_igg_stfd_all_pcr)


#double check to de-identify data
  #take name out of event.
    names(aic_dummy_symptoms)[names(aic_dummy_symptoms) == 'redcap_event_name'] <- 'redcap_event'
  identifiers<-grep("name|gps", names(aic_dummy_symptoms), value = TRUE)
  aic_dummy_symptoms<-aic_dummy_symptoms[ , !(names(aic_dummy_symptoms) %in% identifiers)]
  
#export to csv
  #setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long")
  #f <- "aic_dummy_symptoms_de_identified.csv"
  #write.csv(as.data.frame(aic_dummy_symptoms), f )

#analysis
  attach(aic_dummy_symptoms)
  table(aic_dummy_symptoms$seroc_denv_kenya_igg, aic_dummy_symptoms$seroc_denv_stfd_igg, exclude=NULL)
  
  aic_dummy_symptoms$id_cohort<-substr(aic_dummy_symptoms$person_id, 2, 2)
  aic_dummy_symptoms$aic_dummy_symptoms<-substr(aic_dummy_symptoms$person_id, 1, 1)
  
  n_distinct(aic_dummy_symptoms$person_id)
  table(R01_lab_results$cohort)
  table(R01_lab_results$id_cohort, R01_lab_results$redcap_event_name )
  5204+3918
  5188+16+13 +3918

#use tested = 1 as the zero for infection.
#kenya denv igg seroconverters or PCR positives as infected.
  aic_dummy_symptoms$infected_denv_kenya[aic_dummy_symptoms$tested_denv_kenya_igg ==1 | aic_dummy_symptoms$result_pcr_denv_kenya==0|aic_dummy_symptoms$result_pcr_denv_stfd==0]<-0
  aic_dummy_symptoms$infected_denv_kenya[aic_dummy_symptoms$seroc_denv_kenya_igg==1|aic_dummy_symptoms$result_pcr_denv_kenya==1|aic_dummy_symptoms$result_pcr_denv_stfd==1]<-1
  table(aic_dummy_symptoms$infected_denv_kenya)  
#kenya chikv igg seroconverters or PCR positives as infected.
  aic_dummy_symptoms$infected_chikv_kenya[aic_dummy_symptoms$tested_chikv_kenya_igg ==1 |aic_dummy_symptoms$result_pcr_chikv_kenya==0]<-0
  aic_dummy_symptoms$infected_chikv_kenya[aic_dummy_symptoms$seroc_chikv_kenya_igg==1|aic_dummy_symptoms$result_pcr_chikv_kenya==1]<-1
  table(aic_dummy_symptoms$infected_chikv_kenya)  
  
#stfd denv igg seroconverters or PCR positives as infected.
  aic_dummy_symptoms$infected_denv_stfd[aic_dummy_symptoms$tested_denv_stfd_igg ==1 |aic_dummy_symptoms$result_pcr_denv_kenya==0|aic_dummy_symptoms$result_pcr_denv_stfd==0]<-0
  aic_dummy_symptoms$infected_denv_stfd[aic_dummy_symptoms$seroc_denv_stfd_igg==1|aic_dummy_symptoms$result_pcr_denv_kenya==1|aic_dummy_symptoms$result_pcr_denv_stfd==1]<-1
  table(aic_dummy_symptoms$infected_denv_stfd)  
#stfd chikv igg seroconverters or PCR positives as infected.
  aic_dummy_symptoms$infected_chikv_stfd[aic_dummy_symptoms$tested_chikv_stfd_igg ==1 |aic_dummy_symptoms$result_pcr_chikv_kenya==0]<-0
  aic_dummy_symptoms$infected_chikv_stfd[aic_dummy_symptoms$seroc_chikv_stfd_igg==1|aic_dummy_symptoms$result_pcr_chikv_kenya==1]<-1
  table(aic_dummy_symptoms$infected_chikv_stfd)  

#stanford infected denv aic
  #symptom sum histogram for aic
  infected_pcr_denv_stfd_igg<-aic_dummy_symptoms[which(aic_dummy_symptoms$infected_denv_stfd==1),]
  tiff(file = "AIC DENV Infected (Stanford IgG, all PCR).tiff", width = 3200, height = 3200, units = "px", res = 800)
  hist(infected_pcr_denv_stfd_igg$symptom_sum, breaks=50, main = "AIC DENV Infected (Stanford IgG, all PCR)", xlab = "Number of Symptoms Reported at acute", freq=TRUE)
  dev.off()
  #cohort
  infected_pcr_denv_stfd_igg$id_cohort<-substr(infected_pcr_denv_stfd_igg$person_id, 2, 2)
  table(infected_pcr_denv_stfd_igg$id_cohort , exclude = NULL)
  #symptomatic aic
  table(aic_dummy_symptoms$symptomatic, aic_dummy_symptoms$infected_denv_stfd)
  

#kenya infected denv aic
  #symptom sum for aic
  infected_pcr_denv_kenya_igg<-aic_dummy_symptoms[which(aic_dummy_symptoms$infected_denv_kenya==1),]
  tiff(file = "AIC DENV Infected (Kenya IgG, all PCR).tiff", width = 3200, height = 3200, units = "px", res = 800)
  hist(infected_pcr_denv_kenya_igg$symptom_sum, breaks=50, main = "AIC DENV Infected (Kenya IgG, all PCR)", xlab = "Number of Symptoms Reported at acute", freq=TRUE)
  dev.off()
  #cohort
  infected_pcr_denv_kenya_igg$id_cohort<-substr(infected_pcr_denv_kenya_igg$person_id, 2, 2)
  table(infected_pcr_denv_kenya_igg$id_cohort , exclude = NULL)
  #symptomatic for aic
  table(aic_dummy_symptoms$symptomatic, aic_dummy_symptoms$infected_denv_kenya)
  
#stanford infected chikv aic
  #symptom sum histogram for aic
  infected_pcr_chikv_stfd_igg<-aic_dummy_symptoms[which(aic_dummy_symptoms$infected_chikv_stfd==1),]
  tiff(file = "AIC chikv Infected (Stanford IgG, all PCR).tiff", width = 3200, height = 3200, units = "px", res = 800)
  hist(infected_pcr_chikv_stfd_igg$symptom_sum, breaks=50, main = "AIC chikv Infected (Stanford IgG, all PCR)", xlab = "Number of Symptoms Reported at acute", freq=TRUE)
  dev.off()
  #cohort
  infected_pcr_chikv_stfd_igg$id_cohort<-substr(infected_pcr_chikv_stfd_igg$person_id, 2, 2)
  table(infected_pcr_chikv_stfd_igg$id_cohort , exclude = NULL)
  #symptomatic aic
  table(aic_dummy_symptoms$symptomatic, aic_dummy_symptoms$infected_chikv_stfd)
  
  
#kenya infected chikv aic
  #symptom sum for aic
  infected_pcr_chikv_kenya_igg<-aic_dummy_symptoms[which(aic_dummy_symptoms$infected_chikv_kenya==1),]

  tiff(file = "AIC chikv Infected (Kenya IgG, all PCR).tiff", width = 3200, height = 3200, units = "px", res = 800)
  hist(infected_pcr_chikv_kenya_igg$symptom_sum, breaks=50, main = "AIC chikv Infected (Kenya IgG, all PCR)", xlab = "Number of Symptoms Reported at acute", freq=TRUE)
  dev.off()
  
  #cohort
  infected_pcr_chikv_kenya_igg$id_cohort<-substr(infected_pcr_chikv_kenya_igg$person_id, 2, 2)
  table(infected_pcr_chikv_kenya_igg$id_cohort , exclude = NULL)
  #symptomatic for aic
  table(aic_dummy_symptoms$symptomatic, aic_dummy_symptoms$infected_chikv_kenya)
#save file
  save(aic_dummy_symptoms,file="aic_dummy_symptoms.rda")
  
##survival analysis
  #devtools::install_github("sachsmc/ggkm", force=TRUE)
  library(ggkm)
  load("aic_dummy_symptoms.rda")
  
  
  aic_dummy_symptoms$visit<- as.numeric(as.factor(aic_dummy_symptoms$redcap_event))
  aic_dummy_symptoms$visit<-aic_dummy_symptoms$visit-1
  aic_dummy_symptoms <- within(aic_dummy_symptoms, visit[visit==8] <- NA)
  aic_dummy_symptoms <- within(aic_dummy_symptoms, visit[visit==9] <- NA)
  table(aic_dummy_symptoms$visit)  

  ggplot(aic_dummy_symptoms, aes(time = visit, status = infected_chikv_kenya, color = factor(symptomatic))) + geom_km()
  ggplot(aic_dummy_symptoms, aes(time = visit, status = infected_denv_kenya, color = factor(symptomatic))) + geom_km()
  ggplot(aic_dummy_symptoms, aes(time = visit, status = infected_chikv_stfd, color = factor(symptomatic))) + geom_km()
  ggplot(aic_dummy_symptoms, aes(time = visit, status = infected_denv_stfd,  color = factor(symptomatic))) + geom_km()
  
  survival_infected_chikv_kenya <- survfit(Surv(visit, infected_chikv_kenya)~symptomatic, data=aic_dummy_symptoms)
  survival_infected_denv_kenya <- survfit(Surv(visit, infected_denv_kenya)~symptomatic, data=aic_dummy_symptoms)
  survival_infected_chikv_stfd <- survfit(Surv(visit, infected_chikv_stfd)~symptomatic, data=aic_dummy_symptoms)
  survival_infected_denv_stfd <- survfit(Surv(visit, infected_denv_stfd)~symptomatic, data=aic_dummy_symptoms)
#incidence by year
  library("zoo")
  library("lubridate")
  library(tidyr)
  load("R01_lab_results.backup.rda")
  R01_lab_results<-R01_lab_results.backup
  interview_dates<-R01_lab_results[, grepl("person_id|redcap_event_name|date", names(R01_lab_results))]
interview_dates<-interview_dates[,order(colnames(interview_dates))]
interview_dates[is.na(interview_dates)] = ''
date<-unite(interview_dates, int_date, interview_date:interview_date_aic, sep='')
date<-date[which(date$redcap_event_name!="patient_informatio_arm_1"),]
interview_dates<- merge(interview_dates, date,  by=c("person_id", "redcap_event_name"), all = TRUE)
    #dates
      interview_dates$int_date_2 <-ymd(interview_dates$int_date)
      table(interview_dates$int_date_2)
      #table(interview_dates$int_date)
      interview_dates$month_year <- as.yearmon(interview_dates$int_date_2)
      interview_dates$year <- year(as.Date(interview_dates$int_date_2, origin = '1900-1-1'))
      #table(interview_dates$month_year, exclude = NULL)
    #merge
      names(interview_dates)[names(interview_dates) == 'redcap_event_name'] <- 'redcap_event'
      aic_dummy_symptoms <- merge(interview_dates, aic_dummy_symptoms,  by=c("person_id", "redcap_event"), all = TRUE)
      aic_dummy_symptoms$id_cohort<-substr(aic_dummy_symptoms$person_id, 2, 2)
      
#infected by month
  table(aic_dummy_symptoms$infected_denv_kenya, aic_dummy_symptoms$month_year, exclude =NULL)
  table(aic_dummy_symptoms$infected_chikv_kenya, aic_dummy_symptoms$month_year, exclude =NULL)
  table(aic_dummy_symptoms$infected_denv_stfd, aic_dummy_symptoms$month_year, exclude =NULL)
  table(aic_dummy_symptoms$infected_chikv_stfd, aic_dummy_symptoms$month_year, exclude =NULL)
#infected by year
  aic_dummy_symptoms$id_city<-substr(aic_dummy_symptoms$person_id, 1, 1)
  aic_dummy_symptoms_df=as.data.frame(aic_dummy_symptoms)
#site
  aic_dummy_symptoms_df$site<-NA

  table(aic_dummy_symptoms$id_city)
  aic_dummy_symptoms_df <- within(aic_dummy_symptoms_df, site[aic_dummy_symptoms_df$id_city=="G"] <- "C")
  aic_dummy_symptoms_df <- within(aic_dummy_symptoms_df, site[aic_dummy_symptoms_df$id_city=="U"] <- "C")
  aic_dummy_symptoms_df <- within(aic_dummy_symptoms_df, site[aic_dummy_symptoms_df$id_city=="L"] <- "C")
  aic_dummy_symptoms_df <- within(aic_dummy_symptoms_df, site[aic_dummy_symptoms_df$id_city=="M"] <- "C")

  aic_dummy_symptoms_df <- within(aic_dummy_symptoms_df, site[aic_dummy_symptoms_df$id_city=="C"] <- "W")
  aic_dummy_symptoms_df <- within(aic_dummy_symptoms_df, site[aic_dummy_symptoms_df$id_city=="R"] <- "W")
  aic_dummy_symptoms_df <- within(aic_dummy_symptoms_df, site[aic_dummy_symptoms_df$id_city=="K"] <- "W")
##rural
  aic_dummy_symptoms_df$rural<-NA
  aic_dummy_symptoms_df <- within(aic_dummy_symptoms_df, rural[aic_dummy_symptoms_df$id_city=="G"] <- 1)
  aic_dummy_symptoms_df <- within(aic_dummy_symptoms_df, rural[aic_dummy_symptoms_df$id_city=="U"] <- 0)
  aic_dummy_symptoms_df <- within(aic_dummy_symptoms_df, rural[aic_dummy_symptoms_df$id_city=="L"] <- 1)
  aic_dummy_symptoms_df <- within(aic_dummy_symptoms_df, rural[aic_dummy_symptoms_df$id_city=="M"] <- 1)
  
  aic_dummy_symptoms_df <- within(aic_dummy_symptoms_df, rural[aic_dummy_symptoms_df$id_city=="C"] <- 1)
  aic_dummy_symptoms_df <- within(aic_dummy_symptoms_df, rural[aic_dummy_symptoms_df$id_city=="R"] <- 1)
  aic_dummy_symptoms_df <- within(aic_dummy_symptoms_df, rural[aic_dummy_symptoms_df$id_city=="K"] <- 0)

#cohort
  aic_dummy_symptoms_df <- within(aic_dummy_symptoms_df, id_cohort[aic_dummy_symptoms_df$id_cohort=="M"] <- "F")

    aic_dummy_symptoms<-aic_dummy_symptoms_df
  table(aic_dummy_symptoms_df$rural, exclude = NULL)
#seroprevalence
  #denv
  table(aic_dummy_symptoms$denv_prevalence)
  table(aic_dummy_symptoms$chikv_prevalence)
  #extract first event
  #infected_denv_kenya
  table(aic_dummy_symptoms$infected_denv_kenya, aic_dummy_symptoms$year, exclude = NULL)
  Ranks <- with(aic_dummy_symptoms, ave(infected_denv_kenya, person_id, infected_denv_kenya, FUN = function(x) 
      rank(x, ties.method="first")))
    infected_denv_kenya<-  aic_dummy_symptoms[Ranks == 1, ]

  #infected_chikv_kenya
    table(aic_dummy_symptoms$infected_chikv_kenya, aic_dummy_symptoms$year, exclude = NULL)
    Ranks <- with(aic_dummy_symptoms, ave(infected_chikv_kenya, person_id, infected_chikv_kenya, FUN = function(x) 
      rank(x, ties.method="first")))
    infected_chikv_kenya<-  aic_dummy_symptoms[Ranks == 1, ]
    table(infected_chikv_kenya$infected_chikv_kenya,  exclude = NULL)

  #infected_denv_stfd
    table(aic_dummy_symptoms$infected_denv_stfd, aic_dummy_symptoms$year, exclude = NULL)
      Ranks <- with(aic_dummy_symptoms, ave(infected_denv_stfd, person_id, infected_denv_stfd, FUN = function(x) 
      rank(x, ties.method="first")))
    infected_denv_stfd<-  aic_dummy_symptoms[Ranks == 1, ]
    table(infected_denv_stfd$infected_denv_stfd,  exclude = NULL)

  library(tableone)
  ## Create Table 1 stratified by infection 
  vars <- c("infected_denv_stfd", "site", "id_city", "id_cohort", "year", "rural")
  factorVars <- c("infected_denv_stfd", "site", "id_city", "id_cohort", "year", "rural")
  infected_denv_stfd_hcc<-infected_denv_stfd[infected_denv_stfd$id_cohort =="C", ]
  infected_denv_stfd_aic<-infected_denv_stfd[infected_denv_stfd$id_cohort =="F", ]
  tableOne <- CreateTableOne(vars = vars, factorVars = factorVars, strata = "infected_denv_stfd", data = infected_denv_stfd_hcc)
  print(tableOne, quote = TRUE)
  tableOne <- CreateTableOne(vars = vars, factorVars = factorVars, strata = "infected_denv_stfd", data = infected_denv_stfd_aic)
  print(tableOne, quote = TRUE)
  
  #infected_chikv_stfd
    table(aic_dummy_symptoms$infected_chikv_stfd, aic_dummy_symptoms$year, exclude = NULL)
    Ranks <- with(aic_dummy_symptoms, ave(infected_chikv_stfd, person_id, infected_chikv_stfd, FUN = function(x) 
      rank(x, ties.method="first")))
    infected_chikv_stfd<-  aic_dummy_symptoms[Ranks == 1, ]
    table(infected_chikv_stfd$infected_chikv_stfd,  exclude = NULL)
    table(infected_chikv_stfd$infected_chikv_stfd, infected_chikv_stfd$year,  exclude = NULL)
    table(infected_chikv_stfd$infected_chikv_stfd, infected_chikv_stfd$id_cohort,  exclude = NULL)
    table(infected_chikv_stfd$infected_chikv_stfd, infected_chikv_stfd$site,  exclude = NULL)
#table one
  #incidence
    vars <- c("infected_chikv_stfd", "site", "id_city", "id_cohort")
    factorVars <- c("infected_chikv_stfd", "site", "id_city", "id_cohort")
    infected_chikv_stfd_hcc<-infected_chikv_stfd[infected_chikv_stfd$id_cohort =="C", ]
    infected_chikv_stfd_aic<-infected_chikv_stfd[infected_chikv_stfd$id_cohort =="F", ]
    tableOne <- CreateTableOne(vars = vars, factorVars = factorVars, strata = "infected_chikv_stfd", data = infected_chikv_stfd_hcc)
    print(tableOne, quote = TRUE)
    tableOne <- CreateTableOne(vars = vars, factorVars = factorVars, strata = "infected_chikv_stfd", data = infected_chikv_stfd_aic)
    print(tableOne, quote = TRUE)
  #prevalence chikv
    vars <- c("prev_chikv_igg_stfd_all_pcr", "site", "rural", "id_cohort")
    factorVars <- c("prev_chikv_igg_stfd_all_pcr", "site", "rural", "id_cohort")
    infected_chikv_stfd_hcc<-aic_dummy_symptoms[aic_dummy_symptoms$id_cohort =="C", ]
    infected_chikv_stfd_aic<-aic_dummy_symptoms[aic_dummy_symptoms$id_cohort =="F", ]
    tableOne <- CreateTableOne(vars = vars, factorVars = factorVars, strata = "prev_chikv_igg_stfd_all_pcr", data = aic_dummy_symptoms)
    print(tableOne, quote = TRUE)
    tableOne <- CreateTableOne(vars = vars, factorVars = factorVars, strata = "prev_chikv_igg_stfd_all_pcr", data = aic_dummy_symptoms)
    print(tableOne, quote = TRUE)
  #prevalence denv
    vars <- c("prev_denv_igg_stfd_all_pcr", "site", "rural", "id_cohort")
    factorVars <- c("prev_denv_igg_stfd_all_pcr", "site", "rural", "id_cohort")
    infected_denv_stfd_hcc<-aic_dummy_symptoms[aic_dummy_symptoms$id_cohort =="C", ]
    infected_denv_stfd_aic<-aic_dummy_symptoms[aic_dummy_symptoms$id_cohort =="F", ]
    tableOne <- CreateTableOne(vars = vars, factorVars = factorVars, strata = "prev_denv_igg_stfd_all_pcr", data = aic_dummy_symptoms)
    print(tableOne, quote = TRUE)
    tableOne <- CreateTableOne(vars = vars, factorVars = factorVars, strata = "prev_denv_igg_stfd_all_pcr", data = aic_dummy_symptoms)
    print(tableOne, quote = TRUE)
    
    
        
    #export to csv
    setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long")
    f <- "redcap_data_cleaned.csv"
    write.csv(as.data.frame(aic_dummy_symptoms), f )
    #save as r data frame for use in other analysis. 
    save(aic_dummy_symptoms,file="aic_dummy_symptoms.clean.rda")
    
#missing dates export
  missing_date<-aic_dummy_symptoms[which((aic_dummy_symptoms$infected_denv_stfd!="" & is.na(aic_dummy_symptoms$year)) | (aic_dummy_symptoms$infected_chikv_stfd!="" & is.na(aic_dummy_symptoms$year))) , ]
  #export to csv
      setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long")
      f <- "missing_date.csv"
      write.csv(as.data.frame(missing_date), f )
    
  infected_pcr_denv_stfd_igg<-aic_dummy_symptoms[which(aic_dummy_symptoms$infected_denv_stfd==1),]
  
  #survival with time.
    aic_dummy_symptoms$month_year_date<-as.numeric(as.Date(aic_dummy_symptoms$month_year))-16071
    surv_month_infected_denv_stfd <- survfit(Surv(month_year_date, infected_denv_stfd)~symptomatic, data=aic_dummy_symptoms)
    ggplot(aic_dummy_symptoms, aes(time = month_year_date, status = infected_denv_stfd,  color = factor(symptomatic))) + geom_km()
    table(aic_dummy_symptoms$month_year_date)

        aic_dummy_symptoms$age = aic_dummy_symptoms$age_calc  # your new merged column start with x
        aic_dummy_symptoms$age[!is.na(aic_dummy_symptoms$aic_calculated_age)] = aic_dummy_symptoms$aic_calculated_age[!is.na(aic_dummy_symptoms$aic_calculated_age)]  # merge with y
        aic_dummy_symptoms$age<-round(aic_dummy_symptoms$age)
        
        table(aic_dummy_symptoms$infected_denv_stfd, aic_dummy_symptoms$age , exclude = NULL)
        table(aic_dummy_symptoms$infected_chikv_stfd, aic_dummy_symptoms$age , exclude = NULL)
        
        aic_dummy_symptoms$age_group<-NA
        aic_dummy_symptoms <- within(aic_dummy_symptoms, age_group[age<=5] <- 1)
        aic_dummy_symptoms <- within(aic_dummy_symptoms, age_group[age>5 & age<=10] <- 2)
        aic_dummy_symptoms <- within(aic_dummy_symptoms, age_group[age>10 & age<=15] <- 3)
        aic_dummy_symptoms <- within(aic_dummy_symptoms, age_group[age>15] <- 4)
        table(aic_dummy_symptoms$age_group, exclude = NULL)
        
        table(aic_dummy_symptoms$infected_denv_stfd, aic_dummy_symptoms$age_group, exclude = NULL)
        table(aic_dummy_symptoms$infected_chikv_stfd, aic_dummy_symptoms$age_group , exclude = NULL)
