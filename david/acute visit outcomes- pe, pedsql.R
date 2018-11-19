
#3.	Table info for PE, and outcomes analysis
#Table 2, OR of symptom/sign in reference to co-infection 
# 2.	Does co-infection present differently clinically than solo-infection (symptoms, signs, pedsQL acute)?

pedsql<- AIC[which(AIC$redcap_event_name=="visit_a_arm_1")  , ]#acute only.
pedsql<-pedsql[, grepl("pedsql|strata_all", names(pedsql))]
pedsql<-pedsql[, !grepl("child|infant|teen|812|mean|sum|type|group|complete|comments|idno|date|interviewer", names(pedsql))]
pedsql<-pedsql[order(-(grepl('strata', names(pedsql)))+1L)]

pedsql$strata_all<-as.factor(pedsql$strata_all)
pedsql$strata_all = relevel(pedsql$strata_all, ref = "malaria_pos_denv_pos")
#median tables
pedsql_vars<-names(pedsql[,-1])
pedsql.tableone <- CreateTableOne(vars = pedsql_vars, factorVars = pedsql_vars, strata = "strata_all", data = pedsql)
pedsql.tableone.median.cat.csv<-print(pedsql.tableone, nonnormal=pedsql_vars,quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE)
write.csv(pedsql.tableone.median.cat.csv, file = "pedsql.tableone.median.cat.csv")

pedsql.tableone <- CreateTableOne(vars = pedsql_vars, strata = "strata_all", data = pedsql)
pedsql.tableone.median.cont.csv<-print(pedsql.tableone, nonnormal=pedsql_vars,quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE)
write.csv(pedsql.tableone.median.cont.csv, file = "pedsql.tableone.median.cont.csv")


#or tables
library(nnet)

multi1<-lapply(pedsql[,-1], function(x) multinom(factor(x) ~ pedsql$strata_all+0))#remove factor if we decide to use cont.

coef<-lapply(multi1, coefficients)
or<-lapply(coef, exp)
lapply(or, function(x) write.table( data.frame(x), 'or.csv'  , append= T, sep=',' ))
lapply(names(multi1), function(x) write.table( data.frame(x), 'names.csv'  , append= T, sep=',' ))

#https://stats.stackexchange.com/questions/63222/getting-p-values-for-multinom-in-r-nnet-package
#install.packages("afex")
library(afex)
set_sum_contrasts() # use sum coding, necessary to make type III LR tests valid
library(car)
Anova(test,type="III")
#install.packages("AER")
library(AER)
library(broom)
coeftest(test)
p<-lapply(multi1, coeftest)
ptable<-lapply(p, tidy)
lapply(ptable, function(x) write.table( data.frame(x), 'pedsql_acute_OR_cat2.csv', append= T, sep=',' ))

hist(AIC$pedsql_parent_emotional_mean_conv_paired)

# pedsql paired data ------------------------------------------------------
pedsql_paired_vars=c("pedsql_child_school_mean_acute_paired", "pedsql_child_school_mean_conv_paired", "pedsql_child_social_mean_acute_paired", "pedsql_child_social_mean_conv_paired", "pedsql_parent_school_mean_acute_paired", "pedsql_parent_school_mean_conv_paired", "pedsql_parent_social_mean_acute_paired", "pedsql_parent_social_mean_conv_paired", "pedsql_child_physical_mean_acute_paired", "pedsql_child_physical_mean_conv_paired", "pedsql_parent_physical_mean_acute_paired", "pedsql_parent_physical_mean_conv_paired", "pedsql_child_emotional_mean_acute_paired", "pedsql_child_emotional_mean_conv_paired", "pedsql_parent_emotional_mean_acute_paired", "pedsql_parent_emotional_mean_conv_paired") 
pedsql_paired_tableOne_strata_all <- CreateTableOne(vars = pedsql_paired_vars, strata = "strata_all", data = AIC)
pedsql_paired_tableOne_strata_all <- CreateTableOne(vars = pedsql_paired_vars, strata = "strata_all", data = conv_paired_peds)
#print table one (assume non normal distribution)
pedsql_paired_tableOne_strata_all_non.csv <-print(pedsql_paired_tableOne_strata_all, nonnormal=pedsql_paired_vars, quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE)
write.csv(pedsql_paired_tableOne_strata_all_non.csv, file = "pedsql_paired_tableOne_strata_all_non.csv")

#print table one (assume normal distribution)
pedsql_paired_tableOne_strata_all_normal.csv <-print(pedsql_paired_tableOne_strata_all, quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE)
write.csv(pedsql_paired_tableOne_strata_all_normal.csv, file = "pedsql_paired_tableOne_strata_all_normal.csv")



pedsql<-AIC[, grepl("person_id|pedsql|strata|hospitalized", names(AIC))]

write.csv(as.data.frame(pedsql), "C:/Users/amykr/Box Sync/Amy Krystosik's Files/david coinfection paper/data/pedsql.csv" )
