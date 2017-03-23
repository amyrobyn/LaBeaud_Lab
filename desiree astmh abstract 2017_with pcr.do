/********************************************************************
 *amy krystosik                  							  		*
 *desiree astmh abstract 2017- incidence and prev					*
 *lebeaud lab               				        		  		*
 *last updated march 14, 2017  							  			*
 ********************************************************************/ 
capture log close 
set more 1
set scrollbufsize 100000

log using "des_tropmed2017_wpcr.smcl", text replace 

cd "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\desiree- abstract1\data"

local figures "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\desiree- abstract1\figures\"
local data "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\desiree- abstract1\data\"
local cleandata "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\all linked and cleaned data\data"

foreach outcome in inc_chikv inc_denv{
use "`cleandata'/`outcome'", clear

stset time, failure(`outcome') id(id_wide) 

sts list
sts list, by(cohort) 
sts list, by(site cohort) 
sts list, by(site cohort agecat) 
sts list, by(site) 
sts list, by(urban) 
sts list, by(city) 

**/Active disease from CHIKV and DENV were associated with SES, gender, X and Y. */
preserve
		keep if cohort ==1
			table1,	vars(season cat \cohort cat \  urban bin\ ses_index_sum conts \ gender bin \ site cat \ age conts \ city cat \ mosquito_exposure_index contn \ mosq_prevention_index contn\ \  ses_index_sum  conts \ hygieneindex conts \ wealthindex conts \ ses_index_sum_pct  cat) by(`outcome') missing test saving("`figures'INCIDENCE_$S_DATE.xls", sheet("AIC_`outcome'_W_PCR") sheetreplace) 
restore

preserve
	keep if cohort ==2
		table1,	vars(season cat \cohort cate \ gender bine \ age conts \ city cate \ mosquito_exposure_index conts \ mosq_prevention_index conts\ hccses_index_sum_pct cate \ hccses_index_sum conts\) by(`outcome') missing test saving("`figures'INCIDENCE_$S_DATE.xls", sheet("HCC_`outcome'_W_PCR") sheetreplace) 
restore

}
***************************************************end incidence******************************************************************

***************************************************start Prevalence******************************************************************

use "`cleandata'prev_denv_w_PCR", clear
preserve
keep if cohort ==1
			*denv
			table1,	vars(season cat \cohort cat \  urban bin\ ses_index_sum conts \ gender bin \ site cat \ age conts \ city cat \ mosquito_exposure_index contn \ mosq_prevention_index contn\ \  ses_index_sum  conts \ hygieneindex conts \ wealthindex conts \ ses_index_sum_pct  cat) by(prev_denv) missing test saving("`figures'PREVALENCE_$S_DATE.xls", sheet("AIC_PREV_DENV_W_PCR") sheetreplace) 
restore

preserve
	keep if cohort ==2
		*denv
		table1,	vars(season cat \cohort cate \ gender bine \ age conts \ city cate \ mosquito_exposure_index conts \ mosq_prevention_index conts\ hccses_index_sum_pct cate \ hccses_index_sum conts\) by(prev_denv) missing test saving("`figures'PREVALENCE_$S_DATE.xls", sheet("HCC_PREV_DENV_W_PCR") sheetreplace) 
restore


use "`cleandata'prev_chikv_w_PCR", clear
preserve
keep if cohort ==1
			*chikv
			table1,	vars(season cat \cohort cat \  urban bin\ ses_index_sum conts \ gender bin \ site cat \ age conts \ city cat \ mosquito_exposure_index contn \ mosq_prevention_index contn\ \  ses_index_sum  conts \ hygieneindex conts \ wealthindex conts \ ses_index_sum_pct  cat) by(prev_chikv) missing test saving("`figures'PREVALENCE_$S_DATE.xls", sheet("AIC_PREV_CHIKV_W_PCR") sheetreplace) 
restore

preserve
	keep if cohort ==2
		*chikv
		table1,	vars(season cat \cohort cate \ gender bine \ age conts \ city cate \ mosquito_exposure_index conts \ mosq_prevention_index conts\ hccses_index_sum_pct cate \ hccses_index_sum conts\) by(prev_chikv) missing test saving("`figures'PREVALENCE_$S_DATE.xls", sheet("HCC_PREV_CHIKV_W_PCR") sheetreplace) 
restore
***************************************************end Prevalence******************************************************************

