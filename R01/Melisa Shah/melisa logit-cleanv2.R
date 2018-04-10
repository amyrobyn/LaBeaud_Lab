setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/melisa shah")
aicmalaria <- readRDS("aicmalaria.rds")
library(plyr)
age_site <- ddply(aicmalaria, .(id_site_A), 
                  summarise, 
                  age_mean  = mean(aic_calculated_age_A, na.rm = TRUE),
                  fever_sd  = sd(aic_calculated_age_A, na.rm = TRUE))

pairwise.t.test(aicmalaria$aic_calculated_age_A, aicmalaria$id_site_A, p.adjust="bonferroni", na.rm=TRUE)
#correlation  matrix
#install.packages("corrplot")
library(Hmisc)
library(corrplot)

res <-cor(aicmalaria[sapply(aicmalaria, function(x) is.numeric(x))])
corrplot(res, type = "upper", order = "hclust", 
         tl.col = "black", tl.srt = 45)

#Usually, incubation periods vary depending on the species of Plasmodium causing malaria. The average incubation period is 9-14 days for Plasmodium falciparum, 12-17 days for infections by Plasmodium vivax and 18-40 days for infections caused by Plasmodium malariae[1].
aicmalaria <- aicmalaria[ , grepl("person_id|redcap_event|id_site|interview_date_aic_A|result_microscopy_malaria_kenya_A|aic_calculated_age_A|agecat_A|temp_A|roof_type_A|latrine_type_A|floor_type_A|drinking_water_source_A|number_windows_A|gender_aic_A|fever_contact_A|mosquito_bites_aic_A|mosquito_net_aic_A|telephone|radio|television|bicycle|motor_vehicle|domestic_worker|report" , names(aicmalaria) ) ]

aicmalaria <- aicmalaria[ , !grepl("$_D|$_C|$_B|$_F|$_G|$_H" , names(aicmalaria) ) ]
aicmalaria<-aicmalaria[order((grepl('date', names(aicmalaria)))+1L)]

aicmalaria$interview_date_aic_A<-as.Date(aicmalaria$interview_date_aic_A)
class(aicmalaria$interview_date_aic_A)

# ses ---------------------------------------------------------------------
ses<-(aicmalaria[, grepl("telephone|radio|television|bicycle|motor_vehicle|domestic_worker", names(aicmalaria))])
aicmalaria$ses_sum<-rowSums(aicmalaria[, c("telephone_A","radio_A","television_A","bicycle_A","motor_vehicle_A", "domestic_worker_A")], na.rm = TRUE)
table(aicmalaria$ses_sum)

# by site -----------------------------------------------------------------
table(aicmalaria$id_site_A, exclude=NULL)
aicmalaria_u<-aicmalaria[which(aicmalaria$id_site_A=="Ukunda"),]
aicmalaria_k<-aicmalaria[which(aicmalaria$id_site_A=="Kisumu"),]
aicmalaria_m<-aicmalaria[which(aicmalaria$id_site_A=="Msambweni"),]
aicmalaria_c<-aicmalaria[which(aicmalaria$id_site_A=="Chulaimbo"),]

# climate -----------------------------------------------------------------
load("C:/Users/amykr/Box Sync/Amy Krystosik's Files/vector/climate.rda")
climate<-dplyr::arrange(climate, date_collected)
class(climate$date_collected)

table(climate$redcap_event_name, exclude=NULL)
climate_u<-climate[which(climate$redcap_event_name=="ukunda_arm_1"),]
climate_c<-climate[which(climate$redcap_event_name=="chulaimbo_village_arm_1"),]
climate_k<-climate[which(climate$redcap_event_name=="obama_arm_1"),]
climate_m<-climate[which(climate$redcap_event_name=="msambweni_arm_1"),]

data.length_m <- length(climate_m$date_collected)
time.min_m <- climate_m$date_collected[1]
time.max_m <- climate_m$date_collected[data.length_m]
all.dates_m <- seq(time.min_m, time.max_m, by="day")
all.dates.frame_m <- data.frame(list(date_collected=all.dates_m))
merged.data_m <- merge(all.dates.frame_m, climate_m, all=T, by="date_collected")
merged.data_m$redcap_event_name<-"msambweni_arm_1"
table(merged.data_m$redcap_event_name, exclude=NULL)

data.length_u <- length(climate_u$date_collected)
time.min_u <- climate_u$date_collected[1]
time.max_u <- climate_u$date_collected[data.length_u]
all.dates_u <- seq(time.min_u, time.max_u, by="day")
all.dates.frame_u <- data.frame(list(date_collected=all.dates_u))
merged.data_u <- merge(all.dates.frame_u, climate_u, all=T, by="date_collected")
merged.data_u$redcap_event_name<-"ukunda_arm_1"
table(merged.data_u$redcap_event_name, exclude=NULL)

data.length_k <- length(climate_k$date_collected)
time.min_k <- climate_k$date_collected[1]
time.max_k <- climate_k$date_collected[data.length_k]
all.dates_k <- seq(time.min_k, time.max_k, by="day")
all.dates.frame_k <- data.frame(list(date_collected=all.dates_k))
merged.data_k <- merge(all.dates.frame_k, climate_k, all=T, by="date_collected")
merged.data_k$redcap_event_name<-"obama_arm_1"
table(merged.data_k$redcap_event_name, exclude=NULL)

data.length_c <- length(climate_c$date_collected)
time.min_c <- climate_c$date_collected[1]
time.max_c <- climate_c$date_collected[data.length_c]
all.dates_c <- seq(time.min_c, time.max_c, by="day")
all.dates.frame_c <- data.frame(list(date_collected=all.dates_c))
merged.data_c <- merge(all.dates.frame_c, climate_c, all=T, by="date_collected")
merged.data_c$redcap_event_name<-"chulaimbo_village_arm_1"
table(merged.data_c$redcap_event_name, exclude=NULL)

merged.data<-rbind(merged.data_c,merged.data_k,merged.data_m,merged.data_u)

climate<-merged.data
climate$redcap_event_name<-as.factor(climate$redcap_event_name)
climate$mean_temp<-climate$temp_mean_hobo
summary(climate$mean_temp)
length(which(!is.na(climate$mean_temp)))
climate$mean_temp[is.na(climate$temp_mean_hobo)]<-climate$ltm_lst[!is.na(climate$ltm_lst)]
climate$mean_temp<-as.numeric(climate$mean_temp)

climate$rainfall<-climate$rainfall_hobo
summary(climate$rainfall)
length(which(!is.na(climate$rainfall)))

climate$rainfall[is.na(climate$rainfall_hobo)]<-climate$daily_rainfall[!is.na(climate$daily_rainfall)]
plot(climate$date_collected,round(climate$rainfall), exclude=NULL)
table(round(climate$rainfall), exclude=NULL)
#create sum of last month's data for each day.
library(zoo)
library(DataCombine)
#    install.packages("DataCombine")
# moving mean for that day and previous days (e.g. 5 represents the mean of that day and the for previous days)
library("zoo")
library("dplyr")
climate<-climate[!with(climate,is.na(mean_temp)),]
climate<-climate[!with(climate,is.na(rainfall)),]
length(!is.na(climate$mean_temp))

climate = climate %>%
  group_by(redcap_event_name) %>%
  arrange(redcap_event_name, date_collected) %>%
  mutate(
    temp_mean_hobo_30 = rollmean(x = mean_temp, 30, align = "right", fill = NA),
    rainfall_hobo_30 = rollsum(x = rainfall, 30, align = "right", fill = NA)
  )
climate <- within (climate, rainfall_hobo_30[climate$rainfall_hobo_30<0] <-0)
table(round(climate$temp_mean_hobo_30), climate$redcap_event_name, exclude=NA)
table(round(climate$rainfall_hobo_30), exclude=NA)


library(ggplot2)
ggplot (climate, aes (x = date_collected, y = temp_mean_hobo_30, colour = redcap_event_name)) + geom_point ()
ggplot (climate, aes (x = date_collected, y = rainfall_hobo_30, colour = redcap_event_name)) + geom_point ()

table(round(climate$temp_mean_hobo_30), climate$redcap_event_name, exclude=NULL)
table(round(climate$rainfall_hobo_30),climate$redcap_event_name, exclude=NULL)

hist(round(climate$temp_mean_hobo_30))
hist(round(climate$rainfall_hobo_30))

climate<-climate[order((-grepl('rain|temp', names(climate)))+1L)]
climate<-climate[order((-grepl('date_collected|redcap_event_name', names(climate)))+1L)]

climate$id_site<-NA
climate <- within (climate, id_site[climate$redcap_event_name=="chulaimbo_village_arm_1"] <- "Chulaimbo")
climate <- within (climate, id_site[climate$redcap_event_name=="msambweni_arm_1"] <- "Msambweni")
climate <- within (climate, id_site[climate$redcap_event_name=="obama_arm_1"] <- "Kisumu")
climate <- within (climate, id_site[climate$redcap_event_name=="ukunda_arm_1"] <- "Ukunda")
rain <- climate[ , grepl("date_collected|id_site|rain" , names(climate) ) ]
temp <- climate[ , grepl("date_collected|id_site|temp" , names(climate) ) ]

malaria_climate<-aicmalaria
malaria_climate<-merge(malaria_climate, rain, by.x = c("interview_date_aic_A","id_site_A"), by.y = c("date_collected","id_site"), all.x = T) 
malaria_climate<-merge(malaria_climate, temp, by.x = c("interview_date_aic_A","id_site_A"), by.y = c("date_collected","id_site"), all.x = T) 

table(round(malaria_climate$temp_mean_hobo_30), malaria_climate$id_site_A, exclude = NULL)
table(round(malaria_climate$rainfall_hobo_30), malaria_climate$id_site_A, exclude = NULL)



# table one ---------------------------------------------------------------
library(tableone)
vars<-c("ses_sum","rainfall_hobo_30","temp_mean_hobo_30","rainfall_hobo","temp_mean_hobo","aic_calculated_age_A",  "temp_A", "roof_type_A", "latrine_type_A", "floor_type_A", "drinking_water_source_A", "number_windows_A", "gender_aic_A", "fever_contact_A", "mosquito_bites_aic_A", "mosquito_net_aic_A")
factorVars<-c("roof_type_A", "latrine_type_A", "floor_type_A", "drinking_water_source_A", "gender_aic_A", "fever_contact_A", "mosquito_bites_aic_A", "mosquito_net_aic_A")

tableOne_mal_c <- CreateTableOne(vars = vars, factorVars = factorVars, strata = "result_microscopy_malaria_kenya_A", data = malaria_climate_c)
tableOne_mal_k <- CreateTableOne(vars = vars, factorVars = factorVars, strata = "result_microscopy_malaria_kenya_A", data = malaria_climate_k)
tableOne_mal_m <- CreateTableOne(vars = vars, factorVars = factorVars, strata = "result_microscopy_malaria_kenya_A", data = malaria_climate_m)
tableOne_mal_u <- CreateTableOne(vars = vars, factorVars = factorVars, strata = "result_microscopy_malaria_kenya_A", data = malaria_climate_u)

tableOne_site <- CreateTableOne(vars = vars, factorVars = factorVars, strata = "id_site_A", data = malaria_climate)

# scatter plot ------------------------------------------------------------
my_cols <- c("#00AFBB", "#E7B800")  
pairs(na.omit(aicmalaria[vars]), pch = 19,  cex = 0.5, col = my_cols[aicmalaria$result_microscopy_malaria_kenya_A], lower.panel=NULL)
cor(na.omit(aicmalaria[vars]))
# non-linear temperature option 1. splines -------------------------------------------------------
#install.packages("splines")
library("splines")
malaria_climate$id_site_A<-as.factor(malaria_climate$id_site_A)
malaria_climate$drinking_water_source_A<-as.factor(malaria_climate$drinking_water_source_A)
malaria_climate$gender_aic_A<-as.factor(malaria_climate$gender_aic_A)
malaria_climate$fever_contact_A<-as.factor(malaria_climate$fever_contact_A)
malaria_climate$mosquito_net_aic_A<-as.factor(malaria_climate$mosquito_net_aic_A)

hist(climate$temp_mean_hobo_30)
class(malaria_climate$id_site_A)
malaria_climate$agecat_A<-as.factor(malaria_climate$agecat_A)
malaria_climate$reportcough_A<-as.factor(malaria_climate$reportcough_A)
malaria_climate$reportdiarrhea_A<-as.factor(malaria_climate$reportdiarrhea_A)
malaria_climate$reportjoint_A<-as.factor(malaria_climate$reportjoint_A)
malaria_climate$reportnv_A<-as.factor(malaria_climate$reportnv_A)
malaria_climate$id_site_A<-as.factor(malaria_climate$id_site_A)

bs(malaria_climate$temp_mean_hobo_30, df = 3)
bs(malaria_climate$rainfall_hobo_30, df = 4)

# random intercept for site -----------------------------------------------------------------
library(lmerTest)
library(lme4)
class(malaria_climate$id_site_A)
summary(spline.malaria.random <- lmer(result_microscopy_malaria_kenya_A ~ reportcough_A+reportdiarrhea_A+reportnv_A+reportjoint_A+bs(temp_mean_hobo_30, df = 3) + bs(rainfall_hobo_30, df = 4) + as.factor(agecat_A) +   fever_contact_A + mosquito_bites_aic_A +  (1|id_site_A)+gender_aic_A, data = malaria_climate))
anova(spline.malaria.random)
exp(confint(spline.malaria.random, method="boot", parallel="multicore", ncpus=4))

# all sites -----------------------------------------------------------------
summary(spline.malaria <- lm(result_microscopy_malaria_kenya_A ~ reportcough_A+reportdiarrhea_A+reportnv_A+reportjoint_A+bs(temp_mean_hobo_30, df = 3) +  bs(rainfall_hobo_30, df = 4) + agecat_A +  fever_contact_A + mosquito_bites_aic_A + id_site_A + gender_aic_A, data = malaria_climate))
table(malaria_climate$result_microscopy_malaria_kenya_A, round(malaria_climate$rainfall_hobo_30), exclude=NULL)
exp(cbind(OR = coef(spline.malaria), confint(spline.malaria)))
# by site -----------------------------------------------------------------
summary(spline.malaria.c <- lm(result_microscopy_malaria_kenya_A ~ reportcough_A+reportdiarrhea_A+reportnv_A+reportjoint_A+bs(temp_mean_hobo_30, df = 3) + rainfall_hobo_30 + as.factor(agecat_A) +   fever_contact_A + mosquito_bites_aic_A  + gender_aic_A, data = malaria_climate_c))
exp(cbind(OR = coef(spline.malaria.c), confint(spline.malaria.c)))
summary(spline.malaria.k <- lm(result_microscopy_malaria_kenya_A ~ reportcough_A+reportdiarrhea_A+reportnv_A+reportjoint_A+bs(temp_mean_hobo_30, df = 3) + rainfall_hobo_30  + as.factor(agecat_A) + fever_contact_A + mosquito_bites_aic_A +  gender_aic_A, data = malaria_climate_k))
exp(cbind(OR = coef(spline.malaria.k), confint(spline.malaria.k)))
summary(spline.malaria.m <- lm(result_microscopy_malaria_kenya_A ~ reportcough_A+reportdiarrhea_A+reportnv_A+reportjoint_A+bs(temp_mean_hobo_30, df = 3) + rainfall_hobo_30 + as.factor(agecat_A) + fever_contact_A + mosquito_bites_aic_A +  gender_aic_A, data = malaria_climate_m))
exp(cbind(OR = coef(spline.malaria.m), confint(spline.malaria.m)))
summary(spline.malaria.u <- lm(result_microscopy_malaria_kenya_A ~ reportcough_A+reportdiarrhea_A+reportnv_A+reportjoint_A+ rainfall_hobo_30 + as.factor(agecat_A) + fever_contact_A + mosquito_bites_aic_A +  gender_aic_A, data = malaria_climate_u))
exp(cbind(OR = coef(spline.malaria.u), confint(spline.malaria.u)))

#hold all effects constant except temp
  plot(effects::Effect(focal.predictors = c("temp_mean_hobo_30"), mod = spline.malaria, 
            xlevels = list(temp_mean_hobo.30 = 22:31)), rug = FALSE)
  plot(effects::Effect(focal.predictors = c("rainfall_hobo_30"), mod = spline.malaria, 
                       xlevels = list(rainfall_hobo_30 = 0:442)), rug = FALSE)
saveRDS(malaria_climate, file="malaria_climate.rds")