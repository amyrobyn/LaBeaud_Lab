library(stringr)
#link villages to cornelius list of kisumu villages
setwd("C:/Users/amykr/Box Sync/DENV CHIKV project/gps")
kisumu_villages<-read.csv("Kisumu Villages_Estates.csv")
kisumu_villages$Site<-"Kisumu"
kisumu_villages$Region<-"West"
villages<-read.csv("Kenya Villages fm.csv")
villages$Raw.Village<-tolower(villages$Raw.Village)
kisumu_villages$Raw.Village<-tolower(kisumu_villages$Village.Estate)
kisumu_villages$Raw.Village<-str_trim(kisumu_villages$Raw.Village) 
villages$Raw.Village<-str_trim(villages$Raw.Village) 

villages$Raw.Village<-str_replace_all(villages$Raw.Village, fixed(" "), "")
kisumu_villages$Raw.Village<-str_replace_all(kisumu_villages$Raw.Village, fixed(" "), "")

villages <- join(kisumu_villages, villages,  by='Raw.Village', type='full', match='all')
villages<-villages[!duplicated(villages$Raw.Village), ]
table(villages$Site, villages$Region, exclude = NULL)

gps_points<-read.csv("C:/Users/amykr/Box Sync/DENV CHIKV project/gps/village gps points/village gps points.csv")
gps_points$Raw.Village<-gps_points$village
gps_points$Raw.Village<-tolower(gps_points$Raw.Village)
gps_points$Raw.Village<-str_trim(gps_points$Raw.Village) 
gps_points$Raw.Village<-str_trim(gps_points$Raw.Village) 

villages <- join(gps_points, villages,  by='Raw.Village', type='full', match='all')
villages <- villages[,colSums(is.na(villages))<nrow(villages)]

write.csv(villages, "villages.csv", sep = ",", na="")
