#install.packages("REDCapR")
library(REDCapR)
library(lubridate)
library(ggplot2)
library(plotly)
#setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long")

setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/zika study- grenada")

Redcap.token <- readLines("Redcap.token.zika.txt") # Read API token from folder
REDcap.URL  <- 'https://redcap.stanford.edu/api/'


#export data from redcap to R (must be connected via cisco VPN)
ds <- redcap_read(
  redcap_uri  = REDcap.URL,
  token       = Redcap.token
)$data

class(ds$delivery_date)
class(ds$pregnant)
ds$delivery_date <- ymd(as.character(ds$delivery_date ))
ds$delivery_date[ds$delivery_date=="2007-01-15"]<-"2017-01-15"
ds$prenancy_date<-ds$delivery_date - 280

duration <- 280
zika_start<- ymd(as.character("2016-06-12"))
zika_end <- ymd(as.character("2016-10-01"))

plot(ds$delivery_date)
plot(ds$pregnant)


# Sample client name
client = "Zika Pregnancy Cohort"

# Choose colors based on number of resources
cols <- RColorBrewer::brewer.pal(length(unique(ds$mother_record_id)), name = "Set3")
ds$color <- factor(ds$mother_record_id, labels = cols)

# Initialize empty plot
p <- plot_ly()
# Each task is a separate trace
# Each trace is essentially a thick line plot
# x-axis ticks are dates and handled automatically

for(i in 1:(nrow(ds) - 1)){
  p <- add_trace(p,
                 x = c(ds$prenancy_date[i], ds$prenancy_date[i] + duration[i]),  # x0, x1
                 y = c(i, i),  # y0, y1
                 mode = "lines",
                 line = list(color = ds$color[i], width = 20),
                 showlegend = F,
                 hoverinfo = "text",
                 
                 # Create custom hover text
                 
                 text = paste("Zika during Pregnancy: ", ds$pregnant[i], "<br>",
                              "Ever had Zika: ", ds$ever_had_zikv[i], "<br>",
                              "Lab confirmed: ", ds$confirmed_blood_test[i]),
                 
                 evaluate = T  # needed to avoid lazy loading
  )
}
zika_duration = zika_end - zika_start 
p <- add_trace(p,
               x = c(zika_start, zika_start + zika_duration),  # x0, x1
               mode = "lines",
               line = list(color = ds$color[i], width = 20),
               showlegend = F,
               hoverinfo = "text",
               
               # Create custom hover text
               evaluate = T  # needed to avoid lazy loading
)

p


f <- "REDCap_export_may10.csv"
write.csv(as.data.frame(ds), f )
