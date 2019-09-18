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


# randomized crossover design ---------------------------------------------
  #install.packages("Crossover")
  #install.packages("crossdes")
  #install.packages("clusterPower")
  library(clusterPower)
  
  #alpha .05; power = .8; delta is based on 97% reduction in acute testing with increase exposure to homocides; 
  #cluster is household with mean size of 3;  cv is variation in household size; icc is a guess with a max of .3.
  #varw is within cluster variation and a guess but sapmle size is highly dependent on this.
  #x2 is for 50% of households reporting fever; x4 is for 25% being due to dengue. 
  clusterPower::crtpwr.2mean(alpha = .05, power = 0.8, cv=2, d=0.97, icc=.3,varw=.01,n=3)*2*4
  
  #alpha .05; power = .8; delta is based on 97% reduction in acute testing with increase exposure to homocides; 
  #cluster is household with mean size of 3;  cv is variation in household size; icc is a guess.
  #varw is within cluster variation and a guess but sapmle size is highly dependent on this.
  #x2 is for 50% of households reporting fever; x4 is for 25% being due to dengue. 
  clusterPower::crtpwr.2prop(n=3,cv=5,icc=.5,alpha=.05,power=.8,p1=1,p2=0.03)*2*4
  
  #alpha .05; power = .8; delta is based on 4x reduction in care seeking with increase exposure to violence; 
  #cluster is household with mean size of 3;  cv is variation in household size; icc is a guess with a max of .3.
  #varw is within cluster variation and a guess but sapmle size is highly dependent on this.
  #x2 is for 25% of households reporting fever; x4 is for 25% being due to dengue. 
  clusterPower::crtpwr.2rate(r1=1,r2=11,alpha=.05,power=.8,py=2,cvb=.9)*4*4
  
  clusterPower::power.sim.normal(n.sim = 10, effect.size = log(.25), alpha = .05,period.var =0,ICC=.05,period.effect = 0,n.periods = 48,n.clusters = 480,cluster.size = 3,btw.clust.var = .01, estimation.function = fixed.effect.cluster.level)
  
  set.seed(17)
  library(clusterPower)
  
  test<-clusterPower::power.sim.normal(n.sim=10, effect.size=log(.25), alpha=.05,n.clusters = 30,n.periods = 48,
                                       cluster.size = 3,
                    btw.clust.var = .1, period.effect = 0, period.var = 0.5, 
                    estimation.function = fixed.effect.cluster.level, ICC = 0.1)
  test$power
  plot(test$results)
  #install.packages("simr")
  library(simr)
  cbpp$obs <- 1:nrow(cbpp)
  gm1 <- glmer(cbind(incidence, size - incidence) ~ period + (1 | herd) + (1|obs), data=cbpp,
               family=binomial)
  summary(gm1)$coef
  doTest(gm1, fixed("period", "lr"))
  doTest(gm1, fixed("period2", "z"))
  
  gm2 <- glmer(cbind(incidence, size - incidence) ~ period + size + (1 | herd), data=cbpp,
               family=binomial)
  doTest(gm2, fixed("size", "z"))
  fixef(gm2)["size"] <- 0.05
  powerSim(gm2, fixed("size", "z"), nsim=50)
  #more complex
  fm1 <- lmer(angle ~ recipe * temp + (1|recipe:replicate), data=cake, REML=FALSE)
  doTest(fm1, fcompare(~ recipe + temp))
  fm2 <- lmer(angle ~ recipe + poly(temp, 2) + (1|recipe:replicate), data=cake, REML=FALSE)
  summary(fm2)$coef
  doTest(fm2, fcompare(~ recipe + temp))

#simulate from scratch ---------------------------------------------------------------------
  date <- as.Date(seq(0, 1440, by=30),origin="2021-2-5",format="%Y-%m-%d")
  barrio <- letters[1:9]
  casa <- 1:150
  fever <- 0:1
  clinic <- 0:1
  age <- 0:80
  violence <- 0:1
  X <- expand.grid(date=date, barrio=barrio, casa=casa, fever=fever, clinic=clinic, age=age,violence=violence) 
  summary(X)
  df = dt[seq(1, nrow(dt), 80), ]
  df[sample(nrow(df), 48*150*6), ]

##simmulate data ----------------------------------------------------------------------
  #install.packages("simstudy")
  library(simstudy)
  def <- defData(varname = "date", dist = "uniformInt", formula = "1;1440", id = "idnum")
  def <- defData(def, varname = "month", dist = "uniformInt", formula = "1;12")
  def <- defData(def, varname = "barrio", dist = "categorical", formula = "0.15;0.15;0.15;0.15;0.15;0.15")
  def <- defData(def, varname = "casa", dist = "uniformInt", formula = "1;150")
  def <- defData(def, varname = "age", dist = "normal", formula = 30, variance = 30)
  def <- defData(def, varname = "fever", dist = "binary", formula = ".5*(1/log(age))")
  def <- defData(def, varname = "symptoms", dist = "categorical", formula = "0.8;0.2")
  def <- defData(def, varname = "violence", dist = "normal", formula = "120+barrio*.5-date*.005+log(month)*6",variance = 80)
  def <- defData(def, varname = "violence_cat", dist = "binary", formula = "((violence-93.91)/(160.62 - 93.91))")
  def <- defData(def, varname = "clinic", dist = "poisson", formula = "fever*(1/violence*4)*40")
  rows=1440*6*150
  dt <- genData(rows, def)
  df = dt[seq(1, nrow(dt), 30), ]
  df$date<-as.Date(df$date,origin="01-01-2021",format="d%-m%-y%")
  
  df$strata<-paste(df$casa,df$barrio,sep="_")
  
  hist(dt$violence)
##decompose violence time series ----------------------------------------------------------------------
  violence.ts = ts(df$violence, frequency=12, start=c(2021,1))
  ts.plot(violence.ts)
  # fit the stl model using only the s.window argument
  library(stats)
  fit = stl(violence.ts, s.window="periodic")
  plot(fit)
  fit2 = stl(violence.ts, s.window="periodic", t.window=15)
  plot(fit2)
  
  
  hist(dt$clinic)
  hist(dt$violence)
  hist(dt$age)
  hist(dt$fever)

##simulate power based on simmulated data ----------------------------------------------------------------------
  library(simr)
  gm1 <- lmer(clinic ~ violence + month + (1 | strata), data=df,family="Poisson")
  summary(gm1)$coef
  doTest(gm1, fixed("violence", "lr"))
  doTest(gm1, fixed("violence", "z"))
  powerSim(gm1, fixed("violence", "z"), nsim=50)

##set effect size parameters and simulate power ----------------------------------------------------------------------
  #Specify some fixed and random parameters.
    b <- c(2, -0.75) # fixed intercept and slope 
    V1 <- 0.5 # random intercept variance 
    V2 <- matrix(c(0.5,0.05,0.05,0.1), 2) # random intercept and slope variance-covariance matrix 
    s <- 1 # residual standard deviation
    
  #Use the makeLmer or makeGlmer function to build an artificial lme4 object.
    model1 <- makeLmer(clinic ~ violence + (1|strata), fixef=b, VarCorr=V1, sigma=s, data=df) 
    print(model1)
    powerSim(model1, fixed("violence", "z"), nsim=50)
    model2 <- makeGlmer(clinic ~ violence + (violence|barrio), family="poisson", fixef=b, VarCorr=V2, data=df) 
    print(model2)
    powerSim(model2, fixed("violence", "z"), nsim=50)
