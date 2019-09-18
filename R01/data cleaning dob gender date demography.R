# get data -----------------------------------------------------------------
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long")
load("R01_lab_results 2018-05-23 .rda")

# merge aic and hcc age and sex -------------------------------------------
R01_lab_results$dob<-ifelse(!is.na(R01_lab_results$date_of_birth),R01_lab_results$date_of_birth,R01_lab_results$date_of_birth_aic)
R01_lab_results$interview_date_aic<-trimws(R01_lab_results$interview_date_aic, which = c("both"))
R01_lab_results$interview_date<-trimws(R01_lab_results$interview_date, which = c("both"))

R01_lab_results$dob<-as.Date(R01_lab_results$dob,  format = "%Y-%m-%d")

list(R01_lab_results$interview_date_aic[!is.na(R01_lab_results$interview_date_aic)])
R01_lab_results$interview_date_aic<-as.Date(R01_lab_results$interview_date_aic,  format = "%Y-%m-%d")
list(R01_lab_results$interview_date[!is.na(R01_lab_results$interview_date)])
R01_lab_results$interview_date<-as.Date(R01_lab_results$interview_date,  format = "%Y-%m-%d")

R01_lab_results$int_date<-ifelse(!is.na(R01_lab_results$interview_date), R01_lab_results$interview_date,R01_lab_results$interview_date_aic)

R01_lab_results$int_date2<-R01_lab_results$interview_date
R01_lab_results <- within(R01_lab_results, int_date2[is.na(R01_lab_results$int_date2)] <- R01_lab_results$interview_date_aic[is.na(R01_lab_results$int_date2)])

R01_lab_results$int_date2<-as.Date(R01_lab_results$int_date,  format = "%Y-%m-%d")
R01_lab_results$int_date3<-as.numeric(R01_lab_results$int_date2)

R01_lab_results$sex<-ifelse(!is.na(R01_lab_results$gender),R01_lab_results$gender,ifelse(!is.na(R01_lab_results$gender_aic),R01_lab_results$gender_aic,R01_lab_results$u24_gender))
library(dplyr)
R01_lab_results<-R01_lab_results%>%group_by(person_id)%>%arrange(person_id, redcap_event_name) %>%
    dplyr::mutate(dob.mean=mean(dob,na.rm=T),
    dob.sd=sd(dob,na.rm=T)/30,gender.mean=mean(sex,na.rm=T),
    gender.sd=sd(sex,na.rm=T),
    int_date_diff = int_date2-lag(int_date2), na.rm=TRUE,
    int_date2_lag = lag(int_date2),
    time_diff = difftime(int_date2, int_date2_lag, units = "days")
)

R01_lab_results$diff<-  R01_lab_results$int_date2 - R01_lab_results$int_date2_lag
table(R01_lab_results$diff)
summary(R01_lab_results$int_date_diff)
summary(R01_lab_results$time_diff)
table(R01_lab_results$int_date_diff,exclude = NULL)
table(R01_lab_results$time_diff,exclude = NULL)
#ggplot(R01_lab_results,aes(int_date_diff))+geom_histogram(bins=50)+theme_bw(base_size = 50)

data_cleaning<-R01_lab_results[which(R01_lab_results$dob.sd>6|R01_lab_results$gender.sd>0|R01_lab_results$int_date_diff<0),]
data_cleaning<-R01_lab_results[c("person_id","redcap_event_name","int_date","int_date2","int_date3","interview_date","interview_date_aic","int_date_diff","time_diff","dob.sd","dob.mean","dob","date_of_birth","date_of_birth_aic","u24_date_of_birth","gender_aic","gender","sex","gender.mean","gender.sd","child_surname","child_first_name","child_second_name","child_third_name","child_fourth_name","c_surname","c_f_name","c_s_name","c_t_name","c_fth_name","phone_number","phonenumber","mother_surname","mother_first_name","mother_second_name","mother_third_name","mother_fourth_name","father_surname","father_first_name","father_second_name","father_third_name","father_fourth_name","phone_number_aic","village_aic","village")]

write.csv(data_cleaning,"data_cleaning.csv",na="",row.names = F)
