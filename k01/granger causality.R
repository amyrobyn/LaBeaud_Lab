# get aic data data -----------------------------------------------------------------
library(REDCapR)
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long")
Redcap.token <- readLines("Redcap.token.R01.txt") # Read API token from folder
REDcap.URL  <- 'https://redcap.stanford.edu/api/'
R01_lab_results <- redcap_read(redcap_uri  = REDcap.URL, token = Redcap.token, batch_size = 300)$data#export data from redcap to R (must be connected via cisco VPN)
currentDate <- Sys.Date() 
FileName <- paste("R01_lab_results",currentDate,".rda",sep=" ") 
save(R01_lab_results,file=FileName)

R01_lab_results$id_cohort<-substr(R01_lab_results$person_id, 2, 2)
R01_lab_results$id_city<-substr(R01_lab_results$person_id, 1, 1)

AIC_A<-  R01_lab_results[R01_lab_results$id_cohort=="F"&R01_lab_results$redcap_event_name=="visit_a_arm_1",]
AIC_A$yearmon<-as.yearmon(as.Date(AIC_A$interview_date_aic))
AIC_A<-AIC_A[AIC_A$yearmon>2000,]
table(AIC_A$yearmon)

# get climate data -----------------------------------------------------------------
library(REDCapR)
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/students/melisa")


setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long")
Redcap.token <- readLines("Redcap.token.climate.txt") # Read API token from folder
REDcap.URL  <- 'https://redcap.stanford.edu/api/'
#R01_climate <- redcap_read(redcap_uri  = REDcap.URL, token = Redcap.token, batch_size = 300)$data#export data from redcap to R (must be connected via cisco VPN)
currentDate <- Sys.Date() 
FileName <- paste("R01_climate",currentDate,".rda",sep=" ") 
#save(R01_climate,file=FileName)

gapfilled_climate<-read.csv("gapfilled_climate_data.csv")
gapfilled_climate_long<-reshape(gapfilled_climate,timevar="site",direction = "long",varying = 2:17,sep = ".",idvar ="Date")
gapfilled_climate_long$yearmon<-as.yearmon(as.Date(gapfilled_climate_long$Date,format = "%m / %d / %Y"))

gapfilled_climate_long$GF_cumRain
# format time series -----------------------------------------------------------------
library(dplyr)
climate_month<-gapfilled_climate_long %>%group_by(yearmon,site) %>%summarize(rain_mean = mean(GF_rain, na.rm = TRUE),
                                                                               rain_min = min(GF_rain, na.rm = TRUE),
                                                                               rain_max = max(GF_rain, na.rm = TRUE),
                                                                               rain_median = median(GF_rain, na.rm = TRUE),
                                                                               rain_sd = sd(GF_rain, na.rm = TRUE)
)

AIC_A$count<-1
AIC_month<-AIC_A %>%group_by(yearmon,id_city) %>%summarize(aic_visits = sum(count, na.rm = TRUE),
                                                           aic_sex=mean(gender_aic,na.rm=T))
AIC_month<-AIC_month[!is.na(AIC_month$yearmon),]
ts.AIC_month = ts(AIC_month$aic_visits, start = c(2014,1), end=c(2019, 4), frequency = 12)
plot(ts.AIC_month) 
ts.AIC_month.dc<-decompose(ts.AIC_month)
plot(ts.AIC_month.dc)


ts.climate_month = ts(climate_month$rain_mean, start = c(2014,1), end=c(2019, 4), frequency = 12)
plot(ts.climate_month) 
ts.climate_month.dc<-decompose(ts.climate_month)
plot(ts.AIC_month.dc)

# merge climate and aic -----------------------------------------------------------------
ts.union<-ts.union(ts.AIC_month,ts.climate_month)
plot(ts.union)
ts.union.dc<-decompose(ts.union)
plot(ts.union.dc)
library(sarima)
ts.climate_month.arima<-auto.arima(ts.climate_month,seasonal = T)
plot(ts.climate_month.arima)
autoplot(ts.climate_month.arima)

ts.AIC_month.d<-diff(ts.AIC_month)
ts.climate_month.d<-diff(ts.climate_month)

library(lmtest)
grangertest(ts.AIC_month~ts.climate_month, order=2)

library(sarima)
sarima(ts.AIC_month~ts.climate_month, use.symmetry = FALSE,SSinit = "Rossignol2011")

library(forecast)

library(vars)
var.1<-VAR(ts.union, p = 2, type = "both")
plot(stability(var.1))
summary(var.1)

causality(var.1, cause = "ts.climate_month")


for (i in 1:20)
{
  cat("LAG =", i)
  print(causality(VAR(ts.union, p = i, type = "both"), cause = "ts.climate_month")$Granger)
}
