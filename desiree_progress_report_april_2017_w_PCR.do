set more 1
set scrollbufsize 100000
cd "C:\Users\amykr\Box Sync\Amy Krystosik's Files\progress report april 2017"

local figures "C:\Users\amykr\Box Sync\Amy Krystosik's Files\progress report april 2017\figures\"
local data "C:\Users\amykr\Box Sync\Amy Krystosik's Files\progress report april 2017\data\"
local cleandata "C:\Users\amykr\Box Sync\Amy Krystosik's Files\ASTMH 2017 abstracts\all linked and cleaned data\data\"

use "`cleandata'prev_chikv_w_PCR10 Apr 2017", clear
	*fix city
		replace city = "c" if id_wide =="cf433"
		replace city = id_city if city ==""
		replace city = "chulaimbo" if city=="c"
		replace city = "chulaimbo" if city=="r"
		replace city = "ukunda" if city=="u"
		replace city = "kisumu" if city=="k"
		replace city = "msambweni" if city=="m"
save chikv, replace

use "`cleandata'prev_denv_w_PCR12 Apr 2017", clear
	*fix city
		replace city = "c" if id_wide =="cf433"
		replace city = id_city if city ==""
		replace city = "chulaimbo" if city=="c"
		replace city = "chulaimbo" if city=="r"
		replace city = "ukunda" if city=="u"
		replace city = "kisumu" if city=="k"
		replace city = "msambweni" if city=="m"
save denv, replace		
capture log close 
log using "progress_report_april_2017_w_pcr.smcl", text replace 
/********************************************************************
 *amy krystosik                  							  		*
 *desiree progress report 2017- incidence and prev					*
 *lebeaud lab               				        		  		*
 ********************************************************************/ 
 
display "last updated $S_DATE"

local figures "C:\Users\amykr\Box Sync\Amy Krystosik's Files\progress report april 2017\figures\"
local data "C:\Users\amykr\Box Sync\Amy Krystosik's Files\progress report april 2017\data\"
local cleandata "C:\Users\amykr\Box Sync\Amy Krystosik's Files\ASTMH 2017 abstracts\all linked and cleaned data\data\"
*******************************************start malaria**********************************************
*malaria 
use "`cleandata'cleaned_merged_prevalence$S_DATE", clear
		replace city = "c" if id_wide =="cf433"
		replace city = id_city if city ==""
		replace city = "chulaimbo" if city=="c"
		replace city = "chulaimbo" if city=="r"
		replace city = "ukunda" if city=="u"
		replace city = "kisumu" if city=="k"
		replace city = "msambweni" if city=="m"
tab city, m
lookfor fever
replace fever = 1 if childtemp >=38 & childtemp !=.
replace fever = 0 if childtemp <38 & childtemp !=.
bysort cohort: tab fever, m  
compare fever fevertoday 
replace fever = fevertoday if fever ==. 
replace fever = feverpos1 if fever ==. 
		keep malariapositive_dum species_cat gametocytes   parasite_count_all visit_int id_wide city cohort fever pos_neg acute site
		keep if malariapositive_dum !=.
replace species_cat ="" if species_cat =="neg"|species_cat =="0"
replace species_cat ="pf/pm" if species_cat =="pfpm"
tab species_cat 
egen cohort_city =concat(cohort city)
		table1, vars(species_cat cat \ ) by(cohort_city ) saving("`figures'species.xls", replace)

bysort acute: fsum pos_neg if fever == 1 & cohort ==1
bysort acute: fsum malariapositive_dum if fever == 1 & cohort ==1
drop acute
preserve
	keep if fever ==1 & cohort == 1
	replace site = "west" if city =="kisumu"|city =="chulaimbo"
	replace site = "coast" if city =="msambweni"|city =="ukunda"
	
	reshape wide malariapositive_dum species_cat gametocytes parasite_count_all pos_neg, i(id_wide) j(visit_int) 
	bysort site: fsum malariapositive_dum*
restore
preserve
	keep if fever ==1
	
	replace site = "west" if city =="kisumu"|city =="chulaimbo"
	replace site = "coast" if city =="msambweni"|city =="ukunda"
	
	reshape wide malariapositive_dum species_cat gametocytes parasite_count_all pos_neg, i(id_wide) j(visit_int) 
	bysort site cohort: fsum malariapositive_dum*
restore
 
*******************************************end malaria*************************************************
 

*******************************************start denv**************************************************
use denv, clear
*reshape to wide
		keep prev_denv  malariapositive_dum species_cat gametocytes   parasite_count_all visit_int id_wide city cohort
		keep if prev_denv!=.
		reshape wide prev_denv  malariapositive_dum species_cat gametocytes   parasite_count_all , i(id_wide) j(visit_int) 

		*make variables for report
	gen acute =.
		replace acute = 1 if  prev_denv1 == 1| prev_denv3 ==1|prev_denv5==1
		replace acute = 0 if  prev_denv1 == 0| prev_denv3 ==0|prev_denv5==0
		*AIC
		bysort city: tab acute if cohort ==1
	gen conv = . 
		replace conv = 1 if  prev_denv2 == 1| prev_denv4 ==1
		replace conv = 0 if  prev_denv2 == 0| prev_denv4 ==0
*********start aic *********

		*AIC
		bysort city: tab conv if cohort ==1


	gen seroconverted = .
		replace seroconverted =0 if prev_denv1 !=. & prev_denv2 !=. | prev_denv3 != . & prev_denv4 !=. 
		replace seroconverted =1 if prev_denv1 ==0 & prev_denv2 ==1 | prev_denv3 == 0 & prev_denv4 ==1 
		*AIC
		bysort city: tab seroconverted  if cohort ==1


	gen seroreverted =.
		replace seroreverted =0 if prev_denv1 !=. & prev_denv2 !=. | prev_denv3 != . & prev_denv4 !=. 
		replace seroreverted =1 if prev_denv1 ==1 & prev_denv2 ==0 | prev_denv1 ==1 & prev_denv3 == 0 | prev_denv1 ==1 & prev_denv4 == 0 
		replace seroreverted =1 if prev_denv2 == 1 & prev_denv3 ==0 |prev_denv2 == 1 & prev_denv4 ==0   
		replace seroreverted =1 if prev_denv3 == 1 & prev_denv4 ==0 
*AIC
		bysort city: tab seroreverted  if cohort ==1

reshape long 
*********end aic *********

*********start hcc********
*HCC
keep if cohort ==2
		bysort city : tab seroreverted  
		bysort city : tab seroconverted 
		bysort city : tab conv 
		bysort city : tab acute 
bysort city: tab visit_int prev_denv, m
stset visit_int , id(id_wide) f(prev_denv)
sts list, by(city cohort)
*********end hcc*********
*******************************************end denv**********************************************************

*******************************************start chikv**********************************************************
use chikv, clear
	*reshape to wide
		keep prev_chikv  malariapositive_dum species_cat gametocytes   parasite_count_all visit_int id_wide city cohort
		keep if prev_chikv !=.
		reshape wide prev_chikv malariapositive_dum species_cat gametocytes   parasite_count_all , i(id_wide) j(visit_int) 
	*make variables for report
	gen acute =.
		replace acute = 1 if  prev_chikv1 == 1| prev_chikv3 ==1|prev_chikv5==1
		replace acute = 0 if  prev_chikv1 == 0| prev_chikv3 ==0|prev_chikv5==0
*********start aic *********
*aic
		bysort city: tab acute if cohort ==1


	gen conv = . 
		replace conv = 1 if  prev_chikv2 == 1| prev_chikv4 ==1
		replace conv = 0 if  prev_chikv2 == 0| prev_chikv4 ==0
*aic
		bysort city: tab conv if cohort ==1
	gen seroconverted = .
		replace seroconverted =0 if prev_chikv1 !=. & prev_chikv2 !=. | prev_chikv3 != . & prev_chikv4 !=. 
		replace seroconverted =1 if prev_chikv1 ==0 & prev_chikv2 ==1 | prev_chikv3 == 0 & prev_chikv4 ==1  
*aic
		bysort city: tab seroconverted if cohort ==1

	gen seroreverted =.
		replace seroreverted =0 if prev_chikv1 !=. & prev_chikv2 !=. | prev_chikv3 != . & prev_chikv4 !=. 
		replace seroreverted =1 if prev_chikv1 ==1 & prev_chikv2 ==0 | prev_chikv1 ==1 & prev_chikv3 == 0 | prev_chikv1 ==1 & prev_chikv4 == 0 
		replace seroreverted =1 if prev_chikv2 == 1 & prev_chikv3 ==0 |prev_chikv2 == 1 & prev_chikv4 ==0   
		replace seroreverted =1 if prev_chikv3 == 1 & prev_chikv4 ==0 
*aic
		bysort city: tab seroreverted if cohort ==1
reshape long 
*********end aic *********

*********start hcc*********
*********hcc*********
stset visit_int , id(id_wide) f(prev_chikv)
sts list, by(city cohort)
keep if cohort ==2
bysort city visit: tab prev_chikv
 
bysort city visit: tab seroreverted  
bysort city visit: tab seroconverted 
bysort city visit: tab conv 
bysort city visit: tab acute 
*********end hcc*********
*******************************************end chikv**********************************************************
