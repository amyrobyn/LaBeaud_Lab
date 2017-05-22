setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long")
#install.packages("REDCapR")
library(REDCapR)
library(RCurl)
library(dplyr)
library(redcapAPI)
library(WriteXLS) # Writing Excel files

Redcap.token <- readLines("Redcap.token.R01.txt") # Read API token from folder
REDcap.URL  <- 'https://redcap.stanford.edu/api/'
rcon <- redcapConnection(url=REDcap.URL, token=Redcap.token)


#export data from redcap to R (must be connected via cisco VPN)
R01_lab_results <- redcap_read(
  redcap_uri  = REDcap.URL,
  token       = Redcap.token
)$data

save(R01_lab_results,file="R01_lab_results.Rda")
load("R01_lab_results.Rda")
n_distinct(R01_lab_results$person_id, na.rm = FALSE)

records_to_delete<-read.csv("to delete.csv", header = TRUE, sep = ",", quote = "\"",
                            dec = ".", fill = TRUE, comment.char = "")
records_to_delete<-subset(records_to_delete,!duplicated(records_to_delete$person_id))

f <- "records_to_delete.xls"
write.xlsx(as.data.frame(records_to_delete), f, sheetName = "delete", col.names = TRUE,
           row.names = FALSE, append = FALSE, showNA = TRUE)


records_to_delete_array<- simplify2array(by(records_to_delete, records_to_delete$person_id, as.matrix))





R01_lab_results2 <- R01_lab_results[!R01_lab_results$person_id %in% records_to_delete_array, ]
n_distinct(R01_lab_results2$person_id, na.rm = FALSE)

## S3 method for class 'redcapApiConnection' THis method will require reformatting all the dates to meet redcap standards.
importRecords(rcon, R01_lab_results2, overwriteBehavior = "normal", returnContent = c("count", "ids", "nothing"), 
              returnData = FALSE, logfile = "", proj = NULL,
              batch.size = -1)


