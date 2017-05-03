install.packages(c("readxl", "xlsx", "plyr","dplyr", "zoo", "AICcmodavg","MuMIn", "car", "sjPlot", "visreg", "datamart", "reshape2", "rJava", "WriteXLS", "xlsx", "readxl"))
#if (Sys.getenv("JAVA_HOME")!="")
#  Sys.setenv(JAVA_HOME="")
### Packages :
install.packages(c("sp", "raster"))

library(sp)
library(raster)

library(rJava) 
library(WriteXLS) # Writing Excel files
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
setwd("C:/Users/amykr/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/built environement hcc")
merged <- read.csv("to_map11 Apr 2017.csv", sep = ",")
head(merged)
class(merged)
coordinates(merged) <- c("gps_x_long", "gps_y_lat")
class(merged)
table(merged$inc_denv)
table(merged$inc_chikv)
inc_chikv <- merged[ -(which(is.na(merged$inc_chikv))),]
inc_denv <- merged[ -(which(is.na(merged$inc_denv))),]
incident_malaria  <- merged[ -(which(is.na(merged$incident_malaria ))),]

bubble(incident_malaria, "incident_malaria")
plot(incident_malaria)
plot(inc_denv)
plot(inc_chikv)
spplot(inc_denv)

is.projected(inc_denv) # see if a projection is defined  
proj4string(inc_denv) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs") # this is WGS84
is.projected(inc_denv) # voila! hm. wait a minute..

is.projected(inc_chikv) # see if a projection is defined  
proj4string(inc_chikv) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs") # this is WGS84
is.projected(inc_chikv) # voila! hm. wait a minute..

is.projected(incident_malaria) # see if a projection is defined  
proj4string(incident_malaria) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs") # this is WGS84
is.projected(incident_malaria) # voila! hm. wait a minute..
install.packages("sf")
library(sf)
incident_malaria_sf <- st_as_sf(incident_malaria)
plot(incident_malaria_sf$incident_malaria)
plot(incident_malaria_sf["incident_malaria"])


library(ggmap)
install.packages("ggplot2")
library(ggplot2)
install.packages("sp")
install.packages("spatstat")
install.packages("ncf")
install.packages("spdep")
library(sp)
library(spatstat)
library(ncf)
library(spdep)

w <- 1/as.matrix(dist(coordinates(incident_malaria)))
diag(w) <- 0
moran.test(incident_malaria$incident_malaria,mat2listw(w))
w <- knn2nb(knearneigh(incident_malaria,k=8))
moran.test(incident_malaria$incident_malaria,nb2listw(w))

incident_malariaI <- spline.correlog(x=coordinates(incident_malaria)[,1], y=coordinates(incident_malaria)[,2],
                         z=incident_malaria$incident_malaria, resamp=100, quiet=TRUE)
w <- 1/as.matrix(dist(coordinates(incident_malaria)))
diag(w) <- 0
moran.test(incident_malaria$incident_malaria,mat2listw(w))

plot(density(incident_malaria$incident_malaria))

library(ggplot)
kenya_basemap <- get_map(location="Kenya", zoom=11, maptype = 'satellite')
ggmap(kenya_basemap)
class(incident_malaria)
table(inc_chikv$city)
kisumuincident_malaria<-incident_malaria[ -(which((incident_malaria$city=="kisumu"))),]

ggmap(kenya_basemap)+
  geom_point(aes(x = gps_x_long, y = gps_y_lat), data = as.data.frame(coordinates(incident_malaria)),
             alpha = .5, color="darkred", size = 20)
