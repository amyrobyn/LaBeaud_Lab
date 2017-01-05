cd "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\CSVs nov29_16"

capture log close 
log using "elisa_import_merge_clean.smcl", text replace 
set scrollbufsize 100000
set more 1

*import csv's
insheet using "chulaimbo aic.csv", comma clear names
capture drop *od* 
dropmiss, force
save "chulaimbo_aic", replace
insheet using "chulaimbo hcc.csv", comma clear names
capture drop *od* 
dropmiss, force
save "chulaimbo_hcc", replace
insheet using "kisumu aic.csv", comma clear names
capture drop *od* 
dropmiss, force
save "kisuma_aic", replace
insheet using "kisumu hcc.csv", comma clear names
capture drop *od* 
dropmiss, force
save "kisumu_hcc", replace
insheet using "milalani hcc.csv", comma clear names
capture drop *od* 
dropmiss, force
save "milalani_hcc", replace
insheet using "Msambweni  AIC.csv", comma clear names
capture drop *od* 
dropmiss, force
save "msambweni_aic", replace
insheet using "nganja hcc.csv", comma clear names
capture drop *od* 
dropmiss, force
save "nganja_hcc", replace
insheet using "ukunda aic.csv", comma clear names
capture drop *od* 
dropmiss, force
save "ukunda_aic", replace
insheet using "ukunda hcc.csv", comma clear names
capture drop *od* 
dropmiss, force
save "ukunda_hcc", replace
clear

foreach dataset in "chulaimbo_aic.dta" "kisumu_hcc.dta"  "chulaimbo_hcc.dta" "kisuma_aic.dta" "milalani_hcc.dta" "msambweni_aic.dta" "nganja_hcc.dta" "ukunda_aic.dta" "ukunda_hcc.dta"{
use `dataset', clear
capture drop villhouse_a
capture destring personid_a, replace
save `dataset', replace
}

append using "chulaimbo_aic.dta" "kisumu_hcc.dta"  "chulaimbo_hcc.dta" "kisuma_aic.dta" "milalani_hcc.dta" "msambweni_aic.dta" "nganja_hcc.dta" "ukunda_aic.dta"
save temp, replace
dropmiss

*drop denvigg_e 
drop if studyid_a =="example"
drop if studyid_a =="EXAMPLE"
drop if studyid_a =="Example"
save appended_september20.dta, replace

				replace studyid_a = followupid_b if studyid_a ==""
				replace studyid_a = followupid_c if studyid_a ==""
				replace studyid_a = followupaliquotid_b if studyid_a ==""
				replace studyid_a = followupaliquotid_c if studyid_a ==""
				replace studyid_a = followupaliquotid_d if studyid_a ==""
				replace studyid_a = followupaliquotid_e if studyid_a ==""
				replace studyid_a = followupaliquotid_f if studyid_a ==""
				replace studyid_a = followupaliquotid_g if studyid_a ==""
				replace studyid_a = followupaliquotid_h if studyid_a ==""
				drop studyid_c 
				drop followupaliquotid_*

				replace studyid_a =lower(studyid_a)
				replace studyid_a= subinstr(studyid_a, ".", "",.) 
				replace studyid_a= subinstr(studyid_a, "/", "",.)
				replace studyid_a= subinstr(studyid_a, " ", "",.)
				drop if studyid_a==""
		

	bysort  studyid_a: gen dup_merged = _n 
preserve
	*keep those that i dropped for duplicate and show to elysse
	keep if dup_merged >1	
	export excel using "`save'dup", firstrow(variables) replace
restore
/*
	gen dupkey = "dup" if dup_merged >1
	egen studyid_adup = concat(studyid_a dupkey dup_merged) if dup_merged >1
	replace studyid_a = studyid_adup if studyid_adup !=""
	drop dupkey
	*/
	drop if dup_merged >1
	
save merged, replace


*take visit out of id
						forval i = 1/3 { 
							gen id`i' = substr(studyid_a, `i', 1) 
						}
*gen id_wid without visit						 
	rename id1 city  
	rename id2 id_cohort  
	rename id3 id_visit 
	
	gen id_childnumber = ""
	replace id_childnumber = substr(studyid_a, +4, .)
	order id_cohort city id_visit id_childnumber studyid_a
	egen id_wide = concat(city id_cohort id_childnum)

ds, has(type string) 
foreach v of varlist `r(varlist)' { 
	replace `v' = lower(`v') 
} 
save wide, replace

	bysort id_wide: gen dup2 = _n 
	save wide, replace
		keep if dup2 >1
		export excel using "dup2", firstrow(variables) replace
use wide.dta, clear
/*	gen dupkey = "dup" if dup2 >1
	egen id_widedup = concat(id_wide dupkey dup2) if dup2 >1
*/

	drop if dup2>1
	reshape long chikvigg_ denvigg_  stanforddenvigg_  datesamplecollected_ datesamplerun_ studyid_ followupaliquotid_ chikviggod_ denviggod_ stanfordchikvod_  stanfordchikvigg_ stanforddenvod_ aliquotid_  chikvpcr_ chikvigm_ denvpcr_ denvigm_ stanforddenviggod_ followupid_ antigenused_ , i(id_wide) j(VISIT) string
	tempfile long
	save long, replace
	
use long.dta, clear
count if id_wide==""
	
capture drop _merge

*clean var city
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

					replace city = "" if city =="?"
bysort VISIT : replace  stanfordchikvigg_= stanfordchikvigg2_a if  stanfordchikvigg_ =="" 
drop stanfordchikvigg2_a stanfordchikvod_ stanforddenvod_ stanforddenviggod_
save elisas, replace
