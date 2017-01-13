capture log close 
set scrollbufsize 100000
set more 1

log using "malaria  data.smcl", text replace 
set scrollbufsize 100000
set more 1

cd "C:\Users\amykr\Google Drive\labeaud\malaria prelim data dec 29 2016"
insheet using "AIC Ukunda malaria data April 2016.csv", comma name clear
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

save Msambweni, replace

foreach dataset in "AIC CHULAIMBO MALARIA" "AIC OBAMA MALARIA" "Mbaka Oromo" "HCC Kisumu" "HCC Chulaimbo"{
import excel "C:\Users\amykr\Google Drive\labeaud\malaria prelim data dec 29 2016\Malaria Parasitemia Data.xls", sheet(`dataset') firstrow clear

ds, has(type string) 
foreach v of varlist `r(varlist)' { 
	replace `v' = lower(`v') 
}

capture replace pf200= subinstr(pf200, ",", "",.)

foreach var in Date{
capture gen `var'1 = date(`var', "MDY" ,2050)
capture  format %td `var'1 
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


insheet using "West HCC_Malaria Parasitemia Data_07oct2016.csv", comma name clear
destring _all, replace
ds, has(type string) 
foreach v of varlist `r(varlist)' { 
	replace `v' = lower(`v') 
}
dropmiss, force
save west, replace
append using "Parasitemia" "Ukunda" "Msambweni" "AIC CHULAIMBO MALARIA" "AIC OBAMA MALARIA" "Mbaka Oromo" "HCC Kisumu" "HCC Chulaimbo"

encode gender, gen(sex)
drop gender
rename sex gender



*take visit out of id
replace clientno = subinstr(clientno," ","",1) 
replace studyid = studyid1 if studyid =="" & studyid1 !=""
replace studyid =  clientno if studyid =="" & clientno !=""
replace studyid =   ChildID if studyid =="" & ChildID !=""
replace studyid =  ClientNo if studyid =="" & ClientNo !=""
 
 
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

foreach var in today dob{
gen `var'1 = date(`var', "MDY" ,2050)
format %td `var'1 
drop `var'
rename `var'1 `var'
recast int `var'
}
order *200
egen malariapositive = rowtotal( pf200 - none200)
gen  malariapositive_dum = .
replace malariapositive_dum = 0 if malariapositive==0
replace malariapositive_dum  = 1 if malariapositive >0 & malariapositive <. 

save malaria, replace
