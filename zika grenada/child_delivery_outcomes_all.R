child_outcome_ds<-ds2
child_outcome_vars.delivery<-grep("term_2|gestational_weeks_2_2|delivery_type|apgar_one|apgar_ten|outcome_of_delivery|neonatal_resusitation|ant_fontanelle|sutures|facial_dysmoph|cleft|red_reflex|plantar_reflex|galant_reflex|suck|grasp|moro|cong_abnormal|specify_cong_abnormal|chromosomal_abn|z_seizures|heart_rate|resp_rate|color|cry|tone|moving_limbs|cap_refill|child_referred|gender|muscle_tone_abnormal|resp_rate|temperature",names(child_outcome_ds),value = T)

child_outcome_vars.delivery<-grep(".pn|.12",child_outcome_vars.delivery,value = T)
child_outcomes <- CreateTableOne(vars = child_outcome_vars.delivery, data = child_outcome_ds,strata = "zikv_exposed_mom")
child_outcomes<-print(child_outcomes,quote = F, noSpaces = TRUE, includeNA=TRUE, printToggle = FALSE,smd=T)
write.csv(child_outcomes, file = "Delivery_Outcomes.csv")

# define normal/abnormal --------------------------------------------------------------------
child_outcome_ds$ant_fontanelle.pn.abnormal<-ifelse(child_outcome_ds$ant_fontanelle.pn == "sunken"|child_outcome_ds$ant_fontanelle.pn == "tense/buldging", 1, ifelse(child_outcome_ds$ant_fontanelle.pn=="Normal",0,NA))
table(child_outcome_ds$ant_fontanelle.pn.abnormal)

child_outcome_ds$apgar_one.pn.abnormal<-ifelse(child_outcome_ds$apgar_one.pn <7, 1, ifelse(child_outcome_ds$apgar_one.pn>=7,0,NA))
table(child_outcome_ds$apgar_one.pn.abnormal)

child_outcome_ds$apgar_ten.pn.abnormal<-ifelse(child_outcome_ds$apgar_ten.pn <7, 1, ifelse(child_outcome_ds$apgar_ten.pn>=7,0,NA))
table(child_outcome_ds$apgar_ten.pn.abnormal)

child_outcome_ds$apgar_one_2.12.abnormal<-ifelse(child_outcome_ds$apgar_one_2.12 <7, 1, ifelse(child_outcome_ds$apgar_one_2.12>=7,0,NA))
table(child_outcome_ds$apgar_one_2.12.abnormal)

child_outcome_ds$apgar_five.12.abnormal<-ifelse(child_outcome_ds$apgar_five.12 <7, 1, ifelse(child_outcome_ds$apgar_five.12>=7,0,NA))
table(child_outcome_ds$apgar_five.12.abnormal)

child_outcome_ds$apgar_ten_2.12.abnormal<-ifelse(child_outcome_ds$apgar_ten_2.12 <7, 1, ifelse(child_outcome_ds$apgar_ten_2.12>=7,0,NA))
table(child_outcome_ds$apgar_ten_2.12.abnormal)

child_outcome_ds$cleft.pn.abnormal<-ifelse(child_outcome_ds$cleft.pn == "Yes", 1, ifelse(child_outcome_ds$cleft.pn=="No",0,NA))
table(child_outcome_ds$cleft.pn.abnormal)

child_outcome_ds$cleft_2.12.abnormal<-ifelse(child_outcome_ds$cleft_2.12 == "Yes", 1, ifelse(child_outcome_ds$cleft_2.12=="No",0,NA))
table(child_outcome_ds$cleft_2.12.abnormal)

child_outcome_ds$facial_dysmoph.pn.abnormal<-ifelse(child_outcome_ds$facial_dysmoph.pn == "Yes", 1, ifelse(child_outcome_ds$facial_dysmoph.pn=="No",0,NA))
table(child_outcome_ds$facial_dysmoph.pn.abnormal)

child_outcome_ds$facial_dysmoph_2.12.abnormal<-ifelse(child_outcome_ds$facial_dysmoph_2.12 == "Yes", 1, ifelse(child_outcome_ds$facial_dysmoph_2.12=="No",0,NA))
table(child_outcome_ds$facial_dysmoph_2.12.abnormal)

child_outcome_ds$galant_reflex.pn.abnormal<-ifelse(child_outcome_ds$galant_reflex.pn == "absent", 1, ifelse(child_outcome_ds$galant_reflex.pn=="present",0,NA))
table(child_outcome_ds$galant_reflex.pn.abnormal)

#child_outcome_ds$gestational_weeks_2_2.12.abnormal_preterm<-ifelse(child_outcome_ds$gestational_weeks_2_2.12 < 37, 1, ifelse(child_outcome_ds$gestational_weeks_2_2.12>=37 & child_outcome_ds$gestational_weeks_2_2.12<41,0,NA))
#child_outcome_ds$gestational_weeks_2_2.12.abnormal_lateterm<-ifelse(child_outcome_ds$gestational_weeks_2_2.12 > 41, 1, ifelse(child_outcome_ds$gestational_weeks_2_2.12>=37 & child_outcome_ds$gestational_weeks_2_2.12<41,0,NA))

child_outcome_ds$neonatal_resusitation.pn.abnormal<-ifelse(child_outcome_ds$neonatal_resusitation.pn == "Yes", 1, ifelse(child_outcome_ds$neonatal_resusitation.pn=="No",0,NA))
table(child_outcome_ds$neonatal_resusitation.pn.abnormal)

child_outcome_ds$outcome_of_delivery.pn.abnormal<-ifelse(child_outcome_ds$outcome_of_delivery.pn == "Respiratory distress syndrome" | child_outcome_ds$outcome_of_delivery.pn == "Meconium aspiration", 1, ifelse(child_outcome_ds$outcome_of_delivery.pn=="No complications",0,NA))
table(child_outcome_ds$outcome_of_delivery.pn.abnormal)

child_outcome_ds$plantar_reflex.pn.abnormal<-ifelse(child_outcome_ds$plantar_reflex.pn  == "Absent", 1, ifelse(child_outcome_ds$plantar_reflex.pn =="Present",0,NA))
table(child_outcome_ds$plantar_reflex.pn.abnormal)

child_outcome_ds$plantar_reflex_2.12.abnormal<-ifelse(child_outcome_ds$plantar_reflex_2.12  == "Absent", 1, ifelse(child_outcome_ds$plantar_reflex_2.12 =="Present",0,NA))
table(child_outcome_ds$plantar_reflex_2.12.abnormal)

child_outcome_ds$red_reflex.pn.abnormal<-ifelse(child_outcome_ds$red_reflex.pn  == "No", 1, ifelse(child_outcome_ds$red_reflex.pn =="Yes",0,NA))
table(child_outcome_ds$red_reflex.pn.abnormal)

child_outcome_ds$red_reflex_2.12.abnormal<-ifelse(child_outcome_ds$red_reflex_2.12  == "No", 1, ifelse(child_outcome_ds$red_reflex_2.12 =="Yes",0,NA))
table(child_outcome_ds$red_reflex_2.12.abnormal)

child_outcome_ds$suck.pn.abnormal<-ifelse(child_outcome_ds$suck.pn  == "absent", 1, ifelse(child_outcome_ds$suck.pn =="present",0,NA))
table(child_outcome_ds$suck.pn.abnormal)

child_outcome_ds$sutures.pn.abnormal<-ifelse(child_outcome_ds$sutures.pn== "Overriding"|child_outcome_ds$sutures.pn== "Split", 1, ifelse(child_outcome_ds$sutures.pn =="Normal",0,NA))
table(child_outcome_ds$sutures.pn.abnormal)

child_outcome_ds$sutures_2.12.abnormal<-ifelse(child_outcome_ds$sutures_2.12== "Overriding"|child_outcome_ds$sutures_2.12== "Split", 1, ifelse(child_outcome_ds$sutures_2.12 =="Normal",0,NA))
table(child_outcome_ds$sutures_2.12.abnormal)


child_outcome_vars.delivery.pn<-grep(".pn",names(child_outcome_ds),value = T)
child_outcome_vars.delivery.pn<-grep(".abnormal",child_outcome_vars.delivery.pn,value = T)
child_outcome_vars.delivery.pn<- grep("cong|muscle_tone|ultrasound",child_outcome_vars.delivery.pn,value = T,invert = T)
child_outcome_ds$sum_delivery_Outcomes_abnormal.pn<-rowSums(child_outcome_ds[child_outcome_vars.delivery.pn],na.rm = T)
table(child_outcome_ds$sum_delivery_Outcomes_abnormal.pn)
ggplot2::ggplot(child_outcome_ds, aes(x = zikv_exposed_mom, y = sum_delivery_Outcomes_abnormal.pn)) + geom_boxplot() 

child_outcome_vars.delivery.12<-grep(".12",names(child_outcome_ds),value = T)
child_outcome_vars.delivery.12<-grep(".abnormal",child_outcome_vars.delivery.12,value = T)
child_outcome_vars.delivery.12<- grep("cong|muscle_tone|ultrasound",child_outcome_vars.delivery.12,value = T,invert = T)
child_outcome_ds$sum_delivery_Outcomes_abnormal.12<-rowSums(child_outcome_ds[child_outcome_vars.delivery.12],na.rm = T)
table(child_outcome_ds$sum_delivery_Outcomes_abnormal.12)
ggplot2::ggplot(child_outcome_ds, aes(x = zikv_exposed_mom, y = sum_delivery_Outcomes_abnormal.12)) + geom_boxplot() 

child_outcome_vars.delivery<-grep(".pn|.12",names(child_outcome_ds),value = T)
child_outcome_vars.delivery<-grep(".abnormal|term_2|gestational_weeks_2_2|delivery_type|apgar_one|apgar_five|apgar_ten|outcome_of_delivery|sutures|galant_reflex|suck|grasp|moro|cong_abnormal|specify_cong_abnormal|chromosomal_abn|z_seizures|heart_rate|resp_rate|cry|tone|moving_limbs|cap_refill|child_referred|gender|muscle_tone_abnormal|resp_rate|temperature",child_outcome_vars.delivery,value = T)
#    child_outcome_vars.delivery<- grep("cong|muscle_tone|ultrasound",child_outcome_vars.delivery,value = T,invert = T)
child_outcome_vars.delivery<- grep("ant_fontanelle.pn.abnormal|apgar_one.pn.abnormal|apgar_ten.pn.abnormal|apgar_five.12.abnormal|apgar_ten_2.12.abnormal",child_outcome_vars.delivery,value = T,invert = T)
nonnormal<-grep("gestational_weeks_2_2|apgar|heart_rate|resp_rate|resp_rate|temperature",child_outcome_vars.delivery,value = T)

save(child_outcome_ds,file="child_outcome_ds.rda")