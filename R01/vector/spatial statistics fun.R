#    ###############spatial statistics with donal  ------------------------------------------------------------------------
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/vector")
load("house.vector.rda") 
load("house.vector.k.rda") 
load("house.vector.m.rda") 
load("house.vector.c.rda") 
load("house.vector.u.rda") 

# gam model for vector abundance over time  ---------------------------
install.packages("gamm4")
library("gamm4")
gamm4(formula,random=NULL,family=gaussian(),data=list(),weights=NULL,
      subset=NULL,na.action,knots=NULL,drop.unused.levels=TRUE,
      REML=TRUE,control=NULL,start=NULL,verbose=0L,...)

#     explore the counts by house by season. ------------------------------

#     kendall test over season over house. outdoor vs indoor. -------------


