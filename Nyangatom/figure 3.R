library(haven)
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/students/Nyangatom")
ds_MI <- read_stata("Nyangatom_sampleAMY_MI.DTA")
ds <- read_stata("Nyangatom_sampleAMY.DTA")
library(tidyverse)
library(survey)

ds.w <- svydesign(ids = ds$clustID, data = ds, weights = ds$sweight_child)
summary(ds.w)

table(ds$sweight_child)

nyg<-ggplot(ds,aes(height_cm,child_weight_kg, weight=sweight_child))

nyg+geom_smooth(aes(height_cm,child_weight_kg),level=.95,size=2,formula=y~x,method="glm")+labs(title ="GLM", x = "Height (cm)", y = "Weight (Kg)") +  geom_point(aes(height_cm,child_weight_kg))
nyg+geom_smooth(aes(height_cm,child_weight_kg),level=.95,size=2,formula=y~x,method="loess")+labs(title ="Loess", x = "Height (cm)", y = "Weight (Kg)") +  geom_point(aes(height_cm,child_weight_kg))
nyg+geom_smooth(aes(height_cm,child_weight_kg),level=.95,size=2,formula=y~x,method="lm")+labs(title ="LM", x = "Height (cm)", y = "Weight (Kg)") +  geom_point(aes(height_cm,child_weight_kg))

# fig 3 -------------------------------------------------------------------
ds$sex_child <- factor(ds$sex_child, levels = c(1,2),labels = c("MALE", "FEMALE"))

#The instructions are: Arial, Times, or Symbol font only in 8-12 point
#install.packages("extrafont")
library("extrafont")

# create plot object with loess regression lines
smoothed.ribbon.med.3sd<-ggplot(ds,aes(height_cm,child_weight_kg))+
  stat_smooth(aes(who_height,who_3sd, colour="min"),size=2,alpha=.5, method = "loess", se = FALSE ) +
  stat_smooth(aes(who_height,who_med, colour="max"),size=2 ,alpha=.5, method = "loess", se = FALSE) 
# build plot object for rendering 
gg1 <- ggplot_build(smoothed.ribbon.med.3sd)
# extract data for the loess lines from the 'data' slot
df2 <- data.frame(x = gg1$data[[1]]$x,
                  ymin = gg1$data[[1]]$y,
                  ymax = gg1$data[[2]]$y)

# use the loess data to add the 'ribbon' to plot 

table(ds$sweight_child)
library(ggplot2)
fig3<-ggplot()+ 
  geom_ribbon(data = df2, aes(x = x, ymin = ymin, ymax = ymax,fill = "grey"), alpha = 0.2)+
  geom_smooth(data =ds,aes(height_cm,child_weight_kg, weight=sweight_child,color="Nyangatom 95%CI", linetype="Nyangatom 95%CI"),level=.95,size=1,formula=y~x,method="loess",alpha=.9) +
  geom_line(data =ds,aes(who_height,who_2sd,color="WHO -2SD", linetype="WHO -2SD"),size=1,alpha=.9) +
  geom_point(data =ds,mapping=aes(x=height_cm,y=child_weight_kg,size=sweight_child),alpha=.5,shape=1)+
  facet_grid(.~sex_child)+
  labs(title ="", x = "Height (cm)", y = "Weight (Kg)")+ 
  theme_classic(base_size = 12, base_family="Arial")+ theme(legend.position = c(0.1, 0.8)) + guides(color=guide_legend(override.aes=list(fill=NA)))+
  scale_color_manual(name = "", values = c("Nyangatom 95%CI"="black","WHO -2SD" = "black"), labels = c("Nyangatom 95%CI","WHO -2SD"))+
  scale_fill_identity(name = '', guide = FALSE,labels = c('grey'='WHO median to -3SD')) +
  scale_linetype_manual(name = "",values = c("Nyangatom 95%CI"=1, "WHO -2SD" = 2))+
  scale_size("Sample Weights",range = c(1,3),breaks=c(16,22,23),labels=c("15.1","21.9","23.5"))+
#  scale_x_continuous(limits = c(70, 120))+
  theme(legend.text	= element_text(colour = "black",size= 12, family="Arial"),
        strip.text = element_text(colour = "black",size= 12),
        strip.background = element_rect(colour = "white", fill = "white")  )
# print to tiff -----------------------------------------------------------
tiff(file = "C:/Users/amykr/Box Sync/Amy's Externally Shareable Files/fig 3/fig3_arial12_MI_95CI_legend7.tiff", width = 6200, height = 3200, units = "px", res = 600)
  fig3
dev.off()
