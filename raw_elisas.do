/********************************************************************
 *amy krystosik                  							  		*
 *raw data for elisas												* 
 *elisa for chikv and denv.											*
 *lebeaud lab               				        		  		*
 *last updated march 20, 2017  							  			*
 ********************************************************************/ 

cd "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\elisas\raw"

capture log close 
log using "raw elisas.smcl", text replace 
set scrollbufsize 100000
set more 1

use "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\all linked and cleaned data\data\cleaned_merged_prevalence", clear

bysort cohort: sum *igg
