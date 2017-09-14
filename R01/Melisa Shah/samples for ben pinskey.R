#select melisa samples for ben pinskey
  setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long")
#load data that has been cleaned previously
  load("aic_dummy_symptoms.clean.rda") #load the data from your local directory (this will save you time later rather than always downolading from redcap.)
  R01_lab_results<-aic_dummy_symptoms
  table(R01_lab_results$date_symptom_onset, R01_lab_results$id_cohort)
    
  table(aic_dummy_symptoms$nodes, aic_dummy_symptoms$id_cohort)
  table(aic_dummy_symptoms$aic_pe_large_lymph_nodes, aic_dummy_symptoms$id_cohort)
  

R01_lab_results$site <-NA
R01_lab_results <- within(R01_lab_results, id_city[R01_lab_results$id_city=="R"] <- "C")
R01_lab_results <- within(R01_lab_results, site[R01_lab_results$id_city=="C"] <- "west")
R01_lab_results <- within(R01_lab_results, site[R01_lab_results$id_city=="K"] <- "west")

R01_lab_results <- within(R01_lab_results, site[R01_lab_results$id_city=="G"] <- "coast")
R01_lab_results <- within(R01_lab_results, site[R01_lab_results$id_city=="L"] <- "coast")
R01_lab_results <- within(R01_lab_results, site[R01_lab_results$id_city=="M"] <- "coast")
R01_lab_results <- within(R01_lab_results, site[R01_lab_results$id_city=="U"] <- "coast")
table(R01_lab_results$site)

# subset of the variables
melisa_samples<-R01_lab_results[which(R01_lab_results$id_cohort=="F" | R01_lab_results$id_cohort=="M" ), ]
table(melisa_samples$nodes)
melisa_samples$nodes<-as.factor(melisa_samples$nodes)

    #fever
      melisa_samples$fever_dummy<-NA
      melisa_samples <- within(melisa_samples, fever_dummy[melisa_samples$aic_symptom_fever==1|melisa_samples$temp>=38] <- 1)
      table(melisa_samples$fever_dummy)
    #lymphadenopathy
      melisa_samples$lymphadenopathy<-NA
      table(melisa_samples$nodes, exclude = NULL)
      melisa_samples <- within(melisa_samples, nodes[melisa_samples$nodes==""] <- NA)
      melisa_samples <- within(melisa_samples, lymphadenopathy[!is.na(melisa_samples$nodes) & melisa_samples$nodes!="normal"] <- 1)
      
      melisa_samples <- within(melisa_samples, oth_nodes[melisa_samples$oth_nodes==""] <- NA)
      melisa_samples <- within(melisa_samples, lymphadenopathy[!is.na(melisa_samples$oth_nodes) & melisa_samples$oth_nodes!="normal"] <- 1)
      melisa_samples <- within(melisa_samples, lymphadenopathy[melisa_samples$aic_pe_large_lymph_nodes==1] <- 1)

      table(melisa_samples$lymphadenopathy)
    #arthralgia 
      melisa_samples$arthralgia<-NA
      melisa_samples<- within(melisa_samples, arthralgia[aic_symptom_joint_pains==1] <- 1)
      melisa_samples <- within(melisa_samples, joints[melisa_samples$joints==""] <- NA)
      melisa_samples<- within(melisa_samples, arthralgia[!is.na(melisa_samples$joints) & melisa_samples$joints!="normal"& melisa_samples$joints!=""] <- 1)
      
#create variable for melisa samples
      melisa_samples$melisa_sample<-NA
      melisa_samples<- within(melisa_samples, melisa_sample[ melisa_samples$fever_dummy==1 & melisa_samples$lymphadenopathy==1] <- 1)
      melisa_samples<- within(melisa_samples, melisa_sample[melisa_samples$fever_dummy==1 & melisa_samples$date_symptom_onset<=5] <- 1)
      melisa_samples<- within(melisa_samples, melisa_sample[ melisa_samples$fever_dummy==1 & melisa_samples$arthralgia==1] <- 1)
      
      
      table(melisa_samples$melisa_sample, melisa_samples$cdna_at_stfd)
    
      melisa_samples<-melisa_samples[which(melisa_samples$melisa_sample ==1), ]
      melisa_samples <- melisa_samples[, grepl("person_id|redcap_event|all_symptoms|id_c|id_v|visit_type|temp|fever|head_neck|lymph|node|melisa|cdna|arthralgia|malaria|microscopy|aic_symptom_joint_pains|date_symptom_onset|joint", names(melisa_samples))]
      melisa_samples <- melisa_samples[, !grepl("antigen|aliquot|photo|tempus", names(melisa_samples))]
      melisa_samples<-melisa_samples[,order(colnames(melisa_samples))]
      melisa_samples<-melisa_samples[order(-(grepl('melisa|redcap|person_id|node|temp|fever|lymph|cdna', names(melisa_samples)))+1L)]
      melisa_samples<-melisa_samples[order(-(grepl('lymphadenopathy|aic_symptom_joint_pains|fever_dummy|cdna_at_stfd|date_symptom_onset|joint|node|arthralgia', names(melisa_samples)))+1L)]
      melisa_samples<-melisa_samples[order(-(grepl('melisa|redcap|person_id', names(melisa_samples)))+1L)]
  #export to csv
      setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/melisa shah")
      f <- "melisa_samples_ben_pinskey.csv"
      write.csv(as.data.frame(melisa_samples), f )
