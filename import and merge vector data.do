/*************************************************************
 *amy krystosik                  							  *
 *import and clearn vector data*
 *lebeaud lab               				        		  *
 *last updated feb 2, 2017 									  *
 **************************************************************/ 
capture log close 
*cd "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Dan Weikel\KenyaMerged&FormattedDataSets copy"
cd "C:/Users/amykr/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/built environement hcc"
local export "C:\Users\amykr\Box Sync\Amy Krystosik's Files\vector\"
log using "`export'built environement hcc.smcl", text replace 
set scrollbufsize 100000
set more 1

foreach dataset in OvitrapMonthlySummaries ProkopackMonthlySummaries  SentinelTrapMonthlySummaries LarvalMonthlySummaries LandingCatchesMonthlySummaries{
	foreach sheet in Chulaimbo Kisumu Msambweni Ukunda{
		import excel "`dataset'.xls", sheet(`sheet') firstrow clear
		rename *, lower
		gen dataset = "`dataset'`sheet'"
		capture rename month date
		capture rename Date, lower
		
		gen dm= monthly(date, "MY")
		gen date2 = dofm(dm)
		format date2 %d
		gen interviewmonth=month(date2)
		gen interviewyear=year(date2)

		capture drop date
		capture rename site city
		replace city = lower(city) 


		save "`export'\`dataset'`sheet'.dta", replace
	}
}

foreach dataset in ChulaimboMonthlyClimateData KisumuMonthlyClimateData  UkundaMonthlyClimateData MsamMonthlyClimateData {
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
		capture gen city = "`dataset'"
		replace city = lower(city) 
	save "`export'\`dataset'.dta", replace
}

use "`export'SentinelTrapMonthlySummariesKisumu.dta" , clear
save "`export'merged_vector_climate", replace
foreach dataset in "`export'SentinelTrapMonthlySummariesMsambweni.dta" "`export'SentinelTrapMonthlySummariesUkunda.dta" "`export'UkundaMonthlyClimateData.dta" "`export'ChulaimboMonthlyClimateData.dta" "`export'KisumuMonthlyClimateData.dta" "`export'LarvalMonthlySummariesChulaimbo.dta" "`export'LarvalMonthlySummariesKisumu.dta" "`export'LarvalMonthlySummariesMsambweni.dta" "`export'LarvalMonthlySummariesUkunda.dta" "`export'MsamMonthlyClimateData.dta" "`export'OvitrapMonthlySummariesChulaimbo.dta" "`export'OvitrapMonthlySummariesKisumu.dta" "`export'OvitrapMonthlySummariesMsambweni.dta" "`export'OvitrapMonthlySummariesUkunda.dta" "`export'ProkopackMonthlySummariesChulaimbo.dta" "`export'ProkopackMonthlySummariesKisumu.dta" "`export'ProkopackMonthlySummariesMsambweni.dta" "`export'ProkopackMonthlySummariesUkunda.dta" "`export'SentinelTrapMonthlySummariesChulaimbo.dta"  "`export'LandingCatchesMonthlySummariesKisumu.dta" "`export'LandingCatchesMonthlySummariesMsambweni.dta" "`export'LandingCatchesMonthlySummariesUkunda.dta" "`export'LandingCatchesMonthlySummariesChulaimbo.dta"{
	rename *, lower
	use "`export'merged_vector_climate" , clear	
	merge m:m city interviewmonth interviewyear using  "`dataset'"	
	drop _merge
	save "`export'merged_vector_climate", replace
}

destring *, replace
sum
bysort city: tab interviewmonth interviewyear, m
order city interviewmonth interviewyear
bysort city: tab interviewmonth interviewyear 
rename interviewmonth  month
rename interviewyear year
	replace city = "ukunda" if strpos(city, "ukunda")
	replace city = "msambweni" if strpos(city, "mwam")
	replace city = "msambweni" if strpos(city, "msam")
	replace city = "msambweni" if strpos(city, "msambweni")
	replace city = "msambweni" if strpos(city, "nganja")
	replace city = "msambweni" if strpos(city, "milani")
	replace city = "msambweni" if strpos(city, "milalani")
	replace city = "kisumu" if strpos(city, "kisumu")
	replace city = "chulaimbo" if strpos(city, "chulaimbo")
	tab city
gen traptype = "" 
	replace traptype = dataset 
	replace traptype = "HLC" if strpos(traptype, "LandingCatches")
	replace traptype = "Larval" if strpos(traptype, "Larval")
	replace traptype = "Prokopack" if strpos(traptype, "Prokopack")
	replace traptype = "Sentinel" if strpos(traptype, "Sentinel")
	replace traptype = "Pupal" if strpos(traptype, "Pupal")
	replace traptype = "" if strpos(traptype, "Climate")
	tab traptype
gen immature = ""
	replace immature = traptype
	replace immature = "immature" if strpos(immature, "Larval")
	replace immature = "immature" if strpos(immature, "Pupal")
	replace immature = "mature" if strpos(immature, "HLC")
	replace immature = "mature" if strpos(immature, "Prokopack")
	replace immature = "mature" if strpos(immature, "Sentinel")
	tab immature 

duplicates drop 
collapse (sum) aedesspp anophelesspp culexspp toxorhynchites anopheles culex mansoni avgtemp avgmaxtemp avgmintemp overallmaxtemp overallmintemp avgtemprange avgrh avgdewpt ttlrainfall rainfallanomalies temprangeanomalies tempdewptdiffanomalies tempanomalies rhanomalies rhtempanomalies aedessppindoor culexsppindoor indoortotal aedessppoutdoor culexsppoutdoor outdoortotal anophelessppindoor anophelessppoutdoor aedessppinside aedessppoutside anophelessppinside anophelessppoutside culexsppinside culexsppoutside aedesspptotal culextotal anophelesspptotal aedesindoor aedesoutdoor, by(city month year traptype immature) 
duplicates tag city month year, gen(dups)
tab dups
save "`export'merged_vector_climate", replace
