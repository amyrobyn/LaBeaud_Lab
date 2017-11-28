setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Nyangatom")
df<-read.csv("Nyangatom_DATA_2017-11-27_0946.csv")
summary(df)

library(psych)
describe<-describe(df)

write.csv(as.data.frame(describe), "describe.csv")