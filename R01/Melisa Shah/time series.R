load("C:/Users/amykr/Downloads/uktest1.rda")
library(zoo)
uktest1$month <- as.yearmon(uktest1$date)
library(dplyr)
ts.uktest<-uktest1 %>%group_by(month) %>%summarize(monthly_malaria = mean(microA, na.rm = TRUE))
plot(ts.uktest$month,ts.uktest$monthly_malaria)

ts.uktest = ts(ts.uktest$monthly_malaria, start = c(2014,1), end=c(2018, 1), frequency = 12)
plot(ts.uktest) 

components.ts=decompose(ts.uktest)
plot(components.ts)
