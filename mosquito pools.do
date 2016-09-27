/**************************************************************
 *amy krystosik                  							  *
 *R01 results and discrepencies by strata (lab, antigen, test)*
 *lebeaud lab               				        		  *
 *last updated September 15, 2016  							  *
 **************************************************************/
 
  /*to do 
 list all positives
 graph of % positive by lavarl vs adult by month of collection
  */
  
  
capture log close 
log using "mosquito_pools_9-26-16.smcl", text replace 
set scrollbufsize 100000
set more 1

local import "/Users/amykrystosik/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/longitudinal_analysis_sept152016/"
cd "/Users/amykrystosik/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/CSVs September 20/output"
insheet using "/Users/amykrystosik/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/CSVs September 20/chulaimbo_aic.csv", comma clear names
capture drop *od* followupaliquotid_*
save "chulaimbo_aic", replace
insheet using "/Users/amykrystosik/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/CSVs September 20/chulaimbo_hcc.csv", comma clear names
capture drop *od* followupaliquotid_*
save "chulaimbo_hcc", replace
insheet using "/Users/amykrystosik/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/CSVs September 20/kisuma_aic.csv", comma clear names
capture drop *od* followupaliquotid_*
save "kisuma_aic", replace
insheet using "/Users/amykrystosik/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/CSVs September 20/kisumu_hcc.csv", comma clear names
capture drop *od* followupaliquotid_*
save "kisumu_hcc", replace
insheet using "/Users/amykrystosik/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/CSVs September 20/milalani_hcc.csv", comma clear names
capture drop *od* followupaliquotid_*
save "milalani_hcc", replace
insheet using "/Users/amykrystosik/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/CSVs September 20/msambweni_aic.csv", comma clear names
capture drop *od* followupaliquotid_*
save "msambweni_aic", replace
insheet using "/Users/amykrystosik/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/CSVs September 20/nganja_hcc.csv", comma clear names
capture drop *od* followupaliquotid_*
save "nganja_hcc", replace
insheet using "/Users/amykrystosik/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/CSVs September 20/ukunda_aic.csv", comma clear names
capture drop *od* followupaliquotid_*
save "ukunda_aic", replace
insheet using "/Users/amykrystosik/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/CSVs September 20/ukunda_hcc.csv", comma clear names
capture drop *od* followupaliquotid_*
save "ukunda_hcc", replace
clear

foreach dataset in "chulaimbo_aic.dta" "kisumu_hcc.dta"  "chulaimbo_hcc.dta" "kisuma_aic.dta" "milalani_hcc.dta" "msambweni_aic.dta" "nganja_hcc.dta" "ukunda_aic.dta" "ukunda_hcc.dta"{
use `dataset', clear
capture drop villhouse_a
capture destring personid_a, replace
save `dataset', replace
}
append using "chulaimbo_aic.dta" "kisumu_hcc.dta"  "chulaimbo_hcc.dta" "kisuma_aic.dta" "milalani_hcc.dta" "msambweni_aic.dta" "nganja_hcc.dta" "ukunda_aic.dta" "ukunda_hcc.dta"
drop if studyid_a =="example"
drop if studyid_a =="EXAMPLE"
drop if studyid_a =="Example"
save appended_september20.dta, replace

	drop if studyid_a==""|studyid_a=="???"

