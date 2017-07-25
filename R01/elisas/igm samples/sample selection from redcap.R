library(dplyr)
library(tidyr)
library(plyr)    
library(xlsx)
library(redcapAPI)
library(REDCapR)


setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long")
Redcap.token <- readLines("Redcap.token.R01.txt") # Read API token from folder
REDcap.URL  <- 'https://redcap.stanford.edu/api/'
rcon <- redcapConnection(url=REDcap.URL, token=Redcap.token)

#export data from redcap to R (must be connected via cisco VPN)
#R01_lab_results <- redcap_read(  redcap_uri  = REDcap.URL,  token       = Redcap.token,  batch_size = 300)$data
save(R01_lab_results, file="R01_lab_results.rda")
load("R01_lab_results.rda")

R01_lab_results_wide<-reshape(R01_lab_results, direction = "wide", idvar = "person_id", timevar = "redcap_event_name", sep = "_")
#R01_lab_results_wide <-R01_lab_results_wide[!sapply(R01_lab_results_wide, function (x) all(is.na(x) | x == ""| x == "NA"))]
nameVec <- names(R01_lab_results_wide)
nameVec <- gsub("_patient_informatio_arm_1","_p",nameVec)
nameVec <- gsub("_arm_1","",nameVec)
nameVec <- gsub("_visit","",nameVec)
names(R01_lab_results_wide) <- nameVec
attach(R01_lab_results_wide)

#function to find positives

isPos <- function(x) {
  (x > 0) & (!is.na(x)) * 1
}


#exclude those with pcr positivie from kenya or stfd.
#chikv
R01_lab_results_wide$chikv_igm_sample_a <- ifelse(isPos(ab_chikv_stfd_igg_p) & !isPos(result_pcr_chikv_kenya_a) & !isPos(result_pcr_chikv_stfd_a), 1, NA)
R01_lab_results_wide$chikv_igm_sample_b <- ifelse(isPos(bc_chikv_stfd_igg_p) & !isPos(result_pcr_chikv_kenya_b) & !isPos(result_pcr_chikv_stfd_b), 1, NA)
R01_lab_results_wide$chikv_igm_sample_c <- ifelse(isPos(cd_chikv_stfd_igg_p) & !isPos(result_pcr_chikv_kenya_c & !isPos(result_pcr_chikv_stfd_c)), 1, NA)
R01_lab_results_wide$chikv_igm_sample_d <- ifelse(isPos(de_chikv_stfd_igg_p) & !isPos(result_pcr_chikv_kenya_d & !isPos(result_pcr_chikv_stfd_d)), 1, NA)
R01_lab_results_wide$chikv_igm_sample_e <- ifelse(isPos(ef_chikv_stfd_igg_p) & !isPos(result_pcr_chikv_kenya_e & !isPos(result_pcr_chikv_stfd_e)), 1, NA)
R01_lab_results_wide$chikv_igm_sample_f <- ifelse(isPos(fg_chikv_stfd_igg_p) & !isPos(result_pcr_chikv_kenya_f & !isPos(result_pcr_chikv_stfd_f)), 1, NA) 
R01_lab_results_wide$chikv_igm_sample_g <- ifelse(isPos(gh_chikv_stfd_igg_p) & !isPos(result_pcr_chikv_kenya_g & !isPos(result_pcr_chikv_stfd_g)), 1, NA)


#denv
R01_lab_results_wide$denv_igm_sample_a <- ifelse(isPos(ab_denv_stfd_igg_p) & !isPos(result_pcr_denv_kenya_a & !isPos(result_pcr_denv_stfd_a)), 1, NA)
R01_lab_results_wide$denv_igm_sample_b <- ifelse(isPos(bc_denv_stfd_igg_p) & !isPos(result_pcr_denv_kenya_b & !isPos(result_pcr_denv_stfd_b)), 1, NA)
R01_lab_results_wide$denv_igm_sample_c <- ifelse(isPos(cd_denv_stfd_igg_p) & !isPos(result_pcr_denv_kenya_c & !isPos(result_pcr_denv_stfd_c)), 1, NA)
R01_lab_results_wide$denv_igm_sample_d <- ifelse(isPos(de_denv_stfd_igg_p) & !isPos(result_pcr_denv_kenya_d & !isPos(result_pcr_denv_stfd_d)), 1, NA)
R01_lab_results_wide$denv_igm_sample_e <- ifelse(isPos(ef_denv_stfd_igg_p) & !isPos(result_pcr_denv_kenya_e & !isPos(result_pcr_denv_stfd_e)), 1, NA)
R01_lab_results_wide$denv_igm_sample_f <- ifelse(isPos(fg_denv_stfd_igg_p) & !isPos(result_pcr_denv_kenya_f & !isPos(result_pcr_denv_stfd_f)), 1, NA)
R01_lab_results_wide$denv_igm_sample_g <- ifelse(isPos(gh_denv_stfd_igg_p) & !isPos(result_pcr_denv_kenya_g & !isPos(result_pcr_denv_stfd_g)), 1, NA)

#keep if Stanford results are: Negative to blank; Negative to repeat; Blank to positive; Blank to blank ; Repeat to positive; Repeat to blank; Repeat to repeat

########denv
  #ab                  
  R01_lab_results_wide$negative_blank_denv_stfd_visit_a<-ifelse(result_igg_denv_stfd_a=='0' & is.na(result_igg_denv_stfd_b) & isPos(ab_denv_kenya_igg_p) & !isPos(result_pcr_denv_kenya_a) & !isPos(result_pcr_denv_stfd_a),1,NA)
  R01_lab_results_wide$negative_repeat_denv_stfd_visit_a<-ifelse(result_igg_denv_stfd_a=='0' & result_igg_denv_stfd_b=="98" & isPos(ab_denv_kenya_igg_p) & !isPos(result_pcr_denv_kenya_a) & !isPos(result_pcr_denv_stfd_a),1,NA)
  R01_lab_results_wide$blank_pos_denv_stfd_visit_a<-ifelse(is.na(result_igg_denv_stfd_a) & isPos(result_igg_denv_stfd_b) & isPos(ab_denv_kenya_igg_p) & !isPos(result_pcr_denv_kenya_a) & !isPos(result_pcr_denv_stfd_a),1,NA)
  R01_lab_results_wide$blank_blank_denv_stfd_visit_a<-ifelse(is.na(result_igg_denv_stfd_a) & is.na(result_igg_denv_stfd_b) & isPos(ab_denv_kenya_igg_p) & !isPos(result_pcr_denv_kenya_a) & !isPos(result_pcr_denv_stfd_a),1,NA)
  R01_lab_results_wide$repeat_pos_denv_stfd_visit_a<-ifelse(result_igg_denv_stfd_a=='98' & isPos(result_igg_denv_stfd_b) & isPos(ab_denv_kenya_igg_p) & !isPos(result_pcr_denv_kenya_a) & !isPos(result_pcr_denv_stfd_a),1,NA)
  R01_lab_results_wide$repeat_blank_denv_stfd_visit_a<-ifelse(result_igg_denv_stfd_a=='98' & is.na(result_igg_denv_stfd_b) & isPos(ab_denv_kenya_igg_p) & !isPos(result_pcr_denv_kenya_a) & !isPos(result_pcr_denv_stfd_a),1,NA)
  R01_lab_results_wide$repeat_repeat_denv_stfd_visit_a<-ifelse(result_igg_denv_stfd_a=='98' & result_igg_denv_stfd_b=="98" & isPos(ab_denv_kenya_igg_p) & !isPos(result_pcr_denv_kenya_a) & !isPos(result_pcr_denv_stfd_a),1,NA)
  
  #bc
  R01_lab_results_wide$negative_blank_denv_stfd_visit_b<-ifelse(result_igg_denv_stfd_b=='0' & is.na(result_igg_denv_stfd_c) & isPos(bc_denv_kenya_igg_p) & !isPos(result_pcr_denv_kenya_b) & !isPos(result_pcr_denv_stfd_b),1,NA)
  R01_lab_results_wide$negative_repeat_denv_stfd_visit_b<-ifelse(result_igg_denv_stfd_b=='0' & result_igg_denv_stfd_c=="98" & isPos(bc_denv_kenya_igg_p) & !isPos(result_pcr_denv_kenya_b) & !isPos(result_pcr_denv_stfd_b),1,NA)
  R01_lab_results_wide$blank_pos_denv_stfd_visit_b<-ifelse(is.na(result_igg_denv_stfd_b) & isPos(result_igg_denv_stfd_c) & isPos(bc_denv_kenya_igg_p) & !isPos(result_pcr_denv_kenya_b) & !isPos(result_pcr_denv_stfd_b),1,NA)
  R01_lab_results_wide$blank_blank_denv_stfd_visit_b<-ifelse(is.na(result_igg_denv_stfd_b) & is.na(result_igg_denv_stfd_c) & isPos(bc_denv_kenya_igg_p) & !isPos(result_pcr_denv_kenya_b) & !isPos(result_pcr_denv_stfd_b),1,NA)
  R01_lab_results_wide$repeat_pos_denv_stfd_visit_b<-ifelse(result_igg_denv_stfd_b=='98' & isPos(result_igg_denv_stfd_c) & isPos(bc_denv_kenya_igg_p) & !isPos(result_pcr_denv_kenya_b) & !isPos(result_pcr_denv_stfd_b),1,NA)
  R01_lab_results_wide$repeat_blank_denv_stfd_visit_b<-ifelse(result_igg_denv_stfd_b=='98' & is.na(result_igg_denv_stfd_c) & isPos(bc_denv_kenya_igg_p) & !isPos(result_pcr_denv_kenya_b) & !isPos(result_pcr_denv_stfd_b),1,NA)
  R01_lab_results_wide$repeat_repeat_denv_stfd_visit_b<-ifelse(result_igg_denv_stfd_b=='98' & result_igg_denv_stfd_c=="98" & isPos(bc_denv_kenya_igg_p) & !isPos(result_pcr_denv_kenya_b) & !isPos(result_pcr_denv_stfd_b),1,NA)
  
  #cd
  R01_lab_results_wide$negative_blank_denv_stfd_visit_c<-ifelse(result_igg_denv_stfd_c=='0' & is.na(result_igg_denv_stfd_d) & isPos(cd_denv_kenya_igg_p) & !isPos(result_pcr_denv_kenya_c) & !isPos(result_pcr_denv_stfd_c),1,NA)
  R01_lab_results_wide$negative_repeat_denv_stfd_visit_c<-ifelse(result_igg_denv_stfd_c=='0' & result_igg_denv_stfd_d=="98" & isPos(cd_denv_kenya_igg_p) & !isPos(result_pcr_denv_kenya_c) & !isPos(result_pcr_denv_stfd_c),1,NA)
  R01_lab_results_wide$blank_pos_denv_stfd_visit_c<-ifelse(is.na(result_igg_denv_stfd_c) & isPos(result_igg_denv_stfd_d) & isPos(cd_denv_kenya_igg_p) & !isPos(result_pcr_denv_kenya_c) & !isPos(result_pcr_denv_stfd_c),1,NA)
  R01_lab_results_wide$blank_blank_denv_stfd_visit_c<-ifelse(is.na(result_igg_denv_stfd_c) & is.na(result_igg_denv_stfd_d) & isPos(cd_denv_kenya_igg_p) & !isPos(result_pcr_denv_kenya_c) & !isPos(result_pcr_denv_stfd_c),1,NA)
  R01_lab_results_wide$repeat_pos_denv_stfd_visit_c<-ifelse(result_igg_denv_stfd_c=='98' & isPos(result_igg_denv_stfd_d) & isPos(cd_denv_kenya_igg_p) & !isPos(result_pcr_denv_kenya_c) & !isPos(result_pcr_denv_stfd_c),1,NA)
  R01_lab_results_wide$repeat_blank_denv_stfd_visit_c<-ifelse(result_igg_denv_stfd_c=='98' & is.na(result_igg_denv_stfd_d) & isPos(cd_denv_kenya_igg_p) & !isPos(result_pcr_denv_kenya_c) & !isPos(result_pcr_denv_stfd_c),1,NA)
  R01_lab_results_wide$repeat_repeat_denv_stfd_visit_c<-ifelse(result_igg_denv_stfd_c=='98' & result_igg_denv_stfd_d=="98" & isPos(cd_denv_kenya_igg_p) & !isPos(result_pcr_denv_kenya_c) & !isPos(result_pcr_denv_stfd_c),1,NA)
  
  #de
  R01_lab_results_wide$negative_blank_denv_stfd_visit_d<-ifelse(result_igg_denv_stfd_d=='0' & is.na(result_igg_denv_stfd_e) & isPos(de_denv_kenya_igg_p) & !isPos(result_pcr_denv_kenya_d) & !isPos(result_pcr_denv_stfd_d),1,NA)
  R01_lab_results_wide$negative_repeat_denv_stfd_visit_d<-ifelse(result_igg_denv_stfd_d=='0' & result_igg_denv_stfd_e=="98" & isPos(de_denv_kenya_igg_p) & !isPos(result_pcr_denv_kenya_d) & !isPos(result_pcr_denv_stfd_d),1,NA)
  R01_lab_results_wide$blank_pos_denv_stfd_visit_d<-ifelse(is.na(result_igg_denv_stfd_d) & isPos(result_igg_denv_stfd_e) & isPos(de_denv_kenya_igg_p) & !isPos(result_pcr_denv_kenya_d) & !isPos(result_pcr_denv_stfd_d),1,NA)
  R01_lab_results_wide$blank_blank_denv_stfd_visit_d<-ifelse(is.na(result_igg_denv_stfd_d) & is.na(result_igg_denv_stfd_e) & isPos(de_denv_kenya_igg_p) & !isPos(result_pcr_denv_kenya_d) & !isPos(result_pcr_denv_stfd_d),1,NA)
  R01_lab_results_wide$repeat_pos_denv_stfd_visit_d<-ifelse(result_igg_denv_stfd_d=='98' & isPos(result_igg_denv_stfd_e) & isPos(de_denv_kenya_igg_p) & !isPos(result_pcr_denv_kenya_d) & !isPos(result_pcr_denv_stfd_d),1,NA)
  R01_lab_results_wide$repeat_blank_denv_stfd_visit_d<-ifelse(result_igg_denv_stfd_d=='98' & is.na(result_igg_denv_stfd_e) & isPos(de_denv_kenya_igg_p) & !isPos(result_pcr_denv_kenya_d) & !isPos(result_pcr_denv_stfd_d),1,NA)
  R01_lab_results_wide$repeat_repeat_denv_stfd_visit_d<-ifelse(result_igg_denv_stfd_d=='98' & result_igg_denv_stfd_e=="98" & isPos(de_denv_kenya_igg_p) & !isPos(result_pcr_denv_kenya_d) & !isPos(result_pcr_denv_stfd_d),1,NA)
  
  #ef
  R01_lab_results_wide$negative_blank_denv_stfd_visit_e<-ifelse(result_igg_denv_stfd_e=='0' & is.na(result_igg_denv_stfd_f) & isPos(ef_denv_kenya_igg_p) & !isPos(result_pcr_denv_kenya_e) & !isPos(result_pcr_denv_stfd_e),1,NA)
  R01_lab_results_wide$negative_repeat_denv_stfd_visit_e<-ifelse(result_igg_denv_stfd_e=='0' & result_igg_denv_stfd_f=="98" & isPos(ef_denv_kenya_igg_p) & !isPos(result_pcr_denv_kenya_e) & !isPos(result_pcr_denv_stfd_e),1,NA)
  R01_lab_results_wide$blank_pos_denv_stfd_visit_e<-ifelse(is.na(result_igg_denv_stfd_e) & result_igg_denv_stfd_f=="1" & isPos(ef_denv_kenya_igg_p) & !isPos(result_pcr_denv_kenya_e) & !isPos(result_pcr_denv_stfd_e),1,NA)
  R01_lab_results_wide$blank_blank_denv_stfd_visit_e<-ifelse(is.na(result_igg_denv_stfd_e) & is.na(result_igg_denv_stfd_f) & isPos(ef_denv_kenya_igg_p) & !isPos(result_pcr_denv_kenya_e) & !isPos(result_pcr_denv_stfd_e),1,NA)
  R01_lab_results_wide$repeat_pos_denv_stfd_visit_e<-ifelse(result_igg_denv_stfd_e=='98' & result_igg_denv_stfd_f=="1" & isPos(ef_denv_kenya_igg_p) & !isPos(result_pcr_denv_kenya_e) & !isPos(result_pcr_denv_stfd_e),1,NA)
  R01_lab_results_wide$repeat_blank_denv_stfd_visit_e<-ifelse(result_igg_denv_stfd_e=='98' & is.na(result_igg_denv_stfd_f) & isPos(ef_denv_kenya_igg_p) & !isPos(result_pcr_denv_kenya_e) & !isPos(result_pcr_denv_stfd_e),1,NA)
  R01_lab_results_wide$repeat_repeat_denv_stfd_visit_e<-ifelse(result_igg_denv_stfd_e=='98' & result_igg_denv_stfd_f=="98" & isPos(ef_denv_kenya_igg_p) & !isPos(result_pcr_denv_kenya_e) & !isPos(result_pcr_denv_stfd_e),1,NA)
  
  #fg
  R01_lab_results_wide$negative_blank_denv_stfd_visit_f<-ifelse(result_igg_denv_stfd_f=='0' & is.na(result_igg_denv_stfd_g) & isPos(fg_denv_kenya_igg_p) & !isPos(result_pcr_denv_kenya_f) & !isPos(result_pcr_denv_stfd_f),1,NA)
  R01_lab_results_wide$negative_repeat_denv_stfd_visit_f<-ifelse(result_igg_denv_stfd_f=='0' & result_igg_denv_stfd_g=="98" & isPos(fg_denv_kenya_igg_p) & !isPos(result_pcr_denv_kenya_f) & !isPos(result_pcr_denv_stfd_f),1,NA)
  R01_lab_results_wide$blank_pos_denv_stfd_visit_f<-ifelse(is.na(result_igg_denv_stfd_f) & isPos(result_igg_denv_stfd_g) & isPos(fg_denv_kenya_igg_p) & !isPos(result_pcr_denv_kenya_f) & !isPos(result_pcr_denv_stfd_f),1,NA)
  R01_lab_results_wide$blank_blank_denv_stfd_visit_f<-ifelse(is.na(result_igg_denv_stfd_f) & is.na(result_igg_denv_stfd_g) & isPos(fg_denv_kenya_igg_p) & !isPos(result_pcr_denv_kenya_f) & !isPos(result_pcr_denv_stfd_f),1,NA)
  R01_lab_results_wide$repeat_pos_denv_stfd_visit_f<-ifelse(result_igg_denv_stfd_f=='98' & isPos(result_igg_denv_stfd_g) & isPos(fg_denv_kenya_igg_p) & !isPos(result_pcr_denv_kenya_f) & !isPos(result_pcr_denv_stfd_f),1,NA)
  R01_lab_results_wide$repeat_blank_denv_stfd_visit_f<-ifelse(result_igg_denv_stfd_f=='98' & is.na(result_igg_denv_stfd_g) & isPos(fg_denv_kenya_igg_p) & !isPos(result_pcr_denv_kenya_f) & !isPos(result_pcr_denv_stfd_f),1,NA)
  R01_lab_results_wide$repeat_repeat_denv_stfd_visit_f<-ifelse(result_igg_denv_stfd_f=='98' & result_igg_denv_stfd_g=="98" & isPos(fg_denv_kenya_igg_p) & !isPos(result_pcr_denv_kenya_f) & !isPos(result_pcr_denv_stfd_f),1,NA)
  
  #gh
  R01_lab_results_wide$negative_blank_denv_stfd_visit_g<-ifelse(result_igg_denv_stfd_g=='0' & is.na(result_igg_denv_stfd_h) & isPos(gh_denv_kenya_igg_p) & !isPos(result_pcr_denv_kenya_g) & !isPos(result_pcr_denv_stfd_g),1,NA)
  R01_lab_results_wide$negative_repeat_denv_stfd_visit_g<-ifelse(result_igg_denv_stfd_g=='0' & result_igg_denv_stfd_h=="98" & isPos(gh_denv_kenya_igg_p) & !isPos(result_pcr_denv_kenya_g) & !isPos(result_pcr_denv_stfd_g),1,NA)
  R01_lab_results_wide$blank_pos_denv_stfd_visit_g<-ifelse(is.na(result_igg_denv_stfd_g) & isPos(result_igg_denv_stfd_h) & isPos(gh_denv_kenya_igg_p) & !isPos(result_pcr_denv_kenya_g) & !isPos(result_pcr_denv_stfd_g),1,NA)
  R01_lab_results_wide$blank_blank_denv_stfd_visit_g<-ifelse(is.na(result_igg_denv_stfd_g) & is.na(result_igg_denv_stfd_h) & isPos(gh_denv_kenya_igg_p) & !isPos(result_pcr_denv_kenya_g) & !isPos(result_pcr_denv_stfd_g),1,NA)
  R01_lab_results_wide$repeat_pos_denv_stfd_visit_g<-ifelse(result_igg_denv_stfd_g=='98' & isPos(result_igg_denv_stfd_h) & isPos(gh_denv_kenya_igg_p) & !isPos(result_pcr_denv_kenya_g) & !isPos(result_pcr_denv_stfd_g),1,NA)
  R01_lab_results_wide$repeat_blank_denv_stfd_visit_g<-ifelse(result_igg_denv_stfd_g=='98' & is.na(result_igg_denv_stfd_h) & isPos(gh_denv_kenya_igg_p) & !isPos(result_pcr_denv_kenya_g) & !isPos(result_pcr_denv_stfd_g),1,NA)
  R01_lab_results_wide$repeat_repeat_denv_stfd_visit_g<-ifelse(result_igg_denv_stfd_g=='98' & result_igg_denv_stfd_h=="98" & isPos(gh_denv_kenya_igg_p) & !isPos(result_pcr_denv_kenya_g) & !isPos(result_pcr_denv_stfd_g),1,NA)
  
  attach(R01_lab_results_wide)
  R01_lab_results_wide$denv_igm_sample_a<-ifelse(isPos(negative_blank_denv_stfd_visit_a) | isPos(negative_repeat_denv_stfd_visit_a) | isPos(blank_pos_denv_stfd_visit_a)| isPos(blank_blank_denv_stfd_visit_a) |isPos(repeat_pos_denv_stfd_visit_a)| isPos(repeat_blank_denv_stfd_visit_a) | isPos(repeat_repeat_denv_stfd_visit_a) | isPos(denv_igm_sample_a), 1, NA)
  R01_lab_results_wide$denv_igm_sample_b<-ifelse(isPos(negative_blank_denv_stfd_visit_b) | isPos(negative_repeat_denv_stfd_visit_b) | isPos(blank_pos_denv_stfd_visit_b)| isPos(blank_blank_denv_stfd_visit_b) |isPos(repeat_pos_denv_stfd_visit_b)| isPos(repeat_blank_denv_stfd_visit_b) | isPos(repeat_repeat_denv_stfd_visit_b)| isPos(denv_igm_sample_b), 1, NA)
  R01_lab_results_wide$denv_igm_sample_c<-ifelse(isPos(negative_blank_denv_stfd_visit_c) | isPos(negative_repeat_denv_stfd_visit_c) | isPos(blank_pos_denv_stfd_visit_c)| isPos(blank_blank_denv_stfd_visit_c) |isPos(repeat_pos_denv_stfd_visit_c)| isPos(repeat_blank_denv_stfd_visit_c) | isPos(repeat_repeat_denv_stfd_visit_c)| isPos(denv_igm_sample_c), 1, NA)
  R01_lab_results_wide$denv_igm_sample_d<-ifelse(isPos(negative_blank_denv_stfd_visit_d) | isPos(negative_repeat_denv_stfd_visit_d) | isPos(blank_pos_denv_stfd_visit_d)| isPos(blank_blank_denv_stfd_visit_d) |isPos(repeat_pos_denv_stfd_visit_d)| isPos(repeat_blank_denv_stfd_visit_d) | isPos(repeat_repeat_denv_stfd_visit_d)| isPos(denv_igm_sample_d), 1, NA)
  R01_lab_results_wide$denv_igm_sample_e<-ifelse(isPos(negative_blank_denv_stfd_visit_e) | isPos(negative_repeat_denv_stfd_visit_e) | isPos(blank_pos_denv_stfd_visit_e)| isPos(blank_blank_denv_stfd_visit_e) |isPos(repeat_pos_denv_stfd_visit_e)| isPos(repeat_blank_denv_stfd_visit_e) | isPos(repeat_repeat_denv_stfd_visit_e)| isPos(denv_igm_sample_e), 1, NA)
  R01_lab_results_wide$denv_igm_sample_f<-ifelse(isPos(negative_blank_denv_stfd_visit_f) | isPos(negative_repeat_denv_stfd_visit_f) | isPos(blank_pos_denv_stfd_visit_f)| isPos(blank_blank_denv_stfd_visit_f) |isPos(repeat_pos_denv_stfd_visit_f)| isPos(repeat_blank_denv_stfd_visit_f) | isPos(repeat_repeat_denv_stfd_visit_f)| isPos(denv_igm_sample_f), 1, NA)
  R01_lab_results_wide$denv_igm_sample_g<-ifelse(isPos(negative_blank_denv_stfd_visit_g) | isPos(negative_repeat_denv_stfd_visit_g) | isPos(blank_pos_denv_stfd_visit_g)| isPos(blank_blank_denv_stfd_visit_g) |isPos(repeat_pos_denv_stfd_visit_g)| isPos(repeat_blank_denv_stfd_visit_g) | isPos(repeat_repeat_denv_stfd_visit_g)| isPos(denv_igm_sample_g), 1, NA)
  ########chikv
  #ab                  
  R01_lab_results_wide$negative_blank_chikv_stfd_visit_a<-ifelse(result_igg_chikv_stfd_a=='0' & is.na(result_igg_chikv_stfd_b) & isPos(ab_chikv_kenya_igg_p) & !isPos(result_pcr_chikv_kenya_a) & !isPos(result_pcr_chikv_stfd_a),1,NA)
  R01_lab_results_wide$negative_repeat_chikv_stfd_visit_a<-ifelse(result_igg_chikv_stfd_a=='0' & result_igg_chikv_stfd_b=="98" & isPos(ab_chikv_kenya_igg_p) & !isPos(result_pcr_chikv_kenya_a) & !isPos(result_pcr_chikv_stfd_a),1,NA)
  R01_lab_results_wide$blank_pos_chikv_stfd_visit_a<-ifelse(is.na(result_igg_chikv_stfd_a) & isPos(result_igg_chikv_stfd_b) & isPos(ab_chikv_kenya_igg_p) & !isPos(result_pcr_chikv_kenya_a) & !isPos(result_pcr_chikv_stfd_a),1,NA)
  R01_lab_results_wide$blank_blank_chikv_stfd_visit_a<-ifelse(is.na(result_igg_chikv_stfd_a) & is.na(result_igg_chikv_stfd_b) & isPos(ab_chikv_kenya_igg_p) & !isPos(result_pcr_chikv_kenya_a) & !isPos(result_pcr_chikv_stfd_a),1,NA)
  R01_lab_results_wide$repeat_pos_chikv_stfd_visit_a<-ifelse(result_igg_chikv_stfd_a=='98' & isPos(result_igg_chikv_stfd_b) & isPos(ab_chikv_kenya_igg_p) & !isPos(result_pcr_chikv_kenya_a) & !isPos(result_pcr_chikv_stfd_a),1,NA)
  R01_lab_results_wide$repeat_blank_chikv_stfd_visit_a<-ifelse(result_igg_chikv_stfd_a=='98' & is.na(result_igg_chikv_stfd_b) & isPos(ab_chikv_kenya_igg_p) & !isPos(result_pcr_chikv_kenya_a) & !isPos(result_pcr_chikv_stfd_a),1,NA)
  R01_lab_results_wide$repeat_repeat_chikv_stfd_visit_a<-ifelse(result_igg_chikv_stfd_a=='98' & result_igg_chikv_stfd_b=="98" & isPos(ab_chikv_kenya_igg_p) & !isPos(result_pcr_chikv_kenya_a) & !isPos(result_pcr_chikv_stfd_a),1,NA)
  
  #bc
  R01_lab_results_wide$negative_blank_chikv_stfd_visit_b<-ifelse(result_igg_chikv_stfd_b=='0' & is.na(result_igg_chikv_stfd_c) & isPos(bc_chikv_kenya_igg_p) & !isPos(result_pcr_chikv_kenya_b) & !isPos(result_pcr_chikv_stfd_b),1,NA)
  R01_lab_results_wide$negative_repeat_chikv_stfd_visit_b<-ifelse(result_igg_chikv_stfd_b=='0' & result_igg_chikv_stfd_c=="98" & isPos(bc_chikv_kenya_igg_p) & !isPos(result_pcr_chikv_kenya_b) & !isPos(result_pcr_chikv_stfd_b),1,NA)
  R01_lab_results_wide$blank_pos_chikv_stfd_visit_b<-ifelse(is.na(result_igg_chikv_stfd_b) & isPos(result_igg_chikv_stfd_c) & isPos(bc_chikv_kenya_igg_p) & !isPos(result_pcr_chikv_kenya_b) & !isPos(result_pcr_chikv_stfd_b),1,NA)
  R01_lab_results_wide$blank_blank_chikv_stfd_visit_b<-ifelse(is.na(result_igg_chikv_stfd_b) & is.na(result_igg_chikv_stfd_c) & isPos(bc_chikv_kenya_igg_p) & !isPos(result_pcr_chikv_kenya_b) & !isPos(result_pcr_chikv_stfd_b),1,NA)
  R01_lab_results_wide$repeat_pos_chikv_stfd_visit_b<-ifelse(result_igg_chikv_stfd_b=='98' & isPos(result_igg_chikv_stfd_c) & isPos(bc_chikv_kenya_igg_p) & !isPos(result_pcr_chikv_kenya_b) & !isPos(result_pcr_chikv_stfd_b),1,NA)
  R01_lab_results_wide$repeat_blank_chikv_stfd_visit_b<-ifelse(result_igg_chikv_stfd_b=='98' & is.na(result_igg_chikv_stfd_c) & isPos(bc_chikv_kenya_igg_p) & !isPos(result_pcr_chikv_kenya_b) & !isPos(result_pcr_chikv_stfd_b),1,NA)
  R01_lab_results_wide$repeat_repeat_chikv_stfd_visit_b<-ifelse(result_igg_chikv_stfd_b=='98' & result_igg_chikv_stfd_c=="98" & isPos(bc_chikv_kenya_igg_p) & !isPos(result_pcr_chikv_kenya_b) & !isPos(result_pcr_chikv_stfd_b),1,NA)
  
  #cd
  R01_lab_results_wide$negative_blank_chikv_stfd_visit_c<-ifelse(result_igg_chikv_stfd_c=='0' & is.na(result_igg_chikv_stfd_d) & isPos(cd_chikv_kenya_igg_p) & !isPos(result_pcr_chikv_kenya_c) & !isPos(result_pcr_chikv_stfd_c),1,NA)
  R01_lab_results_wide$negative_repeat_chikv_stfd_visit_c<-ifelse(result_igg_chikv_stfd_c=='0' & result_igg_chikv_stfd_d=="98" & isPos(cd_chikv_kenya_igg_p) & !isPos(result_pcr_chikv_kenya_c) & !isPos(result_pcr_chikv_stfd_c),1,NA)
  R01_lab_results_wide$blank_pos_chikv_stfd_visit_c<-ifelse(is.na(result_igg_chikv_stfd_c) & isPos(result_igg_chikv_stfd_d) & isPos(cd_chikv_kenya_igg_p) & !isPos(result_pcr_chikv_kenya_c) & !isPos(result_pcr_chikv_stfd_c),1,NA)
  R01_lab_results_wide$blank_blank_chikv_stfd_visit_c<-ifelse(is.na(result_igg_chikv_stfd_c) & is.na(result_igg_chikv_stfd_d) & isPos(cd_chikv_kenya_igg_p) & !isPos(result_pcr_chikv_kenya_c) & !isPos(result_pcr_chikv_stfd_c),1,NA)
  R01_lab_results_wide$repeat_pos_chikv_stfd_visit_c<-ifelse(result_igg_chikv_stfd_c=='98' & isPos(result_igg_chikv_stfd_d) & isPos(cd_chikv_kenya_igg_p) & !isPos(result_pcr_chikv_kenya_c) & !isPos(result_pcr_chikv_stfd_c),1,NA)
  R01_lab_results_wide$repeat_blank_chikv_stfd_visit_c<-ifelse(result_igg_chikv_stfd_c=='98' & is.na(result_igg_chikv_stfd_d) & isPos(cd_chikv_kenya_igg_p) & !isPos(result_pcr_chikv_kenya_c) & !isPos(result_pcr_chikv_stfd_c),1,NA)
  R01_lab_results_wide$repeat_repeat_chikv_stfd_visit_c<-ifelse(result_igg_chikv_stfd_c=='98' & result_igg_chikv_stfd_d=="98" & isPos(cd_chikv_kenya_igg_p) & !isPos(result_pcr_chikv_kenya_c) & !isPos(result_pcr_chikv_stfd_c),1,NA)
  
  #de
  R01_lab_results_wide$negative_blank_chikv_stfd_visit_d<-ifelse(result_igg_chikv_stfd_d=='0' & is.na(result_igg_chikv_stfd_e) & isPos(de_chikv_kenya_igg_p) & !isPos(result_pcr_chikv_kenya_d) & !isPos(result_pcr_chikv_stfd_d),1,NA)
  R01_lab_results_wide$negative_repeat_chikv_stfd_visit_d<-ifelse(result_igg_chikv_stfd_d=='0' & result_igg_chikv_stfd_e=="98" & isPos(de_chikv_kenya_igg_p) & !isPos(result_pcr_chikv_kenya_d) & !isPos(result_pcr_chikv_stfd_d),1,NA)
  R01_lab_results_wide$blank_pos_chikv_stfd_visit_d<-ifelse(is.na(result_igg_chikv_stfd_d) & result_igg_chikv_stfd_e=="1" & isPos(de_chikv_kenya_igg_p) & !isPos(result_pcr_chikv_kenya_d) & !isPos(result_pcr_chikv_stfd_d),1,NA)
  R01_lab_results_wide$blank_blank_chikv_stfd_visit_d<-ifelse(is.na(result_igg_chikv_stfd_d) & is.na(result_igg_chikv_stfd_e) & isPos(de_chikv_kenya_igg_p) & !isPos(result_pcr_chikv_kenya_d) & !isPos(result_pcr_chikv_stfd_d),1,NA)
  R01_lab_results_wide$repeat_pos_chikv_stfd_visit_d<-ifelse(result_igg_chikv_stfd_d=='98' & result_igg_chikv_stfd_e=="1" & isPos(de_chikv_kenya_igg_p) & !isPos(result_pcr_chikv_kenya_d) & !isPos(result_pcr_chikv_stfd_d),1,NA)
  R01_lab_results_wide$repeat_blank_chikv_stfd_visit_d<-ifelse(result_igg_chikv_stfd_d=='98' & is.na(result_igg_chikv_stfd_e) & isPos(de_chikv_kenya_igg_p) & !isPos(result_pcr_chikv_kenya_d) & !isPos(result_pcr_chikv_stfd_d),1,NA)
  R01_lab_results_wide$repeat_repeat_chikv_stfd_visit_d<-ifelse(result_igg_chikv_stfd_d=='98' & result_igg_chikv_stfd_e=="98" & isPos(de_chikv_kenya_igg_p) & !isPos(result_pcr_chikv_kenya_d) & !isPos(result_pcr_chikv_stfd_d),1,NA)
  
  #ef
  R01_lab_results_wide$negative_blank_chikv_stfd_visit_e<-ifelse(result_igg_chikv_stfd_e=='0' & is.na(result_igg_chikv_stfd_f) & isPos(ef_chikv_kenya_igg_p) & !isPos(result_pcr_chikv_kenya_e) & !isPos(result_pcr_chikv_stfd_e),1,NA)
  R01_lab_results_wide$negative_repeat_chikv_stfd_visit_e<-ifelse(result_igg_chikv_stfd_e=='0' & result_igg_chikv_stfd_f=="98" & isPos(ef_chikv_kenya_igg_p) & !isPos(result_pcr_chikv_kenya_e) & !isPos(result_pcr_chikv_stfd_e),1,NA)
  R01_lab_results_wide$blank_pos_chikv_stfd_visit_e<-ifelse(is.na(result_igg_chikv_stfd_e) & isPos(result_igg_chikv_stfd_f) & isPos(ef_chikv_kenya_igg_p) & !isPos(result_pcr_chikv_kenya_e) & !isPos(result_pcr_chikv_stfd_e),1,NA)
  R01_lab_results_wide$blank_blank_chikv_stfd_visit_e<-ifelse(is.na(result_igg_chikv_stfd_e) & is.na(result_igg_chikv_stfd_f) & isPos(ef_chikv_kenya_igg_p) & !isPos(result_pcr_chikv_kenya_e) & !isPos(result_pcr_chikv_stfd_e),1,NA)
  R01_lab_results_wide$repeat_pos_chikv_stfd_visit_e<-ifelse(result_igg_chikv_stfd_e=='98' & isPos(result_igg_chikv_stfd_f) & isPos(ef_chikv_kenya_igg_p) & !isPos(result_pcr_chikv_kenya_e) & !isPos(result_pcr_chikv_stfd_e),1,NA)
  R01_lab_results_wide$repeat_blank_chikv_stfd_visit_e<-ifelse(result_igg_chikv_stfd_e=='98' & is.na(result_igg_chikv_stfd_f) & isPos(ef_chikv_kenya_igg_p) & !isPos(result_pcr_chikv_kenya_e) & !isPos(result_pcr_chikv_stfd_e),1,NA)
  R01_lab_results_wide$repeat_repeat_chikv_stfd_visit_e<-ifelse(result_igg_chikv_stfd_e=='98' & result_igg_chikv_stfd_f=="98" & isPos(ef_chikv_kenya_igg_p) & !isPos(result_pcr_chikv_kenya_e) & !isPos(result_pcr_chikv_stfd_e),1,NA)
  
  #fg
  R01_lab_results_wide$negative_blank_chikv_stfd_visit_f<-ifelse(result_igg_chikv_stfd_f=='0' & is.na(result_igg_chikv_stfd_g) & isPos(fg_chikv_kenya_igg_p) & !isPos(result_pcr_chikv_kenya_f) & !isPos(result_pcr_chikv_stfd_f),1,NA)
  R01_lab_results_wide$negative_repeat_chikv_stfd_visit_f<-ifelse(result_igg_chikv_stfd_f=='0' & result_igg_chikv_stfd_g=="98" & isPos(fg_chikv_kenya_igg_p) & !isPos(result_pcr_chikv_kenya_f) & !isPos(result_pcr_chikv_stfd_f),1,NA)
  R01_lab_results_wide$blank_pos_chikv_stfd_visit_f<-ifelse(is.na(result_igg_chikv_stfd_f) & isPos(result_igg_chikv_stfd_g) & isPos(fg_chikv_kenya_igg_p) & !isPos(result_pcr_chikv_kenya_f) & !isPos(result_pcr_chikv_stfd_f),1,NA)
  R01_lab_results_wide$blank_blank_chikv_stfd_visit_f<-ifelse(is.na(result_igg_chikv_stfd_f) & is.na(result_igg_chikv_stfd_g) & isPos(fg_chikv_kenya_igg_p) & !isPos(result_pcr_chikv_kenya_f) & !isPos(result_pcr_chikv_stfd_f),1,NA)
  R01_lab_results_wide$repeat_pos_chikv_stfd_visit_f<-ifelse(result_igg_chikv_stfd_f=='98' & isPos(result_igg_chikv_stfd_g) & isPos(fg_chikv_kenya_igg_p) & !isPos(result_pcr_chikv_kenya_f) & !isPos(result_pcr_chikv_stfd_f),1,NA)
  R01_lab_results_wide$repeat_blank_chikv_stfd_visit_f<-ifelse(result_igg_chikv_stfd_f=='98' & is.na(result_igg_chikv_stfd_g) & isPos(fg_chikv_kenya_igg_p) & !isPos(result_pcr_chikv_kenya_f) & !isPos(result_pcr_chikv_stfd_f),1,NA)
  R01_lab_results_wide$repeat_repeat_chikv_stfd_visit_f<-ifelse(result_igg_chikv_stfd_f=='98' & result_igg_chikv_stfd_g=="98" & isPos(fg_chikv_kenya_igg_p) & !isPos(result_pcr_chikv_kenya_f) & !isPos(result_pcr_chikv_stfd_f),1,NA)
  
  #gh
  R01_lab_results_wide$negative_blank_chikv_stfd_visit_g<-ifelse(result_igg_chikv_stfd_g=='0' & is.na(result_igg_chikv_stfd_h) & isPos(gh_chikv_kenya_igg_p) & !isPos(result_pcr_chikv_kenya_g) & !isPos(result_pcr_chikv_stfd_g),1,NA)
  R01_lab_results_wide$negative_repeat_chikv_stfd_visit_g<-ifelse(result_igg_chikv_stfd_g=='0' & result_igg_chikv_stfd_h=="98" & isPos(gh_chikv_kenya_igg_p) & !isPos(result_pcr_chikv_kenya_g) & !isPos(result_pcr_chikv_stfd_g),1,NA)
  R01_lab_results_wide$blank_pos_chikv_stfd_visit_g<-ifelse(is.na(result_igg_chikv_stfd_g) & isPos(result_igg_chikv_stfd_h) & isPos(gh_chikv_kenya_igg_p) & !isPos(result_pcr_chikv_kenya_g) & !isPos(result_pcr_chikv_stfd_g),1,NA)
  R01_lab_results_wide$blank_blank_chikv_stfd_visit_g<-ifelse(is.na(result_igg_chikv_stfd_g) & is.na(result_igg_chikv_stfd_h) & isPos(gh_chikv_kenya_igg_p) & !isPos(result_pcr_chikv_kenya_g) & !isPos(result_pcr_chikv_stfd_g),1,NA)
  R01_lab_results_wide$repeat_pos_chikv_stfd_visit_g<-ifelse(result_igg_chikv_stfd_g=='98' & isPos(result_igg_chikv_stfd_h) & isPos(gh_chikv_kenya_igg_p) & !isPos(result_pcr_chikv_kenya_g) & !isPos(result_pcr_chikv_stfd_g),1,NA)
  R01_lab_results_wide$repeat_blank_chikv_stfd_visit_g<-ifelse(result_igg_chikv_stfd_g=='98' & is.na(result_igg_chikv_stfd_h) & isPos(gh_chikv_kenya_igg_p) & !isPos(result_pcr_chikv_kenya_g) & !isPos(result_pcr_chikv_stfd_g),1,NA)
  R01_lab_results_wide$repeat_repeat_chikv_stfd_visit_g<-ifelse(result_igg_chikv_stfd_g=='98' & result_igg_chikv_stfd_h=="98" & isPos(gh_chikv_kenya_igg_p) & !isPos(result_pcr_chikv_kenya_g) & !isPos(result_pcr_chikv_stfd_g),1,NA)
  
  attach(R01_lab_results_wide)
  R01_lab_results_wide$chikv_igm_sample_a<-ifelse(isPos(negative_blank_chikv_stfd_visit_a) | isPos(negative_repeat_chikv_stfd_visit_a) | isPos(blank_pos_chikv_stfd_visit_a)| isPos(blank_blank_chikv_stfd_visit_a) |isPos(repeat_pos_chikv_stfd_visit_a)| isPos(repeat_blank_chikv_stfd_visit_a) | isPos(repeat_repeat_chikv_stfd_visit_a)| isPos(chikv_igm_sample_a), 1, NA)
  R01_lab_results_wide$chikv_igm_sample_b<-ifelse(isPos(negative_blank_chikv_stfd_visit_b) | isPos(negative_repeat_chikv_stfd_visit_b) | isPos(blank_pos_chikv_stfd_visit_b)| isPos(blank_blank_chikv_stfd_visit_b) |isPos(repeat_pos_chikv_stfd_visit_b)| isPos(repeat_blank_chikv_stfd_visit_b) | isPos(repeat_repeat_chikv_stfd_visit_b)| isPos(chikv_igm_sample_b), 1, NA)
  R01_lab_results_wide$chikv_igm_sample_c<-ifelse(isPos(negative_blank_chikv_stfd_visit_c) | isPos(negative_repeat_chikv_stfd_visit_c) | isPos(blank_pos_chikv_stfd_visit_c)| isPos(blank_blank_chikv_stfd_visit_c) |isPos(repeat_pos_chikv_stfd_visit_c)| isPos(repeat_blank_chikv_stfd_visit_c) | isPos(repeat_repeat_chikv_stfd_visit_c)| isPos(chikv_igm_sample_c), 1, NA)
  R01_lab_results_wide$chikv_igm_sample_d<-ifelse(isPos(negative_blank_chikv_stfd_visit_d) | isPos(negative_repeat_chikv_stfd_visit_d) | isPos(blank_pos_chikv_stfd_visit_d)| isPos(blank_blank_chikv_stfd_visit_d) |isPos(repeat_pos_chikv_stfd_visit_d)| isPos(repeat_blank_chikv_stfd_visit_d) | isPos(repeat_repeat_chikv_stfd_visit_d)| isPos(chikv_igm_sample_d), 1, NA)
  R01_lab_results_wide$chikv_igm_sample_e<-ifelse(isPos(negative_blank_chikv_stfd_visit_e) | isPos(negative_repeat_chikv_stfd_visit_e) | isPos(blank_pos_chikv_stfd_visit_e)| isPos(blank_blank_chikv_stfd_visit_e) |isPos(repeat_pos_chikv_stfd_visit_e)| isPos(repeat_blank_chikv_stfd_visit_e) | isPos(repeat_repeat_chikv_stfd_visit_e)| isPos(chikv_igm_sample_e), 1, NA)
  R01_lab_results_wide$chikv_igm_sample_f<-ifelse(isPos(negative_blank_chikv_stfd_visit_f) | isPos(negative_repeat_chikv_stfd_visit_f) | isPos(blank_pos_chikv_stfd_visit_f)| isPos(blank_blank_chikv_stfd_visit_f) |isPos(repeat_pos_chikv_stfd_visit_f)| isPos(repeat_blank_chikv_stfd_visit_f) | isPos(repeat_repeat_chikv_stfd_visit_f)| isPos(chikv_igm_sample_f), 1, NA)
  R01_lab_results_wide$chikv_igm_sample_g<-ifelse(isPos(negative_blank_chikv_stfd_visit_g) | isPos(negative_repeat_chikv_stfd_visit_g) | isPos(blank_pos_chikv_stfd_visit_g)| isPos(blank_blank_chikv_stfd_visit_g) |isPos(repeat_pos_chikv_stfd_visit_g)| isPos(repeat_blank_chikv_stfd_visit_g) | isPos(repeat_repeat_chikv_stfd_visit_g)| isPos(chikv_igm_sample_g), 1, NA)
  
  R01_lab_results_wide$chikv_igm_sample_p<-NA
  R01_lab_results_wide$chikv_igm_sample_h<-NA
  R01_lab_results_wide$denv_igm_sample_p<-NA
  R01_lab_results_wide$denv_igm_sample_h<-NA
  
  detach(R01_lab_results_wide)
##clean up database
    igm_sample<-R01_lab_results_wide[ , grepl("person_id|redcap_event_name|denv_igm_sample|chikv_igm_sample|result_igg_|result_igm|result_pcr_|symptom|temp|serum_stfd" , names(R01_lab_results_wide) ) ]
    igm_sample<-igm_sample[ , !grepl("u24|tempus|tech|date|oth" , names(igm_sample) ) ]
    attach(igm_sample)
  
  #order
    igm_sample<-igm_sample[,order(colnames(igm_sample))]
    
    igm_sample<-igm_sample[order(-(grepl('_g$', names(igm_sample)))+1L)]
    igm_sample<-igm_sample[order(-(grepl('_h$', names(igm_sample)))+1L)]
    igm_sample<-igm_sample[order(-(grepl('_f$', names(igm_sample)))+1L)]
    igm_sample<-igm_sample[order(-(grepl('_e$', names(igm_sample)))+1L)]
    igm_sample<-igm_sample[order(-(grepl('_d$', names(igm_sample)))+1L)]
    igm_sample<-igm_sample[order(-(grepl('_c$', names(igm_sample)))+1L)]
    igm_sample<-igm_sample[order(-(grepl('_b$', names(igm_sample)))+1L)]
    igm_sample<-igm_sample[order(-(grepl('_a$', names(igm_sample)))+1L)]
    igm_sample<-igm_sample[order(-(grepl('_p$', names(igm_sample)))+1L)]
    igm_sample<-igm_sample[order(-(grepl('person_id', names(igm_sample)))+1L)]
  
    nameVec <- names(igm_sample)
    v.names=c('chikv_igm_sample', 'denv_igm_sample', 'result_igg_chikv_kenya', 'result_igg_chikv_stfd', 'result_igg_denv_kenya', 'result_igg_denv_stfd', 'result_igm_chikv_kenya', 'result_igm_chikv_stfd', 'result_igm_denv_kenya', 'result_igm_denv_stfd', 'result_pcr_chikv_kenya', 'result_pcr_chikv_stfd', 'result_pcr_denv_kenya', 'result_pcr_denv_stfd', 'serum_stfd', 'symptoms', 'symptoms_aic', 'temp')
    
  #reshape
    igm_sample_long<-reshape(igm_sample, idvar = "person_id", varying = 2:163,  direction = "long", timevar = "visit", times = c("_p", "_a", "_b", "_c", "_d", "_e", "_f", "_g", "_h"), v.names=v.names)
    igm_sample_long <-igm_sample_long[!sapply(igm_sample_long, function (x) all(is.na(x) | x == ""| x == "NA"))]
    
    igm_sample_long<-igm_sample_long[,order(colnames(igm_sample_long))]
    igm_sample_long<-igm_sample_long[order(-(grepl('igm_sample', names(igm_sample_long)))+1L)]
    igm_sample_long<-igm_sample_long[order(-(grepl('chikv', names(igm_sample_long)))+1L)]
    igm_sample_long<-igm_sample_long[order(-(grepl('denv', names(igm_sample_long)))+1L)]
    igm_sample_long<-igm_sample_long[order(-(grepl('serum', names(igm_sample_long)))+1L)]
    igm_sample_long<-igm_sample_long[order(-(grepl('person_id|visit', names(igm_sample_long)))+1L)]
    
    igm_sample_long<-igm_sample_long[order(igm_sample_long$person_id),]

    igm_sample_long$visit<-gsub("_", "", igm_sample_long$visit)
    
    igm_sample_long <-igm_sample_long[which(igm_sample_long$visit!='p' )  , ]

    
#export to csv
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/gina dabba")
f <- "igm_samples_7-24-17.csv"
write.csv(as.data.frame(igm_sample_long), f, na="")