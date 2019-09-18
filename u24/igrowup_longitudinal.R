# import data ---------------------------------------------------------------------
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long")
load("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long/R01_lab_results 2019-05-06 .rda")

growth.over.time<-R01_lab_results
list<-c("u24_weight","child_weight","child_weight","child_weight_aic", "u24_participant",
        "u24_height_stad","u24_height_mt","u24_height","child_height","child_height_aic",
        "gender","gender_aic","u24_gender", "age_calc","age_calc_rc","u24_child_age","u24_age_calc","aic_calculated_age","person_id","redcap_event_name")
growth.over.time<-as.data.frame(growth.over.time[list])

growth.over.time[growth.over.time==999] <- NA
growth.over.time[growth.over.time==99.9] <- NA

growth.over.time$weight <- rowMeans(growth.over.time[, c("u24_weight","child_weight","child_weight","child_weight_aic")], na.rm=TRUE) 
growth.over.time$height <- rowMeans(growth.over.time[, c("u24_height_stad","u24_height_mt","u24_height","child_height","child_height_aic")], na.rm=TRUE) 
growth.over.time$sex <- rowMeans(growth.over.time[, c("gender","gender_aic","u24_gender")], na.rm=TRUE) 
growth.over.time$age <- rowMeans(growth.over.time[,c("age_calc","age_calc_rc","u24_child_age","u24_age_calc","aic_calculated_age")], na.rm=TRUE) 

growth.over.time$age_group<-NA
growth.over.time <- within(growth.over.time, age_group[age<=2] <- "under 2")
growth.over.time <- within(growth.over.time, age_group[age>2 & age<=5] <- "2-5")
growth.over.time <- within(growth.over.time, age_group[age>5 & age<=10] <- "6-10")
growth.over.time <- within(growth.over.time, age_group[age>10 & age<=15] <- "11-15")
growth.over.time <- within(growth.over.time, age_group[age>15] <- "over 15")
growth.over.time$age_group <- factor(growth.over.time$age_group, levels = c("under 2", "2-5", "6-10", "11-15", "over 15"))

growth.over.time <- within(growth.over.time, height[growth.over.time$height>200|growth.over.time$height<40] <-NA)
growth.over.time <- within(growth.over.time, weight[growth.over.time$weight>90|growth.over.time$weight<2] <-NA)

tapply(growth.over.time$weight,growth.over.time$age_group, summary)
tapply(growth.over.time$height,growth.over.time$age_group, summary)

boxplot(growth.over.time$weight~growth.over.time$age_group)
boxplot(growth.over.time$weight~growth.over.time$sex)
boxplot(growth.over.time$height~growth.over.time$age_group)
boxplot(growth.over.time$height~growth.over.time$sex)

#growth.over.time<-readxl::read_excel("C:/Users/amykr/Box Sync/U24 Project/nutrition/growth over time.xlsx")

growth.over.time <- within(growth.over.time, sex[growth.over.time$sex==1] <-"f")
growth.over.time <- within(growth.over.time, sex[growth.over.time$sex==0] <-"m")
z_scores<-growth.over.time[c("person_id","redcap_event_name","height","sex","weight","age","u24_participant")]

library(tidyr)
z_scores<-z_scores %>% drop_na(height,age,sex,weight)
z_scores$agemonth<-as.numeric(round(z_scores$age*12,1))
z_scores$age<-as.numeric(round(z_scores$age,1))

# 0-5 ---------------------------------------------------------------------
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

lessthan5<-as.data.frame(z_scores[which(z_scores$age<=5),])
lessthan5_u24<-as.data.frame(lessthan5[which(lessthan5$u24_participant==1),])
igrowup.standard(mydf=lessthan5, sex=sex, age = agemonth, age.month=T, weight=weight, lenhei=height, FilePath = "C:/Users/amykr/Box Sync/Amy Krystosik's Files/secure- u24 participants/data",FileLab="z_scores_under5_long")
igrowup.standard(mydf=lessthan5_u24, sex=sex, age = agemonth, age.month=T, weight=weight, lenhei=height, FilePath = "C:/Users/amykr/Box Sync/Amy Krystosik's Files/secure- u24 participants/data",FileLab="z_scores_under5_long_u24")
# 5-19 --------------------------------------------------------------------
setwd("C:/Program Files/R/R-3.3.2/library/who2007_R/")
wfawho2007<-read.table("wfawho2007.txt",header=T,sep="",skip=0)
hfawho2007<-read.table("hfawho2007.txt",header=T,sep="",skip=0)
bfawho2007<-read.table("bfawho2007.txt",header=T,sep="",skip=0)
source("who2007.r")
fiveplus<-as.data.frame(z_scores[which(z_scores$age>5),])
fiveplus_u24<-as.data.frame(fiveplus[which(fiveplus$u24_participant==1),])
who2007(mydf=fiveplus, sex=sex, age=agemonth, weight=weight,height=height, FilePath = "C:/Users/amykr/Box Sync/Amy Krystosik's Files/secure- u24 participants/data",FileLab="z_scores_5plus_long")
who2007(mydf=fiveplus_u24, sex=sex, age=agemonth, weight=weight,height=height, FilePath = "C:/Users/amykr/Box Sync/Amy Krystosik's Files/secure- u24 participants/data",FileLab="z_scores_5plus_long_u24")

# load and merge z-score ------------------------------------------------------
fiveplus<-read.csv("C:/Users/amykr/Box Sync/Amy Krystosik's Files/secure- u24 participants/data/z_scores_5plus_long_z.csv")
lessthan5<-read.csv("C:/Users/amykr/Box Sync/Amy Krystosik's Files/secure- u24 participants/data/z_scores_under5_long_z_st.csv")
z<-plyr::rbind.fill(fiveplus,lessthan5)
save(z,file="C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long/z_scores.rda")

# plot --------------------------------------------------------------------
wfawho2007$sd<-wfawho2007$s*wfawho2007$m
hfawho2007$sd <-hfawho2007$s*hfawho2007$m

weianthro$sd<-weianthro$s*weianthro$m
lenanthro$sd<-lenanthro$s*lenanthro$m

wfhanthro$sd<-wfhanthro$s*wfhanthro$m
wflanthro$sd<-wflanthro$s*wflanthro$m
library(plyr)
who_sd_weight_age<-plyr::rbind.fill(weianthro,wfawho2007)
who_sd_height_age<-plyr::rbind.fill(lenanthro,hfawho2007)
wflanthro$height<-wflanthro$length
who_sd_wfh<-plyr::rbind.fill(wflanthro,wfhanthro)

who_sd_w_h_age<-merge(who_sd_weight_age,who_sd_height_age,by=c("sex","age"),  suffixes = c(".weight",".height") )

who_sd_w_h_age$who_weight.3sd<-who_sd_w_h_age$m.weight-(who_sd_w_h_age$sd.weight*3)
who_sd_w_h_age$who_weight.3sd<-who_sd_w_h_age$m.weight-(who_sd_w_h_age$sd.weight*2)

who_sd_w_h_age$who_height.3sd <-who_sd_w_h_age$m.height-(who_sd_w_h_age$sd.height*3)
who_sd_w_h_age$who_height.2sd<-who_sd_w_h_age$m.height-(who_sd_w_h_age$sd.height*2)

who_sd_w_h_age$who_wfh.3sd <-who_sd_w_h_age$m-(who_sd_w_h_age$sd*3)
who_sd_w_h_age$who_wfh.2sd<-who_sd_w_h_age$m-(who_sd_w_h_age$sd*2)

compare<-merge(z,who_sd_w_h_age,by="height",all.x=T)

compare$weight[compare$weight> 100] <-NA
compare$height[compare$height> 200] <-NA

library("extrafont")
plot<-ggplot(compare,aes(height,weight))+
  geom_point(aes(height,weight), alpha = .5)+
  facet_grid(.~sex.x)+
  geom_smooth(aes(height,weight, colour = "black"),level=.95,size=2,formula=y~x,method="loess") +
  geom_line(aes(height,m, colour="blue"),size=2 ,alpha=.5) +
  geom_line(aes(height,who_wfh.2sd, colour="green"),size=2,alpha=.5 ) +
  geom_line(aes(height,who_wfh.3sd, colour="red"),size=2,alpha=.5 ) +
  labs(title ="", x = "Height (cm)", y = "Weight (Kg)")+ 
  scale_color_discrete(name = "", labels = c("Loess smoothed\n regression & 95% CI       ", "WHO\n Median       ", "WHO\n -2 SD       ","WHO\n -3 SD       "))+
  theme_classic(base_size = 12, base_family="Arial")+ theme(legend.position="bottom") + guides(color=guide_legend(override.aes=list(fill=NA)))

fig3<-plot+ theme(legend.text	= element_text(colour = "black",size= 12, family="Arial"),strip.text = element_text(colour = "black",size= 12))+ scale_size("",range = c(1,3),breaks=c(16,22,23),labels=c("15.1","21.9","23.5"))
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long")

tiff(file = "fig3_arial12.tiff", width = 6200, height = 3200, units = "px", res = 600)
fig3
dev.off()
