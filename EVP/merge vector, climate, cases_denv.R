library(plyr)
library(zoo)
library(lubridate)
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/ASTMH 2017 abstracts/amy- built environment/data")
# import data -------------------------------------------------------------

  #merge vector, climate, cases by day/month/year
  load("C:/Users/amykr/Box Sync/Amy Krystosik's Files/climate/MonthlyClimate.rda")

  load(file="C:/Users/amykr/Box Sync/Amy Krystosik's Files/vector/vector.rda")
  load(file="C:/Users/amykr/Box Sync/Amy Krystosik's Files/vector/Monthlyvector.rda")
  
  load("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long/R01_lab_results.clean.rda")

# merge data -------------------------------------------------------------
  vector$date_bg <-ymd(vector$date_bg)
  class(vector$date_bg)
  vector$month_bg <- as.yearmon(vector$date_bg)
  R01_lab_results$study_site<-R01_lab_results$City
  
  R01_lab_results <- within(R01_lab_results, study_site[R01_lab_results$id_city=="L"] <- "m")
  R01_lab_results <- within(R01_lab_results, study_site[R01_lab_results$id_city=="O"] <- NA)
  R01_lab_results <- within(R01_lab_results, study_site[R01_lab_results$id_city=="R"] <- "c")
  R01_lab_results <- within(R01_lab_results, study_site[R01_lab_results$id_city=="G"] <- "m")
  R01_lab_results$study_site<-tolower(R01_lab_results$study_site)
  R01_lab_results <- within(R01_lab_results, study_site[R01_lab_results$study_site=="o"] <- "k")
  R01_lab_results <- within(R01_lab_results, study_site[R01_lab_results$study_site=="r"] <- "c")
  R01_lab_results <- within(R01_lab_results, study_site[R01_lab_results$study_site=="l"] <- "m")
  R01_lab_results <- within(R01_lab_results, study_site[R01_lab_results$study_site=="g"] <- "m")
  table(R01_lab_results$study_site)
  
  Monthlyvector <- within(Monthlyvector, study_site[Monthlyvector$study_site==1] <- "u")
  Monthlyvector <- within(Monthlyvector, study_site[Monthlyvector$study_site==2] <- "m")
  Monthlyvector <- within(Monthlyvector, study_site[Monthlyvector$study_site==3] <- "c")
  Monthlyvector <- within(Monthlyvector, study_site[Monthlyvector$study_site==4] <- "k")
  
  MonthlyClimate <- within(MonthlyClimate, study_site[MonthlyClimate$study_site=="o"] <- "k")
  
  
  
  table(Monthlyvector$study_site)
  table(MonthlyClimate$study_site)
  table(R01_lab_results$study_site)
  
  
  denv <- ddply(R01_lab_results, .(month_year, study_site),
                summarise, infected_denv_stfd_monthly = sum(infected_denv_stfd, na.rm = TRUE))
  chikv <- ddply(R01_lab_results, .(month_year, study_site),
                summarise, infected_chikv_stfd_monthly = sum(infected_chikv_stfd, na.rm = TRUE))
  
  denv <- within(denv, infected_denv_stfd_monthly[is.na(denv$month_year)] <- 0)
  denv <-denv[which(!is.na(denv$month_year)), ]
  denv$month_year<-as.Date(denv$month_year)
#lag vectors by two weeks  
  Monthlyvector$month_year<-as.Date(Monthlyvector$month_year)
  Monthlyvector$month_year_lag<-Monthlyvector$month_year-31

#lag rain by one month  
  MonthlyClimate$month_year<-as.Date(MonthlyClimate$month_year)
  MonthlyClimate$month_year_lag<-MonthlyClimate$month_year-93

  MonthlyClimate$month_year_lag<- as.yearmon(MonthlyClimate$month_year_lag)
  Monthlyvector$month_year_lag<- as.yearmon(Monthlyvector$month_year_lag)
  denv$month_year<- as.yearmon(denv$month_year)
  R01_lab_results$month_year<- as.yearmon(R01_lab_results$month_year)
  
  names(MonthlyClimate)[names(MonthlyClimate) == 'month_year'] <- 'month_year_climate'
  
  vector_climate_cases<-Monthlyvector
  vector_climate_cases<-merge(vector_climate_cases, R01_lab_results, by.x = c("month_year_lag","study_site"), by.y = c("month_year","study_site"), all = T) 
  vector_climate_cases<-merge(vector_climate_cases, MonthlyClimate, by.x = c("month_year","study_site"), by.y = c("month_year_lag","study_site"), all = T)
  vector_climate_cases<-merge(vector_climate_cases, denv, by.x = c("month_year","study_site"), by.y = c("month_year","study_site"), all = T)
  vector_climate_cases<-merge(vector_climate_cases, chikv, by.x = c("month_year","study_site"), by.y = c("month_year","study_site"), all = T)
  save(vector_climate_cases, file="vector_climate_cases.rda")
  write.csv(as.data.frame(vector_climate_cases), "vector_climate_cases.csv")
  
  vector_climate_cases_gps <-vector_climate_cases[which(!is.na(vector_climate_cases$aic_village_gps_lattitude)&!is.na(vector_climate_cases$aic_village_gps_longitude)), ]
  write.csv(as.data.frame(vector_climate_cases_gps), "vector_climate_cases_gps.csv")
#  Create Table 1 stratified by trt (omit strata argument for overall table) -------------------------------------------------------------
  library(tableone)
  table(vector_climate_cases$age)
  vars <- c("month_year", "study_site", "month_year_lag", "Ttl_Aedes.spp.Indoor.ovi", "ttl_Aedes_spp_Outdoor.ovi", "Ttl_Aedes.spp.bg", "Ttl_Aedes.spp_in.proko", "Ttl_Aedes.spp_out.proko", "Ttl_Aedes.spp.hlc", "Ttl_Aedes.spp.larva", "month_year_date", "month_collected", "AvgTemp", "AvgMaxTemp", "AvgMinTemp", "OverallMaxTemp", "OverallMinTemp", "AvgTempRange", "AvgRH", "AvgDewPt", "TtlRainfall", "RainfallAnomalies", "TempRangeAnomalies", "TempDewPtDiffAnomalies", "TempAnomalies", "RHAnomalies", "RHTempAnomalies", 'roof_type' , "floor_type","latrine_type","light_source", "id_cohort","drinking_water_source","gender_all","age_group","age")
  factorVars <- c("study_site",'roof_type',"floor_type","latrine_type","light_source", "id_cohort","drinking_water_source","gender_all","age_group")
  tableOne_denv <- CreateTableOne(vars = vars, factorVars=factorVars, strata = "infected_denv_stfd", data = vector_climate_cases)
  tableOne_chikv <- CreateTableOne(vars = vars, factorVars=factorVars, strata = "infected_chikv_stfd", data = vector_climate_cases)
  tableOne_denv_chikv <- CreateTableOne(vars = vars, factorVars=factorVars, strata = "infected_denv_chikv_stfd", data = vector_climate_cases)

  #  summary(tableOne_denv_chikv)
  print(tableOne_chikv, 
#        nonnormal = c( "Ttl_Aedes.spp.Indoor.ovi", "ttl_Aedes_spp_Outdoor.ovi", "Ttl_Aedes.spp.bg", "Ttl_Aedes.spp_in.proko", "Ttl_Aedes.spp_out.proko", "Ttl_Aedes.spp.hlc", "Ttl_Aedes.spp.larva", "month_year_date", "month_collected", "AvgTemp", "AvgMaxTemp", "AvgMinTemp", "OverallMaxTemp", "OverallMinTemp", "AvgTempRange", "AvgRH", "AvgDewPt", "TtlRainfall", "RainfallAnomalies", "TempRangeAnomalies", "TempDewPtDiffAnomalies", "TempAnomalies", "RHAnomalies", "RHTempAnomalies","age"),
        exact = c("month_year", "study_site", "month_year_lag", 'roof_type' , "floor_type","latrine_type","light_source","drinking_water_source", "id_cohort","age_group","gender_all"),
        cramVars = c("id_cohort"), quote = TRUE)
  
  
#  model data-------------------------------------------------------------
  names <- c('roof_type' ,'house_id', "house_number", "study_site","floor_type","latrine_type","light_source","drinking_water_source","gender_all","age_group")
  vector_climate_cases[,names] <- lapply(vector_climate_cases[,names] , factor)

  library(MASS)
  glm_nb<-glm.nb(infected_denv_stfd_monthly~ study_site + Ttl_Aedes.spp.Indoor.ovi + ttl_Aedes_spp_Outdoor.ovi + Ttl_Aedes.spp.bg + Ttl_Aedes.spp_in.proko + Ttl_Aedes.spp_out.proko + Ttl_Aedes.spp.hlc + Ttl_Aedes.spp.larva + AvgTemp + AvgMaxTemp + AvgMinTemp + OverallMaxTemp + OverallMinTemp + AvgTempRange + AvgRH + AvgDewPt + TtlRainfall + RainfallAnomalies + TempRangeAnomalies + TempDewPtDiffAnomalies + TempAnomalies + RHAnomalies + RHTempAnomalies + number_windows + roof_type + floor_type + latrine_type + light_source + drinking_water_source +gender_all+age_group, data = vector_climate_cases)
  summary(glm_nb)
  exp(coef(glm_nb))  

  glm_binary_denv_chikv<-glm(infected_denv_chikv_stfd~ study_site +  Ttl_Aedes.spp.Indoor.ovi + ttl_Aedes_spp_Outdoor.ovi + Ttl_Aedes.spp.bg + Ttl_Aedes.spp_in.proko + Ttl_Aedes.spp_out.proko + Ttl_Aedes.spp.hlc + Ttl_Aedes.spp.larva + AvgTemp + AvgMaxTemp + AvgMinTemp + OverallMaxTemp + OverallMinTemp + AvgTempRange + AvgRH + AvgDewPt + TtlRainfall + RainfallAnomalies + TempRangeAnomalies + TempDewPtDiffAnomalies + TempAnomalies + RHAnomalies + RHTempAnomalies + roof_type + number_windows + floor_type + latrine_type + light_source + drinking_water_source  +gender_all+age_group, family = binomial, data = vector_climate_cases)  
  summary(glm_binary_denv_chikv)
  exp(coef(glm_binary_denv_chikv))  

  glm_binary_denv<-glm(infected_denv_stfd~ study_site +  Ttl_Aedes.spp.Indoor.ovi + ttl_Aedes_spp_Outdoor.ovi + Ttl_Aedes.spp.bg + Ttl_Aedes.spp_in.proko + Ttl_Aedes.spp_out.proko + Ttl_Aedes.spp.hlc + Ttl_Aedes.spp.larva + AvgTemp + AvgMaxTemp + AvgMinTemp + OverallMaxTemp + OverallMinTemp + AvgTempRange + AvgRH + AvgDewPt + TtlRainfall + RainfallAnomalies + TempRangeAnomalies + TempDewPtDiffAnomalies + TempAnomalies + RHAnomalies + RHTempAnomalies + roof_type + number_windows + floor_type + latrine_type + light_source + drinking_water_source  +gender_all+age_group, family = binomial, data = vector_climate_cases)  
  summary(glm_binary_denv)
  exp(confint(glm_binary_denv))
  
  glm_binary_chikv<-glm(infected_chikv_stfd~ study_site +  Ttl_Aedes.spp.Indoor.ovi + ttl_Aedes_spp_Outdoor.ovi + Ttl_Aedes.spp.bg + Ttl_Aedes.spp_in.proko + Ttl_Aedes.spp_out.proko + Ttl_Aedes.spp.hlc + Ttl_Aedes.spp.larva + AvgTemp + AvgMaxTemp + AvgMinTemp + OverallMaxTemp + OverallMinTemp + AvgTempRange + AvgRH + AvgDewPt + TtlRainfall + RainfallAnomalies + TempRangeAnomalies + TempDewPtDiffAnomalies + TempAnomalies + RHAnomalies + RHTempAnomalies + roof_type + number_windows + floor_type + latrine_type + light_source + drinking_water_source  +gender_all+age_group, family = binomial, data = vector_climate_cases)  
  summary(glm_binary_chikv)
  exp(confint(glm_binary_chikv))
  
  hist(vector_climate_cases$infected_denv_stfd_monthly)
  hist(vector_climate_cases$infected_chikv_stfd_monthly)
  hist(vector_climate_cases$infected_denv_chikv_stfd)
  
# gps data -------------------------------------------------------------
  #denv
  gps_denv<-vector_climate_cases
  gps_denv<-vector_climate_cases[ , !grepl( "year|month" , names(vector_climate_cases) ) ]
  #gps_denv<-vector_climate_cases[ , grepl( "gps|latit|longit|house_id|house_number|infected_denv|infected_chikv" , names(vector_climate_cases) ) ]
  write.csv(as.data.frame(gps_denv), "gps_cases.csv")
  
    library(sp)
    gps_denv <-gps_denv[which(!is.na(gps_denv$aic_village_gps_lattitude)&!is.na(gps_denv$aic_village_gps_longitude)), ]
    coordinates(gps_denv) <- ~aic_village_gps_longitude + aic_village_gps_lattitude
    class(gps_denv)
    
    summary(gps_denv$aic_village_gps_lattitude)
    summary(gps_denv$aic_village_gps_longitude)

    require(raster)
#    projection(gps_denv) = "+init=espg:4326" # WGS84 coords
    projection(gps_denv) ="+proj=utm +zone=37 +datum=WGS84"
    
    distInMeters <- 10
    pc10km <- gBuffer(gps_denv, width=10*distInMeters, byid=TRUE)
    
    shapefile(gps_denv, "gps_denv.shp",overwrite=T)
    
    

    gps_denv.u <-gps_denv[which(gps_denv$study_site=="u"), ]
    gps_denv.c <-gps_denv[which(gps_denv$study_site=="c"), ]
    gps_denv.k <-gps_denv[which(gps_denv$study_site=="k"), ]
    gps_denv.m <-gps_denv[which(gps_denv$study_site=="m"), ]

    cases.k<-spplot(gps_denv.k,c("infected_denv_chikv_stfd"), cuts = 2, legendEntries = c("uninfected", "infected.denv.or.chikv"), include.lowest=T)    
    cases.c<-spplot(gps_denv.c,"infected_denv_chikv_stfd", cuts = 2, legendEntries = c("uninfected", "infected.denv.or.chikv"), include.lowest=T)    
    cases.m<-spplot(gps_denv.m,"infected_denv_chikv_stfd", cuts = 2, legendEntries = c("uninfected", "infected.denv.or.chikv"), include.lowest=T)    
    cases.u<-spplot(gps_denv.u,"infected_denv_chikv_stfd", cuts = 2, legendEntries = c("uninfected", "infected.denv.or.chikv"), include.lowest=T)    
    library(gridExtra)
    
    grid.arrange(cases.m,cases.u,cases.k,cases.c)

##---------------  mosquito, temp, cases plot
load("C:/Users/amykr/Box Sync/Amy Krystosik's Files/ASTMH 2017 abstracts/amy- built environment/data/vector_climate_cases.rda")
load("C:/Users/amykr/Box Sync/Amy Krystosik's Files/climate/MonthlyClimate.rda")
load("C:/Users/amykr/Box Sync/Amy Krystosik's Files/climate/MonthlyClimate_mean.rda")

load("C:/Users/amykr/Box Sync/Amy Krystosik's Files/vector/Monthlyvector.rda")

vector_climate_cases<-  vector_climate_cases[which(!is.na(vector_climate_cases$month_year)), ]
vector_climate_cases$month_year<-as.Date(vector_climate_cases$month_year)

chikv<-  chikv[which(!is.na(chikv$month_year)), ]
chikv$month_year<-as.Date(chikv$month_year)

denv<-  denv[which(!is.na(denv$month_year)), ]
denv$month_year<-as.Date(denv$month_year)

Monthlyvector<-  Monthlyvector[which(!is.na(Monthlyvector$month_year)), ]
Monthlyvector$month_year<-as.Date(Monthlyvector$month_year)

MonthlyClimate<-  MonthlyClimate[which(!is.na(MonthlyClimate$month_year)), ]
MonthlyClimate$month_year<-as.Date(MonthlyClimate$month_year)

MonthlyClimate_mean<-  MonthlyClimate_mean[which(!is.na(MonthlyClimate_mean$month_year)), ]
MonthlyClimate_mean$month_year<-as.Date(MonthlyClimate_mean$month_year)

# plot data -------------------------------------------------------------
library(plotly)

t <- list(
  family = "sans serif",
  size = 36,
  color = 'black')
f <- list(
  family = "sans serif",
  size = 28,
  color = 'black')

m <- list(
  l = 100,
  r = 150,
  b = 150,
  t = 100,
  pad = 4
)

disease <- plot_ly() %>% 
  add_trace(data=chikv, x = ~month_year, y = ~infected_chikv_stfd_monthly, name = 'CHIKV',type = 'bar', yaxis = "y") %>%
  add_trace(data=denv, x = ~month_year, y = ~infected_denv_stfd_monthly, name = 'DENV',type = 'bar', yaxis = "y") %>%
  layout(
          title = 'Incident Cases DENV & CHIKV: PCR/IgG',
          xaxis = list(type ="date", nticks = 15, tickangle =45,title = ""),
          yaxis = list(side = 'left', title = 'Total Cases/Month', showgrid = FALSE, zeroline = FALSE),
          barmode="stack",
          titlefont=t, font=f, autosize=T, margin = m)


climate <- plot_ly() %>% 
  add_trace(data=MonthlyClimate_mean, x = ~month_year, y = ~AvgTempRange, type = 'scatter', mode = 'lines', name='Temperature Range', yaxis = "y")%>%
  add_trace(data=MonthlyClimate_mean, x = ~month_year, y = ~TtlRainfall, type = 'scatter', mode = 'lines', name='Total Rain', yaxis = "y2")%>%
  layout(
    title = 'Climate in four sites in Kenya, 2014-2017',
    xaxis = list(type ="date", nticks = 15, tickangle =45,title = "Date"),
    yaxis = list(side = 'left', title = 'Total Rain (mm)', showgrid = FALSE, zeroline = FALSE),
    yaxis2 = list(side = 'right', overlaying = "y", title = 'Temp range (Degrees Celcius)', showgrid = FALSE, zeroline = FALSE),
    titlefont=t, font=f, autosize=T, margin = m)
