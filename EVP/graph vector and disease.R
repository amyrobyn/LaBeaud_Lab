# packages ----------------------------------------------------------------
library(plyr)
library(zoo)
library(lubridate)
# import data -------------------------------------------------------------
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/ASTMH 2017 abstracts/amy- built environment/data")
load("C:/Users/amykr/Box Sync/Amy Krystosik's Files/climate/MonthlyClimate.rda")

load("C:/Users/amykr/Box Sync/Amy Krystosik's Files/climate/obamaMonthlyClimate.rda")
load("C:/Users/amykr/Box Sync/Amy Krystosik's Files/climate/msambweniMonthlyClimate.rda")
load("C:/Users/amykr/Box Sync/Amy Krystosik's Files/climate/kisumuMonthlyClimate.rda")
load("C:/Users/amykr/Box Sync/Amy Krystosik's Files/climate/UkundaMonthlyClimate.rda")
load("C:/Users/amykr/Box Sync/Amy Krystosik's Files/climate/chulaimboMonthlyClimate.rda")

load(file="C:/Users/amykr/Box Sync/Amy Krystosik's Files/vector/Monthlyvector.rda")
load("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long/R01_lab_results.clean.rda")

monthly_infection <- ddply(R01_lab_results, .(month_year, City),
                           summarise, 
                           infected_denv_stfd_sum = sum(infected_denv_stfd, na.rm = TRUE),
                           infected_chikv_stfd_sum = sum(infected_chikv_stfd, na.rm = TRUE),
                           infected_denv_stfd_inc = mean(infected_denv_stfd, na.rm = TRUE),
                           infected_chikv_stfd_inc = mean(infected_chikv_stfd, na.rm = TRUE),
                           infected_denv_stfd_sd = sd(infected_denv_stfd, na.rm = TRUE),
                           infected_chikv_stfd_sd = sd(infected_chikv_stfd, na.rm = TRUE)
)

# plotly global settings --------------------------------------------------
library(plotly)
f1 <- list(
  family = "Arial, sans-serif",
  size = 18,
  color = "black"
)
f2 <- list(
  family = "Arial, sans-serif",
  size = 24,
  color = "black"
)
f3 <- list(
  family = "Arial, sans-serif",
  size = 36,
  color = "black"
)
a <- list(
  autotick = FALSE,
  ticks = "outside",
  tick0 = 0,
  dtick = 1,
  ticklen = 5,
  tickwidth = 2,
  tickcolor = toRGB("black"),
  tickfont=f1,
  title=""
)

t <- list(
  family = "sans serif",
  size = 36,
  color = 'black')
f <- list(
  family = "sans serif",
  size = 28,
  color = 'black')

m <- list(
  l = 100,
  r = 150,
  b = 150,
  t = 100,
  pad = 4
)

legend = list(orientation = "h",   # show entries horizontally
              xanchor = "center",  # use center of legend as anchor
              x = 0.5,
              font=f2
)  

# split by city -----------------------------------------------------------
monthly_infection$month_year<-as.Date(monthly_infection$month_year)

monthly_infection.c<-monthly_infection[which(monthly_infection$City=="C"), ]
monthly_infection.k<-monthly_infection[which(monthly_infection$City=="K"), ]
monthly_infection.m<-monthly_infection[which(monthly_infection$City=="M"), ]
monthly_infection.u<-monthly_infection[which(monthly_infection$City=="U"), ]

Monthlyvector.c<-Monthlyvector[which(Monthlyvector$study_site==3), ]
Monthlyvector.k<-Monthlyvector[which(Monthlyvector$study_site==4), ]
Monthlyvector.m<-Monthlyvector[which(Monthlyvector$study_site==2), ]
Monthlyvector.u<-Monthlyvector[which(Monthlyvector$study_site==1), ]

# plot vector and disease. chulaimbo --------------------------------------
disease_vector.c<- plot_ly() %>% 
  add_trace(data=Monthlyvector.c, x = ~month_year, y = ~z.egg_count_ovitrap, type = 'bar', name = 'Ovitrap', yaxis = "y")%>%
  add_trace(data=Monthlyvector.c, x = ~month_year, y = ~z.Ttl_Aedes.spp.larva, type = 'bar', name = 'Larva', yaxis = "y")%>%
  add_trace(data=Monthlyvector.c, x = ~month_year, y = ~z.Ttl_Aedes.spp.proko , type = 'bar', name = 'Prokopack', yaxis = "y")%>%
  add_trace(data=Monthlyvector.c, x = ~month_year, y = ~z.Ttl_Aedes.spp.bg , type = 'bar', name = 'BG', yaxis = "y")%>%
  add_trace(data=Monthlyvector.c, x = ~month_year, y = ~z.Ttl_Aedes.spp.hlc , type = 'bar', name = 'HLC', yaxis = "y")%>%
  add_trace(data=monthly_infection.c, name ="CHIKV",x=~month_year, y=~infected_chikv_stfd_inc, type = 'scatter', mode = 'lines', line=list(width=4, color="black", dash="dash"),  connectgaps=TRUE, showlegend=T, yaxis="y2")%>%
  add_trace(data=monthly_infection.c, name ="DENV",x=~month_year, y=~infected_denv_stfd_inc, type = 'scatter', mode = 'lines', line=list(width=4,color ="black"), connectgaps=TRUE, showlegend=T, yaxis="y2")%>%
  layout(
    title = 'Chulaimbo',
    margin = margin, 
    xaxis = list(type ="date", nticks = 15, tickangle =25,title = "",tickfont=f1,titlefont=f2),
    yaxis = list(side = 'left', title = 'Aedes Mosquito (Z-Score)', showgrid = FALSE, zeroline = TRUE, barmode='relative',tickfont=f1,titlefont=f2, range=c(0,80)),
    yaxis2 = list(side = 'right', overlaying = "y", title = 'Proportion Infected', showgrid = FALSE, zeroline = FALSE, range=c(0,0.6), tickformat="%",tickfont=f1,titlefont=f2),
    titlefont=f3, 
    barmode = 'stack', legend=legend)
# plot vector and disease. kisumu --------------------------------------
disease_vector.k<- plot_ly() %>% 
  add_trace(data=Monthlyvector.k, x = ~month_year, y = ~z.egg_count_ovitrap, type = 'bar', name = 'Ovitrap', yaxis = "y")%>%
  add_trace(data=Monthlyvector.k, x = ~month_year, y = ~z.Ttl_Aedes.spp.larva, type = 'bar', name = 'Larva', yaxis = "y")%>%
  add_trace(data=Monthlyvector.k, x = ~month_year, y = ~z.Ttl_Aedes.spp.proko , type = 'bar', name = 'Prokopack', yaxis = "y")%>%
  add_trace(data=Monthlyvector.k, x = ~month_year, y = ~z.Ttl_Aedes.spp.bg , type = 'bar', name = 'BG', yaxis = "y")%>%
  add_trace(data=Monthlyvector.k, x = ~month_year, y = ~z.Ttl_Aedes.spp.hlc , type = 'bar', name = 'HLC', yaxis = "y")%>%
  add_trace(data=monthly_infection.k, name ="CHIKV",x=~month_year, y=~infected_chikv_stfd_inc, type = 'scatter', mode = 'lines', line=list(width=4, color="black", dash="dash"),  connectgaps=TRUE, showlegend=T, yaxis="y2")%>%
  add_trace(data=monthly_infection.k, name ="DENV",x=~month_year, y=~infected_denv_stfd_inc, type = 'scatter', mode = 'lines', line=list(width=4,color ="black"), connectgaps=TRUE, showlegend=T, yaxis="y2")%>%
  layout(
    title = 'Kisumu',
    margin = margin, 
    xaxis = list(type ="date", nticks = 15, tickangle =25,title = "",tickfont=f1,titlefont=f2),
    yaxis = list(side = 'left', title = 'Aedes Mosquito (Z-Score)', showgrid = FALSE, zeroline = TRUE, barmode='relative',tickfont=f1,titlefont=f2, range=c(0,80)),
    yaxis2 = list(side = 'right', overlaying = "y", title = 'Proportion Infected', showgrid = FALSE, zeroline = FALSE, range=c(0,0.6), tickformat="%",tickfont=f1,titlefont=f2),
    titlefont=f3, 
    barmode = 'stack', legend=legend)
# plot vector and disease. msambweni --------------------------------------
disease_vector.m<- plot_ly() %>% 
  add_trace(data=Monthlyvector.m, x = ~month_year, y = ~z.egg_count_ovitrap, type = 'bar', name = 'Ovitrap', yaxis = "y")%>%
  add_trace(data=Monthlyvector.m, x = ~month_year, y = ~z.Ttl_Aedes.spp.larva, type = 'bar', name = 'Larva', yaxis = "y")%>%
  add_trace(data=Monthlyvector.m, x = ~month_year, y = ~z.Ttl_Aedes.spp.proko , type = 'bar', name = 'Prokopack', yaxis = "y")%>%
  add_trace(data=Monthlyvector.m, x = ~month_year, y = ~z.Ttl_Aedes.spp.bg , type = 'bar', name = 'BG', yaxis = "y")%>%
  add_trace(data=Monthlyvector.m, x = ~month_year, y = ~z.Ttl_Aedes.spp.hlc , type = 'bar', name = 'HLC', yaxis = "y")%>%
  add_trace(data=monthly_infection.m, name ="CHIKV",x=~month_year, y=~infected_chikv_stfd_inc, type = 'scatter', mode = 'lines', line=list(width=4, color="black", dash="dash"),  connectgaps=TRUE, showlegend=T, yaxis="y2")%>%
  add_trace(data=monthly_infection.m, name ="DENV",x=~month_year, y=~infected_denv_stfd_inc, type = 'scatter', mode = 'lines', line=list(width=4,color ="black"), connectgaps=TRUE, showlegend=T, yaxis="y2")%>%
  layout(
    title = 'Msambweni',
    margin = margin, 
    xaxis = list(type ="date", nticks = 15, tickangle =25,title = "",tickfont=f1,titlefont=f2),
    yaxis = list(side = 'left', title = 'Aedes Mosquito (Z-Score)', showgrid = FALSE, zeroline = TRUE, barmode='relative',tickfont=f1,titlefont=f2, range=c(0,80)),
    yaxis2 = list(side = 'right', overlaying = "y", title = 'Proportion Infected', showgrid = FALSE, zeroline = FALSE, range=c(0,0.6), tickformat="%",tickfont=f1,titlefont=f2),
    titlefont=f3, 
    barmode = 'stack', legend=legend)
# plot vector and disease. ukunda --------------------------------------
disease_vector.u<- plot_ly() %>% 
  add_trace(data=Monthlyvector.u, x = ~month_year, y = ~z.egg_count_ovitrap, type = 'bar', name = 'Ovitrap', yaxis = "y")%>%
  add_trace(data=Monthlyvector.u, x = ~month_year, y = ~z.Ttl_Aedes.spp.larva, type = 'bar', name = 'Larva', yaxis = "y")%>%
  add_trace(data=Monthlyvector.u, x = ~month_year, y = ~z.Ttl_Aedes.spp.proko , type = 'bar', name = 'Prokopack', yaxis = "y")%>%
  add_trace(data=Monthlyvector.u, x = ~month_year, y = ~z.Ttl_Aedes.spp.bg , type = 'bar', name = 'BG', yaxis = "y")%>%
  add_trace(data=Monthlyvector.u, x = ~month_year, y = ~z.Ttl_Aedes.spp.hlc , type = 'bar', name = 'HLC', yaxis = "y")%>%
  add_trace(data=monthly_infection.u, name ="CHIKV",x=~month_year, y=~infected_chikv_stfd_inc, type = 'scatter', mode = 'lines', line=list(width=4, color="black", dash="dash"),  connectgaps=TRUE, showlegend=T, yaxis="y2")%>%
  add_trace(data=monthly_infection.u, name ="DENV",x=~month_year, y=~infected_denv_stfd_inc, type = 'scatter', mode = 'lines', line=list(width=4,color ="black"), connectgaps=TRUE, showlegend=T, yaxis="y2")%>%
  layout(
    title = 'Ukunda',
    margin = margin, 
    xaxis = list(type ="date", nticks = 15, tickangle =25,title = "",tickfont=f1,titlefont=f2),
    yaxis = list(side = 'left', title = 'Aedes Mosquito (Z-Score)', showgrid = FALSE, zeroline = TRUE, barmode='relative',tickfont=f1,titlefont=f2, range=c(0,80)),
    yaxis2 = list(side = 'right', overlaying = "y", title = 'Proportion Infected', showgrid = FALSE, zeroline = FALSE, range=c(0,0.6), tickformat="%",tickfont=f1,titlefont=f2),
    titlefont=f3, 
    barmode = 'stack', legend=legend)

# add climate ukunda-------------------------------------------------------------
UkundaMonthlyClimate$month_collected<-as.Date(UkundaMonthlyClimate$month_collected)
disease_climate.u<- plot_ly() %>% 
  add_trace(data=UkundaMonthlyClimate, x = ~month_collected, y = ~AvgTemp, type = 'scatter', mode = 'lines', name='Average Temperature', yaxis = "y")%>%
#  add_trace(data=UkundaMonthlyClimate, x = ~month_collected, y = ~TtlRainfall, type = 'scatter', mode = 'lines', name='Total Rain', yaxis = "y")%>%
  add_trace(data=monthly_infection.u, name ="CHIKV",x=~month_year, y=~infected_chikv_stfd_inc, type = 'scatter', mode = 'lines', line=list(width=4, color="black", dash="dash"),  connectgaps=TRUE, showlegend=T, yaxis="y2")%>%
  add_trace(data=monthly_infection.u, name ="DENV",x=~month_year, y=~infected_denv_stfd_inc, type = 'scatter', mode = 'lines', line=list(width=4,color ="black"), connectgaps=TRUE, showlegend=T, yaxis="y2")%>%
  layout(
    title = 'Ukunda',
    margin = margin, 
    xaxis = list(type ="date", nticks = 15, tickangle =25,title = "",tickfont=f1,titlefont=f2),
    yaxis = list(side = 'left', title = 'Climate', showgrid = FALSE, zeroline = TRUE, barmode='relative',tickfont=f1,titlefont=f2),
    yaxis2 = list(side = 'right', overlaying = "y", title = 'Proportion Infected', showgrid = FALSE, zeroline = FALSE, range=c(0,0.6), tickformat="%",tickfont=f1,titlefont=f2),
    titlefont=f3, 
    barmode = 'stack', legend=legend)
# add climate msambweni-------------------------------------------------------------
msambweniMonthlyClimate$month_collected<-as.Date(msambweniMonthlyClimate$month_collected)
disease_climate.m<- plot_ly() %>% 
  add_trace(data=msambweniMonthlyClimate, x = ~month_collected, y = ~AvgTemp, type = 'scatter', mode = 'lines', name='Average Temperature', yaxis = "y")%>%
  #  add_trace(data=msambweniMonthlyClimate, x = ~month_collected, y = ~TtlRainfall, type = 'scatter', mode = 'lines', name='Total Rain', yaxis = "y")%>%
  add_trace(data=monthly_infection.m, name ="CHIKV",x=~month_year, y=~infected_chikv_stfd_inc, type = 'scatter', mode = 'lines', line=list(width=4, color="black", dash="dash"),  connectgaps=TRUE, showlegend=T, yaxis="y2")%>%
  add_trace(data=monthly_infection.m, name ="DENV",x=~month_year, y=~infected_denv_stfd_inc, type = 'scatter', mode = 'lines', line=list(width=4,color ="black"), connectgaps=TRUE, showlegend=T, yaxis="y2")%>%
  layout(
    title = 'Ukunda',
    margin = margin, 
    xaxis = list(type ="date", nticks = 15, tickangle =25,title = "",tickfont=f1,titlefont=f2),
    yaxis = list(side = 'left', title = 'Climate', showgrid = FALSE, zeroline = TRUE, barmode='relative',tickfont=f1,titlefont=f2),
    yaxis2 = list(side = 'right', overlaying = "y", title = 'Proportion Infected', showgrid = FALSE, zeroline = FALSE, range=c(0,0.6), tickformat="%",tickfont=f1,titlefont=f2),
    titlefont=f3, 
    barmode = 'stack', legend=legend)
# add climate kisumu-------------------------------------------------------------
kisumuMonthlyClimate$month_collected<-as.Date(kisumuMonthlyClimate$month_collected)
disease_climate.k<- plot_ly() %>% 
  add_trace(data=kisumuMonthlyClimate, x = ~month_collected, y = ~AvgTemp, type = 'scatter', mode = 'lines', name='Average Temperature', yaxis = "y")%>%
  #  add_trace(data=kisumuMonthlyClimate, x = ~month_collected, y = ~TtlRainfall, type = 'scatter', mode = 'lines', name='Total Rain', yaxis = "y")%>%
  add_trace(data=monthly_infection.k, name ="CHIKV",x=~month_year, y=~infected_chikv_stfd_inc, type = 'scatter', mode = 'lines', line=list(width=4, color="black", dash="dash"),  connectgaps=TRUE, showlegend=T, yaxis="y2")%>%
  add_trace(data=monthly_infection.k, name ="DENV",x=~month_year, y=~infected_denv_stfd_inc, type = 'scatter', mode = 'lines', line=list(width=4,color ="black"), connectgaps=TRUE, showlegend=T, yaxis="y2")%>%
  layout(
    title = 'Ukunda',
    margin = margin, 
    xaxis = list(type ="date", nticks = 15, tickangle =25,title = "",tickfont=f1,titlefont=f2),
    yaxis = list(side = 'left', title = 'Climate', showgrid = FALSE, zeroline = TRUE, barmode='relative',tickfont=f1,titlefont=f2),
    yaxis2 = list(side = 'right', overlaying = "y", title = 'Proportion Infected', showgrid = FALSE, zeroline = FALSE, range=c(0,0.6), tickformat="%",tickfont=f1,titlefont=f2),
    titlefont=f3, 
    barmode = 'stack', legend=legend)
# add climate chulaimbo-------------------------------------------------------------
chulaimboMonthlyClimate$month_collected<-as.Date(chulaimboMonthlyClimate$month_collected)
disease_climate.c<- plot_ly() %>% 
  add_trace(data=chulaimboMonthlyClimate, x = ~month_collected, y = ~AvgTemp, type = 'scatter', mode = 'lines', name='Average Temperature', yaxis = "y")%>%
  #  add_trace(data=chulaimboMonthlyClimate, x = ~month_collected, y = ~TtlRainfall, type = 'scatter', mode = 'lines', name='Total Rain', yaxis = "y")%>%
  add_trace(data=monthly_infection.c, name ="CHIKV",x=~month_year, y=~infected_chikv_stfd_inc, type = 'scatter', mode = 'lines', line=list(width=4, color="black", dash="dash"),  connectgaps=TRUE, showlegend=T, yaxis="y2")%>%
  add_trace(data=monthly_infection.c, name ="DENV",x=~month_year, y=~infected_denv_stfd_inc, type = 'scatter', mode = 'lines', line=list(width=4,color ="black"), connectgaps=TRUE, showlegend=T, yaxis="y2")%>%
  layout(
    title = 'Ukunda',
    margin = margin, 
    xaxis = list(type ="date", nticks = 15, tickangle =25,title = "",tickfont=f1,titlefont=f2),
    yaxis = list(side = 'left', title = 'Climate', showgrid = FALSE, zeroline = TRUE, barmode='relative',tickfont=f1,titlefont=f2),
    yaxis2 = list(side = 'right', overlaying = "y", title = 'Proportion Infected', showgrid = FALSE, zeroline = FALSE, range=c(0,0.6), tickformat="%",tickfont=f1,titlefont=f2),
    titlefont=f3, 
    barmode = 'stack', legend=legend)

# plot  ----------------------------------------------------
disease_vector.u
disease_vector.m
disease_vector.c
disease_vector.k

disease_climate.u
disease_climate.k
disease_climate.m
disease_climate.c