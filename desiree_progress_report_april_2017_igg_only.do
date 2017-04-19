/********************************************************************
 *amy krystosik                  							  		*
 *desiree astmh abstract 2017- incidence and prev					*
 *lebeaud lab               				        		  		*
 *last updated march 14, 2017  							  			*
 ********************************************************************/ 
set more 1
set scrollbufsize 100000
cd "C:\Users\amykr\Box Sync\Amy Krystosik's Files\progress report april 2017"

local figures "C:\Users\amykr\Box Sync\Amy Krystosik's Files\progress report april 2017\figures\"
local data "C:\Users\amykr\Box Sync\Amy Krystosik's Files\progress report april 2017\data\"
local cleandata "C:\Users\amykr\Box Sync\Amy Krystosik's Files\ASTMH 2017 abstracts\all linked and cleaned data\data\"
*******************************************start denv**********************************************************
insheet using "`cleandata'prev_denv_wo_PCR_23 Mar 2017.csv", clear names comma
	*fix city
		replace city = "c" if id_wide =="cf433"
		replace city = id_city if city ==""
		replace city = "chulaimbo" if city=="c"
		replace city = "chulaimbo" if city=="r"
		replace city = "ukunda" if city=="u"
		replace city = "kisumu" if city=="k"
		replace city = "msambweni" if city=="m"
	*reshape to wide
		drop visit_int
		encode visit, gen(visit_int)
		keep prev_denv visit_int id_wide city cohort
		keep if prev_denv!=.
		reshape wide prev_denv, i(id_wide) j(visit_int) 
capture log close 
log using "progress_report_april_2017_igg_only.smcl", text replace 
local figures "C:\Users\amykr\Box Sync\Amy Krystosik's Files\progress report april 2017\figures\"
local data "C:\Users\amykr\Box Sync\Amy Krystosik's Files\progress report april 2017\data\"
local cleandata "C:\Users\amykr\Box Sync\Amy Krystosik's Files\ASTMH 2017 abstracts\all linked and cleaned data\data\"
*******************************************start denv**********************************************************
*using "`cleandata'prev_denv_wo_PCR_23 Mar 2017.csv", clear names comma*
	*make variables for report
	gen acute =.
		replace acute = 1 if  prev_denv1 == 1| prev_denv3 ==1
		replace acute = 0 if  prev_denv1 == 0| prev_denv3 ==0
*********start aic *********
		*AIC
		bysort city: tab acute if cohort =="AIC"

	gen conv = . 
		replace conv = 1 if  prev_denv2 == 1
		replace conv = 0 if  prev_denv2 == 0
		*AIC
		bysort city: tab conv if cohort =="AIC"


	gen seroconverted = .
		replace seroconverted =0 if prev_denv1 !=. & prev_denv2 !=. 
		replace seroconverted =1 if prev_denv1 ==0 & prev_denv2 ==1 
		*AIC
		bysort city: tab seroconverted  if cohort =="AIC"


	gen seroreverted =.
		replace seroreverted =0 if prev_denv1 !=. & prev_denv2 !=. 
		replace seroreverted =1 if prev_denv1 ==1 & prev_denv2 ==0 | prev_denv1 ==1 & prev_denv3 == 0 
		replace seroreverted =1 if prev_denv2 == 1 & prev_denv3 ==0   
*AIC
		bysort city: tab seroreverted  if cohort =="AIC"

*********end aic *********

*********start hcc *********
reshape long 
*HCC
keep if cohort =="HCC"
		bysort city visit: tab seroreverted  
		bysort city visit: tab seroconverted 
		bysort city visit: tab conv 
		bysort city visit: tab acute 

stset visit_int , id(id_wide) f(prev_denv)
sts list, by(city cohort)
*********start hcc*********
*******************************************end denv**********************************************************

*******************************************start chikv**********************************************************
insheet using "`cleandata'prev_chikv_wo_PCR_23 Mar 2017.csv", clear names comma
	*fix city
		replace city = "c" if id_wide =="cf433"
		replace city = id_city if city ==""
		replace city = "chulaimbo" if city=="c"
		replace city = "chulaimbo" if city=="r"
		replace city = "ukunda" if city=="u"
		replace city = "kisumu" if city=="k"
		replace city = "msambweni" if city=="m"
	*reshape to wide
		drop visit_int
		encode visit, gen(visit_int)
		keep prev_chikv visit_int id_wide city cohort
		keep if prev_chikv!=.
		reshape wide prev_chikv, i(id_wide) j(visit_int) 
	*make variables for report
	gen acute =.
		replace acute = 1 if  prev_chikv1 == 1| prev_chikv3 ==1
		replace acute = 0 if  prev_chikv1 == 0| prev_chikv3 ==0
*aic
		bysort city: tab acute if cohort =="AIC"

	gen conv = . 
		replace conv = 1 if  prev_chikv2 == 1
		replace conv = 0 if  prev_chikv2 == 0
*aic
		bysort city: tab conv if cohort =="AIC"
	gen seroconverted = .
		replace seroconverted =0 if prev_chikv1 !=. & prev_chikv2 !=. 
		replace seroconverted =1 if prev_chikv1 ==0 & prev_chikv2 ==1 
*aic
		bysort city: tab seroconverted if cohort =="AIC"

	gen seroreverted =.
		replace seroreverted =0 if prev_chikv1 !=. & prev_chikv2 !=. 
		replace seroreverted =1 if prev_chikv1 ==1 & prev_chikv2 ==0 | prev_chikv1 ==1 & prev_chikv3 == 0 
		replace seroreverted =1 if prev_chikv2 == 1 & prev_chikv3 ==0   
		
*aic
		bysort city: tab seroreverted if cohort =="AIC"
*********start aic *********
		
*********start hcc*********
reshape long 
keep if cohort =="HCC"
bysort city visit: tab seroreverted  
bysort city visit: tab seroconverted 
bysort city visit: tab conv 
bysort city visit: tab acute 
stset visit_int , id(id_wide) f(prev_chikv)
sts list, by(city cohort)
*********end hcc*********

*******************************************end chikv**********************************************************
