*jimmy data

use "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\all linked and cleaned data\data\cleaned_merged_data", replace

 
		drop if year ==.
		drop if month ==.
		keep if year == 2014 & month > 11| year == 2015 & month < 12 
		tab month year
		keep if cohort ==1
		bysort city: sum age , d

		bysort site: sum age
		
		table1, vars(age conts \ gender bin) by(site) test missing
		
		
		
*pcr denv pos and malaria neg 
use "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\all linked and cleaned data\data\cleaned_merged_prevalence", clear
order *dum
tab  denvpcrresults_dum malariapositive_dum
list studyid id_wide visit if  denvpcrresults_dum ==1 & malariapositive_dum ==0

 