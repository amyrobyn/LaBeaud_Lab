#prelim analysis donal and amy paper.

setwd("C:/Users/amykr/Box Sync/DENV CHIKV project/Vector Data/West/West Latest")
Ovitrap1 <- read_excel("Ovitrap Sampling Data.xlsx", sheet = 1)

table(Ovitrap1[,"Egg count"], Ovitrap1[,"House ID"], sum, na.rm=TRUE)

ovi_db<-as.data.frame(Ovitrap1)
house_count<-tapply(ovi_db[,"Egg count"], ovi_db[,"House ID"], sum, na.rm=TRUE)
hist(table(house_count),breaks=50)

ovi_db$compound<-substr(ovi_db$`House ID`,7,9)

house_count<-tapply(ovi_db[,"Egg count"], ovi_db[,"compound"], sum, na.rm=TRUE)
barplot(house_count,las=2)