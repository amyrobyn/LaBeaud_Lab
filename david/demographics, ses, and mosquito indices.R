# demographics ------------------------------------------------------------
#ses- create an index
AIC <- within(AIC, kid_highest_level_education_aic[AIC$kid_highest_level_education_aic==9|AIC$kid_highest_level_education_aic==5] <- NA)
AIC <- within(AIC, mom_highest_level_education_aic[AIC$mom_highest_level_education_aic==9|AIC$mom_highest_level_education_aic==5] <- NA)
AIC <- within(AIC, roof_type[AIC$roof_type==9|AIC$roof_type==4] <- NA)
AIC <- within(AIC, latrine_type[AIC$latrine_type==9|AIC$latrine_type==6] <- NA)
AIC <- within(AIC, floor_type[AIC$floor_type==9|AIC$floor_type==5] <- NA)


AIC <- within(AIC, drinking_water_source[AIC$drinking_water_source==9|AIC$drinking_water_source==6] <- NA)
AIC$drinking_water_source<-  as.numeric(as.character(AIC$drinking_water_source))
class(AIC$drinking_water_source)

class(AIC$light_source)
table(AIC$light_source)
AIC$light_source<-  as.numeric(as.character(AIC$light_source))

AIC <- within(AIC, light_source[AIC$light_source==9|AIC$light_source==7] <- NA)
AIC <- within(AIC, light_source[AIC$light_source==1] <- 30)
AIC <- within(AIC, light_source[AIC$light_source==3] <- 20)
AIC <- within(AIC, light_source[AIC$light_source==2|AIC$light_source==4|AIC$light_source==5|AIC$light_source==6] <- 10)
AIC$light_source <- AIC$light_source/10 
table(AIC$light_source)
class(AIC$light_source)


AIC$telephone<-  as.numeric(as.character(AIC$telephone))
AIC <- within(AIC, telephone[AIC$telephone==8] <- NA)
class(AIC$telephone)


AIC$radio<-  as.numeric(as.character(AIC$radio))
AIC <- within(AIC, radio[AIC$radio==8] <- NA)
class(AIC$radio)


AIC$television<-  as.numeric(as.character(AIC$television))
AIC <- within(AIC, television[AIC$television==8] <- NA)
class(AIC$television)


AIC$bicycle<-  as.numeric(as.character(AIC$bicycle))
AIC <- within(AIC, bicycle[AIC$bicycle==8] <- NA)
class(AIC$bicycle)

AIC$motor_vehicle<-  as.numeric(as.character(AIC$motor_vehicle))
AIC <- within(AIC, motor_vehicle[AIC$motor_vehicle==8] <- NA)
class(AIC$motor_vehicle)

AIC$domestic_worker<-  as.numeric(as.character(AIC$domestic_worker))
AIC <- within(AIC, domestic_worker[AIC$domestic_worker==8] <- NA)
class(AIC$domestic_worker)
table(AIC$domestic_worker)

ses<-(AIC[, grepl("telephone|radio|television|bicycle|motor_vehicle|domestic_worker", names(AIC))])
AIC$ses_sum<-rowSums(AIC[, c("telephone","radio","television","bicycle","motor_vehicle", "domestic_worker")], na.rm = TRUE)
table(AIC$ses_sum)

AIC$aic_calculated_age<-as.numeric(as.character(AIC$aic_calculated_age))
AIC<-AIC[order(-(grepl('pedsql_', names(AIC)))+1L)]
AIC<-AIC[order(-(grepl('_mean', names(AIC)))+1L)]

# demography tables ------------------------------------------------------------------
## 1.	What are risk factors for co-infection (demographics?)
##Create Table 1 for demographics stratified by denv/malaria status.
## Tests are by oneway.test/t.test for continuous, chisq.test for categorical
#mosquito vars 
AIC$mosquito_bites_aic<-as.numeric(as.character(AIC$mosquito_bites_aic))
AIC <- within(AIC, mosquito_bites_aic[AIC$mosquito_bites_aic==8] <-NA )

AIC$mosquito_coil_aic<-as.numeric(as.character(AIC$mosquito_coil_aic))
AIC <- within(AIC, mosquito_coil_aic[AIC$mosquito_coil_aic==8] <-NA )

AIC$outdoor_activity_aic<-as.numeric(as.character(AIC$outdoor_activity_aic))
AIC <- within(AIC, outdoor_activity_aic[AIC$outdoor_activity_aic==8] <-NA )
AIC$mosquito_net_aic<-as.numeric(as.character(AIC$mosquito_net_aic))
AIC <- within(AIC, mosquito_net_aic[AIC$mosquito_net_aic==9] <-NA )

AIC$mosquito_deterrent<-NA
AIC <- within(AIC, mosquito_deterrent[AIC$mosquito_net_aic>=2|AIC$mosquito_coil_aic==0] <-0 )
AIC <- within(AIC, mosquito_deterrent[AIC$mosquito_net_aic==1|AIC$mosquito_coil_aic==1] <-1 )
table(AIC$mosquito_deterrent)

AIC$always_net<-NA
AIC <- within(AIC, always_net[AIC$mosquito_net_aic>=2] <-0 )
AIC <- within(AIC, always_net[AIC$mosquito_net_aic==1] <-1 )
table(AIC$always_net)
                              