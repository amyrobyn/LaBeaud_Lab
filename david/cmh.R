#CMH
AIC <- within(AIC, infected_denv_stfd[infected_denv_stfd==1] <-"DENV Pos" )
AIC <- within(AIC, infected_denv_stfd[infected_denv_stfd==0] <-"DENV Neg" )

AIC <- within(AIC, aic_symptom_abdominal_pain[aic_symptom_abdominal_pain==0] <-"no abdominal pain" )
AIC <- within(AIC, aic_symptom_abdominal_pain[aic_symptom_abdominal_pain==1] <-"abdominal pain" )

AIC <- within(AIC, aic_symptom_chills[aic_symptom_chills==0] <-"no chills" )
AIC <- within(AIC, aic_symptom_chills[aic_symptom_chills==1] <-"chills" )

AIC <- within(AIC, aic_symptom_nausea[aic_symptom_nausea==0] <-"no nausea" )
AIC <- within(AIC, aic_symptom_nausea[aic_symptom_nausea==1] <-"nausea" )

AIC <- within(AIC, aic_symptom_loss_of_appetite[aic_symptom_loss_of_appetite==0] <-"no loss_of_appetite" )
AIC <- within(AIC, aic_symptom_loss_of_appetite[aic_symptom_loss_of_appetite==1] <-"loss_of_appetite" )

AIC <- within(AIC, aic_symptom_joint_pains[aic_symptom_joint_pains==0] <-"no joint_pains" )
AIC <- within(AIC, aic_symptom_joint_pains[aic_symptom_joint_pains==1] <-"joint_pains" )

AIC <- within(AIC, aic_pe_tender[aic_pe_tender==0] <-"no joint_tender" )
AIC <- within(AIC, aic_pe_tender[aic_pe_tender==1] <-"joint_tender" )

AIC <- within(AIC, malaria[malaria==0] <-"Malaria neg" )
AIC <- within(AIC, malaria[malaria==1] <-"Malaria pos" )

denv <- table(AIC$infected_denv_stfd,AIC$aic_pe_tender)
denv_bymalaria <- table(AIC$infected_denv_stfd,AIC$aic_pe_tender,AIC$malaria)
prop.table(denv)
prop.table(denv, 1)
prop.table(denv, 2)
library(samplesizeCMH)

denv
odds.ratio(denv)
denv_bymalaria
apply(denv_bymalaria, 3, odds.ratio)
mantelhaen.test(denv_bymalaria)

library(DescTools)
BreslowDayTest(x = denv_bymalaria, OR = 1)
