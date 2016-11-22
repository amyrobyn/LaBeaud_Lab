cd "/Users/amykrystosik/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/CSVs nov216/output/"
use   "Msambweni HCC Follow two 06Nov16.dta", clear
destring childvillage houseid childage, replace
replace studyid=lower(studyid)
save   "/Users/amykrystosik/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/CSVs nov216/output/Msambweni HCC Follow two 06Nov16.dta", replace

use "/Users/amykrystosik/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/CSVs nov216/output/Msambweni HCC Initial 06Nov16.dta", clear
replace studyid=lower(studyid)
compare studyid studyid1
save "/Users/amykrystosik/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/CSVs nov216/output/Msambweni HCC Initial 06Nov16.dta", replace

use "/Users/amykrystosik/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/CSVs nov216/output/Msambweni HCC Follow one 06Nov16.dta", clear
replace studyid=lower(studyid)
save "/Users/amykrystosik/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/CSVs nov216/output/Msambweni HCC Follow one 06Nov16.dta", replace

use "/Users/amykrystosik/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/CSVs nov216/output/Msambweni HCC Follow three 06Nov16.dta", clear
replace studyid=lower(studyid)
save "/Users/amykrystosik/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/CSVs nov216/output/Msambweni HCC Follow three 06Nov16.dta", replace


insheet using "/Users/amykrystosik/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/CSVs nov216/output/masambweni_hcc_chk_denv_xy2.csv", comma clear
save masambweni, replace
drop houseid
merge 1:1 studyid using "/Users/amykrystosik/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/CSVs nov216/output/Msambweni HCC Initial 06Nov16.dta" 
tostring gender, replace
rename _merge merge1
drop start
rename childvillage village1
rename childheight childheight2
rename childweight childweight2
merge 1:1 studyid using "/Users/amykrystosik/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/CSVs nov216/output/Msambweni HCC Follow one 06Nov16.dta"
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
keep idfull studyid gender childage id1 id2 visitstring id_childnumber visit id_wide stanford_chikv_igg stanford_denv_igg x y villageid datesamplecollected_
merge 1:1 studyid using  "/Users/amykrystosik/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/CSVs nov216/output/Msambweni HCC Follow three 06Nov16.dta"
rename _merge merge3
keep idfull studyid gender childage id1 id2 visitstring id_childnumber visit id_wide stanford_chikv_igg stanford_denv_igg x y villageid datesamplecollected_
merge 1:1 studyid using  "/Users/amykrystosik/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/CSVs nov216/output/Msambweni HCC Follow two 06Nov16.dta"

keep if stanford_chikv_igg !=. | stanford_denv_igg !=.
keep studyid gender childage visitstring stanford_chikv_igg stanford_denv_igg x y villageid datesamplecollected_
order studyid visitstring stanford_chikv_igg stanford_denv_igg x y 
outsheet using msambweni_xy_11_21_16.csv, replace names comma
merge 1:1 studyid using  "/Users/amykrystosik/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/CSVs nov216/output/Msambweni HCC Follow two 06Nov16.dta"

destring agemonths, replace
replace childage =agemonths/12 if childage==.
replace agemonths =childage*12 if agemonths==.
keep if stanford_chikv_igg !=. | stanford_denv_igg !=.
keep studyid gender childage visitstring stanford_chikv_igg stanford_denv_igg x y villageid datesamplecollected_
outsheet using msambweni_xy_11_21_16B.csv, replace names comma
 
