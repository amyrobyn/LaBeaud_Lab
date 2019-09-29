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

growth.over.time<-reshape(growth, idvar = c("mother_record_id","redcap_repeat_instance"), varying = c(3:12),  direction = "long", timevar = "visit", times = c("pn", "12"),v.names=v.names)
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

wd="C:/Users/amykr/Box Sync/Amy Krystosik's Files/zika study- grenada"
setwd(wd)
igrowup.standard(mydf=z_scores, sex=sex, age = age, age.month=T, weight=weight,headc=hc, len=length, FilePath = wd,FileLab="z_scores")

z_scores<-read.csv("z_scores_z_st.csv")

z_scores<-z_scores[,c(1:9,16:20)]
exposure <- ds2[,c("mother_record_id","redcap_repeat_instance","zikv_exposed_mom","mic_nurse_2.12")]
growth_long<-merge(exposure,z_scores,by=c("mother_record_id","redcap_repeat_instance"),all.x = T)


# plots -------------------------------------------------------------------
is_outlier <- function(x) {
  return(x < quantile(x, 0.25) - 2 * IQR(x) | x > quantile(x, 0.75) + 2 * IQR(x))
}

growth_long %>% 
  filter(!is.na(growth_long$zlen))%>%
  group_by(zikv_exposed_mom) %>%
  mutate(outlier=ifelse(is_outlier(zlen),mother_record_id,as.numeric(NA))) %>%
  ggplot(aes(x=factor(visit), zlen)) + 
  geom_boxplot(outlier.colour = NA) +
  ggrepel::geom_text_repel(data=. %>% filter(!is.na(outlier)), aes(label=mother_record_id))

growth_long %>% 
  filter(!is.na(growth_long$zwfl))%>%
  group_by(zikv_exposed_mom) %>%
  mutate(outlier=ifelse(is_outlier(zwfl),mother_record_id,as.numeric(NA))) %>%
  ggplot(aes(x=factor(visit), zwfl)) + 
  geom_boxplot(outlier.colour = NA) +
  ggrepel::geom_text_repel(data=. %>% filter(!is.na(outlier)), aes(label=mother_record_id))

growth_long %>% 
  filter(!is.na(growth_long$zhc))%>%
  group_by(zikv_exposed_mom) %>%
  mutate(outlier=ifelse(is_outlier(zhc),mother_record_id,as.numeric(NA))) %>%
  ggplot(aes(x=factor(visit), zhc)) + 
  geom_boxplot(outlier.colour = NA) +
  ggrepel::geom_text_repel(data=. %>% filter(!is.na(outlier)), aes(label=mother_record_id))

growth_long %>% 
  filter(!is.na(growth_long$zwei))%>%
  group_by(zikv_exposed_mom) %>%
  mutate(outlier=ifelse(is_outlier(zwei),mother_record_id,as.numeric(NA))) %>%
  ggplot(aes(x=factor(visit), zwei)) + 
  geom_boxplot(outlier.colour = NA) +
  ggrepel::geom_text_repel(data=. %>% filter(!is.na(outlier)), aes(label=mother_record_id))

#remove outliers beyond 6 z scores per who recomendations. 
growth_long<-growth_long[growth_long$zwei<6&growth_long$zwei>-6&growth_long$zhc<6&growth_long$zhc>-6&growth_long$zwfl<6&growth_long$zwfl>-6&growth_long$zlen<6&growth_long$zlen>-6,]

child_outcomes <- CreateTableOne(vars = names(growth_long[4:16]), data = growth_long[growth_long$visit=="pn",], strata = c("zikv_exposed_mom"))
child_outcomes<-print(child_outcomes,quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE,smd=T)
write.csv(child_outcomes, file = "child_growth_pn_strata.csv")

child_outcomes <- CreateTableOne(vars = names(growth_long[4:16]), data = growth_long[growth_long$visit=="12",], strata = c("zikv_exposed_mom"))
child_outcomes<-print(child_outcomes,quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE,smd=T)
write.csv(child_outcomes, file = "child_growth_12_strata.csv")

child_outcomes <- CreateTableOne(vars = names(growth_long[4:16]), data = growth_long[!is.na(growth_long$zikv_exposed_mom) & growth_long$visit=="pn",])
child_outcomes<-print(child_outcomes,quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE,smd=T)
write.csv(child_outcomes, file = "child_growth_pn.csv")

child_outcomes <- CreateTableOne(vars = names(growth_long[4:16]), data = growth_long[!is.na(growth_long$zikv_exposed_mom) & growth_long$visit=="12",])
child_outcomes<-print(child_outcomes,quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE,smd=T)
write.csv(child_outcomes, file = "child_growth_12.csv")

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

ggplot(growth_long, aes(x = zikv_exposed_mom, y = sum_growth_Outcomes_abnormal)) + geom_boxplot() 

child_outcomes_vars<-grep("z|mic|mir|sum_growth_Outcomes_abnormal",names(growth_long),value = T)
child_outcomes_vars<-grep("abnormal|mic|mir|sum_growth_Outcomes_abnormal",child_outcomes_vars,value = T)

child_outcomes <- CreateTableOne(vars = child_outcomes_vars, data = growth_long[growth_long$visit=="pn",],strata = "zikv_exposed_mom",factorVars = child_outcomes_vars)
child_outcomes<-print(child_outcomes,quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE,smd=T,cramVars=child_outcomes_vars)
write.csv(child_outcomes, file = "child_growth_abnormal_pn_strata.csv")

child_outcomes <- CreateTableOne(vars = child_outcomes_vars, data = growth_long[growth_long$visit=="12",],strata = "zikv_exposed_mom",factorVars = child_outcomes_vars)
child_outcomes<-print(child_outcomes,quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE,smd=T,cramVars=child_outcomes_vars)
write.csv(child_outcomes, file = "child_growth_abnormal_12_strata.csv")

child_outcomes <- CreateTableOne(vars = child_outcomes_vars, data = growth_long[!is.na(growth_long$zikv_exposed_mom)&growth_long$visit=="pn",],factorVars = child_outcomes_vars)
child_outcomes<-print(child_outcomes,quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE,smd=T,cramVars=child_outcomes_vars)
write.csv(child_outcomes, file = "child_growth_abnormal_pn.csv")

child_outcomes <- CreateTableOne(vars = child_outcomes_vars, data = growth_long[!is.na(growth_long$zikv_exposed_mom)&growth_long$visit=="12",],factorVars = child_outcomes_vars)
child_outcomes<-print(child_outcomes,quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE,smd=T,cramVars=child_outcomes_vars)
write.csv(child_outcomes, file = "child_growth_abnormal_12.csv")