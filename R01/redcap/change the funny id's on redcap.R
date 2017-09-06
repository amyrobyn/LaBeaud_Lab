#install.packages(c("REDCapR", "mlr"))
#install.packages(c("dummies"))
library(dplyr)
library(plyr)
library(redcapAPI)
library(REDCapR)

setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long")
Redcap.token <- readLines("Redcap.token.R01.txt") # Read API token from folder
REDcap.URL  <- 'https://redcap.stanford.edu/api/'
rcon <- redcapConnection(url=REDcap.URL, token=Redcap.token)

#export data from redcap to R (must be connected via cisco VPN)
  #R01_lab_results <- redcap_read(redcap_uri  = REDcap.URL, token = Redcap.token, batch_size = 300)$data
  #save(R01_lab_results,file="R01_lab_results.backup.rda")
  load("R01_lab_results.backup.rda")

#replace funny prefix with sop prefix
p1 <- 'CMB|CMA|CMB|CM|KD|M0'
df1 <- subset(R01_lab_results, grepl(p1, person_id))
df_delete<- subset(R01_lab_results, grepl(p1, person_id))
df_delete<-df_delete[ , grepl( "person_id|redcap_event_name" , names(df_delete) ) ]
df1$funny_id<-df1$person_id
  df1$person_id <- gsub("CMB", "RF", df1$person_id)
  df1$person_id <- gsub("CMBA", "RF", df1$person_id)
  df1$person_id <- gsub("CMA", "RF", df1$person_id)
  df1$person_id <- gsub("CM", "RF", df1$person_id)
  df1$person_id <- gsub("KD", "KC", df1$person_id)
  df1$person_id <- gsub("M0", "MF0", df1$person_id)
  df1<-df1[ , !grepl( "tested|ab_|bc_|cd_|de_|ef|fg_|gh_" , names(   df1 ) ) ]
  df1$funny_id

  df1<-df1[order(-(grepl('aliq', names(df1)))+1L)]
  df1<-df1[order(-(grepl('idno', names(df1)))+1L)]
  df1<-df1[order(-(grepl('funny|idno|aliq', names(df1)))+1L)]
  df1<-df1[order(-(grepl('person_id|redcap_event', names(df1)))+1L)]
  df1<-df1[order(-(grepl('person_id', names(df1)))+1L)]
  df1 <-df1[!sapply(df1, function (x) all(is.na(x) | x == ""| x == "NA"))]
#change cmba's to a visits and cmbb's to visit b. 
  table(grepl("CMBA", df1$aliquot_id_igg_chikv_kenya)|grepl("CMBA", df1$aliquot_id_igg_chikv_kenya)|grepl("CMBA", df1$aliquot_id_microscopy_malaria_kenya)|grepl("CMBA", df1$aliquot_id_igg_denv_stfd)|grepl("CMBA", df1$aliquot_id_serum_stfd)|grepl("CMBA", df1$study_id_aic)|grepl("CMBA", df1$pedsql_idno)|grepl("CMBA", df1$pedsql_idno_parent))
  df1 <- within(df1, redcap_event_name[grepl("CMBA", df1$aliquot_id_igg_chikv_kenya)|grepl("CMBA", df1$aliquot_id_igg_chikv_kenya)|grepl("CMBA", df1$aliquot_id_microscopy_malaria_kenya)|grepl("CMBA", df1$aliquot_id_igg_denv_stfd)|grepl("CMBA", df1$aliquot_id_serum_stfd)|grepl("CMBA", df1$study_id_aic)|grepl("CMBA", df1$pedsql_idno)|grepl("CMBA", df1$pedsql_idno_parent)] <- "visit_a_arm_1")
  df1 <- within(df1, redcap_event_name[grepl("CMBB", df1$aliquot_id_igg_chikv_kenya)|grepl("CMBB", df1$aliquot_id_igg_chikv_kenya)|grepl("CMBB", df1$aliquot_id_microscopy_malaria_kenya)|grepl("CMBB", df1$aliquot_id_igg_denv_stfd)|grepl("CMBB", df1$aliquot_id_serum_stfd)|grepl("CMBB", df1$study_id_aic)] <- "visit_b_arm_1")

#combine rows and use first non missing values over duplicate person_id into one row. 

  df2<-df1 %>%
  group_by(person_id, redcap_event_name) %>%
  summarise_each(funs(max(.[!is.na(.)])))
#compare the two df's.
  table(df1$microscopy_malaria_pf_kenya___1, exclude = NULL)
  table(df2$microscopy_malaria_pf_kenya___1)
  
  table(df1$result_igg_denv_kenya, exclude = NULL)
  table(df2$result_igg_denv_kenya, exclude = NULL)
  #change -inf to NA
    df2[df2 == -Inf] <- NA
  table(df2$result_igg_denv_kenya)

#export to csv to format and upload to redcap
  setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/david coinfectin paper/data")
  f <- "fix.ids3.csv"
  write.csv(as.data.frame(df2), f, na="" )