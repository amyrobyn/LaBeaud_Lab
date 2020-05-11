#intergrowth 21 standard populations. http://intergrowth21.ndog.ox.ac.uk/
  intergrowth21_z<-read.csv("C:/Users/amykr/Box Sync/Amy Krystosik's Files/zika study- grenada/integrowth21-z.csv")
  intergrowth21_z$birth_weight.12<-intergrowth21_z$birth_weight.12*1000
  plot(intergrowth21_z$gestational_weeks_2_2.12,intergrowth21_z$birth_weight.12)
  ds3<-rbind.fill(ds2,intergrowth21_z)

  ggplot(ds3[!is.na(ds3$zikv_exposed_mom),],aes(zikv_exposed_mom,gestational_weeks_2_2.12))+geom_boxplot()  +
    stat_compare_means(size=3,label.y = 45)


library(ggplot2)
tiff(filename = "weight_age_sex.tif",width = 18000,height=4000,units="px",res = 800)
ggplot(ds3[!is.na(ds3$gender_2.12) & !is.na(ds3$zikv_exposed_mom),],aes(x=gestational_weeks_2_2.12, y=birth_weight.12,color=zikv_exposed_mom))+
  geom_point()+
  geom_smooth(method = 'glm',)+
  facet_wrap('gender_2.12')+
  theme(legend.box = 'vertical',
        legend.position =  'right',
        text=element_text(size=35),
        plot.background = element_rect(fill = "transparent", color = NA), # bg of the plot
        #panel.grid.major = element_blank(), # get rid of major grid
        #panel.grid.minor = element_blank(), # get rid of minor grid
        #legend.background = element_rect(fill = "transparent"), # get rid of legend bg
        #legend.box.background = element_rect(fill = "transparent"), # get rid of legend panel bg,
        panel.background = element_rect(fill = "transparent"), # bg of the panel
  )+
  #guides(color=guide_legend(nrow=2,byrow=TRUE))+
  scale_color_discrete(name = "Maternal Pregnancy \nZIKV Exposure", labels = c("Probable", "Possible", "None","Intergrowth21 Standard"))+
  labs(x='Gestational Age (Weeks)', y = 'Birth Weight (grams)')+
  scale_x_discrete(labels = function(x) str_wrap(x, width = 15))
dev.off()


#install.packages('ggeffects')
library(ggeffects)
library(plyr)
label(ds3$zikv_exposed_mom) <- "Maternal Exposure"
ds3 <- within(ds3, zikv_exposed_mom[ds3$zikv_exposed_mom=='intergrowth21_standard'] <- 'Intergrowth21 Standard')
table(ds3$zikv_exposed_mom)
m1<-lm(formula = birth_weight.12~gestational_weeks_2_2.12*zikv_exposed_mom+zikv_exposed_mom + factor(gender_2.12) ,data = ds3)
summary(m1)
anova(m1)
p<-ggpredict(m1, c("gestational_weeks_2_2.12","zikv_exposed_mom"))

tiff(filename = "predicted_weight_age_sex.tif",width = 12000,height=8000,units="px",res = 800)
plot(p)+
  #geom_text('0.0053394 **')+
  theme(legend.box = 'horizontal',
        legend.position =  'bottom',
        text=element_text(size=35),
        plot.background = element_rect(fill = "transparent", color = NA), # bg of the plot
        panel.background = element_rect(fill = "transparent"), # bg of the panel
        legend.title=element_blank()
  )+
  labs(title='',x='Gestational Age (Weeks)', y = 'Birth Weight (grams)')+
  #scale_x_discrete(labels = function(x) str_wrap(x, width = 15))+
  guides(color=guide_legend(nrow=2,byrow=TRUE))+
  scale_color_manual(labels = c("Probably ZIKV \nInfected Pregnancy", "Possibly ZIKV \nInfected Pregnancy","ZIKV Uninfected Pregnancy","InterGrowth21st Standard"), values = c("red", "blue","green",'purple'))
dev.off()


library(lme4)
m2<-lmer(formula = birth_weight.12~gestational_weeks_2_2.12 + factor(gender_2.12)+ (1|zikv_exposed_mom),data = ds3)
p<-ggpredict(m2, c("gestational_weeks_2_2.12","zikv_exposed_mom"))
plot(p)

sga<-ds3[,c('mother_record_id','redcap_repeat_instance','gestational_weeks_2_2.12','head_circ_birth.12','birth_weight.12','birth_length.12','zikv_exposed_mom','gender_2.12')]
write.csv(sga,'sga.csv')

intergrowth21<-read.csv("C:/Users/amykr/Box Sync/Amy Krystosik's Files/zika study- grenada/gestational anthro compared to intergrowth 21 standards.csv")
ds3<-merge(ds3,intergrowth21,by= c("mother_record_id","redcap_repeat_instance"),all.y = TRUE)

ggplot(ds3[!is.na(ds3$zikv_exposed_mom),],aes(zikv_exposed_mom,g.LengthZScore))+geom_boxplot()+
  stat_compare_means(size=3,bracket.size = 1,comparisons = list(c("mom_zikv_Unexposed_during_pregnancy","mom_ZIKV_Exposure_possible_during_pregnancy"),
                                                                c("mom_ZIKV_Exposure_possible_during_pregnancy","mom_ZIKV_Exposed_during_pregnancy"),
                                                                c("mom_ZIKV_Exposed_during_pregnancy","mom_zikv_Unexposed_during_pregnancy") )) + 
  stat_compare_means(size=3,label.y = 8)+
  scale_x_discrete(labels = function(x) str_wrap(x, width = 15))

ds3$sga_weight<-NA
ds3 <- within(ds3, sga_weight[ds3$g.WeightZScore<=-2] <- 1)
ds3 <- within(ds3, sga_weight[ds3$g.WeightZScore>-2] <- 0)
table(ds3$sga_weight,ds3$zikv_exposed_mom)
table(ds3$zikv_exposed_mom)

#print z-score of weight graphs at birth
tiff(filename = "z-score_weight_age_sex.tif",width = 8000,height=6000,units="px",res = 800)
ggplot(ds3[!is.na(ds3$zikv_exposed_mom),],aes(zikv_exposed_mom,g.WeightZScore))+geom_boxplot()+
  #stat_compare_means(size=10,bracket.size = 1,comparisons = list(c("Not ZIKV Infected","Possibly ZIKV Infected During Pregnancy"),
  #                                                              c("Possibly ZIKV Infected During Pregnancy","Probably ZIKV Infected During Pregnancy"),
  #                                                              c("Probably ZIKV Infected During Pregnancy","Not ZIKV Infected") )) + 
  stat_compare_means(size=12,label.y = 4)+
  scale_x_discrete(labels = function(x) str_wrap(x, width = 15))+
  theme(text=element_text(size=35),
        panel.background = element_rect(fill = "transparent") # bg of the panel
  )+
  #scale_color_discrete(name = "Maternal Pregnancy \nZIKV Exposure", labels = c("Probable", "Possible", "None"))+
  labs(x='Maternal Exposure Category', y = 'Birth Weight (Z-Score)')+
  scale_x_discrete(labels = function(x) str_wrap(x, width = 15))
dev.off()

  