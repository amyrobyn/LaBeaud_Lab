/**************************************************************
 *amy krystosik                  							  *
 *malaria, eliza, and pcr merged results					  *
 *lebeaud lab               				        		  *
 *last updated feb1, 2017  							  		  *
 **************************************************************/ 
capture log close 
log using "malaria_prelim_analysis.smcl", text replace 
set scrollbufsize 100000
set more 1
cd "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\malaria prelim data dec 29 2016"
use "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\interviewdata\all_interviews", clear
tab city, m
tab visit , m

*merge with elisa data
drop id_childnumber
merge 1:1 id_wide visit using "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\elisas\feb1 2017\elisas.dta"
tab city, m
tab visit , m

rename _merge interview_elisa_match
drop if rdtresults ==. & chikvigg_ =="" & denvigg_ =="" & stanforddenvigg ==""  & stanfordchikvigg =="" & interview_elisa_match ==1|interview_elisa_match ==2
*add in the pcr data from box and from googledoc. 
merge 1:1 id_wide visit using "C:\Users\amykr\Box Sync\Amy Krystosik's Files\david coinfectin paper\allpcr"
		replace denvpcrresults_dum = 1 if denvpcrresults_dum>0&denvpcrresults_dum<1
		save elisas_PCR_RDT, replace	
		rename _merge interview_elisa_pcr_match


***merge with lab malaria data
destring _all, replace
ds, has(type string) 
			foreach v of varlist `r(varlist)' { 
				replace `v' = lower(`v') 
			}

dropmiss, force

merge 1:1 id_wide visit using "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\malaria prelim data dec 29 2016\malaria"
order malaria*
destring _all, replace 
sum malaria* stanford*

*take visit out of id
									forval i = 1/3 { 

										gen id`i' = substr(studyid, `i', 1) if city ==""|cohort ==""
									}
			*gen id_wid without visit						 
				replace city  = id1 if city ==""
				replace cohort = id2 if cohort==""
				replace visit = id3 if visit ==""

				
replace city = "chulaimbo" if city =="r"
replace city = "chulaimbo" if city =="c"
replace city = "kisumu" if city =="k"
replace city = "ukunda" if city =="u"
replace city ="msambweni" if city =="m" 
replace city ="msambweni" if city ==" msambweni" 

bysort city: sum malaria* stanford*
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
order malaria* city gender hospitalsite interviewdate* age numbermalariainfections 
save mergedjan42016, replace

tab malariapositive_dum
save malariadenguemerged, replace

***
**create village and house id so we can merge with gis points
/*
gen villageid=""
replace villageid = substr(id_wide, +1, 1)
replace villageid = "1" if villageid =="c"
replace villageid = "1" if villageid =="r"

replace villageid = "2" if villageid =="k"

replace villageid = "4" if villageid =="u"

replace villageid = "3" if villageid =="g"
replace villageid = "4" if villageid =="l"
destring villageid, replace
*/

replace cohort = id_cohort if cohort ==""

gen houseid2 = ""
replace houseid2 = substr(id_wide, 3, . ) 
destring houseid2 , replace force 
tostring houseid2, replace
replace houseid2= reverse(houseid2)
replace houseid2 = substr(houseid2, 4, . ) 
replace houseid2= reverse(houseid2)
destring houseid2, replace 
list studyid id_wide houseid2  houseid  if houseid2 != houseid & houseid!=.
count if houseid2 != houseid & houseid!=.

order studyid houseid houseid2 city
destring houseid houseid2  city, replace 
replace houseid = houseid2 if houseid==. & houseid2!=.
order studyid houseid city
tab houseid, m

destring houseid, replace
gen houseidstring = string(houseid ,"%04.0f")
drop houseid houseid2
rename houseidstring  houseid
order houseid
destring houseid , replace force
rename gametocytes gametocytes3
rename parasitelevel parasitelevel2
rename studyid studyid3

rename *, lower
tab city
replace city ="msambweni" if city =="m" 
save malariadenguemerged, replace
 
*****************merge with gis points

use "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\demography\xy", clear
replace gps_house_latitude = y if gps_house_latitude==.
replace gps_house_latitude = x if gps_house_longitude==.

collapse (firstnm) gps_house_longitude  gps_house_latitude, by(city houseid)
destring _all, replace
outsheet using "xy.csv", comma names replace

merge m:m city houseid using "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\malaria prelim data dec 29 2016\malariadenguemerged"
rename _merge housegps
drop if housegps ==1
tab housegps cohort

replace city = "chulaimbo" if city =="c"
replace city = "kisumu" if city =="k"
replace city = "ukunda" if city =="u"

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
	


replace city = "chulaimbo" if studyid =="cca0430005"|studyid=="cca0723003"

replace id_cohort ="aic" if id_cohort =="f"
replace id_cohort ="aic" if id_cohort =="m"
replace id_cohort ="hcc" if id_cohort =="c"
drop cohort
rename id_cohort cohort


gen childweight_kg = childweight
gen childheight_meters =childheight/100
gen bmi =  childweight_kg /(childheight_meters^2) 

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
				
replace city = "chulaimbo" if city =="r"
replace city = "chulaimbo" if city =="c"
replace city = "kisumu" if city =="k"
replace city = "ukunda" if city =="w"
replace city = "ukunda" if city =="u"

replace cohort ="aic" if cohort =="f"
replace city ="chulaimbo" if city =="c"
replace city ="chulaimbo" if city =="r"
replace city ="msambweni" if city =="m" 



foreach var in anobmalaria malariapos_ab malariapos_bc malariapos_cd malariapos_de malariapos_ef malariapos_fg malariapos_gh{
label var `var' ""
_strip_labels `var'
tab `var'
}
 


replace gender = gender - 1 if dataset =="aica msambweni malaria data2016"
replace gender = gender - 1 if dataset =="aic ukunda malaria data april 2016"
tab dataset gender

 
replace city = "kisumu" if city =="k"

replace city =trim(city)

 *ab positive
 
preserve
keep if numbermalariainfections >1
table1 , vars( cohort cat \ gender cat\ age conts\ city cat \  malariapositive conts\ consecutivemalariapos cat \ malariapastmedhist cat \stanfordchikvigg_ cat\ stanforddenvigg_ cat\  chikvpcrresults_dum cat\ denvpcrresults_dum cat\ species_cat cat season cat\ parasite_count conts\ hb conts \ hemoglobin cat \ bmi conts \  temperature conts \ heartrate conts\ diastolicbp conts\ systolicbp conts\ resprate  conts\ pulseoximetry conts\ outcomehospitalized cat\) saving("table1_aic_hcc_multi-infections_malaria.xls", replace ) missing test 
restore


*ab positive
preserve
keep if malariapos_ab ==1
table1 , vars( gender cat\ age conts\ city cat \  malariapositive conts\ consecutivemalariapos cat \ malariapastmedhist cat \stanfordchikvigg_ cat\ stanforddenvigg_ cat\  chikvpcrresults_dum cat\ denvpcrresults_dum cat\ species_cat cat season cat\ parasite_count conts\ hb conts \ hemoglobin cat \ bmi conts \  temperature conts \ heartrate conts\ diastolicbp conts\ systolicbp conts\ resprate  conts\ pulseoximetry conts\ outcomehospitalized cat\) saving("table1_aic_hcc_abpos_malaria.xls", replace ) missing test 
restore

*a no b pos
preserve
keep if anobmalaria==2
table1 , vars( gender cat\ age conts\ city cat \  malariapositive conts\ consecutivemalariapos cat \ malariapastmedhist cat \stanfordchikvigg_ cat\ stanforddenvigg_ cat\  chikvpcrresults_dum cat\ denvpcrresults_dum cat\ species_cat cat season cat\ parasite_count conts\ hb conts \ hemoglobin cat \ bmi conts \  temperature conts \ heartrate conts\ diastolicbp conts\ systolicbp conts\ resprate  conts\ pulseoximetry conts\ outcomehospitalized cat\) saving("table1_aic_hcc_a_pos_b_neg_malaria.xls", replace ) missing test 
restore

*aic a visit
preserve
egen malariapositive_dum_city = concat(malariapositive_dum city)
keep if cohort =="aic"
keep if visit =="a"
table1 , vars( gender cat\ age conts\ city cat \  malariapositive conts\ consecutivemalariapos cat \ malariapastmedhist cat \stanfordchikvigg_ cat\ stanforddenvigg_ cat\    chikvpcrresults_dum cat\ denvpcrresults_dum cat\ species_cat cat season cat\ parasite_count conts\ hb conts \ hemoglobin cat \ bmi conts \  temperature conts \ heartrate conts\ diastolicbp conts\ systolicbp conts\ resprate  conts\ pulseoximetry conts\ outcomehospitalized cat\) by(malariapositive_dum) saving("table1_aic_a_malaria.xls", replace ) missing test 
table1 , vars( gender cat\ age conts\ malariapositive conts\ consecutivemalariapos cat \ malariapastmedhist cat \stanfordchikvigg_ cat\ stanforddenvigg_ cat\    chikvpcrresults_dum cat\ denvpcrresults_dum cat\ species_cat cat season cat\ parasite_count conts\ hb conts \ hemoglobin cat \ bmi conts \  temperature conts \ heartrate conts\ diastolicbp conts\ systolicbp conts\ resprate  conts\ pulseoximetry conts\ outcomehospitalized cat\) by(malariapositive_dum_city ) saving("table1_aic_a_malaria_bycity.xls", replace ) missing test 
restore

*hcc a visit
preserve
keep if cohort =="hcc"
keep if visit =="a"
table1 , vars( gender cat\ age conts\ city cat \  malariapositive conts\ numbermalariainfections cat \ consecutivemalariapos cat \ malariapastmedhist cat \ stanfordchikvigg_ cat\ stanforddenvigg_ cat\   chikvpcrresults_dum cat\ denvpcrresults_dum cat\ species_cat cat season cat\ parasite_count conts \ bmi conts \ tempover38 cat \ ) by(malariapositive_dum) saving("table1_hcc_a_malaria.xls", replace ) missing test 
restore

save denvchikvmalariagps, replace
outsheet using " melisa_malriajan2017.csv", comma names replace
order housegps gps_house_latitude gps_house_longitude
encode childvillage, gen(childvillage_int)
drop childvillage
outsheet using "gps jan 26.csv", comma replace
