/********************************************************************
 *amy krystosik                  							  		*
 *ellyse astmh abstract 2017- apprent and innaparent denv and chikv	*
 *lebeaud lab               				        		  		*
 *last updated march 14, 2017  							  			*
 ********************************************************************/ 
capture log close 
set more 1
set scrollbufsize 100000
log using "elysse_tropmed2017_apparent_inapparent_chikv.smcl", text replace 
cd "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\elysse- apparent inapparent"

local data "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\elysse- apparent inapparent\data\"
local cleandata "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\all linked and cleaned data\data"

foreach inc_outcome in inc_chikv inc_denv{
use "`cleandata'/`inc_outcome'.dta", clear

 
stset visit_int, failure(`inc_outcome') id(id_wide)
stsum, by(malariapositive_dum )
sts list, by(malariapositive_dum apparent_groups) 

stsum, by(apparent_groups )
stsum, by(apparent_groups  site)
stsum, by(apparent_groups  city)

gen all_fever = .
replace all_fever = 1 if fever ==1|fever_6ms ==1
tab all_fever
replace all_fever = 0 if fever ==0|fever_6ms ==0
tab all_fever

stsum, by(all_fever)
gen fever_`inc_outcome' = .
replace fever_`inc_outcome' =1 if all_fever== 1 & `inc_outcome'==1  
stset visit_int, failure(fever_`inc_outcome') id(id_wide)
stsum

gen fever_`inc_outcome'_malaria = .
replace fever_`inc_outcome'_malaria =1 if all_fever== 1 & `inc_outcome'==1  & malariapositive_dum ==1
stset visit_int, failure(fever_`inc_outcome'_malaria ) id(id_wide)
stsum

preserve
	keep if all_fever ==1
	stsum, by(strata)
	stsum, by(agegroup gender)
		stsum, by(agegroup)
restore

preserve
keep if apparent_groups==1
	stsum, by(strata)
	stsum
	stsum, by(gender)
restore

preserve 
	sts list, saving(`inc_outcome'_stsresults, replace) by(strata) 
	use `inc_outcome'_stsresults, clear
	export excel using "`data'stsworkbook", sheet("`inc_outcome'") sheetreplace 
restore

bysort `inc_outcome': tab malariapositive_dum apparent_groups, col
		tab agegroup
		foreach strata in apparent_groups malariapositive_dum seasonyear sex agegroup primarydiag  reasonhospitalized1{
		*survival analysis
			stset visit_int, failure(`inc_outcome') id(id_wide)
			stsum, by(`group')
			sts list, by(`group') 
			ltable visit_int , survival hazard intervals(180) by(`group')
			}

capture drop _merge
merge m:1 strata using "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\elysse- apparent inapparent\data\pop"
*************
preserve
	statsby mean=r(mean) ub=r(ub) lb=r(lb), by(strata) clear : ci `inc_outcome', e(pop) pois
	outsheet using "`data'_irr_ci_`inc_outcome'.csv", names comma replace
	save "`data'_irr_ci_`inc_outcome'", replace
restore
*************

save "`data'/`inc_outcome'", replace
keep if `inc_outcome'!=.
outsheet strata apparent_groups studyid id_wide visit  `inc_outcome'  fevertoday numillnessfever fever_6ms  symptomstoreview  medstoreview durationsymptom everhospitali reasonhospita* othhospitalna* seekmedcare medtype wheremedseek othwheremedseek counthosp durationhospi* hospitalname* datehospitali* numhospitalized outcome outcomehospitalized all_symptoms* using "`data'\`inc_outcome'.xls", replace 
}
