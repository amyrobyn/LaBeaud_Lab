setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/david coinfectin paper/data")
coinfection <- read.csv("david_severity_final.csv")
coinfection <-data.frame(coinfection, row.names = "studyid")
save(coinfection,file="coinfection.Rda")

install.packages("FactoMineR")
library(FactoMineR)
#factors_group <- c("group", "all_symptoms_halitosis" , "all_symptoms_edema" , "all_symptoms_appetite_change" , "all_symptoms_behavior_change" , "all_symptoms_altms" , "all_symptoms_jaundice" , "all_symptoms_constitutional" , "all_symptoms_asthma" , "all_symptoms_lethergy" , "all_symptoms_dysphagia" , "all_symptoms_dysphrea" , "all_symptoms_seizure" , "all_symptoms_itchiness" , "all_symptoms_bleeding_symptom" , "all_symptoms_sore_throat" , "all_symptoms_earache" , "all_symptoms_funny_taste" , "all_symptoms_mucosal_bleed_brs" , "all_symptoms_rash" , "all_symptoms_dysuria" , "all_symptoms_nausea" , "all_symptoms_respiratory" , "all_symptoms_aches_pains" , "all_symptoms_abdominal_pain" , "all_symptoms_diarrhea" , "all_symptoms_vomiting" , "all_symptoms_chiils" , "all_symptoms_fever" , "all_symptoms_eye_symptom" , "all_symptoms_other")
#factors_hospital <- c("outcomehospitalized", "all_symptoms_halitosis" , "all_symptoms_edema" , "all_symptoms_appetite_change" , "all_symptoms_behavior_change" , "all_symptoms_altms" , "all_symptoms_jaundice" , "all_symptoms_constitutional" , "all_symptoms_asthma" , "all_symptoms_lethergy" , "all_symptoms_dysphagia" , "all_symptoms_dysphrea" , "all_symptoms_seizure" , "all_symptoms_itchiness" , "all_symptoms_bleeding_symptom" , "all_symptoms_sore_throat" , "all_symptoms_earache" , "all_symptoms_funny_taste" , "all_symptoms_mucosal_bleed_brs" , "all_symptoms_rash" , "all_symptoms_dysuria" , "all_symptoms_nausea" , "all_symptoms_respiratory" , "all_symptoms_aches_pains" , "all_symptoms_abdominal_pain" , "all_symptoms_diarrhea" , "all_symptoms_vomiting" , "all_symptoms_chiils" , "all_symptoms_fever" , "all_symptoms_eye_symptom" , "all_symptoms_other")

factors_group <- c("group", "all_symptoms_halitosis" , "all_symptoms_edema")
factors_hospital <- c("outcomehospitalized", "all_symptoms_halitosis" , "all_symptoms_edema")

pcadata_group <- coinfection[factors_group]
pcadata_hospital <- coinfection[factors_hospital]

PCA(pcadata_group)
PCA(pcadata_hospital)

res1 <- PCA(pcadata_hospital)
res2 <- PCA(pcadata_group)

dimdesc(res1, axes=1)  # show correlation of variables with 1st axis
res1$var$coord  # show loadings associated to each axis

dimdesc(res2, axes=1)  # show correlation of variables with 1st axis
res2$var$coord  # show loadings associated to each axis