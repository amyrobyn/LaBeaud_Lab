cd "C:\Users\amykr\Box Sync\Amy Krystosik's Files\david coinfectin paper\compare_datasets"
import excel "malaria parasitemia database queried_10162015.xls", sheet("AIC OBAMA MALARIA corrected") firstrow clear
save "AIC OBAMA MALARIA corrected" , replace

import excel "malaria parasitemia database queried_10162015.xls", sheet("AIC CHULAIMBO MALARIA corrected") firstrow clear
save "AIC CHULAIMBO MALARIA corrected" , replace

append using "AIC OBAMA MALARIA corrected" 


order *200
egen malariapositive_kelsey = rowtotal(  pf200 - pv200)
gen  malariapositive__kelsey_dum = .
replace malariapositive__kelsey_dum = 0 if malariapositive_kelsey ==0
replace malariapositive__kelsey_dum = 1 if malariapositive_kelsey >0 & malariapositive_kelsey <. 

gen species_cat_kelsey = "" 
replace species_cat = "pf" if pf200 >0 & pf200 <.
replace species_cat = "pm" if pm200  >0 & pm200 <.
replace species_cat = "po" if po200 >0 & po200 <.
replace species_cat = "pv" if pv200 >0 & pv200 <.
*replace species_cat = "ni" if ni200 >0 & ni200 <.
*replace species_cat = "none" if none200 >0 & none200 <.

order pf200 pm200 po200 pv200 
egen parasite_count_kelsey = rowtotal(pf200 pm200 po200 pv200 ) 

save kelsey_malaria, replace

*cf _all using "C:\Users\amykr\Box Sync\Amy Krystosik's Files\malaria prelim data dec 29 2016\malaria.dta", all verbose 

replace studyid = lower(studyid)
replace studyid = subinstr(studyid, "/", "",.)
replace studyid = subinstr(studyid, " ", "",.)
replace studyid = subinstr(studyid, "-", "",.)
replace studyid = subinstr(studyid, "--", "",.)
replace studyid = subinstr(studyid, "*", "",.)
drop if studyid =="" 

merge m:m studyid using "C:\Users\amykr\Box Sync\Amy Krystosik's Files\malaria prelim data dec 29 2016\malaria.dta"

list studyid malariapositive_dum if _merge ==1
