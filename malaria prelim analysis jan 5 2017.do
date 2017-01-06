/************************************************************** *amy krystosik                  							  * *R01 results and discrepencies by strata (lab, antigen, test)* *lebeaud lab               				        		  * *last updated Jan 5, 2016  							  * **************************************************************/
cd "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\CSVs nov29_16"
*merge elisas with rdt and pcr from sammy
use sammy, clearmerge 1:1 id_wide VISIT using elisas.dta
		rename VISIT visit
		drop id_visit		preserve			keep if _merge ==1 			export excel using "sammyonly", firstrow(variables) replace		restore
		bysort dengueigm_sammy visit: tab stanforddenvigg_		bysort dengueigm_sammy visit: tab denvigg_		preserve			keep if _merge ==1 |_merge ==3			keep study_id nsi stanforddenvigg_ denvigg_ dengueigm_sammy dengue_igg_sammy visit _merge 			export excel using "sammy_comparison", firstrow(variables) replace			keep if _merge ==3			save sammy_jael, replace		restore
		capture drop _merge		save elisas_PCR_RDT, replace		*******declare data as panel data***********		encode id_wide, gen(id)		encode visit, gen(visit_s)
		xtset id visit_s			save longitudinal.dta, replace
		foreach var of varlist stanford*{ 			replace `var' =trim(itrim(lower(`var')))			gen `var'_result =""			replace `var'_result = "neg" if strpos(`var', "neg")			replace `var'_result = "pos" if strpos(`var', "pos") 			drop `var'			rename `var'_result `var'			tab `var'		}		*simple prevalence/incidence by visit			save temp, replace			destring id visit_s, replace			sort id visit_s			capture drop _merge		*	drop visit		*	rename visit_s visit			capture drop dup_merged			drop v28

		count if visit_s ==2 
		count if visit_s >4

save lab, replace

use all_interviews.dta, clear
merge 1:1 id_wide visit using lab.dta
*there are some lab visits that don't have a follow up in the interview data. those can be dropped if the don't have lab data. 
	drop if stanforddenvigg_ =="" & stanfordchikvigg_ =="" & malariabloodsmear ==. & chikvpcr_ =="" & denvpcr_=="" & rdt==. & malariaresults ==. & bsresults==. & rdtresults ==. & _merge==2 
	
foreach var in nsi denvpcr_ chikvpcr{			tab `var', gen(`var'encode)}gen prevalentchikv = .gen prevalentdenv = .
encode stanfordchikvigg_, gen(stanfordchikviggencode)
replace stanfordchikviggencode = stanfordchikviggencode-1rename stanfordchikviggencode Stanford_CHIKV_IGG
_strip_labels Stanford_CHIKV_IGG
encode stanforddenvigg_, gen(stanforddenviggencode)replace stanforddenviggencode= stanforddenviggencode-1
rename stanforddenviggencode Stanford_DENV_IGG
_strip_labels Stanford_DENV_IGG

replace prevalentdenv = 1 if  Stanford_DENV_IGG ==1 & visit =="a"replace prevalentchikv = 1 if  Stanford_CHIKV_IGG ==1 & visit =="a"replace id_cohort = "HCC" if id_cohort == "c"|id_cohort == "d"		replace id_cohort = "AIC" if id_cohort == "f"|id_cohort == "m" 		capture drop cohort		encode id_cohort, gen(cohort)		bysort cohort  city: sum Stanford_DENV_IGG Stanford_CHIKV_IGG
drop _merge

replace city = "Chulaimbo" if city =="c"
replace city = "Kisumu" if city =="u"
replace city = "Ukunda" if city =="k"
save prevalent, replace*chikv matched prevalence	use prevalent, clear		keep if visit == "a" & Stanford_CHIKV_IGG!=.
		save visit_a_chikv, replace	use prevalent, clear		keep if visit == "b" & Stanford_CHIKV_IGG!=.		save visit_b_chikv, replace		merge 1:1 id_wide using visit_a_chikv		rename _merge abvisit		keep abvisit visit id_wide		merge 1:1 id_wide visit using prevalent		keep if abvisit ==3 & Stanford_CHIKV_IGG!=.
		keep studyid  id_wide site visit antigenused_ city Stanford_CHIKV_IGG cohort gender datesamplecollected_ dob  agemonths age gender  Stanford_CHIK~G Stanford_DENV~G visit datesamplecol~_ 		export excel using "C:\Users\amykr\Box Sync/DENV CHIKV project/Personalized Datasets/Amy/CSVs nov216/prevalent_visitab_chikv", firstrow(variables) replace		*denv matched prevalence	use prevalent, clear		keep if visit == "a" & Stanford_DENV_IGG!=.		save visit_a_denv, replace	use prevalent, clear		keep if visit == "b" & Stanford_DENV_IGG!=.		save visit_b_denv, replace
		merge 1:1 id_wide using visit_a_denv
		rename _merge abvisit		keep abvisit id_wide visit		
		merge 1:1 id_wide visit using prevalent		
		keep if abvisit ==3 & Stanford_DENV_IGG!=.		keep studyid  id_wide site visit antigenused_ city Stanford_DENV_IGG cohort gender datesamplecollected_ dob agemonths  age gender  Stanford_CHIK~G Stanford_DENV~G visit datesamplecol~_		export excel using "C:\Users\amykr\Box Sync/DENV CHIKV project/Personalized Datasets/Amy/CSVs nov216/prevalent_visitab_denv", firstrow(variables) replace		*denv prevlaneceuse prevalent, clear

rename denvpcr_ pcr_denv
rename chikvpcr_ pcr_chikv
rename denvigg_ igg_kenya_denv
rename chikvigg_ igg_kenya_chikv
rename dengue_igg_sammy igg_sammy_denv

foreach var in igg_kenya_chikv igg_kenya_denv pcr_chikv pcr_denv igg_sammy_denv{
capture drop dos`var'
encode `var', gen(dos`var')
drop `var'
rename dos`var' `var' 
}
replace igg_kenya_chikv = . if igg_kenya_chikv<402
replace igg_kenya_chikv = . if igg_kenya_chikv==403|igg_kenya_chikv == 404|igg_kenya_chikv == 405| igg_kenya_chikv == 406
replace igg_kenya_chikv = 408 if igg_kenya_chikv==409


save  prevalent, replace

order malaria*
destring malariabloodsmear  malariapastmedhist, replace
encode pos_neg, gen(malariapos)
encode pos_neg1, gen(malariapos2)
replace malariapos = malariapos-1
replace malariapos2=malariapos2-1
_strip_labels malariapos malariapos2
drop pos_neg*

label values malariaresults malariaresults
label define malariaresult 0 "negative" 1 "+" 2 "++" 3 "+++" 4 "++++"
 
sum malaria* Stanford*
tab malariaresults 
bysort city: sum malaria* Stanford*
bysort city: tab malariaresults 
isid id_wide visit
save malariatemp, replace

*malaria repeat offenders by bloodsmear
	use malariatemp, clear
		keep if visit == "a" & malariabloodsmear==1
		save visit_a_malaria, replace

	use malariatemp, clear
		keep if visit == "b" & malariabloodsmear==1
		save visit_b_malaria, replace
		merge 1:1 id_wide using visit_a_malaria
		keep if _merge==3
		rename _merge malariapos_ab
		keep malariapos_ab id_wide visit
		save abmalaria , replace
		
	use malariatemp, clear
		keep if visit == "c" & malariabloodsmear==1
		save visit_c_malaria, replace
		merge 1:1 id_wide using visit_b_malaria
		keep if _merge==3
		rename _merge malariapos_bc
		keep malariapos_bc id_wide visit
		save bcmalaria, replace
	
	use malariatemp, clear
		keep if visit == "d" & malariabloodsmear==1
		save visit_d_malaria, replace
		merge 1:1 id_wide using visit_c_malaria
		keep if _merge==3
		rename _merge malariapos_cd
		keep malariapos_cd id_wide visit
		save cdmalaria, replace
	
	use malariatemp, clear
		keep if visit == "e" & malariabloodsmear==1
		save visit_e_malaria, replace
		merge 1:1 id_wide using visit_d_malaria
		keep if _merge==3
		rename _merge malariapos_de
		keep malariapos_de id_wide visit
		save demalaria, replace 

	use malariatemp, clear
		keep if visit == "f" & malariabloodsmear==1
		save visit_f_malaria, replace
		merge 1:1 id_wide using visit_e_malaria
		keep if _merge==3
		rename _merge malariapos_ef
		keep malariapos_ef id_wide visit
		save efmalaria, replace

	use malariatemp, clear
		keep if visit == "g" & malariabloodsmear==1
		save visit_g_malaria, replace
		merge 1:1 id_wide using visit_f_malaria
		keep if _merge==3
		rename _merge malariapos_fg
		keep malariapos_fg id_wide visit
		save fgmalaria, replace

	use malariatemp, clear
		keep if visit == "h" & malariabloodsmear==1
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
		egen repeatoffender =rowtotal(malariapos_gh malariapos_fg malariapos_ef malariapos_de malariapos_cd malariapos_bc malariapos_ab)
	bysort city: sum repeatoffender if repeatoffender >1 


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
sum `var'  malariabloodsmear if  malariabloodsmear==1 
sum `var'  malariabloodsmear if  malariabloodsmear==1 
}


foreach var in gender hospitalsite age species city { 
tab `var'  malariabloodsmear if  malariabloodsmear ==1, m
}
*repeat offenders
foreach var in interviewdate age{
sum `var'  malariabloodsmear if  malariabloodsmear==1 & repeatoffender >1
sum `var'  malariabloodsmear if  malariabloodsmear==1 & repeatoffender >1
}

foreach var in gender hospitalsite age species city { 
tab `var'  malariabloodsmear if  malariabloodsmear ==1 & repeatoffender >1, m
}

tab repeatoffender malariabloodsmear
order malaria* species city gender hospitalsite interviewdate* age* repeatoffender 
save mergedjan42016, replace

*outsheet using " mergedjan42017.csv", comma names replace

***merge with lab malaria data
replace studyid = studyid_copy if studyid =="" & studyid_copy !=""
replace studyid = studyid1 if studyid =="" & studyid1 !=""
replace studyid = studyid2 if studyid =="" & studyid2 !=""
replace studyid = studyid_ if studyid =="" & studyid_ !=""
replace studyid = duplicateid_a if studyid =="" & duplicateid_a !=""
replace studyid = followupid if studyid =="" & followupid!=""	

merge 1:1 id_wide visit using "C:\Users\amykr\Google Drive\labeaud\malaria prelim data dec 29 2016\malaria"

rename pos_neg malariapos_neg
rename pos_neg1 malariapos_neg1

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
drop _merge
tostring houseid , replace
save malariadenguemerged, replace

*****************merge with gis points
use xy, clear
merge 1:m villageid houseid using malariadenguemerged
drop if _merge ==1

replace city = "Chulaimbo" if city =="c"
replace city = "Kisumu" if city =="u"
replace city = "Ukunda" if city =="k"

*check with david to make sure this is true...
replace malariaresults=bsresults if malariaresults==.
drop bsresults 
save denvchikvmalariagps, replace
outsheet using "denvchikvmalariagps.csv", comma names replace
