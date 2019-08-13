# packages ----------------------------------------------------------------
library(plotly)
library(plotrix)
library(tidyverse)
library(rgdal)
library(tableone)
library(REDCapR)
# get data ----------------------------------------------------------------
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/zika study- grenada")
Redcap.token <- readLines("Redcap.token.zika.txt") # Read API token from folder
REDcap.URL  <- 'https://redcap.stanford.edu/api/'
ds <- redcap_read(redcap_uri  = REDcap.URL,  token   = Redcap.token,  batch_size = 100)$data

table(ds$zikv_ct)
table(ds$denv_ct)
table(ds$chikv_ct)

table(ds$result_denv_urine_mom)
table(ds$result_denv_serum_mom)

ds$denv_pinsky<-NA
ds <- within(ds, denv_pinsky[ds$result_denv_serum_mom==0] <- 0)
ds <- within(ds, denv_pinsky[ds$result_denv_serum_mom==0] <- 0)

ds <- within(ds, denv_pinsky[ds$result_denv_serum_mom==1] <- 1)
ds <- within(ds, denv_pinsky[ds$result_denv_urine_mom==1] <- 1)
table(ds$denv_pinsky)

ds$denv_tetracore<-NA
ds <- within(ds, denv_tetracore[ds$denv_ct==0] <- 0)
ds <- within(ds, denv_tetracore[ds$denv_ct>0] <- 1)
table(ds$denv_tetracore)

table(ds$denv_tetracore, ds$denv_pinsky, exclude = NULL)

ds$zikv_pinsky<-NA
ds <- within(ds, zikv_pinsky[ds$result_zikv_serum_mom==0] <- 0)
ds <- within(ds, zikv_pinsky[ds$result_zikv_serum_mom==0] <- 0)

ds <- within(ds, zikv_pinsky[ds$result_zikv_serum_mom==1] <- 1)
ds <- within(ds, zikv_pinsky[ds$result_zikv_urine_mom==1] <- 1)
table(ds$zikv_pinsky)

ds$zikv_tetracore<-NA
ds <- within(ds, zikv_tetracore[ds$zikv_ct==0] <- 0)
ds <- within(ds, zikv_tetracore[ds$zikv_ct>0] <- 1)
table(ds$zikv_tetracore)

table(ds$zikv_tetracore, ds$zikv_pinsky, exclude = NULL)

ds$chikv_pinsky<-NA
ds <- within(ds, chikv_pinsky[ds$result_chikv_serum_mom==0] <- 0)
ds <- within(ds, chikv_pinsky[ds$result_chikv_serum_mom==0] <- 0)

ds <- within(ds, chikv_pinsky[ds$result_chikv_serum_mom==1] <- 1)
ds <- within(ds, chikv_pinsky[ds$result_chikv_urine_mom==1] <- 1)
table(ds$chikv_pinsky)

ds$chikv_tetracore<-NA
ds <- within(ds, chikv_tetracore[ds$chikv_ct==0] <- 0)
ds <- within(ds, chikv_tetracore[ds$chikv_ct>0] <- 1)
table(ds$chikv_tetracore)

table(ds$chikv_tetracore, ds$chikv_pinsky, exclude = NULL)




table(ds$result_denv_urine_mom,ds$result_denv_serum_mom, exclude = NULL)
9/(116+9+25+1)
table(ds$result_zikv_urine_mom,ds$result_zikv_serum_mom, exclude = NULL)
7/(121+22+4+3+1)
(109/141)*100
currentDate <- Sys.Date() 
FileName <- paste("zika_grenada",currentDate,".rda",sep="") 
save(ds,file=FileName)
load("zika_grenada 2018-05-28 .rda")
table(ds$redcap_event_name)
table(ds$redcap_repeat_instance)

# #split data into mom and child then remerge by id ----------------------------------------------------------------
mom<-subset(ds, redcap_event_name=="mother_arm_1")
mom <- Filter(function(mom)!all(is.na(mom)), mom)

child<-subset(ds, redcap_event_name=="child_arm_1")
child <- Filter(function(child)!all(is.na(child)), child)
total <- merge(mom, child, by="mother_record_id")
#exclude PZ344. mom deleiverd before the outbreak started.
total<-subset(total, mother_record_id!="PZ344")

table(total$redcap_event_name.x)
table(total$redcap_event_name.y)

table(total$cohort___1)
table(total$cohort___2)
table(total$cohort___3)

hist(total$child_calculated_age)
par(cex.main = 1.5, mar = c(5, 6, 4, 5) + 0.1, mgp = c(3.5, 1, 0), cex.lab = 2 , font.lab = 2, cex.axis = 2, bty = "n", las=1)
hist(total$child_calculated_age, main = "", xlab = "", ylab = " ", ylim = c(0, 100), xlim = c(0, 20), axes = FALSE, col = "grey")
axis(1, seq(0, 20, by = 5))
axis(2, seq(0,  100, by = 20))
rug(jitter(total$child_calculated_age))
mtext("Child Age in Months", side = 1, line = 2.5, cex = 2, font = 2)
mtext("Number of Participants", side = 2, line = 3, cex = 2, font = 2, las = 0)

boxplot(total$child_calculated_age,ylim = c(0, 20))
mtext("Child Age in Months", side = 2, line = 3, cex = 2, font = 2, las = 0)

total$gender <- factor(total$gender,levels = c(1,2),labels = c("Male","Female"))
t<-table(total$gender)
lbls <- paste(names(t), "\n", t, sep="")
pie(t,labels = lbls, main = "Child Gender",col = rainbow(length(t)), cex=5)
pie3D(t,labels = lbls,explode = 0.1, main = "Child Gender", labelcex=5,radius=1)

# pregnant and symptomatic ------------------------------------------------
# what the child outcomes were in asymptomatic and symptomatic pregnant cases. 
#By child outcome I mean child anthropometrics and PE findings.
total$symptom_sum <- as.integer(rowSums(total[ , grep("^symptoms___" , names(total))]))
table(total$symptom_sum)

table(total$preg_f.x)
table(total$pregnant)
total$pregnant_cat<-ifelse(is.na(total$preg_f.x),1,total$pregnant)
table(total$pregnant_cat)

total$symptomatic<-NA
total <- within(total, symptomatic[total$symptom_sum>0] <- 1)
total <- within(total, symptomatic[total$symptom_sum==0] <- 0)
table(total$symptomatic, total$pregnant) # symptomatic & pregnant n = 31; non-sympomatic & pregnant n = 2
table(total$symptomatic, total$pregnant_cat) # symptomatic & pregnant n = 31; non-sympomatic & pregnant n = 2
table(total$symptomatic) # symptomatic & pregnant n = 7; non-sympomatic & pregnant n = 1
table(total$pregnant) # symptomatic & pregnant n = 7; non-sympomatic & pregnant n = 1
table(total$pregnant) # symptomatic & pregnant n = 7; non-sympomatic & pregnant n = 1
table(total$trimester)
total$trimester <- factor(total$trimester,levels = c(1,2,3,4,99),labels = c("1st", "2nd", "3rd","delivery","unknown"))
table(total$symptomatic,total$trimester)
table(total$symptomatic)
# mapping -----------------------------------------------------------------
table(total$parish)
total$NAME_1 <- factor(total$parish,levels = c(1,2,3,4,5,6,7,8,99),labels = c("Saint George", "Saint Andrew", "Saint David","Saint Patrick","Saint John","Saint Mark","Carriacou","Petite Matinique","unknown"))
table(total$NAME_1)

cases_parish<-total %>%
  group_by(total$parish)%>%
  summarise(
    zikv_igg_mom_p = mean(result_zikv_igg_pgold.x,na.rm=T),
    zikv_igg_mom_sd = sd(result_zikv_igg_pgold.x,na.rm=T),
    zikv_igg_child_p = mean(result_zikv_igg_pgold.y,na.rm=T),
    zikv_igg_child_sd = sd(result_zikv_igg_pgold.y,na.rm=T),
    denv_igg_mom_p = mean(result_denv_igg_pgold.x,na.rm=T),
    denv_igg_mom_sd = sd(result_denv_igg_pgold.x,na.rm=T),
    denv_igg_child_p = mean(result_denv_igg_pgold.y,na.rm=T),
    denv_igg_child_sd = sd(result_denv_igg_pgold.y,na.rm=T),
    Subjects = n())

cases<-total %>%
  summarise(
    zikv_igg_mom_p = mean(result_zikv_igg_pgold.x,na.rm=T),
    zikv_igg_mom_sd = sd(result_zikv_igg_pgold.x,na.rm=T),
    zikv_igg_child_p = mean(result_zikv_igg_pgold.y,na.rm=T),
    zikv_igg_child_sd = sd(result_zikv_igg_pgold.y,na.rm=T),
    denv_igg_mom_p = mean(result_denv_igg_pgold.x,na.rm=T),
    denv_igg_mom_sd = sd(result_denv_igg_pgold.x,na.rm=T),
    denv_igg_child_p = mean(result_denv_igg_pgold.y,na.rm=T),
    denv_igg_child_sd = sd(result_denv_igg_pgold.y,na.rm=T),
    Subjects = n())

cases<-cases%>%
  mutate(
         zikv_igg_mom_se = zikv_igg_mom_sd / sqrt(Subjects),
         zikv_igg_mom_lower = zikv_igg_mom_p - qt(1 - (0.05 / 2), Subjects - 1) * zikv_igg_mom_se,
         zikv_igg_mom_upper = zikv_igg_mom_p + qt(1 - (0.05 / 2), Subjects - 1) * zikv_igg_mom_se,
         
         zikv_igg_child_se = zikv_igg_child_sd / sqrt(Subjects),
         zikv_igg_child_lower = zikv_igg_child_p - qt(1 - (0.05 / 2), Subjects - 1) * zikv_igg_child_se,
         zikv_igg_child_upper = zikv_igg_child_p + qt(1 - (0.05 / 2), Subjects - 1) * zikv_igg_child_se,
         
         denv_igg_mom_se = denv_igg_mom_sd / sqrt(Subjects),
         denv_igg_mom_lower = denv_igg_mom_p - qt(1 - (0.05 / 2), Subjects - 1) * denv_igg_mom_se,
         denv_igg_mom_upper = denv_igg_mom_p + qt(1 - (0.05 / 2), Subjects - 1) * denv_igg_mom_se,
         
         denv_igg_child_se = denv_igg_child_sd / sqrt(Subjects),
         denv_igg_child_lower = denv_igg_child_p - qt(1 - (0.05 / 2), Subjects - 1) * denv_igg_child_se,
         denv_igg_child_upper = denv_igg_child_p + qt(1 - (0.05 / 2), Subjects - 1) * denv_igg_child_se
  )
write.csv(cases,"cases.csv")
write.csv(total,"total.csv")


library( plotly)

plot_ly(cases)%>%
  add_trace(y=~zikv_igg_mom_p, type="bar", name="ZIKV IgG Maternal",error_y = ~list(value = zikv_igg_mom_upper))%>%
  add_trace( y=~zikv_igg_child_p, type="bar", name="ZIKV IgG Child",error_y = ~list(value = zikv_igg_child_upper))%>%
  add_trace(y=~denv_igg_mom_p, type="bar", name="DENV IgG Maternal",error_y = ~list(value = denv_igg_mom_upper))%>%
  add_trace(y=~denv_igg_child_p, type="bar", name="DENV IgG Child",error_y = ~list(value = denv_igg_child_upper))%>%
  layout(
    xaxis = list(titlefont=list(size=50),title = "", tickfont = list(size=30)),
    yaxis = list(titlefont=list(size=34),tickfont = list(size=30), tickformat="%", showgrid = FALSE, zeroline = FALSE),
    margin=margin,
    legend=list(font=list(size=30), orientation="h"))


parish<-readOGR("C:/Users/amykr/Box Sync/Amy Krystosik's Files/zika study- grenada/map/GRD_adm1.shp")

plot(parish)
subjects_parish<-merge(parish, cases_parish, by="NAME_1")
writeOGR(obj=subjects_parish,layer="grenadazikastudy", driver = "ESRI Shapefile", overwrite_layer=T,dsn="C:/Users/amykr/Box Sync/Amy Krystosik's Files/zika study- grenada/map")
write.csv(cases_parish,"cases_parish.csv")
subjects_parish$denv_igg_mom_sd

labels <- layer(sp.text(coordinates(subjects_parish), txt = paste(subjects_parish$NAME_1,", n=", subjects_parish$Subjects), pos = 2))
#basemaps from google.
library(ggmap)
merc = CRS("+init=epsg:3857")
bgMap = get_map(as.vector(bbox(subjects_parish)), source = "google", zoom = 10) # useless without zoom level

parish_subject_map<-spplot(spTransform(subjects_parish, merc),c("zikv_igg_mom_p"))
#parish_subject_map + labels

parish_subject_map<-spplot(spTransform(subjects_parish, merc),c("zikv_igg_mom_p","zikv_igg_child_p","denv_igg_mom_p","denv_igg_child_p"), names.attr = c("Maternal ZIKV IgG","Child ZIKV IgG","Maternal DENV IgG","Child DENV IgG"),main = "Proportion IgG Positive by Parish",    colorkey=list(space="bottom"),sp.layout = list(panel.ggmap, bgMap, first = TRUE),color="transparent")
#parish_subject_map + labels

parish_subject_map<-spplot(subjects_parish,c("zikv_igg_mom_p","zikv_igg_child_p","denv_igg_mom_p","denv_igg_child_p"), names.attr = c("Maternal ZIKV IgG","Child ZIKV IgG","Maternal DENV IgG","Child DENV IgG"),main = "Proportion IgG Positive by Parish",    colorkey=list(space="bottom"))
#parish_subject_map + labels


# symptoms ----------------------------------------------------------------
#install.packages("Rmisc")
library(Rmisc)

symptom_trimester<-total %>%
  group_by(trimester)%>% 
  summarise(
    symptomatic_sum = sum(symptomatic,na.rm=T),
    symptomatic_max = max(symptomatic,na.rm=T),
    symptomatic_min = min(symptomatic,na.rm=T),
    symptomatic_p = mean(symptomatic,na.rm=T),
    symptomatic_sd = sd(symptomatic,na.rm=T),
    Subjects = n()
  )

symptom_trimester$symptomatic_se <- sqrt((symptom_trimester$symptomatic_p*(1-symptom_trimester$symptomatic_p))/symptom_trimester$Subjects)

ci<-qbeta(c(symptom_trimester$symptomatic_p/2,1-symptom_trimester$symptomatic_p/2),symptom_trimester$symptomatic_sum+0.5,symptom_trimester$Subjects-symptom_trimester$symptomatic_sum+0.5)#https://stats.stackexchange.com/questions/28316/confidence-interval-for-a-proportion-when-sample-proportion-is-almost-1-or-0
symptom_trimester$lower <- ci[seq(1, length(ci), 2)]
symptom_trimester$upper <- ci[seq(2, length(ci), 2)]

symptom_trimester$lower <- ci[1:5]
symptom_trimester$upper <- ci[6:10]
symptom_trimester$upper[2:4]<-NA
symptom_trimester$lower[2:4]<-NA

ggplot (symptom_trimester, aes (x = trimester, y =symptomatic_p))+  geom_bar(size=2, stat = "identity") +  geom_text(aes(x = trimester, y = symptomatic_p, label=paste("n=",Subjects)), size=8,nudge_y = -0.1)+
  geom_errorbar(aes (x = trimester, ymin=lower, ymax=upper), width=0.2, size=1, color="black")+ 
  xlab("Trimester of infection") + 
    ylab("P(Symptomatic)") +
    theme_classic(base_size = 50)  +
  scale_y_continuous(breaks = seq(0, 1, by = .2))



zika_grenada<-as.tibble(total)
ggplot(data = zika_grenada) + 
  geom_bar(aes(x = symptomatic, y = ..prop.., group = 1))

g<-ggplot (total, aes (x = trimester, y = symptom_sum)) 
g+geom_boxplot()+theme_classic(base_size = 30)


geom_text(data=test.pct, aes(label=paste0(round(pct*100,1),"%"),
                             y=pct+0.012), size=4)
library(ggplot2)
symptoms<-names(select(total,symptoms___1:symptoms___34))
symptoms_long<-total %>% 
  gather(symptoms, key = "symptom", value = "reported")
symptoms_long<-as.tibble(symptoms_long)

table(symptoms_long$reported)

symptoms_t<-as.tibble(ddply(symptoms_long,~symptom+trimester,summarise,mean=mean(reported),sd=sd(reported)))

ggplot(data=symptoms_t)+
geom_bar(data=symptoms_t,aes(x = trimester, fill=symptom,y=mean), position = "dodge",stat="identity") +
  xlab("Trimester of infection") + 
  ylab("Symptoms") +
  facet_grid(.~trimester)+
  theme_classic(base_size = 50)  +
  scale_y_continuous(breaks = seq(0, 1, by = .2))+
  theme(axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank())

table(total$symptomatic) 
28/(361+28)*100

symptoms <- ddply(total, .(trimester), 
                  summarise, 
                  fever  = mean(symptoms___1, na.rm = TRUE),fever_sd = sd(symptoms___1, na.rm = TRUE),
                  chills  = mean(symptoms___2, na.rm = TRUE), chills_sd = sd(symptoms___3, na.rm = TRUE),
                  Generalized_body_ache = mean(symptoms___3, na.rm = TRUE), Generalized_body_ache_sd = sd(symptoms___3, na.rm = TRUE),
                  joint  = mean(symptoms___4, na.rm = TRUE), joint_sd = sd(symptoms___4, na.rm = TRUE),
                  muscle  = mean(symptoms___5, na.rm = TRUE), muscle_sd = sd(symptoms___5, na.rm = TRUE),
                  bone  = mean(symptoms___6, na.rm = TRUE),bone_sd = sd(symptoms___6, na.rm = TRUE),
                  itch  = mean(symptoms___7, na.rm = TRUE),itch_sd = sd(symptoms___7, na.rm = TRUE),
                  headache  = mean(symptoms___8, na.rm = TRUE),headache_sd = sd(symptoms___8, na.rm = TRUE),
                  eye_pain  = mean(symptoms___9, na.rm = TRUE),eye_pain_sd = sd(symptoms___9, na.rm = TRUE),
                  dizzy  = mean(symptoms___10, na.rm = TRUE),dizzy_sd = sd(symptoms___10, na.rm = TRUE),
                  eyes_sens  = mean(symptoms___11, na.rm = TRUE),eyes_sens_sd = sd(symptoms___11, na.rm = TRUE),
                  stiff_neck  = mean(symptoms___12, na.rm = TRUE),stiff_neck_sd = sd(symptoms___12, na.rm = TRUE),
                  red_eye  = mean(symptoms___13, na.rm = TRUE),red_eye_sd = sd(symptoms___13, na.rm = TRUE),
                  runny_nose  = mean(symptoms___14, na.rm = TRUE),runny_nose_sd = sd(symptoms___14, na.rm = TRUE),
                  earchache  = mean(symptoms___15, na.rm = TRUE),earchache_sd = sd(symptoms___15, na.rm = TRUE),
                  sore_throat  = mean(symptoms___16, na.rm = TRUE),sore_throat_sd = sd(symptoms___16, na.rm = TRUE),
                  cough  = mean(symptoms___17, na.rm = TRUE),cough_sd = sd(symptoms___17, na.rm = TRUE),
                  short_breath  = mean(symptoms___18, na.rm = TRUE),short_breath_sd = sd(symptoms___18, na.rm = TRUE),
                  appetite  = mean(symptoms___19, na.rm = TRUE),appetite_sd = sd(symptoms___19, na.rm = TRUE),
                  funny_taste  = mean(symptoms___20, na.rm = TRUE),funny_taste_sd = sd(symptoms___20, na.rm = TRUE),
                  nausea  = mean(symptoms___21, na.rm = TRUE),nausea_sd = sd(symptoms___21, na.rm = TRUE),
                  vomit  = mean(symptoms___22, na.rm = TRUE),vomit_sd = sd(symptoms___22, na.rm = TRUE),
                  diarrhea  = mean(symptoms___23, na.rm = TRUE),diarrhea_sd = sd(symptoms___23, na.rm = TRUE),
                  adbominal  = mean(symptoms___24, na.rm = TRUE),adbominal_sd = sd(symptoms___24, na.rm = TRUE),
                  rash  = mean(symptoms___25, na.rm = TRUE),rash_sd = sd(symptoms___25, na.rm = TRUE),
                  bloody_nose  = mean(symptoms___26, na.rm = TRUE),bloody_nose_sd = sd(symptoms___26, na.rm = TRUE),
                  bleeding_gum  = mean(symptoms___27, na.rm = TRUE),bleeding_gum_sd = sd(symptoms___27, na.rm = TRUE),
                  bloody_stool  = mean(symptoms___28, na.rm = TRUE),bloody_stool_sd = sd(symptoms___28, na.rm = TRUE),
                  bloody_vomit  = mean(symptoms___29, na.rm = TRUE),bloody_vomit_sd = sd(symptoms___29, na.rm = TRUE),
                  bloody_urine  = mean(symptoms___30, na.rm = TRUE),bloody_urine_sd = sd(symptoms___30, na.rm = TRUE),
                  bruises  = mean(symptoms___31, na.rm = TRUE),bruises_sd = sd(symptoms___31, na.rm = TRUE),
                  ims  = mean(symptoms___32, na.rm = TRUE),ims_sd = sd(symptoms___32, na.rm = TRUE),
                  seizures  = mean(symptoms___33, na.rm = TRUE),seizures_sd = sd(symptoms___33, na.rm = TRUE),
                  hand_weak  = mean(symptoms___34, na.rm = TRUE),hand_weak_sd = sd(symptoms___34, na.rm = TRUE))


plot_ly(symptoms)%>%
  add_trace(x=~trimester, y=~rash, type="bar", name="Rash",error_y = ~list(value = rash_sd))%>%
  add_trace(x=~trimester, y=~itch, type="bar", name="Pruritis",error_y = ~list(value = itch_sd))%>%
  add_trace(x=~trimester, y=~joint, type="bar", name="Joint",error_y = ~list(value = joint_sd))%>%
  add_trace(x=~trimester, y=~fever, type="bar", name="Fever",error_y = ~list(value = fever_sd))%>%
  add_trace(x=~trimester, y=~headache, type="bar", name="Headache",error_y = ~list(value = headache_sd))%>%
  add_trace(x=~trimester, y=~Generalized_body_ache, type="bar", name="Generalized body ache",error_y = ~list(value = Generalized_body_ache_sd))%>%
  add_trace(x=~trimester, y=~muscle, type="bar", name="Muscle Pain",error_y = ~list(value = muscle_sd))%>%
  add_trace(x=~trimester, y=~chills, type="bar", name="Chills",error_y = ~list(value = chills_sd))%>%
  add_trace(x=~trimester, y=~eye_pain, type="bar", name="Pain behind eye",error_y = ~list(value = eye_pain_sd))%>%
  add_trace(x=~trimester, y=~appetite, type="bar", name="Loss of appetite",error_y = ~list(value = appetite_sd))%>%
  add_trace(x=~trimester, y=~adbominal, type="bar", name="Abdominal pain",error_y = ~list(value = adbominal_sd))%>%
  layout(
    xaxis = list(titlefont=list(size=50),title = "", tickfont = list(size=30)),
    yaxis = list(titlefont=list(size=34),tickfont = list(size=30), tickformat="%", showgrid = FALSE, zeroline = FALSE),
    margin=margin,
    legend=list(font=list(size=30), orientation="h"))


# igg results -------------------------------------------------------------
total$result_zikv_igg_pgold.x <- factor(total$result_zikv_igg_pgold.x,levels = c(0,1),labels = c("Negative", "Positive"))
total$result_zikv_igg_pgold.y <- factor(total$result_zikv_igg_pgold.y,levels = c(0,1),labels = c("Negative", "Positive"))
total$result_denv_igg_pgold.x <- factor(total$result_denv_igg_pgold.x,levels = c(0,1),labels = c("Negative", "Positive"))
total$result_denv_igg_pgold.y <- factor(total$result_denv_igg_pgold.y,levels = c(0,1),labels = c("Negative", "Positive"))

t<-table(total$result_zikv_igg_pgold.x)
lbls <- paste(names(t), "\n", t, sep="")
pie(t,labels = lbls, main = "IgG ZIKV Maternal")

t<-table(total$result_denv_igg_pgold.x)
lbls <- paste(names(t), "\n", t, sep="")
pie(t,labels = lbls)

t<-table(total$result_zikv_igg_pgold.y)
lbls <- paste(names(t), "\n", t, sep="")
pie(t,labels = lbls)

t<-table(total$result_denv_igg_pgold.y)
lbls <- paste(names(t), "\n", t, sep="")
pie(t,labels = lbls)

# pgold results baby -----------------------------------------------------------
cro(total$result_zikv_igg_pgold.y)
(3/388)*100
cro(total$result_denv_igg_pgold.y)
(31/388)*100
cro(total$result_denv_igg_pgold.y,total$result_zikv_igg_pgold.y)

# microcephaly ------------------------------------------------------------
total$microcephaly <- ifelse(total$zhc < -3.0, 2, ifelse(total$zhc < -2.0, 1, ifelse(total$zhc > 2.0, 3, 0)))
total$microcephaly <- factor(total$microcephaly,levels = c(0,1,2,3),labels = c("Normocephalic", "Mild Microcephaly","Severe Microcephaly","Macrocephaly"))

t<-table(total$microcephaly)
lbls <- paste(names(t), "\n", t, sep="")
pie(t,labels = lbls)

# pcr moms ----------------------------------------------------------------
total$result_denv_pcr_mom<-NA
total <- within(total, result_denv_pcr_mom[total$result_denv_urine_mom==0] <- 0)
total <- within(total, result_denv_pcr_mom[total$result_denv_serum_mom==0] <- 0)
total <- within(total, result_denv_pcr_mom[total$result_denv_urine_mom==1] <- 1)
total <- within(total, result_denv_pcr_mom[total$result_denv_serum_mom==1] <- 1)
cro(total$result_denv_pcr_mom)
cro(total$result_denv_pcr_mom, total$symptomatic)

total$result_denv_pcr_mom <- factor(total$result_denv_pcr_mom,levels = c(0,1),labels = c("Negative", "Positive"))

t<-table(total$result_denv_pcr_mom)
lbls <- paste(names(t), "\n", t, sep="")
pie(t,labels = lbls)

total$result_zikv_pcr_mom<-NA
total <- within(total, result_zikv_pcr_mom [total$result_zikv_urine_mom==0] <- 0)
total <- within(total, result_zikv_pcr_mom[total$result_zikv_serum_mom==0] <- 0)
total <- within(total, result_zikv_pcr_mom[total$result_zikv_urine_mom==1] <- 1)
total <- within(total, result_zikv_pcr_mom[total$result_zikv_serum_mom==1] <- 1)

cro(total$result_zikv_pcr_mom,total$result_zikv_igg_pgold.x)
cro(total$result_denv_pcr_mom,total$result_denv_igg_pgold.x)

# pgold moms ----------------------------------------------------------------
cro(total$result_zikv_igg_pgold.x)
cro(total$result_denv_igg_pgold.x)
cro_tpct(total$result_denv_igg_pgold.x,total$result_zikv_igg_pgold.x)

cro_cpct(total$result_avidity_zikv_igg_pgold.x,total$result_zikv_igg_pgold.x)
cro(total$result_avidity_zikv_igg_pgold.x,total$result_zikv_igg_pgold.x)

cro_cpct(total$result_avidity_denv_igg_pgold.x,total$result_denv_igg_pgold.x)
cro(total$result_avidity_denv_igg_pgold.x,total$result_denv_igg_pgold.x)

cro(total$result_denv_igg_pgold.x,total$result_denv_igg_pgold.y)
cro_cpct(total$result_denv_igg_pgold.y)

cro(total$result_zikv_igg_pgold.x)
cro(total$result_denv_igg_pgold.x)

cro(total$result_denv_pcr_mom, total$result_denv_igg_pgold.x)

cro(total$result_denv_pcr_mom, total$result_denv_igg_pgold.x)

total$result_avidity_zikv_igg_pgold <- factor(total$result_avidity_zikv_igg_pgold,levels = c(2,1,0),labels = c("More than 6 Months", "Less than 6 Months", "No Infection"))
table(total$result_avidity_zikv_igg_pgold)

total$result_avidity_denv_igg_pgold <- factor(total$result_avidity_denv_igg_pgold,levels = c(2,1,0),labels = c("More than 6 Months", "Less than 6 Months", "No Infection"))

# mother baby exopsure ----------------------------------------------------
cro(total$result_zikv_igg_pgold.x,total$result_zikv_igg_pgold.y)
cro(total$result_denv_igg_pgold.x,total$result_denv_igg_pgold.y)

# 1. Identify demographic and exposure factors associated with MTC --------

total$mom_zikv_exposed<-NA
total <- within(total, mom_zikv_exposed[total$result_zikv_igg_pgold.x=="Negative"|total$result_zikv_pcr_mom==0] <- 0)
total <- within(total, mom_zikv_exposed[total$result_zikv_igg_pgold.x=="Positive"|total$result_zikv_pcr_mom==1] <- 1)
table(total$mom_zikv_exposed)

total$mom_denv_exposed<-NA
total <- within(total, mom_denv_exposed[total$result_denv_igg_pgold.x=="Negative"|total$result_denv_pcr_mom==0] <- 0)
total <- within(total, mom_denv_exposed[total$result_denv_igg_pgold.x=="Positive"|total$result_denv_pcr_mom==1] <- 1)
table(total$mom_denv_exposed)


total$mom_co_exposed<-NA
total <- within(total, mom_co_exposed[total$mom_denv_exposed==0 & total$mom_zikv_exposed==0] <- 0)
total <- within(total, mom_co_exposed[total$mom_denv_exposed==1&total$mom_zikv_exposed==1] <- 1)
table(total$mom_co_exposed)

total$MTC_zikv<-NA
total <- within(total, MTC_zikv[total$mom_zikv_exposed==1 & total$result_zikv_igg_pgold.y=="Negative"] <- 0)
total <- within(total, MTC_zikv[total$mom_zikv_exposed==1 & total$result_zikv_igg_pgold.y=="Positive"] <- 1)
table(total$MTC_zikv)

vars=c("microcephaly", "symptomatic","trimester","mom_co_exposed","mom_denv_exposed","mom_zikv_exposed","result_avidity_zikv_igg_pgold","result_avidity_denv_igg_pgold","result_denv_igg_pgold.x","result_zikv_igg_pgold.x","result_denv_pcr_mom","result_zikv_pcr_mom","gender","child_calculated_age","delivery_type","cohort___1","cohort___2","cohort___3","parish","race","mothers_age_calc","occupation","education","marrital_status","monthly_income","mosquito_screens","mosquitos_in_home","mosquito_bites","time_of_exposure","job_outdoors","repellent","coil","spray","net","collect_rain_water","store_water","water_covered","travel","ever_had_zikv")
factorVars=c("delivery_type","race","parish","occupation","education","marrital_status","monthly_income","mosquito_screens","mosquitos_in_home","mosquito_bites","time_of_exposure","job_outdoors","repellent","coil","spray","net","collect_rain_water","store_water","water_covered","travel","ever_had_zikv")
tableOne_MTC <- CreateTableOne(vars = vars, strata = "MTC_zikv", data = total,factorVars=factorVars)
tableOne_MTC

vars=c("microcephaly", "symptomatic","trimester","mom_co_exposed","mom_denv_exposed","result_avidity_denv_igg_pgold","result_denv_igg_pgold.x","result_denv_pcr_mom","child_calculated_age","delivery_type","parish","race","mothers_age_calc","occupation","education","marrital_status","monthly_income","mosquito_screens","mosquitos_in_home","mosquito_bites","time_of_exposure","job_outdoors","repellent","coil","spray","net","collect_rain_water","store_water","water_covered","travel","term_2","gestational_weeks_2","gestational_weeks_2","child_delivery","delivery_type","outcome_of_delivery","neonatal_resusitation","cong_abnormal","maternal_resusitation","child_referred","apgar_one","apgar_ten","temperature","heart_rate","resp_rate","color","cry","tone","moving_limbs","ant_fontanelle","sutures","facial_dysmoph","cleft", "sutures",	"facial_dysmoph",	"cleft",	"red_reflex",	"cap_refill",	"heart_sounds",	"murmur",	"breath_sounds",	"breath_noises___1",	"breath_noises___2",	"breath_noises___3",	"breath_noises___0",	"breath_noises___99",	"resp_effort___0",	"resp_effort___1",	"resp_effort___2",	"resp_effort___99",	"bowel_sounds",	"hernia",	"organomegaly___0",	"organomegaly___1",	"organomegaly___2",	"organomegaly___99",	"testes",	"patent_anus",	"hip_manouver",	"hip_creases",	"femoral_pulse",	"scoliosis",	"sacral_dimple",	"moro",	"grasp",	"suck",	"plantar_reflex",	'galant_reflex')
factorVars=c("delivery_type","race","parish","occupation","education","marrital_status","monthly_income","mosquito_screens","mosquitos_in_home","mosquito_bites","time_of_exposure","job_outdoors","repellent","coil","spray","net","collect_rain_water","store_water","water_covered","travel","ever_had_zikv","term_2","child_delivery","delivery_type","outcome_of_delivery","neonatal_resusitation","cong_abnormal","maternal_resusitation","child_referred","color","cry","tone","moving_limbs","ant_fontanelle","sutures",	"red_reflex",	"cap_refill",	"heart_sounds",	"murmur",	"breath_sounds",	"breath_noises___1",	"breath_noises___2",	"breath_noises___3",	"breath_noises___0",	"breath_noises___99",	"resp_effort___0",	"resp_effort___1",	"resp_effort___2",	"resp_effort___99",	"bowel_sounds",	"hernia",	"organomegaly___0",	"organomegaly___1",	"organomegaly___2",	"organomegaly___99",	"testes",	"patent_anus",	"hip_manouver",	"hip_creases",	"femoral_pulse",	"scoliosis",	"sacral_dimple",	"moro",	"grasp",	"suck",	"plantar_reflex",	'galant_reflex')
tableOne_CZ <- CreateTableOne(vars = vars, strata = "mom_zikv_exposed", data = total,factorVars=factorVars)
tableOne_CZ
tableOne_CZ <- print(tableOne_CZ, nonnormal = vars, exact = vars, quote = FALSE, noSpaces = TRUE, printToggle = FALSE)
## Save to a CSV file
write.csv(tableOne_CZ, file = "tableOne_CZ.csv")

table(total$mom_zikv_exposed,total$mom_denv_exposed)
68/(68+12+1)
total$delivery_type

## Tests are by oneway.test/t.test for continuous, chisq.test for categorical
tableOne$CatTable
summary(tableOne)
print(tableOne, 
      nonnormal = c("mean_weight","mean_length","mean_hc","temperature","heart_rate","resp_rate",  "neonatal_resusitation", "cong_abnormal",  "maternal_resusitation", "child_referred",  "apgar_one", "apgar_ten"),
      exact = c("ever_had_dengue", "parish","race", "gender",  "child_delivery", "delivery_type", "outcome_of_delivery",  "opv_vaccine", "vac_utd", "color___1", "color___2", "color___3", "color___4", "color___5", "color___6", "cry", "tone", "moving_limbs", "ant_fontanelle", "sutures", "facial_dysmoph", "cleft", "red_reflex", "cap_refill", "heart_sounds", "murmur", "breath_sounds", "bowel_sounds", "hernia", "color___1", "color___2", "color___3", "color___4", "color___5", "color___6",  "breath_noises___1", "breath_noises___2", "breath_noises___3", "breath_noises___0", "breath_noises___99", "resp_effort___0", "resp_effort___1", "resp_effort___2", "resp_effort___99",  "organomegaly___0", "organomegaly___1", "organomegaly___2", "organomegaly___99",  "testes",  "patent_anus", "hip_manouver", "hip_creases", "femoral_pulse", "scoliosis", "sacral_dimple", "moro", "grasp", "suck", "plantar_reflex", "galant_reflex"),
      cramVars = "neonatal_resusitation, cong_abnormal,  maternal_resusitation, child_referred,  opv_vaccine, vac_utd, color___1, color___2, color___3, color___4, color___5, color___6,  breath_noises___1, breath_noises___2, breath_noises___3, breath_noises___0, breath_noises___99, resp_effort___0, resp_effort___1, resp_effort___2, resp_effort___99,  organomegaly___0, organomegaly___1, organomegaly___2, organomegaly___99", quote = TRUE)




# old code not used. ----------------------------------------------------
## List numerically coded categorical variables
total$parish<-as.factor(total$parish)
total$race<-as.factor(total$race)
table(total$race)

total$race<-as.factor(total$race)
table(total$race)

factorVars <- c("parish","race", "gender",  "child_delivery", "delivery_type", "outcome_of_delivery",
                "opv_vaccine", "vac_utd", 
                "color___1", "color___2", "color___3", "color___4", "color___5", "color___6",
                "cry", "tone", "moving_limbs", "ant_fontanelle", "sutures", "facial_dysmoph", "cleft",
                "red_reflex", "cap_refill", "heart_sounds", "murmur", "breath_sounds", "bowel_sounds", 
                "hernia", 
                "breath_noises___1", "breath_noises___2", "breath_noises___3", "breath_noises___0", 
                "breath_noises___99", "resp_effort___0", "resp_effort___1", "resp_effort___2", 
                "resp_effort___99",  "organomegaly___0", "organomegaly___1", "organomegaly___2", 
                "organomegaly___99",  "testes",  "patent_anus", "hip_manouver", "hip_creases", 
                "femoral_pulse", "scoliosis", "sacral_dimple", "moro", "grasp", "suck", "plantar_reflex", 
                "galant_reflex")

## Create a variable list. Use dput(names(pbc))
vars <- c("mean_weight","mean_length","mean_hc","temperature","heart_rate","resp_rate", "parish","race", "gender", "apgar_one", "apgar_ten", "opv_vaccine", "vac_utd",  "temperature", "heart_rate", "resp_rate", "color___1", "color___2", "color___3", "color___4", "color___5", "color___6", "cry", "tone", "moving_limbs", "ant_fontanelle", "sutures", "facial_dysmoph", "cleft", "red_reflex", "cap_refill", "heart_sounds", "murmur", "breath_sounds", "breath_noises___1", "breath_noises___2", "breath_noises___3", "breath_noises___0", "breath_noises___99", "resp_effort___0", "resp_effort___1", "resp_effort___2", "resp_effort___99", "bowel_sounds", "hernia", "organomegaly___0", "organomegaly___1", "organomegaly___2", "organomegaly___99", "testes", "patent_anus", "hip_manouver", "hip_creases", "femoral_pulse", "scoliosis", "sacral_dimple", "moro", "grasp", "suck", "plantar_reflex", "galant_reflex", "ever_had_dengue")

vars<-c("labour_duration","symptom_duration", "pregnancy_illness","complications","after_birth_problems","first_few_months_illness","parish","other_pregnancy_illness","hospitalized_ever", "trimester","race", "mom_age", "education", "marrital_status", "monthly_income", "medical_conditions___6", "medical_conditions___10", "alcohol", "smoking", "birth_time", "mode_of_delivery", "gestational_age_weekfrac",  "result_child","height_child","weight")
symptoms<-c("symptoms___1", "symptoms___2", "symptoms___3", "symptoms___4", "symptoms___5", "symptoms___6", "symptoms___7", "symptoms___8", "symptoms___9", "symptoms___10", "symptoms___11", "symptoms___12", "symptoms___13", "symptoms___14", "symptoms___15", "symptoms___16", "symptoms___17", "symptoms___18", "symptoms___19", "symptoms___20", "symptoms___21", "symptoms___22", "symptoms___23", "symptoms___24", "symptoms___25", "symptoms___26", "symptoms___27", "symptoms___28", "symptoms___29", "symptoms___30", "symptoms___31", "symptoms___32", "symptoms___33", "symptoms___34")
factorVars<-c("pregnancy_illness","complications","after_birth_problems","first_few_months_illness","parish","other_pregnancy_illness","hospitalized_ever", "trimester","race", "education", "marrital_status", "monthly_income", "medical_conditions___6", "medical_conditions___10", "alcohol", "smoking", "birth_time", "mode_of_delivery","result_child","specify_other_pregnancy_illness")

## Create Table 1 stratified by trt (omit strata argument for overall table)
tableOne <- CreateTableOne(vars = symptoms, strata = "trimester", data = total)
## Tests are by oneway.test/t.test for continuous, chisq.test for categorical
tableOne$CatTable
summary(tableOne)
print(tableOne, 
      nonnormal = c("mean_weight","mean_length","mean_hc","temperature","heart_rate","resp_rate",  "neonatal_resusitation", "cong_abnormal",  "maternal_resusitation", "child_referred",  "apgar_one", "apgar_ten"),
      exact = c("ever_had_dengue", "parish","race", "gender",  "child_delivery", "delivery_type", "outcome_of_delivery",  "opv_vaccine", "vac_utd", "color___1", "color___2", "color___3", "color___4", "color___5", "color___6", "cry", "tone", "moving_limbs", "ant_fontanelle", "sutures", "facial_dysmoph", "cleft", "red_reflex", "cap_refill", "heart_sounds", "murmur", "breath_sounds", "bowel_sounds", "hernia", "color___1", "color___2", "color___3", "color___4", "color___5", "color___6",  "breath_noises___1", "breath_noises___2", "breath_noises___3", "breath_noises___0", "breath_noises___99", "resp_effort___0", "resp_effort___1", "resp_effort___2", "resp_effort___99",  "organomegaly___0", "organomegaly___1", "organomegaly___2", "organomegaly___99",  "testes",  "patent_anus", "hip_manouver", "hip_creases", "femoral_pulse", "scoliosis", "sacral_dimple", "moro", "grasp", "suck", "plantar_reflex", "galant_reflex"),
      cramVars = "neonatal_resusitation, cong_abnormal,  maternal_resusitation, child_referred,  opv_vaccine, vac_utd, color___1, color___2, color___3, color___4, color___5, color___6,  breath_noises___1, breath_noises___2, breath_noises___3, breath_noises___0, breath_noises___99, resp_effort___0, resp_effort___1, resp_effort___2, resp_effort___99,  organomegaly___0, organomegaly___1, organomegaly___2, organomegaly___99", quote = TRUE)


#we don't have have the mtct lab results yet. can't do this. 

#For Aim 2, we will test whether the MTCT for asymptomatic ZIKV infected mothers 
#is different from that for symptomatic mothers by testing for a difference in binomial proportions.  
#Assuming 250 (50%) of the 500 of the pregnant women will be ZIKV infected, 
#20% of whom will be symptomatic with an estimated 50% MTCT rate, we will have power of 90% to detect 
#a difference if the rate is 25% for asymptomatic mothers and 75% if the rate is 30% for asymptomatics.

write.csv(total, "total.csv", na="")
total$mom_zikv_exposed

tableOne <- CreateTableOne(vars = "zhc", strata = "mom_zikv_exposed", data = total)
print(tableOne, exact = "zhc",    quote = TRUE)

table(total$result_zikv_igg_pgold.x)
