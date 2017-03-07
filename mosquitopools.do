cd "C:\Users\amykr\Box Sync\Amy Krystosik's Files\mosquito_pools\"
capture log close 
log using "elisa_import_merge_clean.smcl", text replace 
set scrollbufsize 100000
set more 1
clear

import excel "Master Mosquito Leg Pooling Database_amy.xls", sheet("Pool Database") firstrow
rename *, lower
save pools, replace

import excel "Master Mosquito Leg Pooling Database_amy.xls", sheet("aedes Results 1 -454") firstrow clear
rename *, lower
save aedes1-454, replace

import excel "Master Mosquito Leg Pooling Database_amy.xls", sheet("anopheles results 1-454") firstrow clear
rename *, lower
save anopheles1-454, replace

import excel "Master Mosquito Leg Pooling Database_amy.xls", sheet("Results 459-739") firstrow clear
rename *, lower
save results459-739, replace

import excel "Master Mosquito Leg Pooling Database_amy.xls", sheet("Results 740-860") firstrow clear
rename *, lower
save results740-860, replace

use aedes1-454, clear
append using "results459-739" "results740-860.dta", force
drop if  bigpoolnumber==.
foreach var in chikv_result denv_result zika_result {
	replace `var'="" if `var'=="."
}
keep if chikv_result != "" | denv_result != ""  | zika_result != "" 
dropmiss, obs force
dropmiss, force
save results, replace

use pools, clear
drop if  bigpoolnumber ==.
merge 1:1 bigpoolnumber using results 
drop _merge

foreach var in  chikv_result denv_result zika_result{
replace `var' = lower(`var')
tab `var'
}

foreach var in  chikv_result denv_result zika_result{
replace `var' = lower(`var')
	gen `var'b=.
	tostring `var', replace force
	replace `var'b =  0 if strpos(`var', "neg")
	replace `var'b =  1 if strpos(`var', "pos")
	destring `var', replace
	drop `var'
	rename `var'b `var'
}
sum chikv_result denv_result zika_result
replace traptype = lower(traptype)
replace traptype = "bg" if traptype == "bgs"

gen adult = .
replace adult = 1 if traptype =="backpack aspirator"|traptype =="bg"|traptype =="hlc"|traptype =="light trap"|traptype =="light trap - out"|traptype =="psc"|traptype =="window exit trap"
replace adult = 1 if strpos(traptype, "proko")
replace adult = 0 if strpos(traptype, "larva")
replace adult = 0 if strpos(traptype, "ovi")
replace adult = 0 if strpos(traptype, "pupa")
replace adult = 99 if strpos(traptype, "vector behaviour")
replace adult = 99 if strpos(traptype, "?")

tab adult, m
tab adult chikv_result
order bigpoolnumber adult *_result
order bigpoolnumber adult  chikv_result denv_result zika_result

gen claire_chikvpos_adult = .
foreach number in 355 356 357 361 340 750 754 755 417 740 744 748 {
	replace claire_chikvpos_adult = 1 if bigpoolnumber == `number'
}
gen amy_chikvpos_adult = 1 if adult ==1 & chikv_result ==1

export excel using "mergedpools_march72017.xls", firstrow(variables) replace
