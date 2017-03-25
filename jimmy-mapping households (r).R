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