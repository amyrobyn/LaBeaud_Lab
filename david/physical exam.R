# physical table ----------------------------------------------------------
pe_vars<- colnames(AIC[, grepl("aic_pe", names(AIC))])
pe_vars<-pe_vars[pe_vars != "aic_pe_hyperactive_bowel_sounds"]

pe_tableOne_strata_all <- CreateTableOne(vars = pe_vars, factorVars = pe_vars, strata = "strata_all", data = AIC)
#summary(pe_tableOne)
pe_tableOne_strata_all.csv<-print(pe_tableOne_strata_all, 
                                        exact = pe_vars,
                                        #nonnormal=pe_vars,
                                        quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE)

write.csv(pe_tableOne_strata_all.csv, file = "pe_tableOne_strata_all_dec5.csv")

#Table 2, OR of symptom/sign in reference to co-infection 
AIC$strata_all.backup<-AIC$strata_all
AIC$strata_all<-AIC$strata_all.backup

AIC$strata_all<-as.character(AIC$strata_all)
AIC <- within(AIC, strata_all[strata_all=="malaria_pos_denv_pos"] <-"0" )
AIC <- within(AIC, strata_all[strata_all=="malaria_neg_denv_neg"] <-"1" )
AIC <- within(AIC, strata_all[strata_all=="malaria_pos_denv_neg"] <-"2" )
AIC <- within(AIC, strata_all[strata_all=="malaria_neg_denv_pos"] <-"3" )
AIC$strata_all<-as.numeric(AIC$strata_all)
table(AIC$aic_pe_rapid_rate,AIC$strata_all)

test<-glm(aic_pe_rapid_rate~factor(strata_all)-1, family="binomial",data=AIC)
exp(coefficients(test))
table(AIC$aic_pe_rapid_rate,AIC$strata_all)
(35/256)
(200/1937)/(35/256)

(394/2398)/(35/256)

(22/187)/(35/256)

tab <- matrix(c(2, 29, 35, 64, 12, 6), 3, 2, byrow=TRUE)
dimnames(tab) <- list("Tap water exposure" = c("Lowest", "Intermediate", "Highest"), 
                      "Outcome" = c("Case", "Control"))

table(AIC$strata_all,AIC$aic_pe_red_eyes)
library(DescTools)
tab <- matrix(c(2071, 66, 187, 22, 2730, 62, 277, 14), 4, 2, byrow=TRUE)
dimnames(tab) <- list("Exposure" = c("Coinfection", "negative", "malaria","denv"),"Outcome" = c("non","Rapid Rate"))
tab <- DescTools::Rev(tab, direction="column")
(64/2073)/(14/277)
(13/196)/(14/277)
(82/2710)/(14/277)

OddsRatio(tab[c(2,1),], method="mle", conf.level=0.95)#malaria
OddsRatio(tab[c(3,1),], method="mle", conf.level=0.95)#denv
OddsRatio(tab[c(4,1),], method="mle", conf.level=0.95)#negneg

fits <- lapply(pe_vars, function(x) {glm(substitute(i~factor(strata_all)-1, list(i = as.name(x))), family="binomial", data = AIC)})
coef<-lapply(fits, coefficients)
coef<-lapply(fits, function(x) {exp(cbind("Odds ratio" = coef(x), confint(x, level = 0.95, parallel="multicore", ncpus=4)))})

lapply(coef, function(x) write.table( data.frame(x), 'pe_or.ci_dec5.csv'  , append= T, sep=',' ))

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
lapply(ptable, function(x) write.table( data.frame(x), 'pe_acute_OR_dec5.csv'  , append= T, sep=',' ))
