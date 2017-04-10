set graphics on 
capture log close 
set scrollbufsize 100000
set more 1
cd "C:\Users\amykr\Box Sync\Amy Krystosik's Files\ASTMH 2017 abstracts\priyanka- fogarty nd"
log using "fogartynd_gestationalage.smcl", text replace 
set scrollbufsize 100000
set more 1

local tables "C:\Users\amykr\Box Sync\Amy Krystosik's Files\ASTMH 2017 abstracts\priyanka- fogarty nd\tables\"
insheet using "FogartyNDCHIKV_DATA_2017-04-08_1027.csv", comma clear
describe
	ds, has(type byte) 
		foreach var of varlist `r(varlist)' { 
			replace `var' = . if `var' ==99
		}
	ds, has(type float) 
		foreach var of varlist `r(varlist)' { 
			replace `var' = . if `var' ==99
		}


replace gestational_age_weeks = . if gestational_age_weeks==99
replace gestational_age_days = . if gestational_age_days==99

gen gestational_age_daysfrac = gestational_age_days/7
gen  gestational_age_weekfrac= .
replace gestational_age_weekfrac = gestational_age_weeks + gestational_age_daysfrac 

/*
preterm <37 weeks, term 37-42, posters >42
*/

gen gestational_age_cat= .
replace gestational_age_cat = 1 if gestational_age_weekfrac  >=37 & gestational_age_weekfrac <42
replace gestational_age_cat = 2 if gestational_age_weekfrac  < 37
replace gestational_age_cat = 3 if gestational_age_weekfrac  >=42 & gestational_age_weekfrac <.

label variable gestational_age_cat "gestational_age_categories"
label define gestational_age_cat  1 "full-term" 2 "pre-term" 3 "post-term" , modify
label values gestational_age_cat  gestational_age_categories

tab gestational_age_cat  
sum gestational_age_weekfrac
*sum infant birthing questionaire by trimester of infection gestatational age

foreach var in trimester symptom_duration pregnancy_illness birth_time opioids complications birthing_experience after_birth_problems race monthly_income smoking{
	replace `var'= . if `var'==99
}
*drop if pregnant ==99 | pregnant ==. 
tab pregnant ever_had_chikv, m
tab result_mother ever_had_chikv, m

tab pregnant result_mother, m

gen preg_chikvpos = .
replace preg_chikvpos = 1 if result_mother==1 & pregnant ==1
replace preg_chikvpos = 0 if pregnant == 0 | result_mother==0

tab preg_chikvpos 
drop if trimester ==. & preg_chikvpos ==1
 
gen chikv_preg_non =. 
replace chikv_preg_non = 0 if result_mother ==1 & pregnant == 0
replace chikv_preg_non = 1 if result_mother ==1 & pregnant == 1

label define gestational_age_cat  0 "full-term" 1 "pre-term" 2 "post-term" , modify 
tabout trimester gestational_age_cat if smoking ==0 using trimeste_vs_gestational_agecat.xls , stats(chi2) replace h1("trimeste vs gestational agecat(row %)") h2( "|full-term | pre-term | post-term | Total" ) h3("Didn't Smoke") lines(none)
tabout trimester gestational_age_cat if smoking ==1 using trimeste_vs_gestational_agecat.xls , stats(chi2) append h1("Smoked") h2(nil) h3(nil)
tabout trimester gestational_age_cat using trimeste_vs_gestational_agecat.xls , stats(chi2) append h1("All") h2(nil) h3(nil)

tabout trimester birth_time if smoking ==0 using trimester_vs_bith_time.xls , stats(chi2) replace h1("trimester vs bith time(row %)") h2( "|full-term | pre-term | post-term | Total" ) h3("Didn't Smoke") lines(none)
tabout trimester birth_time if smoking ==1 using trimester_vs_bith_time.xls , stats(chi2) append h1("Smoked") h2(nil) h3(nil)
tabout trimester birth_time using trimester_vs_bith_time.xls , stats(chi2) append h1("All") h2(nil) h3(nil)


*dob 
foreach var in primary_date dob {
				gen `var'2 = `var'
				gen `var'1 = date(`var', "YMD")
				format %td `var'1 
				drop `var'
				rename `var'1 `var'
				recast int `var'
				}
				
				

gen mom_age= primary_date - dob  
tab mom_age, m
replace mom_age = round(mom_age/365.25)
sum mom_age
replace mom_age =. if mom_age <15 
list dob2 primary_date2 if mom_age ==. 

replace mode_of_delivery = mode_of_delivery -1
bysort preg_chikvpos:sum smoking_amount marijuana_amount opioid_amount 

sum reason_hospitalized when_hospitalized duration_hospitalized hospitalized_dengue hospitalized_ever

gen hospitalized_pregnancy = 0 
replace participant_id =lower(participant_id) 
replace hospitalized_pregnancy = 1 if participant_id=="sg0005"| participant_id=="gb0007"| participant_id=="gb0006"|participant_id=="gb0023"

foreach var in list_pregnancy_illness specify_complications  specify_after_birth_problems specify_first_few_months  specify_disabilities caesarean{
	tabout `var' using tocategorize\tab`var'.xls, replace
}


bysort birth_time: sum preg_chikvpos pregnancy_illness opioids mode_of_delivery complications birthing_experience labour_duration after_birth_problems first_few_months_illness race  education mom_age monthly_income  symptom_duration hospitalized_ever  
*mlogit birth_time preg_chikvpos pregnancy_illness opioids mode_of_delivery complications birthing_experience labour_duration after_birth_problems first_few_months_illness race  education mom_age monthly_income  symptom_duration hospitalized_ever  
*opioid_amount  marijuana meth heroine cocaine alcohol_amount 
*symptoms___14 symptoms___26 symptoms___27 symptoms___28 symptoms___29 symptoms___30 symptoms___31 symptoms___32 symptoms___33 symptoms___20 symptoms___17 disabilities alcohol smoking drugs  symptoms___6 symptoms___7  symptoms___12 symptoms___13 symptoms___15 symptoms___16 symptoms___18 symptoms___19 symptoms___21 symptoms___22 symptoms___23 symptoms___24  symptoms___34  

foreach var of varlist specify_after_birth_problems { 			
		replace `var'= subinstr(`var', " ", "_",.)
}

*remove these
*replace specify_after_birth_problems= subinstr(specify_after_birth_problems, "draft_in_his_eye" ,"unknown" ,.)
*replace specify_after_birth_problems= subinstr(specify_after_birth_problems, "required_flush" ,"unknown" ,.)

*
replace specify_after_birth_problems = lower(specify_after_birth_problems)
replace specify_after_birth_problems= subinstr(specify_after_birth_problems, "mucus_on_chest" ,"respiratory" ,.)
replace specify_after_birth_problems= subinstr(specify_after_birth_problems, "breathing_problems" ,"respiratory" ,.)
replace specify_after_birth_problems= subinstr(specify_after_birth_problems, "cartilage_in_trachea_did_not_develop_properly" ,"malformation" ,.)
replace specify_after_birth_problems= subinstr(specify_after_birth_problems, "club_foot" ,"malformation" ,.)
replace specify_after_birth_problems= subinstr(specify_after_birth_problems, "chikungunya" ,"chikv" ,.)
replace specify_after_birth_problems= subinstr(specify_after_birth_problems, "fever" ,"sepsis" ,.)
replace specify_after_birth_problems= subinstr(specify_after_birth_problems, "ear_infection" ,"sepsis" ,.)
replace specify_after_birth_problems= subinstr(specify_after_birth_problems, "head_cold" ,"viral" ,.)
replace specify_after_birth_problems= subinstr(specify_after_birth_problems, "gondis" ,"jaundice" ,.)
replace specify_after_birth_problems= subinstr(specify_after_birth_problems, "fluid_in_testacles" ,"jaundice" ,.)
replace specify_after_birth_problems= subinstr(specify_after_birth_problems, "flu" ,"viral" ,.)
replace specify_after_birth_problems= subinstr(specify_after_birth_problems, "swollen" ,"swelling" ,.)
replace specify_after_birth_problems= subinstr(specify_after_birth_problems, "was_not_feeding_properly,_not_getting_a" ,"poor_feeding" ,.)

rename specify_after_birth_problems abp
foreach var of varlist abp{ 			
foreach symptom in "chikv" "respiratory" "malformation"  "unknown" "sepsis"  "viral" "jaundice" "seizures" "swelling" "sinus" "sickle_cell" "allergies" "eczema" "rash"{
						tostring `var', replace
						replace `var'=trim(itrim(lower(`var')))
						moss `var', match(`symptom') prefix(`symptom')

						gen `var'_`symptom'=0
						replace `var'_`symptom'= 1 if strpos(`var', "`symptom'")
						replace `var'= subinstr(`var', "`symptom'", "",.)
						order `var'_`symptom'
						tab `var'_`symptom'
}
}	


foreach var of varlist specify_complications{ 			
		replace `var'= subinstr(`var', " ", "_",.)
		replace `var' = lower(`var')
}
tab specify_complications
replace specify_complications= subinstr(specify_complications, "alot_of_blood" ,"hemorrhage" ,.)
replace specify_complications= subinstr(specify_complications, "breached" ,"breach" ,.)
replace specify_complications= subinstr(specify_complications, "cervical_tearing" ,"tear" ,.)
replace specify_complications= subinstr(specify_complications, "placenta_previa" ,"prolonged_labour" ,.)

*remove these
*replace specify_complications= subinstr(specify_complications, "swekling_on_baby_head" ,"swollen" ,.)
*replace specify_complications= subinstr(specify_complications, "chikv_pain" ,"tear" ,.)
*replace specify_complications= subinstr(specify_complications, "child_on_posterior" ,"" ,.)


rename specify_complications lab_complic
foreach var of varlist lab_complic{ 			
foreach symptom in  "hemorrhage" "breach" "tear" "chikv_pain" "cord_around_neck" "placenta_previa" "prolonged_labour" "swollen"{
						tostring `var', replace
						replace `var'=trim(itrim(lower(`var')))
						moss `var', match(`symptom') prefix(`symptom')

						gen `var'_`symptom'=0
						replace `var'_`symptom'= 1 if strpos(`var', "`symptom'")
						replace `var'= subinstr(`var', "`symptom'", "",.)
						order `var'_`symptom'
						tab `var'_`symptom'
}
}	

*add these into the labor complications from pregnancy illness
*replace `var' = subinstr(`var' , "rupture_if_placenta" ,"placental_abruption" ,.)
*replace `var' = subinstr(`var' , "the_baby_was_breached" ,"breach" ,.)

foreach var of varlist specify_first_few_months { 			
		replace `var'= subinstr(`var', " ", "_",.)
		replace `var' = lower(`var')

tab `var' 
replace `var' = subinstr(`var' , "allergic_to_formula_milk" ,"allergies" ,.)
replace `var' = subinstr(`var' , "anemic" ,"anemia" ,.)
replace `var' = subinstr(`var' , "asthma" ,"respiratory" ,.)
replace `var' = subinstr(`var' , "Bumps/on skin particularly under feet" ,"rash" ,.)
replace `var' = subinstr(`var' , "chikungunya" ,"chikv" ,.)
replace `var' = subinstr(`var' , "heart_murmur" ,"murmur" ,.)
replace `var' = subinstr(`var' , "intensive_care_for_first_2_months" ,"nicu" ,.)
rename `var' baby_health
}

foreach var of varlist baby_health{ 			
foreach symptom in  "allergies" "anemia" "chikv" "murmur" "nicu" "jaundice" "respiratory" "sickle_cell" {
						tostring `var', replace
						replace `var'=trim(itrim(lower(`var')))
						moss `var', match(`symptom') prefix(health`symptom')

						gen `var'_`symptom'=0
						replace `var'_`symptom'= 1 if strpos(`var', "`symptom'")
						replace `var'= subinstr(`var', "`symptom'", "",.)
						order `var'_`symptom'
						tab `var'_`symptom'
}
}	

foreach var of varlist list_pregnancy_illness{ 			
		replace `var'= subinstr(`var', " ", "_",.)
		replace `var' = lower(`var')
tab `var' 
replace `var' = subinstr(`var' , "chikungunya" ,"chikv" ,.)
replace `var' = subinstr(`var' , "chikungunya" ,"chikv" ,.)
replace `var' = subinstr(`var' , "chick_v" ,"chikv" ,.)
replace `var' = subinstr(`var' , "diabetic" ,"gest_diab" ,.)
replace `var' = subinstr(`var' , "extreme_morning_sickness" ,"hyperemesis_gr" ,.)
replace `var' = subinstr(`var' , "high_blood_pressure" ,"hypert" ,.)
replace `var' = subinstr(`var' , "spotting_blood" ,"pv_bleed" ,.)
replace `var' = subinstr(`var' , "vomiting,_diarrhea,_cramps" ,"breach" ,.)
rename `var' preg_ill
}
gen lab_complic_placental_abruption = .
order lab_complic_placental_abruption 
replace  lab_complic_placental_abruption= 1 if preg_ill== "rupture_if_placenta"
replace  lab_complic_breach = 1 if preg_ill== "the_baby_was_breached"

foreach var of varlist preg_ill{ 			
foreach symptom in  "anemia" "breach" "acid_reflux" "chikv" "placental_abruption" "sickle_cell" "pv_bleed" "syphillis" "uti" "gastroenteritis" "hyperemesis_gr" "gest_diab" "hypert"{
						tostring `var', replace
						replace `var'=trim(itrim(lower(`var')))
						moss `var', match(`symptom') prefix(preg_ill`symptom')

						gen `var'_`symptom'=0
						replace `var'_`symptom'= 1 if strpos(`var', "`symptom'")
						replace `var'= subinstr(`var', "`symptom'", "",.)
						order `var'_`symptom'
						tab `var'_`symptom'
}
}	

gen related_caesarean= 0 if caesarean !=""
order related_caesarean
replace related_caesarean=1 if strpos(caesarean, "Heart rate of child dropped")
replace related_caesarean=1 if strpos(caesarean, "Separated placenta")

egen count_preg_ill= rowtotal( preg_ill_hypert preg_ill_gest_diab preg_ill_hyperemesis_gr preg_ill_gastroenteritis preg_ill_uti preg_ill_syphillis preg_ill_pv_bleed preg_ill_sickle_cell preg_ill_placental_abruption preg_ill_acid_reflux preg_ill_breach preg_ill_anemia)
egen count_baby_health= rowtotal(baby_health_*)
egen count_lab_complic= rowtotal(lab_complic_*)
egen count_abp= rowtotal(abp_*)

order preg_chikvpos 
tab preg_chikvpos  trimester, m


outsheet using final_data.csv, replace comma names

tab  hospitalized_pregnancy  preg_chikvpos , chi2
replace result_child =. if result_child ==99
*tables
*demographic tables
table1, vars(race cat \ mom_age contn \ education cate \ marrital_status bine \ monthly_income cate \  medical_conditions___6 bine \ medical_conditions___10 bine\ alcohol  bine \ smoking bine \ ) by(preg_chikvpos) saving("`tables'demographics_bygroups_$S_DATE.xls", replace) test 

*pregnancy outcomes table
table1, vars(birth_time cate \ mode_of_delivery bine\ gestational_age_weekfrac conts \ count_abp cate\ count_lab_complic cate\ count_preg_ill cate\ count_baby_health cate\ ) by(preg_chikvpos) saving("`tables'pregnancy_bygroups_$S_DATE.xls", replace) test 

*symptoms table
table1, vars(symptoms___1 bine\ symptoms___2 bine\ symptoms___3 bine\ symptoms___4 bine\ symptoms___5 bine\ symptoms___6 bine\ symptoms___7 bine\ symptoms___8 bine\ symptoms___9 bine\ symptoms___10 bine\ symptoms___11 bine\ symptoms___12 bine\ symptoms___13 bine\ symptoms___14 cate \ symptoms___15 bine\ symptoms___16 bine\ symptoms___17 cate \ symptoms___18 bine\ symptoms___19 bine\ symptoms___20 cate \ symptoms___21 bine\ symptoms___22 bine\ symptoms___23 bine\ symptoms___24 bine\ symptoms___25 bine\ symptoms___26 cate \ symptoms___27 cate \ symptoms___28 cate \ symptoms___29 cate \ symptoms___30 cate \ symptoms___31 cate \ symptoms___32 cate \ symptoms___33 cate \ symptoms___34 bine)  by(preg_chikvpos) saving("`tables'symptoms_group_$S_DATE.xls", replace) test 

*symptoms table by chikv during or not during preg
table1, vars(symptoms___1 cate\ symptoms___2 cate\ symptoms___3 cate\ symptoms___4 cate\ symptoms___5 cate\ symptoms___6 cate\ symptoms___7 cate\ symptoms___8 cate\ symptoms___9 cate\ symptoms___10 cate\ symptoms___11 cate\ symptoms___12 cate\ symptoms___13 cate\ symptoms___14 cate \ symptoms___15 cate\ symptoms___16 cate\ symptoms___17 cate \ symptoms___18 cate\ symptoms___19 cate\ symptoms___20 cate \ symptoms___21 cate\ symptoms___22 cate\ symptoms___23 cate\ symptoms___24 cate\ symptoms___25 cate\ symptoms___26 cate \ symptoms___27 cate \ symptoms___28 cate \ symptoms___29 cate \ symptoms___30 cate \ symptoms___31 cate \ symptoms___32 cate \ symptoms___33 cate \ symptoms___34 cate \ symptom_duration conts)  by(chikv_preg_non) saving("`tables'symptoms_chikv_preg_non_$S_DATE.xls", replace) test 

*breakdown_of_pregnancy_outcomes 
table1, vars(result_child bine \ count_abp cate\ count_lab_complic cate\ count_baby_health cate\ count_preg_ill cate\ related_caesarean  cate \ preg_ill_gest_diab  cate \ preg_ill_hyperemesis_gr  cate \ preg_ill_gastroenteritis  cate \ preg_ill_uti  cate \ preg_ill_syphillis  cate \ preg_ill_pv_bleed  cate \ preg_ill_sickle_cell  cate \ preg_ill_placental_abruption  cate \  preg_ill_acid_reflux  cate \ preg_ill_breach  cate \ preg_ill_anemia  cate \ baby_health_sickle_cell  cate \ baby_health_respiratory  cate \ baby_health_jaundice  cate \ baby_health_nicu  cate \ baby_health_murmur  cate \ baby_health_chikv  cate \ baby_health_anemia  cate \ baby_health_allergies  cate \ lab_complic_swollen  cate \ lab_complic_prolonged_labour  cate \ lab_complic_placenta_previa  cate \ lab_complic_cord_around_neck  cate \ lab_complic_chikv_pain  cate \ lab_complic_tear  cate \ lab_complic_breach  cate \ lab_complic_hemorrhage  cate \ abp_rash  cate \ abp_eczema  cate \ abp_allergies  cate \ abp_sickle_cell  cate \ abp_sinus  cate \ abp_swelling  cate \ abp_seizures  cate \ abp_jaundice  cate \ abp_viral  cate \ abp_sepsis  cate \ abp_unknown  cate \ abp_malformation  cate \ abp_respiratory  cate \ abp_chikv cate \) by(preg_chikvpos) saving("`tables'breakdown_of_pregnancy_outcomes_$S_DATE.xls", replace) test 

*desiree's queries
		*check for those with lab data but no interview data
			gen lab_done_no_interview = . 
			replace lab_done_no_interview  =1 if result_child !=. & primary_date==. |result_mother!=. & primary_date==. 
			tab lab_done_no_interview  
			list participant_id if lab_done_no_interview  ==1, clean

		*Desiree LaBeaud <dlabeaud@stanford.edu>: Will be beat to see if the positive kids are any different than the negative ones that all come from positive moms [reporting to have chikv during pregnancy?]. 
		tab result_child preg_chikvpos, chi2
		gen kids_pos_moms = .
		replace kids_pos_moms =1 if preg_chikvpos==1 & result_child ==1
		replace kids_pos_moms =0 if preg_chikvpos ==1 & result_child ==0
		tab kids_pos_moms 
		
			*demographic tables
			table1, vars(race cat \ mom_age contn \ education cate \ marrital_status bine \ monthly_income cate \  medical_conditions___6 bine \ medical_conditions___10 bine\ alcohol  bine \ smoking bine \ ) by(kids_pos_moms) saving("`tables'demographics_kids_pos_moms_$S_DATE.xls", replace) test 

			*pregnancy outcomes table
			table1, vars(birth_time cate \ mode_of_delivery bine\ gestational_age_weekfrac conts \ count_abp cate\ count_lab_complic cate\ count_preg_ill cate\ count_baby_health cate\ ) by(kids_pos_moms) saving("`tables'pregnancy_kids_pos_moms_$S_DATE.xls", replace) test 

			*symptoms table
			table1, vars(symptoms___1 bine\ symptoms___2 bine\ symptoms___3 bine\ symptoms___4 bine\ symptoms___5 bine\ symptoms___6 bine\ symptoms___7 bine\ symptoms___8 bine\ symptoms___9 bine\ symptoms___10 bine\ symptoms___11 bine\ symptoms___12 bine\ symptoms___13 bine\ symptoms___14 cate \ symptoms___15 bine\ symptoms___16 bine\ symptoms___17 cate \ symptoms___18 bine\ symptoms___19 bine\ symptoms___20 cate \ symptoms___21 bine\ symptoms___22 bine\ symptoms___23 bine\ symptoms___24 bine\ symptoms___25 bine\ symptoms___26 cate \ symptoms___27 cate \ symptoms___28 cate \ symptoms___29 cate \ symptoms___30 cate \ symptoms___31 cate \ symptoms___32 cate \ symptoms___33 cate \ symptoms___34 bine)  by(kids_pos_moms) saving("`tables'kids_pos_moms_$S_DATE.xls", replace) test 

			*breakdown_of_pregnancy_outcomes 
			table1, vars(result_child bine \ count_abp cate\ count_lab_complic cate\ count_baby_health cate\ count_preg_ill cate\ related_caesarean  cate \ preg_ill_gest_diab  cate \ preg_ill_hyperemesis_gr  cate \ preg_ill_gastroenteritis  cate \ preg_ill_uti  cate \ preg_ill_syphillis  cate \ preg_ill_pv_bleed  cate \ preg_ill_sickle_cell  cate \ preg_ill_placental_abruption  cate \  preg_ill_acid_reflux  cate \ preg_ill_breach  cate \ preg_ill_anemia  cate \ baby_health_sickle_cell  cate \ baby_health_respiratory  cate \ baby_health_jaundice  cate \ baby_health_nicu  cate \ baby_health_murmur  cate \ baby_health_chikv  cate \ baby_health_anemia  cate \ baby_health_allergies  cate \ lab_complic_swollen  cate \ lab_complic_prolonged_labour  cate \ lab_complic_placenta_previa  cate \ lab_complic_cord_around_neck  cate \ lab_complic_chikv_pain  cate \ lab_complic_tear  cate \ lab_complic_breach  cate \ lab_complic_hemorrhage  cate \ abp_rash  cate \ abp_eczema  cate \ abp_allergies  cate \ abp_sickle_cell  cate \ abp_sinus  cate \ abp_swelling  cate \ abp_seizures  cate \ abp_jaundice  cate \ abp_viral  cate \ abp_sepsis  cate \ abp_unknown  cate \ abp_malformation  cate \ abp_respiratory  cate \ abp_chikv cate \) by(kids_pos_moms) saving("`tables'breakdown_of_pregnancy_outcomes_kids_pos_moms_$S_DATE.xls", replace) test 
