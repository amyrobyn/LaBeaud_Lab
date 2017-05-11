#install.packages("redcapAPI")
#install.packages(c("readxl", "xlsx", "plyr","dplyr", "zoo", "AICcmodavg","MuMIn", "car", "sjPlot", "visreg", "datamart", "reshape2", "rJava", "WriteXLS", "xlsx", "readxl"))

library(redcapAPI)
library(rJava) 
library(WriteXLS) # Writing Excel files
library(readxl) # Excel file reading
library(xlsx) # Writing Excel files
library(plyr) # Data frame manipulation
library(dplyr)
library(zoo) # Useful time function (as.yearmon)
library(AICcmodavg) # QAIC and GLM functions
library(MuMIn)
library(car) # VIF stuff
library(sjPlot) # For making nice tables
library(visreg) # Plotting GLM fits
library(datamart) # String processing functions included
library(reshape2) # reshape datasets
library(reshape)


setwd("C:/Users/amykr/Box Sync/DENV CHIKV project/Lab Data/Malaria Database/Malaria Latest/coast") # Always set where you're grabbing stuff from
#df <- read.csv("Coast AIC Malaria Data_20Apr2017", header = TRUE, sep = ",", quote = "\"")
df <- read_excel("Coast AIC Malaria Data_20Apr2017.xls")
glimpse(df)
df_initial <- df[c (2,16,20:24) ] 
glimpse(df_initial)
df_initial$SPP2 <- tolower(df_initial$SPP2)
df_initial$SPP2[df_initial$SPP2=="malaria pigments"] <- "ni"
df_initial$SPP2[df_initial$SPP2=="none"] <- "ni"
df_initial$SPP2[df_initial$SPP2=="pm/pm"] <- "pm"
df_initial$SPP2[df_initial$SPP2=="p/o"] <- "po"
df_initial$SPP2[df_initial$SPP2=="p/m"] <- "pm"
table(df_initial$SPP2)

df_initial$Pos_neg1 <- tolower(df_initial$Pos_neg1)
df_initial$Pos_neg1[df_initial$Pos_neg1=="neg"] <- "0"
df_initial$Pos_neg1[df_initial$Pos_neg1=="pos"] <- "1"
df_initial$Pos_neg1 <- as.numeric(df_initial$Pos_neg1)
glimpse(df_initial)
df_initial$Gametocytes2[df_initial$Gametocytes2=="None"] <- "0"
df_initial$Gametocytes2[df_initial$Gametocytes2=="Neg"] <- ""
df_initial$Gametocytes2[df_initial$Gametocytes2=="Neg"] <- ""
df_initial$Gametocytes2[df_initial$Gametocytes2=="gametocyte"] <- "1"
df_initial$Gametocytes2[df_initial$Gametocytes2=="schizouts"] <- ""
df_initial$Gametocytes2<-as.numeric(df_initial$Gametocytes2)
table(df_initial$Gametocytes2)

glimpse(df_initial)
names(df_initial)[1] <- "aliquot_id_microscopy_malaria_kenya" 
names(df_initial)[2] <- "date_collected_microscopy_malaria_kenya" 
names(df_initial)[3] <- "microscopy_malaria_spp" 
names(df_initial)[4] <- "density_microscpy" 
names(df_initial)[7] <- "result_microscopy_malaria_kenya" 
df_initial$species<-df_initial$microscopy_malaria_spp 
df_initial$species2<-df_initial$microscopy_malaria_spp 
df_initial$species2[df_initial$species2=="pf/pm"] <- "pf"
df_initial$species2[df_initial$species2=="pm/pf"] <- "pf"
df_initial$species2[df_initial$species2=="pf/po"] <- "pf"
df_initial$species2[df_initial$species2=="po/pf"] <- "pf"
table(df_initial$species2)
glimpse(df_initial)
df_wide <- melt(df_initial, c( 'aliquot_id_microscopy_malaria_kenya', 'date_collected_microscopy_malaria_kenya', 'microscopy_malaria_spp', 'result_microscopy_malaria_kenya', 'Gametocytes2', 'species', 'species2'), 'density_microscpy')
glimpse(df_wide)
df_wide2<-cast(df_wide, aliquot_id_microscopy_malaria_kenya +  date_collected_microscopy_malaria_kenya +  result_microscopy_malaria_kenya + Gametocytes + microscopy_malaria_spp ~ species2, fun = sum, value  = 'value')
glimpse(df_wide2)

df_wide2$species2<-df_wide2$species 

f <- "malria_aic_coast.xls"
write.xlsx(as.data.frame(df_wide2), f, sheetName = "initial", col.names = TRUE,
           row.names = FALSE, append = FALSE, showNA = TRUE)

setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long") # Always set where you're grabbing stuff from
df <- read.csv("coast_hcc_malaria.csv")
names(df)[1] <- "person_id" 

  # Your REDCap issued token, I read mine from a text file
  Redcap.token <- readLines("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long/Redcap.token.txt") # Read API token from folder
  # REDCAp site API-URL, will most likely be the REDCap site where you normally login + api
  REDcap.URL  <- 'https://redcap.stanford.edu/api/'
  rcon <- redcapConnection(url=REDcap.URL, token=Redcap.token)
df <- df[,colSums(is.na(df))<nrow(df)]
glimpse(df)
# convert date info in format 'mm/dd/yyyy'
df$date_collected_microscopy_malaria_kenya <- as.Date(df$date_collected_microscopy_malaria_kenya, "%m/%d/%Y")
df$date_collected_microscopy_malaria_kenya<-as.POSIXct(df$date_collected_microscopy_malaria_kenya)
class(df$date_collected_microscopy_malaria_kenya)

df$date_tested_microscopy_malaria_kenya <- as.Date(df$date_tested_microscopy_malaria_kenya, "%m/%d/%Y")
df$date_tested_microscopy_malaria_kenya<-as.POSIXct(df$date_tested_microscopy_malaria_kenya)
class(df$date_tested_microscopy_malaria_kenya)

df_subset<-subset(df, person_id!="MF658A" & person_id!="MF658B" )

## S3 method for class 'redcapApiConnection'
importRecords(rcon, df, overwriteBehavior = "normal", returnContent = c("count", "ids", "nothing"), 
              returnData = FALSE, logfile = "", proj = NULL,
              batch.size = -1)
