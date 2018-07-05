setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long")

load("R01_lab_results.clean.rda")    
#How often do the kids in HCC have fever in the previous 6 months? All of them? Half?
hist(R01_lab_results$number_illnesses)
summary(R01_lab_results$number_illnesses)
table(R01_lab_results$number_illnesses, R01_lab_results$age_group)

R01_lab_results$ill_last6months<-NA
R01_lab_results <- within(R01_lab_results, ill_last6months[R01_lab_results$number_illnesses==0] <- "no")
R01_lab_results <- within(R01_lab_results, ill_last6months[R01_lab_results$number_illnesses>0] <- "yes")
table(R01_lab_results$last6months)
11794/(2078 +11794) 

library(expss)
cro(R01_lab_results$number_illnesses, R01_lab_results$age_group)
cro(R01_lab_results$ill_last6months, R01_lab_results$age_group)
cro(R01_lab_results$illness_today, R01_lab_results$age_group)


cro_tpct(R01_lab_results$illness_today)
cro_tpct(R01_lab_results$number_illnesses)


# aic ---------------------------------------------------------------------
R01_lab_results$fever_aic<-NA
R01_lab_results <- within(R01_lab_results, fever_aic[R01_lab_results$aic_symptom_fever==1] <- "yes")
R01_lab_results <- within(R01_lab_results, fever_aic[R01_lab_results$temp>=38] <- "no")


cro(R01_lab_results$fever_aic, R01_lab_results$age_group)
cro_tpct(R01_lab_results$fever_aic)


# denv/chikv incidence ----------------------------------------------------
cro_cpct(R01_lab_results$infected_denv_chikv_stfd,R01_lab_results$age_group.p)

# population ----------------------------------------------------
R01_lab_results$age_group.p<-NA
R01_lab_results <- within(R01_lab_results, age_group.p[age<=4] <- "0-4")
R01_lab_results <- within(R01_lab_results, age_group.p[age>4 & age<=9] <- "5-9")
R01_lab_results <- within(R01_lab_results, age_group.p[age>9 & age<=14] <- "10-14")
R01_lab_results <- within(R01_lab_results, age_group.p[age>15 & age<=19] <- "15-19")
R01_lab_results$age_group <- factor(R01_lab_results$age_group.p, levels = c("under 4", "5-9", "10-14", "15-19"))

R01_lab_results$pouplation_age_group<-NA
R01_lab_results <- within(R01_lab_results, pouplation_age_group[R01_lab_results$age_group.p =="0-4"] <-3.04+3.12 )
R01_lab_results <- within(R01_lab_results, pouplation_age_group[R01_lab_results$age_group.p == "5-9"] <- 3.36 + 3.44)
R01_lab_results <- within(R01_lab_results, pouplation_age_group[R01_lab_results$age_group.p =="10-14"] <- 3.12+3.08)
R01_lab_results <- within(R01_lab_results, pouplation_age_group[R01_lab_results$age_group.p =="15-19"] <- 2.32+2.36)
R01_lab_results$pouplation_age_group<-R01_lab_results$pouplation_age_group*1000000
cro(R01_lab_results$pouplation_age_group,R01_lab_results$age_group.p)

cro_cpct(R01_lab_results$ill_last6months,R01_lab_results$age_group.p)
