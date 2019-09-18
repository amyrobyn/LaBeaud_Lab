library(dplyr)
library(plyr)
library(tidyverse)
library(tableone)
library(DescTools)
library(ggplot2)
library(plotly)
library(zoo)
library(DataCombine)
library(lubridate)
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long")
load("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long/R01_lab_results 2018-10-26 .rda")
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/ASTMH/2018/melisa")

####### Creating a File Called CDNA To Do Analysis On ###################
# renaming red cap event name to something shorter called event
R01_lab_results$event<-NA # event p=patient info, a=Visit A, b=Visit B, c=Visit etc 
R01_lab_results <- within (R01_lab_results, event[R01_lab_results$redcap_event_name=="patient_informatio_arm_1"] <- "P")
R01_lab_results <- within (R01_lab_results, event[R01_lab_results$redcap_event_name=="visit_a_arm_1"] <- "A")
R01_lab_results <- within (R01_lab_results, event[R01_lab_results$redcap_event_name=="visit_b_arm_1"] <- "B")
R01_lab_results <- within (R01_lab_results, event[R01_lab_results$redcap_event_name=="visit_c_arm_1"] <- "C")
R01_lab_results <- within (R01_lab_results, event[R01_lab_results$redcap_event_name=="visit_c2_arm_1"] <- "C2")
R01_lab_results <- within (R01_lab_results, event[R01_lab_results$redcap_event_name=="visit_d_arm_1"] <- "D")
R01_lab_results <- within (R01_lab_results, event[R01_lab_results$redcap_event_name=="visit_e_arm_1"] <- "E")
R01_lab_results <- within (R01_lab_results, event[R01_lab_results$redcap_event_name=="visit_f_arm_1"] <- "F")
R01_lab_results <- within (R01_lab_results, event[R01_lab_results$redcap_event_name=="visit_g_arm_1"] <- "G")
R01_lab_results <- within (R01_lab_results, event[R01_lab_results$redcap_event_name=="visit_h_arm_1"] <- "H")
R01_lab_results <- within (R01_lab_results, event[R01_lab_results$redcap_event_name=="visit_u24_arm_1"] <- "U24")

#creating the cohort and village and visit variables for each visit. Colating patient information for subsequent visit.  
R01_lab_results$id_cohort<-substr(R01_lab_results$person_id, 2, 2) #F and M are AIC, 0 C and D are other
R01_lab_results$id_city<-substr(R01_lab_results$person_id, 1, 1) #C is Chulaimbo, K is Kisumu, M is Msambweni, U is Ukunda, one 0 not sure, R is also Chulaimbo, G stands for Nganja (one of the subparts of Msambweni), L is for Mililani (part of Msambweni)

#Creating a new variable by studyID for study site
R01_lab_results$id_site<-NA
R01_lab_results <- within (R01_lab_results, id_site[R01_lab_results$id_city=="C" | R01_lab_results$id_city=="R"] <- "Chulaimbo")
R01_lab_results <- within (R01_lab_results, id_site[R01_lab_results$id_city=="K"] <- "Kisumu")
R01_lab_results <- within (R01_lab_results, id_site[R01_lab_results$id_city=="M" | R01_lab_results$id_city=="G" | R01_lab_results$id_city=="L"] <- "Msambweni")
R01_lab_results <- within (R01_lab_results, id_site[R01_lab_results$id_city=="U" ] <- "Ukunda")
table(R01_lab_results$id_site, useNA="ifany") 

# subset of the variables to only AIC
R01_lab_results<-R01_lab_results[which(R01_lab_results$id_cohort=="F" | R01_lab_results$id_cohort=="M" ), ]

#Removing the one studyID starting with a O
R01_lab_results <- R01_lab_results[which(R01_lab_results$id_city!="O"), ]
table(R01_lab_results$id_city)

#Creating a new variable combining the visit letter into the person ID
#R01_lab_results$fullpersonid <- do.call(paste, c(R01_lab_results[c("person_id", "event")], sep = "")) 

table(R01_lab_results$aliquot_id_ufi2)

#Subsetting to cDNA only
cdna<-R01_lab_results[which(!(R01_lab_results$aliquot_id_ufi2=="")),]
cdna$date <-cdna$interview_date_aic
cdna$date <- as.Date(cdna$date, "%Y-%m-%d")
class(cdna$date)

#limiting aic malaria to ages 0-17
cdna<-cdna[which(cdna$aic_calculated_age>=0 & cdna$aic_calculated_age<=17),]

#limiting cdna from 1/2014 to 12/2017
cdna<-cdna[which(cdna$date>"2014-01-01" & cdna$date<"2017-12-01"),]


library(ggplot2)
cdna$chikv_result_ufi2 <- as.factor(cdna$chikv_result_ufi2)
cdna$denv_result_ufi2 <- as.factor(cdna$denv_result_ufi2)

#####the final plot
cdna$arbo <- "No Arbovirus Detected"
cdna <- within(cdna, arbo[cdna$denv_result_ufi2=="1" & (cdna$chikv_result_ufi2=="0"|cdna$chikv_result_ufi2=="")] <- "DENV Positive") # Denv positive
cdna <- within(cdna, arbo[(cdna$denv_result_ufi2=="0"|cdna$denv_result_ufi2=="") & cdna$chikv_result_ufi2=="1"] <- "CHIKV Positive") # Denv positive
cdna <- within(cdna, arbo[cdna$denv_result_ufi2=="1" & cdna$chikv_result_ufi2=="1"] <- "DENV/CHIKV Co-Infection") # Denv positive

cdna$arbo1 <- "4"
cdna <- within(cdna, arbo1[cdna$denv_result_ufi2=="1" & (cdna$chikv_result_ufi2=="0"|cdna$chikv_result_ufi2=="")] <- "3") # Denv positive
cdna <- within(cdna, arbo1[(cdna$denv_result_ufi2=="0"|cdna$denv_result_ufi2=="") & cdna$chikv_result_ufi2=="1"] <- "2") #Chikv
cdna <- within(cdna, arbo1[cdna$denv_result_ufi2=="1" & cdna$chikv_result_ufi2=="1"] <- "1") # Denv CHIKV coinfection
table(cdna$arbo1)

cdna$arbo<- as.factor(cdna$arbo)
addmargins(table(cdna$arbo, useNA="ifany") )

#subsetting west and coast
cdna$loc <- NA
cdna <- within(cdna, loc[cdna$id_site=="Chulaimbo" | cdna$id_site=="Kisumu"] <- "West") 
cdna <- within(cdna, loc[cdna$id_site=="Msambweni" | cdna$id_site=="Ukunda"] <- "Coast") 

# getting date into year month and gap filling.
cdna$yearmonth<-format(as.Date(cdna$date),"%Y-%m")
cdna2<-cdna[c("date","yearmonth", "arbo","loc")]
cdna2 <- cdna2[order(cdna2$yearmonth),]
table(cdna2$yearmonth)
table(all.dates.frame$yearmonth)
all.dates.frame<-  seq(as.Date("2014/1/1"),as.Date("2017/10/1"), by = "month")
all.dates.frame<-format(as.Date(all.dates.frame),"%Y-%m")
all.dates.frame<-data.frame(list(yearmonth=all.dates.frame))
merged.data.w <- merge(all.dates.frame, cdna2[cdna2$loc=="West",], all=T)
merged.data.c <- merge(all.dates.frame, cdna2[cdna2$loc=="Coast",], all=T)

library(RColorBrewer)
library(ggplot2)
library(plyr)
color="black"

#WEST PLOT
west<-ggplot(merged.data.w, aes(yearmonth)) + geom_bar(aes(fill=arbo), width = 0.5) + 
  labs(title="Chikungunya and Dengue Cases over Time", subtitle="West")+
  theme(axis.text.x=element_text(angle=60, hjust=1),text = element_text(size = 20,color="black")) + 
  xlab("Time, Year-Month") + ylab("# Cases") +
  guides(fill = guide_legend(title = "PCR Result", title.position = "left",direction="horizontal"))+
  theme(
    panel.background = element_rect(fill = "transparent") # bg of the panel
    , plot.background = element_rect(fill = "transparent", color = NA) # bg of the plot
    , panel.grid.major = element_blank() # get rid of major grid
    , panel.grid.minor = element_blank() # get rid of minor grid
    , legend.background = element_rect(fill = "transparent") # get rid of legend bg
    , legend.box.background = element_rect(fill = "transparent") # get rid of legend panel bg
    , strip.background=element_rect(fill="transparent")
    , strip.text.y = element_text(angle =-90,color=color)
    , axis.text.x = element_text(colour = color)
    , axis.text.y = element_text(colour = color)
    ,legend.position="bottom"
  )
west
ggsave(west, filename = "west.png",  bg = "transparent",width = 14, height = 4, dpi = 600, units = "in", device='png')


#COAST PLOT
coast<-ggplot(merged.data.c, aes(yearmonth)) + geom_bar(aes(fill=arbo), width = 0.5) + 
  labs(title="Chikungunya and Dengue Cases over Time", subtitle="Coast")+
  theme(axis.text.x=element_text(angle=60, hjust=1),text = element_text(size = 20,color="black")) + 
  xlab("Time, Year-Month") + ylab("# Cases") +
  guides(fill = guide_legend(title = "PCR Result", title.position = "left",direction="horizontal"))+
  theme(
    panel.background = element_rect(fill = "transparent") # bg of the panel
    , plot.background = element_rect(fill = "transparent", color = NA) # bg of the plot
    , panel.grid.major = element_blank() # get rid of major grid
    , panel.grid.minor = element_blank() # get rid of minor grid
    , legend.background = element_rect(fill = "transparent") # get rid of legend bg
    , legend.box.background = element_rect(fill = "transparent") # get rid of legend panel bg
    , strip.background=element_rect(fill="transparent")
    , strip.text.y = element_text(angle =-90,color=color)
    , axis.text.x = element_text(colour = color)
    , axis.text.y = element_text(colour = color)
    ,legend.position="bottom"
  )
coast
ggsave(coast, filename = "coast.png",  bg = "transparent",width = 14, height = 4, dpi = 600, units = "in", device='png')
