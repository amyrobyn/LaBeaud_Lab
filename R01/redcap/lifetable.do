*lifetable

insheet using "C:\Users\amykr\Box Sync\Amy Krystosik's Files\Data Managment\redcap\ro1 lab results long\redcap_backup.csv", clear names comma
gen time =""
replace time = "1" if redcap_event_name=="visit_a_arm_1"
replace time = "2" if redcap_event_name=="visit_b_arm_1"
replace time = "3" if redcap_event_name=="visit_c_arm_1"
replace time = "4" if redcap_event_name=="visit_d_arm_1"
replace time = "5" if redcap_event_name=="visit_e_arm_1"
destring time, replace
tab  redcap_event_name time , nolab

capture drop visit
gen visit = 0

stset time  ,  id(person_id) failure(visit==1)
stsum
stdescribe
sts list

ltable time,  id(person_id) failure(visit==1)

