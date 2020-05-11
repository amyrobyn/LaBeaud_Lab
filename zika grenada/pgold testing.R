#setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/zika study- grenada/ms zika spectrum of disease")

pgold<-grep("pgold|pcr_positive_zikv_mom|result_zikv_urine_mom.mom|result_zikv_serum_mom.mom|result_flavi_i_igg_elisa.mom",names(ds2),value = T)
pgold_vars<-grep("result|pcr_positive_zikv_mom|result_zikv_urine_mom.mom|result_zikv_serum_mom.mom|result_flavi_i_igg_elisa.mom",pgold,value = T)
#The developing Caribbean island nation of Grenada and Carriacou experienced a large ZIKV outbreak from April 2016 through March 2017, with peak transmission from May 2016 through October 2016.
dem_vars<-c("mother_record_id","mom_id_orig_study_2.mom","mom_id_orig_study.mom","zikv_exposed_mom",'redcap_event_name.mom')
date_vars<-grep("dob|delivery_date|date_assessment|date_collected|date_urine_collected|date_blood_collected|date.mom|date_collected",names(ds2),value = T)
vars<-append(dem_vars,pgold_vars)
vars<-append(vars,date_vars)
pgold<-ds2[,vars]
pgold_undefined_mom<-ds2[is.na(ds2$zikv_exposed_mom),vars]
pgold_undefined_child<-ds2[is.na(ds2$zikv_exposed_child),vars]

ds2_inventory<-pgold

##custom extract functions

#surveillance cohort
Grenada_Orig_Preg_ZIKV<-read.csv('Grenada Orig Preg ZIKV.csv',na.strings=c("","NA"))
names(Grenada_Orig_Preg_ZIKV)[1] <- "mom_id_orig_study_2.mom"#Mother ID number (SURVEILLANCE COHORT)
Grenada_Orig_Preg_ZIKV <- Grenada_Orig_Preg_ZIKV[,colSums(is.na(Grenada_Orig_Preg_ZIKV))<nrow(Grenada_Orig_Preg_ZIKV)]#remove empty collumns
Grenada_Orig_Preg_ZIKV<-Grenada_Orig_Preg_ZIKV[rowSums( is.na(Grenada_Orig_Preg_ZIKV) ) <=1, ]#remove empty rows

#View(Grenada_Orig_Preg_ZIKV)
colnames(Grenada_Orig_Preg_ZIKV)[2:3] <- paste(colnames(Grenada_Orig_Preg_ZIKV[,c(2:3)]),'pre_natal_well', sep = "_")

ds2_inventory<-merge(ds2_inventory,Grenada_Orig_Preg_ZIKV,by = 'mom_id_orig_study_2.mom',all.x = TRUE)
#febrile prenatal moms
Grenada_Febrile_ZIKV_Cohort<-read.csv('Grenada Febrile ZIKV Cohort.csv',na.strings=c("","NA"))
names(Grenada_Febrile_ZIKV_Cohort)[1] <- "mom_id_orig_study.mom"#Mother ID number (FEBRILE COHORT)
Grenada_Febrile_ZIKV_Cohort <- Grenada_Febrile_ZIKV_Cohort[,colSums(is.na(Grenada_Febrile_ZIKV_Cohort))<nrow(Grenada_Febrile_ZIKV_Cohort)]#remove empty collumns
Grenada_Febrile_ZIKV_Cohort<-Grenada_Febrile_ZIKV_Cohort[rowSums( is.na(Grenada_Febrile_ZIKV_Cohort) ) <=1, ]#remove empty rows

#View(Grenada_Febrile_ZIKV_Cohort)
colnames(Grenada_Febrile_ZIKV_Cohort)[2:3] <- paste(colnames(Grenada_Febrile_ZIKV_Cohort[,c(2:3)]),'pre_natal_febrile', sep = "_")

ds2_inventory<-merge(ds2_inventory,Grenada_Febrile_ZIKV_Cohort,by = 'mom_id_orig_study.mom',all.x = TRUE)

#post natal visits
Grenada_ZIKV_FU_Study<-read.csv('Grenada ZIKV FU Study.csv',na.strings=c("","NA"))
Grenada_ZIKV_FU_Study <- Grenada_ZIKV_FU_Study[,colSums(is.na(Grenada_ZIKV_FU_Study))<nrow(Grenada_ZIKV_FU_Study)]#remove empty collumns
Grenada_ZIKV_FU_Study<-Grenada_ZIKV_FU_Study[rowSums( is.na(Grenada_ZIKV_FU_Study) ) <=1, ]#remove empty rows
names(Grenada_ZIKV_FU_Study)[1] <- "mother_record_id"#Mother Record ID
names(Grenada_ZIKV_FU_Study)[names(Grenada_ZIKV_FU_Study)=="Mother.s.Blood.Sample"] <- "blood_sample.mom"
names(Grenada_ZIKV_FU_Study)[names(Grenada_ZIKV_FU_Study)=="Child.s.Blood.Sample..C1."] <- "blood_sample.C1"
names(Grenada_ZIKV_FU_Study)[names(Grenada_ZIKV_FU_Study)=="Child.s.Blood.Sample..C2."] <- "blood_sample.C2"
#View(Grenada_ZIKV_FU_Study)
colnames(Grenada_ZIKV_FU_Study)[2:5] <- paste(colnames(Grenada_ZIKV_FU_Study[,c(2:5)]),'post_natal', sep = "_")

ds2_inventory<-merge(ds2_inventory,Grenada_ZIKV_FU_Study,by = 'mother_record_id',all.x = TRUE)

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

ds2_inventory<-merge(ds2_inventory,Grenada_Neurodevelopment_ZIKV_C,by = 'mother_record_id',all.x = TRUE)

#the merged pgold data with inventory
names(ds2_inventory)[3] <- "mom_surveillance_cohort_id"#Mother ID number (SURVEILLANCE COHORT)
names(ds2_inventory)[2] <- "mom_febrile_cohort_id"#Mother ID number (SURVEILLANCE COHORT)
#View(ds2_inventory)
#write.csv(ds2_inventory,"pgold_inventory.csv",na='')

#lab algorithm sample sizes.
#enrolled prepartum
    table(!is.na(ds2_inventory$mom_febrile_cohort_id)|!is.na(ds2_inventory$mom_surveillance_cohort_id))#enrolled prepartum
    ds2_inventory$prepartum_enrolled_mom<-NA
    ds2_inventory <- within(ds2_inventory, prepartum_enrolled_mom[!is.na(ds2_inventory$mom_febrile_cohort_id)|!is.na(ds2_inventory$mom_surveillance_cohort_id)] <- 1)
    ds2_inventory <- within(ds2_inventory, prepartum_enrolled_mom[is.na(ds2_inventory$mom_febrile_cohort_id)&is.na(ds2_inventory$mom_surveillance_cohort_id)] <- 0)
    table(ds2_inventory$prepartum_enrolled_mom)
    table(!is.na(ds2_inventory$mom_febrile_cohort_id)&!is.na(ds2_inventory$mom_surveillance_cohort_id))#enrolled to both cohorts
    length(unique(ds2_inventory$mom_febrile_cohort_id))+ length(unique(ds2_inventory$mom_surveillance_cohort_id))
    157-2-1#mothers enrolled prepartum - NA for each list - the mom enrolled in both febrile and surveillance.
  #viable samples prepartum
    ds2_inventory$prepartum_blood_sample_mom<-NA
    ds2_inventory <- within(ds2_inventory, prepartum_blood_sample_mom[ds2_inventory$Blood.Sample_pre_natal_well==1|ds2_inventory$Serum.Sample_pre_natal_febrile==1] <- 1)
    ds2_inventory <- within(ds2_inventory, prepartum_blood_sample_mom[ds2_inventory$Blood.Sample_pre_natal_well==0|ds2_inventory$Serum.Sample_pre_natal_febrile==0] <- 0)
    table(ds2_inventory$prepartum_blood_sample_mom,ds2_inventory$prepartum_enrolled_mom==1,exclude = NULL)#moms enrolled prepartum with blood sample

    ds2_inventory$prepartum_urine_sample_mom<-NA
    ds2_inventory <- within(ds2_inventory, prepartum_urine_sample_mom[ds2_inventory$Urine.Sample_pre_natal_febrile==1|ds2_inventory$Urine.Sample_pre_natal_well==1] <- 1)
    ds2_inventory <- within(ds2_inventory, prepartum_urine_sample_mom[ds2_inventory$Urine.Sample_pre_natal_febrile==0|ds2_inventory$Urine.Sample_pre_natal_well==0] <- 0)
    table(ds2_inventory$prepartum_urine_sample_mom,ds2_inventory$prepartum_enrolled_mom==1,exclude = NULL)#moms enrolled prepartum with urine sample
    
  #to be tested pcr
    table(is.na(ds2_inventory$result_zikv_serum_mom.mom)&is.na(ds2_inventory$result_zikv_urine_mom.mom))#moms without pcr results prepartum.
    table(ds2_inventory$prepartum_urine_sample_mom==0 & ds2_inventory$prepartum_blood_sample_mom==0,exclude = NULL)#moms with either blood or urine for pcr prepartum.
    pcr_missing<-ds2_inventory[is.na(ds2_inventory$pcr_positive_zikv_mom)&ds2_inventory$prepartum_enrolled_mom==1, c('mother_record_id','mom_febrile_cohort_id','mom_surveillance_cohort_id',"prepartum_urine_sample_mom",'prepartum_blood_sample_mom','pcr_positive_zikv_mom','result_zikv_serum_mom.mom','result_zikv_urine_mom.mom')]
    write.csv(pcr_missing,"pcr_missing.csv",na='')
    table(ds2_inventory$pcr_positive_zikv_mom, ds2_inventory$prepartum_enrolled_mom,exclude = NULL)#5 prepartum moms with no pcr results.
    table(ds2_inventory$pcr_positive_zikv_mom, ds2_inventory$prepartum_blood_sample_mom,exclude = NULL)#no blood available to be tested.
    table(ds2_inventory$pcr_positive_zikv_mom, ds2_inventory$prepartum_urine_sample_mom,exclude = NULL)#only one urine sample available to be tested
    
  #to be tested Standard elisa igg for flavivirus.
    table(ds2_inventory$result_flavi_i_igg_elisa.mom,ds2_inventory$pcr_positive_zikv_mom,exclude = NULL)
    table(is.na(ds2_inventory$result_flavi_i_igg_elisa.mom))#moms with elisa igg results prepartum.
    table(ds2_inventory$prepartum_blood_sample_mom,ds2_inventory$result_flavi_i_igg_elisa.mom,exclude = NULL)
    flavi_igg_missing<-ds2_inventory[is.na(ds2_inventory$result_flavi_i_igg_elisa.mom)&ds2_inventory$prepartum_enrolled_mom==1, c('mother_record_id','mom_febrile_cohort_id','mom_surveillance_cohort_id',"prepartum_urine_sample_mom",'prepartum_blood_sample_mom','result_flavi_i_igg_elisa.mom','result_zikv_serum_mom.mom','result_zikv_urine_mom.mom')]
    write.csv(flavi_igg_missing,"flavi_igg_missing.csv",na='')
    
  #to be tested pgold elisa igg at prepartum
    table(ds2_inventory$result_zikv_igg_pgold.mom,ds2_inventory$pcr_positive_zikv_mom,exclude = NULL)#6 positive by both pcr and pgold...
    table(ds2_inventory$result_zikv_igg_pgold.mom,ds2_inventory$prepartum_enrolled_mom,exclude = NULL)#to be tested by pgold prepartum.
    pgold_prepartum_missing<-ds2_inventory[is.na(ds2_inventory$result_zikv_igg_pgold.mom) & ds2_inventory$prepartum_enrolled_mom==1, c('mother_record_id','mom_febrile_cohort_id','mom_surveillance_cohort_id',"prepartum_urine_sample_mom",'prepartum_blood_sample_mom','result_zikv_igg_pgold.mom','result_flavi_i_igg_elisa.mom','result_zikv_serum_mom.mom','result_zikv_urine_mom.mom')]
    write.csv(pgold_prepartum_missing,"pgold_prepartum_missing.csv",na='')
    
  #to be tested pgold elisa igg at postpartum
    ds2_inventory$zikv_infected_prepartum<-NA
    ds2_inventory <- within(ds2_inventory, zikv_infected_prepartum[ds2_inventory$result_zikv_igg_pgold.mom=="Negative"] <- 0)
    ds2_inventory <- within(ds2_inventory, zikv_infected_prepartum[ds2_inventory$result_zikv_igg_pgold.mom=="Positive"|ds2_inventory$pcr_positive_zikv_mom=="Positive"] <- 1)
    table(ds2_inventory$zikv_infected_prepartum)
    
    table(ds2_inventory$zikv_infected_prepartum,exclude=NULL)
    ds2_inventory$zikv_infected_prepartum[is.na(ds2_inventory$zikv_infected_prepartum)] <- 99
    
    ##subset to moms not defined prepartum
      postpartum_moms <- subset(ds2_inventory, zikv_infected_prepartum == 0|zikv_infected_prepartum == 99)#subset to moms not defined prepartum
      table(postpartum_moms$result_zikv_igg_pgold_fu.mom,exclude = NULL)

    pgold_post_partum_missing<-postpartum_moms[is.na(postpartum_moms$result_zikv_igg_pgold_fu.mom), c('mother_record_id','mom_febrile_cohort_id','mom_surveillance_cohort_id','blood_sample.mom_post_natal','result_zikv_igg_pgold_fu.mom')]
    write.csv(pgold_post_partum_missing,"pgold_post_partum_missing.csv",na='')
    
  #avidity testing for moms positive at postpartum
    postpartum_moms_pos <- subset(postpartum_moms, result_zikv_igg_pgold_fu.mom=='Positive')#subset to moms positive postpartum
    table(postpartum_moms_pos$result_avidity_zikv_igg_pgold_fu.mom,exclude = NULL)
    pgold_post_partum_avidity_missing<-postpartum_moms_pos[is.na(postpartum_moms_pos$result_avidity_zikv_igg_pgold_fu.mom), c('mother_record_id','mom_febrile_cohort_id','mom_surveillance_cohort_id','blood_sample.mom_post_natal','result_zikv_igg_pgold_fu.mom','result_avidity_zikv_igg_pgold_fu.mom')]
    write.csv(pgold_post_partum_avidity_missing,"pgold_post_partum_avidity_missing.csv",na='')
    
  #delivery within the last 6 months? 
    postpartum_moms$result_zikv_igg_pgold_fu.mom[is.na(postpartum_moms$result_zikv_igg_pgold_fu.mom)] <- 99
    table(postpartum_moms$result_zikv_igg_pgold_fu.mom)
    
    ##subset to moms not defined prepartum and not pgold negative postpartum
    postpartum_moms_undefined <- subset(postpartum_moms, result_zikv_igg_pgold_fu.mom == 'Positive'|result_zikv_igg_pgold_fu.mom == 99)#subset to moms not defined prepartum and not pgold negative postpartum
    table(postpartum_moms_undefined$result_zikv_igg_pgold_fu.mom,exclude = NULL)
    
    library(dplyr)
    postpartum_moms_undefined$Date.Collected_post_natal<-as.Date(postpartum_moms_undefined$Date.Collected_post_natal,format="%d/%m/%y")#sample inventory date.
    postpartum_moms_undefined$date.mom<-as.Date(postpartum_moms_undefined$date.mom,format="%Y-%m-%d")#moms first postnatal visit.
    names(postpartum_moms_undefined)[names(postpartum_moms_undefined)=="date.mom"] <- "post_natal_visit_date.mom"
    names(postpartum_moms_undefined)[names(postpartum_moms_undefined)=="date_collected.mom"] <- "surveillance_visit_date.mom"
    
    table(is.na(postpartum_moms_undefined$Date.Collected_post_natal), postpartum_moms_undefined$blood_sample.mom_post_natal)
    table(is.na(postpartum_moms_undefined$date_blood_collected_f.mom))#febrile prenatal visit data
    table(is.na(postpartum_moms_undefined$date_urine_collected_f.mom))#febrile prenatal visit data
    table(is.na(postpartum_moms_undefined$Date.Collected_post_natal))#prenatal visit data
    dates<-postpartum_moms_undefined[,c('mother_record_id','mom_febrile_cohort_id','mom_surveillance_cohort_id','Date.Collected_post_natal','date_blood_collected_f.mom','date_urine_collected_f.mom','post_natal_visit_date.mom','surveillance_visit_date.mom')]
    
    
    postpartum_moms_undefined$delivery_date.pn<-as.Date(postpartum_moms_undefined$delivery_date.pn,format="%Y-%m-%d")
    table(is.na(postpartum_moms_undefined$delivery_date.pn))
    
    postpartum_moms_undefined$months_btwn_delivery_sample<-(postpartum_moms_undefined$Date.Collected_post_natal-postpartum_moms_undefined$delivery_date.pn)/30
    table(is.na(postpartum_moms_undefined$months_btwn_delivery_sample))
    postpartum_moms_undefined$months_btwn_delivery_sample[is.na(postpartum_moms_undefined$months_btwn_delivery_sample)] <- (postpartum_moms_undefined$post_natal_visit_date.mom[is.na(postpartum_moms_undefined$months_btwn_delivery_sample)]-postpartum_moms_undefined$delivery_date.pn[is.na(postpartum_moms_undefined$months_btwn_delivery_sample)])/30#if the sample inventory date is blank, replace with the first postnatal visit date.
    
    Hmisc::describe(postpartum_moms_undefined$months_btwn_delivery_sample)
  
    postpartum_moms_undefined$six_months_or_less_since_delivery<-NA
    postpartum_moms_undefined <- within(postpartum_moms_undefined, six_months_or_less_since_delivery[postpartum_moms_undefined$months_btwn_delivery_sample<=6] <- 1)
    postpartum_moms_undefined <- within(postpartum_moms_undefined, six_months_or_less_since_delivery[postpartum_moms_undefined$months_btwn_delivery_sample>6] <- 0)
    table(postpartum_moms_undefined$six_months_or_less_since_delivery, postpartum_moms_undefined$blood_sample.mom_post_natal==1,exclude = NULL)
    
    postpartum_moms_undefined<-postpartum_moms_undefined %>%
      select(delivery_date.pn,Date.Collected_post_natal,months_btwn_delivery_sample,blood_sample.mom_post_natal, six_months_or_less_since_delivery,everything())
    
    pgold_post_partum_months<-postpartum_moms_undefined[is.na(postpartum_moms_undefined$result_avidity_zikv_igg_pgold_fu.mom), c('mother_record_id','mom_febrile_cohort_id','mom_surveillance_cohort_id','blood_sample.mom_post_natal','result_zikv_igg_pgold_fu.mom','result_avidity_zikv_igg_pgold_fu.mom','months_btwn_delivery_sample','six_months_or_less_since_delivery','delivery_date.pn','Date.Collected_post_natal','post_natal_visit_date.mom','zikv_infected_prepartum')]
    write.csv(pgold_post_partum_months,"pgold_post_partum_months.csv",na='')
    
#child
    table(ds2_inventory$blood_sample.C1_post_natal)
    table(ds2_inventory$blood_sample.C2_post_natal)