#denv case defination------------------------------------------------------------------------
#redefine infected_denv_stfd to exclude ufi. 
#stfd denv igg seroconverters or PCR positives as infected.
R01_lab_results$infected_denv_kenya[R01_lab_results$tested_denv_kenya_igg ==1 | R01_lab_results$result_pcr_denv_kenya==0|R01_lab_results$result_pcr_denv_stfd==0|R01_lab_results$denv_result_ufi==0]<-0
R01_lab_results$infected_denv_kenya[R01_lab_results$seroc_denv_kenya_igg==1|R01_lab_results$result_pcr_denv_kenya==1|R01_lab_results$result_pcr_denv_stfd==1|R01_lab_results$denv_result_ufi==1]<-1
table(R01_lab_results$infected_denv_kenya, R01_lab_results$denv_result_ufi)
table(AIC$seroc_denv_stfd_igg)
table(AIC$infected_denv_stfd)  

#table of denv at acute visit. 
denv_acute<-  sum(AIC$infected_denv_stfd==1 & AIC$acute==1, na.rm = TRUE)#126 denv infected (seroconverter or PCR +)
#malaria case defination------------------------------------------------------------------------
#Malaria: positive by result_microscopy_malaria_kenya, or if NA, then positive by malaria_result
AIC$malaria<-NA
AIC <- within(AIC, malaria[AIC$result_rdt_malaria_keny==0|AIC$rdt_result==0|AIC$malaria_results==0|AIC$result_microscopy_malaria_kenya==0] <- 0)
AIC <- within(AIC, malaria[AIC$malaria_results>0|AIC$rdt_results==1] <- 1)# Results of malaria blood smear	(+++ system)|rdt
AIC <- within(AIC, malaria[AIC$result_microscopy_malaria_kenya==1] <- 1) #this is gold standard and overwrites all other.

table(AIC$malaria)
#denv by pcr or serology ------------------------------------------------------------------------
AIC$pcr_denv<-NA
AIC <- within(AIC, pcr_denv[AIC$result_pcr_denv_kenya==0] <- 0)
AIC <- within(AIC, pcr_denv[AIC$result_pcr_denv_stfd==0] <- 0)
AIC <- within(AIC, pcr_denv[AIC$result_pcr_denv_kenya==1] <- 1)
AIC <- within(AIC, pcr_denv[AIC$result_pcr_denv_stfd==1] <- 1)
table(AIC$pcr_denv)
table(AIC$seroc_denv_stfd_igg)
table(AIC$seroc_denv_stfd_igg, AIC$pcr_denv, exclude = NULL)#87 by pcr, 6 by igg seroconversion.
table(AIC$infected_denv_stfd, AIC$malaria, exclude = NULL)
table(AIC$infected_denv_stfd, exclude = NULL)
#  #some need to be malaria tested to be included in sample ------------------------------------------------------------------------
not_malaria_tested<-AIC[which(is.na(AIC$malaria) & AIC$infected_denv_stfd==1), ]
table(is.na(AIC$malaria) & AIC$infected_denv_stfd==1)
#  table(not_malaria_tested$person_id, not_malaria_tested$redcap_event_name)
#  keep acute only ------------------------------------------------------------------------
AIC<-AIC[which(AIC$acute==1), ]

#  keep only those tested for both denv and malaria ------------------------------------------------------------------------
#define denv testing as pcr or paired igg.
AIC$tested_malaria<-NA
AIC <- within(AIC, tested_malaria[!is.na(AIC$malaria)] <- 1)
AIC <- within(AIC, tested_denv_stfd_igg[!is.na(AIC$infected_denv_stfd) |AIC$tested_denv_stfd_igg==1] <- 1)
AIC <- within(AIC, tested_denv_stfd_igg[AIC$tested_denv_stfd_igg==0 ] <- NA)
#count just tested for denv not malaria  #just tested for malaria not denv
table(AIC$tested_malaria, exclude = NULL)#malaria tested = 2171 NA = 32
table(AIC$tested_denv_stfd_igg, exclude = NULL)#denv tested = 2037 NA = 166
table(AIC$tested_denv_stfd_igg, AIC$tested_malaria, exclude = NULL)# 32 not malaria tested but denv tested. 166 malaria tested but not denv tested. 0 tested for neither. 2005 tested for both

denv_tested_malaria_tested <-  sum(!is.na(AIC$infected_denv_stfd) & !is.na(AIC$malaria), na.rm = TRUE)#1816 tested for both

denv_not_tested_malaria_not_tested  <-  sum(is.na(AIC$infected_denv_stfd) & is.na(AIC$malaria), na.rm = TRUE)#543
denv_not_tested_malaria_tested <-  sum(is.na(AIC$infected_denv_stfd) & !is.na(AIC$malaria), na.rm = TRUE)#88
denv_tested_malaria_not_tested <-  sum(!is.na(AIC$infected_denv_stfd) & is.na(AIC$malaria), na.rm = TRUE)#362

#  strata for malaria and denv------------------------------------------------------------------------
#denv and any malaria  
#Can you then create a DENV/malaria where all episodes can be defined as DENV/malaria pos, DENV pos, malaria pos, or DENV/malaria neg?
#What I would like is the AIC defined as follows:
#DENV: positive by RT-PCR, or IgG seroconversion (I've run your code but there are symptoms variables that give me errors.says they don't exist). Can you also query how many seroconverted bc, de, fg?
#this is the same way i have defined infection for desiree.

table(AIC$malaria, AIC$infected_denv_stfd, exclude = NULL)
denv_pos_malaria_neg <-  sum(AIC$infected_denv_stfd==1 & AIC$malaria==0, na.rm = TRUE)#42
denv_pos_malaria_pos <-  sum(AIC$infected_denv_stfd==1 & AIC$malaria==1, na.rm = TRUE)#47
denv_neg_malaria_neg <-  sum(AIC$infected_denv_stfd==0 & AIC$malaria==0, na.rm = TRUE)#876
denv_neg_malaria_pos <-  sum(AIC$infected_denv_stfd==0 & AIC$malaria==1, na.rm = TRUE)#1040

# malaria species------------------------------------------------------------------------
AIC$malaria_pf<-NA
AIC <- within(AIC, malaria_pf[AIC$result_rdt_malaria_keny==0 & AIC$malaria!=1] <- 0)#rdt
AIC <- within(AIC, malaria_pf[AIC$result_rdt_malaria_keny==1] <- 1)#rdt

AIC <- within(AIC, malaria_pf[AIC$microscopy_malaria_pf_kenya___1==0 & !is.na(AIC$result_microscopy_malaria_kenya) & AIC$malaria!=1] <- 0)#rdt
AIC <- within(AIC, malaria_pf[AIC$microscopy_malaria_pf_kenya___1==1] <- 1)#rdt

table(AIC$malaria_pf)#pf pos/neg
table(AIC$malaria)#malaria pos/neg
#1. Of the 1816, what was the distribution of Pf vs other species? Basically, I want to say this: "In our cohort, among the subjects with malaria whose Plasmodium species could be identified by blood smear microscopy, X of Y (%) were identified as Pf. P. malariae was identified in 7 subjects with malaria."
table(AIC$malaria)  
table(AIC$malaria_pf)  

# pf malaria strata------------------------------------------------------------------------
table(AIC$malaria_pf, AIC$infected_denv_stfd)
denv_pf_tested_events<-sum(!is.na(AIC$infected_denv_stfd) & !is.na(AIC$malaria_pf), na.rm = TRUE)
denv_pos_pf_neg <-  sum(AIC$infected_denv_stfd==1 & AIC$malaria_pf==0, na.rm = TRUE)#1511
denv_pos_pf_pos <-  sum(AIC$infected_denv_stfd==1 & AIC$malaria_pf==1, na.rm = TRUE)#27
denv_neg_pf_neg <-  sum(AIC$infected_denv_stfd==0 & AIC$malaria_pf==0, na.rm = TRUE)#665
denv_neg_pf_pos <-  sum(AIC$infected_denv_stfd==0 & AIC$malaria_pf==1, na.rm = TRUE)#796

#repate analyasis for both pf and malaria

#create strata: 1 = malaria+ & denv + | 2 = malaria+ denv - | 3= malaria- & denv - | 4= malaria- & denv + 
AIC$strata_all<-NA
AIC <- within(AIC, strata_all[AIC$malaria==1 & AIC$infected_denv_stfd==1] <- "malaria_pos_denv_pos")
AIC <- within(AIC, strata_all[AIC$malaria==1 & AIC$infected_denv_stfd==0] <- "malaria_pos_denv_neg")
AIC <- within(AIC, strata_all[AIC$malaria==0 & AIC$infected_denv_stfd==0] <- "malaria_neg_denv_neg")
AIC <- within(AIC, strata_all[AIC$malaria==0 & AIC$infected_denv_stfd==1] <- "malaria_neg_denv_pos")
table(AIC$strata_all)
AIC$excluded<-NA
AIC <- within(AIC, excluded[!is.na(AIC$malaria)&!is.na(AIC$infected_denv_stfd)] <- "included")
AIC <- within(AIC, excluded[is.na(AIC$malaria)|is.na(AIC$infected_denv_stfd)] <- "excluded")
table(AIC$excluded)

AIC[AIC$excluded=="excluded" & is.na(AIC$malaria) & AIC$infected_denv_stfd==1, c("person_id","int_date","infected_denv_stfd","malaria")]
co_infected <- AIC[AIC$strata_all=="malaria_pos_denv_pos", c("person_id","redcap_event_name","int_date","infected_denv_stfd","malaria","strata_all")]

table(AIC$excluded,AIC$infected_denv_stfd)
t.test(AIC$age~AIC$excluded)
boxplot(AIC$age~AIC$excluded,data=AIC, main="Age by Group", xlab="Groups", ylab="Years")

pedsqlnonna<-AIC[,c("person_id","redcap_event_name","strata_all","result_pcr_denv_kenya","result_pcr_denv_stfd","result_microscopy_malaria_kenya","density_microscpy_pf_kenya","interview_date_aic","rdt_results","temp","result_igg_denv_kenya","result_igg_denv_stfd")]
write.csv(pedsqlnonna,"pedsql_denv_malaria_strata_all.csv")

#create strata: 1 = pf+ & denv + | 2 = pf + denv - | 3= pf- & denv - | 4= pf - & denv + 
#d+, pf+, m+ / d+ pf- m - / d+pf-, m+ / d-p-m+ / d-pf-m- / d-pf+m+
AIC$strata<-NA
AIC <- within(AIC, strata[AIC$microscopy_malaria_pf_kenya___1==1 & AIC$infected_denv_stfd==1] <- "pf_pos_&_denv_pos")
AIC <- within(AIC, strata[AIC$result_rdt_malaria_kenya==1 & AIC$infected_denv_stfd==1] <- "pf_pos_&_denv_pos")

AIC <- within(AIC, strata[AIC$microscopy_malaria_pf_kenya___1==1 & AIC$infected_denv_stfd==0] <- "pf_pos_&_denv_neg")
AIC <- within(AIC, strata[AIC$result_rdt_malaria_kenya==1 & AIC$infected_denv_stfd==0] <- "pf_pos_&_denv_neg")

AIC <- within(AIC, strata[AIC$malaria==0 & AIC$infected_denv_stfd==0] <- "pf_neg_&_denv_neg")

AIC <- within(AIC, strata[AIC$malaria==0 & AIC$infected_denv_stfd==1] <- "pf_neg_&_denv_pos")
table(AIC$strata)  
table(AIC$strata_all)  
