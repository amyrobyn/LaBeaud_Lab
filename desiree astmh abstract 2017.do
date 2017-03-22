/********************************************************************
 *amy krystosik                  							  		*
 *ellyse astmh abstract 2017- apprent and innaparent denv and chikv	*
 *lebeaud lab               				        		  		*
 *last updated march 14, 2017  							  			*
 ********************************************************************/ 
capture log close 
set more 1
set scrollbufsize 100000
log using "des_tropmed2017.smcl", text replace 
cd "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\desiree- abstract1\data"
local figures "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\desiree- abstract1\figures\"
local data "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\desiree- abstract1\data\"
global data "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\desiree- abstract1\data\"

use "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\all linked and cleaned data\data\cleaned_merged_prevalence", clear

/**Of 3,026 paired acute and convalescent serum samples by ELISA, 8 seroconverted for CHIKV (0.9916% , 95% CI 0.9833 - 0.9958) and 6 for DENV (0.9938 , 95% CI 0.9863   - 0.9972)*/
**gen incident data based on igg and pcr results. 

gen inc_denv= 0 if denvpcrresults_dum==0 |stanforddenvigg_==0
replace inc_denv= 1 if denvpcrresults_dum==1 |stanforddenvigg_==1

gen inc_chikv= 0 if chikvpcrresults_dum ==0 | stanfordchikvigg_==0
replace inc_chikv = 1 if chikvpcrresults_dum ==1 | stanfordchikvigg_==1

save temp, replace


******************************************************************************************************************************************
*find the minimum visit that is tested.

preserve 
		keep if stanforddenvigg_ !=. 
		bysort id_wide: egen minvisit_igg = min(visit_int)
		save minvisit_igg, replace 
restore
		merge m:m id_wide using minvisit_igg
	*keep incident cases
	bysort id_wide: gen initial_stanforddenvigg_neg =1 if stanforddenvigg_ == 0 & visit_int == minvisit_igg
	bysort id_wide : carryforward initial_stanforddenvigg_neg, replace
	keep if initial_stanforddenvigg_neg ==1 | denvpcrresults_dum==1 
save inc_denv, replace

use temp, clear
	preserve 
		keep if stanfordchikvigg_ !=. 
		bysort id_wide: egen minvisit_igg = min(visit_int)
		save minvisit_igg, replace 
	restore
		merge m:m id_wide using minvisit_igg
	*keep incident cases
	bysort id_wide: gen initial_stanfordchikvigg_neg =1 if stanfordchikvigg_ == 0 & visit_int == minvisit_igg
	bysort id_wide : carryforward initial_stanfordchikvigg_neg, replace
	keep if initial_stanfordchikvigg_neg ==1 | chikvpcrresults_dum==1 
save inc_chikv, replace

foreach outcome in  inc_chikv inc_denv {
use `outcome', clear

*convert visit to time in months
gen time = . 
replace time = visit_int*1 if cohort ==1

replace time = 1 if visit_int ==1 & cohort ==2 
replace time = 6 if visit_int ==2 & cohort ==2 
replace time = 12 if visit_int ==3 & cohort ==2 

bysort cohort: tab time visit_int
tab time, m
tab time `outcome', m
tab `outcome'
tab cohort visit_int , m nolab
 _strip_labels visit_int

stset time, failure(`outcome') id(id_wide) 

sts list
sts list, by(cohort)
sts list, by(site cohort)


**/Active disease from CHIKV and DENV were associated with SES, gender, X and Y. */
preserve
keep if cohort ==1
	table1,	vars(ses_index_sum conts \ gender bin \ site cat \ age contn \ city cat \ mosquito_exposure_index contn \ mosq_prevention_index contn\) by(`outcome') missing test saving("`figures'aic_`outcome'_$S_DATE.xls", replace)
*table1 , vars(splenomegaly  bin\ age contn \ gender bin\city cat \  zsystolicbp conts \ zdiastolicbp conts \ zpulseoximetry conts \ ztemperature conts \ zresprate conts \ hb conts \  all_symptoms_altms bin\  all_symptoms_jaundice cat\  all_symptoms_bleeding_symptom bin\  all_symptoms_imp_mental cat\  all_symptoms_mucosal_bleed_brs bin\  all_symptoms_bloody_nose cat\  all_symptoms_fever bin\  scleralicterus bin\ systolicbp70 bin\) by(stanforddenvigg_) saving("`tables'seroconverters1'outcome_$S_DATE.xls", replace ) missing test
*table1, vars(parasite_count  conts \ zbmiukwho conts \ zhtukwho conts \  zwtukwho conts \  zhcaukwho conts \  mom_educ cat \ age contn \ gender bin \ city cat \ site cat \ urban cat \ wealthindex contn \ ses_index_sum  contn  \ hygieneindex contn \ sesindeximprovedfloor_index cat \sesindeximprovedwater_index cat \sesindeximprovedlight_index cat \sesindextelephone cat \sesindexradio cat \sesindextelevision cat \sesindexbicycle cat \sesindexmotorizedvehicle cat \sesindexdomesticworker cat \sesindexownflushtoilet cat \ pastmedhist_dum cat \ hivmeds cat \ pmhother_resp cat \ pmhsickle_cell  cat \ pmhpneumonia cat \ pmhintestinal_worms cat \ pmhmalaria cat \ pmhdiarrhea cat \ pmhdiabetes cat \ pmhseizure_disorder  cat \ pmhhiv cat \ pmhmeningitis  cat \ pmhtuberculosis cat \ pmhcardio_illness cat \ pmhasthma cat \ mosq_prevention_index contn \ mosquito_exposure_index contn \ childvillage cat \ ) by(stanforddenvigg_) saving("`tables'`outcome'$S_DATE.xls", replace ) missing test
restore

preserve
keep if cohort ==2
*	table1,	vars(ses_index_sum conts \ gender bin \ site cat \ age contn \ city cat \ mosquito_exposure_index contn \ mosq_prevention_index contn\) by(`outcome') missing test save(hcc_incident.xls)
restore

}
