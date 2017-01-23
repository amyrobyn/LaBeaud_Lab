capture log close 
set scrollbufsize 100000
set more 1

log using "malaria  data.smcl", text replace 
set scrollbufsize 100000
set more 1

cd "C:\Users\amykr\Box Sync\Amy Krystosik's Files\malaria prelim data dec 29 2016"

insheet using "AIC Ukunda malaria data April 2016.csv", comma name clear
gen dataset = "AIC Ukunda malaria data April 2016"
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

rename *, lower
ds, has(type string) 
foreach v of varlist `r(varlist)' { 
	replace `v' = lower(`v') 
}
dropmiss, force
drop if studyid1 =="ufa0675"
replace spp1= subinstr(spp1, "/", "_",.)
reshape wide  countul1, j(spp1) i(studyid1) string
reshape wide  countul2, j(spp2) i(studyid1) string

replace countul1ni= subinstr(countul1ni, ",", "",.)
replace countul1none = subinstr(countul1none , ",", "",.)
destring _all, replace
egen pf200 = rowtotal(countul1pf countul2pf)
egen pm200 = rowtotal(countul1pm )
egen po200 = rowtotal(countul1po )
*egen pv200 = rowtotal(countul1pv countul2pv)
egen ni200 = rowtotal(countul1ni countul2ni)
egen none200 = rowtotal(countul1none countul2none)
drop countul*
capture tostring studyid2, replace
save Ukunda, replace

insheet using "AICA Msambweni Malaria Data2016.csv", comma name clear
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

replace countul1ni= subinstr(countul1ni, ",", "",.)
replace countul1none = subinstr(countul1none , ",", "",.)
replace countul1pf = subinstr(countul1pf  , ",", "",.)
replace countul2pf = subinstr(countul2pf  , ",", "",.)
replace countul1po = subinstr(countul1po , ",", "",.)

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
save Msambweni, replace

foreach dataset in "AIC CHULAIMBO MALARIA" "AIC OBAMA MALARIA" "Mbaka Oromo" "HCC Kisumu" "HCC Chulaimbo"{
import excel "C:\Users\amykr\Box Sync\Amy Krystosik's Files\malaria prelim data dec 29 2016\Malaria Parasitemia Data.xls", sheet(`dataset') firstrow clear
gen dataset ="`dataset'"
rename *, lower

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

capture tostring studyid2, replace

save "`dataset'", replace
}

foreach dataset in "Initial" "1stFU" "2ndFU" "3rdFU"{
	import excel "West HCC_Malaria Parasitemia Data_07oct2016.xlsx", sheet(`dataset') firstrow clear
	gen dataset ="`dataset'"
	rename *, lower
	destring _all, replace
	ds, has(type string) 

	foreach v of varlist `r(varlist)' { 
			replace `v' = lower(`v') 
		}
	dropmiss, force
	
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



append using "Parasitemia" "Ukunda" "Msambweni" "AIC CHULAIMBO MALARIA" "AIC OBAMA MALARIA" "Mbaka Oromo" "HCC Kisumu" "HCC Chulaimbo" "westinitial" "1st_FU" "2nd_FU", gen(append)

encode gender, gen(sex)
drop gender
rename sex gender



*take visit out of id
replace clientno = subinstr(clientno," ","",1) 
replace studyid = studyid1 if studyid =="" & studyid1 !=""
replace studyid =  clientno if studyid =="" & clientno !=""
replace studyid =   childid if studyid =="" & childid !=""
replace studyid =  clientno if studyid =="" & clientno !=""
replace studyid = subinstr(studyid, "/", "",.)

 
 
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
	order id_cohort city visit id_childnumber studyid
	egen id_wide = concat(city id_cohort id_childnumber)

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

gen studyid_all =""
order studyid_all 
foreach id in studyid StudyID studyid1 studyid2{
	replace studyid_all= `id' if studyid_all ==""
	drop `id'
}
rename studyid_all studyid

replace studyid= subinstr(id_wide, "/", "",.)
replace studyid= subinstr(id_wide, " ", "",.)

foreach studyid in cfa00161 kfa00242 kfa00247 kfa00248 kfa00261 kfa00275 kfa00298 cfa00303 cfc00305 kfa00291 cfa00325 cfc00272 cfa00119 cfa00169 cfa00342 cfa00151 cfa00187 cfa00275 cfa00296 cfa00006 cfa00201 cfa00241 cfa00247 kfa00189 kfa00204 kfa00337 cfa00196 cfa00205 cfa00211 cfa00246 cfa00248 cfa00256 cfa00257 cfa00265 cfa00273 cfa00313 cfa00340 rfa00496 cfa00193 cfa00200 cfa00210 cfa00236 cfa00243 cfa00268 cfa00271 cfa00300 cfa00348 cfa00385 kfa00185 kfa00202 kfa00342 cfa00010 kfa00009 rfa00460 cfa00326 cfa00362 cfa00364 rfa00475 cfa00349 cmba0408 rfa00462 cfa00135 cfa00245 cfa00383 kfa00217 kfa00277 kfc00184 rfa00469 {
list studyid malariapositive_dum if studyid =="`studyid'"
}


save malaria, replace
