# import data -------------------------------------------------------------
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/students/njenga")
coast_proko_larva <-read.csv("pupae_larva_coast.csv",encoding = "UTF-8")

# visualize outcomes -------------------------------------------------------------
library(ggplot2)
coast_proko_larva$HouseID<-as.factor(coast_proko_larva$HouseID)
#  ggplot(coast_proko_larva,aes(x=MonYrdate, y=pupae, color=HouseID))+ geom_point()+ theme_bw(base_size = 50)+  labs(title ="", x = "Month", y = "Aedes spp. Pupae Count") + theme(axis.text.x=element_text(angle=60, hjust=1),text = element_text(size = 20))
#  ggplot(coast_proko_larva,aes(x=HouseID, y=Pupae_PA_cat))+ geom_point()+ theme_bw(base_size = 50)+  labs(title ="", x = "Month", y = "Aedes spp. Pupae Count") + theme(axis.text.x=element_text(angle=60, hjust=1),text = element_text(size = 20))
#  ggplot(coast_proko_larva,aes(x=HouseID, y=Pupae_PA))+ geom_point()+ theme_bw(base_size = 50)+  labs(title ="", x = "Month", y = "Aedes spp. Pupae Count") + theme(axis.text.x=element_text(angle=60, hjust=1),text = element_text(size = 20))

# univariate analysis -------------------------------------------------------------
library(tableone)
vars=c("Housewall","Houseroof","Noofrooms","Firewooduse","Insecticidesprayed","Mosquitocoil","Bednetpresent","Eavesopen","Ceilingpresent","Bushesaround","Tallgrassaround","peopleslept","Season","Season2","site","habitat_count")
factorVars=c("Housewall","Houseroof","Firewooduse","Insecticidesprayed","Mosquitocoil","Bednetpresent","Eavesopen","Ceilingpresent","Bushesaround","Tallgrassaround","Season","Season2","site")
univariate<-CreateTableOne(vars=vars,factorVars = factorVars, strata="Pupae_PA_cat",data=coast_proko_larva)

univariate <- print(univariate, quote = FALSE, noSpaces = TRUE, printToggle = FALSE)
write.csv(univariate, file = "univariate.csv")

# choosing variables---------------------------------------------------------------
library(extlasso)
library(glmnet)
coast_proko_larva<-coast_proko_larva[order(-(grepl('Pupae_PA', names(coast_proko_larva)))+1L)]

c<-glmnet(as.matrix(coast_proko_larva[,-1]),coast_proko_larva[,1], standardize=TRUE, alpha =1)
plot(c)
coast_proko_larva$pupae_non_zero<-coast_proko_larva$pupae
coast_proko_larva<- within(coast_proko_larva, pupae_non_zero[coast_proko_larva$pupae==0] <- NA)

library("PerformanceAnalytics")
my_data <- coast_proko_larva[, c("pupae","pupae_non_zero","Total_habitat_Count", "Housewall","Houseroof","Firewooduse","Insecticidesprayed","Mosquitocoil","Eavesopen","Ceilingpresent","Bushesaround","peopleslept")]

tiff('corr_matrix.tiff', height = 20, width = 30, units = 'cm', compression = "lzw", res = 600)
chart.Correlation(my_data, histogram=TRUE, pch=19)
dev.off()

# modeling zero inflated poisson---------------------------------------------------------------
hist(coast_proko_larva$Pupae_PA,breaks=100)#zero inflatec poisson distribution.
table(coast_proko_larva$Pupae_PA)/sum(table(coast_proko_larva$Pupae_PA))
#performance tests: negative binomial vs zero inflated neg. bin. 
#install.packages("R2BayesX")
library(R2BayesX)
library(stringr)

coast_proko_larva$month<-str_sub(coast_proko_larva$MonYrdate, 4)
coast_proko_larva$month<-as.factor(coast_proko_larva$month)

b<-bayesx(pupae~ Total_habitat_Count+sx(month, degree = 4, knots = 12) + sx(HouseID,bs='re'), data=coast_proko_larva, zipdistopt = "zinb", family = poisson, distopt = "nb")

plot(b, term = "sx(month)")

#+Housewall+Houseroof+Firewooduse+Insecticidesprayed+Mosquitocoil+Eavesopen+Ceilingpresent+Bushesaround+peopleslept+site+Total_habitat_Count)

summary(b)
plot(coast_proko_larva$pupae)
#sx for spatiial component. bx shapefile. boundry object. 
#markovial grah. linking the poitns together- this is an option if our points are overlapping. a network of boundaries. 

aggregate(coast_proko_larva,by=HouseID,)
house_total_pa <- aggregate(coast_proko_larva$Pupae_PA, by=list(house=coast_proko_larva$HouseID), FUN=sum)
hist(house_total_pa$x,breaks=100)#zero inflatec poisson distribution.
table(house_total_pa$x<102)
coast_proko_larva[factorVars]<-lapply(coast_proko_larva[factorVars], as.factor)
