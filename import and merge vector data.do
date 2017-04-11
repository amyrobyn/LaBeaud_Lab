/*************************************************************
 *amy krystosik                  							  *
 *import and clearn vector data*
 *lebeaud lab               				        		  *
 *last updated feb 2, 2017 									  *
 **************************************************************/ 
capture log close 
cd "C:/Users/amykr/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/built environement hcc/vector and climate"
log using "built environement hcc.smcl", text replace 
set scrollbufsize 100000
set more 1

import excel "PupaeMonthlySummaries.xls", sheet(Chulaimbo) firstrow clear
gen city ="Chulaimbo"
gen traptype ="PupaeMonthlySummaries"
rename *Date date
drop if city == "Chulaimbo"
save vector, replace

foreach dataset in PupaeMonthlySummaries SentinelTrapMonthlySummaries ProkopackMonthlySummaries LandingCatchesMonthlySummaries OvitrapMonthlySummaries LarvalMonthlySummaries{
	foreach sheet in Chulaimbo Kisumu Msambweni Ukunda{
	import excel "`dataset'.xls", sheet(`sheet') firstrow clear
	gen city  = "`sheet'"
	tab city
	gen traptype = "`dataset'"
	tab traptype
	capture rename *Date date
	capture rename *date date
	save "`dataset'`sheet'.dta", replace
	use vector, clear
	append using "`dataset'`sheet'.dta"
	replace city =lower(city)
	save vector, replace	
	}
}	
use vector, clear
sum 
replace traptype= subinstr(traptype, "MonthlySummaries", "", .)
replace traptype= "HLC" if traptype =="LandingCatches"
replace traptype= "sentinel" if traptype =="SentinelTrap"
tab traptype
tab city

reshape wide Ttl_AedessppIndoor ttl_Aedes_spp_Outdoor Ttl_Aedesspp , j(traptype) i(date city) s
sort date
bysort city: sum 

gen dm= monthly(date, "MY")
		gen date2 = dofm(dm)
		format date2 %d
		gen month=month(date2)
		gen year=year(date2)
save vector, replace
/*gen immature =. 
replace immature =1 if traptype=="LarvalMonthlySummaries"|traptype=="OvitrapMonthlySummaries"|traptype=="PupaeMonthlySummaries"
replace immature =0 if traptype=="LandingCatchesMonthlySummaries"|traptype=="ProkopackMonthlySummaries"|traptype=="SentinelTrapMonthlySummaries"
tab immature
*/


foreach dataset in MsamMonthlyClimateData KisumuMonthlyClimateData ChulaimboMonthlyClimateData UkundaMonthlyClimateData {
	import excel "`dataset'.xls", sheet(`dataset') firstrow clear
	gen dataset = "`dataset'"
	rename *, lower
	capture rename month date
	capture rename Date, lower
	
		gen dm= monthly(date, "MY")
		gen date2 = dofm(dm)
		format date2 %d
		gen interviewmonth=month(date2)
		gen interviewyear=year(date2)

		drop date
	save "`dataset'.dta", replace
}
foreach dataset in "MsamMonthlyClimateData.dta" "UkundaMonthlyClimateData.dta" "ChulaimboMonthlyClimateData.dta" "KisumuMonthlyClimateData.dta" {
use "`dataset'"
	rename *, lower
	replace dataset = lower(dataset)
	capture drop city 
	gen city = dataset
	replace city = "ukunda" if strpos(city, "ukunda")
	replace city = "msambweni" if strpos(city, "mwam")
	replace city = "msambweni" if strpos(city, "msam")
	replace city = "msambweni" if strpos(city, "nganja")
	replace city = "msambweni" if strpos(city, "milani")
	replace city = "msambweni" if strpos(city, "milalani")
	replace city = "kisumu" if strpos(city, "kisumu")
	replace city = "chulaimbo" if strpos(city, "chulaimbo")
	tab city
tab dataset, m
capture drop traptype

duplicates drop 
capture drop dups
duplicates tag city interviewmonth interviewyear , gen(dups)
tab dups
replace city =lower(city)
save "`dataset'", replace
}

use "MsamMonthlyClimateData.dta" 
append using "UkundaMonthlyClimateData.dta" "ChulaimboMonthlyClimateData.dta" "KisumuMonthlyClimateData.dta"
	destring *, replace
		sum
		bysort city: tab interviewmonth interviewyear, m
		order city interviewmonth interviewyear
		bysort city: tab interviewmonth interviewyear 
	rename interviewmonth  month
	rename interviewyear year
save climate, replace
duplicates tag month year city, gen(dup)
tab dup
replace city =lower(city)
merge 1:1 city month year using vector	
drop date date2 dups dup dm _merge
sum 
replace city =lower(city)
tab city 
tab month year
save "C:\Users\amykr\Box Sync\Amy Krystosik's Files\vector\merged_vector_climate", replace
duplicates tag month year city , gen(dup)
tab dup
