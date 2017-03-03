set graphics on 
capture log close 
set scrollbufsize 100000
set more 1

log using "R01_import_interviews.smcl", text replace 
set scrollbufsize 100000
set more 1

*output
local output "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\interviewdata\"

*cd
cd "`output'"

*west folders
local importwestaic "C:\Users\amykr\Box Sync\DENV CHIKV project\West Cleaned\AIC\AIC Latest\"
local importwesthcc "C:\Users\amykr\Box Sync\DENV CHIKV project\West Cleaned\HCC\HCC Latest\"

*coast folders
local importcoastaic C:\Users\amykr\Box Sync\DENV CHIKV project\Coast Cleaned\AIC\AIC Latest\
local importcoastaic_old C:\Users\amykr\Box Sync\DENV CHIKV project\Coast Cleaned\AIC\AIC Outdated\
local importcoasthcc C:\Users\amykr\Box Sync\DENV CHIKV project\Coast Cleaned\HCC\HCC Latest\

*coast AIC
import excel "C:\Users\amykr\Box Sync\DENV CHIKV project\Coast Cleaned\AIC\AIC Latest\Coastal Data-Katherine aug_4_2016.xls", sheet("Coast_AIC_Init-Katherine") firstrow clear
	dropmiss, force obs
	dropmiss, force 
destring *, replace
dropmiss, force obs
dropmiss, force
		gen dataset = "Coast_AIC_Init-Katherine"
		rename IF redeyes2
		rename *, lower
		replace splenomegaly = "1" if splenomegaly =="hyperactive_bowel_sounds" 
		replace hepatomegaly= "1" if hepatomegaly=="hyperactive_bowel_sounds" 
		foreach var of varlist _all{
			capture rename `var', lower
		}

		ds, has(type string) 
			foreach var of var `r(varlist)'{
			capture tostring `var', replace 
			capture  replace `var'=lower(`var')
				}	
		replace neuroabnormal = "1" if neuroabnormal =="1 ab_gait 1"
		replace neuroabnormal = "1" if neuroabnormal =="ab_gait 1"
		
		replace jointabnormal = "1" if jointabnormal =="swollen"
		replace jointnormal = "0" if jointnormal =="swollen"
		replace chills ="0" if chills =="chillsvoid"
		tostring heartexamcoded childvillage , replace
				
		dropmiss, force
		dropmiss, force obs
		replace otherhneck = "1" if otherhneck!=""
		replace otherhneck = "0" if otherhneck==""
		destring otherhneck , replace 
destring *, replace	

ds, has(type string) 
			foreach var of var `r(varlist)'{
			capture tostring `var', replace 
			capture  replace `var'=lower(`var')
}	

	save "Coast_AIC_Init-Katherine", replace

	import excel "C:\Users\amykr\Box Sync\DENV CHIKV project\Coast Cleaned\AIC\AIC Latest\Coastal Data-Katherine aug_4_2016.xls", sheet("FILE1   4 coast_aicfu_18apr16") firstrow clear
	destring *, replace
	dropmiss, force obs
	dropmiss, force
	gen dataset = "coast_aicfu_18apr16"
		rename *, lower
		tostring heartexamcoded stageofdiseasecoded childvillage antibiotic, replace
		dropmiss, force
		dropmiss, force obs

		
		ds, has(type string) 
			foreach var of var `r(varlist)'{
			capture tostring `var', replace 
			capture  replace `var'=lower(`var')
}	
save "coast_aicfu_18apr16" , replace

	import excel "C:\Users\amykr\Box Sync\DENV CHIKV project\Coast Cleaned\AIC\AIC Latest\Coastal Data-Katherine aug_4_2016.xls", sheet("FILE2  AIC Ukunda Malaria") firstrow clear
			dropmiss, force obs
			dropmiss, force 
			destring *, replace
				gen dataset = "AIC Ukunda Malaria"
				rename *, lower	
				drop studyid2
				rename studyid1 studyid
				
				foreach var in dob{
				gen `var'1 = date(`var', "MDY" ,2050)
				format %td `var'1 
				drop `var'
				rename `var'1 `var'
				recast int `var'
				}
		dropmiss, force
		dropmiss, force obs
		replace gender = subinstr(gender, " " , "", .)
		gen sex = .
		replace sex = 1 if gender =="F"
		replace sex = 0 if gender =="M"
		drop gender
		rename sex gender
		bysort studyid: gen dup = _n
		drop if dup>1
		drop dup
		
ds, has(type string) 
			foreach var of var `r(varlist)'{
			capture tostring `var', replace 
			capture  replace `var'=lower(`var')
}	

save "AIC Ukunda Malaria" , replace

*coast hcc	    
import excel "`importcoasthcc'Msambweni HCC Initial 30Nov16.xls", sheet("#LN00024") firstrow clear
	dropmiss, force obs
	dropmiss, force 
	destring *, replace
		gen dataset = "coast_Msambweni HCC Initial" 
		dropmiss, force
		foreach var of varlist _all{
			capture rename `var', lower
		}
		ds, has(type string) 
			foreach var of var `r(varlist)'{
			capture tostring `var', replace 
			capture  replace `var'=lower(`var')
				}	
		foreach var in start{
		gen `var'1 = date(`var', "MDY" ,2050)
		format %td `var'1 
		drop `var'
		rename `var'1 `var'
		recast int `var'
		}


foreach var in hospitalname2 {
replace `var'="1" if strpos(`var', "obama")	
replace `var'="2" if strpos(`var', "chulaimbo")	
replace `var'="3" if strpos(`var', "Msambweni")	
replace `var'="4" if strpos(`var', "ukunda")	
replace `var'="5" if `var'!="" & `var'!="1" & `var'!="2" & `var'!="3" & `var'!="4"  & `var'!="9"
}
destring *, replace
foreach var in durationhospitalized2 childvillage{ 
tostring `var', replace
}
ds, has(type string) 
			foreach var of var `r(varlist)'{
			capture tostring `var', replace 
			capture  replace `var'=lower(`var')
}	

save "Msambweni HCC Initial 06Nov16", replace

import excel "`importcoasthcc'Msambweni HCC Follow one 30Nov16.xls", sheet("#LN00025") firstrow clear
	dropmiss, force obs
	dropmiss, force 
	destring *, replace
		gen dataset = "Msambweni HCC Follow one" 

		dropmiss, force
		foreach var of varlist _all{
			capture rename `var', lower
		}
		ds, has(type string) 
			foreach var of var `r(varlist)'{
			capture tostring `var', replace 
			capture  replace `var'=lower(`var')
				}	
				desc start
		destring childoccupation educlevel mumeduclevel childtravel nightaway everhospitalised hospitalname1 hospitalname1 durationhospitalized1 houseid childindividualid childindividualid phonenumber fevertoday numillnessfever durationsymptom seekmedcare medtype wheremedseek numhosp, replace		
		foreach var in datehospitalized1{
		gen `var'1 = date(`var', "MDY" ,2050)
		format %td `var'1 
		drop `var'
		rename `var'1 `var'
		recast int `var'
		}
		
foreach var in  childvillage{ 
tostring `var', replace
}
ds, has(type string) 
			foreach var of var `r(varlist)'{
			capture tostring `var', replace 
			capture  replace `var'=lower(`var')
}	

save "Msambweni HCC Follow one 06Nov16", replace

import excel "`importcoasthcc'Msambweni HCC Follow two 30Nov16.xls", sheet("#LN00026") firstrow clear
	dropmiss, force obs
	dropmiss, force 
	destring *, replace
		gen dataset = "Msambweni HCC Follow two"
		dropmiss, force
		foreach var of varlist _all{
			capture rename `var', lower
		}
		ds, has(type string) 
			foreach var of var `r(varlist)'{
			capture tostring `var', replace 
			capture  replace `var'=lower(`var')

		}				
			foreach var in datehospitalized1{
			gen `var'1 = date(`var', "MDY" ,2050)
			format %td `var'1 
			drop `var'
			rename `var'1 `var'
			recast int `var'
			}
		
tostring childvillage, replace
ds, has(type string) 
			foreach var of var `r(varlist)'{
			capture tostring `var', replace 
			capture  replace `var'=lower(`var')
}	

save "Msambweni HCC Follow two 06Nov16", replace

import excel "`importcoasthcc'Msambweni HCC Follow three 30Nov16.xls", sheet("#LN00027") firstrow clear
	dropmiss, force obs
	dropmiss, force 
	destring *, replace
			gen dataset = "Msambweni HCC Follow three"
			dropmiss, force
			foreach var of varlist _all{
				capture rename `var', lower
			}
			ds, has(type string) 
				foreach var of var `r(varlist)'{
				capture tostring `var', replace 
				capture  replace `var'=lower(`var')
					}
			
			foreach var in datehospitalized1{
			gen `var'1 = date(`var', "MDY" ,2050)
			format %td `var'1 
			drop `var'
			rename `var'1 `var'
			recast int `var'
			}
			drop today
			dropmiss, force
			dropmiss, force obs
drop phonenumber
tostring childvillage, replace
ds, has(type string) 
			foreach var of var `r(varlist)'{
			capture tostring `var', replace 
			capture  replace `var'=lower(`var')
}	

save "Msambweni HCC Follow three 06Nov16", replace

*ukunda
import excel "C:\Users\amykr\Box Sync\DENV CHIKV project\Coast Cleaned\HCC\HCC Latest\Ukunda HCC Initial 30Nov16.xls", sheet("#LN00059") firstrow clear
	dropmiss, force obs
	dropmiss, force 
	destring *, replace
		gen dataset = "Ukunda HCC Initial 30Nov16"
		rename *, lower	
			dropmiss, force
			dropmiss, force obs

			foreach var in today {
				gen `var'1 = date(`var', "MDY" ,2050)
				format %td `var'1 
				drop `var'
				rename `var'1 `var'
				recast int `var'
				}			
				tostring childvillage, replace
	ds, has(type string) 
			foreach var of var `r(varlist)'{
			capture tostring `var', replace 
			capture  replace `var'=lower(`var')
}	
gen houseid2 = substr(studyid, 4, .)			
order houseid*
rename houseid oldhouseid
rename houseid2 houseid 
duplicates drop
	save "Ukunda HCC Initial 30Nov16" , replace

	import excel "C:\Users\amykr\Box Sync\DENV CHIKV project\Coast Cleaned\HCC\HCC Latest\Ukunda HCC Follow one  06Nov16.xls", sheet("#LN00060") firstrow clear
dropmiss, force obs
dropmiss, force
	destring *, replace
		gen dataset = "coast_hcc_Ukunda_Follow_one _06Nov16"
		rename *, lower 
		destring *, replace

				foreach var in start dob today {
				gen `var'1 = date(`var', "MDY" ,2050)
				format %td `var'1 
				drop `var'
				rename `var'1 `var'
				recast int `var'
				}
		dropmiss, force
		dropmiss, force obs
		tostring childvillage phonenumber, replace
		drop phonenumber
		ds, has(type string) 
			foreach var of var `r(varlist)'{
			capture tostring `var', replace 
			capture  replace `var'=lower(`var')
}	

	save "coast_hcc_Ukunda_Follow_one _06Nov16" , replace

	import excel "C:\Users\amykr\Box Sync\DENV CHIKV project\Coast Cleaned\HCC\HCC Latest\Ukunda HCC Follow two  06Nov16.xls", sheet("#LN00061") firstrow clear
	dropmiss, force obs
	dropmiss, force 
	destring *, replace
		gen dataset = "coast_hcc_Ukunda HCC Follow two  06Nov16"
		rename *, lower			
		dropmiss, force
		dropmiss, force obs
				foreach var in {
				gen `var'1 = date(`var', "MDY" ,2050)
				format %td `var'1 
				drop `var'
				rename `var'1 `var'
				recast int `var'
				}
tostring childvillage, replace
ds, has(type string) 
			foreach var of var `r(varlist)'{
			capture tostring `var', replace 
			capture  replace `var'=lower(`var')
}	

	save "coast_hcc_Ukunda HCC Follow two  06Nov16" , replace

	import excel "C:\Users\amykr\Box Sync\DENV CHIKV project\Coast Cleaned\HCC\HCC Latest\Ukunda HCC Follow three  06Nov16.xls", sheet("#LN00056") firstrow clear
	dropmiss, force obs
	dropmiss, force 
	destring *, replace
		gen dataset = "coast_hcc_Ukunda Follow three  06Nov16"
		rename *, lower
		dropmiss, force
		dropmiss, force obs

		
				foreach var in datehospitalized1 {
				gen `var'1 = date(`var', "MDY" ,2050)
				format %td `var'1 
				drop `var'
				rename `var'1 `var'
				recast int `var'
				}
				tostring childvillage, replace
				ds, has(type string) 
			foreach var of var `r(varlist)'{
			capture tostring `var', replace 
			capture  replace `var'=lower(`var')
}	

	save "coast_hcc_Ukunda_Follow_three_06Nov16" , replace


*west HCC
import excel "`importwesthcc'west_HCC_Initial.xlsx", sheet("Sheet1") firstrow clear
	dropmiss, force obs
	dropmiss, force 
	destring *, replace
	gen dataset = "west_HCC_Initial"
	dropmiss, force
	foreach var of varlist _all{
		capture rename `var', lower
	}
	ds, has(type string) 
		foreach var of var `r(varlist)'{
		capture tostring `var', replace 
		capture  replace `var'=lower(`var')
			}	
			desc start 		
drop end
dropmiss, force
dropmiss, force obs
tostring childvillage, replace
ds, has(type string) 
			foreach var of var `r(varlist)'{
			capture tostring `var', replace 
			capture  replace `var'=lower(`var')
}	

save "west_HCC_Initial", replace

import excel "`importwesthcc'west_HCC_1st Followup.xlsx", sheet("Sheet1") firstrow clear
	dropmiss, force obs
	dropmiss, force 
	destring *, replace
		gen dataset = "west_HCC_1st Followup"
		dropmiss, force
		foreach var of varlist _all{
			capture rename `var', lower
		}
		ds, has(type string) 
			foreach var of var `r(varlist)'{
			capture tostring `var', replace 
			capture  replace `var'=lower(`var')
				}	
				destring mumeduclevel hospitalname1, replace
		foreach var in datehospitalized1 {
		gen `var'1 = date(`var', "MDY" ,2050)
		format %td `var'1 
		drop `var'
		rename `var'1 `var'
		recast int `var'
		}
foreach var in childtravel childvillage{ 
tostring `var', replace
}
destring educlevel mumeduclevel childtravel nightaway everhospitalised hospitalname1 durationhospitalized1 houseid childindividualid phonenumber fevertoday numillnessfever numillnessfever durationsymptom seekmedcare medtype wheremedseek numhosp , replace
ds, has(type string) 
			foreach var of var `r(varlist)'{
			capture tostring `var', replace 
			capture  replace `var'=lower(`var')
}	

save "west_HCC_1st Followup", replace

import excel "`importwesthcc'west_HCC_2nd Followup.xlsx", sheet("Sheet1") firstrow clear
	dropmiss, force obs
	dropmiss, force 
	destring *, replace
		gen dataset = "west_HCC_2nd Followup"
		dropmiss, force
		foreach var of varlist _all{
			capture rename `var', lower
		}
		ds, has(type string) 
			foreach var of var `r(varlist)'{
			capture tostring `var', replace 
			capture  replace `var'=lower(`var')
				}
				
rename end end_byte
foreach var in childvillage { 
tostring `var', replace
}
ds, has(type string) 
			foreach var of var `r(varlist)'{
			capture tostring `var', replace 
			capture  replace `var'=lower(`var')
}	

save "west_HCC_2nd Followup", replace

import excel "`importwesthcc'west_HCC_3rd Followup.xlsx", sheet("Sheet1") firstrow clear
	dropmiss, force obs
	dropmiss, force 
	destring *, replace
		gen dataset = "west_HCC_3rd Followup"
		dropmiss, force
		foreach var of varlist _all{
			capture rename `var', lower
		}
		ds, has(type string) 
			foreach var of var `r(varlist)'{
			capture tostring `var', replace 
			capture  replace `var'=lower(`var')
				}					
		foreach var in childvillage{ 
		tostring `var', replace
		}
rename end end_byte
ds, has(type string) 
			foreach var of var `r(varlist)'{
			capture tostring `var', replace 
			capture  replace `var'=lower(`var')
}	

save "west_HCC_3rd Followup", replace

import excel "`importwesthcc'west_HCC_4th Followup.xls", sheet("Sheet1") firstrow clear
	dropmiss, force obs
	dropmiss, force 
	destring *, replace
		gen dataset = "west_HCC_4th Followup"
		dropmiss, force
		foreach var of varlist _all{
			capture rename `var', lower
		}
		ds, has(type string) 
			foreach var of var `r(varlist)'{
			capture tostring `var', replace 
			capture  replace `var'=lower(`var')
				}	
rename end end_byte
dropmiss, force
dropmiss, force obs
tostring othmumeduclevel childvillage, replace

ds, has(type string) 
			foreach var of var `r(varlist)'{
			capture tostring `var', replace 
			capture  replace `var'=lower(`var')
}	

save "west_HCC_4th Followup", replace

*west aic
insheet using "C:\Users\amykr\Box Sync\DENV CHIKV project\West Cleaned\AIC\AIC Latest\AICInitialVersionOdk_DATA_2017-01-30_1041_west.csv", comma clear
	dropmiss, force obs
	dropmiss, force 
destring *, replace
					gen dataset = "AICInitialVersionOdk_DATA_west"
					 
					replace jointabnormal = "1" if jointabnormal =="1 1"
					replace nodeabnormal = "1" if nodeabnormal =="1 1"
					replace neuroabnormal ="0" if neuroabnormal =="0"
					replace neuroabnormal ="1" if neuroabnormal !="" & neuroabnormal !="0"  
				dropmiss, force
				foreach var of varlist _all{
					capture rename `var', lower
				}
				ds, has(type string) 
					foreach var of var `r(varlist)'{
					capture tostring `var', replace 
					capture  replace `var'=lower(`var')
						}	

				foreach var in educlevel mumeduclevel{ 
				tostring `var', replace
				}

				foreach var in childoccupation educlevel mumeduclevel {
				destring `var', replace
				}
				tab hospitalsite 
				
		foreach var in datesurgery interviewdate  datehospitalized datehospitalized1 datehospitalized2 datehospitalized3 datehospitalized4  {
			gen `var'b = date(`var', "MDY" ,2050)
			format %td `var'b 
			drop `var'
			rename `var'b `var'
			recast int `var'
		}
				replace abdominalpain = "." if abdominalpain =="`"
				replace chills= "." if chills=="`"
				replace cough= "." if cough=="`" 
				drop maltestordered
				replace otherhneck = "1" if otherhneck!=""
				replace otherhneck = "0" if otherhneck==""
				replace locationhospital= "1" if locationhospital=="obama"
				replace locationhospital= "9" if locationhospital=="n/a"
				replace secondarydiag  = "2" if secondarydiag =="chik"
				replace secondarydiag  = "0" if secondarydiag =="same_as_primary"
				
				replace rdtresults = "0" if rdtresults =="negative"
				replace rdtresults = "1" if rdtresults =="positive"
				foreach var in start end today{
				gen `var'1 = date(`var', "MDY" ,2050)
				format %td `var'1 
				drop `var'
				rename `var'1 `var'
				recast int `var'
				}
	

foreach var in hospitalname1 {
replace `var'="1" if strpos(`var', "obama")	
replace `var'="2" if strpos(`var', "chulaimbo")	
replace `var'="3" if strpos(`var', "Msambweni")	
replace `var'="4" if strpos(`var', "ukunda")	
replace `var'="5" if `var'!="" & `var'!="1" & `var'!="2" & `var'!="3" & `var'!="4"  & `var'!="9"
}


foreach var in antimalarial ibuprofen paracetamol urinalysisresult stoolovacyst {
	replace `var'="0" if `var'=="ceftriaxone0"					
		replace `var'="0" if `var'=="ceftriaxone01"					
		replace `var'="0" if `var'=="normal"
		replace `var'="0" if `var'=="wbcs"
		replace `var'="0" if `var'=="other"
		replace `var'="1" if `var'=="ova_or_cysts"

}

foreach var in hospitalname2 hospitalname3 {
replace `var'="1" if strpos(`var', "obama")	
replace `var'="2" if strpos(`var', "chulaimbo")	
replace `var'="3" if strpos(`var', "Msambweni")	
replace `var'="4" if strpos(`var', "ukunda")	
replace `var'="5" if `var'!="" & `var'!="1" & `var'!="2" & `var'!="3" & `var'!="4"  & `var'!="9"
}

destring *, replace 
tostring heartexamcoded stageofdiseasecoded antibiotic, replace
dropmiss, force
dropmiss, force obs

ds, has(type string) 
			foreach var of var `r(varlist)'{
			capture tostring `var', replace 
			capture  replace `var'=lower(`var')
}	

save "AICInitialVersionOdk_DATA_west", replace

insheet using "`importwestaic'AICFollowUpVersion15_DATA_2017-01-30_1107_west.csv", comma clear
	dropmiss, force obs
	dropmiss, force 
				destring *, replace
	
	gen dataset = "AICFollowUpVersion15_DATA_west"
				dropmiss, force
				foreach var of varlist _all{
					capture rename `var', lower
				}
				ds, has(type string) 
					foreach var of var `r(varlist)'{
					capture tostring `var', replace 
					capture  replace `var'=lower(`var')
						}	

				foreach var in today start end{
				gen `var'1 = date(`var', "MDY" ,2050)
				format %td `var'1 
				drop `var'
				rename `var'1 `var'
				recast int `var'
				}
				tostring otherhneck heartexamcoded nodeabnormal jointabnormal neuroabnormal , replace
				
replace hospitalsite = "1" if strpos(hospitalsite, "obama")
replace hospitalsite = "2" if strpos(hospitalsite, "chulaimbo")
replace hospitalsite = "5" if hospitalsite!="" & hospitalsite!="1" & hospitalsite!="2" & hospitalsite!="3" & hospitalsite!="4" & hospitalsite!="9" 
replace gender = "0" if gender =="male"
replace gender = "1" if gender =="female"
tab outcome
replace outcome = "1" if strpos(outcome, "sent_home")

replace informantrelation = "2" if informantrelation == "mother" 
replace informantrelation = "3" if informantrelation == "father" 
destring *, replace
drop end
tostring heartexamcoded antibiotic , replace
dropmiss, force
ds, has(type string) 
			foreach var of var `r(varlist)'{
			capture tostring `var', replace 
			capture  replace `var'=lower(`var')
}	

save "AICFollowUpVersion15_DATA_west", replace

insheet using "`importwestaic'AICinitialsurveyv191_DATA_2017-01-30_1042.csv", comma clear
	dropmiss, force obs
	dropmiss, force 
			destring *, replace
	gen dataset ="AICinitialsurveyv191_DATA"
	dropmiss, force
	
	ds, has(type string) 
			foreach var of var `r(varlist)'{
			capture tostring `var', replace 
			capture  replace `var'=lower(`var')
}	

save "AICinitialsurveyv191_DATA", replace

clear
use 		 "Ukunda HCC Initial 30Nov16" 
destring houseid, replace
append using "Msambweni HCC Follow two 06Nov16" 
append using "Msambweni HCC Follow three 06Nov16" 
append using "coast_hcc_Ukunda_Follow_one _06Nov16"   
append using "coast_hcc_Ukunda HCC Follow two  06Nov16" 
append using "coast_hcc_Ukunda_Follow_three_06Nov16"  
append using "west_HCC_Initial"  "west_HCC_1st Followup" 
append using "west_HCC_2nd Followup" 
append using "west_HCC_3rd Followup" 
append using "west_HCC_4th Followup"  
append using "Msambweni HCC Initial 06Nov16"
append using "Msambweni HCC Follow one 06Nov16"
ds, has(type string) 
			foreach var of var `r(varlist)'{
			capture tostring `var', replace 
			capture  replace `var'=lower(`var')
}	

save hcc, replace

clear
use "coast_aicfu_18apr16"  
append using  "Coast_AIC_Init-Katherine"   
append using "AICInitialVersionOdk_DATA_west"  
append using "AICFollowUpVersion15_DATA_west"  

			replace studyid = subinstr(studyid, ".", "",.) 
			replace studyid = subinstr(studyid, "/", "",.)
			replace studyid = subinstr(studyid, " ", "",.)
			replace studyid = studyid_copy if studyid =="" & studyid_copy !=""
			drop studyid_copy 
			
			gen studyid_all =""
order studyid_all 
order studyid id

foreach id in studyid id{
	replace studyid_all= `id' if studyid_all ==""
	replace studyid_all= `id' if studyid_all =="."
	drop `id'
}

rename studyid_all studyid

bysort studyid: gen dup = _n
*outsheet using dup.csv if dup>1, comma replace names

drop if dup>1
merge 1:1 studyid using "AIC Ukunda Malaria" 
save aic, replace

use hcc, clear
drop end hospitalname2 durationhospitalized2 
append using aic
save all_interview, replace 

gen fevertemp =.
replace fevertemp = 1 if temperature >= 38 & temperature !=. 
replace fevertemp = 0 if temperature < 38 & temperature !=.	

			replace studyid = subinstr(studyid, ".", "",.) 
			replace studyid = subinstr(studyid, "/", "",.)
			replace studyid = subinstr(studyid, " ", "",.)
			replace studyid = studyid1 if studyid =="" & studyid1 !=""
			drop studyid1 
	
			
	bysort  studyid: gen dup_merged = _n 
	tab dup_merged
	list studyid if dup_merged>1
	list studyid if dup_merged>1
	tempfile merged
	save merged, replace
	*keep those that i dropped for duplicate and show to elysse
	keep if dup_merged >1	
	outsheet using "dupinterviews", comma replace
	use merged.dta, clear
	
	drop if dup_merged >1
	
tempfile merged
save merged, replace


*make sure this doesn't create duplicates. also make the same changes to the demographic data.
				replace studyid= subinstr(studyid, "cmb", "hf",.) 

				
*take visit out of id
						forval i = 1/3 { 
							gen id`i' = substr(studyid, `i', 1) 
						}
*gen id_wid without visit						 
	rename id1 id_city  
	rename id2 id_cohort  
	rename id3 id_visit 
	tab id_visit 
	gen id_childnumber = ""
	replace id_childnumber = substr(studyid, +4, .)
	
gen byte notnumeric = real(id_childnumber)==.	/*makes indicator for obs w/o numeric values*/
tab notnumeric	/*==1 where nonnumeric characters*/
list id_childnumber if notnumeric==1	/*will show which have nonnumeric*/
	
gen suffix = "" 
	replace suffix = "a" if strpos(id_childnumber, "a")
	replace id_childnumber = subinstr(id_childnumber, "a","", .)

	replace suffix = "b" if strpos(id_childnumber, "b")
	replace id_childnumber = subinstr(id_childnumber, "b","", .)
 
destring id_childnumber, replace force	
order id_childnumber

	order id_cohort id_city id_visit id_childnumber studyid
	egen id_wide = concat(id_city id_cohort id_childnum suffix)
	order id_wide  
drop suffix
save temp, replace
	
	encode site, gen(siteint)
	drop site
	rename siteint site

*clean age variable
foreach var in interview_date {
				gen `var'1 = date(`var', "MDY" ,2050)
				format %td `var'1 
				drop `var'
				rename `var'1 `var'
				recast int `var'
				}
				
replace interviewdate = interviewdate2 if interviewdate ==.
replace interviewdate = interview_date if interviewdate ==.
replace interviewdate = today if interviewdate ==.


gen agecalc = (interviewdate-dob)/360
replace childage = age2 if childage ==.
replace childage = agecalc if childage ==.
drop age2 agecalc
replace childage = round(childage)
replace agemonths = round(agemonths)

*clean city and site vars
drop site
rename id_city city
replace city ="c" if city =="r" 
replace city ="c" if city =="h" 

	   					replace city  = "Chulaimbo" if city == "c"
						replace city  = "Msambweni" if city == "m"
						replace city  = "Kisumu" if city == "k"
						replace city  = "Ukunda" if city == "u"
						replace city  = "Milani" if city == "l"
						replace city  = "Nganja" if city == "g"
					gen site= "." 
						replace site= "coast" if city =="Msambweni"|city =="Ukunda"|city =="Milani"|city =="Nganja"
						replace site = "west" if city =="Chulaimbo"|city =="Kisumu"	

tab id_visit visit, m
replace visit = id_visit if visit ==""
tostring visit, replace

replace studyid = subinstr(studyid, "/", "",.)

destring _all, replace
ds, has(type string) 
			foreach v of varlist `r(varlist)' { 
				replace `v' = lower(`v') 
			}
drop dup _merge

		
		replace hivresult = "0" if hivresult =="non_reactive"
		
		gen hivtest = 0 
		replace hivtest =1 if strpos(labtests, "hiv") & hivtest ==.
		replace hivtest =1 if strpos(labtestsother, "hiv") & hivtest ==.
		replace hivtest =1 if strpos(othlabtests, "hiv") & hivtest ==.

		gen hivpastmedhist = 0
		replace hivpastmedhist= 1 if strpos(pastmedhist, "hiv") 
		

		egen meds = concat(medsprescribe meds_prescribed meds_prescribed_other othcurrentmeds)

		gen hivmeds = 0
		replace hivmeds= 1 if strpos(meds , "anti-retrovirals") 
		replace hivmeds= 1 if strpos(meds , "arvs") 
		replace hivmeds = 1 if strpos(meds , "arv") & hivresult ==""

		gen pcpdrugs = 0 
		replace pcpdrugs=  1 if strpos(meds , "cotrimoxazole")  
		replace pcpdrugs=  1 if strpos(meds , "bactrim") & hivresult ==""
		replace pcpdrugs=  1 if strpos(meds , "septrin") & hivresult ==""
		
		
		foreach var in pcpdrugs hivmeds hivpastmedhist hivtest hivresult{
			bysort site: tab pcpdrugs  
			bysort site: tab hivmeds 
			
		}

replace site = "west" if strpos(dataset, "aic ukunda malaria") & site =="." 	
replace site = "coast" if strpos(dataset, "aicfollowupversion15_") & site =="." 	

bysort site: sum pcpdrugs hivmeds hivpastmedhist hivtest hivresult 

		foreach v in pcpdrugs hivmeds hivpastmedhist hivtest hivresult {
			tab `v' site
		}
 
egen labtests_all = concat(labtests labtestsother labslabs_ordered othlabtests othlabresults other_labs_ordered)

egen diagnosis_all = concat(primarydiag othprimarydiag secondarydiag othsecondarydiag primary_diagnosis primary_diagnosis_other secondary_diagnosis secondary_diagnosis_other)

		foreach var in primarydiag othprimarydiag secondarydiag othsecondarydiag primary_diagnosis primary_diagnosis_other secondary_diagnosis secondary_diagnosis_other{
		tostring `var', replace
		tab `var'
		*list if  strpos(`var', "hiv") 
		*list if  strpos(`var', "uti") 
		count if  strpos(`var', "hiv") 
		count if  strpos(`var', "uti") 
		count if  strpos(`var', "urinary") 
		}
order diagnosis_all meds labtests_all pcpdrugs hivmeds hivpastmedhist hivtest hivresult 
destring _all, replace		
outsheet using "C:\Users\amykr\Box Sync\Amy Krystosik's Files\david coinfectin paper\hiv.csv" if pcpdrugs ==1 | hivmeds ==1 | hivpastmedhist == 1| hivtest !=. | hivresult != .  , comma names replace
replace childage  = age_calc if childage ==.
replace childage = round(childage)
rename childage age
drop age_calc

replace childheight = child_height  if childheight ==.
drop child_height 

replace childweight = child_weight if childweight ==.
drop child_weight 


foreach var in childheight childweight {
	replace `var' = . if `var' ==999
	replace `var' = . if `var' ==99
	gen round`var' = round(`var')
	tab round`var' , m
	drop round`var' 
}

gen childheight_m = childheight/100
gen childheight_m2 = childheight_m*childheight_m 
gen childbmi = childweight/childheight_m2
net get  dm0004_1.pkg
egen zhcaukwho = zanthro(headcircum,hca,UKWHOterm), xvar(age) gender(gender) gencode(male=0, female=1)nocutoff ageunit(year) 
egen zwtukwho = zanthro(childweight,wa,UKWHOterm), xvar(age) gender(gender) gencode(male=0, female=1)nocutoff ageunit(year) 
egen zhtukwho = zanthro(childheight,ha,UKWHOterm), xvar(age) gender(gender) gencode(male=0, female=1)nocutoff ageunit(year) 
egen zbmiukwho = zanthro(childbmi , ba ,UKWHOterm), xvar(age) gender(gender) gencode(male=0, female=1)nocutoff ageunit(year) 

foreach var in zbmiukwho zhtukwho zwtukwho zhcaukwho{
	gen round`var' = round(`var')
	tab round`var' , m
	drop round`var' 
}
list zbmiukwho  age gender childbmi childheight childweight if zbmiukwho ==.
outsheet studyid gender age zwtukwho childweight  zhtukwho childheight  zbmiukwho childbmi  zhcaukwho  headcircum  if zbmiukwho  >5 & zbmiukwho  !=. |zbmiukwho  <-5 & zbmiukwho  !=. |zhcaukwho  <-5 & zhcaukwho  !=. |zhcaukwho  >5 & zhcaukwho  !=. using anthrotoreview.xls, replace
table1, vars(zhcaukwho conts \ zwtukwho conts \ zhtukwho conts \ zbmiukwho  conts \)  by(site) saving("anthrozscores.xls", replace ) missing test
outsheet studyid gender age zwtukwho childweight  zhtukwho childheight  zbmiukwho childbmi  zhcaukwho  headcircum  using anthrozscoreslist.xls, replace
sum zwtukwho zhtukwho zbmiukwho zhcaukwho, d


save all_interviews, replace
