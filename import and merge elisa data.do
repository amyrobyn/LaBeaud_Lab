local output "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\elisas\march 2017"
local input "C:\Users\amykr\Box Sync\DENV CHIKV project\Lab Data\ELISA Database\ELISA Latest"
cd "`input'"

capture log close 
log using "`output'elisa_import_merge_clean.smcl", text replace 
set scrollbufsize 100000
set more 1

*import csv's
import excel "WEST ELISA Database DL Mar 1 2017.xlsx", sheet("CHULAIMBO AIC") cellrange(A9:CP648) firstrow clear
dropmiss, force obs
dropmiss, force 
rename *, lower
rename stford* stanford*
gen dataset = "chulaimbo_aic" 
save "`output'chulaimbo_aic" , replace

import excel "WEST ELISA Database DL Mar 1 2017.xlsx", sheet("CHULAIMBO HCC") cellrange(A8:BQ644) firstrow clear
dropmiss, force obs
dropmiss, force 
gen dataset = "chulaimbo_hcc"
save "`output'chulaimbo_hcc", replace

import excel "WEST ELISA Database DL Mar 1 2017.xlsx", sheet("KISUMU AIC") cellrange(A9:CF832) firstrow clear
dropmiss, force obs
dropmiss, force 
gen dataset = "kisuma_aic"
save "`output'kisuma_aic", replace

import excel "WEST ELISA Database DL Mar 1 2017.xlsx", sheet("KISUMU HCC") cellrange(A4:BJ829) firstrow clear
dropmiss, force obs
dropmiss, force 
gen dataset = "kisumu_hcc"
save "`output'kisumu_hcc", replace

import excel "COAST ELISA Database DL Mar 1 2017.xls", sheet("MILALANI HCC") cellrange(A8:BL589) firstrow clear
dropmiss, force obs
dropmiss, force 
gen dataset = "milalani_hcc"
save "`output'milalani_hcc", replace

import excel "COAST ELISA Database DL Mar 1 2017.xls", sheet("Msambweni  AIC") cellrange(A9:BG1488) firstrow clear
dropmiss, force obs
dropmiss, force 
egen ChikVIgGOD_db = concat(ChikVIgGOD_d  AK)
drop ChikVIgGOD_d  AK
rename ChikVIgGOD_db ChikVIgGOD_d 
gen dataset = "msambweni_aic"
save "`output'msambweni_aic", replace

import excel "COAST ELISA Database DL Mar 1 2017.xls", sheet("NGANJA HCC") cellrange(A8:BL319) firstrow clear
dropmiss, force obs
dropmiss, force 
gen dataset = "nganja_hcc"
save "`output'nganja_hcc", replace

import excel "COAST ELISA Database DL Mar 1 2017.xls", sheet("Ukunda AIC") cellrange(A9:AZ1519) firstrow clear 
dropmiss, force obs
dropmiss, force 
gen dataset = "ukunda_aic"
save "`output'ukunda_aic", replace

import excel "COAST ELISA Database DL Mar 1 2017.xls", sheet("Ukunda HCC") cellrange(A8:BI1128) firstrow clear
dropmiss, force 
dropmiss, force obs
gen dataset = "ukunda_hcc"
rename *, lower
rename stanfordchikigg_a stanfordchikvigg_a 
save "`output'ukunda_hcc", replace
clear

cd "`output'"
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

			foreach var in chikviggod_a denviggod_b {
			capture drop `var'
			}
				foreach var in datesamplecollected_a datesamplecollected_f datesamplecollected_b datesamplerun_a datesamplecollected_{
					capture gen `var'1 = date(`var', "mdy" ,2050)
					capture  format %td `var'1 
					capture drop `var'
					capture rename `var'1 `var'
					capture recast int `var'
						capture drop denviggod_a 
				}

					ds, has(type string) 
							foreach v of varlist `r(varlist)' { 
							replace `v' = lower(`v') 
							} 

capture rename stanfordchikigg_a   stanfordchikvigg_a
capture rename stanfordchikviggresult_a stanfordchikvigg_a
capture rename stanfordchikviggresult_b stanfordchikvigg_b
capture rename stforddenvigg_a stanforddenvigg_a
capture rename stfrddenvigg_b stanforddenvigg_b
capture rename igg_kenya_denv denvigg_ 
capture rename chikviggresult_a  chikvigg_a 
capture rename igg_kenya_chikv chikvigg_ 


 capture rename stanforddenvreading_* stanforddenvigg_* 
 lookfor chikviggod_ denviggod_
  foreach visit in a b c d e f g h i{
	 capture egen chikvigg_od`visit' = concat(chikvigg_`visit' chikviggod_`visit')
	 capture drop chikvigg_`visit' chikviggod_`visit'
	 capture rename chikvigg_od`visit' chikvigg_`visit'   
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

save temp, replace
	use temp, clear
	preserve
		tostring *, replace force
		gen pos = 0
		gen neg = 0
			ds, has(type string) 
				foreach var of varlist `r(varlist)' { 
					count if strpos(`var', "pos")
						replace pos = pos + r(N)
						sum `var'

					count if strpos(`var', "neg")
						replace neg = neg + r(N)
						sum  `var'
				}
			*36387  neg and 6792  pos
restore

use appended_september20.dta, clear

				replace studyid_a = followupid_b if studyid_a ==""
				replace studyid_a = followupid_c if studyid_a ==""
				replace studyid_a = followupaliquotid_b if studyid_a ==""
				replace studyid_a = followupaliquotid_c if studyid_a ==""
				replace studyid_a = followupaliquotid_d if studyid_a ==""
				replace studyid_a = followupaliquotid_e if studyid_a ==""
				replace studyid_a = followupaliquotid_f if studyid_a ==""
				replace studyid_a = followupaliquotid_g if studyid_a ==""
				replace studyid_a = followupaliquotid_h if studyid_a ==""
				replace studyid_a =  studyid_e if studyid_a ==""
				replace studyid_a = chikvpcr_e  if studyid_a ==""
					
				drop studyid_c 
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
	rename id1 id_city 
	rename id2 id_cohort  
	rename id3 id_visit 
	gen city = id_city  
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
foreach var in chikviggod_* stanfordchikvod_a  stanforddenvigg_f   stanforddenviggod_c antigenused_e  {
tostring `var', replace 
}
tostring chikviggod_* , replace force
	list if dup2>1
	drop if dup2>1
	dropmiss, force
	dropmiss, force obs
	
	capture tostring stanforddenviggod_e , replace
	capture tostring chikviggod_e, replace
capture tostring stanforddenviggod_f , replace force

	

reshape long stanfordchikvigg2_ chikvigg_ denvigg_  stanforddenvigg_  datesamplecollected_ datesamplerun_ studyid_ followupaquotid_ chikviggod_ denviggod_ stanfordchikvod_  stanfordchikvigg_ stanforddenvod_ aliquotid_  chikvpcr_ chikvigm_ denvpcr_ denvigm_ stanforddenviggod_ followupid_ antigenused_ , i(id_wide) j(VISIT) string
encode id_wide, gen(id_wide_int)
encode VISIT, gen(visit_int)
xtset id_wide_int visit_int
by id_wide_int : carryforward id_childnumber id_cohort id_city city, replace

egen stanfordchikvigg_all = concat(stanfordchikvigg2_ stanfordchikvigg_ stanfordchikvod_ )
drop stanfordchikvigg2_  stanfordchikvigg_
rename stanfordchikvigg_all stanfordchikvigg_
order stanfordchikvigg_
outsheet using stanfordchikvigg_discordat.xls if strpos(stanfordchikvigg_, "negpos")| strpos(stanfordchikvigg_, "posneg") , replace

order  chikvigg_ denvigg_ stanforddenvigg_ chikviggod_ denviggod_ stanfordchikvigg_ stanforddenviggod_ 
 
egen chikvigg_all = concat(chikviggod_ chikvigg_ )
drop chikviggod_ chikvigg_ 
rename chikvigg_all chikvigg_ 

egen stanforddenviggall = concat(stanforddenvigg_ stanforddenviggod_ stanforddenvod_ )
drop stanforddenvigg_ stanforddenviggod_ stanforddenvod_ 
rename stanforddenviggall stanforddenvigg_ 

egen denviggall = concat(denvigg_ denviggod_)
drop denvigg_ denviggod_
rename denviggall  denvigg_ 
order denvigg_ 


	foreach var in stanforddenvigg_ stanfordchikvigg_ chikvigg_ denvigg_ {
	gen `var'b=.
	tostring `var', replace force
	replace `var'b =  0 if strpos(`var', "neg")
	replace `var'b =  1 if strpos(`var', "pos")
	destring `var', replace
	drop `var'
	rename `var'b `var'
}
order stanforddenvigg_ stanfordchikvigg_ chikvigg_ denvigg_ 
sum stanforddenvigg_ stanfordchikvigg_ chikvigg_ denvigg_ 
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
	
/*
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

replace antigenused_  = antigenused if antigenused_  =="" 
egen antigenused2  = concat(antigenused antigenused_) if antigenused_  !="" |antigenused_  =="."  & antigenused !="" | antigenused =="."
gen and = " & "
replace antigenused_  = antigenused2  if antigenused2  =="" 
drop antigenused2   antigenused

format %td datesamplecollected_
gen sampleyear=year( datesamplecollected_)


save elisas, replace

		gen prevalentchikv = .
		gen prevalentdenv = .
		

		replace prevalentdenv = 1 if  stanforddenvigg_==1 & visit =="a"
		replace prevalentchikv = 1 if  stanfordchikvigg_==1 & visit =="a"
		gen cohort = id_cohort
		replace cohort= "HCC" if id_cohort == "c"|cohort== "d"
		replace cohort= "AIC" if cohort== "f"|cohort== "m" 
				
		encode cohort, gen(cohort_s)
		drop cohort
		rename cohort_s cohort				
		bysort cohort  city: sum stanforddenvigg_ stanfordchikvigg_ 


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

		keep if visit == "a" & stanfordchikvigg_ !=. 
		save visit_a_chikv, replace
	use prevalent, clear
		keep if visit == "b" & stanfordchikvigg_ !=.
		save visit_b_chikv, replace
		merge 1:1 id_wide using visit_a_chikv
		rename _merge abvisit
		keep abvisit visit id_wide
		merge 1:1 id_wide visit using prevalent
		keep if abvisit ==3 & stanfordchikvigg_ !=.
		
		keep studyid  id_wide site visit id_visit antigenused_ id_city city stanforddenvigg_ stanfordchikvigg_  cohort id_cohort datesamplecollected_ datesamplecol~_ 

		export excel using "prevalent_visitab_chikv", firstrow(variables) replace
	
	*denv matched prevalence
	use prevalent, clear
		keep if visit == "a" & stanforddenvigg_ !=.
		save visit_a_denv, replace
	use prevalent, clear
		keep if visit == "b" & stanforddenvigg_ !=.
		save visit_b_denv, replace

		merge 1:1 id_wide using visit_a_denv
		rename _merge abvisit
		keep abvisit id_wide visit
		
		merge 1:1 id_wide visit using prevalent		
		keep if abvisit ==3 & stanforddenvigg_ !=.
		keep id_visit id_cohort id_city studyid  id_wide site visit antigenused_ city cohort  datesamplecollected_   stanforddenvigg_ stanfordchikvigg_  visit datesamplecol~_
		export excel using "prevalent_visitab_denv", firstrow(variables) replace
		
		*denv prevlanece
use prevalent, clear			
foreach var in stanforddenvigg_ stanfordchikvigg_ chikvigg_ denvigg_ {
	preserve
		keep if `var'!=. 
		rename `var' `var'march2017
		order `var'march2017
		tab `var'march2017
		save "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\elisas\compare july 16 and marhc 17\prevalent`var'march2017", replace
	restore
}		

replace city = "msambweni" if city =="milani"
replace city = "msambweni" if city =="nganja"

save  prevalent, replace

keep id_city id_cohort id_visit studyid id_wide visit city cohort site stanforddenvigg_ stanfordchikvigg_ chikvigg_ denvigg_ 
keep if stanforddenvigg_	!= .|stanfordchikvigg_	!= .|chikvigg_	!= .|denvigg_!= .
encode city, gen(city_int)

by city, sort : ci stanforddenvigg_, binomial 
by city, sort : ci stanfordchikvigg_, binomial 


by cohort, sort : ci stanforddenvigg_, binomial 
by cohort, sort : ci stanfordchikvigg_, binomial 

bysort id_wide: carryforward id_wide, gen(id_wide2)

cd "`input'"
save elisa_merged, replace
outsheet id* studyid id_wide visit stanforddenvigg_ stanfordchikvigg_ chikvigg_ denvigg_  using "elisas_merged.csv", comma names replace
