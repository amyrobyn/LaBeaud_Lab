insheet using "/Users/amykrystosik/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/CSVs nov216/case_control.csv", comma clear name
drop visit
capture drop _merge
duplicates drop
encode case_control, gen(cc)

save case_control, replace
insheet using "/Users/amykrystosik/Desktop/sammy comparison.csv", comma clear
capture drop _merge
duplicates drop
capture drop _merge

merge 1:1 study_id using "/Users/amykrystosik/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/CSVs nov216/output/case_control.dta"
