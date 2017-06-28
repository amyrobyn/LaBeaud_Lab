library(xlsx)
library(data.table)
library(dplyr)
library(plyr)

setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Nyangatom")

villages <- read.csv("Gnangatom_Villages_Clustered_with_Coords_matchesGPX.csv")
names(villages)[27] <- "cluster_number"
names(villages)[7] <- "settlement_village_ID"
names(villages)[9] <- "adminsitrative_kebele"

villages <- subset(villages, select = c("cluster_number", "settlement_village_ID", "adminsitrative_kebele"))

set.seed(1)
cluster_rank<-sample(1:15, 15, replace=F)
cluster_number<-unique(villages$cluster_number)
random_cluster<-rbind(cluster_rank, cluster_number)
random_cluster<-t(random_cluster)

villages<-data.table(villages, key="cluster_number")[
  data.table(random_cluster, key="cluster_number"),
  allow.cartesian=TRUE
  ]

villages<-plyr::ddply(villages, .(cluster_number), transform, settlement_village_count = length(settlement_village_ID))

for (i in  villages$cluster_number){
  assign(paste0("cluster", i), data.frame(subset(villages, villages$cluster_number==i)))
}

dfList <- lapply(0:14, function(x){paste0("cluster", x)})
dfList <- list(df0=cluster0,df1=cluster1,df2=cluster2,df3=cluster3,df4=cluster4,df5=cluster5,df6=cluster6,df7=cluster7,
               df8=cluster8,df9=cluster9,df10=cluster10,df11=cluster11,df12=cluster12,df13=cluster13,df14=cluster14)

dfList<-lapply(dfList, function(x) {
  settlement_village_count<-mean(x$settlement_village_count)
  sample(1:settlement_village_count, settlement_village_count, replace=F) -> x$settlement_village_rank; x
} ) 

cluster_based_settlement_randomization <- do.call("rbind", dfList)
cluster_based_settlement_randomization<-cluster_based_settlement_randomization[c(1, 4, 2, 3, 6)]


Gnangatom_Villages_Clustered_with_Coords_matchesGPX <- read.csv("Gnangatom_Villages_Clustered_with_Coords_matchesGPX.csv")
Gnangatom_Villages_Clustered_with_Coords_matchesGPX_random<-data.table(Gnangatom_Villages_Clustered_with_Coords_matchesGPX, key="name")[
  data.table(cluster_based_settlement_randomization, key="settlement_village_ID"),
  allow.cartesian=TRUE
  ]

f <- "Gnangatom_Villages_Clustered_with_Coords_matchesGPX_random.xls"
write.xlsx(as.data.frame(Gnangatom_Villages_Clustered_with_Coords_matchesGPX_random), f, sheetName = "randomized_rank", col.names = TRUE,
           row.names = FALSE, append = FALSE, showNA = TRUE)
