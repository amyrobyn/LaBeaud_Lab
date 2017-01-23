/**************************************************************
 *amy krystosik                  							  *
 *R01 results and discrepencies by strata (lab, antigen, test)*
 *lebeaud lab               				        		  *
 *last updated Jan 5, 2016  							  *
 **************************************************************/ 
capture log close 
log using "R01_nov2_16.smcl", text replace 
set scrollbufsize 100000
set more 1

cd "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\CSVs nov29_16"

*merge elisas with rdt and pcr from sammy
use sammy, clear
destring _all, replace
ds, has(type string) 
			foreach v of varlist `r(varlist)' { 
				replace `v' = lower(`v') 
			}
tostring id_childnumber  studyid, replace
merge 1:1 studyid using elisas.dta

		ds, has(type string) 
			foreach v of varlist `r(varlist)' { 
				replace `v' = lower(`v') 
			}

		rename VISIT visit
		drop id_visit
		preserve
			keep if _merge ==1 
			export excel using "sammyonly", firstrow(variables) replace
		restore

		bysort dengueigm_sammy visit: tab stanforddenvigg_
		bysort dengueigm_sammy visit: tab denvigg_

		preserve
			keep if _merge ==1 |_merge ==3
			keep study_id nsi stanforddenvigg_ denvigg_ dengueigm_sammy dengue_igg_sammy visit _merge 
			export excel using "sammy_comparison", firstrow(variables) replace

			keep if _merge ==3
			
			ds, has(type string) 
			foreach v of varlist `r(varlist)' { 
				replace `v' = lower(`v') 
			}

			
			save sammy_jael, replace
		restore

		capture drop _merge
		save elisas_RDT, replace
		
	*add in the pcr data from box and from googledoc. 
		merge 1:1 id_wide visit using "C:\Users\amykr\Box Sync\Amy Krystosik's Files\david coinfectin paper\allpcr"
		replace denvpcrresults_dum = 1 if denvpcrresults_dum>0&denvpcrresults_dum<1
		save elisas_PCR_RDT, replace
	

		*******declare data as panel data***********
		encode id_wide, gen(id)
		encode visit, gen(visit_s)
		xtset id visit_s	
		save longitudinal.dta, replace

		*simple prevalence/incidence by visit
			save temp, replace
			destring id visit_s, replace
			sort id visit_s

			capture drop _merge

		*	drop visit
		*	rename visit_s visit
			capture drop dup_merged
			drop v28

		count if visit_s ==2 
		count if visit_s >4
			
			ds, has(type string) 
			foreach v of varlist `r(varlist)' { 
				replace `v' = lower(`v') 
			}

save lab, replace

use all_interviews.dta, clear
destring _all, replace
ds, has(type string) 
			foreach v of varlist `r(varlist)' { 
				replace `v' = lower(`v') 
			}
			


merge 1:1 id_wide visit using lab.dta
*there are some lab visits that don't have a follow up in the interview data. those can be dropped if the don't have lab data. 
	drop if stanforddenvigg_ =="" & stanfordchikvigg_ =="" &  chikvpcrresults_dum ==. & denvpcrresults_dum==. & rdt==. & _merge==2 
	
foreach var in nsi denvpcrresults_dum{
			tab `var', gen(`var'encode)
}

gen prevalentchikv = .
gen prevalentdenv = .
encode stanfordchikvigg_, gen(stanfordchikviggencode)
replace stanfordchikviggencode = stanfordchikviggencode-1
rename stanfordchikviggencode Stanford_CHIKV_IGG
_strip_labels Stanford_CHIKV_IGG

encode stanforddenvigg_, gen(stanforddenviggencode)
replace stanforddenviggencode= stanforddenviggencode-1
rename stanforddenviggencode Stanford_DENV_IGG
_strip_labels Stanford_DENV_IGG


replace prevalentdenv = 1 if  Stanford_DENV_IGG ==1 & visit =="a"
replace prevalentchikv = 1 if  Stanford_CHIKV_IGG ==1 & visit =="a"

replace id_cohort = "HCC" if id_cohort == "c"|id_cohort == "d"
		replace id_cohort = "AIC" if id_cohort == "f"|id_cohort == "m" 
		capture drop cohort
		
		encode id_cohort, gen(cohort)
		
bysort cohort  city: sum Stanford_DENV_IGG Stanford_CHIKV_IGG
drop _merge

replace city = "Chulaimbo" if city =="c"
replace city = "Kisumu" if city =="u"
replace city = "Ukunda" if city =="k"

save prevalent, replace

*chikv matched prevalence
	use prevalent, clear
		ds, has(type string) 
			foreach v of varlist `r(varlist)' { 
				replace `v' = lower(`v') 
			}

		keep if visit == "a" & Stanford_CHIKV_IGG!=.
		save visit_a_chikv, replace
	use prevalent, clear
		keep if visit == "b" & Stanford_CHIKV_IGG!=.
		save visit_b_chikv, replace
		merge 1:1 id_wide using visit_a_chikv
		rename _merge abvisit
		keep abvisit visit id_wide
		merge 1:1 id_wide visit using prevalent
		keep if abvisit ==3 & Stanford_CHIKV_IGG!=.
		keep studyid  id_wide site visit antigenused_ city Stanford_CHIKV_IGG cohort gender datesamplecollected_ dob  agemonths age gender  Stanford_CHIK~G Stanford_DENV~G visit datesamplecol~_ 

		export excel using "C:\Users\amykr\Box Sync/DENV CHIKV project/Personalized Datasets/Amy/CSVs nov216/prevalent_visitab_chikv", firstrow(variables) replace
	
	*denv matched prevalence
	use prevalent, clear
		keep if visit == "a" & Stanford_DENV_IGG!=.
		save visit_a_denv, replace
	use prevalent, clear
		keep if visit == "b" & Stanford_DENV_IGG!=.
		save visit_b_denv, replace

		merge 1:1 id_wide using visit_a_denv
		rename _merge abvisit
		keep abvisit id_wide visit
		
		merge 1:1 id_wide visit using prevalent		
		keep if abvisit ==3 & Stanford_DENV_IGG!=.
		keep studyid  id_wide site visit antigenused_ city Stanford_DENV_IGG cohort gender datesamplecollected_ dob agemonths  age gender  Stanford_CHIK~G Stanford_DENV~G visit datesamplecol~_
		export excel using "C:\Users\amykr\Box Sync/DENV CHIKV project/Personalized Datasets/Amy/CSVs nov216/prevalent_visitab_denv", firstrow(variables) replace
		
*denv prevlanece
use prevalent, clear

rename denvigg_ igg_kenya_denv
rename chikvigg_ igg_kenya_chikv
rename dengue_igg_sammy igg_sammy_denv

foreach var in igg_kenya_chikv igg_kenya_denv igg_sammy_denv{
capture drop dos`var'
encode `var', gen(dos`var')
drop `var'
rename dos`var' `var' 
}
replace igg_kenya_chikv = . if igg_kenya_chikv<402
replace igg_kenya_chikv = . if igg_kenya_chikv==403|igg_kenya_chikv == 404|igg_kenya_chikv == 405| igg_kenya_chikv == 406
replace igg_kenya_chikv = 408 if igg_kenya_chikv==409


save  prevalent, replace

*outsheet using " mergedjan42017.csv", comma names replace

***merge with lab malaria data

gen studyid_all =""
order studyid_all 
foreach id in studyid studyid_ {
	replace studyid_all= `id' if studyid_all ==""
	drop `id'
}
rename studyid_all studyid

*drop bs* malaria* rdt species

destring _all, replace
ds, has(type string) 
			foreach v of varlist `r(varlist)' { 
				replace `v' = lower(`v') 
			}

dropmiss, force

merge 1:1 id_wide visit using "C:\Users\amykr\Box Sync\Amy Krystosik's Files\malaria prelim data dec 29 2016\malaria"
order malaria*

destring _all, replace 
sum malaria* Stanford*
bysort city: sum malaria* Stanford*
bysort city: tab malariapositive_dum
list if id_wide == "" | visit == ""
drop if id_wide == "" | visit == ""
isid id_wide visit

drop _merge
save malariatemp, replace

*malaria repeat offenders by bloodsmear


use malariatemp, clear
keep if visit == "a" & malariapositive_dum >0 & malariapositive_dum <.
save visit_a_malaria, replace
		
use malariatemp, clear
keep if visit == "b" & malariapositive_dum >0 & malariapositive_dum <.
save visit_b_malaria, replace
		
use malariatemp, clear
keep if visit == "c" & malariapositive_dum >0 & malariapositive_dum <.
save visit_c_malaria, replace
		
use malariatemp, clear
keep if visit == "d" & malariapositive_dum >0 & malariapositive_dum <.
save visit_d_malaria, replace

use malariatemp, clear
keep if visit == "e" & malariapositive_dum >0 & malariapositive_dum <.
save visit_e_malaria, replace
		
use malariatemp, clear
keep if visit == "f" & malariapositive_dum >0 & malariapositive_dum <.
save visit_g_malaria, replace
		
use malariatemp, clear
keep if visit == "h" & malariapositive_dum >0 & malariapositive_dum <.
save visit_h_malaria, replace
		

append using visit_a_malaria visit_b_malaria visit_c_malaria visit_d_malaria visit_e_malaria visit_f_malaria 
collapse (sum) malariapositive_dum, by (id_wide)
rename malariapositive_dum numbermalariainfections
save repeatoffender, replace


use malariatemp, clear
replace visit_s = 1 if visit =="a" & visit_s ==.
replace visit_s = 2 if visit =="b" & visit_s ==.
replace visit_s = 3 if visit =="c" & visit_s ==.
replace visit_s = 4 if visit =="d" & visit_s ==.
save malariatemp, replace
keep if malariapositive_dum >0 & malariapositive_dum<. 
egen max = max(visit_s), by(id_wide) 
keep id_wide max visit_s
save maxvisit, replace

merge m:m id_wide using repeatoffender
replace numbermalariainfections = . if max!=visit_s
drop _merge
save repeatoffender, replace

merge 1:1 id_wide visit_s using malariatemp
drop _merge
save malariatemp, replace

** add in the consecutive malariapos again
use malariatemp, clear
		keep if visit == "a" & malariapositive_dum >0 & malariapositive_dum <.
		save visit_a_malaria, replace

	use malariatemp, clear
	tab visit malariapositive_dum
		keep if visit == "b" & malariapositive_dum >0 & malariapositive_dum <.
	tab visit malariapositive_dum
	save visit_b_malaria, replace
	
		
		merge 1:1 id_wide using visit_a_malaria
		keep if _merge==3
		rename _merge malariapos_ab
		keep malariapos_ab id_wide visit
		save abmalaria , replace
		
	use malariatemp, clear
		keep if visit == "c" & malariapositive_dum >0 & malariapositive_dum <.
		save visit_c_malaria, replace
		merge 1:1 id_wide using visit_b_malaria
		keep if _merge==3
		rename _merge malariapos_bc
		keep malariapos_bc id_wide visit
		save bcmalaria, replace
	
	use malariatemp, clear
		keep if visit == "d" & malariapositive_dum >0 & malariapositive_dum <. 
		save visit_d_malaria, replace
		merge 1:1 id_wide using visit_c_malaria
		keep if _merge==3
		rename _merge malariapos_cd
		keep malariapos_cd id_wide visit
		save cdmalaria, replace
	
	use malariatemp, clear
		keep if visit == "e" & malariapositive_dum >0 & malariapositive_dum <.
		save visit_e_malaria, replace
		merge 1:1 id_wide using visit_d_malaria
		keep if _merge==3
		rename _merge malariapos_de
		keep malariapos_de id_wide visit
		save demalaria, replace 

	use malariatemp, clear
		keep if visit == "f" & malariapositive_dum >0 & malariapositive_dum <.
		save visit_f_malaria, replace
		merge 1:1 id_wide using visit_e_malaria
		keep if _merge==3
		rename _merge malariapos_ef
		keep malariapos_ef id_wide visit
		save efmalaria, replace

	use malariatemp, clear
		keep if visit == "g" & malariapositive_dum >0 & malariapositive_dum <.
		save visit_g_malaria, replace
		merge 1:1 id_wide using visit_f_malaria
		keep if _merge==3
		rename _merge malariapos_fg
		keep malariapos_fg id_wide visit
		save fgmalaria, replace

	use malariatemp, clear
		keep if visit == "h" & malariapositive_dum >0 & malariapositive_dum <.
		save visit_h_malaria, replace
		merge 1:1 id_wide using visit_h_malaria
		keep if _merge==3
		rename _merge malariapos_gh
		keep malariapos_gh id_wide visit
		save ghmalaria, replace

use malariatemp, clear
foreach dataset in ghmalaria fgmalaria efmalaria demalaria cdmalaria bcmalaria abmalaria{
		merge 1:1 id_wide visit using "`dataset'"
		capture drop _merge
		save merged, replace
		}
		foreach var in  malariapos_gh malariapos_fg malariapos_ef malariapos_de malariapos_cd malariapos_bc malariapos_ab{
		replace `var' = 1 if `var' >1 & `var'<.
		}

		egen consecutivemalariapos=rowtotal(malariapos_gh malariapos_fg malariapos_ef malariapos_de malariapos_cd malariapos_bc malariapos_ab)

		tab city consecutivemalariapos




foreach var in datesamplecollected_ {
gen `var'1 = date(`var', "MDY" ,2050)
format %td `var'1 
drop `var'
rename `var'1 `var'
recast int `var'
}


replace interviewdate = datesamplecollected_ if interviewdate ==.


gen interviewmonth =month(interviewdate)
gen interviewyear =year(interviewdate)

gen season = . 
replace season =1 if interviewmonth >=1 & interviewmonth <=3 & season ==.
*label define 1 "hot no rain"
replace season =2 if interviewmonth >=4 & interviewmonth <=6 & season ==.
*label define 2 "long rains"
replace season =3 if interviewmonth >=7 & interviewmonth <=10 & season ==.
*label define 3 "less rain cool season"
replace season =4 if interviewmonth >=11 & interviewmonth <=12 & season ==.
*label define 4 "short rains"

*malaria positives
foreach var in interviewdate age{
sum `var'  malariapositive_dum if  malariapositive_dum==1 
sum `var'  malariapositive_dum if  malariapositive_dum==1 
}


foreach var in gender hospitalsite age city { 
tab `var'  malariapositive_dum if  malariapositive_dum==1, m
}
*repeat offenders
foreach var in interviewdate age{
sum `var'  malariapositive_dum if  malariapositive_dum==1 & numbermalariainfections >1
sum `var'  malariapositive_dum if  malariapositive_dum==1 & numbermalariainfections >1
}

foreach var in gender hospitalsite age city { 
tab `var'  malariapositive_dum if  malariapositive_dum ==1 & numbermalariainfections >1, m
}

tab numbermalariainfections malariapositive_dum
order malaria* city gender hospitalsite interviewdate* age* numbermalariainfections 
save mergedjan42016, replace

tab malariapositive_dum
save malariadenguemerged, replace

***
**create village and house id so we can merge with gis points
gen villageid=""
replace villageid = substr(id_wide, +1, 1)
replace villageid = "1" if villageid =="c"
replace villageid = "2" if villageid =="k"

replace villageid = "1" if villageid =="u"
replace villageid = "2" if villageid =="u"

replace villageid = "3" if villageid =="g"
replace villageid = "4" if villageid =="l"
destring villageid, replace

gen houseid2 = ""
replace houseid2 = substr(id_wide, -6, 3) if cohort ==3
replace houseid2= substr(id_wide, 3, 4) if houseid2==""
destring houseid2 , replace force
replace houseid = houseid2 if houseid==. & houseid2!=.

destring houseid, replace
gen houseidstring = string(houseid ,"%04.0f")
drop houseid
rename houseidstring  houseid
order houseid

order studyid houseid villageid

destring houseid villageid, replace force
*replace these when i get the villgae id's

rename gametocytes gametocytes3
rename parasitelevel parasitelevel2
rename studyid studyid3

drop Parasitelevel Gametocytes 
rename *, lower
save malariadenguemerged, replace

*****************merge with gis points
/*
use xy, clear
rename *, lower
destring _all, replace
ds, has(type string) 
			foreach v of varlist `r(varlist)' { 
				replace `v' = lower(`v') 
			}
tostring windows, replace
merge m:m villageid houseid using malariadenguemerged
drop if _merge ==1

replace city = "Chulaimbo" if city =="c"
replace city = "Kisumu" if city =="u"
replace city = "Ukunda" if city =="k"

*check with david to make sure this is true...
save denvchikvmalariagps, replace
*/

*clean symptoms
gen studyid_all =""
order studyid_all 
foreach id in studyid3 clientno {
	replace studyid_all= `id' if studyid_all ==""
	drop `id'
}
rename studyid_all studyid

ds, has(type string)
	foreach var of var `r(varlist)'{
		replace `var' =trim(itrim(lower(`var')))
		rename `var', lower
	}		
	
replace city = "chulaimbo" if city =="r"
replace city = "chulaimbo" if city =="c"
replace city = "kisumu" if city =="k"
replace city = "ukunda" if city =="w"
replace city = "chulaimbo" if studyid =="cca0430005"|studyid=="cca0723003"

replace id_cohort ="aic" if id_cohort =="f"
replace id_cohort ="aic" if id_cohort =="m"
replace id_cohort ="hcc" if id_cohort =="c"
drop cohort
rename id_cohort cohort


gen childweight_kg = childweight
gen childheight_meters =childheight/100
gen bmi =  childweight_kg /(childheight_meters^2) 

replace v259  = "." if v259 =="010chemistry"
destring v259 , replace
replace hemoglobin = v259  if hemoglobin ==. 
sum hb

rename fevertemp tempover38 
replace tempover38 = 1 if temperature >38 & temperature !=.
replace tempover38  = 0 if temperature <=38 !=.
tab tempover38 , m

foreach var in heartrate diastolicbp systolicbp resprate pulseoximetry{ 
replace `var'= . if `var'==999
sum `var'
}

label var numbermalariainfections ""

*take visit out of id

									drop id1 id2 id3
									forval i = 1/3 { 

										gen id`i' = substr(studyid, `i', 1) if city ==""|cohort ==""
									}
			*gen id_wid without visit						 
				replace city  = id1 if city ==""
				replace cohort = id2 if cohort==""
				replace visit = id3 if visit ==""
				
replace cohort ="aic" if cohort =="f"
replace city ="chulaimbo" if city =="c"
replace city ="chulaimbo" if city =="r"
replace city =" msambweni" if city =="m"
 
preserve
keep if cohort =="aic"
table1 , vars( gender cat\ age conts\ city cat \  malariapositive conts\ numbermalariainfections cat \ consecutivemalariapos cat \ malariapastmedhist cat \ stanford_chikv_igg cat\ stanford_denv_igg cat\  chikvpcrresults_dum cat\ denvpcrresults_dum cat\ species_cat cat season cat\ parasite_count conts\ hb conts \ hemoglobin cat \ bmi conts \  temperature conts \ heartrate conts\ diastolicbp conts\ systolicbp conts\ resprate  conts\ pulseoximetry conts\ outcomehospitalized cat\) by(malariapositive_dum) saving("malariatable1_aic.xls", replace ) missing test 
restore

preserve
keep if cohort =="hcc"
table1 , vars( gender cat\ age conts\ city cat \  malariapositive conts\ numbermalariainfections cat \ consecutivemalariapos cat \ malariapastmedhist cat \ stanford_chikv_igg cat\ stanford_denv_igg cat\ chikvpcrresults_dum cat\ denvpcrresults_dum cat\ species_cat cat season cat\ parasite_count conts \ bmi conts \ tempover38 cat \ ) by(malariapositive_dum) saving("malariatable1_hcc.xls", replace ) missing test 
restore

save denvchikvmalariagps, replace

outsheet using " melisa_malriajan2017.csv", comma names replace
