#install.packages(c("plotly", "plyr"))
#library(lubridate)
#library(plotly)
#library(plyr)
#require(ggplot2)
#require(reshape)
#library(xlsx)
library(readxl) # Excel file reading

#rm(list=ls()) #remove previous variable assignments
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Gates/may_2017_presi/CSV files for graphing2/CSV files for graphing")
#without loop
GMC <- read_excel("geo_means_pnps7f_all_polyp_v_uninfected.xlsx")
GMC$geo_mean<-GMC$geomean
#names(GMC)[1] <- "infected"; names(GMC)[2] <- "week"

infected_GMC <- GMC[ which(GMC$infected ==1), c (1:9) ] 
not_infected_GMC <- GMC[ which(GMC$infected ==0), c (1:9) ] 

GMC$group = as.character(GMC$infected)
library(plotly)
f <- list(
  family = "Courier New, monospace",
  size = 18,
  color = "#7f7f7f"
)
x <- list(
  autotick = FALSE,
  ticks = "outside",
  tick0 = 0,
  dtick = 26 ,
  ticklen = 5,
  tickwidth = 2,
  tickcolor = toRGB("black"),
  title = "Weeks",
  titlefont = f
)

y <- list(
  title = "GMC",
  titlefont = f
)
t <- list(
  title = "GMC over weeks by Infection Status",
  titlefont = f
)
plot_ly() %>%
  add_lines(x = infected_GMC$week, y = infected_GMC$geo_mean, 
            color = I("black"), name = "Infected") %>%
  add_ribbons(x = infected_GMC$week, ymin = infected_GMC$lower, ymax = infected_GMC$upper,
              line = list(color="transparent"), showlegend=T, name = "Infected 95% confidence") %>%
  
  add_lines(x = not_infected_GMC$week, y = not_infected_GMC$geo_mean, 
            color = I("black"), name = "Un-Infected", type = "scatter", line = list(dash="dash") ) %>%
  add_ribbons(x = not_infected_GMC$week, ymin = not_infected_GMC$lower, ymax = not_infected_GMC$upper,
              line = list(color="#A020F066"), showlegend=T,
              name = "Un-infected 95% confidence")%>%
  layout(xaxis = x, yaxis = y, title = "GMC over weeks by Infection Status",   titlefont = f )
  