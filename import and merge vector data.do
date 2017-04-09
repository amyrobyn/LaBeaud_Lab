/*************************************************************
 *amy krystosik                  							  *
 *import and clearn vector data*
 *lebeaud lab               				        		  *
 *last updated feb 2, 2017 									  *
 **************************************************************/ 
capture log close 
cd "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Dan Weikel\KenyaMerged&FormattedDataSets copy"
local export "C:\Users\amykr\Box Sync\Amy Krystosik's Files\vector\"

log using "`export'built environement hcc.smcl", text replace 
set scrollbufsize 100000
set more 1

foreach dataset in OvitrapMonthlySummaries ProkopackMonthlySummaries  SentinelTrapMonthlySummaries LarvalMonthlySummaries {
	foreach sheet in Chulaimbo Kisumu Msambweni Ukunda{
		import excel "`dataset'.xls", sheet(`sheet') firstrow clear
		rename *, lower
		gen dataset = "`dataset'`sheet'"
		capture rename Date, lower
		
		gen dm= monthly(date, "MY")
		gen date2 = dofm(dm)
		format date2 %d
		gen interviewmonth=month(date2)
		gen interviewyear=year(date2)

		drop date
		replace city = lower(city) 


		save "`export'\`dataset'`sheet'.dta", replace
	}
}

foreach dataset in ChulaimboMonthlyClimateData KisumuMonthlyClimateData LandingCatchesMonthlySummaries1 UkundaMonthlyClimateData MsamMonthlyClimateData {
	import excel "`dataset'.xls", sheet(`dataset') firstrow clear
	gen dataset = "`dataset'"
	rename *, lower
	capture rename Date, lower
	
		gen dm= monthly(date, "MY")
		gen date2 = dofm(dm)
		format date2 %d
		gen interviewmonth=month(date2)
		gen interviewyear=year(date2)

		drop date
		replace city = lower(city) 

	save "`export'\`dataset'.dta", replace
}

use "C:\Users\amykr\Box Sync\Amy Krystosik's Files\vector\ProkopackMonthlySummariesKisumu.dta" , clear
save "`export'merged_vector_climate", replace

foreach dataset in  "C:\Users\amykr\Box Sync\Amy Krystosik's Files\vector\ProkopackMonthlySummariesMsambweni.dta" "C:\Users\amykr\Box Sync\Amy Krystosik's Files\vector\ProkopackMonthlySummariesUkunda.dta" "C:\Users\amykr\Box Sync\Amy Krystosik's Files\vector\SentinelTrapMonthlySummariesChulaimbo.dta" "C:\Users\amykr\Box Sync\Amy Krystosik's Files\vector\SentinelTrapMonthlySummariesKisumu.dta" "C:\Users\amykr\Box Sync\Amy Krystosik's Files\vector\SentinelTrapMonthlySummariesMsambweni.dta" "C:\Users\amykr\Box Sync\Amy Krystosik's Files\vector\SentinelTrapMonthlySummariesUkunda.dta" "C:\Users\amykr\Box Sync\Amy Krystosik's Files\vector\UkundaMonthlyClimateData.dta" "C:\Users\amykr\Box Sync\Amy Krystosik's Files\vector\ChulaimboMonthlyClimateData.dta" "C:\Users\amykr\Box Sync\Amy Krystosik's Files\vector\KisumuMonthlyClimateData.dta" "C:\Users\amykr\Box Sync\Amy Krystosik's Files\vector\LandingCatchesMonthlySummaries1.dta" "C:\Users\amykr\Box Sync\Amy Krystosik's Files\vector\LarvalMonthlySummariesChulaimbo.dta" "C:\Users\amykr\Box Sync\Amy Krystosik's Files\vector\LarvalMonthlySummariesKisumu.dta" "C:\Users\amykr\Box Sync\Amy Krystosik's Files\vector\LarvalMonthlySummariesMsambweni.dta" "C:\Users\amykr\Box Sync\Amy Krystosik's Files\vector\LarvalMonthlySummariesUkunda.dta" "C:\Users\amykr\Box Sync\Amy Krystosik's Files\vector\MsamMonthlyClimateData.dta" "C:\Users\amykr\Box Sync\Amy Krystosik's Files\vector\OvitrapMonthlySummariesChulaimbo.dta" "C:\Users\amykr\Box Sync\Amy Krystosik's Files\vector\OvitrapMonthlySummariesKisumu.dta" "C:\Users\amykr\Box Sync\Amy Krystosik's Files\vector\OvitrapMonthlySummariesMsambweni.dta" "C:\Users\amykr\Box Sync\Amy Krystosik's Files\vector\OvitrapMonthlySummariesUkunda.dta" "C:\Users\amykr\Box Sync\Amy Krystosik's Files\vector\ProkopackMonthlySummariesChulaimbo.dta" {
	rename *, lower
	use "`export'merged_vector_climate" , clear	
	merge m:m city interviewmonth interviewyear using  "`dataset'"	
	drop _merge
	save "`export'merged_vector_climate", replace
}

destring *, replace
sum
bysort city: tab interviewmonth interviewyear, m

collapse  (first)  aedesaegyptiindoor anophelesgambiaeindoor anophelesfunestusindoor culexsppindoor aedesaegyptioutdoor anophelesgambiaeoutdoor anophelesfunestusoutdoor culexsppoutdoor dataset dm date2 aedessimpsoniindoor anophelescostaniindoor indoortotal aedessimpsonioutdoor outdoortotal aedesaegypti anophelesgambiae anophelesfunestus culexspp toxorhynchites aedessimpsoni aedessppnotlisted masoni avgtemp avgmaxtemp avgmintemp overallmaxtemp overallmintemp avgtemprange avgrh avgdewpt ttlrainfall rainfallanomalies temprangeanomalies tempdewptdiffanomalies tempanomalies rhanomalies rhtempanomalies aedesaegyptiinside aedesaegyptioutside aedesaegyptitotal anophelesgambiaeinside anophelesgambiaeoutside anophelesgambiaetotal anophelesfunestusinside anophelesfunestusoutside k culexsppinside culexsppoutside culexspptotal o p q anophelesoutdoor culexoutdoor toxorhynchitesoutdoor anophelesindoor anophelessppoutdoor n, by(city interviewmonth interviewyear) 
bysort city: tab interviewmonth interviewyear 
rename interviewmonth  month
rename interviewyear year
save "`export'merged_vector_climate", replace
