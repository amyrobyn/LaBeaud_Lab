
library(tableone)

setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Nyangatom")
df<-read.csv("Nyangatom_DATA_2017-11-27_0946.csv")

df[df==99] <-NA#replace 99 with NA
df[df==98] <-NA#replace 98 with NA

summary(df)

library(psych)
describe<-describe(df)

write.csv(as.data.frame(describe), "describe.csv")

vars<-c("married_current","wife_ranking","birth_total", "livestock_holdings","child_size","sex_child")
factorVars<-c("married_current","wife_ranking","sex_child","livestock_holdings")

table(df$cluster, exclude=NULL)

hannahstable <- CreateTableOne(vars = vars, factorVars = factorVars, strata = "cluster", data = df)
