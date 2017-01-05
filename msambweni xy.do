*masambweni hcc results with gps for donal
cd "C:\Users\amykr\Box Sync/DENV CHIKV project/Personalized Datasets/Amy/CSVs nov216/output"

use incidentchikv, clear
encode city, gen(cityint)
keep if cityint ==4 & cohort ==3 
sum Stanford_CHIKV_IGG cityint cohort visit gender datesamplecollected_ dob 
keep studyid id_wide visit village Stanford_CHIKV_IGG cityint cohort visit gender datesamplecollected_ dob agemonths childage age2 gender  Stanford_CHIK~G Stanford_DENV~G visit datesamplecol~_ malaria*
keep if Stanford_CHIKV_IGG!=.
save masambweni_hcc_chik, replace

use incidentdenv, clear
encode city, gen(cityint)
keep if cityint ==4 & cohort ==3 
sum Stanford_DENV_IGG cityint cohort visit gender datesamplecollected_ dob 
keep studyid id_wide visit village Stanford_DENV_IGG cityint cohort visit gender datesamplecollected_ dob agemonths childage age2 gender  Stanford_CHIK~G Stanford_DENV~G visit datesamplecol~_ malaria*
keep if Stanford_DENV_IGG!=.
save masambweni_hcc_denv, replace

merge 1:1 id_wide visit using masambweni_hcc_chik
drop _merge cohort cityint 
*rename id_wide studyid
label drop _all
keep id_wide studyid visit village Stanford_DENV_IGG visit gender datesamplecollected_ agemonths childage gender  Stanford_CHIK~G Stanford_DENV~G visit datesamplecol~_ malaria*

gen villageid=""
replace villageid = substr(id_wide, +1, 1)
replace villageid = "3" if villageid =="g"
replace villageid = "4" if villageid =="l"
*destring villageid, replace


gen houseid = ""
replace houseid = substr(studyid, +4, 4)

order studyid houseid villageid

save masambweni_hcc_chk_denv, replace

import excel "C:\Users\amykr\Box Sync/DENV CHIKV project/Coast Cleaned/Demography/Demography Latest/Msambweni_coordinates complete Nov 21 2016.xls", sheet("Sheet1") firstrow clear
gen houseid  = string(House,"%04.0f")
rename Village villageid
order houseid villageid
drop if villageid ==.
bysort houseid villageid: gen dup =_n
egen duphouse = concat(houseid dup) if dup>1
replace houseid = duphouse if dup>1

merge 1:m villageid houseid using masambweni_hcc_chk_denv
keep id_wide studyid  visit villageid houseid Stanford_DENV_IGG visit gender datesamplecollected_ agemonths childage gender  Stanford_CHIK~G Stanford_DENV~G visit datesamplecol~_ X Y
order id_wide studyid  visit Stanford_CHIK~G Stanford_DENV~G  X Y 
keep if id_wide!=""

replace childage = abs(childage)
replace agemonths = abs(agemonths)
save masambweni_hcc_chk_denv_xy, replace

outsheet using masambweni_hcc_chk_denv_xy1.csv, names comma replace


use masambweni_hcc_chk_denv_xy, clear


gen visitstring = ""
replace visitstring = "a" if visit ==1
replace visitstring = "b" if visit ==2
replace visitstring = "c" if visit ==3
replace visitstring = "d" if visit ==4
order visit visitstring


forval i = 1/2 { 
							gen id`i' = substr(id_wide, `i', 1) 
						}
*gen id_wid without visit						 
		gen id_childnumber = ""
			replace id_childnumber = substr(id_wide, +3, .)
			order id1 id2 visitstring id_childnumber studyid
			egen idfull = concat(id1 id2 visitstring id_childnumber)
order idfull studyid
compare idfull studyid
replace studyid=idfull if studyid==""
outsheet using masambweni_hcc_chk_denv_xy2.csv, names comma replace

keep if childage != . | gender !=.
save temp, replace

keep if childage ==. | gender ==.
drop houseid
merge 1:1 studyid using all_interviews.dta
drop houseid
keep if _merge !=2
append using temp
*keep id_wide studyid  visit villageid houseid Stanford_DENV_IGG visit gender datesamplecollected_ agemonths childage gender  Stanford_CHIK~G Stanford_DENV~G visit datesamplecol~_ X Y 

outsheet using masambweni_hcc_chk_denv_xy3.csv, names comma replace

**********************************************************************


use   "Msambweni HCC Follow two 06Nov16.dta", clear
destring childvillage houseid childage, replace
replace studyid=lower(studyid)
save   "Msambweni HCC Follow two 06Nov16.dta", replace

use "Msambweni HCC Initial 06Nov16.dta", clear
replace studyid=lower(studyid)
compare studyid studyid1
save "Msambweni HCC Initial 06Nov16.dta", replace

use "Msambweni HCC Follow one 06Nov16.dta", clear
replace studyid=lower(studyid)
save "Msambweni HCC Follow one 06Nov16.dta", replace

use "Msambweni HCC Follow three 06Nov16.dta", clear
replace studyid=lower(studyid)
save "Msambweni HCC Follow three 06Nov16.dta", replace


insheet using "masambweni_hcc_chk_denv_xy2.csv", comma clear
save masambweni, replace
drop houseid
merge 1:1 studyid using "Msambweni HCC Initial 06Nov16.dta" 
tostring gender, replace
rename _merge merge1
drop start
rename childvillage village1
rename childheight childheight2
rename childweight childweight2
merge 1:1 studyid using "Msambweni HCC Follow one 06Nov16.dta"
rename _merge merge2
destring educlevel  gender houseid childindividualid childoccupation mumeduclevel, replace
rename childoccupation childoccupationstring
rename othchildoccupation othchildoccupationstring
rename educlevel educlevelstring
rename mumeduclevel mumeduclevelstring
rename othmumeduclevel  othmumeduclevelstring
rename childtravel childtravelstring
rename fevertoday fevertodaystring
rename othfeversymptoms othfeversymptomsstring
keep idfull studyid gender childage id1 id2 visitstring id_childnumber visit id_wide stanford_chikv_igg stanford_denv_igg x y villageid datesamplecollected_ malaria*
merge 1:1 studyid using  "Msambweni HCC Follow three 06Nov16.dta"
rename _merge merge3
keep idfull studyid gender childage id1 id2 visitstring id_childnumber visit id_wide stanford_chikv_igg stanford_denv_igg x y villageid datesamplecollected_ malaria*
merge 1:1 studyid using  "Msambweni HCC Follow two 06Nov16.dta"

keep if stanford_chikv_igg !=. | stanford_denv_igg !=.
keep studyid gender childage visitstring stanford_chikv_igg stanford_denv_igg x y villageid datesamplecollected_ malaria*
order studyid visitstring stanford_chikv_igg stanford_denv_igg x y 
outsheet using msambweni_xy_11_21_16.csv, replace names comma
merge 1:1 studyid using  "Msambweni HCC Follow two 06Nov16.dta"

destring agemonths, replace
replace childage =agemonths/12 if childage==.
replace agemonths =childage*12 if agemonths==.
keep if stanford_chikv_igg !=. | stanford_denv_igg !=.
keep studyid gender childage visitstring stanford_chikv_igg stanford_denv_igg x y villageid datesamplecollected_ malaria*
outsheet using msambweni_xy_11_21_16B.csv, replace names comma

