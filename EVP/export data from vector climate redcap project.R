# packages ----------------------------------------------------------------
library(pastecs)
library(psych)
library(plyr)
library(dplyr)
library(tidyr)
library(zoo)
library(lubridate)
library(stringr)
library(redcapAPI)
library(REDCapR)
library(Hmisc)

# data --------------------------------------------------------------------

setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/vector")


#download data from redcap ## S3 method for class 'redcapApiConnection' THis method will require reformatting all the dates to meet redcap standards.
Redcap.token <- readLines("api.key.txt") # Read API token from folder
REDcap.URL  <- 'https://redcap.stanford.edu/api/'
rcon <- redcapConnection(url=REDcap.URL, token=Redcap.token)
  vector_climate <- redcap_read(redcap_uri  = REDcap.URL, token = Redcap.token, batch_size = 200)$data#export data from redcap to R (must be connected via cisco VPN)
    library(beepr)
    beep(sound=4)  #beep when finishes.


#save backup from today
  currentDate <- Sys.Date() 
  FileName <- paste("vector_climate",currentDate,".rda",sep=" ") 
  save(vector_climate,file=FileName)
#load most recent backup
  load(FileName)

# descriptives ------------------------------------------------------------
describe(vector_climate) 

# graph denv and chikv ----------------------------------------------------
plot_ly() %>%
    add_trace(name ="DENV",x=monthly_infection$month_year, y =monthly_infection$infected_denv_stfd_inc, type = 'scatter', mode = 'lines', line=list(width=4), connectgaps=TRUE, showlegend=T, axis="y")%>%
    add_trace(name ="CHIKV",x=monthly_infection$month_year, y =monthly_infection$infected_chikv_stfd_inc, type = 'scatter', mode = 'lines', line=list(width=4), connectgaps=TRUE, showlegend=T, axis="y")%>%
    add_trace(data=Monthlyvector, x = ~month_year, y = ~Ttl_Aedes.spp.Indoor.ovi+ttl_Aedes_spp_Outdoor.ovi, type = 'bar', name = 'Ovitrap', yaxis = "y2")%>%
    add_trace(data=Monthlyvector, x = ~month_year, y = ~Ttl_Aedes.spp.larva, type = 'bar', name = 'Larva', yaxis = "y2")%>%
    add_trace(data=Monthlyvector, x = ~month_year, y = ~Ttl_Aedes.spp_in.proko+Ttl_Aedes.spp_out.proko, type = 'bar', name = 'Prokopack', yaxis = "y")%>%
    add_trace(data=Monthlyvector, x = ~month_year, y = ~Ttl_Aedes.spp.bg, type = 'bar', name = 'BG', yaxis = "y2")%>%
    add_trace(data=Monthlyvector, x = ~month_year, y = ~Ttl_Aedes.spp.hlc, type = 'bar', name = 'HLC', yaxis = "y2")%>%
    layout(title='Incident Exposure over Time', 
           titlefont=f3, 
           xaxis = a, 
           yaxis = list(title = 'Proportion infected', tickfont=f1,titlefont=f2,range = c(0,1)),legend=legend, 
           yaxis2 = list(side = 'right', overlaying = "y", title = 'Aedes Mosquito (count)', showgrid = FALSE, zeroline = FALSE),
           barmode = 'stack',
           margin = margin)
  
  