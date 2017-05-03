use "C:\Users\amykr\Downloads\prevalent.dta", clear

*bysort id_wide: list city 

bysort id_wide: replace city = city[_n-1] if missing(city)
bysort id_wide: replace city = city[_n+1] if missing(city)
bysort id_wide: replace city = city[_n-1] if missing(city)
bysort id_wide: replace city = city[_n+1] if missing(city)

*bysort id_wide: list city 
 
collapse (sum) Stanford_CHIKV_IGG Stanford_DENV_IGG, by(id_wide city)
gen denvexposed = . 
gen chikvexposed = . 
bysort id_wide: replace chikvexposed = 1 if Stanford_CHIKV_IGG > 0 & Stanford_CHIKV_IGG<.
bysort id_wide: replace chikvexposed = 0 if Stanford_CHIKV_IGG == 0 
bysort id_wide: replace denvexposed  = 1 if Stanford_DENV_IGG > 0 & Stanford_DENV_IGG < .
bysort id_wide: replace denvexposed  = 0 if Stanford_DENV_IGG == 0 

tab chikvexposed city, m
tab denvexposed city, m

isid id_wide
duplicates list id_wide

export excel using "C:\Users\amykr\Downloads\nov29_exposed", firstrow(variables) replace

save exposed.dta, replace

use "C:\Users\amykr\Downloads\prevalent.dta", clear
keep   studyid id_wide child_name phonenumber  othphonenumber 
duplicates drop id_wide, force
merge 1:1 id_wide using "exposed.dta"
