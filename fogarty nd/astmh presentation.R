# packages --------------------------------------------------------
library(redcapAPI)
library(REDCapR)
library(tableone)
library("DiagrammeR")#install.packages("DiagrammeR")
library(plotly)
library(plyr)
# data --------------------------------------------------------
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/ASTMH 2017 abstracts/priyanka- fogarty nd")

Redcap.token <- readLines("api.token.txt") # Read API token from folder
REDcap.URL  <- 'https://redcap.stanford.edu/api/'
rcon <- redcapConnection(url=REDcap.URL, token=Redcap.token)
#chikv_nd <- redcap_read(redcap_uri  = REDcap.URL, token = Redcap.token, batch_size = 200)$data#export data from redcap to R (must be connected via cisco VPN)


currentDate <- Sys.Date() 
FileName <- paste("chikv_nd",currentDate,".rda",sep=" ") 
#save(chikv_nd,file=FileName)
load(FileName)
# data cleaning --------------------------------------------------------
chikv_nd[chikv_nd==99] <-NA#replace 99 with NA
# gestattional age --------------------------------------------------------
chikv_nd$gestational_age_daysfrac<-chikv_nd$gestational_age_days/7
chikv_nd$gestational_age_weekfrac<-chikv_nd$gestational_age_daysfrac+chikv_nd$gestational_age_weeks

gestational_age_cat<-NA
chikv_nd <- within(chikv_nd, gestational_age_cat[gestational_age_weekfrac>=37 & gestational_age_weekfrac<42] <- "full-term")
chikv_nd <- within(chikv_nd, gestational_age_cat[gestational_age_weekfrac<37 ] <- "pre-term")
chikv_nd <- within(chikv_nd, gestational_age_cat[gestational_age_weekfrac>=42 ] <- "post-term")
table(chikv_nd$gestational_age_cat, exclude = NULL)


# outcome -----------------------------------------------------------------
chikv_nd$preg_chikvpos<-NA
chikv_nd <- within(chikv_nd, preg_chikvpos[result_mother==0 | pregnant==0] <- 0)
chikv_nd <- within(chikv_nd, preg_chikvpos[result_mother==1 & pregnant ==1 & !is.na(trimester)] <- 1)
cohort<-as.data.frame(chikv_nd[which(!is.na(chikv_nd$preg_chikvpos) ), ])
# flow chart of subjects --------------------------------------------------
n<-sum(n_distinct(cohort$participant_id, na.rm = FALSE)) #506 mother-child pairs
n_tested_moms<-  sum(!is.na(cohort$result_mother), na.rm = TRUE)#438 tested moms
n_tested_children<-  sum(!is.na(cohort$result_child), na.rm = TRUE)#436 tested children

n_cohort<-  sum(!is.na(cohort$preg_chikvpos), na.rm = TRUE)#332 included in cohort
n_preg_chikv_case<-  sum(cohort$preg_chikvpos==1, na.rm = TRUE)#169 cases 
n_preg_chikv_control<-  sum(cohort$preg_chikvpos==0, na.rm = TRUE)#163 controls 

grViz("
      digraph boxes_and_circles{
      graph[nodesep=2]
      node[shape = oval; color = black; fontsize = 100; fontname=arial; fontcolor=black; penwidth = 6; arrowshape=normal]
      edge[penwidth = 6; arrowhead=normal; arrowsize =4; minlen=4]
      
      #mother child pairs
      mother_child_pairs->506
      
      #tested events
      506->tested_moms; 506->tested_child  
      tested_moms->438; tested_child->436
      
      #cohort. excluded (equivocal_lab_result_or_never_infected). 
      #included as exposed if mother igg pos and infected during preg.
      #included as unexposed if mother igg neg or not infected during pregnancy
      438->included_in_cohort; 438->excluded
      included_in_cohort->332;excluded->174; 
      
      
      #exposed/unexposed
      332->exposed; 332->unexposed
      exposed->169; unexposed->163
      
      }")
        


# trimester ---------------------------------------------------------------
cohort$trimester_lab <- factor(cohort$trimester,levels = c(1,2,3,4),labels = c("1st", "2nd", "3rd", "Delivery"))
trimester_infection <- ddply(cohort, .(trimester_lab), 
                             summarise, 
                             trimester_sum = sum(trimester, na.rm = TRUE),
                             trimester_sd = sd(trimester, na.rm = TRUE)
)
margin = list(l = 100, r = 50, b = 100, t = 75, pad = 4)

plot_ly(trimester_infection, y=~trimester_sum, x=~trimester_lab, type="bar", error_y = ~list(value = trimester_sd))%>%
  layout(title="Trimester of CHIKV Infection", xaxis=list(title="Trimester"), yaxis=list(title="Count"),
         font=list(size=28),
         margin=margin)


# moms elisa result -------------------------------------------------------
colors <- c('rgb(128,133,133)','rgb(211,94,96)' )

chikv_nd <- within(chikv_nd, result_mother[result_mother>1] <- NA)
result_mother<-as.data.frame(table(chikv_nd$result_mother))
result_mother$Var1 <- factor(result_mother$Var1,levels = c(0,1),labels = c("Neg", "Pos"))

plot_ly(result_mother, labels = ~Var1, values = ~Freq,
        textposition = 'inside',
        textinfo = 'label+percent',
        insidetextfont = list(color = '#FFFFFF', size=24),
        marker = list(colors = colors,
                      line = list(color = '#FFFFFF', width = 1)) 
) %>%
  add_pie(hole = 0.6) %>%
  layout(title ='Mother IgG ELISA Result', titlefont=list(size=34),
         xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
         yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))

# child elisa result ------------------------------------------------------------
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


# mom age ---------------------------------------------------------------------
cohort$primary_date<-as.Date(cohort$primary_date)
cohort$dob<-as.Date(cohort$dob)
cohort$mom_age<-round((cohort$primary_date-cohort$dob)/365.25,1)  
cohort$mom_age<-as.numeric(cohort$mom_age)
hist(cohort$mom_age, breaks=20)
cohort <- within(cohort, mom_age[mom_age<10] <- NA)

#text variables to categorize ----------------------------------------------------
cohort_to_cat<-cohort[which(!is.na(cohort$preg_chikvpos)), grepl("participant_id|redcap_event_name|preg_chikvpos|list_pregnancy_illness|specify_after_birth_problems|specify_complications|specify_first_few_months", names(cohort))]
write.csv(as.data.frame(cohort_to_cat), "cohort_to_cat.csv" )


# symptoms data cleaning----------------------------------------------------------------

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
# symptoms graph----------------------------------------------------------------

symptoms$trimester <- factor(symptoms$trimester,levels = c(1,2,3,4),labels = c("1st", "2nd", "3rd", "Delivery"))
plot_ly(symptoms)%>%
  add_trace(x=~trimester, y=~rash, type="bar", name="rash",error_y = ~list(value = rash_sd))%>%
  add_trace(x=~trimester, y=~fever, type="bar", name="fever",error_y = ~list(value = fever_sd))%>%
  add_trace(x=~trimester, y=~chills, type="bar", name="chills",error_y = ~list(value = chills_sd))%>%
  add_trace(x=~trimester, y=~Generalized_body_ache, type="bar", name="Generalized body ache",error_y = ~list(value = Generalized_body_ache_sd))%>%
  add_trace(x=~trimester, y=~joint, type="bar", name="joint",error_y = ~list(value = joint_sd))%>%
  add_trace(x=~trimester, y=~muscle, type="bar", name="muscle",error_y = ~list(value = muscle_sd))%>%
  add_trace(x=~trimester, y=~itch, type="bar", name="itch",error_y = ~list(value = itch_sd))%>%
  add_trace(x=~trimester, y=~headache, type="bar", name="headache",error_y = ~list(value = headache_sd))%>%
  add_trace(x=~trimester, y=~eye_pain, type="bar", name="eye pain",error_y = ~list(value = eye_pain_sd))%>%
  add_trace(x=~trimester, y=~appetite, type="bar", name="loss of appetite",error_y = ~list(value = appetite_sd))%>%
  layout(
         xaxis = list(titlefont=list(size=34),title = "Trimester of Infection", tickfont = list(size=24)),
         yaxis = list(titlefont=list(size=34),tickfont = list(size=24), title = 'Subjects',tickformat="%", showgrid = FALSE, zeroline = FALSE),
         margin=margin,
         legend=list(font=list(size=24), orientation="h"))

# problems ----------------------------------------------------------------
problems <- ddply(cohort, .(preg_chikvpos), 
                  summarise, 
                  pregnancy_illness  = mean(other_pregnancy_illness, na.rm = TRUE),
                  pregnancy_illness_sd = sd(other_pregnancy_illness, na.rm = TRUE),
                  after_birth_problems  = mean(after_birth_problems, na.rm = TRUE),
                  after_birth_problems_sd = sd(after_birth_problems, na.rm = TRUE),
                  complications  = mean(complications, na.rm = TRUE),
                  complications_sd = sd(complications, na.rm = TRUE),
                  first_few_months_illness  = mean(first_few_months_illness, na.rm = TRUE),
                  first_few_months_illness_sd = sd(first_few_months_illness, na.rm = TRUE)
)
problems$preg_chikvpos <- factor(problems$preg_chikvpos,levels = c(0,1),labels = c("Unexposed", "Exposed"))
plot_ly(problems)%>%
  add_trace(x=~preg_chikvpos, y=~complications, type="bar", name="Birth complications",error_y = ~list(value = complications_sd))%>%
  add_trace(x=~preg_chikvpos, y=~first_few_months_illness, type="bar", name="First few months illness",error_y = ~list(value = first_few_months_illness_sd))%>%
  add_trace(x=~preg_chikvpos, y=~after_birth_problems, type="bar", name="After birth problems",error_y = ~list(value = after_birth_problems_sd))%>%
  add_trace(x=~preg_chikvpos, y=~pregnancy_illness, type="bar", name="Pregnancy illness",error_y = ~list(value = pregnancy_illness_sd))%>%
  layout(
         xaxis = list(titlefont=list(size=34),title = "", tickfont = list(size=24)),
         yaxis = list(titlefont=list(size=34),tickfont = list(size=24), title = 'Subjects',tickformat="%", showgrid = FALSE, zeroline = FALSE),
         margin=margin,
         legend=list(font=list(size=30), orientation="h"))




prop.test(table(cohort$after_birth_problems, cohort$preg_chikvpos))
prop.test(table(cohort$pregnancy_illness, cohort$preg_chikvpos))
prop.test(table(cohort$first_few_months_illness, cohort$preg_chikvpos))
prop.test(table(cohort$complications, cohort$preg_chikvpos))

# tables ------------------------------------------------------------------
cohort <- within(cohort, trimester[trimester==4 ] <- NA)
vars<-c("labour_duration","symptom_duration", "pregnancy_illness","complications","after_birth_problems","first_few_months_illness","parish","other_pregnancy_illness","hospitalized_ever", "trimester","race", "mom_age", "education", "marrital_status", "monthly_income", "medical_conditions___6", "medical_conditions___10", "alcohol", "smoking", "birth_time", "mode_of_delivery", "gestational_age_weekfrac",  "result_child")
vars2<-c("symptoms___1", "symptoms___2", "symptoms___3", "symptoms___4", "symptoms___5", "symptoms___6", "symptoms___7", "symptoms___8", "symptoms___9", "symptoms___10", "symptoms___11", "symptoms___12", "symptoms___13", "symptoms___14", "symptoms___15", "symptoms___16", "symptoms___17", "symptoms___18", "symptoms___19", "symptoms___20", "symptoms___21", "symptoms___22", "symptoms___23", "symptoms___24", "symptoms___25", "symptoms___26", "symptoms___27", "symptoms___28", "symptoms___29", "symptoms___30", "symptoms___31", "symptoms___32", "symptoms___33", "symptoms___34")
factorVars<-c("pregnancy_illness","complications","after_birth_problems","first_few_months_illness","parish","other_pregnancy_illness","hospitalized_ever", "trimester","race", "education", "marrital_status", "monthly_income", "medical_conditions___6", "medical_conditions___10", "alcohol", "smoking", "birth_time", "mode_of_delivery","result_child")

table1 <- CreateTableOne(vars = vars, factorVars = factorVars, strata = "preg_chikvpos", data = cohort)
table2 <- CreateTableOne(vars = vars2, strata = "trimester", data = cohort)

print(table1, quote = TRUE)
print(table2, quote = TRUE)
