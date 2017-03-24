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


use "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\all linked and cleaned data\data\cleaned_merged_prevalence", replace

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
dropmiss, force
encode id_wide, gen(id) 
xtset id visit_int

replace parasite_count_lab = parasite_count_hcc if parasite_count_lab ==.
compare parasite_count_lab parasite_count_hcc 
replace malariapositive_dum2 =1 if parasite_count_lab >0 & parasite_count_lab !=.
replace malariapositive_dum2 =0 if parasite_count_lab ==0 
tab species malariapositive_dum 

bysort id_wide: egen mal_freq = sum(malariapositive_dum2)
	foreach var in  zwtukwho zhtukwho zbmiukwho{
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
replace mal_freq  =2 if mal_freq >1 & mal_freq !=.
label variable mal_freq "REPEAT MALARIA INFECTION"
label define mal_freq  0 "NONE" 1 "ONE" 2 "MORE THAN ONE", modify
label values mal_freq  mal_freq  mal_freq 
tab mal_freq 

**collapse by id_wide
drop id
encode id_wide, gen(id)
drop id_wide
tsset id visit_int

desc gametocytes    parasite_count_lab  zbmiukwho  zhtukwho  zwtukwho  age  gender      year  season  month    cohort  sleepbednet_dum  mosquitocoil  mosquitobites  mosquitoday  mosquitonight  mosquitobitefreq  mosqbitedaytime  mosqbitenight  mosquito_exposure_index  mosq_prevention_index  hccses_index_sum  hccsesindeximprovedfuel_index  hccsesindeximprovedwater_index  hccsesindeximprovedlight_index  hccsesindextv  hccsesindexmotor_vehicle  hccsesindexdomestic_worker  hccsesindexownflushtoilet  hccsesindexlatrine_index  hccsesindexland_index  hccsesindexrooms  hccsesindexbedrooms  hccsesindeximprovedroof_index  hccsesindeximprovedfloor_index  sleepbednet  hoh_own_bednet  hoh_number_bednet  hoh_sleep_bednet  hoh_kids_sleep_bednet  usebednet  childrenusebednet  own_bednet  number_bednet  sleep_bednet
collapse2  (first) gametocytes  (first) species (first) city  (first) site  (first) seasonyear (first) mosquitobitefreq (first) mosqbitefreq  (firstnm) parasite_count_lab (firstnm) zbmiukwho (firstnm) zhtukwho (firstnm) zwtukwho (firstnm) age (firstnm) gender (firstnm) year (firstnm) season (firstnm) month (firstnm) cohort (firstnm) sleepbednet_dum (firstnm) mosquitocoil (firstnm) mosquitobites (firstnm) mosquitoday (firstnm) mosquitonight (firstnm) mosqbitedaytime (firstnm) mosqbitenight (firstnm) mosquito_exposure_index (firstnm) mosq_prevention_index (firstnm) hccses_index_sum (firstnm) hccsesindeximprovedfuel_index (firstnm) hccsesindeximprovedwater_index (firstnm) hccsesindeximprovedlight_index (firstnm) hccsesindextv (firstnm) hccsesindexmotor_vehicle (firstnm) hccsesindexdomestic_worker (firstnm) hccsesindexownflushtoilet (firstnm) hccsesindexlatrine_index (firstnm) hccsesindexland_index (firstnm) hccsesindexrooms (firstnm) hccsesindexbedrooms (firstnm) hccsesindeximprovedroof_index (firstnm) hccsesindeximprovedfloor_index (firstnm) sleepbednet (firstnm) hoh_own_bednet (firstnm) hoh_number_bednet (firstnm) hoh_sleep_bednet (firstnm) hoh_kids_sleep_bednet (firstnm) usebednet (firstnm) childrenusebednet (firstnm) own_bednet (firstnm) number_bednet (firstnm) sleep_bednet, by(id)


table1, vars(gametocytes conts \ species cat \ parasite_count_lab  contn \  zbmiukwho conts \ zhtukwho conts \ zwtukwho conts \ age contn \ gender bin\ city cat \ site cat \ year cat \ season cat \ month cat \ seasonyear cat \ cohort cat \ sleepbednet_dum cat \  mosqbitefreq cat \mosquitocoil cat \mosquitobites cat \mosquitoday cat \mosquitonight cat \mosquitobitefreq cat \mosqbitedaytime cat \mosqbitenight cat \mosquito_exposure_index cat \mosq_prevention_index contn \ hccses_index_sum contn \ hccsesindeximprovedfuel_index cat \ hccsesindeximprovedwater_index cat \ hccsesindeximprovedlight_index cat \ hccsesindextv cat \ hccsesindexmotor_vehicle cat \ hccsesindexdomestic_worker cat \ hccsesindexownflushtoilet cat \ hccsesindexlatrine_index cat \ hccsesindexland_index cat \ hccsesindexrooms cat \ hccsesindexbedrooms cat \ hccsesindeximprovedroof_index cat \ hccsesindeximprovedfloor_index cat \  sleepbednet cat \ hoh_own_bednet cat \ hoh_number_bednet cat \ hoh_sleep_bednet cat \ hoh_kids_sleep_bednet cat \ usebednet cat \ childrenusebednet cat \ own_bednet cat \ number_bednet cat \ sleep_bednet cat \sleepbednet_dum cat \) test missing by(mal_freq ) saving("`figures'table_by_malariafreq$S_DATE.xls", replace) 


table1 , vars(all_symptoms_altms cat \ all_symptoms_jaundice cat \ all_symptoms_bleeding_symptom cat \ all_symptoms_imp_mental cat \ all_symptoms_mucosal_bleed_brs cat \ all_symptoms_bloody_nose cat \ all_symptoms_fever cat \ ) test missing by(mal_freq) saving("`figures'symptomslast6mnths_by_malariafreq$S_DATE.xls", replace) 
