/**************************************************************
 *amy krystosik                  							  *
 *R01 results and discrepencies by strata (lab, antigen, test)*
 *lebeaud lab               				        		  *
 *last updated august 15, 2016  							  *
 **************************************************************/
 /*to do
+ -longitudinal nature of data- survival analysis, rain data
+ -sensisitivty by site (west vs coast)
+ -prnt n = 200. check the sensitivity analysis
+ -rdt ns1+/+igm =+. compare that to stfd igg incidence.
+ -pcr + copmared to igg at next visit (ab/bc/cd)
 */
 
cd "C:\Users\Amy\Box Sync\Amy Krystosik's Files\R01\longitudinal_analysis_aug252016\output"
*cd "/Users/amykrystosik/Box Sync/Amy Krystosik's Files/R01/longitudinal_analysis_aug252016"
capture log close 
log using "R01_discrepenciesaugust25longitudinal.smcl", text replace 
set scrollbufsize 100000
set more 1

local import "C:\Users\Amy\Box Sync\Amy Krystosik's Files\R01\longitudinal_analysis_aug252016\"
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
import excel "`import'Western (Chulaimbo, Kisumu) AIC ELISA. Common sheet..xlsx", sheet("KISUMU HCC") cellrange(A4:BE831) firstrow clear
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
	reshape long mydatesamplecollected_ mydatesamplerun_ studyid_ followupaliquotid_ chikvigg_ chikviggod_ denvigg_ denviggod_ stanfordchikvod_  stanfordchikvigg_ stanforddenvod_ stanforddenvigg_ aliquotid_  chikvpcr_ chikvigm_ denvpcr_ denvigm_ stanforddenviggod_ followupid_ antigenused_ , i(id_wide) j(visit) string
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
	ds date*, not
	foreach var of var `r(varlist)'{
		tostring `var', replace force
		replace `var'=lower(`var')
		rename `var', lower
		}	

	
	foreach var of varlist date*{
		*capture destring `var', replace
		capture gen double my`var'= date(`var',"DMY")
		capture format my`var' %td
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
	foreach var of varlist date*{
		*capture destring `var', replace
		capture gen double my`var'= date(`var',"DMY")
		capture format my`var' %td
}

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
encode visit, gen(time)
replace id_city ="c" if id_city =="r" 
encode id_city, gen(city)
xtset id time	
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

**put this in tables later
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
		}
*/
*simple prevalence/incidence by visit
foreach var of varlist *chikv* *denv*{
	bysort time: tab `var'
}

*lagg igg by one visit
destring id time, replace
xtset id time
sort id time

	foreach var in dengueigm_sammy  nsi stanforddenvigg_  stanfordchikvigg_ chikv_prnt chikvigg_ chikviggod_ chikvpcr_ chikvigm_ stanfordchikvod_ denv_prnt denvigg_ denviggod_ denvpcr_ denvigm_ stanforddenvod_ stanforddenviggod_ wnv_prnt onnv_prnt{
		tab `var', gen(`var'encode)
	}
	
	
gen l1_iggS_denv=  stanforddenvigg_encode2[_n-1] 
gen l1_iggS_chikv=  stanfordchikvigg_encode2[_n-1] 
	foreach var in  l1_iggS_chikv l1_iggS_denv{
		tab `var', gen(`var'encode)
	}

*destring  denvigm_ chikv_prntencode stanforddenvigg_encode chikvigg_encode chikviggod_encode chikvpcr_encode chikvigm_encode stanfordchikvod_encode stanfordchikvigg_encode denv_prntencode denv_nsi_resultencode  denvigg_encode denviggod_encode denvpcr_encode denvigm_encode stanforddenvod_encode stanforddenvigg_encode stanforddenviggod_encode wnv_prntencode onnv_prntencode, replace

tempfile temp
save temp, replace
preserve
keep if site==1
tempfile site1
save site1, replace
restore
preserve
keep if site ==2
tempfile site2
save site2, replace
restore	

foreach dataset in site1 site2 temp{
display "**********************`dataset'*******************"
use `dataset', clear
destring *, replace force
sum _all dengueigm_sam~2 nsiencode1 chikv_prntencode2  chikvigg_encode2 chikviggod_encode2 chikvpcr_encode1 stanfordchikvigg_encode2 denv_prntencode2 denvigg_encode2 denviggod_encode2 denvpcr_encode2 stanforddenvigg_encode2  wnv_prntencode2 onnv_prntencode2 

diagt chikv_prntencode2 stanfordchikvigg_encode2
diagt stanfordchikvigg_encode2 chikvigg_encode2
diagt chikvpcr_encode1 l1_iggS_chikv
 
diagt denv_prntencode2 stanforddenvigg_encode2 
diagt stanforddenvigg_encode2 denvigg_encode2  
diagt denvpcr_encode2 l1_iggS_denv
diagt dengueigm_sam~2 nsiencode1
}


use temp, clear

egen site_stanfordigg_chik = concat(site stanforddenvigg_encode2)
egen site_stanfordigg_denv= concat(site stanforddenvigg_encode2)
egen city_stanfordigg_chik = concat(city stanfordchikvigg_encode2)
egen city_stanfordigg_denv = concat(city stanforddenvigg_encode2)

*add time 0 so we can estimate the prevelance in the surival curve too. set dengue and chik =. 
			expand 2 if time == 1, gen(x)
			gsort id time -x
			replace time= time- 1 if x == 1

			foreach var of varlist *denv* {
			tostring `var', replace force
				replace `var'= "." if x == 1
			}

			foreach var of varlist *chikv* {
			tostring `var', replace force
				replace `var'= "." if x == 1
			}

			
gen prevalent = .
destring prevalent  stanfordchikvigg_encode2 stanforddenvigg_encode2 time, replace
replace prevalent = 1 if  stanfordchikvigg_encode2==1 & time ==1
replace prevalent = 1 if  stanforddenvigg_encode2==1 & time ==1

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
		destring id time denvigg_encode2 chikvigg_encode2 stanfordchikvigg_encode2 stanforddenvigg_encode2 site city, replace
		*capture drop if id_cohort=="d"
		replace id_cohort = "HCC" if id_cohort == "c"
		replace id_cohort = "AIC" if id_cohort == "f"
		encode id_cohort, gen(cohort)
		replace cohort = 1 if cohort ==3|cohort ==4
		label variable cohort "Cohort"
		label define Cohort 1 "HCC" 2 "AIC"
		label variable city "City"
		label define City 1 "Chulaimbo" 2 "Kisumu" 3 "Milani" 5 "Nganja" 6 "Ukunda"
save `dataset', replace
}
foreach dataset in "prevalent" "incident"{
*foreach dataset in "prevalent" "incident" "prevalentF" "incidentF" "prevalentC"  "incidentC"  {
use `dataset', clear
foreach failvar of varlist denvigg_encode2 chikvigg_encode2 stanfordchikvigg_encode2 stanforddenvigg_encode2 {
foreach axis of varlist time{
	preserve		
				*drop if `failvar' == .
				collapse (mean) `failvar' (count) n=`failvar' (sd) sd`failvar'=`failvar', by(cohort `axis')
				egen axis = axis(`axis')
				generate hi`failvar'= `failvar' + invttail(n-1,0.025)*(sd`failvar'/ sqrt(n))
				generate lo`failvar'= `failvar'- invttail(n-1,0.025)*(sd`failvar'/ sqrt(n))
			graph twoway ///
			   || (bar `failvar' axis, sort )(rcap hi`failvar' lo`failvar' axis) ///
			   || scatter `failvar' axis, ms(i) mlab(n) mlabpos(2) mlabgap(2) mlabangle(45) mlabcolor(black) mlabsize(4) ///
			   || , by(cohort) ylabel(, format(%5.3f)) ymtick(#4,  tlength(scheme tick)) legend(label(1 "`failvar'") label(2 "95% CI")) xlabel(0 (1) 9)  
				graph export "`dataset'`failvar'`axis'cohort.tif", width(4000) replace 

	restore	
	}
	foreach axis of varlist city {
	preserve		
				*drop if `failvar' == .
				collapse (mean) `failvar' (count) n=`failvar' (sd) sd`failvar'=`failvar', by(cohort `axis')
				egen axis = axis(`axis')
				generate hi`failvar'= `failvar' + invttail(n-1,0.025)*(sd`failvar'/ sqrt(n))
				generate lo`failvar'= `failvar'- invttail(n-1,0.025)*(sd`failvar'/ sqrt(n))
			graph twoway ///
			   || (bar `failvar' axis, sort )(rcap hi`failvar' lo`failvar' axis) ///
			   || scatter `failvar' axis, ms(i) mlab(n) mlabpos(2) mlabgap(2) mlabangle(45) mlabcolor(black) mlabsize(4) ///
			   || , by(cohort) ylabel(, format(%5.4f)) ymtick(#4,  tlength(scheme tick)) legend(label(1 "`failvar'") label(2 "95% CI")) xlabel(1 "Chulaimbo" 2 "Nganja" 3 "Kisumu" 4 "Milani" 5 "Msambweni" 6 "Ukunda", angle(45)) title(`dataset' by cohort and `axis')
				graph export "`dataset'`failvar'`axis'cohort.tif", width(4000) replace 

	restore	
	}
**********survival***************				
			stset time, id(id) failure(`failvar') origin(time==0)
			stdescribe
			stsum
			*drop if `failvar' == .
			*sts graph, hazard 
			sts graph, cumhaz risktable tmax(11) censored(single) title(`failvar') by(cohort) ylabel(minmax, format(%5.3f))  ymtick(##5,  tlength(scheme tick))
			graph export "cumhaz`dataset'`failvar'.tif", width(4000) replace
			sts graph, survival risktable tmax(11) censored(single) title(`failvar') by(cohort) ylabel(minmax, format(%5.3f))ymtick(##5,  tlength(scheme tick))
			graph export "survival`dataset'`failvar'.tif", width(4000) replace
			sts list, survival
			sts graph, risktable tmax(11)  censored(single) title(`failvar') by(cohort site) ylabel(minmax, format(%5.3f))ymtick(##5,  tlength(scheme tick))
			graph export "survivalsite`dataset'`failvar'.tif", width(4000) replace
			sts graph, risktable tmax(11) censored(single) title(`failvar') by(city) ylabel(minmax, format(%5.3f))ymtick(##5,  tlength(scheme tick))
			graph export "survivalcity`dataset'`failvar'.tif", width(4000) replace
			
			*stcox site
			*stcox city
			*stir site
			*strate
			*estat phtest 
			*streg site, d(w)
			*streg site, d(gomp)
			*streg site, d(e)
			*streg site, d(logn)
			*streg site, d(ln)
			*streg site city, d(gam)
			*stcurve, surv
			*graph export "stcurvesurv`dataset'`failvar'.png", replace
			*streg site city
		
foreach strata of varlist site_stanfordigg_chik site_stanfordigg_denv city_stanfordigg_chik city_stanfordigg_denv westcoast city cohort{
		table1, by(`strata')  vars(stanfordchikvigg_encode2 cat \stanforddenvigg_encode2 cat \ wnv_prntencode2 cat \onnv_prntencode2 cat \ chikv_prntencode2 cat \denv_prntencode2  cat \ nsiencode1 cat \denvigg_encode2 cat \ denvigg_encode2 cat \denvpcr_encode2 cat \chikvigg_encode2 cat \chikviggod_encode2 cat \chikvpcr_encode1 cat \)saving(site_stanfordigg_chik`dataset'.xls, replace)
}
}
}
