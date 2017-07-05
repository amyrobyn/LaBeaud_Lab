#### Data Processing - Kenya Data, Dan Weikel (dpweikel@umich.edu/daniel.p.weikel@gmail.com)

# Note: Feel free to email me if you have any questions about the code. Beware though,
# as new forms of data are collected (more species found, etc.) this script will need to
# to be updated accordingly. I tried to note where in the comments where things are occuring
# so one could be able to make those adjustments themselves.

# In order to update the excel files, search and replace the following
#       1) the working directory that you files are looking, search setwd
#       2) the file names themselves, search read_excel 
# Also, make sure that you select the correct sheet number when changing the excel files

#Sys.setenv(JAVA_HOME='C:\\Program Files (x86)\\Java\\jre7') # for 32-bit version
R_LIBS_USER="C:/Program Files/R/R-3.3.2/library"
Sys.setenv(JAVA_HOME='C:\\Program Files\\Java\\jre7') # for 64-bit version
install.packages(c("plyr","xlsx", "readxl", "xlsx", "plyr","dplyr", "zoo", "AICcmodavg","MuMIn", "car", "sjPlot", "visreg", "datamart", "reshape2", "rJava", "WriteXLS", "xlsx", "readxl"))
install.packages("tidyverse")
install.packages("xlsx")

### Packages :
library(xlsx)
library(plyr)
library(xlsx)
library(rJava) 
library(WriteXLS) # Writing Excel files
library(write.xlsx)
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
library(reshape2) # reshape datasets
library(reshape)

### Data
## Climate Data
setwd("C:/Users/amykr/Box Sync/DENV CHIKV project/Climate Data/Climate Coast/Climate Coast Latest") # Always set where you're grabbing stuff from

# Ukunda
Diani <- read_excel("Coast daily rainfall Mar 2017.xls", sheet = "Ukunda")
Ukunda_Rain <- Diani
Ukunda_Rain$Date <- as.Date(Ukunda_Rain$Date)

Diani <-  read_excel("Daily climate data temp dewpoint and humidity for Ukunda Feb 2017.xls")
Diani$Date <- as.Date(Diani$Date)

# Renaming the variables
#names(Diani)[2] <- "Temp"; names(Diani)[5] <- "RH"; names(Diani)[8] <- "DewPt"

# Collating all of the individual day's information together
#Ukunda_Daily <- ddply(Diani, ~Date, summarise,  MaxTemp = max(Temp, na.rm = T),MinTemp = min(Temp, na.rm = T),
#                    Temp = mean(Temp, na.rm = T), RH = mean(RH, na.rm = T), DewPt = mean(DewPt, na.rm = T))

names(Ukunda_Rain)[2] <- "rain"
UkundaClimate <- merge(Ukunda_Rain, Diani, by = "Date", all.y = TRUE)
#UkundaClimate[is.na(UkundaClimate$rain),2] <- 0 # Entering 0 for the rain fall amounts where there was none

# Removing the observations with missing or no data
#UkundaClimate <- UkundaClimate[-(which(UkundaClimate$RH == "NaN")),]

# Creating the anomaly data (data that's farther than 1.5 SD from the mean)
UkundaRainMean <- mean(UkundaClimate$rain,  na.rm=TRUE) 
UkundaRainSD <- sqrt(var(UkundaClimate$rain,  na.rm=TRUE))

UkundaClimate$RainfallAnomaly <- sapply(UkundaClimate$rain, # Logical values indicating if the rain exceeds 1.5 sd of the mean
                                        function(x, m , sd) (x > m + 1.5*sd), 
                                        m = UkundaRainMean, sd = UkundaRainSD)
table(UkundaClimate$RainfallAnomaly)

names(UkundaClimate)[3] <- "Temp"
names(UkundaClimate)[4] <- "MinTemp"
names(UkundaClimate)[5] <- "MaxTemp"
names(UkundaClimate)[9] <- "DewPt"
names(UkundaClimate)[6] <- "RH"
UkundaClimate$DewPt<-as.numeric(UkundaClimate$DewPt)
UkundaClimate$DewPt<-as.numeric(UkundaClimate$Temp)
UkundaClimate$RH<-as.numeric(UkundaClimate$RH)

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
UkundaRHMean <- mean(UkundaClimate$RH, na.rm=TRUE); UkundaRHSD <- sqrt(var(UkundaClimate$RH,  na.rm=TRUE))

UkundaClimate$TempAnom <- sapply(UkundaClimate$Temp, 
                                 function(x, m , sd) (x < m + 1.5*sd),
                                 m = UkundaTempMean, sd = UkundaTempSD)
UkundaClimate$RHAnom <- sapply(UkundaClimate$RH, 
                               function(x, m , sd) (x < m + 1.5*sd),
                               m = UkundaRHMean, sd = UkundaRHSD)

UkundaClimate$RHTempAnomaly = (UkundaClimate$TempAnom & UkundaClimate$RHAnom)

# Msambweni
Msam <- read_excel("Coast daily rainfall Mar 2017.xls", sheet = "Msambweni")
Msam_Rain <- Msam
Msam_Rain$Date <- as.Date(Msam_Rain$Date)
names(Msam_Rain)[2] <- "rain2"
Msam <-  read_excel("Daily climate data temp dewpoint and humidity for Msambweni Feb 2017.xls")
Msam$Date <- as.Date(Msam$Date)

# Renaming the day data
names(Msam)[2] <- "Temp"; names(Msam)[5] <- "RH"; names(Msam)[8] <- "DewPt"

# Collating day data
#Msam_Daily <- ddply(Msam, ~Date, summarise,  MaxTemp = max(Temp, na.rm = T),MinTemp = min(Temp, na.rm = T),
#                     Temp = mean(Temp, na.rm = T), RH = mean(RH, na.rm = T), DewPt = mean(DewPt, na.rm = T))
MsamClimate <- merge(Msam_Rain, Msam, by = "Date", all = TRUE)

#MsamClimate[is.na(MsamClimate$rain2),2] <- 0 # Entering 0 for the rain fall amounts where there was none
# Creating the anomalies
MsamRainMean <- mean(MsamClimate$rain2, na.rm=TRUE); MsamRainSD <- sqrt(var(MsamClimate$rain2, na.rm=TRUE))
MsamClimate$RainfallAnomaly <- sapply(MsamClimate$rain2, # Logical values indicating if the rain exceeds 1.5 sd of the mean
                                      function(x, m , sd) (x > m + 1.5*sd), 
                                      m = MsamRainMean, sd = MsamRainSD)
MsamClimate$TempRange <- MsamClimate$Temp_max - MsamClimate$Temp_min
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
glimpse(twoSites)

chulaimbo_dailyrain <- twoSites[, c (5, 6) ] 
names(chulaimbo_dailyrain)[2] <- paste("Rainfall")
glimpse(chulaimbo_dailyrain)

kisumu_dailyrain <- twoSites[,c(5,7)]
names(kisumu_dailyrain)[2] <- paste("Rainfall")
glimpse(kisumu_dailyrain)

# Chulaimbo
chul_hospitalTemp <- read_excel("Temperature_Daily data_Oct 3 2016.xlsx", sheet = 1) 
chul_villageTemp <- read_excel("Temperature_Daily data_Oct 3 2016.xlsx", sheet = 2) 

chul_hospitalRH <- read_excel("RH_Daily data_Oct 3 2016.xlsx", sheet = 1)
chul_villageRH <- read_excel("RH_Daily data_Oct 3 2016.xlsx", sheet = 2) 

chul_hospitalDewPt <- read_excel("DewPt_Daily data_Oct 3 2016.xlsx", sheet = 1) 
chul_villageDewPt <- read_excel("DewPt_Daily data_Oct 3 2016.xlsx", sheet = 2) 

# Eliminating extraneous columns and rows (filled mostly with NA's)
a <- c(5:19)

chul_hospitalTemp <- chul_hospitalTemp[,-(5:19)] 
chul_villageTemp <- chul_villageTemp[,-(5:19)]
chul_hospitalRH <- chul_hospitalRH[,-a] 
chul_villageRH <- chul_villageRH[,-a]
chul_hospitalDewPt <- chul_hospitalDewPt[,-a] 
chul_villageDewPt <- chul_villageDewPt[,-a]

# Renaming variable for ease of use
names(chul_hospitalTemp)[2] <- paste("MaxTemp"); names(chul_hospitalTemp)[4] <- paste("MinTemp")
names(chul_hospitalTemp)[3] <- paste("Temp")
names(chul_villageTemp)[2] <- paste("MaxTemp"); names(chul_villageTemp)[4] <- paste("MinTemp")
names(chul_villageTemp)[3] <- paste("Temp")

names(chul_hospitalRH)[2] <- paste("MaxRH");names(chul_hospitalRH)[3] <- paste("RH"); names(chul_hospitalRH)[4] <- paste("MinRH")
names(chul_hospitalDewPt)[2] <- paste("MinDewPt"); names(chul_hospitalDewPt)[3] <- paste("DewPt"); names(chul_hospitalDewPt)[4] <- paste("MaxDewPt")
names(chul_villageDewPt)[2] <- paste("MinDewPt"); names(chul_villageDewPt)[3] <- paste("DewPt"); names(chul_villageDewPt)[4] <- paste("MaxDewPt")
names(chul_villageRH)[2] <- paste("MinRH"); names(chul_villageRH)[3] <- paste("RH"); names(chul_villageRH)[4] <- paste("MaxRH")

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

Chulaimbo_DailyCom$Date <- as.POSIXct(as.Date(Chulaimbo_DailyCom$Date))
chulaimbo_dailyrain$Date <- chulaimbo_dailyrain$Date
names(chulaimbo_dailyrain)[1] <- paste("Date")
names(chulaimbo_dailyrain)[2] <- paste("Rainfall")
glimpse(chulaimbo_dailyrain)

ChulaimboClimate <- merge(Chulaimbo_DailyCom, chulaimbo_dailyrain, by = "Date", all = TRUE)
#ChulaimboClimate[is.na(ChulaimboClimate$Rainfall),7] <- 0
glimpse(ChulaimboClimate)

# Starting to make the anomaly data
ChulaimboRainMean <- mean(ChulaimboClimate$Rainfall, na.rm = T); ChulaimboRainSD <- sqrt(var(ChulaimboClimate$Rainfall, na.rm = T))

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

a <- c(5:19)

# Removing the extraneous columns and rows
kisumu_hospitalTemp <- kisumu_hospitalTemp[,-(5:19)] 
kisumu_estateTemp <- kisumu_estateTemp[,-a]
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

Kisumu_DailyCom$Date <- as.Date(Kisumu_DailyCom$Date)
names(kisumu_dailyrain)[1] <- paste("Date")
kisumu_dailyrain$Date <- as.Date(kisumu_dailyrain$Date)
glimpse(kisumu_dailyrain)
KisumuClimate <- merge(Kisumu_DailyCom, kisumu_dailyrain, by = "Date", all = TRUE)
glimpse(KisumuClimate)
#KisumuClimate[is.na(KisumuClimate$Rainfall),7] <- 0

# Creating anomaly data
KisumuRainMean <- mean(KisumuClimate$Rainfall, na.rm = T) 
KisumuRainSD <- sqrt(var(KisumuClimate$Rainfall, na.rm = T))

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
#setwd("C:/Users/amykr/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/built environement hcc/vector and climate")
setwd("C:/Users/amykr/Box Sync/DENV CHIKV project/Climate Data/monthly summaries")
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
glimpse(ChulaimboClimate)
ChulaimboMonthlyClimate <- ddply(ChulaimboClimate, ~Month, summarise, AvgTemp = mean(Temp, na.rm = T), 
                                 AvgMaxTemp = mean(MaxTemp, na.rm = T), AvgMinTemp = mean(MinTemp, na.rm = T), 
                                 OverallMaxTemp = max(MaxTemp, na.rm = T), OverallMinTemp = min(MinTemp, na.rm = T),
                                 AvgTempRange = mean((MaxTemp - MinTemp), na.rm = T), AvgRH = mean(RH, na.rm = T),
                                 AvgDewPt = mean(DewPt, na.rm = T), TtlRainfall = sum(Rainfall),
                                 RainfallAnomalies = sum(RainfallAnomaly), TempRangeAnomalies = sum(RangeAnomaly),
                                 TempDewPtDiffAnomalies = sum(DewDiffAnomaly), TempAnomalies = sum(TempAnom),
                                 RHAnomalies = sum(RHAnom), RHTempAnomalies = sum(RHTempAnomaly)) 
glimpse(KisumuClimate)
KisumuMonthlyClimate <- ddply(KisumuClimate, ~Month, summarise, AvgTemp = mean(Temp, na.rm = T), 
                              AvgMaxTemp = mean(MaxTemp, na.rm = T), AvgMinTemp = mean(MinTemp, na.rm = T), 
                              OverallMaxTemp = max(MaxTemp, na.rm = T), OverallMinTemp = min(MinTemp, na.rm = T),
                              AvgTempRange = mean((MaxTemp - MinTemp), na.rm = T), AvgRH = mean(RH, na.rm = T),
                              AvgDewPt = mean(DewPt, na.rm = T), TtlRainfall = sum(Rainfall),
                              RainfallAnomalies = sum(RainfallAnomaly), TempRangeAnomalies = sum(RangeAnomaly),
                              TempDewPtDiffAnomalies = sum(DewDiffAnomaly), TempAnomalies = sum(TempAnom),
                              RHAnomalies = sum(RHAnom), RHTempAnomalies = sum(RHTempAnomaly)) 
glimpse(MsamClimate)
MsamMonthlyClimate <- ddply(MsamClimate, ~Month, summarise, AvgTemp = mean(Temp, na.rm = T), 
                            AvgMaxTemp = mean(Temp_max, na.rm = T), AvgMinTemp = mean(Temp_min, na.rm = T), 
                            OverallMaxTemp = max(Temp_max, na.rm = T), OverallMinTemp = min(Temp_min, na.rm = T),
                            AvgTempRange =mean((Temp_max - Temp_min), na.rm = T), AvgRH = mean(RH, na.rm = T),
                            AvgDewPt = mean(DewPt, na.rm = T), TtlRainfall = sum(rain2),
                            RainfallAnomalies = sum(RainfallAnomaly), TempRangeAnomalies = sum(RangeAnomaly),
                            TempDewPtDiffAnomalies = sum(DewDiffAnomaly), TempAnomalies = sum(TempAnom),
                            RHAnomalies = sum(RHAnom), RHTempAnomalies = sum(RHTempAnomaly)) 

glimpse(UkundaClimate)
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
write.xlsx(ChulaimboMonthlyClimate, f, sheetName = "ChulaimboMonthlyClimateData", col.names = TRUE,
           row.names = FALSE, append = FALSE, showNA = TRUE)
f = "KisumuMonthlyClimateData.xls"
write.xlsx(KisumuMonthlyClimate, f, sheetName = "KisumuMonthlyClimateData", col.names = TRUE,
           row.names = FALSE, append = FALSE, showNA = TRUE)
f = "MsamMonthlyClimateData.xls"
write.xlsx(MsamMonthlyClimate, f, sheetName = "MsamMonthlyClimateData", col.names = TRUE,
           row.names = FALSE, append = FALSE, showNA = TRUE)
f = "UkundaMonthlyClimateData.xls"
write.xlsx(UkundaMonthlyClimate, f, sheetName = "UkundaMonthlyClimateData", col.names = TRUE,
           row.names = FALSE, append = FALSE, showNA = TRUE)

## Mosquito Data 
setwd("C:/Users/amykr/Box Sync/DENV CHIKV project/Vector Data/West/West Latest")
Ovitrap1 <- read_excel("Ovitrap Sampling Data.xlsx", sheet = 1)
Larval1 <- read_excel("Larval Sampling Data.xlsx", sheet = 1)
Prokopack1 <- read_excel("Prokopack Sampling Data.xlsx", sheet = 1)
SentinelTrap1 <- read_excel("BioGents-Sentinel Trap Mosquito   Sampling Data.xlsx", sheet = 1)
LandingCatches1 <- read_excel("HLC  Adult Mosquito Sampling  Data.xlsx", sheet = 1)
Pupae1 <-Larval1[,1:15]

setwd("C:/Users/amykr/Box Sync/DENV CHIKV project/Vector Data/Coast/Coast Latest")
Ovitrap2 <- read_excel("Ovitrapdata.xls", sheet = 1)
Larval2 <- read_excel("LarvalF.xls", sheet = 2)
Prokopack2 <- read_excel("ProkopackF.xls", sheet = 1)
SentinelTrap2 <- read_excel("BG Sentinel data.xls", sheet = 1)
LandingCatches2 <- read_excel("HLC.xls", sheet = 1)
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
Ovitrap1wide<-cast(Ovitrap1wide, site + date + indoors ~ species , fun = sum, value  = 'measure')
glimpse(Ovitrap1wide)

Aedes_aegypti_Indoor <- Ovitrap1wide[ which(Ovitrap1wide$indoors ==1), c (1:2, 5) ] 
names(Aedes_aegypti_Indoor)[3] <- "Indoor" 

CulexsppIndoor <- Ovitrap1wide[ which(Ovitrap1wide$indoors ==1), c (1:2, 6) ] 
names(CulexsppIndoor)[3] <- "Indoor" 

Aedes_aegypti_outdoor <- Ovitrap1wide[ which(Ovitrap1wide$indoors ==0), c (1:2, 5) ] 
names(Aedes_aegypti_outdoor)[3] <- "outdoor" 

Culexsppoutdoor <- Ovitrap1wide[ which(Ovitrap1wide$indoors ==0), c (1:2, 6) ] 
names(Culexsppoutdoor)[3] <- "outdoor" 

Indoor_Total<- rbind(Aedes_aegypti_Indoor, CulexsppIndoor)
Indoor_Total <- aggregate(Indoor_Total$Indoor, by=list(date=Indoor_Total$date, site =Indoor_Total$site), FUN=sum)
names(Indoor_Total)[3] <- "Indoor Total" 

outdoor_Total<- rbind(Aedes_aegypti_outdoor, Culexsppoutdoor)
outdoor_Total <- aggregate(outdoor_Total$outdoor, by=list(date=outdoor_Total$date, site =outdoor_Total$site), FUN=sum)
names(outdoor_Total)[3] <- "Outdoor Total" 

#names
names(Aedes_aegypti_Indoor)[3] <- "Aedes spp, Indoor" 
glimpse(Aedes_aegypti_Indoor)
names(CulexsppIndoor)[3] <- "Culex spp., Indoor" 
glimpse(CulexsppIndoor)
names(Aedes_aegypti_outdoor)[3] <- "Aedes spp, Outdoor" 
glimpse(Aedes_aegypti_outdoor)
names(Culexsppoutdoor)[3] <- "Culex spp., Outdoor" 
glimpse(Culexsppoutdoor)

glimpse(c(Aedes_aegypti_outdoor, Culexsppoutdoor, outdoor_Total, Indoor_Total, Aedes_aegypti_Indoor, CulexsppIndoor))

# merge two data frames by ID and Country
total <- merge(Aedes_aegypti_outdoor, Culexsppoutdoor, by=c("date","site"))
total <- merge(total, outdoor_Total, by=c("date","site"))
total <- merge(total, Indoor_Total, by=c("date","site"))
total <- merge(total, Aedes_aegypti_Indoor, by=c("date","site"))
total <- merge(total, CulexsppIndoor, by=c("date","site"))
Ovitrap1<-total[c(2,1,7, 8, 6, 3, 4, 5)]

# These variable names may need to be updated as more data is collected
names(Ovitrap1)[1] <- "Site"; 
names(Ovitrap1)[2] <- "Date"
names(Ovitrap1)[3] <- "Aedes spp, Indoor"
names(Ovitrap1)[4] <- "Culex spp., Indoor"
names(Ovitrap1)[5] <- "Indoor Total"
names(Ovitrap1)[6] <- "Aedes spp, Outdoor"
names(Ovitrap1)[7] <- "Culex spp., Outdoor"
names(Ovitrap1)[8] <- "Outdoor Total"

glimpse(Ovitrap1)
# Removing excess columns and rows
Ovitrap1 <- Ovitrap1[-1,]
ind <- apply(Ovitrap1, 2, function(x) all(is.na(x)))
Ovitrap1 <- Ovitrap1[,!ind]
#Ovitrap1b <- Ovitrap1[(-which(is.na(Ovitrap1$Date))),]
glimpse(Ovitrap1)

# Adjusting and including site names as well as variable names
# These variable names may need to be updated as more data is collected
glimpse(Ovitrap2)

#reshape to wide
names(Ovitrap2) <- tolower(names(Ovitrap2))
Ovitrap2$species[Ovitrap2$species=="Ae.aegypti/simpsoni"] <- "aedes spp"
Ovitrap2$species[Ovitrap2$species=="Aedes"] <- "aedes spp"
Ovitrap2$species[Ovitrap2$species=="Ae.aegypti"] <- "Aedes spp"
Ovitrap2$species[Ovitrap2$species=="A.aegypti/simpsoni"] <- "aedes spp"
Ovitrap2$species[Ovitrap2$species=="Aedes aegypti"] <- "Aedes spp"
Ovitrap2$species[Ovitrap2$species=="Ae. Aegypti"] <- "Aedes spp"
Ovitrap2$species[Ovitrap2$species=="none"] <- "N/A"
Ovitrap2$species[Ovitrap2$species=="_"] <- "N/A"
Ovitrap2$species[Ovitrap2$species=="None"] <- "N/A"
Ovitrap2$species[Ovitrap2$species=="0.000000"] <- "N/A"
table(Ovitrap2$species)

library(reshape)
Ovitrap2wide <- melt(Ovitrap2, c("date", "site", "species", "location"), "egg count")
Ovitrap2wide<-cast(Ovitrap2wide, site + date + location ~ species, fun = sum, value  = 'egg count')
glimpse(Ovitrap2wide)

Aedes_aegypti_Indoor <- Ovitrap2wide[ which(Ovitrap2wide$location =="Indoor"), c (1:2, 7) ] 
glimpse(Aedes_aegypti_Indoor)
names(Aedes_aegypti_Indoor)[3] <- "Indoor" 

CulexsppIndoor <- Ovitrap2wide[ which(Ovitrap2wide$location =="Indoor"), c (1:2, 9) ] 
names(CulexsppIndoor)[3] <- "Indoor" 

Aedes_aegypti_outdoor <- Ovitrap2wide[ which(Ovitrap2wide$location =="Outdoor"), c (1:2, 7) ] 
names(Aedes_aegypti_outdoor)[3] <- "outdoor" 

Culexsppoutdoor <- Ovitrap2wide[ which(Ovitrap2wide$location =="Outdoor"), c (1:2, 9) ] 
names(Culexsppoutdoor)[3] <- "outdoor" 

Indoor_Total<- rbind(Aedes_aegypti_Indoor, CulexsppIndoor)
Indoor_Total <- aggregate(Indoor_Total$Indoor, by=list(date=Indoor_Total$date, site =Indoor_Total$site), FUN=sum)
names(Indoor_Total)[3] <- "Indoor Total" 

outdoor_Total<- rbind(Aedes_aegypti_outdoor, Culexsppoutdoor)
outdoor_Total <- aggregate(outdoor_Total$outdoor, by=list(date=outdoor_Total$date, site =outdoor_Total$site), FUN=sum)
names(outdoor_Total)[3] <- "Outdoor Total" 

#names
names(Aedes_aegypti_Indoor)[3] <- "Aedes spp, Indoor" 
glimpse(Aedes_aegypti_Indoor)
names(CulexsppIndoor)[3] <- "Culex spp., Indoor" 
glimpse(CulexsppIndoor)
names(Aedes_aegypti_outdoor)[3] <- "Aedes spp, Outdoor" 
glimpse(Aedes_aegypti_outdoor)
names(Culexsppoutdoor)[3] <- "Culex spp., Outdoor" 
glimpse(Culexsppoutdoor)

glimpse(c(Aedes_aegypti_outdoor, Culexsppoutdoor, outdoor_Total, Indoor_Total, Aedes_aegypti_Indoor, CulexsppIndoor))

# merge two data frames by ID and Country
total <- merge(Aedes_aegypti_outdoor, Culexsppoutdoor, by=c("date","site"))
total <- merge(total, outdoor_Total, by=c("date","site"))
total <- merge(total, Indoor_Total, by=c("date","site"))
total <- merge(total, Aedes_aegypti_Indoor, by=c("date","site"))
total <- merge(total, CulexsppIndoor, by=c("date","site"))
Ovitrap2<-total[c(2,1,7, 8, 6, 3, 4, 5)]
glimpse(Ovitrap2)
# These variable names may need to be updated as more data is collected
names(Ovitrap2)[1] <- "Site"; 
names(Ovitrap2)[2] <- "Date"
names(Ovitrap2)[3] <- "Aedes spp, Indoor"
names(Ovitrap2)[4] <- "Culex spp., Indoor"
names(Ovitrap2)[5] <- "Indoor Total"
names(Ovitrap2)[6] <- "Aedes spp, Outdoor"
names(Ovitrap2)[7] <- "Culex spp., Outdoor"
names(Ovitrap2)[8] <- "Outdoor Total"

# Removing excess columns and rows
Ovitrap2 <- Ovitrap2[-1,]
Ovitrap2 <- Ovitrap2[-dim(Ovitrap2)[1], -dim(Ovitrap2)[2]] # last one is totals which we don't really need

# Adjusting dates
Ovitrap1$Date <- as.yearmon(as.Date(as.POSIXct(Ovitrap1$Date), origin = "1900-01-01"))
Ovitrap2$Date <- as.yearmon(as.Date(as.POSIXct(Ovitrap2$Date), origin = "1900-01-01"))

# Double checking everything was processed okay
head(Ovitrap1)
head(Ovitrap2)

Ovitrap2$Site[Ovitrap2$Site=="nganja"] <- "Msambweni"
Ovitrap2$Site[Ovitrap2$Site=="Nganja"] <- "Msambweni"
Ovitrap2$Site[Ovitrap2$Site=="MILALANI"] <- "Msambweni"
Ovitrap2$Site[Ovitrap2$Site=="Milalani"] <- "Msambweni"
Ovitrap2$Site[Ovitrap2$Site=="mwamambi A"] <- "Ukunda"
Ovitrap2$Site[Ovitrap2$Site=="Mwamambi A"] <- "Ukunda"
Ovitrap2$Site[Ovitrap2$Site=="Mwamambi B"] <- "Ukunda"
Ovitrap2$Site[Ovitrap2$Site=="mwamambi B"] <- "Ukunda"

# Separating data into site specific data sets
OvitrapC <- Ovitrap1[which(Ovitrap1[,1] == "Chulaimbo"),]
OvitrapK <- Ovitrap1[-which(Ovitrap1[,1] == "Chulaimbo"),]
OvitrapM <- Ovitrap2[which(Ovitrap2[,1] == "Msambweni"),]
OvitrapU <- Ovitrap2[which(Ovitrap2[,1] == "Ukunda"),]


# Larval 

# Removing excess columns and rows
# Larval

# Adjusting and including site names as well as variable names
for(i in 1:(dim(Larval2)[1])){
  if(is.na(Larval2[i,1])){
    Larval2[i,1] = Larval2[(i - 1),1]
  }
}
glimpse(Larval2)
table(Larval2$SpeciesL)
names(Larval2)[names(Larval2)=="SpeciesL"] <- "species"
Larval2$measure <- rowSums(Larval2[15:16])
names(Larval2) <- tolower(names(Larval2))
Larval2$species <- tolower(Larval2$species)

#reshape to wide
library(reshape)
glimpse(Larval2wide)
Larval2$species[Larval2$species=="ae.simp"] <- "ae.simpsoni"
Larval2$species[Larval2$species=="toxorhynchite"] <- "toxo"
Larval2$species[Larval2$species=="ae.simpsoni"] <- "aedes spp"
Larval2$species[Larval2$species=="aedes"] <- "aedes spp"
table(Larval2$species)

Larval2wide <- melt(Larval2, c("date", "site", "species", "location"), "measure")
Larval2wide<-cast(Larval2wide, site + date + location ~ species, fun = sum, value  = 'measure')
glimpse(Larval2wide)
names(Larval2wide)[names(Larval2wide)=="location"] <- "indoors"
Larval2wide$indoors[Larval2wide$indoors=="indoor"] <- "1"
Larval2wide$indoors[Larval2wide$indoors=="outdoor"] <- "0"
Larval2wide$indoors[Larval2wide$indoors=="Indoor"] <- "1"
Larval2wide$indoors[Larval2wide$indoors=="Outdoor"] <- "0"

Aedes_aegypti_Indoor <- Larval2wide[ which(Larval2wide$indoors ==1), c (1:2, 5) ] 
names(Aedes_aegypti_Indoor)[3] <- "Indoor" 

CulexsppIndoor <- Larval2wide[ which(Larval2wide$indoors ==1), c (1:2, 7) ] 
names(CulexsppIndoor)[3] <- "Indoor" 

Aedes_aegypti_outdoor <- Larval2wide[ which(Larval2wide$indoors ==0), c (1:2, 5) ] 
names(Aedes_aegypti_outdoor)[3] <- "outdoor" 

Culexsppoutdoor <- Larval2wide[ which(Larval2wide$indoors ==0), c (1:2, 7) ] 
names(Culexsppoutdoor)[3] <- "outdoor" 

Indoor_Total<- rbind(Aedes_aegypti_Indoor, CulexsppIndoor)
Indoor_Total <- aggregate(Indoor_Total$Indoor, by=list(date=Indoor_Total$date, site =Indoor_Total$site), FUN=sum)
names(Indoor_Total)[3] <- "Indoor Total" 

outdoor_Total<- rbind(Aedes_aegypti_outdoor, Culexsppoutdoor)
outdoor_Total <- aggregate(outdoor_Total$outdoor, by=list(date=outdoor_Total$date, site =outdoor_Total$site), FUN=sum)
names(outdoor_Total)[3] <- "Outdoor Total" 

#names
names(Aedes_aegypti_Indoor)[3] <- "Aedes spp, Indoor" 
glimpse(Aedes_aegypti_Indoor)
names(CulexsppIndoor)[3] <- "Culex spp., Indoor" 
glimpse(CulexsppIndoor)
names(Aedes_aegypti_outdoor)[3] <- "Aedes spp, Outdoor" 
glimpse(Aedes_aegypti_outdoor)
names(Culexsppoutdoor)[3] <- "Culex spp., Outdoor" 
glimpse(Culexsppoutdoor)

glimpse(c(Aedes_aegypti_outdoor, Culexsppoutdoor, outdoor_Total, Indoor_Total, Aedes_aegypti_Indoor, CulexsppIndoor))

# merge two data frames by ID and Country
total <- merge(Aedes_aegypti_outdoor, Culexsppoutdoor, by=c("date","site"))
total <- merge(total, outdoor_Total, by=c("date","site"))
total <- merge(total, Indoor_Total, by=c("date","site"))
total <- merge(total, Aedes_aegypti_Indoor, by=c("date","site"))
total <- merge(total, CulexsppIndoor, by=c("date","site"))
Larval2<-total[c(2,1,7, 8, 6, 3, 4, 5)]
glimpse(Larval2)
# These variable names may need to be updated as more data is collected
names(Larval2)[1] <- "Site"; 
names(Larval2)[2] <- "Date"
names(Larval2)[4] <- "Culex spp., Indoor"
names(Larval2)[5] <- "Indoor Total"
names(Larval2)[6] <- "Aedes spp, Outdoor"
names(Larval2)[7] <- "Culex spp., Outdoor"
names(Larval2)[8] <- "Outdoor Total"

glimpse(Larval2)
# Removing excess columns and rows
Larval2 <- Larval2[-1,]
ind <- apply(Larval2, 2, function(x) all(is.na(x)))
Larval2 <- Larval2[,!ind]
#Larval2b <- Larval2[(-which(is.na(Larval2$Date))),]
glimpse(Larval2)


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
glimpse(Larval1)
table(Larval1$Species)
Larval1$measure <- rowSums(Larval1[13:14])
names(Larval1) <- tolower(names(Larval1))
Larval1$species <- tolower(Larval1$species)
names(Larval1)[8] <- "indoors" 
Larval1$indoors[Larval1$indoors=="indoors"] <- "1"
Larval1$indoors[Larval1$indoors=="outdoors"] <- "0"
Larval1$indoors[Larval1$indoors=="Indoors"] <- "1"
Larval1$indoors[Larval1$indoors=="Outdoors"] <- "0"

#reshape to wide
library(reshape)
Larval1wide <- melt(Larval1, c("date", "site", "species", "indoors"), "measure")
Larval1wide<-cast(Larval1wide, site + date + indoors ~ species, fun = sum, value  = 'measure')
glimpse(Larval1wide)

Aedes_aegypti_Indoor <- Larval1wide[ which(Larval1wide$indoors ==1), c (1:2, 5) ] 
names(Aedes_aegypti_Indoor)[3] <- "Indoor" 

CulexsppIndoor <- Larval1wide[ which(Larval1wide$indoors ==1), c (1:2, 7) ] 
names(CulexsppIndoor)[3] <- "Indoor" 

Aedes_aegypti_outdoor <- Larval1wide[ which(Larval1wide$indoors ==0), c (1:2, 5) ] 
names(Aedes_aegypti_outdoor)[3] <- "outdoor" 

Culexsppoutdoor <- Larval1wide[ which(Larval1wide$indoors ==0), c (1:2, 7) ] 
names(Culexsppoutdoor)[3] <- "outdoor" 

Indoor_Total<- rbind(Aedes_aegypti_Indoor, CulexsppIndoor)
Indoor_Total <- aggregate(Indoor_Total$Indoor, by=list(date=Indoor_Total$date, site =Indoor_Total$site), FUN=sum)
names(Indoor_Total)[3] <- "Indoor Total" 

outdoor_Total<- rbind(Aedes_aegypti_outdoor, Culexsppoutdoor)
outdoor_Total <- aggregate(outdoor_Total$outdoor, by=list(date=outdoor_Total$date, site =outdoor_Total$site), FUN=sum)
names(outdoor_Total)[3] <- "Outdoor Total" 

#names
names(Aedes_aegypti_Indoor)[3] <- "Aedes spp, Indoor" 
glimpse(Aedes_aegypti_Indoor)
names(CulexsppIndoor)[3] <- "Culex spp., Indoor" 
glimpse(CulexsppIndoor)
names(Aedes_aegypti_outdoor)[3] <- "Aedes spp, Outdoor" 
glimpse(Aedes_aegypti_outdoor)
names(Culexsppoutdoor)[3] <- "Culex spp., Outdoor" 
glimpse(Culexsppoutdoor)

glimpse(c(Aedes_aegypti_outdoor, Culexsppoutdoor, outdoor_Total, Indoor_Total, Aedes_aegypti_Indoor, CulexsppIndoor))

# merge two data frames by ID and Country
total <- merge(Aedes_aegypti_outdoor, Culexsppoutdoor, by=c("date","site"))
total <- merge(total, outdoor_Total, by=c("date","site"))
total <- merge(total, Indoor_Total, by=c("date","site"))
total <- merge(total, Aedes_aegypti_Indoor, by=c("date","site"))
total <- merge(total, CulexsppIndoor, by=c("date","site"))
Larval1<-total[c(2,1,7, 8, 6, 3, 4, 5)]
glimpse(Larval1)
# These variable names may need to be updated as more data is collected
names(Larval1)[1] <- "Site"; 
names(Larval1)[2] <- "Date"
names(Larval1)[3] <- "Aedes spp, Indoor"
names(Larval1)[4] <- "Culex spp., Indoor"
names(Larval1)[5] <- "Indoor Total"
names(Larval1)[6] <- "Aedes spp, Outdoor"
names(Larval1)[7] <- "Culex spp., Outdoor"
names(Larval1)[8] <- "Outdoor Total"

glimpse(Larval1)
# Removing excess columns and rows
Larval1 <- Larval1[-1,]
ind <- apply(Larval1, 2, function(x) all(is.na(x)))
Larval1 <- Larval1[,!ind]
#Larval1b <- Larval1[(-which(is.na(Larval1$Date))),]
glimpse(Larval1)

# Adjusting dates
Larval1$Date <- as.yearmon(as.Date(as.POSIXct(Larval1$Date), origin = "1900-01-01"))
Larval2$Date <- as.yearmon(as.Date(as.POSIXct(Larval2$Date), origin = "1900-01-01"))


# Double checking everything was processed correctly
head(Larval1)
head(Larval2)
Larval2$Site[Larval2$Site=="Milalani"] <- "Msambweni"
Larval2$Site[Larval2$Site=="Nganja"] <- "Msambweni"
Larval2$Site[Larval2$Site=="Milalani"] <- "Msambweni"
Larval2$Site[Larval2$Site=="Nganja"] <- "Msambweni"

table(Larval1$Site)

LarvalC <- Larval1[which(Larval1$Site == "Chulaimbo"),]
LarvalK <- Larval1[-which(Larval1$Site == "Chulaimbo"),]
LarvalM <- Larval2[which(Larval2$Site == "Msambweni"),]
LarvalU <- Larval2[-which(Larval2$Site == "Msambweni"),]
glimpse(LarvalU)
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
glimpse(Pupae1)
Pupae1<-Pupae1[c("Site", "Date", "Pupae", "Species", "IN-OUT-DOORS")]
table(Pupae1$Species)
Pupae1$Species[Pupae1$Species=="0"] <- "none"
Pupae1$Species[Pupae1$Species=="33"] <- "none"

#reshape to wide
pupae1wide <- melt(Pupae1, c("Date", "Site", "Species", "IN-OUT-DOORS"), "Pupae")
glimpse(pupae1wide)


glimpse(Pupae2)
Pupae2$Pupae <- rowSums(Pupae2[16:17])
Pupae2<-Pupae2[c("Site", "Date", "Pupae", "Location", "SpeciesL")]
Pupae2$SpeciesL[Pupae2$SpeciesL=="Toxorhynchite"] <- "Toxo"
Pupae2$SpeciesL[Pupae2$SpeciesL=="Ae.simpsoni"] <- "Ae.simp"
Pupae2$SpeciesL[Pupae2$SpeciesL==""] <- "none"
Pupae2$SpeciesL[Pupae2$SpeciesL=="_"] <- "none"
Pupae2$SpeciesL[Pupae2$SpeciesL=="Ae.simp"] <- "aedes spp"
Pupae2$SpeciesL <- tolower(Pupae2$SpeciesL)
Pupae2$SpeciesL[Pupae2$SpeciesL=="ae.simp"] <- "aedes spp"
Pupae2$SpeciesL[Pupae2$SpeciesL=="aedes simp"] <- "aedes spp"
table(Pupae2$SpeciesL)

Pupae2$Location[Pupae2$Location=="1ndoor"] <- "indoor"
Pupae2$Location[Pupae2$Location=="Indoor"] <- "indoor"
Pupae2$Location[Pupae2$Location=="Outdoor"] <- "outdoor"
Pupae2_indoor <- Pupae2[which(Pupae2$Location == "indoor"),]
table(Pupae2_indoor$SpeciesL)
Pupae2_indoor$SpeciesL[Pupae2_indoor$SpeciesL=="aedes"] <- "aedes indoor"
Pupae2_indoor$SpeciesL[Pupae2_indoor$SpeciesL=="an.gambiae"] <- "anopheles indoor"
Pupae2_indoor$SpeciesL[Pupae2_indoor$SpeciesL=="culex"] <- "culex indoor"
Pupae2_indoorwide <- melt(Pupae2_indoor, c("Date", "Site", "SpeciesL", "Location"), "Pupae")
Pupae2_indoorwide<-cast(Pupae2_indoorwide, Site + Date + Location ~ SpeciesL, fun = sum, value  = 'Pupae')
glimpse(Pupae2_indoorwide)

#come back here
Pupae2_outdoor <- Pupae2[which(Pupae2$Location == "outdoor"),]
table(Pupae2_outdoor$SpeciesL)
Pupae2_outdoor$SpeciesL[Pupae2_outdoor$SpeciesL=="Ae.simpsoni"] <- "aedes outdoor"
Pupae2_outdoor$SpeciesL[Pupae2_outdoor$SpeciesL=="Aedes simp"] <- "aedes outdoor"
Pupae2_outdoor$SpeciesL[Pupae2_outdoor$SpeciesL=="Aedes"] <- "aedes outdoor"
Pupae2_outdoor$SpeciesL[Pupae2_outdoor$SpeciesL=="Ae.simp"] <- "aedes outdoor"
Pupae2_outdoor$SpeciesL[Pupae2_outdoor$SpeciesL=="aedes"] <- "aedes outdoor"
Pupae2_outdoor$SpeciesL[Pupae2_outdoor$SpeciesL=="aedes spp"] <- "aedes outdoor"
Pupae2_outdoor$SpeciesL[Pupae2_outdoor$SpeciesL=="an.gambiae"] <- "anopheles outdoor"
Pupae2_outdoor$SpeciesL[Pupae2_outdoor$SpeciesL=="culex"] <- "culex outdoor"
Pupae2_outdoor$SpeciesL[Pupae2_outdoor$SpeciesL=="Culex"] <- "culex outdoor"
Pupae2_outdoor$SpeciesL[Pupae2_outdoor$SpeciesL=="Toxo"] <- "Toxo outdoor"
Pupae2_outdoor$SpeciesL[Pupae2_outdoor$SpeciesL=="Toxorhynchite"] <- "Toxo outdoor"
Pupae2_outdoor$SpeciesL[Pupae2_outdoor$SpeciesL=="None"] <- "none"
Pupae2_outdoor$SpeciesL[Pupae2_outdoor$SpeciesL==""] <- "none"
Pupae2_outdoor$SpeciesL[Pupae2_outdoor$SpeciesL=="_"] <- "none"
Pupae2_outdoor$SpeciesL[Pupae2_outdoor$SpeciesL=="0"] <- "none"
glimpse(Pupae2_outdoor)

Pupae2_indoorwide <- melt(Pupae2_indoor, c("Date", "Site", "SpeciesL", "Location"), "Pupae")
glimpse(Pupae2_indoorwide)
Pupae2_indoorwide<-cast(Pupae2_indoorwide, Site + Date + Location ~ SpeciesL, fun = sum, value  = 'Pupae')
glimpse(Pupae2_indoorwide)

Pupae2_outdoor <- melt(Pupae2_outdoor, c("Date", "Site", "SpeciesL", "Location"), "Pupae")
glimpse(Pupae2_outdoorwide)
Pupae2_outdoorwide<-cast(Pupae2_outdoor, Site + Date + Location~SpeciesL, fun = sum, value  = 'Pupae')
glimpse(Pupae2_outdoorwide)

Pupae2 <- merge(Pupae2_outdoorwide, Pupae2_indoorwide, by=c("Date","Site"))
glimpse(Pupae2)

# These variable names may need to be updated as more data is collected
glimpse(Pupae1)
table(Pupae1$'IN-OUT-DOORS')
Pupae1$'IN-OUT-DOORS'[Pupae1$'IN-OUT-DOORS'=="indoors"] <- "indoor"
Pupae1$'IN-OUT-DOORS'[Pupae1$'IN-OUT-DOORS'=="Indoors"] <- "indoor"
Pupae1$'IN-OUT-DOORS'[Pupae1$'IN-OUT-DOORS'=="Outdoors"] <- "outdoor"
Pupae1$'IN-OUT-DOORS'[Pupae1$'IN-OUT-DOORS'=="outdoors"] <- "outdoor"
Pupae1_indoor <- Pupae1[which(Pupae1$'IN-OUT-DOORS' == "indoor"),]
table(Pupae1_indoor$Species)
Pupae1_indoor$Species[Pupae1_indoor$Species=="Aedes aegypti"] <- "aedes indoor"
Pupae1_indoor$Species[Pupae1_indoor$Species=="Culex"] <- "culex indoor"
glimpse(Pupae1_indoor)
Pupae1_indoorwide <- melt(Pupae1_indoor, c("Date", "Site", "Species", "IN-OUT-DOORS"), "Pupae")
Pupae1_indoorwide<-cast(Pupae1_indoorwide, Site + Date + IN-OUT-DOORS~ Species, fun = sum, value  = 'Pupae')
glimpse(Pupae1_indoorwide)


Pupae1_outdoor <- Pupae1[which(Pupae1$'IN-OUT-DOORS' == "outdoor"),]
table(Pupae1_outdoor$Species)
Pupae1_outdoor$Species[Pupae1_outdoor$Species=="Aedes aegypti"] <- "aedes outdoor"
Pupae1_outdoor$Species[Pupae1_outdoor$Species=="Anopheles"] <- "Anopheles outdoor"
Pupae1_outdoor$Species[Pupae1_outdoor$Species=="Culex"] <- "culex outdoor"
Pupae1_outdoor$Species[Pupae1_outdoor$Species=="Toxorhynchites"] <- "Toxorhynchites outdoor"

glimpse(Pupae1_outdoor)
Pupae1_outdoorwide <- melt(Pupae1_outdoor, c("Date", "Site", "Species", "IN-OUT-DOORS"), "Pupae")
Pupae1_outdoorwide<-cast(Pupae1_outdoorwide, Site + Date + IN-OUT-DOORS~ Species)
glimpse(Pupae1_outdoorwide)

Pupae1 <- merge(Pupae1_outdoorwide, Pupae1_indoorwide, by=c("Date","Site"))
glimpse(Pupae1)


Pupae2wide<-Pupae2wide[c(1:5, 7)]
names(Pupae2wide)[1] <- "Site"; 
names(Pupae2wide)[2] <- "Date"
names(Pupae2wide)[3] <- "Aedes spp"
names(Pupae2wide)[4] <- "Anopheles spp."
names(Pupae2wide)[5] <- "Culex spp."
names(Pupae2wide)[6] <- "Toxo spp."
glimpse(Pupae2wide)
Pupae2<-Pupae2wide
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
table(Pupae2$Site)
Pupae2$Site[Pupae2$Site=="Milalani"] <- "Msambweni"
Pupae2$Site[Pupae2$Site=="Nganja"] <- "Msambweni"

Pupae2$Site[Pupae2$Site=="Diani A "] <- "Diani"
Pupae2$Site[Pupae2$Site=="Diani A"] <- "Diani"
Pupae2$Site[Pupae2$Site=="Diani B"] <- "Diani"
Pupae2$Site[Pupae2$Site=="DianiA"] <- "Diani"
Pupae2$Site[Pupae2$Site=="DianiB"] <- "Diani"
Pupae2$Site[Pupae2$Site=="Diani"] <- "Ukunda"
table(Pupae2$Site)

table(Pupae2$Site)

PupaeC <- Pupae1[which(Pupae1$Site == "Chulaimbo"),]
PupaeK <- Pupae1[-which(Pupae1$Site == "Chulaimbo"),]

PupaeM <- Pupae2[which(Pupae2$Site == "Msambweni"),]
PupaeU <- Pupae2[-which(Pupae2$Site == "Msambweni"),]

# Prokopack
# Adjusting and including site names as well as variable names
for(i in 1:(dim(Prokopack1)[1])){
  if(is.na(Prokopack1[i,1])){
    Prokopack1[i,1] = Prokopack1[(i - 1),1]
  }
}

glimpse(Prokopack1)
INDOOR<-Prokopack1[1:38]
INDOOR<-INDOOR[c(19:38, 1:18)]
glimpse(INDOOR)
names(INDOOR)[28] <- "Indoor" 
INDOOR$`Bushes around the house` <-"NA"
INDOOR$`Bushes around the house` <-"NA"

OUTDODOR<-Prokopack1[ c (1:7, 39:61) ]
OUTDODOR<-OUTDODOR[c(11:30, 1:10)]
glimpse(OUTDODOR)
names(OUTDODOR)[28] <- "Indoor" 
#add the other variables so we can bind.
OUTDODOR$ `House wall` <-"NA"
OUTDODOR$`House roof` <-"NA"
OUTDODOR$`Rooms with ceilings` <-"NA"
OUTDODOR$`Eaves open` <-"NA"
OUTDODOR$`Bed net present` <-"NA"
OUTDODOR$`Mosquito coil burn` <-"NA"
OUTDODOR$`Insecticide sprayed` <-"NA"
OUTDODOR$`No. of sleeper` <-"NA"
OUTDODOR$`Firewood use in the house` <-"NA"
OUTDODOR$`No. of rooms`<-"NA"

OUTDODOR$Indoor[OUTDODOR$Indoor == 2] <- 0
Prokopack1<-rbind.fill(OUTDODOR, INDOOR)
glimpse(Prokopack1)
library(tidyr)
gather<-gather(Prokopack1, keycol, valuecol, 1:20)
glimpse(gather)
names(Prokopack1)[names(Prokopack1)=="Aedes-Blood fed"] <- "Aedes-Bloodfed"
names(Prokopack1)[names(Prokopack1)=="Aedes-Half gravid"] <- "Aedes.Halfgravid"
names(Prokopack1)[names(Prokopack1)=="Aedes-Half gravid"] <- "Aedes.Halfgravid"
names(Prokopack1)[names(Prokopack1)=="Aedes-Male"] <- "Aedes.Male"
names(Prokopack1)[names(Prokopack1)=="Aedes-unfed"] <- "Aedes.unfed"
names(Prokopack1)[names(Prokopack1)=="Aedes -Gravid"] <- "Aedes.Gravid"
names(Prokopack1)[names(Prokopack1)=="Cu-Bloodfed"] <- "Cu.Bloodfed"
names(Prokopack1)[names(Prokopack1)=="Cu-gravid"] <- "Cu.gravid"    
names(Prokopack1)[names(Prokopack1)=="Cu-Half gravid"] <- "Cu.Halfgravid"    
names(Prokopack1)[names(Prokopack1)=="Cu-Male"] <- "Cu.Male"    
names(Prokopack1)[names(Prokopack1)=="Cu-Unfed"] <- "Cu.Unfed"    
names(Prokopack1)[names(Prokopack1)=="Fu- gravid"] <- "Fu.gravid"    
names(Prokopack1)[names(Prokopack1)=="Fu- Half gravid"] <- "Fu.Halfgravid"    
names(Prokopack1)[names(Prokopack1)=="Fu-Blood fed"] <- "Fu.Bloodfed"    
names(Prokopack1)[names(Prokopack1)=="Fu-Male"] <- "Fu.Male"    
names(Prokopack1)[names(Prokopack1)=="Fu-Unfed"] <- "Fu.Unfed"    
names(Prokopack1)[names(Prokopack1)=="Ga- Bloodfed"] <- "Ga.Bloodfed"    
names(Prokopack1)[names(Prokopack1)=="Ga- Half gravid"] <- "Ga.Halfgravid"    
names(Prokopack1)[names(Prokopack1)=="Ga-gravid"] <- "Ga.gravid"    
names(Prokopack1)[names(Prokopack1)=="Ga-Male"] <- "Ga.Male"    
names(Prokopack1)[names(Prokopack1)=="Ga-Unfed"] <- "Ga.Unfed"    
names(Prokopack1) <- tolower(names(Prokopack1))
glimpse(Prokopack1)
Prokopack1_s<-Prokopack1[c(1:21,25, 28)]
glimpse(Prokopack1_s)
Prokopack1_s$aedes <- rowSums(Prokopack1_s[1:5])
table(Prokopack1_s$aedes)
names(Prokopack1_s) <- tolower(names(Prokopack1_s))
Prokopack1_s$species <- tolower(Prokopack1_s$species)

#reshape to wide
glimpse(Prokopack1_s)
#come back here and fix this tomorrow
Prokopack1wide <- melt(Prokopack1_s, c("date", "site", "indoor"), "aedes")
glimpse(Prokopack1wide)
table(Prokopack1wide$value,Prokopack1wide$indoor)
aedes_Indoor <- Prokopack1wide[ which(Prokopack1wide$indoor ==1), ] 
glimpse(aedes_Indoor)
names(aedes_Indoor)[3] <- "aedes indoor" 

aedes_outdoor <- Prokopack1wide[ which(Prokopack1wide$indoor ==0),] 
names(aedes_outdoor)[3] <- "aedes outdoor" 

glimpse(c(aedes_outdoor, aedes_Indoor))

# merge two data frames by ID and Country
total <- merge(aedes_outdoor, aedes_Indoor, by=c("date","site"))
Prokopack1<-total[c(2,1, 3, 6)]
glimpse(Prokopack1)
# These variable names may need to be updated as more data is collected
# Removing excess columns and rows
Prokopack1 <- Prokopack1[-1,]
ind <- apply(Prokopack1, 2, function(x) all(is.na(x)))
Prokopack1 <- Prokopack1[,!ind]
#Prokopack1b <- Prokopack1[(-which(is.na(Prokopack1$Date))),]
glimpse(Prokopack1)

# Adjusting dates
Prokopack1$date <- as.yearmon(Prokopack1$date) 

# Taking care of NA's
Prokopack1[is.na(Prokopack1)] <- 0

# Double checking everything is processed correctly
head(Prokopack1)

# Separation into site specific data sets
Prokopack1$Site[Prokopack1$site=="Milalani"] <- "Msambweni"
Prokopack1$Site[Prokopack1$site=="Nganja"] <- "Msambweni"

Prokopack1$Site[Prokopack1$site=="Diani A"] <- "Diani"
Prokopack1$Site[Prokopack1$site=="Diani B"] <- "Diani"
Prokopack1$Site[Prokopack1$site=="DianiA"] <- "Diani"
Prokopack1$Site[Prokopack1$site=="DianiB"] <- "Diani"

table(Prokopack1$site)

ProkopackC <- Prokopack1[which(Prokopack1[,1] == "Chulaimbo"),]
ProkopackK <- Prokopack1[-which(Prokopack1[,1] == "Chulaimbo"),]
glimpse(ProkopackC)
# Prokopack2
# Adjusting and including site names as well as variable names
for(i in 1:(dim(Prokopack2)[1])){
  if(is.na(Prokopack2[i,1])){
    Prokopack2[i,1] = Prokopack2[(i - 1),1]
  }
}

glimpse(Prokopack2)
INDOOR<-Prokopack2[which(Prokopack2$Location2 == "1"),]
OUTDOOR<-Prokopack2[which(Prokopack2$Location2 == "2"),]

glimpse(OUTDOOR)
glimpse(INDOOR)
names(INDOOR)[10] <- "Indoor" 
INDOOR$`Bushes around the house` <-"NA"
INDOOR$`Bushes around the house` <-"NA"

glimpse(OUTDOOR)
names(OUTDOOR)[10] <- "Indoor" 
#add the other variables so we can bind.
OUTDOOR$ `House wall` <-"NA"
OUTDOOR$`House roof` <-"NA"
OUTDOOR$`Rooms with ceilings` <-"NA"
OUTDOOR$`Eaves open` <-"NA"
OUTDOOR$`Bed net present` <-"NA"
OUTDOOR$`Mosquito coil burn` <-"NA"
OUTDOOR$`Insecticide sprayed` <-"NA"
OUTDOOR$`No. of sleeper` <-"NA"
OUTDOOR$`Firewood use in the house` <-"NA"
OUTDOOR$`No. of rooms`<-"NA"

Prokopack2<-rbind.fill(OUTDOOR, INDOOR)
glimpse(Prokopack2)

#reshape to wide
library(reshape)
names(Prokopack2) <- tolower(names(Prokopack2))
names(Prokopack2)[6] <- "site" 
glimpse(Prokopack2)
Prokopack2wide <- melt(Prokopack2, c("date", "site", "species", "indoor"), c("fed","unfed", "male", "gravid","halfgravid"))
glimpse(Prokopack2wide)
trimws(Prokopack2$species, which = c("both", "left", "right"))
Prokopack2$species[Prokopack2$species=="ae.aegypti"] <- "aedes spp"
Prokopack2$species[Prokopack2$species==" Aedea spp"] <- "aedes spp"
Prokopack2$species[Prokopack2$species=="Aedes simpsoni"] <- "aedes spp"
Prokopack2$species[Prokopack2$species=="An.costani"] <- "aedes spp"
Prokopack2$species[Prokopack2$species=="Ae.simpsoni"] <- "aedes spp"
Prokopack2$species[Prokopack2$species=="Aedes sp"] <- "aedes spp"
Prokopack2$species[Prokopack2$species=="aedes"] <- "aedes spp"
Prokopack2$species[Prokopack2$species=="aedes aedes"] <- "aedes spp"
Prokopack2$species[Prokopack2$species=="aedes aegypti"] <- "aedes spp"
Prokopack2$species[Prokopack2$species=="Aedes aegypti"] <- "aedes spp"
Prokopack2$species[Prokopack2$species=="Ae. Simp"] <- "aedes spp"
Prokopack2$species[Prokopack2$species=="Ae.aegypti"] <- "aedes spp"
Prokopack2$species[Prokopack2$species=="Ae. Aegypti"] <- "aedes spp"
Prokopack2$species[Prokopack2$species=="Aedes spp"] <- "aedes spp"

Prokopack2$species[Prokopack2$species=="An.funestus"] <- "anopheles"
Prokopack2$species[Prokopack2$species=="An.gambiae"] <- "anopheles"
Prokopack2$species[Prokopack2$species=="An.gambie"] <- "anopheles"
Prokopack2$species[Prokopack2$species=="An. funestus"] <- "anopheles"
Prokopack2$species[Prokopack2$species=="An. gambiae"] <- "anopheles"
Prokopack2$species[Prokopack2$species=="An. Gambiae"] <- "anopheles"
Prokopack2$species[Prokopack2$species=="Anoph.gambie"] <- "anopheles"

Prokopack2$species[Prokopack2$species=="Culex "] <- "culex"
Prokopack2$species[Prokopack2$species=="Culex"] <- "culex"

Prokopack2$species[Prokopack2$species=="None"] <- "none"
Prokopack2$species[Prokopack2$species=="none "] <- "none"

Prokopack2$species[Prokopack2$species=="0.000000"] <- "none"
Prokopack2$species[Prokopack2$species=="1.000000"] <- "none"
Prokopack2$species[Prokopack2$species=="2.000000"] <- "none"
table(Prokopack2$species)


glimpse(Prokopack2)
Prokopack2wide<-cast(Prokopack2, site + date + indoor ~ species, fun = sum, value  = 'total mosq count')
glimpse(Prokopack2wide)

Aedes_aegypti_Indoor <- Prokopack2wide[ which(Prokopack2wide$indoor ==1), c (1:2, 4) ] 
names(Aedes_aegypti_Indoor)[3] <- "Indoor" 
glimpse(Aedes_aegypti_Indoor)

anopheles_Indoor <- Prokopack2wide[ which(Prokopack2wide$indoor ==1), c (1:2, 5) ] 
names(anopheles_Indoor)[3] <- "Indoor" 
glimpse(anopheles_Indoor)

CulexsppIndoor <-Prokopack2wide[ which(Prokopack2wide$indoor ==1), c (1:2, 6) ] 
names(CulexsppIndoor)[3] <- "Indoor" 
glimpse(CulexsppIndoor)

Aedes_aegypti_outdoor <- Prokopack2wide[ which(Prokopack2wide$indoor ==2), c (1:2, 4) ] 
names(Aedes_aegypti_outdoor)[3] <- "outdoor" 
glimpse(Aedes_aegypti_outdoor)

anopheles_outdoor <- Prokopack2wide[ which(Prokopack2wide$indoor ==2), c (1:2, 5) ] 
names(anopheles_outdoor)[3] <- "outdoor" 
glimpse(anopheles_outdoor)

Culexsppoutdoor <-Prokopack2wide[ which(Prokopack2wide$indoor ==2), c (1:2, 6) ] 
names(Culexsppoutdoor)[3] <- "outdoor" 
glimpse(Culexsppoutdoor)
Indoor_Total<- rbind(Aedes_aegypti_Indoor, CulexsppIndoor, anopheles_Indoor)
Indoor_Total <- aggregate(Indoor_Total$Indoor, by=list(date=Indoor_Total$date, site =Indoor_Total$site), FUN=sum)
names(Indoor_Total)[3] <- "Indoor Total" 
glimpse(Indoor_Total)

outdoor_Total<- rbind(Aedes_aegypti_outdoor, Culexsppoutdoor, anopheles_outdoor)
outdoor_Total <- aggregate(outdoor_Total$outdoor, by=list(date=outdoor_Total$date, site =outdoor_Total$site), FUN=sum)
names(outdoor_Total)[3] <- "Outdoor Total" 
glimpse(outdoor_Total)
#names
names(Aedes_aegypti_Indoor)[3] <- "Aedes spp, Indoor" 
glimpse(Aedes_aegypti_Indoor)
names(CulexsppIndoor)[3] <- "Culex spp., Indoor" 
glimpse(CulexsppIndoor)
names(Aedes_aegypti_outdoor)[3] <- "Aedes spp, Outdoor" 
glimpse(Aedes_aegypti_outdoor)
names(Culexsppoutdoor)[3] <- "Culex spp., Outdoor" 
glimpse(Culexsppoutdoor)
names(anopheles_Indoor)[3] <- "Anopheles spp., Indoor" 
glimpse(anopheles_Indoor)
names(anopheles_outdoor)[3] <- "Anopheles spp., Outdoor" 
glimpse(anopheles_outdoor)

glimpse(c(Aedes_aegypti_outdoor, Culexsppoutdoor, outdoor_Total, Indoor_Total, Aedes_aegypti_Indoor, CulexsppIndoor, anopheles_Indoor, anopheles_outdoor))

# merge two data frames by ID and Country
total <- merge(Aedes_aegypti_outdoor, Culexsppoutdoor, by=c("date" , "site"))
total <- merge(total, outdoor_Total, by=c("date","site"))
total <- merge(total, anopheles_outdoor, by=c("date","site"))
total <- merge(total, Indoor_Total, by=c("date","site"))
total <- merge(total, Aedes_aegypti_Indoor, by=c("date","site"))
total <- merge(total, CulexsppIndoor, by=c("date","site"))
total <- merge(total, anopheles_Indoor, by=c("date","site"))
glimpse(total)
Prokopack2<-total[c(2,1,7, 8, 9, 10, 5, 6, 3, 4)]
glimpse(Prokopack2)
# These variable names may need to be updated as more data is collected
names(Prokopack2)[1] <- "Site"; 
names(Prokopack2)[2] <- "Date"
names(Prokopack2)[3] <- "Indoor Total"
names(Prokopack2)[4] <- "Aedes spp, Indoor"
names(Prokopack2)[5] <- "Culex spp., Indoor"
names(Prokopack2)[6] <- "Anopheles spp., Indoor"

names(Prokopack2)[7] <- "Outdoor Total"
names(Prokopack2)[8] <- "Anopheles spp., Outdoor"
names(Prokopack2)[9] <- "Aedes spp, Outdoor"
names(Prokopack2)[10] <- "Culex spp., Outdoor"

glimpse(Prokopack2)
# Removing excess columns and rows
Prokopack2 <- Prokopack2[-1,]
ind <- apply(Prokopack2, 2, function(x) all(is.na(x)))
Prokopack2 <- Prokopack2[,!ind]
#Prokopack2 <- Prokopack2[(-which(is.na(Prokopack2$Date))),]
glimpse(Prokopack2)

# Adjusting dates
Prokopack2$Date <- as.yearmon(as.Date(as.POSIXct(Prokopack2$Date), origin = "1900-01-01"))

# Taking care of NA's
Prokopack2[is.na(Prokopack2)] <- 0

# Double checking everything is processed correctly
head(Prokopack2)

# Separation into site specific data sets
Prokopack2$Site[Prokopack2$Site=="milalani"] <- "Msambweni"
Prokopack2$Site[Prokopack2$Site=="nganja"] <- "Msambweni"
Prokopack2$Site[Prokopack2$Site=="Milalani"] <- "Msambweni"
Prokopack2$Site[Prokopack2$Site=="Nganja"] <- "Msambweni"

Prokopack2$Site[Prokopack2$Site=="Diani A"] <- "Diani"
Prokopack2$Site[Prokopack2$Site=="Diani B"] <- "Diani"
Prokopack2$Site[Prokopack2$Site=="DianiA"] <- "Diani"
Prokopack2$Site[Prokopack2$Site=="DianiB"] <- "Diani"
Prokopack2$Site[Prokopack2$Site=="Ukunda"] <- "ukunda"

table(Prokopack2$Site)

ProkopackM <- Prokopack2[which(Prokopack2[,1] == "Msambweni"),]
glimpse(ProkopackM)
ProkopackU <- Prokopack2[which(Prokopack2[,1] == "ukunda"),]
glimpse(ProkopackU)

# Double checking everything was processed correctly
head(Prokopack1)
head(Prokopack2)

# Separation into site specific data sets
table(Prokopack2$Site)
table(Prokopack1$Site)

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
glimpse(SentinelTrap1)
#aedes
SentinelTrap1_aedes<-SentinelTrap1[c(1,5, 9:13)]
glimpse(SentinelTrap1_aedes)
SentinelTrap1_aedes$measure <-rowSums(SentinelTrap1_aedes[3:7])
SentinelTrap1_aedes$species <-"aedes spp"
SentinelTrap1_aedes<-SentinelTrap1_aedes[c(1,2, 8, 9)]
head(SentinelTrap1_aedes)

#culex
SentinelTrap1_culex<-SentinelTrap1[c(1,5, 24:28)]
glimpse(SentinelTrap1_culex)
SentinelTrap1_culex$measure <-rowSums(SentinelTrap1_culex[3:7])
SentinelTrap1_culex$species <-"culex spp"
SentinelTrap1_culex<-SentinelTrap1_culex[c(1,2, 8, 9)]
head(SentinelTrap1_culex)

#anopheles
SentinelTrap1_anopheles<-SentinelTrap1[c(1,5, 14:23)]
glimpse(SentinelTrap1_anopheles)
SentinelTrap1_anopheles$measure <-rowSums(SentinelTrap1_anopheles[3:12])
SentinelTrap1_anopheles$species <-"an spp"
SentinelTrap1_anopheles<-SentinelTrap1_anopheles[c(1,2, 13:14)]
head(SentinelTrap1_anopheles)

#toxo
SentinelTrap1_toxo<-SentinelTrap1[c(1,5, 29:33)]
glimpse(SentinelTrap1_toxo)
SentinelTrap1_toxo$measure <-rowSums(SentinelTrap1_toxo[3:7])
SentinelTrap1_toxo$species <-"toxo spp"
SentinelTrap1_toxo<-SentinelTrap1_toxo[c(1,2, 8:9)]
head(SentinelTrap1_toxo)

SentinelTrap1long<-rbind.fill(SentinelTrap1_toxo, SentinelTrap1_aedes, SentinelTrap1_anopheles, SentinelTrap1_culex)
glimpse(SentinelTrap1long)
table(SentinelTrap1long$species, SentinelTrap1long$measure)
names(SentinelTrap1long)[1] <- "date"
names(SentinelTrap1long)[2] <- "site";

SentinelTrap1wide <- melt(SentinelTrap1long, c("date", "site", "species"), "measure")
SentinelTrap1wide<-cast(SentinelTrap1wide, site + date ~ species, fun = sum, value  = 'measure')
glimpse(SentinelTrap1wide)
SentinelTrap1<-SentinelTrap1wide
names(SentinelTrap1)[1] <- "Site";
names(SentinelTrap1)[2] <- "Date"
names(SentinelTrap1)[3] <- "Aedes spp"
names(SentinelTrap1)[4] <- "Anopheles spp"
names(SentinelTrap1)[5] <- "Culex spp."
names(SentinelTrap1)[6] <- "Toxorhynchites"
glimpse(SentinelTrap1)
# Removing excess columns and rows
ind <- apply(SentinelTrap1, 2, function(x) all(is.na(x)))
SentinelTrap1 <- SentinelTrap1[,!ind]

# Adjusting and including site names as well as variable names
# These variable names may need to be updated as more data is collected
glimpse(SentinelTrap2)
names(SentinelTrap2)[1] <- "Date"
names(SentinelTrap2)[5] <- "Site"; 
SentinelTrap2$measure <-rowSums(SentinelTrap2[12:16])
SentinelTrap2 <- melt(SentinelTrap2, c("Date", "Site", "Species"), "measure")
glimpse(SentinelTrap2)
table(SentinelTrap2$Species)
SentinelTrap2$Species[SentinelTrap2$Species=="Ae.Simpsoni"] <- "aedes spp"
SentinelTrap2$Species[SentinelTrap2$Species=="Aedes simpsoni"] <- "aedes spp"
SentinelTrap2$Species[SentinelTrap2$Species=="An.gambie"] <- "anopheles"
SentinelTrap2$Species[SentinelTrap2$Species=="An.funestus"] <- "anopheles"
SentinelTrap2$Species[SentinelTrap2$Species=="Ae. Aegypti"] <- "aedes spp"
SentinelTrap2$Species[SentinelTrap2$Species=="Ae. Simpsoni"] <- "aedes spp"
SentinelTrap2$Species[SentinelTrap2$Species=="Ae.aegypti"] <- "aedes spp"
SentinelTrap2$Species[SentinelTrap2$Species=="Aedes aegypti"] <- "aedes spp"
SentinelTrap2$Species[SentinelTrap2$Species=="Aedes sp."] <- "aedes spp"
SentinelTrap2$Species[SentinelTrap2$Species=="An. funestus"] <- "anopheles"
SentinelTrap2$Species[SentinelTrap2$Species=="An. Funestus"] <- "anopheles"
SentinelTrap2$Species[SentinelTrap2$Species=="An.funestus"] <- "anopheles"
SentinelTrap2$Species[SentinelTrap2$Species=="An.gambiae"] <- "anopheles"
SentinelTrap2$Species[SentinelTrap2$Species=="An.gambie "] <- "anopheles"
SentinelTrap2$Species[SentinelTrap2$Species=="Culex"] <- "culex"
SentinelTrap2$Species[SentinelTrap2$Species=="Mansoni"] <- "mansoni"
SentinelTrap2$Species[SentinelTrap2$Species=="none"] <- "none"
SentinelTrap2$Species[SentinelTrap2$Species=="None"] <- "none"
SentinelTrap2$Species[SentinelTrap2$Species=="Not done"] <- "99"
table(SentinelTrap2$Species)

SentinelTrap2wide<-cast(SentinelTrap2, Site + Date ~ Species, fun = sum, value  = 'measure')
glimpse(SentinelTrap2wide)
SentinelTrap2<-SentinelTrap2wide

# Removing excess columns and rows
i1 <- apply(SentinelTrap2,1,function(x) all(is.na(x)))
SentinelTrap2 <- SentinelTrap2[!i1,]
SentinelTrap2 <- SentinelTrap2[-dim(SentinelTrap2)[1],] 
i2 <- sapply(SentinelTrap2,function(x) all(is.na(x)))
SentinelTrap2 <- SentinelTrap2[,!i2]
SentinelTrap2 <- SentinelTrap2[, -dim(SentinelTrap2)[2]] 

# Adjusting dates
SentinelTrap1$Date <- as.yearmon(SentinelTrap1$Date)
SentinelTrap2$Date <- as.yearmon(as.Date((SentinelTrap2$Date), origin = "1900-01-01"))
glimpse(SentinelTrap2)

SentinelTrap2$Site[SentinelTrap2$Site=="nganja"] <- "Msambweni"
SentinelTrap2$Site[SentinelTrap2$Site=="Nganja"] <- "Msambweni"
SentinelTrap2$Site[SentinelTrap2$Site=="Milalani"] <- "Msambweni"
SentinelTrap2$Site[SentinelTrap2$Site=="Diani B"] <- "Ukunda"
SentinelTrap2$Site[SentinelTrap2$Site=="Diani A"] <- "Ukunda"
table(SentinelTrap2$Site)

# Separation into site specific data sets
SentinelTrapC <- SentinelTrap1[which(SentinelTrap1$Site == "Chulaimbo"),]
SentinelTrapK <- SentinelTrap1[-which(SentinelTrap1$Site == "Chulaimbo"),]
SentinelTrapM <- SentinelTrap2[which(SentinelTrap2$Site == "Msambweni"),]
SentinelTrapU <- SentinelTrap2[-which(SentinelTrap2$Site == "Msambweni"),]
glimpse(c(SentinelTrapU, SentinelTrapM, SentinelTrapK, SentinelTrapC))

# Landing Catches
# Adjusting and including site names as well as variable names
for(i in 1:(dim(LandingCatches1)[1])){
  if(is.na(LandingCatches1[i,1])){
    LandingCatches1[i,1] = LandingCatches1[(i - 1),1]
  }
}
glimpse(LandingCatches1)
LandingCatches1[is.na(LandingCatches1)] <- 0
LandingCatches1$Aedes <- rowSums(LandingCatches1[11:27])
LandingCatches1$anopheles <- rowSums(LandingCatches1[28:61])
LandingCatches1$culex <- rowSums(LandingCatches1[62:78])
LandingCatches1_long<-LandingCatches1[c(1, 5, 9, 79:81)]
names(LandingCatches1_long)[1] <- "date"
names(LandingCatches1_long)[2] <- "site" 
names(LandingCatches1_long)[3] <- "indoor"
names(LandingCatches1_long)[4] <- "aedes" 
names(LandingCatches1_long)[5] <- "an" 
names(LandingCatches1_long)[6] <- "culex" 
glimpse(LandingCatches1_long)

table(LandingCatches1_long$indoor)
indoor<-LandingCatches1_long[which(LandingCatches1_long[3]=="Inside"), ]
outdoor<-LandingCatches1_long[which(LandingCatches1_long[3]=="outside"), ]

names(outdoor)[4] <- "aedes.outdoor"
names(outdoor)[5] <- "anopheles.outdoor"
names(outdoor)[6] <- "culex.outdoor"
outdoor<-outdoor[c(1,2, 4:6)]

names(indoor)[4] <- "aedes.indoor"
names(indoor)[5] <- "anopheles.indoor"
names(indoor)[6] <- "culex.indoor"
indoor<-indoor[c(1,2, 4:6)]
LandingCatches1 <- merge(indoor, outdoor, by=c("date","site"), all = TRUE)
LandingCatches1$aedes.total<-rowSums(LandingCatches1$aedes.indoor, LandingCatches1$ae)
LandingCatches1 <- LandingCatches1[c(1, 2, 3, 6, 4, 7, 5, 8)]
LandingCatches1$aedes.total <- rowSums(LandingCatches1[3:4])

LandingCatches1$culex.total <- rowSums(LandingCatches1[7:8])
LandingCatches1$anopheles.total <- rowSums(LandingCatches1[5:6])
glimpse(LandingCatches1)

# These variable names may need to be updated as more data is collected
names(LandingCatches1)[1] <- "date"
names(LandingCatches1)[2] <- "site";
names(LandingCatches1)[3] <- "Aedes spp, Inside"
names(LandingCatches1)[4] <- "Aedes spp, Outside"
names(LandingCatches1)[5] <- "Anopheles spp, Inside"
names(LandingCatches1)[6] <- "Anopheles spp, Outside"
names(LandingCatches1)[7] <- "Culex spp., Inside"
names(LandingCatches1)[8] <- "Culex spp., Outside"
names(LandingCatches1)[9] <- "Aedes spp, Total"
ames(LandingCatches1)[10] <- "Culex spp., Total"
names(LandingCatches1)[11] <- "Anopheles spp, Total"

# Removing excess rows and columns
LandingCatches1 <- LandingCatches1[-1,]
ind <- apply(LandingCatches1, 2, function(x) all(is.na(x)))
LandingCatches1 <- LandingCatches1[,!ind]

#get the data in the correct format
LandingCatches2[is.na(LandingCatches2)] <- 0
glimpse(LandingCatches2)
LandingCatches2$measure <-rowSums(LandingCatches2[13:17])
LandingCatches2wide <- melt(LandingCatches2, c("Date", "Site", "Species", "Location"), "measure")
glimpse(LandingCatches2wide)

LandingCatches2$Species <- tolower(LandingCatches2$Species)

LandingCatches2wide<-cast(LandingCatches2wide, Site + Date~ Species + Location, fun = sum, value  = 'measure')
LandingCatches2wide$aedes.indoor <- rowSums(LandingCatches2wide[c(3, 5, 7 , 9 , 12, 15, 17, 19)])
LandingCatches2wide$aedes.outdoor <- rowSums(LandingCatches2wide[c(4, 6, 8 , 10, 11, 13, 14, 18, 20, 21)])
LandingCatches2wide$aedes.total <- rowSums(LandingCatches2wide[c(51:52)])
glimpse(LandingCatches2wide)
LandingCatches2<-LandingCatches2wide[c(1:2, 51:53)]
# Adjusting and including site names as well as variable names
# These variable names may need to be updated as more data is collected
glimpse(LandingCatches2)
# Removing excess rows and columns
i1 <- apply(LandingCatches2,1,function(x) all(is.na(x)))
LandingCatches2 <- LandingCatches2[!i1,]
LandingCatches2 <- LandingCatches2[-dim(LandingCatches2)[1],] 
i2 <- sapply(LandingCatches2,function(x) all(is.na(x)))
LandingCatches2 <- LandingCatches2[,!i2]
LandingCatches2 <- LandingCatches2[, -dim(LandingCatches2)[2]] 
LandingCatches2 <- LandingCatches2[-1,]

# Adjusting dates (Date format for LandingCatches2 was weird)
LandingCatches1$date<-as.yearmon(as.Date(as.character(LandingCatches1$date)))
LandingCatches2$Date <- as.yearmon(LandingCatches2$Date, origin = "1900-01-01")
glimpse(LandingCatches1)

# Separation into site specific data sets
table(LandingCatches1$site)
table(LandingCatches2$Site)
glimpse(LandingCatches2)
glimpse(LandingCatches1)

LandingCatchesC <- LandingCatches1[which(LandingCatches1[,2] == "Chulaimbo"),]
LandingCatchesK <- LandingCatches1[-which(LandingCatches1[,2] == "Chulaimbo"),]
LandingCatchesM <- LandingCatches2[which(LandingCatches2[,1] == "Msambweni"),]
LandingCatchesU <- LandingCatches2[-which(LandingCatches2[,1] == "Msambweni"),]
glimpse(LandingCatchesU)
glimpse(LandingCatchesM)
glimpse(LandingCatchesC)
glimpse(LandingCatchesK)

# Save the now cleaned data sets as individual Excel files, with sheets for the different sites
setwd("C:/Users/amykr/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/built environement hcc/vector and climate")
#setwd("C:/Users/amykr/Box Sync/DENV CHIKV project/Vector Data/monthly summaries from both sites")
#create montly summary of the vector data for each site and trap type
glimpse(OvitrapC)
OvitrapC$'AedessppIndoor'<-as.double(OvitrapC$'Aedes spp, Indoor')
OvitrapC$'AedessppOutdoor'<-as.double(OvitrapC$'Aedes spp, Outdoor')
glimpse(OvitrapC)
MonthlyOvitrapC <- ddply(OvitrapC, ~OvitrapC$Date, summarise, 
                         Ttl_Aedes.spp.Indoor = sum(AedessppIndoor),
                         ttl_Aedes_spp_Outdoor = sum(AedessppOutdoor)) 
glimpse(MonthlyOvitrapC)

glimpse(OvitrapK)
OvitrapK$'AedessppIndoor'<-as.double(OvitrapK$'Aedes spp, Indoor')
OvitrapK$'AedessppOutdoor'<-as.double(OvitrapK$'Aedes spp, Outdoor')
glimpse(OvitrapK)
MonthlyOvitrapK <- ddply(OvitrapK, ~OvitrapK$Date, summarise, 
                         Ttl_Aedes.spp.Indoor = sum(AedessppIndoor),
                         ttl_Aedes_spp_Outdoor = sum(AedessppOutdoor)) 

glimpse(OvitrapM)
OvitrapM$'AedessppIndoor'<-as.double(OvitrapM$'Aedes spp, Indoor')
OvitrapM$'AedessppOutdoor'<-as.double(OvitrapM$'Aedes spp, Outdoor')
glimpse(OvitrapM)
MonthlyOvitrapM <- ddply(OvitrapM, ~OvitrapM$Date, summarise, 
                         Ttl_Aedes.spp.Indoor = sum(AedessppIndoor),
                         ttl_Aedes_spp_Outdoor = sum(AedessppOutdoor)) 
glimpse(OvitrapU)
OvitrapU$'AedessppIndoor'<-as.double(OvitrapU$'Aedes spp, Indoor')
OvitrapU$'AedessppOutdoor'<-as.double(OvitrapU$'Aedes spp, Outdoor')
glimpse(OvitrapU)
MonthlyOvitrapU <- ddply(OvitrapU, ~OvitrapU$Date, summarise, 
                         Ttl_Aedes.spp.Indoor = sum(AedessppIndoor),
                         ttl_Aedes_spp_Outdoor = sum(AedessppOutdoor)) 

f <- "OvitrapMonthlySummaries.xls"
write.xlsx(as.data.frame(MonthlyOvitrapC), f, sheetName = "Chulaimbo", col.names = TRUE,
           row.names = FALSE, append = FALSE, showNA = TRUE)
write.xlsx(as.data.frame(MonthlyOvitrapK), f, sheetName = "Kisumu", col.names = TRUE,
           row.names = FALSE, append = TRUE, showNA = TRUE)
write.xlsx(as.data.frame(MonthlyOvitrapM), f, sheetName = "Msambweni", col.names = TRUE,
           row.names = FALSE, append = TRUE, showNA = TRUE)
write.xlsx(as.data.frame(MonthlyOvitrapU), f, sheetName = "Ukunda", col.names = TRUE,
           row.names = FALSE, append = TRUE, showNA = TRUE)


#create montly summary of the vector data for each site and trap type
glimpse(LarvalC)
LarvalC$'AedessppIndoor'<-as.double(LarvalC$'Aedes spp, Indoor')
LarvalC$'AedessppOutdoor'<-as.double(LarvalC$'Aedes spp, Outdoor')
glimpse(LarvalC)
MonthlyLarvalC <- ddply(LarvalC, ~Date, summarise, 
                        Ttl_Aedes.spp.Indoor = sum(AedessppIndoor),
                        ttl_Aedes_spp_Outdoor = sum(AedessppOutdoor)) 
glimpse(LarvalK)
LarvalK$'AedessppIndoor'<-as.double(LarvalK$'Aedes spp, Indoor')
LarvalK$'AedessppOutdoor'<-as.double(LarvalK$'Aedes spp, Outdoor')
MonthlyLarvalK <- ddply(LarvalK, ~Date, summarise, 
                        Ttl_Aedes.spp.Indoor = sum(AedessppIndoor),
                        ttl_Aedes_spp_Outdoor = sum(AedessppOutdoor)) 

glimpse(LarvalM)
LarvalM$'AedessppIndoor'<-as.double(LarvalM$'Aedes spp, Indoor')
LarvalM$'AedessppOutdoor'<-as.double(LarvalM$'Aedes spp, Outdoor')
glimpse(LarvalM)
MonthlyLarvalM <- ddply(LarvalM, ~Date, summarise, 
                        Ttl_Aedes.spp.Indoor = sum(AedessppIndoor),
                        ttl_Aedes_spp_Outdoor = sum(AedessppOutdoor)) 

glimpse(LarvalU)
LarvalU$'AedessppIndoor'<-as.double(LarvalU$'Aedes spp, Indoor')
LarvalU$'AedessppOutdoor'<-as.double(LarvalU$'Aedes spp, Outdoor')
glimpse(LarvalU)
MonthlyLarvalU <- ddply(LarvalU, ~Date, summarise, 
                        Ttl_Aedes.spp.Indoor = sum(AedessppIndoor),
                        ttl_Aedes_spp_Outdoor = sum(AedessppOutdoor)) 

f <- "LarvalMonthlySummaries.xls"
write.xlsx(as.data.frame(MonthlyLarvalC), f, sheetName = "Chulaimbo", col.names = TRUE,
           row.names = FALSE, append = FALSE, showNA = TRUE)
write.xlsx(as.data.frame(MonthlyLarvalK), f, sheetName = "Kisumu", col.names = TRUE,
           row.names = FALSE, append = TRUE, showNA = TRUE)
write.xlsx(as.data.frame(MonthlyLarvalM), f, sheetName = "Msambweni", col.names = TRUE,
           row.names = FALSE, append = TRUE, showNA = TRUE)
write.xlsx(as.data.frame(MonthlyLarvalU), f, sheetName = "Ukunda", col.names = TRUE,
           row.names = FALSE, append = TRUE, showNA = TRUE)

#create montly summary of the vector data for each site and trap type
glimpse(PupaeC)
PupaeC$'AedessppIndoor'<-as.double(PupaeC$'aedes indoor')
PupaeC$'AedessppOutdoor'<-as.double(PupaeC$'aedes outdoor')
MonthlyPupaeC <- ddply(PupaeC, ~PupaeC$Date, summarise, 
                       Ttl_Aedes.spp.Indoor = sum(AedessppIndoor),
                       ttl_Aedes_spp_Outdoor = sum(AedessppOutdoor)) 
glimpse(PupaeK)
table(PupaeK$'aedes outdoor')
PupaeK$'AedessppIndoor'<-as.double(PupaeK$'aedes indoor')
PupaeK$'AedessppOutdoor'<-as.double(PupaeK$'aedes outdoor')
glimpse(PupaeK)
MonthlyPupaeK <- ddply(PupaeK, ~PupaeK$Date, summarise, 
                       Ttl_Aedes.spp.Indoor = sum(AedessppIndoor),
                       ttl_Aedes_spp_Outdoor = sum(AedessppOutdoor)) 

glimpse(PupaeM)
PupaeM$'AedessppIndoor'<-as.double(PupaeM$'aedes indoor')
PupaeM$'AedessppOutdoor'<-as.double(PupaeM$'aedes outdoor')
glimpse(PupaeM)
MonthlyPupaeM <- ddply(PupaeM, ~PupaeM$Date, summarise, 
                       Ttl_Aedes.spp.Indoor = sum(AedessppIndoor),
                       ttl_Aedes_spp_Outdoor = sum(AedessppOutdoor)) 

glimpse(PupaeU)
PupaeU$'AedessppIndoor'<-as.double(PupaeU$'aedes indoor')
PupaeU$'AedessppOutdoor'<-as.double(PupaeU$'aedes outdoor')
glimpse(PupaeU)
MonthlyPupaeU <- ddply(PupaeU, ~PupaeU$Date, summarise, 
                       Ttl_Aedes.spp.Indoor = sum(AedessppIndoor),
                       ttl_Aedes_spp_Outdoor = sum(AedessppOutdoor)) 

f <- "PupaeMonthlySummaries.xls"
write.xlsx(as.data.frame(MonthlyPupaeC), f, sheetName = "Chulaimbo", col.names = TRUE,
           row.names = FALSE, append = FALSE, showNA = TRUE)
write.xlsx(as.data.frame(MonthlyPupaeK), f, sheetName = "Kisumu", col.names = TRUE,
           row.names = FALSE, append = TRUE, showNA = TRUE)
write.xlsx(as.data.frame(MonthlyPupaeM), f, sheetName = "Msambweni", col.names = TRUE,
           row.names = FALSE, append = TRUE, showNA = TRUE)
write.xlsx(as.data.frame(MonthlyPupaeU), f, sheetName = "Ukunda", col.names = TRUE,
           row.names = FALSE, append = TRUE, showNA = TRUE)

#create montly summary of the vector data for each site and trap type
glimpse(ProkopackC)
ProkopackC$'AedessppIndoor'<-as.double(ProkopackC$'aedes indoor')
ProkopackC$'AedessppOutdoor'<-as.double(ProkopackC$'aedes outdoor')
glimpse(ProkopackC)
MonthlyProkopackC <- ddply(ProkopackC, ~ProkopackC$date, summarise, 
                           Ttl_Aedes.spp.Indoor = sum(AedessppIndoor),
                           ttl_Aedes_spp_Outdoor = sum(AedessppOutdoor)) 
glimpse(ProkopackK)
ProkopackK$'AedessppIndoor'<-as.double(ProkopackK$'aedes indoor')
ProkopackK$'AedessppOutdoor'<-as.double(ProkopackK$'aedes outdoor')
glimpse(ProkopackK)
MonthlyProkopackK <- ddply(ProkopackK, ~ProkopackK$date, summarise, 
                           Ttl_Aedes.spp.Indoor = sum(AedessppIndoor),
                           ttl_Aedes_spp_Outdoor = sum(AedessppOutdoor)) 

glimpse(ProkopackM)
ProkopackM$'AedessppIndoor'<-as.double(ProkopackM$'Aedes spp, Indoor')
ProkopackM$'AedessppOutdoor'<-as.double(ProkopackM$'Aedes spp, Outdoor')
glimpse(ProkopackM)
MonthlyProkopackM <- ddply(ProkopackM, ~ProkopackM$Date, summarise, 
                           Ttl_Aedes.spp.Indoor = sum(AedessppIndoor),
                           ttl_Aedes_spp_Outdoor = sum(AedessppOutdoor)) 

glimpse(ProkopackU)
ProkopackU$AedessppIndoor<-as.double(ProkopackU$'Aedes spp, Indoor')
ProkopackU$AedessppOutdoor<-as.double(ProkopackU$'Aedes spp, Outdoor')
glimpse(ProkopackU)
MonthlyProkopackU <- ddply(ProkopackU, ~ProkopackU$Date, summarise, 
                           Ttl_Aedes.spp.Indoor = sum(AedessppIndoor),
                           ttl_Aedes_spp_Outdoor = sum(AedessppOutdoor)) 

setwd("C:/Users/amykr/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/built environement hcc/vector and climate")
f <- "ProkopackMonthlySummaries.xls"
write.xlsx(as.data.frame(MonthlyProkopackC), f, sheetName = "Chulaimbo", col.names = TRUE,
           row.names = FALSE, append = FALSE, showNA = TRUE)
write.xlsx(as.data.frame(MonthlyProkopackK), f, sheetName = "Kisumu", col.names = TRUE,
           row.names = FALSE, append = TRUE, showNA = TRUE)
write.xlsx(as.data.frame(MonthlyProkopackM), f, sheetName = "Msambweni", col.names = TRUE,
           row.names = FALSE, append = TRUE, showNA = TRUE)
write.xlsx(as.data.frame(MonthlyProkopackU), f, sheetName = "Ukunda", col.names = TRUE,
           row.names = FALSE, append = TRUE, showNA = TRUE)



#create montly summary of the vector data for each site and trap type
glimpse(SentinelTrapC)
SentinelTrapC$'aedesspp'<-as.double(SentinelTrapC$'Aedes spp')
glimpse(SentinelTrapC)
MonthlySentinelTrapC <- ddply(SentinelTrapC, ~SentinelTrapC$Date, summarise, 
                              Ttl_Aedes.spp = sum(aedesspp))

glimpse(SentinelTrapK)
SentinelTrapK$'aedesspp'<-as.double(SentinelTrapK$'Aedes spp')
glimpse(SentinelTrapK)
MonthlySentinelTrapK <- ddply(SentinelTrapK, ~SentinelTrapK$Date, summarise, 
                              Ttl_Aedes.spp = sum(aedesspp))


glimpse(SentinelTrapM)
SentinelTrapM$'aedesspp'<-as.double(SentinelTrapM$'aedes spp')
glimpse(SentinelTrapM)
MonthlySentinelTrapM <- ddply(SentinelTrapM, ~SentinelTrapM$Date, summarise, Ttl_Aedes.spp = sum(aedesspp))


glimpse(SentinelTrapU)
SentinelTrapU$'aedesspp'<-as.double(SentinelTrapU$'aedes spp')
glimpse(SentinelTrapU)
MonthlySentinelTrapU <- ddply(SentinelTrapU, ~SentinelTrapU$Date, summarise, Ttl_Aedes.spp = sum(aedesspp))
 

f <- "SentinelTrapMonthlySummaries.xls"
write.xlsx(as.data.frame(MonthlySentinelTrapC), f, sheetName = "Chulaimbo", col.names = TRUE,
           row.names = FALSE, append = FALSE, showNA = TRUE)
write.xlsx(as.data.frame(MonthlySentinelTrapK), f, sheetName = "Kisumu", col.names = TRUE,
           row.names = FALSE, append = TRUE, showNA = TRUE)
write.xlsx(as.data.frame(MonthlySentinelTrapM), f, sheetName = "Msambweni", col.names = TRUE,
           row.names = FALSE, append = TRUE, showNA = TRUE)
write.xlsx(as.data.frame(MonthlySentinelTrapU), f, sheetName = "Ukunda", col.names = TRUE,
           row.names = FALSE, append = TRUE, showNA = TRUE)

#create montly summary of the vector data for each site and trap type
glimpse(LandingCatchesC)
LandingCatchesC$'AedessppInside'<-as.double(LandingCatchesC$'Aedes spp, Inside')
LandingCatchesC$'AedessppOutside'<-as.double(LandingCatchesC$'Aedes spp, Outside')
glimpse(MonthlyLandingCatchesC)
MonthlyLandingCatchesC <- ddply(LandingCatchesC, ~LandingCatchesC$date, summarise, 
                                Ttl_Aedes.spp.Indoor = sum(AedessppInside),
                                ttl_Aedes_spp_Outdoor = sum(AedessppOutside)) 

glimpse(LandingCatchesK)
LandingCatchesK$'AedessppInside'<-as.double(LandingCatchesK$'Aedes spp, Inside')
LandingCatchesK$'AedessppOutside'<-as.double(LandingCatchesK$'Aedes spp, Outside')
MonthlyLandingCatchesK <- ddply(LandingCatchesK, ~LandingCatchesK$date, summarise, 
                                Ttl_Aedes.spp.Indoor = sum(AedessppInside),
                                ttl_Aedes_spp_Outdoor = sum(AedessppOutside)) 

glimpse(LandingCatchesM)
LandingCatchesM$'aedes.indoor'<-as.double(LandingCatchesM$'aedes.indoor')
LandingCatchesM$'aedes.outdoor'<-as.double(LandingCatchesM$'aedes.outdoor')
glimpse(LandingCatchesM)
MonthlyLandingCatchesM <- ddply(LandingCatchesM, ~LandingCatchesM$Date, summarise, 
                                Ttl_Aedes.spp.Indoor = sum(aedes.indoor),
                                ttl_Aedes_spp_Outdoor = sum(aedes.outdoor)) 

glimpse(LandingCatchesU)
LandingCatchesU$'aedes.indoor'<-as.double(LandingCatchesU$'aedes.indoor')
LandingCatchesU$'Aedes spp, Outside'<-as.double(LandingCatchesU$'aedes.outdoor')
glimpse(LandingCatchesU)
MonthlyLandingCatchesU <- ddply(LandingCatchesU, ~LandingCatchesU$Date, 
                                summarise, Ttl_Aedes.spp.Indoor = sum(aedes.indoor),
                                ttl_Aedes_spp_Outdoor = sum(aedes.outdoor)) 

f <- "LandingCatchesMonthlySummaries.xls"
write.xlsx(as.data.frame(MonthlyLandingCatchesC), f, sheetName = "Chulaimbo", col.names = TRUE,
           row.names = FALSE, append = FALSE, showNA = TRUE)
write.xlsx(as.data.frame(MonthlyLandingCatchesK), f, sheetName = "Kisumu", col.names = TRUE,
           row.names = FALSE, append = TRUE, showNA = TRUE)
write.xlsx(as.data.frame(MonthlyLandingCatchesM), f, sheetName = "Msambweni", col.names = TRUE,
           row.names = FALSE, append = TRUE, showNA = TRUE)
write.xlsx(as.data.frame(MonthlyLandingCatchesU), f, sheetName = "Ukunda", col.names = TRUE,
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
#setwd("C:/Users/amykr/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/built environement hcc")
setwd("C:/Users/amykr/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/built environement hcc/vector and climate")
f <- "DENVData.xls"
write.xlsx(as.data.frame(DENV), f, sheetName = "Chulaimbo", col.names = TRUE,
           row.names = FALSE, append = FALSE, showNA = TRUE)
