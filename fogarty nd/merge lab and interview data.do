set graphics on 
capture log close 
cd "C:\Users\amykr\Box Sync\Fogarty ND CHIKV study\REDCap\elisa"
log using "data_merge.smcl", text replace 
set scrollbufsize 100000
set more 1


*merge lab and interview data
insheet using "FogartyNDCHIKV_DATA_2017-06-07_1251.csv", clear
duplicates tag participant_id , gen(dup)
keep participant_id	redcap_event_name date
save records, replace

insheet using "exp 6.csv", clear comma
*drop if  sampleid == "41" |sampleid == "42" 	
*replace participant_id = "SG0062" if participant_id == "SG062" 
*replace participant_id = "SG0065" if participant_id == "SG065" 

	preserve
		keep if strpos(participant_id, "C1")
			replace participant_id = subinstr(participant_id, "C1", "", .) 
			foreach var in  sampleid rep1chikv isr reading testresult {
			rename `var' `var'_child
		}
		save elisa_child, replace
	restore

	drop if strpos(participant_id, "C1")
	drop if participant_id ==""
			foreach var in  sampleid rep1chikv isr reading testresult {
			rename `var' `var'_mother
		}

	save elisa_mother, replace

merge 1:1  participant_id using elisa_child
save elisa, replace

drop _merge

merge 1:m  participant_id using records
*drop those without lab results here. 
drop if _merge ==2
list participant_id  redcap_event_name if _merge ==1
gen clinic = substr(participant_id , 1, 2)

tab redcap_event_name clinic 
replace redcap_event_name = "child_1_arm_15" if clinic =="GA"
replace redcap_event_name = "child1_arm_3" if clinic =="GO"
replace redcap_event_name = "child1_arm_1" if clinic =="SG"
replace redcap_event_name = "child1_arm_2" if clinic =="GB"

list participant_id  redcap_event_name if _merge ==1

drop clinic
duplicates tag, gen(dup2)

order participant_id _merge
sort _merge

rename reading_mother result_mother	
gen lab_results_mother	=1 if  result_mother 	!=.
drop testresult_mother

rename reading_child result_child
gen lab_results_child = 1 if result_child  !=.
drop testresult_child

gen date_tested_child = "5/19/2017" if result_child  != .

gen date_tested_mother= "5/19/2017" if result_mother != .

gen date_collected_mother = date
gen date_collected_child = date

rename sampleid_mother elisa_lab_number_mother	
rename sampleid_child elisa_lab_number_child
rename rep1chikv_mother od_mother	
rename rep1chikv_child od_child

gen lab_tech_name_mother = 2 if result_mother != .
gen lab_tech_name_child = 2 if  result_child  !=.

gen mother_lab_results_complete	 = 1 if result_mother != .
gen child_lab_results_0c57_complete	 = 1 if  result_child  !=.

gen isr_mother_neg_control = 0.161702128 if  result_mother 	!=.
gen od_mother_neg_control = 0.057 if  result_mother 	!=.

gen isr_child_neg_control =  0.161702128 if result_child  != .
gen od_child_neg_control = 0.057 if result_child  != .

gen isr_mother_pos_control = 3.197163121 if  result_mother 	!=.
gen od_mother_pos_control = 1.127 if  result_mother 	!=.

gen isr_child_pos_control = 3.197163121 if result_child != .
gen od_child_pos_control = 1.127 if result_child != .


order participant_id redcap_event_name 
drop date dup dup2 _merge

outsheet using merged.csv, comma names replace
