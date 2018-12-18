# pca ---------------------------------------------------------------------
ses<-AIC[, c("person_id","redcap_event_name","id_city","strata_all","telephone","radio","television","bicycle","motor_vehicle", "domestic_worker","roof_type","latrine_type","roof_type","floor_type","drinking_water_source","light_source")]
ses<-ses[complete.cases(ses), ]
ses.pca<-prcomp(ses[,5:16 ], center = TRUE,scale. = TRUE)
summary(ses.pca)
#install_github("vqv/ggbiplot")
library("ggbiplot")
ggbiplot(ses.pca)
ggbiplot(ses.pca,ellipse=TRUE, groups=ses$id_city)
ggbiplot(ses.pca,ellipse=TRUE, groups=ses$strata_all)
std_dev <- ses.pca$sdev
pr_var <- std_dev^2
prop_varex <- pr_var/sum(pr_var)
plot(prop_varex, xlab = "Principal Component",ylab = "Proportion of Variance Explained",type = "b")



ses<-cbind(ses,ses.pca$x)
AIC<-merge(ses,AIC,by=c("person_id","redcap_event_name"), all.y=T)
colnames(AIC)[colnames(AIC) == 'id_city.y'] <- 'id_city'
colnames(AIC)[colnames(AIC) == 'strata_all.y'] <- 'strata_all'
