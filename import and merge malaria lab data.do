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
save Ukunda, replace

insheet using "AICA Msambweni Malaria Data2016.csv", comma name clear
ds, has(type string) 
foreach v of varlist `r(varlist)' { 
	replace `v' = lower(`v') 
}
dropmiss, force
destring studyid2 countul2, replace force
save Msambweni, replace

insheet using "Malaria Parasitemia Data.csv", comma name clear
ds, has(type string) 
foreach v of varlist `r(varlist)' { 
	replace `v' = lower(`v') 
}
dropmiss, force
save Parasitemia, replace

insheet using "West HCC_Malaria Parasitemia Data_07oct2016.csv", comma name clear
ds, has(type string) 
foreach v of varlist `r(varlist)' { 
	replace `v' = lower(`v') 
}
dropmiss, force
save west, replace

append using "Parasitemia" "Ukunda" "Msambweni"

encode gender, gen(sex)
drop gender
rename sex gender
rename studyid2 childid


*take visit out of id
replace clientno = subinstr(clientno," ","",1) 
replace studyid = studyid1 if studyid =="" & studyid1 !=""
replace studyid =  clientno if studyid =="" & clientno !=""

 
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
isid id_wide visit_int
drop visit 
rename visit_int visit
	
	
foreach var in today dob{
gen `var'1 = date(`var', "MDY" ,2050)
format %td `var'1 
drop `var'
rename `var'1 `var'
recast int `var'
}


	save malaria, replace
