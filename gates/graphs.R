#install.packages(c("plotly", "plyr"))
#library(lubridate)
#library(plotly)
#library(plyr)
#require(ggplot2)
#require(reshape)
#library(xlsx)
library(readxl) # Excel file reading
library(plotly)


#rm(list=ls()) #remove previous variable assignments
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Gates/may_2017_presi/CSV files for graphing2/CSV files for graphing")
#without loop
GMC <- read_excel("log_ab_pnps6b_everinfected.xlsx")
names(GMC)[7] <- "month"


infected <- GMC[which(GMC$ever_infected  ==1), c (1:8) ] 
uninfected <- GMC[which(GMC$ever_infected ==0), c (1:8) ] 

m <- list(
  l = 90,
  r = 30,
  b = 100,
  t = 130,
  pad = 3
)



f <- list(
  family = "Arial",
  size = 33,
  color = "rgb(68, 68, 68)"
)

l = list(
  x = 0.1, 
  y = 0.9, 
  layer =	above, 
  xanchor	=	left, 
  yanchor	=	top, 
  sizex	=	0.5, 
  sizey	=	0.2, 
  sizing	=	contain, 
  opacity	=	1, 
  xref	=	paper, 
  x	=	-0.1, 
  yref	=	paper, y	=	1.27, orientation = 'v')

x <- list(
  autotick = FALSE,
  ticks = "outside",
  tick0 = 0,
  dtick = 6,
  ticklen = 5,
  tickwidth = 2,
  tickcolor = toRGB("black"),
  title = "Age (Months)",
  titlefont = f
)

y <- list(
  title = "GMCPnPs 6B antibody (ug/ml)",
  titlefont = f
)
t <- list(
  title = "Antibody over Time",
  titlefont = f
)

p<-  plot_ly() %>%
    add_lines(x = infected$month, y = infected$geo_mean, 
              color = I("black"), name = "Ever infected") %>%
    add_ribbons(x = infected$month, ymin = infected$lower, ymax = infected$upper,
                line = list(color="transparent"), showlegend=T, name = "Ever infected 95% confidence") %>%
    
    add_lines(x = uninfected$month, y = uninfected$geo_mean, 
              color = I("black"), name = "Uninfected", type = "scatter", line = list(dash="dash") ) %>%
    add_ribbons(x = uninfected$month, ymin = uninfected$lower, ymax = uninfected$upper,
                line = list(color="#A020F066"), showlegend=T,
                name = "Uninfected 95% confidence")%>%
    layout(xaxis = x, yaxis = y, title = "GMC of PnPs 6B antibody over months", titlefont = f,  legend = l , margin = m)
       
plotly_POST(p, filename = "r-docs/test1")

y


