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

gen villageid=""
replace villageid = substr(id_wide, +1, 1)
replace villageid = "1" if villageid =="c"
replace villageid = "1" if villageid =="r"

replace villageid = "2" if villageid =="k"

replace villageid = "?" if villageid =="u"

replace villageid = "3" if villageid =="g"
replace villageid = "4" if villageid =="l"
destring villageid, replace

replace id_cohort = "HCC" if id_cohort =="c"
drop cohort
rename id_cohort cohort
gen houseid2 = ""
replace houseid2 = substr(id_wide, -6, 3) if cohort =="c"
destring houseid2 , replace force
replace houseid = houseid2 if houseid==. & houseid2!=.

destring houseid, replace
gen houseidstring = string(houseid ,"%04.0f")
drop houseid houseid2
rename houseidstring  houseid
order houseid

order studyid houseid villageid

destring houseid villageid, replace force
*replace these when i get the villgae id's

rename *, lower
save hcc_prevalence, replace
 
*****************merge with gis points

use "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\demography\xy", clear
replace gps_house_latitude = y if gps_house_latitude==.
replace gps_house_latitude = x if gps_house_longitude==.
keep if gps_house_latitude!=. & gps_house_longitude!=.

dropmiss, force obs piasm  trim
dropmiss, force   piasm  trim
rename *, lower
replace site = lower(site)
collapse (first)  studyid - bicycle, by(site villageid houseid)
destring _all, replace
tostring studyid windows, replace
merge m:m site villageid houseid using hcc_prevalence
rename _merge housegps

replace city = "chulaimbo" if city =="c"
replace city = "kisumu" if city =="k"
replace city = "ukunda" if city =="u"
replace city = lower(city)
save elisa_demography, replace
merge m:m interviewmonth interviewyear city using "C:\Users\amykr\Box Sync\Amy Krystosik's Files\vector\merged_vector_climate"

			foreach var of varlist motor_vehicle domestic_worker toilet_latrine latrine_location latrine_distance head_of_household_communal_tv tv telephone radio bicycle rooftype othrooftype latrinetype othlatrinetype floortype othfloortype watersource lightsource othlightsource windownum numroomhse numpplehse television motorizedvehicle domesticworker {
			capture tostring `var', replace
			tab `var'
			}

			foreach var of varlist _all{
			capture replace `var'=trim(itrim(lower(`var')))
			capture replace `var' = "" if `var'==""
			rename *, lower
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


rename head_of_household_floor flooring 
gen improvedfloor_index = "no"
replace improvedfloor_index= "yes" if flooring =="cement"|flooring =="tile"|flooring =="cement/dirt"|flooring =="dirt/cement"|flooring =="dirt/tiles"

rename head_of_household_roof roof
gen improvedroof_index = "no"
replace improvedroof_index= "yes" if strpos(roof, "corrugated")
replace improvedroof_index= "yes" if strpos(roof, "iron")
replace improvedroof_index= "yes" if strpos(roof, "tiles")
replace improvedroof_index= "yes" if strpos(roof, "mabati")


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
		egen city_denv = concat(city stanford_denv)
		egen city_chikv = concat(city stanford_chikv)
		bysort city_denv  city_chikv : tab ses_index_sum


		/*
**mosquito index
windows screens sleep_window own_bednet usemosqcoil  usenetfreq  childbitten mosqbitedaytime mosqbitenight number_bednet sleep_bednet kids_sleep_bed head_of_household_mosquito_contr avoidmosquitoes mosqbitefreq userepellant mosquitocoil sleepbednet mosquitobites mosquitoday mosquitonight mosquitobitefreq wearinsectrepellant 

*water
head_of_household_water_collecti head_of_household_water_collect0 watercollobjects watercolltype objectwater watercollectitems 


*livestock
keep_livestock  habits_livestock_location habits_which_livestock_livestock habits_which_livestock_livestoc1 habits_attend_livestock_attend_l habits_attend_livestock_attend_0 habits_livestock_contact_livesto habits_livestock_contact_livest0 
*travel
childtravel wheretravel nightaway 
*activities
outdooractivity hrsoutdoors 
*child health
yellowfever childvaccination 
*mosquito aedes
aedesaegyptiindoor anophelesgambiaeindoor anophelesfunestusindoor aedesaegyptioutdoor aedessimpsoniindoor aedessimpsonioutdoor aedesaegypti aedessimpsoni aedessppnotlisted aedesaegyptiinside aedesaegyptitotal 
*anopheles
anophelesgambiaeoutdoor anophelesfunestusoutdoor anophelescostaniindoor anophelesgambiae anophelesfunestus anophelesoutdoor 
*culex
culexsppindoor culexsppoutdoor culexspp 
*totals
indoortotal outdoortotal 
*yellow fever
masoni 
*culex
culexsppinside k culexsppoutside culexspptotal culexoutdoor 
*toxo
toxorhynchitesoutdoor  toxorhynchites 
*temp
avgtemp avgmaxtemp avgmintemp overallmaxtemp overallmintemp avgtemprange avgrh avgdewpt ttlrainfall rainfallanomalies temprangeanomalies tempdewptdiffanomalies tempanomalies rhanomalies rhtempanomalies 
*/

foreach var in sleep_window sleep_bednet  {
replace `var'=lower(`var')
tab `var'
}
		
gen mosquito_exposure_index =.

foreach var in sleep_window sleep_bednet  {
						gen mosq`var' =`var'
						replace mosq`var' = "1" if `var' == "yes" 
						replace mosq`var' = "0" if `var' == "no" |`var' == "none" 
						destring mosq`var', replace force
			}
			
		order mosq*
		sum  mosqbitefreq - mosqsleep_bednet 
		egen mosq_index_sum= rowtotal(mosqbitefreq - mosqsleep_bednet )

replace yf = lower(yf)
replace yf= "1" if yf== "yes" 
replace yf= "0" if yf== "no"  
replace yf= "" if yf== "3953"|yf== "not available"||yf== ""
destring yf, replace



gen educ = schoolcompleted 
replace educ = trim(itrim(lower(educ)))
replace educ = "0" if educ =="none"
replace educ = "1" if educ =="primary"
replace educ = "2" if educ =="secondary"
replace educ = "3" if educ =="college"|educ =="university"|educ =="adult educateion"|educ =="madrassa" |educ =="adult education"
replace educ = "" if educ =="refused"
encode educ, gen(educ_int)

encode tribe, gen(tribe_int)

save coastal_villages, replace 

xtile ses_index_sum_pct =  ses_index_sum, n(4)

gen mosqcontrol_index0 =  mosq_index_sum if  mosq_index_sum==0
replace  mosq_index_sum=. if  mosq_index_sum==0
xtile mosq_index_sum_pct =   mosq_index_sum, n(3)
replace mosq_index_sum_pct =  mosqcontrol_index0 if mosqcontrol_index0 !=.


bysort 	rvfvelisa: sum age gender ses_index_sum mosq_index_sum yf tribe_int educ_int
bysort 	rvfvelisa: sum age gender ses_index_sum_pct mosq_index_sum_pct yf tribe_int educ_int

egen village_elisa = concat(village rvfvelisa)
keep if rvfvelisa!=.

table1, by(village_elisa) vars(age conts \ses_index_sum_pct cat \mosq_index_sum_pct cat \yf cat \educ_int cat \gender cat \tribe_int cat \) saving("table1_coastalvillages_`i'.xls", replace) test missing

/*
foreach i in magodzoni{
preserve
keep if village== "`i'" 
table1, vars(age conts \ses_index_sum_pct cate \mosq_index_sum_pct cate \yf cate \educ_int cate \gender cate \tribe_int cate \) saving("table1_coastalvillages_`i'.xls", replace) test missing
restore
}
*/
table1, vars(age conts \ses_index_sum_pct cate \mosq_index_sum_pct cate \yf cate \educ_int cate \gender cate \tribe_int cate \) saving("table1_coastalvillages_total.xls", replace) test missing
table1, by(rvfvelisa) vars(age conts \ses_index_sum_pct cate \mosq_index_sum_pct cate \yf cate \educ_int cate \gender cate \tribe_int cate \) saving("table1_coastalvillages.xls", replace) test missing


export excel using "coastal villages", firstrow(variables) replace

*tabout  ses_index_sum_pct mosq_index_sum_pct yf educ_int gender tribe_int village_elisa using rowpercent.xls,  replace c(freq row) show(all)

*paper edits feb 2

gen adult = .
replace adult = 0 if age <18
replace adult = 1 if age >=18

gen female = . 
replace female =1 if sex=="female"
replace female =0 if sex=="male"

encode village, gen(villagestring)
bysort rvfvelisa: tab village villagestring , nolab


rename sesindexmotorvehicle  ownmoterbike

destring *, replace

*here are two options for your logistic regression
logit rvfvelisa ownland2 ownmoterbike i.villagestring female adult, or 
outreg2 using logit1.xls, replace

logit rvfvelisa  i.villagestring female age ses_index_sum_pct mosq_index_sum_pct educ_int , or
outreg2 using logit1.xls, append

*here is your table 1
table1, by(rvfvelisa) vars(ownland2 cat \ ownmoterbike cat \ villagestring cat \ female cat \ adult cat \age conts \ses_index_sum_pct cate \mosq_index_sum_pct cate \yf cate \educ_int cate \gender cate \tribe_int cate \) saving("table1_coastalvillagesfeb2.xls", replace) test missing

