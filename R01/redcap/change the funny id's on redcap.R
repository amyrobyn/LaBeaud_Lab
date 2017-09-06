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
  R01_lab_results<-R01_lab_results.backup
  
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

  df1<-df1[order(-(grepl('id|date|redcap_event', names(df1)))+1L)]
  df1 <-df1[!sapply(df1, function (x) all(is.na(x) | x == ""| x == "NA"))]
#collapse by id into one row per event
  df1$id<-paste (df1$person_id, df1$redcap_event_name, sep = ".", collapse = NULL)
  #combine rows and use first non missing values over duplicate person_id into one row. 
  library(data.table)
  df3<-setDT(df1)[, lapply(.SD, na.omit), by = id]
  df3<-df1[, lapply(.SD, paste0, collapse=""), by = id]
  df3 <- lapply(df3, function(x) {
                      gsub("NA", "", x)
                  })
df3<-  as.data.frame(df3)

#export to csv to format and upload to redcap
  setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/david coinfectin paper/data")
  f <- "fix.ids.csv"
  write.csv(as.data.frame(df1), f, na="" )
  
  
#Delete the funny id's from redcap
  #!/usr/bin/env Rscript
  library(RCurl)
  result <- postForm(
    uri='https://redcap.stanford.edu/api/',
    token='82F1C4081DEF007B8D4DE287426046E1',
    action='delete',
    content='record',
    'records[0]' = 'CM0405',
    'records[1]' = 'CM0406',
    'records[1]' = 'CM0407',
    'records[2]' = 'CM0408',
    'records[2]' = 'CM0409',
    'records[3]' = 'CM0410',
    'records[3]' = 'CM0411',
    'records[4]' = 'CM0413',
    'records[4]' = 'CM0414',
    'records[5]' = 'CM0415',
    'records[5]' = 'CM0416',
    'records[6]' = 'CM0417',
    'records[6]' = 'CM0418',
    'records[7]' = 'CM0419',
    'records[7]' = 'CM0420',
    'records[8]' = 'CM0421',
    'records[8]' = 'CM0422',
    'records[9]' = 'CMA0406',
    'records[9]' = 'CMA0407',
    'records[10]' = 'CMA0408',
    'records[10]' = 'CMA0409',
    'records[11]' = 'CMA0410',
    'records[11]' = 'CMA0411',
    'records[12]' = 'CMA0413',
    'records[12]' = 'CMA0414',
    'records[13]' = 'CMA0415',
    'records[13]' = 'CMA0416',
    'records[14]' = 'CMA0417',
    'records[14]' = 'CMA0418',
    'records[15]' = 'CMA0419',
    'records[15]' = 'CMA0420',
    'records[16]' = 'CMA0421',
    'records[16]' = 'CMA0422',
    'records[17]' = 'CMB0406',
    'records[17]' = 'CMB0406',
    'records[18]' = 'CMB0406',
    'records[18]' = 'CMB0407',
    'records[19]' = 'CMB0407',
    'records[19]' = 'CMB0407',
    'records[20]' = 'CMB0408',
    'records[20]' = 'CMB0408',
    'records[21]' = 'CMB0408',
    'records[21]' = 'CMB0409',
    'records[22]' = 'CMB0409',
    'records[22]' = 'CMB0409',
    'records[23]' = 'CMB0410',
    'records[23]' = 'CMB0410',
    'records[24]' = 'CMB0410',
    'records[24]' = 'CMB0411',
    'records[25]' = 'CMB0411',
    'records[25]' = 'CMB0411',
    'records[26]' = 'CMB0413',
    'records[26]' = 'CMB0413',
    'records[27]' = 'CMB0413',
    'records[27]' = 'CMB0414',
    'records[28]' = 'CMB0414',
    'records[28]' = 'CMB0414',
    'records[29]' = 'CMB0415',
    'records[29]' = 'CMB0415',
    'records[30]' = 'CMB0415',
    'records[30]' = 'CMB0416',
    'records[31]' = 'CMB0416',
    'records[31]' = 'CMB0416',
    'records[32]' = 'CMB0417',
    'records[32]' = 'CMB0417',
    'records[33]' = 'CMB0417',
    'records[33]' = 'CMB0418',
    'records[34]' = 'CMB0418',
    'records[34]' = 'CMB0418',
    'records[35]' = 'CMB0419',
    'records[35]' = 'CMB0419',
    'records[36]' = 'CMB0419',
    'records[36]' = 'CMB0420',
    'records[37]' = 'CMB0420',
    'records[37]' = 'CMB0420',
    'records[38]' = 'CMB0420',
    'records[38]' = 'CMB0421',
    'records[39]' = 'CMB0421',
    'records[39]' = 'CMB0421',
    'records[40]' = 'CMB0422',
    'records[40]' = 'CMB0422',
    'records[41]' = 'CMB0422',
    'records[41]' = 'KD0005003',
    'records[42]' = 'KD0005003',
    'records[42]' = 'KD0008003',
    'records[43]' = 'KD0008003',
    'records[43]' = 'KD0008004',
    'records[44]' = 'KD0008004',
    'records[44]' = 'KD0009003',
    'records[45]' = 'KD0009003',
    'records[45]' = 'KD0009004',
    'records[46]' = 'KD0009004',
    'records[46]' = 'KD0011003',
    'records[47]' = 'KD0011003',
    'records[47]' = 'KD0011004',
    'records[48]' = 'KD0011004',
    'records[48]' = 'KD0048003',
    'records[49]' = 'KD0048003',
    'records[49]' = 'KD0048004',
    'records[50]' = 'KD0048004',
    'records[50]' = 'KD0049003',
    'records[51]' = 'KD0049003',
    'records[51]' = 'KD0049004',
    'records[52]' = 'KD0049004',
    'records[52]' = 'KD0065004',
    'records[53]' = 'KD0065004',
    'records[53]' = 'KD0076003',
    'records[54]' = 'KD0076003',
    'records[54]' = 'M0102',
    'records[55]' = 'M0109',
    'records[55]' = 'M0165',
    'records[56]' = 'M0172',
    'records[56]' = 'M0233',
    'records[57]' = 'M0260',
    'records[57]' = 'M0305',
    'records[58]' = 'M0363',
    'records[58]' = 'M0378',
    'records[59]' = 'M0380',
    'records[59]' = 'M0384',
    'records[60]' = 'M0421',
    'records[60]' = 'M0425',
    'records[61]' = 'M0435',
    'records[61]' = 'M0437',
    'records[62]' = 'M0450',
    'records[62]' = 'M0463',
    'records[63]' = 'M0468',
    'records[63]' = 'M0490',
    'records[64]' = 'M0494',
    'records[64]' = 'M0516',
    'records[65]' = 'M0523',
    'records[65]' = 'M0525',
    'records[66]' = 'M0533',
    'records[66]' = 'M0557',
    'records[67]' = 'M0566',
    'records[67]' = 'M0583',
    'records[68]' = 'M0587',
    'records[68]' = 'M0602',
    'records[69]' = 'M0626',
    'records[69]' = 'M0639',
    'records[70]' = 'M0649',
    'records[70]' = 'M0673',
    'records[71]' = 'M0674',
    'records[71]' = 'M0684',
    'records[72]' = 'M0687',
    'records[72]' = 'M0690',
    'records[73]' = 'M0697',
    'records[73]' = 'M0698', 
    'records[74]' = 'M0699',
    'records[74]' = 'M0730',
    'records[75]' = 'M0774',
    'records[75]' = 'M0784',
    'records[76]' = 'M0828',
    'records[76]' = 'M0842',
    'records[77]' = 'M0872',
    'records[77]' = 'M0884',
    'records[78]' = 'M0895',
    'records[78]' = 'M0924'
  )
  print(result)
  
  
