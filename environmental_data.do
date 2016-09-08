/**************************************************************
 *amy krystosik                  							  *
 *R01 results and discrepencies by strata (lab, antigen, test)*
 *lebeaud lab               				        		  *
 *last updated august 15, 2016  							  *
 **************************************************************/
local import "C:\Users\Amy\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\environmental_data\KenyaMerged&FormattedDataSets\"
cd "C:\Users\Amy\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\longitudinal_analysis_aug252016\output"
 
capture log close 
log using "enviro.smcl", text replace 
set scrollbufsize 100000
set more 1


import excel "`import'ChulaimboMonthlyClimateData.xls", clear firstrow
gen site = Chulaimbo
gen date2 = date(Month, "M20Y")
rename Month monthyear
format date2  %tmy
gen year = year(date2)
gen month = month(date2)
save ChulaimboMonthlyClimateData, replace

import excel "`import'KisumuMonthlyClimateData.xls", clear firstrow
gen site = Kisumu
gen date2 = date(Month, "M20Y")
rename Month monthyear
format date2  %tmy
gen year = year(date2)
gen month = month(date2)
save KisumuMonthlyClimateData, replace

import excel "`import'LandingCatchesMonthlySummaries_all.xls", clear firstrow
gen date2 = date(Month, "M20Y")
rename Month monthyear
format date2  %tmy
gen year = year(date2)
gen month = month(date2)
save LandingCatchesMonthlySummaries_all, replace

import excel "`import'LarvalMonthlySummaries.xls", clear firstrow
gen date2 = date(Date, "M20Y")
rename Date monthyear
format date2  %tmy
gen year = year(date2)
gen month = month(date2)
save LarvalMonthlySummaries, replace


import excel "`import'MsamMonthlyClimateData.xls", clear firstrow
gen date2 = date(Month, "M20Y")
rename Month monthyear
format date2  %tmy
gen year = year(date2)
gen month = month(date2)
save MsamMonthlyClimateData, replace

import excel "`import'OvitrapMonthlySummaries.xls", clear firstrow
gen date2 = date(Date, "M20Y")
rename Date monthyear
format date2  %tmy
gen year = year(date2)
gen month = month(date2)
save OvitrapMonthlySummaries, replace

import excel "`import'ProkopackMonthlySummaries.xls", clear firstrow
gen date2 = date(Date, "M20Y")
rename Date monthyear
format date2  %tmy
gen year = year(date2)
gen month = month(date2)
save ProkopackMonthlySummaries, replace

import excel "`import'SentinelTrapMonthlySummaries.xls", clear firstrow
gen date2 = date(Date, "M20Y")
rename Date monthyear
format date2  %tmy
gen year = year(date2)
gen month = month(date2)
save SentinelTrapMonthlySummaries, replace

import excel "`import'UkundaMonthlyClimateData.xls", clear firstrow
gen date2 = date(Month, "M20Y")
rename Month monthyear
format date2  %tmy
gen year = year(date2)
gen month = month(date2)
save UkundaMonthlyClimateData, replace


merge m:m month year site using SentinelTrapMonthlySummaries
drop _merge
capture drop  Month_year 
capture drop  MonthYear
save merged_enviro.dta, replace


foreach dataset in "ProkopackMonthlySummaries" "OvitrapMonthlySummaries" "MsamMonthlyClimateData" "LarvalMonthlySummaries"  "ChulaimboMonthlyClimateData" "KisumuMonthlyClimateData" "LandingCatchesMonthlySummaries_all"{
use `dataset', clear

	capture drop MonthYear 
	capture drop Month_year 
	capture drop MonthYear

merge m:m year month site using merged_enviro.dta
drop _merge
save merged_enviro.dta, replace
}
gen date= ym(year, month)
format date %tm
encode city, gen(city_dum)
xtset city_dum date

foreach var in  Aedes_aegyti_ovi_IN Culex_species_ovi_IN Indoors_Total_ovi_IN Aedes_aegyti_ovi_OUT Culex_species_ovi_OUT Outdoors_Total_ovi_OUT Grand_Total_ovi Aedes_aegypti_Larva_IN Aedes_simpsoni_Larva_IN Anopheles_Larva_IN Culex_Larva_IN Total_Larva_IN Aedes_Larva_OUT Aedes_simpsoni_Larva_OUT Anopheles_Larva_OUT Culex_Larva_OUT Toxorhynchite_Larva_OUT Total_Larva_OUT Grand_Total_Larva Aedeseagypti_BG Aedessimpsoni_BG Aedesspp_BG Anophelesgambiae_BG Anophelesfunestus_BG Culexspecies_BG Mansoni_BG Grandtotal_BG Aedes_aegypti_papae Anopheles_papae Culex_papae Toxorhynchites_papae GrandTotal_papae Aedes_aegypti_propack_PP_IN Aedessimpsoni_PP_IN Anophelesgambiae_PP_IN AnophelesCostani_PP_IN Anophelesfunestus_PP_IN Culex_PP_IN IndoorsTotal_PP_IN Aedes_PP_OUT Aedessimpsoni_PP_OUT Anophelesgambiae_PP_OUT Anophelesfunestus_PP_OUT Culex_PP_OUT OutdoorsTotal_PP_OUT GrandTotal_PP Aedes_eagypti_HLC_IN Aedes_eagypti_HLC_OUT Aedes_eagypti_HLC_TTL Anopheles_gambiae_HLC_IN Anopheles_gambiae_HLC_OUT Anopheles_gambiae_HLC_TTL Anopheles_funestus_HLC_IN Anopheles_funestus_HLC_OUT Anopheles_funestus_HLC_TTL Aedes_simpsoni_HLC_IN Aedes_simpsoni_HLC_OUT Aedes_simpsoni_HLC_TTL Culex_species_HLC_IN Culex_species_HLC_OUT Culex_species_HLC_TTL HLC_Grand_TTL rainfall_mm_{
xtline `var', overlay title(`var' by City and month)  xtitle(Month and Year) xlabel(#20, angle(45) )
graph export "`var'.tif", width(4000) replace  
}

replace city = "c" if city =="Chulaimbo"
replace city = "k" if city =="Kisumu"
replace city = "m" if city =="Msambweni"
replace city = "u" if city =="Ukunda"
replace city = "c" if city =="chulaimbo"
replace city = "k" if city =="obama"

gen site = "" 
replace site = "coast" if city =="m"|city =="u"
replace site = "west" if city =="k"|city =="c"

encode city, gen(city1)
drop city
rename city1 city
tab city
tab city, nolab

encode site, gen(site1)
drop site
rename site1 site
tab site
tab site, nolab

save merged_enviro.dta, replace
