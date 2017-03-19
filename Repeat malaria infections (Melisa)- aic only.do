/********************************************************************
 *amy krystosik                  							  		*
 *melisa Repeat malaria infections (Melisa)- aic only				*
 *lebeaud lab               				        		  		*
 *last updated march 18, 2017  							  			*
 ********************************************************************/ 
capture log close 
set more 1
set scrollbufsize 100000
log using "LOG Repeat malaria infections (Melisa)- aic only.smcl", text replace 
cd "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\Repeat malaria infections (Melisa)- aic only"
local figures "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\Repeat malaria infections (Melisa)- aic only\draft figures\"
local data "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\Repeat malaria infections (Melisa)- aic only\data\"

use "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\all linked and cleaned data\data\cleaned_merged_data", replace
use "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\all linked and cleaned data\data\cleaned_merged_data", replace


/*Repeat malaria infections (Melisa)- aic only
Due to reinfection or maltreatment?
Amy Send melisa
Spatial climate, ses, village, season, year, Treatment, location, demographics, height weight, bednets, parasite species and density
Only kids with malaria
1st pos second non
1st pos second pos
How many kids have gametocytes?
*/
