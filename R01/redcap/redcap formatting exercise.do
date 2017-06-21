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
use "C:\Users\amykr\Box Sync\Amy Krystosik's Files\ASTMH 2017 abstracts\all linked and cleaned data\data\cleaned_merged_prevalence28 Apr 2017", clear

gen aliquot_id = studyid 

replace visit = lower(visit)
replace visit = id_visit if visit ==""
replace visit = "a" if visit_int ==1 & visit ==""

encode visit, gen(redcap_repeat_instance) 
replace id_wide = upper(id_wide)

replace city = lower(city)
replace city = "1" if city =="chulaimbo"
replace city = "2" if city =="kisumu"
replace city = "3" if city  =="msambweni"
replace city = "4" if city  =="ukunda"
destring city, replace

rename id_childnumber child_number

drop if suffix!=""

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

	rename chikvigg_ result_igg_chikv_kenya	
	rename denvigg_ result_igg_denv_kenya
	
	foreach var in date_of_birth age_calc gender child_height child_weight phone_number occupation kid_highest_level_education mom_highest_level_education number_siblings travel  stay_overnight outdoor_activity time_outdoors mosquito_bite_frequency avoid_mosquitoes {
	replace `var' = . if visit !="a" | `var' == 8 | `var' == 99
	}
	format dob %td
	replace date_of_birth = . if  id_wide =="KF184"
	replace date_of_birth = . if  id_wide =="KF159"
	replace date_of_birth = . if  id_wide =="KF160"
	replace date_of_birth = . if  id_wide =="KF161"

	replace where ="" if visit !="a"
	replace occupation =. if occupation ==99
	
	gen date_collected_igg_denv_stfd = date_collected_igg_denv
	rename date_collected_igg_denv date_collected_igg_denv_kenya
	drop visittype 
	gen visittype = acute if acute ==1 | acute == 2 
	keep visittype  date_collected_igg_denv*  aliquot_id  stanfordchikvigg_  stanforddenvigg_  value_*  id_wide redcap_repeat_instance city cohort house_number child_number result_igg_chikv	result_igg_denv malariapositive_dum denvpcrresults_dum  date_of_birth age_calc gender child_height child_weight phone_number occupation kid_highest_level_education mom_highest_level_education number_siblings travel where stay_overnight outdoor_activity time_outdoors mosquito_bite_frequency avoid_mosquitoes 
	*repellent mosquito_coil mosquito_net mosquito_bites mosquitoes_day mosquitoes_night water_collection illness_today number_illnesses  duration hospitalized_1 number_hospitalizations_1 reason_1 when_1 where_1 duration_1 
	order id_wide redcap_repeat_instance city cohort house_number child_number result_igg_chikv result_igg_denv malariapositive_dum date_of_birth age_calc gender child_height child_weight phone_number occupation kid_highest_level_education mom_highest_level_education number_siblings travel where stay_overnight outdoor_activity time_outdoors mosquito_bite_frequency avoid_mosquitoes 
	*repellent mosquito_coil mosquito_net mosquito_bites mosquitoes_day mosquitoes_night water_collection illness_today number_illnesses  duration hospitalized_1 number_hospitalizations_1 reason_1 when_1 where_1 duration_1 
	rename id_wide person_id
	
	rename malariapositive_dum result_microscopy_malaria_kenya
	rename denvpcrresults_dum result_pcr_denv_kenya

	rename value_iggdenviggod_  value_igg_denv_kenya
	rename value_iggchikviggod_  value_igg_chikv_kenya
	
	rename stanfordchikvigg_ result_igg_chikv_stfd	
	rename stanforddenvigg_  result_igg_denv_stfd
	rename value_iggstanforddenvod_ value_igg_denv_stfd
	rename value_iggstanfordchikvod_ value_igg_chikv_stfd
	rename date_of_birth dob
	rename age_calc calculated_age
	rename occupation child_occupation
	rename kid_highest_level_education educ_level 
	rename mom_highest_level_education mum_educ_level
	rename travel child_travel
	rename where where_travel
	rename stay_overnight night_away 
	replace  mum_educ_level = . if  mum_educ_level ==0


	_strip_labels cohort
 tab redcap_repeat_instance
	isid redcap_repeat_instance person_id

*microscopy_malaria_kenya 
foreach assay in igg_denv_stfd  igg_chikv_kenya igg_denv_kenya igg_chikv_stfd pcr_denv_kenya{
	gen aliquot_id_`assay' = upper(aliquot_id) if result_`assay' !=.
}

drop aliquot_id calculated_age
replace aliquot_id_igg_denv_kenya = "UC20130213" if person_id =="UC20130213"
replace aliquot_id_igg_denv_stfd = "UC20956603" if person_id =="UC20956603"
replace aliquot_id_igg_chikv_stfd = "UC20956603" if person_id =="UC20956603"

format date_collected* %td
drop date_collected*
	
preserve
	gen redcap_event_name ="visit_arm_1"
	keep if cohort ==2
	gen follow_up_visit_num = redcap_repeat_instance
save temp, replace
foreach visit in 1 2 3 4 5 6 7 8 {
	use temp, clear
	_strip_labels redcap_repeat_instance 
		keep if redcap_repeat_instance ==`visit'
		tab redcap_repeat_instance
		order person_id redcap_event_name  redcap_repeat_instance   
		drop cohort city house_number child_number 
		outsheet using  "redcap_import_HCC_`visit'_$S_DATE.csv", comma names replace
	}

restore

preserve
		gen redcap_event_name ="patient_informatio_arm_1"
		gen follow_up_visit_num = redcap_repeat_instance
		keep if cohort ==2
		keep person_id redcap_event_name redcap_repeat_instance	cohort	city house_number	child_number	
		tab redcap_repeat_instance
		order person_id redcap_event_name  redcap_repeat_instance   
		outsheet using  "redcap_import_HCC_patient_info_$S_DATE.csv", comma names replace
restore

preserve
	gen redcap_event_name ="visit_arm_1"
	_strip_labels redcap_repeat_instance 
	keep if cohort ==1
	keep person_id redcap_event_name  redcap_repeat_instance visittype  result*  value_*  aliquot_id*  
	outsheet using  "redcap_import_AIC_$S_DATE.csv", comma names replace
restore

preserve
	gen redcap_event_name = "patient_informatio_arm_1"
	keep if cohort ==1
	keep person_id	redcap_event_name	redcap_repeat_instance	cohort	city	house_number	child_number	
	order person_id redcap_event_name  redcap_repeat_instance   
	outsheet using  "redcap_import_AIC_patient_info_$S_DATE.csv", comma names replace
restore

   
