## Kenya Data Visualization ~ Dan Weikel (dpweikel@umich.edu/daniel.p.weikel@gmail.com)

# Just a quick script that will run through and create plots to visualize some of the 
# mosquito abundance, climate, and DENV data for a single site. In order to get multiple 
# plots for different sites just adjust the data input. 

# The script focuses on Chulaimbo, as that is the initial outbreak site.
# Given changes to the excel input and adjusting the variables, it can be used
# to generate similar output for the other sites.

# The following variables control the red bars included in the plots. If you wish to
# highlight a different snapshot in time, you need to change them accordingly.
A <- as.yearmon("2014-6") 
B <- as.yearmon("2014-12") 

########################
# Packages :
library(readxl) # Excel reading
library(plyr) # Data frame manipulation
library(dplyr)
library(xts) # Time series options
library(zoo)
library(ggplot2)

# Data
setwd("C:/Users/amykr/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/built environement hcc")

Climate <- read_excel("ChulaimboMonthlyClimateData.xls", sheet = 1)

  # Just change the sheet number to get a different site's data 
Ovitrap <- read_excel("OvitrapMonthlySummaries.xls", sheet = 1)
Larval <- read_excel("LarvalMonthlySummaries.xls", sheet = 1)
Pupae <- read_excel("PupaeMonthlySummaries.xls", sheet = 1)
Proko <- read_excel("ProkopackMonthlySummaries.xls", sheet = 1)
ST <- read_excel("SentinelTrapMonthlySummaries.xls", sheet = 1)
LC <- read_excel("LandingCatchesMonthlySummaries.xls", sheet = 1) 

DENV <- read_excel("DENVData.xls", sheet = 1)

# Making datasets that make sense, make sure to choose the right variables
head(Ovitrap)
head(Larval)
head(Pupae)
head(Proko)
head(ST)
head(LC)

# These column selections assume certain variable placement, if more species are found
# please adjust using the information from the above head statements.
Ovitrap <- Ovitrap[,c(2,6)]; names(Ovitrap)[2] <- "Ovitrap"
Larval <- Larval[, c(2,6)]; names(Larval)[2] <- "Larval"
Pupae <- Pupae[, c(2,3)]; names(Pupae)[2] <- "Pupae"
Proko <- Proko[, c(2,7)]; names(Proko)[2] <- "Proko" 
ST <- ST[, c(2,3)]; names(ST)[2] <- "ST"

# Ignoring LC since there's quite a dearth of data comparatively

# Creating a large dataset on mosquito abundance to have an equal time frame
Abundance <- merge(Ovitrap, Larval, by = "Date")
Abundance <- merge(Abundance, Pupae, by = "Date")
Abundance <- merge(Abundance, Proko, by = "Date" )
Abundance <- merge(Abundance, ST, by = "Date")

# Merged Abundance data has time issues, this reorders the data based on time.
# Otherwise you end up with time traveling mosquito populations that create plots
# that look like a poor attempt at abstract art.
Abundance$Date <- as.Date(as.yearmon(Abundance$Date))
Abundance <- Abundance[order(as.Date(Abundance$Date, format="%Y-%m-%d")),]

# Adjusting Date information
Climate$Month <- as.Date(as.yearmon(Climate$Month))
DENV$Date <- as.Date(as.yearmon(DENV$Date))

# Plots prep, the following creates a sequence that allows us to make the 
# gray dotted lines. The sequence should adjust based on the DENV data available, 
# which is the main focus in terms of the time frame.
x <- as.yearmon(min(DENV$Date)); y <- as.yearmon(max(DENV$Date))
months <- 12*(y - x)
dateSeq <- seq(as.Date("2014-01-01"), by = "month", length.out = months )


# Creating a pdf of all of the plots together
pdf("KenyaOutbreak_VisualizationPlots.pdf", width = 14, height = 6)

# Cases plot
plot(as.yearmon(DENV$Date), DENV$POS, type = "both",
     main = "Kenya Outbreak, DENV Cases in Chulaimbo",
     ylab = "Positive Cases", xlab = "Date")
abline(v = as.yearmon(dateSeq), lty = 3, col = "light gray")
abline(v = A, lty = 1, col = "red")
abline(v = B, lty = 1, col = "red")

# Temp Not Scaled
plot(as.yearmon(Climate$Month), Climate$AvgTemp, type = "l", lwd = 2,  main = "Chulaimbo Temperature Data",
     ylab = expression(paste("Temperature (", degree, "C)")), 
     xlab = "Date", ylim = c(10, 40))
abline(v = as.yearmon(dateSeq), lty = 3, col = "light gray")
lines(as.yearmon(Climate$Month), Climate$AvgMaxTemp, lty = 1, lwd = 2, col = "light blue")
lines(as.yearmon(Climate$Month), Climate$AvgMinTemp, lty = 1, lwd = 2, col = "light green")
lines(as.yearmon(Climate$Month), Climate$OverallMaxTemp, lty = 1, lwd = 2, col = "dark blue")
lines(as.yearmon(Climate$Month), Climate$OverallMinTemp, lty = 1, lwd = 2, col = "dark green")
abline(v = A, lty = 1, col = "red")
abline(v = B, lty = 1, col = "red")
legend(as.yearmon("2015-06-01"), 20, c("OverallMaxTemp", "AvgMaxTemp", "AvgTemp", "AvgMinTemp", "OverallMinTemp"),
       col = c("dark blue", "light blue", "black", "light green", "dark green"), lwd = c(2,2,2,2,2),
       lty = c(1,1,1,1,1), bty = "n")

# RH and DewPt Not Scaled
plot(as.yearmon(Climate$Month), Climate$AvgRH, type = "l", lwd = 2,  main = "Chulaimbo RH and Dew Pt Data",
     ylab = expression(paste("% Humidity / Temperature (", degree, "C)")), 
     xlab = "Date", ylim = c(0, 100))
abline(v = as.yearmon(dateSeq), lty = 3, col = "light gray")
lines(as.yearmon(Climate$Month), Climate$AvgDewPt, type = "l", lwd = 2, col = "dark blue")
abline(v = A, lty = 1, col = "red")
abline(v = B, lty = 1, col = "red")
legend(as.yearmon(as.Date("2015-06-01")), 40, c("AvgRH", "AvgDewPt"),
       col = c("black", "dark blue"), lwd = c(2,2), lty = c(1,1), bty = "n")

# Rainfall 
plot(as.yearmon(Climate$Month), Climate$TtlRainfall, type = "l", lwd = 2, main = "Chulaimbo Rainfall",
     ylab = "Rainfall (cm)", xlab = "Date")
abline(v = as.yearmon(dateSeq), lty = 3, col = "light gray")
abline(v = A, lty = 1, col = "red")
abline(v = B, lty = 1, col = "red")

# Mosquitoes not scaled
plot(as.yearmon(Abundance$Date), Abundance$Ovitrap, type = "l", lwd = 2,
     main = "Chulaimbo Mosquito Abundance",
     ylab = "Mosquito Count", xlab = "Date", ylim = c(0,1500))
abline(v = as.yearmon(dateSeq), lty = 3, col = "light gray")
lines(as.yearmon(Abundance$Date), Abundance$Larval, lty = 1, lwd =2, col = "purple")
lines(as.yearmon(Abundance$Date), Abundance$Pupae, lty = 1, lwd =2, col = "orange")
lines(as.yearmon(Abundance$Date), Abundance$Proko, lty = 1, lwd =2, col = "blue")
lines(as.yearmon(Abundance$Date), Abundance$ST, lty = 1, lwd =2, col = "green")
abline(v = A, lty = 1, col = "red")
abline(v = B, lty = 1, col = "red")
legend(as.yearmon(as.Date("2015-09-01")), 1550, c("Ovitrap", "Larval", "Pupae", "Prokopack", "Sentinel Trap"),
       col = c("black","purple", "orange", "blue", "green"), lwd = c(2,2,2,2,2), lty = c(1,1,1,1,1),
       bty = "n")


## With things scaled

Climate$AvgTemp <- Climate$AvgTemp/max(Climate$AvgTemp)
Climate$AvgMaxTemp <- Climate$AvgMaxTemp/max(Climate$AvgMaxTemp)
Climate$AvgMinTemp <- Climate$AvgMinTemp/max(Climate$AvgMinTemp)
Climate$OverallMaxTemp <- Climate$OverallMaxTemp/max(Climate$OverallMaxTemp)
Climate$OverallMinTemp <- Climate$OverallMinTemp/max(Climate$OverallMinTemp)
Climate$AvgRH <- Climate$AvgRH/max(Climate$AvgRH)
Climate$AvgDewPt <- Climate$AvgDewPt/max(Climate$AvgDewPt)
Climate$TtlRainfall <- Climate$TtlRainfall/max(Climate$TtlRainfall)

Abundance$Ovitrap <- as.numeric(Abundance$Ovitrap)
Abundance$Larval <- as.numeric(Abundance$Larval)
Abundance$Pupae <- as.numeric(Abundance$Pupae)
Abundance$Proko <- as.numeric(Abundance$Proko)
Abundance$ST <- as.numeric(Abundance$ST)

Abundance$Ovitrap <- Abundance$Ovitrap/max(Abundance$Ovitrap)
Abundance$Larval <- Abundance$Larval/max(Abundance$Larval)
Abundance$Pupae <- Abundance$Pupae/max(Abundance$Pupae)
Abundance$Proko <- Abundance$Proko/max(Abundance$Proko)
Abundance$ST <- Abundance$ST/max(Abundance$ST)

# Temp Scaled
plot(as.yearmon(Climate$Month), Climate$AvgTemp, type = "l", lwd = 2,
     main = "Chulaimbo Temperature Data (Scaled)",
     ylab = "Observations Scaled to Max", 
     xlab = "Date", ylim = c(0.65, 1))
abline(v = as.yearmon(dateSeq), lty = 3, col = "light gray")
lines(as.yearmon(Climate$Month), Climate$AvgMaxTemp, lty = 1, lwd = 2, col = "light blue")
lines(as.yearmon(Climate$Month), Climate$AvgMinTemp, lty = 1, lwd = 2, col = "light green")
lines(as.yearmon(Climate$Month), Climate$OverallMaxTemp, lty = 1, lwd = 2, col = "dark blue")
lines(as.yearmon(Climate$Month), Climate$OverallMinTemp, lty = 1, lwd = 2, col = "dark green")
abline(v = A, lty = 1, col = "red")
abline(v = B, lty = 1, col = "red")
legend(as.yearmon(as.Date("2015-06-01")), .8,
       c("OverallMaxTemp", "AvgMaxTemp", "AvgTemp", "AvgMinTemp", "OverallMinTemp"),
       col = c("dark blue", "light blue", "black", "light green", "dark green"), lwd = c(2,2,2,2,2),
       lty = c(1,1,1,1,1), bty = "n")

# RH and DewPt Scaled
plot(as.yearmon(Climate$Month), Climate$AvgRH, type = "l", lwd = 2,  main = "Chulaimbo RH and Dew Pt Data (Scaled)",
     ylab = "Observations Scaled to Max", 
     xlab = "Date", ylim = c(0.6, 1))
abline(v = as.yearmon(dateSeq), lty = 3, col = "light gray")
lines(as.yearmon(Climate$Month), Climate$AvgDewPt, type = "l", lwd = 2, col = "dark blue")
abline(v = A, lty = 1, col = "red")
abline(v = B, lty = 1, col = "red")
legend(as.yearmon(as.Date("2015-06-01")), .7, c("AvgRH", "AvgDewPt"),
       col = c("black", "dark blue"), lwd = c(2,2), lty = c(1,1), bty = "n")

# Mosquitoes scaled
plot(as.yearmon(Abundance$Date), Abundance$Ovitrap, type = "l", lwd = 2,
     main = "Chulaimbo Mosquito Abundance (Scaled)",
     ylab = "Observations Scaled to Max", xlab = "Date", ylim = c(0,1))
abline(v = as.yearmon(dateSeq), lty = 3, col = "light gray")
lines(as.yearmon(Abundance$Date), Abundance$Larval, lty = 1, lwd =2, col = "purple")
lines(as.yearmon(Abundance$Date), Abundance$Pupae, lty = 1, lwd =2, col = "orange")
lines(as.yearmon(Abundance$Date), Abundance$Proko, lty = 1, lwd =2, col = "blue")
lines(as.yearmon(Abundance$Date), Abundance$ST, lty = 1, lwd =2, col = "green")
abline(v = A, lty = 1, col = "red")
abline(v = B, lty = 1, col = "red")
legend(as.yearmon(as.Date("2014-12-01")),1 , c("Ovitrap", "Larval", "Pupae", "Prokopack", "Sentinel Trap"),
       col = c("black","purple", "orange", "blue", "green"), lwd = c(2,2,2,2,2), lty = c(1,1,1,1,1),
       bty = "n")

# Rainfall, Cases, Ovitrap

DENV$POS <- DENV$POS/max(DENV$POS)

plot(as.yearmon(DENV$Date), DENV$POS, type = "l", lwd = 2,
     main = "Ovitrap, Rainfall, and Positive DENV Cases (Scaled)",
     ylab = "Observations Scaled to Max", xlab = "Date", ylim = c(0,1))
abline(v = as.yearmon(dateSeq), lty = 3, col = "light gray")
lines(as.yearmon(Climate$Month), Climate$TtlRainfall, lty = 1, lwd = 2, col = "blue")
lines(as.yearmon(Abundance$Date), Abundance$Ovitrap, lty = 1, lwd = 2, col = "green")
abline(v = A, lty = 1, col = "red")
abline(v = B, lty = 1, col = "red")
legend(as.yearmon(as.Date("2015-12-01")), .9, c("DENV Cases", "TtlRainfall","Ovitrap"),
       col = c("black", "blue", "green"), lwd = c(2,2,2), lty = c(1,1,1), bty = "n")


plot(as.yearmon(Climate$Month), Climate$RainfallAnomalies,
     type = "l", lwd = 2, main = "Chulaimbo Climate Anomalies",
     ylab = "Observed Anomalies", xlab = "Date",
     ylim = c(0, 40))
abline(v = as.yearmon(dateSeq), lty = 3, col = "light gray")
lines(as.yearmon(Climate$Month), Climate$TempRangeAnomalies,
      lty = 1, lwd = 2, col = "blue")
lines(as.yearmon(Climate$Month), Climate$TempDewPtDiffAnomalies,
      lty = 1, lwd = 2, col = "green")
lines(as.yearmon(Climate$Month), Climate$RHTempAnomalies,
      lty = 1, lwd = 2, col = "orange")
abline(v = A, lty = 1, col = "red")
abline(v = B, lty = 1, col = "red")
legend(as.yearmon(as.Date("2015-08-01")), 40,
       c("Rainfall Anomalies", "Temp. Range Anomalies", "Temp. - Dew Pt. Anomalies",
         "Temp. & RH Anomalies"),
       col = c("black", "blue", "green", "orange"), lwd = c(2,2,2,2), lty = c(1,1,1,1), bty = "n")


dev.off()