# concatenate climate data from redcap and gapfill missing logger data --------
rm(list=ls()) #remove previous variable assignments
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/melisa shah")
load("redcap_clim_vec.rda")

# load libraries
library(plyr)

# load and format data ---------------------------------------------------------
# import redcap data as 'redcap_clim_vec'
# source("C:/Users/Jamie/Box Sync/DENV/Codes/REDCap_extract_climate_and_vector_data.R")

# subset data columns associated with climate
climate.all.sites <- redcap_clim_vec[, grepl("date_collected$|hobo|wu|^redcap_event_name$|lst|daily", names(redcap_clim_vec))]

# create site variables and rename date variable
climate.all.sites$site <- gsub("_arm_1", "", climate.all.sites$redcap_event_name)
climate.all.sites$site <- gsub("chulaimbo_hospital|chulaimbo_village", "chulaimbo", climate.all.sites$site)
climate.all.sites$site <- gsub("kisumu_estate|obama", "kisumu", climate.all.sites$site)
colnames(climate.all.sites)[1] <- "Date"

# subset data
climate <- subset(climate.all.sites, site=="chulaimbo"|site=="kisumu"|site=="msambweni"|site=="ukunda"|site=="hkki"|site=="hkmo")

# average across chulaimbo and kisumu loggers
climateMerged <- ddply(climate, .(Date, site)
                       , summarize
                       , temp_mean_hobo = mean(temp_mean_hobo, na.rm=T)
                       , mean_temp_wu = mean(mean_temp_wu, na.rm=T)
                       , rainfall_hobo = mean(rainfall_hobo, na.rm=T)
                       , rain_wu = mean(rain_wu, na.rm=T)
                       , rh_mean_hobo = mean(rh_mean_hobo, na.rm=T)
                       , mean_humidity_wu = mean(mean_humidity_wu, na.rm=T)
                       , RS_lst_mean = mean(mean_lst, na.rm=T)
                       , RS_rain = mean(daily_rainfall, na.rm=T))

# merge data for gapfilling ----------------------------------------------------
sites <- unique(climateMerged$site)
siteNames <- as.character(sites)

climateMerged2 <- subset(climateMerged, site == sites[1])
colnames(climateMerged2)[2] <- siteNames[1]
lastCol <- length(climateMerged2)
colnames(climateMerged2)[3:lastCol] <- paste(siteNames[1], colnames(climateMerged2)[3:lastCol], sep = "_")

for (i in 2:length(sites)){
  tempDF <- subset(climateMerged, site == sites[i])
  colnames(tempDF)[2:lastCol] <- paste(siteNames[i], colnames(tempDF)[2:lastCol], sep = "_")
  climateMerged2 <- merge(climateMerged2, tempDF, by=c("Date"), all=T)
  newName <- paste0("climate_", siteNames[i])
  assign(newName, tempDF)
}

# plot logger versus wu data -------------------------------------------------
# xs <- c(rep("kisumu_temp_mean_hobo", 2), "chulaimbo_temp_mean_hobo", rep("ukunda_temp_mean_hobo", 2), "msambweni_temp_mean_hobo", "chulaimbo_rainfall_hobo", "kisumu_rainfall_hobo", "msambweni_rainfall_hobo", "ukunda_rainfall_hobo", "chulaimbo_rh_mean_hobo", "kisumu_rh_mean_hobo", "msambweni_rh_mean_hobo", "ukunda_rh_mean_hobo")
# ys <- c("chulaimbo_temp_mean_hobo", "hkki_mean_temp_wu", "hkki_mean_temp_wu", "msambweni_temp_mean_hobo", "hkki_mean_temp_wu", "hkki_mean_temp_wu", rep("hkki_rain_wu", 2), rep("hkmo_rain_wu", 2), rep("hkki_mean_humidity_wu", 2), rep("hkmo_mean_humidity_wu", 2))
# 
# for (i in 1:length(xs)){
#   fileName <- paste0("Kenya/Figures/climate/temp_rain_rh_", xs[i], "_v_", ys[i], ".tiff")
#   if (i < 7){
#     fileName <- gsub("_temp_mean_hobo|hkki_mean_temp_|hkmo_mean_temp|rain_|rh_", "", fileName)
#   } else if (i >= 7 & i < 11) {
#     fileName <- gsub("_rainfall_hobo|_hkki_rain|_hkmo_rain|temp_|rh_", "", fileName)
#   } else {
#     fileName <- gsub("_rh_mean_hobo|hkki_mean_humidity_|hkmo_mean_humidity_|temp_|rain_", "", fileName)
#   }
#   tiff(fileName, width = 793, height = 471, units = "px")
#   plot(climateMerged2[,xs[i]], climateMerged2[,ys[i]], xlim = c(15,32), ylim = c(15,32), col = alpha("blue", 0.5), pch=16, xlab = xs[i], ylab = ys[i])
#   abline(a=0, b=1)
#   dev.off()
# }

# gapfill climate data ---------------------------------------------------
# calculate regression equations for temperature
fill.ch.w.ki = lm(chulaimbo_temp_mean_hobo ~ kisumu_temp_mean_hobo, data=climateMerged2)
fill.ch.w.wu = lm(chulaimbo_temp_mean_hobo ~ hkki_mean_temp_wu, data=climateMerged2)
fill.ki.w.ch = lm(kisumu_temp_mean_hobo ~ chulaimbo_temp_mean_hobo, data=climateMerged2)
fill.ki.w.wu = lm(kisumu_temp_mean_hobo ~ hkki_mean_temp_wu, data=climateMerged2)
fill.uk.w.ms = lm(ukunda_temp_mean_hobo ~ msambweni_temp_mean_hobo, data=climateMerged2)
fill.uk.w.wu = lm(ukunda_temp_mean_hobo ~ hkmo_mean_temp_wu, data=climateMerged2)
fill.ms.w.uk = lm(msambweni_temp_mean_hobo ~ ukunda_temp_mean_hobo, data=climateMerged2)
fill.ms.w.wu = lm(msambweni_temp_mean_hobo ~ hkmo_mean_temp_wu, data=climateMerged2)

# gap fill temperature data with paired site if available, else with weather underground temperature
climateMerged2$GF_Chulaimbo_mean_temp <- ifelse(!is.na(climateMerged2$chulaimbo_temp_mean_hobo), climateMerged2$chulaimbo_temp_mean_hobo, round(coef(fill.ch.w.ki)[[1]] + coef(fill.ch.w.ki)[[2]] * climateMerged2$kisumu_temp_mean_hobo, 1))
climateMerged2$GF_Chulaimbo_mean_temp <- ifelse(!is.na(climateMerged2$GF_Chulaimbo_mean_temp), climateMerged2$GF_Chulaimbo_mean_temp, round(coef(fill.ch.w.wu)[[1]] + coef(fill.ch.w.wu)[[2]] * climateMerged2$hkki_mean_temp_wu, 1))

climateMerged2$GF_Kisumu_mean_temp <- ifelse(!is.na(climateMerged2$kisumu_temp_mean_hobo), climateMerged2$kisumu_temp_mean_hobo, round(coef(fill.ki.w.ch)[[1]] + coef(fill.ki.w.ch)[[2]] * climateMerged2$chulaimbo_temp_mean_hobo, 1))
climateMerged2$GF_Kisumu_mean_temp <- ifelse(!is.na(climateMerged2$GF_Kisumu_mean_temp), climateMerged2$GF_Kisumu_mean_temp, round(coef(fill.ki.w.wu)[[1]] + coef(fill.ki.w.wu)[[2]] * climateMerged2$hkki_mean_temp_wu, 1))

climateMerged2$GF_Msambweni_mean_temp <- ifelse(!is.na(climateMerged2$msambweni_temp_mean_hobo), climateMerged2$msambweni_temp_mean_hobo, round(coef(fill.ms.w.uk)[[1]] + coef(fill.ms.w.uk)[[2]] * climateMerged2$ukunda_temp_mean_hobo, 1))
climateMerged2$GF_Msambweni_mean_temp <- ifelse(!is.na(climateMerged2$GF_Msambweni_mean_temp), climateMerged2$GF_Msambweni_mean_temp, round(coef(fill.ms.w.wu)[[1]] + coef(fill.ms.w.wu)[[2]] * climateMerged2$hkmo_mean_temp_wu, 1))

climateMerged2$GF_Ukunda_mean_temp <- ifelse(!is.na(climateMerged2$ukunda_temp_mean_hobo), climateMerged2$ukunda_temp_mean_hobo, round(coef(fill.uk.w.ms)[[1]] + coef(fill.uk.w.ms)[[2]] * climateMerged2$msambweni_temp_mean_hobo, 1))
climateMerged2$GF_Ukunda_mean_temp <- ifelse(!is.na(climateMerged2$GF_Ukunda_mean_temp), climateMerged2$GF_Ukunda_mean_temp, round(coef(fill.uk.w.wu)[[1]] + coef(fill.uk.w.wu)[[2]] * climateMerged2$hkmo_mean_temp_wu, 1))

# gap fill rain data with weather underground
climateMerged2$GF_Chulaimbo_rain <- ifelse(!is.na(climateMerged2$chulaimbo_rainfall_hobo), climateMerged2$chulaimbo_rainfall_hobo, climateMerged2$hkki_rain_wu)
climateMerged2$GF_Kisumu_rain <- ifelse(!is.na(climateMerged2$kisumu_rainfall_hobo), climateMerged2$kisumu_rainfall_hobo, climateMerged2$hkki_rain_wu)
climateMerged2$GF_Msambweni_rain <- ifelse(!is.na(climateMerged2$msambweni_rainfall_hobo), climateMerged2$msambweni_rainfall_hobo, climateMerged2$hkmo_rain_wu)
climateMerged2$GF_Ukunda_rain <- ifelse(!is.na(climateMerged2$ukunda_rainfall_hobo), climateMerged2$ukunda_rainfall_hobo, climateMerged2$hkmo_rain_wu)

# gap fill humidity data with weather underground
climateMerged2$GF_Chulaimbo_humidity <- ifelse(!is.na(climateMerged2$chulaimbo_rh_mean_hobo), climateMerged2$chulaimbo_rh_mean_hobo, climateMerged2$hkki_mean_humidity_wu)
climateMerged2$GF_Kisumu_humidity <- ifelse(!is.na(climateMerged2$kisumu_rh_mean_hobo), climateMerged2$kisumu_rh_mean_hobo, climateMerged2$hkki_mean_humidity_wu)
climateMerged2$GF_Msambweni_humidity <- ifelse(!is.na(climateMerged2$msambweni_rh_mean_hobo), climateMerged2$msambweni_rh_mean_hobo, climateMerged2$hkmo_mean_humidity_wu)
climateMerged2$GF_Ukunda_humidity <- ifelse(!is.na(climateMerged2$ukunda_rh_mean_hobo), climateMerged2$ukunda_rh_mean_hobo, climateMerged2$hkmo_mean_humidity_wu)

# average from 2 days before and after for dates without data from logger and weather underground records
sites2 <- colnames(climateMerged2[, grepl("GF", names(climateMerged2))])

for (i in 1:length(sites2)){
  if (any(is.na(climateMerged2[,sites2[i]]))==TRUE){
    for (j in 1:nrow(climateMerged2)){
      if (is.na(climateMerged2[,sites2[i]][j])==TRUE){
        climSub <- climateMerged2[c(c(j-2):c(j+2)),]
        climateMerged2[,sites2[i]][j] <- mean(climSub[,sites2[i]], na.rm=T)
      }
    }
  }
}

# subset gap filled data
gapfilled_data <- climateMerged2[, grepl("Date|GF", names(climateMerged2))]

# create cumulative rainfall in prior week for each day
gapfilled_data$GF_Chulaimbo_cumRain <- NA
gapfilled_data$GF_Kisumu_cumRain <- NA
gapfilled_data$GF_Msambweni_cumRain <- NA
gapfilled_data$GF_Ukunda_cumRain <- NA

gapfilled_data$Date<-as.numeric(as.Date(gapfilled_data$Date))
for (j in 7:nrow(gapfilled_data)){
  rainSub <- subset(gapfilled_data, Date >= Date[j] - 6 & Date <= Date[j])
  gapfilled_data$GF_Chulaimbo_cumRain[j] <- sum(rainSub$GF_Chulaimbo_rain)
  gapfilled_data$GF_Kisumu_cumRain[j] <- sum(rainSub$GF_Kisumu_rain)
  gapfilled_data$GF_Msambweni_cumRain[j] <- sum(rainSub$GF_Msambweni_rain)
  gapfilled_data$GF_Ukunda_cumRain[j] <- sum(rainSub$GF_Ukunda_rain)
}

gapfilled_data <- gapfilled_data[7:nrow(gapfilled_data),]
write.csv(gapfilled_data, "gapfilled_climate_data.csv", row.names=F)

# plot gap filled data v remotely sensed data ------------------------------------------
# library(ggplot2)
# gf <- colnames(climateMerged2[, grepl("GF", names(climateMerged2))])
# gf <- gf[!grepl("humidity", gf)]
# rs <- c(colnames(climateMerged2[, grepl("RS_lst", names(climateMerged2))]), colnames(climateMerged2[, grepl("RS_rain", names(climateMerged2))]))
# rs <- rs[!grepl("hkki|hkmo", rs)]
# 
# for (i in 1:length(gf)){
#   fileName <- paste0("Kenya/Figures/climate/", gf[i], "_v_", rs[i], ".tiff")
#   fileName <- gsub("GF_|_mean", "", fileName)
#   fileName <- gsub("chulaimbo_RS|kisumu_RS|msambweni_RS|ukunda_RS", "RS", fileName)
#   tiff(fileName, width = 793, height = 471, units = "px")
#   plot(climateMerged2[,gf[i]], climateMerged2[,rs[i]], xlim = c(15,32), ylim = c(15,32), col = alpha("blue", 0.5), pch=16, xlab = gf[i], ylab = rs[i])
#   abline(a=0, b=1)
#   dev.off()
# }