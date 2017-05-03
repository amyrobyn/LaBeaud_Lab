#plotting data from hh_to_map file
install.packages("knitr")
knitr::opts_chunk$set(echo=TRUE,
                      cache=TRUE,
                      prompt=FALSE,
                      tidy=TRUE,
                      comment=NA,
                      message=FALSE,
                      warning=FALSE)
install.packages(c("sp", "raster", "sf"))
library(sp)
library(raster)
library(sf)
library(readxl)


setwd("C:/Users/amykr/Box Sync/DENV CHIKV project/Coast Cleaned/Demography/Demography Latest") # Always set where you're grabbing stuff from
hh_to_map <-read_excel("Msambweni_coordinates complete Nov 21 2016.xls")

Provisory <- matrix(c(hh_to_map$X, hh_to_map$Y), ncol=2, nrow=436)
Msam <- na.exclude(Provisory)
Msam_sp <- SpatialPoints(Msam)
plot(Msam_sp, pch=19)

#transform coordinates from UTM to latitude and longitude (not finished)
install.packages("rgdal")
library(rgdal)
ukgrid = "+init=epsg:27700"
latlong = "+init=epsg:4326"
Msam_sp_LL <-spTransform(Msam_sp, CRS(latlong))

#ukunda
setwd("C:/Users/amykr/Box Sync/DENV CHIKV project/Coast Cleaned/Demography/Demography Latest") # Always set where you're grabbing stuff from
hh_to_map_ukunda <-read_excel("Ukunda_HCC_children_demography Mar17.xls")

ukunda <- matrix(c(hh_to_map$Longitude, hh_to_map$Latitude), ncol=2, nrow=436)
ukunda <- na.exclude(ukunda)
ukunda_sp <- SpatialPoints(ukunda)
plot(ukunda_sp, pch=19)
