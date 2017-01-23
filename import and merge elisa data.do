cd "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\elisas\jan 19 2017"

capture log close 
log using "elisa_import_merge_clean.smcl", text replace 
set scrollbufsize 100000
set more 1

*import csv's
import excel "Western (Chulaimbo, Kisumu) AIC ELISA. Common sheet.xlsx", sheet("CHULAIMBO AIC") cellrange(A9:CQ680) firstrow clear
capture drop *od* 
dropmiss, force
*rename stforddenvigg_a stanforddenvigg_a 
gen dataset = "chulaimbo_aic" 
save "chulaimbo_aic" , replace

import excel "Western (Chulaimbo, Kisumu) AIC ELISA. Common sheet.xlsx", sheet("CHULAIMBO HCC") cellrange(A8:BQ1913) firstrow clear
capture drop *od* 
dropmiss, force
gen dataset = "chulaimbo_hcc"
save "chulaimbo_hcc", replace

import excel "Western (Chulaimbo, Kisumu) AIC ELISA. Common sheet.xlsx", sheet("KISUMU AIC") cellrange(A9:CF832) firstrow clear
capture drop *od* 
dropmiss, force
gen dataset = "kisuma_aic"
save "kisuma_aic", replace

import excel "Western (Chulaimbo, Kisumu) AIC ELISA. Common sheet.xlsx", sheet("KISUMU HCC") cellrange(A4:BF829) firstrow clear
capture drop *od* 
dropmiss, force
gen dataset = "kisumu_hcc"
save "kisumu_hcc", replace

import excel "UPDATED DATABASE 04 May 2016.xls.xlsx", sheet("MILALANI HCC") cellrange(A7:BW649) firstrow clear
capture drop *od* 
dropmiss, force
gen dataset = "milalani_hcc"
save "milalani_hcc", replace

import excel "UPDATED DATABASE 04 May 2016.xls.xlsx", sheet("Msambweni  AIC") cellrange(A9:BG1609) firstrow clear
capture drop *od* 
dropmiss, force
gen dataset = "msambweni_aic"
save "msambweni_aic", replace

import excel "UPDATED DATABASE 04 May 2016.xls.xlsx", sheet("NGANJA HCC") cellrange(A8:BW319) firstrow clear
capture drop *od* 
dropmiss, force
gen dataset = "nganja_hcc"
save "nganja_hcc", replace

import excel "UPDATED DATABASE 04 May 2016.xls.xlsx", sheet("Ukunda AIC") cellrange(A9:AZ3375) firstrow clear 
capture drop *od* 
dropmiss, force
gen dataset = "ukunda_aic"
save "ukunda_aic", replace

import excel "UPDATED DATABASE 04 May 2016.xls.xlsx", sheet("Ukunda HCC") cellrange(A4:BL1128) firstrow clear
capture drop *od* 
dropmiss, force
gen dataset = "ukunda_hcc"
save "ukunda_hcc", replace
clear

foreach dataset in "kisumu_hcc.dta"  "kisuma_aic.dta" "chulaimbo_aic.dta" "msambweni_aic.dta" "nganja_hcc.dta" "chulaimbo_hcc.dta" "milalani_hcc.dta"   "ukunda_aic.dta" "ukunda_hcc.dta" {
use `dataset', clear
dropmiss, force
capture drop villhouse_a
capture destring personid_a, replace

capture replace Datesamplecollected_a ="." if Datesamplecollected_a=="N/A"
capture destring Datesamplecollected_a, replace
capture recast int Datesamplecollected_a

			foreach var in ChikVIgGOD_a DenVIgGOD_a DenVIgGOD_a  DenVIgGOD_b ChikVIgGOD_b ChikVIgGOD_c DenVIgGOD_c DenVIgGOD_e DenVIgGOD_f StanfordChikVOD_d StanfordChikVOD_d N Datesamplecollected StanfordDenVOD_a P S U W AB stanforddenvigg_f stanfordchikvod_a {
			capture tostring `var', replace force
			}


	foreach var in Datesamplecollected_a Datesamplecollected_f Datesamplecollected_b Datesamplerun_a datesamplecollected_{
		capture gen `var'1 = date(`var', "MDY" ,2050)
		capture  format %td `var'1 
		capture drop `var'
		capture rename `var'1 `var'
		capture recast int `var'
			capture drop DenVIgGOD_a 
	}

		capture tostring  DenVIgG_f  StudyID_a, replace force

		ds, has(type string) 
				foreach v of varlist `r(varlist)' { 
				replace `v' = lower(`v') 
				} 
rename *, lower

save `dataset', replace
}



append using "kisumu_hcc.dta"  "kisuma_aic.dta" "chulaimbo_aic.dta" "msambweni_aic.dta" "nganja_hcc.dta" "chulaimbo_hcc.dta" "milalani_hcc.dta"   "ukunda_aic.dta" 

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

*make sure this doesn't create duplicates. also make the same changes to the demographic data.
				replace studyid_a= subinstr(studyid_a, "cmb", "hf",.) 

		

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
	gen newid_childnumber = string(real(id_childnumber) ,"%04.0f") if inrange(length(id_childnumber),0,4)
	replace newid_childnumber = string(real(id_childnumber) ,"%07.0f") if inrange(length(id_childnumber),5,7)
	replace id_childnumber 	= newid_childnumber 		

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
		*export excel using "dup2", firstrow(variables) replace
use wide.dta, clear
/*	gen dupkey = "dup" if dup2 >1
	egen id_widedup = concat(id_wide dupkey dup2) if dup2 >1
*/

tostring stanfordchikvod_a  stanforddenvigg_f chikviggod_e chikviggod_g chikviggod_h denviggod_d denviggod_g denviggod_h stanfordchikvigg_e stanfordchikvigg_f stanforddenviggod_c stanforddenviggod_f antigenused_b_f antigenused_e , replace force
	drop if dup2>1
	reshape long chikvigg_ denvigg_  stanforddenvigg_  datesamplecollected_ datesamplerun_ studyid_ followupaliquotid_ chikviggod_ denviggod_ stanfordchikvod_  stanfordchikvigg_ stanforddenvod_ aliquotid_  chikvpcr_ chikvigm_ denvpcr_ denvigm_ stanforddenviggod_ followupid_ antigenused_ , i(id_wide) j(VISIT) string
	tempfile long
	save long, replace
	
use long.dta, clear
count if id_wide==""
	
capture drop _merge

*clean var city
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

					replace city = "" if city =="?"
bysort VISIT : replace  stanfordchikvigg_= stanfordchikvigg2_a if  stanfordchikvigg_ =="" 
drop stanfordchikvigg2_a stanfordchikvod_ stanforddenvod_ stanforddenviggod_

*clean results

ds, has(type string)
	foreach var of var `r(varlist)'{
		replace `var' =trim(itrim(lower(`var')))
		rename `var', lower
	}	
	
		foreach var of varlist stanford* *igm* *igg* { 
			tostring `var', replace
			replace `var' =trim(itrim(lower(`var')))
			gen `var'_result =""
			replace `var'_result = "neg" if strpos(`var', "neg")
			replace `var'_result = "pos" if strpos(`var', "pos") 
			drop `var'
			rename `var'_result `var'
			tab `var'
		}
rename visit VISIT 
save pcr, replace
drop *pcr*
save elisas, replace

use  pcr, clear
keep id_wide id_visit VISIT studyid *pcr* dataset

foreach var in   chikvpcr_ denvpcr_{
tab `var'
gen `var'_dum = .
replace `var'_dum = 1 if strpos(`var', "pos")
replace `var'_dum = 0 if strpos(`var', "neg")
drop `var'
order `var'_dum 
}

collapse (mean)  denvpcr__dum chikvpcr__dum, by(id_wide id_visit)
save PCR_googledoc, replace
