set graphics on 
capture log close 
set scrollbufsize 100000
set more 1

log using "R01_import_interviews.smcl", text replace 
set scrollbufsize 100000
set more 1

*cd "C:\Users\amykr\Box Sync\DENV CHIKV project/Personalized Datasets/Amy/CSVs nov216/output"
cd "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\CSVs nov29_16\output"

local importcoasthcc "C:\Users\amykr\Box Sync\DENV CHIKV project\Coast Cleaned\HCC\HCC Latest/"
local importcoastaic "C:\Users\amykr\Box Sync\DENV CHIKV project\Coast Cleaned\AIC\AIC Latest/"
local importwesthcc "C:\Users\amykr\Box Sync\DENV CHIKV project\West Cleaned\HCC\HCC Latest/"
local importwestaic "C:\Users\amykr\Box Sync\DENV CHIKV project\West Cleaned\AIC\AIC Latest/"

*coast hcc
import excel "`importcoasthcc'Ukunda HCC Initial 30Nov16.xls", sheet("#LN00059") firstrow clear
	dropmiss, force piasm  trim
	dropmiss, force obs piasm  trim
	foreach var of varlist _all{
		capture rename `var', lower
	}
	ds, has(type string) 
		foreach var of var `r(varlist)'{
		capture tostring `var', replace 
		capture  replace `var'=lower(`var')
			}	
tostring *, replace force
save "Ukunda HCC Initial", replace

import excel "`importcoasthcc'Ukunda HCC Follow one  06Nov16.xls", sheet("#LN00060") firstrow clear
	dropmiss, force piasm  trim
	dropmiss, force obs piasm  trim
	foreach var of varlist _all{
		capture rename `var', lower
	}
	ds, has(type string) 
		foreach var of var `r(varlist)'{
		capture tostring `var', replace 
		capture  replace `var'=lower(`var')
			}	
			
	tostring *, replace force
save "Ukunda HCC Follow one", replace

import excel "`importcoasthcc'Ukunda HCC Follow two  06Nov16.xls", sheet("#LN00061") firstrow clear
	dropmiss, force piasm  trim
	dropmiss, force obs piasm  trim
	foreach var of varlist _all{
		capture rename `var', lower
	}
	ds, has(type string) 
		foreach var of var `r(varlist)'{
		capture tostring `var', replace 
		capture  replace `var'=lower(`var')
			}	
			
	tostring *, replace force
save "Ukunda HCC Follow two", replace

import excel "`importcoasthcc'Ukunda HCC Follow three  06Nov16.xls", sheet("#LN00056") firstrow clear
	dropmiss, force piasm  trim
	dropmiss, force obs piasm  trim
	foreach var of varlist _all{
		capture rename `var', lower
	}
	ds, has(type string) 
		foreach var of var `r(varlist)'{
		capture tostring `var', replace 
		capture  replace `var'=lower(`var')
			}	
			
	tostring *, replace force
save "Ukunda HCC Follow three", replace

import excel "`importcoasthcc'Msambweni HCC Initial 30Nov16.xls", sheet("#LN00024") firstrow clear
dropmiss, force piasm  trim
dropmiss, force obs piasm  trim
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
foreach var in datehospitalized1{
gen `var'1 = date(`var', "MDY" ,2050)
format %td `var'1 
drop `var'
rename `var'1 `var'
recast int `var'
}
tostring *, replace force 
save "Msambweni HCC Initial 06Nov16", replace
 
import excel "`importcoasthcc'Msambweni HCC Follow one 30Nov16.xls", sheet("#LN00025") firstrow clear
dropmiss, force piasm  trim
dropmiss, force obs piasm  trim
foreach var of varlist _all{
	capture rename `var', lower
}
ds, has(type string) 
	foreach var of var `r(varlist)'{
	capture tostring `var', replace 
	capture  replace `var'=lower(`var')
		}	
		desc start
foreach var in datehospitalized1{
gen `var'1 = date(`var', "MDY" ,2050)
format %td `var'1 
drop `var'
rename `var'1 `var'
recast int `var'
}
tostring *, replace force
save "Msambweni HCC Follow one 06Nov16", replace

import excel "`importcoasthcc'Msambweni HCC Follow two 30Nov16.xls", sheet("#LN00026") firstrow clear
dropmiss, force piasm  trim
dropmiss, force obs piasm  trim
foreach var of varlist _all{
	capture rename `var', lower
}
ds, has(type string) 
	foreach var of var `r(varlist)'{
	capture tostring `var', replace 
	capture  replace `var'=lower(`var')
		}
		destring childtravel nightaway everhospitalised hospitalname1 durationhospitalized1 density gametocytes houseid childindividualid fevertoday, replace
		capture tostring hospitalname1 numhospitalized , replace 

foreach var in datehospitalized1 {
gen `var'1 = date(`var', "MDY" ,2050)
format %td `var'1 
drop `var'
rename `var'1 `var'
recast int `var'
}
tostring *, replace force
save "Msambweni HCC Follow two 06Nov16", replace

import excel "`importcoasthcc'Msambweni HCC Follow three 30Nov16.xls", sheet("#LN00027") firstrow clear
dropmiss, force piasm  trim
dropmiss, force obs piasm  trim
foreach var of varlist _all{
	capture rename `var', lower
}
ds, has(type string) 
	foreach var of var `r(varlist)'{
	capture tostring `var', replace 
	capture  replace `var'=lower(`var')
		}
		destring nightaway everhospitalised hospitalname1 durationhospitalized1 , replace
capture tostring hospitalname1 numhospitalized , replace 

foreach var in 		datehospitalized1{
gen `var'1 = date(`var', "MDY" ,2050)
format %td `var'1 
drop `var'
rename `var'1 `var'
recast int `var'
}
		

tostring *, replace force
save "Msambweni HCC Follow three 06Nov16", replace

*west HCC
import excel "`importwesthcc'west_HCC_1st Followup.xlsx", sheet("Sheet1") firstrow clear
dropmiss, force piasm  trim
dropmiss, force obs piasm  trim
foreach var of varlist _all{
	capture rename `var', lower
}
ds, has(type string) 
	foreach var of var `r(varlist)'{
	capture tostring `var', replace 
	capture  replace `var'=lower(`var')
		}	
		destring mumeduclevel hospitalname1, replace
capture tostring hospitalname1 numhospitalized , replace 

foreach var in datehospitalized1{
	gen `var'1 = date(`var', "MDY" ,2050)
	format %td `var'1 
	drop `var'
	rename `var'1 `var'
	recast int `var'
}
tostring *, replace force
save "west_HCC_1st Followup", replace

import excel "`importwesthcc'west_HCC_2nd Followup.xlsx", sheet("Sheet1") firstrow clear
dropmiss, force piasm  trim
dropmiss, force obs piasm  trim
foreach var of varlist _all{
	capture rename `var', lower
}
ds, has(type string) 
	foreach var of var `r(varlist)'{
	capture tostring `var', replace 
	capture  replace `var'=lower(`var')
		}
		desc start
capture tostring hospitalname1 numhospitalized , replace 
tostring *, replace force
save "west_HCC_2nd Followup", replace

import excel "`importwesthcc'west_HCC_3rd Followup.xlsx", sheet("Sheet1") firstrow clear
dropmiss, force piasm  trim
dropmiss, force obs piasm  trim
foreach var of varlist _all{
	capture rename `var', lower
}
ds, has(type string) 
	foreach var of var `r(varlist)'{
	capture tostring `var', replace 
	capture  replace `var'=lower(`var')
		}
		capture tostring hospitalname1 numhospitalized , replace 
tostring *, replace force
save "west_HCC_3rd Followup", replace

import excel "`importwesthcc'west_HCC_Initial.xlsx", sheet("Sheet1") firstrow clear
dropmiss, force piasm  trim
dropmiss, force obs piasm  trim
foreach var of varlist _all{
	capture rename `var', lower
}
ds, has(type string) 
	foreach var of var `r(varlist)'{
	capture tostring `var', replace 
	capture  replace `var'=lower(`var')
		}	
		desc start 
		tostring childvillage , replace
		capture tostring hospitalname1 numhospitalized , replace 
tostring *, replace force
save "west_HCC_Initial", replace



*AIC
import excel "`importcoastaic'Coastal Data-Katherine aug_4_2016.xls", sheet("Coast_AIC_Init-Katherine") firstrow clear
dropmiss, force piasm  trim
dropmiss, force obs piasm  trim

ds, has(type string) 
	foreach var of var `r(varlist)'{
	capture tostring `var', replace 
	capture  replace `var'=lower(`var')
		}	

dropmiss, force
foreach var of varlist _all{
	capture rename `var', lower
}

replace splenomegaly = "1" if splenomegaly =="hyperactive_bowel_sounds" 
replace hepatomegaly= "1" if hepatomegaly=="hyperactive_bowel_sounds" 
replace jointnormal = "0" if jointnormal =="swollen"

*replace antibiotic = "0" if antibiotic =="chillsvoid"
replace chills ="0" if chills =="chillsvoid"
tostring *, replace force
save "Coast_AIC_Init-Katherine", replace

import excel "`importcoastaic'Coastal Data-Katherine aug_4_2016.xls", sheet("FILE1   4 coast_aicfu_18apr16") firstrow clear
dropmiss, force piasm  trim
dropmiss, force obs piasm  trim
foreach var of varlist _all{
	capture rename `var', lower
}
ds, has(type string) 
	foreach var of var `r(varlist)'{
	capture tostring `var', replace 
	capture  replace `var'=lower(`var')
		}	
destring scleralicterus nodeabnormal , replace
tostring nodeabnormal jointabnormal neuroabnormal antibiotic , replace
capture tostring hospitalname1 numhospitalized , replace 
tostring *, replace force
save "FILE1   4 coast_aicfu_18apr16", replace

import excel "`importcoastaic'Coastal Data-Katherine aug_4_2016.xls", sheet("FILE2  AIC Ukunda Malaria") firstrow clear
dropmiss, force piasm  trim
dropmiss, force obs piasm  trim
foreach var of varlist _all{
	capture rename `var', lower
}
ds, has(type string) 
	foreach var of var `r(varlist)'{
	capture tostring `var', replace 
	capture  replace `var'=lower(`var')
		}
capture tostring hospitalname1 numhospitalized , replace 
tostring studyid2 , replace
		encode gender, gen(sex)
		drop gender
		rename sex gender
		replace gender = gender-1
		
foreach var in dob{
	gen `var'1 = date(`var', "MDY" ,2050)
	format %td `var'1 
	drop `var'
	rename `var'1 `var'
	recast int `var'
}
tostring *, replace force
save "FILE2  AIC Ukunda Malaria", replace

**west aic**
insheet using "`importwestaic'AICFollowUpVersion15_DATA_2017-01-30_1107_west.csv", comma names clear
dropmiss, force piasm  trim
dropmiss, force obs piasm  trim
foreach var of varlist _all{
	capture rename `var', lower
}
ds, has(type string) 
	foreach var of var `r(varlist)'{
	capture tostring `var', replace 
	capture  replace `var'=lower(`var')
		}	
foreach var in end{
	gen `var'1 = date(`var', "MDY" ,2050)
	format %td `var'1 
	drop `var'
	rename `var'1 `var'
	recast int `var'
}
tostring otherhneck heartexamcoded nodeabnormal jointabnormal neuroabnormal , replace
destring adenopathy malariabloodsmear antimalarial antiparasitic ibuprofen paracetamol scleralicterus , replace
desc adenopathy 
capture tostring hospitalname1 numhospitalized , replace 
tostring *, replace force
save "Western_AICFU-Katherine", replace

insheet using "`importwestaic'AICInitialVersionOdk_DATA_2017-01-30_1041_west.csv", comma names clear
dropmiss, force piasm  trim
dropmiss, force obs piasm  trim
foreach var of varlist _all{
	capture rename `var', lower
}
ds, has(type string) 
	foreach var of var `r(varlist)'{
	capture tostring `var', replace 
	capture  replace `var'=lower(`var')
		}	

foreach var in start today interviewdate datehospitalized1 {
gen `var'1 = date(`var', "MDY" ,2050)
format %td `var'1 
drop `var'
rename `var'1 `var'
recast int `var'
}

foreach var in educlevel mumeduclevel childtravel nightaway everhospitalised hospitalname1 durationhospitalized1 counthosp{ 
tostring `var', replace
}
replace abdominalpain ="." if abdominalpain =="`"

encode childvillage, gen(childvillage_s)
drop childvillage 
rename childvillage_s childvillage 
capture tostring hospitalname1 numhospitalized , replace 
tostring *, replace force
save "West_AIC_INITIAL", replace

append using "Ukunda HCC Initial" "Ukunda HCC Follow one" "Ukunda HCC Follow two" "Ukunda HCC Follow three"  "Msambweni HCC Follow three 06Nov16" "Msambweni HCC Follow two 06Nov16" "Msambweni HCC Follow one 06Nov16" "Msambweni HCC Initial 06Nov16"  "west_HCC_1st Followup.dta" "west_HCC_2nd Followup.dta" "west_HCC_3rd Followup.dta" "west_HCC_Initial.dta" "Western_AICFU-Katherine.dta" "Coast_AIC_Init-Katherine.dta" "FILE2  AIC Ukunda Malaria.dta" "FILE1   4 coast_aicfu_18apr16.dta" , gen(append) 

replace hospitalname2 = "3" if hospitalname2 =="3) mswambweni district hospital"
replace hospitalname2 = "5" if hospitalname2 =="5) other"
replace hospitalname2 = "9" if hospitalname2 =="9) n/a"

replace durationhospitalized2 = "1" if durationhospitalized2 ==" 1) 0 - 3 days"
replace durationhospitalized2 = "1" if durationhospitalized2 =="1) 0 - 3 days"
replace durationhospitalized2 = "2" if durationhospitalized2 =="2) 4 - 7 days"
replace durationhospitalized2 = "99" if durationhospitalized2 =="99) error: check raw data to correct"
replace abdominalpain ="." if abdominalpain =="`"
replace antimalarial  = "0" if antimalarial =="ceftriaxone0"
replace ibuprofen ="0" if ibuprofen =="ceftriaxone0" 
replace paracetamol ="0" if paracetamol =="ceftriaxone01"  
replace cough ="." if cough =="`"
replace chills = "." if chills =="`" 
replace chills = "0" if chills=="chillsvoid"

destring *, replace

foreach var in end{
	gen `var'1 = date(`var', "MDY" ,2050)
	format %td `var'1 
	drop `var'
	rename `var'1 `var'
	recast int `var'
}

tab malariabloodsmear


gen fevertemp =.
replace fevertemp = 1 if temperature >= 38
replace fevertemp = 0 if temperature < 38

foreach var of varlist *date*{
		capture gen double my`var'= date(`var',"DMY")
		capture format my`var' %td
		*drop `var'
}
foreach var of varlist my*{
	gen `var'_year = year(`var')
	gen `var'_month = month(`var')
	gen `var'_day = day(`var')

}
			replace studyid = subinstr(studyid, ".", "",.) 
			replace studyid = subinstr(studyid, "/", "",.)
			replace studyid = subinstr(studyid, " ", "",.)
			replace studyid = studyid_copy if studyid =="" & studyid_copy !=""
			replace studyid = studyid1 if studyid =="" & studyid1 !=""
			
	duplicates tag studyid, gen(dup_merged) 
	tab dup_merged
	save merged, replace
	*keep those that i dropped for duplicate and show to elysse
		keep if dup_merged >0	
		outsheet using "dupinterviews", comma replace
	use merged.dta, clear
	drop if dup_merged >0
			isid studyid
	
save merged, replace


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
foreach suffix in a b c d e f g h {
	replace suffix = "`suffix'" if strpos(id_childnumber, "`suffix'")
	replace id_childnumber = subinstr(id_childnumber, "`suffix'","", .)
	}
destring id_childnumber, replace 	 
tostring id_childnumber, replace
egen id_childnumber2 = concat(id_childnumber suffix)
drop id_childnumber
rename id_childnumber2 id_childnumber
	order id_cohort id_city id_visit id_childnumber studyid
	egen id_wide = concat(id_city id_cohort id_childnum)
drop suffix

duplicates tag id_wide id_visit, gen(id_wide_id_visit_dup)
tab id_wide_id_visit_dup
outsheet id_wide_id_visit_dup studyid id_wide id_visit using "C:\Users\amykr\Box Sync\Amy Krystosik's Files\duplicates dropped\hcc_aic_interviews_wide_id_visit_dup.csv" if id_wide_id_visit_dup>0, comma names replace
drop if id_wide_id_visit_dup>0
isid id_city id_cohort  id_childnumber id_visit 
isid id_wide id_visit


save temp, replace
	
	encode site, gen(siteint)
	drop site
	rename siteint site
destring *, replace
save all_interviews, replace

use all_interviews, replace
*export the malaria results for coast hcc to the lab results section.
keep if id_city == "u"|id_city == "g"|id_city == "l" & id_cohort =="c"
dropmiss, force
dropmiss, obs force
lookfor childnumber
keep id_wide id_visit id_cohort id_city species prev density gametocytes id_childnumber
egen studyid = concat(id_city id_cohort id_visit id_childnumber)
order studyid  id_wide id_city id_cohort id_visit id_childnumber species prev density gametocytes
outsheet using "C:\Users\amykr\Box Sync\DENV CHIKV project\Lab Data\Malaria Database\Malaria Latest\coast\coast_hcc_malaria.csv", replace comma names

*create list of those without demogrpahy data from cornelius
		import excel using "C:\Users\amykr\Box Sync\DENV CHIKV project\West Cleaned\Demography\Demography Latest\id's with no demography data_cornelius_march3_2017.xlsx", clear firstrow
			gen no_demography =1
			replace StudyID = lower(StudyID)
			rename StudyID studyid 
			replace studyid = subinstr(studyid, ".", "",.) 
			replace studyid = subinstr(studyid, "/", "",.)
			replace studyid = subinstr(studyid, " ", "",.)

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
		foreach suffix in a b c d e f g h {
			replace suffix = "`suffix'" if strpos(id_childnumber, "`suffix'")
			replace id_childnumber = subinstr(id_childnumber, "`suffix'","", .)
			}
		destring id_childnumber, replace 	 
		tostring id_childnumber, replace
		egen id_childnumber2 = concat(id_childnumber suffix)
		drop id_childnumber
		rename id_childnumber2 id_childnumber
			order id_cohort id_city id_visit id_childnumber studyid
			egen id_wide = concat(id_city id_cohort id_childnum)
		drop suffix

		duplicates tag id_wide id_visit, gen(id_wide_id_visit_dup)
		tab id_wide_id_visit_dup
keep studyid id_wide  id_visit no_demography
save "C:\Users\amykr\Box Sync\DENV CHIKV project\West Cleaned\Demography\Demography Latest\no_demography", replace
