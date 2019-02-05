load("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long/R01_lab_results.clean.rda")
R01_lab_results_2014<-R01_lab_results[which(R01_lab_results$year=="2014"), ]

# q 1 ----------------------------------------------------------------------
#I am working on a power analysis and I was wondering from your R01- do you have any preliminary data on the rate of acute DENV infection among febrile individuals in Msambweni or in the coastal region of Kenya? For acute infection, I saw in the literature  (Konongoi et al) that acute DENV infection in febrile patients in coastal Kenya was 43%, but this seems high.
#The aic pcr positives by site and virus 
table(R01_lab_results_2014$infected_denv_stfd,R01_lab_results_2014$City, R01_lab_results_2014$Cohort)

table(R01_lab_results_2014$infected_chikv_stfd,R01_lab_results_2014$City, R01_lab_results_2014$Cohort)

# q 2 ----------------------------------------------------------------------
#In terms of DENV IgG seroprevalence- I saw your manuscript "Short Report: Serologic Evidence of Arboviral Infections among Humans in Kenya" and  noted that the seroprevalence for DENV for Msambweni was about 44-67%. This will give us an ample sample size to look at something like DENV IgG antibody transfer to neonates... I think this would be very interesting to look at, among other things.
#The seroprevalence rate by site and cohort and virus in 2014:
table(R01_lab_results_2014$result_igg_chikv_stfd,R01_lab_results_2014$City, R01_lab_results_2014$Cohort)
table(R01_lab_results_2014$result_igg_chikv_kenya,R01_lab_results_2014$City, R01_lab_results_2014$Cohort)

table(R01_lab_results_2014$result_igg_denv_stfd,R01_lab_results_2014$City, R01_lab_results_2014$Cohort)
table(R01_lab_results_2014$result_igg_denv_kenya,R01_lab_results_2014$City, R01_lab_results_2014$Cohort)

#all years
table(R01_lab_results$result_igg_chikv_stfd,R01_lab_results$City, R01_lab_results$Cohort)
table(R01_lab_results$result_igg_chikv_kenya,R01_lab_results$City, R01_lab_results$Cohort)

table(R01_lab_results$result_igg_denv_stfd,R01_lab_results$City, R01_lab_results$Cohort)
table(R01_lab_results$result_igg_denv_kenya,R01_lab_results$City, R01_lab_results$Cohort)

