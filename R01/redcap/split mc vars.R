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

#double check to de-identify data
  #take name out of event.
    names(aic_dummy_symptoms)[names(aic_dummy_symptoms) == 'redcap_event_name'] <- 'redcap_event'
  identifiers<-grep("name|gps", names(aic_dummy_symptoms), value = TRUE)
  aic_dummy_symptoms<-aic_dummy_symptoms[ , !(names(aic_dummy_symptoms) %in% identifiers)]
  
#export to csv
  setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long")
  f <- "aic_dummy_symptoms_de_identified.csv"
  write.csv(as.data.frame(aic_dummy_symptoms), f )

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
  load("R01_lab_results.backup.rda")
  R01_lab_results<-R01_lab_results.backup
  interview_dates<-R01_lab_results[, grepl("person_id|redcap_event_name|interview_date", names(R01_lab_results))]

    #aic
      interview_dates$interview_date_aic_2 <-ymd(interview_dates$interview_date_aic)
      #table(interview_dates$interview_date_aic_2)
      #table(interview_dates$interview_date_aic)
      interview_dates$month_year_aic <- as.yearmon(interview_dates$interview_date_aic_2)
      interview_dates$year_aic <- year(as.Date(interview_dates$interview_date_aic_2, origin = '1900-1-1'))
      #table(interview_dates$month_year_aic)
    #hcc
      interview_dates$interview_date_2 <- ymd(interview_dates$interview_date)
      #table(interview_dates$interview_date_2)
      interview_dates$month_year_hcc <- as.yearmon(interview_dates$interview_date_2)
      interview_dates$year_hcc <- year(as.Date(interview_dates$interview_date_2, origin = '1900-1-1'))

      #table(interview_dates$month_year_hcc)
    #merge
      names(interview_dates)[names(interview_dates) == 'redcap_event_name'] <- 'redcap_event'
      aic_dummy_symptoms <- merge(interview_dates, aic_dummy_symptoms,  by=c("person_id", "redcap_event"), all = TRUE)
      R01_lab_results$id_cohort<-substr(R01_lab_results$person_id, 2, 2)
      
#infected by month
  table(aic_dummy_symptoms$infected_denv_kenya, aic_dummy_symptoms$month_year_aic)
  table(aic_dummy_symptoms$infected_chikv_kenya, aic_dummy_symptoms$month_year_aic)
  table(aic_dummy_symptoms$infected_denv_stfd, aic_dummy_symptoms$month_year_aic)
  table(aic_dummy_symptoms$infected_chikv_stfd, aic_dummy_symptoms$month_year_aic)
#infected by year
  table(aic_dummy_symptoms$infected_denv_kenya, aic_dummy_symptoms$year_aic)
  table(aic_dummy_symptoms$infected_chikv_kenya, aic_dummy_symptoms$year_aic)
  table(aic_dummy_symptoms$infected_denv_stfd, aic_dummy_symptoms$year_aic)
  table(aic_dummy_symptoms$infected_chikv_stfd, aic_dummy_symptoms$year_aic)
  #survival with time.
  aic_dummy_symptoms$month_year_aic_date<-as.numeric(as.Date(aic_dummy_symptoms$month_year_aic))-16071
  surv_month_infected_denv_stfd <- survfit(Surv(month_year_aic_date, infected_denv_stfd)~symptomatic, data=aic_dummy_symptoms)
  ggplot(aic_dummy_symptoms, aes(time = month_year_aic_date, status = infected_denv_stfd,  color = factor(symptomatic))) + geom_km()
  table(aic_dummy_symptoms$month_year_aic_date)