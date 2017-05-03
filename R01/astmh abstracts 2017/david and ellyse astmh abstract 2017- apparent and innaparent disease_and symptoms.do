/********************************************************************
 *amy krystosik                  							  		*
 *astmh abstract 2017- apprent and innaparent denv and chikv & symptoms*
 *lebeaud lab               				        		  		*
 *last updated march 23, 2017  							  			*
 ********************************************************************/ 
capture log close 
set more 1
set scrollbufsize 100000
cd "C:\Users\amykr\Box Sync\Amy Krystosik's Files\ASTMH 2017 abstracts\elysse- apparent inapparent"
log using "tropmed2017_apparent_inapparent_chikv& symptoms.smcl", text replace 

local data "C:\Users\amykr\Box Sync\Amy Krystosik's Files\ASTMH 2017 abstracts\elysse- apparent inapparent\data\"
local cleandata "C:\Users\amykr\Box Sync\Amy Krystosik's Files\ASTMH 2017 abstracts\all linked and cleaned data\data"

foreach inc_outcome in inc_chikv inc_denv{
use "`cleandata'/`inc_outcome'.dta", clear
replace apparent_groups = collapsed_apparent_groups  
 
stset visit_int, failure(`inc_outcome') id(id_wide)
stsum, by(malariapositive_dum )
sts list, by(malariapositive_dum apparent_groups) 

stsum, by(apparent_groups)
sts list, by(site)


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
stsum, by(antimalarial)

gen fever_`inc_outcome'_malaria = .
replace fever_`inc_outcome'_malaria =1 if all_fever== 1 & `inc_outcome'==1  & malariapositive_dum ==1
stset visit_int, failure(fever_`inc_outcome'_malaria ) id(id_wide)
stsum
stsum, by(antimalarial)

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
	display "*******************`inc_outcome'*************"
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

table1 , vars(age contn \ gender bin \ city cat \ outcome cat \ outcomehospitalized bin \stanforddenvigg_ cat \  heart_rate conts \ zhcaukwho conts \ zwtukwho conts \ zhtukwho conts \ zbmiukwho conts \ zheart_rate conts \ zsystolicbp conts \ zdiastolicbp conts \ zpulseoximetry conts \ ztemperature conts \ zresprate conts \ zlen conts \ zwei conts \ zwfl conts \ zbmi conts \ zhc conts \ scleralicterus cat \ splenomegaly  cat \ temperature conts \ hivmeds bin \ hivpastmedhist bin \) by(apparent_groups ) saving("`figures'table2_by_group`inc_outcome'.xls", replace ) missing test 
table1, vars(bleeding bin \all_symptoms_halitosis bin \  all_symptoms_edema bin \  all_symptoms_appetite_change bin \  all_symptoms_constipation cat \  all_symptoms_behavior_change bin \  all_symptoms_altms bin \  all_symptoms_abnormal_gums cat \  all_symptoms_jaundice cat \  all_symptoms_constitutional bin \  all_symptoms_asthma cat \  all_symptoms_lethergy cat \  all_symptoms_dysphagia bin \  all_symptoms_dysphrea bin  \  all_symptoms_anaemia cat \  all_symptoms_seizure bin \  all_symptoms_itchiness bin \  all_symptoms_bleeding_symptom bin \  all_symptoms_sore_throat bin \  all_symptoms_sens_eyes cat \  all_symptoms_earache bin \  all_symptoms_funny_taste bin \  all_symptoms_imp_mental cat \  all_symptoms_mucosal_bleed_brs bin \  all_symptoms_bloody_nose cat \  all_symptoms_rash bin \  all_symptoms_dysuria bin \  all_symptoms_nausea bin \  all_symptoms_respiratory bin \  all_symptoms_aches_pains bin \  all_symptoms_abdominal_pain bin \  all_symptoms_diarrhea bin \  all_symptoms_vomiting bin \  all_symptoms_chiils  bin \  all_symptoms_fever bin \  all_symptoms_eye_symptom bin \  all_symptoms_other cat \  ) by(apparent_groups ) saving("`figures'symptoms_by_group`inc_outcome'.xls", replace) missing test
table1, vars(all_meds_antifungal cat \ all_meds_supplement cat \ all_meds_allergy cat \ all_meds_expectorant cat\ all_meds_antihelmenthic cat \ all_meds_antipyretic cat \ all_meds_antimalarial cat \ all_meds_antibacterial cat  \ all_meds_benzimidazole  cat \antiparasitic cat\ all_meds_bronchospasm cat \ all_meds_topical  cat \ all_meds_antiamoeba cat \    all_meds_none cat \   all_meds_gerd cat \   all_meds_painmed cat \ all_meds_sulphate cat \ all_meds_cough cat \ all_meds_iv cat \ all_meds_ors cat \ all_meds_admit cat \ all_meds_othermed cat \  ) by(apparent_groups ) saving("`figures'meds_by_group`inc_outcome'.xls", replace) missing test

}



