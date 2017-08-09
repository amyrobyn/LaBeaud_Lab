#install.packages(c("REDCapR", "mlr"))
#install.packages(c("dummies"))
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

R01_lab_results$id_cohort<-substr(R01_lab_results$person_id, 2, 2)
R01_lab_results$id_city<-substr(R01_lab_results$person_id, 1, 1)
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
        symptoms$symptomatic<-NA
        symptoms <- within(symptoms, symptomatic[symptoms$symptom_sum>0] <- 1)
        symptoms <- within(symptoms, symptomatic[symptoms$symptom_sum==0] <- 0)
        
#how much of our acute DENV was symptomatic vs. mildly/asymptomatic, etc.
  table(symptoms$symptomatic, exclude=NULL)
#export to box.
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/reports")
symptoms<-as.data.frame(cbind(ids, symptoms))

table(symptoms$symptomatic, symptoms$redcap_event_name, symptoms$id_cohort, exclude=NULL)
table(symptoms$symptomatic, symptoms$visit_type, symptoms$id_cohort, exclude=NULL)
table(symptoms$symptomatic, symptoms$visit_type, symptoms$id_cohort, exclude=NULL)

aic_symptoms<-subset(symptoms, id_cohort=="F")
aic_symptoms <-aic_symptoms[!sapply(aic_symptoms, function (x) all(is.na(x) | x == ""))]

#seroconversion
  R01_lab_results<-R01_lab_results.backup
  seroconverter<-R01_lab_results[, grepl("person_id|redcap_event|ab_|bc_|cd_|de_|ef_|fg_|gh_", names(R01_lab_results))]
    seroconverter<-seroconverter[which(seroconverter$redcap_event_name=="patient_informatio_arm_1"),]
    nameVec <- names(seroconverter)
    
    v.names=c('denv_kenya_igg', 'chikv_kenya_igg', 'denv_stfd_igg',  'chikv_stfd_igg')
    times = c("ab_", "bc_", "cd_", "de_", "ef_", "fg_", "gh_")    
    seroconverter_long<-reshape(seroconverter, idvar = "person_id", varying = 3:30,  direction = "long", timevar = "visit", times=times, v.names=v.names)
    seroconverter_long$visit
    seroconverter_long <- within(seroconverter_long, visit[visit=="ab_"] <- "visit_a_arm_1")
    seroconverter_long <- within(seroconverter_long, visit[visit=="bc_"] <- "visit_b_arm_1")
    seroconverter_long <- within(seroconverter_long, visit[visit=="cd_"] <- "visit_d_arm_1")
    seroconverter_long <- within(seroconverter_long, visit[visit=="de_"] <- "visit_d_arm_1")
    seroconverter_long <- within(seroconverter_long, visit[visit=="ef_"] <- "visit_e_arm_1")
    seroconverter_long <- within(seroconverter_long, visit[visit=="fg_"] <- "visit_f_arm_1")
    seroconverter_long <- within(seroconverter_long, visit[visit=="gh_"] <- "visit_g_arm_1")
    seroconverter_long$redcap_event_name<-seroconverter_long$visit
    seroconverter_long<-rename(seroconverter_long, c("denv_kenya_igg" = "seroc_denv_kenya_igg"))
    seroconverter_long<-rename(seroconverter_long, c("chikv_kenya_igg" = "seroc_chikv_kenya_igg"))
    seroconverter_long<-rename(seroconverter_long, c("denv_stfd_igg" = "seroc_denv_stfd_igg"))
    seroconverter_long<-rename(seroconverter_long, c("chikv_stfd_igg" = "seroc_chikv_stfd_igg"))
    head(seroconverter_long)

#merge symptoms to redcap data
  aic_dummy_symptoms <- merge(seroconverter_long, aic_symptoms,  by=c("person_id", "redcap_event_name"), all = TRUE)
  aic_dummy_symptoms <-aic_dummy_symptoms[!sapply(aic_dummy_symptoms, function (x) all(is.na(x) | x == ""))]
  aic_dummy_symptoms<-aic_dummy_symptoms[, grepl("person_id|redcap|visit|symptom|seroc|temp", names(aic_dummy_symptoms))]
#merge pcr results
  pcr<-R01_lab_results[, grepl("person_id|redcap_event_name|result_pcr", names(R01_lab_results))]
  aic_dummy_symptoms <- merge(pcr, aic_dummy_symptoms,  by=c("person_id", "redcap_event_name"), all = TRUE)
  aic_dummy_symptoms <-aic_dummy_symptoms[!sapply(aic_dummy_symptoms, function (x) all(is.na(x) | x == ""))]
  
#double check to de-identify data
  identifiers<-grep("name|gps", names(aic_dummy_symptoms), value = TRUE)
  aic_dummy_symptoms<-aic_dummy_symptoms[ , !(names(aic_dummy_symptoms) %in% identifiers)]
  aic_dummy_symptoms<-rename(aic_dummy_symptoms, c("visit" = "redcap_event_name"))
#export to csv
  setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long")
  f <- "aic_dummy_symptoms_de_identified.csv"
  write.csv(as.data.frame(aic_dummy_symptoms), f )

#analysis
  attach(aic_dummy_symptoms)
  table(aic_dummy_symptoms$seroc_chikv_kenya_igg, seroc_chikv_stfd_igg, exclude=NULL)
  table(aic_dummy_symptoms$seroc_denv_kenya_igg, aic_dummy_symptoms$seroc_denv_stfd_igg, exclude=NULL)

#kenya denv igg seroconverters or PCR positives as infected.
  aic_dummy_symptoms$infected_denv_kenya[aic_dummy_symptoms$seroc_denv_kenya_igg==1|aic_dummy_symptoms$result_pcr_denv_kenya==1|aic_dummy_symptoms$result_pcr_denv_stfd==1]<-1
  table(aic_dummy_symptoms$infected_denv_kenya)  
#kenya chikv igg seroconverters or PCR positives as infected.
  aic_dummy_symptoms$infected_chikv_kenya[aic_dummy_symptoms$seroc_chikv_kenya_igg==1|aic_dummy_symptoms$result_pcr_chikv_kenya==1]<-1
  table(aic_dummy_symptoms$infected_chikv_kenya)  
#stfd denv igg seroconverters or PCR positives as infected.
  aic_dummy_symptoms$infected_denv_stfd[aic_dummy_symptoms$seroc_denv_stfd_igg==1|aic_dummy_symptoms$result_pcr_denv_kenya==1|aic_dummy_symptoms$result_pcr_denv_stfd==1]<-1
  table(aic_dummy_symptoms$infected_denv_stfd)  
#stfd chikv igg seroconverters or PCR positives as infected.
  aic_dummy_symptoms$infected_chikv_stfd[aic_dummy_symptoms$seroc_chikv_stfd_igg==1|aic_dummy_symptoms$result_pcr_chikv_kenya==1]<-1
  table(aic_dummy_symptoms$infected_chikv_stfd)  
  
seroc_chikv_kenya_igg_symptomatic<-table(aic_dummy_symptoms$symptomatic, aic_dummy_symptoms$redcap_event_name, aic_dummy_symptoms$infected_chikv_kenya)
seroc_chikv_kenya_igg_symptom_sum<-table( aic_dummy_symptoms$symptom_sum, aic_dummy_symptoms$redcap_event_name, aic_dummy_symptoms$infected_chikv_kenya)

seroc_denv_kenya_igg_symptomatic<-table( aic_dummy_symptoms$symptomatic, aic_dummy_symptoms$redcap_event_name, aic_dummy_symptoms$infected_denv_kenya)
seroc_denv_kenya_igg_symptom_sum<-table( aic_dummy_symptoms$symptom_sum, aic_dummy_symptoms$redcap_event_name, aic_dummy_symptoms$infected_denv_kenya)

seroc_chikv_stfd_igg_symptomatic<-table( aic_dummy_symptoms$symptomatic, aic_dummy_symptoms$redcap_event_name, aic_dummy_symptoms$infected_chikv_stfd)
seroc_chikv_stfd_igg_symptom_sum<-table( aic_dummy_symptoms$symptom_sum, aic_dummy_symptoms$redcap_event_name, aic_dummy_symptoms$infected_chikv_stfd)

seroc_denv_stfd_igg_symptomatic<-table( aic_dummy_symptoms$symptomatic, aic_dummy_symptoms$redcap_event_name, aic_dummy_symptoms$infected_denv_stfd)
seroc_denv_stfd_igg_symptom_sum<-table( aic_dummy_symptoms$symptom_sum, aic_dummy_symptoms$redcap_event_name, aic_dummy_symptoms$infected_denv_stfd)

hist(seroc_denv_stfd_igg_symptom_sum, breaks=50)
hist(seroc_denv_kenya_igg_symptom_sum, breaks=50)
