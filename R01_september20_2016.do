/**************************************************************
 *amy krystosik                  							  *
 *R01 results and discrepencies by strata (lab, antigen, test)*
 *lebeaud lab               				        		  *
 *last updated September 15, 2016  							  *
 **************************************************************/
 /*to do
+++ survival for hcc only
	lag it by one visit (if they have positive eliza at b, that means they were infected at a).
++++ prevalence/incidence only for aic
	lag it by one visit (if they have positive eliza at b, that means they were infected at a).
++++ #kids by number of visits
	bysort subject: gen numvisits = count (visits)
	tab numvisits
666+ aic fever/igg pcr/igg igm/igg (ab bc cd de)
	do the same thing that we did with pcr igm


+++ -longitudinal nature of data- survival analysis- done by visit. do it by date
+rain data- add the data from dan
+ -sensisitivty by site (west vs coast)- done. put in tables and add the fever/igg lagged and igm/igg lagged
+ -prnt n = 200. check the sensitivity analysis
+ -rdt ns1+/+igm =+. compare that to stfd igg incidence.- done. add to tables
+ -pcr + copmared to igg at next visit (ab/bc/cd)- done add to tables. 



updates after lab meeting sept 15: 
Get incidence and prevalence tables by cohort by site by visit using stanford only data to desiree by october 1
 
 */
 
capture log close 
log using "R01_september20.smcl", text replace 
set scrollbufsize 100000
set more 1
local import "/Users/amykrystosik/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/longitudinal_analysis_sept152016/"
cd "/Users/amykrystosik/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/CSVs September 20/output"
insheet using "/Users/amykrystosik/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/CSVs September 20/chulaimbo_aic.csv", comma clear names
capture drop *od* followupaliquotid_*
save "chulaimbo_aic", replace
insheet using "/Users/amykrystosik/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/CSVs September 20/chulaimbo_hcc.csv", comma clear names
capture drop *od* followupaliquotid_*
save "chulaimbo_hcc", replace
insheet using "/Users/amykrystosik/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/CSVs September 20/kisuma_aic.csv", comma clear names
capture drop *od* followupaliquotid_*
save "kisuma_aic", replace
insheet using "/Users/amykrystosik/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/CSVs September 20/kisumu_hcc.csv", comma clear names
capture drop *od* followupaliquotid_*
save "kisumu_hcc", replace
insheet using "/Users/amykrystosik/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/CSVs September 20/milalani_hcc.csv", comma clear names
capture drop *od* followupaliquotid_*
save "milalani_hcc", replace
insheet using "/Users/amykrystosik/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/CSVs September 20/msambweni_aic.csv", comma clear names
capture drop *od* followupaliquotid_*
save "msambweni_aic", replace
insheet using "/Users/amykrystosik/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/CSVs September 20/nganja_hcc.csv", comma clear names
capture drop *od* followupaliquotid_*
save "nganja_hcc", replace
insheet using "/Users/amykrystosik/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/CSVs September 20/ukunda_aic.csv", comma clear names
capture drop *od* followupaliquotid_*
save "ukunda_aic", replace
insheet using "/Users/amykrystosik/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/CSVs September 20/ukunda_hcc.csv", comma clear names
capture drop *od* followupaliquotid_*
save "ukunda_hcc", replace
clear

foreach dataset in "chulaimbo_aic.dta" "kisumu_hcc.dta"  "chulaimbo_hcc.dta" "kisuma_aic.dta" "milalani_hcc.dta" "msambweni_aic.dta" "nganja_hcc.dta" "ukunda_aic.dta" "ukunda_hcc.dta"{
use `dataset', clear
capture drop villhouse_a
capture destring personid_a, replace
save `dataset', replace
}
append using "chulaimbo_aic.dta" "kisumu_hcc.dta"  "chulaimbo_hcc.dta" "kisuma_aic.dta" "milalani_hcc.dta" "msambweni_aic.dta" "nganja_hcc.dta" "ukunda_aic.dta" "ukunda_hcc.dta"
drop if studyid_a =="example"
drop if studyid_a =="EXAMPLE"
drop if studyid_a =="Example"
save appended_september20.dta, replace

	drop if studyid_a==""|studyid_a=="???"

	
foreach var of varlist date*{
		capture confirm string var `var'
			if _rc==0 {
						gen double my`var'= date(`var',"DMY")
						format my`var' %td
						drop `var'
						}
			else {
						gen double my`var'= `var'
						format my`var' %td
						drop `var'
				}
							}
	ds my*, not
	foreach var of var `r(varlist)'{
		tostring `var', replace 
		replace `var'=lower(`var')
		rename `var', lower
		}	


		
			
	ds my*, not
	foreach var of var `r(varlist)'{
		tostring `var', replace
		replace `var'=lower(`var')
		rename `var', lower
	}	

	
			replace studyid_a= subinstr(studyid_a, ".", "",.) 
			replace studyid_a= subinstr(studyid_a, "/", "",.)
			replace studyid_a= subinstr(studyid_a, " ", "",.)
			drop if studyid_a==""
		

	bysort  studyid_a: gen dup_merged = _n 
	tab dup_merged
	list studyid_a if dup_merged>1
	tempfile merged
	save merged, replace
	*keep those that i dropped for duplicate and show to elysse
	keep if dup_merged >1	
	export excel using "`save'dup", firstrow(variables) replace

	use merged.dta, clear
	drop if dup_merged >1
	
tempfile merged
save merged, replace


*take visit out of id
						forval i = 1/3 { 
							gen id`i' = substr(studyid_a, `i', 1) 
						}
*gen id_wid without visit						 
	rename id1 city  
	rename id2 id_cohort  
	rename id3 id_visit 
	tab id_visit 
	gen id_childnumber = ""
	replace id_childnumber = substr(studyid_a, +4, .)
	order id_cohort city id_visit id_childnumber studyid_a
	egen id_wide = concat(city id_cohort id_childnum)

ds, has(type string) 
foreach v of varlist `r(varlist)' { 
	replace `v' = lower(`v') 
} 
tempfile wide
save wide, replace

	bysort id_wide: gen dup2 = _n 
	save wide, replace
		keep if dup2 >1
		export excel using "dup2", firstrow(variables) replace
use wide.dta, clear
	drop if dup2 >1
	gen begindate = mydatesamplecollected_a if mydatesamplecollected_a !=.
	reshape long mydatesamplecollected_ mydatesamplerun_ studyid_ followupaliquotid_ chikvigg_ chikviggod_ denvigg_ denviggod_ stanfordchikvod_  stanfordchikvigg_ stanforddenvod_ stanforddenvigg_ aliquotid_  chikvpcr_ chikvigm_ denvpcr_ denvigm_ stanforddenviggod_ followupid_ antigenused_ , i(id_wide) j(visit) string
	format mydatesamplecollected_ %td
	format begindate %td
	tempfile long
	save long, replace
	
	use long.dta, clear
	drop if id_wide==""

	ds my*, not
	foreach var of var `r(varlist)'{
		tostring `var', replace 
		replace `var'=lower(`var')
		rename `var', lower
	}	


	
capture drop _merge
save elisas, replace

************************************add RDT data**********************************

import excel "/Users/amykrystosik/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/longitudinal_analysis_sept152016/DENGUE RDT RESULTS Aug 30th august 2016.xls", sheet("Sheet3") firstrow clear
rename STUDYNUMBER STUDY_ID
rename IgM dengueigm_sammy
rename IgG dengue_igg_sammy
tempfile ns1
save ns1, replace
*take visit out of id

						forval i = 1/3 { 
							gen id`i' = substr(STUDY_ID, `i', 1) 
						}
*gen id_wid without visit						 
	gen city  = id1 
	gen id_cohort = id2 
	gen visit = id3
	tab visit
	gen id_childnumber = ""
	replace id_childnumber = substr(STUDY_ID, +4, .)
	order id_cohort city STUDY_ID id_childnumber 
	egen id_wide = concat(city id_cohort id_childnum)

	foreach var of varlist _all{
		rename `var', lower
}
	ds *t*, not
	foreach var of var `r(varlist)'{
		tostring `var', replace 
		replace `var'=lower(`var')
		rename `var', lower
		}	
	foreach var of varlist date*{
		*capture destring `var', replace
		capture gen double my`var'= date(`var',"DMY")
		capture format my`var' %td
		drop `var'
}
	ds my*, not
	foreach var of var `r(varlist)'{
		tostring `var', replace 
		replace `var'=lower(`var')
		rename `var', lower
	}	
	ds my*, not
	foreach var of var `r(varlist)'{
	replace `var' =trim(itrim(lower(`var')))
	}
save ns1, replace
merge 1:1 id_wide visit using elisas.dta
drop _merge
save elisas_PCR_RDT, replace

************************************add PRNT data**********************************
import excel "/Users/amykrystosik/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/longitudinal_analysis_sept152016/LaBeaud RESULTS - july 2016.xls", sheet("2016 PRNT-Msambweni Results") cellrange(A2:E154) firstrow clear
tempfile PRNT_Msambweni 
save PRNT_Msambweni, replace
import excel "/Users/amykrystosik/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/longitudinal_analysis_sept152016/LaBeaud RESULTS - july 2016.xls", sheet("2016 PRNT-Ukunda Results") cellrange(A2:F80) firstrow clear
tempfile PRNT_Ukunda
save PRNT_Ukunda, replace

foreach dataset in "PRNT_Msambweni" "PRNT_Ukunda"{
use "`dataset'", clear
		replace ALIQUOTELISAID= subinstr(ALIQUOTELISAID, " ", "",.)

		*take visit out of id

								forval i = 1/3 { 
									gen id`i' = substr(ALIQUOTELISAID, `i', 1) 
								}
		*gen id_wid without visit						 
			gen city  = id1 
			gen id_cohort = id2 
			gen visit = id3
			tab visit
			gen id_childnumber = ""
			replace id_childnumber = substr(ALIQUOTELISAID, +4, .)
			destring id_childnumber, replace
			gen str4 id_childnumber4 = string(id_childnumber,"%04.0f")
			
			order id_cohort city ALIQUOTELISAID id_childnumber4 
			egen id_wide = concat(city id_cohort id_childnumber4)
			
		*recode prnt values as pos(20+)/ neg
	foreach var of varlist _all{
		rename `var', lower
}
	foreach var of var _all{
		tostring `var', replace 
		replace `var'=lower(`var')
		rename `var', lower
		}	

	foreach var of var _all{
		tostring `var', replace 
		replace `var'=lower(`var')
		rename `var', lower
	}	
	
	foreach var of var _all{
			replace `var' =trim(itrim(lower(`var')))
	}

		 foreach v of varlist  denv2 wnv chikv onnv{
			  replace `v' = "pos" if `v' == "40"|`v' == ">80"|`v' == "20"
			  replace `v' = "neg" if `v' == "10"|`v' == "<10"
			  replace `v' = "" if `v' == "no sample"|`v' == "no sample received at cdc"|`v' == ""
		   tab `v', m
		   }   
		   
		   rename  denv2 denv_prnt
		   rename  wnv wnv_prnt 
		   rename  chikv chikv_prnt 
		   rename  onnv onnv_prnt
	save "`dataset'", replace
}
use "PRNT_Msambweni", clear
*merge with elisas.dta
merge 1:1 id_wide visit using "elisas_PCR_RDT.dta"
drop _merge
tempfile elisas_PCR_RDT_PRNT1
save elisas_PCR_RDT_PRNT1, replace
use PRNT_Ukunda, clear
*merge with elisas.dta
merge 1:1 id_wide visit using elisas_PCR_RDT_PRNT1.dta
drop _merge
tempfile elisas_PCR_RDT_PRNT2
save elisas_PCR_RDT_PRNT2, replace

*******declare data as panel data***********
	ds my*, not
	foreach var of var `r(varlist)'{
		tostring `var', replace 
		replace `var'=lower(`var')
		replace `var' =trim(itrim(lower(`var')))
		rename `var', lower
	}	


encode id_wide, gen(id)
sort visit
drop if visit =="a2"
encode visit, gen(visit_s)
replace city ="c" if city =="r" 
xtset id visit_s	
save longitudinal.dta, replace

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
					egen cohortcityantigen = concat(id_cohort city antigenused)

						
 drop stanforddenviggod_ stanfordchikvod_ stanforddenvod_
foreach var of varlist stanford*{ 
	replace `var' =trim(itrim(lower(`var')))
	gen `var'_result =""
	replace `var'_result = "neg" if strpos(`var', "neg")
	replace `var'_result = "pos" if strpos(`var', "pos") 
	drop `var'
	rename `var'_result `var'
	tab `var'
}


*simple prevalence/incidence by visit
save temp, replace


*lagg igg by one visit
destring id visit_s, replace
xtset id visit_s
sort id visit_s


capture drop mydate_year mydate_month mydate_day
*add year and month to merge with rain and vector data
foreach var of varlist my*{
	gen `var'_year = year(`var')
	gen `var'_month = month(`var')
	gen `var'_day = day(`var')

}

rename  mydatesamplecollected__year year
rename mydatesamplecollected__month month
rename mydatesamplecollected__day day

*merge m:1 year month day city using merged_enviro.dta
capture drop _merge
*save lab_enviro, replace

drop visit
rename visit_s visit
capture drop dup_merged
merge m:m id_wide using all_interviews.dta
drop _merge
*save lab_enviro_interviews, replace
	
foreach var in dengueigm_sammy nsi chikv_prnt denv_prnt denvpcr_ chikvpcr{
			tab `var', gen(`var'encode)
}

 capture gen igmns1pos=.
 replace igmns1 = 1 if dengueigm_sammyencode2 == 1 & nsiencode1 == 1
  replace igmns1 = 0 if dengueigm_sammyencode2 == 0 & nsiencode1 == 0
gen season = . 
replace season =1 if month >=1 & month  <=3 & season ==.
*label define 1 "hot no rain from mid december"
replace season =2 if month >=4 & month  <=6 & season ==.
*label define 2 "long rains"
replace season =3 if month >=7 & month  <=10 & season ==.
*label define 3 "less rain cool season"
replace season =4 if month >=11 & month  <=12 & season ==.
*label define 4 "short rains"

*add time 0 so we can estimate the prevelance in the surival curve too. set dengue and chik =. 
drop x
			expand 2 if visit == 1, gen(x)
			gsort id visit -x
			replace visit= visit- 1 if x == 1

			foreach var of varlist *denv* {
			tostring `var', replace 
				replace `var'= "." if x == 1
			}

			foreach var of varlist *chikv* {
			tostring `var', replace 
				replace `var'= "." if x == 1
				}
			

			
gen prevalent = .

tab stanfordchikvigg_, gen(stanfordchikviggencode)
rename stanfordchikviggencode3 CHIKVPOS

tab stanforddenvigg_, gen(stanforddenviggencode)
rename stanforddenviggencode3 DENVPOS
drop stanford* 

replace prevalent = 1 if  DENVPOS ==1 & visit ==1
replace prevalent = 1 if  CHIKV ==1 & visit ==1

save prevalent, replace
preserve
drop if prevalent == 1 
save incident, replace
restore


************************************************survival and longitudinal analysis********************************************
foreach dataset in "prevalent" "incident"{
use `dataset', clear
		replace id_cohort = "HCC" if id_cohort == "c"
		replace id_cohort = "AIC" if id_cohort == "f"
		encode id_cohort, gen(cohort)
		*replace cohort = 1 if cohort ==3|cohort ==4
		label variable cohort "Cohort"
		*label define Cohort 1 "AIC" 2 "HCC"
		label variable city "City"
		label define City 1 "Chulaimbo" 2 "Kisumu" 3 "Milani" 5 "Nganja" 6 "Ukunda"
save `dataset', replace
}

drop if visit ==0
foreach v of varlist CHIKVPOS DENVPOS{
	tabout visit city `v' using `v'_tab.xls, replace
}

foreach dataset in "incident" "prevalent"{
	use `dataset', clear
	foreach failvar of varlist CHIKVPOS DENVPOS {
										**********survival***************				
			/*preserve 
						 keep if cohort ==2
						stset visit, id(id) failure(`failvar')
						stdescribe
						stsum
						sts graph, cumhaz risktable censored(single) title(`failvar') ylabel(minmax, format(%5.3f)) ymtick(##5, tlength(scheme tick)) xlabel(, format(%td)) xlabel(, angle(45)) xmtick(##5, tlength(scheme tick)) 
								graph export "cumhaz`dataset'`failvar'date.tif", width(4000) replace
						sts graph, cumhaz risktable censored(single) title(`failvar') by(city) ylabel(minmax, format(%5.3f)) ymtick(##5, tlength(scheme tick)) xlabel(, format(%td)) xlabel(, angle(45)) xmtick(##5, tlength(scheme tick)) 
								graph export "cumhaz`dataset'`failvar'citydate.tif", width(4000) replace
						sts graph, cumhaz risktable censored(single) title(`failvar') by(site) ylabel(minmax, format(%5.3f)) ymtick(##5, tlength(scheme tick)) xlabel(, format(%td)) xlabel(, angle(45)) xmtick(##5, tlength(scheme tick)) 
								graph export "cumhaz`dataset'`failvar'sitedate.tif", width(4000) replace
						
						sts graph, survival risktable censored(single) title(`failvar') ylabel(minmax, format(%5.3f)) ymtick(##5, tlength(scheme tick)) xlabel(, format(%td)) xlabel(, angle(45)) xmtick(##5, tlength(scheme tick)) 
						graph export "survival`dataset'`failvar'date.tif", width(4000) replace
						sts list, survival
						sts graph, risktable censored(single) title(`failvar') by(site) ylabel(minmax, format(%5.3f)) ymtick(##5, tlength(scheme tick)) xlabel(, format(%td)) xlabel(, angle(45)) xmtick(##5, tlength(scheme tick)) 
						graph export "survivalsite`dataset'`failvar'date.tif", width(4000) replace
						sts graph, risktable censored(single) title(`failvar') by(city) ylabel(minmax, format(%5.3f)) ymtick(##5, tlength(scheme tick)) xlabel(, format(%td)) xlabel(, angle(45)) xmtick(##5, tlength(scheme tick)) 
						graph export "survivalcity`dataset'`failvar'date.tif", width(4000) replace

						
						stset visit, id(id) failure(`failvar')
						stdescribe
						stsum
						sts graph, cumhaz risktable tmax(11) censored(single) title(`failvar') ylabel(minmax, format(%5.3f))  ymtick(##5,  tlength(scheme tick))
						graph export "cumhaz`dataset'`failvar'visit.tif", width(4000) replace
						sts graph, survival risktable tmax(11) censored(single) title(`failvar')  ylabel(minmax, format(%5.3f))ymtick(##5,  tlength(scheme tick))
						graph export "survival`dataset'`failvar'visit.tif", width(4000) replace
						sts list, survival
						sts graph, risktable tmax(11)  censored(single) title(`failvar') by(site) ylabel(minmax, format(%5.3f))ymtick(##5,  tlength(scheme tick))
						graph export "survivalsite`dataset'`failvar'visit.tif", width(4000) replace
						sts graph, risktable tmax(11) censored(single) title(`failvar') by(city) ylabel(minmax, format(%5.3f))ymtick(##5,  tlength(scheme tick))
						graph export "survivalcity`dataset'`failvar'visit.tif", width(4000) replace
						
						
			restore */

							destring `failvar', replace 
								preserve
							
									capture keep if date ==.
									capture keep date id
									outsheet using no_dates`var', comma replace
								restore
								
							preserve		
							drop if `failvar' == .
							collapse (mean) `failvar' (count) n=`failvar' (sd) sd`failvar'=`failvar', by(cohort visit)
							egen axis = axis(visit)
							generate hi`failvar'= `failvar' + invttail(n-1,0.025)*(sd`failvar'/ sqrt(n))
							generate lo`failvar'= `failvar'- invttail(n-1,0.025)*(sd`failvar'/ sqrt(n))
						graph twoway ///
						   || (bar `failvar' axis, sort )(rcap hi`failvar' lo`failvar' axis) ///
						   || scatter `failvar' axis, ms(i) mlab(n) mlabpos(2) mlabgap(2) mlabangle(45) mlabcolor(black) mlabsize(4) ///
						   || , by(cohort) ylabel(, format(%5.3f)) ymtick(#4,  tlength(scheme tick)) legend(label(1 "`failvar'") label(2 "95% CI")) xlabel(0 (1) 9)  
							graph export "`dataset'`failvar'visitcohort1.tif", width(4000) replace 

				restore				
				preserve		
							*drop if `failvar' == .
							collapse (mean) `failvar' (count) n=`failvar' (sd) sd`failvar'=`failvar', by(cohort city)
							egen axis = axis(city)
							generate hi`failvar'= `failvar' + invttail(n-1,0.025)*(sd`failvar'/ sqrt(n))
							generate lo`failvar'= `failvar'- invttail(n-1,0.025)*(sd`failvar'/ sqrt(n))
						graph twoway ///
						   || (bar `failvar' axis, sort )(rcap hi`failvar' lo`failvar' axis) ///
						   || scatter `failvar' axis, ms(i) mlab(n) mlabpos(2) mlabgap(2) mlabangle(45) mlabcolor(black) mlabsize(4) ///
						   || , by(cohort) ylabel(, format(%5.4f)) ymtick(#4,  tlength(scheme tick)) legend(label(1 "`failvar'") label(2 "95% CI")) xlabel(1 "Chulaimbo" 2 "Nganja" 3 "Kisumu" 4 "Milani" 5 "Msambweni" 6 "Ukunda", angle(45)) title(`dataset' by cohort and city)
							graph export "`dataset'`failvar'citycohort.tif", width(4000) replace 

				restore	
			}
			}
			
			
