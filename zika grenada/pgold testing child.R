setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/zika study- grenada/ms zika spectrum of disease")

pgold<-grep("pgold|pcr_positive_zikv_mom|result_zikv_urine_mom.mom|result_zikv_serum_mom.mom|result_flavi_i_igg_elisa.mom",names(ds2),value = T)
pgold_vars<-grep("result|pcr_positive_zikv_mom|result_zikv_urine_mom.mom|result_zikv_serum_mom.mom|result_flavi_i_igg_elisa.mom",pgold,value = T)
#The developing Caribbean island nation of Grenada and Carriacou experienced a large ZIKV outbreak from April 2016 through March 2017, with peak transmission from May 2016 through October 2016.
dem_vars<-c("mother_record_id",'redcap_repeat_instance',"mom_id_orig_study_2.mom","mom_id_orig_study.mom","zikv_exposed_mom",'redcap_event_name.mom')
date_vars<-grep("dob|delivery_date|date_assessment|date_collected|date_urine_collected|date_blood_collected|date.mom|date_collected",names(ds2),value = T)
vars<-append(dem_vars,pgold_vars)
vars<-append(vars,date_vars)
pgold<-ds2[,vars]
pgold_undefined_child<-ds2[is.na(ds2$zikv_exposed_child),vars]
ds2_inventory<-pgold
ds2_inventory <- within(ds2_inventory, redcap_repeat_instance[ds2_inventory$redcap_repeat_instance=="1"] <- "C1")
ds2_inventory <- within(ds2_inventory, redcap_repeat_instance[ds2_inventory$redcap_repeat_instance=="2"] <- "C2")
table(ds2_inventory$redcap_repeat_instance)

##custom extract functions
#post natal visits
Grenada_ZIKV_FU_Study<-read.csv('Grenada ZIKV FU Study.csv',na.strings=c("","NA"))
  Grenada_ZIKV_FU_Study <- Grenada_ZIKV_FU_Study[,colSums(is.na(Grenada_ZIKV_FU_Study))<nrow(Grenada_ZIKV_FU_Study)]#remove empty collumns
  Grenada_ZIKV_FU_Study<-Grenada_ZIKV_FU_Study[rowSums( is.na(Grenada_ZIKV_FU_Study) ) <=1, ]#remove empty rows
  names(Grenada_ZIKV_FU_Study)[1] <- "mother_record_id"#Mother Record ID
  names(Grenada_ZIKV_FU_Study)[names(Grenada_ZIKV_FU_Study)=="Mother.s.Blood.Sample"] <- "blood_sample.mom"
  colnames(Grenada_ZIKV_FU_Study)[2:5] <- paste(colnames(Grenada_ZIKV_FU_Study[,c(2:5)]),'F0', sep = "_")
  names(Grenada_ZIKV_FU_Study)[names(Grenada_ZIKV_FU_Study)=="Child.s.Blood.Sample..C1._F0"] <- "C1"
  names(Grenada_ZIKV_FU_Study)[names(Grenada_ZIKV_FU_Study)=="Child.s.Blood.Sample..C2._F0"] <- "C2"
  #View(Grenada_ZIKV_FU_Study)
  library(reshape2)
  Grenada_ZIKV_FU_Study_wide<-melt(Grenada_ZIKV_FU_Study,na.rm = TRUE,value.name = 'blood_sample_F0',id.vars = c('mother_record_id','Date.Collected_F0'),measure.vars = c('C1','C2'))
  table(Grenada_ZIKV_FU_Study_wide$variable)
  names(Grenada_ZIKV_FU_Study_wide)[names(Grenada_ZIKV_FU_Study_wide)=="variable"] <- "redcap_repeat_instance"
  ds2_inventory<-merge(ds2_inventory,Grenada_ZIKV_FU_Study_wide,by = c('mother_record_id','redcap_repeat_instance'),all = TRUE)#additional inventory samples that are not matched with c2.
#2nd and 3rd follow up 
Grenada_Neurodevelopment_ZIKV_C<-read.csv('Grenada Neurodevelopment ZIKV C.csv',na.strings=c("","NA"))
  Grenada_Neurodevelopment_ZIKV_C$followup<-substring(Grenada_Neurodevelopment_ZIKV_C$New.ID.Code, 8, 9)
  Grenada_Neurodevelopment_ZIKV_C$event<-substring(Grenada_Neurodevelopment_ZIKV_C$New.ID.Code, 6, 7)
  Grenada_Neurodevelopment_ZIKV_C <- within(Grenada_Neurodevelopment_ZIKV_C, event[Grenada_Neurodevelopment_ZIKV_C$event=="MF"] <- "M")
  Grenada_Neurodevelopment_ZIKV_C <- Grenada_Neurodevelopment_ZIKV_C[,colSums(is.na(Grenada_Neurodevelopment_ZIKV_C))<nrow(Grenada_Neurodevelopment_ZIKV_C)]#remove empty collumns
  Grenada_Neurodevelopment_ZIKV_C[Grenada_Neurodevelopment_ZIKV_C==""] <- NA#replace blank with NA
  Grenada_Neurodevelopment_ZIKV_C<-Grenada_Neurodevelopment_ZIKV_C[rowSums( is.na(Grenada_Neurodevelopment_ZIKV_C)) <=1, ]#remove empty rows
  
  names(Grenada_Neurodevelopment_ZIKV_C)[3] <- "mother_record_id"#Mother Record ID
  Grenada_Neurodevelopment_ZIKV_C<-Grenada_Neurodevelopment_ZIKV_C[,3:9]
  names(Grenada_Neurodevelopment_ZIKV_C)[5] <- "notes"
  colnames(Grenada_Neurodevelopment_ZIKV_C)[2:7] <- paste(colnames(Grenada_Neurodevelopment_ZIKV_C[,c(2:7)]),'Neurod', sep = "_")
  #View(Grenada_Neurodevelopment_ZIKV_C)
  
  Grenada_Neurodevelopment_ZIKV_C <- within(Grenada_Neurodevelopment_ZIKV_C, followup_Neurod[Grenada_Neurodevelopment_ZIKV_C$followup_Neurod=="0"] <- "F0")
  
  Grenada_Neurodevelopment_ZIKV_C_wide<-spread(Grenada_Neurodevelopment_ZIKV_C,followup_Neurod,followup_Neurod,fill='0')
  Grenada_Neurodevelopment_ZIKV_C_wide <- within(Grenada_Neurodevelopment_ZIKV_C_wide, F0[Grenada_Neurodevelopment_ZIKV_C_wide$F0=="F0"] <- 1)
  Grenada_Neurodevelopment_ZIKV_C_wide <- within(Grenada_Neurodevelopment_ZIKV_C_wide, F1[Grenada_Neurodevelopment_ZIKV_C_wide$F1=="F1"] <- 1)
  Grenada_Neurodevelopment_ZIKV_C_wide <- within(Grenada_Neurodevelopment_ZIKV_C_wide, F2[Grenada_Neurodevelopment_ZIKV_C_wide$F2=="F2"] <- 1)
  Grenada_Neurodevelopment_ZIKV_C_wide <- within(Grenada_Neurodevelopment_ZIKV_C_wide, F3[Grenada_Neurodevelopment_ZIKV_C_wide$F3=="F3"] <- 1)
  colnames(Grenada_Neurodevelopment_ZIKV_C_wide)[7:10] <- paste('child_blood',colnames(Grenada_Neurodevelopment_ZIKV_C_wide[,c(7:10)]), sep = "_")
  names(Grenada_Neurodevelopment_ZIKV_C_wide)[names(Grenada_Neurodevelopment_ZIKV_C_wide)=="event_Neurod"] <- "redcap_repeat_instance"
  ds2_inventory<-merge(ds2_inventory,Grenada_Neurodevelopment_ZIKV_C_wide,by = c('mother_record_id','redcap_repeat_instance'),all = TRUE)

#the merged pgold data with inventory
  names(ds2_inventory)[names(ds2_inventory)=="mom_id_orig_study_2.mom"] <- "mom_surveillance_cohort_id"
  names(ds2_inventory)[names(ds2_inventory)=="mom_id_orig_study.mom"] <- "mom_febrile_cohort_id"
  write.csv(ds2_inventory,"pgold_inventory.csv",na='')

#child
    ds2_inventory<-ds2_inventory[ds2_inventory$redcap_repeat_instance=='C1'|ds2_inventory$redcap_repeat_instance=='C2',]
  
    table(ds2_inventory$blood_sample_F0,ds2_inventory$redcap_repeat_instance, exclude = NULL)
    table(ds2_inventory$child_blood_F0,ds2_inventory$redcap_repeat_instance, exclude = NULL)
    table(ds2_inventory$child_blood_F1,ds2_inventory$redcap_repeat_instance, exclude = NULL)
    table(ds2_inventory$child_blood_F2,ds2_inventory$redcap_repeat_instance, exclude = NULL)
    table(ds2_inventory$child_blood_F3,ds2_inventory$redcap_repeat_instance, exclude = NULL)

    ds2_inventory$child_blood_F0<-as.integer(ds2_inventory$child_blood_F0)
    

    table(ds2_inventory$child_blood_F0,ds2_inventory$result_zikv_igg_pgold.pn,exclude = NULL)
    table(ds2_inventory$blood_sample_F0,ds2_inventory$result_zikv_igg_pgold.pn,exclude = NULL)

    table(ds2_inventory$child_blood_F1,ds2_inventory$result_zikv_igg_pgold.12,exclude = NULL)
    ds2_inventory <- within(ds2_inventory, result_zikv_igg_pgold.12[is.na(ds2_inventory$result_zikv_igg_pgold.12)] <- 99)
    
    
    pgold_f1<-ds2_inventory[which(ds2_inventory$child_blood_F1==1 & ds2_inventory$result_zikv_igg_pgold.12==99),c('mother_record_id','child_blood_F1','result_zikv_igg_pgold.12','delivery_date.pn','delivery_date_2.12','Date.of.Collection.B.S._Neurod','child_dob.pn','child_dob.12','child_dob.24.x')]
    write.csv(pgold_f1,'pgold_f1.csv')

    
    table(ds2_inventory$child_blood_F2,ds2_inventory$result_zikv_igg_pgold.24.x,exclude = NULL)
    ds2_inventory <- within(ds2_inventory, result_zikv_igg_pgold.24.x[is.na(ds2_inventory$result_zikv_igg_pgold.24.x)] <- 99)
    pgold_f2<-ds2_inventory[which(ds2_inventory$child_blood_F2==1&ds2_inventory$result_zikv_igg_pgold.24.x==99),c('mother_record_id','child_blood_F2','result_zikv_igg_pgold.24.x','delivery_date.pn','delivery_date_2.12','Date.of.Collection.B.S._Neurod')]
    write.csv(pgold_f2,'pgold_f2.csv')
    
    table(ds2_inventory$child_blood_F3,ds2_inventory$result_zikv_igg_pgold.27,exclude = NULL)
    
    #dob
    ds2_inventory$child_dob<-ds2_inventory$delivery_date.pn
    ds2_inventory$child_dob[is.na(ds2_inventory$child_dob)]<-ds2_inventory$delivery_date_2.12[is.na(ds2_inventory$child_dob)]
    ds2_inventory$child_dob[is.na(ds2_inventory$child_dob)]<-ds2_inventory$delivery_date_2.24.x[is.na(ds2_inventory$child_dob)]
    ds2_inventory$Child.D.O.B._Neurod<-as.Date(ds2_inventory$Child.D.O.B._Neurod,format='%m/%d/%y')
    ds2_inventory$child_dob[is.na(ds2_inventory$child_dob)]<-as.Date(ds2_inventory$Child.D.O.B._Neurod[is.na(ds2_inventory$child_dob)],format='%y/%m/%d')
    table(ds2_inventory$child_dob)
    ds2_inventory$child_dob[ds2_inventory$child_dob==17141|ds2_inventory$child_dob==17199|ds2_inventory$child_dob==17302]<-NA

#dob to sample collection    
    #f0
      ds2_inventory$months_birth_f0_sample<-                                            as.Date(ds2_inventory$Date.Collected_F0,format='%d/%m/%y')- as.Date(ds2_inventory$child_dob,format='%Y-%m-%d')
      ds2_inventory$months_birth_f0_sample[is.na(ds2_inventory$months_birth_f0_sample)&!is.na(ds2_inventory$child_blood_F0)]<- as.Date(ds2_inventory$Date.of.Collection.B.S._Neurod[is.na(ds2_inventory$months_birth_f0_sample)],format='%m/%d/%y')- as.Date(ds2_inventory$Child.D.O.B._Neurod[is.na(ds2_inventory$months_birth_f0_sample)&!is.na(ds2_inventory$child_blood_F0)],format='%m/%d/%y')
      
      ds2_inventory$months_birth_f0_sample<-round(ds2_inventory$months_birth_f0_sample/30,0)
      table(ds2_inventory$months_birth_f0_sample,exclude = NULL)
    #f1
      ds2_inventory$months_birth_f1_sample[!is.na(ds2_inventory$child_blood_F1)]<-round((as.Date(ds2_inventory$Date.of.Collection.B.S._Neurod[!is.na(ds2_inventory$child_blood_F1)],format='%d/%m/%y')- as.Date(ds2_inventory$child_dob[!is.na(ds2_inventory$child_blood_F1)],format='%Y-%m-%d'))/30,0)
    #f2
      ds2_inventory$months_birth_f2_sample[!is.na(ds2_inventory$child_blood_F2)]<-round((as.Date(ds2_inventory$Date.of.Collection.B.S._Neurod[!is.na(ds2_inventory$child_blood_F2)],format='%d/%m/%y')- as.Date(ds2_inventory$child_dob[!is.na(ds2_inventory$child_blood_F2)],format='%Y-%m-%d'))/30,0)
      table(ds2_inventory$months_birth_f2_sample,ds2_inventory$child_blood_F2,exclude = NULL)
      
    #f3
      ds2_inventory$months_birth_f3_sample[!is.na(ds2_inventory$child_blood_F3)]<-round((as.Date(ds2_inventory$Date.of.Collection.B.S._Neurod[!is.na(ds2_inventory$child_blood_F3)],format='%d/%m/%y')- as.Date(ds2_inventory$child_dob[!is.na(ds2_inventory$child_blood_F3)],format='%Y-%m-%d'))/30,0)
      table(ds2_inventory$months_birth_f3_sample)
      
# pgold results
    table(ds2_inventory$redcap_repeat_instance)
    library(reshape2)
    ds2_inventory_pgold<-melt(ds2_inventory,na.rm = FALSE,value.name = 'pgold_result_child',measure.vars = c('result_zikv_igg_pgold.pn','result_zikv_igg_pgold.12','result_zikv_igg_pgold.24.y','result_zikv_igg_pgold.27','result_zikv_igg_pgold.30'),
                              id.vars = c('mother_record_id','redcap_repeat_instance','result_avidity_denv_igg_pgold.pn'))
    ds2_inventory_long<-melt(ds2_inventory,na.rm = FALSE,value.name = 'blood_samples_child',measure.vars = c('child_blood_F0','blood_sample_F0','child_blood_F1','child_blood_F2','child_blood_F3'),
                              id.vars = c('mother_record_id','redcap_repeat_instance','months_birth_f0_sample','months_birth_f1_sample','months_birth_f2_sample','months_birth_f3_sample','result_avidity_denv_igg_pgold.pn'))
    table(ds2_inventory_long$variable,ds2_inventory_long$blood_samples_child)
    ds2_inventory_pgold_sample<-merge(ds2_inventory_pgold,ds2_inventory_long,by=c('mother_record_id','redcap_repeat_instance'))
    table(ds2_inventory_pgold_sample$variable.x, ds2_inventory_pgold_sample$blood_samples_child,ds2_inventory_pgold_sample$pgold_result_child,exclude = NULL)
    
    table(ds2_inventory_pgold$pgold_result_child,exclude = NULL)
    table(ds2_inventory_pgold$pgold_result_child,ds2_inventory_pgold$result_avidity_denv_igg_pgold.pn,exclude = NULL)
    table(ds2_inventory_pgold$pgold_result_child,ds2_inventory_pgold$result_avidity_denv_igg_pgold.pn,ds2_inventory_pgold$blood_sample_F0,exclude = NULL)
    
    table(ds2_inventory_pgold$pgold_result_child,ds2_inventory_pgold$blood_sample_F0,exclude = NULL)
    
    table(ds2_inventory_pgold$pgold_result_child,ds2_inventory_pgold$child_blood_F0,exclude = NULL)
    table(ds2_inventory_pgold$pgold_result_child,ds2_inventory_pgold$child_blood_F1,exclude = NULL)
    table(ds2_inventory_pgold$pgold_result_child,ds2_inventory_pgold$child_blood_F2,exclude = NULL)
    table(ds2_inventory_pgold$pgold_result_child,ds2_inventory_pgold$child_blood_F3,exclude = NULL)
    
