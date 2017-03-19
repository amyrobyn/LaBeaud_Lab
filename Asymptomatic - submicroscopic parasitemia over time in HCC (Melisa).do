/********************************************************************
 *amy krystosik                  							  		*
 *Asymptomatic/submicroscopic parasitemia over time in HCC (Melisa)	*
 *lebeaud lab               				        		  		*
 *last updated march 18, 2017  							  			*
 ********************************************************************/ 
capture log close 
set more 1
set scrollbufsize 100000
cd "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\Asymptomatic-submicroscopic parasitemia over time in HCC (Melisa)"
log using "LOG Asymptomatic-submicroscopic parasitemia over time in HCC (Melisa).smcl", text replace 

local figures "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\Asymptomatic-submicroscopic parasitemia over time in HCC (Melisa)\draft figures\"
local data "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\Asymptomatic-submicroscopic parasitemia over time in HCC (Melisa)\data\"

use "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\all linked and cleaned data\data\cleaned_merged_data", replace


/*
Asymptomatic/submicroscopic parasitemia over time in HCC (Melisa)
Impacts on growth
Amy send melissa table 1 
No malaria pos vs malaria pos 1 or many times
Exclude those w fever today
	Malaria history- we don't have for hcc
Growth trajectory over time by number of malaria times- done
Demographics, location, growth variables, bednets, season, year
	Add in mosq, climate later if needed
*/

keep if cohort == 2
keep if fevertoday   == 0

encode id_wide, gen(id) 
xtset id visit_int

bysort id_wide: egen mal_freq = sum(malariapositive_dum)
foreach var in zhcaukwho zwtukwho zhtukwho zbmiukwho zheart_rate zsystolicbp zdiastolicbp zpulseoximetry ztemperature zresprate zlen zwei zwfl zbmi zhc zac zts zss{
bysort mal_freq visit: egen mean`var' = mean(`var')
order mean`var'
}
*xtline zwtukwho  if id < 10, overlay legend(off) 
graph drop _all
egen malfreq_visit = concat(visit_int mal_freq)

*growth_by_malariafreq
table1, vars(zwtukwho contn \ zhtukwho contn \ zbmiukwho contn\) test missing by(malfreq_visit) saving("`figures'growth_by_malariafreq.xls", replace) 

/*
egen mal_freq_group= group(mal_freq) 
sum mal_freq_group, meanonly 

foreach var in meanzwtukwho meanzhtukwho meanzbmiukwho{
forval i = 1/`r(mean)' { 
	xtline `var' if mal_freq_group == `i', overlay name(gr`i') 
	local graphs `graphs' gr`i'
}  
*/
*graph doesn't work in stata. export to do in excel
export excel mal_freq visit   meanzwtukwho meanzhtukwho meanzbmiukwho using tables, replace firstrow(variables)

*Demographics, location, growth variables, bednets, season, year
drop  gametocytes1 gametocytes2

table1, vars(zbmiukwho conts \ zhtukwho conts \ zwtukwho conts \ age contn \ gender bin\ city cat \ site cat \ year cat \ season cat \ month cat \ seasonyear cat \ cohort cat \ sleepbednet_dum cat \ hccsesindexrooms contn\  mosqbitefreq cat \mosquitocoil cat \mosquitobites cat \mosquitoday cat \mosquitonight cat \mosquitobitefreq cat \mosqbitedaytime cat \mosqbitenight cat \mosquito_exposure_index cat \mosq_prevention_index contn\) test missing by(mal_freq ) saving("`figures'table_by_malariafreq.xls", replace) 

* vars(zwtukwho contn \ zhtukwho contn \ zbmiukwho contn\) 
table1 , vars(all_symptoms_altms cat \ all_symptoms_jaundice cat \ all_symptoms_bleeding_symptom cat \ all_symptoms_imp_mental cat \ all_symptoms_mucosal_bleed_brs cat \ all_symptoms_bloody_nose cat \ all_symptoms_fever cat \ ) test missing by(mal_freq) saving("`figures'symptoms_by_malariafreq.xls", replace) 
