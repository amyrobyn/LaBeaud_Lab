/********************************************************************************************
 *Author: Amy Krystosik			               							  					*
 *Function: format data for redcap upload													*
 *Org: LaBeaud Lab, Stanford School of Medicine, Pediatrics 			  					*
 *Last updated: april 17, 2017  									  						*
 *Notes: any data without unique id was dropped from this analysis 							*
 *******************************************************************************************/ 

capture log close 
set scrollbufsize 100000
set more 1
set scrollbufsize 100000
cd "C:\Users\amykr\Box Sync\Amy Krystosik's Files\Data Managment\redcap\ro1 lab results long"
log using "data import ex.smcl", text replace 
use "C:\Users\amykr\Box Sync\Amy Krystosik's Files\ASTMH 2017 abstracts\all linked and cleaned data\data\cleaned_merged_prevalence$S_DATE", clear
replace visit = lower(visit)

replace visit = id_visit if visit ==""

replace visit = "a" if visit_int ==1 & visit ==""

gen redcap_event_name_kenya = ""
replace redcap_event_name_kenya= "visit_a_arm_1" if visit == "a"
replace redcap_event_name_kenya= "visit_b_arm_1" if visit == "b"
replace redcap_event_name_kenya = "visit_c_arm_1" if visit == "c"
replace redcap_event_name_kenya = "visit_d_arm_1" if visit == "d"
replace redcap_event_name_kenya = "visit_e_arm_1" if visit == "e"
replace redcap_event_name_kenya = "visit_f_arm_1" if visit == "f"
replace redcap_event_name_kenya = "visit_g_arm_1" if visit == "g"
replace redcap_event_name_kenya = "visit_h_arm_1" if visit == "h"

gen redcap_event_name_stanford = ""
replace redcap_event_name_stanford= "visit_a_arm_2" if visit == "a"
replace redcap_event_name_stanford= "visit_b_arm_2" if visit == "b"
replace redcap_event_name_stanford = "visit_c_arm_2" if visit == "c"
replace redcap_event_name_stanford = "visit_d_arm_2" if visit == "d"
replace redcap_event_name_stanford = "visit_e_arm_2" if visit == "e"
replace redcap_event_name_stanford = "visit_f_arm_2" if visit == "f"
replace redcap_event_name_stanford = "visit_g_arm_2" if visit == "g"
replace redcap_event_name_stanford = "visit_h_arm_2" if visit == "h"

_strip_labels cohort

replace id_wide = upper(id_wide)

replace city = lower(city)
replace city = "1" if city =="chulaimbo"
replace city = "2" if city =="kisumu"
replace city = "3" if city  =="msambweni"
replace city = "4" if city  =="ukunda"
destring city, replace

rename id_childnumber child_number


drop if suffix!=""
replace cohort =. if visit != "a"
replace city = . if visit != "a"
replace house_number=. if visit != "a"
replace child_number =. if visit != "a"

*redcap_data_access_group
rename site redcap_data_access_group
rename followed participant_status  
gen patient_information_complete =.
gen name_tech_igg_denv =""
gen date_collected_igg_denv	= datesamplecollected_   
gen date_tested_igg_denv=.
gen antigen_used_igg_denv = .
gen other_antigen_igg_denv = antigenused_ 
gen aliquot_id_igg_denv = studyid

rename age age_calc 
rename childheight child_height
rename childweight child_weight
rename  phonenumber phone_number
rename childoccupation occupation 
rename educlevel kid_highest_level_education 
rename mom_educ mom_highest_level_education
replace numofsiblings = numsiblings if numofsiblings ==.
rename  numofsiblings  number_siblings
rename childtravel travel 
rename wheretravel where
rename nightaway stay_overnight
rename outdooractivity outdoor_activity 
rename timeoutdoors time_outdoors 
rename mosqbitefreq  mosquito_bite_frequency 
rename  avoidmosquitoes  avoid_mosquitoes
rename sleepbednet  mosquito_net 
rename mosquitobites mosquito_bites 
rename mosqbitedaytime mosquitoes_day
rename mosqbitenight mosquitoes_night
rename objectwater water_collection
rename fevertoday illness_today
rename numillnessfever number_illnesses
rename durationsymptom duration
rename  everhospitalised hospitalized_1
rename numhospitalized  number_hospitalizations_1
rename reasonhospita~1 reason_1 
rename datehospitali~1 when_1 
rename hospitalname1 where_1
rename durationhospi~1 duration_1 
preserve
	rename chikvigg_    result_igg_chikv	
	rename denvigg_  result_igg_denv 
	
	foreach var in date_of_birth age_calc gender child_height child_weight phone_number occupation kid_highest_level_education mom_highest_level_education number_siblings travel  stay_overnight outdoor_activity time_outdoors mosquito_bite_frequency avoid_mosquitoes {
	replace `var' = . if visit !="a" | `var' == 8 | `var' == 99
	}
	format dob %td
	replace date_of_birth = . if  id_wide =="KF184"
	replace date_of_birth = . if  id_wide =="KF159"
	replace date_of_birth = . if  id_wide =="KF160"
	replace date_of_birth = . if  id_wide =="KF161"

	replace where =""	if visit !="a"
	replace occupation =. if occupation ==99	
	keep  value_iggchikviggod_ value_iggdenviggod_ id_wide redcap_event_name_kenya city cohort house_number child_number result_igg_chikv	result_igg_denv malariapositive_dum denvpcrresults_dum  date_of_birth age_calc gender child_height child_weight phone_number occupation kid_highest_level_education mom_highest_level_education number_siblings travel where stay_overnight outdoor_activity time_outdoors mosquito_bite_frequency avoid_mosquitoes 
	*repellent mosquito_coil mosquito_net mosquito_bites mosquitoes_day mosquitoes_night water_collection illness_today number_illnesses  duration hospitalized_1 number_hospitalizations_1 reason_1 when_1 where_1 duration_1 
	order id_wide redcap_event_name_kenya city cohort house_number child_number result_igg_chikv result_igg_denv malariapositive_dum date_of_birth age_calc gender child_height child_weight phone_number occupation kid_highest_level_education mom_highest_level_education number_siblings travel where stay_overnight outdoor_activity time_outdoors mosquito_bite_frequency avoid_mosquitoes 
	*repellent mosquito_coil mosquito_net mosquito_bites mosquitoes_day mosquitoes_night water_collection illness_today number_illnesses  duration hospitalized_1 number_hospitalizations_1 reason_1 when_1 where_1 duration_1 
	rename id_wide studyid
	rename redcap_event_name_kenya redcap_event_name
	rename malariapositive_dum result_microscopy_malaria
	rename denvpcrresults_dum result_pcr_denv

	rename value_iggdenviggod_  value_igg_denv
	rename value_iggchikviggod_  value_igg_chikv
	
	outsheet using  "redcap_import_kenya.csv", comma names replace
restore

preserve
	rename stanfordchikvigg_ result_igg_chikv	
	rename stanforddenvigg_  result_igg_denv
	keep value_iggstanfordchikvod_ value_iggstanforddenvod_  id_wide redcap_event_name_stanford city cohort house_number child_number  result_igg_denv result_igg_chikv	
	order id_wide redcap_event_name_stanford city cohort house_number child_number  result_igg_denv result_igg_chikv 
	rename id_wide studyid
	rename redcap_event_name_stanford redcap_event_name
	rename value_iggstanforddenvod_   value_igg_denv
	rename value_iggstanfordchikvod_  value_igg_chikv
	outsheet using  "redcap_import_stanford.csv", comma names replace
restore

*order studyid	redcap_event_name*	redcap_data_access_group	cohort	city	house_number	child_number	participant_status	patient_information_complete	name_tech_igg_denv	date_tested_igg_denv	antigen_used_igg_denv	other_antigen_igg_denv	aliquot_id_igg_denv	date_collected_igg_denv	result_igg_denv	result_igg_chikv	result_pcr_denv	result_microscopy_malaria	species_microscopy_malaria___1	species_microscopy_malaria___2	species_microscopy_malaria___3	species_microscopy_malaria___4	species_microscopy_malaria___98	species_microscopy_malaria___99	species_microscopy_malaria_other	density_microscpy_pf	gametocytes_microscpy_pf	density_microscpy_pm	gametocytes_microscpy_pm	density_microscpy_po	gametocytes_microscpy_po	density_microscpy_pv	gametocytes_microscpy_pv	density_microscpy_other	gametocytes_microscpy_other	density_microscpy_ni	gametocytes_microscpy_ni	malaria_treatment___1	malaria_treatment___2	malaria_treatment___3	malaria_treatment___4	malaria_treatment___5	malaria_treatment___98	malaria_treatment_other	notes_microscopy_malaria	microscopy_malaria_complete	name_tech_pcr_chikv	date_tested_pcr_chikv	antigen_used_pcr_chikv	other_antigen_pcr_chikv	aliquot_id_pcr_chikv	date_collected_pcr_chikv	value_pcr_chikv	result_pcr_chikv	notes_pcr_chikv	pcr_chikv_complete	name_tech_rdt_denv	date_tested_rdt_denv	antigen_used_rdt_denv	other_antigen_rdt_denv	aliquot_id_rdt_denv	date_collected_rdt_denv	value_rdt_denv	result_rdt_denv	notes_rdt_denv	rdt_denv_complete	name_tech_igm_denv	date_tested_igm_denv	antigen_used_igm_denv	other_antigen_igm_denv	aliquot_id_igm_denv	date_collected_igm_denv	value_igm_denv	result_igm_denv	notes_igm_denv	igm_denv_complete	name_tech_igm_chikv	date_tested_igm_chikv	antigen_used_igm_chikv	other_antigen_igm_chikv	aliquot_id_igm_chikv	date_collected_igm_chikv	value_igm_chikv	result_igm_chikv	notes_igm_chikv	igm_chikv_complete	name_tech_rdt_malaria	date_tested_rdt_malaria	antigen_used_rdt_malaria	other_antigen_rdt_malaria	aliquot_id_rdt_malaria	date_collected_rdt_malaria	value_rdt_malaria	result_rdt_malaria	notes_rdt_malaria	rdt_malaria_complete	assay_other_other	name_tech_other	date_tested_other	antigen_used_other	other_antigen_other	aliquot_id_other	date_collected_other	value_other	result_other	notes_other	other_complete	full_id	start	end	today	deviceid	subscriberid	phonenumber	village	interviewer_name	interview_date	hcc_id	house_number_hcc	gps_lat gps_long	study_id	child_surname	child_first_name	child_second_name	child_third_name	child_fourth_name	date_of_birth	age_calc	gender	child_height	child_weight	phone_number	occupation	kid_highest_level_education	mom_highest_level_education	number_siblings	travel	where	stay_overnight	outdoor_activity	time_outdoors	mosquito_bite_frequency	avoid_mosquitoes repellent	mosquito_coil	mosquito_net	mosquito_bites	mosquitoes_day	mosquitoes_night	water_collection	type_water_collection___1	type_water_collection___2	type_water_collection___3	type_water_collection___4	type_water_collection___5	type_water_collection___6	type_water_collection___7	type_water_collection___8	type_water_collection___9	type_water_collection___10	type_water_collection___11	type_water_collection___12	illness_today	number_illnesses	symptoms___1	symptoms___2	symptoms___3	symptoms___4	symptoms___5	symptoms___6	symptoms___7	symptoms___8	symptoms___9	symptoms___10	symptoms___11	symptoms___12	symptoms___13	symptoms___14	symptoms___15	symptoms___16	symptoms___17	symptoms___18	symptoms___19	symptoms___20	symptoms___21	symptoms___22	symptoms___23	symptoms___24	symptoms___25	symptoms___26	symptoms___27	symptoms___28	symptoms___29	symptoms___30	symptoms___31	symptoms___32	symptoms___33	symptoms___34	symptoms___35	symptoms___	duration	hospitalized_1	number_hospitalizations_1	reason_1	when_1	where_1	duration_1	hospitalized_2	number_hospitalizations_2	reason_2	when_2	where_2	duration_2	hospitalized_3	number_hospitalizations_3	reason_3	when_3	where_3	duration_3	hospitalized_4	number_hospitalizations_4	reason_4	when_4	where_4	duration_4	hospitalized_5	number_hospitalizations_5	reason_5	when_5	where_5	duration_5	hcc_interview_initial_complete
