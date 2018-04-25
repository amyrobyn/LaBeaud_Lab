library(ggplot2)
library(dplyr)
library(readr)

#brazil sinan data
# import data -------------------------------------------------------------
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/brazil hospital surveillance denv/SINAN")
#chikv <- read_csv("CHIKUNGUNYA 2013 A 2018.csv")
#yf <- read_csv("FEBRE AMARELA 2013 A2018 NOVO.csv")
#zikv <- read_csv("ZIKA 2013 A 2018 NOVO.csv")
denv <- read_csv("DENGUE 2013 A 2018 NOVO.csv")

# fix dates ---------------------------------------------------------------
table(is.na(denv$DT_NOTIFIC))
denv$date<-NA
denv$date <- ifelse(grepl("/", denv$DT_NOTIFIC), denv$DT_NOTIFIC, NA)
denv$date <- as.Date(denv$date, "%m/%d/%Y")
table(denv$date)

denv$date2<-NA
denv$date2 <- ifelse(!grepl("/", denv$DT_NOTIFIC), denv$DT_NOTIFIC, NA)
denv$date2 <- as.Date(denv$date2, "%Y%m%d")
table(denv$date2)

denv$date <- ifelse(is.na(denv$date), denv$date2, denv$date)
denv$date<-as.Date(denv$date,origin = "1970-01-01")
table(denv$date)
denv$year = as.numeric(format(denv$date, "%Y"))

table(is.na(denv$date))
table(is.na(denv$year))
table(is.na(denv$DT_NOTIFIC))

denv$CS_SEXO<-as.factor(denv$CS_SEXO)

cases_week_df<-as.data.frame(table(denv$date))
summary(cases_week_df)
cases_week_df$date<-as.Date(cases_week_df$Var1)
plot(cases_week_df$date, cases_week_df$Freq)

# cases over time by neighborhood -----------------------------------------
cases_week_df<-as.data.frame(table(denv$date,denv$ID_BAIRRO))
cases_week_df$date<-as.Date(cases_week_df$Var1)
cases_week_df$neighborhood<-as.factor(cases_week_df$Var2)

p<-ggplot(cases_week_df, aes (x = date, y = Freq, color=neighborhood)) +
    scale_x_date(date_breaks = "3 months", date_labels =  "%b %Y") +
    theme(axis.text.x=element_text(angle=60, hjust=1),text = element_text(size = 20))+
    xlab("Date of notification") + ylab("DENV Cases reported") +
    #geom_line(size=2) + 
    geom_bar(stat="identity", size =2) + 
    #facet_grid(neighborhood ~ ., scales = "free")+
    theme(strip.text.y = element_text(angle = 0))
    scaleFUN <- function(x) sprintf("%.0f", x)
    
  tiff("cases by neighborhood over time.tif", height = 18, width = 30, units = 'cm', compression = "lzw", res = 600)
      p + scale_y_continuous(labels=scaleFUN)
  dev.off()
# cases over neighorhood --------------------------------------------------
  
p2<-ggplot(cases_week_df, aes (x = neighborhood, y = Freq, color=date)) +
      #scale_x_date(date_breaks = "3 months", date_labels =  "%b %Y") +
      theme(axis.text.x=element_text(angle=60, hjust=1),text = element_text(size = 20))+
      xlab("Neighorhood") + ylab("DENV Cases reported") +
      #geom_line(size=2) + 
      geom_bar(stat="identity", size =2) + 
      #facet_grid(neighborhood ~ ., scales = "free")+
      theme(strip.text.y = element_text(angle = 0))
tiff("cases over neighborhood by year.tif", height = 18, width = 40, units = 'cm', compression = "lzw", res = 600)
  p2 + scale_y_continuous(labels=scaleFUN)
dev.off()
# cases over time by serology ---------------------------------------------
cases_week_df<-as.data.frame(table(denv$date, denv$RESUL_SORO))
summary(cases_week_df)
cases_week_df$date<-as.Date(cases_week_df$Var1)
cases_week_df$serology<-as.factor(cases_week_df$Var2)

p3<-ggplot(cases_week_df, aes (x = date, y = Freq, color=serology)) +
      scale_x_date(date_breaks = "3 months", date_labels =  "%b %Y") +
      theme(axis.text.x=element_text(angle=60, hjust=1),text = element_text(size = 20))+
      xlab("Date of notification") + ylab("DENV Cases reported") +
      #geom_line(size=2) + 
      geom_bar(stat="identity", size =2) + 
      #facet_grid(neighborhood ~ ., scales = "free")+
      theme(strip.text.y = element_text(angle = 0))
tiff("cases over time by serology.tif", height = 18, width = 40, units = 'cm', compression = "lzw", res = 600)
    p3 + scale_y_continuous(labels=scaleFUN)
dev.off()

# cases over time by Sex ---------------------------------------------
cases_week_df<-as.data.frame(table(denv$date,denv$CS_SEXO ))
cases_week_df$date<-as.Date(cases_week_df$Var1)
cases_week_df$sex<-as.factor(cases_week_df$Var2)
plot(cases_week_df$date, cases_week_df$Freq)

p4<-ggplot(cases_week_df, aes (x = date, y = Freq, color=sex)) +
      scale_x_date(date_breaks = "3 months", date_labels =  "%b %Y") +
      theme(axis.text.x=element_text(angle=60, hjust=1),text = element_text(size = 20))+
      xlab("Date of notification") + ylab("DENV Cases reported") +
      #geom_line(size=2) + 
      geom_bar(stat="identity", size =2,position='dodge') + 
      #facet_grid(neighborhood ~ ., scales = "free")+
      theme(strip.text.y = element_text(angle = 0))
tiff("cases over time by sex.Tif", height = 18, width = 40, units = 'cm', compression = "lzw", res = 600)
    p4 + scale_y_continuous(labels=scaleFUN)
dev.off()
    
# table one ------------------------------------------------
library(tableone)
vars<-colnames( denv )
factorVars <- vars
tableOne <- CreateTableOne(vars = vars, strata = "year", data = denv)
table1 <- print(tableOne, exact=vars, nonnormal=vars, quote = FALSE, noSpaces = TRUE, printToggle = FALSE)
write.csv(table1, file = "table1.csv")
