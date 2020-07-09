recent_rainfall_Chulaimbo<-read.csv("C:/Users/amykr/Box Sync/Amy Krystosik's Files/students/cameron/thesis/recent_rainfall_Chulaimbo.csv")
bgChulaimbo<-read.csv("C:/Users/amykr/Box Sync/Amy Krystosik's Files/students/cameron/thesis/bgChulaimbo.csv")
mydata<-read.csv("C:/Users/amykr/Box Sync/Amy Krystosik's Files/students/cameron/thesis/mydata.csv")
library(ggplot2)

lineplot<-ggplot() + 
  geom_line(recent_rainfall_Chulaimbo, mapping=aes(x = as.Date(as.character(recent_rainfall_Chulaimbo$Date, "%Y-%m-$d")), 
                                                   y = recent_rainfall_Chulaimbo$rainfall_anomaly), color = "blue") + 
  geom_line(bgChulaimbo, mapping = aes(x = as.Date(as.character(bgChulaimbo$Date), "%m/%d/%y"), 
                                       y = bgChulaimbo$aedes_total_bg), color="red")+
  scale_y_continuous(sec.axis = sec_axis(~ . *1/15 + 10, name = "# of BG Aedes Aegypti"))+
  labs(x = 'Date', y = 'Rainfall Anamolies (cm)', title = 'Your Title')
lineplot

lineplot_transformed<-ggplot() + 
  geom_line(recent_rainfall_Chulaimbo, mapping=aes(x = as.Date(as.character(recent_rainfall_Chulaimbo$Date, "%Y-%m-$d")), 
                                                   y = recent_rainfall_Chulaimbo$rainfall_anomaly), color = "blue") + 
  geom_line(bgChulaimbo, mapping = aes(x = as.Date(as.character(bgChulaimbo$Date), "%m/%d/%y"), 
                                       y = bgChulaimbo$aedes_total_bg*15-10), color="red")+
  scale_y_continuous(sec.axis = sec_axis(~ . *1/15 + 10, name = "# of BG Aedes Aegypti"))+
  labs(x = 'Date', y = 'Rainfall Anamolies (cm)', title = 'Transformed')
lineplot_transformed


mydata$Date <- as.Date(paste0(as.character(mydata$Year.Month), "-01"), "%Y-%m-%d")

rainfall_all_vectors_plot_transformed <- ggplot(mydata) +
  geom_bar(aes(mydata$Date, mydata$rainfall_anomaly), stat = "identity") +
  scale_x_date(date_breaks = "1 year") +
  geom_line(mydata, mapping=aes(x=mydata$Date, y=mydata$aedes_proko*3-45), color = "blue") +
  geom_line(mydata, mapping=aes(x=mydata$Date, y=mydata$aedes_bg*3-45), color = "green") +
  geom_line(mydata, mapping=aes(x=mydata$Date, y=mydata$aedes_ovi*3-45), color = "red") +
  geom_line(mydata, mapping=aes(x=mydata$Date, y=mydata$pupae_total*3-45), color = "yellow") +
  scale_y_continuous(sec.axis = sec_axis(~ . *1/3+45, name = "# of Aedes Aegypti")) +
  facet_wrap(mydata$Site)+ theme_bw() + labs(x = "Date", y = "Rainfall Anomalies (mm)",
                                             title = "Rainfall Anomalies vs Vector Abundance by Trapping Method (transformed)")
rainfall_all_vectors_plot_transformed


rainfall_all_vectors_plot_transformed2 <- ggplot(mydata) +
  geom_bar(aes(mydata$Date, mydata$rainfall_anomaly), stat = "identity") +
  scale_x_date(date_breaks = "1 year") +
  geom_line(mydata, mapping=aes(x=mydata$Date, y=mydata$pupae_total-400), color = "yellow") +
  scale_y_continuous(
    sec.axis = sec_axis(~ .+400,  name = "# of Aedes Aegypti")
    ) +
  #facet_wrap(mydata$Site)+ theme_bw() + 
  labs(x = "Date", y = "Rainfall Anomalies (mm)", title = "Rainfall Anomalies vs Vector Abundance by Trapping Method (transformed)")

rainfall_all_vectors_plot_transformed2

rainfall_all_vectors_plot3


rainfall_all_vectors_plot <- ggplot(mydata) +
  geom_bar(aes(mydata$Date, mydata$rainfall_anomaly), stat = "identity") +
  scale_x_date(date_breaks = "1 year") +
  geom_line(mydata, mapping=aes(x=mydata$Date, y=mydata$aedes_proko), color = "blue") +
  geom_line(mydata, mapping=aes(x=mydata$Date, y=mydata$aedes_bg), color = "green") +
  geom_line(mydata, mapping=aes(x=mydata$Date, y=mydata$aedes_ovi), color = "red") +
  geom_line(mydata, mapping=aes(x=mydata$Date, y=mydata$pupae_total), color = "yellow") +
  scale_y_continuous(sec.axis = sec_axis(~ ., name = "# of Aedes Aegypti")) +
  facet_wrap(mydata$Site)+ theme_bw() + labs(x = "Date", y = "Rainfall Anomalies (mm)",
                                             title = "Rainfall Anomalies vs Vector Abundance by Trapping Method")
rainfall_all_vectors_plot


rainfall_all_vectors_plot2 <- ggplot(mydata) +
  geom_bar(aes(mydata$Date, mydata$rainfall_anomaly), stat = "identity") +
  scale_x_date(date_breaks = "1 year") +
  geom_line(mydata, mapping=aes(x=mydata$Date, y=mydata$pupae_total), color = "yellow") +
  scale_y_continuous(sec.axis = sec_axis(~ ., name = "# of Aedes Aegypti")) +
  facet_wrap(mydata$Site)+ theme_bw() + labs(x = "Date", y = "Rainfall Anomalies (mm)",
                                             title = "Rainfall Anomalies vs Vector Abundance by Trapping Method")
rainfall_all_vectors_plot2


rainfall_all_vectors_plot3 <- ggplot(mydata) +
  geom_bar(aes(mydata$Date, mydata$rainfall_anomaly), stat = "identity") +
  scale_x_date(date_breaks = "1 year") +
  geom_line(mydata, mapping=aes(x=mydata$Date, y=mydata$pupae_total), color = "yellow") +
  scale_y_continuous(sec.axis = sec_axis(~ ., name = "# of Aedes Aegypti")) +
  #facet_wrap(mydata$Site)+ theme_bw() + 
  labs(x = "Date", y = "Rainfall Anomalies (mm)",
                                             title = "Rainfall Anomalies vs Vector Abundance by Trapping Method")
rainfall_all_vectors_plot3
