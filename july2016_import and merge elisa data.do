cd "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\elisas\july 2016"
capture log close 
log using "elisa_import_merge_clean_july2016.smcl", text replace 
set scrollbufsize 100000
set more 1

local west "July 1 2016 - Western (Chulaimbo, Kisumu) AIC ELISA. Common sheet.xls"
local coast "July 1 2016 - Coast (Msambweni, Ukunda) AIC ELISA.Common Sheet.xls"

import excel "`west'", describe
import excel "`coast'", describe

import excel "`west'", sheet("CHULAIMBO AIC") cellrange(A8:AF1003) firstrow clear  
	dropmiss, force obs
	dropmiss, force 
	rename *, lower
	rename stford* stanford*
	gen dataset = "chulaimbo_aic" 
save "chulaimbo_aic" , replace

import excel "`west'", sheet("CHULAIMBO HCC") cellrange(A3:BA1010) firstrow clear
dropmiss, force obs
dropmiss, force 
gen dataset = "chulaimbo_hcc"
save "chulaimbo_hcc", replace

import excel "`west'", sheet("KISUMU AIC") cellrange(A8:AI1003) firstrow clear
dropmiss, force obs
dropmiss, force 
gen dataset = "kisuma_aic"
save "kisuma_aic", replace

import excel "`west'", sheet("KISUMU HCC") cellrange(A3:AY1001) firstrow clear
dropmiss, force obs
dropmiss, force 
gen dataset = "kisumu_hcc"
save "kisumu_hcc", replace

import excel "`coast'", sheet("MILALANI HCC") cellrange(A3:AY1001) firstrow clear
dropmiss, force obs
dropmiss, force 
gen dataset = "milalani_hcc"
save "milalani_hcc", replace

import excel "`coast'", sheet("Msambweni  AIC") cellrange(A9:AI1228) firstrow clear
dropmiss, force obs
dropmiss, force 
gen dataset = "msambweni_aic"
save "msambweni_aic", replace

import excel "`coast'", sheet("NGANJA HCC") cellrange(A3:AY1001) firstrow clear
dropmiss, force obs
dropmiss, force 
gen dataset = "nganja_hcc"
save "nganja_hcc", replace

import excel "`coast'", sheet("Ukunda AIC") cellrange(A8:AK1330) firstrow clear 
dropmiss, force obs
dropmiss, force 
gen dataset = "ukunda_aic"
save "ukunda_aic", replace

import excel "`coast'", sheet("Ukunda HCC") cellrange(A3:BE1139) firstrow clear
dropmiss, force 
dropmiss, force obs
gen dataset = "ukunda_hcc"
save "ukunda_hcc", replace
clear

foreach dataset in "kisumu_hcc.dta"  "kisuma_aic.dta" "chulaimbo_aic.dta" "msambweni_aic.dta" "nganja_hcc.dta" "chulaimbo_hcc.dta" "milalani_hcc.dta" "ukunda_aic.dta" "ukunda_hcc.dta" {
			use `dataset', clear
			rename *, lower
			dropmiss, force obs
			dropmiss, force 
			capture drop villhouse_a
			capture destring personid_a, replace
			
capture tostring stanforddenvod_*, replace force
capture  tostring chikviggod_*, replace force

			capture replace datesamplecollected_a ="." if datesamplecollected_a=="n/a"
			capture destring datesamplecollected_a, replace
			capture recast int datesamplecollected_a

						foreach var in  denviggod_b  denvigg_f  studyid_a denviggod_b chikviggod_a  chikviggod_a denviggod_a denviggod_a  denviggod_b chikviggod_b chikviggod_c denviggod_c denviggod_e denviggod_f stanfordchikvod_d stanfordchikvod_d n datesamplecollected stanforddenvod_a p s u w ab stanforddenvigg_f stanfordchikvod_a  stanfordchikvod_b  chikvigg_e  denvigg_e followupaliquotid_f  antigenused_d chikvigg_d  chikviggod_d chikvigg_f chikviggod_f stanfordchikvigg_d  stanforddenvigg_d antigenused_e initialaliquotid_e chikvpcr_e{
						capture tostring `var', replace 
						
						}
				foreach var in datesamplecollected_a datesamplecollected_f datesamplecollected_b datesamplerun_a datesamplecollected_{
					capture gen `var'1 = date(`var', "mdy" ,2050)
					capture  format %td `var'1 
					capture drop `var'
					capture rename `var'1 `var'
					capture recast int `var'
				}

					ds, has(type string) 
							foreach v of varlist `r(varlist)' { 
							replace `v' = lower(`v') 
							} 


foreach var in stanforddenvigg_b denvigg_a chikvigg_a denvigg_a stanforddenvigg_b chikvigg_a {
	capture tostring `var', replace force
}

capture rename stanfordchikigg_a   stanfordchikvigg_a
capture rename stanfordchikviggresult_a stanfordchikvigg_a
capture rename stanfordchikviggresult_b stanfordchikvigg_b
capture rename stforddenvigg_a stanforddenvigg_a
capture rename stfrddenvigg_b stanforddenvigg_b
capture rename igg_kenya_denv* denvigg_* 
capture rename chikviggresult_a  chikvigg_a 
capture rename igg_kenya_chikv* chikvigg_* 


 capture rename stanforddenvreading_* stanforddenvigg_* 

 foreach visit in a b c d e f g h i{
	 capture egen chikvigg_od`visit' = concat(chikvigg_`visit' chikviggod_`visit'  )
	 capture drop chikvigg_`visit' chikviggod_`visit'
	 capture rename chikvigg_od`visit' chikvigg_`visit'   
 }

 foreach visit in a b c d e f g h i{
	 capture egen stanfordchikvigg_od`visit' = concat(stanfordchikvigg_`visit' stanfordchikvod_`visit')
	 capture drop stanfordchikvigg_`visit' stanfordchikvod_`visit'
	 capture rename stanfordchikvigg_od`visit' stanfordchikvigg_`visit'  
 }

  foreach visit in a b c d e f g h i{
	 capture egen stanforddenvigg_od`visit' = concat(stanforddenvigg_`visit' stanforddenvod_`visit' stanforddenviggod_`visit')
	 capture drop stanforddenvigg_`visit' 
	 capture drop stanforddenvod_`visit' 
	 capture drop stanforddenviggod_`visit'
	 capture renamestanforddenvigg_od`visit' stanforddenvigg_`visit'   
 }
  
 foreach visit in a b c d e f g h i{
	capture egen denvigg_od`visit' = concat(denvigg_`visit' denviggod_`visit')
	 capture drop denvigg_`visit' denviggod_`visit'
	 capture rename denvigg_od`visit' denvigg_`visit'   
 }
 capture rename igg_kenya_chikv* chikvigg_*  
 capture rename igg_kenya_denv* denvigg_* 
 capture rename kenyachikvreading_a chikvigg_a  
 capture rename kenyadenvreading_a denvigg_a 
save `dataset', replace
}

append using "kisumu_hcc.dta"  
append using "kisuma_aic.dta" 
append using "chulaimbo_aic.dta" 
append using "msambweni_aic.dta" 
append using "nganja_hcc.dta"
append using  "chulaimbo_hcc.dta"
append using  "milalani_hcc.dta"
append using    "ukunda_aic.dta" 
save temp, replace
dropmiss, force obs
 
save appended_september20.dta, replace

use appended_september20.dta, clear

				replace studyid_a = followupid_b if studyid_a ==""
				replace studyid_a = followupid_c if studyid_a ==""
				replace studyid_a = followupaliquotid_b if studyid_a ==""
				drop followupaliquotid_*

				replace studyid_a =lower(studyid_a)
				replace studyid_a= subinstr(studyid_a, ".", "",.) 
				replace studyid_a= subinstr(studyid_a, "/", "",.)
				replace studyid_a= subinstr(studyid_a, " ", "",.)
				list if studyid_a==""
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
	
	gen id_childnumber  = ""
	replace id_childnumber  = substr(studyid_a, +4, .)

gen byte notnumeric = real(id_childnumber)==.	/*makes indicator for obs w/o numeric values*/
tab notnumeric	/*==1 where nonnumeric characters*/
list id_childnumber if notnumeric==1	/*will show which have nonnumeric*/

gen suffix = "" 	
local suffix a 
foreach suffix in a b c d e f g h {
	replace suffix = "`suffix'" if strpos(id_childnumber, "`suffix'")
	replace id_childnumber = subinstr(id_childnumber, "`suffix'","", .)
	}
destring id_childnumber, replace 	 
	order id_cohort city id_visit id_childnumber studyid_a
	egen id_wide = concat(city id_cohort id_childnum suffix)
drop suffix
drop if id_visit =="?"

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
	dropmiss, force
	dropmiss, force obs

	list if dup2>1
	drop if dup2>1
	dropmiss, force
	dropmiss, force obs
	
	capture tostring stanforddenviggod_e , replace
	capture tostring chikviggod_e, replace
capture tostring stanforddenviggod_f , replace force
	
reshape long stanforddenvreading_ kenyachikvreading_ kenyadenvreading_  collectiondate_ dateofcollection_ datesamplewascollected_ chikvigg_ denvigg_  stanforddenvigg_  datesamplecollected_ datesamplerun_ studyid_ followupaquotid_ chikviggod_ denviggod_ stanfordchikvod_  stanfordchikvigg_ stanforddenvod_ aliquotid_  chikvpcr_ chikvigm_ denvpcr_ denvigm_ stanforddenviggod_ followupid_ antigenused_ , i(id_wide) j(VISIT) string

foreach var in stanforddenvigg_ stanfordchikvigg_ chikviggod_ chikvigg_ denvigg_ stanforddenvreading_ kenyachikvreading_ kenyadenvreading_{
	gen `var'b=.
	tostring `var', replace force
	replace `var'b =  0 if strpos(`var', "neg")
	replace `var'b =  1 if strpos(`var', "pos")
	destring `var', replace
	drop `var'
	rename `var'b `var'
}

replace  stanforddenvigg_ = stanforddenvreading_ if stanforddenvigg_ ==.
drop stanforddenvreading_ chikviggod_ kenyachikvreading_ kenyadenvreading_
sum   stanforddenvigg_ stanfordchikvigg_ chikvigg_ denvigg_ 
order stanforddenvigg_ stanfordchikvigg_ chikvigg_ denvigg_ 

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
					gen site= "." 
						replace site= "coast" if city =="Msambweni"|city =="Ukunda"|city =="Milani"|city =="Nganja"
						replace site= "west" if city =="Chulaimbo"|city =="Kisumu"
					
					replace city = "" if city =="?"

*clean results

ds, has(type string)
	foreach var of var `r(varlist)'{
		replace `var' =trim(itrim(lower(`var')))
		rename `var', lower
	}	
	
/*		foreach var of varlist stanford* *igm* *igg* { 
			tostring `var', replace 
			replace `var' =trim(itrim(lower(`var')))
			gen `var'_result =""
			replace `var'_result = "neg" if strpos(`var', "neg")
			replace `var'_result = "pos" if strpos(`var', "pos") 
			drop `var'
			rename `var'_result `var'
			tab `var'
		}
		*/
rename visit VISIT 
save pcr, replace
drop *pcr*
dropmiss, force obs
dropmiss, force
isid id_wide VISIT

		ds, has(type string) 
			foreach v of varlist `r(varlist)' { 
				replace `v' = lower(`v') 
			}
		rename VISIT visit		
destring id_childnumber  , replace

replace collectiondate_ = dateofcollection_ if collectiondate_ ==""
drop dateofcollection_ 
rename collectiondate_ datesamplecollected_

*tostring datesamplecollected_, replace
gen datesamplecollected_1 = date(datesamplecollected_, "DMY")
					format %td datesamplecollected_1
					drop datesamplecollected_
					rename datesamplecollected_1 datesamplecollected_
					recast int datesamplecollected_
					


format %td datesamplewascollected_ 
format %td datesamplecollected_

gen sampleyear=year(datesamplecollected_)

save elisas, replace

		gen prevalentchikv = .
		gen prevalentdenv = .
 
		replace prevalentdenv = 1 if  stanforddenvigg_ ==1 & visit =="a"
		replace prevalentchikv = 1 if  stanfordchikvigg_==1 & visit =="a"

		replace id_cohort = "HCC" if id_cohort == "c"|id_cohort == "d"
				replace id_cohort = "AIC" if id_cohort == "f"|id_cohort == "m" 
				capture drop cohort
				
		encode id_cohort, gen(cohort)
				
		bysort cohort  city: sum stanfordchikvigg_ stanforddenvigg_ 


		replace city = "Chulaimbo" if city =="c"
		replace city = "Kisumu" if city =="u"
		replace city = "Ukunda" if city =="k"

		save prevalent, replace

preserve 
	keep if id_cohort =="HCC"
	save prevalent_hcc, replace
restore


*chikv matched prevalence
	use prevalent, clear
		ds, has(type string) 
			foreach v of varlist `r(varlist)' { 
				replace `v' = lower(`v') 
			}

		keep if visit == "a" &  stanfordchikvigg_!=.
		save visit_a_chikv, replace
	use prevalent, clear
		keep if visit == "b" &  stanfordchikvigg_!=.
		save visit_b_chikv, replace
		merge 1:1 id_wide using visit_a_chikv
		rename _merge abvisit
		keep abvisit visit id_wide
		merge 1:1 id_wide visit using prevalent
		keep if abvisit ==3 &  stanfordchikvigg_!=.
		
		keep studyid  id_wide site visit city  stanfordchikvigg_ cohort datesamplecollected_  stanfordchikvigg_  stanforddenvigg_ visit datesamplecol~_ 

		export excel using "prevalent_visitab_chikv", firstrow(variables) replace
	
	*denv matched prevalence
	use prevalent, clear
		keep if visit == "a" &  stanforddenvigg_!=.
		save visit_a_denv, replace
	use prevalent, clear
		keep if visit == "b" & stanforddenvigg_!=.
		save visit_b_denv, replace

		merge 1:1 id_wide using visit_a_denv
		rename _merge abvisit
		keep abvisit id_wide visit
		
		merge 1:1 id_wide visit using prevalent		
		keep if abvisit ==3 & stanforddenvigg_!= .
		keep studyid  id_wide site visit city stanforddenvigg_ cohort  datesamplecollected_   stanfordchikvigg_ visit datesamplecol~_
		capture export excel using "prevalent_visitab_denv", firstrow(variables) replace
		
*denv prevlanece
use prevalent, clear
foreach var in  stanforddenvigg_ stanfordchikvigg_ chikvigg_ denvigg_{
	preserve
		keep if `var'!=. 
		rename `var' `var'july2016
		order `var'july2016
		tab `var'july2016
		save "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\elisas\compare july 16 and marhc 17\prevalent`var'july2016", replace
	restore
}
