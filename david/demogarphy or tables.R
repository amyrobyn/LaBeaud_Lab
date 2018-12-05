#Table 2, OR of demographics in reference to no-infection 
vars=c("mosquito_bites_aic", "mosquito_deterrent","always_net")
AIC$strata_all<-as.factor(AIC$strata_all)
AIC$strata_all<-relevel(AIC$strata_all,"malaria_neg_denv_neg")
print(levels(AIC$strata_all))

AIC <- within(AIC, number_people_in_house[number_people_in_house>20] <-NA )
hist(AIC$number_people_in_house,breaks=100)

number_people_in_house<-glm(number_people_in_house~strata_all-1, family="poisson", data = AIC)
summary(number_people_in_house)
exp(cbind("Odds ratio" = coef(number_people_in_house),confint(number_people_in_house, level = 0.95, parallel="multicore", ncpus=4)))

always_net<-glm(always_net~factor(strata_all), family="binomial", data = AIC)
exp(coefficients(always_net))
fits <- lapply(vars, function(x) {glm(substitute(i~strata_all, list(i = as.name(x))), family="binomial", data = AIC)})


coef<-lapply(fits, coefficients)
coef<-lapply(fits, function(x) {exp(cbind("Odds ratio" = coef(x), confint(x, level = 0.95,parallel="multicore", ncpus=4)))})



lapply(coef, function(x) write.table( data.frame(x), 'demo_or.dec5.csv'  , append= T, sep=',' ))

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
lapply(ptable, function(x) write.table( data.frame(x), 'demo_acute_OR_dec5.csv'  , append= T, sep=',' ))

# freq tables -------------------------------------------------------------
AIC$strata_all <- factor(AIC$strata_all, levels = c("malaria_pos_denv_pos","malaria_neg_denv_pos","malaria_pos_denv_neg","malaria_neg_denv_neg"))
table(AIC$strata_all)

AIC$gender_all<-as.factor(AIC$gender_all)
table(AIC$gender_all)
AIC$gender_all<-relevel(AIC$gender_all,"1")

dem_vars=c("gender_all","aic_calculated_age","ses_sum","mosquito_bites_aic","mosquito_deterrent","always_net","zbmi","zhfa")
dem_factorVars <- c("gender_all","mosquito_bites_aic", "mosquito_deterrent","always_net") 

dem_tableOne_total <- CreateTableOne(vars = dem_vars, factorVars = dem_factorVars, data = AIC)
dem_tableOne_total.csv <-print(dem_tableOne_total, nonnormal=c("aic_calculated_age"), quote = F, noSpaces = TRUE, includeNA=TRUE,, printToggle = FALSE)
write.csv(dem_tableOne_total.csv, file = "dem_tableOne_total.csv")

dem_tableOne_strata_all <- CreateTableOne(vars = dem_vars, factorVars = dem_factorVars, strata = "strata_all", data = AIC)
table(AIC$strata_all,AIC$mosquito_bites_aic)
tab <- matrix(c(457, 1530, 38, 150, 386, 2306, 32, 249), 4, 2, byrow=TRUE)
dimnames(tab) <- list("outcome" = c("NON", "DENV", "malaria","Coinfection"),"exposure" = c("non","Exposed"))
tab <- DescTools::Rev(tab, direction="column")
(249/32)/(1530/457)
OddsRatio(tab[c(1,4),], method="mle", conf.level=0.95)
(2306/386)/(1530/457)
OddsRatio(tab[c(2,4),], method="mle", conf.level=0.95)
(150/38)/(1530/457)
OddsRatio(tab[c(3,4),], method="mle", conf.level=0.95)

dem_tableOne_strata_all.csv <-print(dem_tableOne_strata_all, nonnormal=c("aic_calculated_age"), quote = F, noSpaces = TRUE, includeNA=TRUE,, printToggle = FALSE)
write.csv(dem_tableOne_strata_all.csv, file = "dem_tableOne_strata_all.csv")
hist(AIC$zhfa,breaks = 100)
