library("plyr")
library(redcapAPI)
library(REDCapR)
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/vector")
# import climate data -------------------------------------------------------------
  Redcap.token <- readLines("api.key.txt") # Read API token from folder
  REDcap.URL  <- 'https://redcap.stanford.edu/api/'
  rcon <- redcapConnection(url=REDcap.URL, token=Redcap.token)
climate <- redcap_read(redcap_uri  = REDcap.URL, token = Redcap.token, batch_size = 100)$data#export data from redcap to R (must be connected via cisco VPN)
  #save backup from today
  currentDate <- Sys.Date() 
  FileName <- paste("vector_climate",currentDate,".rda",sep=" ") 
  save(vector_climate,file=FileName)
  #load most recent backup
#  load(FileName)
  climate<-vector_climate
  
  climate$month_collected <- as.yearmon(climate$date_collected)
  table(climate$month_collected)
  
  #format date
    library(zoo)
    library(lubridate)
  climate$date_collected<-as.Date(climate$date_collected)
  climate$date_collected<-ymd(climate$date_collected)
  
  #remove outliers
  climate <-climate[which(climate$rainfall_hobo<=120), ]
  
#plot climate
  library(plotly)
  plot_hobo<-plot_ly(climate, x = ~date_collected, y = ~rainfall_hobo, type = 'scatter', mode="lines", name = 'rainfall hobo')%>%
            add_trace(y = ~temp_max_hobo, name = 'Max Temp Hobo',type = 'scatter', mode="lines", fill = 'tonexty', fillcolor='rgba(0,100,80,0.2)', line = list(color = 'transparent'), yaxis = "y2") %>%
            add_trace(y = ~temp_min_hobo, name = 'Min Temp Hobo',type = 'scatter', mode="lines",fill = 'tonexty', fillcolor='rgba(0,100,80,0.2)', line = list(color = 'transparent'), yaxis = "y2") %>%
            add_trace(y = ~temp_mean_hobo, name = 'Mean Temp Hobo',type = 'scatter', mode="lines", yaxis = "y2") %>%
    
            #add_trace(y = ~rh_mean_hobo, name = 'rh_mean_hobo',type = 'scatter',mode="lines") %>%
            #add_trace(y = ~climate$dewpt_mean_hobo, name = 'dewpt_mean_hobo',type = 'scatter',mode="lines") %>%
            layout(title = 'Temperature, and rainfall in Kenya 2014-2017',
                             xaxis = list(title = "Date"),
                             yaxis = list(side = 'left', title = 'Precipitation (mm)', showgrid = FALSE, zeroline = TRUE), barmode='relative',
                             yaxis2 = list(side = 'right', overlaying = "y", title = 'Mean temperature (degrees C)', 
                                           showgrid = FALSE, zeroline = FALSE))

  #   add_trace(data=temp, x = ~Date, y = ~upper, name = 'Max temp', mode = 'lines+markers', fill = 'tonexty', fillcolor='rgba(0,100,80,0.2)', line = list(color = 'transparent'), yaxis = "y2")%>%
  #   add_trace(data=temp, x = ~Date, y = ~lower, name = 'Min temp', mode = 'lines+markers', fill = 'tonexty', fillcolor='rgba(0,100,80,0.2)', line = list(color = 'transparent'), yaxis = "y2")%>%
  
  # dates -------------------------------------------------------------
  climate$date_lag<-climate$date_collected-30
  climate$date_lag<-as.Date(climate$date_lag)
  table(round(climate$temp_mean_hobo), climate$redcap_event_name)
# save climate data -------------------------------------------------------------
  save(climate,file="climate.rda")
# monthly summary by site:chulaimbo -------------------------------------------------------------
  chulaimboClimate<-climate[which(climate$redcap_event_name =="chulaimbo_village_arm_1"|climate$redcap_event_name =="chulaimbo_hospital_arm_1"), ]
  # Creating the anomaly data (data that's farther than 1.5 SD from the mean)
  chulaimboRainMean <- mean(chulaimboClimate$rainfall_hobo,  na.rm=TRUE) 
  chulaimboRainSD <- sqrt(var(chulaimboClimate$rainfall_hobo,  na.rm=TRUE))
  
  chulaimboClimate$RainfallAnomaly <- sapply(chulaimboClimate$rainfall_hobo, # Logical values indicating if the rain exceeds 1.5 sd of the mean
                                             function(x, m , sd) (x > m + 1.5*sd), 
                                             m = chulaimboRainMean, sd = chulaimboRainSD)
  
  chulaimboClimate$TempRange <- chulaimboClimate$temp_max_hobo - chulaimboClimate$temp_min_hobo
  
  chulaimboRangeMean <- mean(chulaimboClimate$TempRange); chulaimboRangeSD <- sqrt(var(chulaimboClimate$TempRange))
  
  chulaimboClimate$RangeAnomaly <- sapply(chulaimboClimate$TempRange, 
                                          function(x, m , sd) (x > m + 1.5*sd),
                                          m = chulaimboRangeMean, sd = chulaimboRangeSD)
  
  
  chulaimboClimate$DewDiff <- chulaimboClimate$temp_mean_hobo - chulaimboClimate$dewpt_mean_hobo
  
  chulaimboDewDiffMean <- mean(chulaimboClimate$DewDiff, na.rm = T); chulaimboDewDiffSD <- sqrt(var(chulaimboClimate$DewDiff, na.rm = T))
  
  chulaimboClimate$DewDiffAnomaly <- sapply(chulaimboClimate$DewDiff, 
                                            function(x, m , sd) (x < m - 1.5*sd),
                                            m = chulaimboDewDiffMean, sd = chulaimboDewDiffSD)
  
  chulaimboTempMean <- mean(chulaimboClimate$temp_mean_hobo, na.rm = T); chulaimboTempSD <- sqrt(var(chulaimboClimate$temp_mean_hobo, na.rm = T))
  chulaimboRHMean <- mean(chulaimboClimate$rh_mean_hobo, na.rm = T); chulaimboRHSD <- sqrt(var(chulaimboClimate$rh_mean_hobo , na.rm = T))
  
  chulaimboClimate$TempAnom <- sapply(chulaimboClimate$Temp, 
                                      function(x, m , sd) (x < m + 1.5*sd),
                                      m = chulaimboTempMean, sd = chulaimboTempSD)
  chulaimboClimate$RHAnom <- sapply(chulaimboClimate$rh_mean_hobo, 
                                    function(x, m , sd) (x < m + 1.5*sd),
                                    m = chulaimboRHMean, sd = chulaimboRHSD)
  
  chulaimboClimate$RHTempAnomaly = (chulaimboClimate$TempAnom & chulaimboClimate$RHAnom)
  
  library("plyr")
  chulaimboMonthlyClimate <- ddply(chulaimboClimate, ~month_collected , summarise, AvgTemp = mean(temp_mean_hobo, na.rm = T), 
                                   AvgMaxTemp = mean(temp_max_hobo, na.rm = T), AvgMinTemp = mean(temp_min_hobo, na.rm = T), 
                                   OverallMaxTemp = max(temp_max_hobo, na.rm = T), OverallMinTemp = min(temp_min_hobo, na.rm = T),
                                   AvgTempRange = mean((temp_max_hobo - temp_min_hobo), na.rm = T), AvgRH = mean(rh_mean_hobo, na.rm = T),
                                   AvgDewPt = mean(dewpt_mean_hobo, na.rm = T), TtlRainfall = sum(rainfall_hobo, na.rm = T),
                                   RainfallAnomalies = sum(RainfallAnomaly, na.rm = T), TempRangeAnomalies = sum(RangeAnomaly, na.rm = T),
                                   TempDewPtDiffAnomalies = sum(DewDiffAnomaly, na.rm = T), TempAnomalies = sum(TempAnom, na.rm = T),
                                   RHAnomalies = sum(RHAnom, na.rm = T), RHTempAnomalies = sum(RHTempAnomaly, na.rm = T), study_site = "c") 
  
  save(chulaimboMonthlyClimate,file="chulaimboMonthlyClimate.rda")
        # monthly summary by site:Ukunda -------------------------------------------------------------
        UkundaClimate<-climate[which(climate$redcap_event_name =="ukunda_arm_1"), ]
        # Creating the anomaly data (data that's farther than 1.5 SD from the mean)
        UkundaRainMean <- mean(UkundaClimate$rainfall_hobo,  na.rm=TRUE) 
        UkundaRainSD <- sqrt(var(UkundaClimate$rainfall_hobo,  na.rm=TRUE))
        
        UkundaClimate$RainfallAnomaly <- sapply(UkundaClimate$rainfall_hobo, # Logical values indicating if the rain exceeds 1.5 sd of the mean
                                                function(x, m , sd) (x > m + 1.5*sd), 
                                                m = UkundaRainMean, sd = UkundaRainSD)
        
        UkundaClimate$TempRange <- UkundaClimate$temp_max_hobo - UkundaClimate$temp_min_hobo
        
        UkundaRangeMean <- mean(UkundaClimate$TempRange); UkundaRangeSD <- sqrt(var(UkundaClimate$TempRange))
        
        UkundaClimate$RangeAnomaly <- sapply(UkundaClimate$TempRange, 
                                             function(x, m , sd) (x > m + 1.5*sd),
                                             m = UkundaRangeMean, sd = UkundaRangeSD)
        
        
        UkundaClimate$DewDiff <- UkundaClimate$temp_mean_hobo - UkundaClimate$dewpt_mean_hobo
        
        UkundaDewDiffMean <- mean(UkundaClimate$DewDiff, na.rm = T); UkundaDewDiffSD <- sqrt(var(UkundaClimate$DewDiff, na.rm = T))
        
        UkundaClimate$DewDiffAnomaly <- sapply(UkundaClimate$DewDiff, 
                                               function(x, m , sd) (x < m - 1.5*sd),
                                               m = UkundaDewDiffMean, sd = UkundaDewDiffSD)
        
        UkundaTempMean <- mean(UkundaClimate$temp_mean_hobo, na.rm = T); UkundaTempSD <- sqrt(var(UkundaClimate$temp_mean_hobo, na.rm = T))
        UkundaRHMean <- mean(UkundaClimate$rh_mean_hobo, na.rm = T); UkundaRHSD <- sqrt(var(UkundaClimate$rh_mean_hobo , na.rm = T))
        
        UkundaClimate$TempAnom <- sapply(UkundaClimate$Temp, 
                                         function(x, m , sd) (x < m + 1.5*sd),
                                         m = UkundaTempMean, sd = UkundaTempSD)
        UkundaClimate$RHAnom <- sapply(UkundaClimate$rh_mean_hobo, 
                                       function(x, m , sd) (x < m + 1.5*sd),
                                       m = UkundaRHMean, sd = UkundaRHSD)
        
        UkundaClimate$RHTempAnomaly = (UkundaClimate$TempAnom & UkundaClimate$RHAnom)
        
        UkundaMonthlyClimate <- ddply(UkundaClimate, ~month_collected , summarise, AvgTemp = mean(temp_mean_hobo, na.rm = T), 
                                      AvgMaxTemp = mean(temp_max_hobo, na.rm = T), AvgMinTemp = mean(temp_min_hobo, na.rm = T), 
                                      OverallMaxTemp = max(temp_max_hobo, na.rm = T), OverallMinTemp = min(temp_min_hobo, na.rm = T),
                                      AvgTempRange = mean((temp_max_hobo - temp_min_hobo), na.rm = T), AvgRH = mean(rh_mean_hobo, na.rm = T),
                                      AvgDewPt = mean(dewpt_mean_hobo, na.rm = T), TtlRainfall = sum(rainfall_hobo, na.rm = T),
                                      RainfallAnomalies = sum(RainfallAnomaly, na.rm = T), TempRangeAnomalies = sum(RangeAnomaly, na.rm = T),
                                      TempDewPtDiffAnomalies = sum(DewDiffAnomaly, na.rm = T), TempAnomalies = sum(TempAnom, na.rm = T),
                                      RHAnomalies = sum(RHAnom, na.rm = T), RHTempAnomalies = sum(RHTempAnomaly, na.rm = T), study_site = "u") 
        
        save(UkundaMonthlyClimate,file="UkundaMonthlyClimate.rda")
        
        # monthly summary by site:kisumu -------------------------------------------------------------
        kisumuClimate<-climate[which(climate$redcap_event_name =="kisumu_estate_arm_1"), ]
        # Creating the anomaly data (data that's farther than 1.5 SD from the mean)
        kisumuRainMean <- mean(kisumuClimate$rainfall_hobo,  na.rm=TRUE) 
        kisumuRainSD <- sqrt(var(kisumuClimate$rainfall_hobo,  na.rm=TRUE))
        
        kisumuClimate$RainfallAnomaly <- sapply(kisumuClimate$rainfall_hobo, # Logical values indicating if the rain exceeds 1.5 sd of the mean
                                                function(x, m , sd) (x > m + 1.5*sd), 
                                                m = kisumuRainMean, sd = kisumuRainSD)
        
        kisumuClimate$TempRange <- kisumuClimate$temp_max_hobo - kisumuClimate$temp_min_hobo
        
        kisumuRangeMean <- mean(kisumuClimate$TempRange); kisumuRangeSD <- sqrt(var(kisumuClimate$TempRange))
        
        kisumuClimate$RangeAnomaly <- sapply(kisumuClimate$TempRange, 
                                             function(x, m , sd) (x > m + 1.5*sd),
                                             m = kisumuRangeMean, sd = kisumuRangeSD)
        
        
        kisumuClimate$DewDiff <- kisumuClimate$temp_mean_hobo - kisumuClimate$dewpt_mean_hobo
        
        kisumuDewDiffMean <- mean(kisumuClimate$DewDiff, na.rm = T); kisumuDewDiffSD <- sqrt(var(kisumuClimate$DewDiff, na.rm = T))
        
        kisumuClimate$DewDiffAnomaly <- sapply(kisumuClimate$DewDiff, 
                                               function(x, m , sd) (x < m - 1.5*sd),
                                               m = kisumuDewDiffMean, sd = kisumuDewDiffSD)
        
        kisumuTempMean <- mean(kisumuClimate$temp_mean_hobo, na.rm = T); kisumuTempSD <- sqrt(var(kisumuClimate$temp_mean_hobo, na.rm = T))
        kisumuRHMean <- mean(kisumuClimate$rh_mean_hobo, na.rm = T); kisumuRHSD <- sqrt(var(kisumuClimate$rh_mean_hobo , na.rm = T))
        
        kisumuClimate$TempAnom <- sapply(kisumuClimate$Temp, 
                                         function(x, m , sd) (x < m + 1.5*sd),
                                         m = kisumuTempMean, sd = kisumuTempSD)
        kisumuClimate$RHAnom <- sapply(kisumuClimate$rh_mean_hobo, 
                                       function(x, m , sd) (x < m + 1.5*sd),
                                       m = kisumuRHMean, sd = kisumuRHSD)
        
        kisumuClimate$RHTempAnomaly = (kisumuClimate$TempAnom & kisumuClimate$RHAnom)
        
        kisumuMonthlyClimate <- ddply(kisumuClimate, ~month_collected , summarise, AvgTemp = mean(temp_mean_hobo, na.rm = T), 
                                      AvgMaxTemp = mean(temp_max_hobo, na.rm = T), AvgMinTemp = mean(temp_min_hobo, na.rm = T), 
                                      OverallMaxTemp = max(temp_max_hobo, na.rm = T), OverallMinTemp = min(temp_min_hobo, na.rm = T),
                                      AvgTempRange = mean((temp_max_hobo - temp_min_hobo), na.rm = T), AvgRH = mean(rh_mean_hobo, na.rm = T),
                                      AvgDewPt = mean(dewpt_mean_hobo, na.rm = T), TtlRainfall = sum(rainfall_hobo, na.rm = T),
                                      RainfallAnomalies = sum(RainfallAnomaly, na.rm = T), TempRangeAnomalies = sum(RangeAnomaly, na.rm = T),
                                      TempDewPtDiffAnomalies = sum(DewDiffAnomaly, na.rm = T), TempAnomalies = sum(TempAnom, na.rm = T),
                                      RHAnomalies = sum(RHAnom, na.rm = T), RHTempAnomalies = sum(RHTempAnomaly, na.rm = T), study_site = "k") 
        
        save(kisumuMonthlyClimate,file="kisumuMonthlyClimate.rda")
        # monthly summary by site:msambweni -------------------------------------------------------------
        msambweniClimate<-climate[which(climate$redcap_event_name =="msambweni_arm_1"), ]
        # Creating the anomaly data (data that's farther than 1.5 SD from the mean)
        msambweniRainMean <- mean(msambweniClimate$rainfall_hobo,  na.rm=TRUE) 
        msambweniRainSD <- sqrt(var(msambweniClimate$rainfall_hobo,  na.rm=TRUE))
        
        msambweniClimate$RainfallAnomaly <- sapply(msambweniClimate$rainfall_hobo, # Logical values indicating if the rain exceeds 1.5 sd of the mean
                                                   function(x, m , sd) (x > m + 1.5*sd), 
                                                   m = msambweniRainMean, sd = msambweniRainSD)
        
        msambweniClimate$TempRange <- msambweniClimate$temp_max_hobo - msambweniClimate$temp_min_hobo
        
        msambweniRangeMean <- mean(msambweniClimate$TempRange); msambweniRangeSD <- sqrt(var(msambweniClimate$TempRange))
        
        msambweniClimate$RangeAnomaly <- sapply(msambweniClimate$TempRange, 
                                                function(x, m , sd) (x > m + 1.5*sd),
                                                m = msambweniRangeMean, sd = msambweniRangeSD)
        
        
        msambweniClimate$DewDiff <- msambweniClimate$temp_mean_hobo - msambweniClimate$dewpt_mean_hobo
        
        msambweniDewDiffMean <- mean(msambweniClimate$DewDiff, na.rm = T); msambweniDewDiffSD <- sqrt(var(msambweniClimate$DewDiff, na.rm = T))
        
        msambweniClimate$DewDiffAnomaly <- sapply(msambweniClimate$DewDiff, 
                                                  function(x, m , sd) (x < m - 1.5*sd),
                                                  m = msambweniDewDiffMean, sd = msambweniDewDiffSD)
        
        msambweniTempMean <- mean(msambweniClimate$temp_mean_hobo, na.rm = T); msambweniTempSD <- sqrt(var(msambweniClimate$temp_mean_hobo, na.rm = T))
        msambweniRHMean <- mean(msambweniClimate$rh_mean_hobo, na.rm = T); msambweniRHSD <- sqrt(var(msambweniClimate$rh_mean_hobo , na.rm = T))
        
        msambweniClimate$TempAnom <- sapply(msambweniClimate$Temp, 
                                            function(x, m , sd) (x < m + 1.5*sd),
                                            m = msambweniTempMean, sd = msambweniTempSD)
        msambweniClimate$RHAnom <- sapply(msambweniClimate$rh_mean_hobo, 
                                          function(x, m , sd) (x < m + 1.5*sd),
                                          m = msambweniRHMean, sd = msambweniRHSD)
        
        msambweniClimate$RHTempAnomaly = (msambweniClimate$TempAnom & msambweniClimate$RHAnom)
        
        msambweniMonthlyClimate <- ddply(msambweniClimate, ~month_collected , summarise, AvgTemp = mean(temp_mean_hobo, na.rm = T), 
                                         AvgMaxTemp = mean(temp_max_hobo, na.rm = T), AvgMinTemp = mean(temp_min_hobo, na.rm = T), 
                                         OverallMaxTemp = max(temp_max_hobo, na.rm = T), OverallMinTemp = min(temp_min_hobo, na.rm = T),
                                         AvgTempRange = mean((temp_max_hobo - temp_min_hobo), na.rm = T), AvgRH = mean(rh_mean_hobo, na.rm = T),
                                         AvgDewPt = mean(dewpt_mean_hobo, na.rm = T), TtlRainfall = sum(rainfall_hobo, na.rm = T),
                                         RainfallAnomalies = sum(RainfallAnomaly, na.rm = T), TempRangeAnomalies = sum(RangeAnomaly, na.rm = T),
                                         TempDewPtDiffAnomalies = sum(DewDiffAnomaly, na.rm = T), TempAnomalies = sum(TempAnom, na.rm = T),
                                         RHAnomalies = sum(RHAnom, na.rm = T), RHTempAnomalies = sum(RHTempAnomaly, na.rm = T), study_site = "m") 
        
        save(msambweniMonthlyClimate,file="msambweniMonthlyClimate.rda")
        # monthly summary by site:obama -------------------------------------------------------------
        obamaClimate<-climate[which(climate$redcap_event_name =="obama_arm_1"), ]
        # Creating the anomaly data (data that's farther than 1.5 SD from the mean)
        obamaRainMean <- mean(obamaClimate$rainfall_hobo,  na.rm=TRUE) 
        obamaRainSD <- sqrt(var(obamaClimate$rainfall_hobo,  na.rm=TRUE))
        
        obamaClimate$RainfallAnomaly <- sapply(obamaClimate$rainfall_hobo, # Logical values indicating if the rain exceeds 1.5 sd of the mean
                                               function(x, m , sd) (x > m + 1.5*sd), 
                                               m = obamaRainMean, sd = obamaRainSD)
        
        obamaClimate$TempRange <- obamaClimate$temp_max_hobo - obamaClimate$temp_min_hobo
        
        obamaRangeMean <- mean(obamaClimate$TempRange); obamaRangeSD <- sqrt(var(obamaClimate$TempRange))
        
        obamaClimate$RangeAnomaly <- sapply(obamaClimate$TempRange, 
                                            function(x, m , sd) (x > m + 1.5*sd),
                                            m = obamaRangeMean, sd = obamaRangeSD)
        
        
        obamaClimate$DewDiff <- obamaClimate$temp_mean_hobo - obamaClimate$dewpt_mean_hobo
        
        obamaDewDiffMean <- mean(obamaClimate$DewDiff, na.rm = T); obamaDewDiffSD <- sqrt(var(obamaClimate$DewDiff, na.rm = T))
        
        obamaClimate$DewDiffAnomaly <- sapply(obamaClimate$DewDiff, 
                                              function(x, m , sd) (x < m - 1.5*sd),
                                              m = obamaDewDiffMean, sd = obamaDewDiffSD)
        
        obamaTempMean <- mean(obamaClimate$temp_mean_hobo, na.rm = T); obamaTempSD <- sqrt(var(obamaClimate$temp_mean_hobo, na.rm = T))
        obamaRHMean <- mean(obamaClimate$rh_mean_hobo, na.rm = T); obamaRHSD <- sqrt(var(obamaClimate$rh_mean_hobo , na.rm = T))
        
        obamaClimate$TempAnom <- sapply(obamaClimate$Temp, 
                                        function(x, m , sd) (x < m + 1.5*sd),
                                        m = obamaTempMean, sd = obamaTempSD)
        obamaClimate$RHAnom <- sapply(obamaClimate$rh_mean_hobo, 
                                      function(x, m , sd) (x < m + 1.5*sd),
                                      m = obamaRHMean, sd = obamaRHSD)
        
        obamaClimate$RHTempAnomaly = (obamaClimate$TempAnom & obamaClimate$RHAnom)
        
        obamaMonthlyClimate <- ddply(obamaClimate, ~month_collected , summarise, AvgTemp = mean(temp_mean_hobo, na.rm = T), 
                                     AvgMaxTemp = mean(temp_max_hobo, na.rm = T), AvgMinTemp = mean(temp_min_hobo, na.rm = T), 
                                     OverallMaxTemp = max(temp_max_hobo, na.rm = T), OverallMinTemp = min(temp_min_hobo, na.rm = T),
                                     AvgTempRange = mean((temp_max_hobo - temp_min_hobo), na.rm = T), AvgRH = mean(rh_mean_hobo, na.rm = T),
                                     AvgDewPt = mean(dewpt_mean_hobo, na.rm = T), TtlRainfall = sum(rainfall_hobo, na.rm = T),
                                     RainfallAnomalies = sum(RainfallAnomaly, na.rm = T), TempRangeAnomalies = sum(RangeAnomaly, na.rm = T),
                                     TempDewPtDiffAnomalies = sum(DewDiffAnomaly, na.rm = T), TempAnomalies = sum(TempAnom, na.rm = T),
                                     RHAnomalies = sum(RHAnom, na.rm = T), RHTempAnomalies = sum(RHTempAnomaly, na.rm = T), study_site = "o") 
        
        save(obamaMonthlyClimate,file="obamaMonthlyClimate.rda")
        

        MonthlyClimate_mean <- ddply(climate, ~month_collected , summarise, AvgTemp = mean(temp_mean_hobo, na.rm = T), 
                                     AvgMaxTemp = mean(temp_max_hobo, na.rm = T), AvgMinTemp = mean(temp_min_hobo, na.rm = T), 
                                     OverallMaxTemp = max(temp_max_hobo, na.rm = T), OverallMinTemp = min(temp_min_hobo, na.rm = T),
                                     AvgTempRange = mean((temp_max_hobo - temp_min_hobo), na.rm = T), AvgRH = mean(rh_mean_hobo, na.rm = T),
                                     AvgDewPt = mean(dewpt_mean_hobo, na.rm = T), TtlRainfall = sum(rainfall_hobo, na.rm = T),
                                     study_site = "all") 
        table(round(MonthlyClimate_mean$AvgTempRange))
        
# merge the villages back -------------------------------------------------
  MonthlyClimate<-rbind(obamaMonthlyClimate, chulaimboMonthlyClimate, UkundaMonthlyClimate, msambweniMonthlyClimate, kisumuMonthlyClimate)
        
# save climate data -------------------------------------------------------------
  MonthlyClimate$month_year<-MonthlyClimate$month_collected
        MonthlyClimate$month_year<-MonthlyClimate$month_collected
        MonthlyClimate_mean$month_year<-MonthlyClimate_mean$month_collected
        save(MonthlyClimate_mean,file="MonthlyClimate_mean.rda")
        save(MonthlyClimate,file="MonthlyClimate.rda")
        