/*************************************************************
 *amy krystosik                  							  *
 *built environement hcc									  *
 *lebeaud lab               				        		  *
 *last updated feb 2, 2017 									  *
 **************************************************************/ 

capture log close 
log using "built environement hcc.smcl", text replace 
set scrollbufsize 100000
set more 1

cd "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\built environement hcc"

use "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\interviewdata\all_interviews", clear
keep if id_cohort =="c"
drop id_childnumber

*merge with hcc elisa data
merge 1:1 id_wide visit using "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\elisas\feb1 2017\prevalent_hcc.dta"
drop _merge
tab chikvigg_   denvigg_
tab stanforddenvigg_ stanfordchikvigg_, nolab m

foreach var in stanforddenvigg_ stanfordchikvigg_ chikvigg_   denvigg_{
	replace `var' = "1" if `var' =="pos"
	replace `var' = "0" if `var' =="neg"
	destring `var', replace
}

gen interviewyear = year(interviewdate) 
gen interviewmonth = month(interviewdate) 
tab interviewmonth interviewyear, m 
tab city
tab site
save prevalent_hcc, replace


***
**create village and house id so we can merge with gis points
/*
gen villageid=""
replace villageid = substr(id_wide, +1, 1)
replace villageid = "1" if villageid =="c" & dataset ==""
replace villageid = "1" if villageid =="r" & dataset ==""

replace villageid = "2" if villageid =="k"

tab dataset
replace villageid = "4" if villageid =="u" & dataset ==""

replace villageid = "3" if villageid =="g" & dataset ==""
replace villageid = "4" if villageid =="l" & dataset ==""
*/
replace id_cohort = "HCC" if id_cohort =="c"
keep if id_cohort == "HCC" 
drop cohort
rename id_cohort cohort
order studyid id_wide houseid city


gen houseid2 = ""
replace houseid2 = substr(id_wide, 3, . ) 
order houseid*
sort city
destring houseid2 , replace force 
tostring houseid2, replace
replace houseid2= reverse(houseid2)
replace houseid2 = substr(houseid2, 4, . ) 
replace houseid2= reverse(houseid2)
destring houseid2, replace 

list studyid id_wide houseid2  houseid  if houseid2 != houseid & houseid!=. & city =="milani"
list studyid id_wide houseid2  houseid  if houseid2 != houseid & houseid!=. & city =="nganja"
bysort city: count if houseid2 != houseid & houseid!=.

order studyid houseid houseid2 city
destring houseid houseid2  city, replace 
replace houseid = houseid2 if houseid==. & houseid2!=.
order studyid houseid city

*replace these when i get the villgae id's

rename *, lower
save hcc_prevalence, replace

bysort city: tab interviewmonth interviewyear 
*****************merge with gis points
merge m:1 city interviewyear interviewmonth using "C:\Users\amykr\Box Sync\Amy Krystosik's Files\vector\merged_vector_climate" 
rename _merge vector_climate
drop if vector_climate == 2
bysort city: tab interviewmonth interviewyear 

merge m:1 city houseid using "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\demography\xy"

bysort _merge city: count if houseid2 != houseid & houseid!=.
bysort _merge: list studyid id_wide houseid2  houseid  if houseid2 != houseid & houseid!=. & city =="milani"
list studyid id_wide houseid2  houseid  if houseid2 != houseid & houseid!=. & city =="nganja"

drop if _merge == 2 

rename _merge child_demography
save elisa_demography, replace

gen group = . 
replace group = 0 if stanford_denv_igg  == 0 & stanford_chikv_igg  ==0
replace group = 1 if stanford_denv_igg  == 1| stanford_chikv_igg  ==1
replace group = 2 if stanford_denv_igg  == 1 & stanford_chikv_igg  ==1
*keep if group !=. 

gen group2 = . 
replace group2 = 0 if denvigg_ == 0 & chikvigg_ ==0
replace group2 = 1 if denvigg_ == 1| chikvigg_ ==1
replace group2 = 2 if denvigg_ == 1 & chikvigg_ ==1

foreach var of varlist motor_vehicle domestic_worker toilet_latrine latrine_location latrine_distance head_of_household_communal_tv tv telephone radio bicycle rooftype othrooftype latrinetype othlatrinetype floortype othfloortype watersource lightsource othlightsource windownum numroomhse numpplehse television motorizedvehicle domesticworker {
			capture tostring `var', replace
			tab `var'
			}

			foreach var of varlist _all{
			capture replace `var'=trim(itrim(lower(`var')))
			rename *, lower
			}

foreach var in childtravel nightaway  keep_livestock  outdooractivity mosquitocoil mosquitobites mosquitoday mosquitonight mosqbitedaytime mosqbitenight{
replace `var' = . if `var' == 8
}


rename habits_cooking_fuel cookingfuel
gen improvedfuel_index = "no"
replace improvedfuel_index= "yes" if strpos(cookingfuel, "electricity")
replace improvedfuel_index= "yes" if strpos(cookingfuel, "gas")

rename habits_water_source drinkingwater
gen improvedwater_index = "no"
replace improvedwater_index = "yes" if drinkingwater=="piped water in house"|drinkingwater=="piped water in public"|drinkingwater=="piped water in public tap"
replace improvedwater_index = "yes" if strpos(drinkingwater, "pipe")

rename habits_light_source light
gen improvedlight_index = "no"
replace improvedlight_index = "yes" if light=="electricity"|light=="electricity line"|light=="solar"|light=="solar electrical battery"
replace improvedlight_index = "yes" if strpos(light, "electric")
replace improvedlight_index = "yes" if strpos(light, "solar")

rename latrine_location wherelatrine
gen latrine_index = "0"
replace latrine_index = "1" if wherelatrine=="outside (without water)"|wherelatrine=="outside without water"
replace latrine_index = "1" if strpos(wherelatrine, "outside")
replace latrine_index = "2" if strpos(wherelatrine, "inside")

 gen ownflushtoilet = 0
 replace  ownflushtoilet = 1 if strpos(toilet_latrine, "own_flush")

 rename habits_land  land_index 

*house
foreach var in rooms bedrooms head_of_household_floor head_of_household_floor_other head_of_household_roof head_of_household_roof_other { 
tab `var'
}


egen flooring2 = concat( hoh_floor head_of_household_floor flooring floorspecify floortype)
drop hoh_floor head_of_household_floor flooring floorspecify floortype
rename flooring2  flooring 

gen improvedfloor_index = "no"
replace improvedfloor_index= "yes" if strpos(flooring, "cement")|strpos(flooring, "tile")|strpos(flooring, "cement/dirt")|strpos(flooring, "dirt/cement")|strpos(flooring, "dirt/tiles")

foreach var in roof hoh_roof hoh_other_roof head_of_household_roof roofspecify rooftype{
tab `var'
}
egen roof2 = concat(roof hoh_roof hoh_other_roof head_of_household_roof roofspecify rooftype head_of~f_other  othrooftype)
drop roof hoh_roof hoh_other_roof head_of_household_roof roofspecify rooftype head_of~f_other  othrooftype
rename roof2  roof
gen improvedroof_index = "no"
replace improvedroof_index = "yes" if strpos(roof, "corrugated")|strpos(roof, "tiles")|strpos(roof, "iron")|strpos(roof, "mabati")



foreach var of varlist improvedfuel_index improvedwater_index improvedlight_index telephone radio tv bicycle motor_vehicle domestic_worker ownflushtoilet latrine_index land_index rooms bedrooms improvedroof_index improvedfloor_index{
						tostring `var', replace
						replace `var'=lower(`var')
						gen sesindex`var' =`var'
						*drop `var'
						replace sesindex`var' = "1" if `var' == "yes" 
						replace sesindex`var' = "0" if `var' == "no" |`var' == "none" 
						destring sesindex`var', replace force
			}
			
		order sesindex*
		sum  sesindeximprovedfuel_index - sesindexland_index
		egen ses_index_sum= rowtotal(sesindeximprovedfuel_index - sesindexland_index)
		drop sesindeximprovedfuel_index - sesindexland_index



	ds, has(type string) 
	foreach var of varlist `r(varlist)' { 
		replace `var' = "0" if strpos(`var', "no")
		replace `var' = "0" if strpos(`var', "none")
		replace `var' = "1" if strpos(`var', "some")
		replace `var' = "2" if strpos(`var', "yes")
		replace `var' = "2" if strpos(`var', "all")
		destring `var', replace
	}

	
*climate
foreach var in avgtemp avgmaxtemp avgmintemp overallmaxtemp overallmintemp avgtemprange avgrh avgdewpt ttlrainfall rainfallanomalies temprangeanomalies tempdewptdiffanomalies tempanomalies rhanomalies rhtempanomalies {
tab `var'
}


		replace mosquitobitefreq = "1daily" if mosquitobitefreq == "daily"
		replace mosquitobitefreq = "2every_other_day " if mosquitobitefreq == "every_other_day"
		replace mosquitobitefreq = "3weekly" if mosquitobitefreq == "weekly"
		replace mosquitobitefreq = "4monthly" if mosquitobitefreq == "monthly"
		replace mosquitobitefreq = "5every_other_month" if mosquitobitefreq == "every_other_month"
		replace mosquitobitefreq = "" if mosquitobitefreq == "refused"
		encode mosquitobitefreq, gen(mosquitobitefreq_int)
		tab mosquitobitefreq_int
		drop mosqbitefreq mosquitobitefreq
**mosquito exposure index
foreach var in windows sleep_window childbitten mosqbitedaytime mosqbitenight mosquitobites mosquitoday mosquitonight mosquitobitef{
replace `var' = . if `var' ==8
}
sum windows sleep_window childbitten mosqbitedaytime mosqbitenight mosquitobites mosquitoday mosquitonight mosquitobitefreq_int
egen mosquito_exposure_index = rowtotal(windows sleep_window childbitten mosqbitedaytime mosqbitenight mosquitobites mosquitoday mosquitonight mosquitobitef)

*mosquito prevention index
	replace  head_of_household_mosquito_contr = "0" if  head_of_household_mosquito_contr=="n/a"
	replace usemosqcoil = 1 if strpos(head_of_household_mosquito_contr , "coil") 
	replace usemosqcoil = mosquitocoil if usemosqcoil ==.
	replace userepellant  = wearinsectrep if userepellant  ==. 
	replace userepellant  = 1 if strpos(head_of_household_mosquito_contr , "spray") 
	replace userepellant  = 1 if strpos(head_of_household_mosquito_contr , "repellent") 
	gen naturalmosqrepel= . 
	replace naturalmosqrepel= 1 if strpos(head_of_household_mosquito_contr , "herbs") 
	drop mosquitocoil  wearinsectrep head_of_household_mosquito_contr 

foreach var in naturalmosqrepel screens own_bednet usemosqcoil  usenetfreq  number_bednet sleep_bednet kids_sleep_bed avoidmosquitoes userepellant sleepbednet {
replace `var' = . if `var' ==8
}
sum naturalmosqrepel screens own_bednet usemosqcoil  usenetfreq  number_bednet sleep_bednet kids_sleep_bed avoidmosquitoes userepellant sleepbednet

egen mosq_prevention_index = rowtotal( naturalmosqrepel screens own_bednet usemosqcoil  usenetfreq  number_bednet sleep_bednet kids_sleep_bed avoidmosquitoes userepellant sleepbednet )


*mosquito aedes
sum aedesaegyptiindoor aedessimpsoniindoor aedesaegyptioutdoor aedessimpsonioutdoor  aedesaegypti  aedessimpsoni  aedessppnotlisted  aedesaegyptiinside  aedesaegyptitotal 

*anopheles
sum anophelesgambiaeindoor anophelesfunestusindoor  anophelesgambiaeoutdoor anophelesfunestusoutdoor anophelescostaniindoor anophelesgambiae anophelesfunestus anophelesoutdoor 

*culex
sum culexsppindoor culexsppoutdoor culexspp 

*totals
sum indoortotal outdoortotal 

*yellow fever
sum masoni 

*culex
sum culexsppinside k culexsppoutside culexspptotal culexoutdoor 

*toxo
sum toxorhynchitesoutdoor  toxorhynchites 


*water
tab head_of_household_water_collecti 
tab head_of_household_water_collect0 
gen water_cotainers = . 

replace water_cotainers = 0 if head_of_household_water_collecti ==""|head_of_household_water_collecti =="n/a"
replace water_cotainers = 1 if head_of_household_water_collecti !="" & water_cotainers ==.

replace water_cotainers = 0 if head_of_household_water_collect0 ==""|head_of_household_water_collect0 =="n/a" & water_cotainers ==.
replace water_cotainers = 1 if head_of_household_water_collect0 !="" & water_cotainers ==.

replace water_cotainers = 0 if watercolltype  ==""| watercolltype =="n/a" & water_cotainers ==.
replace water_cotainers = 1 if watercolltype  !="" & water_cotainers ==.

replace water_cotainers = 0 if watercollectitems ==""| watercollectitems  =="n/a" & water_cotainers ==.
replace water_cotainers = 1 if watercollectitems !="" & water_cotainers ==.


replace water_cotainers = watercollobjects if water_cotainers ==.
replace water_cotainers = objectwater if water_cotainers ==.

drop objectwater watercollobjects watercollectitems watercolltype  head_of_household_water_collect0 head_of_household_water_collecti 

*livestock
sum keep_livestock  habits_livestock_location habits_which_livestock_livestock habits_which_livestock_livestoc1 habits_attend_livestock_attend_l habits_attend_livestock_attend_0 habits_livestock_contact_livesto habits_livestock_contact_livest0 

foreach var in keep_livestock  habits_livestock_location habits_which_livestock_livestock habits_which_livestock_livestoc1 habits_attend_livestock_attend_l habits_attend_livestock_attend_0 habits_livestock_contact_livesto habits_livestock_contact_livest0 {
	tab `var'
}

*travel
sum childtravel wheretravel nightaway 

*activities
sum outdooractivity hrsoutdoors 
*child health
sum yellowfever childvaccination 

rename educlevel educ

foreach var in  hoc_tribe hoc_othtribe hoh_tribe hoh_othtribe tribe tribeother hh_tribe hh_tribe_other{
tab `var'
}
egen tribe2 = concat( hoc_tribe hoc_othtribe hoh_tribe hoh_othtribe tribe tribeother hh_tribe hh_tribe_other)
drop hoc_tribe hoc_othtribe hoh_tribe hoh_othtribe tribe tribeother hh_tribe hh_tribe_other 
rename tribe2 tribe
encode tribe, gen(tribe_int)

save builtenvironment, replace 

xtile ses_index_sum_pct =  ses_index_sum, n(4)


bysort group: sum age gender ses_index_sum tribe_int educ
egen village_elisa = concat(village group)


outsheet using "built environemnt.csv", comma names replace

gen adult = .
replace adult = 0 if age <18
replace adult = 1 if age >=18

gen female = . 
replace female =1 if sex=="female"
replace female =0 if sex=="male"
replace female = gender  if female ==.

rename motor_vehicle  ownmoterbike

destring *, replace
replace land_index = "0none" if land_index =="none"
replace land_index = "1rent" if land_index =="rent"
replace land_index = "2family" if land_index =="family"
replace land_index = "3own" if land_index =="own"

encode land_index, gen(ownland2)
encode  city, gen(city_int)
*here are two options for your logistic regression

bysort group: sum age ses_index_sum_pct educ gender tribe_int 
table1, by(group) vars(age conts \ses_index_sum_pct cat \educ cat \gender cat \tribe_int cat \) saving("table1a.xls", replace) test missing
table1, vars(age conts \ses_index_sum_pct cate \educ cate \gender cate \tribe_int cate \) saving("table1b.xls", replace) test missing
table1, by(group) vars(age contn \ses_index_sum_pct cat \educ cat \gender cat \tribe_int cat \) saving("table1c.xls", replace) test missing

replace group2 = 1 if group2 == 2
*ownland2 ownmoterbike keep_livestock  aedesaegyptitotal   rainfallanomalies temprangeanomalies tempdewptdiffanomalies tempanomalies rhanomalies rhtempanomalies  
bysort group: sum group2 female adult  water_cotainers  mosquito_exposure_index  mosq_prevention_index  ses_index_sum

logit group2 group2 city_int female adult  water_cotainers  mosquito_exposure_index  mosq_prevention_index  ses_index_sum, or
bysort group2: sum windows ownland2 ownmoterbike i.city_int female adult keep_livestock   water_cotainers  mosquito_exposure_index  mosq_prevention_index  aedesaegyptitotal  rainfallanomalies temprangeanomalies tempdewptdiffanomalies tempanomalies rhanomalies rhtempanomalies  ses_index_sum

table1, by(group) vars(windows conts \ownland2 cat \ ownmoterbike cat\  city_int cat\ female cat\ adult cat\ keep_livestock   cat\ water_cotainers  cat\ mosquito_exposure_index  conts \ mosq_prevention_index  contn \ aedesaegyptitotal  contn \ rainfallanomalies contn \ temprangeanomalies contn \ tempdewptdiffanomalies contn \ tempanomalies contn \ rhanomalies contn \ rhtempanomalies  contn \ ses_index_sum contn \) saving("table1.xls", replace) test missing

logit group2 windows ownland2 ownmoterbike i.city_int female adult keep_livestock   mosquito_exposure_index  mosq_prevention_index  ses_index_sum, or 
bysort group: sum windows ownland2 ownmoterbike i.city_int female adult keep_livestock   mosquito_exposure_index  mosq_prevention_index  ses_index_sum

outreg2 using logit1.xls, replace

logit group2  i.city_int ses_index_sum_pct  educ childage , or
outreg2 using logit2.xls, append

*table 1
table1, by(group) vars(ownland2 cat \ ownmoterbike cat \ villagestring cat \ female cat \ adult cat \childage  conts \ses_index_sum_pct cate \educ cate \gender cate \tribe_int cate \) saving("table2.xls", replace) test missing
