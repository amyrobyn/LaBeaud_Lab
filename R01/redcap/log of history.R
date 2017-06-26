setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long") # Always set where you're grabbing stuff from
log<-read.csv("R01CHIKVDENVProject_Logging.csv", header = TRUE, sep = ",",   fill = TRUE )
logSubset <- log[grep("Updated Record", log$Action),]
Action_split<-strsplit(logSubset$Action, ", ")


x <- c(as = "asfef", qu = "qwerty", "yuiop[", "b", "stuff.blah.yech")
# split x on the letter e
y<-strsplit(x, "e")