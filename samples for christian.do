/********************************************************************
 *amy krystosik                  							  		*
 *samples for christian
 *lebeaud lab               				        		  		*
 *last updated march 18, 2017  							  			*
 ********************************************************************/ 
capture log close 
set more 1
set scrollbufsize 100000

log using "samples for christian.smcl", text replace 
use "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\all linked and cleaned data\data\cleaned_merged_prevalence", replace

**if I force these to be igg negative for denv and chikv, there aren't enough samples**
keep if chikvpcrresults_dum !=1 & denvpcrresults_dum !=1
tab severemalaria
 
gen christian_groups = . 
replace christian_groups =1 if cohort ==1 & severemalaria==1 
replace christian_groups =2 if cohort ==1 & severemalaria==0 
replace christian_groups =3 if cohort ==2 & malariapositive_dum2==1 
replace christian_groups =4 if cohort ==2 & malariapositive_dum2==0

tab christian_groups
table1, vars(age conts\) by(christian_groups) 
keep christian_groups age studyid malariapositive_dum2 severemalaria cohort chikvpcrresults_dum denvpcrresults_dum 
keep if christian_groups !=. 
*try to get similar ages
keep if age<=5 & age>=3 | christian_groups ==1
tab christian_groups 
table1, vars(age conts\) by(christian_groups) 
outsheet using "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\all linked and cleaned data\data\christian_samples.csv", comma names replace
