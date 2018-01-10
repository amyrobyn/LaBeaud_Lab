
library(tableone)

setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Nyangatom")
df<-read.csv("Nyangatom_DATA_2017-11-27_0946.csv")

df[df==99] <-NA#replace 99 with NA
df[df==98] <-NA#replace 98 with NA
df[df==9999] <-NA#replace 98 with NA
df$interview_date <- as.Date("2017-01-1")#rough estimate since we didn't collect date of intervieiw. if we need more precise measurements we can take from log book. 


summary(df)

library(psych)
describe<-describe(df)

write.csv(as.data.frame(describe), "describe.csv")

table(df$cluster, exclude=NULL)

# subset moms and children ------------------------------------------------
moms<-subset(df, redcap_event_name=="mother_arm_1")
children<-subset(df, redcap_event_name!="mother_arm_1")

# total pregnancies -------------------------------------------------------
moms$preg_total<-moms$birth_total+moms$miscarriage_total
moms$live_bith_prop<-moms$birth_total/moms$preg_total
moms$misc_prop<-moms$miscarriage_total/moms$preg_total

# total child deaths -------------------------------------------------------
moms$total_deaths<-moms$girl_deaths+moms$boy_deaths
moms$prop_deaths<-moms$total_deaths/moms$birth_total
moms$mortality_ratio_mf<-moms$girl_deaths/moms$boy_deaths
moms<- within(moms, mortality_ratio_mf[moms$mortality_ratio_mf==Inf] <- NA)


# table one for moms ------------------------------------------------
vars_moms<-c("wives_number" ,"married_current","wife_ranking","birth_total", "livestock_holdings","miscarriage_total","preg_total","misc_prop","live_bith_prop","boy_deaths","girl_deaths","total_deaths","prop_deaths","mortality_ratio_mf")
factorVars_moms<-c("married_current","wife_ranking","livestock_holdings")
hannahstable_moms <- CreateTableOne(vars = vars_moms, factorVars = factorVars_moms, data = moms,includeNA=T)

# table one for  kids ------------------------------------------------
library(zoo)
children$dob_month_year <-paste(children$date_birth_day, children$date_birth_month, children$date_birth_year, sep = "-")
table(children$dob_month_year)
children$dob_month_year <- as.yearmon(paste(children$date_birth_year, children$date_birth_month, sep = "-"))

table(children$date_birth_month, children$date_birth_year, exclude = NULL)

library(lubridate)
children$date_birth_year<-as.yearmon(children$date_birth_year)
children$age_years <- year(children$interview_date) - year(children$date_birth_year)#since the most precise measurement we always have is years....
table(children$age_years)
children$age_cat<-NA
children<- within(children, age_cat[children$age_years<=16 & children$age_years>5] <- "6-16")
children<- within(children, age_cat[children$age_years<=5] <- "Under 5")
children<- within(children, age_cat[children$age_years<=1] <- "Under 1")
table(children$age_cat)


vars_children<-c("child_size","sex_child","age_years","age_cat")
factorVars_children<-c("sex_child","age_cat")
hannahstable_children <- CreateTableOne(vars = vars_children, factorVars = factorVars_children, data = children,includeNA=T)
