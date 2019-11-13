eye<-read.csv("C:/Users/amykr/Box Sync/Amy Krystosik's Files/zika study- grenada/eye.csv")
eye<-bind_cols(eye[1:6],eye[104:110])

ds2<-merge(ds2,eye,by.y=c("mother_id","event"),by.x = c("mother_record_id","redcap_repeat_instance"),all.y = TRUE)
ds2$Acuityat50cm_n<-NA
ds2$Acuityat50cm[ds2$Acuityat50cm == "98"] <- NA

ds2 <- within(ds2, Acuityat50cm_n[ds2$Acuityat50cm=="C"] <- 3)
ds2 <- within(ds2, Acuityat50cm_n[ds2$Acuityat50cm=="H"] <- 8)
ds2 <- within(ds2, Acuityat50cm_n[ds2$Acuityat50cm=="I"] <- 9)
ds2 <- within(ds2, Acuityat50cm_n[ds2$Acuityat50cm=="J"] <- 10)
ds2 <- within(ds2, Acuityat50cm_n[ds2$Acuityat50cm=="K"] <- 11)
ds2 <- within(ds2, Acuityat50cm_n[ds2$Acuityat50cm=="L"] <- 12)
ds2 <- within(ds2, Acuityat50cm_n[ds2$Acuityat50cm=="M"] <- 13)
table(ds2$Contrast.Sensitivity)
library(ggpubr)
ggplot(ds2,aes(zikv_exposed_mom,LogMAR))+geom_boxplot()+
  stat_compare_means(size=3,bracket.size = 1,comparisons = list(c("mom_zikv_Unexposed_during_pregnancy","mom_ZIKV_Exposure_possible_during_pregnancy"),
                                                                c("mom_ZIKV_Exposure_possible_during_pregnancy","mom_ZIKV_Exposed_during_pregnancy"),
                                                                c("mom_ZIKV_Exposed_during_pregnancy","mom_zikv_Unexposed_during_pregnancy") )) + 
  stat_compare_means(size=3,label.y = 1.75)

ggplot(ds2,aes(zikv_exposed_mom,Acuityat50cm_n))+geom_boxplot()+
  stat_compare_means(size=3,bracket.size = 1,comparisons = list(c("mom_zikv_Unexposed_during_pregnancy","mom_ZIKV_Exposure_possible_during_pregnancy"),
                                                                 c("mom_ZIKV_Exposure_possible_during_pregnancy","mom_ZIKV_Exposed_during_pregnancy"),
                                                                 c("mom_ZIKV_Exposed_during_pregnancy","mom_zikv_Unexposed_during_pregnancy") )) + 
  stat_compare_means(size=3,label.y = 18)

ggplot(ds2,aes(zikv_exposed_mom,Contrast.Sensitivity))+geom_boxplot()+
  stat_compare_means(size=3,bracket.size = 1,comparisons = list(c("mom_zikv_Unexposed_during_pregnancy","mom_ZIKV_Exposure_possible_during_pregnancy"),
                                                                c("mom_ZIKV_Exposure_possible_during_pregnancy","mom_ZIKV_Exposed_during_pregnancy"),
                                                                c("mom_ZIKV_Exposed_during_pregnancy","mom_zikv_Unexposed_during_pregnancy") )) + 
  stat_compare_means(size=3,label.y = 150)


describe(ds2[2865:2872])
