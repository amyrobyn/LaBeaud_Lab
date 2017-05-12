#install.packages(c("plotly", "plyr"))
#library(lubridate)
#library(plotly)
#library(plyr)
#require(ggplot2)
#require(reshape)
#library(xlsx)
library(readxl) # Excel file reading
library(plotly)
library(plyr)


#rm(list=ls()) #remove previous variable assignments
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Gates/may_2017_presi")
m <- list(
  l = 90,
  r = 30,
  b = 130,
  t = 90,
  pad = 4
)

f <- list(
  family = "Arial",
  size = 33,
  color = "rgb(68, 68, 68)"
)

smallf <- list(
  family = "Arial",
  size = 16,
  color = "rgb(68, 68, 68)"
)

l = list(
  orientation = 'h',
  traceorder = 'reversed',
  font = list(
    family = "Arial",
    size = 15,
    color = "rgb(68, 68, 68)", 
    x = -0.07068607068607069, 
    y = -0.1)
) 


x <- list(
  autotick = FALSE,
  ticks = "outside",
  tick0 = 0,
  dtick = 6,
  ticklen = 5,
  tickwidth = 2,
  tickfont = smallf,
  tickcolor = toRGB("black"),
  title = "Age (Months)",
  titlefont = smallf
)

y <- list(
  title = "GMCPnPs 6B antibody (ug/ml)",
  titlefont = f
)
t <- list(
  title = "Antibody over Time",
  titlefont = f
)


df<-read.csv("noah_data.csv", header = TRUE, sep = ",", quote = "\"",
         dec = ".", fill = TRUE, comment.char = "")


#geometric mean function
attach(df)
df$ln_ab_conc <- logb(ab_conc)

    GMC <- ddply(df, ~month + ab + ever_infected, summarise, mean_ln_antibody = mean(ln_ab_conc, na.rm = T), 
                 sd_ln_antibody = sd(ln_ab_conc, na.rm = T))
    ##change this sd to se later##
    
    infected <- GMC[which(GMC$ever_infected  ==1 & GMC$ab =="pnps6b"), c (1:5)] 
    infected$geo_mean <- exp(infected$mean_ln_antibody)
    infected$lower <- exp((infected$mean_ln_antibody - (infected$sd_ln_antibody * 1.96) ))
    infected$upper <- exp((infected$mean_ln_antibody + (infected$sd_ln_antibody * 1.96) ))
    
    
    uninfected <- GMC[which(GMC$ever_infected ==0 & GMC$ab =="pnps6b"), c (1:5)] 
    uninfected$geo_mean <- exp(uninfected$mean_ln_antibody)
    uninfected$lower <- exp((uninfected$mean_ln_antibody - (uninfected$sd_ln_antibody * 1.96) ))
    uninfected$upper <- exp((uninfected$mean_ln_antibody + (uninfected$sd_ln_antibody * 1.96) ))
    
    
    p<-  plot_ly() %>%
        add_lines(x = infected$month, y = infected$geo_mean, 
                  color = I("black"), name = "Ever infected") %>%
        add_ribbons(x = infected$month, ymin = infected$lower, ymax = infected$upper,
                    line = list(color="transparent"), showlegend=T, name = "Ever infected 95% CI") %>%
        
        add_lines(x = uninfected$month, y = uninfected$geo_mean, 
                  color = I("black"), name = "Uninfected", type = "scatter", line = list(dash="dash") ) %>%
        add_ribbons(x = uninfected$month, ymin = uninfected$lower, ymax = uninfected$upper,
                    line = list(color="#A020F066"), showlegend=T,
                    name = "Uninfected 95% CI")%>%
        layout(xaxis = x, yaxis = y, title = "GMC of PnPs 6B antibody over months", titlefont = f,  legend = l, margin = m)
           
    p
    #plotly_POST(p, filename = "r-docs/test1")
    #y