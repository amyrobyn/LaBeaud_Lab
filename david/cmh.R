attach(AIC)
#order factors ---------------------------------------------
  aic_symptom_dizziness <- factor(aic_symptom_dizziness, levels = c(1, 0))#switch factor order so two by two table has 1,1 in top left hand corner.
  aic_pe_decreased_strength <- factor(aic_pe_decreased_strength, levels = c(1, 0))
  aic_pe_icteric_sclerae <- factor(aic_pe_icteric_sclerae, levels = c(1, 0))
  aic_symptom_abdominal_pain <- factor(aic_symptom_abdominal_pain, levels = c(1, 0))
  aic_pe_swollen <- factor(aic_pe_swollen, levels = c(1, 0))
  aic_pe_tender <- factor(aic_pe_tender, levels = c(1, 0))
  infected_denv_stfd <- factor(infected_denv_stfd, levels = c(1, 0))
  malaria <- factor(malaria, levels = c(1, 0))
  #CMH for all significant symptoms ---------------------------------------------
#  install.packages("questionr")
  library(questionr)
  table(malaria,aic_symptom_dizziness)#table for crude OR.
  odds.ratio(table(malaria,aic_symptom_dizziness), level =.99)
  table(malaria,aic_symptom_dizziness,infected_denv_stfd)#table for stratifieid OR
  apply(table(malaria,aic_symptom_dizziness,infected_denv_stfd), 3, odds.ratio,level=.99)
  table(malaria,aic_symptom_dizziness,infected_denv_stfd)#table for CMH
  mantelhaen.test(table(malaria,aic_symptom_dizziness,infected_denv_stfd),conf.level = 0.99)
  
  odds.ratio(table(infected_denv_stfd,aic_pe_decreased_strength))
  apply(table(malaria,aic_pe_decreased_strength,infected_denv_stfd), 3, odds.ratio)
  mantelhaen.test(table(malaria,aic_pe_decreased_strength,infected_denv_stfd))
  
  odds.ratio(table(infected_denv_stfd,aic_pe_icteric_sclerae))
  apply(table(malaria,aic_pe_icteric_sclerae,infected_denv_stfd), 3, odds.ratio)
  mantelhaen.test(table(malaria,aic_pe_icteric_sclerae,infected_denv_stfd))

  odds.ratio(table(aic_symptom_abdominal_pain,infected_denv_stfd))
  apply(table(malaria,aic_symptom_abdominal_pain,infected_denv_stfd), 3, odds.ratio)
  mantelhaen.test(table(malaria,aic_symptom_abdominal_pain,infected_denv_stfd))
  
  odds.ratio(table(infected_denv_stfd,aic_pe_swollen))
  apply(table(malaria,aic_pe_swollen,infected_denv_stfd), 3, odds.ratio)
  mantelhaen.test(table(malaria,aic_pe_swollen,infected_denv_stfd))
  
  