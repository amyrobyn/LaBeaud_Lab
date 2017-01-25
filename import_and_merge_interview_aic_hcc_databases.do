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
destring *, replace
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
tab neuroabnormal 

	save "Coast_AIC_Init-Katherine", replace

	import excel "C:\Users\amykr\Box Sync\DENV CHIKV project\Coast Cleaned\AIC\AIC Latest\Coastal Data-Katherine aug_4_2016.xls", sheet("FILE1   4 coast_aicfu_18apr16") firstrow clear
	destring *, replace
	gen dataset = "coast_aicfu_18apr16"
		rename *, lower
		tostring heartexamcoded stageofdiseasecoded childvillage antibiotic, replace
		dropmiss, force
		dropmiss, force obs

	save "coast_aicfu_18apr16" , replace

	import excel "C:\Users\amykr\Box Sync\DENV CHIKV project\Coast Cleaned\AIC\AIC Latest\Coastal Data-Katherine aug_4_2016.xls", sheet("FILE2  AIC Ukunda Malaria") firstrow clear
	destring *, replace
		gen dataset = "AIC Ukunda Malaria"
		rename *, lower		
		
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
save "AIC Ukunda Malaria" , replace

*coast hcc	    
import excel "`importcoasthcc'Msambweni HCC Initial 30Nov16.xls", sheet("#LN00024") firstrow clear
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
		destring childoccupation childvillage educlevel mumeduclevel childtravel nightaway everhospitalised hospitalname1 durationhospitalized1 houseid childindividualid phonenumber fevertoday numillnessfever durationsymptom , replace		

foreach var in childtravel childvillage density gametocytes childoccupation{
destring `var', replace
}
foreach var in childtravel durationhospitalized2{ 
tostring `var', replace
}
destring educlevel mumeduclevel childtravel nightaway everhospitalised hospitalname1 durationhospitalized1 houseid childindividualid phonenumber fevertoday numillnessfever numillnessfever durationsymptom  numhosp , replace

save "Msambweni HCC Initial 06Nov16", replace

import excel "`importcoasthcc'Msambweni HCC Follow one 30Nov16.xls", sheet("#LN00025") firstrow clear
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
		
		foreach var in childtravel childvillage density gametocytes childoccupation{
destring `var', replace
}
foreach var in childtravel { 
tostring `var', replace
}


destring educlevel mumeduclevel childtravel nightaway everhospitalised hospitalname1 durationhospitalized1 houseid childindividualid phonenumber fevertoday numillnessfever numillnessfever durationsymptom seekmedcare medtype wheremedseek numhosp , replace

save "Msambweni HCC Follow one 06Nov16", replace

import excel "`importcoasthcc'Msambweni HCC Follow two 30Nov16.xls", sheet("#LN00026") firstrow clear
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
		

save "Msambweni HCC Follow two 06Nov16", replace

import excel "`importcoasthcc'Msambweni HCC Follow three 30Nov16.xls", sheet("#LN00027") firstrow clear
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
save "Msambweni HCC Follow three 06Nov16", replace

*ukunda

	import excel "C:\Users\amykr\Box Sync\DENV CHIKV project\Coast Cleaned\HCC\HCC Latest\Ukunda HCC Initial 30Nov16.xls", sheet("#LN00059") firstrow clear
	destring *, replace
		gen dataset = "Ukunda HCC Initial 30Nov16"
		rename *, lower	
			destring childtravel nightaway fevertoday everhospitalised  childheight childweight hospitalname1 durationhospitalized1 childvillage childoccupation educlevel mumeduclevel numillnessfever durationsymptom , replace
			
			dropmiss, force
			dropmiss, force obs

			foreach var in today {
				gen `var'1 = date(`var', "MDY" ,2050)
				format %td `var'1 
				drop `var'
				rename `var'1 `var'
				recast int `var'
				}			
	save "Ukunda HCC Initial 30Nov16" , replace

	import excel "C:\Users\amykr\Box Sync\DENV CHIKV project\Coast Cleaned\HCC\HCC Latest\Ukunda HCC Follow one  06Nov16.xls", sheet("#LN00060") firstrow clear
	destring *, replace
		gen dataset = "coast_hcc_Ukunda_Follow_one _06Nov16"
		rename *, lower 
		destring childvillage houseid childindividualid childheight childweight childoccupation educlevel mumeduclevel, replace
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
		tostring phonenumber, replace
		drop phonenumber
	save "coast_hcc_Ukunda_Follow_one _06Nov16" , replace

	import excel "C:\Users\amykr\Box Sync\DENV CHIKV project\Coast Cleaned\HCC\HCC Latest\Ukunda HCC Follow two  06Nov16.xls", sheet("#LN00061") firstrow clear
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

	save "coast_hcc_Ukunda HCC Follow two  06Nov16" , replace

	import excel "C:\Users\amykr\Box Sync\DENV CHIKV project\Coast Cleaned\HCC\HCC Latest\Ukunda HCC Follow three  06Nov16.xls", sheet("#LN00056") firstrow clear
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
	save "coast_hcc_Ukunda_Follow_three_06Nov16" , replace


*west HCC
import excel "`importwesthcc'west_HCC_Initial.xlsx", sheet("Sheet1") firstrow clear
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
save "west_HCC_Initial", replace

import excel "`importwesthcc'west_HCC_1st Followup.xlsx", sheet("Sheet1") firstrow clear
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
		foreach var in childtravel childvillage childoccupation{
destring `var', replace
}
foreach var in childtravel { 
tostring `var', replace
}
destring educlevel mumeduclevel childtravel nightaway everhospitalised hospitalname1 durationhospitalized1 houseid childindividualid phonenumber fevertoday numillnessfever numillnessfever durationsymptom seekmedcare medtype wheremedseek numhosp , replace

save "west_HCC_1st Followup", replace

import excel "`importwesthcc'west_HCC_2nd Followup.xlsx", sheet("Sheet1") firstrow clear
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
		foreach var in childtravel childvillage childoccupation{
destring `var', replace
}
foreach var in childtravel { 
tostring `var', replace
}
destring educlevel mumeduclevel childtravel nightaway everhospitalised hospitalname1 durationhospitalized1 houseid childindividualid phonenumber fevertoday numillnessfever numillnessfever durationsymptom seekmedcare medtype wheremedseek , replace

save "west_HCC_2nd Followup", replace

import excel "`importwesthcc'west_HCC_3rd Followup.xlsx", sheet("Sheet1") firstrow clear
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
				
		foreach var in childvillage {
		destring `var', replace
		}
		foreach var in childtravel { 
		tostring `var', replace
		}
		destring educlevel mumeduclevel childtravel nightaway everhospitalised hospitalname1 durationhospitalized1 houseid childindividualid phonenumber fevertoday numillnessfever numillnessfever durationsymptom seekmedcare medtype wheremedseek numhosp , replace
rename end end_byte
save "west_HCC_3rd Followup", replace

import excel "`importwesthcc'west_HCC_4th Followup.xls", sheet("Sheet1") firstrow clear
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
tostring othmumeduclevel, replace

save "west_HCC_4th Followup", replace

*west aic
insheet using "`importwestaic'AICInitialVersionOdk_DATA_2017-01-24_1054.csv", comma clear
destring *, replace
					gen dataset = "west_AICInitialVersionOdk_DATA_2017-01-24_1054"
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
				tab malariabloods~r
				
				
				foreach var in start end today{
				gen `var'1 = date(`var', "MDY" ,2050)
				format %td `var'1 
				drop `var'
				rename `var'1 `var'
				recast int `var'
				}
				tab hospitalsite
replace hospitalsite = "1" if hospitalsite== "obama" 
replace hccparticipant = "0" if hccparticipant == "no" 

destring *, replace
tab hccparticipant
desc hccparticipant
stop 
		save "west_AICInitialVersionOdk_DATA_2017-01-24_1054", replace

insheet using "`importwestaic'AICFollowUpVersion15_DATA_2017-01-24_1119.csv", comma clear
				destring *, replace
	
	gen dataset = "west_AICFollowUpVersion15_DATA_2017-01-24_1119"
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
				destring adenopathy malariabloodsmear antimalarial antiparasitic ibuprofen paracetamol scleralicterus , replace
				desc adenopathy 
				tab malariabloods~r 
		save "west_AICFollowUpVersion15_DATA_2017-01-24_1119", replace

insheet using "`importwestaic'AICinitialsurveyv191_past_med_history_past_hospitalization_DATA_2017-01-24_1048.csv", comma clear
			destring *, replace
	gen dataset ="west_AICinitialsurveyv191_past_med_history_past_hospitalization_DATA"
		save "AICinitialsurveyv191_past_med_history_past_hospitalization_DATA_2017-01-24_1048", replace

clear
use "Ukunda HCC Initial 30Nov16" 
append using  "Msambweni HCC Follow two 06Nov16" "Msambweni HCC Follow three 06Nov16" 
append using  "coast_hcc_Ukunda_Follow_one _06Nov16"  

append using  "coast_hcc_Ukunda HCC Follow two  06Nov16"  
append using  "coast_hcc_Ukunda_Follow_three_06Nov16"  
append using  "west_HCC_Initial" 
append using  "west_HCC_1st Followup" 
append using  "west_HCC_2nd Followup" 
append using  "west_HCC_3rd Followup" 
append using  "west_HCC_4th Followup"  
append using  "Msambweni HCC Initial 06Nov16" 
append using  "Msambweni HCC Follow one 06Nov16"
save hcc, replace
clear
use "coast_aicfu_18apr16"  
append using "AIC Ukunda Malaria"  
append using "Coast_AIC_Init-Katherine"  
append using "west_AICInitialVersionOdk_DATA_2017-01-24_1054"  
append using "west_AICFollowUpVersion15_DATA_2017-01-24_1119" 
append using "AICinitialsurveyv191_past_med_history_past_hospitalization_DATA_2017-01-24_1048"
save aic, replace

clear 
use hcc
append using aic
save all_interview, replace 

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
 
destring id_childnumber, replace 	


	order id_cohort id_city id_visit id_childnumber studyid
	egen id_wide = concat(id_city id_cohort id_childnum suffix)
drop suffix
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
replace city ="c" if city =="h" 

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

tab id_visit visit, m
replace visit = id_visit if visit ==""
tostring visit, replace

gen studyid_all =""
order studyid_all 
foreach id in studyid studyid_copy studyid1 studyid2{
	replace studyid_all= `id' if studyid_all ==""
	drop `id'
}
rename studyid_all studyid
replace studyid = subinstr(studyid, "/", "",.)

destring _all, replace
ds, has(type string) 
			foreach v of varlist `r(varlist)' { 
				replace `v' = lower(`v') 
			}

save all_interviews, replace
