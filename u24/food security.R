setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/secure- u24 participants/data")
load("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long/R01_lab_results 2018-11-16 .rda")
food_insecurity_db<-R01_lab_results[which(R01_lab_results$redcap_event_name=="visit_u24_arm_1"& R01_lab_results$u24_participant==1) ,c("person_id","redcap_event_name","child_hungry","skip_meals","skip_meals_3_months","no_food_entire_day","rely_on_lowcost_food","balanced_meal","not_eat_enough","cut_meal_size")  ]
#For the food insecurity assessment questions 1-4 of the attached document, I would recommend using this scoring metric from the USDA: 
#Often true - 1 point /  Sometimes true - 1 point /  Never true - 0 points/   NA 
food_insecurity<-c("rely_on_lowcost_food","balanced_meal","not_eat_enough","cut_meal_size")
for(i in food_insecurity){
  food_insecurity_db[[i]][food_insecurity_db[[i]]==1] <-1
  food_insecurity_db[[i]][food_insecurity_db[[i]]==2] <-1
  food_insecurity_db[[i]][food_insecurity_db[[i]]==3] <-0
  food_insecurity_db[[i]][food_insecurity_db[[i]]==99] <-NA
}

#For questions 5-8, I would recommend using this metric:
#   Yes - 1 point /  No - 0 points /  DK or Refused - NA
food_insecurity2<-c("child_hungry","skip_meals","skip_meals_3_months","no_food_entire_day")
for(i in food_insecurity2){
  food_insecurity_db[[i]][food_insecurity_db[[i]]==1] <-1
  food_insecurity_db[[i]][food_insecurity_db[[i]]==0] <-0
  food_insecurity_db[[i]][food_insecurity_db[[i]]==99] <-NA
}

food_insecurity3<-c("child_hungry","skip_meals","skip_meals_3_months","no_food_entire_day","rely_on_lowcost_food","balanced_meal","not_eat_enough","cut_meal_size")
food_insecurity_db$food_insecurity<-rowSums(food_insecurity_db[food_insecurity3],na.rm=T)
table(food_insecurity_db$food_insecurity)

#The USDA defines food security as high or marginal, low, or very low:
#Raw score 0-1-High or marginal food security (raw score 1 may be considered marginal food security, 
#but a large proportion of households that would be measured as having marginal food security using the
#household or adult scale will have raw score zero on the six-item scale) / Raw score 2-4-Low food security / Raw score 5-6-Very low food security

#Since our assessment equates to an 8-point scale, I would recommend using the following scoring metric: 
#0-1: High or marginal food security/2-5: Low food security/6-8: Very low food security
food_insecurity_db$food_insecurity_cat<-cut(food_insecurity_db$food_insecurity,breaks=c(0,1,5,8))
table(food_insecurity_db$food_insecurity_cat)

save(food_insecurity_db,file = "food_insecurity_db.rda")
