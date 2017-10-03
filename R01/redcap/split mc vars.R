# packages -----------------------------------------------------------------
#install.packages(c("REDCapR", "mlr"))
#install.packages(c("dummies"))
  library(dplyr)
library(plyr)
library(redcapAPI)
library(REDCapR)

# get data -----------------------------------------------------------------
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long")
Redcap.token <- readLines("Redcap.token.R01.txt") # Read API token from folder
REDcap.URL  <- 'https://redcap.stanford.edu/api/'
rcon <- redcapConnection(url=REDcap.URL, token=Redcap.token)

#export data from redcap to R (must be connected via cisco VPN)
R01_lab_results <- redcap_read(redcap_uri  = REDcap.URL, token = Redcap.token, batch_size = 300)$data
save(R01_lab_results,file="R01_lab_results.backup.rda")
load("R01_lab_results.backup.rda")
R01_lab_results<- R01_lab_results[which(!is.na(R01_lab_results$redcap_event_name))  , ]
table(R01_lab_results$outcome_hospitalized)
table(R01_lab_results$outcome, R01_lab_results$outcome_hospitalized)


# parse the id -----------------------------------------------------------------
R01_lab_results$id_cohort<-substr(R01_lab_results$person_id, 2, 2)
R01_lab_results$id_city<-substr(R01_lab_results$person_id, 1, 1)

n_distinct(R01_lab_results$person_id)
table(R01_lab_results$id_cohort, R01_lab_results$redcap_event_name)

R01_lab_results$id_visit<-as.integer(factor(R01_lab_results$redcap_event_name))
R01_lab_results$id_visit<-R01_lab_results$id_visit-1
# create binary symptom vars -----------------------------------------------------------------
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
symptoms$all_symptoms<-tolower(symptoms$all_symptoms)

symptoms$all_symptoms <- gsub('abdomil_pain', 'abp', symptoms$all_symptoms)
symptoms$all_symptoms <- gsub('abdominal_pa', 'abp', symptoms$all_symptoms)
symptoms$all_symptoms <- gsub('abdomin', 'abp', symptoms$all_symptoms)
symptoms$all_symptoms <- gsub('abdomina', 'abp', symptoms$all_symptoms)
symptoms$all_symptoms <- gsub('abdominal_pai', 'abp', symptoms$all_symptoms)
symptoms$all_symptoms <- gsub('abdominal_p', 'abp', symptoms$all_symptoms)
symptoms$all_symptoms <- gsub('abdo', 'abp', symptoms$all_symptoms)
symptoms$all_symptoms <- gsub('abd', 'abp', symptoms$all_symptoms)
symptoms$all_symptoms <- gsub('abpin', 'abp', symptoms$all_symptoms)
symptoms$all_symptoms <- gsub('abpi', 'abp', symptoms$all_symptoms)
symptoms$all_symptoms <- gsub('abpal_p', 'abp', symptoms$all_symptoms)
symptoms$all_symptoms <- gsub('abpa', 'abp', symptoms$all_symptoms)
symptoms$all_symptoms <- gsub('abp', 'abdominal_pain', symptoms$all_symptoms)

symptoms$all_symptoms <- gsub('chiils', 'chills', symptoms$all_symptoms)
symptoms$all_symptoms <- gsub('diarrh', 'diarrhea', symptoms$all_symptoms)
symptoms$all_symptoms <- gsub('diarrheaea', 'diarrhea', symptoms$all_symptoms)
symptoms$all_symptoms <- gsub('usea', 'nausea', symptoms$all_symptoms)
symptoms$all_symptoms <- gsub('nanausea', 'nausea', symptoms$all_symptoms)
symptoms$all_symptoms <- gsub('ras', 'rash', symptoms$all_symptoms)
symptoms$all_symptoms <- gsub('rashh', 'rash', symptoms$all_symptoms)
symptoms$all_symptoms <- gsub('99', '', symptoms$all_symptoms)
symptoms$all_symptoms <- gsub('none', '', symptoms$all_symptoms)
symptoms$all_symptoms <- gsub("\\<a\\>", '', symptoms$all_symptoms)

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
ids <- c("person_id", "redcap_event_name", "all_symptoms")
ids <- symptoms[ids]
symptoms<-symptoms[ , !(names(symptoms) %in% "aic_symptom_")]
aic_symptom_<-grep("aic_symptom_", names(symptoms), value = TRUE)
symptoms<-symptoms[ , (names(symptoms) %in% aic_symptom_)]
symptoms <-as.data.frame(sapply(symptoms, as.numeric.factor))

#collapse the symptoms that are the same.
symptoms <- within(symptoms, aic_symptom_impaired_mental_status[symptoms$aic_symptom_fits==1] <- 1)
symptoms <- within(symptoms, aic_symptom_impaired_mental_status[symptoms$aic_symptom_seizures==1] <- 1)

symptoms$bleeding<-NA
symptoms <- within(symptoms, bleeding[symptoms$aic_symptom_bleeding_gums==1] <- 1)
symptoms <- within(symptoms, bleeding[symptoms$aic_symptom_bleeding_gums==1] <- 1)
symptoms <- within(symptoms, bleeding[symptoms$aic_symptom_bloody_nose==1] <- 1)
symptoms <- within(symptoms, bleeding[symptoms$aic_symptom_bloody_urine==1] <- 1)
symptoms <- within(symptoms, bleeding[symptoms$aic_symptom_bloody_stool==1] <- 1)
symptoms <- within(symptoms, bleeding[symptoms$aic_symptom_bloody_vomit==1] <- 1)
symptoms <- within(symptoms, bleeding[symptoms$aic_symptom_bruises==1] <- 1)

symptoms$body_ache<-NA
symptoms <- within(symptoms, body_ache[symptoms$aic_symptom_general_body_ache==1] <- 1)
symptoms <- within(symptoms, body_ache[symptoms$aic_symptom_muscle_pains==1] <- 1)
symptoms <- within(symptoms, body_ache[symptoms$aic_symptom_bone_pains==1] <- 1)
table(symptoms$body_ache)
variable.names(symptoms)
symptoms$nausea_vomitting<-NA
symptoms <- within(symptoms, nausea_vomitting[symptoms$aic_symptom_nausea==1|symptoms$aic_symptom_vomiting| symptoms$aic_symptom_bloody_vomit==1] <- 1)

symptoms<-symptoms[ , grepl( "aic_symptom|bleeding|body_ache|nausea_vomitting" , names(symptoms) ) ]
symptoms$symptom_sum <- as.integer(rowSums(symptoms[ , grep("aic_symptom" , names(symptoms))], na.rm = TRUE))
table(symptoms$symptom_sum, exclude=NULL)
symptoms$symptomatic<-NA
symptoms <- within(symptoms, symptomatic[symptoms$symptom_sum>0] <- 1)
symptoms <- within(symptoms, symptomatic[symptoms$symptom_sum==0] <- 0)

#how much of our acute DENV was symptomatic vs. mildly/asymptomatic, etc.
table(symptoms$symptomatic, exclude=NULL)
#export to box.
symptoms<-as.data.frame(cbind(ids, symptoms))
symptoms$id_cohort<-substr(symptoms$person_id, 2, 2)
aic_symptoms<-subset(symptoms, id_cohort!="C")
aic_symptoms<-aic_symptoms[, !grepl("id_cohort", names(aic_symptoms))]

# create binary physical vars -----------------------------------------------------------------
#parce the physical exam results
#subset physical_exam
physical_exam<-R01_lab_results[which(R01_lab_results$redcap_event_name!="patient_informatio_arm_1"), c("person_id", "redcap_event_name","head_neck_exam", "skin", "neuro", "abdomen", "chest", "heart", "nodes", "joints")]
physical_exam<-as.data.frame(physical_exam)    
physical_exam$all_exam<-paste(physical_exam$head_neck_exam, physical_exam$skin, physical_exam$neuro, physical_exam$abdomen, physical_exam$joints, physical_exam$nodes, physical_exam$heart, physical_exam$chest, physical_exam$abdomen, sep=" ")
physical_exam <- lapply(physical_exam, function(x) {
  gsub(",NA", "", x)
})
physical_exam <- lapply(physical_exam, function(x) {
  gsub("NA", "", x)
})
physical_exam <- lapply(physical_exam, function(x) {
  gsub(",none", "", x)
})
physical_exam <- lapply(physical_exam, function(x) {
  gsub("none", "", x)
})
physical_exam<-as.data.frame(physical_exam)

#create dummy vars for all physical_exam
lev <- levels(factor(physical_exam$all_exam))
lev <- unique(unlist(strsplit(lev, " ")))
mnames <- gsub(" ", "_", paste("aic_pe", lev, sep = "_"))
result <- matrix(data = "0", nrow = length(physical_exam$all_exam), ncol = length(lev))
char.aic_pe <- as.character(physical_exam$all_exam)
for (i in 1:length(lev)) {
  result[grep(lev[i], char.aic_pe, fixed = TRUE), i] <- "1"
}
result <- data.frame(result, stringsAsFactors = TRUE)
colnames(result) <- mnames
physical_exam <- cbind(physical_exam,result)

as.numeric.factor <- function(x) {as.numeric(levels(x))[x]}
ids <- c("person_id", "redcap_event_name", "all_exam")
ids <- physical_exam[ids]
physical_exam<-physical_exam[ , !(names(physical_exam) %in% "aic_pe_")]
aic_pe<-grep("aic_pe_", names(physical_exam), value = TRUE)
physical_exam<-physical_exam[ , (names(physical_exam) %in% aic_pe)]
physical_exam <-as.data.frame(sapply(physical_exam, as.numeric.factor))

#create binary var for nodes      
physical_exam$node<-NA
table(physical_exam$aic_pe_large_lymph_nodes)

physical_exam<-as.data.frame(cbind(ids, physical_exam))

# reshape testing vars -----------------------------------------------------------------
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
table(tested$ab_chikv_stfd_igg)
table(tested$bc_chikv_stfd_igg)
table(tested_long$chikv_stfd_igg, tested_long$visit)


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
# reshape sereoconverter vars -----------------------------------------------------------------
#seroconversion
seroconverter<-R01_lab_results[, grepl("person_id|redcap_event|ab_|bc_|cd_|de_|ef_|fg_|gh_", names(R01_lab_results))]
seroconverter<-seroconverter[, !grepl("malaria|tested", names(seroconverter))]
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

table(seroconverter$ab_chikv_stfd_igg)
table(seroconverter$ab_denv_stfd_igg)
table(seroconverter$bc_chikv_stfd_igg)
table(seroconverter$bc_denv_stfd_igg)
table(seroconverter_long$chikv_stfd_igg, seroconverter_long$visit)
table(seroconverter_long$denv_stfd_igg, seroconverter_long$visit)

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

# merging the created data sets back to main -----------------------------------------------------------------
  R01_lab_results <- merge(seroconverter_long, R01_lab_results,  by=c("person_id", "redcap_event_name"), all = TRUE)  #merge symptoms to redcap data
  R01_lab_results <- merge(aic_symptoms, R01_lab_results, by=c("person_id", "redcap_event_name"), all = TRUE)  #merge symptoms to redcap data
  R01_lab_results <- merge(physical_exam, R01_lab_results,  by=c("person_id", "redcap_event_name"), all = TRUE)  #merge pe parsed data
  R01_lab_results <- merge(tested_long, R01_lab_results,  by=c("person_id", "redcap_event_name"), all = TRUE)  #merge tested samples 
# dengue : probable and warning -----------------------------------------------------------------
  R01_lab_results$probable_dengue<-rowSums(R01_lab_results[, grep("/body_ache|aic_symptom_vomitfg|aic_symptom_nausea|bleeding|impaired_mental_status|hepatomegaly|rash", names(R01_lab_results))], na.rm = TRUE)    #probable dengue
  R01_lab_results$dengue_warning_signs<-rowSums(R01_lab_results[, grep("aic_symptom_impaired_mental_status|bleeding|aic_symptom_vomiting|aic_symptom_abdominal_pain|hepatomegaly|splenomegaly|edema", names(R01_lab_results))], na.rm = TRUE)#warning signs (dengue)
  R01_lab_results$dengue_warning<-ifelse(R01_lab_results$probable_dengue >= 2 & R01_lab_results$dengue_warning_signs >0 , 1, 0)#dengue with warning signs   
  table(R01_lab_results$dengue_warning_signs, R01_lab_results$probable_dengue)
# PCR -----------------------------------------------------------------
#PCR DENV or chikv
R01_lab_results$denv_chikv_result_pcr[R01_lab_results$result_pcr_denv_kenya == 0|R01_lab_results$result_pcr_denv_stfd == 0|R01_lab_results$result_pcr_chikv_kenya == 0|R01_lab_results$result_pcr_chikv_stfd == 0] <- 0
R01_lab_results$denv_chikv_result_pcr[R01_lab_results$result_pcr_denv_kenya == 1|R01_lab_results$result_pcr_denv_stfd == 1|R01_lab_results$result_pcr_chikv_kenya == 1|R01_lab_results$result_pcr_chikv_stfd == 1] <- 1
table(R01_lab_results$denv_chikv_result_pcr)
125/(2415)*100

# UFI -----------------------------------------------------------------
#UFI CHIKV
R01_lab_results$chikv_result_ufi_pos<-NA
R01_lab_results$chikv_result_ufi_pos[R01_lab_results$chikv_result_ufi == 0 & R01_lab_results$ufiresult_ufi___14!=1 ] <- 0
R01_lab_results$chikv_result_ufi_pos[R01_lab_results$chikv_result_ufi == 1 & R01_lab_results$ufiresult_ufi___14!=1 ] <- 1

R01_lab_results$chikv_result_ufi_pos[R01_lab_results$chikv_result_ufi == 0|R01_lab_results$chikv_2_result_ufi == 0] <- 0
R01_lab_results$chikv_result_ufi_pos[R01_lab_results$chikv_result_ufi == 1 |R01_lab_results$chikv_2_result_ufi == 1] <- 1
table(R01_lab_results$chikv_result_ufi_pos)

#UFI DENV
R01_lab_results$denv_result_ufi[R01_lab_results$denv_result_ufi == 1] <- 1
R01_lab_results$denv_result_ufi[R01_lab_results$denv_result_ufi == 0] <- 0
table(R01_lab_results$denv_result_ufi)
#UFI DENV or chikv
R01_lab_results$denv_chikv_result_ufi[R01_lab_results$denv_result_ufi == 0|R01_lab_results$chikv_result_ufi_pos==0] <- 0
R01_lab_results$denv_chikv_result_ufi[R01_lab_results$denv_result_ufi == 1|R01_lab_results$chikv_result_ufi_pos==1] <- 1
table(R01_lab_results$denv_chikv_result_ufi)
133/(133+344)*100

# prevalence
R01_lab_results <- within(R01_lab_results, prev_chikv_igg_stfd_all_pcr[prev_chikv_igg_stfd_all_pcr>0|R01_lab_results$chikv_result_ufi_pos==1] <- 1)
R01_lab_results <- within(R01_lab_results, prev_denv_igg_stfd_all_pcr[prev_denv_igg_stfd_all_pcr>0|R01_lab_results$denv_result_ufi==1] <- 1)

table(R01_lab_results$prev_denv_igg_stfd_all_pcr, R01_lab_results$id_cohort)
table(R01_lab_results$prev_chikv_igg_stfd_all_pcr, R01_lab_results$id_cohort)

# seroprevalence
  table(R01_lab_results$result_igg_denv_stfd)
    8185  + 222   + 10 
    222/8417*100
  table(R01_lab_results$result_igg_chikv_stfd)
    9134+  225+   16 
    225/9375*100
    
  table(R01_lab_results$result_igg_chikv_stfd, R01_lab_results$site, exclude=NULL)
  62/(6024+62+13)*100#chikv seroprevalence coast
  163/(3110+163+3)*100#chikv seroprevalence west
  table(R01_lab_results$result_igg_denv_stfd, R01_lab_results$site, exclude=NULL)
  189/(4961+189+9)*100#denv coast
  33/(3224+33+1)*100#denv west
  
table(R01_lab_results$result_igg_chikv_stfd, R01_lab_results$id_cohort)
  table(R01_lab_results$result_igg_denv_stfd, R01_lab_results$id_cohort)
# acute -----------------------------------------------------------------
    #create acute variable
      R01_lab_results$acute<-NA
      R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$visit_type==1] <- 1)
      R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$visit_type==2] <- 1)
      R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$visit_type==3] <- 0)
      R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$visit_type==4] <- 1)
      R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$visit_type==5] <- 1)
      #if they ask an initial survey question (see odk aic inital and follow up forms), it is an initial visit.
      R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$kid_highest_level_education_aic!=""] <- 1)
      R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$occupation_aic!=""] <- 1)
      R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$oth_educ_level_aic!=""] <- 1)
      R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$mom_highest_level_education_aic!=""] <- 1)
      R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$roof_type!=""] <- 1)
      R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$pregnant!=""] <- 1)
      #if it is visit a,call it acute
      R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$redcap_event=="visit_a_arm_1" & id_cohort=="F"] <- 1)
      #if they have fever, call it acute
      R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$aic_symptom_fever==1] <- 1)
      R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$temp>=38] <- 1)
      #otherwise, it is not acute
      R01_lab_results <- within(R01_lab_results, acute[R01_lab_results$acute!=1 & !is.na(R01_lab_results$gender_aic) ] <- 0)
      
      table(R01_lab_results$acute)

# deidentify -----------------------------------------------------------------
    #double check to de-identify data
    #take name out of event.
    names(R01_lab_results)[names(R01_lab_results) == 'redcap_event_name'] <- 'redcap_event'
    identifiers<-grep("name|gps", names(R01_lab_results), value = TRUE)
    R01_lab_results<-R01_lab_results[ , !(names(R01_lab_results) %in% identifiers)]
    names(R01_lab_results)[names(R01_lab_results) == 'redcap_event'] <- 'redcap_event_name'
    
# incidence -----------------------------------------------------------------
    table(R01_lab_results$seroc_denv_kenya_igg, R01_lab_results$seroc_denv_stfd_igg, exclude=NULL)
    
    R01_lab_results$id_cohort<-substr(R01_lab_results$person_id, 2, 2)
    R01_lab_results$id_city<-substr(R01_lab_results$person_id, 1, 1)
    #use tested = 1 as the zero for infection.
    #kenya denv igg seroconverters or PCR positives as infected.
      R01_lab_results$infected_denv_kenya[R01_lab_results$tested_denv_kenya_igg ==1 | R01_lab_results$result_pcr_denv_kenya==0|R01_lab_results$result_pcr_denv_stfd==0|R01_lab_results$denv_result_ufi==0]<-0
      R01_lab_results$infected_denv_kenya[R01_lab_results$seroc_denv_kenya_igg==1|R01_lab_results$result_pcr_denv_kenya==1|R01_lab_results$result_pcr_denv_stfd==1|R01_lab_results$denv_result_ufi==1]<-1
      table(R01_lab_results$infected_denv_kenya, R01_lab_results$denv_result_ufi)

      table(R01_lab_results$result_pcr_denv_kenya)  
      table(R01_lab_results$denv_result_ufi)  
    #kenya chikv igg seroconverters or PCR positives as infected.
      R01_lab_results$infected_chikv_kenya[R01_lab_results$tested_chikv_kenya_igg ==1 |R01_lab_results$result_pcr_chikv_kenya==0|R01_lab_results$chikv_result_ufi_pos==0|R01_lab_results$chikv_2_result_ufi==0]<-0
      R01_lab_results$infected_chikv_kenya[R01_lab_results$seroc_chikv_kenya_igg==1|R01_lab_results$result_pcr_chikv_kenya==1|R01_lab_results$chikv_result_ufi_pos==1|R01_lab_results$chikv_2_result_ufi==1]<-1
      table(R01_lab_results$infected_chikv_kenya)  
      
    #stfd denv igg seroconverters or PCR positives as infected.
    R01_lab_results$infected_denv_stfd[R01_lab_results$tested_denv_stfd_igg ==1 |R01_lab_results$result_pcr_denv_kenya==0|R01_lab_results$result_pcr_denv_stfd==0|R01_lab_results$denv_result_ufi==0]<-0
    R01_lab_results$infected_denv_stfd[R01_lab_results$seroc_denv_stfd_igg==1|R01_lab_results$result_pcr_denv_kenya==1|R01_lab_results$result_pcr_denv_stfd==1|R01_lab_results$denv_result_ufi==1]<-1
    table(R01_lab_results$infected_denv_stfd)  
    174/(174+3899)*100
    table(R01_lab_results$infected_denv_stfd, R01_lab_results$redcap_event_name)  
    table(R01_lab_results$infected_denv_stfd, R01_lab_results$id_cohort)
    table(R01_lab_results$tested_denv_stfd_igg, R01_lab_results$id_cohort)
    172/(172 + 3216)*100#aic inc
    table(R01_lab_results$seroc_denv_stfd_igg, R01_lab_results$id_cohort)  
    table(R01_lab_results$tested_denv_stfd_igg, R01_lab_results$id_cohort)  
    2/685*100 #hcc seroconverters
    
    #stfd chikv igg seroconverters or PCR positives as infected.
      R01_lab_results$infected_chikv_stfd[R01_lab_results$tested_chikv_stfd_igg ==1 |R01_lab_results$result_pcr_chikv_kenya==0|R01_lab_results$chikv_result_ufi_pos==0|R01_lab_results$chikv_2_result_ufi==0]<-0
      R01_lab_results$infected_chikv_stfd[R01_lab_results$seroc_chikv_stfd_igg==1|R01_lab_results$result_pcr_chikv_kenya==1|R01_lab_results$chikv_result_ufi_pos==1|R01_lab_results$chikv_2_result_ufi==1]<-1
      table(R01_lab_results$infected_chikv_stfd)  
      119/(119+4032)*100
      
      table(R01_lab_results$infected_chikv_stfd, R01_lab_results$id_cohort)  
      114/(3465)*100#aic inc
      114+3351
      table(R01_lab_results$seroc_chikv_stfd_igg, R01_lab_results$id_cohort)  
      table(R01_lab_results$tested_chikv_stfd_igg, R01_lab_results$id_cohort)  
      5/686*100 #hcc seroconverters
      table(R01_lab_results$seroc_chikv_stfd_igg, R01_lab_results$site)  
      
      
      #chikv or denv incidence
    R01_lab_results$infected_denv_chikv_stfd[R01_lab_results$infected_chikv_stfd==0 |R01_lab_results$infected_denv_stfd==0]<-0
    R01_lab_results$infected_denv_chikv_stfd[R01_lab_results$infected_chikv_stfd==1 |R01_lab_results$infected_denv_stfd==1]<-1
    table(R01_lab_results$infected_denv_chikv_stfd)
    281/(281 + 4423)*100
    table(R01_lab_results$infected_denv_chikv_stfd, R01_lab_results$id_cohort)  
    7/(7 + 714)*100#hcc
    274/(274 + 3709)*100#aic

# graphs -----------------------------------------------------------------
    #stanford infected denv aic
    #symptom sum histogram for aic
    infected_pcr_denv_stfd_igg<-R01_lab_results[which(R01_lab_results$infected_denv_stfd==1),]
    tiff(file = "AIC DENV Infected (Stanford IgG, all PCR).tiff", width = 3200, height = 3200, units = "px", res = 800)
    hist(infected_pcr_denv_stfd_igg$symptom_sum, breaks=50, main = "AIC DENV Infected (Stanford IgG, all PCR)", xlab = "Number of Symptoms Reported at acute", freq=TRUE)
    dev.off()
    #cohort
    infected_pcr_denv_stfd_igg$id_cohort<-substr(infected_pcr_denv_stfd_igg$person_id, 2, 2)
    table(infected_pcr_denv_stfd_igg$id_cohort , exclude = NULL)
    #symptomatic aic
    table(R01_lab_results$symptomatic, R01_lab_results$infected_denv_stfd)
    
    
    #kenya infected denv aic
    #symptom sum for aic
    infected_pcr_denv_kenya_igg<-R01_lab_results[which(R01_lab_results$infected_denv_kenya==1),]
    tiff(file = "AIC DENV Infected (Kenya IgG, all PCR).tiff", width = 3200, height = 3200, units = "px", res = 800)
    hist(infected_pcr_denv_kenya_igg$symptom_sum, breaks=50, main = "AIC DENV Infected (Kenya IgG, all PCR)", xlab = "Number of Symptoms Reported at acute", freq=TRUE)
    dev.off()
    #cohort
    infected_pcr_denv_kenya_igg$id_cohort<-substr(infected_pcr_denv_kenya_igg$person_id, 2, 2)
    table(infected_pcr_denv_kenya_igg$id_cohort , exclude = NULL)
    #symptomatic for aic
    table(R01_lab_results$symptomatic, R01_lab_results$infected_denv_kenya)
    
    #stanford infected chikv aic
    #symptom sum histogram for aic
    infected_pcr_chikv_stfd_igg<-R01_lab_results[which(R01_lab_results$infected_chikv_stfd==1),]
    tiff(file = "AIC chikv Infected (Stanford IgG, all PCR).tiff", width = 3200, height = 3200, units = "px", res = 800)
    hist(infected_pcr_chikv_stfd_igg$symptom_sum, breaks=50, main = "AIC chikv Infected (Stanford IgG, all PCR)", xlab = "Number of Symptoms Reported at acute", freq=TRUE)
    dev.off()
    #cohort
    infected_pcr_chikv_stfd_igg$id_cohort<-substr(infected_pcr_chikv_stfd_igg$person_id, 2, 2)
    table(infected_pcr_chikv_stfd_igg$id_cohort , exclude = NULL)
    #symptomatic aic
    table(R01_lab_results$symptomatic, R01_lab_results$infected_chikv_stfd)
    
    
    #kenya infected chikv aic
    #symptom sum for aic
    infected_pcr_chikv_kenya_igg<-R01_lab_results[which(R01_lab_results$infected_chikv_kenya==1),]
    
    tiff(file = "AIC chikv Infected (Kenya IgG, all PCR).tiff", width = 3200, height = 3200, units = "px", res = 800)
    hist(infected_pcr_chikv_kenya_igg$symptom_sum, breaks=50, main = "AIC chikv Infected (Kenya IgG, all PCR)", xlab = "Number of Symptoms Reported at acute", freq=TRUE)
    dev.off()
    
    #cohort
    infected_pcr_chikv_kenya_igg$id_cohort<-substr(infected_pcr_chikv_kenya_igg$person_id, 2, 2)
    table(infected_pcr_chikv_kenya_igg$id_cohort , exclude = NULL)
    #symptomatic for aic
    table(R01_lab_results$symptomatic, R01_lab_results$infected_chikv_kenya)
    #save file
    save(R01_lab_results,file="R01_lab_results.rda")
    
    ##survival analysis
    #devtools::install_github("sachsmc/ggkm", force=TRUE)
    library(ggkm)
#    load("R01_lab_results.rda")
    
    
    R01_lab_results$visit<- as.numeric(as.factor(R01_lab_results$redcap_event))
    R01_lab_results$visit<-R01_lab_results$visit-1
    R01_lab_results <- within(R01_lab_results, visit[visit==8] <- NA)
    R01_lab_results <- within(R01_lab_results, visit[visit==9] <- NA)
    table(R01_lab_results$visit)  
    
    #ggplot(R01_lab_results, aes(time = visit, status = infected_chikv_kenya, color = factor(symptomatic))) + geom_km()
    #ggplot(R01_lab_results, aes(time = visit, status = infected_denv_kenya, color = factor(symptomatic))) + geom_km()
    #ggplot(R01_lab_results, aes(time = visit, status = infected_chikv_stfd, color = factor(symptomatic))) + geom_km()
    #ggplot(R01_lab_results, aes(time = visit, status = infected_denv_stfd,  color = factor(symptomatic))) + geom_km()
    #incidence  
    survival_infected_chikv_kenya <- survfit(Surv(visit, infected_chikv_kenya)~symptomatic, data=R01_lab_results)
    survival_infected_denv_kenya <- survfit(Surv(visit, infected_denv_kenya)~symptomatic, data=R01_lab_results)
    survival_infected_chikv_stfd <- survfit(Surv(visit, infected_chikv_stfd)~symptomatic, data=R01_lab_results)
    survival_infected_denv_stfd <- survfit(Surv(visit, infected_denv_stfd)~symptomatic, data=R01_lab_results)
    
    #incidence by year
    library("zoo")
    library("lubridate")
    library(tidyr)
    #    load("R01_lab_results.rda")
    interview_dates<-R01_lab_results[, grepl("person_id|redcap_event_name|interview_date", names(R01_lab_results))]
    interview_dates<-interview_dates[, !grepl("u24", names(interview_dates))]
    interview_dates[is.na(interview_dates)] = ''
    interview_dates<-unite(interview_dates, int_date, interview_date_aic:interview_date, sep='')
    R01_lab_results<- merge(interview_dates, R01_lab_results,  by=c("person_id", "redcap_event_name"), all = TRUE)
    
    #dates
    R01_lab_results$int_date <-ymd(R01_lab_results$int_date)
    n_distinct(R01_lab_results$int_date)
    R01_lab_results$month_year <- as.yearmon(R01_lab_results$int_date)
    R01_lab_results$year <- year(as.Date(R01_lab_results$int_date, origin = '1900-1-1'))
    #table(interview_dates$month_year, exclude = NULL)
    
    #infected by month
    table(R01_lab_results$infected_denv_kenya, R01_lab_results$month_year, exclude =NULL)
    table(R01_lab_results$infected_chikv_kenya, R01_lab_results$month_year, exclude =NULL)
    table(R01_lab_results$infected_denv_stfd, R01_lab_results$month_year, exclude =NULL)
    table(R01_lab_results$infected_chikv_stfd, R01_lab_results$month_year, exclude =NULL)
    #infected by year
    R01_lab_results$id_city<-substr(R01_lab_results$person_id, 1, 1)
    R01_lab_results_df=as.data.frame(R01_lab_results)
    #site
    R01_lab_results_df$site<-NA
    
    table(R01_lab_results$id_city)
    R01_lab_results_df <- within(R01_lab_results_df, site[R01_lab_results_df$id_city=="G"] <- "C")
    R01_lab_results_df <- within(R01_lab_results_df, site[R01_lab_results_df$id_city=="U"] <- "C")
    R01_lab_results_df <- within(R01_lab_results_df, site[R01_lab_results_df$id_city=="L"] <- "C")
    R01_lab_results_df <- within(R01_lab_results_df, site[R01_lab_results_df$id_city=="M"] <- "C")
    
    R01_lab_results_df <- within(R01_lab_results_df, site[R01_lab_results_df$id_city=="C"] <- "W")
    R01_lab_results_df <- within(R01_lab_results_df, site[R01_lab_results_df$id_city=="R"] <- "W")
    R01_lab_results_df <- within(R01_lab_results_df, site[R01_lab_results_df$id_city=="K"] <- "W")
    ##rural
    R01_lab_results_df$rural<-NA
    R01_lab_results_df <- within(R01_lab_results_df, rural[R01_lab_results_df$id_city=="G"] <- 1)
    R01_lab_results_df <- within(R01_lab_results_df, rural[R01_lab_results_df$id_city=="U"] <- 0)
    R01_lab_results_df <- within(R01_lab_results_df, rural[R01_lab_results_df$id_city=="L"] <- 1)
    R01_lab_results_df <- within(R01_lab_results_df, rural[R01_lab_results_df$id_city=="M"] <- 1)
    
    R01_lab_results_df <- within(R01_lab_results_df, rural[R01_lab_results_df$id_city=="C"] <- 1)
    R01_lab_results_df <- within(R01_lab_results_df, rural[R01_lab_results_df$id_city=="R"] <- 1)
    R01_lab_results_df <- within(R01_lab_results_df, rural[R01_lab_results_df$id_city=="K"] <- 0)
    
    #cohort
    R01_lab_results_df <- within(R01_lab_results_df, id_cohort[R01_lab_results_df$id_cohort=="M"] <- "F")
    
    R01_lab_results<-R01_lab_results_df
    table(R01_lab_results_df$rural, exclude = NULL)
    table(R01_lab_results_df$site, exclude = NULL)
    table(R01_lab_results_df$site,R01_lab_results_df$seroc_chikv_stfd_igg, exclude = NULL)
    
    #prevalence
    #denv
    table(R01_lab_results$denv_prevalence)
    table(R01_lab_results$chikv_prevalence)
    #extract first event
    #infected_denv_kenya
    table(R01_lab_results$infected_denv_kenya, R01_lab_results$year, exclude = NULL)
    Ranks <- with(R01_lab_results, ave(infected_denv_kenya, person_id, infected_denv_kenya, FUN = function(x) 
      rank(x, ties.method="first")))
    infected_denv_kenya<-  R01_lab_results[Ranks == 1, ]
    
    #infected_chikv_kenya
    table(R01_lab_results$infected_chikv_kenya, R01_lab_results$year, exclude = NULL)
    Ranks <- with(R01_lab_results, ave(infected_chikv_kenya, person_id, infected_chikv_kenya, FUN = function(x) 
      rank(x, ties.method="first")))
    infected_chikv_kenya<-  R01_lab_results[Ranks == 1, ]
    table(infected_chikv_kenya$infected_chikv_kenya,  exclude = NULL)
    
    #infected_denv_stfd
    table(R01_lab_results$infected_denv_stfd, R01_lab_results$year, exclude = NULL)
    Ranks <- with(R01_lab_results, ave(infected_denv_stfd, person_id, infected_denv_stfd, FUN = function(x) 
      rank(x, ties.method="first")))
    infected_denv_stfd<-  R01_lab_results[Ranks == 1, ]
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
    table(R01_lab_results$infected_chikv_stfd, R01_lab_results$year, exclude = NULL)
    Ranks <- with(R01_lab_results, ave(infected_chikv_stfd, person_id, infected_chikv_stfd, FUN = function(x) 
      rank(x, ties.method="first")))
    infected_chikv_stfd<-  R01_lab_results[Ranks == 1, ]
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
    infected_chikv_stfd_hcc<-R01_lab_results[R01_lab_results$id_cohort =="C", ]
    infected_chikv_stfd_aic<-R01_lab_results[R01_lab_results$id_cohort =="F", ]
    tableOne <- CreateTableOne(vars = vars, factorVars = factorVars, strata = "prev_chikv_igg_stfd_all_pcr", data = R01_lab_results)
    print(tableOne, quote = TRUE)
    tableOne <- CreateTableOne(vars = vars, factorVars = factorVars, strata = "prev_chikv_igg_stfd_all_pcr", data = R01_lab_results)
    print(tableOne, quote = TRUE)
    #prevalence denv
    vars <- c("prev_denv_igg_stfd_all_pcr", "site", "rural", "id_cohort")
    factorVars <- c("prev_denv_igg_stfd_all_pcr", "site", "rural", "id_cohort")
    infected_denv_stfd_hcc<-R01_lab_results[R01_lab_results$id_cohort =="C", ]
    infected_denv_stfd_aic<-R01_lab_results[R01_lab_results$id_cohort =="F", ]
    tableOne <- CreateTableOne(vars = vars, factorVars = factorVars, strata = "prev_denv_igg_stfd_all_pcr", data = R01_lab_results)
    print(tableOne, quote = TRUE)
    tableOne <- CreateTableOne(vars = vars, factorVars = factorVars, strata = "prev_denv_igg_stfd_all_pcr", data = R01_lab_results)
    print(tableOne, quote = TRUE)
    
    R01_lab_results<-R01_lab_results[,order(colnames(R01_lab_results))]
    R01_lab_results$gender[is.na(R01_lab_results$gender)] = ''
    R01_lab_results$gender_aic[is.na(R01_lab_results$gender_aic)] = ''
    
    R01_lab_results<-unite(R01_lab_results, gender_all, gender_aic:gender, sep='')
    R01_lab_results$gender_all[R01_lab_results$gender_all==''] = NA
    
    #missing dates export
    missing_date<-R01_lab_results[which((R01_lab_results$infected_denv_stfd!="" & is.na(R01_lab_results$year)) | (R01_lab_results$infected_chikv_stfd!="" & is.na(R01_lab_results$year))) , ]
    #export to csv
    setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long")
    f <- "missing_date.csv"
    write.csv(as.data.frame(missing_date), f )
    
    infected_pcr_denv_stfd_igg<-R01_lab_results[which(R01_lab_results$infected_denv_stfd==1),]
    
    #survival with time.
    R01_lab_results$month_year_date<-as.numeric(as.Date(R01_lab_results$month_year))-16071
    surv_month_infected_denv_stfd <- survfit(Surv(month_year_date, infected_denv_stfd)~symptomatic, data=R01_lab_results)
    ggplot(R01_lab_results, aes(time = month_year_date, status = infected_denv_stfd,  color = factor(symptomatic))) + geom_km()
    table(R01_lab_results$month_year_date)
    #denominator is only those tested for chikv by pcr or igg at stfd
    R01_lab_results$tested_chikv<-NA
    R01_lab_results<- within(R01_lab_results, tested_chikv[infected_chikv_stfd==1 |tested_chikv_stfd_igg==1 | !is.na(result_pcr_chikv_kenya)| !is.na(result_pcr_chikv_stfd)| !is.na(chikv_result_ufi)| !is.na(chikv_2_result_ufi)] <- 1)
    table(R01_lab_results$infected_chikv_stfd, exclude = NULL)
    table(R01_lab_results$tested_chikv, exclude = NULL)
    table(R01_lab_results$tested_chikv, R01_lab_results$infected_chikv_stfd, exclude = NULL)
    (19/3938)*100 #incidence chikv
    
    #denominator is only those tested for denv by pcr or igg at stfd
    R01_lab_results$tested_denv<-NA
    R01_lab_results<- within(R01_lab_results, tested_denv[infected_denv_stfd==1 |tested_denv_stfd_igg==1 | !is.na(result_pcr_denv_kenya) | !is.na(result_pcr_denv_stfd)|!is.na(denv_result_ufi)] <- 1)
    #denominator is only those tested for denv or chikv by pcr or igg at stfd
    R01_lab_results$tested_denv_chikv<-NA
    R01_lab_results<- within(R01_lab_results, tested_denv_chikv[tested_chikv==1 |tested_denv==1] <- 1)
    
    table(R01_lab_results$tested_denv, exclude = NULL)
    table(R01_lab_results$infected_denv_stfd, exclude = NULL)
    (137/3676)*100 #incidence denv
    
    table(R01_lab_results$infected_denv_stfd, R01_lab_results$tested_denv, exclude = NULL)
    #incidence by age age group
    R01_lab_results$age = R01_lab_results$age_calc  # your new merged column start with x
    R01_lab_results$age[!is.na(R01_lab_results$aic_calculated_age)] = R01_lab_results$aic_calculated_age[!is.na(R01_lab_results$aic_calculated_age)]  # merge with y
    R01_lab_results$age<-round(R01_lab_results$age)
    table(R01_lab_results$infected_denv_stfd)
    table(R01_lab_results$infected_denv_stfd, R01_lab_results$age , exclude = NULL)
    table(R01_lab_results$infected_chikv_stfd, R01_lab_results$age , exclude = NULL)
    
    R01_lab_results$age_group<-NA
    R01_lab_results <- within(R01_lab_results, age_group[age<=2] <- "under 2")
    R01_lab_results <- within(R01_lab_results, age_group[age>2 & age<=5] <- "2-4")
    R01_lab_results <- within(R01_lab_results, age_group[age>5 & age<=10] <- "6-10")
    R01_lab_results <- within(R01_lab_results, age_group[age>10 & age<=15] <- "11-15")
    R01_lab_results <- within(R01_lab_results, age_group[age>15] <- "over 15")
    table(R01_lab_results$age_group, exclude = NULL)

    #either denv or chikv incidence 
    table(R01_lab_results$infected_denv_chikv_stfd, R01_lab_results$id_cohort)
    table(R01_lab_results$infected_denv_chikv_stfd, R01_lab_results$age_group, exclude = NULL)
    #either denv or chikv prevalence 
    R01_lab_results$prev_denv_chikv_all[R01_lab_results$prev_denv_igg_stfd_all_pcr ==0|R01_lab_results$prev_chikv_igg_stfd_all_pcr==0]<-0
    R01_lab_results$prev_denv_chikv_all[R01_lab_results$prev_denv_igg_stfd_all_pcr ==1|R01_lab_results$prev_chikv_igg_stfd_all_pcr==1]<-1

    table(R01_lab_results$prev_chikv_igg_stfd_all_pcr, R01_lab_results$age_group, exclude = NULL)
    table(R01_lab_results$prev_denv_igg_stfd_all_pcr, R01_lab_results$age_group, exclude = NULL)
    table(R01_lab_results$prev_denv_chikv_all, R01_lab_results$age_group, exclude = NULL)
    table(R01_lab_results$tested_denv_chikv, R01_lab_results$age_group, exclude = NULL)
    
32/795*100

    #get incidence by age group numberator and denominator 
    #denv
    table(R01_lab_results$infected_denv_stfd, R01_lab_results$id_cohort, exclude = NULL)
    table(R01_lab_results$tested_denv, R01_lab_results$id_cohort, exclude = NULL)
    table(R01_lab_results$infected_denv_stfd, R01_lab_results$age_group, exclude = NULL)
    table(R01_lab_results$tested_denv, R01_lab_results$age_group, exclude = NULL)
    #chikv
    table(R01_lab_results$infected_chikv_stfd, R01_lab_results$age_group, exclude = NULL)
    table(R01_lab_results$tested_chikv, R01_lab_results$id_cohort, exclude = NULL)
    table(R01_lab_results$infected_chikv_stfd, R01_lab_results$id_cohort, exclude = NULL)
    table(R01_lab_results$tested_chikv, R01_lab_results$age_group, exclude = NULL)
    #denv or chikv
    table(R01_lab_results$infected_denv_chikv_stfd, R01_lab_results$age_group, exclude = NULL)
    table(R01_lab_results$infected_denv_chikv_stfd, R01_lab_results$id_cohort, exclude = NULL)
    table(R01_lab_results$tested_denv_chikv, R01_lab_results$age_group, exclude = NULL)

    
    #get incidence by cohort numberator and denominator 
    table(R01_lab_results$infected_denv_stfd, R01_lab_results$id_cohort)
    table(R01_lab_results$tested_denv, R01_lab_results$id_cohort)
    
    table(R01_lab_results$infected_chikv_stfd, R01_lab_results$id_cohort)
    table(R01_lab_results$tested_chikv, R01_lab_results$id_cohort)
    
    table(R01_lab_results$infected_denv_chikv_stfd, R01_lab_results$id_cohort, exclude = NULL)
    table(R01_lab_results$tested_denv_chikv, R01_lab_results$id_cohort, exclude = NULL)
    
    #some need age  to be included in sample
    no_age<-R01_lab_results[which(is.na(R01_lab_results$age_group) & R01_lab_results$infected_denv_stfd==1), ]
    table(is.na(R01_lab_results$age_group) & R01_lab_results$infected_denv_stfd==1)
    table(no_age$person_id, no_age$redcap_event_name)
    #prevalence
    table(R01_lab_results$prev_chikv_igg_stfd_all_pcr)
    (195/6992)*100#prevalence of chikv.
    table(R01_lab_results$prev_chikv_igg_stfd_all_pcr, R01_lab_results$site)
    (145/(145+2958))*100#prevalence of chikv west
    (50/(50+3839))*100#prevalence of chikv coast
    table(R01_lab_results$prev_denv_igg_stfd_all_pcr)
    (268/6748)*100#prevalence of denv.
    table(R01_lab_results$prev_denv_igg_stfd_all_pcr, R01_lab_results$site)
    (154/(154+3442))*100#prevalence of denv coast
    (114/(114+3038))*100#prevalence of denv west
    
    table(R01_lab_results$prev_denv_igg_stfd_all_pcr, R01_lab_results$rural)
    (103/(103+3184))*100#prevalence of denv urban
    (165/(165+3296))*100#prevalence of denv rural
    
    #export to csv
    setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long")
    f <- "redcap_data_cleaned.csv"
    write.csv(as.data.frame(R01_lab_results), f )
    #save as r data frame for use in other analysis. 
    save(R01_lab_results,file="R01_lab_results.clean.rda")