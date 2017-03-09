#### Data Processing - Kenya Data, Dan Weikel (dpweikel@umich.edu/daniel.p.weikel@gmail.com)

# Note: Feel free to email me if you have any questions about the code. Beware though,
# as new forms of data are collected (more species found, etc.) this script will need to
# to be updated accordingly. I tried to note where in the comments where things are occuring
# so one could be able to make those adjustments themselves.

# In order to update the excel files, search and replace the following
#       1) the working directory that you files are looking, search setwd
#       2) the file names themselves, search read_excel 
# Also, make sure that you select the correct sheet number when changing the excel files

Sys.setenv(JAVA_HOME='C:\\Program Files (x86)\\Java\\jre7') # for 32-bit version

install.packages(c("readxl", "xlsx", "plyr","dplyr", "zoo", "AICcmodavg","MuMIn", "car", "sjPlot", "visreg", "datamart"))
install.packages(c("rJava", "WriteXLS", "xlsx"))
install.packages("readxl")

#if (Sys.getenv("JAVA_HOME")!="")
#  Sys.setenv(JAVA_HOME="")
### Packages :
library(rJava) # Writing Excel files
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
setwd("C:/Users/amykr/Box Sync/DENV CHIKV project/Climate Data/Climate Coast") # Always set where you're grabbing stuff from
# Ukunda 
Diani <- read_excel("Diani_Rainfall.xls")
Ukunda_Rain <- Diani
Ukunda_Rain$Date <- as.Date(Ukunda_Rain$Date)

Diani <-  read_excel("Diani_Temp.xls")
Diani$Date <- as.Date(Diani$Date)

# Renaming the variables
names(Diani)[2] <- "Temp"; names(Diani)[3] <- "RH"; names(Diani)[4] <- "DewPt"

# Collating all of the individual day's information together
Ukunda_Daily <- ddply(Diani, ~Date, summarise,  MaxTemp = max(Temp, na.rm = T),MinTemp = min(Temp, na.rm = T),
                     Temp = mean(Temp, na.rm = T), RH = mean(RH, na.rm = T), DewPt = mean(DewPt, na.rm = T))

names(Ukunda_Rain)[2] <- "rain"
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
Msam <- read_excel("Msambweni_Rainfall.xls")
Msam_Rain <- Msam
Msam_Rain$Date <- as.Date(Msam_Rain$Date)
names(Msam_Rain)[2] <- "rain2"
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
MsamRangeMean <- mean(MsamClimate$TempRange, na.rm=TRUE)
MsamRangeSD <- sqrt(var(MsamClimate$TempRange, na.rm=TRUE))
MsamClimate$RangeAnomaly <- sapply(MsamClimate$TempRange, 
                                     function(x, m , sd) (x > m + 1.5*sd),
                                     m = MsamRangeMean, sd = MsamRangeSD)
MsamClimate$DewDiff <- MsamClimate$Temp - MsamClimate$DewPt

MsamDewDiffMean <- mean(MsamClimate$DewDiff, na.rm=TRUE); MsamDewDiffSD <- sqrt(var(MsamClimate$DewDiff, na.rm=TRUE))

MsamClimate$DewDiffAnomaly <- sapply(MsamClimate$DewDiff, 
                                       function(x, m , sd) (x < m - 1.5*sd),
                                       m = MsamDewDiffMean, sd = MsamDewDiffSD)
MsamTempMean <- mean(MsamClimate$Temp, na.rm=TRUE); MsamTempSD <- sqrt(var(MsamClimate$Temp, na.rm=TRUE))
MsamRHMean <- mean(MsamClimate$RH, na.rm=TRUE); MsamRHSD <- sqrt(var(MsamClimate$RH, na.rm=TRUE))

MsamClimate$TempAnom <- sapply(MsamClimate$Temp, 
                                 function(x, m , sd) (x < m + 1.5*sd),
                                 m = MsamTempMean, sd = MsamTempSD)
MsamClimate$RHAnom <- sapply(MsamClimate$RH, 
                               function(x, m , sd) (x < m + 1.5*sd),
                               m = MsamRHMean, sd = MsamRHSD)

MsamClimate$RHTempAnomaly = (MsamClimate$TempAnom & MsamClimate$RHAnom)

  ## Kisumu and Chulaimbo rain was recorded together:
setwd("C:/Users/amykr/Box Sync/DENV CHIKV project/Climate Data/Climate West/Climate West Latest")
twoSites <- read_excel("Rainfall_Daily Data_Oct 3 2016.xlsx", sheet = 1) 

twoSites <- twoSites[,-(1:3)]

chulaimbo_dailyrain <- twoSites[,1:2]; names(chulaimbo_dailyrain)[2] <- paste("Rainfall")
kisumu_dailyrain <- twoSites[,-2]; names(kisumu_dailyrain)[2] <- paste("Rainfall")

  # Chulaimbo
chul_hospitalTemp <- read_excel("Temperature_Daily data_Oct 3 2016.xlsx", sheet = 1) 
chul_villageTemp <- read_excel("Temperature_Daily data_Oct 3 2016.xlsx", sheet = 2) 

chul_hospitalRH <- read_excel("RH_Daily data_Oct 3 2016.xlsx", sheet = 1)
chul_villageRH <- read_excel("RH_Daily data_Oct 3 2016.xlsx", sheet = 2) 

chul_hospitalDewPt <- read_excel("DewPt_Daily data_Oct 3 2016.xlsx", sheet = 1) 
chul_villageDewPt <- read_excel("DewPt_Daily data_Oct 3 2016.xlsx", sheet = 2) 

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
#ChulClimate_Hospital <- ChulClimate_Hospital[ -(which(is.na(ChulClimate_Hospital$Date))),]

ChulClimate_Village <- merge(chul_villageTemp, chul_villageRH, by = "Date", all = TRUE)
ChulClimate_Village <- merge(ChulClimate_Village, chul_villageDewPt, by = "Date", all = TRUE)
#ChulClimate_Village <- ChulClimate_Village[ -(which(is.na(ChulClimate_Village$Date))),]

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

ChulaimboRangeMean <- mean(ChulaimboClimate$TempRange, na.rm = T); ChulaimboRangeSD <- sqrt(var(ChulaimboClimate$TempRange, na.rm = T))

ChulaimboClimate$RangeAnomaly <- sapply(ChulaimboClimate$TempRange, 
                                   function(x, m , sd) (x > m + 1.5*sd),
                                   m = ChulaimboRangeMean, sd = ChulaimboRangeSD)
ChulaimboClimate$DewDiff <- ChulaimboClimate$Temp - ChulaimboClimate$DewPt

ChulaimboDewDiffMean <- mean(ChulaimboClimate$DewDiff, na.rm = T); ChulaimboDewDiffSD <- sqrt(var(ChulaimboClimate$DewDiff, na.rm = T))

ChulaimboClimate$DewDiffAnomaly <- sapply(ChulaimboClimate$DewDiff, 
                                     function(x, m , sd) (x < m - 1.5*sd),
                                     m = ChulaimboDewDiffMean, sd = ChulaimboDewDiffSD)

ChulaimboTempMean <- mean(ChulaimboClimate$Temp, na.rm = T); ChulaimboTempSD <- sqrt(var(ChulaimboClimate$Temp, na.rm = T))
ChulaimboRHMean <- mean(ChulaimboClimate$RH, na.rm = T); ChulaimboRHSD <- sqrt(var(ChulaimboClimate$RH, na.rm = T))

ChulaimboClimate$TempAnom <- sapply(ChulaimboClimate$Temp, 
                               function(x, m , sd) (x < m + 1.5*sd),
                               m = ChulaimboTempMean, sd = ChulaimboTempSD)
ChulaimboClimate$RHAnom <- sapply(ChulaimboClimate$RH, 
                             function(x, m , sd) (x < m + 1.5*sd),
                             m = ChulaimboRHMean, sd = ChulaimboRHSD)

ChulaimboClimate$RHTempAnomaly = (ChulaimboClimate$TempAnom & ChulaimboClimate$RHAnom)

  # Kisumu
kisumu_hospitalTemp <- read_excel("Temperature_Daily data_Oct 3 2016.xlsx", sheet = 3) 
kisumu_estateTemp <- read_excel("Temperature_Daily data_Oct 3 2016.xlsx", sheet = 4) 

kisumu_hospitalRH <- read_excel("RH_Daily data_Oct 3 2016.xlsx", sheet = 3) 
kisumu_estateRH <- read_excel("RH_Daily data_Oct 3 2016.xlsx", sheet = 4) 

kisumu_hospitalDewPt <- read_excel("DewPt_Daily data_Oct 3 2016.xlsx", sheet = 3) 
kisumu_estateDewPt <- read_excel("DewPt_Daily data_Oct 3 2016.xlsx", sheet = 4) 

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
KisumuRainMean <- mean(KisumuClimate$Rainfall, na.rm = T); KisumuRainSD <- sqrt(var(KisumuClimate$Rainfall, na.rm = T))

KisumuClimate$RainfallAnomaly <- sapply(KisumuClimate$Rainfall, # Logical values indicating if the rain exceeds 1.5 sd of the mean
                                           function(x, m , sd) (x > m + 1.5*sd), 
                                           m = KisumuRainMean, sd = KisumuRainSD)

KisumuClimate$TempRange <- KisumuClimate$MaxTemp - KisumuClimate$MinTemp

KisumuRangeMean <- mean(KisumuClimate$TempRange, na.rm = T); KisumuRangeSD <- sqrt(var(KisumuClimate$TempRange, na.rm = T))

KisumuClimate$RangeAnomaly <- sapply(KisumuClimate$TempRange, 
                                        function(x, m , sd) (x > m + 1.5*sd),
                                        m = KisumuRangeMean, sd = KisumuRangeSD)

KisumuClimate$DewDiff <- KisumuClimate$Temp - KisumuClimate$DewPt

KisumuDewDiffMean <- mean(KisumuClimate$DewDiff, na.rm = T); KisumuDewDiffSD <- sqrt(var(KisumuClimate$DewDiff, na.rm = T))

KisumuClimate$DewDiffAnomaly <- sapply(KisumuClimate$DewDiff, 
                                          function(x, m , sd) (x < m - 1.5*sd),
                                          m = KisumuDewDiffMean, sd = KisumuDewDiffSD)

KisumuTempMean <- mean(KisumuClimate$Temp, na.rm = T); KisumuTempSD <- sqrt(var(KisumuClimate$Temp, na.rm = T))
KisumuRHMean <- mean(KisumuClimate$RH, na.rm = T); KisumuRHSD <- sqrt(var(KisumuClimate$RH, na.rm = T))

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
setwd("C:/Users/amykr/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/built environement hcc")

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
glimpse(KisumuMonthlyClimate)
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
                            AvgDewPt = mean(DewPt, na.rm = T), TtlRainfall = sum(rain),
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
setwd("C:/Users/amykr/Box Sync/DENV CHIKV project/Vector Data/West/West Latest")
Ovitrap1 <- read_excel("Ovitrap Sampling Data.xlsx", sheet = 1)
Larval1 <- read_excel("Larval Sampling Data.xlsx", sheet = 1)
Prokopack1 <- read_excel("Prokopack Sampling Data.xlsx", sheet = 1)
SentinelTrap1 <- read_excel("BioGents-Sentinel Trap Mosquito Sampling Data.xlsx", sheet = 1)
LandingCatches1 <- read_excel("HLC Adult Mosquito Sampling Data.xlsx", sheet = 1)

setwd("C:/Users/amykr/Box Sync/DENV CHIKV project/Vector Data/Coast/Coast Latest")
Ovitrap2 <- read_excel("Ovitrapdata.xls", sheet = 3)
Larval2 <- read_excel("LarvalF.xls", sheet = 2)
Prokopack2 <- read_excel("ProkopackF.xls", sheet = 1)
SentinelTrap2 <- read_excel("BG Sentinel data.xls", sheet = 5)
LandingCatches2 <- read_excel("HLC.xls", sheet = 1)

Pupae1 <-Larval1[,1:15]
Pupae2 <-Larval2[,1:17]

# Cleaning

# Ovitrap 

# Adjusting and including site names as well as variable names
for(i in 1:(dim(Ovitrap1)[1])){
  if(is.na(Ovitrap1[i,1])){
    Ovitrap1[i,1] = Ovitrap1[(i - 1),1]
  }
}

names(Ovitrap1)[names(Ovitrap1)=="Mosquito type"] <- "species"
names(Ovitrap1)[3] <- "Date"
names(Ovitrap1)[11] <- "species"
names(Ovitrap1)[12] <- "Egg_count"
names(Ovitrap1)[13] <- "Early_instars"
names(Ovitrap1)[14] <- "Late_instars"
names(Ovitrap1)[15] <- "male"
names(Ovitrap1)[16] <- "female"

names(Ovitrap1)[19] <- "species"
names(Ovitrap1)[20] <- "Egg_count"
names(Ovitrap1)[21] <- "Early_instars"
names(Ovitrap1)[22] <- "Late_instars"
names(Ovitrap1)[23] <- "male"
names(Ovitrap1)[24] <- "female"
names(Ovitrap1)[1] <- "date_set"

glimpse(Ovitrap1)
INDOOR<-Ovitrap1[1:16]
names(INDOOR)[10] <- "Place"
OUTDODOR<-Ovitrap1[ c (1:8, 17:24) ]
names(OUTDODOR)[9] <- "INDOORS"
OUTDODOR$INDOORS[OUTDODOR$INDOORS == 2] <- 0
Ovitrap1<-rbind.fill(OUTDODOR, INDOOR)
Ovitrap1$measure <- rowSums(Ovitrap1[12:14])
names(Ovitrap1) <- tolower(names(Ovitrap1))
Ovitrap1$species <- tolower(Ovitrap1$species)

#reshape to wide
library(reshape)
Ovitrap1wide <- melt(Ovitrap1, c("date", "site", "species", "indoors"), "measure")
Ovitrap1wide<-cast(Ovitrap1wide, site + date + indoors ~ species)
glimpse(Ovitrap1wide)


## come back here tomorrow
# These variable names may need to be updated as more data is collected
names(Ovitrap1)[1] <- "Site"; 
names(Ovitrap1)[2] <- "Date"
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

# Pupae **Data is now availalbe for coast and west! 
# Removing excess columns and rows
ind <- apply(Pupae1, 1, function(x) all(is.na(x)))
Pupae1 <- Pupae1[!ind,]

ind <- apply(Pupae2, 1, function(x) all(is.na(x)))
Pupae2 <- Pupae2[!ind,]

# Adjusting and including site names as well as variable names
for(i in 1:(dim(Pupae1)[1])){
  if(is.na(Pupae1[i,1])){
    Pupae1[i,1] = Pupae1[(i - 1),1]
  }
}

for(i in 1:(dim(Pupae2)[1])){
  if(is.na(Pupae2[i,1])){
    Pupae2[i,1] = Pupae2[(i - 1),1]
  }
}

Pupae1<-Pupae1[c("Site", "Date", "Pupae", "Species")]
#reshape to wide
attach(Pupae1)
mytable <- table(Site,Species) # A will be rows, B will be columns 
mytable # print tabl
pupae1wide <- melt(Pupae1, c("Date", "Site", "Species"), "Pupae")
Pupae1<-cast(pupae1wide, Site + Date ~ Species)
Pupae1<-Pupae1[c("Site", "Date", "Aedes aegypti", "Anopheles", "Culex", "Toxorhynchites")]

Pupae2<-Pupae2[c("Site", "Date", "Pupae", "SpeciesL")]
Pupae2$SpeciesL[Pupae2$SpeciesL=="Toxorhynchite"] <- "Toxo"
Pupae2$SpeciesL[Pupae2$SpeciesL=="Ae.simpsoni"] <- "Ae.simp"
Pupae2$SpeciesL[Pupae2$SpeciesL==""] <- "none"
Pupae2$SpeciesL[Pupae2$SpeciesL=="_"] <- "none"
Pupae2$SpeciesL[Pupae2$SpeciesL=="Ae.simp"] <- "aedes"
Pupae2$SpeciesL <- tolower(Pupae2$SpeciesL)
Pupae2$SpeciesL[Pupae2$SpeciesL=="ae.simp"] <- "aedes"

pupae2wide <- melt(Pupae2, c("Date", "Site", "SpeciesL"), "Pupae")
Pupae2<-cast(pupae2b, Site + Date ~ SpeciesL)
Pupae2<-Pupae2[c("Site", "Date", "aedes", "an.gambiae", "culex", "toxo")]

# These variable names may need to be updated as more data is collected
names(Pupae1)[1] <- "Site"; 
names(Pupae1)[2] <- "Date"
names(Pupae1)[3] <- "Aedes aegypti"
names(Pupae1)[4] <- "Anopheles spp."
names(Pupae1)[5] <- "Culex spp."
names(Pupae1)[6] <- "Toxorhynchites spp."

names(Pupae2)[1] <- "Site"; 
names(Pupae2)[2] <- "Date"
names(Pupae2)[3] <- "Aedes"
names(Pupae2)[4] <- "Anopheles spp."
names(Pupae2)[5] <- "Culex spp."
names(Pupae2)[6] <- "Toxorhynchites spp."

# Adjusting dates
Pupae1$Date <- as.yearmon(as.Date(as.POSIXct(Pupae1$Date), origin = "1900-01-01"))

Pupae2$Date <- as.yearmon(as.Date(as.POSIXct(Pupae2$Date), origin = "1900-01-01"))

# Taking care of NA's
Pupae1[is.na(Pupae1)] <- 0
Pupae2[is.na(Pupae2)] <- 0

  # Double checking everything is processed correctly
head(Pupae1)
head(Pupae2)
  
# Separation into site specific data sets
Pupae2$Site[Pupae2$Site=="Diani A"] <- "Diani"
Pupae2$Site[Pupae2$Site=="Diani B"] <- "Diani"
Pupae2$Site[Pupae2$Site=="DianiA"] <- "Diani"
Pupae2$Site[Pupae2$Site=="DianiB"] <- "Diani"

PupaeC <- Pupae1[which(Pupae2[,1] == "Chulaimbo"),]
PupaeK <- Pupae1[-which(Pupae2[,1] == "Chulaimbo"),]

PupaeM <- Pupae2[which(Pupae2[,1] == "Msambweni"),]
PupaeU <- Pupae2[-which(Pupae2[,1] == "Msambweni"),]

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
setwd("C:/Users/amykr/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/built environement hcc")

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
write.xlsx(as.data.frame(PupaeM), f, sheetName = "Msambweni", col.names = TRUE,
           row.names = FALSE, append = TRUE, showNA = TRUE)
write.xlsx(as.data.frame(PupaeU), f, sheetName = "Ukunda", col.names = TRUE,
           row.names = FALSE, append = TRUE, showNA = TRUE)

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
setwd("C:/Users/amykr/Box Sync/DENV CHIKV project/Lab Data/PCR Database/PCR Latest")
DENV <- read_excel("PCR Database_01Feb2017.xlsx", sheet = 1)
DENV$month<-months(DENV$`Date Sample Collected`, abbreviate = FALSE)
DENV$month_int<-format(as.Date(DENV$`Date Sample Collected`), "%m")
DENV$year<-format(as.Date(DENV$`Date Sample Collected`), "%Y")

# Removing unneeded data
DENV <- DENV[, c("site", "city", "DENV PCR Results", "month", "year")]

# Removing rows of NA's
i1 <- apply(DENV,1,function(x) all(is.na(x)))
DENV <- DENV[!i1,]

#collapse data down to month level
attach(DENV)
head(DENV)
DENV$`DENV PCR Results`[DENV$`DENV PCR Results`=="NEG"] <- "0"
DENV$`DENV PCR Results`[DENV$`DENV PCR Results`=="POS"] <- "1"
DENV$`DENV PCR Results`<-as.numeric(DENV$`DENV PCR Results`)
DENV<-aggregate(DENV["DENV PCR Results"], DENV[c("city", "year", "month")], sum)
DENV[is.na(DENV$`DENV PCR Results`),4] <- 0 # Entering 0 for the dengue pcr pos amounts where there was none
detach(DENV)

# Running through and adding years
for(i in 1:(dim(DENV)[1])){
  if(is.na(DENV[i,1])){
    DENV[i,1] = DENV[(i - 1),1]
  }
}

# Adjusting the dates
DENV$month <- paste(DENV$month, DENV$year, sep = "")
DENV$Date <- paste("01", DENV$month, sep = "")
DENV$Date <- strptime(DENV$Date, "%d%b%Y")
DENV$Date <- as.yearmon((DENV$Date))
DENV <- DENV[, c("city","Date", "DENV PCR Results")]

# Save the now cleaned data sets as an Excel file
setwd("C:/Users/amykr/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/built environement hcc")
f <- "DENVData.xls"
require(xlsx)
require(rJava)
write.xlsx(as.data.frame(DENV), f, sheetName = "Chulaimbo", col.names = TRUE,
           row.names = FALSE, append = FALSE, showNA = TRUE)
