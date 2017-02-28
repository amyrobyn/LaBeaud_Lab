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
Early Term:  Between 37 weeks 0 days and 38 weeks 6 days
Full Term:    Between 39 weeks 0 days and 40 weeks 6 days
Late Term:   Between 41 weeks 0 days and 41 weeks 6 days
Postterm:     Between 42 weeks 0 days and beyond*/

gen gestational_age_cat= .
replace gestational_age_cat = 0 if gestational_age_weekfrac  >=39 & gestational_age_weekfrac <41
replace gestational_age_cat = 1 if gestational_age_weekfrac  < 39
replace gestational_age_cat = 2 if gestational_age_weekfrac  >=41 & gestational_age_weekfrac  <42
replace gestational_age_cat = 3 if gestational_age_weekfrac  >=42 & gestational_age_weekfrac <.
label variable gestational_age_cat "gestational_age_categories"
label define gestational_age_cat  0 "full term" 1 "early term" 2 "late term" 3 "post term" , modify
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
 
tabout trimester gestational_age_cat if smoking ==0 using trimeste_vs_gestational_agecat.xls , stats(chi2) replace h1("trimeste vs gestational agecat(row %)") h2( "|full term | early term | late term | post term | Total" ) h3("Didn't Smoke") lines(none)
tabout trimester gestational_age_cat if smoking ==1 using trimeste_vs_gestational_agecat.xls , stats(chi2) append h1("Smoked") h2(nil) h3(nil)
tabout trimester gestational_age_cat using trimeste_vs_gestational_agecat.xls , stats(chi2) append h1("All") h2(nil) h3(nil)

tabout trimester birth_time if smoking ==0 using trimester_vs_bith_time.xls , stats(chi2) replace h1("trimester vs bith time(row %)") h2( "|full term | early term | late term | post term | Total" ) h3("Didn't Smoke") lines(none)
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
table1, vars(pregnancy_illness bin \ birth_time cat \ gestational_age_cat cat \ alcohol bin \ smoking bin \ drugs bin \ marijuana cat \ meth cat \ heroine cat \ cocaine cat \ opioids bin\ mode_of_delivery bin\ complications bin\ birthing_experience cat \ labour_duration conts \ after_birth_problems bin\ first_few_months_illness bin\ disabilities cat \ race cat \ education cat \ mom_age contn \ monthly_income cat \ symptoms___1 bin\ symptoms___2 bin\ symptoms___3 bin\ symptoms___4 bin\ symptoms___5 bin\ symptoms___6 bin\ symptoms___7 bin\ symptoms___8 bin\ symptoms___9 bin\ symptoms___10 bin\ symptoms___11 bin\ symptoms___12 bin\ symptoms___13 bin\ symptoms___14 cat \ symptoms___15 bin\ symptoms___16 bin\ symptoms___17 cat \ symptoms___18 bin\ symptoms___19 bin\ symptoms___20 cat \ symptoms___21 bin\ symptoms___22 bin\ symptoms___23 bin\ symptoms___24 bin\ symptoms___25 bin\ symptoms___26 cat \ symptoms___27 cat \ symptoms___28 cat \ symptoms___29 cat \ symptoms___30 cat \ symptoms___31 cat \ symptoms___32 cat \ symptoms___33 cat \ symptoms___34 bin\ opioid_amount conts \ gestational_age_weekfrac contn \ symptom_duration contn \ alcohol_amount contn \)  by(preg_chikvpos) saving(table2.xls, replace)

foreach var in list_pregnancy_illness specify_complications  specify_after_birth_problems specify_first_few_months  specify_disabilities caesarean{
	tabout `var' using tocategorize\tab`var'.xls, replace
}
