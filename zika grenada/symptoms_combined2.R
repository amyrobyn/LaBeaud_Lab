symptoms_zika<-ds2[ds2$zikv_exposed_mom=="mom_ZIKV_Exposed_during_pregnancy"|ds2$zikv_exposed_mom=="mom_ZIKV_Exposure_possible_during_pregnancy",grep("symptoms_zika|^symptoms__|mother_record_id|redcap_repeat_instance",names(ds2))]
symptoms_zika[symptoms_zika=="Unchecked"]<-0
symptoms_zika[symptoms_zika=="Checked"]<-1

symptoms_zika$fever_group<-NA
symptoms_zika <- within(symptoms_zika, fever_group[symptoms_zika$symptoms___2.mom==0 | symptoms_zika$symptoms_zika___3.mom==0|symptoms_zika$symptoms___1.mom==0|symptoms_zika$symptoms_zika___1.mom==0] <- 0)
symptoms_zika <- within(symptoms_zika, fever_group[symptoms_zika$symptoms___2.mom==1|symptoms_zika$symptoms_zika___3.mom==1|symptoms_zika$symptoms___1.mom==1|symptoms_zika$symptoms_zika___1.mom==1] <- 1)

symptoms_zika$body_ache_group<-NA
symptoms_zika <- within(symptoms_zika, body_ache_group[symptoms_zika$symptoms___3.mom==0|symptoms_zika$symptoms_zika___5.mom==0|symptoms_zika$symptoms_zika___4==0|symptoms_zika$symptoms___5.mom==0|symptoms_zika$symptoms_zika___7.mom==0|symptoms_zika$symptoms___6.mom==0|symptoms_zika$symptoms_zika___8.mom==0|symptoms_zika$symptoms___4.mom==0|symptoms_zika$symptoms_zika___6.mom==0] <- 0)
symptoms_zika <- within(symptoms_zika, body_ache_group[symptoms_zika$symptoms_zika___4==1|symptoms_zika$symptoms___6.mom==1|symptoms_zika$symptoms_zika___8.mom==1|symptoms_zika$symptoms___5.mom==1|symptoms_zika$symptoms_zika___7.mom==1|symptoms_zika$symptoms___4.mom==1|symptoms_zika$symptoms_zika___6.mom==1|symptoms_zika$symptoms___3.mom==1|symptoms_zika$symptoms_zika___5.mom==1] <- 1)
table(symptoms_zika$body_ache_group)

symptoms_zika$itch_rash_group<-NA
symptoms_zika <- within(symptoms_zika, itch_rash_group[symptoms_zika$symptoms___25.mom==0|symptoms_zika$symptoms_zika___17.mom==0|symptoms_zika$symptoms___7.mom==0|symptoms_zika$symptoms_zika___9.mom==0] <- 0)
symptoms_zika <- within(symptoms_zika, itch_rash_group[symptoms_zika$symptoms___25.mom==1|symptoms_zika$symptoms_zika___17.mom==1|symptoms_zika$symptoms___7.mom==1|symptoms_zika$symptoms_zika___9.mom==1] <- 1)
table(symptoms_zika$itch_rash_group)

symptoms_zika$headache_group<-NA
symptoms_zika <- within(symptoms_zika, headache_group[symptoms_zika$symptoms___9.mom==0|symptoms_zika$symptoms_zika___11.mom==0|symptoms_zika$symptoms___8.mom==0|symptoms_zika$symptoms_zika___10.mom==0] <- 0)
symptoms_zika <- within(symptoms_zika, headache_group[symptoms_zika$symptoms___8.mom==1|symptoms_zika$symptoms_zika___10.mom==1|symptoms_zika$symptoms___9.mom==1|symptoms_zika$symptoms_zika___11.mom==1] <- 1)
table(symptoms_zika$headache_group)

symptoms_zika$neurologic_symptoms_group<-NA
symptoms_zika <- within(symptoms_zika, neurologic_symptoms_group[symptoms_zika$symptoms___34.mom==0|symptoms_zika$symptoms_zika___18.mom==0|symptoms_zika$symptoms___32.mom==0|symptoms_zika$symptoms___33.mom==0|symptoms_zika$symptoms_zika___19.mom==0 | symptoms_zika$symptoms___12.mom==0|symptoms_zika$symptoms_zika___15.mom==0|symptoms_zika$symptoms___10.mom==0|symptoms_zika$symptoms_zika___13.mom==0|symptoms_zika$symptoms___11.mom==0|symptoms_zika$symptoms_zika___14.mom==0] <- 0)
symptoms_zika <- within(symptoms_zika, neurologic_symptoms_group[symptoms_zika$symptoms___33.mom==1|symptoms_zika$symptoms_zika___19.mom==1|symptoms_zika$symptoms___12.mom==1|symptoms_zika$symptoms_zika___15.mom==1|symptoms_zika$symptoms___34.mom==1|symptoms_zika$symptoms_zika___18.mom==1|symptoms_zika$symptoms___32.mom==1|symptoms_zika$symptoms___10.mom==1|symptoms_zika$symptoms_zika___13.mom==1|symptoms_zika$symptoms___11.mom==1|symptoms_zika$symptoms_zika___14.mom==1] <- 1)

symptoms_zika$Conjunctivitis_group<-NA
symptoms_zika <- within(symptoms_zika, Conjunctivitis_group[symptoms_zika$symptoms___13.mom==0|symptoms_zika$symptoms_zika___16.mom==0|symptoms_zika___2.mom==0] <- 0)
symptoms_zika <- within(symptoms_zika, Conjunctivitis_group[symptoms_zika$symptoms___13.mom==1|symptoms_zika$symptoms_zika___16.mom==1|symptoms_zika___2.mom==1] <- 1)

symptoms_zika$respiratory_symptoms_group<-NA
symptoms_zika <- within(symptoms_zika, respiratory_symptoms_group[symptoms_zika$symptoms___14.mom==0 | symptoms_zika$symptoms___15.mom==0 | symptoms_zika$symptoms___16.mom==0 | symptoms_zika$symptoms___17.mom==0| symptoms_zika$symptoms___18.mom==0] <- 0)
symptoms_zika <- within(symptoms_zika, respiratory_symptoms_group[symptoms_zika$symptoms___14.mom==1|symptoms_zika$symptoms___15.mom==1|symptoms_zika$symptoms___16.mom==1|symptoms_zika$symptoms___17.mom==1|symptoms_zika$symptoms___18.mom==1] <- 1)

symptoms_zika$abdominal_complaints_group<-NA
symptoms_zika <- within(symptoms_zika, abdominal_complaints_group[symptoms_zika$symptoms___19.mom==0|symptoms_zika$symptoms___21.mom==0|symptoms_zika$symptoms___22.mom==0|symptoms_zika$symptoms___24.mom==0|symptoms_zika$symptoms___23.mom==0] <- 0)
symptoms_zika <- within(symptoms_zika, abdominal_complaints_group[symptoms_zika$symptoms___19.mom==1|symptoms_zika$symptoms___21.mom==1|symptoms_zika$symptoms___22.mom==1|symptoms_zika$symptoms___23.mom==1|symptoms_zika$symptoms___24.mom==1] <- 1)

symptoms_zika$bleeding_group<-NA
symptoms_zika <- within(symptoms_zika, bleeding_group[symptoms_zika$symptoms___26.mom==0 | symptoms_zika$symptoms___27.mom==0 | symptoms_zika$symptoms___28.mom==0  | symptoms_zika$symptoms___29.mom==0  | symptoms_zika$symptoms___30.mom==0 | symptoms_zika$symptoms___31.mom==0] <- 0)
symptoms_zika <- within(symptoms_zika, bleeding_group[symptoms_zika$symptoms___26.mom==1 | symptoms_zika$symptoms___27.mom==1 | symptoms_zika$symptoms___28.mom==1  | symptoms_zika$symptoms___29.mom==1  | symptoms_zika$symptoms___30.mom==1 | symptoms_zika$symptoms___31.mom==1] <- 1)

symptoms_zika$lymphadenopathy_group<-NA
symptoms_zika <- within(symptoms_zika, lymphadenopathy_group[symptoms_zika$symptoms_zika___12.mom==0] <- 0)
symptoms_zika <- within(symptoms_zika, lymphadenopathy_group[symptoms_zika$symptoms_zika___12.mom==1] <- 1)

symptoms_zika<-symptoms_zika[,c(1:2,57:66)]

symptoms_zika[3:12]<-lapply(symptoms_zika[3:12], as.numeric)
symptoms_zika$zika_symptom_sum_groups<-rowSums(symptoms_zika[3:12])

symptoms_zika_group_var<-names(symptoms_zika[,c(3:13)])
lapply(symptoms_zika[3:13], table)
symptoms_zika_groups<-symptoms_zika

#save(symptoms_zika,file="symptoms_zika_groups.rda")
