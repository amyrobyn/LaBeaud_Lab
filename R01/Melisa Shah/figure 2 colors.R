load("C:/Users/amykr/Box Sync/Amy Krystosik's Files/students/melisa/malaria_climate.rda")
library(ggplot2)
climate<-malaria_climate
malaria_climate$date_collected<-malaria_climate$interview_date_aic_A
figure2<-malaria_climate
figure2$site<-figure2$id_site_A 

    figure2plot<- ggplot (figure2, aes (x = date_collected, y = meanTemp, colour = factor(site))) +
    geom_line(linetype = "solid",size=0.5) +
    scale_x_date(date_breaks = "1 year", date_labels =  "%Y", 
                 date_minor_breaks = "1 month", limits = as.Date(c('2014-01-06','2018-08-27'))) +
    theme(axis.text.x=element_text(angle=90, hjust=1),legend.position="none",text = element_text(size = 20)) + 
    facet_grid(site ~ .)+xlab("Year") + ylab(expression(paste("Daily Mean Temperature (",degree,"C)"))) 
  
  figure2plot
  colors <- c("Chulaimbo" = "mediumslateblue", "Kisumu" = "mediumturquoise", "Msambweni" = "mediumvioletred", "Ukunda" = "lightsalmon2")
  figure2plot + scale_colour_manual(values=colors)

