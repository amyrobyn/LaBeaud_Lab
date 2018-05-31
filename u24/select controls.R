# get data -----------------------------------------------------------------
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long")
load("R01_lab_results 2018-05-17 .rda")
table(round(R01_lab_results$u24_age_calc))

controls<-readRDS("controls.rds")
cases<-readRDS("cases.rds")
u24.cc<-readRDS("u24.rds")
u24_results<- R01_lab_results[which(R01_lab_results$redcap_event_name=="visit_u24_arm_1"& R01_lab_results$u24_participant==1)  , ]

R01_lab_results<-merge(R01_lab_results,u24.cc,by="person_id",all=T)
table(R01_lab_results$u24_strata)

# merge aic and hcc age and sex -------------------------------------------
R01_lab_results$dob<-ifelse(!is.na(R01_lab_results$date_of_birth),R01_lab_results$date_of_birth,R01_lab_results$date_of_birth_aic)
R01_lab_results$dob<-as.Date(R01_lab_results$dob,  format = "%Y-%m-%d")

R01_lab_results$sex<-ifelse(!is.na(R01_lab_results$gender),R01_lab_results$gender,ifelse(!is.na(R01_lab_results$gender_aic),R01_lab_results$gender_aic,R01_lab_results$u24_gender))
library(dplyr)
R01_lab_results<-R01_lab_results%>%group_by(person_id)%>%dplyr::mutate(dob.mean=mean(dob,na.rm=T),dob.sd=sd(dob,na.rm=T)/30,gender.mean=mean(sex,na.rm=T),gender.sd=sd(sex,na.rm=T))

R01_lab_results<-R01_lab_results[order(-(grepl('person_id|redcap', names(R01_lab_results)))+1L)]
gender_sd<-R01_lab_results[which(R01_lab_results$gender.sd>0),]
gender_sd<-gender_sd[c("person_id","redcap_event_name","gender","gender.mean","gender.sd","gender_aic")]
write.csv(gender_sd,"gender_sd.csv")


R01_lab_results$age_today<-(Sys.Date() - R01_lab_results$dob.mean)/365
R01_lab_results$age.cc <- R01_lab_results$age_today
R01_lab_results$age.cc<-R01_lab_results$age_today
R01_lab_results <- within(R01_lab_results, u24_participant[is.na(R01_lab_results$u24_participant)] <- 0)
R01_lab_results$age.cc<-ifelse(R01_lab_results$u24_participant==1,R01_lab_results$u24_age_calc,R01_lab_results$age_today)

R01_lab_results <- within(R01_lab_results, dob.sd[is.na(R01_lab_results$dob.sd)] <- 0)
R01_lab_results <- within(R01_lab_results, gender.sd[is.na(R01_lab_results$gender.sd)] <- 0)


R01_lab_results <- R01_lab_results[order(R01_lab_results$dob.sd),]
R01_lab_results<-R01_lab_results[order(-(grepl('dob', names(R01_lab_results)))+1L)]
R01_lab_results<-R01_lab_results[order(-(grepl('person_id|redcap', names(R01_lab_results)))+1L)]
dob_sd<-R01_lab_results[which(R01_lab_results$dob.sd>12),]
dob_sd<-dob_sd[c("dob.sd","person_id","redcap_event_name","dob","dob.mean","date_of_birth","date_of_birth_aic")]
write.csv(dob_sd,"dob.sd.csv")


R01_lab_results$cc <- NA
R01_lab_results <- within(R01_lab_results, cc[u24_strata =="control"] <- 0)
R01_lab_results <- within(R01_lab_results, cc[(R01_lab_results$u24_strata =="denv"|R01_lab_results$u24_strata =="chikv"|R01_lab_results$u24_strata =="both")&R01_lab_results$u24_participant==1] <- 1)


matchControls<- R01_lab_results[which((!is.na(R01_lab_results$sex)&!is.na(R01_lab_results$age.cc)&!is.na(R01_lab_results$cc)&R01_lab_results$dob.sd<=12 & R01_lab_results$gender.sd==0)|R01_lab_results$u24_participant==1)  , ]#exclude controls with high sd or missing  age or gender
matchControls<- R01_lab_results[which((!is.na(R01_lab_results$sex)&!is.na(R01_lab_results$age.cc)&!is.na(R01_lab_results$cc))), ]#exclude u24 without gender or without dob.
matchControls <- with(matchControls, matchControls[order(person_id),])
matchControls<-matchControls[!duplicated(matchControls$person_id), ]

table(matchControls$cc)
matchControls<- matchControls[c("sex","age.cc","cc","person_id","u24_strata","u24_village","u24_participant")]
matchControls<-as.data.frame(matchControls[which(matchControls$cc==0|matchControls$u24_participant==1)  , ])
p_score<-glm(cc~sex+age.cc, data = matchControls)
summary(p_score)
matchControls$p_score_i<-predict(p_score)
matchControls$cc<-as.factor(matchControls$cc)
ggplot(matchControls)+geom_histogram(aes(x = p_score_i, fill = cc, binwidth = .001)) + geom_density(aes(x = p_score_i, fill = cc), alpha = 0.2)

controls<-as.data.frame(matchControls[which(matchControls$cc==0)  , ])

cases<-as.data.frame(matchControls[which(matchControls$cc==1)  , ])
cases <- cases[order(cases$p_score_i),] 

group <-list(seq(1, 88, by = 3),seq(1, 88, by = 3),seq(1, 88, by = 3))
  group<-as.data.frame(group)
  library(tidyverse)
  group<-gather(group)
  group <- group[order(group$value),] 
  group<-group["value"]
  group<-as.data.frame(group[c(1:88),])
  cases<-cbind(group,cases)
  colnames(cases)[1] <- "group"
  cases$group<-as.factor(cases$group)
  cases<-  as.data.frame(cases)

  cases2<-cases %>%group_by(group) %>%dplyr::summarise(p_score_i = mean(p_score_i), sex=mean(sex),age.cc=mean(age.cc) )
  cases2$cc<-1
  cases2$person_id<-"case"
  table(controls$cc)
  controls<- controls[c("sex","age.cc","cc","person_id","p_score_i")]
  cases2<- cases2[c("sex","age.cc","cc","person_id","p_score_i")]
  

  case_30_control_all<-  rbind(cases2,controls)
  table(case_30_control_all$cc)
  case_30_control_all$case_control<-as.numeric(case_30_control_all$cc)
  
library("MatchIt")
set.seed(1234)
    match.it <- matchit(case_control ~ p_score_i, data = case_30_control_all, method="nearest", ratio=1)
    a <- summary(match.it)
    library("knitr")
    kable(a$sum.matched[c(1,2,4)], digits = 2, align = 'c', 
          caption = 'Table 3: Summary of balance for matched data')
    plot(match.it, type = 'jitter', interactive = FALSE)
    df.match <- match.data(match.it)[1:ncol(case_30_control_all)]
    df.match<-as.data.frame(df.match)
    df.match.controls<-as.data.frame(df.match[which(df.match$case_control==0)  , ])
    u24_all_matched_controls<-merge(df.match.controls, R01_lab_results, by ="person_id",all.x = T)
    u24_all_matched_controls<-u24_all_matched_controls[order(-(grepl('sex|age.cc|case_control|person_id|p_score_i', names(u24_all_matched_controls)))+1L)]
    u24_all_matched_controls$case_control<-0
    colnames(u24_all_matched_controls)[2] <- "sex"
    colnames(u24_all_matched_controls)[3] <- "age.cc"
    u24_matched_controls<- u24_all_matched_controls[c("sex","age.cc","person_id","case_control")]
    
    u24_all_matched_controls<- u24_all_matched_controls[c("sex","age.cc","person_id","case_control","child_surname","child_first_name","child_second_name","child_third_name","child_fourth_name","c_surname","c_f_name","c_s_name","c_t_name","c_fth_name","phone_number","phonenumber","mother_surname","mother_first_name","mother_second_name","mother_third_name","mother_fourth_name","father_surname","father_first_name","father_second_name","father_third_name","father_fourth_name","phone_number_aic","village_aic","village")]
    write.csv(u24_all_matched_controls,"controls_identfied.csv")
    u24_all_cases<-as.data.frame(R01_lab_results[which(R01_lab_results$u24_participant==1)  , ])
    u24_all_cases$case_control<-1
    u24_all_cases<-u24_all_cases[order(-(grepl('sex|age.cc|case_control|person_id|p_score_i', names(u24_all_cases)))+1L)]
    u24_matched_cases<- u24_all_cases[c("sex","age.cc","person_id","case_control")]
    
    u24_all_matched<-rbind(u24_matched_cases,u24_matched_controls)
    
# no differences between groups by age and sex. matching worked---------------------------
boxplot(u24_all_matched$age.cc~ u24_all_matched$case_control,ylab="age",xlab="case=1, control=0")
table(round(u24_all_matched$age.cc), exclude = NULL)
summary(glm(u24_all_matched$case_control~u24_all_matched$age.cc+u24_all_matched$sex))

prop.test(table(u24_all_matched$sex, u24_all_matched$case_control))
wilcox.test(u24_all_matched$age.cc~ u24_all_matched$case_control) 

write.csv(u24_all_matched,"u24_matched.csv")
