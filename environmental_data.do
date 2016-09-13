/**************************************************************
 *amy krystosik                  							  *
 *R01 results and discrepencies by strata (lab, antigen, test)*
 *lebeaud lab               				        		  *
 *last updated august 15, 2016  							  *
 **************************************************************/
local import "C:\Users\Amy\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\environmental_data\KenyaMerged&FormattedDataSets\"
cd "C:\Users\Amy\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\longitudinal_analysis_aug252016\output"
 
set graphics on 
capture log close 
log using "enviro.smcl", text replace 
set scrollbufsize 100000
set more 1


import excel "`import'ChulaimboDailyClimateData.xls", clear firstrow
gen site =""
replace site = "Chulaimbo"
capture rename city site
gen year = year(Date)
capture drop Month
gen month = month(Date)
gen day= day(Date)
save ChulaimboDailyClimateData, replace

import excel "`import'KisumuDailyClimateData.xls", clear firstrow
gen site =""
replace site = "Kisumu"
capture rename city site
gen year = year(Date)
capture  drop Month
gen month = month(Date)
gen day= day(Date)
rename *, lower
save KisumuDailyClimateData, replace

import excel "`import'LandingCatchesMonthlySummaries_all.xls", clear firstrow
capture rename city site
gen date2 = date(Month, "M20Y")
rename Month monthyear
format date2  %tmy
gen year = year(date2)
gen month = month(date2)
save LandingCatchesMonthlySummaries_all, replace

import excel "`import'LarvalMonthlySummaries.xls", clear firstrow
capture rename city site
gen date2 = date(Date, "M20Y")
rename Date monthyear
format date2  %tmy
gen year = year(date2)
gen month = month(date2)
save LarvalMonthlySummaries, replace


import excel "`import'MsamDailyClimateData.xls", clear firstrow
gen site =""
replace site = "Msambweni"
capture rename city site
gen year = year(Date)
capture drop Month
gen month = month(Date)
gen day= day(Date)
save MsamDailyClimateData, replace

import excel "`import'OvitrapMonthlySummaries.xls", clear firstrow
capture rename city site
gen date2 = date(Date, "M20Y")
rename Date monthyear
format date2  %tmy
gen year = year(date2)
gen month = month(date2)
save OvitrapMonthlySummaries, replace

import excel "`import'ProkopackMonthlySummaries.xls", clear firstrow
capture rename city site
gen date2 = date(Date, "M20Y")
rename Date monthyear
format date2  %tmy
gen year = year(date2)
gen month = month(date2)
save ProkopackMonthlySummaries, replace

import excel "`import'SentinelTrapMonthlySummaries.xls", clear firstrow
capture rename city site
gen date2 = date(Date, "M20Y")
rename Date monthyear
format date2  %tmy
gen year = year(date2)
gen month = month(date2)
save SentinelTrapMonthlySummaries, replace

import excel "`import'UkundaDailyClimateData.xls", clear firstrow
gen site = ""
replace site ="Ukunda"
gen year = year(Date)
capture drop Month
gen month = month(Date)
gen day= day(Date)
rename *, lower
save UkundaDailyClimateData, replace


merge m:m day month year site using MsamDailyClimateData
drop _merge
capture drop  Month_year 
capture drop  MonthYear
save merged_enviro.dta, replace


foreach dataset in "ChulaimboDailyClimateData" "KisumuDailyClimateData" {
use `dataset', clear
rename *, lower
capture rename city site

	capture drop MonthYear 
	capture drop Month_year 
	capture drop MonthYear

merge m:m day month year site using merged_enviro.dta
drop _merge
save merged_enviro.dta, replace
}

foreach dataset in "SentinelTrapMonthlySummaries" "ProkopackMonthlySummaries" "OvitrapMonthlySummaries" "LarvalMonthlySummaries"  "LandingCatchesMonthlySummaries_all"{
use `dataset', clear
rename *, lower
capture rename city site
	capture drop MonthYear 
	capture drop Month_year 
	capture drop MonthYear

merge m:m year month site using merged_enviro.dta
drop _merge
save merged_enviro.dta, replace
}

gen season = .
replace season =1 if month >=1 & month  <=3
*label define 1 "hot no rain from mid december"
replace season =2 if month >=4 & month  <=6
*label define 2 "long rains"
replace season =3 if month >=7 & month  <=10
*label define 3 "less rain cool season"
replace season =4 if month >=11 & month  <=12
*label define 4 "short rains"
twoway (scatter  rainfall season, sort mlabel(month))

gen date3= ym(year, month)
format date3 %tm
encode site, gen(city_dum)
xtset city_dum date

foreach var in  aedesaegyptiinside aedesaegyptioutside aedesaegyptitotal aedesaegyptiindoor aedesaegyptioutdoor aedesaegypti anophelesgambiaeinside anophelesgambiaeoutside anophelesgambiaetotal anophelesfunestusinside anophelesfunestusoutside k culexsppinside culexsppoutside culexspptotal o p q culexsppindoor indoortotal anophelesoutdoor culexoutdoor toxorhynchitesoutdoor outdoortotal culexsppoutdoor anophelesgambiaeindoor anophelesfunestusindoor anophelesgambiaeoutdoor anophelesfunestusoutdoor anophelesgambiae anophelesfunestus culexspp toxorhynchites maxtemp mintemp temp rh dewpt rainfall  temprange dewdiff rain2 MaxTemp MinTemp Temp RH DewPt TempRange DewDiff{
destring `var', replace
xtline `var', overlay title(`var' by city and date)  xtitle(date) xlabel(#20, angle(45))
graph export "`var'.tif", width(4000) replace  

preserve
collapse `var', by(season site)
twoway scatter `var' season,  title(`var' by city and season)  xtitle(season) xlabel(#4, angle(45))
graph export "`var'_season.tif", width(4000) replace  
restore
}

/*replace city = "c" if city =="Chulaimbo"
replace city = "k" if city =="Kisumu"
replace city = "m" if city =="Msambweni"
replace city = "u" if city =="Ukunda"
replace city = "c" if city =="chulaimbo"
replace city = "k" if city =="obama"
*/
drop site
gen site = .
replace site = 1 if city ==3|city ==4
replace site = 2 if city ==1|city ==2

save merged_enviro.dta, replace
