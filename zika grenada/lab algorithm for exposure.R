# zikv exposure -------------------------------------------------------------------
    ds2$pcr_positive_zikv_mom<-NA
    ds2 <- within(ds2, pcr_positive_zikv_mom[ds2$result_zikv_urine_mom.mom=="Negative"|ds2$result_zikv_serum_mom.mom=="Negative"] <- "Negative")
    ds2 <- within(ds2, pcr_positive_zikv_mom[ds2$result_zikv_urine_mom.mom=="Positive"|ds2$result_zikv_serum_mom.mom=="Positive"] <- "Positive")
    
    table(ds2$pcr_positive_zikv_mom, ds2$redcap_event_name.mom, exclude = NULL)
    table(ds2$zikv_exposed_mom,ds2$pcr_positive_denv_mom)

    source("C:/Users/amykr/Documents/GitHub/LaBeaud_lab/zika grenada/maternal_exposure_strata_3.R")#change to maternal_exposure_strata_2.R to switch strata for total analysis.

    subset(ds2, pcr_positive_zikv_mom == 'Positive', c(mom_id_orig_study_2.mom,mom_id_orig_study.mom,mother_record_id,zikv_exposed_mom,pcr_positive_zikv_mom,result_zikv_igg_pgold.mom,result_zikv_igg_pgold_fu.mom))
    table(ds2$mom_id_orig_study_2.mom)
    
    table(ds2$zikv_exposed_mom,ds2$result_zikv_igg_pgold.pn, exclude = NULL)
    table(ds2$zikv_exposed_mom,ds2$result_zikv_igg_pgold.12, exclude = NULL)
    ds2$date_assessment.pn<-as.Date(ds2$date_assessment.pn,format='%Y-%m-%d')
    ds2$date_assessment_2.12<-as.Date(ds2$date_assessment_2.12,format='%Y-%m-%d')
    
    ds2$days_pn_12<-as.numeric(round((as.Date(as.character(ds2$date_assessment_2.12))-as.Date(as.character(ds2$date_assessment.pn)))/31,1))
    mom_avidity<-subset(ds2, is.na(ds2$result_zikv_igg_pgold.mom)&ds2$result_zikv_igg_pgold_fu.mom=="Positive"&ds2$result_avidity_zikv_igg_pgold_fu.mom=="less than 6 months", select=c(mother_record_id,redcap_repeat_instance,days_pn_12,date_assessment_2.12,date_assessment.pn,result_avidity_zikv_igg_pgold_fu.mom,result_zikv_igg_pgold.mom,result_zikv_igg_pgold_fu.mom,pcr_positive_zikv_mom))
    write.csv(mom_avidity,"avidity.csv")
    
    mom_postnatal<-subset(ds2, ds2$result_zikv_igg_pgold.mom=="Negative", select=c(mother_record_id,redcap_repeat_instance,days_pn_12,date_assessment_2.12,date_assessment.pn,result_avidity_zikv_igg_pgold_fu.mom,result_zikv_igg_pgold.mom,result_zikv_igg_pgold_fu.mom,pcr_positive_zikv_mom))
    write.csv(mom_postnatal,"mom_postnatal.csv")
    table(ds2$result_zikv_igg_pgold.mom,ds2$result_zikv_igg_pgold_fu.mom,exclude = NULL)
    
    table(ds2$zikv_exposed_mom,ds2$result_avidity_zikv_igg_pgold.mom,exclude=NULL)
    table(ds2$zikv_exposed_mom,ds2$result_avidity_zikv_igg_pgold_fu.mom,exclude=NULL)
    
    table(ds2$result_zikv_igg_pgold_fu.mom,ds2$result_zikv_igg_pgold.mom,exclude = NULL)
    
    table(ds2$zikv_exposed_mom,ds2$redcap_repeat_instance, exclude = NULL)
    table(ds2$pcr_positive_zikv_mom=="Positive"|ds2$result_zikv_igg_pgold.mom=="Positive",ds2$cohort___1.mom,ds2$redcap_repeat_instance, exclude = NULL)
    table(ds2$pcr_positive_zikv_mom=="Positive"|ds2$result_zikv_igg_pgold.mom=="Positive",ds2$cohort___2.mom,ds2$redcap_repeat_instance, exclude = NULL)
    
#child zikv exposure
    ds2$zikv_exposed_child<-NA
    ds2 <- within(ds2, zikv_exposed_child[ds2$result_zikv_igg_pgold.pn=="Negative"|ds2$result_zikv_igg_pgold.12=="Negative"] <- "child ZIKV Unexposed")
    ds2 <- within(ds2, zikv_exposed_child[ds2$result_zikv_igg_pgold.pn=="Positive"|ds2$result_zikv_igg_pgold.12=="Positive"] <- "child ZIKV Exposed")
    
    ds2$cohort<-NA
    ds2 <- within(ds2, cohort[ds2$cohort___3.mom=="Checked"] <- "Zika Follow Up")
    ds2 <- within(ds2, cohort[ds2$cohort___1.mom=="Checked"] <- "Original Pregnancy")
    ds2 <- within(ds2, cohort[ds2$cohort___2.mom=="Checked"] <- "Febrile Zika")
    
    table(ds2$child_delivery,ds2$redcap_repeat_instance,ds2$cohort,ds2$zikv_exposed_mom,exclude = NULL)
    #drop PZ349, accidentally entered 2x in redcap. jonathan and nikita will merge. 
    ds2<-ds2[!(ds2$child_delivery=="Singleton" & ds2$redcap_repeat_instance==2),]
    table(ds2$child_delivery,ds2$redcap_repeat_instance,ds2$cohort,ds2$zikv_exposed_mom,exclude = NULL)
    
    table(ds2$zikv_exposed_mom,ds2$result_zikv_igg_pgold.pn,exclude = NULL)
    table(ds2$zikv_exposed_mom,ds2$result_zikv_igg_pgold.12,exclude = NULL)

    addmargins(table(round(ds2$child_calculated_age.pn,0)))
    addmargins(table(round(ds2$child_calculated_age_2.12,0)))

    addmargins(table(round(ds2$child_age_2_2.12,0),ds2$zikv_exposed_mom))
    addmargins(table(ds2$gender.pn,ds2$zikv_exposed_mom,exclude = NULL))
    addmargins(table(ds2$gender_2.12,ds2$zikv_exposed_mom))
    (table(ds2$zikv_exposed_mom,ds2$maternal_zikv_exposure.mom, exclude=NULL))
    
    #change names to be equal for zikv_exposed_mom and maternal_zikv_exposure.mom  
      ds2 <- within(ds2, maternal_zikv_exposure.mom[ds2$maternal_zikv_exposure.mom=="ZIKV Exposed during pregnancy"] <- "mom_ZIKV_Exposed_during_pregnancy")
      ds2 <- within(ds2, maternal_zikv_exposure.mom[ds2$maternal_zikv_exposure.mom=="ZIKV Exposure possible during pregnancy"] <- "mom_ZIKV_Exposure_possible_during_pregnancy")
      ds2 <- within(ds2, maternal_zikv_exposure.mom[ds2$maternal_zikv_exposure.mom=="ZIKV Unexposed during pregnancy"] <- "mom_zikv_Unexposed_during_pregnancy")
      ds2 <- within(ds2, zikv_exposed_mom[is.na(ds2$zikv_exposed_mom)] <- "unknown")
    table(ds2$zikv_exposed_mom,ds2$maternal_zikv_exposure.mom)
  #write to csv
      write.csv(ds2[c('mother_record_id','mom_id_orig_study.mom','mom_id_orig_study_2.mom','cohort___1.mom','cohort___2.mom','cohort___3.mom','redcap_repeat_instance','zikv_exposed_mom','maternal_zikv_exposure.mom','result_zikv_urine_mom.mom','result_zikv_serum_mom.mom','result_zikv_igg_pgold_fu.mom','result_zikv_igg_pgold.mom','pcr_positive_zikv_mom')],'zikv_exposure.csv', na='',row.names = FALSE,quote = FALSE)
      
  #denv exposure mom
    ds2$pcr_positive_denv_mom<-NA
    ds2 <- within(ds2, pcr_positive_denv_mom[ds2$result_denv_urine_mom.mom=="Negative"|ds2$result_denv_serum_mom.mom=="Negative"] <- "Negative")
    ds2 <- within(ds2, pcr_positive_denv_mom[ds2$result_denv_urine_mom.mom=="Positive"|ds2$result_denv_serum_mom.mom=="Positive"] <- "Positive")
    
    ds2$denv_exposed_mom<-NA
    ds2 <- within(ds2, denv_exposed_mom[ds2$result_denv_igg_pgold.mom=="Negative"|result_denv_igg_pgold_fu.mom=="Negative"] <- "Mom denv Unexposed")
    ds2 <- within(ds2, denv_exposed_mom[ds2$pcr_positive_denv_mom=="Positive"|ds2$result_denv_igg_pgold.mom=="Positive"|result_denv_igg_pgold_fu.mom=="Positive"] <- "mom denv Exposed")
    
    table(ds2$denv_exposed_mom,ds2$redcap_repeat_instance, exclude = NULL)
    addmargins(table(ds2$cohort,ds2$zikv_exposed_mom,ds2$redcap_repeat_instance,exclude = NULL))
    
#child denv exposure
    ds2$denv_exposed_child<-NA
    ds2 <- within(ds2, denv_exposed_child[ds2$result_denv_igg_pgold.pn=="Negative"|ds2$result_denv_igg_pgold.12=="Negative"] <- "child denv Unexposed")
    ds2 <- within(ds2, denv_exposed_child[ds2$result_denv_igg_pgold.pn=="Positive"|ds2$result_denv_igg_pgold.12=="Positive"] <- "child denv Exposed")


#review the lab assays and algorithms
  #source("C:/Users/amykr/Documents/GitHub/LaBeaud_lab/zika grenada/pgold testing.R")