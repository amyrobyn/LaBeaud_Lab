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

ds$sex_child <- factor(ds$sex_child, levels = c(1,2),labels = c("Male", "Female"))

#The instructions are: Arial, Times, or Symbol font only in 8-12 point
#install.packages("extrafont")
library("extrafont")
plot<-ggplot(ds,aes(height_cm,child_weight_kg))+
  geom_point(aes(height_cm,child_weight_kg,size=sweight_child), alpha = .5)+
  facet_grid(.~sex_child)+
  geom_smooth(aes(height_cm,child_weight_kg, colour = "black", weight=sweight_child),level=.95,size=2,formula=y~x,method="loess") +
  geom_line(aes(who_height,who_med, colour="blue"),size=2 ,alpha=.5) +
  geom_line(aes(who_height,who_2sd, colour="green"),size=2,alpha=.5 ) +
  geom_line(aes(who_height,who_3sd, colour="red"),size=2,alpha=.5 ) +
  labs(title ="", x = "Height (cm)", y = "Weight (Kg)")+ 
  scale_color_discrete(name = "", labels = c("Loess smoothed\n regression & 95% CI       ", "WHO\n Median       ", "WHO\n -2 SD       ","WHO\n -3 SD       "))+
  theme_classic(base_size = 12, base_family="Arial")+ theme(legend.position="bottom") + guides(color=guide_legend(override.aes=list(fill=NA)))

fig3<-plot+ theme(legend.text	= element_text(colour = "black",size= 12, family="Arial"),strip.text = element_text(colour = "black",size= 12))+ scale_size("",range = c(1,3),breaks=c(16,22,23),labels=c("15.1","21.9","23.5"))

tiff(file = "fig3_arial12.tiff", width = 6200, height = 3200, units = "px", res = 600)
fig3
dev.off()