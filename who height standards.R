# import who antrho standards data sets -----------------------------------
lenanthro<-read.table("C:/Program Files/R/R-3.3.2/library/igrowup_R/lenanthro.txt",header=T,sep="",skip=0)
lenanthro$age.month<-round(lenanthro$age/30.5)
lenanthro$age.year<-lenanthro$age/365.25
summary(lenanthro$age)
summary(lenanthro$age.month)
summary(lenanthro$age.year)
lenanthro<-lenanthro[which(lenanthro$age.year<5),]

library(dplyr)
lenanthro.month<-lenanthro %>%
  group_by(age.month,sex) %>%
  summarize(
    m = max(m, na.rm = TRUE),
    s = max(s, na.rm = TRUE)
  )
lenanthro.month$age.year<-lenanthro.month$age.month/12

# 5-19 --------------------------------------------------------------------

hfawho2007<-read.table("C:/Program Files/R/R-3.3.2/library/who2007_R/hfawho2007.txt",header=T,sep="",skip=0)
hfawho2007$age.year<-hfawho2007$age/12
names(hfawho2007)[names(hfawho2007) == 'age'] <- 'age.month'
hfawho2007<-hfawho2007[which(hfawho2007$age.year>=5),]

# merge over and under 5 --------------------------------------------------
height.length.age<-plyr::rbind.fill(hfawho2007,lenanthro.month)

# calculate 2 and 3 sd ----------------------------------------------------

height.length.age$sd<-height.length.age$s*height.length.age$m
plot(height.length.age$age.month,height.length.age$m)

height.length.age$who_height.3sd <-height.length.age$m-(height.length.age$sd*3)
height.length.age$who_height.2sd <-height.length.age$m-(height.length.age$sd*2)

# save --------------------------------------------------------------------
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long")
save(height.length.age,file="who_height.Rda")
