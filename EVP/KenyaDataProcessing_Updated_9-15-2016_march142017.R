#### Data Processing - Kenya Data, Dan Weikel (dpweikel@umich.edu/daniel.p.weikel@gmail.com)

# Note: Feel free to email me if you have any questions about the code. Beware though,
# as new forms of data are collected (more species found, etc.) this script will need to
# to be updated accordingly. I tried to note where in the comments where things are occuring
# so one could be able to make those adjustments themselves.

# In order to update the excel files, search and replace the following
#       1) the working directory that you files are looking, search setwd
#       2) the file names themselves, search read_excel 
# Also, make sure that you select the correct sheet number when changing the excel files

### Packages :
library(readxl) # Excel file reading
library(xlsx) # Writing Excel files
library(plyr) # Data frame manipulation
library(dplyr)
library(zoo) # Useful time function (as.yearmon)
library(AICcmodavg) # QAIC and GLM functions
library(MuMIn)
library(car) # VIF stuff
library(sjPlot) # For making nice tables
library(visreg) # Plotting GLM fits
library(datamart) # String processing functions included

### Data

## Climate Data
setwd("~/Desktop/Summer 2016/Newest Data") # Always set where you're grabbing stuff from

# Ukunda 
Diani <- read_excel("44 Rainfall data from Msambweni March 2016.xls")
Ukunda_Rain <- Diani[, -(2:3)]
Ukunda_Rain$Date <- as.Date(Ukunda_Rain$Date)

Diani <-  read_excel("Diani_Temp.xls")
Diani$Date <- as.Date(Diani$Date)

# Renaming the variables
names(Diani)[2] <- "Temp"; names(Diani)[3] <- "RH"; names(Diani)[4] <- "DewPt"

# Collating all of the individual day's information together
Ukunda_Daily <- ddply(Diani, ~Date, summarise,  MaxTemp = max(Temp, na.rm = T),MinTemp = min(Temp, na.rm = T),
                     Temp = mean(Temp, na.rm = T), RH = mean(RH, na.rm = T), DewPt = mean(DewPt, na.rm = T))

UkundaClimate <- merge(Ukunda_Rain, Ukunda_Daily, by = "Date", all.y = TRUE)

UkundaClimate[is.na(UkundaClimate$rain),2] <- 0 # Entering 0 for the rain fall amounts where there was none

# Removing the observations with missing or no data
UkundaClimate <- UkundaClimate[-(which(UkundaClimate$RH == "NaN")),]

# Creating the anomaly data (data that's farther than 1.5 SD from the mean)
UkundaRainMean <- mean(UkundaClimate$rain); UkundaRainSD <- sqrt(var(UkundaClimate$rain))

UkundaClimate$RainfallAnomaly <- sapply(UkundaClimate$rain, # Logical values indicating if the rain exceeds 1.5 sd of the mean
                                        function(x, m , sd) (x > m + 1.5*sd), 
                                        m = UkundaRainMean, sd = UkundaRainSD)

UkundaClimate$TempRange <- UkundaClimate$MaxTemp - UkundaClimate$MinTemp

UkundaRangeMean <- mean(UkundaClimate$TempRange); UkundaRangeSD <- sqrt(var(UkundaClimate$TempRange))

UkundaClimate$RangeAnomaly <- sapply(UkundaClimate$TempRange, 
                                     function(x, m , sd) (x > m + 1.5*sd),
                                     m = UkundaRangeMean, sd = UkundaRangeSD)

UkundaClimate$DewDiff <- UkundaClimate$Temp - UkundaClimate$DewPt

UkundaDewDiffMean <- mean(UkundaClimate$DewDiff); UkundaDewDiffSD <- sqrt(var(UkundaClimate$DewDiff))

UkundaClimate$DewDiffAnomaly <- sapply(UkundaClimate$DewDiff, 
                                       function(x, m , sd) (x < m - 1.5*sd),
                                       m = UkundaDewDiffMean, sd = UkundaDewDiffSD)

UkundaTempMean <- mean(UkundaClimate$Temp); UkundaTempSD <- sqrt(var(UkundaClimate$Temp))
UkundaRHMean <- mean(UkundaClimate$RH); UkundaRHSD <- sqrt(var(UkundaClimate$RH))

UkundaClimate$TempAnom <- sapply(UkundaClimate$Temp, 
                                 function(x, m , sd) (x < m + 1.5*sd),
                                 m = UkundaTempMean, sd = UkundaTempSD)
UkundaClimate$RHAnom <- sapply(UkundaClimate$RH, 
                                 function(x, m , sd) (x < m + 1.5*sd),
                                 m = UkundaRHMean, sd = UkundaRHSD)

UkundaClimate$RHTempAnomaly = (UkundaClimate$TempAnom & UkundaClimate$RHAnom)

# Msambweni
Msam <- read_excel("44 Rainfall data from Msambweni March 2016.xls")
Msam_Rain <- Msam[, -(2:3)]
Msam_Rain$Date <- as.Date(Msam_Rain$Date)

Msam <-  read_excel("Msambweni_Temperature.xls")
Msam$Date <- as.Date(Msam$Date)

# Renaming the day data
names(Msam)[2] <- "Temp"; names(Msam)[3] <- "RH"; names(Msam)[4] <- "DewPt"

# Collating day data
Msam_Daily <- ddply(Msam, ~Date, summarise,  MaxTemp = max(Temp, na.rm = T),MinTemp = min(Temp, na.rm = T),
                      Temp = mean(Temp, na.rm = T), RH = mean(RH, na.rm = T), DewPt = mean(DewPt, na.rm = T))

MsamClimate <- merge(Msam_Rain, Msam_Daily, by = "Date", all = TRUE)

MsamClimate[is.na(MsamClimate$rain2),2] <- 0 # Entering 0 for the rain fall amounts where there was none

# Creating the anomalies
MsamRainMean <- mean(MsamClimate$rain2); MsamRainSD <- sqrt(var(MsamClimate$rain2))

MsamClimate$RainfallAnomaly <- sapply(MsamClimate$rain2, # Logical values indicating if the rain exceeds 1.5 sd of the mean
                                        function(x, m , sd) (x > m + 1.5*sd), 
                                        m = MsamRainMean, sd = MsamRainSD)

MsamClimate$TempRange <- MsamClimate$MaxTemp - MsamClimate$MinTemp

MsamRangeMean <- mean(MsamClimate$TempRange); MsamRangeSD <- sqrt(var(MsamClimate$TempRange))

MsamClimate$RangeAnomaly <- sapply(MsamClimate$TempRange, 
                                     function(x, m , sd) (x > m + 1.5*sd),
                                     m = MsamRangeMean, sd = MsamRangeSD)

MsamClimate$DewDiff <- MsamClimate$Temp - MsamClimate$DewPt

MsamDewDiffMean <- mean(MsamClimate$DewDiff); MsamDewDiffSD <- sqrt(var(MsamClimate$DewDiff))

MsamClimate$DewDiffAnomaly <- sapply(MsamClimate$DewDiff, 
                                       function(x, m , sd) (x < m - 1.5*sd),
                                       m = MsamDewDiffMean, sd = MsamDewDiffSD)

MsamTempMean <- mean(MsamClimate$Temp); MsamTempSD <- sqrt(var(MsamClimate$Temp))
MsamRHMean <- mean(MsamClimate$RH); MsamRHSD <- sqrt(var(MsamClimate$RH))

MsamClimate$TempAnom <- sapply(MsamClimate$Temp, 
                                 function(x, m , sd) (x < m + 1.5*sd),
                                 m = MsamTempMean, sd = MsamTempSD)
MsamClimate$RHAnom <- sapply(MsamClimate$RH, 
                               function(x, m , sd) (x < m + 1.5*sd),
                               m = MsamRHMean, sd = MsamRHSD)

MsamClimate$RHTempAnomaly = (MsamClimate$TempAnom & MsamClimate$RHAnom)

  ## Kisumu and Chulaimbo rain was recorded together:
twoSites <- read_excel("Rainfall_Daily Data_Feb 1 2016.xlsx", sheet = 1) 

twoSites <- twoSites[,-(1:3)]

chulaimbo_dailyrain <- twoSites[,1:2]; names(chulaimbo_dailyrain)[2] <- paste("Rainfall")
kisumu_dailyrain <- twoSites[,-2]; names(kisumu_dailyrain)[2] <- paste("Rainfall")

  # Chulaimbo
chul_hospitalTemp <- read_excel("Temperature_Daily data.xlsx", sheet = 1) 
chul_villageTemp <- read_excel("Temperature_Daily data.xlsx", sheet = 2) 

chul_hospitalRH <- read_excel("RH_Daily data.xlsx", sheet = 1)
chul_villageRH <- read_excel("RH_Daily data.xlsx", sheet = 2) 

chul_hospitalDewPt <- read_excel("DewPt_Daily data.xlsx", sheet = 1) 
chul_villageDewPt <- read_excel("DewPt_Daily data.xlsx", sheet = 2) 


# Eliminating extraneous columns and rows (filled mostly with NA's)
a <- c(2, 4:18)

chul_hospitalTemp <- chul_hospitalTemp[,-(5:18)] 
chul_villageTemp <- chul_villageTemp[,-(5:18)]
chul_hospitalRH <- chul_hospitalRH[,-a] 
chul_villageRH <- chul_villageRH[,-a]
chul_hospitalDewPt <- chul_hospitalDewPt[,-a] 
chul_villageDewPt <- chul_villageDewPt[,-a]

# Renaming variable for ease of use
names(chul_hospitalTemp)[2] <- paste("MaxTemp"); names(chul_hospitalTemp)[4] <- paste("MinTemp")
names(chul_hospitalTemp)[3] <- paste("Temp")
names(chul_villageTemp)[2] <- paste("MaxTemp"); names(chul_villageTemp)[4] <- paste("MinTemp")
names(chul_villageTemp)[3] <- paste("Temp")

names(chul_hospitalRH)[2] <- paste("RH"); names(chul_villageRH)[2] <- paste("RH")
names(chul_hospitalDewPt)[2] <- paste("DewPt"); names(chul_villageDewPt)[2] <- paste("DewPt")

# Merging subsite data
ChulClimate_Hospital <- merge(chul_hospitalTemp, chul_hospitalRH, by = "Date", all = TRUE)
ChulClimate_Hospital <- merge(ChulClimate_Hospital, chul_hospitalDewPt, by = "Date", all = TRUE)

ChulClimate_Hospital <- ChulClimate_Hospital[ -(which(is.na(ChulClimate_Hospital$Date))),]

ChulClimate_Village <- merge(chul_villageTemp, chul_villageRH, by = "Date", all = TRUE)
ChulClimate_Village <- merge(ChulClimate_Village, chul_villageDewPt, by = "Date", all = TRUE)

ChulClimate_Village <- ChulClimate_Village[ -(which(is.na(ChulClimate_Village$Date))),]

ChulClimate <- rbind(ChulClimate_Hospital, ChulClimate_Village)

# Combining the Hospital and Village Data
Chulaimbo_DailyCom <- ddply(ChulClimate, ~Date, summarise,  MaxTemp = max(Temp, na.rm = T), MinTemp = min(Temp, na.rm = T),
                      Temp = mean(Temp, na.rm = T), RH = mean(RH, na.rm = T), DewPt = mean(DewPt, na.rm = T))

Chulaimbo_DailyCom$Date <- as.Date(Chulaimbo_DailyCom$Date); chulaimbo_dailyrain$Date <- as.Date(chulaimbo_dailyrain$Date)

ChulaimboClimate <- merge(Chulaimbo_DailyCom, chulaimbo_dailyrain, by = "Date", all = TRUE)

ChulaimboClimate[is.na(ChulaimboClimate$Rainfall),7] <- 0

# Starting to make the anomaly data
ChulaimboRainMean <- mean(ChulaimboClimate$Rainfall); ChulaimboRainSD <- sqrt(var(ChulaimboClimate$Rainfall))

ChulaimboClimate$RainfallAnomaly <- sapply(ChulaimboClimate$Rainfall, # Logical values indicating if the rain exceeds 1.5 sd of the mean
                                      function(x, m , sd) (x > m + 1.5*sd), 
                                      m = ChulaimboRainMean, sd = ChulaimboRainSD)

ChulaimboClimate$TempRange <- ChulaimboClimate$MaxTemp - ChulaimboClimate$MinTemp

ChulaimboRangeMean <- mean(ChulaimboClimate$TempRange); ChulaimboRangeSD <- sqrt(var(ChulaimboClimate$TempRange))

ChulaimboClimate$RangeAnomaly <- sapply(ChulaimboClimate$TempRange, 
                                   function(x, m , sd) (x > m + 1.5*sd),
                                   m = ChulaimboRangeMean, sd = ChulaimboRangeSD)

ChulaimboClimate$DewDiff <- ChulaimboClimate$Temp - ChulaimboClimate$DewPt

ChulaimboDewDiffMean <- mean(ChulaimboClimate$DewDiff); ChulaimboDewDiffSD <- sqrt(var(ChulaimboClimate$DewDiff))

ChulaimboClimate$DewDiffAnomaly <- sapply(ChulaimboClimate$DewDiff, 
                                     function(x, m , sd) (x < m - 1.5*sd),
                                     m = ChulaimboDewDiffMean, sd = ChulaimboDewDiffSD)

ChulaimboTempMean <- mean(ChulaimboClimate$Temp); ChulaimboTempSD <- sqrt(var(ChulaimboClimate$Temp))
ChulaimboRHMean <- mean(ChulaimboClimate$RH); ChulaimboRHSD <- sqrt(var(ChulaimboClimate$RH))

ChulaimboClimate$TempAnom <- sapply(ChulaimboClimate$Temp, 
                               function(x, m , sd) (x < m + 1.5*sd),
                               m = ChulaimboTempMean, sd = ChulaimboTempSD)
ChulaimboClimate$RHAnom <- sapply(ChulaimboClimate$RH, 
                             function(x, m , sd) (x < m + 1.5*sd),
                             m = ChulaimboRHMean, sd = ChulaimboRHSD)

ChulaimboClimate$RHTempAnomaly = (ChulaimboClimate$TempAnom & ChulaimboClimate$RHAnom)

  # Kisumu
kisumu_hospitalTemp <- read_excel("Temperature_Daily data.xlsx", sheet = 1) 
kisumu_estateTemp <- read_excel("Temperature_Daily data.xlsx", sheet = 2) 

kisumu_hospitalRH <- read_excel("RH_Daily data.xlsx", sheet = 1)
kisumu_estateRH <- read_excel("RH_Daily data.xlsx", sheet = 2) 

kisumu_hospitalDewPt <- read_excel("DewPt_Daily data.xlsx", sheet = 1) 
kisumu_estateDewPt <- read_excel("DewPt_Daily data.xlsx", sheet = 2) 

a <- c(2, 4:18)

# Removing the extraneous columns and rows
kisumu_hospitalTemp <- kisumu_hospitalTemp[,-(5:18)] 
kisumu_estateTemp <- kisumu_estateTemp[,-(5:18)]
kisumu_hospitalRH <- kisumu_hospitalRH[,-a] 
kisumu_estateRH <- kisumu_estateRH[,-a]
kisumu_hospitalDewPt <- kisumu_hospitalDewPt[,-a] 
kisumu_estateDewPt <- kisumu_estateDewPt[,-a]

# Renaming the variables
names(kisumu_hospitalTemp)[2] <- paste("MaxTemp"); names(kisumu_hospitalTemp)[4] <- paste("MinTemp")
names(kisumu_hospitalTemp)[3] <- paste("Temp")
names(kisumu_estateTemp)[2] <- paste("MaxTemp"); names(kisumu_estateTemp)[4] <- paste("MinTemp")
names(kisumu_estateTemp)[3] <- paste("Temp")

names(kisumu_hospitalRH)[2] <- paste("RH"); names(kisumu_estateRH)[2] <- paste("RH")
names(kisumu_hospitalDewPt)[2] <- paste("DewPt"); names(kisumu_estateDewPt)[2] <- paste("DewPt")

# Merging site's climate data and removing extraneous rows
KisumuClimate_Hospital <- merge(kisumu_hospitalTemp, kisumu_hospitalRH, by = "Date", all = TRUE)
KisumuClimate_Hospital <- merge(KisumuClimate_Hospital, kisumu_hospitalDewPt, by = "Date", all = TRUE)

KisumuClimate_estate <- merge(kisumu_estateTemp, kisumu_estateRH, by = "Date", all = TRUE)
KisumuClimate_estate <- merge(KisumuClimate_estate, kisumu_estateDewPt, by = "Date", all = TRUE)

KisumuClimate <- rbind(KisumuClimate_Hospital, KisumuClimate_estate)

# Combining the Obama Hospital and Estate data together
Kisumu_DailyCom <- ddply(KisumuClimate, ~Date, summarise,  MaxTemp = max(Temp, na.rm = T), MinTemp = min(Temp, na.rm = T),
                            Temp = mean(Temp, na.rm = T), RH = mean(RH, na.rm = T), DewPt = mean(DewPt, na.rm = T))

Kisumu_DailyCom$Date <- as.Date(Kisumu_DailyCom$Date); kisumu_dailyrain$Date <- as.Date(kisumu_dailyrain$Date)

KisumuClimate <- merge(Kisumu_DailyCom, kisumu_dailyrain, by = "Date", all = TRUE)

KisumuClimate[is.na(KisumuClimate$Rainfall),7] <- 0

# Creating anomaly data
KisumuRainMean <- mean(KisumuClimate$Rainfall); KisumuRainSD <- sqrt(var(KisumuClimate$Rainfall))

KisumuClimate$RainfallAnomaly <- sapply(KisumuClimate$Rainfall, # Logical values indicating if the rain exceeds 1.5 sd of the mean
                                           function(x, m , sd) (x > m + 1.5*sd), 
                                           m = KisumuRainMean, sd = KisumuRainSD)

KisumuClimate$TempRange <- KisumuClimate$MaxTemp - KisumuClimate$MinTemp

KisumuRangeMean <- mean(KisumuClimate$TempRange); KisumuRangeSD <- sqrt(var(KisumuClimate$TempRange))

KisumuClimate$RangeAnomaly <- sapply(KisumuClimate$TempRange, 
                                        function(x, m , sd) (x > m + 1.5*sd),
                                        m = KisumuRangeMean, sd = KisumuRangeSD)

KisumuClimate$DewDiff <- KisumuClimate$Temp - KisumuClimate$DewPt

KisumuDewDiffMean <- mean(KisumuClimate$DewDiff); KisumuDewDiffSD <- sqrt(var(KisumuClimate$DewDiff))

KisumuClimate$DewDiffAnomaly <- sapply(KisumuClimate$DewDiff, 
                                          function(x, m , sd) (x < m - 1.5*sd),
                                          m = KisumuDewDiffMean, sd = KisumuDewDiffSD)

KisumuTempMean <- mean(KisumuClimate$Temp); KisumuTempSD <- sqrt(var(KisumuClimate$Temp))
KisumuRHMean <- mean(KisumuClimate$RH); KisumuRHSD <- sqrt(var(KisumuClimate$RH))

KisumuClimate$TempAnom <- sapply(KisumuClimate$Temp, 
                                    function(x, m , sd) (x < m + 1.5*sd),
                                    m = KisumuTempMean, sd = KisumuTempSD)
KisumuClimate$RHAnom <- sapply(KisumuClimate$RH, 
                                  function(x, m , sd) (x < m + 1.5*sd),
                                  m = KisumuRHMean, sd = KisumuRHSD)

KisumuClimate$RHTempAnomaly = (KisumuClimate$TempAnom & KisumuClimate$RHAnom)

# Saving Daily Summaries

ChulaimboClimate$Month <- as.yearmon(ChulaimboClimate$Date)
KisumuClimate$Month <- as.yearmon(KisumuClimate$Date)
MsamClimate$Month <- as.yearmon(MsamClimate$Date)
UkundaClimate$Month <- as.yearmon(UkundaClimate$Date)

  # Save Daily Summaries
setwd("~/Desktop/Summer 2016/Created Data Sets")

f = "ChulaimboDailyClimateData.xls"
write.xlsx(ChulaimboClimate, f, sheetName = "Climate Data, Daily Scale", col.names = TRUE,
           row.names = FALSE, append = FALSE, showNA = TRUE)
f = "KisumuDailyClimateData.xls"
write.xlsx(KisumuClimate, f, sheetName = "Climate Data, Daily Scale", col.names = TRUE,
           row.names = FALSE, append = FALSE, showNA = TRUE)
f = "MsamDailyClimateData.xls"
write.xlsx(MsamClimate, f, sheetName = "Climate Data, Daily Scale", col.names = TRUE,
           row.names = FALSE, append = FALSE, showNA = TRUE)
f = "UkundaDailyClimateData.xls"
write.xlsx(UkundaClimate, f, sheetName = "Climate Data, Daily Scale", col.names = TRUE,
           row.names = FALSE, append = FALSE, showNA = TRUE)

# Creating monthly summaries of all the data
ChulaimboMonthlyClimate <- ddply(ChulaimboClimate, ~Month, summarise, AvgTemp = mean(Temp, na.rm = T), 
                                 AvgMaxTemp = mean(MaxTemp, na.rm = T), AvgMinTemp = mean(MinTemp, na.rm = T), 
                                 OverallMaxTemp = max(MaxTemp, na.rm = T), OverallMinTemp = min(MinTemp, na.rm = T),
                                 AvgTempRange = mean((MaxTemp - MinTemp), na.rm = T), AvgRH = mean(RH, na.rm = T),
                                 AvgDewPt = mean(DewPt, na.rm = T), TtlRainfall = sum(Rainfall),
                                 RainfallAnomalies = sum(RainfallAnomaly), TempRangeAnomalies = sum(RangeAnomaly),
                                 TempDewPtDiffAnomalies = sum(DewDiffAnomaly), TempAnomalies = sum(TempAnom),
                                 RHAnomalies = sum(RHAnom), RHTempAnomalies = sum(RHTempAnomaly)) 

KisumuMonthlyClimate <- ddply(KisumuClimate, ~Month, summarise, AvgTemp = mean(Temp, na.rm = T), 
                                 AvgMaxTemp = mean(MaxTemp, na.rm = T), AvgMinTemp = mean(MinTemp, na.rm = T), 
                                 OverallMaxTemp = max(MaxTemp, na.rm = T), OverallMinTemp = min(MinTemp, na.rm = T),
                                 AvgTempRange = mean((MaxTemp - MinTemp), na.rm = T), AvgRH = mean(RH, na.rm = T),
                                 AvgDewPt = mean(DewPt, na.rm = T), TtlRainfall = sum(Rainfall),
                                 RainfallAnomalies = sum(RainfallAnomaly), TempRangeAnomalies = sum(RangeAnomaly),
                                 TempDewPtDiffAnomalies = sum(DewDiffAnomaly), TempAnomalies = sum(TempAnom),
                                 RHAnomalies = sum(RHAnom), RHTempAnomalies = sum(RHTempAnomaly)) 

MsamMonthlyClimate <- ddply(MsamClimate, ~Month, summarise, AvgTemp = mean(Temp, na.rm = T), 
                              AvgMaxTemp = mean(MaxTemp, na.rm = T), AvgMinTemp = mean(MinTemp, na.rm = T), 
                              OverallMaxTemp = max(MaxTemp, na.rm = T), OverallMinTemp = min(MinTemp, na.rm = T),
                              AvgTempRange =mean((MaxTemp - MinTemp), na.rm = T), AvgRH = mean(RH, na.rm = T),
                              AvgDewPt = mean(DewPt, na.rm = T), TtlRainfall = sum(rain2),
                              RainfallAnomalies = sum(RainfallAnomaly), TempRangeAnomalies = sum(RangeAnomaly),
                              TempDewPtDiffAnomalies = sum(DewDiffAnomaly), TempAnomalies = sum(TempAnom),
                              RHAnomalies = sum(RHAnom), RHTempAnomalies = sum(RHTempAnomaly)) 

UkundaMonthlyClimate <- ddply(UkundaClimate, ~Month, summarise, AvgTemp = mean(Temp, na.rm = T), 
                            AvgMaxTemp = mean(MaxTemp, na.rm = T), AvgMinTemp = mean(MinTemp, na.rm = T), 
                            OverallMaxTemp = max(MaxTemp, na.rm = T), OverallMinTemp = min(MinTemp, na.rm = T),
                            AvgTempRange = mean((MaxTemp - MinTemp), na.rm = T), AvgRH = mean(RH, na.rm = T),
                            AvgDewPt = mean(DewPt, na.rm = T), TtlRainfall = sum(rain2),
                            RainfallAnomalies = sum(RainfallAnomaly), TempRangeAnomalies = sum(RangeAnomaly),
                            TempDewPtDiffAnomalies = sum(DewDiffAnomaly), TempAnomalies = sum(TempAnom),
                            RHAnomalies = sum(RHAnom), RHTempAnomalies = sum(RHTempAnomaly)) 


  #Saving the Monthly Summaries
f = "ChulaimboMonthlyClimateData.xls"
write.xlsx(ChulaimboMonthlyClimate, f, sheetName = "Climate Data, Monthly Scale", col.names = TRUE,
           row.names = FALSE, append = FALSE, showNA = TRUE)
f = "KisumuMonthlyClimateData.xls"
write.xlsx(KisumuMonthlyClimate, f, sheetName = "Climate Data, Monthly Scale", col.names = TRUE,
           row.names = FALSE, append = FALSE, showNA = TRUE)
f = "MsamMonthlyClimateData.xls"
write.xlsx(MsamMonthlyClimate, f, sheetName = "Climate Data, Monthly Scale", col.names = TRUE,
           row.names = FALSE, append = FALSE, showNA = TRUE)
f = "UkundaMonthlyClimateData.xls"
write.xlsx(UkundaMonthlyClimate, f, sheetName = "Climate Data, Monthly Scale", col.names = TRUE,
           row.names = FALSE, append = FALSE, showNA = TRUE)

## Mosquito Data 
setwd("~/Desktop/Summer 2016/Newest Data")

Ovitrap1 <- read_excel("Vectors Monthly Data_Mar 31 2016.xlsx", sheet = 1)
Larval1 <- read_excel("Vectors Monthly Data_Mar 31 2016.xlsx", sheet = 2)
Prokopack1 <- read_excel("Vectors Monthly Data_Mar 31 2016.xlsx", sheet = 3)
SentinelTrap1 <- read_excel("Vectors Monthly Data_Mar 31 2016.xlsx", sheet = 4)
LandingCatches1 <- read_excel("Vectors Monthly Data_Mar 31 2016.xlsx", sheet = 5)

Ovitrap2 <- read_excel("Mosquito monthly summaries coast Feb16.xlsx", sheet = 3)
Larval2 <- read_excel("Mosquito monthly summaries coast Feb16.xlsx", sheet = 2)
Prokopack2 <- read_excel("Mosquito monthly summaries coast Feb16.xlsx", sheet = 4)
SentinelTrap2 <- read_excel("Mosquito monthly summaries coast Feb16.xlsx", sheet = 1)
LandingCatches2 <- read_excel("Mosquito monthly summaries coast Feb16.xlsx", sheet = 5)

Pupae1 <- read_excel("Pupae Monthly Totals.xlsx", sheet = 1)


# Cleaning

# Ovitrap 

# Adjusting and including site names as well as variable names
for(i in 1:(dim(Ovitrap1)[1])){
  if(is.na(Ovitrap1[i,1])){
    Ovitrap1[i,1] = Ovitrap1[(i - 1),1]
  }
}

# These variable names may need to be updated as more data is collected
names(Ovitrap1)[1] <- "Site"; names(Ovitrap1)[2] <- "Date"
names(Ovitrap1)[3] <- "Aedes aegypti, Indoor"
names(Ovitrap1)[4] <- "Culex spp., Indoor"
names(Ovitrap1)[5] <- "Indoor Total"
names(Ovitrap1)[6] <- "Aedes aegypti, Outdoor"
names(Ovitrap1)[7] <- "Culex spp., Outdoor"
names(Ovitrap1)[8] <- "Outdoor Total"

# Removing excess columns and rows
Ovitrap1 <- Ovitrap1[-1,]
ind <- apply(Ovitrap1, 2, function(x) all(is.na(x)))
Ovitrap1 <- Ovitrap1[,!ind]
Ovitrap1 <- Ovitrap1[-(which(is.na(Ovitrap1$Date))),]

# Adjusting and including site names as well as variable names
# These variable names may need to be updated as more data is collected
names(Ovitrap2)[1] <- "Site"; names(Ovitrap2)[2] <- "Date"
names(Ovitrap2)[3] <- "Aedes aegypti, Indoor"
names(Ovitrap2)[4] <- "Culex spp., Indoor"
names(Ovitrap2)[5] <- "Indoor Total"
names(Ovitrap2)[6] <- "Aedes aegypti, Outdoor"
names(Ovitrap2)[7] <- "Culex spp., Outdoor"
names(Ovitrap2)[8] <- "Outdoor Total"

# Removing excess columns and rows
Ovitrap2 <- Ovitrap2[-1,]
Ovitrap2 <- Ovitrap2[-dim(Ovitrap2)[1], -dim(Ovitrap2)[2]] # last one is totals which we don't really need

# Adjusting dates
Ovitrap1$Date <- as.yearmon(as.Date(as.numeric(Ovitrap1$Date), origin = "1900-01-01"))
Ovitrap2$Date <- as.yearmon(as.Date(as.numeric(Ovitrap2$Date), origin = "1900-01-01"))

  # Double checking everything was processed okay
  head(Ovitrap1)
  head(Ovitrap2)
  
# Separating data into site specific data sets
OvitrapC <- Ovitrap1[which(Ovitrap1[,1] == "Chulaimbo"),]
OvitrapK <- Ovitrap1[-which(Ovitrap1[,1] == "Chulaimbo"),]
OvitrapM <- Ovitrap2[which(Ovitrap2[,1] == "Msambweni"),]
OvitrapU <- Ovitrap2[-which(Ovitrap2[,1] == "Msambweni"),]

# Larval 

# Removing excess columns and rows
Larval2 <- Larval2[-1,]
Larval2 <- Larval2[-dim(Larval2)[1],] 
i2 <- sapply(Larval2,function(x) all(is.na(x)))
Larval2 <- Larval2[,!i2]
Larval2 <- Larval2[, -dim(Larval2)[2]] 

# Adjusting and including site names as well as variable names
for(i in 1:(dim(Larval1)[1])){
  if(is.na(Larval1[i,1])){
    Larval1[i,1] = Larval1[(i - 1),1]
  }
}

# These variable names may need to be updated as more data is collected
names(Larval1)[1] <- "Site"; names(Larval1)[2] <- "Date"
names(Larval1)[3] <- "Aedes aegypti, Indoor"
names(Larval1)[4] <- "Culex spp., Indoor"
names(Larval1)[5] <- "Indoor Total"
names(Larval1)[6] <- "Aedes aegypti, Outdoor"
names(Larval1)[7] <- "Anopheles, Outdoor"
names(Larval1)[8] <- "Culex, Outdoor"
names(Larval1)[9] <- "Toxorhynchites, Outdoor"
names(Larval1)[10] <- "Outdoor Total"

# Adjusting and including site names as well as variable names
# These variable names may need to be updated as more data is collected
names(Larval2)[1] <- "Site"; names(Larval2)[2] <- "Date"
names(Larval2)[3] <- "Aedes aegypti, Indoor"
names(Larval2)[4] <- "Aedes simpsoni, Indoor"
names(Larval2)[5] <- "Anopheles, Indoor"
names(Larval2)[6] <- "Culex spp., Indoor"
names(Larval2)[7] <- "Indoor Total"
names(Larval2)[8] <- "Aedes aegypti, Outdoor"
names(Larval2)[9] <- "Aedes simpsoni, Outdoor"
names(Larval2)[10] <- "Anopheles spp, Outdoor"
names(Larval2)[11] <- "Culex spp., Outdoor"
names(Larval2)[12] <- "Toxorhynchites, Outdoor"
names(Larval2)[13] <- "Outdoor Total"

# Removing excess columns and rows
Larval1 <- Larval1[-1,]
ind <- apply(Larval1, 2, function(x) all(is.na(x)))
Larval1 <- Larval1[,!ind]

# Adjusting dates
Larval1$Date <- as.yearmon(as.Date(as.numeric(Larval1$Date), origin = "1900-01-01"))
Larval2$Date <- as.yearmon(as.Date(as.numeric(Larval2$Date), origin = "1900-01-01"))

  # Double checking everything was processed correctly
  head(Larval1)
  head(Larval2)

LarvalC <- Larval1[which(Larval1[,1] == "Chulaimbo"),]
LarvalK <- Larval1[-which(Larval1[,1] == "Chulaimbo"),]
LarvalM <- Larval2[which(Larval2[,1] == "Msambweni"),]
LarvalU <- Larval2[-which(Larval2[,1] == "Msambweni"),]

# Pupae **Data is only available for Chulaimbo and Kisumu

# Removing excess columns and rows
Pupae1 <- Pupae1[-1,-7]
ind <- apply(Pupae1, 1, function(x) all(is.na(x)))
Pupae1 <- Pupae1[!ind,]

# Adjusting and including site names as well as variable names
for(i in 1:(dim(Pupae1)[1])){
  if(is.na(Pupae1[i,1])){
    Pupae1[i,1] = Pupae1[(i - 1),1]
  }
}

# These variable names may need to be updated as more data is collected
names(Pupae1)[1] <- "Site"; names(Pupae1)[2] <- "Date"
names(Pupae1)[3] <- "Aedes aegypti"
names(Pupae1)[4] <- "Anopheles spp."
names(Pupae1)[5] <- "Culex spp."
names(Pupae1)[6] <- "Toxorhynchites spp."

# Adjusting dates
Pupae1$Date <- as.yearmon(as.Date(as.numeric(Pupae1$Date), origin = "1900-01-01"))

# Taking care of NA's
Pupae1[is.na(Pupae1)] <- 0

  # Double checking everything is processed correctly
  head(Pupae1)
  
# Separation into site specific data sets
PupaeC <- Pupae1[which(Pupae1[,1] == "Chulaimbo"),]
PupaeK <- Pupae1[-which(Pupae1[,1] == "Chulaimbo"),]


# Prokopack

# Adjusting and including site names as well as variable names
for(i in 1:(dim(Prokopack1)[1])){
  if(is.na(Prokopack1[i,1])){
    Prokopack1[i,1] = Prokopack1[(i - 1),1]
  }
}

# These variable names may need to be updated as more data is collected
names(Prokopack1)[1] <- "Site"; names(Prokopack1)[2] <- "Date"
names(Prokopack1)[3] <- "Aedes aegypti, Indoor"
names(Prokopack1)[4] <- "Anopheles gambiae, Indoor"
names(Prokopack1)[5] <- "Anopheles funestus, Indoor"
names(Prokopack1)[6] <- "Culex spp., Indoor"
names(Prokopack1)[7] <- "Aedes aegypti, Outdoor"
names(Prokopack1)[8] <- "Anopheles gambiae, Outdoor"
names(Prokopack1)[9] <- "Anopheles funestus, Outdoor"
names(Prokopack1)[10] <- "Culex spp., Outdoor"

# Removing excess rows and colunmns
Prokopack1 <- Prokopack1[-1,]
ind <- apply(Prokopack1, 2, function(x) all(is.na(x)))
Prokopack1 <- Prokopack1[,!ind]

# Adjusting and including site names as well as variable names
# These variable names may need to be updated as more data is collected
names(Prokopack2)[1] <- "Site"; names(Prokopack2)[2] <- "Date"
names(Prokopack2)[3] <- "Aedes aegypti, Indoor"
names(Prokopack2)[4] <- "Aedes simpsoni, Indoor"
names(Prokopack2)[5] <- "Anopheles gambiae, Indoor"
names(Prokopack2)[6] <- "Anopheles costani, Indoor"
names(Prokopack2)[7] <- "Anopheles funestus, Indoor"
names(Prokopack2)[8] <- "Culex spp, Indoor"
names(Prokopack2)[9] <- "Indoor Total"
names(Prokopack2)[10] <- "Aedes aegypti, Outdoor"
names(Prokopack2)[11] <- "Aedes simpsoni, Outdoor"
names(Prokopack2)[12] <- "Anopheles gambiae, Outdoor"
names(Prokopack2)[13] <- "Anopheles funestus, Outdoor"
names(Prokopack2)[14] <- "Culex spp, Outdoor"
names(Prokopack2)[15] <- "Outdoor Total"

# Removing excess rows and columns
Prokopack2 <- Prokopack2[-1,]
Prokopack2 <- Prokopack2[-dim(Prokopack2)[1],] 
i2 <- sapply(Prokopack2,function(x) all(is.na(x)))
Prokopack2 <- Prokopack2[,!i2]
Prokopack2 <- Prokopack2[, -dim(Prokopack2)[2]] 

# Adjusting dates
Prokopack1$Date <- as.yearmon(as.Date(as.numeric(Prokopack1$Date), origin = "1900-01-01"))
Prokopack2$Date <- as.yearmon(as.Date(as.numeric(Prokopack2$Date), origin = "1900-01-01"))

  # Double checking everything was processed correctly
  head(Prokopack1)
  head(Prokopack2)

# Separation into site specific data sets
ProkopackC <- Prokopack1[which(Prokopack1[,1] == "Chulaimbo"),]
ProkopackK <- Prokopack1[-which(Prokopack1[,1] == "Chulaimbo"),]
ProkopackM <- Prokopack2[which(Prokopack2[,1] == "Msambweni"),]
ProkopackU <- Prokopack2[-which(Prokopack2[,1] == "Msambweni"),]

# Sentinel Trap

# Adjusting and including site names as well as variable names
for(i in 1:(dim(SentinelTrap1)[1])){
  if(is.na(SentinelTrap1[i,1])){
    SentinelTrap1[i,1] = SentinelTrap1[(i - 1),1]
  }
}

names(SentinelTrap1)[1] <- "Site"; names(SentinelTrap1)[2] <- "Date"
names(SentinelTrap1)[3] <- "Aedes aegypti"
names(SentinelTrap1)[4] <- "Anopheles gambiae"
names(SentinelTrap1)[5] <- "Anopheles funestus"
names(SentinelTrap1)[6] <- "Culex spp."
names(SentinelTrap1)[7] <- "Toxorhynchites"

# Removing excess columns and rows
ind <- apply(SentinelTrap1, 2, function(x) all(is.na(x)))
SentinelTrap1 <- SentinelTrap1[,!ind]

# Adjusting and including site names as well as variable names
# These variable names may need to be updated as more data is collected
names(SentinelTrap2)[1] <- "Site"; names(SentinelTrap2)[2] <- "Date"
names(SentinelTrap2)[3] <- "Aedes aegypti"
names(SentinelTrap2)[4] <- "Aedes simpsoni"
names(SentinelTrap2)[5] <- "Aedes spp. (not listed)" # I assume that this is not aegypti or simpsoni
names(SentinelTrap2)[6] <- "Anopheles gambiae"
names(SentinelTrap2)[7] <- "Anopheles funestus"
names(SentinelTrap2)[8] <- "Culex spp."
names(SentinelTrap2)[9] <- "Masoni (?)" # I don't know what other identifiers go with it

# Removing excess columns and rows
i1 <- apply(SentinelTrap2,1,function(x) all(is.na(x)))
SentinelTrap2 <- SentinelTrap2[!i1,]
SentinelTrap2 <- SentinelTrap2[-dim(SentinelTrap2)[1],] 
i2 <- sapply(SentinelTrap2,function(x) all(is.na(x)))
SentinelTrap2 <- SentinelTrap2[,!i2]
SentinelTrap2 <- SentinelTrap2[, -dim(SentinelTrap2)[2]] 

# Adjusting dates
SentinelTrap1$Date <- as.yearmon(SentinelTrap1$Date)
SentinelTrap2$Date <- as.yearmon(as.Date(as.numeric(SentinelTrap2$Date), origin = "1900-01-01"))

# Separation into site specific data sets
SentinelTrapC <- SentinelTrap1[which(SentinelTrap1[,1] == "Chulaimbo"),]
SentinelTrapK <- SentinelTrap1[-which(SentinelTrap1[,1] == "Chulaimbo"),]
SentinelTrapM <- SentinelTrap2[which(SentinelTrap2[,1] == "Msambweni"),]
SentinelTrapU <- SentinelTrap2[-which(SentinelTrap2[,1] == "Msambweni"),]

# Landing Catches

# Adjusting and including site names as well as variable names
for(i in 1:(dim(LandingCatches1)[1])){
  if(is.na(LandingCatches1[i,1])){
    LandingCatches1[i,1] = LandingCatches1[(i - 1),1]
  }
}

# These variable names may need to be updated as more data is collected
names(LandingCatches1)[1] <- "Site"; names(LandingCatches1)[2] <- "Date"
names(LandingCatches1)[3] <- "Aedes aegypti, Inside"
names(LandingCatches1)[4] <- "Aedes aegypti, Outside"
names(LandingCatches1)[5] <- "Aedes aegypti, Total"
names(LandingCatches1)[6] <- "Anopheles gambiae, Inside"
names(LandingCatches1)[7] <- "Anopheles gambiae, Outside"
names(LandingCatches1)[8] <- "Anopheles gambiae, Total"
names(LandingCatches1)[9] <- "Anopheles funestus, Inside"
names(LandingCatches1)[10] <- "Anopheles funestus, Outside"
names(LandingCatches1)[11] <- "Anopheles funestus, Inside"
names(LandingCatches1)[12] <- "Culex spp., Inside"
names(LandingCatches1)[13] <- "Culex spp., Outside"
names(LandingCatches1)[14] <- "Culex spp., Total"

# Removing excess rows and columns
LandingCatches1 <- LandingCatches1[-1,]
ind <- apply(LandingCatches1, 2, function(x) all(is.na(x)))
LandingCatches1 <- LandingCatches1[,!ind]

# Adjusting and including site names as well as variable names
# These variable names may need to be updated as more data is collected
names(LandingCatches2)[1] <- "Site"; names(LandingCatches2)[2] <- "Date"
names(LandingCatches2)[3] <- "Aedes aegypti, Inside"
names(LandingCatches2)[4] <- "Aedes aegypti, Outside"
names(LandingCatches2)[5] <- "Aedes aegypti, Total"
names(LandingCatches2)[6] <- "Anopheles gambiae, Inside"
names(LandingCatches2)[7] <- "Anopheles gambiae, Outside"
names(LandingCatches2)[8] <- "Anopheles gambiae, Total"
names(LandingCatches2)[9] <- "Anopheles funestus, Inside"
names(LandingCatches2)[10] <- "Anopheles funestus, Outside"
names(LandingCatches2)[11] <- "Anopheles funestus, Inside"
names(LandingCatches2)[12] <- "Aedes simpsoni, Inside"
names(LandingCatches2)[13] <- "Aedes simpsoni, Outside"
names(LandingCatches2)[14] <- "Aedes simpsoni, Total"
names(LandingCatches2)[15] <- "Culex spp., Inside"
names(LandingCatches2)[16] <- "Culex spp., Outside"
names(LandingCatches2)[17] <- "Culex spp., Total"

# Removing excess rows and columns
i1 <- apply(LandingCatches2,1,function(x) all(is.na(x)))
LandingCatches2 <- LandingCatches2[!i1,]
LandingCatches2 <- LandingCatches2[-dim(LandingCatches2)[1],] 
i2 <- sapply(LandingCatches2,function(x) all(is.na(x)))
LandingCatches2 <- LandingCatches2[,!i2]
LandingCatches2 <- LandingCatches2[, -dim(LandingCatches2)[2]] 
LandingCatches2 <- LandingCatches2[-1,]

# Adjusting dates (Date format for LandingCatches2 was weird)
LandingCatches2$Date <- paste("01", LandingCatches2$Date, sep = "")
LandingCatches2$Date <- strptime(LandingCatches2$Date, "%d%b%y")

LandingCatches1$Date <- as.yearmon(as.Date(as.numeric(LandingCatches1$Date), origin = "1900-01-01"))
LandingCatches2$Date <- as.yearmon(LandingCatches2$Date, origin = "1900-01-01")

# Separation into site specific data sets
LandingCatchesC <- LandingCatches1[which(LandingCatches1[,1] == "Chulaimbo"),]
LandingCatchesK <- LandingCatches1[-which(LandingCatches1[,1] == "Chulaimbo"),]
LandingCatchesM <- LandingCatches2[which(LandingCatches2[,1] == "Msambweni"),]
LandingCatchesU <- LandingCatches2[-which(LandingCatches2[,1] == "Msambweni"),]

# Save the now cleaned data sets as individual Excel files, with sheets for the different sites
setwd("~/Desktop/Summer 2016/Created Data Sets")

f <- "OvitrapMonthlySummaries.xls"
write.xlsx(as.data.frame(OvitrapC), f, sheetName = "Chulaimbo", col.names = TRUE,
           row.names = FALSE, append = FALSE, showNA = TRUE)
write.xlsx(as.data.frame(OvitrapK), f, sheetName = "Kisumu", col.names = TRUE,
           row.names = FALSE, append = TRUE, showNA = TRUE)
write.xlsx(as.data.frame(OvitrapM), f, sheetName = "Msambweni", col.names = TRUE,
           row.names = FALSE, append = TRUE, showNA = TRUE)
write.xlsx(as.data.frame(OvitrapU), f, sheetName = "Ukunda", col.names = TRUE,
           row.names = FALSE, append = TRUE, showNA = TRUE)

f <- "LarvalMonthlySummaries.xls"
write.xlsx(as.data.frame(LarvalC), f, sheetName = "Chulaimbo", col.names = TRUE,
           row.names = FALSE, append = FALSE, showNA = TRUE)
write.xlsx(as.data.frame(LarvalK), f, sheetName = "Kisumu", col.names = TRUE,
           row.names = FALSE, append = TRUE, showNA = TRUE)
write.xlsx(as.data.frame(LarvalM), f, sheetName = "Msambweni", col.names = TRUE,
           row.names = FALSE, append = TRUE, showNA = TRUE)
write.xlsx(as.data.frame(LarvalU), f, sheetName = "Ukunda", col.names = TRUE,
           row.names = FALSE, append = TRUE, showNA = TRUE)

f <- "PupaeMonthlySummaries.xls"
write.xlsx(as.data.frame(PupaeC), f, sheetName = "Chulaimbo", col.names = TRUE,
           row.names = FALSE, append = FALSE, showNA = TRUE)
write.xlsx(as.data.frame(PupaeK), f, sheetName = "Kisumu", col.names = TRUE,
           row.names = FALSE, append = TRUE, showNA = TRUE)
#write.xlsx(as.data.frame(LarvalM), f, sheetName = "Msambweni", col.names = TRUE,
#           row.names = FALSE, append = TRUE, showNA = TRUE)
#write.xlsx(as.data.frame(LarvalU), f, sheetName = "Ukunda", col.names = TRUE,
#           row.names = FALSE, append = TRUE, showNA = TRUE)

f <- "ProkopackMonthlySummaries.xls"
write.xlsx(as.data.frame(ProkopackC), f, sheetName = "Chulaimbo", col.names = TRUE,
           row.names = FALSE, append = FALSE, showNA = TRUE)
write.xlsx(as.data.frame(ProkopackK), f, sheetName = "Kisumu", col.names = TRUE,
           row.names = FALSE, append = TRUE, showNA = TRUE)
write.xlsx(as.data.frame(ProkopackM), f, sheetName = "Msambweni", col.names = TRUE,
           row.names = FALSE, append = TRUE, showNA = TRUE)
write.xlsx(as.data.frame(ProkopackU), f, sheetName = "Ukunda", col.names = TRUE,
           row.names = FALSE, append = TRUE, showNA = TRUE)

f <- "SentinelTrapMonthlySummaries.xls"
write.xlsx(as.data.frame(SentinelTrapC), f, sheetName = "Chulaimbo", col.names = TRUE,
           row.names = FALSE, append = FALSE, showNA = TRUE)
write.xlsx(as.data.frame(SentinelTrapK), f, sheetName = "Kisumu", col.names = TRUE,
           row.names = FALSE, append = TRUE, showNA = TRUE)
write.xlsx(as.data.frame(SentinelTrapM), f, sheetName = "Msambweni", col.names = TRUE,
           row.names = FALSE, append = TRUE, showNA = TRUE)
write.xlsx(as.data.frame(SentinelTrapU), f, sheetName = "Ukunda", col.names = TRUE,
           row.names = FALSE, append = TRUE, showNA = TRUE)

f <- "LandingCatchesMonthlySummaries.xls"
write.xlsx(as.data.frame(LandingCatchesC), f, sheetName = "Chulaimbo", col.names = TRUE,
           row.names = FALSE, append = FALSE, showNA = TRUE)
write.xlsx(as.data.frame(LandingCatchesK), f, sheetName = "Kisumu", col.names = TRUE,
           row.names = FALSE, append = TRUE, showNA = TRUE)
write.xlsx(as.data.frame(LandingCatchesM), f, sheetName = "Msambweni", col.names = TRUE,
           row.names = FALSE, append = TRUE, showNA = TRUE)
write.xlsx(as.data.frame(LandingCatchesU), f, sheetName = "Ukunda", col.names = TRUE,
           row.names = FALSE, append = TRUE, showNA = TRUE)

## DENV Data (Only for Chulaimbo, lacks data for other sites) ********

# Loading data
setwd("~/Desktop/Summer 2016/Newest Data")
DENV <- read_excel("PCR Results from 2014 to date..xlsx", sheet = 1)

# Removing unneeded data
DENV <- DENV[-(1:2), c(1:3,5)]

# Removing rows of NA's
i1 <- apply(DENV,1,function(x) all(is.na(x)))
DENV <- DENV[!i1,]

# Removing extraneous rows
DENV <- DENV[which(DENV$Months != "Total"),]

# Running through and adding years
for(i in 1:(dim(DENV)[1])){
  if(is.na(DENV[i,1])){
    DENV[i,1] = DENV[(i - 1),1]
  }
}

# Adjusting the dates
DENV$Month <- paste(DENV$Months, DENV$Years, sep = "")
DENV$Date <- paste("01", DENV$Month, sep = "")
DENV$Date <- strptime(DENV$Date, "%d%b%Y")
DENV$Date <- as.yearmon((DENV$Date))

# Rearranging variables
DENV <- DENV[, c(6,3,4)]

# Save the now cleaned data sets as an Excel file
setwd("~/Desktop/Summer 2016/Created Data Sets")

f <- "DENVData.xls"
write.xlsx(as.data.frame(DENV), f, sheetName = "Chulaimbo", col.names = TRUE,
           row.names = FALSE, append = FALSE, showNA = TRUE)
