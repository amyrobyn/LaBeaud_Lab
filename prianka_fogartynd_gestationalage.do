set graphics on 
capture log close 
set scrollbufsize 100000
set more 1
log using "fogartynd_gestationalage.smcl", text replace 
set scrollbufsize 100000
set more 1

cd "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\priyanka- fogarty nd"
insheet using "FogartyNDCHIKV_DATA_2017-02-27_1939.csv", comma clear

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

foreach var in trimester symptom_duration pregnancy_illness birth_time opioids complications birthing_experience after_birth_problems race monthly_income{
	replace `var'= . if `var'==99
}
*drop if pregnant ==99 | pregnant ==. 
tab pregnant ever_had_chikv, m

gen preg_chikvpos = .
replace preg_chikvpos = 1 if pregnant ==1 
replace preg_chikvpos = 0 if pregnant == 0 | ever_had_chikv ==0
tab preg_chikvpos 
label define gestational_age_cat  0 "full-term" 1 "pre-term" 2 "post-term" , modify 
tabout trimester gestational_age_cat if smoking ==0 using trimeste_vs_gestational_agecat.xls , stats(chi2) replace h1("trimeste vs gestational agecat(row %)") h2( "|full-term | pre-term | post-term | Total" ) h3("Didn't Smoke") lines(none)
tabout trimester gestational_age_cat if smoking ==1 using trimeste_vs_gestational_agecat.xls , stats(chi2) append h1("Smoked") h2(nil) h3(nil)
tabout trimester gestational_age_cat using trimeste_vs_gestational_agecat.xls , stats(chi2) append h1("All") h2(nil) h3(nil)

tabout trimester birth_time if smoking ==0 using trimester_vs_bith_time.xls , stats(chi2) replace h1("trimester vs bith time(row %)") h2( "|full-term | pre-term | post-term | Total" ) h3("Didn't Smoke") lines(none)
tabout trimester birth_time if smoking ==1 using trimester_vs_bith_time.xls , stats(chi2) append h1("Smoked") h2(nil) h3(nil)
tabout trimester birth_time using trimester_vs_bith_time.xls , stats(chi2) append h1("All") h2(nil) h3(nil)


*dob 
foreach var in primary_date dob {
				gen `var'1 = date(`var', "MDY")
				format %td `var'1 
				drop `var'
				rename `var'1 `var'
				recast int `var'
				}
sort dob
gen mom_age= primary_date - dob  
replace mom_age = round(mom_age/365.25)
sum mom_age
replace mom_age =. if mom_age <15 

replace mode_of_delivery = mode_of_delivery -1
bysort preg_chikvpos:sum smoking_amount marijuana_amount opioid_amount 
*table1, vars(pregnancy_illness bin \ birth_time cat \ gestational_age_cat cat \ alcohol bin \ smoking bin \ drugs bin \ marijuana cat \ meth cat \ heroine cat \ cocaine cat \ opioids bin\ mode_of_delivery bin\ complications bin\ birthing_experience cat \ labour_duration conts \ after_birth_problems bin\ first_few_months_illness bin\ disabilities cat \ race cat \ education cat \ mom_age contn \ monthly_income cat \ symptoms___1 bin\ symptoms___2 bin\ symptoms___3 bin\ symptoms___4 bin\ symptoms___5 bin\ symptoms___6 bin\ symptoms___7 bin\ symptoms___8 bin\ symptoms___9 bin\ symptoms___10 bin\ symptoms___11 bin\ symptoms___12 bin\ symptoms___13 bin\ symptoms___14 cat \ symptoms___15 bin\ symptoms___16 bin\ symptoms___17 cat \ symptoms___18 bin\ symptoms___19 bin\ symptoms___20 cat \ symptoms___21 bin\ symptoms___22 bin\ symptoms___23 bin\ symptoms___24 bin\ symptoms___25 bin\ symptoms___26 cat \ symptoms___27 cat \ symptoms___28 cat \ symptoms___29 cat \ symptoms___30 cat \ symptoms___31 cat \ symptoms___32 cat \ symptoms___33 cat \ symptoms___34 bin\ opioid_amount conts \ gestational_age_weekfrac contn \ symptom_duration contn \ alcohol_amount contn \ medical_conditions___10 bin\ medical_conditions___6 bin \  marrital_status bin)  by(preg_chikvpos) saving(table2.xls, replace)
sum reason_hospitalized when_hospitalized duration_hospitalized hospitalized_dengue hospitalized_ever

foreach var in list_pregnancy_illness specify_complications  specify_after_birth_problems specify_first_few_months  specify_disabilities caesarean{
	tabout `var' using tocategorize\tab`var'.xls, replace
}


bysort birth_time: sum preg_chikvpos pregnancy_illness opioids mode_of_delivery complications birthing_experience labour_duration after_birth_problems first_few_months_illness race  education mom_age monthly_income  symptom_duration hospitalized_ever  
mlogit birth_time preg_chikvpos pregnancy_illness opioids mode_of_delivery complications birthing_experience labour_duration after_birth_problems first_few_months_illness race  education mom_age monthly_income  symptom_duration hospitalized_ever  
*opioid_amount  marijuana meth heroine cocaine alcohol_amount 
*symptoms___14 symptoms___26 symptoms___27 symptoms___28 symptoms___29 symptoms___30 symptoms___31 symptoms___32 symptoms___33 symptoms___20 symptoms___17 disabilities alcohol smoking drugs  symptoms___6 symptoms___7  symptoms___12 symptoms___13 symptoms___15 symptoms___16 symptoms___18 symptoms___19 symptoms___21 symptoms___22 symptoms___23 symptoms___24  symptoms___34  

foreach var of varlist specify_after_birth_problems { 			
		replace `var'= subinstr(`var', " ", "_",.)
}

replace specify_after_birth_problems = lower(specify_after_birth_problems)
replace specify_after_birth_problems= subinstr(specify_after_birth_problems, "mucus_on_chest" ,"respiratory" ,.)
replace specify_after_birth_problems= subinstr(specify_after_birth_problems, "breathing_problems" ,"respiratory" ,.)
replace specify_after_birth_problems= subinstr(specify_after_birth_problems, "cartilage_in_trachea_did_not_develop_properly" ,"malformation" ,.)
replace specify_after_birth_problems= subinstr(specify_after_birth_problems, "club_foot" ,"malformation" ,.)
replace specify_after_birth_problems= subinstr(specify_after_birth_problems, "chikungunya" ,"chikv" ,.)
replace specify_after_birth_problems= subinstr(specify_after_birth_problems, "draft_in_his_eye" ,"unknown" ,.)
replace specify_after_birth_problems= subinstr(specify_after_birth_problems, "required_flush" ,"unknown" ,.)
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
replace specify_complications= subinstr(specify_complications, "chikv_pain" ,"tear" ,.)
replace specify_complications= subinstr(specify_complications, "child_on_posterior" ,"" ,.)
replace specify_complications= subinstr(specify_complications, "placenta_previa" ,"prolonged_labour" ,.)
replace specify_complications= subinstr(specify_complications, "swekling_on_baby_head" ,"swollen" ,.)

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

replace `var' = subinstr(`var' , "chick_v" ,"chikv" ,.)
replace `var' = subinstr(`var' , "chikungunya" ,"chikv" ,.)
replace `var' = subinstr(`var' , "diabetic" ,"gest_diab" ,.)
replace `var' = subinstr(`var' , "extreme_morning_sickness" ,"hyperemesis_gr" ,.)
replace `var' = subinstr(`var' , "high_blood_pressure" ,"hypert" ,.)
replace `var' = subinstr(`var' , "rupture_if_placenta" ,"placental_abruption" ,.)
replace `var' = subinstr(`var' , "spotting_blood" ,"pv_bleed" ,.)
replace `var' = subinstr(`var' , "the_baby_was_breached" ,"breach" ,.)
replace `var' = subinstr(`var' , "vomiting,_diarrhea,_cramps" ,"breach" ,.)
rename `var' preg_ill
}

foreach var of varlist preg_ill{ 			
foreach symptom in  "anemia" "breach" "acid_reflux " "chikv"  "placental_abruption" "sickle_cell" "pv_bleed" "syphillis" "uti" "gastroenteritis" "hyperemesis_gr" "gest_diab" "hypert"{
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

table1, vars(  count_abp cat\ count_lab_complic cat\ count_baby_health cat\ count_preg_ill cat\ related_caesarean  cat \ preg_ill_gest_diab  cat \ preg_ill_hyperemesis_gr  cat \ preg_ill_gastroenteritis  cat \ preg_ill_uti  cat \ preg_ill_syphillis  cat \ preg_ill_pv_bleed  cat \ preg_ill_sickle_cell  cat \ preg_ill_placental_abruption  cat \ \ preg_ill_acid_reflux  cat \ preg_ill_breach  cat \ preg_ill_anemia  cat \ baby_health_sickle_cell  cat \ baby_health_respiratory  cat \ baby_health_jaundice  cat \ baby_health_nicu  cat \ baby_health_murmur  cat \ baby_health_chikv  cat \ baby_health_anemia  cat \ baby_health_allergies  cat \ lab_complic_swollen  cat \ lab_complic_prolonged_labour  cat \ lab_complic_placenta_previa  cat \ lab_complic_cord_around_neck  cat \ lab_complic_chikv_pain  cat \ lab_complic_tear  cat \ lab_complic_breach  cat \ lab_complic_hemorrhage  cat \ abp_rash  cat \ abp_eczema  cat \ abp_allergies  cat \ abp_sickle_cell  cat \ abp_sinus  cat \ abp_swelling  cat \ abp_seizures  cat \ abp_jaundice  cat \ abp_viral  cat \ abp_sepsis  cat \ abp_unknown  cat \ abp_malformation  cat \ abp_respiratory  cat \ abp_chikv cat \) by(preg_chikvpos) saving(table3.xls, replace) test missing
