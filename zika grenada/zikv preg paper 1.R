### packages
library(REDCapR)
library(tidyr)
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/zika study- grenada")

# load data -------------------------------------------------------------------
Redcap.token <- readLines("Redcap.token.zika.txt") # Read API token from folder
REDcap.URL  <- 'https://redcap.stanford.edu/api/'
#ds <- redcap_read(  redcap_uri  = REDcap.URL,  token       = Redcap.token,  batch_size = 100)$data
currentDate <- Sys.Date() 
FileName <- paste("zika",currentDate,".rda",sep=" ") 
#save(ds,file=FileName)
load(FileName)
ds<-dplyr::filter(ds, !grepl("--",mother_record_id))

# merge -------------------------------------------------------------------
dataMoms <- ds[ds$redcap_event_name=="mother_arm_1",]
datainfant <- ds[ds$redcap_event_name=="child_arm_1",]
data12 <- ds[ds$redcap_event_name=="12m_fu_arm_1",]
data24 <- ds[ds$redcap_event_name=="24m_fu_arm_1",]
library(dplyr)
ds2 <- merge(dataMoms, datainfant, by = "mother_record_id", suffixes = c(".mom",".child"))

# #make sure the child # didn't change over visits. -------------------------------------------------------------------
twin_ids<-ds[ds$redcap_repeat_instance>1&!is.na(ds$redcap_repeat_instance),"mother_record_id"]
twins<-subset(ds, (c(mother_record_id) %in% twin_ids))
twins<-twins[,grepl("name|mother_record_id|redcap_repeat_instance|redcap_event_name",colnames(twins))]
twins<-twins[,grepl("child|mother_record_id|redcap_repeat_instance|redcap_event_name",colnames(twins))]
twins<-tidyr::unite(twins, child_surname, child_surname,child_surname_2, sep='')
twins<-tidyr::unite(twins, child_firstname, child_firstname,child_firstname_2, sep='')
twins<-tidyr::unite(twins, child_secondname, child_secondname,child_secondname_2, sep='')
twins<-twins[twins$redcap_event_name!="mother_arm_1",]

ds2 <- merge(ds2, data12, by.x = c("mother_record_id","redcap_repeat_instance.child"),by.y = c("mother_record_id","redcap_repeat_instance"), suffixes = c("",".12"),all.x=T)
ds2 <- merge(ds2, data24, by.x = c("mother_record_id","redcap_repeat_instance.child"),by.y = c("mother_record_id","redcap_repeat_instance"), suffixes = c("","24"),all.x=T)

ds2 <- Filter(function(x)!all(is.na(x)), ds2)

# tables -------------------------------------------------------------------
summary(ds2$head_circ_birth)
summary(ds2$mean_hc.child)
summary(ds2$mean_hc_2)
boxplot(ds2$head_circ_birth,ds2$mean_hc.child,ds2$mean_hc_2,ds2$mean_hc_2.24,ylab="Head Circumference, cm",names= c("birth","post","12 m","24 m"))
microcephalic<-ds2[,c("mother_record_id","redcap_event_name","zhc_2","zhc.child","zhc_2.24","head_circ_birth","head_circ_birth.24","mean_hc.child","mean_hc_2","mean_hc_2.24","mir.child","mic_nurse_2","mic_nurse_2.24","mir.24","mir")]

table(ds2$result_zikv_igg_pgold.mom, ds2$mir.child, useNA = "ifany")
table(ds2$result_avidity_zikv_igg_pgold.mom, useNA = "ifany")
table(ds2$result_denv_igg_pgold.mom, useNA = "ifany")

factorVars <- c("mir.child", "result_zikv_igg_pgold.mom", "result_avidity_zikv_igg_pgold.mom", "result_denv_igg_pgold.mom","result_avidity_denv_igg_pgold.mom")
ds2[, factorVars] <- lapply(ds2[, factorVars], factor)

# zika -------------------------------------------------------------------
summary(glm(mir.child ~ result_zikv_igg_pgold.mom, family = "binomial", data = ds2))

summary(glm(mir.child ~ mothers_age_calc.mom + result_zikv_igg_pgold.mom, family = "binomial", data = ds2))

summary(glm(mir.child ~ mothers_age_calc.mom + relevel(result_avidity_zikv_igg_pgold.mom, "0"), family = "binomial", data = ds2))

summary(glm(mir.child ~ mothers_age_calc.mom + relevel(result_avidity_zikv_igg_pgold.mom, "0") + result_zikv_igg_pgold.mom, family = "binomial", data = ds2))

# denv -------------------------------------------------------------------
summary(glm(mir.child ~ result_denv_igg_pgold.mom, family = "binomial", data = ds2))

summary(glm(mir.child ~ mothers_age_calc.mom + result_denv_igg_pgold.mom, family = "binomial", data = ds2))

summary(glm(mir.child ~ mothers_age_calc.mom + relevel(result_avidity_denv_igg_pgold.mom, "0"), family = "binomial", data = ds2))

summary(glm(mir.child ~ mothers_age_calc.mom + relevel(result_avidity_denv_igg_pgold.mom, "0") + result_denv_igg_pgold.mom, family = "binomial", data = ds2))

# both -------------------------------------------------------------------
summary(glm(mir.child ~ mothers_age_calc.mom +result_denv_igg_pgold.mom+ relevel(result_avidity_denv_igg_pgold.mom, "0") + result_zikv_igg_pgold.mom + relevel(result_avidity_zikv_igg_pgold.mom, "0"), family = "binomial", data = ds2))

# tab1 for child descriptive variables -------------------------------------------------------------------
require(tableone)
tab1vars <- c("cohort___1.mom","cohort___2.mom","cohort___3.mom")
tab1All <- CreateTableOne(vars = tab1vars, data = ds2, factorVars = c("delivery_type.child", "cong_abnormal.child", "gender.child"))
tab1 <- CreateTableOne(vars = tab1vars, strata = "mir.child" , data = ds2, factorVars = c("delivery_type.child", "cong_abnormal.child", "gender.child"))
print(tab1, smd=TRUE)

tab1 <- print(tab1, quote = FALSE, noSpaces = TRUE, printToggle = FALSE, smd=TRUE)
tab1All <- print(tab1All, quote = FALSE, noSpaces = TRUE, printToggle = FALSE, smd=TRUE)

## Save to a CSV file
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/zika study- grenada")
write.csv(tab1, file = "table1zika_20180326.csv")
write.csv(tab1All, "table1zikaOverall_20180326.csv")