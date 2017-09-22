#zika study 
#link tetracore results and redcap subjects
library(REDCapR)
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/zika study- grenada")
Redcap.token <- readLines("Redcap.token.zika.txt") # Read API token from folder
REDcap.URL  <- 'https://redcap.stanford.edu/api/'


#export data from redcap to R (must be connected via cisco VPN)
  stfd_zika_pregnancy_cohort <- redcap_read(redcap_uri  = REDcap.URL, token = Redcap.token)$data
  stfd_zika_pregnancy_cohort<-stfd_zika_pregnancy_cohort[ , grepl( "redcap|id" , names(stfd_zika_pregnancy_cohort) ) ]
  stfd_zika_pregnancy_cohort<-stfd_zika_pregnancy_cohort[ , !grepl( "aliq" , names(stfd_zika_pregnancy_cohort) ) ]
#import the tetracore results and sympotatic data
  setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/zika study- grenada/tetra core results/combined")
  symptomatic<-read.csv("All Zika(Febrile&Study)_Asymtomatic_Symptomatic.csv")
  pcr_igm<-read.csv("All Results (Febrile&Study)_PCR&IgM Tetracore.csv")
  pcr_igm$ZIKV_CT<-as.character(pcr_igm$ZIKV_CT)
  pcr_igm <- within(pcr_igm, ZIKV_CT[pcr_igm$ZIKV_CT=="not enough to test"] <- 98)
  pcr_igm <- within(pcr_igm, ZIKV_CT[pcr_igm$ZIKV_CT=="+"] <- 99)
  pcr_igm$ZIKV_CT<-as.numeric(as.character(pcr_igm$ZIKV_CT))

  pcr<-pcr_igm[ , grepl( "ID|CT" , names(pcr_igm) ) ]
  igm_serum<-  subset(pcr_igm, !grepl("Urine|urine", pcr_igm[[5]]), drop = TRUE)
  
  igm_urine<-  subset(pcr_igm, grepl("Urine|urine", pcr_igm[[5]]), drop = TRUE)
  table(igm_urine$IgM_Results_Multiplex_serology)
  
#merge
  merged_pcr<-merge(pcr, stfd_zika_pregnancy_cohort, by.y = "mom_id_orig_study", by.x = "Sample_ID")
    summary(merged_pcr$DENV_CT)
    summary(merged_pcr$ZIKV_CT)
    summary(merged_pcr$CHIKV_CT)

  merged_igm_serum<-merge(igm_serum, stfd_zika_pregnancy_cohort, by.y = "mom_id_orig_study", by.x = "Sample_ID")
  merged_igm_urine<-merge(igm_urine, stfd_zika_pregnancy_cohort, by.y = "mom_id_orig_study", by.x = "Sample_ID")
  merged_symptomatic<-merge(symptomatic, stfd_zika_pregnancy_cohort, by.y = "mom_id_orig_study", by.x = "ï..zika_id_code")
  
  f <- "merged_pcr.csv"
  write.csv(as.data.frame(merged_pcr), f )

  f <- "merged_symptoms.csv"
  write.csv(as.data.frame(merged_symptomatic), f )
  
  f <- "merged_igm_urine.csv"
  write.csv(as.data.frame(merged_igm_urine), f )
  
  f <- "merged_igm_serum.csv"
  write.csv(as.data.frame(merged_igm_serum), f )