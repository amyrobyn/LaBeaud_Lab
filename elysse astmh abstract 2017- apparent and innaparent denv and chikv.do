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
global figures "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\elysse- apparent inapparent\figures\"
local data "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\elysse- apparent inapparent\data\"
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

egen denv_chikv = rowtotal(schikvigg sdenvigg)
tab denv_chikv 
drop if denv_chikv ==2

gen visits = visit
save temp, replace

		use temp, clear
			*create right and left censoring times
		save temp1, replace
				keep if denv_chikv!=.
				egen firstvisit= min(visit_int), by(id_wide) 
				save first, replace
				tab firstvisit
		use temp1, clear
			save temp1, replace
				keep if denv_chikv!=.
				egen right = max(visit_int), by(id_wide) 
				save right, replace
				tab right 
			use temp1, clear

			save temp1, replace
				keep if denv_chikv==1
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
			tab denv_chikv , m 

			keep  firstvisit right  id_wide apparent_groups denv_chikv fever fever_6ms posvisit
			gen visit_int = posvisit 
			collapse firstvisit (max) right  denv_chikv (min) visit_int apparent_groups fever fever_6ms posvisit , by(id_wide)
			keep if denv_chikv !=.
			merge 1:1 id_wide visit_int using temp
			bysort _merge: tab posvisit apparent_groups
			bysort apparent_groups: tab  malariapositive_dum  if posvisit>1 & posvisit!=.
			gen fail_denv_chikv = visit if _merge==3
			tab fail_denv_chikv
			
			

		*reshape wide prevalent firstvisit posvisit groups  denv_chikv, i(id_wide) j(visit_int )

		*export to r
		*outsheet using "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\elysse- apparent inapparent\data\elysse_survival.csv", names comma replace
		
drop if fail_denv_chikv=="a"
replace apparent_groups =2 if apparent_groups==3

stset visit_int, failure(denv_chikv) id(id_wide)
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

gen fever_schikv = .
replace fever_schikv =1 if all_fever== 1 & denv_chikv ==1  
stset visit_int, failure(fever_schikv) id(id_wide)
stsum

gen fever_schikv_malaria = .
replace fever_schikv_malaria =1 if all_fever== 1 & denv_chikv ==1  & malariapositive_dum ==1
stset visit_int, failure(fever_schikv_malaria ) id(id_wide)
stsum
global kenyapop0_17 = 19147737
display `r(ir)'*$kenyapop0_17 
stop 


preserve
	keep if all_fever ==1
	stsum, by(strata)
	stsum, by(agegroup gender)
		stsum, by(agegroup)
		tab 
restore

preserve
keep if apparent_groups==1
	stsum, by(strata)
	stsum
	stsum, by(gender)
restore

preserve 
	sts list, saving(denv_chikvstsresults, replace) by(strata) 
	stop
	use denv_chikvstsresults, clear
	export excel using "`data'stsworkbook", sheet("denv_chikv") sheetreplace 
	collapse  (max) survivor_1 survivor_2 survivor_3 survivor_4 survivor_5 survivor_6 survivor_7 survivor_8 survivor_9 survivor_10 survivor_11 survivor_12 survivor_13 survivor_14 survivor_15 survivor_16 survivor_17 survivor_18 survivor_19 survivor_20 survivor_21 survivor_22 survivor_23 survivor_24 survivor_25 survivor_26 survivor_27 survivor_28 survivor_29 survivor_30 survivor_31 survivor_32 survivor_33 survivor_34 survivor_35 survivor_36 survivor_37 survivor_38 survivor_39 survivor_40 survivor_41 survivor_42 survivor_43 survivor_44 survivor_45 survivor_46 survivor_47 survivor_48 survivor_49 survivor_50 survivor_51, by(strata)
restore
stop

bysort fail_denv_chikv: tab malariapositive_dum apparent_groups, col
		tab agegroup
		foreach strata in apparent_groups malariapositive_dum seasonyear sex agegroup primarydiag  reasonhospitalized1{
		*survival analysis
			stset visit_int, failure(denv_chikv) id(id_wide)
			stsum, by(`group')
			sts list, by(`group') 
			ltable visit_int , survival hazard intervals(180) by(`group')
			}

preserve
	keep if fail_denv_chikv!=""
	tab malariapositive_dum apparent_groups	
restore

	/*
	gene byte baseline = 1
	encode strata, gen(strataint)
	levelsof strata, local(levels) 
	foreach l of local levels {
				preserve
				keep if strata == "`l'"
				capture sum denv_chikv
				display `r(sum)'
				display "`l'"
				if  `r(sum)' >1 {
				poisson denv_chikv baseline, noconst irr 
				ir  denv_chikv fever visit_int
				}
				restore
		}
	*/
restore
	capture drop _merge
merge m:1 strata using "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\elysse- apparent inapparent\data\pop"
*************
preserve
	statsby mean=r(mean) ub=r(ub) lb=r(lb), by(strata) clear : ci denv_chikv, e(pop) pois
	outsheet using "$"data"_irr_ci_denv_chikv.csv", names comma replace
	save "$"data"_irr_ci_denv_chikv", replace
restore
*************


		
		save "$"data"datadenv_chikv", replace
		keep if fail_denv_chikv !=""
		outsheet strata apparent_groups studyid id_wide visit  fail_denv_chikv  fevertoday numillnessfever fever_6ms  symptomstoreview  medstoreview durationsymptom everhospitali reasonhospita* othhospitalna* seekmedcare medtype wheremedseek othwheremedseek counthosp durationhospi* hospitalname* datehospitali* numhospitalized outcome outcomehospitalized all_symptoms* using "$"data"faildenv_chikv.xls", replace 

*/
