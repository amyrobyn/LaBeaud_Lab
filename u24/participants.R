library(dplyr)
library(plyr)
load("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long/R01_lab_results.clean.rda")

  R01_lab_results<- R01_lab_results[which(!is.na(R01_lab_results$redcap_event_name))  , ]
  R01_lab_results$id_cohort<-substr(R01_lab_results$person_id, 2, 2)
  R01_lab_results$id_city<-substr(R01_lab_results$person_id, 1, 1)
# those exposed in msambweni. we had so many with any exposure that i cut it down to those with documented incident infection. ---------------------------------------------------------------
      R01_lab_results$u24_strata<-NA
      R01_lab_results <- within(R01_lab_results, u24_strata[(R01_lab_results$infected_chikv_stfd==1|R01_lab_results$prnt_interpretation_alpha___2==1)  & (R01_lab_results$id_city=="M"|R01_lab_results$id_city=="G"|R01_lab_results$id_city=="L") ] <- 1)
      R01_lab_results <- within(R01_lab_results, u24_strata[(R01_lab_results$infected_denv_stfd==1|R01_lab_results$prnt_interpretation_flavi___1==1) & (R01_lab_results$id_city=="M"|R01_lab_results$id_city=="G"|R01_lab_results$id_city=="L") ] <- 2)
      R01_lab_results <- within(R01_lab_results, u24_strata[(R01_lab_results$result_igg_denv_stfd==1|R01_lab_results$infected_denv_stfd==1|R01_lab_results$prnt_result_denv==1) &(R01_lab_results$result_igg_chikv_stfd==1|R01_lab_results$infected_chikv_stfd==1|R01_lab_results$prnt_result_chikv==1)  & (R01_lab_results$id_city=="M"|R01_lab_results$id_city=="G"|R01_lab_results$id_city=="L") ] <- 3)
      R01_lab_results <- within(R01_lab_results, u24_strata[(R01_lab_results$result_igg_denv_stfd==0 & R01_lab_results$infected_denv_stfd==0 & R01_lab_results$prnt_interpretation_flavi___1!=1) & (R01_lab_results$result_igg_chikv_stfd==0|R01_lab_results$infected_chikv_stfd==0|R01_lab_results$prnt_interpretation_alpha___2!=1)  & (R01_lab_results$id_city=="M"|R01_lab_results$id_city=="G"|R01_lab_results$id_city=="L") ] <- 0)
      table(R01_lab_results$u24_strata)
      u24_participants<-R01_lab_results[which(!is.na(R01_lab_results$u24_strata)), ]
      u24_participants<- u24_participants[, grepl("person_id|u24_strata|redcap_event_name", names(u24_participants))]
      
      #replace duplicates with the highest strata.
      u24_strata <-     as.data.frame(aggregate(u24_strata ~ person_id, data = u24_participants, max))
      table(u24_strata$u24_strata)
      u24_all<-subset(R01_lab_results, (c(person_id) %in% u24_participants$person_id))
      u24_all<- u24_all[, !grepl("date|dob|u24", names(u24_all))]
      library(janitor)
      u24_all<-    u24_all %>%
        remove_empty_cols()
      u24_all_wide<-reshape(u24_all, direction = "wide", idvar = "person_id", timevar = "redcap_event_name", sep = "_")
      u24_all_wide<-    u24_all_wide %>%
        remove_empty_cols()
      u24_all_wide<- u24_all_wide[, grepl("name|result|gps|village|person_id|age|gender|prnt_interpretation", names(u24_all_wide))]
      
      u24_participants<-merge(u24_strata, u24_all_wide, by ="person_id", all=TRUE)
      u24_participants<-u24_participants[order(-(grepl('person_id|redcap', names(u24_participants)))+1L)]
    
    table(u24_participants$u24_strata)
    n_distinct(u24_participants$person_id)
    u24_participants <- within(u24_participants, u24_strata[u24_participants$u24_strata ==0] <- "control")
    u24_participants <- within(u24_participants, u24_strata[u24_participants$u24_strata ==1] <- "chikv")
    u24_participants <- within(u24_participants, u24_strata[u24_participants$u24_strata ==2] <- "denv")
    u24_participants <- within(u24_participants, u24_strata[u24_participants$u24_strata ==3] <- "both")
    
    u24_participants$case_control<-NA
    u24_participants <- within(u24_participants, case_control[u24_participants$u24_strata =="control" & !is.na(u24_participants$age_visit_a_arm_1) & !is.na(u24_participants$gender_all_visit_a_arm_1)] <- "control")
    u24_participants <- within(u24_participants, case_control[(u24_participants$u24_strata =="chikv"|u24_participants$u24_strata =="denv"|u24_participants$u24_strata =="both") & (!is.na(u24_participants$age_visit_a_arm_1) & !is.na(u24_participants$gender_all_visit_a_arm_1))] <- "case")
    table(u24_participants$case_control, u24_participants$u24_strata, exclude = NULL)

## now look at the group properties:
boxplot(u24_participants$age_visit_a_arm_1 ~ u24_participants$u24_strata)
boxplot(u24_participants$age_visit_a_arm_1 ~ u24_participants$case_control)
barplot(table(u24_participants$gender_all_visit_a_arm_1, u24_participants$u24_strata), beside = TRUE)
barplot(table(u24_participants$gender_all_visit_a_arm_1, u24_participants$case_control))
#install.packages("e1071")
matchControls<- u24_participants[which(!is.na(u24_participants$gender_all_visit_a_arm_1)&!is.na(u24_participants$age_visit_a_arm_1)&!is.na(u24_participants$case_control))  , ]
matchControls<- matchControls[c("gender_all_visit_a_arm_1","age_visit_a_arm_1","case_control","person_id")]
library("MatchIt")
set.seed(1234)
matchControls <- within(matchControls, case_control[case_control =="control"] <- 0)
matchControls <- within(matchControls, case_control[case_control =="case"] <- 1)
matchControls$case_control<-as.numeric(matchControls$case_control)

    match.it <- matchit(matchControls$case_control ~ matchControls$gender_all_visit_a_arm_1 + matchControls$age_visit_a_arm_1, data = matchControls, method="nearest", ratio=1)
    a <- summary(match.it)
    library("knitr")
    kable(a$sum.matched[c(1,2,4)], digits = 2, align = 'c', 
          caption = 'Table 3: Summary of balance for matched data')
    plot(match.it, type = 'jitter', interactive = FALSE)
    df.match <- match.data(match.it)[1:ncol(matchControls)]

df.match<-as.data.frame(df.match)
boxplot(df.match$age_visit_a_arm_1 ~ df.match$case_control)
barplot(table(df.match$gender_all_visit_a_arm_1, df.match$case_control))

u24_participants<-merge(df.match, u24_participants, by ="person_id", all.x = TRUE)

u24_participants$prnt_confirmed<-rowSums(u24_participants[, grep("prnt_interpretation_flavi___1|prnt_interpretation_alpha___2", names(u24_participants))], na.rm = TRUE)
table(u24_participants$u24_strata,u24_participants$prnt_confirmed)

u24_participants<-u24_participants[order(-(grepl('person_id|redcap_event_name|u24_strata|prnt_confirmed', names(u24_participants)))+1L)]

u24_participants<-u24_participants %>%
  remove_empty_cols()

#export list with id's
write.csv(as.data.frame(u24_participants), "C:/Users/amykr/Box Sync/U24 Project/data/u24_participants.csv", na = "")
