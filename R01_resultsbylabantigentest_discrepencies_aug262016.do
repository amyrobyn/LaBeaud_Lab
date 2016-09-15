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
log using "R01_discrepenciesaugust25longitudinal.smcl", text replace 
set scrollbufsize 100000
set more 1

local import "/Users/amykrystosik/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/longitudinal_analysis_sept152016/"
import excel "`import'UPDATED DATABASE 04 May 2016.xls.xlsx", sheet("Ukunda AIC") cellrange(A9:AZ1375) firstrow clear
tempfile aic_ukunda
save aic_ukunda, replace
import excel "`import'UPDATED DATABASE 04 May 2016.xls.xlsx", sheet("Msambweni  AIC") cellrange(A9:BH1388) firstrow clear
tempfile  aic_msambweni
save aic_msambweni, replace
import excel "`import'UPDATED DATABASE 04 May 2016.xls.xlsx", sheet("MILALANI HCC") cellrange(A4:BA555) firstrow clear
tempfile hcc_milalani
save hcc_milalani, replace
import excel "`import'UPDATED DATABASE 04 May 2016.xls.xlsx", sheet("NGANJA HCC") cellrange(A4:BA334) firstrow clear
tempfile hcc_nganja
save hcc_nganja, replace
import excel "`import'UPDATED DATABASE 04 May 2016.xls.xlsx", sheet("Ukunda HCC") cellrange(A4:BJ1193) firstrow clear
tempfile hcc_ukunda
save hcc_ukunda, replace
import excel "`import'Western (Chulaimbo, Kisumu) AIC ELISA. Common sheet..xlsx", sheet("CHULAIMBO HCC") cellrange(A4:ad770) firstrow clear
tempfile hcc_chulaimbo
save hcc_chulaimbo, replace
import excel "`import'Western (Chulaimbo, Kisumu) AIC ELISA. Common sheet..xlsx", sheet("KISUMU AIC") cellrange(A9:AD741) firstrow clear
tempfile aic_kisumu
save aic_kisumu, replace
import excel "`import'Western (Chulaimbo, Kisumu) AIC ELISA. Common sheet..xlsx", sheet("KISUMU HCC") cellrange(A4:Bf829) firstrow clear
tempfile hcc_kisumu
save hcc_kisumu, replace
import excel "`import'Western (Chulaimbo, Kisumu) AIC ELISA. Common sheet..xlsx", sheet("CHULAIMBO AIC") cellrange(A9:AE680) firstrow clear
tempfile aic_chulaimbo
save aic_chulaimbo, replace


foreach dataset in "aic_ukunda" "aic_msambweni" "hcc_milalani" "hcc_nganja" "hcc_ukunda" "aic_kisumu" "hcc_chulaimbo" "hcc_kisumu" "aic_chulaimbo.dta"{
use `dataset', clear
foreach var of varlist _all{
		rename `var', lower
}
	ds date*, not
	foreach var of var `r(varlist)'{
		tostring `var', replace force
		replace `var'=lower(`var')
		rename `var', lower
		}	
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
		tostring `var', replace force
		replace `var'=lower(`var')
		rename `var', lower
		}	

	save `dataset', replace
}

**append the different site and cohort excel sheets. 
use "hcc_kisumu", clear
append using "aic_ukunda" "aic_msambweni" "hcc_milalani" "hcc_nganja" "hcc_ukunda" "aic_kisumu" "hcc_chulaimbo"  "aic_chulaimbo.dta", generate(append) force
			
			
	ds my*, not
	foreach var of var `r(varlist)'{
		tostring `var', replace force
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
	rename id1 id_city  
	rename id2 id_cohort  
	rename id3 id_visit 
	tab id_visit 
	gen id_childnumber = ""
	replace id_childnumber = substr(studyid_a, +4, .)
	order id_cohort id_city id_visit id_childnumber studyid_a
	egen id_wide = concat(id_city id_cohort id_childnum)

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
		tostring `var', replace force
		replace `var'=lower(`var')
		rename `var', lower
	}	


	
capture drop _merge
tempfile elisas
save elisas, replace

************************************add RDT data**********************************

import excel "`import'DENGUE RDT RESULTS Aug 30th august 2016.xls", sheet("Sheet3") firstrow clear
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
	gen id_city  = id1 
	gen id_cohort = id2 
	gen visit = id3
	tab visit
	gen id_childnumber = ""
	replace id_childnumber = substr(STUDY_ID, +4, .)
	order id_cohort id_city STUDY_ID id_childnumber 
	egen id_wide = concat(id_city id_cohort id_childnum)

	foreach var of varlist _all{
		rename `var', lower
}
	ds *t*, not
	foreach var of var `r(varlist)'{
		tostring `var', replace force
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
		tostring `var', replace force
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
import excel "`import'LaBeaud RESULTS - july 2016.xls", sheet("2016 PRNT-Msambweni Results") cellrange(A2:E154) firstrow clear
tempfile PRNT_Msambweni 
save PRNT_Msambweni, replace
import excel "`import'LaBeaud RESULTS - july 2016.xls", sheet("2016 PRNT-Ukunda Results") cellrange(A2:F80) firstrow clear
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
			gen id_city  = id1 
			gen id_cohort = id2 
			gen visit = id3
			tab visit
			gen id_childnumber = ""
			replace id_childnumber = substr(ALIQUOTELISAID, +4, .)
			destring id_childnumber, replace
			gen str4 id_childnumber4 = string(id_childnumber,"%04.0f")
			
			order id_cohort id_city ALIQUOTELISAID id_childnumber4 
			egen id_wide = concat(id_city id_cohort id_childnumber4)
			
		*recode prnt values as pos(20+)/ neg
	foreach var of varlist _all{
		rename `var', lower
}
	foreach var of var _all{
		tostring `var', replace force
		replace `var'=lower(`var')
		rename `var', lower
		}	

	foreach var of var _all{
		tostring `var', replace force
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
		tostring `var', replace force
		replace `var'=lower(`var')
		replace `var' =trim(itrim(lower(`var')))
		rename `var', lower
	}	


encode id_wide, gen(id)
sort visit
drop if visit =="a2"
encode visit, gen(visit_s)
replace id_city ="c" if id_city =="r" 
encode id_city, gen(city)
xtset id visit_s	
save longitudinal.dta, replace

	   					replace id_city  = "Chulaimbo" if id_city == "c"
						replace id_city  = "Msambweni" if id_city == "m"
						replace id_city  = "Kisumu" if id_city == "k"
						replace id_city  = "Ukunda" if id_city == "u"
						replace id_city  = "Milani" if id_city == "l"
						replace id_city  = "Nganja" if id_city == "g"
					gen westcoast= "." 
						replace westcoast = "Coast" if id_city =="Msambweni"|id_city =="Ukunda"|id_city =="Milani"|id_city =="Nganja"
						replace westcoast = "West" if id_city =="Chulaimbo"|id_city =="Kisumu"
					encode westcoast, gen(site)			
					egen cohortcityantigen = concat(id_cohort id_city antigenused)

						
	*	 stanfordchikvod_ stanfordchikvigg_ stanforddenvod_ stanforddenvigg_ stanforddenviggod_ stanfordchikvigg_encode stanforddenvigg_encode
foreach var in dengueigm_sammy nsi wnv_prnt onnv_prnt chikv_prnt stanfordchikvigg_  denv_prnt stanforddenvigg_ denvigg_ denviggod_ denvpcr_ denvigm_ chikvigg_ chikviggod_ chikvpcr_ chikvigm_ stanfordchikvod_ stanfordchikvigg_ stanforddenvod_ stanforddenvigg_ stanforddenviggod_ {  
	replace `var' =trim(itrim(lower(`var')))
	gen `var'_result =""
	replace `var'_result = "neg" if strpos(`var', "neg")
	replace `var'_result = "pos" if strpos(`var', "pos") 
	drop `var'
	rename `var'_result `var'
	tab `var'
}


/*levelsof cohortcityantigen, local(levels) 
foreach l of local levels { 
	foreach var of varlist *chikv* *denv* chikv* denv*{ 
		display "`l'"
		display "************************************************************stratachik**********************************************"
		tab `var'  stanfordchikvigg_ if strpos(`var', "neg")|strpos(`var', "pos") & cohortcityantigen== "`l'", m 
		display "************************************************************stratadenv**********************************************"
		tab `var' stanforddenvigg_ if strpos(`var', "neg")|strpos(`var', "pos") & cohortcityantigen== "`l'", m 
		display "************************************************************sitechik**********************************************"
		}
		}

levelsof westcoast, local(levels) 
		foreach l of local levels { 
		display "`l'"
		foreach var of varlist *chikv* *denv* chikv* denv*{ 
		tab `var'  stanfordchikvigg_ if strpos(`var', "neg")|strpos(`var', "pos") & cohortcityantigen== "`l'", m 
		display "************************************************************site**********************************************"
		tab `var'  stanforddenvigg_ if strpos(`var', "neg")|strpos(`var', "pos") & cohortcityantigen== "`l'", m
	}
		}*/


*simple prevalence/incidence by visit
foreach var of varlist *chikv* *denv*{
	bysort visit_s: tab `var'
}

*lagg igg by one visit
destring id visit_s, replace
xtset id visit_s
sort id visit_s

*+ #kids by number of visits
	bysort id_wide: egen numvisits = count(visit_s)
	tab numvisits 


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

replace id_city =lower(id_city)
drop city 
rename id_city city
merge m:1 year month day city using merged_enviro.dta
drop _merge
save lab_enviro, replace
merge m:m id_wide using all_interviews.dta, force
drop _merge
save lab_enviro_interviews, replace

	foreach var in stanforddenvigg_  stanfordchikvigg_ chikvigg_ denvigg_ {
		tab `var', gen(`var'encode)
		gen l1_`var'=  `var'[_n-1] 
		tab l1_`var', gen(l1_`var'encode)
		tab numvisits  `var'
		bysort visit_s: tab l1_`var'encode2 chikvpcr_
		bysort visit_s: tab l1_`var'encode2 fevertemp
		bysort visit_s: tab l1_`var'encode2 denvpcr_
		bysort visit_s: tab l1_`var'encode2 denvigm_ 
		bysort visit_s: tab l1_`var'encode2 chikvigm_
		bysort visit_s: tab l1_`var'encode2 dengueigm_sammy
		
}
	
foreach var in dengueigm_sammy nsi chikv_prnt denv_prnt denvpcr_ chikvpcr{
			tab `var', gen(`var'encode)
}

save temp, replace
preserve
keep if site==1
save site1, replace
restore
preserve
keep if site ==2
save site2, replace
restore	

foreach dataset in  site2 site1{
display "**********************`dataset'*******************"
use `dataset', clear

  capture gen igmns1pos=.
 replace igmns1 = 1 if dengueigm_sammyencode2 == 1 & nsiencode1 == 1
  replace igmns1 = 0 if dengueigm_sammyencode2 == 0 & nsiencode1 == 0
/*
diagt l1_stanforddenvigg_encode2 igmns1
diagt chikv_prntencode2 l1_stanfordchikvigg_encode2
diagt stanfordchikvigg_encode2 chikvigg_encode2
diagt chikvpcrencode1  l1_stanfordchikvigg_encode2
 
diagt denv_prntencode2 l1_stanforddenvigg_encode2 
diagt stanforddenvigg_encode2 denvigg_encode2  
diagt denvpcr_encode2  l1_stanforddenvigg_encode2
diagt dengueigm_sammyencode2 nsiencode1

diagt l1_stanforddenvigg_encode2 fevertemp
diagt l1_stanfordchikvigg_encode2 fevertemp

diagt denvpcr_encode2 fevertemp
diagt denv_prntencode2 fevertemp

diagt chikv_prntencode2 fevertemp
diagt chikvpcr_encode2 fevertemp*/

}




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
			expand 2 if visit_s == 1, gen(x)
			gsort id visit_s -x
			replace visit_s= visit_s- 1 if x == 1

			foreach var of varlist *denv* {
			tostring `var', replace force
				replace `var'= "." if x == 1
			}

			foreach var of varlist *chikv* {
			tostring `var', replace force
				replace `var'= "." if x == 1
			}

			
gen prevalent = .
destring prevalent  stanfordchikvigg_encode2 stanforddenvigg_encode2 visit_s, replace
replace prevalent = 1 if  stanfordchikvigg_encode2==1 & visit_s ==1
replace prevalent = 1 if  stanforddenvigg_encode2==1 & visit_s ==1

tempfile prevalent
save prevalent, replace
preserve
keep if id_cohort =="c"
tempfile prevalentC
save prevalentC, replace
restore
preserve
keep if id_cohort =="f"
tempfile prevalentF
save prevalentF, replace
restore
preserve
drop if prevalent == 1 
tempfile incident
save incident, replace
keep if id_cohort =="c"
tempfile incidentC
save incidentC, replace
restore
preserve
keep if id_cohort =="f"
tempfile incidentF
save incidentF, replace
restore


************************************************survival and longitudinal analysis********************************************
foreach dataset in "prevalent" "incident"{
use `dataset', clear
		destring id visit_s l1_denvigg_encode2 l1_chikvigg_encode2 l1_stanfordchikvigg_encode2 l1_stanforddenvigg_encode2 site city denvigg_encode2 chikvigg_encode2 stanfordchikvigg_encode2 stanforddenvigg_encode2 , replace
		*capture drop if id_cohort=="d"
		replace id_cohort = "HCC" if id_cohort == "c"
		replace id_cohort = "AIC" if id_cohort == "f"
		encode id_cohort, gen(cohort)
		replace cohort = 1 if cohort ==3|cohort ==4
		label variable cohort "Cohort"
		label define Cohort 1 "AIC" 2 "HCC"
		label variable city "City"
		label define City 1 "Chulaimbo" 2 "Kisumu" 3 "Milani" 5 "Nganja" 6 "Ukunda"
save `dataset', replace
}

/*
foreach dataset in "incident" "prevalent"{
	use `dataset', clear
	foreach failvar of varlist chikvigg_encode2 denvigg_encode2 stanfordchikvigg_encode2 stanforddenvigg_encode2 l1_chikvigg_encode2 l1_denvigg_encode2 l1_stanfordchikvigg_encode2 l1_stanforddenvigg_encode2 {
										**********survival***************				
			preserve 
						keep if cohort ==2
						destring begindate, replace
						drop if begindate ==.
						format begindate %td
						stset mydatesamplecollected_, id(id) failure(`failvar') time0(begindate) enter(begindate)
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

						
						stset visit_s, id(id) failure(`failvar')
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
						
						
			restore 

							destring `failvar', replace 
								preserve
							
									keep if date ==.
									keep date id
									outsheet using no_dates`var', comma replace
								restore
								
							preserve		
							drop if `failvar' == .
							collapse (mean) `failvar' (count) n=`failvar' (sd) sd`failvar'=`failvar', by(cohort visit_s)
							egen axis = axis(visit_s)
							generate hi`failvar'= `failvar' + invttail(n-1,0.025)*(sd`failvar'/ sqrt(n))
							generate lo`failvar'= `failvar'- invttail(n-1,0.025)*(sd`failvar'/ sqrt(n))
						graph twoway ///
						   || (bar `failvar' axis, sort )(rcap hi`failvar' lo`failvar' axis) ///
						   || scatter `failvar' axis, ms(i) mlab(n) mlabpos(2) mlabgap(2) mlabangle(45) mlabcolor(black) mlabsize(4) ///
						   || , by(cohort) ylabel(, format(%5.3f)) ymtick(#4,  tlength(scheme tick)) legend(label(1 "`failvar'") label(2 "95% CI")) xlabel(0 (1) 9)  
							graph export "`dataset'`failvar'visit_scohort1.tif", width(4000) replace 

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
			*/
save ro1.dta, replace
