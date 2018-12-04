#table 1
dem_vars=c("id_city", "gender_all","aic_calculated_age","ses_sum","mosquito_bites_aic", "mosquito_coil_aic", "outdoor_activity_aic", "mosquito_net_aic","mom_highest_level_education_aic","mosquito_deterrent","always_net")
dem_factorVars <- c("id_city","mosquito_bites_aic", "mosquito_coil_aic", "outdoor_activity_aic", "mosquito_net_aic") 
dem_tableOne_site <-CreateTableOne(vars = dem_vars, factorVars = dem_factorVars, strata = "id_city", data = AIC)
dem_tableOne_site.csv <-print(dem_tableOne_site, nonnormal=c("aic_calculated_age"), exact = c("id_city", "gender_all", "mosquito_bites_aic", "mosquito_coil_aic", "outdoor_activity_aic", "mosquito_net_aic"), quote = F, noSpaces = TRUE, includeNA=TRUE,, printToggle = FALSE)
write.csv(dem_tableOne_site.csv, file = "dem_tableOne_site.csv")

dem_tableOne_total <- CreateTableOne(vars = dem_vars, factorVars = dem_factorVars, data = AIC)
dem_tableOne_total.csv <-print(dem_tableOne_total, nonnormal=c("aic_calculated_age"), exact = c("id_city", "gender_all", "mosquito_bites_aic", "mosquito_coil_aic", "outdoor_activity_aic", "mosquito_net_aic"), quote = F, noSpaces = TRUE, includeNA=TRUE,, printToggle = FALSE)
write.csv(dem_tableOne_total.csv, file = "dem_tableOne_total.csv")

dem_tableOne_strata_all <- CreateTableOne(vars = dem_vars, factorVars = dem_factorVars, strata = "strata_all", data = AIC)
dem_tableOne_strata_all.csv <-print(dem_tableOne_strata_all, nonnormal=c("aic_calculated_age"), exact = c("id_city", "gender_all", "mosquito_bites_aic", "mosquito_coil_aic", "outdoor_activity_aic", "mosquito_net_aic"), quote = F, noSpaces = TRUE, includeNA=TRUE,, printToggle = FALSE)
write.csv(dem_tableOne_strata_all.csv, file = "dem_tableOne_strata_all.csv")


#Table 2, OR of demographics in reference to no-infection 
vars=c("mosquito_bites_aic", "mosquito_deterrent","always_net")
AIC <- fastDummies::dummy_cols(AIC, select_columns = "strata_all")

fits <- lapply(vars, function(x) {glm(substitute(i~strata_all_malaria_pos_denv_pos+strata_all_malaria_neg_denv_pos+strata_all_malaria_pos_denv_neg -1, list(i = as.name(x))), family="binomial", data = AIC)})

AIC <- within(AIC, number_people_in_house[number_people_in_house>20] <-NA )
hist(AIC$number_people_in_house,breaks=100)

number_people_in_house<-glm(number_people_in_house~strata_all_malaria_pos_denv_pos+strata_all_malaria_neg_denv_pos+strata_all_malaria_pos_denv_neg -1, family="poisson", data = AIC)

coef<-lapply(fits, coefficients)
coef<-lapply(fits, function(x) {exp(cbind("Odds ratio" = coef(x), confint(x, level = 0.95,method="boot", parallel="multicore", ncpus=4)))})

exp(confint(number_people_in_house, level = 0.95,method="boot", parallel="multicore", ncpus=4))


lapply(coef, function(x) write.table( data.frame(x), 'demo_or.bootstrap_dec4.csv'  , append= T, sep=',' ))

#https://stats.stackexchange.com/questions/63222/getting-p-values-for-multinom-in-r-nnet-package
#install.packages("afex")
library(afex)
set_sum_contrasts() # use sum coding, necessary to make type III LR tests valid
library(car)
#install.packages("AER")
library(AER)
p<-lapply(fits, coeftest)
library(broom)
ptable<-lapply(p, tidy)
lapply(ptable, function(x) write.table( data.frame(x), 'demo_acute_OR_dec4.csv'  , append= T, sep=',' ))
