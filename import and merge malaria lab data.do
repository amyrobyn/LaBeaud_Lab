/**************************************************************
 *amy krystosik                  							  *
 *malaria data import and clean*
 *lebeaud lab               				        		  *
 *last updated feb2, 2017  							  		  *
 **************************************************************/ 

log using "malaria  data.smcl", text replace 
capture log close 
set scrollbufsize 100000
set more 1

cd "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\malaria prelim data dec 29 2016"

import excel "C:\Users\amykr\Box Sync\DENV CHIKV project\Lab Data\Malaria Database\Malaria Latest\coast\AIC Ukunda malaria data April 2016.xls", sheet("Ukunda") firstrow clear
		gen dataset = "AIC Ukunda malaria data April 2016"
		rename *, lower
		ds, has(type string) 
		foreach v of varlist `r(varlist)' { 
			replace `v' = lower(`v') 
		}
		foreach var in date{
			capture gen `var'1 = date(`var', "MDY" ,2050)
			capture  format %td `var'1 
			capture drop `var'
			capture rename `var'1 `var'
			capture recast int `var'
		}

			foreach var in today date{
				capture gen `var'1 = date(`var', "DMY" ,2050)
				capture format %td `var'1 
				capture drop `var'
				capture rename `var'1 `var'
				capture recast int `var'
			}


		dropmiss, force
		drop if studyid1 =="ufa0675"
		replace spp1= subinstr(spp1, "/", "_",.)
		reshape wide  countul1, j(spp1) i(studyid1) string
		reshape wide  countul2, j(spp2) i(studyid1) string

		*replace countul1ni= subinstr(countul1ni, ",", "",.)
		*replace countul1none = subinstr(countul1none , ",", "",.)
		destring _all, replace
		egen pf200 = rowtotal(countul1pf countul2pf)
		egen pm200 = rowtotal(countul1pm )
		egen po200 = rowtotal(countul1po )
		*egen pv200 = rowtotal(countul1pv countul2pv)
		egen ni200 = rowtotal(countul1ni countul2ni)
		egen none200 = rowtotal(countul1none countul2none)
		drop countul*
		capture tostring studyid2, replace
		drop studyid2
		rename studyid1 studyid
save Ukunda, replace

import excel "C:\Users\amykr\Box Sync\DENV CHIKV project\Lab Data\Malaria Database\Malaria Latest\coast\AICA Msambweni Malaria Data2016.xls", sheet("Msambweni data") firstrow clear
		gen dataset = "AICA Msambweni Malaria Data2016"
		rename *, lower
		ds, has(type string) 
		foreach v of varlist `r(varlist)' { 
			replace `v' = lower(`v') 
		}
		dropmiss, force

		replace spp1= subinstr(spp1, "/", "_",.)
		drop if studyid1 =="mfa0557"|studyid1 =="mfa0662"|studyid1 == "mfa0681"|studyid1 == "mfa0897"

		reshape wide  countul1, j(spp1) i(studyid1) string
		replace spp2= subinstr(spp2, "/", "_",.)
		reshape wide  countul2, j(spp2) i(studyid1) string

		*replace countul1ni= subinstr(countul1ni, ",", "",.)
		*replace countul1none = subinstr(countul1none , ",", "",.)
*		replace countul1pf = subinstr(countul1pf  , ",", "",.)
*		replace countul2pf = subinstr(countul2pf  , ",", "",.)
*		replace countul1po = subinstr(countul1po , ",", "",.)

		destring _all, replace
		egen pf200 = rowtotal(countul1pf countul2pf)
		egen pm200 = rowtotal(countul1pm countul2pm)
		egen po200 = rowtotal(countul1po )
		*egen pv200 = rowtotal(countul1pv countul2pv)
		egen ni200 = rowtotal(countul1ni countul2ni)
		egen none200 = rowtotal(countul1none countul2none)
		drop countul*

		capture tostring studyid2, replace

		foreach var in date{
			capture gen `var'1 = date(`var', "MDY" ,2050)
			capture  format %td `var'1 
			capture drop `var'
			capture rename `var'1 `var'
			capture recast int `var'
		}
			foreach var in today date{
				capture gen `var'1 = date(`var', "DMY" ,2050)
				capture format %td `var'1 
				capture drop `var'
				capture rename `var'1 `var'
				capture recast int `var'
			}
			
					drop studyid2
		rename studyid1 studyid

save Msambweni, replace

foreach dataset in "Obama" "Chulaimbo-Mbaka_Oromo"{
		import excel "C:\Users\amykr\Box Sync\DENV CHIKV project\Lab Data\Malaria Database\Malaria Latest\west\West AIC Malaria Parasitemia Data.xls", sheet(`dataset') firstrow clear
		gen dataset ="`dataset'"

		rename *, lower
		capture rename clientno studyid
		capture rename childid studyid
		ds, has(type string) 
		foreach v of varlist `r(varlist)' { 
			replace `v' = lower(`v') 
		}

		capture replace pf200= subinstr(pf200, ",", "",.)

		foreach var in date{
			capture gen `var'1 = date(`var', "MDY" ,2050)
			capture  format %td `var'1 
			capture drop `var'
			capture rename `var'1 `var'
			capture recast int `var'
		}

			foreach var in today date{
				capture gen `var'1 = date(`var', "DMY" ,2050)
				capture format %td `var'1 
				capture drop `var'
				capture rename `var'1 `var'
				capture recast int `var'
			}

		destring _all, replace
		ds, has(type string) 
		foreach v of varlist `r(varlist)' { 
			replace `v' = lower(`v') 
		}
		dropmiss, force
		dropmiss, force obs

		capture tostring studyid2, replace

save "`dataset'", replace
}

foreach dataset in "Initial" "1stFU" "2ndFU" "3rdFU"{
		import excel "C:\Users\amykr\Box Sync\DENV CHIKV project\Lab Data\Malaria Database\Malaria Latest\west\West HCC_Malaria Parasitemia Data_07oct2016.xlsx", sheet(`dataset') firstrow clear
		gen dataset ="`dataset'"

		rename *, lower
		destring _all, replace
		ds, has(type string) 
		foreach v of varlist `r(varlist)' { 
				replace `v' = lower(`v') 
			}
		dropmiss, force
		dropmiss, force obs
		
		foreach var in today date{
			capture gen `var'1 = date(`var', "DMY" ,2050)
			capture format %td `var'1 
			capture drop `var'
			capture rename `var'1 `var'
			capture recast int `var'
		}
		foreach var in today date{
			capture gen `var'1 = date(`var', "MDY" ,2050)
			capture format %td `var'1 
			capture drop `var'
			capture rename `var'1 `var'
			capture recast int `var'
		}

save `dataset', replace
}
 

append using "Ukunda" "Msambweni" "1stFU" "2ndFU" "Initial" , gen(append)

encode gender, gen(sex)
drop gender
rename sex gender



*take visit out of id
replace studyid = subinstr(studyid, "/", "",.)
replace studyid = subinstr(studyid, " ", "",.)
replace studyid = subinstr(studyid, "--", "",.)
replace studyid = subinstr(studyid, "*", "",.)

 
						forval i = 1/3 { 
							gen id`i' = substr(studyid, `i', 1) 
						}
*gen id_wid without visit						 
	rename id1 city  
	rename id2 id_cohort 
	rename id3 visit
	tab visit
	
	gen id_childnumber = ""
	replace id_childnumber= substr(studyid, +4, .)

gen byte notnumeric = real(id_childnumber)==.	/*makes indicator for obs w/o numeric values*/
tab notnumeric	/*==1 where nonnumeric characters*/
list id_childnumber if notnumeric==1	/*will show which have nonnumeric*/

gen suffix = "" 
	replace suffix = "a" if strpos(id_childnumber, "a")
	replace id_childnumber = subinstr(id_childnumber, "a","", .)

	replace suffix = "b" if strpos(id_childnumber, "b")
	replace id_childnumber = subinstr(id_childnumber, "b","", .)

destring id_childnumber, replace 	

	order id_cohort city visit id_childnumber studyid
	egen id_wide = concat(city id_cohort id_childnum suffix)
drop suffix

	
	gen visit_int = . 
	replace visit_int = 1 if visit =="a"
	replace visit_int = 2 if visit =="b"
	replace visit_int = 3 if visit =="c"
	replace visit_int = 4 if visit =="d"
	replace visit_int = 5 if visit =="e"
	replace visit_int = 6 if visit =="f"
	replace visit_int = 7 if visit =="g"

	bysort id_wide visit_int: gen dup = _n
	drop if dup >1
	drop if id_wide ==""
	drop if visit_int==.
	
	isid id_wide visit_int

foreach var in dob{
gen `var'1 = date(`var', "MDY" ,2050)
format %td `var'1 
drop `var'
rename `var'1 `var'
recast int `var'
}

	foreach var in today date{
		capture gen `var'1 = date(`var', "DMY" ,2050)
		capture format %td `var'1 
		capture drop `var'
		capture rename `var'1 `var'
		capture recast int `var'
	}

order *200
egen malariapositive = rowtotal( pf200 - none200)
gen  malariapositive_dum = .
replace malariapositive_dum = 0 if malariapositive==0
replace malariapositive_dum  = 1 if malariapositive >0 & malariapositive <. 

gen species_cat = "" 
replace species_cat = "pf" if pf200 >0 & pf200 <.
replace species_cat = "pm" if pm200  >0 & pm200 <.
replace species_cat = "po" if po200 >0 & po200 <.
replace species_cat = "pv" if pv200 >0 & pv200 <.
replace species_cat = "ni" if ni200 >0 & ni200 <.
replace species_cat = "none" if none200 >0 & none200 <.

order pf200 pm200 po200 pv200 ni200 none200 
egen parasite_count= rowtotal(pf200 pm200 po200 pv200 ni200 none200 ) 

replace id_cohort = "f" if id_cohort =="m"
replace id_wide= subinstr(id_wide, "/", "",.)

replace studyid= subinstr(studyid, "/", "",.)
replace studyid= subinstr(studyid, " ", "",.)

replace studyid = subinstr(studyid, "/", "",.)
replace studyid = subinstr(studyid, " ", "",.)
replace studyid = subinstr(studyid, "--", "",.)
replace studyid = subinstr(studyid, "*", "",.)
replace studyid = subinstr(studyid, "-", "",.)

drop if studyid =="" & id_wide ==""
drop id_childnumber
save malaria, replace
