cd "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\CSVs nov29_16"

************************************add sammy dengue RDT data**********************************
insheet using "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\RDT\sammy data nov4.csv", comma clear names

rename studynumber study_id
rename igm dengueigm_sammy
rename igg dengue_igg_sammy
tempfile ns1
save ns1, replace

*take visit out of id

						forval i = 1/3 { 
							gen id`i' = substr(study_id, `i', 1) 
						}
*gen id_wid without visit						 
	gen city  = id1 
	gen id_cohort = id2 
	gen VISIT = id3
	tab VISIT
	gen id_childnumber = ""
	replace id_childnumber = substr(study_id, +4, .)
	order id_cohort city study_id id_childnumber 
	egen id_wide = concat(city id_cohort id_childnum)

	foreach var of varlist _all{
		rename `var', lower
}
	ds *t*, not
	foreach var of var `r(varlist)'{
		tostring `var', replace 
		replace `var'=lower(`var')
		rename `var', lower
		}	
	foreach var of varlist date*{
		*capture destring `var', replace
		capture gen double my`var'= date(`var',"DMY")
		capture format my`var' %td
		drop `var'
}
	ds my*, not
	foreach var of var `r(varlist)'{
		tostring `var', replace 
		replace `var'=lower(`var')
		rename `var', lower
	}	
	ds my*, not
	foreach var of var `r(varlist)'{
	replace `var' =trim(itrim(lower(`var')))
	}
replace nsi = "0" if nsi =="n eg"
save ns1, replace
rename visit VISIT
bysort id_wide VISIT: gen dup =_n
drop if dup>1
drop dup
save sammy
