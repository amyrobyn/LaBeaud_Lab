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
	gen id_city  = id1 
	gen id_cohort = id2 
	gen id_visit = id3
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
egen cohortcityantigen = concat(id_cohort id_city antigenused)
tostring *, replace force

foreach var in   chikvigg_ chikviggod_ stanfordchikvod_ stanfordchikvigg_ chikvpcr_ chikvigm_ denvigg_ denviggod_ stanforddenvod_ stanforddenvigg_ denvpcr_ denvigm_ stanforddenviggod_{
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
		tab `var' stanfordchikvigg_ if strpos(`var', "neg")|strpos(`var', "pos") & cohortcityantigen== "`l'", m 
		display "************************************************************sitechik**********************************************"
		}
		}

levelsof westcoast, local(levels) 
		foreach l of local levels { 
		display "`l'"
		foreach var of varlist *chikv* *denv* chikv* denv*{ 
		tab `var'  stanfordchikvigg_ if strpos(`var', "neg")|strpos(`var', "pos") & cohortcityantigen== "`l'", m 
		display "************************************************************site**********************************************"
		tab `var' stanfordchikvigg_ if strpos(`var', "neg")|strpos(`var', "pos") & cohortcityantigen== "`l'", m
	}
		}

table1, by(cohortcityantigen) vars(chikvigg_ cat \ chikviggod_ cat \ chikvpcr_ cat \) saving(cohortcityantigen_neg_pos.xls, replace)
table1, by(westcoast)  vars(chikvigg_ cat \ chikviggod_ cat \ chikvpcr_ cat \) saving(site_neg_pos.xls, replace)


encode id_wide, gen(ID)
encode visit, gen(time)
encode stanfordchikvigg_, gen(CHIKV_igg_stanford)
encode stanforddenvigg_, gen(DENV_igg_stanford)
encode westcoast, gen(site)
encode id_city, gen(city)

save elisas.dta, replace

**add RDT data
import excel "RDT_results_aug2.xls", sheet("RDT_results_aug2") firstrow clear
save "RDT_results_aug2.dta", replace

**add PRNT data
import excel "LaBeaud RESULTS - july 2016.xls", sheet("2016 PRNT-Msambweni Results") cellrange(A2:E154) firstrow clear
*splice on space and make child number equal to 4 and try to merge. any that don't match make childnumber = 7 and try to merge again. 
*recode prnt values as pos(20+)/ neg
save "2016 PRNT-Msambweni Results.dta", replace
*merge with elisas.dta
*drop if not matched and add to notmatched.dta. splice on space and make child number equal to 7 and try to merge again. 
*merge with elisas.dta


import excel "LaBeaud RESULTS - july 2016.xls", sheet("2016 PRNT-Ukunda Results") cellrange(A2:F80) firstrow clear
*splice on space and make child number equal to 4 and try to merge. any that don't match make childnumber = 7 and try to merge again. 
*recode prnt values as pos(20+)/ neg
save "2016 PRNT-Ukunda Results.dta", replace
*merge with elisas.dta
*drop if not matched and add to notmatched.dta. splice on space and make child number equal to 7 and try to merge again. 
*merge with elisas.dta




xtset ID time	
foreach failvar of varlist DENV_igg_stanford CHIKV_igg_stanford{
	stset time, id(ID) failure(`failvar') origin(time==1)
	stdescribe
	stsum
	stcox site
	stcox city
	stir site
	strate
	estat phtest 
	streg site city, d(w)
	stcurve, surv
	stset, clear
}
save longitudinal.dta, replace
