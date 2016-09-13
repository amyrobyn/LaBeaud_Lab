/****************************************************
 *amy krystosik                  					*
 *coastalcities*
 *lebeaud lab               				        *
 *last updated august 8, 2016  						*
 ***************************************************/
cd "C:\Users\Amy\Box Sync\Amy Krystosik's Files\elysse coastal village map"
capture log close 
log using "use coastal_9_8_16.smcl", text replace 
set scrollbufsize 100000
set more 1

use coastal, clear
replace Age = age if Age ==.

replace Sex = "Female" if Sex =="Female"|Sex =="Femal"|Sex =="Famale"
encode Sex, gen(gender)
replace HHM2_Sex = "Female" if HHM2_Sex == "Eemale"
encode HHM2_Sex , gen(sex2)
replace gender = sex2 if gender ==. 
drop sex2 HHM2_Sex 

drop age AlphavirusCorrected Alphaviruscorrected Habits_Date habits_Date infoInform_Date infoinform_Date  infoInform_Study_ID infoinform_Study_ID  meanArmcirc MeanArmCirc meanheight MeanHeight meanTric_fold MeanTric_Fold meanweight MeanWeight OtherRelationToHH OtherRelationtoHH
foreach var of varlist _all{
capture replace `var'=trim(itrim(lower(`var')))
capture replace `var' = "." if `var'==""
rename *, lower
}
encode rvfvelisa, gen(rvfvelisa_int)
replace rvfvelisa_int =0 if rvfvelisa_int ==2
replace rvfvelisa_int =. if rvfvelisa_int ==1|rvfvelisa_int ==4
replace rvfvelisa_int =1 if rvfvelisa_int ==3

label define  rvfvelisa_int 0 "rvfv negative", modify
label define  rvfvelisa_int 1 "rvfv positive", modify

egen village_rfv=concat(village rvfvelisa)
sum

**ses index
			foreach var of varlist ownrent flooring roof cookingfuel drinkingwater light telephone radio television bicycle motorvehicle domesticservant ownflushtoilet uselatrine wherelatrine ownland{
			capture tostring `var', replace
			tab `var'
			}
gen own_index = "no"
replace own_index = "yes" if ownrent =="own"

gen improvedfloor_index = "no"
replace improvedfloor_index= "yes" if flooring =="cement"|flooring =="tile"|flooring =="cement/dirt"|flooring =="dirt/cement"|flooring =="dirt/tiles"

gen improvedroof_index = "no"
replace improvedroof_index= "yes" if roof=="corrugated  iron"|roof=="corrugated iron"|roof=="corrugated iron"|roof=="roofing tiles"|roof=="mabati"

gen improvedfuel_index = "no"
replace improvedfuel_index= "yes" if cookingfuel=="electricity"|cookingfuel=="gas"

gen improvedwater_index = "no"
replace improvedwater_index = "yes" if drinkingwater=="piped water in house"|drinkingwater=="piped water in public"|drinkingwater=="piped water in public tap"

gen improvedlight_index = "no"
replace improvedlight_index = "yes" if light=="electricity"|light=="electricity line"|light=="solar"|light=="solar electrical battery"

gen latrine_index = "0"
replace latrine_index = "1" if wherelatrine=="outside (without water)"|wherelatrine=="outside without water"
replace latrine_index = "2" if wherelatrine=="outside ( with water)"|wherelatrine=="outside (with water)"|wherelatrine=="outside with water"
replace latrine_index = "3" if wherelatrine=="inside your house"

gen land_index = "0"
replace land_index = "1" if ownland =="own"|ownland =="all"

			foreach var of varlist own_index improvedfloor_index improvedroof_index improvedfuel_index improvedwater_index improvedlight_index telephone radio television bicycle motorvehicle domesticservant ownflushtoilet uselatrine latrine_index land_index{
						replace `var'=lower(`var')
						gen sesindex`var' =`var'
						replace sesindex`var' = "1" if `var' == "yes" 
						replace sesindex`var' = "0" if `var' == "no" |`var' == "none" 
						destring sesindex`var', replace force
			}
			
		order sesindex*
		sum sesindexown_index - sesindexland_index
		egen ses_index_sum= rowtotal(sesindexown_index - sesindexland_index)
		bysort village_rfv : tab ses_index_sum

		
foreach var in sleepbywindow usebednet childrenusebednet nettreated{
replace `var'=lower(`var')
tab `var'
}
		
gen mosquito_exposure_index =.
replace childrenusebednet ="0" if childrenusebednet =="no"|childrenusebednet =="none"
replace childrenusebednet ="1" if childrenusebednet =="some"
replace childrenusebednet ="2" if childrenusebednet =="all"
replace childrenusebednet ="." if childrenusebednet =="don’t know"|childrenusebednet =="refused"

foreach var in sleepbywindow usebednet childrenusebednet nettreated{
						gen mosq`var' =`var'
						replace mosq`var' = "1" if `var' == "yes" 
						replace mosq`var' = "0" if `var' == "no" |`var' == "none" 
						destring mosq`var', replace force
			}
			
		order mosq*
		sum mosqsleepbywindow - mosqnettreated
		egen mosq_index_sum= rowtotal(mosqsleepbywindow - mosqnettreated)



replace yf = lower(yf)
replace yf= "1" if yf== "yes" 
replace yf= "0" if yf== "no"  
replace yf= "." if yf== "3953"|yf== "not available"||yf== ""
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
xtile mosq_index_sum_pct =  mosq_index_sum, n(4)

bysort 	rvfvelisa_int: sum age gender ses_index_sum mosq_index_sum yf tribe_int educ_int
bysort 	rvfvelisa_int: sum age gender ses_index_sum_pct mosq_index_sum_pct yf tribe_int educ_int



foreach i in Jego Milalani Kinango Nganja Vuga{
preserve
keep if village== "`i'"
table1, by(rvfvelisa_int) vars(age conts \ses_index_sum_pct cate \mosq_index_sum_pct cate \yf cate \educ_int cate \gender cate \tribe_int cate \) saving("table1_coastalvillages_`i'.xls", replace) test missing
restore
}

foreach i in Magodzoni{
preserve
keep if village== "`i'" 
table1, vars(age conts \ses_index_sum_pct cate \mosq_index_sum_pct cate \yf cate \educ_int cate \gender cate \tribe_int cate \) saving("table1_coastalvillages_`i'.xls", replace) test missing
restore
}

table1, vars(age conts \ses_index_sum_pct cate \mosq_index_sum_pct cate \yf cate \educ_int cate \tribe_int cate \gender cate \) saving("table1_coastalvillages_total.xls", replace) test missing
table1, by(rvfvelisa_int) vars(village cate \ age conts \gender cate \ses_index_sum_pct cate \mosq_index_sum_pct cate \yf cate \tribe_int cate \educ_int cate \) saving("table1_coastalvillages.xls", replace) test missing

export excel using "coastal villages", firstrow(variables) replace
