/********************************************************************
 *amy krystosik                  							  		*
 *ellyse astmh abstract 2017- apprent and innaparent denv and chikv	*
 *lebeaud lab               				        		  		*
 *last updated march 14, 2017  							  			*
 ********************************************************************/ 
capture log close 
set more 1
set scrollbufsize 100000
log using "des_tropmed2017_no_pcr.smcl", text replace 
cd "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\desiree- abstract1\data"
local figures "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\desiree- abstract1\figures\"
local data "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\desiree- abstract1\data\"
global data "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\desiree- abstract1\data\"

use "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\all linked and cleaned data\data\cleaned_merged_prevalence", clear

**gen incident data based on igg and pcr results. 
gen inc_denv= 0 if stanforddenvigg_==0
replace inc_denv= 1 if stanforddenvigg_==1

gen inc_chikv= 0 if stanfordchikvigg_==0
replace inc_chikv = 1 if stanfordchikvigg_==1

save temp, replace
******************************************************************************************************************************************
*find the minimum visit that is tested.
*denv
preserve 
		keep if stanforddenvigg_ !=. 
		sort id_wide visit, stable 
egen minvisit_igg = min(visit_int), by(id_wide)
		save minvisit_igg, replace 
restore
 
merge m:m id_wide using minvisit_igg
	*keep incident cases
	bysort id_wide: gen initial_stanforddenvigg_neg =1 if stanforddenvigg_ == 0 & visit_int == minvisit_igg
	egen max_initial_igg  = max(initial_stanforddenvigg_neg), by(id_wide)
	drop initial_stanforddenvigg_neg
	rename max_initial_igg   initial_stanforddenvigg_neg
	
	keep if initial_stanforddenvigg_neg ==1
	order inc_denv inc_chikv minvisit_igg
	sum inc_denv inc_chikv minvisit_igg
 
save inc_denv, replace

*chikv
use temp, clear
	preserve 
		keep if stanfordchikvigg_ !=. 
		bysort id_wide: egen minvisit_igg = min(visit_int)
		save minvisit_igg, replace 
	restore
		merge m:m id_wide using minvisit_igg
	*keep incident cases
	bysort id_wide: gen initial_stanfordchikvigg_neg =1 if stanfordchikvigg_ == 0 & visit_int == minvisit_igg
	egen max_initial_igg = max(initial_stanfordchikvigg_neg), by(id_wide)
	drop initial_stanfordchikvigg_neg
	rename max_initial_igg   initial_stanfordchikvigg_neg

	keep if initial_stanfordchikvigg_neg ==1 
sum inc_denv inc_chikv minvisit_igg
save inc_chikv, replace

foreach outcome in  inc_chikv  inc_denv  {
use `outcome', clear

*convert visit to time in months
gen time = . 
replace time = visit_int*1 if cohort ==1

replace time = 1 if visit_int ==1 & cohort ==2 
replace time = 6 if visit_int ==2 & cohort ==2 
replace time = 12 if visit_int ==3 & cohort ==2 

stset time, failure(`outcome') id(id_wide) 

sts list
sts list, by(cohort) 
sts list, by(site cohort) 
sts list, by(site) 
sts list, by(urban) 
sts list, by(city) 

**/INCIDENT ACTIVE disease from CHIKV and DENV were associated with SES, gender, X and Y. */
preserve
		keep if cohort ==1
			table1,	vars(season cat \cohort cat \  urban bin\ ses_index_sum conts \ gender bin \ site cat \ age conts \ city cat \ mosquito_exposure_index contn \ mosq_prevention_index contn\ \  ses_index_sum  conts \ hygieneindex conts \ wealthindex conts \ ses_index_sum_pct  cat) by(`outcome') missing test saving("`figures'INCIDENCE_$S_DATE.xls", sheet("AIC_`outcome'_NO_PCR") sheetreplace) 
restore

preserve
	keep if cohort ==2
		table1,	vars(season cat \cohort cate \ gender bine \ age conts \ city cate \ mosquito_exposure_index conts \ mosq_prevention_index conts\ hccses_index_sum_pct cate \ hccses_index_sum conts\) by(`outcome') missing test saving("`figures'INCIDENCE_$S_DATE.xls", sheet("HCC_`outcome'_NO_PCR") sheetreplace)  
restore
}

***************************************************end incidence ******************************************************************


***************************************************start Prevalence******************************************************************

use "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\all linked and cleaned data\data\cleaned_merged_prevalence", clear
**gen prevalence data based on igg only . 
encode id_wide, gen(id)
stset id visit_int

**denv prevalence**
		stgen no_denv = always(stanforddenvigg_==0)
		stgen when_denv = when(stanforddenvigg_==1)
		stgen prev_denv = ever(stanforddenvigg_==1)

		tab prev_denv 
		tab no_denv 

		gen denv_prev = .
		replace denv_prev = 1 if prev_denv ==1
		replace denv_prev = 0 if no_denv ==1
		tab denv_prev 
		keep if denv_prev !=.
		tab prev_denv 

**chikv prevalence**
		stgen no_chikv = always(stanfordchikvigg_==0)
		stgen when_chikv = when(stanfordchikvigg_==1)
		stgen prev_chikv  = ever(stanfordchikvigg_==1)

		tab prev_chikv 
		tab no_chikv  

		gen chikv_prev = .
		replace chikv_prev = 1 if prev_chikv ==1
		replace chikv_prev = 0 if no_chikv ==1
		tab chikv_prev 
		keep if chikv_prev !=.
		tab prev_chikv 


preserve
keep if cohort ==1
			table1,	vars(season cat \cohort cat \  urban bin\ ses_index_sum conts \ gender bin \ site cat \ age conts \ city cat \ mosquito_exposure_index contn \ mosq_prevention_index contn\ \  ses_index_sum  conts \ hygieneindex conts \ wealthindex conts \ ses_index_sum_pct  cat) by(prev_chikv) missing test saving("`figures'PREVALENCE_$S_DATE.xls", sheet("AIC_PREV_CHIKV_NO_PCR") sheetreplace) 
			table1,	vars(season cat \cohort cat \  urban bin\ ses_index_sum conts \ gender bin \ site cat \ age conts \ city cat \ mosquito_exposure_index contn \ mosq_prevention_index contn\ \  ses_index_sum  conts \ hygieneindex conts \ wealthindex conts \ ses_index_sum_pct  cat) by(prev_denv) missing test saving("`figures'PREVALENCE_$S_DATE.xls", sheet("AIC_PREV_DENV_NO_PCR") sheetreplace) 
restore

preserve
	keep if cohort ==2
		table1,	vars(season cat \cohort cate \ gender bine \ age conts \ city cate \ mosquito_exposure_index conts \ mosq_prevention_index conts\ hccses_index_sum_pct cate \ hccses_index_sum conts\) by(prev_chikv) missing test saving("`figures'PREVALENCE_$S_DATE.xls", sheet("HCC_PREV_CHIKV_NO_PCR") sheetreplace) 
		table1,	vars(season cat \cohort cate \ gender bine \ age conts \ city cate \ mosquito_exposure_index conts \ mosq_prevention_index conts\ hccses_index_sum_pct cate \ hccses_index_sum conts\) by(prev_denv) missing test saving("`figures'PREVALENCE_$S_DATE.xls", sheet("HCC_PREV_DENV_NO_PCR") sheetreplace) 
restore
***************************************************end Prevalence******************************************************************
