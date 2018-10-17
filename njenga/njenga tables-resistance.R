setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/njenga/")
datOG <- read.csv("C:/Users/amykr/Box Sync/Amy Krystosik's Files/njenga/BTI susectibility data 2-controls_max.csv", stringsAsFactors = FALSE)
## lots of blank columns

dat <- datOG[, c(1:14)]
dat[, c(1:3)] <- lapply(dat[, c(1:3)], function(x) as.Date(x, format="%m/%d/%y"))

## for some reason dat$EndDate has some 2017 years -- don't think this is right, need to change to 2016
dat$EndDate[grep("2017-", dat$EndDate)] <- gsub("2017-", "2016-", dat$EndDate[grep("2017-", dat$EndDate)])

## some of the data is messy -- there are a handful that have total.larva == 0, I assume these should all be == 10
dat$total.larva[dat$total.larva==0] <- 10
# for dat$BTI_conc=="0.016g/l control" and "0.016g/l" -- days 21:24 have wrong date, should be February not January
dat$Date[dat$BTI_conc %in% c("0.016g/l control", "0.016g/l") & dat$Day %in% c(21:24)] <- gsub("-01-", "-02-", dat$Date[dat$BTI_conc %in% c("0.016g/l control", "0.016g/l") & dat$Day %in% c(21:24)])

## total.larva.inset is always 10; total.larva.inrep is dat$total.larva*dat$larval.set
dat$total.larva.inset <- 10
dat$total.larva.inrep <- dat$total.larva*dat$larval.set

## rolling_sum is how many have died each day
dat$larva.dead.inset <- dat$rolling_sum

dat$larva.alive.inset <- dat$total.larva.inset - dat$rolling_sum

# http://lukemiller.org/index.php/2010/02/calculating-lt50-median-lethal-temperature-aka-ld50-quickly-in-r/
require(MASS)
## 0.016 g/l DRY
y <- cbind(dat$larva.alive.inset[dat$Season=="DRY" & dat$BTI_conc=="0.016g/l"], dat$larva.dead.inset[dat$Season=="DRY" & dat$BTI_conc=="0.016g/l"])
dry.016mod <- glm(y~ bti.age, family = "binomial",data=dat[dat$Season=="DRY" & dat$BTI_conc=="0.016g/l",])
summary(dry.016mod)
dose.p(dry.016mod, p=c(0.5, 0.9))
dose.p(update(dry.016mod, family=binomial(link = probit)), p=c(0.5,0.9))
## 0.016 g/l Rainy
y <- cbind(dat$larva.alive.inset[dat$Season=="Rainy" & dat$BTI_conc=="0.016g/l"], dat$larva.dead.inset[dat$Season=="Rainy" & dat$BTI_conc=="0.016g/l"])
rainy.016mod <- glm(y~ bti.age, family = "binomial",data=dat[dat$Season=="Rainy" & dat$BTI_conc=="0.016g/l",])
summary(rainy.016mod)
dose.p(rainy.016mod, p=c(0.5, 0.9))
dose.p(update(rainy.016mod, family=binomial(link = probit)), p=c(0.5,0.9))

## 0.16 g/l DRY
y <- cbind(dat$larva.alive.inset[dat$Season=="DRY" & dat$BTI_conc=="0.16g/l"], dat$larva.dead.inset[dat$Season=="DRY" & dat$BTI_conc=="0.16g/l"])
dry.16mod <- glm(y~ bti.age, family = "binomial",data=dat[dat$Season=="DRY" & dat$BTI_conc=="0.16g/l",])
summary(dry.16mod)
dose.p(dry.16mod, p=c(0.5, 0.9))
dose.p(update(dry.16mod, family=binomial(link = probit)), p=c(0.5,0.9))
## 0.16 g/l Rainy
y <- cbind(dat$larva.alive.inset[dat$Season=="Rainy" & dat$BTI_conc=="0.16g/l"], dat$larva.dead.inset[dat$Season=="Rainy" & dat$BTI_conc=="0.16g/l"])
rainy.16mod <- glm(y~ bti.age, family = "binomial",data=dat[dat$Season=="Rainy" & dat$BTI_conc=="0.16g/l",])
summary(rainy.16mod)
dose.p(rainy.16mod, p=c(0.5, 0.9))
dose.p(update(rainy.16mod, family=binomial(link = probit)), p=c(0.5,0.9))

## 0.32 g/l DRY
y <- cbind(dat$larva.alive.inset[dat$Season=="DRY" & dat$BTI_conc=="0.32g/l"], dat$larva.dead.inset[dat$Season=="DRY" & dat$BTI_conc=="0.32g/l"])
dry.32mod <- glm(y~ bti.age, family = "binomial",data=dat[dat$Season=="DRY" & dat$BTI_conc=="0.32g/l",])
summary(dry.32mod)
dose.p(dry.32mod, p=c(0.5, 0.9))
dose.p(update(dry.32mod, family=binomial(link = probit)), p=c(0.5,0.9))
## 0.32 g/l Rainy
y <- cbind(dat$larva.alive.inset[dat$Season=="Rainy" & dat$BTI_conc=="0.32g/l"], dat$larva.dead.inset[dat$Season=="Rainy" & dat$BTI_conc=="0.32g/l"])
rainy.32mod <- glm(y~ bti.age, family = "binomial",data=dat[dat$Season=="Rainy" & dat$BTI_conc=="0.32g/l",])
summary(rainy.32mod)
dose.p(rainy.32mod, p=c(0.5, 0.9))
dose.p(update(rainy.32mod, family=binomial(link = probit)), p=c(0.5,0.9))



### make some figures?
require(ggplot2)
dat$prop.alive.inset <- dat$larva.alive.inset / (dat$larva.alive.inset + dat$larva.dead.inset)
dat$prop.dead.inset <- dat$larva.dead.inset / (dat$larva.alive.inset + dat$larva.dead.inset)


dat$day<-dat$Day
dat$day<-ifelse(dat$day>36,dat$day-36,dat$day)
table(dat$day,dat$Season)
dat$day_group<-cut(dat$day,c(0,6,12,18,24,30,36),right=TRUE)	
dat$bti.age_group<-cut(dat$bti.age,c(0,6,12,18,24,30,36),right=TRUE)

table(dat$bti.age_group,dat$BTI_conc,dat$Season)
prop.table(table(dat$bti.age_group,dat$BTI_conc,dat$Season),2)
write.csv(dat,file="njenga.csv")

library(dplyr)
mortality_by_groups<-dat %>%group_by(bti.age_group,BTI_conc,Season) %>%summarize(mean_mortality = mean(prop.dead.inset, na.rm = TRUE),mean_mortality_sd = sd(prop.dead.inset, na.rm = TRUE),count=length(prop.dead.inset))
write.csv(mortality_by_groups,file="mortality_by_groups.csv")
# test daily mortality by conc --------------------------------------------
test<-mortality_by_groups%>%tidyr::spread(bti.age_group,mean_mortality)
test$control<-ifelse(grepl("control",test$BTI_conc),T,F)
names(test) <- sub(",", "_", names(test))
names(test) <- sub("]", "", names(test))
names(test) <- sub("\\(", "", names(test))
vars=c("0_6","6_12","12_18","18_24","24_30","30_36")

tableOne<-tableone::CreateTableOne(data=test[test$control=="FALSE",],vars=vars,strata=c("BTI_conc"))
table1 <- print(tableOne, quote = FALSE, noSpaces = TRUE, printToggle = FALSE)
write.csv(table1, file = "daily_mortality_bticonc.csv")
# test daily mortality by Season --------------------------------------------
tableOne<-tableone::CreateTableOne(data=test[test$control=="FALSE",],vars=vars,strata=c("Season"))
table1 <- print(tableOne, quote = FALSE, noSpaces = TRUE, printToggle = FALSE)
write.csv(table1, file = "daily_mortality_season.csv")
# test daily mortality by Season & Conc --------------------------------------------
tableOne<-tableone::CreateTableOne(data=test[test$control=="FALSE",],vars=vars,strata=c("Season","BTI_conc"))
table1 <- print(tableOne, quote = FALSE, noSpaces = TRUE, printToggle = FALSE)
write.csv(table1, file = "daily_mortality_season_conc.csv")

hist(dat$prop.dead.inset, breaks=100)
t.test(dat$prop.dead.inset~dat$Season)
summary(aov(prop.dead.inset~bti.age_group,data=dat))
summary(aov(prop.dead.inset~BTI_conc,data=dat))

summary(glm(prop.dead.inset~bti.age_group+BTI_conc+Season, family="binomial",data= dat))
library(fitdistrplus)
fitdistr(dat$prop.dead.inset,"Normal")
descdist(dat$prop.dead.inset, discrete = FALSE)
fit.norm <- fitdist(dat$prop.dead.inset, "norm")
plot(fit.norm)
install.packages("gamlss")

library(gamlss)
beinf<-gamlss(prop.dead.inset~bti.age_group+BTI_conc+Season, data=na.omit(dat),family=BEINF())
summary(beinf)
plot(beinf)

## 0.016 g/l DRY
png("C:/Users/amykr/Box Sync/Amy Krystosik's Files/njenga/Dry16mg.png",width = 800, height=600, units="px")
ggplot(data=dat[dat$Season=="DRY" & dat$BTI_conc=="0.016g/l" & dat$replicates!=0,], aes(x=bti.age, y=prop.dead.inset, color=as.factor(replicates))) + geom_point() + theme_bw(base_size = 15) + labs(x="BTI Age (days)", y="Proportion Dead", title="0.016g/l BTI (Dry Season)", color="Replicate Number")
dev.off()
## 0.016 g/l Rainy
png("C:/Users/amykr/Box Sync/Amy Krystosik's Files/njenga/Rainy16mg.png",width = 800, height=600, units="px")
ggplot(data=dat[dat$Season=="Rainy" & dat$BTI_conc=="0.016g/l" & dat$replicates!=0,], aes(x=bti.age, y=prop.dead.inset, color=as.factor(replicates))) + geom_point() + theme_bw(base_size = 15) + labs(x="BTI Age (days)", y="Proportion Dead", title="0.016g/l BTI (Rainy Season)", color="Replicate Number")
dev.off()

## 0.16 g/l DRY
png("C:/Users/amykr/Box Sync/Amy Krystosik's Files/njenga/Dry160mg.png",width = 800, height=600, units="px")
ggplot(data=dat[dat$Season=="DRY" & dat$BTI_conc=="0.16g/l" & dat$replicates!=0,], aes(x=bti.age, y=prop.dead.inset, color=as.factor(replicates))) + geom_point() + theme_bw(base_size = 15) + labs(x="BTI Age (days)", y="Proportion Dead", title="0.16g/l BTI (Dry Season)", color="Replicate Number")
dev.off()
## 0.16 g/l Rainy
png("C:/Users/amykr/Box Sync/Amy Krystosik's Files/njenga/Rainy160mg.png",width = 800, height=600, units="px")
ggplot(data=dat[dat$Season=="Rainy" & dat$BTI_conc=="0.16g/l" & dat$replicates!=0,], aes(x=bti.age, y=prop.dead.inset, color=as.factor(replicates))) + geom_point() + theme_bw(base_size = 15) + labs(x="BTI Age (days)", y="Proportion Dead", title="0.16g/l BTI (Rainy Season)", color="Replicate Number")
dev.off()

## 0.32 g/l DRY
png("C:/Users/amykr/Box Sync/Amy Krystosik's Files/njenga/Dry320mg.png",width = 800, height=600, units="px")
ggplot(data=dat[dat$Season=="DRY" & dat$BTI_conc=="0.32g/l" & dat$replicates!=0,], aes(x=bti.age, y=prop.dead.inset, color=as.factor(replicates))) + geom_point() + theme_bw(base_size = 15) + labs(x="BTI Age (days)", y="Proportion Dead", title="0.32g/l BTI (Dry Season)", color="Replicate Number")
dev.off()
## 0.32 g/l Rainy
png("C:/Users/amykr/Box Sync/Amy Krystosik's Files/njenga/Rainy320mg.png",width = 800, height=600, units="px")
ggplot(data=dat[dat$Season=="Rainy" & dat$BTI_conc=="0.32g/l" & dat$replicates!=0,], aes(x=bti.age, y=prop.dead.inset, color=as.factor(replicates))) + geom_point() + theme_bw(base_size = 15) + labs(x="BTI Age (days)", y="Proportion Dead", title="0.32g/l BTI (Rainy Season)", color="Replicate Number")
dev.off()
