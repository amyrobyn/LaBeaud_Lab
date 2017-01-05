set graphics on 
capture log close 
set scrollbufsize 100000
set more 1

log using "R01_import_interviews.smcl", text replace 
set scrollbufsize 100000
set more 1

cd "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\CSVs nov29_16"

local import "C:\Users\amykr\Box Sync\DENV CHIKV project/Personalized Datasets/Amy/longitudinal_analysis_sept152016/"
local importnov15 "C:\Users\amykr\Box Sync\DENV CHIKV project/Coast Cleaned/HCC/HCC Latest/"

import excel "`importnov15'Msambweni HCC Initial 30Nov16.xls", sheet("#LN00024") firstrow clear
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
destring childoccupation childvillage educlevel mumeduclevel childtravel nightaway everhospitalised hospitalname1 durationhospitalized1 houseid childindividualid phonenumber fevertoday numillnessfever durationsymptom , replace		
foreach var in datehospitalized1{
gen `var'1 = date(`var', "MDY" ,2050)
format %td `var'1 
drop `var'
rename `var'1 `var'
recast int `var'
}
save "Msambweni HCC Initial 06Nov16", replace
	 
  
import excel "`importnov15'Msambweni HCC Follow one 30Nov16.xls", sheet("#LN00025") firstrow clear
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
save "Msambweni HCC Follow one 06Nov16", replace



import excel "`importnov15'Msambweni HCC Follow two 30Nov16.xls", sheet("#LN00026") firstrow clear
dropmiss, force
foreach var of varlist _all{
	capture rename `var', lower
}
ds, has(type string) 
	foreach var of var `r(varlist)'{
	capture tostring `var', replace 
	capture  replace `var'=lower(`var')
		}
		destring childtravel nightaway everhospitalised hospitalname1 durationhospitalized1 density gametocytes houseid childindividualid fevertoday, replace
		
foreach var in datehospitalized1 {
gen `var'1 = date(`var', "MDY" ,2050)
format %td `var'1 
drop `var'
rename `var'1 `var'
recast int `var'
}
save "Msambweni HCC Follow two 06Nov16", replace


import excel "`importnov15'Msambweni HCC Follow three 30Nov16.xls", sheet("#LN00027") firstrow clear
dropmiss, force
foreach var of varlist _all{
	capture rename `var', lower
}
ds, has(type string) 
	foreach var of var `r(varlist)'{
	capture tostring `var', replace 
	capture  replace `var'=lower(`var')
		}
		destring nightaway everhospitalised hospitalname1 durationhospitalized1 , replace

foreach var in 		datehospitalized1{
gen `var'1 = date(`var', "MDY" ,2050)
format %td `var'1 
drop `var'
rename `var'1 `var'
recast int `var'
}
		


save "Msambweni HCC Follow three 06Nov16", replace

*west HCC
import excel "`import'HCC_1st Followup.xls", sheet("Sheet1") firstrow clear
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
foreach var in interviewdate datehospitalized1 {
gen `var'1 = date(`var', "MDY" ,2050)
format %td `var'1 
drop `var'
rename `var'1 `var'
recast int `var'
}
		save "west_HCC_1st Followup", replace

import excel "`import'HCC_2nd Followup.xls", sheet("Sheet1") firstrow clear
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

foreach var in start{
gen `var'1 = date(`var', "MDY" ,2050)
format %td `var'1 
drop `var'
rename `var'1 `var'
recast int `var'
}

save "west_HCC_2nd Followup", replace

import excel "`import'HCC_3rd Followup.xls", sheet("Sheet1") firstrow clear
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

save "west_HCC_3rd Followup", replace

import excel "`import'HCC_Initial.xls", sheet("Sheet1") firstrow clear
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
		tostring childvillage , replace
save "west_HCC_Initial", replace



*AIC
insheet using "`import'Coast_AIC_Init-Katherine.csv", comma clear
replace splenomegaly = "1" if splenomegaly =="hyperactive_bowel_sounds" 
replace hepatomegaly= "1" if hepatomegaly=="hyperactive_bowel_sounds" 

dropmiss, force
foreach var of varlist _all{
	capture rename `var', lower
}

ds, has(type string) 
	foreach var of var `r(varlist)'{
	capture tostring `var', replace 
	capture  replace `var'=lower(`var')
		}	
		
foreach var in start today interviewdate dob datehospitalized1 end {
gen `var'1 = date(`var', "MDY" ,2050)
format %td `var'1 
drop `var'
rename `var'1 `var'
recast int `var'
}
replace jointnormal = "0" if jointnormal =="swollen"

replace ovaparasites ="." if ovaparasites =="00chemistry"
*replace antibiotic = "0" if antibiotic =="chillsvoid"
replace chills ="0" if chills =="chillsvoid"
destring splenomegaly hepatomegaly nodenormal jointnormal neuronormal ovaparasites chills adenopathy, replace
tostring antibiotic , replace
tab malariabloods~r 
save "Coast_AIC_Init-Katherine", replace

insheet using "`import'FILE1   4 coast_aicfu_18apr16.csv", comma clear
dropmiss, force
foreach var of varlist _all{
	capture rename `var', lower
}
ds, has(type string) 
	foreach var of var `r(varlist)'{
	capture tostring `var', replace 
	capture  replace `var'=lower(`var')
		}	

foreach var in start today dob end {
gen `var'1 = date(`var', "MDY" ,2050)
format %td `var'1 
drop `var'
rename `var'1 `var'
recast int `var'
}
destring scleralicterus nodeabnormal , replace
tostring nodeabnormal jointabnormal neuroabnormal antibiotic , replace
*tab malariabloods~r 
save "FILE1   4 coast_aicfu_18apr16", replace

insheet using "`import'FILE2  AIC Ukunda Malaria...  .csv", comma clear
dropmiss, force
foreach var of varlist _all{
	capture rename `var', lower
}
ds, has(type string) 
	foreach var of var `r(varlist)'{
	capture tostring `var', replace 
	capture  replace `var'=lower(`var')
		}
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

*tab malariabloods~r 
save "FILE2  AIC Ukunda Malaria", replace

insheet using "`import'Western_AICFU-Katherine.csv", comma clear
dropmiss, force
foreach var of varlist _all{
	capture rename `var', lower
}
ds, has(type string) 
	foreach var of var `r(varlist)'{
	capture tostring `var', replace 
	capture  replace `var'=lower(`var')
		}	

foreach var in today start interviewdate dob end{
gen `var'1 = date(`var', "MDY" ,2050)
format %td `var'1 
drop `var'
rename `var'1 `var'
recast int `var'
}
tostring otherhneck heartexamcoded nodeabnormal jointabnormal neuroabnormal , replace
destring adenopathy malariabloodsmear antimalarial antiparasitic ibuprofen paracetamol scleralicterus , replace
desc adenopathy 
tab malariabloods~r 
save "Western_AICFU-Katherine", replace

insheet using "`import'Western_AIC_Init-Katherine.csv", comma clear case
dropmiss, force
foreach var of varlist _all{
	capture rename `var', lower
}
ds, has(type string) 
	foreach var of var `r(varlist)'{
	capture tostring `var', replace 
	capture  replace `var'=lower(`var')
		}	
foreach var in start today interviewdate dob datehospitalized1 {
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

foreach var in childoccupation educlevel mumeduclevel childtravel nightaway everhospitalised hospitalname1 durationhospitalized1 malariapastmedhist paracetamolcurrentmeds{
destring `var', replace
}


encode childvillage, gen(childvillage_s)
drop childvillage 
rename childvillage_s childvillage 
tab malariabloods~r 
save "West_AIC_INITIAL", replace

append using "Msambweni HCC Follow three 06Nov16", gen(append) 
tab malariabloodsmear

foreach var in childoccupation educlevel mumeduclevel{ 
tostring `var', replace
}

foreach var in childvillage { 
tostring `var', gen(`var'1)
drop `var'
rename `var'1 `var'
}
destring everhospitalised , replace
drop append

append using "Msambweni HCC Follow two 06Nov16", gen(append) 

foreach var in childtravel childvillage density gametocytes childoccupation{
destring `var', replace
}
foreach var in childtravel outdooractivity mosquitobites mosquitocoil sleepbednet numhospitalized hospitalname2 durationhospitalized2{ 
tostring `var', replace
}


destring educlevel mumeduclevel childtravel nightaway everhospitalised hospitalname1 durationhospitalized1 houseid childindividualid phonenumber fevertoday numillnessfever numillnessfever durationsymptom seekmedcare medtype wheremedseek numhosp , replace
drop append
append using "Msambweni HCC Follow one 06Nov16" "Msambweni HCC Initial 06Nov16"  "west_HCC_1st Followup.dta" "west_HCC_2nd Followup.dta" "west_HCC_3rd Followup.dta" , gen(append)  


foreach var in end{
gen `var'1 = date(`var', "MDY" ,2050)
format %td `var'1 
drop `var'
rename `var'1 `var'
recast int `var'
}
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
destring outdooractivity avoidmosquitoes mosquitobites mosquitocoil sleepbednet numhospitalized hospitalname2 durationhospitalized2 malariapastmedhist paracetamolcurrentmeds abdominalpain malariabloodsmear antimalarial ibuprofen paracetamol counthosp numsiblings cough chills scleralicterus , replace
tostring heartexamcoded stageofdiseasecoded childvillage antibiotic, replace
drop append

append using "west_HCC_Initial.dta" "Western_AICFU-Katherine.dta" "Coast_AIC_Init-Katherine.dta" "FILE2  AIC Ukunda Malaria.dta" "FILE1   4 coast_aicfu_18apr16.dta" , gen(append) 

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
			replace studyid = studyid2 if studyid =="" & studyid2 !=""
			drop if studyid ==""
			
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
	order id_cohort id_city id_visit id_childnumber studyid
	egen id_wide = concat(id_city id_cohort id_childnum)

save temp, replace
	
	encode site, gen(siteint)
	drop site
	rename siteint site

*clean age variable
foreach var in interviewdate2 {
gen `var'1 = date(`var', "MDY" ,2050)
format %td `var'1 
drop `var'
rename `var'1 `var'
recast int `var'
}

replace interviewdate = interviewdate2 if interviewdate ==.
gen agecalc = (interviewdate-dob)/360
replace age = age2 if age==.
replace age = childage if age==.
replace age = agecalc if age==.
drop age2 childage agecalc
replace age = round(age)
replace agemonths = round(agemonths)

*clean city and site vars
drop site
rename id_city city
replace city ="c" if city =="r" 

	   					replace city  = "Chulaimbo" if city == "c"
						replace city  = "Msambweni" if city == "m"
						replace city  = "Kisumu" if city == "k"
						replace city  = "Ukunda" if city == "u"
						replace city  = "Milani" if city == "l"
						replace city  = "Nganja" if city == "g"
					gen westcoast= "." 
						replace westcoast = "Coast" if city =="Msambweni"|city =="Ukunda"|city =="Milani"|city =="Nganja"
						replace westcoast = "West" if city =="Chulaimbo"|city =="Kisumu"
					encode westcoast, gen(site)			

save all_interviews, replace
