/********************************************************************
 *amy krystosik                  							  		*
 *ellyse astmh abstract 2017- apprent and innaparent denv and chikv	*
 *lebeaud lab               				        		  		*
 *last updated march 14, 2017  							  			*
 ********************************************************************/ 
capture log close 
set more 1
set scrollbufsize 100000
log using "elysse_tropmed2017_apparent_inapparent.smcl", text replace 
cd "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\elysse- apparent inapparent"
local figures "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\elysse- apparent inapparent\figures\"
local data "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\elysse- apparent inapparent\data\"

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
replace apparent_groups= 3 if cohort == 2 & fever_6ms ==1
tab apparent_groups

gen visits = visit
save temp, replace

foreach outcome in schikvigg sdenvigg{
		use temp, clear
			*create right and left censoring times
		save temp1, replace
				keep if `outcome'!=.
				egen firstvisit= min(visit_int), by(id_wide) 
				save first, replace
				tab firstvisit
		use temp1, clear
			save temp1, replace
				keep if `outcome'!=.
				egen right = max(visit_int), by(id_wide) 
				save right, replace
				tab right 
			use temp1, clear

			save temp1, replace
				keep if `outcome'==1
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
			tab `outcome' , m 

			keep  firstvisit right  id_wide apparent_groups `outcome' fever fever_6ms posvisit
			rename posvisit visit_int
			collapse firstvisit (max) right  `outcome' (min) visit apparent_groups fever fever_6ms , by(id_wide)
			keep if `outcome' !=.
			merge 1:1 id_wide visit using temp
			bysort _merge: tab visit apparent_groups
			gen fail_`outcome' = visit if _merge==3
			tab fail_`outcome'
			
		*reshape wide prevalent firstvisit posvisit groups  schikvigg, i(id_wide) j(visit_int )

		*export to r
		*outsheet using "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\elysse- apparent inapparent\data\elysse_survival.csv", names comma replace
		gen agegroup = . 
		replace agegroup =1 if age <=4
		replace agegroup =2 if age >= 5 & age <=9
		replace agegroup =3 if age >= 10 & age <=14
		replace agegroup =4 if age >= 15 & age <=17
		replace agegroup =5 if age >= 18 & age <=.

		tab agegroup

		foreach strata in apparent_groups malariapositive_dum seasonyear sex agegroup primarydiag  reasonhospitalized1{
		*survival analysis
			stset visit_int, failure(`outcome') id(id_wide)
			stsum, by(`group')
			sts list, by(`group') 
			ltable visit_int , survival hazard intervals(180) by(`group')
		
		save "`data'data`outcome'", replace
		keep if fail_`outcome' !=""
		outsheet apparent_groups studyid id_wide visit  fail_`outcome'  fevertoday numillnessfever fever_6ms  symptomstoreview  medstoreview durationsymptom everhospitali reasonhospita* othhospitalna* seekmedcare medtype wheremedseek othwheremedseek counthosp durationhospi* hospitalname* datehospitali* numhospitalized outcome outcomehospitalized all_symptoms* using "`data'fail`outcome'.xls", replace 

}
}
