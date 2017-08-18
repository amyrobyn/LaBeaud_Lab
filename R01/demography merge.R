setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long")
demo<-read.csv("R01CHIKVDENVProject_DATA_2017-08-17_1647_demo_merge.csv")
demo_wide<-reshape(demo, direction = "wide", idvar = "ï..person_id", timevar = "redcap_event_name", sep = "_")
demo_wide$gender_equal <- ifelse(demo_wide$gender_visit_a_arm_1 != demo_wide$dem_child_gender_patient_informatio_arm_1 | demo_wide$gender_visit_b_arm_1 != demo_wide$dem_child_gender_patient_informatio_arm_1  | demo_wide$gender_visit_c_arm_1 != demo_wide$dem_child_gender_patient_informatio_arm_1  | demo_wide$gender_visit_d_arm_1 != demo_wide$dem_child_gender_patient_informatio_arm_1  | demo_wide$gender_visit_e_arm_1 != demo_wide$dem_child_gender_patient_informatio_arm_1, 0, 1)
table(demo_wide$gender_equal)

demo_wide <-demo_wide[!sapply(demo_wide, function (x) all(is.na(x) | x == ""| x == "NA"))]

write.csv(as.data.frame(demo_wide), "demo_wide.csv")
