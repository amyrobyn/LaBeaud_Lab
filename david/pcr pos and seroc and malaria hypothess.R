#denv pcr+
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/david coinfectin paper/data")
#load data that has been cleaned previously
load("david_denv_pf_cohort.rda") #load the data from your local directory (this will save you time later rather than always downolading from redcap.)

cases$result_pcr_denv_kenya<-as.numeric(as.character(cases$result_pcr_denv_kenya))
cases$result_pcr_denv_stfd<-as.numeric(as.character(cases$result_pcr_denv_stfd))
cases$pcr_pos<-NA
cases <- within(cases, pcr_pos[cases$result_pcr_denv_kenya=="1"|cases$result_pcr_denv_stfd=="1"] <- "1")

pcr_pos_cohort<-cases[which(cases$result_pcr_denv_kenya==1|cases$result_pcr_denv_stfd==1), ]
table(pcr_pos_cohort$seroc_denv_stfd_igg)
table( pcr_pos_cohort$malaria_pf, exclude= NULL)
table(pcr_pos_cohort$seroc_denv_stfd_igg, pcr_pos_cohort$malaria_pf, exclude= NULL)
