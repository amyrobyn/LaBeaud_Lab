#order factors ---------------------------------------------
  AIC$aic_symptom_dizziness <- factor(AIC$aic_symptom_dizziness, levels = c(1, 0))
  AIC$aic_pe_decreased_strength <- factor(AIC$aic_pe_decreased_strength, levels = c(1, 0))
  AIC$aic_pe_icteric_sclerae <- factor(AIC$aic_pe_icteric_sclerae, levels = c(1, 0))
  AIC$aic_symptom_abdominal_pain <- factor(AIC$aic_symptom_abdominal_pain, levels = c(1, 0))
  AIC$aic_pe_swollen <- factor(AIC$aic_pe_swollen, levels = c(1, 0))
  AIC$aic_pe_tender <- factor(AIC$aic_pe_tender, levels = c(1, 0))
  AIC$infected_denv_stfd <- factor(AIC$infected_denv_stfd, levels = c(1, 0))
  
  #AIC$strata_all <- factor(AIC$strata_all, levels = c("malaria_pos_denv_pos", "malaria_neg_denv_pos", "malaria_pos_denv_neg","malaria_neg_denv_neg"))
  
  #CMH for all significant symptoms ---------------------------------------------
  attach(AIC)
#  install.packages("questionr")
  library(questionr)
  odds.ratio(table(malaria,aic_symptom_dizziness), level =.99)
  apply(table(malaria,aic_symptom_dizziness,infected_denv_stfd), 3, odds.ratio,level=.99)
  mantelhaen.test(table(malaria,aic_symptom_dizziness,infected_denv_stfd),conf.level = 0.99)
  
  mantelhaen.test(table(infected_denv_stfd,aic_symptom_dizziness,malaria))
  
  odds.ratio(table(infected_denv_stfd,aic_pe_decreased_strength))
  apply(table(infected_denv_stfd,aic_pe_decreased_strength,malaria), 3, odds.ratio)
  mantelhaen.test(table(infected_denv_stfd,aic_pe_decreased_strength,malaria))
  
  odds.ratio(table(infected_denv_stfd,aic_pe_icteric_sclerae))
  apply(table(infected_denv_stfd,aic_pe_icteric_sclerae,malaria), 3, odds.ratio)
  mantelhaen.test(table(infected_denv_stfd,aic_pe_icteric_sclerae,malaria))

  odds.ratio(table(aic_symptom_abdominal_pain,infected_denv_stfd))
  apply(table(infected_denv_stfd,aic_symptom_abdominal_pain,malaria), 3, odds.ratio)
  mantelhaen.test(table(infected_denv_stfd,aic_symptom_abdominal_pain,malaria))
  
  odds.ratio(table(infected_denv_stfd,aic_pe_swollen))
  apply(table(infected_denv_stfd,aic_pe_swollen,malaria), 3, odds.ratio)
  mantelhaen.test(table(infected_denv_stfd,aic_pe_swollen,malaria))
  
  