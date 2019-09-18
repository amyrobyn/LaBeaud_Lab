load("C:/Users/amykr/Box Sync/Amy Krystosik's Files/students/melisa/malaria_climate.rda")
##### THIS IS IT FINAL MODEL 
library(lme4)
library(splines)
library(DHARMa)

??DHARMa
vignette("DHARMa", package="DHARMa")
citation("DHARMa")

#adding year into the model
malaria_climate$year = as.factor(format(malaria_climate$interview_date_aic_A, "%Y"))

malaria_climate<-malaria_climate[,c("person_id","result_microscopy_malaria_kenya_A" , "temp_mean_30_30dlag", "rain_sum_30_30dlag", "agecat", "mosquito_bites_aic_A", "poorses", "gender_aic_A", "year", "id_site_A")]
malaria_climate<-malaria_climate[complete.cases(malaria_climate),]

summary(spline.malaria <- glmer(result_microscopy_malaria_kenya_A ~ ns(temp_mean_30_30dlag, knots=c(24,26)) + log(rain_sum_30_30dlag) + agecat + mosquito_bites_aic_A + poorses + gender_aic_A + (1|year) + (1|id_site_A), family="binomial", data = malaria_climate))
anova(spline.malaria)
simulationOutput <- simulateResiduals(fittedModel = spline.malaria, n=1000)
hist(simulationOutput)
plot(simulationOutput,quantreg = T)
plotResiduals(simulationOutput$fittedPredictedResponse, simulationOutput$scaledResiduals)
testResiduals(simulationOutput)
testDispersion(simulationOutput)
testZeroInflation(simulationOutput)
testOutliers(simulationOutput)
plotResiduals(pred = malaria_climate$temp_mean_30_30dlag, 
              residuals = simulationOutput$scaledResiduals, quantreg = T,xlim=c(22, 32),xlab="30 day lagged Temperature (C)")

simulationOutput <- simulateResiduals(fittedModel = spline.malaria, refit = T)
simulationOutput <- simulateResiduals(fittedModel = spline.malaria, n = 250, use.u = T)
simulationOutput = recalculateResiduals(simulationOutput, group = malaria_climate$year)
simulationOutput$randomState



plot(effects::Effect(focal.predictors = c("temp_mean_30_30dlag"), mod = spline.malaria, xlevels = list(temp_mean_30_30dlag = 22.64:30.99)), 
     rescale.axis=FALSE,
     ylim=c(0,1),
     rug = FALSE, sub="All Sites",main="", ylab="Smear Positivity Rate", xlab="Lagged 30-day Mean Temperature (Celcius)")

effects::Effect("temp_mean_30_30dlag", spline.malaria, xlevels=list(temp_mean_30=22.6:31.02,.5))

summary(malaria_climate$temp_mean_30_30dlag)
summary(malaria_climate_c$rain_sum_30_30dlag)
summary(malaria_climate_k$rain_sum_30_30dlag)
summary(malaria_climate_m$rain_sum_30_30dlag)
summary(malaria_climate_u$rain_sum_30_30dlag)
