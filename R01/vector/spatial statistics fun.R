#    ###############spatial statistics with donal  ------------------------------------------------------------------------
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/vector")
load("house.vector.rda") 
load("house.vector.k.rda") 
#load("house.vector.m.rda") 
load("house.vector.c.rda") 
#load("house.vector.u.rda") 

#The climate is characterized by monsoonal 'long rains' (April-June, LRS) 
#and 'short rains' (October-December, SRS) rainy seasons, 
#and by hot (January-March, HDS) 
#and cool (July-September, CDS) dry seasons.

library("zoo")
house.vector$month_year<-as.yearmon(house.vector$date_collected.y)
library(lubridate)
house.vector$month<-month(as.yearmon(house.vector$date_collected.y))

house.vector<-as.data.frame(house.vector)
house.vector$season<-NA
house.vector <- within(house.vector, season[house.vector$month >=1 & house.vector$month <=3] <- "HDS")
house.vector <- within(house.vector, season[house.vector$month >=4 & house.vector$month <=6] <- "LRS")
house.vector <- within(house.vector, season[house.vector$month >=7 & house.vector$month <=9] <- "CDS")
house.vector <- within(house.vector, season[house.vector$month >=10 & house.vector$month <=12] <- "SRS")
table(house.vector$season)

# gam model for vector abundance over time  ---------------------------
#install.packages("gamm4")
library("gamm4")
gamm4(formula,random=NULL,family=gaussian(),data=list(),weights=NULL,
      subset=NULL,na.action,knots=NULL,drop.unused.levels=TRUE,
      REML=TRUE,control=NULL,start=NULL,verbose=0L,...)

#     explore the counts by house by season. ------------------------------

#     kendall test over season over house. outdoor vs indoor. -------------
#  install.packages("Kendall")
  library("Kendall")
  cor.test(exer, smoke, method="kendall") 
  library(rpud)                     # load rpudplus 
  rpucor(m, method="kendall", use="pairwise") 
  rt <- rpucor.test(m, method="kendall", use="pairwise") 
  rt$estimate 
  rt$p.value 
  rt$p.value < 0.05
