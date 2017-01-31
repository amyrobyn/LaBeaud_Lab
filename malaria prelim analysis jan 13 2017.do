/**************************************************************
 *amy krystosik                  							  *
 *malaria, eliza, and pcr merged results											  *
 *lebeaud lab               				        		  *
 *last updated Jan 26, 2017  							  *
 **************************************************************/ 
capture log close 
log using "R01_nov2_16.smcl", text replace 
set scrollbufsize 100000
set more 1
cd "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\CSVs nov29_16"
use all_interviews, clear
*merge with elisa data
merge 1:1 id_wide visit using "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\elisas\jan 19 2017\elisas.dta"
rename _merge interview_elisa_match
drop if rdtresults ==. & chikvigg_ =="" & denvigg_ =="" & stanforddenvigg ==""  & stanfordchikvigg =="" & interview_elisa_match ==1|interview_elisa_match ==2
*add in the pcr data from box and from googledoc. 
merge 1:1 id_wide visit using "C:\Users\amykr\Box Sync\Amy Krystosik's Files\david coinfectin paper\allpcr"
		replace denvpcrresults_dum = 1 if denvpcrresults_dum>0&denvpcrresults_dum<1
		save elisas_PCR_RDT, replace	
		rename _merge interview_elisa_pcr_match

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

	
foreach var in igg_kenya_chikv igg_kenya_denv {
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
destring adbtenderness, replace
dropmiss, force obs
dropmiss, force
capture drop coliandmequal 

	foreach var in datesamplecollected_ {
		capture gen `var'1 = date(`var', "DMY" ,2050)
		capture format %td `var'1 
		capture drop `var'
		capture rename `var'1 `var'
		capture recast int `var'
	}

	
save malariatemp, replace

*malaria repeat offenders by bloodsmear


use malariatemp, clear
keep if visit == "a" & malariapositive_dum >0 & malariapositive_dum <.
tostring adbtenderness, replace
dropmiss, force obs
dropmiss, force
capture drop coliandmequal 
capture drop coloandjequal
save visit_a_malaria, replace
		
use malariatemp, clear
keep if visit == "b" & malariapositive_dum >0 & malariapositive_dum <.
tostring adbtenderness, replace
dropmiss, force obs
dropmiss, force
capture drop coliandmequal 
capture drop coloandjequal
save visit_b_malaria, replace
		
use malariatemp, clear
keep if visit == "c" & malariapositive_dum >0 & malariapositive_dum <.
tostring adbtenderness, replace
dropmiss, force obs
dropmiss, force
capture drop coliandmequal 
capture drop coloandjequal
save visit_c_malaria, replace
		
use malariatemp, clear
keep if visit == "d" & malariapositive_dum >0 & malariapositive_dum <.
tostring adbtenderness, replace
dropmiss, force obs
dropmiss, force
capture drop coliandmequal 
capture drop coloandjequal
save visit_d_malaria, replace

use malariatemp, clear
keep if visit == "e" & malariapositive_dum >0 & malariapositive_dum <.
tostring adbtenderness, replace
dropmiss, force obs
dropmiss, force
capture drop coliandmequal 
capture drop coloandjequal
save visit_e_malaria, replace

foreach dataset in visit_a_malaria visit_b_malaria visit_c_malaria visit_d_malaria visit_e_malaria {
use "`dataset'", clear
desc id_childnumber
display "`dataset'"
}

append using visit_a_malaria visit_b_malaria visit_c_malaria visit_d_malaria visit_e_malaria 

collapse (sum) malariapositive_dum, by (id_wide)
rename malariapositive_dum numbermalariainfections
save repeatoffender, replace

use malariatemp, clear
keep if malariapositive_dum >0 & malariapositive_dum<. 
egen min = min(visit_int), by(id_wide) 
keep id_wide min visit* 
save minvisit, replace

merge m:1 id_wide using repeatoffender
replace numbermalariainfections = . if min!=visit_int
drop _merge
save repeatoffender, replace

bysort  id_wide visit_int : gen dup = _n
drop if dup >1

merge m:m id_wide visit_int using malariatemp
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
		preserve 
		keep if _merge==3
		rename _merge malariapos_ab
		keep malariapos_ab id_wide visit
		save abmalaria , replace
		restore		
		keep if _merge==2
		rename _merge anobmalaria
		save anobmalaria, replace
		
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
foreach dataset in ghmalaria fgmalaria efmalaria demalaria cdmalaria bcmalaria abmalaria anobmalaria{
		merge 1:1 id_wide visit using "`dataset'"
		capture drop _merge
		save merged, replace
		}
		foreach var in  malariapos_gh malariapos_fg malariapos_ef malariapos_de malariapos_cd malariapos_bc malariapos_ab{
		replace `var' = 1 if `var' >1 & `var'<.
		}

		egen consecutivemalariapos=rowtotal(malariapos_gh malariapos_fg malariapos_ef malariapos_de malariapos_cd malariapos_bc malariapos_ab)
		tab city consecutivemalariapos


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
replace villageid = "1" if villageid =="r"

replace villageid = "2" if villageid =="k"

replace villageid = "?" if villageid =="u"

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

rename *, lower
save malariadenguemerged, replace
 
*****************merge with gis points

use xy, clear
replace gps_house_latitude = y if gps_house_latitude==.
replace gps_house_latitude = x if gps_house_longitude==.
keep if gps_house_latitude!=. & gps_house_longitude!=.

collapse (firstnm) gps_house_longitude  gps_house_latitude, by(site villageid houseid)
destring _all, replace
outsheet using "xy.csv", comma names replace
merge m:m site villageid houseid using malariadenguemerged
rename _merge housegps

replace city = "Chulaimbo" if city =="c"
replace city = "Kisumu" if city =="k"
replace city = "Ukunda" if city =="u"

*check with david to make sure this is true...
save denvchikvmalariagps, replace
*/

*clean symptoms
gen studyid_all =""
order studyid_all 
foreach id in studyid3 studyid_ {
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

foreach var in anobmalaria malariapos_ab malariapos_bc malariapos_cd malariapos_de malariapos_ef malariapos_fg malariapos_gh{
label var `var' ""
_strip_labels `var'
tab `var'
}
 
*ab positive
preserve
keep if numbermalariainfections >1
table1 , vars( cohort cat \ gender cat\ age conts\ city cat \  malariapositive conts\ consecutivemalariapos cat \ malariapastmedhist cat \stanford_chikv_igg cat\ stanford_denv_igg cat\  chikvpcrresults_dum cat\ denvpcrresults_dum cat\ species_cat cat season cat\ parasite_count conts\ hb conts \ hemoglobin cat \ bmi conts \  temperature conts \ heartrate conts\ diastolicbp conts\ systolicbp conts\ resprate  conts\ pulseoximetry conts\ outcomehospitalized cat\) saving("malariatable1_aic_hcc_multi-infections.xls", replace ) missing test 
restore


 *ab positive
preserve
keep if malariapos_ab ==1
table1 , vars( gender cat\ age conts\ city cat \  malariapositive conts\ consecutivemalariapos cat \ malariapastmedhist cat \stanford_chikv_igg cat\ stanford_denv_igg cat\  chikvpcrresults_dum cat\ denvpcrresults_dum cat\ species_cat cat season cat\ parasite_count conts\ hb conts \ hemoglobin cat \ bmi conts \  temperature conts \ heartrate conts\ diastolicbp conts\ systolicbp conts\ resprate  conts\ pulseoximetry conts\ outcomehospitalized cat\) saving("malariatable1_aic_hcc_abpos.xls", replace ) missing test 
restore

*a no b pos
preserve
keep if anobmalaria==2
table1 , vars( gender cat\ age conts\ city cat \  malariapositive conts\ consecutivemalariapos cat \ malariapastmedhist cat \stanford_chikv_igg cat\ stanford_denv_igg cat\  chikvpcrresults_dum cat\ denvpcrresults_dum cat\ species_cat cat season cat\ parasite_count conts\ hb conts \ hemoglobin cat \ bmi conts \  temperature conts \ heartrate conts\ diastolicbp conts\ systolicbp conts\ resprate  conts\ pulseoximetry conts\ outcomehospitalized cat\) saving("malariatable1_aic_hcc_a_pos_b_neg.xls", replace ) missing test 
restore

*aic a visit
preserve
keep if cohort =="aic"
keep if visit =="a"
table1 , vars( gender cat\ age conts\ city cat \  malariapositive conts\ consecutivemalariapos cat \ malariapastmedhist cat \stanford_chikv_igg cat\ stanford_denv_igg cat\  chikvpcrresults_dum cat\ denvpcrresults_dum cat\ species_cat cat season cat\ parasite_count conts\ hb conts \ hemoglobin cat \ bmi conts \  temperature conts \ heartrate conts\ diastolicbp conts\ systolicbp conts\ resprate  conts\ pulseoximetry conts\ outcomehospitalized cat\) by(malariapositive_dum) saving("malariatable1_aic_a.xls", replace ) missing test 
restore

*hcc a visit
preserve
keep if cohort =="hcc"
keep if visit =="a"
table1 , vars( gender cat\ age conts\ city cat \  malariapositive conts\ numbermalariainfections cat \ consecutivemalariapos cat \ malariapastmedhist cat \ stanford_chikv_igg cat\ stanford_denv_igg cat\ chikvpcrresults_dum cat\ denvpcrresults_dum cat\ species_cat cat season cat\ parasite_count conts \ bmi conts \ tempover38 cat \ ) by(malariapositive_dum) saving("malariatable1_hcc_a.xls", replace ) missing test 
restore

save denvchikvmalariagps, replace
outsheet using " melisa_malriajan2017.csv", comma names replace
order housegps gps_house_latitude gps_house_longitude
encode childvillage, gen(childvillage_int)
drop childvillage
outsheet using "gps jan 26.csv", comma replace
