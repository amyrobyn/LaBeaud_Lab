/********************************************************************
 *amy krystosik                  							  		*
 *desiree astmh abstract 2017- incidence and prev					*
 *lebeaud lab               				        		  		*
 *last updated march 14, 2017  							  			*
 ********************************************************************/ 
capture log close 
set more 1
set scrollbufsize 100000
cd "C:\Users\amykr\Box Sync\Amy Krystosik's Files\progress report april 2017"
log using "progress_report_april_2017_w_pcr.smcl", text replace 

local figures "C:\Users\amykr\Box Sync\Amy Krystosik's Files\progress report april 2017\figures\"
local data "C:\Users\amykr\Box Sync\Amy Krystosik's Files\progress report april 2017\data\"
local cleandata "C:\Users\amykr\Box Sync\Amy Krystosik's Files\ASTMH 2017 abstracts\all linked and cleaned data\data\"
*******************************************start denv**********************************************************
use "`cleandata'prev_denv_w_PCR12 Apr 2017", clear
	*fix city
		replace city = "c" if id_wide =="cf433"
		replace city = id_city if city ==""
		replace city = "chulaimbo" if city=="c"
		replace city = "chulaimbo" if city=="r"
		replace city = "ukunda" if city=="u"
		replace city = "kisumu" if city=="k"
		replace city = "msambweni" if city=="m"
	*reshape to wide
		keep prev_denv time id_wide city cohort
		keep if prev_denv!=.
		reshape wide prev_denv, i(id_wide) j(time ) 
	*make variables for report
	gen acute =.
		replace acute = 1 if  prev_denv1 == 1| prev_denv3 ==1|prev_denv5==1
		replace acute = 0 if  prev_denv1 == 0| prev_denv3 ==0|prev_denv5==0
		bysort city cohort: tab acute 

	gen conv = . 
		replace conv = 1 if  prev_denv2 == 1| prev_denv4 ==1
		replace conv = 0 if  prev_denv2 == 0| prev_denv4 ==0
		bysort city cohort: tab conv

	gen seroconverted = .
		replace seroconverted =0 if prev_denv1 !=. & prev_denv2 !=. | prev_denv3 != . & prev_denv4 !=. 
		replace seroconverted =1 if prev_denv1 ==0 & prev_denv2 ==1 | prev_denv3 == 0 & prev_denv4 ==1 
		bysort city cohort: tab seroconverted 

	gen seroreverted =.
		replace seroreverted =0 if prev_denv1 !=. & prev_denv2 !=. | prev_denv3 != . & prev_denv4 !=. 
		replace seroreverted =1 if prev_denv1 ==1 & prev_denv2 ==0 | prev_denv1 ==1 & prev_denv3 == 0 | prev_denv1 ==1 & prev_denv4 == 0 
		replace seroreverted =1 if prev_denv2 == 1 & prev_denv3 ==0 |prev_denv2 == 1 & prev_denv4 ==0   
		replace seroreverted =1 if prev_denv3 == 1 & prev_denv4 ==0 
		bysort city cohort: tab seroreverted 
*******************************************end denv**********************************************************

*******************************************start chikv**********************************************************
use "`cleandata'prev_chikv_w_PCR10 Apr 2017", clear
	*fix city
		replace city = "c" if id_wide =="cf433"
		replace city = id_city if city ==""
		replace city = "chulaimbo" if city=="c"
		replace city = "chulaimbo" if city=="r"
		replace city = "ukunda" if city=="u"
		replace city = "kisumu" if city=="k"
		replace city = "msambweni" if city=="m"
	*reshape to wide
		keep prev_chikv time id_wide city cohort
		keep if prev_chikv!=.
		reshape wide prev_chikv, i(id_wide) j(time ) 
	*make variables for report
	gen acute =.
		replace acute = 1 if  prev_chikv1 == 1| prev_chikv3 ==1|prev_chikv5==1
		replace acute = 0 if  prev_chikv1 == 0| prev_chikv3 ==0|prev_chikv5==0
		bysort city cohort: tab acute 

	gen conv = . 
		replace conv = 1 if  prev_chikv2 == 1| prev_chikv4 ==1
		replace conv = 0 if  prev_chikv2 == 0| prev_chikv4 ==0
		bysort city cohort: tab conv

	gen seroconverted = .
		replace seroconverted =0 if prev_chikv1 !=. & prev_chikv2 !=. | prev_chikv3 != . & prev_chikv4 !=. 
		replace seroconverted =1 if prev_chikv1 ==0 & prev_chikv2 ==1 | prev_chikv3 == 0 & prev_chikv4 ==1 
		bysort city cohort: tab seroconverted 

	gen seroreverted =.
		replace seroreverted =0 if prev_chikv1 !=. & prev_chikv2 !=. | prev_chikv3 != . & prev_chikv4 !=. 
		replace seroreverted =1 if prev_chikv1 ==1 & prev_chikv2 ==0 | prev_chikv1 ==1 & prev_chikv3 == 0 | prev_chikv1 ==1 & prev_chikv4 == 0 
		replace seroreverted =1 if prev_chikv2 == 1 & prev_chikv3 ==0 |prev_chikv2 == 1 & prev_chikv4 ==0   
		replace seroreverted =1 if prev_chikv3 == 1 & prev_chikv4 ==0 
		bysort city cohort: tab seroreverted 
*******************************************start chikv**********************************************************
