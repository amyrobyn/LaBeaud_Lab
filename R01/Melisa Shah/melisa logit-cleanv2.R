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
    #create sum of last month's data for each day.
    library(dplyr)
    library(zoo)
    library(DataCombine)
#    install.packages("DataCombine")
# moving mean for that day and previous days (e.g. 5 represents the mean of that day and the for previous days)

  climate = climate %>%
      group_by(redcap_event_name) %>%
      arrange(redcap_event_name, date_collected) %>%
      mutate(temp_mean_hobo.30 = rollmean(x = temp_mean_hobo, 30, align = "right", fill = NA))
  table(round(climate$temp_mean_hobo.30))

  climate = climate[order(climate$redcap_event_name, climate$date_collected), ]
  climate = climate %>%
    group_by(redcap_event_name) %>%
    arrange(redcap_event_name, date_collected) %>%
    mutate(rainfall_hobo.30 = rollsum(x = rainfall_hobo, 30, align = "right", fill = NA))
  
  hist(round(climate$rainfall_hobo.30))

table(aicmalaria$id_site_A)
table(climate$redcap_event_name)
climate$id_site<-NA
climate <- within (climate, id_site[climate$redcap_event_name=="chulaimbo_village_arm_1"] <- "Chulaimbo")
climate <- within (climate, id_site[climate$redcap_event_name=="msambweni_arm_1"] <- "Msambweni")
climate <- within (climate, id_site[climate$redcap_event_name=="obama_arm_1"] <- "Kisumu")
climate <- within (climate, id_site[climate$redcap_event_name=="ukunda_arm_1"] <- "Ukunda")
rain <- climate[ , grepl("date_collected|id_site|rain" , names(climate) ) ]
temp <- climate[ , grepl("date_collected|id_site|temp" , names(climate) ) ]
malaria_climate<-aicmalaria
malaria_climate$interview_date_aic_A
malaria_climate<-merge(malaria_climate, rain, by.x = c("interview_date_aic_A","id_site_A"), by.y = c("date_collected","id_site"), all = T) 
malaria_climate<-merge(malaria_climate, temp, by.x = c("interview_date_aic_A","id_site_A"), by.y = c("date_collected","id_site"), all = T) 


# table one ---------------------------------------------------------------
vars<-c("rainfall_hobo","temp_mean_hobo","aic_calculated_age_A",  "temp_A", "roof_type_A", "latrine_type_A", "floor_type_A", "drinking_water_source_A", "number_windows_A", "gender_aic_A", "fever_contact_A", "mosquito_bites_aic_A", "mosquito_net_aic_A")
factorVars<-c("roof_type_A", "latrine_type_A", "floor_type_A", "drinking_water_source_A", "gender_aic_A", "fever_contact_A", "mosquito_bites_aic_A", "mosquito_net_aic_A")
tableOne <- CreateTableOne(vars = vars, factorVars = factorVars, strata = "result_microscopy_malaria_kenya_A", data = malaria_climate)

# scatter plot ------------------------------------------------------------
my_cols <- c("#00AFBB", "#E7B800")  
pairs(na.omit(aicmalaria[vars]), pch = 19,  cex = 0.5, col = my_cols[aicmalaria$result_microscopy_malaria_kenya_A], lower.panel=NULL)
cor(na.omit(aicmalaria[vars]))

# logit -------------------------------------------------------------------
#install.packages("aod")
library(aod)
library(ggplot2)

mylogit <- glm(result_microscopy_malaria_kenya_A ~ rainfall_hobo*temp_mean_hobo + aic_calculated_age_A + temp_A + as.factor(id_site_A) + as.factor(drinking_water_source_A) + as.factor(gender_aic_A) + as.factor(fever_contact_A) + as.factor(mosquito_net_aic_A)*number_windows_A , data = malaria_climate, family = "binomial")

var=c("gender_aic_A", "drinking_water_source_A","temp_mean_hobo","rainfall_hobo")
cor(na.omit(malaria_climate[var]))
    

summary(mylogit)
wald.test(b = coef(mylogit), Sigma = vcov(mylogit), Terms = 4:6)
exp(cbind(OR = coef(mylogit), confint(mylogit)))
#only chulaimbo
malaria_climate_chulaimbo<- malaria_climate[which(malaria_climate$id_site_A== "Chulaimbo")  , ]

mylogit <- glm(result_microscopy_malaria_kenya_A ~ rainfall_hobo*temp_mean_hobo +aic_calculated_age_A + temp_A + drinking_water_source_A*gender_aic_A + fever_contact_A + mosquito_net_aic_A*number_windows_A , data = malaria_climate_chulaimbo, family = "binomial")

summary(mylogit)
wald.test(b = coef(mylogit), Sigma = vcov(mylogit), Terms = 4:6)
exp(cbind(OR = coef(mylogit), confint(mylogit)))
# confounding -------------------------------------------------------------

# effect modification -----------------------------------------------------

# non-linear temperature option 1. splines -------------------------------------------------------
#install.packages("splines")
library("splines")
malaria_climate$id_site_A<-as.factor(malaria_climate$id_site_A)
malaria_climate$drinking_water_source_A<-as.factor(malaria_climate$drinking_water_source_A)
malaria_climate$gender_aic_A<-as.factor(malaria_climate$gender_aic_A)
malaria_climate$fever_contact_A<-as.factor(malaria_climate$fever_contact_A)
malaria_climate$mosquito_net_aic_A<-as.factor(malaria_climate$mosquito_net_aic_A)

summary(spline.malaria <- lm(result_microscopy_malaria_kenya_A ~ bs(temp_mean_hobo.30, df = 3)*rainfall_hobo.30 + aic_calculated_age_A + temp_A + id_site_A + drinking_water_source_A + gender_aic_A + fever_contact_A + mosquito_net_aic_A*number_windows_A , data = malaria_climate))
  boot::inv.logit(coef(spline.malaria)[2])
  boot::inv.logit(coef(spline.malaria)[3])
  boot::inv.logit(coef(spline.malaria)[4])
#hold all effects constant except rain and temp
  plot(effects::Effect(focal.predictors = c("temp_mean_hobo.30","rainfall_hobo.30"), mod = spline.malaria, 
            xlevels = list(temp_mean_hobo.30 = 22:31)), rug = FALSE)
#hold all effects constant except temp
  plot(effects::Effect(focal.predictors = c("temp_mean_hobo.30"), mod = spline.malaria, 
                     xlevels = list(temp_mean_hobo.30 = 18:31)), rug = FALSE)

wald.test(b = coef(spline.malaria), Sigma = vcov(spline.malaria), Terms = 4:6)
exp(cbind(OR = coef(spline.malaria), confint(spline.malaria)))

saveRDS(malaria_climate, file="malaria_climate.rds")

