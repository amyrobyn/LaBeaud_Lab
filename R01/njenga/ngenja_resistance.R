#install.packages("ecotoxicology")
library("ecotoxicology")
install.packages("lc")
??lc
library("plyr")
library(("reshape"))
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/ASTMH/2018/ngenja resistance")
persistance_larval<-read.csv("BTI susectibility data 2-larval.csv")
resistance_adult<-read.csv("Insecticide resistance-adult.csv")

binary_survival_adult<-resistance_adult[rep(1:nrow(resistance_adult),resistance_adult$mosquito.count ),-10]

table(binary_survival_adult$Replicates, binary_survival_adult$Insecticide)
binary_survival_adult$exposureTime

myprobit <- glm(death ~ exposureTime, family = binomial(link = "probit"), 
                data = binary_survival_adult)
plot(myprobit)


library(ggplot2)
#GGPLOT
qplot(x=day, y=larvae_avg, 
      data=resistance_sum, 
      colour=bti_conc_g_l, 
      main="Average larva per day by BTI Concentration (g/l)")


#BTI- biological controls- larval
#persistance.
#insecticide-larval




#Data from the example on page 5:
#Hamilton, m.a., R.c. Russo, and r.v. Thurston, 1977.
#Trimmed spearman-karber method for estimating median
#Lethal concentrations in toxicity bioassays.
#Environ. Sci. Technol. 11(7): 714-719;
#Correction 12(4):417 (1978).
concentration<-c(.5,1,2,4,8)
exposed<-c(10,10,10,10,10)
mortality<-c(0,2,4,9,10)
resistance_adult$Insecticide
CalculateLC50(cbind(concentration, exposed, mortality))






library(MASS)
dosis <- c(2.6,3.8,5.1,7.7,10.2)
nges <- c(50,48,46,49,50)
nok <- c(6,16,24,42,44)
mm <- glm(cbind(nok, nges - nok) ~ log(dosis), family=binomial)
logED50 <- dose.p(mm, p=0.5)
exp(c(logED50))


