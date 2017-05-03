 /********************************************************************
 *asmy krystosik  NUEVO CAMBIO 10:03  mas cambios       							  		*
 *Asymptomatic/submicroscopic parasitemia over time in HCC (Melisa)	*
 *lebeaud lab               				        		  		*
 *last updated march 18, 2017  							  			*
 ********************************************************************/ 
capture log close 
set more 1
set scrollbufsize 100000
cd "C:\Users\amykr\Box Sync\Amy Krystosik's Files\ASTMH 2017 abstracts\Asymptomatic-submicroscopic parasitemia over time in HCC (Melisa)"
log using "LOG Asymptomatic-submicroscopic parasitemia over time in HCC (Melisa).smcl", text replace 

local figures "C:\Users\amykr\Box Sync\Amy Krystosik's Files\ASTMH 2017 abstracts\Asymptomatic-submicroscopic parasitemia over time in HCC (Melisa)\draft figures\"
local data "C:\Users\amykr\Box Sync\Amy Krystosik's Files\ASTMH 2017 abstracts\Asymptomatic-submicroscopic parasitemia over time in HCC (Melisa)\data\"

use "C:\Users\amykr\Box Sync\Amy Krystosik's Files\ASTMH 2017 abstracts\all linked and cleaned data\data\cleaned_merged_prevalence", replace

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
replace species  = species_cat if species  ==""

*asymptomatic malaria means hcc + no fever
	keep if cohort == 2
	keep if fevertoday == 0
	dropmiss, force

*clean up bednet		
	replace hoh_sleep_bednet =sleepbednet if hoh_sleep_bednet ==.
	replace hoh_sleep_bednet =usebednet if hoh_sleep_bednet ==.
	drop sleepbednet usebednet 
	replace hoh_kids_sleep_bednet = childrenusebednet if hoh_kids_sleep_bednet ==.
	drop childrenusebednet 
*clean up mosq
	replace mosquitocoil = usemosqcoil if mosquitocoil ==.
	drop usemosqcoil 
*clean up mosqbitfreq
	tostring  mosquitobitefreq mosqbitefreq, replace
	replace mosqbitefreq = mosquitobitefreq if  mosqbitefreq  =="."|mosquitobitefreq ==""
	tab mosqbitefreq 
	drop mosquitobitefreq 
	replace mosqbitefreq ="1" if mosqbitefreq =="daily"
	replace mosqbitefreq ="2" if mosqbitefreq =="every_other_day"
	replace mosqbitefreq ="3" if mosqbitefreq =="weekly"
	replace mosqbitefreq ="5" if mosqbitefreq =="monthly"
	replace mosqbitefreq ="6" if mosqbitefreq =="every_other_month"
	replace mosqbitefreq ="8" if mosqbitefreq =="refused"
	destring mosqbitefreq , replace 
	tab mosqbitefreq 
*stset data
	capture drop id 
	encode id_wide, gen(id)
	stset visit_int, id(id) f(malariapositive_dum)

*************use the malariapositive_dum2 **************
replace parasite_count_lab = parasite_count_hcc if parasite_count_lab ==.
compare parasite_count_lab parasite_count_hcc 
replace malariapositive_dum2 =1 if parasite_count_lab >0 & parasite_count_lab !=.
replace malariapositive_dum2 =0 if parasite_count_lab==0 
tab species malariapositive_dum 
drop malariapositive_dum 
rename malariapositive_dum2 malariapositive_dum

*survival data
	stdescribe
	sts list
		stgen no_malaria= always(malariapositive_dum==0 |malariapositive_dum==. )
		stgen when_malaria= when(malariapositive_dum==1)
		tab when_malaria visit_int
		
		stgen prev_malaria= ever(malariapositive_dum==1)
		tab prev_malaria

		tab no_malaria
		gen malaria_prev = .
		replace malaria_prev = 1 if prev_malaria==1
		replace malaria_prev = 0 if no_malaria ==1
		tab malaria_prev 
		bysort id: egen minvisit = min(visit_int) if no_malaria ==1 
		tab minvisit 
		drop if no_malaria ==1 & visit_int !=minvisit
		tab malaria_prev 

	*create the malaria yes/no bin. 
		drop if when_malaria==1 & visit!="a"|when_malaria==2 & visit!="b"|when_malaria==3 & visit!="c"|when_malaria==4 & visit!="d"
		drop if when_malaria  ==. & no_malaria !=1
			gen asympt_malaria_cat =. 
			replace asympt_malaria_cat= 1 if no_malaria ==0
			replace asympt_malaria_cat= 0 if no_malaria ==1

*clean up species
		replace species = "pf/pm" if species =="pfpm"
		replace species = "neg" if species =="0" & asympt_malaria_cat==0
		replace species = "neg" if species =="" & asympt_malaria_cat==0
		replace species = "neg" if asympt_malaria_cat==0




**fsum by malaria
	sum asympt_malaria_cat gametocytes species parasite_count_lab  
	bysort asympt_malaria_cat: sum hoh_sleep_bednet hoh_kids_sleep_bednet hoh_own_bednet hoh_number_bednet sleepbednet_dum 
	bysort asympt_malaria_cat: sum cohort age gender city site year season month seasonyear 
	
	bysort asympt_malaria_cat: sum  mosquito_exposure_index  mosq_prevention_index mosqbitefreq  mosquitocoil mosquitobites mosquitoday mosquitonight mosqbitedaytime mosqbitenight  avoidmosquitoes hoh_mosquito_control 
	bysort asympt_malaria_cat: sum hccses_index_sum hccsesindexmotor_vehicle hccsesindexdomestic_worker hccsesindexland_index hccsesindeximprovedroof_index hccsesindeximprovedfloor_index  hoh_room hoh_bedroom

label variable childmerge  "demography information at child level, merge status"
label variable hhmerge "demography information at household level, merge status"
label define childmerge  1 "No demography data" 3 "merged with demography data" , modify
label values childmerge  childmerge  
label define hhmerge  1 "No demography data" 3 "merged with demography data" , modify
label values hhmerge  hhmerge   

*table 1
*table1, vars(cohort cat \ sleepbednet_dum cat \  mosqbitefreq cat \mosquitocoil cat \mosquitobites cat \mosquitoday cat \mosquitonight cat \mosqbitedaytime cat \mosqbitenight cat \ age conts \ gender bin\ city cat \ site cat \ year cat \ season cat \ month cat \ seasonyear cat \  gametocytes conts \species cate \ parasite_count_lab  contn \  ) test missing by(malaria) saving("`figures'table_by_malariafreq$S_DATE.xls", replace)  
table1, vars(childmerge cat \ hhmerge cat \ gametocytes conts \ species cat \ parasite_count_lab  conts \ hoh_sleep_bednet cat \hoh_kids_sleep_bednet cat \hoh_own_bednet cat \hoh_number_bednet cat \ cohort cat \ age contn \ gender bin \ city cat \ site cat \ year cat \ season cat \ month cat \ seasonyear cat \  mosquito_exposure_index  conts \ mosq_prevention_index conts \ mosqbitefreq conts \ mosquitocoil cat \ mosquitobites cat \ mosquitoday cat \ mosquitonight cat \ mosqbitedaytime cat \ mosqbitenight  cat \ avoidmosquitoes cat \ hoh_mosquito_control cat \ hccses_index_sum conts \ hccsesindexmotor_vehicle cat \  hccsesindexdomestic_worker cat \ hccsesindexland_index cat \ hccsesindeximprovedroof_index cat \ hccsesindeximprovedfloor_index  cat \ hoh_room conts \ hoh_bedroom conts \ ) test missing by(asympt_malaria_cat) saving("`figures'table_by_malaria$S_DATE.xls", replace)
table1, vars(childmerge cat \ hhmerge cat \  gametocytes conts \ species cat \ parasite_count_lab  conts \ hoh_sleep_bednet cat \hoh_kids_sleep_bednet cat \hoh_own_bednet cat \hoh_number_bednet cat \ cohort cat \ age contn \ gender bin \ city cat \ site cat \ year cat \ season cat \ month cat \ seasonyear cat \  mosquito_exposure_index  conts \ mosq_prevention_index conts \ mosqbitefreq conts \ mosquitocoil cat \ mosquitobites cat \ mosquitoday cat \ mosquitonight cat \ mosqbitedaytime cat \ mosqbitenight  cat \ avoidmosquitoes cat \ hoh_mosquito_control cat \ hccses_index_sum conts \ hccsesindexmotor_vehicle cat \  hccsesindexdomestic_worker cat \ hccsesindexland_index cat \ hccsesindeximprovedroof_index cat \ hccsesindeximprovedfloor_index  cat \ hoh_room conts \ hoh_bedroom conts \ ) test by(asympt_malaria_cat) saving("`figures'table_by_malaria_NOMISSING$S_DATE.xls", replace)

preserve 
	keep if asympt_malaria_cat==1
	table1, vars(gametocytes conts \ species cat \ parasite_count_lab  conts \) by(city)  test missing saving("`figures'table_mal_POS_bycity_$S_DATE.xls", replace)
	table1, vars(gametocytes conts \ species cat \ parasite_count_lab  conts \) by(city)  test saving("`figures'table_mal_POS_bycity_NOMISSING_$S_DATE.xls", replace)
restore
