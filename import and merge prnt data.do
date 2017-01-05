************************************add PRNT data**********************************
cd "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\CSVs nov29_16"

import excel "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\longitudinal_analysis_sept152016/LaBeaud RESULTS - july 2016.xls", sheet("2016 PRNT-Msambweni Results") cellrange(A2:E154) firstrow clear
tempfile PRNT_Msambweni 
save PRNT_Msambweni, replace
import excel "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\longitudinal_analysis_sept152016/LaBeaud RESULTS - july 2016.xls", sheet("2016 PRNT-Ukunda Results") cellrange(A2:F80) firstrow clear
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
			gen city  = id1 
			gen id_cohort = id2 
			gen visit = id3
			tab visit
			gen id_childnumber = ""
			replace id_childnumber = substr(ALIQUOTELISAID, +4, .)
			destring id_childnumber, replace
			gen str4 id_childnumber4 = string(id_childnumber,"%04.0f")
			
			order id_cohort city ALIQUOTELISAID id_childnumber4 
			
			egen id_wide = concat(city id_cohort id_childnumber4)
			
		*recode prnt values as pos(20+)/ neg
	foreach var of varlist _all{
		rename `var', lower
}
	foreach var of var _all{
		tostring `var', replace 
		replace `var'=lower(`var')
		rename `var', lower
		}	

	foreach var of var _all{
		tostring `var', replace 
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
use "PRNT_Msambweni" 
append using "PRNT_Ukunda"
save prnt.dta, replace
