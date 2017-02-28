setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/david coinfectin paper/igrowup_R")
# Restore reference data sets using the following commands:
  
weianthro<-read.table("weianthro.txt",header=T,sep="",skip=0)
lenanthro<-read.table("lenanthro.txt",header=T,sep="",skip=0)
bmianthro<-read.table("bmianthro.txt",header=T,sep="",skip=0)
hcanthro<-read.table("hcanthro.txt",header=T,sep="",skip=0)
acanthro<-read.table("acanthro.txt",header=T,sep="",skip=0)
ssanthro<-read.table("ssanthro.txt",header=T,sep="",skip=0)
tsanthro<-read.table("tsanthro.txt",header=T,sep="",skip=0)
wflanthro<-read.table("wflanthro.txt",header=T,sep="",skip=0)
wfhanthro<-read.table("wfhanthro.txt",header=T,sep="",skip=0)

#Source the igrowup_standard.r and igrowup_restricted.r files in the package directory [dir], using the command
source("igrowup_standard.r")
source("igrowup_restricted.r")


#Step 2: Import your data file into R. The following example is using the data set survey.csv contained in the package igrowup_R.
#Example: dataframe=survey

#"C:/Users/amykr/Box Sync/Amy Krystosik's Files/david coinfectin paper/denvchikvmalariagps_symptoms.csv"

survey<-read.csv("C:/Users/amykr/Box Sync/Amy Krystosik's Files/david coinfectin paper/denvchikvmalariagps_symptoms.csv",header=T,sep=",",skip=0,na.strings="")
#Step 3:
#Standard analysis
igrowup.standard(FilePath="C:/Users/amykr/Box Sync/Amy Krystosik's Files/david coinfectin paper/who anthro", FileLab="MySurvey",mydf=survey,sex=GENDER,age=agemons,age.month=T,weight=WEIGHT,lenhei=HEIGHT,measure=measure,oedema=oedema,headc=HEAD)