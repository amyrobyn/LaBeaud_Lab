df<-read.csv("C:/Users/amykr/Box Sync/Amy Krystosik's Files/fogarty chikv/megan_regressiondata.csv")
sapply(df, class)

# 2 weeks -----------------------------------------------------------------
df$neonatal_2weeks <- as.integer(rowSums(df[ , grep("_2week" , names(df))]))
table(df$neonatal_2weeks)
df$neonatal_2weeks_binary <- as.numeric(df$neonatal_2weeks>=1)
table(df$neonatal_2weeks_binary)

model_2weeeks <- glm(neonatal_2weeks_binary ~mother_age.x + gestatiol_age_weeks.x,family=binomial(link='logit'),data=df)

summary(model_2weeeks)
anova(model_2weeeks, test="Chisq")
exp(cbind(OR = coef(model_2weeeks), confint(model_2weeeks)))


# month -------------------------------------------------------------------
df$neonatal_month <- as.integer(rowSums(df[ , grep("_month" , names(df))]))
table(df$neonatal_month)
df$neonatal_month_binary <- as.numeric(df$neonatal_month>=1)
table(df$neonatal_month_binary)

model_month <- glm(neonatal_month_binary ~mother_age.x + gestatiol_age_weeks.x,family=binomial(link='logit'),data=df)

summary(model_month)
anova(model_month, test="Chisq")
exp(cbind(OR = coef(model_month), confint(model_month)))
