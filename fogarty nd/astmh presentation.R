# packages --------------------------------------------------------
library(redcapAPI)
library(REDCapR)
library(tableone)
library("DiagrammeR")#install.packages("DiagrammeR")
library(plotly)
library(plyr)
library(dplyr)
# data --------------------------------------------------------
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/ASTMH 2017 abstracts/priyanka- fogarty nd")

Redcap.token <- readLines("api.token.txt") # Read API token from folder
REDcap.URL  <- 'https://redcap.stanford.edu/api/'
rcon <- redcapConnection(url=REDcap.URL, token=Redcap.token)
#chikv_nd <- redcap_read(redcap_uri  = REDcap.URL, token = Redcap.token, batch_size = 200)$data#export data from redcap to R (must be connected via cisco VPN)


currentDate <- Sys.Date() 
FileName <- paste("chikv_nd",currentDate,".rda",sep=" ") 
#save(chikv_nd,file=FileName)
load("chikv_nd 2017-11-01 .rda")
# tested momo and baby-----------------------------------------------------------------
cohort<-as.data.frame(chikv_nd[which(!is.na(chikv_nd$result_mother)& !is.na(chikv_nd$result_child)), ])#495 tested both mother and child.

# outcome pregchikv pos ---------------------------------------------------
cohort$preg_chikvpos<-cohort$result_mother*-1
cohort <- within(cohort, preg_chikvpos[is.na(cohort$pregnant)] <- "no answer to pregant")#26 
cohort <- within(cohort, preg_chikvpos[is.na(cohort$ever_had_chikv)] <- "no answer to ever had chikv")#5

cohort <- within(cohort, preg_chikvpos[cohort$result_mother==1] <- "pos but preg<>1")#122
cohort <- within(cohort, preg_chikvpos[cohort$pregnant==1] <- "pregnant but not chikv+")#1
cohort <- within(cohort, preg_chikvpos[!is.na(trimester)] <- "doesnt recall trimester")#7

cohort <- within(cohort, preg_chikvpos[result_mother==0 | pregnant==0] <- "unexposed")#154
cohort <- within(cohort, preg_chikvpos[result_mother==1 & pregnant ==1] <- "exposed")#179


#153 negative or not infected during pregnancy
#168 infected and during pregnancy with trimester recall.
#152 had chikv but not during pregnancy.
#18 had chikv but didn't respond to if during pregancy or not.
table(cohort$preg_chikvpos,exclude = NULL)
table(cohort$preg_chikvpos)
cohort$preg_chikvpos<-NA
cohort <- within(cohort, preg_chikvpos[result_mother==0 | pregnant==0] <-0)#154
cohort <- within(cohort, preg_chikvpos[result_mother==1 & pregnant ==1] <- 1)#179

cohort<-as.data.frame(cohort[which(cohort$preg_chikvpos==1|cohort$preg_chikvpos==0 ), ])
table(cohort$preg_chikvpos,exclude = NULL)
154+179


# outcome by trimester ----------------------------------------------------

cohort$first_v_unexposed<-NA
cohort<- within(cohort, first_v_unexposed[cohort$preg_chikvpos==0] <- 0)#26 
cohort<- within(cohort, first_v_unexposed[cohort$trimester==1 & cohort$preg_chikvpos==1] <- 1)#26 
table(cohort$first_v_unexposed)

cohort$second_v_unexposed<-NA
cohort<- within(cohort, second_v_unexposed[cohort$preg_chikvpos==0] <- 0)#26 
cohort<- within(cohort, second_v_unexposed[cohort$trimester==2 & cohort$preg_chikvpos==1] <- 1)#26 
table(cohort$second_v_unexposed)

cohort$third_d_v_unexposed<-NA
cohort<- within(cohort, third_d_v_unexposed[cohort$preg_chikvpos==0] <- 0)#26 
cohort<- within(cohort, third_d_v_unexposed[(cohort$trimester==3 & cohort$preg_chikvpos==1)|(cohort$trimester==4 & cohort$preg_chikvpos==1)] <- 1)#26 
table(cohort$third_d_v_unexposed)

cohort$third_v_unexposed<-NA
cohort<- within(cohort, third_v_unexposed[cohort$preg_chikvpos==0] <- 0)#26 
cohort<- within(cohort, third_v_unexposed[cohort$trimester==3 & cohort$preg_chikvpos==1] <- 1)#26 
table(cohort$third_v_unexposed)

cohort$d_v_unexposed<-NA
cohort<- within(cohort, d_v_unexposed[cohort$preg_chikvpos==0] <- 0)#26 
cohort<- within(cohort, d_v_unexposed[cohort$trimester==4 & cohort$preg_chikvpos==1] <- 1)#26 
table(cohort$d_v_unexposed)
table(cohort$trimester)


# flow chart of subjects --------------------------------------------------
n<-sum(n_distinct(chikv_nd$participant_id,chikv_nd$redcap_event_name, na.rm = FALSE)) #516 mother-child pairs

n_preg_chikv_case<-  sum(cohort$preg_chikvpos==1, na.rm = TRUE)#186 cases 
n_preg_chikv_control<-  sum(cohort$preg_chikvpos==0, na.rm = TRUE)#154 controls 

mermaid("
  graph TB;
      A(Mother child pairs)-->B(516)
      B(516)-->C(Tested both<br> mother and child)
      C(Tested both<br> mother and child)-->D(495)
     
      
      D(495)-->I(Exposed)
      D(495)-->J(Unexposed)
      I(Exposed)-->K(186)
      J(Unexposed)-->L(154)
      D(495)-->E(Excluded<br> from cohort)
      
      E(Excluded<br> from cohort)-->F(155)
        ")    


# trimester ---------------------------------------------------------------
cohort$trimester_lab <- factor(cohort$trimester,levels = c(1,2,3,4),labels = c("1st", "2nd", "3rd", "Delivery"))
cohort$trimester<-as.factor(cohort$trimester)

trimester_infection<-as.data.frame(with(cohort, table(trimester_lab)))
trimester_infection$Freq

margin = list(l = 100, r = 50, b = 100, t = 75, pad = 4)

plot_ly(trimester_infection, y=~Freq, x=~trimester_lab, type="bar")%>%
  layout(title="Trimester of CHIKV Infection", xaxis=list(title="Trimester"), yaxis=list(title="Count"),
         font=list(size=28),
         margin=margin)

# moms elisa result -------------------------------------------------------
colors <- c('rgb(128,133,133)','rgb(211,94,96)' )

chikv_nd <- within(chikv_nd, result_mother[result_mother>1] <- NA)
result_mother<-as.data.frame(table(chikv_nd$result_mother))
result_mother$Var1 <- factor(result_mother$Var1,levels = c(0,1),labels = c("Neg", "Pos"))

plot_ly(result_mother, labels = ~Var1, values = ~Freq,type = 'pie',
        textposition = 'inside',
        textinfo = 'label+percent',
        insidetextfont = list(color = '#FFFFFF', size=24),
        marker = list(colors = colors,
                      line = list(color = '#FFFFFF', width = 1)) 
) %>%
  layout(title ='Mother IgG ELISA Result', titlefont=list(size=34),
         xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
         yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))

# child elisa result all comers------------------------------------------------------------
chikv_nd <- within(chikv_nd, result_child[result_child>1] <- NA)
result_child<-as.data.frame(table(chikv_nd$result_child))
result_child$Var1 <- factor(result_child$Var1,levels = c(0,1),labels = c("Neg", "Pos"))

plot_ly(result_child, labels = ~Var1, values = ~Freq,type = 'pie',
        textposition = 'inside',
        textinfo = 'label+percent',
        insidetextfont = list(color = '#FFFFFF', size=24),
        marker = list(colors = colors,
                      line = list(color = '#FFFFFF', width = 1)) 
) %>%
  layout(title ='Child IgG ELISA Result', titlefont=list(size=34),
         xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
         yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))


# child elisa result cohort------------------------------------------------------------
cohort <- within(cohort, result_child[result_child>1] <- NA)
result_child <- ddply(cohort, .(preg_chikvpos), 
                      summarise, 
                      child_infection_rate = mean(result_child, na.rm = TRUE),
                      child_infection_sd = sd(result_child, na.rm = TRUE)
)
result_child$preg_chikvpos <- factor(result_child$preg_chikvpos,levels = c(0,1),labels = c("Unexposed", "Exposed"))

plot_ly(result_child, x= ~preg_chikvpos, y = ~child_infection_rate, type = "bar", 
        error_y = ~list(value = child_infection_sd, color = '#000000')) %>%
  layout(title ='Child IgG ELISA Result', titlefont=list(size=34),
         xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = TRUE, title="",  tickfont = list(size=24)),
         yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = TRUE,tickformat = "%", title="Infants Infected", titlefont=list(size =24),  tickfont = list(size=24)) ,
         margin=margin)

prop.test(table(cohort$result_child,cohort$preg_chikvpos))


# data cleaning --------------------------------------------------------
cohort[cohort==99] <-NA#replace 99 with NA
# gestattional age --------------------------------------------------------
cohort$gestational_age_daysfrac<-cohort$gestational_age_days/7
cohort$gestational_age_weekfrac<-cohort$gestational_age_daysfrac+cohort$gestational_age_weeks

cohort$gestational_age_cat<-NA
cohort <- within(cohort, gestational_age_cat[gestational_age_weekfrac>=37 & gestational_age_weekfrac<42] <- "full-term")
cohort <- within(cohort, gestational_age_cat[gestational_age_weekfrac<37 ] <- "pre-term")
cohort <- within(cohort, gestational_age_cat[gestational_age_weekfrac>=42 ] <- "post-term")
table(cohort$gestational_age_cat, exclude = NULL)
# mom age ---------------------------------------------------------------------
cohort$primary_date<-as.Date(cohort$primary_date)
cohort$dob<-as.Date(cohort$dob)
cohort$mom_age<-round((cohort$primary_date-cohort$dob)/365.25,1)  
cohort$mom_age<-as.numeric(cohort$mom_age)
hist(cohort$mom_age, breaks=20)
cohort <- within(cohort, mom_age[mom_age<10] <- NA)

#text variables to categorize ----------------------------------------------------
cohort_to_cat<-cohort[which(!is.na(cohort$preg_chikvpos)), grepl("preg_chikvpos|participant_id|redcap_event_name|preg_chikvpos|list_pregnancy_illness|specify_after_birth_problems|specify_complications|specify_first_few_months", names(cohort))]
write.csv(as.data.frame(cohort_to_cat), "cohort_to_cat.csv" )


# symptoms data cleaning by trimester----------------------------------------------------------------

cases<-as.data.frame(cohort[which(cohort$preg_chikvpos==1), ])

symptoms <- ddply(cases, .(trimester), 
                  summarise, 
                  fever  = mean(symptoms___1, na.rm = TRUE),
                  fever_sd = sd(symptoms___1, na.rm = TRUE),
                  chills  = mean(symptoms___2, na.rm = TRUE),
                  chills_sd = sd(symptoms___3, na.rm = TRUE),
                  Generalized_body_ache = mean(symptoms___3, na.rm = TRUE),
                  Generalized_body_ache_sd = sd(symptoms___3, na.rm = TRUE),
                  joint  = mean(symptoms___4, na.rm = TRUE),
                  joint_sd = sd(symptoms___4, na.rm = TRUE),
                  muscle  = mean(symptoms___5, na.rm = TRUE),
                  muscle_sd = sd(symptoms___5, na.rm = TRUE),
                  bone  = mean(symptoms___6, na.rm = TRUE),
                  bone_sd = sd(symptoms___6, na.rm = TRUE),
                  itch  = mean(symptoms___7, na.rm = TRUE),
                  itch_sd = sd(symptoms___7, na.rm = TRUE),
                  headache  = mean(symptoms___8, na.rm = TRUE),
                  headache_sd = sd(symptoms___8, na.rm = TRUE),
                  eye_pain  = mean(symptoms___9, na.rm = TRUE),
                  eye_pain_sd = sd(symptoms___9, na.rm = TRUE),
                  dizzy  = mean(symptoms___10, na.rm = TRUE),
                  dizzy_sd = sd(symptoms___10, na.rm = TRUE),
                  eyes_sens  = mean(symptoms___11, na.rm = TRUE),
                  eyes_sens_sd = sd(symptoms___11, na.rm = TRUE),
                  stiff_neck  = mean(symptoms___12, na.rm = TRUE),
                  stiff_neck_sd = sd(symptoms___12, na.rm = TRUE),
                  red_eye  = mean(symptoms___13, na.rm = TRUE),
                  red_eye_sd = sd(symptoms___13, na.rm = TRUE),
                  runny_nose  = mean(symptoms___14, na.rm = TRUE),
                  runny_nose_sd = sd(symptoms___14, na.rm = TRUE),
                  earchache  = mean(symptoms___15, na.rm = TRUE),
                  earchache_sd = sd(symptoms___15, na.rm = TRUE),
                  sore_throat  = mean(symptoms___16, na.rm = TRUE),
                  sore_throat_sd = sd(symptoms___16, na.rm = TRUE),
                  cough  = mean(symptoms___17, na.rm = TRUE),
                  cough_sd = sd(symptoms___17, na.rm = TRUE),
                  short_breath  = mean(symptoms___18, na.rm = TRUE),
                  short_breath_sd = sd(symptoms___18, na.rm = TRUE),
                  appetite  = mean(symptoms___19, na.rm = TRUE),
                  appetite_sd = sd(symptoms___19, na.rm = TRUE),
                  funny_taste  = mean(symptoms___20, na.rm = TRUE),
                  funny_taste_sd = sd(symptoms___20, na.rm = TRUE),
                  nausea  = mean(symptoms___21, na.rm = TRUE),
                  nausea_sd = sd(symptoms___21, na.rm = TRUE),
                  vomit  = mean(symptoms___22, na.rm = TRUE),
                  vomit_sd = sd(symptoms___22, na.rm = TRUE),
                  diarrhea  = mean(symptoms___23, na.rm = TRUE),
                  diarrhea_sd = sd(symptoms___23, na.rm = TRUE),
                  adbominal  = mean(symptoms___24, na.rm = TRUE),
                  adbominal_sd = sd(symptoms___24, na.rm = TRUE),
                  rash  = mean(symptoms___25, na.rm = TRUE),
                  rash_sd = sd(symptoms___25, na.rm = TRUE),
                  bloody_nose  = mean(symptoms___26, na.rm = TRUE),
                  bloody_nose_sd = sd(symptoms___26, na.rm = TRUE),
                  bleeding_gum  = mean(symptoms___27, na.rm = TRUE),
                  bleeding_gum_sd = sd(symptoms___27, na.rm = TRUE),
                  bloody_stool  = mean(symptoms___28, na.rm = TRUE),
                  bloody_stool_sd = sd(symptoms___28, na.rm = TRUE),
                  bloody_vomit  = mean(symptoms___29, na.rm = TRUE),
                  bloody_vomit_sd = sd(symptoms___29, na.rm = TRUE),
                  bloody_urine  = mean(symptoms___30, na.rm = TRUE),
                  bloody_urine_sd = sd(symptoms___30, na.rm = TRUE),
                  bruises  = mean(symptoms___31, na.rm = TRUE),
                  bruises_sd = sd(symptoms___31, na.rm = TRUE),
                  ims  = mean(symptoms___32, na.rm = TRUE),
                  ims_sd = sd(symptoms___32, na.rm = TRUE),
                  seizures  = mean(symptoms___33, na.rm = TRUE),
                  seizures_sd = sd(symptoms___33, na.rm = TRUE),
                  hand_weak  = mean(symptoms___34, na.rm = TRUE),
                  hand_weak_sd = sd(symptoms___34, na.rm = TRUE))
# symptoms graph by trimester----------------------------------------------------------------
symptoms<-as.data.frame(symptoms[which(symptoms$trimester!=4), ])

symptoms$trimester <- factor(symptoms$trimester,levels = c(1,2,3),labels = c("1st", "2nd", "3rd"))

plot_ly(symptoms)%>%
  add_trace(x=~trimester, y=~joint, type="bar", name="joint",error_y = ~list(value = joint_sd))%>%
  add_trace(x=~trimester, y=~fever, type="bar", name="fever",error_y = ~list(value = fever_sd))%>%
  add_trace(x=~trimester, y=~rash, type="bar", name="rash",error_y = ~list(value = rash_sd))%>%
  add_trace(x=~trimester, y=~headache, type="bar", name="headache",error_y = ~list(value = headache_sd))%>%
  add_trace(x=~trimester, y=~itch, type="bar", name="itch",error_y = ~list(value = itch_sd))%>%
  add_trace(x=~trimester, y=~Generalized_body_ache, type="bar", name="Generalized body ache",error_y = ~list(value = Generalized_body_ache_sd))%>%
  add_trace(x=~trimester, y=~muscle, type="bar", name="muscle",error_y = ~list(value = muscle_sd))%>%
  add_trace(x=~trimester, y=~chills, type="bar", name="chills",error_y = ~list(value = chills_sd))%>%
  add_trace(x=~trimester, y=~eye_pain, type="bar", name="pain behnd eye*",error_y = ~list(value = eye_pain_sd))%>%
  add_trace(x=~trimester, y=~appetite, type="bar", name="loss of appetite",error_y = ~list(value = appetite_sd))%>%
  add_trace(x=~trimester, y=~adbominal, type="bar", name="adbominal pain**",error_y = ~list(value = adbominal_sd))%>%
  layout(
         xaxis = list(titlefont=list(size=34),title = "Trimester of Infection", tickfont = list(size=24)),
         yaxis = list(titlefont=list(size=34),tickfont = list(size=24), title = 'Subjects',tickformat="%", showgrid = FALSE, zeroline = FALSE),
         margin=margin,
         legend=list(font=list(size=24), orientation="h"))

# symptoms data cleaning by pregnancy----------------------------------------------------------------
cases<-as.data.frame(chikv_nd[which(chikv_nd$result_mother==1&(chikv_nd$pregnant==1|chikv_nd$pregnant==0)), ])
cases$pregnant <- factor(cases$pregnant,levels = c(0,1),labels = c("Not", "Pregnancy"))

symptoms <- ddply(cases, .(pregnant), 
                  summarise, 
                  fever  = mean(symptoms___1, na.rm = TRUE),
                  fever_sd = sd(symptoms___1, na.rm = TRUE),
                  chills  = mean(symptoms___2, na.rm = TRUE),
                  chills_sd = sd(symptoms___3, na.rm = TRUE),
                  Generalized_body_ache = mean(symptoms___3, na.rm = TRUE),
                  Generalized_body_ache_sd = sd(symptoms___3, na.rm = TRUE),
                  joint  = mean(symptoms___4, na.rm = TRUE),
                  joint_sd = sd(symptoms___4, na.rm = TRUE),
                  muscle  = mean(symptoms___5, na.rm = TRUE),
                  muscle_sd = sd(symptoms___5, na.rm = TRUE),
                  bone  = mean(symptoms___6, na.rm = TRUE),
                  bone_sd = sd(symptoms___6, na.rm = TRUE),
                  itch  = mean(symptoms___7, na.rm = TRUE),
                  itch_sd = sd(symptoms___7, na.rm = TRUE),
                  headache  = mean(symptoms___8, na.rm = TRUE),
                  headache_sd = sd(symptoms___8, na.rm = TRUE),
                  eye_pain  = mean(symptoms___9, na.rm = TRUE),
                  eye_pain_sd = sd(symptoms___9, na.rm = TRUE),
                  dizzy  = mean(symptoms___10, na.rm = TRUE),
                  dizzy_sd = sd(symptoms___10, na.rm = TRUE),
                  eyes_sens  = mean(symptoms___11, na.rm = TRUE),
                  eyes_sens_sd = sd(symptoms___11, na.rm = TRUE),
                  stiff_neck  = mean(symptoms___12, na.rm = TRUE),
                  stiff_neck_sd = sd(symptoms___12, na.rm = TRUE),
                  red_eye  = mean(symptoms___13, na.rm = TRUE),
                  red_eye_sd = sd(symptoms___13, na.rm = TRUE),
                  runny_nose  = mean(symptoms___14, na.rm = TRUE),
                  runny_nose_sd = sd(symptoms___14, na.rm = TRUE),
                  earchache  = mean(symptoms___15, na.rm = TRUE),
                  earchache_sd = sd(symptoms___15, na.rm = TRUE),
                  sore_throat  = mean(symptoms___16, na.rm = TRUE),
                  sore_throat_sd = sd(symptoms___16, na.rm = TRUE),
                  cough  = mean(symptoms___17, na.rm = TRUE),
                  cough_sd = sd(symptoms___17, na.rm = TRUE),
                  short_breath  = mean(symptoms___18, na.rm = TRUE),
                  short_breath_sd = sd(symptoms___18, na.rm = TRUE),
                  appetite  = mean(symptoms___19, na.rm = TRUE),
                  appetite_sd = sd(symptoms___19, na.rm = TRUE),
                  funny_taste  = mean(symptoms___20, na.rm = TRUE),
                  funny_taste_sd = sd(symptoms___20, na.rm = TRUE),
                  nausea  = mean(symptoms___21, na.rm = TRUE),
                  nausea_sd = sd(symptoms___21, na.rm = TRUE),
                  vomit  = mean(symptoms___22, na.rm = TRUE),
                  vomit_sd = sd(symptoms___22, na.rm = TRUE),
                  diarrhea  = mean(symptoms___23, na.rm = TRUE),
                  diarrhea_sd = sd(symptoms___23, na.rm = TRUE),
                  adbominal  = mean(symptoms___24, na.rm = TRUE),
                  adbominal_sd = sd(symptoms___24, na.rm = TRUE),
                  rash  = mean(symptoms___25, na.rm = TRUE),
                  rash_sd = sd(symptoms___25, na.rm = TRUE),
                  bloody_nose  = mean(symptoms___26, na.rm = TRUE),
                  bloody_nose_sd = sd(symptoms___26, na.rm = TRUE),
                  bleeding_gum  = mean(symptoms___27, na.rm = TRUE),
                  bleeding_gum_sd = sd(symptoms___27, na.rm = TRUE),
                  bloody_stool  = mean(symptoms___28, na.rm = TRUE),
                  bloody_stool_sd = sd(symptoms___28, na.rm = TRUE),
                  bloody_vomit  = mean(symptoms___29, na.rm = TRUE),
                  bloody_vomit_sd = sd(symptoms___29, na.rm = TRUE),
                  bloody_urine  = mean(symptoms___30, na.rm = TRUE),
                  bloody_urine_sd = sd(symptoms___30, na.rm = TRUE),
                  bruises  = mean(symptoms___31, na.rm = TRUE),
                  bruises_sd = sd(symptoms___31, na.rm = TRUE),
                  ims  = mean(symptoms___32, na.rm = TRUE),
                  ims_sd = sd(symptoms___32, na.rm = TRUE),
                  seizures  = mean(symptoms___33, na.rm = TRUE),
                  seizures_sd = sd(symptoms___33, na.rm = TRUE),
                  hand_weak  = mean(symptoms___34, na.rm = TRUE),
                  hand_weak_sd = sd(symptoms___34, na.rm = TRUE))

# symptoms graph by preg----------------------------------------------------------------
table(chikv_nd$trimester)
plot_ly(symptoms)%>%
  add_trace(x=~pregnant, y=~joint, type="bar", name="joint pain**",error_y = ~list(value = joint_sd))%>%
  add_trace(x=~pregnant, y=~fever, type="bar", name="fever",error_y = ~list(value = fever_sd))%>%
  add_trace(x=~pregnant, y=~rash, type="bar", name="rash",error_y = ~list(value = rash_sd))%>%
  add_trace(x=~pregnant, y=~itch, type="bar", name="itch",error_y = ~list(value = itch_sd))%>%
  add_trace(x=~pregnant, y=~Generalized_body_ache, type="bar", name="Generalized body ache",error_y = ~list(value = Generalized_body_ache_sd))%>%
  add_trace(x=~pregnant, y=~headache, type="bar", name="headache**",error_y = ~list(value = headache_sd))%>%
  add_trace(x=~pregnant, y=~chills, type="bar", name="chills*",error_y = ~list(value = chills_sd))%>%
  add_trace(x=~pregnant, y=~muscle, type="bar", name="muscle pain***",error_y = ~list(value = muscle_sd))%>%
  add_trace(x=~pregnant, y=~eye_pain, type="bar", name="pain behnd eye",error_y = ~list(value = eye_pain_sd))%>%
  add_trace(x=~pregnant, y=~appetite, type="bar", name="loss of appetite**",error_y = ~list(value = appetite_sd))%>%
  add_trace(x=~pregnant, y=~vomit, type="bar", name="vomitting**",error_y = ~list(value = vomit_sd))%>%
  add_trace(x=~pregnant, y=~bone, type="bar", name="bone pain*",error_y = ~list(value = bone_sd))%>%
  add_trace(x=~pregnant, y=~diarrhea, type="bar", name="dhiarrea*",error_y = ~list(value = diarrhea_sd))%>%
  add_trace(x=~pregnant, y=~cough, type="bar", name="cough*",error_y = ~list(value = cough_sd))%>%
  add_trace(x=~pregnant, y=~adbominal, type="bar", name="adbominal pain",error_y = ~list(value = adbominal_sd))%>%
  layout(
    xaxis = list(titlefont=list(size=34),title = "When infected", tickfont = list(size=24)),
    yaxis = list(titlefont=list(size=34),tickfont = list(size=24), title = 'Subjects',tickformat="%", showgrid = FALSE, zeroline = FALSE),
    margin=margin,
    legend=list(font=list(size=24), orientation="v"))

# load dummy compmlications and merge with full database ------------------
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/ASTMH 2017 abstracts/priyanka- fogarty nd")
load("complications.dum.rda")
cohort<-merge(complications,cohort, by=c("participant_id", "redcap_event_name"), all.y=T)

table(cohort$abp__sum, cohort$preg_chikvpos)
table(cohort$compl__sum, cohort$preg_chikvpos)
table(cohort$preg_ill_sum, cohort$preg_chikvpos)
table(cohort$ffm__sum, cohort$preg_chikvpos)

# problems ----------------------------------------------------------------
table(cohort$other_pregnancy_illness, cohort$pregnancy_illness)
cohort <- within(cohort, other_pregnancy_illness[grepl("CHIKV", cohort$list_pregnancy_illness_category2) & (is.na(cohort$list_pregnancy_illness_category)|cohort$list_pregnancy_illness_category=="") ] <- 0)
cohort <- within(cohort, other_pregnancy_illness[!is.na(cohort$list_pregnancy_illness_category) & cohort$list_pregnancy_illness_category!=""] <- 1)

cohort <- within(cohort, pregnancy_illness[grepl("CHIKV", cohort$list_pregnancy_illness_category2) & (is.na(cohort$list_pregnancy_illness_category)|cohort$list_pregnancy_illness_category=="") ] <- 0)
cohort <- within(cohort, pregnancy_illness[!is.na(cohort$list_pregnancy_illness_category) & cohort$list_pregnancy_illness_category!=""] <- 1)
table(cohort$other_pregnancy_illness)
table(cohort$pregnancy_illness,cohort$other_pregnancy_illness)

cohort$child_compl_dum<-NA
cohort$mother_compl_dum<-NA

cohort <- within(cohort, child_compl_dum[cohort$after_birth_problems==0| cohort$first_few_months_illness==0] <- 0)
cohort <- within(cohort, child_compl_dum[cohort$after_birth_problems==1| cohort$first_few_months_illness==1] <- 1)

cohort <- within(cohort, mother_compl_dum[cohort$other_pregnancy_illness==0| cohort$complications==0|cohort$pregnancy_illness==0] <- 0)
cohort <- within(cohort, mother_compl_dum[cohort$other_pregnancy_illness==1| cohort$complications==1|cohort$pregnancy_illness==1] <- 1)
problems <- ddply(cohort, .(preg_chikvpos), 
                  summarise, 
                  mother_compl_dum  = mean(mother_compl_dum, na.rm = TRUE),
                  mother_compl_dum_sd = sd(mother_compl_dum, na.rm = TRUE),
                  child_compl_dum  = mean(child_compl_dum, na.rm = TRUE),
                  child_compl_dum_sd = sd(child_compl_dum, na.rm = TRUE),
                  pregnancy_illness  = mean(other_pregnancy_illness, na.rm = TRUE),
                  pregnancy_illness_sd = sd(other_pregnancy_illness, na.rm = TRUE),
                  after_birth_problems  = mean(after_birth_problems, na.rm = TRUE),
                  after_birth_problems_sd = sd(after_birth_problems, na.rm = TRUE),
                  complications  = mean(complications, na.rm = TRUE),
                  complications_sd = sd(complications, na.rm = TRUE),
                  first_few_months_illness  = mean(first_few_months_illness, na.rm = TRUE),
                  first_few_months_illness_sd = sd(first_few_months_illness, na.rm = TRUE)
)
problems$preg_chikvpos <- factor(problems$preg_chikvpos,levels = c(0,1),labels = c("Mother not infected during pregnancy", "Mother infected during pregnancy"))

plot_ly(problems)%>%
  add_trace(x=~preg_chikvpos, y=~complications, type="bar", name="Birth complications. ",error_y = ~list(value = complications_sd))%>%
  add_trace(x=~preg_chikvpos, y=~first_few_months_illness, type="bar", name="First few months illness",error_y = ~list(value = first_few_months_illness_sd))%>%
  add_trace(x=~preg_chikvpos, y=~after_birth_problems, type="bar", name="After birth problems",error_y = ~list(value = after_birth_problems_sd))%>%
  add_trace(x=~preg_chikvpos, y=~pregnancy_illness, type="bar", name="Pregnancy illness",error_y = ~list(value = pregnancy_illness_sd))%>%

  add_trace(x=~preg_chikvpos, y=~mother_compl_dum, type="bar", name="Pregnancy illness or birth complications",error_y = ~list(value = mother_compl_dum_sd))%>%
  add_trace(x=~preg_chikvpos, y=~child_compl_dum, type="bar", name="After birth problems or first few months illness",error_y = ~list(value = child_compl_dum_sd))%>%
  
  layout(
         xaxis = list(titlefont=list(size=34),title = "", tickfont = list(size=24)),
         yaxis = list(titlefont=list(size=34),tickfont = list(size=24), title = 'Subjects',tickformat="%", showgrid = FALSE, zeroline = FALSE),
         margin=margin,
         legend=list(font=list(size=30), orientation="h"))



prop.test(table(cohort$after_birth_problems, cohort$preg_chikvpos))
prop.test(table(cohort$pregnancy_illness, cohort$preg_chikvpos))
prop.test(table(cohort$first_few_months_illness, cohort$preg_chikvpos))
prop.test(table(cohort$complications, cohort$preg_chikvpos))


# baby birth measurments --------------------------------------------------
summary(cohort$weight)
names<-c("height","height_stad","height_mt")
cohort[names] <- sapply(cohort[names],as.numeric)
cohort$height_child <- rowMeans(cohort[names], na.rm=TRUE)
summary(cohort$height_child)

# tables ------------------------------------------------------------------
cohort <- within(cohort, trimester[trimester==4 ] <- NA)
vars<-c("labour_duration","symptom_duration", "pregnancy_illness","complications","after_birth_problems","first_few_months_illness","parish","other_pregnancy_illness","hospitalized_ever", "trimester","race", "mom_age", "education", "marrital_status", "monthly_income", "medical_conditions___6", "medical_conditions___10", "alcohol", "smoking", "birth_time", "mode_of_delivery", "gestational_age_weekfrac",  "result_child","abp__sum","compl__sum","preg_ill_sum","ffm__sum","height_child","weight","child_compl_dum","mother_compl_dum")
vars2<-c("symptoms___1", "symptoms___2", "symptoms___3", "symptoms___4", "symptoms___5", "symptoms___6", "symptoms___7", "symptoms___8", "symptoms___9", "symptoms___10", "symptoms___11", "symptoms___12", "symptoms___13", "symptoms___14", "symptoms___15", "symptoms___16", "symptoms___17", "symptoms___18", "symptoms___19", "symptoms___20", "symptoms___21", "symptoms___22", "symptoms___23", "symptoms___24", "symptoms___25", "symptoms___26", "symptoms___27", "symptoms___28", "symptoms___29", "symptoms___30", "symptoms___31", "symptoms___32", "symptoms___33", "symptoms___34","child_compl_dum","mother_compl_dum")
factorVars<-c("pregnancy_illness","complications","after_birth_problems","first_few_months_illness","parish","other_pregnancy_illness","hospitalized_ever", "trimester","race", "education", "marrital_status", "monthly_income", "medical_conditions___6", "medical_conditions___10", "alcohol", "smoking", "birth_time", "mode_of_delivery","result_child")

vars3<-names(cohort[ , grepl( "preg_ill_|ffm__|compl__|abp__|mother__compl_|child__compl_" , names( cohort) ) ])

table1_child_in_utero_exp <- CreateTableOne(vars = vars, factorVars = factorVars, strata = "preg_chikvpos", data = cohort)
table1_mom_exp <- CreateTableOne(vars = vars, factorVars = factorVars, strata = "result_mother", data = chikv_nd)

symptoms_by_trimester <- CreateTableOne(vars = vars2, strata = "trimester", data = cohort)
symptoms_by_preg.vs.not <- CreateTableOne(vars = vars2, strata = "pregnant", data = cases)

complications.by.exposure <- CreateTableOne(vars = vars3, strata = "preg_chikvpos", data = cohort)

complications.by.exposure_1 <- CreateTableOne(vars = vars3, strata = "first_v_unexposed", data = cohort)
complications.by.exposure_2 <- CreateTableOne(vars = vars3, strata = "second_v_unexposed", data = cohort)
complications.by.exposure_3d <- CreateTableOne(vars = vars3, strata = "third_d_v_unexposed", data = cohort)
complications.by.exposure_3 <- CreateTableOne(vars = vars3, strata = "third_v_unexposed", data = cohort)
complications.by.exposure_d <- CreateTableOne(vars = vars3, strata = "d_v_unexposed", data = cohort)

print(table1_child_in_utero_exp, quote = TRUE)
print(symptoms_by_trimester, quote = TRUE)
print(symptoms_by_preg.vs.not, quote = TRUE)
print(complications.by.exposure, quote = TRUE)

print(table1_mom_exp, quote = TRUE)

print(complications.by.exposure_1, quote = TRUE)
print(complications.by.exposure_2, quote = TRUE)
print(complications.by.exposure_3, quote = TRUE)
print(complications.by.exposure_3d, quote = TRUE)
print(complications.by.exposure_d, quote = TRUE)

