/**************************************************************
 *amy krystosik                  							  *
 *R01 results and discrepencies by strata (lab, antigen, test)*
 *lebeaud lab               				        		  *
 *last updated august 15, 2016  							  *
 **************************************************************/
 /*to do
 -longitudinal nature of data- survival analysis, rain data
 -sensisitivty by site (west vs coast)
 -prnt n = 200. check the sensitivity analysis
 -rdt ns1+/+igm =+. compare that to stfd igg incidence.
 -add 700 samples from ukunda
 -pcr + copmared to igg at next visit (ab/bc/cd)
 */
 
cd "C:\Users\Amy\Box Sync\Amy Krystosik's Files\R01\longitudinal_analysis_aug252016"
*cd "/Users/amykrystosik/Box Sync/Amy Krystosik's Files/R01/longitudinal_analysis_aug252016"
capture log close 
log using "R01_discrepenciesaugust25longitudinal.smcl", text replace 
set scrollbufsize 100000
set more 1

**download the data from BOX and import here as xlsx sheets. 
import excel "UPDATED DATABASE 04 May 2016.xls.xlsx", sheet("Msambweni  AIC") cellrange(A9:BG1579) firstrow clear
	tostring *, replace force
	foreach var of varlist _all{
		replace `var'=lower(`var')
		rename `var', lower
		}	
	drop if studyid_a==""
save aic_msambweni.dta, replace
import excel "UPDATED DATABASE 04 May 2016.xls.xlsx", sheet("MILALANI HCC") cellrange(A4:AY602) firstrow clear
	tostring *, replace force
	foreach var of varlist _all{
		replace `var'=lower(`var')
		rename `var', lower
		}	
	drop if studyid_a==""
save hcc_milalani.dta, replace
import excel "UPDATED DATABASE 04 May 2016.xls.xlsx", sheet("NGANJA HCC") cellrange(A4:AY1002) firstrow clear
	tostring *, replace force
	foreach var of varlist _all{
		replace `var'=lower(`var')
		rename `var', lower
		}	
	drop if studyid_a==""
save hcc_nganja.dta, replace
import excel "UPDATED DATABASE 04 May 2016.xls.xlsx", sheet("Ukunda HCC") cellrange(A4:BH1193) firstrow clear
	tostring *, replace force
	foreach var of varlist _all{
		replace `var'=lower(`var')
		rename `var', lower
		}	
	drop if studyid_a==""
save hcc_ukunda.dta, replace
import excel "Western (Chulaimbo, Kisumu) AIC ELISA. Common sheet..xlsx", sheet("KISUMU AIC") cellrange(A9:AD1004) firstrow clear
	tostring *, replace force
	foreach var of varlist _all{
		replace `var'=lower(`var')
		rename `var', lower
		}	
	drop if studyid_a==""
save aic_kisumu.dta, replace
import excel "Western (Chulaimbo, Kisumu) AIC ELISA. Common sheet..xlsx", sheet("CHULAIMBO HCC") cellrange(A4:BF1011) firstrow clear
	tostring *, replace force
	foreach var of varlist _all{
		replace `var'=lower(`var')
		rename `var', lower
		}	
	drop if studyid_a==""
save hcc_chulaimbo.dta, replace
import excel "Western (Chulaimbo, Kisumu) AIC ELISA. Common sheet..xlsx", sheet("KISUMU HCC") cellrange(A4:BC1010) firstrow clear
	tostring *, replace force
	foreach var of varlist _all{
		replace `var'=lower(`var')
		rename `var', lower
		}	
	drop if studyid_a==""
save hcc_kisumu.dta, replace
import excel "UPDATED DATABASE 04 May 2016.xls.xlsx", sheet("Ukunda AIC") cellrange(A9:BC1579) firstrow clear
	rename StanfordCHIKVIgG_a StanfordCHIKVIgG_a2
	rename StanfordCHIKVOD_a StanfordCHIKVOD_a2
	tostring *, replace force
	foreach var of varlist _all{
		replace `var'=lower(`var')
		rename `var', lower
		}	
	drop if studyid_a==""
save aic_ukunda.dta, replace


**append the different site and cohort excel sheets. 
use "hcc_kisumu", clear
append using "aic_ukunda" "aic_msambweni" "hcc_milalani" "hcc_nganja" "hcc_ukunda" "aic_kisumu" "hcc_chulaimbo" "hcc_kisumu", generate(append)
			tostring *, replace force
	
			replace studyid_a= subinstr(studyid_a, ".", "",.) 
			replace studyid_a= subinstr(studyid_a, "/", "",.)
			replace studyid_a= subinstr(studyid_a, " ", "",.)
			drop if studyid_a==""
		

	bysort  studyid_a: gen dup_merged = _n 
	tab dup_merged
	list studyid_a if dup_merged>1
	save merged.dta, replace
	*keep those that i dropped for duplicate and show to elysse
	keep if dup_merged >1	
	export excel using "dup", firstrow(variables) replace

	use merged.dta, replace
	drop if dup_merged >1
	
save merged.dta, replace


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
save wide.dta, replace

	bysort id_wide: gen dup2 = _n 
	save wide.dta, replace
		keep if dup2 >1
		export excel using "dup2", firstrow(variables) replace
use wide.dta, clear
	drop if dup2 >1
	reshape long   studyid_ followupaliquotid_ dateofcollection_ chikvigg_ chikviggod_ denvigg_ denviggod_ stanfordchikvod_  stanfordchikvigg_ stanforddenvod_ stanforddenvigg_ aliquotid_  chikvpcr_ chikvigm_ denvpcr_ denvigm_ stanforddenviggod_ followupid_ antigenused_ datesamplecollected_, i(id_wide) j(visit) string
	save long.dta, replace
	
	use long.dta, clear
	drop if id_wide==""
tostring *, replace force
capture drop _merge
save elisas.dta, replace

************************************add RDT data**********************************

import excel "DENGUE RDT RESULTS Aug 2 2016.xls", sheet("Sheet3") firstrow clear
rename STUDYNUMBER STUDY_ID
rename IgM dengueigm_sammy
rename IgG dengue_igg_sammy
save "DENGUE RDT RESULTS Aug 2 2016.dta", replace
save ns1.dta, replace
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
	
tostring *, replace force
	foreach var of varlist _all{
	replace `var' =trim(itrim(lower(`var')))
	}
save ns1.dta, replace
merge 1:1 id_wide visit using elisas.dta
drop _merge
save elisas_PCR_RDT.dta, replace

************************************add PRNT data**********************************
import excel "LaBeaud RESULTS - july 2016.xls", sheet("2016 PRNT-Msambweni Results") cellrange(A2:E154) firstrow clear
save "2016 PRNT-Msambweni Results.dta", replace
import excel "LaBeaud RESULTS - july 2016.xls", sheet("2016 PRNT-Ukunda Results") cellrange(A2:F80) firstrow clear
save "2016 PRNT-Ukunda Results.dta", replace

foreach dataset in "2016 PRNT-Ukunda Results" "2016 PRNT-Msambweni Results"{
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
		tostring *, replace force
			foreach var of varlist _all{
			replace `var' =trim(itrim(lower(`var')))
			}

		 foreach v of varlist  DENV2 WNV CHIKV ONNV{
			  replace `v' = "pos" if `v' == "40"|`v' == ">80"|`v' == "20"
			  replace `v' = "neg" if `v' == "10"|`v' == "<10"
			  replace `v' = "" if `v' == "no sample"|`v' == "no sample received at cdc"|`v' == ""
		   tab `v', m
		   }   
		   
		   rename  DENV2 denv_prnt
		   rename  WNV wnv_prnt 
		   rename  CHIKV chikv_prnt 
		   rename  ONNV onnv_prnt
	save "`dataset'", replace
}
use "2016 PRNT-Msambweni Results.dta", clear
*merge with elisas.dta
merge 1:1 id_wide visit using "elisas_PCR_RDT.dta"
drop _merge
save "elisas_PCR_RDT_PRNT1.dta", replace

use "2016 PRNT-Ukunda Results.dta", clear
*merge with elisas.dta
merge 1:1 id_wide visit using elisas_PCR_RDT_PRNT1.dta
drop _merge
save "elisas_PCR_RDT_PRNT2.dta", replace

*******declare data as panel data***********
tostring *, replace force
foreach v of varlist _all { 
			replace `v' = lower(`v') 
} 
tostring *, replace
foreach v of varlist _all {
		rename `v' `=lower("`v'")'
   }
 foreach var of varlist _all{
							replace `var' =trim(itrim(lower(`var')))
	}
encode id_wide, gen(id)
sort visit
drop if visit =="a2"
encode visit, gen(time)

encode id_city, gen(city)
xtset id time	
save longitudinal.dta, replace

	   					replace id_city  = "Chulaimbo" if id_city == "c"|id_city == "r"
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


save temp.dta, replace
keep if site==1
save site1.dta, replace
use temp.dta, clear
keep if site ==2
save site2.dta, replace
	
cd "C:\Users\Amy\Box Sync\Amy Krystosik's Files\R01\longitudinal_analysis_aug252016"
foreach dataset in site1.dta site2.dta temp.dta{
display "**********************`dataset'*******************"
use `dataset', clear
sum dengueigm_sam~2 nsiencode1 chikv_prntencode2  chikvigg_encode2 chikviggod_encode2 chikvpcr_encode1 stanfordchikvigg_encode2 denv_prntencode2 denvigg_encode2 denviggod_encode2 denvpcr_encode2 stanforddenvigg_encode2  wnv_prntencode2 onnv_prntencode2 

diagt chikv_prntencode2 stanfordchikvigg_encode2
diagt stanfordchikvigg_encode2 chikvigg_encode2
diagt chikvpcr_encode1 l1_iggS_chikv
 
diagt denv_prntencode2 stanforddenvigg_encode2 
diagt stanforddenvigg_encode2 denvigg_encode2  
diagt denvpcr_encode2 l1_iggS_denv
diagt dengueigm_sam~2 nsiencode1
}


use temp.dta, clear

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

save prevalent.dta, replace
keep if id_cohort =="c"
save prevalentC.dta, replace
use prevalent.dta, clear
keep if id_cohort =="f"
save prevalentF.dta, replace

use prevalent.dta, clear
drop if prevalent == 1 
save incident.dta, replace
keep if id_cohort =="c"
save incidentC.dta, replace
use incident.dta, clear
keep if id_cohort =="f"
save incidentF.dta, replace






************************************************survival and longitudinal analysis********************************************
cd "C:\Users\Amy\Box Sync\Amy Krystosik's Files\R01\longitudinal_analysis_aug252016"
*cd "/Users/amykrystosik/Box Sync/Amy Krystosik's Files/R01/longitudinal_analysis_aug252016"
capture log close 
*log using "R01_discrepenciesaugust25longitudinal.smcl", text replace 

foreach dataset in "prevalent" "incident"{
use `dataset', clear
		destring id time denvigg_encode2 chikvigg_encode2 stanfordchikvigg_encode2 stanforddenvigg_encode2 site city, replace
		
		capture drop if id_cohort=="d"
		replace id_cohort = "HCC" if id_cohort == "c"
		replace id_cohort = "AIC" if id_cohort == "f"
		encode id_cohort, gen(cohort)
		label variable cohort "Cohort"
		label define Cohort 1 "HCC" 2 "AIC"
		
		label variable city "City"
		label define City 1 "Chulaimbo" 2 "Kisumu" 3 "Milani" 5 "Nganja" 6 "Ukunda"
save `dataset', replace
}
set scrollbufsize 100000
set more 1

foreach dataset in "prevalent" "incident"{
*foreach dataset in "prevalent" "incident" "prevalentF" "incidentF" "prevalentC"  "incidentC"  {
use `dataset', clear
foreach failvar of varlist denvigg_encode2 chikvigg_encode2 stanfordchikvigg_encode2 stanforddenvigg_encode2 {
foreach axis of varlist city time{
	preserve		
				drop if `failvar'==.
				collapse (mean) `failvar' (count) n=`failvar' (sd) sd`failvar'=`failvar', by(cohort `axis')
				egen axis = axis(`axis')
				generate hi`failvar'= `failvar' + invttail(n-1,0.025)*(sd`failvar'/ sqrt(n))
				generate lo`failvar'= `failvar'- invttail(n-1,0.025)*(sd`failvar'/ sqrt(n))
			graph twoway ///
			   || (bar `failvar' axis, sort )(rcap hi`failvar' lo`failvar' axis) ///
			   || scatter `failvar' axis, ms(i) mlab(n) mlabpos(12) mlabgap(2) mlabangle(45) mlabcolor(black) ///
			   || , by(cohort) yscale(range(0.00 `=r(max)')) xscale(range(1`=r(max)')) legend(label(1 "`failvar'") label(2 "95% CI")) 
				*xlabel(1 "Chulaimbo" 2 "Nganja" 3 "Milani" 4 "Kisumu" 5 "Msambweni" 6 "Ukunda", angle(45))  
				graph export "`dataset'`failvar'`axis'cohort.tif", width(4000) replace 

	restore	
**********survival***************				
			stset time, id(id) failure(`failvar') origin(time==0)
			stdescribe
			stsum
			*sts graph, hazard 
			sts graph, cumhaz risktable tmax(11) tmax(1) atrisk censored(single) title(`failvar') by(cohort) 
			graph export "cumhaz`dataset'`failvar'.tif", width(4000) replace
			sts graph, survival
			graph export "survival`dataset'`failvar'.tif", width(4000) replace
			sts list, survival
			sts graph, by(site)
			graph export "survivalsite`dataset'`failvar'.tif", width(4000) replace
			sts graph, by(city)
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
}

