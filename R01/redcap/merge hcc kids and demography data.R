library(redcapAPI)
library(REDCapR)


setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long")#put your local folder here.
Redcap.token <- readLines("Redcap.token.R01.txt") #create a text file in that folder with your api token. then Read API token from folder
REDcap.URL  <- 'https://redcap.stanford.edu/api/'#this is the redcap url at stanford.
rcon <- redcapConnection(url=REDcap.URL, token=Redcap.token) #create an object with the url and your api.

#export data from redcap to R (must be connected via cisco VPN)

R01_lab_results <- redcap_read(  
  redcap_uri  = REDcap.URL,  
  token       = Redcap.token,  batch_size = 300)$data

hcc_kids<-R01_lab_results[-which(R01_lab_results$cohort ==2)  , ]

save(R01_lab_results, file="R01_lab_results.rda") #save the data to your local working directory.

#after you have the data, next time you can start from line 19.
load("R01_lab_results.rda") #load the data from your local directory (this will save you time later rather than always downolading from redcap.)

#read the csv files into r
child_demography<-read.csv("your_filename.csv")
house_demography<-read.csv("your_filename.csv")

#merge the hcc data with the demography data
merged<-  merge(x = child_demography, y = house_demography, by.x = c("house_id"), by.y = c("house_id"), all.x = TRUE)
  
merged<-  merge(x = merged, y = hcc_kids, by.x = c("house_id"), by.y = c("house_id"), all.y = TRUE)
  #keep those with a redcap event name 
  merged<-merged[-which(is.na(merged$redcap_event_name))  , ]

#export to csv
f <- "your file name.csv"
write.csv(as.data.frame(merged), f, na="")