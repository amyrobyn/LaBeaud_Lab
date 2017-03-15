capture log close 
set more 1
set scrollbufsize 100000

cd "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\desiree- abstract1"
local outcome "stanforddenvigg"
local data "data"

use `data', clear
capture drop _merge
drop visit_int
encode visit, gen(visit_int)
drop dup
bysort  id_wide visit_int : gen dup = _n
drop if dup >1
save `data', replace
save `outcome'temp, replace

*`outcome' repeat offenders by bloodsmear
use `data', clear
keep if visit == "a" & `outcome'>0 & `outcome'<.
tostring adbtenderness, replace
dropmiss, force obs
dropmiss, force
save visit_a_`outcome', replace
		
use `data', clear
keep if visit == "b" & `outcome' >0 & `outcome' <.
tostring adbtenderness, replace
dropmiss, force obs
dropmiss, force
capture drop coliandmequal 
capture drop coloandjequal
save visit_b_`outcome', replace
		
use `data', clear
keep if visit == "c" & `outcome' >0 & `outcome' <.
tostring adbtenderness, replace
dropmiss, force obs
dropmiss, force
capture drop coliandmequal 
capture drop coloandjequal
save visit_c_`outcome', replace
	
append using visit_a_`outcome' visit_b_`outcome' visit_c_`outcome'  visit_d_`outcome' visit_e_`outcome' 

collapse (sum) `outcome', by (id_wide)
rename `outcome' number`outcome'
save repeatoffender, replace

use `data', clear
keep if `outcome' >0 & `outcome'<. 
egen min2 = min(visit_int), by(id_wide) 
keep id_wide min visit* 
save minvisit, replace

merge m:1 id_wide using repeatoffender
replace number`outcome' = . if min!=visit_int
drop _merge
save repeatoffender, replace

merge m:m id_wide visit_int using `outcome'temp
drop _merge
save `outcome'temp, replace

** add in the consecutive `outcome'pos again
use `data', clear
		keep if visit_int == 1 & `outcome' >0 & `outcome' <.
		save visit_a_`outcome', replace

	use `data', clear
	tab visit `outcome'
		keep if visit_int == 2 & `outcome' >0 & `outcome' <.
	tab visit `outcome'
	save visit_b_`outcome', replace
	
		
		merge 1:1 id_wide using visit_a_`outcome'
		preserve 
		keep if _merge==3
		rename _merge `outcome'pos_ab
		keep `outcome'pos_ab id_wide visit_int
		save ab`outcome' , replace
		restore		
		keep if _merge==2
		rename _merge anob`outcome'
		save anob`outcome', replace
		
	use `data', clear
		keep if visit_int == 3 & `outcome' >0 & `outcome' <.
		save visit_c_`outcome', replace
		merge 1:1 id_wide using visit_b_`outcome'
		keep if _merge==3
		rename _merge `outcome'pos_bc
		keep `outcome'pos_bc id_wide visit_int
		save bc`outcome', replace
	
	use `data', clear
		keep if visit_int == 4 & `outcome' >0 & `outcome' <. 
		save visit_d_`outcome', replace
		merge 1:1 id_wide using visit_c_`outcome'
		keep if _merge==3
		rename _merge `outcome'pos_cd
		keep `outcome'pos_cd id_wide visit_int
		save cd`outcome', replace
	
	use `data', clear
		keep if visit_int == 5 & `outcome' >0 & `outcome' <.
		save visit_e_`outcome', replace
		merge 1:1 id_wide using visit_d_`outcome'
		keep if _merge==3
		rename _merge `outcome'pos_de
		keep `outcome'pos_de id_wide visit_int
		save de`outcome', replace 

	use `data', clear
		keep if visit_int == 6 & `outcome' >0 & `outcome' <.
		save visit_f_`outcome', replace
		merge 1:1 id_wide using visit_e_`outcome'
		keep if _merge==3
		rename _merge `outcome'pos_ef
		keep `outcome'pos_ef id_wide visit_int
		save ef`outcome', replace

	use `data', clear
		keep if visit_int == 7 & `outcome' >0 & `outcome' <.
		save visit_g_`outcome', replace
		merge 1:1 id_wide using visit_f_`outcome'
		keep if _merge==3
		rename _merge `outcome'pos_fg
		keep `outcome'pos_fg id_wide visit_int
		save fg`outcome', replace

	use `data', clear
		keep if visit_int == 8 & `outcome' >0 & `outcome' <.
		save visit_h_`outcome', replace
		merge 1:1 id_wide using visit_h_`outcome'
		keep if _merge==3
		rename _merge `outcome'pos_gh
		keep `outcome'pos_gh id_wide visit_int
		save gh`outcome', replace

use `data', clear
foreach dataset in gh`outcome' fg`outcome' ef`outcome' de`outcome' cd`outcome' bc`outcome' ab`outcome' anob`outcome'{
		merge 1:1 id_wide visit_int using "`dataset'"
		capture drop _merge
		save merged, replace
		}
		foreach var in  `outcome'pos_gh `outcome'pos_fg `outcome'pos_ef `outcome'pos_de `outcome'pos_cd `outcome'pos_bc `outcome'pos_ab{
		replace `var' = 1 if `var' >1 & `var'<.
		}

		egen consecutive`outcome'pos=rowtotal(`outcome'pos_gh `outcome'pos_fg `outcome'pos_ef `outcome'pos_de `outcome'pos_cd `outcome'pos_bc `outcome'pos_ab)
		tab city consecutive`outcome'pos


*repeat offenders
save merged, replace


foreach var in anob`outcome' `outcome'pos_ab `outcome'pos_bc `outcome'pos_cd `outcome'pos_de `outcome'pos_ef `outcome'pos_fg `outcome'pos_gh{
label var `var' ""
_strip_labels `var'
tab `var'
}


rename heart_rate heartrate 
 *ab positive 
preserve
keep if number`outcome' >1
table1 , vars( cohort cat \ gender cat\ age conts\ city cat \ consecutive`outcome'pos cat \stanfordchikvigg_ cat\ stanforddenvigg_ cat\  chikvpcrresults_dum cat\ denvpcrresults_dum cat\ species_cat cat season cat\ parasite_count conts\ hb conts \ hemoglobin cat \  temperature conts \ heartrate conts\ diastolicbp conts\ systolicbp conts\ resprate  conts\ pulseoximetry conts\ outcomehospitalized cat\ zbmi contn\) saving("table1_aic_hcc_multi-infections_`outcome'.xls", replace ) missing test 
restore


*ab positive
preserve
keep if `outcome'pos_ab ==1
table1 , vars( gender cat\ age conts\ city cat \ consecutive`outcome'pos cat \ `outcome'pastmedhist cat \stanfordchikvigg_ cat\ stanforddenvigg_ cat\  chikvpcrresults_dum cat\ denvpcrresults_dum cat\ species_cat cat season cat\ parasite_count conts\ hb conts \ hemoglobin cat \ zbmi conts \  temperature conts \ heartrate conts\ diastolicbp conts\ systolicbp conts\ resprate  conts\ pulseoximetry conts\ outcomehospitalized cat\) saving("table1_aic_hcc_abpos_`outcome'.xls", replace ) missing test 
restore

*a no b pos
preserve
keep if anob`outcome'==2
table1 , vars( gender cat\ age conts\ city cat \  consecutive`outcome'pos cat \ `outcome'pastmedhist cat \stanfordchikvigg_ cat\ stanforddenvigg_ cat\  chikvpcrresults_dum cat\ denvpcrresults_dum cat\ species_cat cat season cat\ parasite_count conts\ hb conts \ hemoglobin cat \ zbmi conts \  temperature conts \ heartrate conts\ diastolicbp conts\ systolicbp conts\ resprate  conts\ pulseoximetry conts\ outcomehospitalized cat\) saving("table1_aic_hcc_a_pos_b_neg_`outcome'.xls", replace ) missing test 
restore

*aic a visit
preserve
egen `outcome'positive_dum_city = concat(`outcome'positive_dum city)
keep if cohort =="aic"
keep if visit =="a"
table1 , vars( gender cat\ age conts\ city cat \  consecutive`outcome'pos cat \ `outcome'pastmedhist cat \stanfordchikvigg_ cat\ stanforddenvigg_ cat\    chikvpcrresults_dum cat\ denvpcrresults_dum cat\ species_cat cat season cat\ parasite_count conts\ hb conts \ hemoglobin cat \ zbmi conts \  temperature conts \ heartrate conts\ diastolicbp conts\ systolicbp conts\ resprate  conts\ pulseoximetry conts\ outcomehospitalized cat\) by(`outcome'positive_dum) saving("table1_aic_a_`outcome'.xls", replace ) missing test 
table1 , vars( gender cat\ age conts\ consecutive`outcome'pos cat \ `outcome'pastmedhist cat \stanfordchikvigg_ cat\ stanforddenvigg_ cat\    chikvpcrresults_dum cat\ denvpcrresults_dum cat\ species_cat cat season cat\ parasite_count conts\ hb conts \ hemoglobin cat \ zbmi conts \  temperature conts \ heartrate conts\ diastolicbp conts\ systolicbp conts\ resprate  conts\ pulseoximetry conts\ outcomehospitalized cat\) by(`outcome'positive_dum_city ) saving("table1_aic_a_`outcome'_bycity.xls", replace ) missing test 
restore

*hcc a visit
preserve
keep if cohort =="hcc"
keep if visit =="a"
table1 , vars( gender cat\ age conts\ city cat \  number`outcome' cat \ consecutive`outcome'pos cat \ `outcome'pastmedhist cat \ stanfordchikvigg_ cat\ stanforddenvigg_ cat\   chikvpcrresults_dum cat\ denvpcrresults_dum cat\ species_cat cat season cat\ parasite_count conts \ zbmi conts \ tempover38 cat \ ) by(`outcome'positive_dum) saving("table1_hcc_a_`outcome'.xls", replace ) missing test 
restore

save denvchikv`outcome'gps, replace
outsheet using " melisa_malriajan2017.csv", comma names replace
order housegps gps_house_latitude gps_house_longitude
encode childvillage, gen(childvillage_int)
drop childvillage
outsheet using "gps jan 26.csv", comma replace
