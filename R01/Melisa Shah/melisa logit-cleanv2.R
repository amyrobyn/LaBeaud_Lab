#  I'm not sure how to include environmental variables like temperature/humidity/rainfall.......
  
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/melisa shah")
aicmalaria <- readRDS("aicmalaria.rds")

library(plyr)
age_site <- ddply(aicmalaria, .(id_site_A), 
                  summarise, 
                  age_mean  = mean(aic_calculated_age_A, na.rm = TRUE),
                  fever_sd  = sd(aic_calculated_age_A, na.rm = TRUE))

pairwise.t.test(aicmalaria$aic_calculated_age_A, aicmalaria$id_site_A, p.adjust="bonferroni", na.rm=TRUE)

#Usually, incubation periods vary depending on the species of Plasmodium causing malaria. The average incubation period is 9-14 days for Plasmodium falciparum, 12-17 days for infections by Plasmodium vivax and 18-40 days for infections caused by Plasmodium malariae[1].
aicmalaria <- aicmalaria[ , grepl("person_id|redcap_event|id_site|interview_date_aic_A|result_microscopy_malaria_kenya_A|aic_calculated_age_A|temp_A|roof_type_A|latrine_type_A|floor_type_A|drinking_water_source_A|number_windows_A|gender_aic_A|fever_contact_A|mosquito_bites_aic_A|mosquito_net_aic_A" , names(aicmalaria) ) ]
aicmalaria <- aicmalaria[ , !grepl("$_D|$_C|$_B|$_F|$_G|$_H" , names(aicmalaria) ) ]
aicmalaria<-aicmalaria[order((grepl('date', names(aicmalaria)))+1L)]

aicmalaria$interview_date_aic_A<-as.Date(aicmalaria$interview_date_aic_A)
class(aicmalaria$interview_date_aic_A)

load("C:/Users/amykr/Box Sync/Amy Krystosik's Files/vector/climate.rda")
climate$mean_temp<-climate$temp_mean_hobo
climate$mean_temp[!is.na(climate$ltm_lst)]<-climate$ltm_lst[!is.na(climate$ltm_lst)]
table(round(climate$mean_temp), exclude = NULL)

#create sum of last month's data for each day.
    library(dplyr)
    library(zoo)
    library(DataCombine)
#    install.packages("DataCombine")
# moving mean for that day and previous days (e.g. 5 represents the mean of that day and the for previous days)
library("zoo")
library("dplyr")
climate = climate[order(climate$date_collected), ]
    climate = climate %>%
    group_by(redcap_event_name) %>%
    mutate(
      climate$temp_mean_hobo_30<-rollapply(climate$temp_mean_hobo, width=30, mean, align ="right", partial =F, fill=NA),
      climate$rainfall_hobo_30<-rollapply(climate$rainfall_hobo, width=30, mean, align ="right", partial =F, fill=NA)
    )
  table(round(climate$temp_mean_hobo_30), climate$redcap_event_name, exclude=NA)
  table(round(climate$rainfall_hobo.30), climate$redcap_event_name, exclude=NA)

    hist(round(climate$temp_mean_hobo.30))
    hist(round(climate$rainfall_hobo.30))

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

table(round(malaria_climate$temp_mean_hobo.30), malaria_climate$id_site_A, exclude = NULL)
table(round(malaria_climate$rainfall_hobo.30), malaria_climate$id_site_A, exclude = NULL)

# table one ---------------------------------------------------------------
vars<-c("rainfall_hobo","temp_mean_hobo","aic_calculated_age_A",  "temp_A", "roof_type_A", "latrine_type_A", "floor_type_A", "drinking_water_source_A", "number_windows_A", "gender_aic_A", "fever_contact_A", "mosquito_bites_aic_A", "mosquito_net_aic_A")
factorVars<-c("roof_type_A", "latrine_type_A", "floor_type_A", "drinking_water_source_A", "gender_aic_A", "fever_contact_A", "mosquito_bites_aic_A", "mosquito_net_aic_A")
tableOne_mal <- CreateTableOne(vars = vars, factorVars = factorVars, strata = "result_microscopy_malaria_kenya_A", data = malaria_climate)

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

hist(climate$temp_mean_hobo.30)
class(malaria_climate$id_site_A)
#we are missing lots of temp!
summary(spline.malaria <- lm(result_microscopy_malaria_kenya_A ~ bs(temp_mean_hobo.30, df = 3) + rainfall_hobo.30 + aic_calculated_age_A + temp_A + drinking_water_source_A + gender_aic_A + fever_contact_A + mosquito_net_aic_A + number_windows_A, data = malaria_climate))
#hold all effects constant except temp
  table(round(malaria_climate$temp_mean_hobo.30))
  plot(effects::Effect(focal.predictors = c("temp_mean_hobo.30"), mod = spline.malaria, 
            xlevels = list(temp_mean_hobo.30 = 22:27)), rug = FALSE)

wald.test(b = coef(spline.malaria), Sigma = vcov(spline.malaria), Terms = 4:6)
exp(cbind(OR = coef(spline.malaria), confint(spline.malaria)))

saveRDS(malaria_climate, file="malaria_climate.rds")