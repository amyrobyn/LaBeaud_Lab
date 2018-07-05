library(tidyverse)
library(plyr)
library(tableone)
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/david coinfectin paper/data")
# combine cleaned pedsql and coinfection strata ---------------------------
load("C:/Users/amykr/Box Sync/Amy Krystosik's Files/david coinfectin paper/data/david_coinfection_strata_hospitalization.rda")
load("C:/Users/amykr/Box Sync/Amy Krystosik's Files/david coinfectin paper/data/pedsql_pairs_acute.rda")
load("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long/R01_lab_results.clean.rda")

pedsql_pairs_acute$redcap_event_name<-pedsql_pairs_acute$redcap_event_name_acute_paired
joined.df <- join(pedsql_pairs_acute, david_coinfection_strata_hospitalization,  by=c("person_id", "redcap_event_name"), match = "all" , type="full")


# table of the change scores ----------------------------------------------
var<-grep("mean_change|mean_z|time", names(pedsql_pairs_acute), value = TRUE)
pedsql_paired_tableOne <- CreateTableOne(vars = var, strata = "strata", data = joined.df)

# model of change score ---------------------------------------------------
lm <- lm(pedsql_child_total_mean_change/100 ~ elapsed.time_conv_paired + factor(strata_all)+factor(gender_all)+factor(age_group)+factor(mom_highest_level_education_aic), data = joined.df)
summary(lm)
plot(lm$fitted.values, joined.df$pedsql_child_total_mean)
table(joined.df$elapsed.time_conv_paired)
table(joined.df$elapsed.time_acute_paired)
head(joined.df[c("elapsed.time_conv_paired", "elapsed.time_acute_paired")] )

# graph of score over time to fu ------------------------------------------
total_timetovis<-ggplot(joined.df,aes(elapsed.time_conv_paired,pedsql_child_total_mean_change))
total_timetovis+ geom_point()+ geom_smooth(method = "loess")+facet_grid(.~strata_all)

pedsql_child_total_mean_acute_paired<-ggplot(joined.df,aes(strata_all,pedsql_child_total_mean_acute_paired))
pedsql_child_total_mean_conv_paired<-ggplot(joined.df,aes(strata_all,pedsql_child_total_mean_conv_paired))

pedsql_child_total_mean_acute_paired+ geom_boxplot()
pedsql_child_total_mean_conv_paired+ geom_boxplot()

joined.df$pedsql_child_total_mean_acute_paired
visits_timetovisit<-ggplot(joined.df,aes(elapsed.time_conv_paired, fill = strata_all))
visits_timetovisit+ geom_histogram()+    scale_x_continuous(breaks = seq(12, 84, 1), lim = c(12, 84))

joined.df$id_city<-substr(joined.df$person_id, 1, 1)
pedsqlnonna<-joined.df[which(!is.na(joined.df$pedsql_child_total_mean_acute_paired)&is.na(joined.df$strata_all)&(joined.df$id_city=="C"|joined.df$id_city=="K"|joined.df$id_city=="R")),]
pedsqlnonna2<-merge(R01_lab_results,pedsqlnonna,by=c("person_id","redcap_event_name"), all.y=T)
pedsqlnonna2<-pedsqlnonna2[,c("person_id","redcap_event_name","strata_all","result_pcr_denv_kenya","result_pcr_denv_stfd","result_microscopy_malaria_kenya","density_microscpy_pf_kenya","interview_date_aic","rdt_results","temp","pedsql_child_total_mean_acute_paired","result_igg_denv_kenya","result_igg_denv_stfd","interviewer_name_aic")]
write.csv(pedsqlnonna2,"pedsql_denv_malaria.csv")

pedsql_pairs_long_strata.full<-joined.df[c("elapsed.time_conv_paired","pedsql_child_emotional_mean_change","strata_all","gender_all","age_group","mom_highest_level_education_aic")]
pedsql_pairs_long_strata.full <-  pedsql_pairs_long_strata.full[complete.cases(pedsql_pairs_long_strata.full), ] 
library(mgcv)
gamm <- gamm(pedsql_child_emotional_mean_change ~ s(elapsed.time_conv_paired) + factor(strata_all)+factor(gender_all)+factor(age_group)+factor(mom_highest_level_education_aic), data = pedsql_pairs_long_strata.full)
summary(gamm)
plot(gamm$gam,pedsql_pairs_long_strata.full$pedsql_child_emotional_mean_change)


# tables with pe and strata -----------------------------------------------

#3.	Table 1 info for PE, and outcomes analysis
# pedsql paired data ------------------------------------------------------
pedsql_paired_vars <- c("pedsql_child_school_mean_acute_paired", "pedsql_child_school_mean_conv_paired", "pedsql_child_social_mean_acute_paired", "pedsql_child_social_mean_conv_paired", "pedsql_parent_school_mean_acute_paired", "pedsql_parent_school_mean_conv_paired", "pedsql_parent_social_mean_acute_paired", "pedsql_parent_social_mean_conv_paired", "pedsql_child_physical_mean_acute_paired", "pedsql_child_physical_mean_conv_paired", "pedsql_parent_physical_mean_acute_paired", "pedsql_parent_physical_mean_conv_paired", "pedsql_child_emotional_mean_acute_paired", "pedsql_child_emotional_mean_conv_paired", "pedsql_parent_emotional_mean_acute_paired", "pedsql_parent_emotional_mean_conv_paired")
pedsql_paired_tableOne_strata <- CreateTableOne(vars = pedsql_paired_vars, strata = "strata", data = cases)
#print table one (assume non normal distribution)
pedsql_paired_tableOne_strata_non.csv <-print(pedsql_paired_tableOne_strata, 
                                              nonnormal=c("pedsql_child_school_mean_acute_paired", "pedsql_child_school_mean_conv_paired", "pedsql_child_social_mean_acute_paired", "pedsql_child_social_mean_conv_paired", "pedsql_parent_school_mean_acute_paired", "pedsql_parent_school_mean_conv_paired", "pedsql_parent_social_mean_acute_paired", "pedsql_parent_social_mean_conv_paired", "pedsql_child_physical_mean_acute_paired", "pedsql_child_physical_mean_conv_paired", "pedsql_parent_physical_mean_acute_paired", "pedsql_parent_physical_mean_conv_paired", "pedsql_child_emotional_mean_acute_paired", "pedsql_child_emotional_mean_conv_paired", "pedsql_parent_emotional_mean_acute_paired", "pedsql_parent_emotional_mean_conv_paired"), 
                                              quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE)
write.csv(pedsql_paired_tableOne_strata_non.csv, file = "pedsql_paired_tableOne.csv")

#print table one (assume normal distribution)
pedsql_paired_tableOne_strata_normal.csv <-print(pedsql_paired_tableOne_strata, 
                                                 quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE)
write.csv(pedsql_paired_tableOne_strata_normal.csv, file = "pedsql_paired_tableOne_strata_normal.csv")


pedsql_paired_tableOne_strata_all <- CreateTableOne(vars = pedsql_paired_vars, strata = "strata_all", data = cases)
#print table one (assume non normal distribution)
pedsql_paired_tableOne_strata_all_non.csv <-print(pedsql_paired_tableOne_strata_all, 
                                                  nonnormal=c("pedsql_child_school_mean_acute_paired", "pedsql_child_school_mean_conv_paired", "pedsql_child_social_mean_acute_paired", "pedsql_child_social_mean_conv_paired", "pedsql_parent_school_mean_acute_paired", "pedsql_parent_school_mean_conv_paired", "pedsql_parent_social_mean_acute_paired", "pedsql_parent_social_mean_conv_paired", "pedsql_child_physical_mean_acute_paired", "pedsql_child_physical_mean_conv_paired", "pedsql_parent_physical_mean_acute_paired", "pedsql_parent_physical_mean_conv_paired", "pedsql_child_emotional_mean_acute_paired", "pedsql_child_emotional_mean_conv_paired", "pedsql_parent_emotional_mean_acute_paired", "pedsql_parent_emotional_mean_conv_paired"), 
                                                  quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE)
write.csv(pedsql_paired_tableOne_strata_all_non.csv, file = "pedsql_paired_tableOne_strata_all_non.csv")

#print table one (assume normal distribution)
pedsql_paired_tableOne_strata_all_normal.csv <-print(pedsql_paired_tableOne_strata_all, 
                                                     quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE)
write.csv(pedsql_paired_tableOne_strata_all_normal.csv, file = "pedsql_paired_tableOne_strata_all_normal.csv")



pedsql<-cases[, grepl("person_id|pedsql|strata|hospitalized", names(cases))]

write.csv(as.data.frame(pedsql), "C:/Users/amykr/Box Sync/Amy Krystosik's Files/david coinfectin paper/data/pedsql.csv" )