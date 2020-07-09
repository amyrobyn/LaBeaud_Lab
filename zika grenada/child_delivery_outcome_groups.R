ds2<-ds2
# define normal/abnormal --------------------------------------------------------------------
ds2$assisted_delivery<-ifelse(ds2$delivery_type.pn == "Cesarean section"|ds2$delivery_type.pn == "Other assisted delivery (eg, forceps/ventouse)", 1, ifelse(ds2$delivery_type.pn=="Normal vaginal delivery",0,NA))
ds2$intrapartum_fever <-ifelse(ds2$outcome_of_delivery.pn == "Intrapartum fever", 1, 0)
ds2$neonate_need_resuscitation <-ifelse(ds2$outcome_of_delivery.pn == "Meconium aspiration"|ds2$outcome_of_delivery.pn == "Respiratory distress syndrome"|ds2$neonatal_resusitation == "Yes", 1, ifelse(ds2$neonatal_resusitation == "No"&ds2$outcome_of_delivery.pn == "No complications",0,NA))
ds2$apgar_one.pn.abnormal<-ifelse(ds2$apgar_one.pn <7, 1, ifelse(ds2$apgar_one.pn>=7,0,NA))
ds2$apgar_ten.pn.abnormal<-ifelse(ds2$apgar_ten.pn <7, 1, ifelse(ds2$apgar_ten.pn>=7,0,NA))
table(ds2$apgar_one.pn)
table(ds2$apgar_ten.pn)

ds2$preterm<-ifelse(ds2$gestational_weeks_2_2.12 < 37, 1, ifelse(ds2$gestational_weeks_2_2.12>=37 & ds2$gestational_weeks_2_2.12<41,0,NA))

table(ds2$preterm)
ds2$lateterm<-ifelse(ds2$gestational_weeks_2_2.12 > 41, 1, ifelse(ds2$gestational_weeks_2_2.12>=37 & ds2$gestational_weeks_2_2.12<41,0,NA))

ds2$facial_dysmoph_cleft <-ifelse(ds2$facial_dysmoph.pn == "Yes"|ds2$cleft.pn == "Yes", 1, ifelse(ds2$facial_dysmoph.pn == "No"&ds2$cleft.pn == "No",0,NA))
ds2$abnormal_reflex <-ifelse(ds2$plantar_reflex.pn == "Absent"|ds2$galant_reflex.pn == "absent"|ds2$suck.pn == "absent", 1, ifelse(ds2$plantar_reflex.pn == "Present"&ds2$galant_reflex.pn == "present"&ds2$suck.pn == "present",0,NA))
ds2$bulging_fontanelle<-ifelse(ds2$ant_fontanelle.pn == "tense/buldging", 1, ifelse(ds2$ant_fontanelle.pn=="Normal"|ds2$ant_fontanelle.pn == "sunken",0,NA))
ds2$split_sutures<-ifelse(ds2$sutures.pn== "Split", 1, ifelse(ds2$sutures.pn =="Normal"|ds2$sutures.pn== "Overriding",0,NA))
#summary
child_outcome_vars.delivery<-c("preterm","lateterm","assisted_delivery","intrapartum_fever","neonate_need_resuscitation","apgar_one.pn.abnormal","apgar_ten.pn.abnormal","split_sutures","bulging_fontanelle","abnormal_reflex","facial_dysmoph_cleft")
ds2$sum_delivery_Outcomes_abnormal.pn<-rowSums(ds2[child_outcome_vars.delivery],na.rm = T)
ds2 <- within(ds2, sum_delivery_Outcomes_abnormal.pn[is.na(ds2$intrapartum_fever)&is.na(ds2$assisted_delivery)&is.na(ds2$neonate_need_resuscitation)&is.na(ds2$apgar_ten.pn.abnormal)&is.na(ds2$apgar_one.pn.abnormal)&is.na(ds2$split_sutures)&is.na(ds2$bulging_fontanelle)&is.na(ds2$abnormal_reflex)&is.na(ds2$facial_dysmoph_cleft)&is.na(ds2$preterm)&is.na(ds2$facial_dysmoph_cleft)&is.na(ds2$preterm)&is.na(ds2$lateterm)] <- NA)

addmargins(table(ds2$sum_delivery_Outcomes_abnormal.pn,ds2$zikv_exposed_mom))
library(ggplot2)
ggplot2::ggplot(ds2, aes(x = zikv_exposed_mom, y = sum_delivery_Outcomes_abnormal.pn)) + geom_boxplot()