/**************************************************************
 *amy krystosik                  							  *
 *R01 results and discrepencies by strata (lab, antigen, test)*
 *lebeaud lab               				        		  *
 *last updated august 15, 2016  							  *
 **************************************************************/
local import "C:\Users\Amy\Box Sync\Amy Krystosik's Files\R01\longitudinal_analysis_aug252016\"
cd "C:\Users\Amy\Box Sync\Amy Krystosik's Files\R01\longitudinal_analysis_aug252016\output"
 
capture log close 
log using "enviro.smcl", text replace 
set scrollbufsize 100000
set more 1


insheet using "`import'Rainfall_Daily Data_Jul 1 2016.csv", comma clear
gen date2 = date(date, "M20Y")
format date2  %tmy
gen year = year(date2)
gen month = month(date2)
collapse chulaimbo_rainfall_mm obama_rainfall_mm, by(month year) 
rename chulaimbo_rainfall_mm rainfall_mm_chulaimbo 
rename obama_rainfall_mm rainfall_mm_obama
reshape long rainfall_mm_, i(year month) j(Site) string
save Rainfall, replace

import excel "`import'Mosquito monthly summaries coast Jun16.xls", sheet("Prokopack") firstrow clear
tab month, m
save Prokopack, replace
import excel "`import'Mosquito monthly summaries coast Jun16.xls", sheet("pupae") firstrow clear
tab month, m
save pupae, replace
import excel "`import'Mosquito monthly summaries coast Jun16.xls", sheet("BG sentinel") firstrow clear
tab month, m
save BG_sentinel, replace
import excel "`import'Mosquito monthly summaries coast Jun16.xls", sheet("Larval") firstrow clear
tab month, m
save Larval, replace
import excel "`import'Mosquito monthly summaries coast Jun16.xls", sheet("Ovitraps") firstrow clear
tab month, m
save Ovitraps, replace
import excel "`import'Mosquito monthly summaries coast Jun16.xls", sheet("HLC") firstrow clear
tab month, m
save HLC, replace

merge m:m month year Site using Rainfall
drop _merge
capture drop  Month_year 
capture drop  MonthYear
save merged_enviro.dta, replace


foreach dataset in "Prokopack" "pupae" "BG_sentinel" "Larval" "Ovitraps"{
use `dataset', clear

	capture drop MonthYear 
	capture drop Month_year 
	capture drop MonthYear

merge m:m year month  Site  using merged_enviro.dta
drop _merge
save merged_enviro.dta, replace
}
gen date= ym(year, month)
format date %tm
encode Site, gen(site_dum)
xtset site_dum date

foreach var in  Aedes_aegyti_ovi_IN Culex_species_ovi_IN Indoors_Total_ovi_IN Aedes_aegyti_ovi_OUT Culex_species_ovi_OUT Outdoors_Total_ovi_OUT Grand_Total_ovi Aedes_aegypti_Larva_IN Aedes_simpsoni_Larva_IN Anopheles_Larva_IN Culex_Larva_IN Total_Larva_IN Aedes_Larva_OUT Aedes_simpsoni_Larva_OUT Anopheles_Larva_OUT Culex_Larva_OUT Toxorhynchite_Larva_OUT Total_Larva_OUT Grand_Total_Larva Aedeseagypti_BG Aedessimpsoni_BG Aedesspp_BG Anophelesgambiae_BG Anophelesfunestus_BG Culexspecies_BG Mansoni_BG Grandtotal_BG Month_Year Aedes_aegypti_papae Anopheles_papae Culex_papae Toxorhynchites_papae GrandTotal_papae Aedes_aegypti_propack_PP_IN Aedessimpsoni_PP_IN Anophelesgambiae_PP_IN AnophelesCostani_PP_IN Anophelesfunestus_PP_IN Culex_PP_IN IndoorsTotal_PP_IN Aedes_PP_OUT Aedessimpsoni_PP_OUT Anophelesgambiae_PP_OUT Anophelesfunestus_PP_OUT Culex_PP_OUT OutdoorsTotal_PP_OUT GrandTotal_PP Aedes_eagypti_HLC_IN Aedes_eagypti_HLC_OUT Aedes_eagypti_HLC_TTL Anopheles_gambiae_HLC_IN Anopheles_gambiae_HLC_OUT Anopheles_gambiae_HLC_TTL Anopheles_funestus_HLC_IN Anopheles_funestus_HLC_OUT Anopheles_funestus_HLC_TTL Aedes_simpsoni_HLC_IN Aedes_simpsoni_HLC_OUT Aedes_simpsoni_HLC_TTL Culex_species_HLC_IN Culex_species_HLC_OUT Culex_species_HLC_TTL HLC_Grand_TTL rainfall_mm_{
xtline rainfall_mm_ , overlay title(rainfall_mm_ by site and month)  xtitle(Month and Year) xlabel(#20, angle(45) )
graph export "`var'.tif", width(4000) replace  
}
