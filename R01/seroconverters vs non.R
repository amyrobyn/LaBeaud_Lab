setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long")
load("R01_lab_results.clean.rda")    


# subset and keep only pcr+ -----------------------------------------------
pcr_pos<- R01_lab_results[which(R01_lab_results$infected_denv_stfd==1)  , ]


# table of pcr + and seroconverters vs non --------------------------------
table(pcr_pos$seroc_denv_stfd_igg)

table(pcr_pos$tested_denv)

table(pcr_pos$seroc_denv_kenya_igg)

vars <- c("site", "City", "Cohort", "rural", "age_group", "Female")
factorVars <- c("site", "City", "Cohort", "rural", "age_group", "Female")

tableOne <- CreateTableOne(vars = vars, factorVars = factorVars, strata = "seroc_denv_stfd_igg", data = pcr_pos)
print(tableOne, quote = TRUE,
      exact=c("site", "City", "Cohort", "rural", "age_group", "Female"))

# primary vs secondary infection ------------------------------------------

table(pcr_pos$result_igg_denv_stfd)
table(pcr_pos$result_igg_denv_kenya)
111+29+11

