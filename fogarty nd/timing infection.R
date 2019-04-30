library(redcapAPI)
library(tableone)
library(REDCapR)
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/fogarty chikv")
Redcap.token <- readLines("API_code.txt") # Read API token from folder
REDcap.URL  <- 'https://redcap.stanford.edu/api/'
rcon <- redcapConnection(url=REDcap.URL, token=Redcap.token)
chikv_nd <- redcap_read(redcap_uri  = REDcap.URL, token = Redcap.token, batch_size = 200)$data#export data from redcap to R (must be connected via cisco VPN)

cohort<-chikv_nd

cohort$strata5<-NA
cohort<-within(cohort, strata5[result_mother==1 & pregnant==0&symptoms___4==1&(symptoms___1==1|symptoms___3==1|symptoms___5==1|symptoms___6==1|symptoms___25==1)]<-0)
cohort <- within(cohort, strata5[result_mother==1 & pregnant ==1&symptoms___4==1&(symptoms___1==1|symptoms___3==1|symptoms___5==1|symptoms___6==1|symptoms___25==1)] <- 1)

trimester<-CreateTableOne(vars="trimester", strata="strata5",factorVars = "trimester",data=cohort)

# infection timing --------------------------------------------------------
cohort$when<-zoo::as.Date(cohort$when)
cohort$childs_birth_date<-zoo::as.Date(cohort$childs_birth_date)
cohort$days_delivery_chikv<- as.numeric(cohort$when - cohort$childs_birth_date)

hist(cohort$days_delivery_chikv[cohort$strata5==0])
hist(cohort$days_delivery_chikv[cohort$strata5==1])
summary(cohort$days_delivery_chikv)
hist(cohort$days_delivery_chikv,breaks=c(-1234,-15,-3,-2,966))

cohort$partum<-NA
cohort<-within(cohort,partum[cohort$days_delivery_chikv <= -15] <- 1 )

cohort<-within(cohort,partum[cohort$days_delivery_chikv>=-15 & cohort$days_delivery_chikv <= -3]<-2)
cohort<-within(cohort,partum[cohort$days_delivery_chikv>=-2 & cohort$days_delivery_chikv<=2]<-3)

table(cohort$partum)

vars=c("days_delivery_chikv","trimester","partum")
factorVars = c("trimester","partum")
CreateTableOne(vars = vars,factorVars = factorVars, strata = "strata5", data = cohort)