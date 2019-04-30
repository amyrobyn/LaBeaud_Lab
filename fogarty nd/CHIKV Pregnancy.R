# packages --------------------------------------------------------
library(redcapAPI)
library(REDCapR)
library(tableone)
library("DiagrammeR")#install.packages("DiagrammeR")
library(plotly)
library(plyr)
library(dplyr)
library(raster)

# data --------------------------------------------------------
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/fogarty chikv")

Redcap.token <- readLines("API_code.txt") # Read API token from folder
REDcap.URL  <- 'https://redcap.stanford.edu/api/'
rcon <- redcapConnection(url=REDcap.URL, token=Redcap.token)
chikv_nd <- redcap_read(redcap_uri  = REDcap.URL, token = Redcap.token, batch_size = 50)$data#export data from redcap to R (must be connected via cisco VPN)

currentDate <- Sys.Date() 
FileName <- paste("chikv_nd",currentDate,".rda",sep=" ") 
save(chikv_nd,file=FileName)

#load(FileName)
cohort<-chikv_nd
cohort<-read.csv("CSComplicationsCHIKV.csv", header=TRUE) #import csv for complications analysis

# infection timing --------------------------------------------------------
cohort$when<-zoo::as.Date(cohort$when)
cohort$childs_birth_date<-zoo::as.Date(cohort$childs_birth_date)
cohort$days_delivery_chikv<- as.numeric(cohort$when - cohort$childs_birth_date)

summary(cohort$days_delivery_chikv)
hist(cohort$days_delivery_chikv,breaks=c(-1234,-15,-3,-2,966))

cohort$partum<-NA
cohort<-within(cohort,partum[cohort$days_delivery_chikv <= -15] <- 1 )

cohort<-within(cohort,partum[cohort$days_delivery_chikv>=-15 & cohort$days_delivery_chikv <= -3]<-2)
cohort<-within(cohort,partum[cohort$days_delivery_chikv>=-2 & cohort$days_delivery_chikv<=2]<-3)

table(cohort$partum)

#establish strata
#cohort<-as.data.frame(cohort[which(!is.na(cohort$result_mother) & cohort$result_mother!=98),])
cohort$strata1<-NA
cohort<-within(cohort, strata1[(result_mother==1&pregnant==0)|result_mother==0]<-0)
cohort<-within(cohort, strata1[result_mother==1 & pregnant ==1]<-1)
cohort$strata2<-NA
cohort <- within(cohort, strata2[result_mother==1 & pregnant==0|result_mother==0] <- 0)
cohort <- within(cohort, strata2[result_mother==1 & pregnant ==1&symptoms___4==1&(symptoms___1==1|symptoms___3==1|symptoms___5==1|symptoms___6==1|symptoms___25==1)] <- 1)
cohort$strata3<-NA
cohort<-within(cohort, strata3[result_mother==1&pregnant==0]<-0)
cohort<-within(cohort, strata3[result_mother==1 & pregnant ==1]<-1)
cohort$strata4<-NA
cohort<-within(cohort, strata4[result_mother==0]<-0)
cohort <- within(cohort, strata4[result_mother==1 & pregnant ==1&symptoms___4==1&(symptoms___1==1|symptoms___3==1|symptoms___5==1|symptoms___6==1|symptoms___25==1)] <- 1)
strata4_excluded<-cohort[which(is.na(cohort$strata4)),]
table(cohort$strata4)
table(cohort$result_mother,exclude=NULL)
strata4_excluded_igg<-cohort[which(cohort$result_mother!=1&cohort$result_mother!=0|is.na(cohort$result_mother)),]
strata4_excluded_outsidepreg<-cohort[which(cohort$result_mother==1&(cohort$pregnant!=1|is.na(cohort$pregnant))),]
strata4_excluded_jointpain<-cohort[which(cohort$result_mother==1&cohort$pregnant==1&(cohort$symptoms___4!=1|is.na(cohort$symptoms___4))),]
strata4_excluded_othersymptoms<-cohort[which(cohort$result_mother==1&cohort$pregnant==1&cohort$symptoms___4==1&((cohort$symptoms___1!=1|is.na(cohort$symptoms___1))&(cohort$symptoms___3!=1|is.na(cohort$symptoms___3))&(cohort$symptoms___5!=1|is.na(cohort$symptoms___5))&(cohort$symptoms___6!=1|is.na(cohort$symptoms___6))&(cohort$symptoms___25!=1|is.na(cohort$symptoms___25)))),]


table(cohort$strata4,exclude = NULL)
table(cohort$strata4,cohort$result_mother, exclude = NULL)
table(cohort$strata4,cohort$pregnant, exclude = NULL)

cohort$strata5<-NA
cohort<-within(cohort, strata5[result_mother==1 & pregnant==0]<-0)
cohort <- within(cohort, strata5[result_mother==1 & pregnant ==1&symptoms___4==1&(symptoms___1==1|symptoms___3==1|symptoms___5==1|symptoms___6==1|symptoms___25==1)] <- 1)

strata5_excluded<-cohort[which(is.na(cohort$strata5)),]
table(cohort$strata5,exclude = NULL)


# next --------------------------------------------------------------------
strata3posbefore<- cohort$result_mother==1 & cohort$pregnant ==0
strata3posduring<-cohort$result_mother==1 & cohort$pregnant ==1
posprior<-sum(strata3posbefore, na.rm=TRUE)
pospregnant<-sum(strata3posduring, na.rm=TRUE)
percentageduring <- 100*pospregnant/(pospregnant+posprior)
percentageprior<-100*posprior/(pospregnant+posprior)
percentageduring
percentageprior

#chikvpos + pregnant vs nonpregnant
cohort$preg_chikvpos<-NA
cohort <- within(cohort, preg_chikvpos[result_mother==0] <- "control")
cohort <- within(cohort, preg_chikvpos[result_mother==1&pregnant==1] <- "exposure")
table(cohort$preg_chikvpos_wsymptoms)
table(cohort$preg_chikvpos)
#CHIKV rates among pregnant women
binom.test(187,287,p=.89, alternative = "two.sided")

#Do pregnant women have more severe disease than non-pregnant women?
strata1.group<-as.data.frame(cohort[which(!is.na(cohort$strata1)), ])
table(strata1.group$strata1, exclude = NULL)
strata2.group<-as.data.frame(cohort[which(!is.na(cohort$strata2)), ])
table(strata2.group$strata2, exclude = NULL)
strata3.group<-as.data.frame(cohort[which(!is.na(cohort$strata3)), ])
table(strata3.group$strata3, exclude = NULL)
strata4.group<-as.data.frame(cohort[which(!is.na(cohort$strata4)), ])
table(strata4.group$strata4, exclude = NULL)
strata5.group<-as.data.frame(cohort[which(!is.na(cohort$strata5)), ])
table(strata5.group$strata5, exclude = NULL)
vars2<-c("joint_pain_today","joint_pain_since", "joint_pain_last_week","joint_pain_last_month", "symptoms___1", "symptoms___2", "symptoms___3", "symptoms___4", "symptoms___5", "symptoms___6", "symptoms___7", "symptoms___8", "symptoms___9", "symptoms___10", "symptoms___11", "symptoms___12", "symptoms___13", "symptoms___14", "symptoms___15", "symptoms___16", "symptoms___17", "symptoms___18", "symptoms___19", "symptoms___20", "symptoms___21", "symptoms___22", "symptoms___23", "symptoms___24", "symptoms___25", "symptoms___26", "symptoms___27", "symptoms___28", "symptoms___29", "symptoms___30", "symptoms___31", "symptoms___32", "symptoms___33", "symptoms___34","specify_other_pregnancy_illness")
cohort[vars2] <- sapply(cohort[vars2],as.factor)
testa<-CreateTableOne(vars = vars2, strata = "strata5", data = cohort)

testa<-print(testa, nonnormal = vars2)
write.csv(testa, file = "pregnancy_severity5.csv")
testb<-CreateTableOne(vars = vars2, strata = "strata3",data =cohort)
testb<-print(testb, nonnormal = vars2)
write.csv(testb, file = "pregnancy_severity3.csv")


#complications for pregnancy, delivery, and reason for CS


variables <-c("preg_anemia","preg_asthma", "preg_elevatedbloodpressure","preg_lowbloodpressure","preg_diabetes","preg_nausea","preg_migraines","preg_abruption","preg_placenta","preg_malpresentation","preg_meconium","preg_vaginalbleeding","preg_abdominalpain","preg_pretermlabor","preg_cervicalincompetence","preg_syncope","preg_genitourinaryinfection","preg_pain","preg_thyroiddisease","preg_sicklecell","preg_other","preg_uterineabnormality","preg_chikv","preg_largefetus","preg_PPROM","preg_fetaldistress","preg_maternalindication","preg_failedinduction","preg_cephalopelvic","preg_postdates","preg_macrosomia","preg_history","preg_cervical","preg_breach","preg_shoulder","CS_fetaldistress","CS_abruption","CS_malpresentation","CS_maternalindiciation","CS_failedinduction","CS_cephalopelvic","CS_postdates","CS_placenta","CS_macrosomia","CS_meconium","CS_uterineabnormality","CS_history","CS_other","CS_retained","delivery_fetaldistress","delivery_vaginalbleeding","delivery_shoulder","delivery_breach","delivery_cervical","delivery_abruption","delivery_malpresentation","delivery_maternalindication","delivery_failedinduction","delivery_cephalopelvic","delivery_postdates","delivery_placentaprevia","delivery_macrosomia","delivery_meconium","delivery_uterineabnormality","delivery_history","delivery_other")
cohort[variables]<-sapply(cohort[variables],as.character)
cohort[variables]<-sapply(cohort[variables],as.factor)

cohort$maternal_antepartum_pregnancy_complications<-NA
cohort<-within(cohort,maternal_antepartum_pregnancy_complications[cohort$preg_elevatedbloodpressure==1|cohort$preg_diabetes==1]<-1)
cohort<-within(cohort,maternal_antepartum_pregnancy_complications[cohort$preg_elevatedbloodpressure==0&cohort$preg_diabetes==0]<-0)
table(cohort$maternal_antepartum_pregnancy_complications)
test1a<-CreateTableOne(vars="maternal_antepartum_pregnancy_complications", strata="strata1",data=cohort)
test1b<-CreateTableOne(vars="maternal_antepartum_pregnancy_complications", strata="strata2",data=cohort)
test1c<-CreateTableOne(vars="maternal_antepartum_pregnancy_complications", strata="strata3",data=cohort)
test1d<-CreateTableOne(vars="maternal_antepartum_pregnancy_complications", strata="strata4",data=cohort)
test1a<-print(test1a)
test1b<-print(test1b)
test1c<-print(test1c)
test1d<-print(test1d)
write.csv(test1a,file="maternal_antepartum_complications1.csv")
write.csv(test1b,file="maternal_antepartum_complications2.csv")
write.csv(test1c,file="maternal_antepartum_complications3.csv")
write.csv(test1d,file="maternal_antepartum_complications4.csv")

cohort$pregnancy_complications<-NA
cohort<-within(cohort,pregnancy_complications[cohort$preg_abruption==1|cohort$preg_meconium==1|cohort$preg_vaginalbleeding==1|cohort$preg_pretermlabor==1|cohort$preg_cervicalincompetence==1|cohort$CS_fetaldistress==1|cohort$CS_abruption==1|cohort$CS_placenta==1|cohort$delivery_abruption==1|cohort$delivery_fetaldistress==1|cohort$delivery_shoulder==1|cohort$delivery_placentaprevia==1|cohort$delivery_meconium==1]<-1)
cohort<-within(cohort,pregnancy_complications[cohort$preg_abruption==0&cohort$preg_meconium==0&cohort$preg_vaginalbleeding==0&cohort$preg_pretermlabor==0&cohort$preg_cervicalincompetence==0&cohort$CS_fetaldistress==0&cohort$CS_abruption==0&cohort$CS_placenta==0&cohort$delivery_abruption==0&cohort$delivery_fetaldistress==0&cohort$delivery_shoulder==0&cohort$delivery_placentaprevia==0&cohort$delivery_meconium==0]<-0)
test2a<-CreateTableOne(vars="pregnancy_complications", strata="strata1",data=cohort)
test2b<-CreateTableOne(vars="pregnancy_complications", strata="strata2",data=cohort)
test2c<-CreateTableOne(vars="pregnancy_complications", strata="strata3",data=cohort)
test2d<-CreateTableOne(vars="pregnancy_complications", strata="strata4",data=cohort)
test2a<-print(test2a)
test2b<-print(test2b)
test2c<-print(test2c)
test2d<-print(test2d)
write.csv(test2a,file="pregnancy_complications1.csv")
write.csv(test2b,file="pregnancy_complications2.csv")
write.csv(test2c,file="pregnancy_complications3.csv")
write.csv(test2d,file="pregnancy_complications4.csv")

cohort$maternal_comorbidities<-NA
cohort<-within(cohort,maternal_comorbidities[cohort$preg_anemia==1|cohort$preg_elevatedbloodpressure==1|cohort$preg_diabetes==1|cohort$preg_asthma==1|cohort$preg_migraines==1|cohort$preg_genitourinaryinfection==1|cohort$preg_thyroiddisease==1|cohort$preg_other==1]<-1)
cohort<-within(cohort,maternal_comorbidities[cohort$preg_anemia==0&cohort$preg_elevatedbloodpressure==0&cohort$preg_diabetes==0&cohort$preg_asthma==0&cohort$preg_migraines==0&cohort$preg_genitourinaryinfection==0&cohort$preg_thyroiddisease==0&cohort$preg_other==0]<-0)
test3a<-CreateTableOne(vars="maternal_comorbidities", strata="strata1",data=cohort)
test3b<-CreateTableOne(vars="maternal_comorbidities", strata="strata2",data=cohort)
test3c<-CreateTableOne(vars="maternal_comorbidities", strata="strata3",data=cohort)
test3d<-CreateTableOne(vars="maternal_comorbidities", strata="strata4",data=cohort)
test3a<-print(test3a)
test3b<-print(test3b)
test3c<-print(test3c)
test3d<-print(test3d)
write.csv(test3a,file="maternal_comorbidities1.csv")
write.csv(test3b,file="maternal_comorbidities2.csv")
write.csv(test3c,file="maternal_comorbidities3.csv")
write.csv(test3d,file="maternal_comorbidities4.csv")

cohort$CS_for_fetaldistress<-NA
cohort<-within(cohort, CS_for_fetaldistress[cohort$CS_fetaldistress==1|cohort$CS_abruption==1]<-1)
cohort<-within(cohort, CS_for_fetaldistress[cohort$CS_fetaldistress==0&cohort$CS_abruption==0]<-0)
test4a<-CreateTableOne(vars="CS_for_fetaldistress", strata="strata1",data=cohort)
test4b<-CreateTableOne(vars="CS_for_fetaldistress", strata="strata2",data=cohort)
test4c<-CreateTableOne(vars="CS_for_fetaldistress", strata="strata3",data=cohort)
test4d<-CreateTableOne(vars="CS_for_fetaldistress", strata="strata4",data=cohort)
test4a<-print(test4a)
test4b<-print(test4b)
test4c<-print(test4c)
test4d<-print(test4d)
write.csv(test4a,file="CS_for_fetaldistress1.csv")
write.csv(test4b,file="CS_for_fetaldistress2.csv")
write.csv(test4c,file="CS_for_fetaldistress3.csv")
write.csv(test4d,file="CS_for_fetaldistress4.csv")

cohort$fetal_macrosomia<-NA
cohort<-within(cohort, fetal_macrosomia[cohort$delivery_macrosomia==1|cohort$CS_macrosomia==1|cohort$preg_macrosomia==1|cohort$preg_largefetus==1]<-1)
cohort<-within(cohort, fetal_macrosomia[cohort$delivery_macrosomia==0&cohort$CS_macrosomia==0&cohort$preg_macrosomia==0&cohort$preg_largefetus==0]<-0)
test5a<-CreateTableOne(vars="fetal_macrosomia", strata="strata1",data=cohort)
test5b<-CreateTableOne(vars="fetal_macrosomia", strata="strata2",data=cohort)
test5c<-CreateTableOne(vars="fetal_macrosomia", strata="strata3",data=cohort)
test5d<-CreateTableOne(vars="fetal_macrosomia", strata="strata4",data=cohort)
test5a<-print(test5a)
test5b<-print(test5b)
test5c<-print(test5c)
test5d<-print(test5d)
write.csv(test5a,file="fetal_macro1.csv")
write.csv(test5b,file="fetal_macro2.csv")
write.csv(test5c,file="fetal_macro3.csv")
write.csv(test5d,file="fetal_macro4.csv")

cohort$deliverycomplications_analysis<-NA
cohort<-within(cohort,deliverycomplications_analysis[cohort$CS_fetaldistress==1|cohort$CS_abruption==1|cohort$CS_placenta==1|cohort$CS_macrosomia==1|cohort$CS_meconium==1|cohort$delivery_fetaldistress==1|cohort$delivery_vaginalbleeding==1|cohort$delivery_shoulder==1|cohort$delivery_cervical==1|cohort$delivery_cervical==1|cohort$delivery_abruption==1|cohort$delivery_placentaprevia==1|cohort$delivery_meconium==1]<-1)
cohort<-within(cohort,deliverycomplications_analysis[cohort$CS_fetaldistress==0&cohort$CS_abruption==0&cohort$CS_placenta==0&cohort$CS_macrosomia==0&cohort$CS_meconium==0&cohort$delivery_fetaldistress==0&cohort$delivery_vaginalbleeding==0&cohort$delivery_shoulder==0&cohort$delivery_cervical==0&cohort$delivery_cervical==0&cohort$delivery_abruption==0&cohort$delivery_placentaprevia==0&cohort$delivery_meconium==0]<-0)
test6a<-CreateTableOne(vars="deliverycomplications_analysis", strata="strata1",data=cohort)
test6b<-CreateTableOne(vars="deliverycomplications_analysis", strata="strata2",data=cohort)
test6c<-CreateTableOne(vars="deliverycomplications_analysis", strata="strata3",data=cohort)
test6d<-CreateTableOne(vars="deliverycomplications_analysis", strata="strata4",data=cohort)
test6a<-print(test6a)
test6b<-print(test6b)
test6c<-print(test6c)
test6d<-print(test6d)
write.csv(test6a,file="delivery_complications1.csv")
write.csv(test6b,file="delivery_complications2.csv")
write.csv(test6c,file="delivery_complications3.csv")
write.csv(test6d,file="delivery_complications4.csv")

cohort$fetaldistress<-NA
cohort<-within(cohort,fetaldistress[cohort$CS_fetaldistress==1|cohort$CS_abruption==1|cohort$preg_abruption==1|cohort$preg_meconium==1|cohort$delivery_meconium==1|cohort$preg_meconium==1]<-1)
cohort<-within(cohort,fetaldistress[cohort$CS_fetaldistress==0&cohort$CS_abruption==0&cohort$preg_abruption==0&cohort$preg_meconium==0&cohort$delivery_meconium==0&cohort$preg_meconium==0]<-0)
test7a<-CreateTableOne(vars="fetaldistress", strata="strata1",data=cohort)
test7b<-CreateTableOne(vars="fetaldistress", strata="strata2",data=cohort)
test7c<-CreateTableOne(vars="fetaldistress", strata="strata3",data=cohort)
test7d<-CreateTableOne(vars="fetaldistress", strata="strata4",data=cohort)
test7a<-print(test7a)
test7b<-print(test7b)
test7c<-print(test7c)
test7d<-print(test7d)
write.csv(test7a,file="fetaldistress1.csv")
write.csv(test7b,file="fetaldistress2.csv")
write.csv(test7c,file="fetaldistress3.csv")
write.csv(test7d,file="fetaldistress4.csv")

cohort$delivery_method<-NA
cohort<-within(cohort,delivery_method[cohort$mode_of_delivery==1]<-"vaginal")
cohort<-within(cohort,delivery_method[cohort$mode_of_delivery==2]<-"CS")
test8a<-CreateTableOne(vars="delivery_method", strata="strata1",data=cohort)
test8b<-CreateTableOne(vars="delivery_method", strata="strata2",data=cohort)
test8c<-CreateTableOne(vars="delivery_method", strata="strata3",data=cohort)
test8d<-CreateTableOne(vars="delivery_method", strata="strata4",data=cohort)
test8a<-print(test8a)  
test8b<-print(test8b)  
test8c<-print(test8c)  
test8d<-print(test8d)  
write.csv(test8a,file="mode_of_delivery1.csv")
write.csv(test8b,file="mode_of_delivery2.csv")
write.csv(test8c,file="mode_of_delivery3.csv")
write.csv(test8d,file="mode_of_delivery4.csv")

#gestational weeks comaprison

cohort$gestationcategory<-NA
cohort <- within(cohort, gestationcategory[gestational_age_weeks <= 28] <-"<=28")
cohort <- within(cohort, gestationcategory[gestational_age_weeks >= 29 & gestational_age_weeks <=32] <- "29-32")
cohort <- within(cohort, gestationcategory[gestational_age_weeks >= 33 & gestational_age_weeks <=36] <- "33-36")
cohort <- within(cohort, gestationcategory[gestational_age_weeks >= 42] <-">=42")
t1<-CreateTableOne(vars = "gestationcategory", strata = "preg_chikvpos", data = cohort)
t1<-print(t1)
write.csv(t1, file = "gestationalweeks.csv")



#maternal characteristics comparison
cohort<- within(cohort, mother_age[cohort$mother_age>60|cohort$mother_age<15] <- NA) 
vars3 <-c("mother_age","occupation","previous_pregnancy","race","education","marrital_status","divorced_or_separated","repellent","coil","spray","net","collect_rain_water","store_water")
cohort[vars3] <- sapply(cohort[vars3],as.factor)
cohort$mother_age<-as.numeric(cohort$mother_age)
test10a<-CreateTableOne(vars=vars3, strata = "strata1", data = cohort)
p <- test10a[,"p.value"]
test10a$MetaData$
test10b<-CreateTableOne(vars=vars3, strata = "strata2", data = cohort)
test10c<-CreateTableOne(vars=vars3, strata = "strata3", data = cohort)
test10d<-CreateTableOne(vars=vars3, strata = "strata4", data = cohort)
test10e<-CreateTableOne(vars=vars3, strata = "strata5", data = cohort)
test10a<-print(test10a)
test10b<-print(test10b)
test10c<-print(test10c)
test10d<-print(test10d)
test10e<-print(test10e)
write.csv(test10a, file= "maternalcharacteristics1.csv")
write.csv(test10b, file= "maternalcharacteristics2.csv")
write.csv(test10c, file= "maternalcharacteristics3.csv")
write.csv(test10d, file= "maternalcharacteristics4.csv")
write.csv(test10e, file= "maternalcharacteristics5.csv")

#outcome by trimester
cohort$trimesterexposure1<-NA
cohort<- within(cohort, trimesterexposure1[cohort$trimester==1 & cohort$strata1==1] <- 1) 
cohort<- within(cohort, trimesterexposure1[cohort$trimester==2 & cohort$strata1==1] <- 2) 
cohort<- within(cohort, trimesterexposure1[cohort$trimester==3 & cohort$strata1==1] <- 3)
cohort$trimesterexposure2<-NA
cohort<- within(cohort, trimesterexposure2[cohort$trimester==1 & cohort$strata2==1] <- 1) 
cohort<- within(cohort, trimesterexposure2[cohort$trimester==2 & cohort$strata2==1] <- 2) 
cohort<- within(cohort, trimesterexposure2[cohort$trimester==3 & cohort$strata2==1] <- 3)
table(cohort$trimesterexposure1)
table(cohort$trimesterexposure2)
vars4<-c("symptoms___1", "symptoms___2", "symptoms___3", "symptoms___4", "symptoms___5", "symptoms___6", "symptoms___7", "symptoms___8", "symptoms___9", "symptoms___10", "symptoms___11", "symptoms___12", "symptoms___13", "symptoms___14", "symptoms___15", "symptoms___16", "symptoms___17", "symptoms___18", "symptoms___19", "symptoms___20", "symptoms___21", "symptoms___22", "symptoms___23", "symptoms___24", "symptoms___25", "symptoms___26", "symptoms___27", "symptoms___28", "symptoms___29", "symptoms___30", "symptoms___31", "symptoms___32", "symptoms___33", "symptoms___34")
test3<-CreateTableOne(vars=vars4, strata="trimesterexposure1", data = cohort)
test3<-print(test3)
test3a<-CreateTableOne(vars=vars4, strata="trimesterexposure2", data = cohort)
test3a<-print(test3a)
write.csv(test3, file= "trimester_outcomes1.csv")
write.csv(test3a, file= "trimester_outcomes2.csv")

#2 week neonatal outcomes
week2specific<-c("sicklecell_2weeks","jaundice_2weeks","anemia_2weeks","seizures_2weeks","growthrestriction_2weeks","NICU_2weeks","meconium_2weeks","poorfeeding_2weeks","hypoglycemia_2weeks","respiratorydistress_2weeks","eczema_2weeks","rash_2weeks","congenital_2weeks","fever_2weeks","infection_2weeks","GU_2weeks","hematologicabn_2weeks","chik_2weeks")
cohort[week2specific] <- sapply(cohort[week2specific],as.factor)
neonatal1a<-CreateTableOne(vars=week2specific, strata="strata1", data = cohort)
neonatal1b<-CreateTableOne(vars=week2specific, strata="strata2", data = cohort)
neonatal1c<-CreateTableOne(vars=week2specific, strata="strata3", data = cohort)
neonatal1d<-CreateTableOne(vars=week2specific, strata="strata4", data = cohort)
neonatal1e<-CreateTableOne(vars=week2specific, strata="strata5", data = cohort)
neonatal1a<-print(neonatal1a)
neonatal1b<-print(neonatal1b)
neonatal1c<-print(neonatal1c)
neonatal1d<-print(neonatal1d)
neonatal1e<-print(neonatal1e)
write.csv(neonatal1a, file="week2neonatal_specific_outcomes1.csv")
write.csv(neonatal1b, file="week2neonatal_specific_outcomes2.csv")
write.csv(neonatal1c, file="week2neonatal_specific_outcomes3.csv")
write.csv(neonatal1d, file="week2neonatal_specific_outcomes4.csv")
write.csv(neonatal1e, file="week2neonatal_specific_outcomes5.csv")
week2general<-c("jaundice_2weeks","hematologicgen_2weeks","seizuresgen_2weeks","NICUgen_2weeks","respiratorydistress_2weeks","skincondition_2weeks","infectiongen_2weeks","fever_2weeks","congenital_2weeks","chik_2weeks")
cohort[week2general] <- sapply(cohort[week2general],as.factor)
neonatal2a<-CreateTableOne(vars=week2general, strata="strata1", data = cohort)
neonatal2b<-CreateTableOne(vars=week2general, strata="strata2", data = cohort)
neonatal2c<-CreateTableOne(vars=week2general, strata="strata3", data = cohort)
neonatal2d<-CreateTableOne(vars=week2general, strata="strata4", data = cohort)
neonatal2e<-CreateTableOne(vars=week2general, strata="strata5", data = cohort)
neonatal2a<-print(neonatal2a)
neonatal2b<-print(neonatal2b)
neonatal2c<-print(neonatal2c)
neonatal2d<-print(neonatal2d)
neonatal2e<-print(neonatal2e)
write.csv(neonatal2a, file="week2neonatal_general_outcomes1.csv")
write.csv(neonatal2b, file="week2neonatal_general_outcomes2.csv")
write.csv(neonatal2c, file="week2neonatal_general_outcomes3.csv")
write.csv(neonatal2d, file="week2neonatal_general_outcomes4.csv")
write.csv(neonatal2e, file="week2neonatal_general_outcomes5.csv")
week2composite<-c("seizuresgen_2weeks","NICUgen_2weeks","respiratorydistress_2weeks")
cohort$weekcompositesevere_sum<-as.integer(rowSums(cohort[ , week2composite]))
neonatal3a<-CreateTableOne(vars="weekcompositesevere_sum", strata="strata1", data = cohort)
neonatal3b<-CreateTableOne(vars="weekcompositesevere_sum", strata="strata2", data = cohort)
neonatal3c<-CreateTableOne(vars="weekcompositesevere_sum", strata="strata3", data = cohort)
neonatal3d<-CreateTableOne(vars="weekcompositesevere_sum", strata="strata4", data = cohort)
neonatal3e<-CreateTableOne(vars="weekcompositesevere_sum", strata="strata5", data = cohort)
neonatal3a<-print(neonatal3a)
neonatal3b<-print(neonatal3b)
neonatal3c<-print(neonatal3c)
neonatal3d<-print(neonatal3d)
neonatal3e<-print(neonatal3e)
write.csv(neonatal3a, file="week2_composite_severe1.csv")
write.csv(neonatal3b, file="week2_composite_severe2.csv")
write.csv(neonatal3c, file="week2_composite_severe3.csv")
write.csv(neonatal3d, file="week2_composite_severe4.csv")
write.csv(neonatal3e, file="week2_composite_severe5.csv")
cohort$weektotalcomposite<-as.integer(rowSums(cohort[ ,week2specific]))
neonatal4a<-CreateTableOne(vars="weektotalcomposite", strata="strata1", data = cohort)
neonatal4b<-CreateTableOne(vars="weektotalcomposite", strata="strata2", data = cohort)
neonatal4c<-CreateTableOne(vars="weektotalcomposite", strata="strata3", data = cohort)
neonatal4d<-CreateTableOne(vars="weektotalcomposite", strata="strata4", data = cohort)
neonatal4e<-CreateTableOne(vars="weektotalcomposite", strata="strata5", data = cohort)
neonatal4a<-print(neonatal4a)
neonatal4b<-print(neonatal4b)
neonatal4c<-print(neonatal4c)
neonatal4d<-print(neonatal4d)
neonatal4e<-print(neonatal4e)
write.csv(neonatal4a, file="week2_composite_severe1.csv")
write.csv(neonatal4b, file="week2_composite_severe2.csv")
write.csv(neonatal4c, file="week2_composite_severe3.csv")
write.csv(neonatal4d, file="week2_composite_severe4.csv")
write.csv(neonatal4e, file="week2_composite_severe5.csv")

#month neonatal outcomes
monthspecific<-c("sicklecell_month","jaundice_month","anemia_month","seizures_month","failuretothrive_month","NICU_month","respiratorydistress_month","eczema_month","rash_month","congential_month","fever_month","infection_month","hematologicabn_month","chik_month")
cohort[monthspecific] <- sapply(cohort[monthspecific],as.factor)
neonatal5a<-CreateTableOne(vars=monthspecific, strata="strata1", data = cohort)
neonatal5b<-CreateTableOne(vars=monthspecific, strata="strata2", data = cohort)
neonatal5c<-CreateTableOne(vars=monthspecific, strata="strata3", data = cohort)
neonatal5d<-CreateTableOne(vars=monthspecific, strata="strata4", data = cohort)
neonatal5e<-CreateTableOne(vars=monthspecific, strata="strata5", data = cohort)
neonatal5a<-print(neonatal5a)
neonatal5b<-print(neonatal5b)
neonatal5c<-print(neonatal5c)
neonatal5d<-print(neonatal5d)
neonatal5e<-print(neonatal5e)
write.csv(neonatal5a, file="month_specific_neonatal_outcomes1.csv")
write.csv(neonatal5b, file="month_specific_neonatal_outcomes2.csv")
write.csv(neonatal5c, file="month_specific_neonatal_outcomes3.csv")
write.csv(neonatal5d, file="month_specific_neonatal_outcomes4.csv")
write.csv(neonatal5e, file="month_specific_neonatal_outcomes5.csv")
monthgeneral<-c("jaundice_month", "hematologicgen_month",
                "seizures_month", "NICU_month", "respiratorydistress_month","skincondition_month","infectiongen_month","congential_month","chik_month")
cohort[monthgeneral] <- sapply(cohort[monthgeneral],as.factor)
neonatal6a<-CreateTableOne(vars=monthgeneral, strata="strata1", data = cohort)
neonatal6b<-CreateTableOne(vars=monthgeneral, strata="strata2", data = cohort)
neonatal6c<-CreateTableOne(vars=monthgeneral, strata="strata3", data = cohort)
neonatal6d<-CreateTableOne(vars=monthgeneral, strata="strata4", data = cohort)
neonatal6e<-CreateTableOne(vars=monthgeneral, strata="strata5", data = cohort)
neonatal6a<-print(neonatal6a)
neonatal6b<-print(neonatal6b)
neonatal6c<-print(neonatal6c)
neonatal6d<-print(neonatal6d)
neonatal6e<-print(neonatal6e)
write.csv(neonatal6a, file="month_general_neonatal_outcomes1.csv")
write.csv(neonatal6b, file="month_general_neonatal_outcomes2.csv")
write.csv(neonatal6c, file="month_general_neonatal_outcomes3.csv")
write.csv(neonatal6d, file="month_general_neonatal_outcomes4.csv")
write.csv(neonatal6e, file="month_general_neonatal_outcomes5.csv")
monthcomposite<-c("seizures_month", "NICU_month", "respiratorydistress_month")
class(monthcomposite)
monthcomposite<-as.numeric(monthcomposite)
cohort$monthcompositivesevere_sum<-as.integer(rowSums(cohort[ , monthcomposite]))
neonatal7a<-CreateTableOne(vars="monthcompositivesevere_sum", strata="strata1", data = cohort)
neonatal7b<-CreateTableOne(vars="monthcompositivesevere_sum", strata="strata2", data = cohort)
neonatal7c<-CreateTableOne(vars="monthcompositivesevere_sum", strata="strata3", data = cohort)
neonatal7d<-CreateTableOne(vars="monthcompositivesevere_sum", strata="strata4", data = cohort)
neonatal7e<-CreateTableOne(vars="monthcompositivesevere_sum", strata="strata5", data = cohort)
neonatal7a<-print(neonatal7a)
neonatal7b<-print(neonatal7b)
neonatal7c<-print(neonatal7c)
neonatal7d<-print(neonatal7d)
neonatal7e<-print(neonatal7e)
write.csv(neonatal7a, file="monthcompositivesevere_sum_outcomes1.csv")
write.csv(neonatal7b, file="monthcompositivesevere_sum_outcomes2.csv")
write.csv(neonatal7c, file="monthcompositivesevere_sum_outcomes3.csv")
write.csv(neonatal7d, file="monthcompositivesevere_sum_outcomes4.csv")
write.csv(neonatal7e, file="monthcompositivesevere_sum_outcomes5.csv")
cohort$monthtotalcomposite<-as.integer(rowSums(cohort[ ,monthspecific]))
neonatal8a<-CreateTableOne(vars="monthtotalcomposite", strata="strata1", data = cohort)
neonatal8b<-CreateTableOne(vars="monthtotalcomposite", strata="strata2", data = cohort)
neonatal8c<-CreateTableOne(vars="monthtotalcomposite", strata="strata3", data = cohort)
neonatal8d<-CreateTableOne(vars="monthtotalcomposite", strata="strata4", data = cohort)
neonatal8e<-CreateTableOne(vars="monthtotalcomposite", strata="strata5", data = cohort)
neonatal8a<-print(neonatal8a)
neonatal8b<-print(neonatal8b)
neonatal8c<-print(neonatal8c)
neonatal8d<-print(neonatal8d)
neonatal8e<-print(neonatal8e)
write.csv(neonatal7a, file="monthtotalcomposite_outcomes1.csv")
write.csv(neonatal7b, file="monthtotalcomposite_sum_outcomes2.csv")
write.csv(neonatal7c, file="monthtotalcomposite_sum_outcomes3.csv")
write.csv(neonatal7d, file="monthtotalcomposite_sum_outcomes4.csv")
write.csv(neonatal7e, file="monthtotalcomposite_sum_outcomes5.csv")


#total symptoms

cohort$symptoms_sum<- as.integer(rowSums(cohort[ , vars4]))
class(cohort$symptoms_sum)
test4<-CreateTableOne(vars="symptoms_sum", strata="strata1", data=cohort)
test4<-print(test4)
write.csv(test4, file = "totalsymptoms1.csv")



# model logit -------------------------------------------------------------
### 2 weeks 
cohort$neonatal_2weeks <- as.integer(rowSums(cohort[ , grep("_2week" , names(cohort))]))
table(cohort$neonatal_2weeks)
cohort$neonatal_2weeks_binary <- as.numeric(cohort$neonatal_2weeks>=1)
table(cohort$neonatal_2weeks_binary)

model_2weeeks <- glm(neonatal_2weeks_binary ~mother_age.x + gestatiol_age_weeks.x,family=binomial(link='logit'),data=cohort)

summary(model_2weeeks)
anova(model_2weeeks, test="Chisq")
exp(cbind(OR = coef(model_2weeeks), confint(model_2weeeks)))


### 4 weeks 
cohort$neonatal_month <- as.integer(rowSums(cohort[ , grep("_month" , names(cohort))]))
table(cohort$neonatal_month)
cohort$neonatal_month_binary <- as.numeric(cohort$neonatal_month>=1)
table(cohort$neonatal_month_binary)

model_month <- glm(neonatal_month_binary ~mother_age.x + gestatiol_age_weeks.x,family=binomial(link='logit'),data=cohort)

summary(model_month)
anova(model_month, test="Chisq")
exp(cbind(OR = coef(model_month), confint(model_month)))


# model beta binomial -----------------------------------------------------
install.packages("gamlss")
library("gamlss")

# model poisson -----------------------------------------------------------



# kaplan meier curve of joint pain by group ---------------------------------------------------------------
### duration of jp 
## I couldn't get your code to run so i am importing clea data.
# please insert the correct strata here. my n is larger than yours in the table.
library(readr)
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/fogarty chikv")
cohort <- read_csv("C:/Users/amykr/Box Sync/Amy Krystosik's Files/fogarty chikv/FogartyNDCHIKV_DATA_2019-02-07_1043.csv")

cohort$strata5<-NA
cohort<-within(cohort, strata5[result_mother==1 & pregnant==0]<-0)
cohort <- within(cohort, strata5[result_mother==1 & pregnant ==1&symptoms___4==1&(symptoms___1==1|symptoms___3==1|symptoms___5==1|symptoms___6==1|symptoms___25==1)] <- 1)

strata5_excluded<-cohort[which(is.na(cohort$strata5)),]
table(cohort$strata5,exclude = NULL)

cohort$dd<-as.numeric(cohort$primary_date-cohort$when)

cohort$duration<-ifelse(cohort$joint_pain_since!=1,cohort$dd,NA)
cohort$duration<-ifelse(cohort$joint_pain_last_month==1,cohort$dd-30,NA)
cohort$duration<-ifelse(cohort$joint_pain_last_week==1,cohort$dd-7,cohort$duration)
cohort$duration<-ifelse(cohort$joint_pain_today==1,cohort$dd,cohort$duration)

cohort$pregnant<-as.factor(cohort$pregnant)
library(ggplot2)
ggplot<-ggplot(cohort,aes(x=pregnant,y=duration))
ggplot + geom_boxplot()

library(statar)
cohort$dd_cat<-xtile(cohort$dd, n = 10)
table(cohort$dd_cat)
hist(cohort$dd)
library(plyr)
library(tidyverse)
fig <- ddply(cohort, .(pregnant,dd_cat),
             summarise, 
             joint_pain_today_mean = mean(joint_pain_today, na.rm = TRUE),
             joint_pain_last_week_mean = mean(joint_pain_last_week, na.rm = TRUE),
             joint_pain_last_month_mean = mean(joint_pain_last_month, na.rm = TRUE),
             joint_pain_today_sd = sd(joint_pain_today, na.rm = TRUE),
             joint_pain_last_week_sd = sd(joint_pain_last_week, na.rm = TRUE),
             joint_pain_last_month_sd = sd(joint_pain_last_month, na.rm = TRUE)
)

### survival analysis 
cohort$today<-cohort$primary_date
cohort$last_week<-cohort$primary_date-7
cohort$last_month<-cohort$primary_date-30
cohort$onset<-cohort$when

cohort_covariates<-cohort[c("participant_id","mother_age","race")]
names(cohort_covariates)<-c("id", "mother_age","race")
cohort_covariates<-subset(cohort_covariates,!duplicated(cohort_covariates$id))
cohort_long<-cohort[c("participant_id","strata5","onset","joint_pain_today", "joint_pain_last_week", "joint_pain_last_month","last_week","last_month","today")]
names(cohort_long)<-c("id", "strata5","onset","jp_today","jp_lastweek","jp_lastmonth", "date_lastweek","date_lastmonth","date_today")
cohort_long<-as.data.frame(subset(cohort_long,!duplicated(cohort_long$id)))

cohort_long<-reshape(cohort_long, varying = 4:9, timevar = "when", idvar = "id", direction="long",sep="_")
cohort_long<-merge(cohort_long,cohort_covariates,by="id")

library(survival)
#install.packages("survminer")
library(survminer)
library(dplyr)
cohort_long$fu<-as.numeric(cohort_long$date-cohort_long$onset)
cohort_long$jp_cure<-NA
cohort_long <- within(cohort_long, jp_cure[jp==0] <- 1)
cohort_long <- within(cohort_long, jp_cure[jp==1] <- 0)
table(cohort_long$jp_cure)
require("survival")
fit <-survfit(Surv(fu, jp)~strata5, data=cohort_long)
tiff(filename = "joint_paint_preg.tiff",width = 5200, height = 4200, units = "px", res = 800)
ggsurvplot(fit, data = cohort_long, legend = "top", surv.median.line = "hv", legend.title = "CHIKV Infection Timing", legend.labs = c("Not pregnant", "Pregnant"), pval = TRUE, conf.int = TRUE, risk.table = TRUE, tables.height = 0.2, tables.theme = theme_cleantable(), ggtheme = theme_bw())+xlab("Time (days from acute infection)")+ylab("Persistance of joint pain")
dev.off()   
write.csv(cohort_long,"joint_point_duration_days.csv")
cohort_jp<-cohort[,c("pregnant","joint_pain_today","joint_pain_last_week","joint_pain_last_month","onset","joint_pain_since","participant_id")]
write.csv(cohort_jp,"joint_point.csv")

### cox ph model of joint pain by group ---------------------------------------------------------------
fit <-survfit(Surv(fu, jp)~strata5+ mother_age + race, data=cohort_long)
summary( coxph(Surv(fu, jp) ~ strata5+ mother_age + race, cohort_long),na.action="na.omit")
