library(haven)
library(plyr)
growth_long$sex<-revalue(growth_long$sex, c("f"="2", "m"="1"))
growth_long$height<-round(growth_long$length,2)
wfhanthro$who_height<-round(wfhanthro$height,2)

growth_long_z<-merge(growth_long,wfhanthro, by.x = c('sex','height'), by.y = c('sex','who_height'))#match to who standards based on sex and height.
#calculate who weights for z scores. https://www.cdc.gov/growthcharts/percentile_data_files.htm
growth_long_z$weight_neg2_z = growth_long_z$m*(1+growth_long_z$l*growth_long_z$s*-2)**(1/growth_long_z$l)
growth_long_z$weight_neg3_z = growth_long_z$m*(1+growth_long_z$l*growth_long_z$s*-3)**(1/growth_long_z$l)
growth_long_z$weight_2_z = growth_long_z$m*(1+growth_long_z$l*growth_long_z$s*2)**(1/growth_long_z$l)
growth_long_z$weight_3_z = growth_long_z$m*(1+growth_long_z$l*growth_long_z$s*3)**(1/growth_long_z$l)
growth_long_z$weight_0_z = growth_long_z$m*(1+growth_long_z$l*growth_long_z$s*0)**(1/growth_long_z$l)

library(tidyverse)

growth_chart<-ggplot(growth_long_z,aes(height,weight))

growth_chart+geom_smooth(aes(height,weight),level=.95,size=2,formula=y~x,method="glm")+labs(title ="GLM", x = "Height (cm)", y = "Weight (Kg)") +  geom_point(aes(height,weight))
growth_chart+geom_smooth(aes(height,weight),level=.95,size=2,formula=y~x,method="lm")+labs(title ="LM", x = "Height (cm)", y = "Weight (Kg)") +  geom_point(aes(height,weight))
growth_chart+geom_smooth(aes(height,weight),level=.95,size=2,formula=y~x,method="loess")+labs(title ="Loess", x = "Height (cm)", y = "Weight (Kg)") +  geom_point(aes(height,weight))

# fig 3 -------------------------------------------------------------------
growth_long_z$sex <- factor(growth_long_z$sex, levels = c(1,2),labels = c("MALE", "FEMALE"))

#The instructions are: Arial, Times, or Symbol font only in 8-12 point
#install.packages("extrafont")
library("extrafont")

# create plot object with loess regression lines
smoothed.ribbon.med.3sd<-ggplot(growth_long_z,aes(height,weight))+
  stat_smooth(aes(height,weight_neg3_z, colour="min"),size=2,alpha=.5, method = "loess", se = FALSE ) +
  stat_smooth(aes(height,weight_0_z, colour="max"),size=2 ,alpha=.5, method = "loess", se = FALSE) 
# build plot object for rendering 
gg1 <- ggplot_build(smoothed.ribbon.med.3sd)
# extract data for the loess lines from the 'data' slot
df2 <- data.frame(x = gg1$data[[1]]$x,
                  ymin = gg1$data[[1]]$y,
                  ymax = gg1$data[[2]]$y)

# use the loess data to add the 'ribbon' to plot 

library(ggplot2)
growthcurve<-ggplot()+ 
  geom_ribbon(data = df2, aes(x = x, ymin = ymin, ymax = ymax,fill = "grey"), alpha = 0.2)+
  geom_smooth(data =growth_long_z,aes(height,weight, color="Grenada Loess Regression & 95% CI", linetype="Grenada Loess Regression & 95% CI"),level=.95,size=1,formula=y~x,method="loess",alpha=.9) +
  geom_smooth(data =growth_long_z,aes(height,weight_neg2_z, color="WHO -2SD", linetype="WHO -2SD"),level=.95,size=1,formula=y~x,method="loess",alpha=.9, se=F) +
  geom_point(data =growth_long_z,mapping=aes(x=height,y=weight, shape=visit),alpha=.5,size=3)+
  #facet_grid(visit~zikv_exposed_mom)+
  facet_grid(.~zikv_exposed_mom)+
  labs(title ="", x = "Height (cm)", y = "Weight (Kg)")+ 
  theme_classic(base_size = 12, base_family="Arial")+ 
  theme(legend.position ="bottom") + 
  guides(color=guide_legend(override.aes=list(fill=NA)))+
  scale_color_manual(name = "", values = c("Grenada Loess Regression & 95% CI"="black","WHO -2SD" = "black"), labels = c("Grenada Loess Regression & 95% CI","WHO -2SD"))+
  scale_fill_identity(name = '', guide = FALSE,labels = c('grey'='WHO median to -3SD')) +
  scale_linetype_manual(name = "",values = c("Grenada Loess Regression & 95% CI"=1, "WHO -2SD" = 3))+
  scale_shape(name="Visit")+
  #scale_size("Sample Weights",range = c(1,3),breaks=c(16,22,23),labels=c("15.1","21.9","23.5"))+
  #scale_x_continuous(limits = c(70, 120))+
  theme(legend.text	= element_text(colour = "black",size= 12, family="Arial"),
        strip.text = element_text(colour = "black",size= 12),
        strip.background = element_rect(colour = "white", fill = "white")  )
growthcurve
# print to tiff -----------------------------------------------------------
tiff(file = "growth_curve_1_21.tiff", width = 6200, height = 3200, units = "px", res = 600)
  growthcurve
dev.off()
