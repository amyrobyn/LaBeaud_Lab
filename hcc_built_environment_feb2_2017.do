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
tab interviewmonth interviewyear 
tab city
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

collapse (firstnm) gps_house_longitude  gps_house_latitude, by(site villageid houseid)
destring _all, replace
outsheet using "xy.csv", comma names replace
merge m:m site villageid houseid using hcc_prevalence
rename _merge housegps

replace city = "Chulaimbo" if city =="c"
replace city = "Kisumu" if city =="k"
replace city = "Ukunda" if city =="u"


