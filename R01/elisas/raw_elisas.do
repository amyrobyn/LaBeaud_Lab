/********************************************************************
 *amy krystosik                  							  		*
 *raw data for elisas												* 
 *elisa for chikv and denv.											*
 *lebeaud lab               				        		  		*
 *last updated march 20, 2017  							  			*
 ********************************************************************/ 

cd "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\elisas\raw"

capture log close 
log using "raw elisas.smcl", text replace 
set scrollbufsize 100000
set more 1

use "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\all linked and cleaned data\data\cleaned_merged_prevalence", clear

bysort cohort: sum  stanfordchikvigg_ stanforddenvigg_ chikvigg_ denvigg_
bysort visit: sum  stanfordchikvigg_ stanforddenvigg_ chikvigg_ denvigg_
bysort site: sum  stanfordchikvigg_ stanforddenvigg_ chikvigg_ denvigg_

save temp, replace
foreach outcome in stanfordchikvigg_ stanforddenvigg_ chikvigg_ denvigg_{
use temp, clear

keep if `outcome'!=.

foreach followup in b c d e f g {
	foreach visit in a b c d e f g {
		preserve
		keep if visit =="`visit'"
		save `outcome'`visit', replace
		
	isid visit id_wide 
	merge 1:1 id_wide using `outcome'`followup'
	keep if _merge == 3
	keep _merge 
	rename _merge `outcome'`visit'`followup'
	
	save `outcome'`visit'`followup', replace
restore
}
}
}

use temp, clear
keep studyid id_wide visit

foreach outcome in stanfordchikvigg_ stanforddenvigg_ chikvigg_ denvigg_{
	foreach followup in b c d e f g {
		foreach visit in a b c d e f g {
			append using `outcome'`visit'`followup'
}
}
}
fsum

