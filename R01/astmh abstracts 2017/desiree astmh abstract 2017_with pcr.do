/********************************************************************
 *amy krystosik                  							  		*
 *desiree astmh abstract 2017- incidence and prev					*
 *lebeaud lab               				        		  		*
 *last updated march 14, 2017  							  			*
 ********************************************************************/ 
capture log close 
set more 1
set scrollbufsize 100000
cd "C:\Users\amykr\Box Sync\Amy Krystosik's Files\ASTMH 2017 abstracts\desiree- abstract1\data"

log using "des_tropmed2017_wpcr.smcl", text replace 

local figures "C:\Users\amykr\Box Sync\Amy Krystosik's Files\ASTMH 2017 abstracts\desiree- abstract1\figures\"
local data "C:\Users\amykr\Box Sync\Amy Krystosik's Files\ASTMH 2017 abstracts\desiree- abstract1\data\"
local cleandata "C:\Users\amykr\Box Sync\Amy Krystosik's Files\ASTMH 2017 abstracts\all linked and cleaned data\data\"

foreach outcome in inc_chikv inc_denv{
use "`cleandata'/`outcome'", clear
tab season
gen wet = . 
replace wet =0 if season ==1|season ==3
replace wet =1 if season ==2|season ==4

stset time, failure(`outcome') id(id_wide) 

gen ttlrainfalllag1 = ttlrainfall[_n-1]
gen avgrhlag1 = avgrh[_n-1]


**/Active disease from CHIKV and DENV were associated with SES, gender, X and Y. */
preserve
	keep if cohort ==1
	tab cohort
	drop dup
	duplicates tag id_wide, gen(dup)
	drop if dup >0 & `outcome'!=1
	drop dup
	duplicates tag id_wide, gen(dup)
	drop if dup >0 

	table1,	vars(avgrhlag1  conts \ avgrh conts \ ttlrainfall  conts \ ttlrainfalllag1  conts \ wet bin \ season cat \cohort cat \  urban bin\ ses_index_sum conts \ gender bin \ site cat \ age conts \ city cat \ mosq_prevention_index  contn \  ses_index_sum  conts \ hygieneindex conts \ wealthindex conts ) by(`outcome') missing test saving("`figures'INCIDENCE_$S_DATE.xls", sheet("AIC_`outcome'_W_PCR") sheetreplace) 
restore

preserve
	keep if cohort ==2
	tab cohort
	display "`outcome'"
	bysort `outcome': sum season    cohort     gender     age    city  hccses_index_sum 

	drop dup
	duplicates tag id_wide, gen(dup)
	drop if dup >0 & `outcome'!=1
	drop dup
	duplicates tag id_wide, gen(dup)
	drop if dup >0 

		table1,	vars(wet bin \ season cat \cohort cate \ gender bine \ age conts \ city cate \ ) by(`outcome') missing test saving("`figures'INCIDENCE_$S_DATE.xls", sheet("HCC_`outcome'_W_PCR") sheetreplace) 
restore

sts list
sts list, by(cohort) 
sts list, by(city) 
sts list, by(season) 
sts list, by(site cohort) 
sts list, by(site cohort agegroup ) 
sts list, by(site) 
sts list, by(urban) 
sts list, by(urban cohort) 
sts list, by(cohort city) 
sts list, by(cohort city agegroup ) 

}
***************************************************end incidence******************************************************************

***************************************************start Prevalence******************************************************************

use "`cleandata'prev_denv_w_PCR$S_DATE", clear
stset time, failure(prev_denv) id(id_wide) 
sts list
sts list, by(cohort) 
sts list, by(site cohort) 
sts list, by(site cohort agegroup ) 
sts list, by(site) 
sts list, by(urban) 
sts list, by(urban cohort) 
sts list, by(cohort city) 
sts list, by(cohort city agegroup ) 

preserve
keep if cohort ==1
			*denv
			table1,	vars(season cat \cohort cat \  urban bin\ aic_ses_index_sum conts \ gender bin \ site cat \ age conts \ city cat \ mosquito_exposure_index contn \ mosquito_prevention_index  contn\ \  aic_ses_index_sum  conts \ hygieneindex conts \ wealthindex conts \ ) by(prev_denv) missing test saving("`figures'PREVALENCE_$S_DATE.xls", sheet("AIC_PREV_DENV_W_PCR") sheetreplace) 
restore

preserve
	keep if cohort ==2
		*denv
		table1,	vars(season cat \cohort cate \ gender bine \ age conts \ city cate \ mosquito_exposure_index conts \ mosquito_prevention_index conts\ hccses_index_sum conts\) by(prev_denv) missing test saving("`figures'PREVALENCE_$S_DATE.xls", sheet("HCC_PREV_DENV_W_PCR") sheetreplace) 
restore

use "`cleandata'prev_chikv_w_PCR10 Apr 2017", clear
stset time, failure(prev_chikv) id(id_wide) 
stsum, by(cohort  city) 

sts list
sts list, by(cohort) 
sts list, by(site cohort) 
sts list, by(site cohort agegroup ) 
sts list, by(site) 
sts list, by(urban) 
sts list, by(urban cohort) 
sts list, by(cohort city) 
sts list, by(cohort city agegroup ) 


preserve
keep if cohort ==1
			*chikv
			table1,	vars(season cat \cohort cat \  urban bin\ aic_ses_index_sum conts \ gender bin \ site cat \ age conts \ city cat \ mosquito_exposure_index contn \ mosquito_prevention_index contn\ aic_ses_index_sum  conts \ hygieneindex conts \ wealthindex conts \) by(prev_chikv) missing test saving("`figures'PREVALENCE_$S_DATE.xls", sheet("AIC_PREV_CHIKV_W_PCR") sheetreplace) 
restore

preserve
	keep if cohort ==2
		*chikv
		table1,	vars(season cat \cohort cate \ gender bine \ age conts \ city cate \ mosquito_exposure_index conts \ mosquito_prevention_index conts\ hccses_index_sum conts\) by(prev_chikv) missing test saving("`figures'PREVALENCE_$S_DATE.xls", sheet("HCC_PREV_CHIKV_W_PCR") sheetreplace) 
restore
***************************************************end Prevalence********************************************************
