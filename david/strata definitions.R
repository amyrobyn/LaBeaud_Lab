#denv case defination------------------------------------------------------------------------
#redefine infected_denv_stfd to exclude ufi. 
#stfd denv igg seroconverters or PCR positives as infected.
AIC$infected_denv_kenya[AIC$tested_denv_kenya_igg ==1 | AIC$result_pcr_denv_kenya==0|AIC$result_pcr_denv_stfd==0|AIC$denv_result_ufi==0]<-0
AIC$infected_denv_kenya[AIC$seroc_denv_kenya_igg==1|AIC$result_pcr_denv_kenya==1|AIC$result_pcr_denv_stfd==1|AIC$denv_result_ufi==1]<-1
table(AIC$infected_denv_kenya, AIC$denv_result_ufi)
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

#create strata: 1 = malaria+ & denv + | 2 = malaria+ denv - | 3= malaria- & denv - | 4= malaria- & denv + 
AIC$strata_all<-NA
AIC <- within(AIC, strata_all[AIC$malaria==1 & AIC$infected_denv_stfd==1] <- "malaria_pos_denv_pos")
AIC <- within(AIC, strata_all[AIC$malaria==1 & AIC$infected_denv_stfd==0] <- "malaria_pos_denv_neg")
AIC <- within(AIC, strata_all[AIC$malaria==0 & AIC$infected_denv_stfd==0] <- "malaria_neg_denv_neg")
AIC <- within(AIC, strata_all[AIC$malaria==0 & AIC$infected_denv_stfd==1] <- "malaria_neg_denv_pos")
table(AIC$strata_all)

#create strata: 1 = malaria+ & denv + | 2 = malaria+ denv - | 3= malaria- & denv - | 4= malaria- & denv + 
AIC$denv_strata<-NA
AIC <- within(AIC, denv_strata[AIC$malaria==1 & AIC$infected_denv_stfd==1] <- "DENV/Malaria co-infection")
AIC <- within(AIC, denv_strata[AIC$malaria==0 & AIC$infected_denv_stfd==1] <- "DENV solo infection")
AIC <- within(AIC, denv_strata[is.na(AIC$malaria) & AIC$infected_denv_stfd==1] <- "DENV infection without malaria testing")
table(AIC$denv_strata)

AIC$excluded<-NA
AIC <- within(AIC, excluded[!is.na(AIC$malaria)&!is.na(AIC$infected_denv_stfd)] <- "included")
AIC <- within(AIC, excluded[is.na(AIC$malaria)|is.na(AIC$infected_denv_stfd)] <- "excluded")
table(AIC$excluded)

AIC[AIC$excluded=="excluded" & is.na(AIC$malaria) & AIC$infected_denv_stfd==1, c("person_id","int_date","infected_denv_stfd","malaria")]
co_infected <- AIC[AIC$strata_all=="malaria_pos_denv_pos", c("person_id","redcap_event_name","int_date","infected_denv_stfd","malaria","strata_all")]

table(AIC$excluded,AIC$infected_denv_stfd)
t.test(AIC$age~AIC$excluded)
boxplot(AIC$age~AIC$excluded,data=AIC, main="Age by Group", xlab="Groups", ylab="Years")
