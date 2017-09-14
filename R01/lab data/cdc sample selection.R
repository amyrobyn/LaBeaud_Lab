#Samples to send to CDC:
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long")
load("R01_lab_results.backup.rda")
R01_lab_results$id_cohort<-substr(R01_lab_results$person_id, 2, 2)
R01_lab_results$id_city<-substr(R01_lab_results$person_id, 1, 1)

#any AIC seroconverters in the last year, positive samples only (plus a few negatives for QC testing)
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
    seroconverter_long <- within(seroconverter_long, visit[visit=="ab_"] <- "visit_b_arm_1")
    seroconverter_long <- within(seroconverter_long, visit[visit=="bc_"] <- "visit_c_arm_1")
    seroconverter_long <- within(seroconverter_long, visit[visit=="cd_"] <- "visit_d_arm_1")
    seroconverter_long <- within(seroconverter_long, visit[visit=="de_"] <- "visit_e_arm_1")
    seroconverter_long <- within(seroconverter_long, visit[visit=="ef_"] <- "visit_f_arm_1")
    seroconverter_long <- within(seroconverter_long, visit[visit=="fg_"] <- "visit_g_arm_1")
    seroconverter_long <- within(seroconverter_long, visit[visit=="gh_"] <- "visit_h_arm_1")
    seroconverter_long$redcap_event_name<-seroconverter_long$visit
    names(seroconverter_long)[names(seroconverter_long) == 'denv_kenya_igg'] <- 'seroc_denv_kenya_igg'
    names(seroconverter_long)[names(seroconverter_long) == 'chikv_kenya_igg'] <- 'seroc_chikv_kenya_igg'
    names(seroconverter_long)[names(seroconverter_long) == 'denv_stfd_igg'] <- 'seroc_denv_stfd_igg'
    names(seroconverter_long)[names(seroconverter_long) == 'chikv_stfd_igg'] <- 'seroc_chikv_stfd_igg'
    
    
    seroconverter_long <- merge(seroconverter_long, R01_lab_results,  by=c("person_id", "redcap_event_name"), all = TRUE)
    #keep only aic
    table(seroconverter_long$id_cohort)
      aic_seroconverters<-seroconverter_long[which(seroconverter_long$id_cohort=="F" )  , ]
    #keep only seroconverters
        aic_seroconverters<-aic_seroconverters[which(aic_seroconverters$seroc_chikv_kenya_igg==1|aic_seroconverters$seroc_denv_kenya_igg==1|aic_seroconverters$seroc_chikv_stfd_igg==1|aic_seroconverters$seroc_denv_stfd_igg==1 )  , ]
    #keep only the last year
        library("lubridate")
        aic_seroconverters$interview_date_aic <-ymd(aic_seroconverters$interview_date_aic)
        aic_seroconverters$this_year<-aic_seroconverters$interview_date_aic>as.Date("2016-02-02") 
        table(aic_seroconverters$this_year)
        table(aic_seroconverters$this_year, aic_seroconverters$interview_date_aic)
        aic_seroconverters<-aic_seroconverters[which(aic_seroconverters$this_year ==TRUE)  , ]
        table(aic_seroconverters$this_year, aic_seroconverters$interview_date_aic)
        table(aic_seroconverters$person_id, aic_seroconverters$redcap_event_name)
        aic_seroconverters_short<-aic_seroconverters[, grepl("person_id|redcap_event_name|date|result_igg|seroc|igg_antigen|igg_value|id_city|id_cohort", names(aic_seroconverters))]
        aic_seroconverters_short<-aic_seroconverters_short[, !grepl("malaria|micro|peds|u24|other|birth", names(aic_seroconverters_short))]
        aic_seroconverters_short<-aic_seroconverters_short[,order(colnames(aic_seroconverters_short))]
        aic_seroconverters_short<-aic_seroconverters_short[order(-(grepl('id', names(aic_seroconverters_short)))+1L)]
        aic_seroconverters_short<-aic_seroconverters_short[order(-(grepl('person_id|redcap|result|sero', names(aic_seroconverters_short)))+1L)]
        
      #export to csv
      setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long")
      f <- "cdc_samples_aic.csv"
      write.csv(as.data.frame(aic_seroconverters_short), f , na = "")
#All HCC positives for prevalence confirmation
    hcc_pos<- R01_lab_results[which(R01_lab_results$id_cohort=="C" )  , ]
    hcc_pos<-hcc_pos[, grepl("person_id|redcap_event_name|date|result_igg|result_pcr|igg_antigen|igg_value|id_city|id_cohort", names(hcc_pos))]
    hcc_pos<-hcc_pos[, !grepl("malaria|micro|peds|u24|ufi|aic|other|birth|serum|cdna|urine|submission", names(hcc_pos))]
    hcc_pos<-hcc_pos[,order(colnames(hcc_pos))]
    hcc_pos<-hcc_pos[order(-(grepl('id|redcap|result', names(hcc_pos)))+1L)]
#denv
    hcc_pos_denv<- hcc_pos[which(hcc_pos$result_igg_denv_kenya==1|hcc_pos$result_igg_denv_stfd==1 )  , ]
    hcc_pos_denv<-hcc_pos_denv[, !grepl("chikv", names(hcc_pos_denv))]
    
#chikv
    hcc_pos_chikv<- hcc_pos[which(hcc_pos$result_igg_chikv_kenya==1|hcc_pos$result_igg_chikv_stfd==1 )  , ]
    hcc_pos_chikv<-hcc_pos_chikv[, !grepl("denv", names(hcc_pos_chikv))]
    
#All discordant HCC positives for prevalence confirmation
    hcc_pos_denv$discordant_denv<-ifelse(hcc_pos_denv$result_igg_denv_kenya != hcc_pos_denv$result_igg_denv_stfd & !is.na(hcc_pos_denv$result_igg_denv_stfd) & !is.na(hcc_pos_denv$result_igg_denv_kenya), 1,0)
    hcc_pos_chikv$discordant_chikv<-ifelse(hcc_pos_chikv$result_igg_chikv_kenya != hcc_pos_chikv$result_igg_chikv_stfd & !is.na(hcc_pos_chikv$result_igg_chikv_stfd) & !is.na(hcc_pos_chikv$result_igg_chikv_kenya), 1,0)

    table(hcc_pos_denv$result_igg_denv_kenya, hcc_pos_denv$result_igg_denv_stfd, exclude = NULL)
    table(hcc_pos_denv$discordant_denv)
    hcc_discordant_denv<- hcc_pos_denv[which(hcc_pos_denv$discordant_denv==1 )  , ]
    table(hcc_discordant_denv$id_city)
    64+398
    
    table(hcc_pos_chikv$result_igg_chikv_kenya, hcc_pos_chikv$result_igg_chikv_stfd, exclude = NULL)
    table(hcc_pos_chikv$discordant_chikv)
    hcc_discordant_chikv<- hcc_pos_chikv[which(hcc_pos_chikv$discordant_chikv==1 )  , ]
    table(hcc_discordant_chikv$id_city)

    #total n =     
      561 + 807    
      
both<-merge(hcc_discordant_chikv, hcc_discordant_denv, by=c("person_id", "redcap_event_name", "id_city"), all = TRUE, suffixes = c(".chikv", ".denv"))
table(both$discordant_chikv, both$discordant_denv, exclude = NULL)
both<-both[,order(colnames(both))]
both<-both[order(-(grepl('antigen', names(both)))+1L)]
both<-both[order(-(grepl('id_city|result_igg', names(both)))+1L)]
both<-both[order(-(grepl('discordant', names(both)))+1L)]
both<-both[order(-(grepl('person_id|redcap_event_name', names(both)))+1L)]

  #export to csv
    setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long")
    f <- "cdc_samples_hcc_denv.csv"
    write.csv(as.data.frame(hcc_pos_denv), f , na = "")

    setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long")
    f <- "cdc_samples_hcc_chikv.csv"
    write.csv(as.data.frame(hcc_pos_chikv), f , na = "")
    
    
    setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long")
    f <- "cdc_samples_hcc_both_chikv_denv.csv"
    write.csv(as.data.frame(both), f , na = "")
    
    
    