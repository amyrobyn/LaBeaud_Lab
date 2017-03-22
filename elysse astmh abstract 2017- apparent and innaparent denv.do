/********************************************************************
 *amy krystosik                  							  		*
 *ellyse astmh abstract 2017- apprent and innaparent denv and chikv	*
 *lebeaud lab               				        		  		*
 *last updated march 14, 2017  							  			*
 ********************************************************************/ 
capture log close 
set more 1
set scrollbufsize 100000
log using "elysse_tropmed2017_apparent_inapparent_denv.smcl", text replace 
cd "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\elysse- apparent inapparent"
global figures "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\elysse- apparent inapparent\figures\"
global data "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\elysse- apparent inapparent\data\"

use "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\all linked and cleaned data\data\cleaned_merged_data", replace
*shorten outcomes
rename stanforddenvigg_ sdenvigg
rename stanfordchikvigg_ schikvigg
save temp, replace


*generate fail events
*apparent is aic cohort: first febrile episode + fever- take everyone that fails
*innapparent is hcc cohort: seroconversion with no fever- take only the failures after the first visit (incident, not prevalent)
*third group is hcc cohort: seroconversion with fever- take only the failures after the first visit (incident, not prevalent)

gen apparent_groups= . 
replace apparent_groups= 1 if cohort == 1 & fevertemp ==1
replace apparent_groups= 2 if cohort == 2 & fever_6ms ==0
replace apparent_groups= 3 if cohort == 2 & fever_6ms ==1 |cohort == 2 & fever_6ms ==.
tab apparent_groups

gen visits = visit
save temp, replace

		use temp, clear
			*create right and left censoring times
		save temp1, replace
				keep if sdenvigg!=.
				egen firstvisit= min(visit_int), by(id_wide) 
				save first, replace
				tab firstvisit
		use temp1, clear
			save temp1, replace
				keep if sdenvigg!=.
				egen right = max(visit_int), by(id_wide) 
				save right, replace
				tab right 
			use temp1, clear

			save temp1, replace
				keep if sdenvigg==1
				egen posvisit= min(visit_int), by(id_wide) 
				save posvisit, replace
				tab posvisit 
			use temp1, clear


			merge 1:1 id_wide visit using posvisit
			drop _merge
			merge 1:1 id_wide visit using first
			drop _merge
			merge 1:1 id_wide visit using right 
			order id_wide visit_int firstvisit right 
			tab sdenvigg , m 

			keep  firstvisit right  id_wide apparent_groups sdenvigg fever fever_6ms posvisit
			gen visit_int = posvisit 
			collapse firstvisit (max) right  sdenvigg (min) visit_int posvisit  apparent_groups fever fever_6ms , by(id_wide)
			keep if sdenvigg !=.
			merge 1:1 id_wide visit_int using temp
			bysort _merge: tab visit_int apparent_groups
			gen fail_sdenvigg = visit_int if _merge==3
			tab fail_sdenvigg
			
drop if posvisit ==1
replace apparent_groups =2 if apparent_groups==3
bysort fail_sdenvigg: tab malariapositive_dum apparent_groups, col
bysort apparent_groups: tab malariapositive_dum if posvisit >1 & posvisit !=.

stset visit_int, failure(sdenvigg) id(id_wide)
stsum, by(malariapositive_dum )
sts list, by(malariapositive_dum apparent_groups) 
sts list
stsum, by(apparent_groups )
stsum, by(apparent_groups  site)
stsum, by(apparent_groups  city)
stop 
		*reshape wide prevalent firstvisit posvisit groups  schikvigg, i(id_wide) j(visit_int )

		*export to r
		*outsheet using "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\elysse- apparent inapparent\data\elysse_survival.csv", names comma replace
		
		tab agegroup
		foreach strata in apparent_groups malariapositive_dum seasonyear sex agegroup primarydiag  reasonhospitalized1{
		*survival analysis
			stset visit_int, failure(sdenvigg) id(id_wide)
			stsum, by(`group')
			sts list, by(`group') 
			ltable visit_int , survival hazard intervals(180) by(`group')
			}
preserve 
	sts list, saving(sdenviggstsresults, replace) by(strata) compare
	use sdenviggstsresults, clear
	export excel using "$"data"stsworkbook", sheet("sdenvigg") sheetreplace 

	/*
	gene byte baseline = 1
	encode strata, gen(strataint)
	levelsof strata, local(levels) 
	foreach l of local levels {
				preserve
				keep if strata == "`l'"
				capture sum sdenvigg
				display `r(sum)'
				display "`l'"
				if  `r(sum)' >1 {
				poisson sdenvigg baseline, noconst irr 
				ir  sdenvigg fever visit_int
				}
				restore
		}
	*/
restore
	capture drop _merge
merge m:1 strata using "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\elysse- apparent inapparent\data\pop"
*************
preserve
	statsby mean=r(mean) ub=r(ub) lb=r(lb), by(strata) clear : ci sdenvigg, e(pop) pois
	outsheet using "$"data"_irr_ci_sdenvigg.csv", names comma replace
	save "$"data"_irr_ci_sdenvigg", replace
restore
*************


		
		save "$"data"datasdenvigg", replace
		keep if fail_sdenvigg !=""
		outsheet strata apparent_groups studyid id_wide visit  fail_sdenvigg  fevertoday numillnessfever fever_6ms  symptomstoreview  medstoreview durationsymptom everhospitali reasonhospita* othhospitalna* seekmedcare medtype wheremedseek othwheremedseek counthosp durationhospi* hospitalname* datehospitali* numhospitalized outcome outcomehospitalized all_symptoms* using "$"data"failsdenvigg.xls", replace 

*/
