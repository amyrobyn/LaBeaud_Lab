setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/spectrum population health 2017/colombia anopheles data")
mosq <- read.csv("workingdata.csv")
head(mosq)
class(mosq)
library("sp")

mosq$lat1<-as.numeric(gsub(".", "", mosq$lat, fixed = TRUE))
mosq$lon1<-as.numeric(gsub(".", "", mosq$lon, fixed = TRUE))

mosq$lat1<-mosq$lat1*1e-13
mosq$lon1<-mosq$lon1*1e-13

mosq <-mosq[which(mosq$lat1!='.' & mosq$lon1!='.')  , ]
coordinates(mosq) <- c("lon1", "lat1")

class(mosq)
bubble(mosq)
plot(mosq)
spplot(mosq)

library(sf)

mosq_sf <- st_as_sf(mosq)
plot(mosq_sf)
plot(mosq_sf["intra_mosq"])
plot(mosq_sf["peri_mosq"])
plot(mosq_sf["species"])
