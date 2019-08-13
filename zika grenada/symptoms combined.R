symptoms_zika<-ds2[ds2$zikv_exposed_mom=="mom_ZIKV_Exposed",grep("symptoms_zika|^symptoms__|mother_record_id",names(ds2))]
symptoms_zika[symptoms_zika=="Unchecked"]<-0
symptoms_zika[symptoms_zika=="Checked"]<-1

symptoms_zika$fever<-NA
symptoms_zika <- within(symptoms_zika, fever[symptoms_zika$symptoms___1.mom==0|symptoms_zika$symptoms_zika___1.mom==0] <- 0)
symptoms_zika <- within(symptoms_zika, fever[symptoms_zika$symptoms___1.mom==1|symptoms_zika$symptoms_zika___1.mom==1] <- 1)

symptoms_zika$chills<-NA
symptoms_zika <- within(symptoms_zika, chills[symptoms_zika$symptoms___2.mom==0|symptoms_zika$symptoms_zika___3.mom==0] <- 0)
symptoms_zika <- within(symptoms_zika, chills[symptoms_zika$symptoms___2.mom==1|symptoms_zika$symptoms_zika___3.mom==1] <- 1)

symptoms_zika$body_ache<-NA
symptoms_zika <- within(symptoms_zika, body_ache[symptoms_zika$symptoms___3.mom==0|symptoms_zika$symptoms_zika___5.mom==0] <- 0)
symptoms_zika <- within(symptoms_zika, body_ache[symptoms_zika$symptoms___3.mom==1|symptoms_zika$symptoms_zika___5.mom==1] <- 1)

symptoms_zika$joint_pains<-NA
symptoms_zika <- within(symptoms_zika, joint_pains[symptoms_zika$symptoms___4.mom==0|symptoms_zika$symptoms_zika___6.mom==0] <- 0)
symptoms_zika <- within(symptoms_zika, joint_pains[symptoms_zika$symptoms___4.mom==1|symptoms_zika$symptoms_zika___6.mom==1] <- 1)

symptoms_zika$muscle_pains<-NA
symptoms_zika <- within(symptoms_zika, muscle_pains[symptoms_zika$symptoms___5.mom==0|symptoms_zika$symptoms_zika___7.mom==0] <- 0)
symptoms_zika <- within(symptoms_zika, muscle_pains[symptoms_zika$symptoms___5.mom==1|symptoms_zika$symptoms_zika___7.mom==1] <- 1)

symptoms_zika$bone_pains<-NA
symptoms_zika <- within(symptoms_zika, bone_pains[symptoms_zika$symptoms___6.mom==0|symptoms_zika$symptoms_zika___8.mom==0] <- 0)
symptoms_zika <- within(symptoms_zika, bone_pains[symptoms_zika$symptoms___6.mom==1|symptoms_zika$symptoms_zika___8.mom==1] <- 1)

symptoms_zika$itch<-NA
symptoms_zika <- within(symptoms_zika, itch[symptoms_zika$symptoms___7.mom==0|symptoms_zika$symptoms_zika___9.mom==0] <- 0)
symptoms_zika <- within(symptoms_zika, itch[symptoms_zika$symptoms___7.mom==1|symptoms_zika$symptoms_zika___9.mom==1] <- 1)

symptoms_zika$headache<-NA
symptoms_zika <- within(symptoms_zika, headache[symptoms_zika$symptoms___8.mom==0|symptoms_zika$symptoms_zika___10.mom==0] <- 0)
symptoms_zika <- within(symptoms_zika, headache[symptoms_zika$symptoms___8.mom==1|symptoms_zika$symptoms_zika___10.mom==1] <- 1)

symptoms_zika$pain_b_eye<-NA
symptoms_zika <- within(symptoms_zika, pain_b_eye[symptoms_zika$symptoms___9.mom==0|symptoms_zika$symptoms_zika___11.mom==0] <- 0)
symptoms_zika <- within(symptoms_zika, pain_b_eye[symptoms_zika$symptoms___9.mom==1|symptoms_zika$symptoms_zika___11.mom==1] <- 1)

symptoms_zika$dizzy<-NA
symptoms_zika <- within(symptoms_zika, dizzy[symptoms_zika$symptoms___10.mom==0|symptoms_zika$symptoms_zika___13.mom==0] <- 0)
symptoms_zika <- within(symptoms_zika, dizzy[symptoms_zika$symptoms___10.mom==1|symptoms_zika$symptoms_zika___13.mom==1] <- 1)

symptoms_zika$eye_sens_light<-NA
symptoms_zika <- within(symptoms_zika, eye_sens_light[symptoms_zika$symptoms___11.mom==0|symptoms_zika$symptoms_zika___14.mom==0] <- 0)
symptoms_zika <- within(symptoms_zika, eye_sens_light[symptoms_zika$symptoms___11.mom==1|symptoms_zika$symptoms_zika___14.mom==1] <- 1)

symptoms_zika$stiff_neck<-NA
symptoms_zika <- within(symptoms_zika, stiff_neck[symptoms_zika$symptoms___12.mom==0|symptoms_zika$symptoms_zika___15.mom==0] <- 0)
symptoms_zika <- within(symptoms_zika, stiff_neck[symptoms_zika$symptoms___12.mom==1|symptoms_zika$symptoms_zika___15.mom==1] <- 1)

symptoms_zika$red_eye<-NA
symptoms_zika <- within(symptoms_zika, red_eye[symptoms_zika$symptoms___13.mom==0|symptoms_zika$symptoms_zika___16.mom==0] <- 0)
symptoms_zika <- within(symptoms_zika, red_eye[symptoms_zika$symptoms___13.mom==1|symptoms_zika$symptoms_zika___16.mom==1] <- 1)

symptoms_zika$u_resp_inf<-NA
symptoms_zika <- within(symptoms_zika, u_resp_inf[symptoms_zika$symptoms___14.mom==0 | symptoms_zika$symptoms___15.mom==0 | symptoms_zika$symptoms___16.mom==0 | symptoms_zika$symptoms___17.mom==0] <- 0)
symptoms_zika <- within(symptoms_zika, u_resp_inf[symptoms_zika$symptoms___14.mom==1|symptoms_zika$symptoms___15.mom==1|symptoms_zika$symptoms___16.mom==1|symptoms_zika$symptoms___17.mom==1] <- 1)

symptoms_zika$short_breath<-NA
symptoms_zika <- within(symptoms_zika, short_breath[symptoms_zika$symptoms___18.mom==0] <- 0)
symptoms_zika <- within(symptoms_zika, short_breath[symptoms_zika$symptoms___18.mom==1] <- 1)

symptoms_zika$anorexia<-NA
symptoms_zika <- within(symptoms_zika, anorexia[symptoms_zika$symptoms___19.mom==0] <- 0)
symptoms_zika <- within(symptoms_zika, anorexia[symptoms_zika$symptoms___19.mom==1] <- 1)

symptoms_zika$funny_taste<-NA
symptoms_zika <- within(symptoms_zika, funny_taste[symptoms_zika$symptoms___20.mom==0] <- 0)
symptoms_zika <- within(symptoms_zika, funny_taste[symptoms_zika$symptoms___20.mom==1] <- 1)

symptoms_zika$nausea<-NA
symptoms_zika <- within(symptoms_zika, nausea[symptoms_zika$symptoms___21.mom==0] <- 0)
symptoms_zika <- within(symptoms_zika, nausea[symptoms_zika$symptoms___21.mom==1] <- 1)

symptoms_zika$vomit<-NA
symptoms_zika <- within(symptoms_zika, vomit[symptoms_zika$symptoms___22.mom==0] <- 0)
symptoms_zika <- within(symptoms_zika, vomit[symptoms_zika$symptoms___22.mom==1] <- 1)

symptoms_zika$Diarrhea<-NA
symptoms_zika <- within(symptoms_zika, Diarrhea[symptoms_zika$symptoms___23.mom==0] <- 0)
symptoms_zika <- within(symptoms_zika, Diarrhea[symptoms_zika$symptoms___23.mom==1] <- 1)

symptoms_zika$ab_pain<-NA
symptoms_zika <- within(symptoms_zika, ab_pain[symptoms_zika$symptoms___24.mom==0] <- 0)
symptoms_zika <- within(symptoms_zika, ab_pain[symptoms_zika$symptoms___24.mom==1] <- 1)

symptoms_zika$rash<-NA
symptoms_zika <- within(symptoms_zika, rash[symptoms_zika$symptoms___25.mom==0|symptoms_zika$symptoms_zika___17.mom==0] <- 0)
symptoms_zika <- within(symptoms_zika, rash[symptoms_zika$symptoms___25.mom==1|symptoms_zika$symptoms_zika___17.mom==1] <- 1)

symptoms_zika$bleeding<-NA
symptoms_zika <- within(symptoms_zika, bleeding[symptoms_zika$symptoms___26.mom==0 | symptoms_zika$symptoms___27.mom==0 | symptoms_zika$symptoms___28.mom==0  | symptoms_zika$symptoms___29.mom==0  | symptoms_zika$symptoms___30.mom==0 | symptoms_zika$symptoms___31.mom==0] <- 0)
symptoms_zika <- within(symptoms_zika, bleeding[symptoms_zika$symptoms___26.mom==1 | symptoms_zika$symptoms___27.mom==1 | symptoms_zika$symptoms___28.mom==1  | symptoms_zika$symptoms___29.mom==1  | symptoms_zika$symptoms___30.mom==1 | symptoms_zika$symptoms___31.mom==1] <- 1)

symptoms_zika$ims<-NA
symptoms_zika <- within(symptoms_zika, ims[symptoms_zika$symptoms___32.mom==0] <- 0)
symptoms_zika <- within(symptoms_zika, ims[symptoms_zika$symptoms___32.mom==1] <- 1)

symptoms_zika$weak_hand<-NA
symptoms_zika <- within(symptoms_zika, weak_hand[symptoms_zika$symptoms___34.mom==0|symptoms_zika$symptoms_zika___18.mom==0] <- 0)
symptoms_zika <- within(symptoms_zika, weak_hand[symptoms_zika$symptoms___34.mom==1|symptoms_zika$symptoms_zika___18.mom==1] <- 1)

symptoms_zika$seizures<-NA
symptoms_zika <- within(symptoms_zika, seizures[symptoms_zika$symptoms___33.mom==0|symptoms_zika$symptoms_zika___19.mom==0] <- 0)
symptoms_zika <- within(symptoms_zika, seizures[symptoms_zika$symptoms___33.mom==1|symptoms_zika$symptoms_zika___19.mom==1] <- 1)

symptoms_zika$other_symptom<-NA
symptoms_zika <- within(symptoms_zika, other_symptom[symptoms_zika$symptoms_zika___98.mom==0] <- 0)
symptoms_zika <- within(symptoms_zika, other_symptom[symptoms_zika$symptoms_zika___98.mom==1] <- 1)

symptoms_zika<-symptoms_zika[,c(1,56:82)]
symptoms_zika[2:28]<-lapply(symptoms_zika[2:28], as.numeric)
symptoms_zika$zika_symptom_sum<-rowSums(symptoms_zika[2:28])
lapply(symptoms_zika[2:29], table)

save(symptoms_zika,file="symptoms_zika.rda")

symptoms_zika_var<-names(symptoms_zika[,c(2:29)])
