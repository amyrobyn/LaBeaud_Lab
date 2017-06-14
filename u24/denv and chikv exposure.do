*************************************************************
 *amy krystosik                  							  *
 *u24 									  *
 *lebeaud lab               				        		  *
 *last updated april 26, 2017 									  *
 **************************************************************/ 

local output "C:\Users\amykr\Box Sync\U24 Project\data\"
cd "C:\Users\amykr\Box Sync\U24 Project\data"
capture log close 
log using "exposure.smcl", text replace 
set scrollbufsize 100000
set more 1

*use "C:\Users\amykr\Box Sync\DENV CHIKV project\outdated- see redcap for updated data\Lab Data\outdated- go to redcap database for updated data. do not enter data here\ELISA Database\ELISA Latest\elisa_merged", clear
/*insheet using "C:\Users\amykr\Box Sync\Amy Krystosik's Files\Data Managment\redcap\ro1 lab results long\R01_lab_results.csv", comma clear names

foreach var of varlist _all{
	capture replace `var' = "" if `var' =="NA"
	destring `var', replace
}
*/
*save r01, replace

use r01, clear
encode redcap_event_name, gen(visit)
encode person_id , gen(id)
xtset id visit 
by id: carryforward city, replace
collapse (sum) result_igg_denv_stfd result_igg_chikv_stfd, by(person_id city)
gen denvexposed = . 
gen chikvexposed = . 
bysort person_id : replace chikvexposed = 1 if result_igg_chikv_stfd > 0 & result_igg_chikv_stfd<. & result_igg_denv_stfd ==0
bysort person_id : replace chikvexposed = 0 if result_igg_chikv_stfd== 0 

bysort person_id: replace denvexposed  = 1 if result_igg_denv_stfd >0 & result_igg_denv_stfd<. & result_igg_chikv_stfd ==0
bysort person_id: replace denvexposed  = 0 if result_igg_denv_stfd ==0 

gen denv_chikv_exposed=.
bysort person_id: replace denv_chikv_exposed= 1 if result_igg_chikv_stfd >0 & result_igg_chikv_stfd<. & result_igg_denv_stfd >0 & result_igg_denv_stfd<.
bysort person_id: replace denv_chikv_exposed= 0 if result_igg_denv_stfd ==0 & result_igg_chikv_stfd==0
tab denv_chikv_exposed city


gen chikv_denv_unexposed=.
bysort person_id: replace chikv_denv_unexposed = 1 if chikvexposed ==0 & denvexposed==0
bysort person_id: replace chikv_denv_unexposed = 0 if result_igg_denv_stfd >=1 & result_igg_denv_stfd <. | result_igg_chikv_stfd>=1 & result_igg_chikv_stfd<.
tab chikv_denv_unexposed

tab chikvexposed city, m
tab denvexposed city, m

export excel using "`output'exposed", firstrow(variables) replace
outsheet person_id denvexposed city using "`output'denv_igg_msambweni.csv" if city ==3 & denvexposed==1 |city ==4 & denvexposed==1, replace comma names
outsheet person_id chikvexposed city using "`output'chikv_igg_msambweni.csv" if city ==3 & chikvexposed ==1|city ==4 & chikvexposed ==1,  replace comma names

ci denvexposed, bin
ci chikvexposed, bin
ci denv_chikv_exposed, bin
ci chikv_denv_unexposed, bin


gen exposed_group = .
replace exposed_group =1 if denvexposed==1 
replace exposed_group =2 if chikvexposed ==1 
replace exposed_group =3 if denv_chikv_exposed ==1 
replace exposed_group =0 if chikv_denv_unexposed==1

label variable exposed_group  "exposure categories"
label define exposed_group  0 "neither chikv nor denv" 1 "denv" 2 "chikv" 3 "both chikv and denv" , modify
label values exposed_group  exposed_group  exposed_group  exposed_group  
save exposed_group, replace

use r01, clear
tab redcap_event_name 
keep if redcap_event_name!="patient_informatio_arm_1"
encode redcap_event_name, gen(visit)
encode person_id , gen(id)
xtset id visit 

egen firstvisit = min(visit), by(id)
tab firstvisit 
keep if visit==firstvisit 
save first_visit, replace
use first_visit
merge 1:1 person_id using exposed_group  
tab _merge 
tab visit , m
keep person_id visit age phonenumber gps_lat gps_long gender dob *name name* interviewername city result_igg_denv_stfd result_igg_chikv_stfd denvexposed chikvexposed denv_chikv_exposed chikv_denv_unexposed site exposed_group

tab exposed_group
order exposed_group  
bysort city: tab exposed_group  

bysort exposed_group city: sum age, d 

outsheet using "C:\Users\amykr\Box Sync\U24 Project\data\particpants_$S_DATE.csv" if denvexposed==1 |chikvexposed ==1 | chikv_denv_unexposed ==1 |chikv_denv_unexposed==1, comma names replace
stop
*here we are just looking at exposed vs not exposed so there is one row for each person. match that to many pedsql visits. if we want to make it 1:1 we can look at prior exposure vs incidence.
merge 1:m id_wide using "C:\Users\amykr\Box Sync\Amy Krystosik's Files\pedsql\pedsql"
