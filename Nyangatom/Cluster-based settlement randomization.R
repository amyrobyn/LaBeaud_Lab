library(data.table)
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Nyangatom")
villages <- read.csv("villages.csv")
names(villages)[7] <- "settlement_village_ID"
names(villages)[9] <- "adminsitrative_kebele"
names(villages)[27] <- "cluster_number"

df <- subset(villages, select = c("settlement_village_ID",  "adminsitrative_kebele",  "cluster_number"))

#method 1
setDT(df)
df[, sample_membership := sample.int(12, .N, replace=T), keyby = .(cluster_number, settlement_village_ID)]
glimpse(df)

#method 2
# get number of observations for each group
groupCnt <- with(df, aggregate(cluster_number, list(cluster_number, settlement_village_ID), FUN=length))$x

# for reproducibility, set the seed
set.seed(1234)    
# get sample by group
df$sample <- c(sapply(groupCnt, function(i) sample(12, i, replace=TRUE)))
glimpse(df)
