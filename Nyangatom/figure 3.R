library(haven)
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/students/Nyangatom")
ds <- read_stata("Nyangatom_sampleAMY.DTA")
library(tidyverse)
library(survey)

ds.w <- svydesign(ids = ds$clustID, data = ds, weights = ds$sweight_child)
summary(ds.w)

table(ds$sweight_child)

nyg<-ggplot(ds,aes(height_cm,child_weight_kg, weight=sweight_child))
#dev.off()

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
library(ggplot2)
plot<-ggplot()+ 
  geom_ribbon(data = df2, aes(x = x, ymin = ymin, ymax = ymax),fill = "grey", alpha = 0.2)+
  geom_point(data =ds,mapping=aes(x=height_cm,y=child_weight_kg,size=sweight_child),alpha=.5)+
  facet_grid(.~sex_child)+
  geom_smooth(data =ds,aes(height_cm,child_weight_kg, weight=sweight_child),level=.95,size=1,formula=y~x,method="loess",alpha=.5) +
  geom_line(data =ds,aes(who_height,who_2sd),linetype=2 ,size=1,alpha=.9) +
  labs(title ="", x = "Height (cm)", y = "Weight (Kg)")+ 
  theme_classic(base_size = 12, base_family="Arial")+ theme(legend.position="bottom") + guides(color=guide_legend(override.aes=list(fill=NA)))

fig3<-plot+ 
  theme(legend.text	= element_text(colour = "black",size= 12, family="Arial"),
        strip.text = element_text(colour = "black",size= 12),
        strip.background = element_rect(colour = "white", fill = "white")
        )+
  scale_size("",range = c(1,3),breaks=c(16,22,23),labels=c("small","medium","large"))
fig3

tiff(file = "fig3_arial12.tiff", width = 6200, height = 3200, units = "px", res = 600)
fig3
dev.off()