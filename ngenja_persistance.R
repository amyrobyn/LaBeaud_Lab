# import data -------------------------------------------------------------
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/njenga")
coast_proko_larva <-read.csv("pupae_larva_coast.csv",encoding = "UTF-8")

# visualize outcomes -------------------------------------------------------------
library(ggplot2)
coast_proko_larva$HouseID<-as.factor(coast_proko_larva$HouseID)
#  ggplot(coast_proko_larva,aes(x=MonYrdate, y=pupae, color=HouseID))+ geom_point()+ theme_bw(base_size = 50)+  labs(title ="", x = "Month", y = "Aedes spp. Pupae Count") + theme(axis.text.x=element_text(angle=60, hjust=1),text = element_text(size = 20))
#  ggplot(coast_proko_larva,aes(x=HouseID, y=Pupae_PA_cat))+ geom_point()+ theme_bw(base_size = 50)+  labs(title ="", x = "Month", y = "Aedes spp. Pupae Count") + theme(axis.text.x=element_text(angle=60, hjust=1),text = element_text(size = 20))
#  ggplot(coast_proko_larva,aes(x=HouseID, y=Pupae_PA))+ geom_point()+ theme_bw(base_size = 50)+  labs(title ="", x = "Month", y = "Aedes spp. Pupae Count") + theme(axis.text.x=element_text(angle=60, hjust=1),text = element_text(size = 20))

# univariate analysis -------------------------------------------------------------
library(tableone)
vars=c("Housewall","Houseroof","Noofrooms","Firewooduse","Insecticidesprayed","Mosquitocoil","Bednetpresent","Eavesopen","Ceilingpresent","Bushesaround","Tallgrassaround","peopleslept","Season","Season2","site")
factorVars=c("Housewall","Houseroof","Firewooduse","Insecticidesprayed","Mosquitocoil","Bednetpresent","Eavesopen","Ceilingpresent","Bushesaround","Tallgrassaround","Season","Season2","site")
univariate<-CreateTableOne(vars=vars,factorVars = factorVars, strata="Pupae_PA_cat",data=coast_proko_larva)

univariate <- print(univariate, quote = FALSE, noSpaces = TRUE, printToggle = FALSE)
write.csv(univariate, file = "univariate.csv")

# modeling zero inflated poisson---------------------------------------------------------------
hist(coast_proko_larva$Pupae_PA)#zero inflatec poisson distribution.
coast_proko_larva[factorVars]<-lapply(coast_proko_larva[factorVars], as.factor)
table(coast_proko_larva$Housewall)

library(pscl)
library(boot)
library(glmmTMB)
library(bbmle) ## for AICtab
#we have to choose vars....
fit_zipoisson <- glmmTMB(Pupae_PA~(Housewall+Houseroof+Firewooduse+Insecticidesprayed+Mosquitocoil+Eavesopen+Ceilingpresent+Bushesaround+peopleslept+site)+(1|HouseID),
                         data=coast_proko_larva,
                         ziformula=~1,
                         family=poisson)
summary(fit_zipoisson)
#we have to choose vars...
summary(zeroinfl(Pupae_PA~Season+Housewall,data=coast_proko_larva))

# choosing variables---------------------------------------------------------------
library(extlasso)
library(glmnet)
coast_proko_larva<-coast_proko_larva[order(-(grepl('Pupae_PA', names(coast_proko_larva)))+1L)]

c<-glmnet(as.matrix(coast_proko_larva[,-1]),coast_proko_larva[,1], standardize=TRUE, alpha =1)
plot(c)