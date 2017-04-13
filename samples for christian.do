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
use "C:\Users\amykr\Box Sync\Amy Krystosik's Files\ASTMH 2017 abstracts\all linked and cleaned data\data\cleaned_merged_prevalence$S_DATE.dta", clear
lookfor tribe ethnicity parasite cbc

*use "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\all linked and cleaned data\data\cleaned_merged_prevalence", replace

**if I force these to be igg negative for denv and chikv, there aren't enough samples**
tab severemalaria
 
gen christian_groups = . 
replace christian_groups =1 if cohort ==1 & severemalaria==1 
replace christian_groups =2 if cohort ==1 & severemalaria==0 
replace christian_groups =3 if cohort ==2 & malariapositive_dum2==1 
replace christian_groups =4 if cohort ==2 & malariapositive_dum2==0

tab christian_groups
table1, vars(age conts\) by(christian_groups) 
keep christian_groups id_wide hoh_tribe  hoh_language parasite_count_lab parasite_count_hcc hemoglobin  tribeother parasitelevel_desc tribe  parasite_count_all  symptms othersymptms fvrsymptms otherfvrsymptms visit age gender studyid malariapositive_dum2 severemalaria cohort chikvpcrresults_dum denvpcrresults_dum stanfordchikvigg_ stanforddenvigg_  species  parasite_count_lab parasite_count_hcc parasitelevel_desc parasite_count_all all_symptoms_*
order studyid id_wide cohort  visit christian_groups age gender malariapositive_dum2 severemalaria chikvpcrresults_dum denvpcrresults_dum stanfordchikvigg_ stanforddenvigg_  species  parasite_count_lab parasite_count_hcc parasitelevel_desc parasite_count_all all_symptoms_*

tab christian_groups 

table1, vars(age conts\) by(christian_groups) 
export excel using "C:\Users\amykr\Box Sync\Amy Krystosik's Files\ASTMH 2017 abstracts\all linked and cleaned data\data\\christian_samples.xls", firstrow(variables) replace
