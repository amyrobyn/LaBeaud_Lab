/****************************************************
 *amy krystosik                  					*
 *coastalcities*
 *lebeaud lab               				        *
 *last updated feb 2, 2017							*
 ***************************************************/
*here is where your data is stored and your output is sent
cd "C:\Users\amykr\Box Sync\Amy Krystosik's Files\elysse coastal village map"
capture log close 
log using "use coastal_9_8_16.smcl", text replace 
set scrollbufsize 100000
set more 1

*import merged datafile. 
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
capture replace `var' = "" if `var'==""
rename *, lower
}

replace rvfvelisa ="0" if rvfvelisa=="negative"
replace rvfvelisa="" if rvfvelisa=="Repeat"|rvfvelisa =="repeat"
replace rvfvelisa="1" if rvfvelisa=="positive"
destring rvfvelisa, replace

egen village_rfv=concat(village rvfvelisa)
sum

**ses index
			foreach var of varlist ownrent flooring roof cookingfuel drinkingwater light telephone radio television bicycle motorvehicle domesticservant ownflushtoilet uselatrine wherelatrine ownland{
			capture tostring `var', replace
			tab `var'
			}

			foreach var of varlist _all{
			capture replace `var'=trim(itrim(lower(`var')))
			capture replace `var' = "" if `var'==""
			rename *, lower
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
		bysort village_rfv: tab ses_index_sum

		
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

rename land_index ownland2
rename sesindexmotorvehicle  ownmoterbike

destring *, replace

*here are two options for your logistic regression
logit rvfvelisa ownland2 ownmoterbike i.villagestring female adult, or 
outreg2 using logit1.xls, replace

logit rvfvelisa  i.villagestring female age ses_index_sum_pct mosq_index_sum_pct educ_int , or
outreg2 using logit1.xls, append

*here is your table 1
table1, by(rvfvelisa) vars(ownland2 cat \ ownmoterbike cat \ villagestring cat \ female cat \ adult cat \age conts \ses_index_sum_pct cate \mosq_index_sum_pct cate \yf cate \educ_int cate \gender cate \tribe_int cate \) saving("table1_coastalvillagesfeb2.xls", replace) test missing

