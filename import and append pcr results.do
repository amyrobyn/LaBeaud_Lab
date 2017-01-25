cd "C:\Users\amykr\Box Sync\Amy Krystosik's Files\david coinfectin paper"
import excel "C:\Users\amykr\Box Sync\DENV CHIKV project\Lab Data\PCR Database\PCR Latest\West_PCR_Database and Summaries_jan_23_2017.xls", sheet("West PCR Database") firstrow clear

/*
import excel "C:\Users\amykr\Box Sync\DENV CHIKV project\Lab Data\PCR Database\PCR database 05-27-16.xlsx", sheet("Kenya Site PCR Results") cellrange(A2:H2941) firstrow clear
gen dataset = "05-27-16 Kenya Site PCR Results"
save "05-27-16 Kenya Site PCR Results", replace

import excel "C:\Users\amykr\Box Sync\DENV CHIKV project\Lab Data\PCR Database\PCR database 05-27-16.xlsx", sheet("CHIKV PCR SAMPLES") firstrow clear
gen dataset = "PCR database 05-27-16 CHIKV PCR SAMPLES"
save "PCR database 05-27-16 CHIKV PCR SAMPLES", replace

import excel "C:\Users\amykr\Box Sync\DENV CHIKV project\Lab Data\PCR Database\PCR DATA BASE ..END FEB 2016.xlsx", sheet("Kenya Site PCR Results") cellrange(A2:H2941) firstrow clear
save "PCR DATA BASE ..END FEB 2016 Kenya Site PCR Results", replace
gen dataset = "PCR DATA BASE ..END FEB 2016 Kenya Site PCR Results"

import excel "C:\Users\amykr\Box Sync\DENV CHIKV project\Lab Data\PCR Database\PCR DATA BASE ..END FEB 2016 (1).xlsx", sheet("Kenya Site PCR Results") cellrange(A2:H2941) firstrow clear
gen dataset = "PCR DATA BASE ..END FEB 2016 (1)Kenya Site PCR Results"
save "PCR DATA BASE ..END FEB 2016 (1)Kenya Site PCR Results", replace
cf _all using "PCR DATA BASE ..END FEB 2016 Kenya Site PCR Results", all verbose

import excel "C:\Users\amykr\Box Sync\DENV CHIKV project\Lab Data\PCR Database\PCR DATA BASE ..END FEB 2016.xlsx", sheet("CHIKV PCR SAMPLES") firstrow clear
gen dataset  = "PCR DATA BASE ..END FEB 2016 CHIKV PCR SAMPLES" 
save "PCR DATA BASE ..END FEB 2016 CHIKV PCR SAMPLES" , replace

import excel "C:\Users\amykr\Box Sync\DENV CHIKV project\Lab Data\PCR Database\PCR DATA BASE ..END FEB 2016 (1).xlsx", sheet("CHIKV PCR SAMPLES") firstrow clear
gen dataset = "PCR DATA BASE ..END FEB 2016 (1)CHIKV PCR SAMPLES"
save "PCR DATA BASE ..END FEB 2016 (1)CHIKV PCR SAMPLES", replace
cf _all using "PCR DATA BASE ..END FEB 2016 CHIKV PCR SAMPLES", all verbose
*/
*use "PCR DATA BASE ..END FEB 2016 (1)CHIKV PCR SAMPLES", clear 
*append using "05-27-16 Kenya Site PCR Results" "PCR database 05-27-16 CHIKV PCR SAMPLES" "PCR DATA BASE ..END FEB 2016 (1)Kenya Site PCR Results" 

ds, has(type string)
foreach var of var `r(varlist)'{
	replace `var' = lower(`var')
} 

rename *, lower
				rename id studyid
				replace studyid=lower(studyid)
				replace studyid= subinstr(studyid, ".", "",.) 
				replace studyid= subinstr(studyid, "/", "",.)
				replace studyid= subinstr(studyid, " ", "",.)
				replace studyid= subinstr(studyid, " ", "",.)
				replace studyid= subinstr(studyid, " ", "",.)
				replace studyid= subinstr(studyid, " ", "",.)
				drop if studyid==""

save PCR_box, replace


foreach var in  denvpcrresults chikvpcrresults {
	tab `var'
	gen `var'_dum = .
	replace `var'_dum = 1 if strpos(`var', "pos")
	replace `var'_dum = 0 if strpos(`var', "neg")
	drop `var'
	order `var'_dum 
}

collapse (mean)   chikvpcrresults_dum denvpcrresults_dum, by(studyid)

*take visit out of id
									forval i = 1/3 { 
										gen id`i' = substr(studyid, `i', 1) 
									}
			*gen id_wid without visit						 
				rename id1 id_city  
				rename id2 cohort  
				rename id3 visit 
				
				gen id_childnumber = ""
				replace id_childnumber = substr(studyid, +4, .)
				
gen byte notnumeric = real(id_childnumber)==.	/*makes indicator for obs w/o numeric values*/
tab notnumeric	/*==1 where nonnumeric characters*/
list id_childnumber if notnumeric==1	/*will show which have nonnumeric*/
list studyid if strpos(id_childnumber , "6*4") 				
drop if studyid =="mfc6*4"


gen suffix = "" 
	replace suffix = "a" if strpos(id_childnumber, "a")
	replace id_childnumber = subinstr(id_childnumber, "a","", .)

	replace suffix = "b" if strpos(id_childnumber, "b")
	replace id_childnumber = subinstr(id_childnumber, "b","", .)

destring id_childnumber, replace 	
	order cohort id_city visit id_childnumber studyid
	egen id_wide = concat(id_city cohort id_childnum suffix)
drop suffix


				save PCR_box, replace

merge 1:1 id_wide visit using "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\elisas\jan 19 2017\PCR_googledoc"

save allpcr, replace
replace denvpcrresults_dum = denvpcr__dum if denvpcrresults_dum  ==. 
replace chikvpcrresults_dum = chikvpcr__dum if chikvpcrresults_dum  ==. 
drop denvpcr__dum chikvpcr__dum 
sum *_dum 
drop _merge
bysort id_wide visit: gen dup = _n	

ds, has(type string) 
			foreach v of varlist `r(varlist)' { 
				replace `v' = lower(`v') 
}
save allpcr, replace
