
ggplot(ds2[!is.na(ds2$gender_2.12) & !is.na(ds2$zikv_exposed_mom),],aes(x=gestational_weeks_2_2.12, y=birth_weight.12,color=zikv_exposed_mom))+geom_point()+geom_smooth(method = 'glm')+
  facet_grid('gender_2.12')

sga<-ds2[,c('mother_record_id','redcap_repeat_instance','gestational_weeks_2_2.12','head_circ_birth.12','birth_weight.12','birth_length.12','zikv_exposed_mom','gender_2.12')]
write.csv(sga,'sga.csv')

intergrowth21<-read.csv("C:/Users/amykr/Box Sync/Amy Krystosik's Files/zika study- grenada/gestational anthro compared to intergrowth 21 standards.csv")
ds2<-merge(ds2,intergrowth21,by= c("mother_record_id","redcap_repeat_instance"),all.y = TRUE)

ggplot(ds2[!is.na(ds2$zikv_exposed_mom),],aes(zikv_exposed_mom,g.LengthZScore))+geom_boxplot()+
  stat_compare_means(size=3,bracket.size = 1,comparisons = list(c("mom_zikv_Unexposed_during_pregnancy","mom_ZIKV_Exposure_possible_during_pregnancy"),
                                                                c("mom_ZIKV_Exposure_possible_during_pregnancy","mom_ZIKV_Exposed_during_pregnancy"),
                                                                c("mom_ZIKV_Exposed_during_pregnancy","mom_zikv_Unexposed_during_pregnancy") )) + 
  stat_compare_means(size=3,label.y = 8)

ggplot(ds2[!is.na(ds2$zikv_exposed_mom),],aes(zikv_exposed_mom,g.WeightZScore))+geom_boxplot()+
  stat_compare_means(size=3,bracket.size = 1,comparisons = list(c("mom_zikv_Unexposed_during_pregnancy","mom_ZIKV_Exposure_possible_during_pregnancy"),
                                                                c("mom_ZIKV_Exposure_possible_during_pregnancy","mom_ZIKV_Exposed_during_pregnancy"),
                                                                c("mom_ZIKV_Exposed_during_pregnancy","mom_zikv_Unexposed_during_pregnancy") )) + 
  stat_compare_means(size=3,label.y = 8)

