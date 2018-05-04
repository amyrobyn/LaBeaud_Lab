library(haven)
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Nyangatom")
ds <- read_stata("Nyangatom_sampleAMY.DTA")
library(tidyverse)

nyg<-ggplot(ds,aes(height_cm,child_weight_kg))

nyg+geom_smooth(aes(height_cm,child_weight_kg),level=.95,size=2,formula=y~x,method="glm")+labs(title ="GLM", x = "Height (cm)", y = "Weight (Kg)") +  geom_point(aes(height_cm,child_weight_kg))
nyg+geom_smooth(aes(height_cm,child_weight_kg),level=.95,size=2,formula=y~x,method="loess")+labs(title ="Loess", x = "Height (cm)", y = "Weight (Kg)") +  geom_point(aes(height_cm,child_weight_kg))
nyg+geom_smooth(aes(height_cm,child_weight_kg),level=.95,size=2,formula=y~x,method="lm")+labs(title ="LM", x = "Height (cm)", y = "Weight (Kg)") +  geom_point(aes(height_cm,child_weight_kg))



ggplot(ds,aes(height_cm,child_weight_kg))+
  geom_point(aes(height_cm,child_weight_kg), size = 2, alpha = .5)+
  facet_grid(.~sex_child)+
  geom_smooth(aes(height_cm,child_weight_kg, colour = "black"),level=.95,size=2,formula=y~x,method="loess") +
  geom_line(aes(who_height,who_med, colour="blue"),size=2 ,alpha=.5,fill="blank") +
  geom_line(aes(who_height,ds$who_3sd, colour="red"),size=2,alpha=.5 ) +
  labs(title ="", x = "Height (cm)", y = "Weight (Kg)")+
  scale_color_discrete(name = "Y series", labels = c("Loess smoothed Regression \n 95% CI of Nyangatom Observations", "WHO Median", "WHO -3 SD"))+
  theme_classic(base_size = 30)+ theme(legend.position="bottom")

