#igm results from google sheets to redcap.
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/backups/google sheet elisas")
library(gtools)
library(plyr)
#coast
  ukunda_aic<-read.csv("Ukunda AIC.csv")
  ukunda_hcc<-read.csv("Ukunda HCC.csv")
    
  mililani_hcc<-read.csv("MILALANI HCC.csv")
  msambweni_aic<-read.csv("Msambweni  AIC.csv")
  nganja_hcc<-read.csv("NGANJA HCC.csv")
  
#west
  chulaimbo_aic<-read.csv("CHULAIMBO AIC.csv")
  chulaimbo_hcc<-read.csv("CHULAIMBO HCC.csv")
  
  kisumu_aic<-read.csv("KISUMU AIC.csv")
  kisumu_hcc<-read.csv("KISUMU HCC.csv")


all_data<-smartbind(ukunda_aic, ukunda_hcc, mililani_hcc, msambweni_aic, nganja_hcc , chulaimbo_aic, chulaimbo_hcc, kisumu_aic, kisumu_hcc)
#all_data<-rbind.fill(ukunda_aic, ukunda_hcc, mililani_hcc, msambweni_aic, nganja_hcc , chulaimbo_aic, chulaimbo_hcc, kisumu_aic, kisumu_hcc)

igm <- all_data[ , grepl( "igm|studyid" , names(all_data),ignore.case = TRUE ) ]
igm <-igm[!sapply(igm, function (x) all(is.na(x) | x == ""| x == "NA"))]

igm  <- igm[ -(which(is.na(igm$CHIKV.IgM_e) | is.na(igm$DENV.IgM_e ))),]
igm  <- igm[ (which((igm$CHIKV.IgM_e!="") | (igm$DENV.IgM_e !=""))),]
igm <- igm[ , grepl( "igm|studyid_e" , names(igm),ignore.case = TRUE ) ]

igm <- within(igm, CHIKV.IgM_e[CHIKV.IgM_e=="Neg"] <- 0)
igm <- within(igm, DENV.IgM_e[DENV.IgM_e=="Neg"] <- 0)

#export to csv
f <- "igm_tested_7-25-17.csv"
write.csv(as.data.frame(igm), f )
