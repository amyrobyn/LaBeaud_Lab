*************************************************************
 *amy krystosik                  							  *
 *u24 									  *
 *lebeaud lab               				        		  *
 *last updated april 26, 2017 									  *
 **************************************************************/ 
local output "C:\Users\amykr\Box Sync\U24 Project\data\"
cd "C:\Users\amykr\Box Sync\U24 Project\data"
capture log close 
log using "exposure.smcl", text replace 
set scrollbufsize 100000
set more 1

use "C:\Users\amykr\Box Sync\DENV CHIKV project\Lab Data\ELISA Database\ELISA Latest\elisa_merged", clear
replace city = "msambweni" if city =="milani"
replace city = "msambweni" if city =="nganja"

collapse (sum)  stanforddenvigg_ stanfordchikvigg_, by(id_wide city)
gen denvexposed = . 
gen chikvexposed = . 
bysort id_wide: replace chikvexposed = 1 if stanfordchikvigg_ > 0 & stanfordchikvigg_<. & stanforddenvigg_ ==0
bysort id_wide: replace chikvexposed = 0 if stanfordchikvigg_ == 0 

bysort id_wide: replace denvexposed  = 1 if stanforddenvigg_ >0 & stanforddenvigg_<. & stanfordchikvigg_ ==0
bysort id_wide: replace denvexposed  = 0 if stanforddenvigg_ ==0 

gen denv_chikv_exposed=.
bysort id_wide: replace denv_chikv_exposed= 1 if stanfordchikvigg_ >0 & stanfordchikvigg_<. & stanforddenvigg_ >0 & stanforddenvigg_<.
bysort id_wide: replace denv_chikv_exposed= 0 if stanforddenvigg_ ==0 & stanfordchikvigg_==0
tab denv_chikv_exposed city


gen chikv_denv_unexposed=.
bysort id_wide: replace chikv_denv_unexposed = 1 if chikvexposed ==0 & denvexposed==0
bysort id_wide: replace chikv_denv_unexposed = 0 if stanforddenvigg_ >=1 & stanforddenvigg_ <. | stanfordchikvigg_>=1 & stanfordchikvigg_<.
tab chikv_denv_unexposed

tab chikvexposed city, m
tab denvexposed city, m

export excel using "`output'exposed", firstrow(variables) replace
outsheet id_wide denvexposed city using "`output'denv_igg_msambweni.csv" if city =="msambweni" & denvexposed==1 |city =="ukunda" & denvexposed==1, replace comma names
outsheet id_wide chikvexposed city using "`output'chikv_igg_msambweni.csv" if city =="msambweni" & chikvexposed ==1|city =="ukunda" & chikvexposed ==1,  replace comma names

ci denvexposed, bin
ci chikvexposed, bin
ci denv_chikv_exposed, bin
ci chikv_denv_unexposed, bin


gen site = "coast" if city =="msambweni"|city =="ukunda"
replace site = "west" if city !="msambweni" & city !="ukunda"
tab site

foreach group in denv_chikv_exposed chikv_denv_unexposed denvexposed chikvexposed{
tab `group' city if site =="coast"
}


gen exposed_group = .
replace exposed_group =1 if denvexposed==1 
replace exposed_group =2 if chikvexposed ==1 
replace exposed_group =3 if denv_chikv_exposed ==1 
replace exposed_group =0 if chikv_denv_unexposed==1

label variable exposed_group  "exposure categories"
label define exposed_group  0 "neither chikv nor denv" 1 "denv" 2 "chikv" 3 "both chikv and denv" , modify
label values exposed_group  exposed_group  exposed_group  exposed_group  
save exposed_group, replace

insheet using "C:\Users\amykr\Box Sync\Amy Krystosik's Files\ASTMH 2017 abstracts\all linked and cleaned data\data\cleaned_merged_prevalence21 Apr 2017.csv", clear
keep if visit =="a"
save visit_a, replace
use visit_a
drop _merge
merge 1:1 id_wide using exposed_group  
tab _merge 

keep age phonenumber gps_x_long gps_y_lat gender dob child_name interviewername ctname cfthname othinterviewername firstname secondname familyname hoc_surname hoc_fname hoc_mname hoc_lname hoc_othername hoh_surname hoh_fname hoh_mname hoh_lname hoh_othername child_othername school_name thirdname surname interviewer_name childsname mothername fathername childname1 childname2 childname3 childname_long   id_wide city stanforddenvigg_ stanfordchikvigg_ denvexposed chikvexposed denv_chikv_exposed chikv_denv_unexposed site exposed_group
*cut down the exposed_group==0 to match the other groups by age. 
keep if exposed_group==0 & age >4 & city == "msambweni" | exposed_group!=0
tab exposed_group
order exposed_group  
keep if site =="coast" 
bysort city: tab exposed_group  

bysort exposed_group city: sum age, d 

outsheet using "C:\Users\amykr\Box Sync\U24 Project\data\particpants_$S_DATE.csv" if denvexposed==1 |chikvexposed ==1 | chikv_denv_unexposed ==1 |chikv_denv_unexposed==1, comma names replace
order id_wide
*here we are just looking at exposed vs not exposed so there is one row for each person. match that to many pedsql visits. if we want to make it 1:1 we can look at prior exposure vs incidence.
merge 1:m id_wide using "C:\Users\amykr\Box Sync\Amy Krystosik's Files\pedsql\pedsql"
