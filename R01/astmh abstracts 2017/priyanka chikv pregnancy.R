library(REDCapR)
library(redcapAPI)

#priyanka grenada chikv pregnancy abstract
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/greneda chikv")

Redcap.token <- readLines("api.key.txt") # Read API token from folder
#Redcap.token <- "82F1C4081DEF007B8D4DE287426046E1"
REDcap.URL  <- 'https://redcap.stanford.edu/api/'
rcon <- redcapConnection(url=REDcap.URL, token=Redcap.token)

#export data from redcap to R (must be connected via cisco VPN)
chikv_nd <- redcap_read(  redcap_uri  = REDcap.URL,  token       = Redcap.token,  batch_size = 300, raw_or_label="raw")$data
#keep only those meeting subject inclusion criteria.
  #subjects<-chikv_nd[which(chikv_nd$trimester!=99 & chikv_nd$pregnant!=99 & chikv_nd$result_mother!=99 & !is.na(chikv_nd$result_mother)), ]
  subjects<-chikv_nd
table(chikv_nd$trimester)
  table(subjects$trimester)

#To date 212 participants have been recruited and classified into 2 groups by reported history: 
#those infected with CHIKV during pregnancy and those not infected during pregnancy. 
  subjects$preg_chikvpos<-NA
  subjects <- within(subjects, preg_chikvpos[subjects$pregnant == 0 | subjects$result_mother==0] <- 0)
  subjects <- within(subjects, preg_chikvpos[subjects$result_mother==1 & subjects$pregnant==1 & !(is.na(subjects$trimester)) & subjects$trimester!=99] <- 1)
  subjects<-subjects[which(!is.na(subjects$preg_chikvpos)), ]
  table(subjects$preg_chikvpos,subjects$trimester)
  table(subjects$preg_chikvpos,subjects$result_mother)
  table(subjects$preg_chikvpos,subjects$pregnant)
  
#table of results versus pregannt.
  table(subjects$result_mother, subjects$pregnant)

#complications by group
  subjects <- within(subjects, first_few_months_illness[first_few_months_illness == 99] <- NA)
  subjects <- within(subjects, after_birth_problems[after_birth_problems == 99] <- NA)
  subjects <- within(subjects, complications[complications == 99] <- NA)
    table(subjects$complications, subjects$preg_chikvpos)

#export symptoms to excel for charts
    f <- "chikv_nd_subjects.csv"
    write.csv(as.data.frame(subjects), f, na = "" )
    
#subset symptoms
    symptoms<-subjects[ , grepl("symptom|participant_id", names(subjects)) ]
    symptoms[,] <- lapply(symptoms[,], factor)
    summary(symptoms)
    
    symptoms_long<-reshape(symptoms, idvar = "participant_id", varying = 2:35,  direction = "long", timevar = "symptom_type", times=1:34, v.names="symptoms")
#label symtpoms
    symptoms_long <- within(symptoms_long, symptom_type[symptom_type==1] <- "fever")
    symptoms_long <- within(symptoms_long, symptom_type[symptom_type==2] <- "chills")
    symptoms_long <- within(symptoms_long, symptom_type[symptom_type==3] <- "general body ache")
    symptoms_long <- within(symptoms_long, symptom_type[symptom_type==4] <- "joint pains")
    symptoms_long <- within(symptoms_long, symptom_type[symptom_type==5] <- "muscle pains")
    symptoms_long <- within(symptoms_long, symptom_type[symptom_type==6] <- "bone pains")
    symptoms_long <- within(symptoms_long, symptom_type[symptom_type==7] <- "itchiness")
    symptoms_long <- within(symptoms_long, symptom_type[symptom_type==8] <- "headache")
    symptoms_long <- within(symptoms_long, symptom_type[symptom_type==9] <- "pain behind eyes")
    symptoms_long <- within(symptoms_long, symptom_type[symptom_type==10] <- "dizziness")
    symptoms_long <- within(symptoms_long, symptom_type[symptom_type==11] <- "eyes sensitive to light")
    symptoms_long <- within(symptoms_long, symptom_type[symptom_type==12] <- "stiff neck")
    symptoms_long <- within(symptoms_long, symptom_type[symptom_type==13] <- "red eyes")
    symptoms_long <- within(symptoms_long, symptom_type[symptom_type==14] <- "runny nose")
    symptoms_long <- within(symptoms_long, symptom_type[symptom_type==15] <- "earache")
    symptoms_long <- within(symptoms_long, symptom_type[symptom_type==16] <- "sore throat")
    symptoms_long <- within(symptoms_long, symptom_type[symptom_type==17] <- "cough")
    symptoms_long <- within(symptoms_long, symptom_type[symptom_type==18] <- "shortness of breath")
    symptoms_long <- within(symptoms_long, symptom_type[symptom_type==19] <- "loss of appetite")
    symptoms_long <- within(symptoms_long, symptom_type[symptom_type==20] <- "funny tast in mouth")
    symptoms_long <- within(symptoms_long, symptom_type[symptom_type==21] <- "nausea")
    symptoms_long <- within(symptoms_long, symptom_type[symptom_type==22] <- "vomiting")
    symptoms_long <- within(symptoms_long, symptom_type[symptom_type==23] <- "Diarrhea")
    symptoms_long <- within(symptoms_long, symptom_type[symptom_type==24] <- "Abdominal pain")
    symptoms_long <- within(symptoms_long, symptom_type[symptom_type==25] <- "Rash")
    symptoms_long <- within(symptoms_long, symptom_type[symptom_type==26] <- "bloody nose")
    symptoms_long <- within(symptoms_long, symptom_type[symptom_type==27] <- "bleeding gums")
    symptoms_long <- within(symptoms_long, symptom_type[symptom_type==28] <- "bloody stools")
    symptoms_long <- within(symptoms_long, symptom_type[symptom_type==29] <- "bloody vomit")
    symptoms_long <- within(symptoms_long, symptom_type[symptom_type==30] <- "bloody urine")
    symptoms_long <- within(symptoms_long, symptom_type[symptom_type==31] <- "bruises or bleeding into the skin")
    symptoms_long <- within(symptoms_long, symptom_type[symptom_type==32] <- "impaired mental status")
    symptoms_long <- within(symptoms_long, symptom_type[symptom_type==33] <- "seizures")
    symptoms_long <- within(symptoms_long, symptom_type[symptom_type==34] <- "hand weakness")
#export symptoms to excel for charts
    f <- "symptoms.csv"
    write.csv(as.data.frame(symptoms_long), f )
    
