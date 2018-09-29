library(readxl)
states <- read_excel("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Brazil/YFV/Epizootics nhp Brazil 1999-2018_SINAN.xlsx", 
                               sheet = "states")
write.csv(states,"states.csv")
Epizootics <- read_excel("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Brazil/YFV/Epizootics nhp Brazil 1999-2018_SINAN.xlsx", 
                                                    sheet = "Epizootics NHP 1999 to 2016")
missing_date<-Epizootics[which(is.na(Epizootics$Date_of_occurrence)),]
Epizootics<-Epizootics[which(!is.na(Epizootics$Date_of_occurrence)),]

setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Brazil/YFV")
Epizootics_sp<-Epizootics[c("Brazilian_state/federal_unit", "Number_of_animals","Date_of_occurrence")]

library(dplyr)
library(zoo)
Epizootics_sp$Date_of_occurrence<-as.Date(as.character(as.POSIXct(Epizootics_sp$Date_of_occurrence)))
Epizootics_sp$Month_Yr<-as.yearmon(Epizootics_sp$Date_of_occurrence)
#Epizootics_sp$Month_Yr <- format(as.Date(Epizootics_sp$Date_of_occurrence), "%Y-%m")
#Epizootics_sp$Month_Yr<-as.factor(Epizootics_sp$Month_Yr)
Epizootics_sp$state<-as.factor(Epizootics_sp$`Brazilian_state/federal_unit`)

Epizootics_sp_dt<-Epizootics_sp %>%
  group_by(state, Month_Yr) %>%
  summarize(
    animials = sum(Number_of_animals, na.rm = TRUE)
  )

# fill in gaps ------------------------------------------------------------

# Convert the Month_Yr column to a date column.
# Accessing a column is done by using the '$' sign
# like so: Epizootics_sp_dt$Month_Yr.
Epizootics_sp_dt$Month_Yr <- as.Date(Epizootics_sp_dt$Month_Yr)

# sort the data by Month_Yr. The [*,] selects all rows that
# match the specified condition - in this case an order function
# applied to the Month_Yr column.
sorted.data <- Epizootics_sp_dt[order(Epizootics_sp_dt$Month_Yr),]

# Find the length of the dataset
data.length <- length(sorted.data$Month_Yr)

# Find min and max. Because the data is sorted, this will be
# the first and last element.
Month_Yr.min <- sorted.data$Month_Yr[1]
Month_Yr.max <- sorted.data$Month_Yr[data.length]

# generate a Month_Yr sequence with 1 month intervals to fill in
# missing dates
all.dates <- seq(Month_Yr.min, Month_Yr.max, by="month")

# Convert all dates to a data frame. Note that we're putting
# the new dates into a column called "Month_Yr" just like the
# original column. This will allow us to merge the data.
all.dates.frame <- data.frame(list(Month_Yr=all.dates))
all.states.frame <- data.frame(list(states=table(Epizootics_sp_dt$state)))
all.dates.frame <- merge(all.dates.frame, all.states.frame, all=T)

colnames(all.dates.frame)[2] <- "state"
# Merge the two datasets: the full dates and original data
merged.data <- merge(all.dates.frame, sorted.data, by = c("Month_Yr","state"), all=T)

# The above merge set the new observations to NA.
# To replace those with a 0, we must first find all the rows
# and then assign 0 to them.
merged.data$animials[which(is.na(merged.data$animials ))] <- 0
colnames(states)[5] <- "state"
merged.data<-merge(states,merged.data,by="state")
merged.data$Month_Yr <- format(as.Date(merged.data$Month_Yr), "%Y-%m")

# write to csv ------------------------------------------------------------
write.csv(merged.data,"Epizootics.csv",na="",row.names = F)

confirmed_year_city <- read_excel("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Brazil/YFV/Epizootics nhp Brazil 1999-2018_SINAN.xlsx", 
                                                    sheet = "confirmed year city")
cities_lat_long<- read_excel("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Brazil/YFV/Epizootics nhp Brazil 1999-2018_SINAN.xlsx", 
                                                    sheet = "cities lat long")
cities_GDP_and_population <- read_excel("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Brazil/YFV/Epizootics nhp Brazil 1999-2018_SINAN.xlsx", 
                                                    sheet = "cities GDP and population")

p1<-ggplot(Epizootics,aes(Date_of_occurrence,Number_of_animals))
p1+geom_bar(aes(fill=`Brazilian_state/federal_unit`), stat = "identity")+ ylim(0, 100)+facet_grid(final_classification~.)
p1+geom_bar(aes(fill=`Brazilian_state/federal_unit`), stat = "identity")+ ylim(0, 100)+facet_grid(final_classification~.)

table(Epizootics_state$NM_ESTADO)

require(rgdal)
brazil_states <- readOGR(dsn = "C:/Users/amykr/Box Sync/Amy Krystosik's Files/Brazil/YFV/br_unidades_da_federacao", layer = "BRUFE250GC_SIR")
plot(brazil_states)
table(brazil_states$NM_ESTADO)
Epizootics_state_shp<-merge(brazil_states,Epizootics_state,by="NM_ESTADO")
#install.packages("SpatialEpiApp")
#install.packages("rsatscan")
library(rsatscan)
library(rsconnect)
#install.packages('rsconnect')
#rsconnect::setAccountInfo(name='amy-robyn', token='393F16288B9C9A39C212211587E6B9CB', secret='Y3DN9TC6kfXMYJfREnI5a6lqp2Zcc0ZRs3AIJY7/')
#rsconnect::appDependencies() 

#source("http://www.math.ntnu.no/inla/givemeINLA.R")
#options(repos = c(getOption("repos"), "INLA"="https://inla.r-inla-download.org/R/testing", "CRAN"="https://cran.rstudio.org"))
#options(repos = c("MyRepo"="http://packages.example.com", "CRAN"="https://cran.rstudio.org"))
#install.packages("INLA", repos=c(getOption("repos"), INLA="https://inla.r-inla-download.org/R/stable"), dep=TRUE)#do i have to reinstall every time?

library("SpatialEpiApp")
options(repos = c(getOption("repos"), INLA="https://inla.r-inla-download.org/R/testing"))
memory.limit(size = 7500000)
run_app()


#install.packages("devtools")
#library(devtools)
#install_github("Paula-Moraga/SpatialEpiApp")
library(SpatialEpiApp)
run_app()
