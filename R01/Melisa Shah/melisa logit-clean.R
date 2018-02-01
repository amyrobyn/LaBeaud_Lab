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
table(aicmalaria$id_site_A)
table(climate$redcap_event_name)
climate$id_site<-NA
climate <- within (climate, id_site[climate$redcap_event_name=="chulaimbo_village_arm_1"] <- "Chulaimbo")
climate <- within (climate, id_site[climate$redcap_event_name=="msambweni_arm_1"] <- "Msambweni")
climate <- within (climate, id_site[climate$redcap_event_name=="obama_arm_1"] <- "Kisumu")
climate <- within (climate, id_site[climate$redcap_event_name=="ukunda_arm_1"] <- "Ukunda")
class(climate$date_collected)
climate$date_collected_1mL<-as.Date(climate$date_collected-30)
rain <- climate[ , grepl("date_collected|id_site|rain" , names(climate) ) ]
temp <- climate[ , grepl("date_collected|id_site|temp" , names(climate) ) ]
malaria_climate<-aicmalaria
malaria_climate<-merge(malaria_climate, rain, by.x = c("interview_date_aic_A","id_site_A"), by.y = c("date_collected_1mL","id_site"), all = T) 
malaria_climate<-merge(malaria_climate, temp, by.x = c("interview_date_aic_A","id_site_A"), by.y = c("date_collected_1mL","id_site"), all = T) 
malaria_climate$normal_temp<-800*0.95^((malaria_climate$temp_mean_hobo-25)^2)
  
plot(malaria_climate$result_microscopy_malaria_kenya_A, round(malaria_climate$rainfall_hobo))


plot(malaria_climate$result_microscopy_malaria_kenya_A, round(malaria_climate$temp_mean_hobo))
plot(round(malaria_climate$temp_mean_hobo))
plot(round(malaria_climate$normal_temp))
plot(malaria_climate$result_microscopy_malaria_kenya_A~ round(malaria_climate$temp_mean_hobo))

library(ggplot2)
ggplot(malaria_climate, aes(x = temp_mean_hobo, y = ..density.., fill = result_microscopy_malaria_kenya_A == 1)) +
  geom_histogram() + 
  scale_fill_manual(values = c("gray30", "skyblue"))
install.packages("rstanarm")
library("rstanarm")
library("stan_glm")

t_prior <- student_t(df = 7, location = 0, scale = 2.5)
fit1 <- stan_glm(result_microscopy_malaria_kenya_A ~ temp_mean_hobo, data = malaria_climate, 
                 family = binomial(link = "logit"), 
                 prior = t_prior, prior_intercept = t_prior,  
                 chains = CHAINS, cores = CORES, seed = SEED, iter = ITER)

round(posterior_interval(fit1, prob = 0.5), 2)

# Predicted probability as a function of x
pr_malaria <- function(x, ests) plogis(ests[1] + ests[2] * x)
# A function to slightly jitter the binary data
jitt <- function(...) {
  geom_point(aes_string(...), position = position_jitter(height = 0.05, width = 0.1), 
             size = 2, shape = 21, stroke = 0.2)
}
ggplot(malaria_climate, aes(x = temp_mean_hobo, y = result_microscopy_malaria_kenya_A, color = result_microscopy_malaria_kenya_A)) + 
  scale_y_continuous(breaks = c(0, 0.5, 1)) +
  jitt(x="temp_mean_hobo") + 
  stat_function(fun = pr_malaria, args = list(ests = coef(fit1)), 
                size = 2, color = "gray35")

fit2 <- update(fit1, formula = result_microscopy_malaria_kenya_A ~ temp_mean_hobo + rainfall_hobo) 

(coef_fit2 <- round(coef(fit2), 3))

pr_malaria2 <- function(x, y, ests) plogis(ests[1] + ests[2] * x + ests[3] * y)
grid <- expand.grid(temp_mean_hobo = seq(0, 4, length.out = 100), 
                    rainfall_hobo = seq(0, 10, length.out = 100))
grid$prob <- with(grid, pr_malaria2(temp_mean_hobo, rainfall_hobo, coef(fit2)))
ggplot(grid, aes(x = temp_mean_hobo, y = rainfall_hobo)) + 
  geom_tile(aes(fill = prob)) + 
  geom_point(data = malaria_climate, aes(color = factor(result_microscopy_malaria_kenya_A)), size = 2, alpha = 0.85) + 
  scale_fill_gradient() +
  scale_color_manual("result_microscopy_malaria_kenya_A", values = c("white", "black"), labels = c("Negative", "Positive"))
  
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

saveRDS(malaria_climate, file="malaria_climate.rds")

#only chulaimbo
malaria_climate_chulaimbo<- malaria_climate[which(malaria_climate$id_site_A== "Chulaimbo")  , ]

mylogit <- glm(result_microscopy_malaria_kenya_A ~ rainfall_hobo*temp_mean_hobo +aic_calculated_age_A + temp_A + drinking_water_source_A*gender_aic_A + fever_contact_A + mosquito_net_aic_A*number_windows_A , data = malaria_climate_chulaimbo, family = "binomial")

summary(mylogit)
wald.test(b = coef(mylogit), Sigma = vcov(mylogit), Terms = 4:6)
exp(cbind(OR = coef(mylogit), confint(mylogit)))
# confounding -------------------------------------------------------------

# effect modification -----------------------------------------------------


