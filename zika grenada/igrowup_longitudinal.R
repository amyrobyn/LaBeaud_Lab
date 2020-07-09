datainfant$child_calculated_age.pn <- rowMeans(datainfant[, c("child_calculated_age.pn","age_sampled.pn")], na.rm=TRUE) 
growth.pn<-ds2[,grep("mother_record_id|redcap_repeat_instance|mean_hc.pn|mean_length.pn|mean_weight.pn|^gender.pn|child_calculated_age.pn",names(ds2),value = T)]
ds2$mean_length_2.12 <- rowMeans(ds2[, c("mean_length_2.12","mean_height_2.12")], na.rm=TRUE) 
growth.12<-ds2[,grep("mother_record_id|redcap_repeat_instance|mean_hc_2.12|mean_length_2.12|mean_weight_2.12|^gender_2.12|child_calculated_age_2.12",names(ds2),value = T)]
growth <- merge(growth.pn, growth.12, by = c("mother_record_id","redcap_repeat_instance"), all=T)
growth<-growth[,order(colnames(growth))]
growth<-growth[order(-(grepl('_2.12', names(growth)))+1L)]
growth<-growth[order(-(grepl('.pn', names(growth)))+1L)]
growth<-growth[order(-(grepl('redcap_repeat_instance', names(growth)))+1L)]
growth<-growth[order(-(grepl('mother_record_id', names(growth)))+1L)]
v.names  <-c("age","gender","hc","length","weight")     

growth.over.time<-reshape(growth[!is.na(growth$mother_record_id),], idvar = c("mother_record_id","redcap_repeat_instance"), varying = c(3:12),  direction = "long", timevar = "visit", times = c("pn", "12"),v.names=v.names)
growth.over.time$sex<-NA
growth.over.time <- within(growth.over.time, sex[growth.over.time$gender=="Female"] <-"f")
growth.over.time <- within(growth.over.time, sex[growth.over.time$gender=='Male'] <-"m")


growth.over.time[growth.over.time==999] <- NA
#growth.over.time[growth.over.time==99.9] <- NA
#growth.over.time[growth.over.time==99] <- NA

growth.over.time <- within(growth.over.time, length[growth.over.time$length>200|growth.over.time$length<40] <-NA)
growth.over.time <- within(growth.over.time, weight[growth.over.time$weight>90|growth.over.time$weight<2] <-NA)
growth.over.time <- within(growth.over.time, age[growth.over.time$age>40|growth.over.time$age<0] <-NA)

growth.over.time$age_group<-NA
growth.over.time <- within(growth.over.time, age_group[age<=2] <- "under 2")
growth.over.time <- within(growth.over.time, age_group[age>2 & age<=5] <- "2-5")
growth.over.time <- within(growth.over.time, age_group[age>5 & age<=10] <- "6-10")
growth.over.time <- within(growth.over.time, age_group[age>10 & age<=15] <- "11-15")
growth.over.time <- within(growth.over.time, age_group[age>15] <- "over 15")
growth.over.time$age_group <- factor(growth.over.time$age_group, levels = c("under 2", "2-5", "6-10", "11-15", "over 15"))


tapply(growth.over.time$weight,growth.over.time$age_group, summary)
tapply(growth.over.time$length,growth.over.time$age_group, summary)

boxplot(growth.over.time$weight~growth.over.time$age_group)
boxplot(growth.over.time$weight~growth.over.time$sex)
boxplot(growth.over.time$length~growth.over.time$age_group)
boxplot(growth.over.time$length~growth.over.time$sex)

z_scores<-growth.over.time[c("mother_record_id","redcap_repeat_instance","visit","age","sex","hc","length","weight")]

library(tidyr)
z_scores<-z_scores %>% drop_na(age,sex)
z_scores$age<-as.numeric(round(z_scores$age,1))

# who i growup antrho z scores ---------------------------------------------------------------------
setwd("C:/Program Files/R/R-3.3.2/library/igrowup_R/")
weianthro<-read.table("weianthro.txt",header=T,sep="",skip=0)
lenanthro<-read.table("lenanthro.txt",header=T,sep="",skip=0)
bmianthro<-read.table("bmianthro.txt",header=T,sep="",skip=0)
hcanthro<-read.table("hcanthro.txt",header=T,sep="",skip=0)
acanthro<-read.table("acanthro.txt",header=T,sep="",skip=0)
ssanthro<-read.table("ssanthro.txt",header=T,sep="",skip=0)
tsanthro<-read.table("tsanthro.txt",header=T,sep="",skip=0)
wflanthro<-read.table("wflanthro.txt",header=T,sep="",skip=0)
wfhanthro<-read.table("wfhanthro.txt",header=T,sep="",skip=0)

source("igrowup_standard.r")
source("igrowup_restricted.r")

wd="C:/Users/amykr/Box Sync/Amy's Externally Shareable Files/zika_grenada/zikv paper 1 analysis"
setwd(wd)

igrowup.standard(mydf=z_scores, sex=sex, age = age, age.month=T, weight=weight,headc=hc, len=length, FilePath = wd,FileLab="z_scores")

z_scores<-read.csv("z_scores_z_st.csv")

z_scores<-z_scores[,c(1:9,16:28)]

ds2$zikv_exposed_mom<-  as.factor(ds2$zikv_exposed_mom)
levels(ds2$zikv_exposed_mom)[levels(ds2$zikv_exposed_mom)=="mom_ZIKV_Exposed_during_pregnancy"] <- "Probably ZIKV Infected During Pregnancy"
levels(ds2$zikv_exposed_mom)[levels(ds2$zikv_exposed_mom)=="mom_ZIKV_Exposure_possible_during_pregnancy"] <- "Possibly ZIKV Infected During Pregnancy"
levels(ds2$zikv_exposed_mom)[levels(ds2$zikv_exposed_mom)=="mom_zikv_Unexposed_during_pregnancy"] <- "Not ZIKV Infected"

exposure <- ds2[,c("mother_record_id","redcap_repeat_instance","zikv_exposed_mom","mic_nurse_2.12")]
growth_long<-merge(exposure,z_scores,by=c("mother_record_id","redcap_repeat_instance"),all.x = T)


# plots -------------------------------------------------------------------
setwd("C:/Users/amykr/Box Sync/Amy's Externally Shareable Files/zika_grenada/zikv paper 1 analysis")
is_outlier <- function(x) {
  return(x < quantile(x, 0.25) - 2 * IQR(x) | x > quantile(x, 0.75) + 2 * IQR(x))
}

growth_long %>% 
  filter(!is.na(growth_long$zlen))%>%
  group_by(zikv_exposed_mom) %>%
  mutate(outlier=ifelse(is_outlier(zlen),mother_record_id,(NA))) %>%
  ggplot(aes(x=factor(visit), zlen)) + 
  geom_boxplot(outlier.colour = NA) +
  ggrepel::geom_text_repel(data=. %>% filter(!is.na(outlier)), aes(label=mother_record_id))

growth_long %>% 
  filter(!is.na(growth_long$zwfl))%>%
  group_by(zikv_exposed_mom) %>%
  mutate(outlier=ifelse(is_outlier(zwfl),mother_record_id,(NA))) %>%
  ggplot(aes(x=factor(visit), zwfl)) + 
  geom_boxplot(outlier.colour = NA) +
  ggrepel::geom_text_repel(data=. %>% filter(!is.na(outlier)), aes(label=mother_record_id))

growth_long %>% 
  filter(!is.na(growth_long$zhc))%>%
  group_by(zikv_exposed_mom) %>%
  mutate(outlier=ifelse(is_outlier(zhc),mother_record_id,(NA))) %>%
  ggplot(aes(x=factor(visit), zhc)) + 
  geom_boxplot(outlier.colour = NA) +
  ggrepel::geom_text_repel(data=. %>% filter(!is.na(outlier)), aes(label=mother_record_id))

growth_long %>% 
  filter(!is.na(growth_long$zwei))%>%
  group_by(zikv_exposed_mom) %>%
  mutate(outlier=ifelse(is_outlier(zwei),mother_record_id,(NA))) %>%
  ggplot(aes(x=factor(visit), zwei)) + 
  geom_boxplot(outlier.colour = NA) +
  ggrepel::geom_text_repel(data=. %>% filter(!is.na(outlier)), aes(label=mother_record_id))

#remove outliers per who recomendations. 
  growth_long <- within(growth_long, zwei[growth_long$fwei==1] <-NA)
  growth_long <- within(growth_long, weight[growth_long$fwei==1] <-NA)
  
  growth_long <- within(growth_long, zhc[growth_long$fhc==1] <-NA)
  growth_long <- within(growth_long, hc[growth_long$fhc==1] <-NA)
  
  growth_long <- within(growth_long, zwfl[growth_long$fwfl==1] <-NA)
  growth_long <- within(growth_long, weight[growth_long$fwfl==1] <-NA)
  growth_long <- within(growth_long, length[growth_long$fwfl==1] <-NA)
  
  growth_long <- within(growth_long, zlen[growth_long$flen==1] <-NA)
  growth_long <- within(growth_long, length[growth_long$flen==1] <-NA)
  
  growth_long <- within(growth_long, zbmi[growth_long$fbmi==1] <-NA)

#raw z score tables. table 7

  growth_long<-growth_long[growth_long$zikv_exposed_mom!='unknown',]
  growth_long$zikv_exposed_mom<-factor(growth_long$zikv_exposed_mom) 

  child_outcomes_vars<-c("age","zhc", "zlen", "zwei", "zwfl", "zbmi")

  
  child_outcomes <- CreateTableOne(vars = child_outcomes_vars,
                                   includeNA=TRUE,
                                 data = growth_long[growth_long$visit=="pn",], 
                                 strata = c("zikv_exposed_mom"))
  child_outcomes<-print(child_outcomes,
                        quote = F, 
                        noSpaces = TRUE,  
                        printToggle = FALSE,
                        smd=T,
                        nonnormal = child_outcomes_vars)
  write.csv(child_outcomes, file = "table7_child_growth_pn_strata.csv")

child_outcomes <- CreateTableOne(vars = child_outcomes_vars,
                                 includeNA=TRUE, 
                                 data = growth_long[growth_long$visit=="12",], 
                                 strata = c("zikv_exposed_mom"))
child_outcomes<-print(child_outcomes,
                      quote = F, 
                      noSpaces = TRUE, 
                      printToggle = FALSE,
                      smd=T,
                      nonnormal = child_outcomes_vars)

write.csv(child_outcomes, file = "table7_child_growth_12_strata.csv")

child_outcomes <- CreateTableOne(vars = child_outcomes_vars, 
                                 includeNA=TRUE, 
                                 data = growth_long[!is.na(growth_long$zikv_exposed_mom) & growth_long$visit=="pn",])
summary(child_outcomes$ContTable)

child_outcomes<-print(child_outcomes,
                      quote = F, 
                      noSpaces = TRUE, 
                      printToggle = FALSE,
                      smd=T,
                      nonnormal = child_outcomes_vars)
write.csv(child_outcomes, file = "table7_child_growth_pn.csv")

child_outcomes <- CreateTableOne(vars = child_outcomes_vars,
                                 includeNA=TRUE, 
                                 data = growth_long[!is.na(growth_long$zikv_exposed_mom) & growth_long$visit=="12",])
summary(child_outcomes$ContTable)
child_outcomes<-print(child_outcomes,
                      quote = F, 
                      noSpaces = TRUE, 
                      printToggle = FALSE,
                      smd=T,
                      nonnormal = child_outcomes_vars)
write.csv(child_outcomes, file = "table7_child_growth_12.csv")

# define normal/abnormal --------------------------------------------------------------------
zscores<-grep("zlen|zhc|zbmi|zwei|zwfl",names(growth_long),value = T)
abnormal<-function(x) ifelse(growth_long[x] >= 2|growth_long[x] <= -2, 1, ifelse(growth_long[x] > -2 & growth_long[x] < 2,0,NA))
zscores_matrix<-lapply(zscores, abnormal)

rename<-function(x) paste(x,"abnormal",sep=".")
zscores<-lapply(zscores, rename)
zscores_matrix<-as.data.frame(zscores_matrix)
colnames(zscores_matrix)<-zscores

growth_long<-cbind(growth_long,zscores_matrix)

growth_long$mic_nurse_2.12<-as.numeric(as.factor(growth_long$mic_nurse_2.12))-1
child_outcomes.12<-grep(".12",names(growth_long),value = T)
child_outcomes.12<-grep("z|mic",child_outcomes.12,value = T)
child_outcomes.12<-grep("abnormal|mic",child_outcomes.12,value = T)

growth_long$sum_growth_Outcomes_abnormal<-rowSums(growth_long[17:21],na.rm = T)
table(growth_long$zikv_exposed_mom,growth_long$sum_growth_Outcomes_abnormal,exclude = NULL)

# New facet label names for visit variable
visit.labs <- c("Visit 1", "Visit 2")
names(visit.labs) <- c("pn", "12")
library(stringr)
library(ggpubr)

transparent.plot=ggplot(growth_long[!is.na(growth_long$zikv_exposed_mom),], aes(x= zikv_exposed_mom,y = sum_growth_Outcomes_abnormal)) + 
  geom_boxplot(size=5, outlier.size = 8,alpha=.8) +
  theme(
    text = element_text(size = 150),
    plot.background = element_rect(fill = "transparent", color = NA), # bg of the plot
    panel.grid.major = element_blank(), # get rid of major grid
    panel.grid.minor = element_blank(), # get rid of minor grid
    legend.background = element_rect(fill = "transparent"), # get rid of legend bg
    legend.box.background = element_rect(fill = "transparent"), # get rid of legend panel bg,
    axis.ticks =element_line(colour = 'black',size=10),
    axis.text = element_text(colour = 'black',size = 150),
    axis.title = element_text(color = 'black',size=150),
    axis.ticks.length =  unit(0.25, "cm"),
    axis.line = element_line(color='black',size=10),
    panel.background = element_rect(fill = "transparent"),
    strip.text.x = element_text(size = 150, colour = "black")
    # bg of the panel
  )+
  labs(y = "Sum of abnormal growth outcomes", x = "Maternal Exposure")+
  facet_wrap('visit',nrow=2,dir='v',labeller = labeller(visit = visit.labs))+
  scale_x_discrete(labels=c("Probable ZIKV \nExposed Pregnancy", "Possible ZIKV \nExposed Pregnancy","ZIKV \nUnexposed Pregnancy"))+
  stat_compare_means(size=40,label.y = 5)

ggsave(filename = "growth_transparent_background.png",
       plot = last_plot(),
       bg = "transparent", 
       width = 80,
       height = 40,
       #dpi=600,
       units = "in",
       limitsize = FALSE)

growth_long$zbmi.abnormal <- factor(growth_long$zbmi.abnormal, levels = c("1", "0"))
growth_long$zlen.abnormal <- factor(growth_long$zlen.abnormal, levels = c("1", "0"))
growth_long$zwei.abnormal <- factor(growth_long$zwei.abnormal, levels = c("1", "0"))
growth_long$zwfl.abnormal <- factor(growth_long$zwfl.abnormal, levels = c("1", "0"))
growth_long$zhc.abnormal <- factor(growth_long$zhc.abnormal, levels = c("1", "0"))
growth_long$mic_nurse_2.12 <- factor(growth_long$mic_nurse_2.12, levels = c("1", "0"))

child_outcomes_vars<-c("age","mic_nurse_2.12","zhc.abnormal", "zlen.abnormal", "zwei.abnormal", "zwfl.abnormal", "zbmi.abnormal")

growth_long<-growth_long[growth_long$zikv_exposed_mom!='unknown',]
growth_long$zikv_exposed_mom<-factor(growth_long$zikv_exposed_mom) 
child_outcomes_vars_factor<-c("mic_nurse_2.12","zhc.abnormal", "zlen.abnormal", "zwei.abnormal", "zwfl.abnormal", "zbmi.abnormal")


############################create table 5######################

child_outcomes_tableone <- CreateTableOne(vars = child_outcomes_vars, 
                                 includeNA=TRUE, 
                                 data = growth_long[growth_long$visit=="pn",],
                                 strata = "zikv_exposed_mom",
                                 factorVars = child_outcomes_vars_factor)
summary(child_outcomes_tableone$ContTable)
summary(child_outcomes_tableone$CatTable)

child_outcomes_tableone<-print(child_outcomes_tableone,
                               quote = F, 
                      noSpaces = TRUE, 
                      nonnormal = 'age',
                      printToggle = FALSE,
                      smd=T,
                      cramVars=child_outcomes_vars)
write.csv(child_outcomes_tableone, file = "table5_child_growth_abnormal_pn_strata.csv")

child_outcomes_tableone <- CreateTableOne(vars = child_outcomes_vars, 
                                 includeNA=TRUE, 
                                 data = growth_long[growth_long$visit=="12",],
                                 strata = "zikv_exposed_mom",
                                 factorVars = child_outcomes_vars_factor)
child_outcomes_tableone<-print(child_outcomes_tableone,quote = F, 
                      nonnormal = 'age',
                      noSpaces = TRUE, 
                      printToggle = FALSE,
                      smd=T,
                      cramVars=child_outcomes_vars)
write.csv(child_outcomes_tableone, file = "table5_child_growth_abnormal_12_strata.csv")

child_outcomes_tableone <- CreateTableOne(vars = child_outcomes_vars, 
                                 includeNA=TRUE, 
                                 data = growth_long[!is.na(growth_long$zikv_exposed_mom)&growth_long$visit=="pn",],
                                 factorVars = child_outcomes_vars_factor)
summary(child_outcomes_tableone$ContTable)

child_outcomes_tableone<-print(child_outcomes_tableone,
                      nonnormal = 'age',
                      quote = F, 
                      noSpaces = TRUE, 
                      printToggle = FALSE,
                      smd=T,
                      cramVars=child_outcomes_vars)

write.csv(child_outcomes_tableone, file = "table_5child_growth_abnormal_pn.csv")

child_outcomes_tableone <- CreateTableOne(vars = child_outcomes_vars, 
                                 includeNA=TRUE, 
                                 data = growth_long[!is.na(growth_long$zikv_exposed_mom)&growth_long$visit=="12",],
                                 factorVars = child_outcomes_vars_factor)
summary(child_outcomes_tableone$ContTable)

child_outcomes_tableone<-print(child_outcomes_tableone,
                      nonnormal = 'age',
                      quote = F, 
                      noSpaces = TRUE, 
                      printToggle = FALSE,
                      smd=T,
                      cramVars=child_outcomes_vars)
write.csv(child_outcomes_tableone, file = "table5_child_growth_abnormal_12.csv")

##plot figure 2. z scores over visit by subject.
#::::::::::::::::::::::::::::::::::::::::::
growth_long$visit <- factor(growth_long$visit, levels = c("pn", "12"))
growth_long$visit<-plyr::revalue(growth_long$visit, c("pn"="1st", "12"="2nd"))

tiff(filename = "fig2_zwfl_visit.tif",width = 6000,height=2000,units="px",family = "sans",bg="white",pointsize = 12,res=300)
  ggpaired(growth_long[!is.na(growth_long$zwfl),], x = "visit", y = "zwfl",
           color = "visit", line.color = "gray", line.size = 0.4,
           palette = "npg",facet.by = 'zikv_exposed_mom',ylab = 'Z-Score Weight for Length', xlab = 'Visit', ggtheme=labs_pubr(base_size = 24))
dev.off()