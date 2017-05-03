install.packages("sf")
library(sf)
library(sp)
library(raster)
library(sf)


setwd("C:/Users/amykr/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/demography")
duphouse <- read.csv("duphouseid_gps.csv")
#myvars <-c("gps_house_latitude", "gps_house_longitude", "houseid")
duphouse <-duphouse[which(duphouse$gps_house_latitude!='.' & duphouse$gps_house_longitude!='.')  , ]
duphouse <-duphouse[142:460,]
head(duphouse)
class(duphouse)

coordinates(duphouse) <- c("gps_house_longitude", "gps_house_latitude")
class(duphouse)
bubble(duphouse, "houseid")
plot(duphouse$gps_house_longitude, duphouse$gps_house_latitude)

duphouse_sf <- st_as_sf(duphouse)

names(duphouse_sf)
str(duphouse_sf)

class(duphouse_sf$geometry)    
st_geometry(duphouse_sf)  # use this method to retreive geometry!
st_geometry(duphouse_sf)[[1]]

# careful with this:
plot(duphouse_sf["houseid"])
class(duphouse_sf["houseid"])
plot(duphouse_sf)


require(plyr)
# split up captures by the unique individual id for processing
ddply(duphouse, "houseid", function(df){
  # single captures don't have any dist/time changes
  if(nrow(df)==1) {
    return(data.frame(start=NA,
                      end=NA,
                      dist=NA,
                      mean.time=NA))
  }
  
  # for each pair of consecutive displacement, calculate dist and mean time
  out <- sapply(1:(nrow(df)-1), function(i){
    #x<-cbind(duphouse$gps_house_longitude, duphouse$gps_house_latitude)
    #d<-distm(x, fun=distHaversine)
    d <- dist(df[i:(i+1),6:7])
    t <- mean(df[i:(i+1),10])
    
    lat <- df[i:(i+1),6:6]
    long <-df[i:(i+1),7:7]
    c(d,t, lat, long)
  })
  out <- t(out)
# reports results, adding the starting and ending record number for each displacement
data.frame(start=head(df$dup,-1), end=tail(df$dup, -1), dist=out[,1], mean.time=out[,2], lat=out[,3], long=out[,4] )
#write.table(d, "C:/Users/amykr/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/demography/mydata.txt", sep="\t")
})

install.packages("geosphere")
library("geosphere")
x<-cbind(duphouse$gps_house_longitude, duphouse$gps_house_latitude)
d<-distm(x, fun=distHaversine)