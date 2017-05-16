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
library(dplyr)
library(zoo)


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
    x = 0, 
    y = -0.2)
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

t <- list(
  title = "Antibody over Time",
  titlefont = f
)


df<-read.csv("noah_data.csv", header = TRUE, sep = ",", quote = "\"",
         dec = ".", fill = TRUE, comment.char = "")
#loop over strata and ab
strata<-unique(df$strata)
ab<-unique(df$ab)

for (i in 1:length(strata)){
  for (j in 1:length(ab)){
    
    #keep if strata == "ever_any_sth" & ab == "dptcrm" & ab_!=. & strata_ !=.
        temp <- df[df$ab==ab[j] & df$strata==strata[i] & !is.na(df$strata_) & !is.na(df$ab_conc), ]
        
        #geometric mean function
        attach(temp)
        temp$ln_ab_conc <- logb(ab_conc)

        GMC <- ddply(temp, ~month + ab + strata + strata_,  summarise, n = n(), mean_ln_antibody = mean(ln_ab_conc, na.rm = T), 
                     se_ln_antibody = (sd(ln_ab_conc, na.rm = T)/sqrt(n())))
  
        y <- list(
          title = paste("GMC of ",ab[j], sep = ""),
          titlefont = f
        )

    infected <- GMC[which(GMC$strata_  ==1 ), ] 
    infected$geo_mean <- exp(infected$mean_ln_antibody)
    infected$lower <- exp((infected$mean_ln_antibody - (infected$se_ln_antibody * 1.96) ))
    infected$upper <- exp((infected$mean_ln_antibody + (infected$se_ln_antibody * 1.96) ))
    
    
    uninfected <- GMC[which(GMC$strata_ ==0 ), ] 
    uninfected$geo_mean <- exp(uninfected$mean_ln_antibody)
    uninfected$lower <- exp((uninfected$mean_ln_antibody - (uninfected$se_ln_antibody * 1.96) ))
    uninfected$upper <- exp((uninfected$mean_ln_antibody + (uninfected$se_ln_antibody * 1.96) ))
    
    p<-  plot_ly() %>%
        add_lines(x = infected$month, y = infected$geo_mean, 
                  color = I("black"), name = strata[i]) %>%
        add_ribbons(x = infected$month, ymin = infected$lower, ymax = infected$upper,
                    line = list(color="transparent"), showlegend=T, name = "Infected 95% CI") %>%
        
        add_lines(x = uninfected$month, y = uninfected$geo_mean, 
                  color = I("black"), name = "Uninfected", type = "scatter", line = list(dash="dash") ) %>%
        add_ribbons(x = uninfected$month, ymin = uninfected$lower, ymax = uninfected$upper,
                    line = list(color="#A020F066"), showlegend=T,
                    name = "Uninfected 95% CI")%>%
        layout(xaxis = x, yaxis = y, title = paste("Antibody GMC over time", sep = ""), titlefont = f,  legend = l, margin = m)

    api_create(p, filename = paste("r-docs/Noah AB Graphs/", ab[j], "_", strata[i], sep = ""))
    

      }
}
