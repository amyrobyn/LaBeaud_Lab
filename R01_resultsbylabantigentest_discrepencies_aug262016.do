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
	
	keep if dup_merged >1	
	save dup.dta, replace

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
   						replace id_city  = "Chulaimbo" if id_city == "c"|id_city == "r"
						replace id_city  = "Msambweni" if id_city == "m"
						replace id_city  = "Kisumu" if id_city == "k"
						replace id_city  = "Ukunda" if id_city == "u"
						replace id_city  = "Milani" if id_city == "l"
						replace id_city  = "Nganja" if id_city == "g"
					gen westcoast= "." 
						replace westcoast = "Coast" if id_city =="Msambweni"|id_city =="Ukunda"|id_city =="Milani"|id_city =="Nganja"
						replace westcoast = "West" if id_city =="Chulaimbo"|id_city =="Kisumu"


save wide.dta, replace

	bysort id_wide: gen dup2 = _n 
	save wide.dta, replace
		keep if dup2 >1
		save dup2.dta, replace
use wide.dta, clear
	drop if dup2 >1
	reshape long   studyid_ followupaliquotid_ dateofcollection_ chikvigg_ chikviggod_ denvigg_ denviggod_ stanfordchikvod_  stanfordchikvigg_ stanforddenvod_ stanforddenvigg_ aliquotid_  chikvpcr_ chikvigm_ denvpcr_ denvigm_ stanforddenviggod_ followupid_ antigenused_ datesamplecollected_, i(id_wide) j(visit) string
	save long.dta, replace
	
	use long.dta, clear
	drop if id_wide==""
tostring *, replace force

encode id_wide, gen(ID)
encode visit, gen(time)
encode stanfordchikvigg_, gen(CHIKV_igg_stanford)
encode stanforddenvigg_, gen(DENV_igg_stanford)
encode westcoast, gen(site)
encode id_city, gen(city)

save elisas.dta, replace

************************************add RDT data**********************************
import excel "RDT_results_aug2.xls", sheet("RDT_results_aug2") firstrow clear
save "RDT_results_aug2.dta", replace
replace STUDY_ID= subinstr( STUDY_ID, " ", "",.)

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
save "RDT_results_aug2.dta", replace
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

xtset ID time	
save longitudinal.dta, replace
use longitudinal.dta, clear
egen cohortcityantigen = concat(id_cohort id_city antigenused)


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

order *denv* *chikv*  chikv*  denv*  denv*  wnv_prnt onnv_prnt 

foreach var in  wnv_prnt onnv_prnt chikv_prnt chikv_igg_stanford denv_prnt denv_nsi_result denv_igg_stanford denvigg_ denviggod_ denvpcr_ denvigm_ chikvigg_ chikviggod_ chikvpcr_ chikvigm_ stanfordchikvod_ stanfordchikvigg_ stanforddenvod_ stanforddenvigg_ stanforddenviggod_ {  
	replace `var' =trim(itrim(lower(`var')))
	gen `var'_result =""
	replace `var'_result = "neg" if strpos(`var', "neg")
	replace `var'_result = "pos" if strpos(`var', "pos") 
	drop `var'
	rename `var'_result `var'
	tab `var'
}

levelsof cohortcityantigen, local(levels) 
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

save temp.dta, replace
keep if site=="1"
save site1.dta, replace
use temp.dta, clear
keep if site =="2"
save site2.dta, replace

foreach dataset in site1.dta site2.dta temp.dta{
use `dataset', clear
	foreach var in  chikv_prnt chikv_igg_stanford chikvigg_ chikviggod_ chikvpcr_ chikvigm_ stanfordchikvod_ stanfordchikvigg_ denv_prnt denv_nsi_result denv_igg_stanford denvigg_ denviggod_ denvpcr_ denvigm_ stanforddenvod_ stanforddenvigg_ stanforddenviggod_ wnv_prnt onnv_prnt{
		encode `var', gen(`var'encode)
	}
	
	foreach var in  chikvigg_encode chikviggod_encode chikvpcr_encode stanfordchikvigg_encode denv_prntencode denv_nsi_resultencode denvigg_encode denviggod_encode denvpcr_encode stanforddenvigg_encode wnv_prntencode onnv_prntencode{
		diagt  stanfordchikvigg_encode  `var' 
		diagt stanforddenvigg_encode `var'		
		save `dataset', replace
}
}
use temp.dta, clear

egen site_stanfordigg_chik = concat(site stanforddenvigg_encode)
egen site_stanfordigg_denv= concat(site stanforddenvigg_encode)
egen city_stanfordigg_chik = concat(city stanfordchikvigg_encode)
egen city_stanfordigg_denv = concat(city stanforddenvigg_encode)


gen prevalent = .
tab stanfordchikvigg_encode, gen(stanfordchikvigg_dum)
tab stanforddenvigg_encode, gen(stanforddenvigg_dum)
destring prevalent  stanfordchikvigg_dum2 stanforddenvigg_dum2 time, replace
replace prevalent = 1 if  stanfordchikvigg_dum2==1 & time ==1
replace prevalent = 1 if  stanforddenvigg_dum2==1 & time ==1
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
set scrollbufsize 100000
set more 1

*trajectory.do file for Stata 6.0
clear
use prevalent
egen newid=group(id)
sum newid
drop id
ren newid id
sort id time
gen pick = 0
local i=1
while `i' < 8{
set seed `i'
local r = round(1+uniform()*369,1)
gen denvigg_encode`i' = denvigg_encode if (id == `r')
 local i=`i'+1
}
ksm denvigg_encode  time, lowess gen(denvigg_encodesmth) nograph
graph7 denvigg_encode denvigg_encode1 - denvigg_encodesmth1 time, c(.LLLLLLL.) s(.iiiiiiio) pen(233333334) xlab ylab 


*stanforddenvigg_dum2  no incident events
foreach dataset in "prevalent" "prevalentC" "prevalentF" "incident" "incidentC" "incidentF"{
use `dataset', clear

destring id time  denvigg_encode chikvigg_encode stanfordchikvigg_dum2 stanforddenvigg_dum2 site city, replace

rename denvigg_encode DIGG
rename  chikvigg_encode CIGG
rename stanfordchikvigg_dum2 SCIGG 
rename stanforddenvigg_dum2 SDIGG
foreach failvar of varlist DIGG CIGG SCIGG SDIGG{

		**********longitudinal***************
		*b) Create individual profiles over time with a solid trend line. 
		sort id time
		*xtline `failvar', t(time) i(id) overlay addplot(qfit `failvar' time, lcolor(red) lwidth(thick))
		*graph export "xtlineqfit`dataset'`failvar'.png", replace

		*c) Create individual profiles over time with a solid trend line for treatment groups. Comment on it. [5 points]
		*xtline `failvar', t(time) i(id) overlay addplot (( qfit `failvar' time if site== "West", n(4) lwidth(thick)) || ( qfit lead_µgperdL week if site == "Coast", n(4) lwidth(thick)))
		*graph export "xtlineqfitsite`dataset'`failvar'.png", replace

		*d) Plot empirical mean response over time for treatment groups.
		by time site, sort : egen float mean`failvar' = mean(`failvar')
		separate  mean`failvar', by(site) veryshortlabel
		scatter mean`failvar'? time, c(direct)
		graph export "scattermean`dataset'`failvar'.png", replace

		
		
		
		

		*e.
		xtset id time
		xtdes
		xtsum
		xttab `failvar'
		xtreg `failvar' site
		xtreg `failvar' city
		xtgraph `failvar', group(city)

		*compare gee and mixed but use mixed
		xtgee `failvar' b0.time b1.site time#site, family(gaussian) link(identity) corr(exchangeable) vce(robust)
		xtmixed `failvar' b0.time b1.site time#site, vce(robust) 
		*reference group = week 0 and placebo

		*h)
		*compare gee and mixed but use mixed
		xi: xtgee `failvar' time i.site|time, family(gaussian) link(identity) corr(exchangeable) vce(robust)
		xi: xtmixed `failvar' time i.site|time, vce(robust) 


		*m.
		*compare gee and mixed but use mixed
		xi: xtgee `failvar' time site i.site|time, family(gaussian) link(identity) corr(exchangeable) vce(robust)
		xi: xtmixed `failvar' time site i.site|time, vce(robust)



		**********survival***************	
			
			/*stset time, id(id) failure(`failvar') origin(time==1)
			stdescribe
			stsum
			*sts graph, hazard 
			sts graph, cumhaz 
			graph export "cumhaz`dataset'`failvar'.png", replace
			sts graph, survival
			graph export "survival`dataset'`failvar'.png", replace
			sts list, survival
			sts graph, by(site)
			graph export "survivalsite`dataset'`failvar'.png", replace
			sts graph, by(city)
			graph export "survivalcity`dataset'`failvar'.png", replace
			
			stcox site
			stcox city
			stir site
			strate
			estat phtest 
			streg site, d(w)
			streg site, d(gomp)
			streg site, d(e)
			streg site, d(logn)
			streg site, d(ln)
			*streg site city, d(gam)
			stcurve, surv
			graph export "stcurvesurv`dataset'`failvar'.png", replace
			streg site city
			*/
}

/*
		table1, by(site_stanfordigg_chik)  vars(stanfordchikvigg_encode cat \stanforddenvigg_encode cat \ wnv_prntencode cat \onnv_prntencode cat \ chikv_prntencode cat \denv_prntencode  cat \ denv_nsi_resultencode cat \denvigg_encode cat \ denvigg_encode cat \denvpcr_encode cat \chikvigg_encode cat \chikviggod_encode cat \chikvpcr_encode cat \)saving(site_stanfordigg_chik`dataset'.xls, replace)
		table1, by(site_stanfordigg_denv)  vars(stanfordchikvigg_encode cat \stanforddenvigg_encode cat \ wnv_prntencode cat \onnv_prntencode cat \ chikv_prntencode cat \denv_prntencode  cat \ denv_nsi_resultencode cat \denvigg_encode cat \ denvigg_encode cat \denvpcr_encode cat \chikvigg_encode cat \chikviggod_encode cat \chikvpcr_encode cat \)saving(site_stanfordigg_denv`dataset'.xls, replace)
		table1, by(city_stanfordigg_chik)  vars(stanfordchikvigg_encode cat \stanforddenvigg_encode cat \ wnv_prntencode cat \onnv_prntencode cat \ chikv_prntencode cat \denv_prntencode  cat \ denv_nsi_resultencode cat \denvigg_encode cat \ denvigg_encode cat \denvpcr_encode cat \chikvigg_encode cat \chikviggod_encode cat \chikvpcr_encode cat \)saving(city_stanfordigg_chik`dataset', replace)
		table1, by(city_stanfordigg_denv)  vars(stanfordchikvigg_encode cat \stanforddenvigg_encode cat \ wnv_prntencode cat \onnv_prntencode cat \ chikv_prntencode cat \denv_prntencode  cat \ denv_nsi_resultencode cat \denvigg_encode cat \ denvigg_encode cat \denvpcr_encode cat \chikvigg_encode cat \chikviggod_encode cat \chikvpcr_encode cat \)saving(city_stanfordigg_denv`dataset'.xls, replace)
		table1, by(westcoast)  vars(stanfordchikvigg_encode cat \stanforddenvigg_encode cat \ wnv_prntencode cat \onnv_prntencode cat \ chikv_prntencode cat \denv_prntencode  cat \ denv_nsi_resultencode cat \denvigg_encode cat \ denvigg_encode cat \denvpcr_encode cat \chikvigg_encode cat \chikviggod_encode cat \chikvpcr_encode cat \)saving(westcoast`dataset'.xls, replace)
		table1, by(city)  vars(stanfordchikvigg_encode cat \stanforddenvigg_encode cat \ wnv_prntencode cat \onnv_prntencode cat \ chikv_prntencode cat \denv_prntencode  cat \ denv_nsi_resultencode cat \denvigg_encode cat \ denvigg_encode cat \denvpcr_encode cat \chikvigg_encode cat \chikviggod_encode cat \chikvpcr_encode cat \)saving(city`dataset'.xls, replace)
		table1, vars(stanfordchikvigg_encode cat \stanforddenvigg_encode cat \ wnv_prntencode cat \onnv_prntencode cat \ chikv_prntencode cat \denv_prntencode  cat \ denv_nsi_resultencode cat \denvigg_encode cat \ denvigg_encode cat \denvpcr_encode cat \chikvigg_encode cat \chikviggod_encode cat \chikvpcr_encode cat \)saving(total`dataset'.xls, replace)
		*/
}
