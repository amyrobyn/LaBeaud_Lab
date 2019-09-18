*Kenya_datamanagment_step3_HCC_R01_vs6
set more off
*log using "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Log\Kenya_datamanagment_step2_R01_vs14.log", replace

*Author: C.J.Alberts 
*Funding: R01 NIH, entitled xxxx

*******************************************************************************
**Table of contents
*******************************************************************************
**Drop records with same dates within one person
**nthRecHCC
**date_hcc_input
**date_complete2 (contains date_complete and date_hcc_input)

*******************************************************************************
********************************************************************************


********************************************************************************
*Drop records with same dates
********************************************************************************
clear
use "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_step2.dta", replace

ta cohortID, m
keep if cohortID==2
ta cohortID, m

*Drop all individuals with weird record id's
gen funnyID=1 if(regexm(person_id, "[A-Z][A-Z][A-Z]"))
*browse person_id funnyID
ta funnyID, m
drop if funnyID==1
ta funnyID, m

drop if person_id=="UC212104" & redcap_event_name=="visit_g_arm_1"
drop if person_id=="UC100504" & redcap_event_name=="visit_g_arm_1"
drop if person_id=="UC113603" & redcap_event_name=="visit_a_arm_1"
drop if person_id=="LC019008" & redcap_event_name=="visit_c_arm_1"
drop if person_id=="UC217606" & redcap_event_name=="visit_a_arm_1"
drop if person_id=="LC066003" & redcap_event_name=="visit_c_arm_1"
drop if person_id=="GC021007" & redcap_event_name=="visit_g_arm_1"

replace person_id="LC0534007" if person_id=="LC00534007" & redcap_event_name=="visit_c_arm_1"

*Drop records with same dates
gen tDiff=.
sort person_id date_complete nthRec
by person_id: replace tDiff=date_complete[_n+1]-date_complete[_n] if date_complete!=.
ta tDiff, m

*browse person_id redcap_event_name date_complete igg_tested denv_igg_y chikv_igg_y tDiff if tDiff==0
*browse person_id redcap_event_name date_complete igg_tested denv_igg_y chikv_igg_y  tDiff 

drop if person_id=="KC0188004" & redcap_event_name=="visit_b_arm_1" //this visit does nog have igg data
drop if person_id=="KC0846004" & redcap_event_name=="visit_g_arm_1" //does not matter which visit
drop if person_id=="UC1040304" & redcap_event_name=="visit_g_arm_1" //"
drop if person_id=="UC1051909" & redcap_event_name=="visit_g_arm_1" //"
drop if person_id=="UC2059105" & redcap_event_name=="visit_e_arm_1" //"
drop if person_id=="UC2061804" & redcap_event_name=="visit_b_arm_1" //"
drop if person_id=="UC2061806" & redcap_event_name=="visit_c_arm_1" //" //"
drop if person_id=="UC2062705" & redcap_event_name=="visit_c_arm_1" //"
drop if person_id=="UC2081503" & redcap_event_name=="visit_b_arm_1" //"
drop if person_id=="UC2104504" & redcap_event_name=="visit_c_arm_1" //" //"
drop if person_id=="UC2107006" & redcap_event_name=="visit_b_arm_1" //"
drop if person_id=="UC2112603" & redcap_event_name=="visit_c_arm_1" //"
drop if person_id=="UC2134204" & redcap_event_name=="visit_b_arm_1" //"
drop if person_id=="UC2134205" & redcap_event_name=="visit_b_arm_1" //"
drop if person_id=="UC2134303" & redcap_event_name=="visit_b_arm_1" //"
drop if person_id=="UC2134304" & redcap_event_name=="visit_a_arm_1" //dropped visit without igg data
drop if person_id=="UC2134403" & redcap_event_name=="visit_b_arm_1" //does not matter which visit
drop if person_id=="UC2134404" & redcap_event_name=="visit_b_arm_1" //"

*Check whether everyone is dropped now
drop tDiff
gen tDiff=.
sort person_id date_complete nthRec
by person_id: replace tDiff=date_complete[_n+1]-date_complete[_n] if date_complete!=.
ta tDiff, m

save "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_temp1.dta", replace
clear

*********************************************************************************
*Generate nthRecHCC by person_id and visitnr (so not sorted on date)
*I need this to input missing dates
********************************************************************************	
clear
use "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_temp1.dta"



keep if cohortID==2
drop if visitLetter=="t_"
ta visitnr visitLetter, m
sort person_id visitnr
bysort person_id: gen nthRecHCC=_n
ta nthRecHCC visitLetter, m
keep person_id redcap_event_name nthRecHCC
save "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_nth.dta", replace
clear

********************************************************************************
*Merge nthRecHCC
use "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_temp1.dta"
count

merge m:m person_id redcap_event_name using "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_nth.dta"
ta visitLetter _merge, m

********************************************************************************
**Inpute dates
********************************************************************************

gen date_hcc_input=. 
format date_hcc_input %td

********************************************************************************
*HCC; West; Chulaimbo
*Chulaimbo
*By checking which is the nthRec and visitLetter you can figure out who should be in principle
*considered as a person from initial visit or as a catch-up visit:
*inclusion visit 0 					--> nthRecHCC==1 & visitLetter=a
*inclusion during catch-up visit 0 	--> nthRecHCC==1 & visitLetter=b
*1st follow-up 						--> nthRecHCC==2 & visitLetter=b
*catch-up visit 0 and 1st follow-up were done at the same time, 
*so they will be inputted with the same dates
*the rest is chronologically based on letter

*********************************************************************************
*first visit during first inclusion period
sort date_complete
**browse person_id cohortID nthRecHCC visitLetter2 date_complete if nthRecHCC==1 & visitLetter2=="a_" & siteID==2 & cohortID==2
*(1) Date range found in the dataset: 5 march 2014 - 29 march 2014 AND 14 march 2015 - 1 may 2015
*The persons included in 2015 are probably from the catch-up?
*(2) date range provided by gladys: 5 march 2014 - 29 may 2014
*(3) decision: use Gladys date range
replace date_hcc_input=date("20140105","YMD")+((date("20140529","YMD")-date("20140105","YMD"))/2) if date_complete==. & nthRecHCC==1 & visitLetter2=="a_" & siteID==2 & cohortID==2
list person_id cohortID siteID date_complete nthRecHCC visitLetter2 date_hcc_input if date_complete==. & nthRecHCC==1 & visitLetter2=="a_" & siteID==2 & cohortID==2

*********************************************************************************
*first visit during catch-up
*The dates for the inclusion of this visit was based on all those records with a 'b' visit as a first record
sort date_complete
**browse person_id cohortID nthRecHCC visitLetter2 date_complete if nthRecHCC==1 & visitLetter2=="b_" & siteID==2 & cohortID==2
*14 jan 2015 till 1 may 2015 (These dates coincide with the dates of the first follow-up rpovided by Gladys)
replace date_hcc_input=date("20150114","YMD")+((date("20150501","YMD")-date("20150114","YMD"))/2) if date_complete==. & nthRecHCC==1 & visitLetter2=="b_" & siteID==2 & cohortID==2
list person_id cohortID siteID date_complete nthRecHCC visitLetter2 date_hcc_input if date_complete==. & nthRecHCC==1 & visitLetter2=="b_" & siteID==2 & cohortID==2
*All dates are complete for this site for the catch-up

*********************************************************************************
*1st follow-up visit
sort date_complete
**browse person_id cohortID nthRecHCC visitLetter2 date_complete if nthRecHCC==2 & visitLetter2=="b_" & siteID==2 & cohortID==2
*(1) Date range found in dataset: 14 jan 2015 - 8 september 2015
*(2) Date range provided by Gladys: 14 jan 2015 - 1st may 2015
*(3) We will use the date range provided by Gladys
replace date_hcc_input=date("20150114","YMD")+((date("20150501","YMD")-date("20150114","YMD"))/2) if date_complete==. & nthRecHCC==2 & visitLetter2=="b_" & siteID==2 & cohortID==2
list person_id cohortID siteID date_complete nthRecHCC visitLetter2 date_hcc_input if date_complete==. & nthRecHCC==2 & visitLetter2=="b_" & siteID==2 & cohortID==2

*********************************************************************************
*2nd follow-up visit; 2nd follow-up everyone has a date
*I am not using nthRec anymore, but I am now just going by letter
sort date_complete
**browse person_id cohortID nthRecHCC visitLetter2 date_complete if visitLetter2=="c_" & siteID==2 & cohortID==2
*(1) Data range dataset: 7 sept 2015 - 9 dec 2015
*(2) Date range provided by Gladys: 7 sept 2015 - 9 Dec 2015
*(3) Decision: same date range :)
replace date_hcc_input=date("20150907","YMD")+((date("20151209","YMD")-date("20150907","YMD"))/2) if date_complete==. & visitLetter2=="c_" & siteID==2 & cohortID==2
list person_id cohortID siteID date_complete nthRecHCC visitLetter2 date_hcc_input if date_complete==. & visitLetter2=="c_" & siteID==2 & cohortID==2

*********************************************************************************
*3thfollow-up visit
sort date_complete
**browse person_id cohortID nthRecHCC visitLetter2 date_complete if visitLetter2=="d_" & siteID==2 & cohortID==2
* (1) date range dataset: 5 april 2016 - 31 may 2016 
* (2) date range Gladys: 5 april 2016 - 31 may 2016
* (3) Decision: same :)
replace date_hcc_input=date("20160405","YMD")+((date("20160531","YMD")-date("20160405","YMD"))/2) if date_complete==. & visitLetter2=="d_" & siteID==2 & cohortID==2
list person_id cohortID siteID date_complete nthRecHCC visitLetter2 date_hcc_input if date_complete==. & visitLetter2=="d_" & siteID==2 & cohortID==2

*********************************************************************************
*4thfollow-up visit
sort date_complete
**browse person_id cohortID nthRecHCC visitLetter2 date_complete if visitLetter2=="e_" & siteID==2 & cohortID==2
* (1) date range dataset: 11 oct 2016 - 10 jan 2017
* (2) date range Gladys: 11 oct 2016 - 10 jan 2017
* (3) Decision: same :)
replace date_hcc_input=date("20161011","YMD")+((date("20170110","YMD")-date("20161011","YMD"))/2) if date_complete==. & visitLetter2=="e_" & siteID==2 & cohortID==2
list person_id cohortID redcap_event_name date_complete nthRecHCC date_hcc_input if date_complete==. & visitLetter2=="e_" & siteID==2 & cohortID==2
*Note the individuals to who I am assigning a date, actually are the first or third record in the dataset; 
*that does not make sense; ask Jonathan whether he may be able to check 

*********************************************************************************
*5thfollow-up visit
sort date_complete
**browse person_id cohortID nthRecHCC visitLetter2 date_complete if visitLetter2=="f_" & siteID==2 & cohortID==2
* (1) date range dataset: 3 april 2017 - 22 jun 2017
* (2) date range Gladys: 3 april 2017 - 22 jun 2017
* (3) Decision: same :)
replace date_hcc_input=date("20170403","YMD")+((date("20170622","YMD")-date("20170403","YMD"))/2) if date_complete==. & visitLetter2=="f_" & siteID==2 & cohortID==2
list person_id cohortID redcap_event_name date_complete nthRecHCC date_hcc_input if date_complete==. & visitLetter2=="f_" & siteID==2 & cohortID==2
**browse person_id cohortID siteID date_complete nthRecHCC visitLetter2 date_hcc_input if date_complete==. & visitLetter2=="f_" & siteID==2 & cohortID==2
*Same issue here; it concerns individuals of whom it is the first record?
*person_id
*CC0426006
*CC0725006

*********************************************************************************
*6thfollow-up visit
sort date_complete
**browse person_id cohortID nthRecHCC visitLetter2 date_complete if visitLetter2=="g_" & siteID==2 & cohortID==2
* (1) date range dataset: 2 oct 2017 - 17 jan 2018 + 12 april 2018
* (2) date range Gladys: 2 oct 2017 - 17 jan 2018
* (3) Decision: using date range and ingorning 12th of april 2018
replace date_hcc_input=date("20171002","YMD")+((date("20180117","YMD")-date("20171002","YMD"))/2) if date_complete==. & visitLetter2=="g_" & siteID==2 & cohortID==2
list person_id cohortID siteID date_complete nthRecHCC visitLetter2 date_hcc_input if date_complete==. & visitLetter2=="g_" & siteID==2 & cohortID==2
**browse person_id cohortID siteID date_complete nthRecHCC visitLetter2 date_hcc_input if date_complete==. & visitLetter2=="g_" & siteID==2 & cohortID==2
*Individuals with letter g, of which it is the 1st or 3th record in the dataset

********************************************************************************
**browse person_id cohortID nthRecHCC visitLetter2 date_complete if visitLetter2=="h_" & siteID==1 & cohortID==2
**browse person_id cohortID siteID date_complete nthRecHCC visitLetter2 date_hcc_input if date_complete==. & date_hcc_input==. & siteID==2 & cohortID==2
*For all those that not had a date I was able to generate a proxy


********************************************************************************
*HCC; West; Kisumu

********************************************************************************
*first visit during first inclusion period
sort date_complete
**browse person_id cohortID nthRecHCC visitLetter2 date_complete if nthRecHCC==1 & visitLetter2=="a_" & siteID==1 & cohortID==2
* (1) date range dataset: 8th oct 2014 - 18 dec 2014 and 5th of may 2015 - 17th of aug 2015
* (2) date range Gladys: 8 oct 2014 - 18th of December 2014
* (3) Decision: use first date range
replace date_hcc_input=date("20141008","YMD")+((date("20141218","YMD")-date("20141008","YMD"))/2) if date_complete==. & nthRecHCC==1 & visitLetter2=="a_" & siteID==1 & cohortID==2
list person_id cohortID siteID date_complete nthRecHCC visitLetter2 date_hcc_input if date_complete==. & nthRecHCC==1 & visitLetter2=="a_" & siteID==1 & cohortID==2

********************************************************************************
*first visit during first inclusion at catch-up
*The dates for the inclusion of this visit was based on all those records with a 'b' visit as a first record
sort date_complete
*browse person_id cohortID nthRecHCC visitLetter2 date_complete if nthRecHCC==1 & visitLetter2=="b_" & siteID==1 & cohortID==2
* (1) date range dataset: 8 may 2015 till 21 aug 2015
* (2) date range Gladys: 5 may 2015 - 21 aug 2015
* (3) Decision: Using Gladys date range
replace date_hcc_input=date("20150505","YMD")+((date("20150821","YMD")-date("20150505","YMD"))/2) if date_complete==. & nthRecHCC==1 & visitLetter2=="b_" & siteID==1 & cohortID==2
list person_id cohortID siteID date_complete nthRecHCC visitLetter2 date_hcc_input if date_complete==. & nthRecHCC==1 & visitLetter2=="b_" & siteID==1 & cohortID==2

********************************************************************************
*1st follow-up visit
sort date_complete
*browse person_id cohortID nthRecHCC visitLetter2 date_complete if nthRecHCC==2 & visitLetter2=="b_" & siteID==1 & cohortID==2
* (1) date range dataset: 5 may 2015 - 21 aug 2015
* (2) date range Gladys: 5 may 2015 - 21 aug 2015
* (3) Decision: same
replace date_hcc_input=date("20150505","YMD")+((date("20150821","YMD")-date("20150505","YMD"))/2) if date_complete==. & nthRecHCC==2 & visitLetter2=="b_" & siteID==1 & cohortID==2
list person_id cohortID siteID date_complete nthRecHCC visitLetter2 date_hcc_input if date_complete==. & nthRecHCC==2 & visitLetter2=="b_" & siteID==1 & cohortID==2

********************************************************************************
*2nd follow-up visit; 
sort date_complete
**browse person_id cohortID nthRecHCC visitLetter2 date_complete if visitLetter2=="c_" & siteID==1 & cohortID==2
* (1) date range dataset: 5 jan 2016 - 28 march 2016
* (2) date range Gladys: 5 jan 2016 - 28 march 2016
* (3) Decision: same
replace date_hcc_input=date("20160105","YMD")+((date("20160328","YMD")-date("20160105","YMD"))/2) if date_complete==. & visitLetter2=="c_" & siteID==1 & cohortID==2
list person_id cohortID siteID date_complete nthRecHCC visitLetter2 date_hcc_input if date_complete==. & visitLetter2=="c_" & siteID==1 & cohortID==2

********************************************************************************
*3thfollow-up visit
sort date_complete
**browse person_id cohortID nthRecHCC visitLetter2 date_complete if visitLetter2=="d_" & siteID==1 & cohortID==2
* (1) date range dataset: 5 jul 2016 - 14 jul 2016
* (2) date range Gladys: 5 jul 2016 - 24 sept 2016
* (3) Decision: Used Gladys date range
replace date_hcc_input=date("20160705","YMD")+((date("20160924","YMD")-date("20160705","YMD"))/2) if date_complete==. & visitLetter2=="d_" & siteID==1 & cohortID==2
list person_id cohortID siteID date_complete nthRecHCC visitLetter2 date_hcc_input if date_complete==. & visitLetter2=="d_" & siteID==1 & cohortID==2

********************************************************************************
*4thfollow-up visit
sort date_complete
**browse person_id cohortID nthRecHCC visitLetter2 date_complete if visitLetter2=="e_" & siteID==1 & cohortID==2
* (1) date range dataset: 16 jan 2017 - 29 march 2017
* (2) date range Gladys: 16 jan 2017 - 29 march 2017
* (3) Decision: same
replace date_hcc_input=date("20170116","YMD")+((date("20170329","YMD")-date("20170116","YMD"))/2) if date_complete==. & visitLetter2=="e_" & siteID==1 & cohortID==2
list person_id cohortID redcap_event_name date_complete nthRecHCC date_hcc_input if date_complete==. & visitLetter2=="e_" & siteID==1 & cohortID==2

********************************************************************************
*5thfollow-up visit
sort date_complete
**browse person_id cohortID nthRecHCC visitLetter2 date_complete if visitLetter2=="f_" & siteID==1 & cohortID==2
* (1) date range dataset: 10 jul 2017 - 25 aug 2017
* (2) date range Gladys: 10 jul 2017 - 26 sept 2017
* (3) Decision: used gladys dates
replace date_hcc_input=date("20170710","YMD")+((date("20170926","YMD")-date("20170710","YMD"))/2) if date_complete==. & visitLetter2=="f_" & siteID==1 & cohortID==2
list person_id cohortID redcap_event_name date_complete nthRecHCC date_hcc_input if date_complete==. & visitLetter2=="f_" & siteID==1 & cohortID==2
**browse person_id cohortID siteID date_complete nthRecHCC visitLetter2 date_hcc_input if date_complete==. & visitLetter2=="f_" & siteID==1 & cohortID==2


********************************************************************************
*6thfollow-up visit
sort date_complete
*browse person_id cohortID nthRecHCC visitLetter2 date_complete if visitLetter2=="g_" & siteID==1 & cohortID==2
*There is one record that does not make sense:
*person_id=KC0846004 --> g_	19jul2017
* (1) date range dataset: 8 jan 2018 - 11 april 2018
* (2) date range Gladys: 8 jan 2018 - 11 april 2018
* (3) Decision: same
replace date_hcc_input=date("20180108","YMD")+((date("20180411","YMD")-date("20180108","YMD"))/2) if date_complete==. & visitLetter2=="g_" & siteID==1 & cohortID==2
list person_id cohortID siteID date_complete nthRecHCC visitLetter2 date_hcc_input if date_complete==. & visitLetter2=="g_" & siteID==1 & cohortID==2
**browse person_id cohortID siteID date_complete nthRecHCC visitLetter2 date_hcc_input if date_complete==. & visitLetter2=="g_" & siteID==1 & cohortID==2

*
**browse person_id cohortID nthRecHCC visitLetter2 date_complete if visitLetter2=="h_" & siteID==1 & cohortID==2
**browse person_id cohortID siteID date_complete nthRecHCC visitLetter2 date_hcc_input if date_complete==. & date_hcc_input==. & siteID==1 & cohortID==2

********************************************************************************
*HCC; Rural-coast; Msambweni

********************************************************************************
*first visit during first inclusion period
sort date_complete
**browse person_id cohortID nthRecHCC visitLetter2 date_complete if nthRecHCC==1 & visitLetter2=="a_" & siteID==4 & cohortID==2
* (1) date range dataset: 5 feb 2014 - 3 may 2014
* (2) date range Gladys: 5 feb 2014 - 17 april 2014 + 20-28 april 2014
* (3) Decision: Used date range from dataset (as this is wider)
replace date_hcc_input=date("20140205","YMD")+((date("20140503","YMD")-date("20140205","YMD"))/2) if date_complete==. & nthRecHCC==1 & visitLetter2=="a_" & siteID==4 & cohortID==2
list person_id cohortID siteID date_complete nthRecHCC visitLetter2 date_hcc_input if date_complete==. & nthRecHCC==1 & visitLetter2=="a_" & siteID==4 & cohortID==2

********************************************************************************
*first visit during first inclusion at catch-up
*The dates for the inclusion of this visit was based on all those records with a 'b' visit as a first record
sort date_complete
*browse person_id cohortID nthRecHCC visitLetter2 date_complete if nthRecHCC==1 & visitLetter2=="b_" & siteID==4 & cohortID==2
* (1) date range dataset: 29 jan 2015 - 2 may 2015 + 2 oct 2015
* (2) date range Gladys: 29 jan 2015 - 13 may 2015
* (3) Decision: Using gladys date range
replace date_hcc_input=date("20150129","YMD")+((date("20150513","YMD")-date("20150129","YMD"))/2) if date_complete==. & nthRecHCC==1 & visitLetter2=="b_" & siteID==4 & cohortID==2
list person_id cohortID siteID date_complete nthRecHCC visitLetter2 date_hcc_input if date_complete==. & nthRecHCC==1 & visitLetter2=="b_" & siteID==4 & cohortID==2


********************************************************************************
*1st follow-up visit
sort date_complete
**browse person_id cohortID nthRecHCC visitLetter2 date_complete if nthRecHCC==2 & visitLetter2=="b_" & siteID==4 & cohortID==2
* (1) date range dataset: 29 jan 2015 - 13 may 2015
* (2) date range Gladys: 29 jan 2015 - 13 may 2015
* (3) Decision: same
replace date_hcc_input=date("20150129","YMD")+((date("20150513","YMD")-date("20150129","YMD"))/2) if date_complete==. & nthRecHCC==2 & visitLetter2=="b_" & siteID==4 & cohortID==2
list person_id cohortID siteID date_complete nthRecHCC visitLetter2 date_hcc_input if date_complete==. & nthRecHCC==2 & visitLetter2=="b_" & siteID==4 & cohortID==2

********************************************************************************
*2nd follow-up visit; 
sort date_complete
**browse person_id cohortID nthRecHCC visitLetter2 date_complete if visitLetter2=="c_" & siteID==4 & cohortID==2
* (1) date range dataset: 10 aug 2015 - 4 dec 2015 + 11 april 2015 + 11 may 2015 + 10 jul 2015 + 6 oct 2016
* (2) date range Gladys: 28th September 2015 - 4th of December 2015
* (3) Decision: dataset range because it is wider
replace date_hcc_input=date("20150810","YMD")+((date("20151204","YMD")-date("20150810","YMD"))/2) if date_complete==. & visitLetter2=="c_" & siteID==4 & cohortID==2
list person_id cohortID redcap_event_name date_complete nthRecHCC date_hcc_input if date_complete==. & visitLetter2=="c_" & siteID==4 & cohortID==2
*NOtice these are all individuals of which it is the first record, which does not make sense, ask jonathan

********************************************************************************
*3thfollow-up visit
sort date_complete
*browse person_id cohortID nthRecHCC visitLetter2 date_complete if visitLetter2=="d_" & siteID==4 & cohortID==2
* (1) date range dataset: 12 may 2016 - 8 jul 2016 + 18 aug 2016 + 6 oct 2016
* (2) date range Gladys: 12 may 2016 - 18 aug 2016
* (3) Decision: Used gladys date range
replace date_hcc_input=date("20160512","YMD")+((date("20161018","YMD")-date("20160512","YMD"))/2) if date_complete==. & visitLetter2=="d_" & siteID==4 & cohortID==2
list person_id cohortID siteID date_complete nthRecHCC visitLetter2 date_hcc_input if date_complete==. & visitLetter2=="d_" & siteID==4 & cohortID==2

********************************************************************************
*4thfollow-up visit
sort date_complete
**browse person_id cohortID nthRecHCC visitLetter2 date_complete if visitLetter2=="e_" & siteID==4 & cohortID==2
* (1) date range dataset: 11 oct 2016 - 9 jan 2017
* (2) date range Gladys: 11 oct 2016 - 6th of jan 2017
* (3) Decision: dates observed in dataset as it provided wider interval
replace date_hcc_input=date("20161011","YMD")+((date("20170109","YMD")-date("20161011","YMD"))/2) if date_complete==. & visitLetter2=="e_" & siteID==4 & cohortID==2
list person_id cohortID siteID date_complete nthRecHCC visitLetter2 date_hcc_input if date_complete==. & visitLetter2=="e_" & siteID==4 & cohortID==2
*There are two idea's with id-numbers that are odd:
*GCE0017004 and GCE031005

********************************************************************************
*5thfollow-up visit
sort date_complete
**browse person_id cohortID nthRecHCC visitLetter2 date_complete if visitLetter2=="f_" & siteID==4 & cohortID==2
* (1) date range dataset: 4 april 2017 - 14 jun 2017
* (2) date range Gladys: 4th April 2017 - 14 June 2017
* (3) Decision: same
replace date_hcc_input=date("20170404","YMD")+((date("20170614","YMD")-date("20170404","YMD"))/2) if date_complete==. & visitLetter2=="f_" & siteID==4 & cohortID==2
list person_id cohortID redcap_event_name date_complete nthRecHCC date_hcc_input if date_complete==. & visitLetter2=="f_" & siteID==4 & cohortID==2 & nthRec<5

********************************************************************************
*6thfollow-up visit
sort date_complete
**browse person_id cohortID nthRecHCC visitLetter2 date_complete if visitLetter2=="g_" & siteID==4 & cohortID==2
* (1) date range dataset: 11 oct 2017 - 20 feb 2018
* (2) date range Gladys: 11 oct 2017 - 10 feb 2018
* (3) Decision: dataset range as it is wider
replace date_hcc_input=date("20171011","YMD")+((date("20180220","YMD")-date("20171011","YMD"))/2) if date_complete==. & visitLetter2=="g_" & siteID==4 & cohortID==2
list person_id cohortID siteID date_complete nthRecHCC visitLetter2 date_hcc_input if date_complete==. & visitLetter2=="g_" & siteID==4 & cohortID==2
*browse person_id cohortID siteID date_complete nthRecHCC visitLetter2 date_hcc_input if date_complete==. & visitLetter2=="g_" & siteID==4 & cohortID==2
*again a couple of records of which the letter does not match with the nth visit
*
**browse person_id cohortID nthRecHCC visitLetter2 date_complete if visitLetter2=="h_" & siteID==4 & cohortID==2
**browse person_id cohortID siteID date_complete nthRecHCC visitLetter2 date_hcc_input if date_complete==. & date_hcc_input==. & siteID==4 & cohortID==2

********************************************************************************
*HCC; Urban-coast; Ukunda
********************************************************************************
* (1) date range dataset: xxx
* (2) date range Gladys: xxx
* (3) Decision: xxx

********************************************************************************
*first visit during first inclusion period
sort date_complete
**browse person_id cohortID nthRecHCC visitLetter2 date_complete if nthRecHCC==1 & visitLetter2=="a_" & siteID==3 & cohortID==2
* (1) date range dataset: 18th of September 2014 - 20 aug 2015 + 11 may 2014 + 11 jul 2014 AND 22 jun 2015 - 20 aug 2015 (catch-up)
* (2) date range Gladys: 18th of september 2018 - 19th of December 2014
* (3) Decision: Gladys dates
replace date_hcc_input=date("20140918","YMD")+((date("20141219","YMD")-date("20140918","YMD"))/2) if date_complete==. & nthRecHCC==1 & visitLetter2=="a_" & siteID==3 & cohortID==2
list person_id cohortID siteID date_complete nthRecHCC visitLetter2 date_hcc_input if date_complete==. & nthRecHCC==1 & visitLetter2=="a_" & siteID==3 & cohortID==2

********************************************************************************
*first visit during first inclusion at catch-up
sort date_complete
**browse person_id cohortID nthRecHCC visitLetter2 date_complete if nthRecHCC==1 & visitLetter2=="b_" & siteID==3 & cohortID==2
* (1) date range dataset: 6 may 2015 + 8 may + 8 june 2015 till 29 aug 2015
* (2) date range Gladys: 8 jun 2015 - 21 aug 2015
* (3) Decision: date range 8th june 2016 till 29th of aug 2016
replace date_hcc_input=date("20150506","YMD")+((date("20150829","YMD")-date("20150506","YMD"))/2) if date_complete==. & nthRecHCC==1 & visitLetter2=="b_" & siteID==3 & cohortID==2
list person_id cohortID siteID date_complete nthRecHCC visitLetter2 date_hcc_input if date_complete==. & nthRecHCC==1 & visitLetter2=="b_" & siteID==3 & cohortID==2


********************************************************************************
*1st follow-up visit
sort date_complete
**browse person_id cohortID nthRecHCC visitLetter2 date_complete if nthRecHCC==2 & visitLetter2=="b_" & siteID==3 & cohortID==2
* (1) date range dataset: 29 june 2015 + 8 may + 8 june 2015 till 21 aug 2015 + 8 feb 2016 till 11 feb 2016 + 29 aug 2016 + 26 jan 2017
* (2) date range Gladys: 8 jun 2015 - 21 aug 2015
* (3) Decision: Gladys
replace date_hcc_input=date("20150608","YMD")+((date("20150821","YMD")-date("20150608","YMD"))/2) if date_complete==. & nthRecHCC==2 & visitLetter2=="b_" & siteID==3 & cohortID==2
list person_id cohortID siteID date_complete nthRecHCC visitLetter2 date_hcc_input if date_complete==. & nthRecHCC==2 & visitLetter2=="b_" & siteID==3 & cohortID==2

********************************************************************************
*2nd follow-up visit; 
sort date_complete
**browse person_id cohortID nthRecHCC visitLetter2 date_complete if visitLetter2=="c_" & siteID==3 & cohortID==2
* (1) date range dataset: 1 feb 2016 - 19 april 2016
* (2) date range Gladys: 1 feb 2016 - 19 april 2016
* (3) Decision: same
replace date_hcc_input=date("20160201","YMD")+((date("20160419","YMD")-date("20160201","YMD"))/2) if date_complete==. & visitLetter2=="c_" & siteID==3 & cohortID==2
list person_id cohortID siteID date_complete nthRecHCC visitLetter2 date_hcc_input if date_complete==. & visitLetter2=="c_" & siteID==3 & cohortID==2 & nthRecHCC<2
*Notice these are all individuals of which it is the first record, which does not make sense, ask jonathan


********************************************************************************
*3thfollow-up visit
sort date_complete
**browse person_id cohortID nthRecHCC visitLetter2 date_complete if visitLetter2=="d_" & siteID==3 & cohortID==2
* (1) date range dataset:26 jul 2016 - 26 sept 2016
* (2) date range Gladys: 26 jul 2016 - 26 sept 2017
* (3) Decision: same
replace date_hcc_input=date("20160626","YMD")+((date("20160926","YMD")-date("20160626","YMD"))/2) if date_complete==. & visitLetter2=="d_" & siteID==3 & cohortID==2
list person_id cohortID siteID date_complete nthRecHCC visitLetter2 date_hcc_input if date_complete==. & visitLetter2=="d_" & siteID==3 & cohortID==2

********************************************************************************
*4thfollow-up visit
sort date_complete
**browse person_id cohortID nthRecHCC visitLetter2 date_complete if visitLetter2=="e_" & siteID==3 & cohortID==2
*17 jan 2017 - 28 april 2017
* (1) date range dataset: 17 jan 2017 - 28 april 2017
* (2) date range Gladys: 11 jan 2017 - 28 april 2017
* (3) Decision: Gladys as rang eis wider, to make sure we catch everyone :)
replace date_hcc_input=date("20170111","YMD")+((date("20170428","YMD")-date("20170111","YMD"))/2) if date_complete==. & visitLetter2=="e_" & siteID==3 & cohortID==2
list person_id cohortID siteID date_complete nthRecHCC visitLetter2 date_hcc_input if date_complete==. & visitLetter2=="e_" & siteID==3 & cohortID==2
*All there records are the first record in the dataset, but the corresponding letter is an e?


********************************************************************************
*5thfollow-up visit
sort date_complete
**browse person_id cohortID nthRecHCC visitLetter2 date_complete if visitLetter2=="f_" & siteID==3 & cohortID==2
* (1) date range dataset: 11 jul 2017 - 5 oct 2017
* (2) date range Gladys: 11 jul 2017 - 5th oct 2017
* (3) Decision: same
replace date_hcc_input=date("20170711","YMD")+((date("20171005","YMD")-date("20170711","YMD"))/2) if date_complete==. & visitLetter2=="f_" & siteID==3 & cohortID==2
list person_id cohortID siteID date_complete nthRecHCC visitLetter2 date_hcc_input if date_complete==. & visitLetter2=="f_" & siteID==3 & cohortID==2
*Same here, a lot of visits of which it is the 1st record in the dataset?


********************************************************************************
*6thfollow-up visit
sort date_complete
***browse person_id cohortID nthRecHCC visitLetter2 date_complete if visitLetter2=="g_" & siteID==3 & cohortID==2
* (1) date range dataset: 23 jan 2018 - 11 may 2018
* (2) date range Gladys: 23 jan 2018 - 11th may 2018
* (3) Decision: same
replace date_hcc_input=date("20180123","YMD")+((date("20180511","YMD")-date("20180123","YMD"))/2) if date_complete==. & visitLetter2=="g_" & siteID==3 & cohortID==2
list person_id cohortID siteID date_complete nthRecHCC visitLetter2 date_hcc_input if date_complete==. & visitLetter2=="g_" & siteID==3 & cohortID==2
*browse person_id cohortID siteID date_complete nthRecHCC visitLetter2 date_hcc_input if date_complete==. & visitLetter2=="g_" & siteID==3 & cohortID==2
*most are first record in the dataset?

*
***browse person_id cohortID nthRecHCC visitLetter2 date_complete if visitLetter2=="h_" & siteID==3 & cohortID==2
***browse person_id cohortID siteID date_complete nthRecHCC visitLetter2 date_hcc_input if date_complete==. & date_hcc_input==. & siteID==3 & cohortID==2

********************************************************************************
*Generate categories for the flow-diagrom for the HCC cohort

gen flowHCC=.

*siteID==2 --> Chulaimbo
*Original dates
replace flowHCC=0 if date_complete>=date("20140105","YMD") &  date_complete<=date("20140529","YMD") & nthRecHCC==1 & visitLetter2=="a_" & siteID==2 & cohortID==2

replace flowHCC=0.5 if date_complete>=date("20150114","YMD") &  date_complete<=date("20150501","YMD") & nthRecHCC==1 & visitLetter2=="a_" & siteID==2 & cohortID==2
replace flowHCC=0.5 if date_complete>=date("20150114","YMD") &  date_complete<=date("20150501","YMD") & nthRecHCC==1 & visitLetter2=="b_" & siteID==2 & cohortID==2
	
replace flowHCC=1 if date_complete>=date("20150114","YMD") &  date_complete<=date("20150501","YMD") & nthRecHCC==2 & visitLetter2=="b_" & siteID==2 & cohortID==2
	
replace flowHCC=2 if date_complete>=date("20150907","YMD") &  date_complete<=date("20151209","YMD") & visitLetter2=="c_" & siteID==2 & cohortID==2
replace flowHCC=3 if date_complete>=date("20160405","YMD") &  date_complete<=date("20160531","YMD") & visitLetter2=="d_" & siteID==2 & cohortID==2
replace flowHCC=4 if date_complete>=date("20161011","YMD") &  date_complete<=date("20170110","YMD") & visitLetter2=="e_" & siteID==2 & cohortID==2
replace flowHCC=5 if date_complete>=date("20170403","YMD") &  date_complete<=date("20170622","YMD") & visitLetter2=="f_" & siteID==2 & cohortID==2
replace flowHCC=6 if date_complete>=date("20171002","YMD") &  date_complete<=date("20180117","YMD") & visitLetter2=="g_" & siteID==2 & cohortID==2

*Inputed dates
replace flowHCC=0 if date_hcc_input>=date("20140105","YMD") &  date_hcc_input<=date("20140529","YMD") & nthRecHCC==1 & visitLetter2=="a_" & siteID==2 & cohortID==2

replace flowHCC=0.5 if date_hcc_input>=date("20150114","YMD") &  date_hcc_input<=date("20150501","YMD") & nthRecHCC==1 & visitLetter2=="a_" & siteID==2 & cohortID==2
replace flowHCC=0.5 if date_hcc_input>=date("20150114","YMD") &  date_hcc_input<=date("20150501","YMD") & nthRecHCC==1 & visitLetter2=="b_" & siteID==2 & cohortID==2
	
replace flowHCC=1 if date_hcc_input>=date("20150114","YMD") &  date_hcc_input<=date("20150501","YMD") & nthRecHCC==2 & visitLetter2=="b_" & siteID==2 & cohortID==2
	
replace flowHCC=2 if date_hcc_input>=date("20150907","YMD") &  date_hcc_input<=date("20151209","YMD") & visitLetter2=="c_" & siteID==2 & cohortID==2
replace flowHCC=3 if date_hcc_input>=date("20160405","YMD") &  date_hcc_input<=date("20160531","YMD") & visitLetter2=="d_" & siteID==2 & cohortID==2
replace flowHCC=4 if date_hcc_input>=date("20161011","YMD") &  date_hcc_input<=date("20170110","YMD") & visitLetter2=="e_" & siteID==2 & cohortID==2
replace flowHCC=5 if date_hcc_input>=date("20170403","YMD") &  date_hcc_input<=date("20170622","YMD") & visitLetter2=="f_" & siteID==2 & cohortID==2
replace flowHCC=6 if date_hcc_input>=date("20171002","YMD") &  date_hcc_input<=date("20180117","YMD") & visitLetter2=="g_" & siteID==2 & cohortID==2

*Independent of the letter assigned if flowHCC is empty
replace flowHCC=0 if date_complete>=date("20140105","YMD") &  date_complete<=date("20140529","YMD") & siteID==2 & cohortID==2 & flowHCC==.

replace flowHCC=0.5 if date_complete>=date("20150114","YMD") &  date_complete<=date("20150501","YMD") & siteID==2 & cohortID==2 & flowHCC==.
replace flowHCC=0.5 if date_complete>=date("20150114","YMD") &  date_complete<=date("20150501","YMD") & siteID==2 & cohortID==2 & flowHCC==.
	
replace flowHCC=1 if date_complete>=date("20150114","YMD") &  date_complete<=date("20150501","YMD") & siteID==2 & cohortID==2 & flowHCC==.
	
replace flowHCC=2 if date_complete>=date("20150907","YMD") &  date_complete<=date("20151209","YMD") & siteID==2 & cohortID==2 & flowHCC==.
replace flowHCC=3 if date_complete>=date("20160405","YMD") &  date_complete<=date("20160531","YMD") & siteID==2 & cohortID==2 & flowHCC==.
replace flowHCC=4 if date_complete>=date("20161011","YMD") &  date_complete<=date("20170110","YMD") & siteID==2 & cohortID==2 & flowHCC==.
replace flowHCC=5 if date_complete>=date("20170403","YMD") &  date_complete<=date("20170622","YMD") & siteID==2 & cohortID==2 & flowHCC==.
replace flowHCC=6 if date_complete>=date("20171002","YMD") &  date_complete<=date("20180117","YMD") & siteID==2 & cohortID==2 & flowHCC==.

ta flowHCC siteID if cohortID==2, m
***browse nthRecHCC visitLetter2 date_complete date_hcc_input siteID cohortID if cohortID==2 & siteID==2 & flowHCC==.
*There are 6 records of which the dates and the letters do not match
*nthRecHCC	visitLetter2	date_complete	date_hcc_input	siteID	cohortID
*2	b_	08sep2015		rural west	HCC
*2	b_	08sep2015		rural west	HCC
*2	b_	08sep2015		rural west	HCC
*4	g_	12apr2018		rural west	HCC
*5	g_	12apr2018		rural west	HCC
*5	g_	12apr2018		rural west	HCC

*siteID==1 --> Kisumu
*Using date_complete:
replace flowHCC=0 if date_complete>=date("20141008","YMD") &  date_complete<=date("20141218","YMD") & nthRecHCC==1 & visitLetter2=="a_" & siteID==1 & cohortID==2
	
replace flowHCC=0.5 if date_complete>=date("20150504","YMD") &  date_complete<=date("20150821","YMD") & nthRecHCC==1 & visitLetter2=="a_" & siteID==1 & cohortID==2
replace flowHCC=0.5 if date_complete>=date("20150504","YMD") &  date_complete<=date("20150821","YMD") & nthRecHCC==1 & visitLetter2=="b_" & siteID==1 & cohortID==2
	
replace flowHCC=1 if date_complete>=date("20150505","YMD") &  date_complete<=date("20150821","YMD") & nthRecHCC==2 & visitLetter2=="b_" & siteID==1 & cohortID==2

replace flowHCC=2 if date_complete>=date("20160105","YMD") &  date_complete<=date("20160328","YMD") & visitLetter2=="c_" & siteID==1 & cohortID==2
replace flowHCC=3 if date_complete>=date("20160705","YMD") &  date_complete<=date("20160924","YMD") & visitLetter2=="d_" & siteID==1 & cohortID==2
replace flowHCC=4 if date_complete>=date("20170116","YMD") &  date_complete<=date("20170329","YMD") & visitLetter2=="e_" & siteID==1 & cohortID==2
replace flowHCC=5 if date_complete>=date("20170710","YMD") &  date_complete<=date("20170926","YMD") & visitLetter2=="f_" & siteID==1 & cohortID==2
replace flowHCC=6 if date_complete>=date("20180108","YMD") &  date_complete<=date("20180411","YMD") & visitLetter2=="g_" & siteID==1 & cohortID==2

*Using imputed dates:
replace flowHCC=0 if date_hcc_input>=date("20141008","YMD") &  date_hcc_input<=date("20141218","YMD") & nthRecHCC==1 & visitLetter2=="a_" & siteID==1 & cohortID==2
	
replace flowHCC=0.5 if date_hcc_input>=date("20150504","YMD") &  date_hcc_input<=date("20150821","YMD") & nthRecHCC==1 & visitLetter2=="a_" & siteID==1 & cohortID==2
replace flowHCC=0.5 if date_hcc_input>=date("20150504","YMD") &  date_hcc_input<=date("20150821","YMD") & nthRecHCC==1 & visitLetter2=="b_" & siteID==1 & cohortID==2
	
replace flowHCC=1 if date_hcc_input>=date("20150505","YMD") &  date_hcc_input<=date("20150821","YMD") & nthRecHCC==2 & visitLetter2=="b_" & siteID==1 & cohortID==2

replace flowHCC=2 if date_hcc_input>=date("20160105","YMD") &  date_hcc_input<=date("20160328","YMD") & visitLetter2=="c_" & siteID==1 & cohortID==2
replace flowHCC=3 if date_hcc_input>=date("20160705","YMD") &  date_hcc_input<=date("20160924","YMD") & visitLetter2=="d_" & siteID==1 & cohortID==2
replace flowHCC=4 if date_hcc_input>=date("20170116","YMD") &  date_hcc_input<=date("20170329","YMD") & visitLetter2=="e_" & siteID==1 & cohortID==2
replace flowHCC=5 if date_hcc_input>=date("20170710","YMD") &  date_hcc_input<=date("20170926","YMD") & visitLetter2=="f_" & siteID==1 & cohortID==2
replace flowHCC=6 if date_hcc_input>=date("20180108","YMD") &  date_hcc_input<=date("20180411","YMD") & visitLetter2=="g_" & siteID==1 & cohortID==2

*Independent of letter when flow_hcc is empty
replace flowHCC=0 if date_complete>=date("20141008","YMD") &  date_complete<=date("20141218","YMD") & siteID==1 & cohortID==2 & flowHCC==.
	
replace flowHCC=0.5 if date_complete>=date("20150504","YMD") &  date_complete<=date("20150821","YMD") & siteID==1 & cohortID==2 & flowHCC==.
replace flowHCC=0.5 if date_complete>=date("20150504","YMD") &  date_complete<=date("20150821","YMD") & siteID==1 & cohortID==2 & flowHCC==.
	
replace flowHCC=1 if date_complete>=date("20150505","YMD") &  date_complete<=date("20150821","YMD") & siteID==1 & cohortID==2 & flowHCC==.

replace flowHCC=2 if date_complete>=date("20160105","YMD") &  date_complete<=date("20160328","YMD") & siteID==1 & cohortID==2 & flowHCC==.
replace flowHCC=3 if date_complete>=date("20160705","YMD") &  date_complete<=date("20160924","YMD") & siteID==1 & cohortID==2 & flowHCC==.
replace flowHCC=4 if date_complete>=date("20170116","YMD") &  date_complete<=date("20170329","YMD") & siteID==1 & cohortID==2 & flowHCC==.
replace flowHCC=5 if date_complete>=date("20170710","YMD") &  date_complete<=date("20170926","YMD") & siteID==1 & cohortID==2 & flowHCC==.
replace flowHCC=6 if date_complete>=date("20180108","YMD") &  date_complete<=date("20180411","YMD") & siteID==1 & cohortID==2 & flowHCC==.

ta flowHCC siteID if cohortID==2, m
***browse nthRecHCC visitLetter2 date_complete date_hcc_input siteID cohortID if cohortID==2 & siteID==1 & flowHCC==.
***browse nthRecHCC visitLetter2 date_complete date_hcc_input siteID cohortID if cohortID==2 & siteID==1 & flowHCC==.

*siteID==4 --> Msambweni
*date_complete
replace flowHCC=0 if date_complete>=date("20140205","YMD") &  date_complete<=date("20140503","YMD") & nthRecHCC==1 & visitLetter2=="a_" & siteID==4 & cohortID==2

replace flowHCC=0.5 if date_complete>=date("20150129","YMD") &  date_complete<=date("20150513","YMD") & nthRecHCC==1 & visitLetter2=="a_" & siteID==4 & cohortID==2
replace flowHCC=0.5 if date_complete>=date("20150129","YMD") &  date_complete<=date("20150513","YMD") & nthRecHCC==1 & visitLetter2=="b_" & siteID==4 & cohortID==2

replace flowHCC=1 if date_complete>=date("20150129","YMD") &  date_complete<=date("20150513","YMD") & nthRecHCC==2 & visitLetter2=="b_" & siteID==4 & cohortID==2

replace flowHCC=2 if date_complete>=date("20150810","YMD") &  date_complete<=date("20151204","YMD") & visitLetter2=="c_" & siteID==4 & cohortID==2
replace flowHCC=3 if date_complete>=date("20160512","YMD") &  date_complete<=date("20161018","YMD") & visitLetter2=="d_" & siteID==4 & cohortID==2
replace flowHCC=4 if date_complete>=date("20161011","YMD") &  date_complete<=date("20170109","YMD") & visitLetter2=="e_" & siteID==4 & cohortID==2
replace flowHCC=5 if date_complete>=date("20170404","YMD") &  date_complete<=date("20170614","YMD") & visitLetter2=="f_" & siteID==4 & cohortID==2
replace flowHCC=6 if date_complete>=date("20171011","YMD") &  date_complete<=date("20180220","YMD") & visitLetter2=="g_" & siteID==4 & cohortID==2

*date inputted
replace flowHCC=0 if date_hcc_input>=date("20140205","YMD") &  date_hcc_input<=date("20140503","YMD") & nthRecHCC==1 & visitLetter2=="a_" & siteID==4 & cohortID==2

replace flowHCC=0.5 if date_hcc_input>=date("20150129","YMD") &  date_hcc_input<=date("20150513","YMD") & nthRecHCC==1 & visitLetter2=="a_" & siteID==4 & cohortID==2
replace flowHCC=0.5 if date_hcc_input>=date("20150129","YMD") &  date_hcc_input<=date("20150513","YMD") & nthRecHCC==1 & visitLetter2=="b_" & siteID==4 & cohortID==2

replace flowHCC=1 if date_hcc_input>=date("20150129","YMD") &  date_hcc_input<=date("20150513","YMD") & nthRecHCC==2 & visitLetter2=="b_" & siteID==4 & cohortID==2

replace flowHCC=2 if date_hcc_input>=date("20150810","YMD") &  date_hcc_input<=date("20151204","YMD") & visitLetter2=="c_" & siteID==4 & cohortID==2
replace flowHCC=3 if date_hcc_input>=date("20160512","YMD") &  date_hcc_input<=date("20161018","YMD") & visitLetter2=="d_" & siteID==4 & cohortID==2
replace flowHCC=4 if date_hcc_input>=date("20161011","YMD") &  date_hcc_input<=date("20170109","YMD") & visitLetter2=="e_" & siteID==4 & cohortID==2
replace flowHCC=5 if date_hcc_input>=date("20170404","YMD") &  date_hcc_input<=date("20170614","YMD") & visitLetter2=="f_" & siteID==4 & cohortID==2
replace flowHCC=6 if date_hcc_input>=date("20171011","YMD") &  date_hcc_input<=date("20180220","YMD") & visitLetter2=="g_" & siteID==4 & cohortID==2

*Independent of letter when flow_hcc is empty
replace flowHCC=0 if date_complete>=date("20140205","YMD") &  date_complete<=date("20140503","YMD") & siteID==4 & cohortID==2 & flowHCC==.

replace flowHCC=0.5 if date_complete>=date("20150129","YMD") &  date_complete<=date("20150513","YMD") & siteID==4 & cohortID==2 & flowHCC==.
replace flowHCC=0.5 if date_complete>=date("20150129","YMD") &  date_complete<=date("20150513","YMD") & siteID==4 & cohortID==2 & flowHCC==.

replace flowHCC=1 if date_complete>=date("20150129","YMD") &  date_complete<=date("20150513","YMD") & siteID==4 & cohortID==2 & flowHCC==.

replace flowHCC=2 if date_complete>=date("20150810","YMD") &  date_complete<=date("20151204","YMD") & siteID==4 & cohortID==2 & flowHCC==.
replace flowHCC=3 if date_complete>=date("20160512","YMD") &  date_complete<=date("20161018","YMD") & siteID==4 & cohortID==2 & flowHCC==.
replace flowHCC=4 if date_complete>=date("20161011","YMD") &  date_complete<=date("20170109","YMD") & siteID==4 & cohortID==2 & flowHCC==.
replace flowHCC=5 if date_complete>=date("20170404","YMD") &  date_complete<=date("20170614","YMD") & siteID==4 & cohortID==2 & flowHCC==.
replace flowHCC=6 if date_complete>=date("20171011","YMD") &  date_complete<=date("20180220","YMD") & siteID==4 & cohortID==2 & flowHCC==.

ta flowHCC siteID if cohortID==2, m
***browse nthRecHCC visitLetter2 date_complete date_hcc_input siteID cohortID if cohortID==2 & siteID==4 & flowHCC==.
*Letters do not match inclusion period
*nthRecHCC	visitLetter2	date_complete	date_hcc_input	siteID	cohortID
*1	c_	11apr2015		rural coast	HCC
*1	c_	11may2015		rural coast	HCC
*1	c_	10jul2015		rural coast	HCC
*1	b_	02oct2015		rural coast	HCC
*1	b_	02oct2015		rural coast	HCC
*1	b_	02oct2015		rural coast	HCC
*1	b_	02oct2015		rural coast	HCC
*3	c_	06oct2016		rural coast	HCC


*Ukunda
*Using date_complete
replace flowHCC=0 if date_complete>=date("20140918","YMD") &  date_complete<=date("20141219","YMD") & nthRecHCC==1 & visitLetter2=="a_" & siteID==3 & cohortID==2

replace flowHCC=0.5 if date_complete>=date("20150506","YMD") &  date_complete<=date("20150829","YMD") & nthRecHCC==1 & visitLetter2=="a_" & siteID==3 & cohortID==2
replace flowHCC=0.5 if date_complete>=date("20150506","YMD") &  date_complete<=date("20150829","YMD") & nthRecHCC==1 & visitLetter2=="b_" & siteID==3 & cohortID==2

replace flowHCC=1 if date_complete>=date("20150608","YMD") &  date_complete<=date("20150821","YMD") & nthRecHCC==2 & visitLetter2=="b_" & siteID==3 & cohortID==2

replace flowHCC=2 if date_complete>=date("20160201","YMD") &  date_complete<=date("20160419","YMD") & visitLetter2=="c_" & siteID==3 & cohortID==2
replace flowHCC=3 if date_complete>=date("20160626","YMD") &  date_complete<=date("20160926","YMD") & visitLetter2=="d_" & siteID==3 & cohortID==2
replace flowHCC=4 if date_complete>=date("20170117","YMD") &  date_complete<=date("20170428","YMD") & visitLetter2=="e_" & siteID==3 & cohortID==2
replace flowHCC=5 if date_complete>=date("20170711","YMD") &  date_complete<=date("20171005","YMD") & visitLetter2=="f_" & siteID==3 & cohortID==2
replace flowHCC=6 if date_complete>=date("20180123","YMD") &  date_complete<=date("20180511","YMD") & visitLetter2=="g_" & siteID==3 & cohortID==2

*Using imputted dates
replace flowHCC=0 if date_hcc_input>=date("20140918","YMD") &  date_hcc_input<=date("20141219","YMD") & nthRecHCC==1 & visitLetter2=="a_" & siteID==3 & cohortID==2

replace flowHCC=0.5 if date_hcc_input>=date("20150506","YMD") &  date_hcc_input<=date("20150829","YMD") & nthRecHCC==1 & visitLetter2=="a_" & siteID==3 & cohortID==2
replace flowHCC=0.5 if date_hcc_input>=date("20150506","YMD") &  date_hcc_input<=date("20150829","YMD") & nthRecHCC==1 & visitLetter2=="b_" & siteID==3 & cohortID==2

replace flowHCC=1 if date_hcc_input>=date("20150608","YMD") &  date_hcc_input<=date("20150821","YMD") & nthRecHCC==2 & visitLetter2=="b_" & siteID==3 & cohortID==2

replace flowHCC=2 if date_hcc_input>=date("20160201","YMD") &  date_hcc_input<=date("20160419","YMD") & visitLetter2=="c_" & siteID==3 & cohortID==2
replace flowHCC=3 if date_hcc_input>=date("20160626","YMD") &  date_hcc_input<=date("20160926","YMD") & visitLetter2=="d_" & siteID==3 & cohortID==2
replace flowHCC=4 if date_hcc_input>=date("20170117","YMD") &  date_hcc_input<=date("20170428","YMD") & visitLetter2=="e_" & siteID==3 & cohortID==2
replace flowHCC=5 if date_hcc_input>=date("20170711","YMD") &  date_hcc_input<=date("20171005","YMD") & visitLetter2=="f_" & siteID==3 & cohortID==2
replace flowHCC=6 if date_hcc_input>=date("20180123","YMD") &  date_hcc_input<=date("20180511","YMD") & visitLetter2=="g_" & siteID==3 & cohortID==2

*Independent of letter when flow_hcc is empty
replace flowHCC=0 if date_complete>=date("20140918","YMD") &  date_complete<=date("20141219","YMD") & siteID==3 & cohortID==2 & flowHCC==.

replace flowHCC=0.5 if date_complete>=date("20150506","YMD") &  date_complete<=date("20150829","YMD") & siteID==3 & cohortID==2 & flowHCC==.
replace flowHCC=0.5 if date_complete>=date("20150506","YMD") &  date_complete<=date("20150829","YMD") & siteID==3 & cohortID==2 & flowHCC==.

replace flowHCC=1 if date_complete>=date("20150608","YMD") &  date_complete<=date("20150821","YMD") & siteID==3 & cohortID==2 & flowHCC==.

replace flowHCC=2 if date_complete>=date("20160201","YMD") &  date_complete<=date("20160419","YMD") & siteID==3 & cohortID==2 & flowHCC==.
replace flowHCC=3 if date_complete>=date("20160626","YMD") &  date_complete<=date("20160926","YMD") & siteID==3 & cohortID==2 & flowHCC==.
replace flowHCC=4 if date_complete>=date("20170117","YMD") &  date_complete<=date("20170428","YMD") & siteID==3 & cohortID==2 & flowHCC==.
replace flowHCC=5 if date_complete>=date("20170711","YMD") &  date_complete<=date("20171005","YMD") & siteID==3 & cohortID==2 & flowHCC==.
replace flowHCC=6 if date_complete>=date("20180123","YMD") &  date_complete<=date("20180511","YMD") & siteID==3 & cohortID==2 & flowHCC==.

ta flowHCC siteID if cohortID==2, m
sort date_complete
**browse person_id cohortID siteID nthRecHCC visitLetter2 date_complete date_hcc_input siteID cohortID flowHCC if cohortID==2 & siteID==3 & flowHCC==., nol
*Letters don't match inclusion period, ask jonathan
*cohortID	siteID	nthRecHCC	visitLetter2	date_complete
*HCC	urban coast	2	b_	29jun2014
*HCC	urban coast	2	b_	08may2015
*HCC	urban coast	2	b_	08feb2016
*HCC	urban coast	2	b_	09feb2016
*HCC	urban coast	2	b_	11feb2016
*HCC	urban coast	1	b_	10mar2016
*HCC	urban coast	1	b_	18mar2016
*HCC	urban coast	2	b_	29mar2016
*HCC	urban coast	2	b_	29aug2016
*HCC	urban coast	1	b_	29aug2016
*HCC	urban coast	2	b_	26jan2017
*HCC	urban coast	7	g_	11jul2017
*HCC	urban coast	7	g_	25jul2017


ta flowHCC siteID if cohortID==2, m

*Check whether I have multiple records within every inclusion period
egen rec_0 = total(flowHCC==0), by(person_id)
egen rec_05 = total(flowHCC==0.5), by(person_id)
egen rec_1 = total(flowHCC==1), by(person_id)
egen rec_2 = total(flowHCC==2), by(person_id)
egen rec_3 = total(flowHCC==3), by(person_id)
egen rec_4 = total(flowHCC==4), by(person_id)
egen rec_5 = total(flowHCC==5), by(person_id)
egen rec_6 = total(flowHCC==6), by(person_id)

ta rec_0 if flowHCC==0, m
ta rec_05 if flowHCC==0.5, m
ta rec_1 if flowHCC==1, m
ta rec_2 if flowHCC==2, m
ta rec_3 if flowHCC==3, m
ta rec_4 if flowHCC==4, m
ta rec_5 if flowHCC==5, m
ta rec_6 if flowHCC==6, m

*Generate flowHCC2 that I can use later for graphs, etc
gen flowHCC2=.
replace flowHCC2=0 if flowHCC==0
replace flowHCC2=1 if flowHCC==0.5 //these should be in theory recruited within the same time period as flowHCC==1
replace flowHCC2=1 if flowHCC==1
replace flowHCC2=2 if flowHCC==2
replace flowHCC2=3 if flowHCC==3
replace flowHCC2=4 if flowHCC==4
replace flowHCC2=5 if flowHCC==5
replace flowHCC2=6 if flowHCC==6
ta flowHCC2 flowHCC, m

*Generate flowHCC3 to count pariticipants during each inclusion
gen flowHCC3=.
replace flowHCC3=0 if flowHCC==0
replace flowHCC3=0 if flowHCC==0.5 //these should be in theory recruited within the same time period as flowHCC==1
replace flowHCC3=1 if flowHCC==1
replace flowHCC3=2 if flowHCC==2
replace flowHCC3=3 if flowHCC==3
replace flowHCC3=4 if flowHCC==4
replace flowHCC3=5 if flowHCC==5
replace flowHCC3=6 if flowHCC==6
ta flowHCC3 flowHCC, m

ta flowHCC igg_tested if siteID==1 & cohortID==2, m row
ta flowHCC igg_tested if siteID==2 & cohortID==2, m row
ta flowHCC igg_tested if siteID==3 & cohortID==2, m row
ta flowHCC igg_tested if siteID==4 & cohortID==2, m row

ta flowHCC2 igg_tested if siteID==1 & cohortID==2, m row
ta flowHCC2 igg_tested if siteID==2 & cohortID==2, m row
ta flowHCC2 igg_tested if siteID==3 & cohortID==2, m row
ta flowHCC2 igg_tested if siteID==4 & cohortID==2, m row

********************************************************************************
**Generate an overall data for further analyses
********************************************************************************
gen date_complete2=date_complete
replace date_complete2=date_hcc_input if cohortID==2 & date_complete==.
**browse cohortID person_id date_complete2 date_complete date_hcc_input if date_complete2==.
format date_complete2 %td

********************************************************************************
**Age
********************************************************************************
*With inputed dates we can re-estimate age
drop age ageyrs
gen age=.
replace age=date_complete2-dob2 
replace age=age/365.25
gen ageyrs=int(age)
summ ageyrs, d

********************************************************************************
**Number of follow-up visits
********************************************************************************
egen totVisist = total(cohortID==2), by(person_id)
ta totVisist, m

save "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_step3_complete.dta", replace
clear

********************************************************************************
**Drop when no igg data is available
********************************************************************************
use "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_step3_complete.dta"

*All follow-up analyses will be based on records with igg data
ta igg_tested, m
*browse person_id date_complete2 redcap_event_name denv_igg_y chikv_igg_y if igg_tested==0
keep if igg_tested==1
ta igg_tested, m
ta denv_igg_y, m
ta chikv_igg_y, m
ta denv_igg_y chikv_igg_y, m

egen totRec = total(cohortID==2), by(person_id)
ta totRec, m

*********************************************************************************
*Generate nthRecHCC2 based on records with a date
*********************************************************************************
ta cohortID, m
ta visitLetter, m

sort person_id date_complete2 flowHCC
bysort person_id: gen nthRecHCC2=_n
ta nthRecHCC2 visitLetter, m
ta nthRecHCC2 flowHCC, m
ta nthRecHCC2 igg_tested, m

keep person_id redcap_event_name totRec nthRecHCC2

save "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_step3_complete_totRec.dta", replace
clear

use "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_step3_complete.dta"

drop nthRec*

drop _merge
merge m:1 person_id redcap_event_name using "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_step3_complete_totRec.dta"

ta cohortID, m
ta visitLetter, m

sort person_id visitnr
bysort person_id: gen nthRec=_n
ta nthRecHCC2 visitLetter, m


********************************************************************************
*Serconversion HCC
********************************************************************************
*generate serconversion based on those records with lab test results, 
*vs5: rewrote the code such that the serconversion is stored in the record
*when that person became seropositive, this is more convenient when
*runnig the risk-factor analyses
********************************************************************************

********************************************************************************
*denv_sconv_y_hcc
*The code searches for the next record with igg data in case there was no igg data in the relevant record
*Despite that I dropped everyone with no chikv and denv igg data, there are records
*that e.g. only have DENV but no CHIKV data

gen denv_sconv_y=.
sort person_id nthRecHCC2

browse person_id date_complete2 nthRecHCC2 denv_igg_y denv_sconv_y

forval i=0/8{
*No overwriting allowed ( & denv_sconv_y[_n]==. )
*No serconversion
sort person_id nthRecHCC2
by person_id: replace denv_sconv_y=0 if nthRecHCC2==`i' & denv_igg_y[_n-1]==0 & denv_igg_y[_n]==0 
by person_id: replace denv_sconv_y=0 if nthRecHCC2==`i' & denv_igg_y[_n-2]==0 & denv_igg_y[_n]==0 & denv_sconv_y[_n]==. 
by person_id: replace denv_sconv_y=0 if nthRecHCC2==`i' & denv_igg_y[_n-3]==0 & denv_igg_y[_n]==0 & denv_sconv_y[_n]==. 
by person_id: replace denv_sconv_y=0 if nthRecHCC2==`i' & denv_igg_y[_n-4]==0 & denv_igg_y[_n]==0 & denv_sconv_y[_n]==. 
by person_id: replace denv_sconv_y=0 if nthRecHCC2==`i' & denv_igg_y[_n-5]==0 & denv_igg_y[_n]==0 & denv_sconv_y[_n]==. 
by person_id: replace denv_sconv_y=0 if nthRecHCC2==`i' & denv_igg_y[_n-6]==0 & denv_igg_y[_n]==0 & denv_sconv_y[_n]==. 
by person_id: replace denv_sconv_y=0 if nthRecHCC2==`i' & denv_igg_y[_n-7]==0 & denv_igg_y[_n]==0 & denv_sconv_y[_n]==. 
**browse person_id flowHCC2 nthRecHCC2 visitLetter2 date_complete2 denv_igg_y denv_sconv_y if denv_sconv_y==0 & nthRecHCC2==`i'
**browse person_id flowHCC2 nthRecHCC2 visitLetter2 date_complete2 denv_igg_y denv_sconv_y 
ta denv_sconv_y nthRecHCC2, m
}
forval i=0/8{
*Already seropositive and seropostive at subsequent viist (so serconversion is not possible, censor later)
sort person_id nthRecHCC2
by person_id: replace denv_sconv_y=0 if nthRecHCC2==`i' & denv_igg_y[_n-1]==1 & denv_igg_y[_n]==1 
by person_id: replace denv_sconv_y=0 if nthRecHCC2==`i' & denv_igg_y[_n-2]==1 & denv_igg_y[_n]==1 & denv_sconv_y[_n]==. 
by person_id: replace denv_sconv_y=0 if nthRecHCC2==`i' & denv_igg_y[_n-3]==1 & denv_igg_y[_n]==1 & denv_sconv_y[_n]==. 
by person_id: replace denv_sconv_y=0 if nthRecHCC2==`i' & denv_igg_y[_n-4]==1 & denv_igg_y[_n]==1 & denv_sconv_y[_n]==. 
by person_id: replace denv_sconv_y=0 if nthRecHCC2==`i' & denv_igg_y[_n-5]==1 & denv_igg_y[_n]==1 & denv_sconv_y[_n]==. 
by person_id: replace denv_sconv_y=0 if nthRecHCC2==`i' & denv_igg_y[_n-6]==1 & denv_igg_y[_n]==1 & denv_sconv_y[_n]==. 
by person_id: replace denv_sconv_y=0 if nthRecHCC2==`i' & denv_igg_y[_n-7]==1 & denv_igg_y[_n]==1 & denv_sconv_y[_n]==. 
**browse person_id flowHCC2 nthRecHCC2 visitLetter2 date_complete2 denv_igg_y denv_sconv_y if denv_sconv_y==0 & nthRecHCC2==`i'
**browse person_id flowHCC2 nthRecHCC2 visitLetter2 date_complete2 denv_igg_y denv_sconv_y 
ta denv_sconv_y nthRecHCC2, m
}
forval i=0/8{
*Serorevertors: seropostive initial visit and seronegative at subsequent viist (so serconversion is not possible, censor later)
sort person_id nthRecHCC2
by person_id: replace denv_sconv_y=0 if nthRecHCC2==`i' & denv_igg_y[_n-1]==1 & denv_igg_y[_n]==0 
by person_id: replace denv_sconv_y=0 if nthRecHCC2==`i' & denv_igg_y[_n-2]==1 & denv_igg_y[_n]==0 & denv_sconv_y[_n]==. 
by person_id: replace denv_sconv_y=0 if nthRecHCC2==`i' & denv_igg_y[_n-3]==1 & denv_igg_y[_n]==0 & denv_sconv_y[_n]==. 
by person_id: replace denv_sconv_y=0 if nthRecHCC2==`i' & denv_igg_y[_n-4]==1 & denv_igg_y[_n]==0 & denv_sconv_y[_n]==. 
by person_id: replace denv_sconv_y=0 if nthRecHCC2==`i' & denv_igg_y[_n-5]==1 & denv_igg_y[_n]==0 & denv_sconv_y[_n]==. 
by person_id: replace denv_sconv_y=0 if nthRecHCC2==`i' & denv_igg_y[_n-6]==1 & denv_igg_y[_n]==0 & denv_sconv_y[_n]==. 
by person_id: replace denv_sconv_y=0 if nthRecHCC2==`i' & denv_igg_y[_n-7]==1 & denv_igg_y[_n]==0 & denv_sconv_y[_n]==. 
**browse person_id flowHCC2 nthRecHCC2 visitLetter2 date_complete2 denv_igg_y denv_sconv_y if denv_sconv_y==0 & nthRecHCC2==`i'
**browse person_id flowHCC2 nthRecHCC2 visitLetter2 date_complete2 denv_igg_y denv_sconv_y 
ta denv_sconv_y nthRecHCC2, m
}
forval i=0/8{
*Allow over-writing with '1' when '0', but keep in mind that all in-between visits should be missing to be allowed to use the subsequent visit!
*14/Dec, in between don't need to be missing anymore (altough it will not affect out results) as I am not storing the serconversion in the latest postiive record 
sort person_id date_complete2 nthRecHCC2
by person_id: replace denv_sconv_y=1 if nthRecHCC2==`i' & denv_igg_y[_n-1]==0 & denv_igg_y[_n]==1 
by person_id: replace denv_sconv_y=1 if nthRecHCC2==`i' & denv_igg_y[_n-2]==0 & denv_igg_y[_n]==1 
by person_id: replace denv_sconv_y=1 if nthRecHCC2==`i' & denv_igg_y[_n-3]==0 & denv_igg_y[_n]==1 
by person_id: replace denv_sconv_y=1 if nthRecHCC2==`i' & denv_igg_y[_n-4]==0 & denv_igg_y[_n]==1 
by person_id: replace denv_sconv_y=1 if nthRecHCC2==`i' & denv_igg_y[_n-5]==0 & denv_igg_y[_n]==1 
by person_id: replace denv_sconv_y=1 if nthRecHCC2==`i' & denv_igg_y[_n-6]==0 & denv_igg_y[_n]==1 
by person_id: replace denv_sconv_y=1 if nthRecHCC2==`i' & denv_igg_y[_n-7]==0 & denv_igg_y[_n]==1 
**browse person_id flowHCC2 nthRecHCC2 visitLetter2 date_complete2 denv_igg_y denv_sconv_y denv_sconv_y if denv_sconv_y==1 & nthRecHCC2==`i'
**browse person_id flowHCC2 nthRecHCC2 visitLetter2 date_complete2 denv_igg_y denv_sconv_y denv_sconv_y  
ta denv_sconv_y nthRecHCC2, m
}
*

ta denv_sconv_y nthRecHCC2, m

*First serconversion
gen denv_firstSconv=.
sort person_id date_complete2 nthRecHCC2
by person_id: replace denv_firstSconv=1 if nthRecHCC2==1 & denv_sconv_y==1
by person_id: carryforward denv_firstSconv, replace
by person_id: replace denv_firstSconv=2 if nthRecHCC2==2 & denv_sconv_y==1 & denv_firstSconv[_n-1]==.
by person_id: carryforward denv_firstSconv, replace
by person_id: replace denv_firstSconv=3 if nthRecHCC2==3 & denv_sconv_y==1 & denv_firstSconv[_n-1]==.
by person_id: carryforward denv_firstSconv, replace
by person_id: replace denv_firstSconv=4 if nthRecHCC2==4 & denv_sconv_y==1 & denv_firstSconv[_n-1]==.
by person_id: carryforward denv_firstSconv, replace
by person_id: replace denv_firstSconv=5 if nthRecHCC2==5 & denv_sconv_y==1 & denv_firstSconv[_n-1]==.
by person_id: carryforward denv_firstSconv, replace
by person_id: replace denv_firstSconv=6 if nthRecHCC2==6 & denv_sconv_y==1 & denv_firstSconv[_n-1]==.
by person_id: carryforward denv_firstSconv, replace
by person_id: replace denv_firstSconv=7 if nthRecHCC2==7 & denv_sconv_y==1 & denv_firstSconv[_n-1]==.
by person_id: carryforward denv_firstSconv, replace

*Censor after first serconversion
replace denv_sconv_y=. if nthRecHCC2>denv_firstSconv //there are >1 serconversions within one person

*Seropositive at the beginning
gen denv_sPos1stRec=.
replace denv_sPos1stRec=1 if denv_igg_y==1 & nthRecHCC2==1 
sort person_id nthRecHCC2
by person_id: carryforward denv_sPos1stRec, replace

*Censor individuals seropositive at intake
replace denv_sconv_y=. if denv_sPos1stRec==1

*For analyses we will be using any-serconversion as outcome, as risk factors (except for travelling) do not vary over time
gen denv_sconv_1stRec=.
sort person_id nthRecHCC2
by person_id: replace denv_sconv_1stRec=0 if nthRecHCC2[_n]==1 & denv_sconv_y==0
by person_id: replace denv_sconv_1stRec=0 if nthRecHCC2[_n]==1 & denv_sconv_y[_n+1]==0
by person_id: replace denv_sconv_1stRec=0 if nthRecHCC2[_n]==1 & denv_sconv_y[_n+2]==0
by person_id: replace denv_sconv_1stRec=0 if nthRecHCC2[_n]==1 & denv_sconv_y[_n+3]==0
by person_id: replace denv_sconv_1stRec=0 if nthRecHCC2[_n]==1 & denv_sconv_y[_n+4]==0
by person_id: replace denv_sconv_1stRec=0 if nthRecHCC2[_n]==1 & denv_sconv_y[_n+5]==0
by person_id: replace denv_sconv_1stRec=0 if nthRecHCC2[_n]==1 & denv_sconv_y[_n+6]==0
by person_id: replace denv_sconv_1stRec=0 if nthRecHCC2[_n]==1 & denv_sconv_y[_n+7]==0
*Overwrite with 1
by person_id: replace denv_sconv_1stRec=1 if nthRecHCC2[_n]==1 & denv_sconv_y==1
by person_id: replace denv_sconv_1stRec=1 if nthRecHCC2[_n]==1 & denv_sconv_y[_n+1]==1
by person_id: replace denv_sconv_1stRec=1 if nthRecHCC2[_n]==1 & denv_sconv_y[_n+2]==1
by person_id: replace denv_sconv_1stRec=1 if nthRecHCC2[_n]==1 & denv_sconv_y[_n+3]==1
by person_id: replace denv_sconv_1stRec=1 if nthRecHCC2[_n]==1 & denv_sconv_y[_n+4]==1
by person_id: replace denv_sconv_1stRec=1 if nthRecHCC2[_n]==1 & denv_sconv_y[_n+5]==1
by person_id: replace denv_sconv_1stRec=1 if nthRecHCC2[_n]==1 & denv_sconv_y[_n+6]==1
by person_id: replace denv_sconv_1stRec=1 if nthRecHCC2[_n]==1 & denv_sconv_y[_n+7]==1
*browse person_id nthRecHCC2 denv_sconv_y denv_sconv_1stRec
ta denv_sconv_1stRec denv_sconv_y, m 
ta denv_sconv_1stRec nthRecHCC2, m

*DENV
gen denv_serop_carFrw=.
replace denv_serop_carFrw=1 if denv_igg_y==1
sort person_id nthRecHCC2
bysort person_id: carryforward denv_serop_carFrw, replace
replace denv_serop_carFrw=0 if denv_igg_y==0 & denv_serop_carFrw==.
sort person_id nthRecHCC2
bysort person_id: carryforward denv_serop_carFrw, replace
sort person_id -nthRecHCC2
bysort person_id: carryforward denv_serop_carFrw, replace

********************************************************************************
*chikv_sconv_y
********************************************************************************

gen chikv_sconv_y=.

forval i=0/8{
*No overwriting allowed ( & chikv_sconv_y[_n]==. )
*No serconversion
sort person_id nthRecHCC2
by person_id: replace chikv_sconv_y=0 if nthRecHCC2==`i' & chikv_igg_y[_n-1]==0 & chikv_igg_y[_n]==0 
by person_id: replace chikv_sconv_y=0 if nthRecHCC2==`i' & chikv_igg_y[_n-2]==0 & chikv_igg_y[_n]==0 & chikv_sconv_y[_n]==. 
by person_id: replace chikv_sconv_y=0 if nthRecHCC2==`i' & chikv_igg_y[_n-3]==0 & chikv_igg_y[_n]==0 & chikv_sconv_y[_n]==. 
by person_id: replace chikv_sconv_y=0 if nthRecHCC2==`i' & chikv_igg_y[_n-4]==0 & chikv_igg_y[_n]==0 & chikv_sconv_y[_n]==. 
by person_id: replace chikv_sconv_y=0 if nthRecHCC2==`i' & chikv_igg_y[_n-5]==0 & chikv_igg_y[_n]==0 & chikv_sconv_y[_n]==. 
by person_id: replace chikv_sconv_y=0 if nthRecHCC2==`i' & chikv_igg_y[_n-6]==0 & chikv_igg_y[_n]==0 & chikv_sconv_y[_n]==. 
by person_id: replace chikv_sconv_y=0 if nthRecHCC2==`i' & chikv_igg_y[_n-7]==0 & chikv_igg_y[_n]==0 & chikv_sconv_y[_n]==. 
**browse person_id flowHCC2 nthRecHCC2 visitLetter2 date_complete2 chikv_igg_y chikv_sconv_y if chikv_sconv_y==0 & nthRecHCC2==`i'
**browse person_id flowHCC2 nthRecHCC2 visitLetter2 date_complete2 chikv_igg_y chikv_sconv_y 
ta chikv_sconv_y nthRecHCC2, m

*Already seropositive and seropostive at subsequent viist (so serconversion is not possible, censor later)
sort person_id nthRecHCC2
by person_id: replace chikv_sconv_y=0 if nthRecHCC2==`i' & chikv_igg_y[_n-1]==1 & chikv_igg_y[_n]==1 
by person_id: replace chikv_sconv_y=0 if nthRecHCC2==`i' & chikv_igg_y[_n-2]==1 & chikv_igg_y[_n]==1 & chikv_sconv_y[_n]==. 
by person_id: replace chikv_sconv_y=0 if nthRecHCC2==`i' & chikv_igg_y[_n-3]==1 & chikv_igg_y[_n]==1 & chikv_sconv_y[_n]==. 
by person_id: replace chikv_sconv_y=0 if nthRecHCC2==`i' & chikv_igg_y[_n-4]==1 & chikv_igg_y[_n]==1 & chikv_sconv_y[_n]==. 
by person_id: replace chikv_sconv_y=0 if nthRecHCC2==`i' & chikv_igg_y[_n-5]==1 & chikv_igg_y[_n]==1 & chikv_sconv_y[_n]==. 
by person_id: replace chikv_sconv_y=0 if nthRecHCC2==`i' & chikv_igg_y[_n-6]==1 & chikv_igg_y[_n]==1 & chikv_sconv_y[_n]==. 
by person_id: replace chikv_sconv_y=0 if nthRecHCC2==`i' & chikv_igg_y[_n-7]==1 & chikv_igg_y[_n]==1 & chikv_sconv_y[_n]==. 
**browse person_id flowHCC2 nthRecHCC2 visitLetter2 date_complete2 chikv_igg_y chikv_sconv_y if chikv_sconv_y==0 & nthRecHCC2==`i'
**browse person_id flowHCC2 nthRecHCC2 visitLetter2 date_complete2 chikv_igg_y chikv_sconv_y 
ta chikv_sconv_y nthRecHCC2, m

*Serorevertors: seropostive initial visit and seronegative at subsequent viist (so serconversion is not possible, censor later)
sort person_id nthRecHCC2
by person_id: replace chikv_sconv_y=0 if nthRecHCC2==`i' & chikv_igg_y[_n-1]==1 & chikv_igg_y[_n]==0 
by person_id: replace chikv_sconv_y=0 if nthRecHCC2==`i' & chikv_igg_y[_n-2]==1 & chikv_igg_y[_n]==0 & chikv_sconv_y[_n]==. 
by person_id: replace chikv_sconv_y=0 if nthRecHCC2==`i' & chikv_igg_y[_n-3]==1 & chikv_igg_y[_n]==0 & chikv_sconv_y[_n]==. 
by person_id: replace chikv_sconv_y=0 if nthRecHCC2==`i' & chikv_igg_y[_n-4]==1 & chikv_igg_y[_n]==0 & chikv_sconv_y[_n]==. 
by person_id: replace chikv_sconv_y=0 if nthRecHCC2==`i' & chikv_igg_y[_n-5]==1 & chikv_igg_y[_n]==0 & chikv_sconv_y[_n]==. 
by person_id: replace chikv_sconv_y=0 if nthRecHCC2==`i' & chikv_igg_y[_n-6]==1 & chikv_igg_y[_n]==0 & chikv_sconv_y[_n]==. 
by person_id: replace chikv_sconv_y=0 if nthRecHCC2==`i' & chikv_igg_y[_n-7]==1 & chikv_igg_y[_n]==0 & chikv_sconv_y[_n]==. 
**browse person_id flowHCC2 nthRecHCC2 visitLetter2 date_complete2 chikv_igg_y chikv_sconv_y if chikv_sconv_y==0 & nthRecHCC2==`i'
**browse person_id flowHCC2 nthRecHCC2 visitLetter2 date_complete2 chikv_igg_y chikv_sconv_y 
ta chikv_sconv_y nthRecHCC2, m

*Allow over-writing with '1' when '0',
*Vs8, in between visits do not need to be missing anymore
sort person_id nthRecHCC2
by person_id: replace chikv_sconv_y=1 if nthRecHCC2==`i' & chikv_igg_y[_n-1]==0 & chikv_igg_y[_n]==1 
by person_id: replace chikv_sconv_y=1 if nthRecHCC2==`i' & chikv_igg_y[_n-2]==0 & chikv_igg_y[_n]==1 
by person_id: replace chikv_sconv_y=1 if nthRecHCC2==`i' & chikv_igg_y[_n-3]==0 & chikv_igg_y[_n]==1 
by person_id: replace chikv_sconv_y=1 if nthRecHCC2==`i' & chikv_igg_y[_n-4]==0 & chikv_igg_y[_n]==1 
by person_id: replace chikv_sconv_y=1 if nthRecHCC2==`i' & chikv_igg_y[_n-5]==0 & chikv_igg_y[_n]==1 
by person_id: replace chikv_sconv_y=1 if nthRecHCC2==`i' & chikv_igg_y[_n-6]==0 & chikv_igg_y[_n]==1 
by person_id: replace chikv_sconv_y=1 if nthRecHCC2==`i' & chikv_igg_y[_n-7]==0 & chikv_igg_y[_n]==1 
**browse person_id flowHCC2 nthRecHCC2 visitLetter2 date_complete2 chikv_igg_y chikv_sconv_y chikv_sconv_y if chikv_sconv_y==1 & nthRecHCC2==`i'
**browse person_id flowHCC2 nthRecHCC2 visitLetter2 date_complete2 chikv_igg_y chikv_sconv_y chikv_sconv_y  
ta chikv_sconv_y nthRecHCC2, m
}
*
ta chikv_sconv_y nthRecHCC2, m
**browse person_id flowHCC2 nthRecHCC2 visitLetter2 date_complete2 chikv_igg_y chikv_sconv_y totRec if chikv_igg_y!=. & chikv_igg_y[_n+1]!=. & chikv_sconv_y==. & totRec>1 & totRec!=nthRecHCC2


*First serconversion
gen chikv_firstSconv=.
sort person_id date_complete2 nthRecHCC2
by person_id: replace chikv_firstSconv=1 if nthRecHCC2==1 & chikv_sconv_y==1
by person_id: carryforward chikv_firstSconv, replace
by person_id: replace chikv_firstSconv=2 if nthRecHCC2==2 & chikv_sconv_y==1 & chikv_firstSconv[_n-1]==.
by person_id: carryforward chikv_firstSconv, replace
by person_id: replace chikv_firstSconv=3 if nthRecHCC2==3 & chikv_sconv_y==1 & chikv_firstSconv[_n-1]==.
by person_id: carryforward chikv_firstSconv, replace
by person_id: replace chikv_firstSconv=4 if nthRecHCC2==4 & chikv_sconv_y==1 & chikv_firstSconv[_n-1]==.
by person_id: carryforward chikv_firstSconv, replace
by person_id: replace chikv_firstSconv=5 if nthRecHCC2==5 & chikv_sconv_y==1 & chikv_firstSconv[_n-1]==.
by person_id: carryforward chikv_firstSconv, replace
by person_id: replace chikv_firstSconv=6 if nthRecHCC2==6 & chikv_sconv_y==1 & chikv_firstSconv[_n-1]==.
by person_id: carryforward chikv_firstSconv, replace
by person_id: replace chikv_firstSconv=7 if nthRecHCC2==7 & chikv_sconv_y==1 & chikv_firstSconv[_n-1]==.
by person_id: carryforward chikv_firstSconv, replace
ta chikv_firstSconv, m

*Censor after first serconversion
replace chikv_sconv_y=. if nthRecHCC2>chikv_firstSconv //there are >1 serconversions within one person

*Seropositive at the beginning
gen chikv_sPos1stRec=.
replace chikv_sPos1stRec=1 if chikv_igg_y==1 & nthRecHCC2==1 
sort person_id nthRecHCC2
by person_id: carryforward chikv_sPos1stRec, replace

*Censor individuals seropositive at intake
replace chikv_sconv_y=. if chikv_sPos1stRec==1

*For analyses we will be using any-serconversion as outcome, as risk factors (except for travelling) do not vary over time
gen chikv_sconv_1stRec=.
sort person_id nthRecHCC2
by person_id: replace chikv_sconv_1stRec=0 if nthRecHCC2[_n]==1 & chikv_sconv_y==0
by person_id: replace chikv_sconv_1stRec=0 if nthRecHCC2[_n]==1 & chikv_sconv_y[_n+1]==0
by person_id: replace chikv_sconv_1stRec=0 if nthRecHCC2[_n]==1 & chikv_sconv_y[_n+2]==0
by person_id: replace chikv_sconv_1stRec=0 if nthRecHCC2[_n]==1 & chikv_sconv_y[_n+3]==0
by person_id: replace chikv_sconv_1stRec=0 if nthRecHCC2[_n]==1 & chikv_sconv_y[_n+4]==0
by person_id: replace chikv_sconv_1stRec=0 if nthRecHCC2[_n]==1 & chikv_sconv_y[_n+5]==0
by person_id: replace chikv_sconv_1stRec=0 if nthRecHCC2[_n]==1 & chikv_sconv_y[_n+6]==0
by person_id: replace chikv_sconv_1stRec=0 if nthRecHCC2[_n]==1 & chikv_sconv_y[_n+7]==0
*Overwrite with 1
by person_id: replace chikv_sconv_1stRec=1 if nthRecHCC2[_n]==1 & chikv_sconv_y==1
by person_id: replace chikv_sconv_1stRec=1 if nthRecHCC2[_n]==1 & chikv_sconv_y[_n+1]==1
by person_id: replace chikv_sconv_1stRec=1 if nthRecHCC2[_n]==1 & chikv_sconv_y[_n+2]==1
by person_id: replace chikv_sconv_1stRec=1 if nthRecHCC2[_n]==1 & chikv_sconv_y[_n+3]==1
by person_id: replace chikv_sconv_1stRec=1 if nthRecHCC2[_n]==1 & chikv_sconv_y[_n+4]==1
by person_id: replace chikv_sconv_1stRec=1 if nthRecHCC2[_n]==1 & chikv_sconv_y[_n+5]==1
by person_id: replace chikv_sconv_1stRec=1 if nthRecHCC2[_n]==1 & chikv_sconv_y[_n+6]==1
by person_id: replace chikv_sconv_1stRec=1 if nthRecHCC2[_n]==1 & chikv_sconv_y[_n+7]==1
*browse person_id nthRecHCC2 chikv_sconv_y chikv_sconv_1stRec
ta chikv_sconv_1stRec chikv_sconv_y, m 
ta chikv_sconv_1stRec nthRecHCC2, m

*chikv
gen chikv_serop_carFrw=.
replace chikv_serop_carFrw=1 if chikv_igg_y==1
sort person_id nthRecHCC2
bysort person_id: carryforward chikv_serop_carFrw, replace
replace chikv_serop_carFrw=0 if chikv_igg_y==0 & chikv_serop_carFrw==.
sort person_id nthRecHCC2
bysort person_id: carryforward chikv_serop_carFrw, replace
sort person_id -nthRecHCC2
bysort person_id: carryforward chikv_serop_carFrw, replace

*Person person_id CC0331003 is great to check whether your code worked

********************************************************************************
*Seroreversion HCC
********************************************************************************
*generate sesreversion based on those records with lab test results, 
*note that I will follow
********************************************************************************

********************************************************************************
*denv_srev_y_hcc
*The code searches for the next record with igg data in case there was no igg data in the relevant record
*Despite that I dropped everyone with no chikv and denv igg data, there are records
*that e.g. only have DENV but no CHIKV data

gen denv_srev_y=.
sort person_id date_complete2 nthRecHCC2


forval i=0/8{
*No overwriting allowed ( & denv_srev_y[_n]==. )
*No sesreversion
by person_id: replace denv_srev_y=0 if nthRecHCC2==`i' & denv_igg_y[_n]==0 & denv_igg_y[_n+1]==0 
by person_id: replace denv_srev_y=0 if nthRecHCC2==`i' & denv_igg_y[_n]==0 & denv_igg_y[_n+2]==0 & denv_srev_y[_n]==. 
by person_id: replace denv_srev_y=0 if nthRecHCC2==`i' & denv_igg_y[_n]==0 & denv_igg_y[_n+3]==0 & denv_srev_y[_n]==. 
by person_id: replace denv_srev_y=0 if nthRecHCC2==`i' & denv_igg_y[_n]==0 & denv_igg_y[_n+4]==0 & denv_srev_y[_n]==. 
by person_id: replace denv_srev_y=0 if nthRecHCC2==`i' & denv_igg_y[_n]==0 & denv_igg_y[_n+5]==0 & denv_srev_y[_n]==. 
by person_id: replace denv_srev_y=0 if nthRecHCC2==`i' & denv_igg_y[_n]==0 & denv_igg_y[_n+6]==0 & denv_srev_y[_n]==. 
by person_id: replace denv_srev_y=0 if nthRecHCC2==`i' & denv_igg_y[_n]==0 & denv_igg_y[_n+7]==0 & denv_srev_y[_n]==. 
**browse person_id flowHCC2 nthRecHCC2 visitLetter2 date_complete2 denv_igg_y denv_srev_y if denv_srev_y==0 & nthRecHCC2==`i'
**browse person_id flowHCC2 nthRecHCC2 visitLetter2 date_complete2 denv_igg_y denv_srev_y 
ta denv_srev_y nthRecHCC2, m

*Already seropositive and seropostive at subsequent viist (so sesreversion is not possible, however they should be counted in the denominator)
by person_id: replace denv_srev_y=0 if nthRecHCC2==`i' & denv_igg_y[_n]==1 & denv_igg_y[_n+1]==1 
by person_id: replace denv_srev_y=0 if nthRecHCC2==`i' & denv_igg_y[_n]==1 & denv_igg_y[_n+2]==1 & denv_srev_y[_n]==. 
by person_id: replace denv_srev_y=0 if nthRecHCC2==`i' & denv_igg_y[_n]==1 & denv_igg_y[_n+3]==1 & denv_srev_y[_n]==. 
by person_id: replace denv_srev_y=0 if nthRecHCC2==`i' & denv_igg_y[_n]==1 & denv_igg_y[_n+4]==1 & denv_srev_y[_n]==. 
by person_id: replace denv_srev_y=0 if nthRecHCC2==`i' & denv_igg_y[_n]==1 & denv_igg_y[_n+5]==1 & denv_srev_y[_n]==. 
by person_id: replace denv_srev_y=0 if nthRecHCC2==`i' & denv_igg_y[_n]==1 & denv_igg_y[_n+6]==1 & denv_srev_y[_n]==. 
by person_id: replace denv_srev_y=0 if nthRecHCC2==`i' & denv_igg_y[_n]==1 & denv_igg_y[_n+7]==1 & denv_srev_y[_n]==. 
**browse person_id flowHCC2 nthRecHCC2 visitLetter2 date_complete2 denv_igg_y denv_srev_y if denv_srev_y==0 & nthRecHCC2==`i'
**browse person_id flowHCC2 nthRecHCC2 visitLetter2 date_complete2 denv_igg_y denv_srev_y 
ta denv_srev_y nthRecHCC2, m

*Serorevertors: seropostive initial visit and seronegative at subsequent viist (so sesreversion is not possible, however they should be counted in the denominator)
by person_id: replace denv_srev_y=0 if nthRecHCC2==`i' & denv_igg_y[_n]==0 & denv_igg_y[_n+1]==1 
by person_id: replace denv_srev_y=0 if nthRecHCC2==`i' & denv_igg_y[_n]==0 & denv_igg_y[_n+2]==1 & denv_srev_y[_n]==. 
by person_id: replace denv_srev_y=0 if nthRecHCC2==`i' & denv_igg_y[_n]==0 & denv_igg_y[_n+3]==1 & denv_srev_y[_n]==. 
by person_id: replace denv_srev_y=0 if nthRecHCC2==`i' & denv_igg_y[_n]==0 & denv_igg_y[_n+4]==1 & denv_srev_y[_n]==. 
by person_id: replace denv_srev_y=0 if nthRecHCC2==`i' & denv_igg_y[_n]==0 & denv_igg_y[_n+5]==1 & denv_srev_y[_n]==. 
by person_id: replace denv_srev_y=0 if nthRecHCC2==`i' & denv_igg_y[_n]==0 & denv_igg_y[_n+6]==1 & denv_srev_y[_n]==. 
by person_id: replace denv_srev_y=0 if nthRecHCC2==`i' & denv_igg_y[_n]==0 & denv_igg_y[_n+7]==1 & denv_srev_y[_n]==. 
**browse person_id flowHCC2 nthRecHCC2 visitLetter2 date_complete2 denv_igg_y denv_srev_y if denv_srev_y==0 & nthRecHCC2==`i'
**browse person_id flowHCC2 nthRecHCC2 visitLetter2 date_complete2 denv_igg_y denv_srev_y 
ta denv_srev_y nthRecHCC2, m

*Allow over-writing with '1' when '0', but keep in mind that all in-between visits should be missing to be allowed to use the subsequent visit!
sort person_id date_complete2 nthRecHCC2
by person_id: replace denv_srev_y=1 if nthRecHCC2==`i' & denv_igg_y[_n]==1 & denv_igg_y[_n+1]==0 
by person_id: replace denv_srev_y=1 if nthRecHCC2==`i' & denv_igg_y[_n]==1 & denv_igg_y[_n+1]==. & denv_igg_y[_n+2]==0 
by person_id: replace denv_srev_y=1 if nthRecHCC2==`i' & denv_igg_y[_n]==1 & denv_igg_y[_n+1]==. & denv_igg_y[_n+2]==. & denv_igg_y[_n+3]==0 
by person_id: replace denv_srev_y=1 if nthRecHCC2==`i' & denv_igg_y[_n]==1 & denv_igg_y[_n+1]==. & denv_igg_y[_n+2]==. & denv_igg_y[_n+3]==. & denv_igg_y[_n+4]==0 
by person_id: replace denv_srev_y=1 if nthRecHCC2==`i' & denv_igg_y[_n]==1 & denv_igg_y[_n+1]==. & denv_igg_y[_n+2]==. & denv_igg_y[_n+3]==. & denv_igg_y[_n+4]==. & denv_igg_y[_n+5]==0 
by person_id: replace denv_srev_y=1 if nthRecHCC2==`i' & denv_igg_y[_n]==1 & denv_igg_y[_n+1]==. & denv_igg_y[_n+2]==. & denv_igg_y[_n+3]==. & denv_igg_y[_n+4]==. & denv_igg_y[_n+5]==. & denv_igg_y[_n+6]==0
by person_id: replace denv_srev_y=1 if nthRecHCC2==`i' & denv_igg_y[_n]==1 & denv_igg_y[_n+1]==. & denv_igg_y[_n+2]==. & denv_igg_y[_n+3]==. & denv_igg_y[_n+4]==. & denv_igg_y[_n+5]==. & denv_igg_y[_n+6]==. & denv_igg_y[_n+7]==0 
**browse person_id flowHCC2 nthRecHCC2 visitLetter2 date_complete2 denv_igg_y denv_srev_y denv_srev_y if denv_srev_y==1 & nthRecHCC2==`i'
**browse person_id flowHCC2 nthRecHCC2 visitLetter2 date_complete2 denv_igg_y denv_srev_y denv_srev_y  
ta denv_srev_y nthRecHCC2, m
}
*
ta denv_srev_y denv_sconv_y, m
ta denv_srev_y nthRecHCC2, m

********************************************************************************
*chikv_srev_y

gen chikv_srev_y=.
sort person_id date_complete2 nthRecHCC2

forval i=0/8{
*No overwriting allowed ( & chikv_srev_y[_n]==. )
*No sesreversion
by person_id: replace chikv_srev_y=0 if nthRecHCC2==`i' & chikv_igg_y[_n]==0 & chikv_igg_y[_n+1]==0 
by person_id: replace chikv_srev_y=0 if nthRecHCC2==`i' & chikv_igg_y[_n]==0 & chikv_igg_y[_n+2]==0 & chikv_srev_y[_n]==. 
by person_id: replace chikv_srev_y=0 if nthRecHCC2==`i' & chikv_igg_y[_n]==0 & chikv_igg_y[_n+3]==0 & chikv_srev_y[_n]==. 
by person_id: replace chikv_srev_y=0 if nthRecHCC2==`i' & chikv_igg_y[_n]==0 & chikv_igg_y[_n+4]==0 & chikv_srev_y[_n]==. 
by person_id: replace chikv_srev_y=0 if nthRecHCC2==`i' & chikv_igg_y[_n]==0 & chikv_igg_y[_n+5]==0 & chikv_srev_y[_n]==. 
by person_id: replace chikv_srev_y=0 if nthRecHCC2==`i' & chikv_igg_y[_n]==0 & chikv_igg_y[_n+6]==0 & chikv_srev_y[_n]==. 
by person_id: replace chikv_srev_y=0 if nthRecHCC2==`i' & chikv_igg_y[_n]==0 & chikv_igg_y[_n+7]==0 & chikv_srev_y[_n]==. 
**browse person_id flowHCC2 nthRecHCC2 visitLetter2 date_complete2 chikv_igg_y chikv_srev_y if chikv_srev_y==0 & nthRecHCC2==`i'
**browse person_id flowHCC2 nthRecHCC2 visitLetter2 date_complete2 chikv_igg_y chikv_srev_y 
ta chikv_srev_y nthRecHCC2, m

*Already seropositive and seropostive at subsequent viist (so sesreversion is not possible, however they should be counted in the denominator)
by person_id: replace chikv_srev_y=0 if nthRecHCC2==`i' & chikv_igg_y[_n]==1 & chikv_igg_y[_n+1]==1 
by person_id: replace chikv_srev_y=0 if nthRecHCC2==`i' & chikv_igg_y[_n]==1 & chikv_igg_y[_n+2]==1 & chikv_srev_y[_n]==. 
by person_id: replace chikv_srev_y=0 if nthRecHCC2==`i' & chikv_igg_y[_n]==1 & chikv_igg_y[_n+3]==1 & chikv_srev_y[_n]==. 
by person_id: replace chikv_srev_y=0 if nthRecHCC2==`i' & chikv_igg_y[_n]==1 & chikv_igg_y[_n+4]==1 & chikv_srev_y[_n]==. 
by person_id: replace chikv_srev_y=0 if nthRecHCC2==`i' & chikv_igg_y[_n]==1 & chikv_igg_y[_n+5]==1 & chikv_srev_y[_n]==. 
by person_id: replace chikv_srev_y=0 if nthRecHCC2==`i' & chikv_igg_y[_n]==1 & chikv_igg_y[_n+6]==1 & chikv_srev_y[_n]==. 
by person_id: replace chikv_srev_y=0 if nthRecHCC2==`i' & chikv_igg_y[_n]==1 & chikv_igg_y[_n+7]==1 & chikv_srev_y[_n]==. 
**browse person_id flowHCC2 nthRecHCC2 visitLetter2 date_complete2 chikv_igg_y chikv_srev_y if chikv_srev_y==0 & nthRecHCC2==`i'
**browse person_id flowHCC2 nthRecHCC2 visitLetter2 date_complete2 chikv_igg_y chikv_srev_y 
ta chikv_srev_y nthRecHCC2, m

*Serorevertors: seropostive initial visit and seronegative at subsequent viist (so sesreversion is not possible, however they should be counted in the denominator)
by person_id: replace chikv_srev_y=0 if nthRecHCC2==`i' & chikv_igg_y[_n]==0 & chikv_igg_y[_n+1]==1 
by person_id: replace chikv_srev_y=0 if nthRecHCC2==`i' & chikv_igg_y[_n]==0 & chikv_igg_y[_n+2]==1 & chikv_srev_y[_n]==. 
by person_id: replace chikv_srev_y=0 if nthRecHCC2==`i' & chikv_igg_y[_n]==0 & chikv_igg_y[_n+3]==1 & chikv_srev_y[_n]==. 
by person_id: replace chikv_srev_y=0 if nthRecHCC2==`i' & chikv_igg_y[_n]==0 & chikv_igg_y[_n+4]==1 & chikv_srev_y[_n]==. 
by person_id: replace chikv_srev_y=0 if nthRecHCC2==`i' & chikv_igg_y[_n]==0 & chikv_igg_y[_n+5]==1 & chikv_srev_y[_n]==. 
by person_id: replace chikv_srev_y=0 if nthRecHCC2==`i' & chikv_igg_y[_n]==0 & chikv_igg_y[_n+6]==1 & chikv_srev_y[_n]==. 
by person_id: replace chikv_srev_y=0 if nthRecHCC2==`i' & chikv_igg_y[_n]==0 & chikv_igg_y[_n+7]==1 & chikv_srev_y[_n]==. 
**browse person_id flowHCC2 nthRecHCC2 visitLetter2 date_complete2 chikv_igg_y chikv_srev_y if chikv_srev_y==0 & nthRecHCC2==`i'
**browse person_id flowHCC2 nthRecHCC2 visitLetter2 date_complete2 chikv_igg_y chikv_srev_y 
ta chikv_srev_y nthRecHCC2, m

*Allow over-writing with '1' when '0', but keep in mind that all in-between visits should be missing to be allowed to use the subsequent visit!
sort person_id date_complete2 nthRecHCC2
by person_id: replace chikv_srev_y=1 if nthRecHCC2==`i' & chikv_igg_y[_n]==1 & chikv_igg_y[_n+1]==0 
by person_id: replace chikv_srev_y=1 if nthRecHCC2==`i' & chikv_igg_y[_n]==1 & chikv_igg_y[_n+1]==. & chikv_igg_y[_n+2]==0
by person_id: replace chikv_srev_y=1 if nthRecHCC2==`i' & chikv_igg_y[_n]==1 & chikv_igg_y[_n+1]==. & chikv_igg_y[_n+2]==. & chikv_igg_y[_n+3]==0
by person_id: replace chikv_srev_y=1 if nthRecHCC2==`i' & chikv_igg_y[_n]==1 & chikv_igg_y[_n+1]==. & chikv_igg_y[_n+2]==. & chikv_igg_y[_n+3]==. & chikv_igg_y[_n+4]==0
by person_id: replace chikv_srev_y=1 if nthRecHCC2==`i' & chikv_igg_y[_n]==1 & chikv_igg_y[_n+1]==. & chikv_igg_y[_n+2]==. & chikv_igg_y[_n+3]==. & chikv_igg_y[_n+4]==. & chikv_igg_y[_n+5]==0 
by person_id: replace chikv_srev_y=1 if nthRecHCC2==`i' & chikv_igg_y[_n]==1 & chikv_igg_y[_n+1]==. & chikv_igg_y[_n+2]==. & chikv_igg_y[_n+3]==. & chikv_igg_y[_n+4]==. & chikv_igg_y[_n+5]==. & chikv_igg_y[_n+6]==0
by person_id: replace chikv_srev_y=1 if nthRecHCC2==`i' & chikv_igg_y[_n]==1 & chikv_igg_y[_n+1]==. & chikv_igg_y[_n+2]==. & chikv_igg_y[_n+3]==. & chikv_igg_y[_n+4]==. & chikv_igg_y[_n+5]==. & chikv_igg_y[_n+6]==. & chikv_igg_y[_n+7]==0
**browse person_id flowHCC2 nthRecHCC2 visitLetter2 date_complete2 chikv_igg_y chikv_srev_y chikv_srev_y if chikv_srev_y==1 & nthRecHCC2==`i'
**browse person_id flowHCC2 nthRecHCC2 visitLetter2 date_complete2 chikv_igg_y chikv_srev_y chikv_srev_y  
ta chikv_srev_y nthRecHCC2, m
}
*
ta chikv_srev_y chikv_sconv_y, m
ta chikv_srev_y nthRecHCC2, m
**browse person_id flowHCC2 nthRecHCC2 visitLetter2 date_complete2 chikv_igg_y chikv_srev_y totRec if chikv_igg_y!=. & chikv_igg_y[_n+1]!=. & chikv_srev_y==. & totRec>1 & totRec!=nthRecHCC2
*browse person_id flowHCC2 nthRecHCC2 visitLetter2 date_complete2 chikv_igg_y chikv_sconv_y chikv_srev_y totRec if chikv_srev_y==. & chikv_sconv_y==1
*browse person_id flowHCC2 nthRecHCC2 visitLetter2 date_complete2 chikv_igg_y chikv_sconv_y chikv_srev_y totRec 


********************************************************************************
**House hold characteristics
********************************************************************************
*Most? information is stored in the t-record
*However, as there are sometimes inconsistancies within one person
*we are going to go by record within one person
*Notice you are not going by nthRecHCC2 as this one was created by dropping the patient information visit

*Roof type
ta dem_hoh_roof, m
ta dem_hoh_roof nthRec, m 
*1 Natural material
*2 Corrugated iron
*3 Roofing tiles
*4 Other
*99 refused
ta dem_hoh_other_roof, m

gen roofTypeT=.
forval i=0/8{
sort person_id nthRec
replace roofTypeT=1 if  dem_hoh_roof=="1" & nthRec==`i' & roofTypeT==.
replace roofTypeT=2 if  dem_hoh_roof=="2" & nthRec==`i' & roofTypeT==.
replace roofTypeT=3 if  dem_hoh_roof=="3" & nthRec==`i' & roofTypeT==.
replace roofTypeT=3 if  dem_hoh_roof=="4" & nthRec==`i' & roofTypeT==.
ta roofTypeT dem_hoh_roof, m

sort person_id nthRec
by person_id: carryforward roofTypeT, replace
gsort person_id -nthRec
by person_id: carryforward roofTypeT, replace
sort person_id nthRec
}
* browse person_id redcap_event_name nthRec roofTypeT dem_hoh_roof if roofTypeT!=. & dem_hoh_roof=="NA"
*I first fill-in with the other answers given, when nothing pops-up
ta roofTypeT, m
replace roofTypeT=4 if roofTypeT==. 
ta roofTypeT, m

label define lbl_roofType 1 "natural material" 2 "iron" 3 "other" 4 "missing"
label val roofTypeT lbl_roofType
ta roofTypeT if visitLetter!="t_", m


gen roofTypeT2=.
replace roofTypeT2=1 if roofTypeT==1
replace roofTypeT2=2 if roofTypeT==2
replace roofTypeT2=3 if roofTypeT==3
replace roofTypeT2=3 if roofTypeT==4
label define lbl_roofType2 1 "natural material" 2 "iron" 3 "other/missing"
label val roofTypeT2 lbl_roofType2
ta roofTypeT2 roofTypeT if visitLetter!="t_", m

gen roofTypeT3=.
replace roofTypeT3=1 if roofTypeT==1
replace roofTypeT3=2 if roofTypeT==2
*replace roofTypeT3=3 if roofTypeT==3 //too small to be a separate category
label define lbl_roofType3 1 "natural material" 2 "iron" //3 "other"
label val roofTypeT3 lbl_roofType3
ta roofTypeT3 roofTypeT if visitLetter!="t_", m

********************************************************************************
*Floor type
ta dem_hoh_floor		, m //head of household floor
ta dem_hoh_other_floor	, m
*Note the labels are different for flor_type
*1 dirt/earth
*2 Wood plank
*3 Tile
*4 Cement
*5 Other
*99 refused
ta dem_hoh_floor dem_hoh_other_floor, m



gen floorTypeT=.
forval i=0/8 {
sort person_id nthRec
replace floorTypeT=1 if  dem_hoh_floor=="1" & nthRec==`i' & floorTypeT==.
replace floorTypeT=1 if  dem_hoh_floor=="2" & nthRec==`i' & floorTypeT==.
replace floorTypeT=2 if  dem_hoh_floor=="3" & nthRec==`i' & floorTypeT==.
replace floorTypeT=2 if  dem_hoh_floor=="4" & nthRec==`i' & floorTypeT==.
replace floorTypeT=3 if  dem_hoh_floor=="5" & nthRec==`i' & floorTypeT==.
ta floorTypeT dem_hoh_floor, m

sort person_id nthRec
by person_id: carryforward floorTypeT, replace
gsort person_id -nthRec
by person_id: carryforward floorTypeT, replace
sort person_id date_complete nthRec
}
*
ta floorTypeT, m
replace floorTypeT=4 if floorTypeT==.
ta floorTypeT, m

ta floorTypeT dem_hoh_floor, m
label define lbl_floorType 1 "soft" 2 "hard" 3 "other" 4 "missing"
label val floorTypeT lbl_floorType
ta floorTypeT if visitLetter!="t_", m

gen floorTypeT2=.
replace floorTypeT2=1 if floorTypeT==1
replace floorTypeT2=2 if floorTypeT==2
replace floorTypeT2=3 if floorTypeT==3
replace floorTypeT2=3 if floorTypeT==4
label define lbl_floorType2 1 "soft" 2 "hard" 3 "other/missing"
label val floorTypeT2 lbl_floorType2
ta floorTypeT2 floorTypeT if visitLetter!="t_", m

gen floorTypeT3=.
replace floorTypeT3=1 if floorTypeT==1
replace floorTypeT3=2 if floorTypeT==2
* replace floorTypeT3=3 if floorTypeT==3 //too small to be a separate category
label define lbl_floorType3 1 "soft" 2 "hard" 
label val floorTypeT3 lbl_floorType3
ta floorTypeT3 floorTypeT if visitLetter!="t_", m




*****************************************************************************
**Number of rooms

*dmod$NumRooms <- ifelse(is.na(dmod$rooms_in_house), dmod$dem_hoh_rooms, ifelse(is.na(dmod$dem_hoh_rooms), dmod$rooms_in_house, NA))
ta dem_hoh_rooms, m
replace dem_hoh_rooms="" if dem_hoh_rooms=="NA"
destring dem_hoh_rooms, replace
ta dem_hoh_rooms, m

gen numRoomsT=.
forval i=0/8{
sort person_id nthRec
replace numRoomsT=dem_hoh_rooms  if nthRec==`i' & numRoomsT==.
ta numRoomsT dem_hoh_rooms, m

sort person_id nthRec
by person_id: carryforward numRoomsT, replace
gsort person_id -nthRec
by person_id: carryforward numRoomsT, replace
sort person_id nthRec
}
*
**browse person_id visitLetter date_complete nthRec rooms_in_house if numRoomsT==.
**browse person_id visitLetter date_complete nthRec rooms_in_house 

*I am assuming that more than 10 rooms is most likely a typo, so now categorized as missing
ta numRoomsT, m
replace numRoomsT=. if numRoomsT>=10
ta numRoomsT, m

*Var as category
gen numRoomsCat=.
replace numRoomsCat=1 if numRoomsT>=1 & numRoomsT<3
replace numRoomsCat=2 if numRoomsT>=3 & numRoomsT<7
replace numRoomsCat=3 if numRoomsT>=7 & numRoomsT<10
replace numRoomsCat=4 if numRoomsT==.
ta numRoomsT numRoomsCat , m
label define lbl_numRoomsCat 1 "1-2" 2 "3-6" 3 "7-9" 4 "missing"
label val numRoomsCat lbl_numRoomsCat
ta numRoomsCat if visitLetter!="t_", m

*vs when missing is made real missing
gen numRoomsCat3=.
replace numRoomsCat3=1 if numRoomsT>=1 & numRoomsT<3
replace numRoomsCat3=2 if numRoomsT>=3 & numRoomsT<7
replace numRoomsCat3=3 if numRoomsT>=7 & numRoomsT<10
label define lbl_numRoomsCat3 1 "1-2" 2 "3-6" 3 "7-9" 4 "missing"
label val numRoomsCat3 lbl_numRoomsCat3
ta numRoomsT numRoomsCat3, m
ta numRoomsCat3 if visitLetter!="t_", m

********************************************************************************
*Desity in the house

*Number of people in the household
*dmod$NumPplHouse <- ifelse(is.na(dmod$number_people_in_house), dmod$dem_hoh_live_here, ifelse(is.na(dmod$dem_hoh_live_here), dmod$number_people_in_house, NA))
ta number_people_in_house, m
ta number_sleeping_same_room, m
ta number_windows, m
*Empty
*ta dem_hoh_bedrooms, m --> will be correlated with number of rooms, ignore now

*
ta number_siblings ,m
replace number_siblings="" if number_siblings=="NA"
destring number_siblings, replace
ta number_siblings, m

gen nrSibHT=.
forval i=0/8{
sort person_id nthRec
replace nrSibHT=number_siblings  if nthRec==`i' & nrSibHT==.
ta nrSibHT number_siblings, m
 
sort person_id nthRec
by person_id: carryforward nrSibHT, replace
gsort person_id -nthRec
by person_id: carryforward nrSibHT, replace
sort person_id nthRec
}
*

gen nrSibHCat=.
replace nrSibHCat=1 if nrSibHT>=0 & nrSibHT<4
replace nrSibHCat=2 if nrSibHT>=4 & nrSibHT<7
replace nrSibHCat=3 if nrSibHT>=7 & nrSibHT!=.
replace nrSibHCat=4 if nrSibHCat==.
ta nrSibHT nrSibHCat, m
label define lbl_nrSibH 1 "0-3" 2 "4-6" 3 ">=7" 4 "missing"
label val nrSibHCat lbl_nrSibH
ta nrSibHCat if visitLetter!="t_", m

gen nrSibHCat3=.
replace nrSibHCat3=1 if nrSibHT>=0 & nrSibHT<4
replace nrSibHCat3=2 if nrSibHT>=4 & nrSibHT<7
replace nrSibHCat3=3 if nrSibHT>=7 & nrSibHT!=.
ta nrSibHT nrSibHCat3, m
label define lbl_nrSibH3 1 "0-3" 2 "4-6" 3 ">=7"
label val nrSibHCat3 lbl_nrSibH
ta nrSibHCat3  if visitLetter!="t_", m



*******************************************************************************
*Number of windows
ta dem_hoh_windows, m //How many windows are there in the house?
replace dem_hoh_windows="" if dem_hoh_windows=="NA"
destring dem_hoh_windows, replace
ta dem_hoh_windows, m

ta dem_hoh_windows, m
replace dem_hoh_windows=. if dem_hoh_windows>=24
ta dem_hoh_windows, m

gen nrWndCat=.
forval i=0/8{
sort person_id nthRec
replace nrWndCat=0 if dem_hoh_windows==0 & nthRec==`i' & nrWndCat==. 
replace nrWndCat=1 if dem_hoh_windows==1 & nthRec==`i' & nrWndCat==. 
replace nrWndCat=2 if dem_hoh_windows==2 & nthRec==`i' & nrWndCat==. 
replace nrWndCat=3 if dem_hoh_windows>=3 & dem_hoh_windows!=. & nthRec==`i' & nrWndCat==. 
ta nrWndCat dem_hoh_windows, m

sort person_id nthRec
by person_id: carryforward nrWndCat, replace
gsort person_id -nthRec
by person_id: carryforward nrWndCat, replace
sort person_id nthRec
}
*
replace nrWndCat=4 if nrWndCat==.
label define lbl_nrWndCat 0 "0" 1 "1" 2 "2" 3 ">=3" 4 "missing"
label val nrWndCat lbl_nrWndCat
ta nrWndCat, m


gen nrWndCat3=.
replace nrWndCat3=0 if nrWndCat==0
replace nrWndCat3=1 if nrWndCat==1
replace nrWndCat3=2 if nrWndCat==2
replace nrWndCat3=3 if nrWndCat==3
ta nrWndCat3 nrWndCat, m
label define lbl_nrWndCat3 0 "0" 1 "1" 2 "2" 3 ">=3" 
label val nrWndCat3 lbl_nrWndCat3
ta nrWndCat3 if visitLetter!="t_", m

browse person_id nthRec dem_hoh_windows nrWndCat

gen diffnrWndCat=.
sort person_id nthRec
by person_id: replace diffnrWndCat=1 if nrWndCat[_n]!=nrWndCat[_n+1] & nrWndCat[_n+1]!=. & nrWndCat[_n]!=3 & nrWndCat[_n+1]!=3
ta diffnrWndCat, m
drop diffnrWndCat



*******************************************************************************
*Main light source
ta dem_light_source cohortID, m //light source
*1 Electricity
*2 Pressure lamp
*3 Lantern
*4 Tin lamp
*5 Fuel wood
*6 Solar
*7 Candles
*8 Kerosine
*9 Other
*88 Refused


gen lghtSrT=.
forval i=1/8{
sort person_id nthRec
replace lghtSrT=1 if dem_light_source=="1" & nthRec==`i' & lghtSrT==. 
replace lghtSrT=1 if dem_light_source=="6" & nthRec==`i' & lghtSrT==. 
*other sources
replace lghtSrT=2 if dem_light_source=="2" & nthRec==`i' & lghtSrT==. 
replace lghtSrT=2 if dem_light_source=="3" & nthRec==`i' & lghtSrT==. 
replace lghtSrT=2 if dem_light_source=="4" & nthRec==`i' & lghtSrT==. 
replace lghtSrT=2 if dem_light_source=="5" & nthRec==`i' & lghtSrT==. 
replace lghtSrT=2 if dem_light_source=="7" & nthRec==`i' & lghtSrT==. 
replace lghtSrT=2 if dem_light_source=="8" & nthRec==`i' & lghtSrT==. 
ta lghtSrT dem_light_source, m

sort person_id nthRec
by person_id: carryforward lghtSrT, replace
gsort person_id -nthRec
by person_id: carryforward lghtSrT, replace
sort person_id nthRec
}
replace lghtSrT=3 if lghtSrT==.
ta lghtSrT, m

label define lbl_lghtSrT 1 "elect/solar" 2 "other;paraffin/lantern" 3 "missing"
label val lghtSrT lbl_lghtSrT
ta lghtSrT, m

gen lghtSrT2=.
replace lghtSrT2=1 if lghtSrT==1
replace lghtSrT2=2 if lghtSrT==2
replace lghtSrT2=2 if lghtSrT==3
label define lbl_lghtSrT2 1 "elect/solar" 2 "other & missing"
label val lghtSrT2 lbl_lghtSrT2
ta lghtSrT2 lghtSrT, m
ta lghtSrT2 if visitLetter!="t_", m

gen lghtSrT3=.
replace lghtSrT3=1 if lghtSrT==1
replace lghtSrT3=2 if lghtSrT==2
label define lbl_lghtSrT3 1 "elect/solar" 2 "other;paraffin/lantern" 
label val lghtSrT3 lbl_lghtSrT2
ta lghtSrT3 lghtSrT, m
ta lghtSrT3 if visitLetter!="t_", m

gen difflghtSrT=.
sort person_id nthRec
by person_id: replace difflghtSrT=1 if lghtSrT[_n]!=lghtSrT[_n+1] & lghtSrT[_n+1]!=. & lghtSrT[_n]!=3 & lghtSrT[_n+1]!=3
ta difflghtSrT, m
drop difflghtSrT



********************************************************************************
*Drinking water
ta dem_water_source 
ta dem_other_water_source
*1 Piped house
*2 Piped public
*3 Public well
*4 Rain
*5 River canal
*6 Dam/pond
*7 Borehole
*8 Borehole pump
*9 Other


gen drnkWtSrT=.
forval i=1/8 {
sort person_id nthRec
*Natural source
replace drnkWtSrT=1 if dem_water_source=="4" & nthRec==`i' & drnkWtSrT==. 
replace drnkWtSrT=1 if dem_water_source=="5" & nthRec==`i' & drnkWtSrT==. 
replace drnkWtSrT=1 if dem_water_source=="6" & nthRec==`i' & drnkWtSrT==. 
replace drnkWtSrT=1 if dem_water_source=="7" & nthRec==`i' & drnkWtSrT==. 
replace drnkWtSrT=1 if dem_water_source=="8" & nthRec==`i' & drnkWtSrT==. 
*Well
replace drnkWtSrT=2 if dem_water_source=="3" & nthRec==`i' & drnkWtSrT==. 
*Tap/piped
replace drnkWtSrT=3 if dem_water_source=="1" & nthRec==`i' & drnkWtSrT==. 
replace drnkWtSrT=3 if dem_water_source=="2" & nthRec==`i' & drnkWtSrT==. 
ta drnkWtSrT dem_water_source, m

sort person_id nthRec
by person_id: carryforward drnkWtSrT, replace
gsort person_id -nthRec
by person_id: carryforward drnkWtSrT, replace
sort person_id nthRec
}
ta drnkWtSrT, m
replace drnkWtSrT=4 if drnkWtSrT==.
ta drnkWtSrT, m

label define lbl_drnkWtSrT 1 "natural source" 2 "well" 3 "piped" 4 "missing"
label val drnkWtSrT lbl_drnkWtSrT
ta drnkWtSrT, m

gen drnkWtSrT3=.
replace drnkWtSrT3=1 if drnkWtSrT==1
replace drnkWtSrT3=2 if drnkWtSrT==2
replace drnkWtSrT3=3 if drnkWtSrT==3
label define lbl_drnkWtSrT3 1 "natural source" 2 "well" 3 "piped" 
label val drnkWtSrT3 lbl_drnkWtSrT3
ta drnkWtSrT3 drnkWtSrT, m

gen diffdrnkWtSrT=.
sort person_id nthRec
by person_id: replace diffdrnkWtSrT=1 if drnkWtSrT[_n]!=drnkWtSrT[_n+1] & drnkWtSrT[_n+1]!=. & drnkWtSrT[_n]!=3 & drnkWtSrT[_n+1]!=3
ta diffdrnkWtSrT, m
drop diffdrnkWtSrT



********************************************************************************
*latrine use
ta dem_toilet_latrine , m
ta dem_other_toilet_latrine , m
*0 Flush
*1 Own flush
*2 Shared flush
*3 Traditional pit latrine
*4 Ventilated improved latrine
*5 Bush/ open field
*6 Other
*88 Refused


********************************************************************************
**Generate Type of toilet
gen toiletTypeT=.
forval i=0/8 {
*flush toielet
sort person_id nthRec
replace toiletTypeT=1 if dem_toilet_latrine=="0"	& nthRec==`i' & toiletTypeT==. 
replace toiletTypeT=1 if dem_toilet_latrine=="1"	& nthRec==`i' & toiletTypeT==. 
replace toiletTypeT=1 if dem_toilet_latrine=="2"	& nthRec==`i' & toiletTypeT==. 
*ventilated improved pit latrine (VIP)  or traditional pit latrine
replace toiletTypeT=2 if dem_toilet_latrine=="3"	& nthRec==`i' & toiletTypeT==. 
replace toiletTypeT=2 if dem_toilet_latrine=="4"	& nthRec==`i' & toiletTypeT==. 
*Outside + Bush
replace toiletTypeT=3 if dem_toilet_latrine=="5" 	& nthRec==`i' & toiletTypeT==. 
replace toiletTypeT=3 if dem_toilet_latrine=="6" 	& nthRec==`i' & toiletTypeT==. 
ta toiletTypeT dem_toilet_latrine, m

sort person_id nthRec
by person_id: carryforward toiletTypeT, replace
gsort person_id -nthRec
by person_id: carryforward toiletTypeT, replace
sort person_id nthRec
}
*
ta toiletTypeT, m
replace toiletTypeT=4 if toiletTypeT==.
ta toiletTypeT, m
label define lbl_toiletTypeT  1 "flush"  2 "VIP/pit" 3 "outside/bush" 4 "missing"
label val toiletTypeT lbl_toiletTypeT
ta toiletTypeT, m

gen toiletTypeT3=.
replace toiletTypeT3=1 if toiletTypeT==1
replace toiletTypeT3=2 if toiletTypeT==2
replace toiletTypeT3=3 if toiletTypeT==3
label define lbl_toiletTypeT3  1 "flush"  2 "VIP/pit" 3 "outside/bush"
label val toiletTypeT3 lbl_toiletTypeT3
ta toiletTypeT3 toiletTypeT, m

gen difftoiletTypeT=.
sort person_id nthRec
by person_id: replace difftoiletTypeT=1 if toiletTypeT[_n]!=toiletTypeT[_n+1] & toiletTypeT[_n+1]!=. & toiletTypeT[_n]!=3 & toiletTypeT[_n+1]!=3
ta difftoiletTypeT, m
drop difftoiletTypeT



********************************************************************************
**Generate distance to toilet, this var is only existant for hcc cohort
ta dem_latrine_location, m //latrine location
ta dem_latrine_location siteID, m //latrine location
*1 Inside your house
*2 Outside with water
*3 Outside without water
*4 No Toilet
*5 Other
*8 Refused

ta dem_latrine_location nthRec, m
ta dem_latrine_location visitLetter2, m

*Everything is stored in the patient information visit;
*For all above variables I did not check that, so it might
*have been easier without the loop (I will leave it like that for now)

gen toiletPosT=.
*Inside
replace toiletPosT=1 if dem_latrine_location=="1" 
*Outside
replace toiletPosT=2 if dem_latrine_location=="2" 
replace toiletPosT=2 if dem_latrine_location=="3" 
replace toiletPosT=2 if dem_latrine_location=="4" 
ta toiletPosT dem_latrine_location, m

sort person_id nthRec
by person_id: carryforward toiletPosT, replace
gsort person_id -nthRec
by person_id: carryforward toiletPosT, replace
sort person_id nthRec

ta toiletPosT, m
replace toiletPosT=3 if toiletPosT==.
ta toiletPosT, m

label define lbl_toiletPosT 1 "Inside" 2 "Oustide" 3 "missing"
label val toiletPosT lbl_toiletPosT
ta toiletPosT, m

gen toiletPosT3=.
replace toiletPosT3=1 if toiletPosT==1
replace toiletPosT3=2 if toiletPosT==2
label define lbl_toiletPosT3 1 "Inside" 2 "Oustide"
label val toiletPosT3 lbl_toiletPosT3
ta toiletPosT toiletPosT3, m

*An extra last chec
gen difftoiletPosT=.
sort person_id nthRec
bysort person_id: replace difftoiletPosT=1 if toiletPosT[_n]!=toiletPosT[_n+1] & toiletPosT[_n+1]!=. 
ta difftoiletPosT, m

*******************************************************************************
*SES
*******************************************************************************

********************************************************************************
ta mom_highest_level_education, m //What is the mom's highest level of  education?
ta oth_mom_educ_level, m
replace mom_highest_level_education="" if mom_highest_level_education=="NA"
ta mom_highest_level_education, m
destring mom_highest_level_education, replace
ta mom_highest_level_education, m
ta mom_highest_level_education nthRec, m //stored in a lot of records!!!
*1 Primary school
*2 Secondary school
*3 Technical college
*4 Professional degree
*5 Other
*9 N/A


gen momEducT=.
forval i=1/8{
*replace momEducT=1 	if mom_highest_level_education==9 & nthRec==`i' & momEducT==. 
sort person_id nthRec
replace momEducT=2 	if mom_highest_level_education==1 & nthRec==`i' & momEducT==. 
replace momEducT=3 	if mom_highest_level_education==2 & nthRec==`i' & momEducT==. 
replace momEducT=4 	if mom_highest_level_education==3 & mom_highest_level_education==4 & nthRec==`i' & momEducT==. 
ta momEducT mom_highest_level_education, m

sort person_id nthRec
by person_id: carryforward momEducT, replace
gsort person_id -nthRec
by person_id: carryforward momEducT, replace
sort person_id nthRec
}
ta momEducT, m
replace momEducT=1 if momEducT==.
ta momEducT, m
*Notice that I am blending the "other" category into no education (this category is too small to handle as one group)
*You can also choose to make them missing
*
label define  lbl_modEduc 1 "no educ" 2 "primary school" 3 "secondary school" 4 "technical+professional"
label val momEducT lbl_modEduc
ta momEducT, m

gen diffmomEducT=.
sort person_id nthRec
by person_id: replace diffmomEducT=1 if momEducT[_n]!=momEducT[_n+1] & momEducT[_n+1]!=. & momEducT[_n]!=3 & momEducT[_n+1]!=3
ta diffmomEducT, m
drop diffmomEducT



*******************************************************************************
*dem_own_telephone
ta dem_own_telephone, m //own dem_own_telephone
*1 Yes
*0 No
*8 Refused


gen telphnT=.
forval i=1/8{
sort person_id nthRec
replace telphnT=0 if dem_own_telephone=="0"		& nthRec==`i' & telphnT==. 
replace telphnT=1 if dem_own_telephone=="1"		& nthRec==`i' & telphnT==. 
ta telphnT dem_own_telephone, m

sort person_id nthRec
by person_id: carryforward telphnT, replace
gsort person_id -nthRec
by person_id: carryforward telphnT, replace
sort person_id nthRec
ta telphnT, m
}
*
ta telphnT, m
replace telphnT=2 if telphnT==.
ta telphnT, m

label define lbl_telphnT 0 "no" 1 "yes" 2 "missing"
label val telphnT lbl_telphnT
ta telphnT, m

gen telphnT3=.
replace telphnT3=0 if telphnT==0
replace telphnT3=1 if telphnT==1
label define lbl_telphnT3 0 "no" 1 "yes" 
label val telphnT3 lbl_telphnT3
ta telphnT3 telphnT, m
ta telphnT3, m

gen difftelphnT=.
sort person_id nthRec
by person_id: replace difftelphnT=1 if telphnT[_n]!=telphnT[_n+1] & telphnT[_n+1]!=. & telphnT[_n]!=3 & telphnT[_n+1]!=3
ta difftelphnT, m
drop difftelphnT


*******************************************************************************
*dem_own_radio
ta dem_own_radio, m //own dem_own_radio
*1 Yes
*0 No
*8 Refused

gen radioT=.
forval i=1/8{
sort person_id nthRec
replace radioT=0 if dem_own_radio=="0"	& nthRec==`i' & radioT==. 
replace radioT=1 if dem_own_radio=="1"	& nthRec==`i' & radioT==. 
ta radioT dem_own_radio, m

sort person_id nthRec
by person_id: carryforward radioT, replace
gsort person_id -nthRec
by person_id: carryforward radioT, replace
sort person_id nthRec
}
*
ta radioT, m
replace radioT=2 if radioT==.
ta radioT, m
label define lbl_radioT 0 "no" 1 "yes" 2 "missing"
label val radioT lbl_radioT
ta radioT, m

gen radioT3=.
replace radioT3=0 if radioT==0
replace radioT3=1 if radioT==1
label define lbl_radioT3 0 "no" 1 "yes" 
label val radioT3 lbl_radioT3
ta radioT3 radioT, m

gen diffradioT=.
sort person_id nthRec
by person_id: replace diffradioT=1 if radioT[_n]!=radioT[_n+1] & radioT[_n+1]!=. & radioT[_n]!=3 & radioT[_n+1]!=3
ta diffradioT, m
drop diffradioT


*******************************************************************************
*dem_own_tv
ta dem_own_tv, m //dem_own_tv
*1 Yes
*0 No
*8 Refused

gen tvT=.
forval i=1/8{
sort person_id nthRec
replace tvT=0 if dem_own_tv=="0" & nthRec==`i' & tvT==. 
replace tvT=1 if dem_own_tv=="1" & nthRec==`i' & tvT==. 
ta tvT dem_own_tv, m

sort person_id nthRec
by person_id: carryforward tvT, replace
gsort person_id -nthRec
by person_id: carryforward tvT, replace
sort person_id nthRec
}
*
ta tvT, m
replace tvT=2 if tvT==.
ta tvT, m

label define lbl_tvT 0 "no" 1 "yes" 2 "missing"
label val tvT lbl_tvT
ta tvT, m

gen tvT3=.
replace tvT3=0 if tvT==0
replace tvT3=1 if tvT==1
label define lbl_tvT3 0 "no" 1 "yes" 
label val tvT3 lbl_tvT3
ta tvT3 tvT, m

gen difftvT=.
sort person_id nthRec
by person_id: replace difftvT=1 if tvT[_n]!=tvT[_n+1] & tvT[_n+1]!=. & tvT[_n]!=3 & tvT[_n+1]!=3
ta difftvT, m
drop difftvT

*******************************************************************************
*dem_own_bicycle
ta dem_own_bicycle, m //own dem_own_bicycle
*1 Yes
*0 No
*8 Refused

gen bicycleT=.
forval i=1/8{
replace bicycleT=0 if dem_own_bicycle=="0"	& nthRec==`i' & bicycleT==. 
replace bicycleT=1 if dem_own_bicycle=="1"	& nthRec==`i' & bicycleT==. 
ta bicycleT dem_own_bicycle, m

sort person_id nthRec
by person_id: carryforward bicycleT, replace
gsort person_id -nthRec
by person_id: carryforward bicycleT, replace
sort person_id nthRec
ta bicycleT, m
}
*
ta bicycleT, m
replace bicycleT=2 if bicycleT==.
ta bicycleT, m
label define lbl_bicycleT 0 "no" 1 "yes" 2 "missing"
label val bicycleT lbl_bicycleT
ta bicycleT, m

gen bicycleT3=.
replace bicycleT3=0 if bicycleT==0
replace bicycleT3=1 if bicycleT==1
label define lbl_bicycleT3 0 "no" 1 "yes"
label val bicycleT3 lbl_bicycleT3
ta bicycleT3 bicycleT, m

gen diffbicycleT=.
sort person_id nthRec
by person_id: replace diffbicycleT=1 if bicycleT[_n]!=bicycleT[_n+1] & bicycleT[_n+1]!=. & bicycleT[_n]!=3 & bicycleT[_n+1]!=3
ta diffbicycleT, m
drop diffbicycleT


*******************************************************************************
*MotorCycle
ta dem_motor_vehicle, m
*1 Yes
*0 No
*8 Refused

gen motorT=.
forval i=1/8{
sort person_id nthRec
replace motorT=0 if dem_motor_vehicle=="0"	& nthRec==`i' & motorT==. 
replace motorT=1 if dem_motor_vehicle=="1"	& nthRec==`i' & motorT==. 
ta motorT dem_motor_vehicle, m

sort person_id nthRec
by person_id: carryforward motorT, replace
gsort person_id -nthRec
by person_id: carryforward motorT, replace
sort person_id nthRec
ta motorT, m
}
*
ta motorT, m
replace motorT=2 if motorT==.
ta motorT, m
label define lbl_motorT 0 "no" 1 "yes" 2 "missing"
label val motorT lbl_motorT
ta motorT, m

gen motorT3=.
replace motorT3=0 if motorT==0
replace motorT3=1 if motorT==1
label define lbl_motorT3 0 "no" 1 "yes" 
label val motorT3 lbl_motorT3
ta motorT3 motorT, m

gen diffmotorT=.
sort person_id nthRec
by person_id: replace diffmotorT=1 if motorT[_n]!=motorT[_n+1] & motorT[_n+1]!=. & motorT[_n]!=3 & motorT[_n+1]!=3
ta diffmotorT, m
drop diffmotorT


*******************************************************************************
*Domestic worker
ta dem_domestic_worker, m //domestic worker
*1 Yes 0 No 8 Refused

gen domesticT=.
forval i=1/8{
sort person_id nthRec
replace domesticT=0 if dem_domestic_worker=="0"	& nthRec==`i' & domesticT==. 
replace domesticT=1 if dem_domestic_worker=="1"	& nthRec==`i' & domesticT==. 
ta domesticT dem_domestic_worker, m

sort person_id nthRec
by person_id: carryforward domesticT, replace
gsort person_id -nthRec
by person_id: carryforward domesticT, replace
sort person_id nthRec
}
*
ta domesticT, m
replace domesticT=2 if domesticT==.
ta domesticT, m
label define lbl_domesticT 0 "no" 1 "yes" 2 "missing"
label val domesticT lbl_domesticT
ta domesticT , m

gen domesticT3=.
replace domesticT3=0 if domesticT==0
replace domesticT3=1 if domesticT==1
label define lbl_domesticT3 0 "no" 1 "yes" 
label val domesticT3 lbl_domesticT3
ta domesticT3 domesticT, m

gen diffdomesticT3=.
sort person_id nthRec
by person_id: replace diffdomesticT3=1 if domesticT3[_n]!=domesticT3[_n+1] & domesticT3[_n+1]!=. & domesticT3[_n]!=3 & domesticT3[_n+1]!=3
ta diffdomesticT3, m
drop diffdomesticT3



********************************************************************************
***Amy's syntax on ses
*ses<-(malaria_climate[, grepl("telephone|radio|television|bicycle|motor_vehicle|domestic_worker", names(malaria_climate))])

egen ses=rmean(telphnT3 radioT3 tvT3 bicycleT3 motorT3 domesticT3)
ta ses if visitLetter!="t_", m
**browse person_id telphnT3 radioT3 tvT3 bicycleT3 motorT3 domesticT3 ses if  telphnT3==. | telphnT3==. | bicycleT3==. | motorT3==. | domesticT3==.

gen sesCat=.
replace sesCat=1 if ses<0.25
replace sesCat=2 if ses>=0.25 & ses<0.75
replace sesCat=3 if ses>=0.75 & ses!=.
replace sesCat=4 if ses==.

label define lbl_sesCat 1 "0-2 assests" 2 "3 assets" 3 "4-5 assets" 4 "missing"
label val sesCat lbl_sesCat
ta sesCat, m

gen sesCat3=.
replace sesCat3=1 if ses<0.25
replace sesCat3=2 if ses>=0.25 & ses<0.75
replace sesCat3=3 if ses>=0.75 & ses!=.
label define lbl_sesCat3 1 "0-2 assests" 2 "3 assets" 3 "4-5 assets" 
label val sesCat3 lbl_sesCat3
ta ses sesCat3, m
ta sesCat3, m

gen diffses=.
sort person_id nthRec
by person_id: replace diffses=1 if ses[_n]!=ses[_n+1] & ses[_n+1]!=. & ses[_n]!=3 & ses[_n+1]!=3
ta diffses, m
drop diffses
 

 
 
 
 
 
 
 
 
********************************************************************************
********************************************************************************
****Mosquito exposure and preventive behavior - DENV	
********************************************************************************
********************************************************************************
*These are variables that vary over time



********************************************************************************
*Outdoor activities
ta outdoor_activity, m
*0 No
*1 Yes
*8 Refused

ta outdoor_activity nthRec, m
ta outdoor_activity visitLetter2, m

gen outdoorActyT=.
replace outdoorActyT=0 if outdoor_activity=="0"
replace outdoorActyT=1 if outdoor_activity=="1"
ta outdoorActyT outdoor_activity, m

sort person_id nthRec
by person_id: carryforward outdoorActyT, replace
gsort person_id -nthRec
by person_id: carryforward outdoorActyT, replace
sort person_id nthRec

label define lbl_outdoorActyT 0 "No" 1 "Yes" 2"missing"
label val outdoorActyT lbl_outdoorActyT
ta outdoorActyT, m

gen outdoorActyT3=.
replace outdoorActyT3=0 if outdoorActyT==0
replace outdoorActyT3=1 if outdoorActyT==1
label define lbl_outdoorActyT3 0 "No" 1 "Yes"
label val outdoorActyT3 lbl_outdoorActyT3
ta outdoorActyT outdoorActyT3, m

*An extra last chec
gen diffoutdoorActyT=.
sort person_id nthRec
bysort person_id: replace diffoutdoorActyT=1 if outdoorActyT[_n]!=outdoorActyT[_n+1] & outdoorActyT[_n+1]!=. 
ta diffoutdoorActyT, m

********************************************************************************
*Self-reported mosquito bites

ta mosquito_bites, m
*1 Yes
*0 No
*8 Refused

ta mosquito_bites nthRec, m
ta mosquito_bites visitLetter2, m

*everything is stored in the same recorde/a-visit

gen msqtBitesT=.
replace msqtBitesT=0 if mosquito_bites=="0"
replace msqtBitesT=1 if mosquito_bites=="1"

sort person_id nthRec
by person_id: carryforward msqtBitesT, replace
gsort person_id -nthRec
by person_id: carryforward msqtBitesT, replace
sort person_id nthRec

ta msqtBitesT, m
replace msqtBitesT=2 if msqtBitesT==.
ta msqtBitesT, m

label define lbl_msqtBitesT 0 "No" 1 "Yes" 2"missing"
label val msqtBitesT lbl_msqtBitesT
ta msqtBitesT, m
*browse person_id  date_complete nthRecAIC Acute denv_pcr_y mosquito_bites_aic msqtBitesT

gen msqtBitesT3=.
replace msqtBitesT3=0 if msqtBitesT==0
replace msqtBitesT3=1 if msqtBitesT==1
label define lbl_msqtBitesT3 0 "No" 1 "Yes"
label val msqtBitesT3 lbl_msqtBitesT3
ta msqtBitesT msqtBitesT3, m

gen diffmsqtBitesT=.
sort person_id nthRec
bysort person_id : replace diffmsqtBitesT=1 if msqtBitesT[_n]!=msqtBitesT[_n+1] & msqtBitesT[_n+1]!=. 
ta diffmsqtBitesT, m
drop diffmsqtBitesT	



*********************************************************************************
*Mosquito coil

ta mosquito_coil, m //Does the child use a mosquito coil to avoid mosquitoes?
*1 Yes
*0 No
*8 Refused

ta mosquito_coil nthRec, m
ta mosquito_coil visitLetter2, m

gen msqtCoilT=.
replace msqtCoilT=0 if mosquito_coil=="0"
replace msqtCoilT=1 if mosquito_coil=="1"

sort person_id nthRec
by person_id: carryforward msqtCoilT, replace
gsort person_id -nthRec
by person_id: carryforward msqtCoilT, replace
sort person_id nthRec

ta msqtCoilT mosquito_coil_aic, m
ta msqtCoilT, m
replace msqtCoilT=2 if msqtCoilT==.
ta msqtCoilT, m

label define lbl_msqtCoilT 0 "No" 1 "Yes" 2"missing"
label val msqtCoilT lbl_msqtCoilT
ta msqtCoilT, m

gen msqtCoilT3=.
replace msqtCoilT3=0 if msqtCoilT==0
replace msqtCoilT3=1 if msqtCoilT==1
label define lbl_msqtCoilT3 0 "No" 1 "Yes"
label val msqtCoilT3 lbl_msqtCoilT3
ta msqtCoilT msqtCoilT3, m

gen diffmsqtCoilT=.
sort person_id nthRec
bysort person_id: replace diffmsqtCoilT=1 if msqtCoilT[_n]!=msqtCoilT[_n+1] & msqtCoilT[_n+1]!=. 
ta diffmsqtCoilT, m
drop diffmsqtCoilT	



********************************************************************************
**Mosquito NET

ta mosquito_net, m //How often does the child sleep under a mosquito net?
*1 Always
*2 Sometimes
*3 Rarely
*4 Never
*5 Refused

ta mosquito_net nthRec, m
ta mosquito_net visitLetter2, m

ta mosquito_net, m
replace mosquito_net="" if mosquito_net=="NA"
replace mosquito_net="" if mosquito_net=="9"
destring(mosquito_net), replace
ta mosquito_net, m

gen msqtNetT=.
replace msqtNetT=mosquito_net
ta msqtNetT mosquito_net, m

sort person_id nthRec
by person_id: carryforward msqtNetT, replace
gsort person_id -nthRec
by person_id: carryforward msqtNetT, replace
sort person_id nthRec

ta msqtNetT, m
replace msqtNetT=5 if msqtNetT==.
ta msqtNetT, m

label define lbl_msqtNetT 1 "Always" 2 "Sometimes" 3 "Rarely" 4 "Never" 5 "missing"
label val msqtNetT lbl_msqtNetT
ta msqtNetT, m

gen msqtNetT3=.
replace msqtNetT3=0 if msqtNetT==1
replace msqtNetT3=1 if msqtNetT==2 |  msqtNetT==3 |  msqtNetT==4
label define lbl_msqtNetT3 0 "Always protected" 1 "Sometimes-never protected"
label val msqtNetT3 lbl_msqtNetT3
ta msqtNetT msqtNetT3, m

gen diffmsqtNetT=.
sort person_id nthRec
bysort person_id: replace diffmsqtNetT=1 if msqtNetT[_n]!=msqtNetT[_n+1] & msqtNetT[_n+1]!=. 
ta diffmsqtNetT, m
drop diffmsqtNetT	

********************************************************************************
*Child traveled
********************************************************************************

ta travel, m //Has the child traveled more than 10km away from home in the last 6 months?
*1 Yes
*0 No
*8 Refused
ta stay_overnight, m //Did the child spend at least one night in the travel destination?
*1 Yes
*0 No
*8 Refused

*This variable was asked again every visit
ta travel visitLetter2, m
ta travel nthRec, m

ta travel, m
replace travel="" if travel=="NA"
replace travel="" if travel=="8"
destring travel, replace
ta travel, m

label define lbl_travel 0 "no" 1 "yes"
label val travel lbl_travel
ta travel, m


gen childTrav_denvT=.
*Fill when denv_sconv_y==1
forval i=1/8 {
sort person_id nthRecHCC2
replace childTrav_denvT=travel if denv_sconv_y==1 & childTrav_denvT==. & nthRecHCC2==`i' 
ta childTrav_denvT travel, m

sort person_id nthRecHCC2
by person_id: carryforward childTrav_denvT , replace
gsort person_id -nthRecHCC2
by person_id: carryforward childTrav_denvT , replace
sort person_id nthRecHCC2
}
*
*Fill when denv_sconv_y==0

forval i=1/8 {
sort person_id nthRecHCC2
replace childTrav_denvT=travel if denv_sconv_y==0 & childTrav_denvT==. & nthRecHCC2==`i' 
ta childTrav_denvT travel, m

sort person_id nthRecHCC2
by person_id: carryforward childTrav_denvT , replace
gsort person_id -nthRecHCC2
by person_id: carryforward childTrav_denvT , replace
sort person_id nthRecHCC2
}
*
*browse person_id nthRecHCC2 denv_sconv_y denv_sconv_Any travel childTrav_denvT if denv_sconv_y==1 & childTrav_denvT==1
*browse person_id nthRecHCC2 denv_sconv_y denv_sconv_Any travel childTrav_denvT 
*ta childTrav_denvT nthRecHCC2, m
*replace childTrav_denvT=. if nthRecHCC2!=1
*ta childTrav_denvT nthRecHCC2, m

label define lbl_childTrav_denvT 0 "no" 1 "yes"
label val childTrav_denvT lbl_childTrav_denvT
ta childTrav_denvT, m

*Child travelled for CHIKV
gen childTrav_chikvT=.
*Fill when chikv_sconv_y==1
forval i=1/8 {
sort person_id nthRecHCC2
replace childTrav_chikvT=travel if chikv_sconv_y==1 & childTrav_chikvT==. & nthRecHCC2==`i' 
ta childTrav_chikvT travel, m

sort person_id nthRecHCC2
by person_id: carryforward childTrav_chikvT , replace
gsort person_id -nthRecHCC2
by person_id: carryforward childTrav_chikvT , replace
sort person_id nthRecHCC2
}
*
*Fill when chikv_sconv_y==0

forval i=1/8 {
sort person_id nthRecHCC2
replace childTrav_chikvT=travel if chikv_sconv_y==0 & childTrav_chikvT==. & nthRecHCC2==`i' 
ta childTrav_chikvT travel, m

sort person_id nthRecHCC2
by person_id: carryforward childTrav_chikvT , replace
gsort person_id -nthRecHCC2
by person_id: carryforward childTrav_chikvT , replace
sort person_id nthRecHCC2
}
*
*browse person_id nthRecHCC2 chikv_sconv_y denv_sconv_Any travel childTrav_chikvT if chikv_sconv_y==1 & childTrav_chikvT==1
*browse person_id nthRecHCC2 chikv_sconv_y denv_sconv_Any travel childTrav_chikvT 
*ta childTrav_chikvT nthRecHCC2, m
*replace childTrav_chikvT=. if nthRecHCC2!=1
*ta childTrav_chikvT nthRecHCC2, m

label define lbl_childTrav_chikvT 0 "no" 1 "yes"
label val childTrav_chikvT lbl_childTrav_chikvT
ta childTrav_chikvT, m

*******************************************************************************
*Child moved away (only for HCC)
ta moved_away, m //During the last 6 months, have you moved out of the study area for at least 1 month?
*0 No
*1 Yes
*99 Refused
ta duration_away, m //During the last 6 months, have you moved out of the study area for at least 1 month?
*1 One month
*2 Two months
*3 Three Months
*4 Four Months
*5 Five Months
*6 Six Months
*98 Other
*99 Refused/No Answer

ta  duration_away chikv_igg_y, row
ta  duration_away denv_igg_y, row
*We don't have the power to make separate categories for how long they were away
*Also the data does not suggest we will find any associations there

ta moved_away nthRec, m
ta moved_away visitLetter2, m //It looks like they did not start recording this information before visit F
*Do we want to do something with this or ignore?
ta moved_away chikv_igg_y, row
ta moved_away denv_igg_y, row
*There is not much power there to do anything with this
*I will leave it for now





















********************************************************************************
**Drop everyone that was not assigned an inclusio visit/do not have a date
**I can't include those in any of the analyses
**so would be mainly a pain to keep them in the dataset
********************************************************************************
ta yr flowHCC, m
ta flowHCC denv_igg_y, m
ta flowHCC chikv_igg_y, m
*Those also hardly have any igg data
drop if flowHCC==.
ta yr flowHCC, m

*******************************************************************************
*******************************************************************************
*******************************************************************************

save "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_step3_complete2.dta", replace
clear

*******************************************************************************
******************Dataset for seropositivity analyses**************************
*******************************************************************************
use "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_step3_complete2.dta"

ta visitLetter2, m
drop if visitLetter2=="t_"
ta visitLetter2, m

*For the seroprevalence analyses I only want to include records of their first visit
ta flowHCC, m
ta flowHCC2, m
ta flowHCC3, m

ta flowHCC, m
keep if flowHCC==0 | flowHCC==0.5 //includes first inclusion + catch-up
ta flowHCC, m

ta denv_igg_y, m
ta chikv_igg_y, m

save "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_step3_complete_seroprevalenceAnlyses.dta", replace
clear


*******************************************************************************
******************Dataset for serconversion analyses - plain*******************
*******************************************************************************
use "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_step3_complete2.dta"

ta visitLetter2, m
drop if visitLetter2=="t_"
ta visitLetter2, m

ta denv_sconv_1stRec nthRecHCC2, m
ta chikv_sconv_1stRec nthRecHCC2, m

ta nthRecHCC2, m
keep if nthRecHCC2==1
ta nthRecHCC2, m

ta denv_sconv_y, m
ta denv_sconv_1stRec, m

ta chikv_sconv_y, m
ta chikv_sconv_1stRec, m

save "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_step3_complete_seroconversionAnlyses.dta", replace
clear



*******************************************************************************
******************Dataset for serconversion analyses - GEE  *******************
*******************************************************************************
use "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_step3_complete2.dta"

*******************************************************************************
ta visitLetter2, m
drop if visitLetter2=="t_"
ta visitLetter2, m

drop if denv_sconv_y==.

*******************************************************************************
drop nthRec*
bysor person_id: gen nthRec=_n
ta nthRec, m

*******************************************************************************
ta denv_sconv_y, m
ta chikv_sconv_y, m
ta denv_sconv_y chikv_sconv_y, m


*******************************************************************************
*Destring person_id for analyses purpose for gee analyses

gen person_id2_numbers = regexs(0) if(regexm(person_id, "[0-9][0-9][0-9][0-9][0-9][0-9][0-9]$"))
gen person_id2_letters = ""
replace person_id2_letters=regexs(0) if(regexm(person_id, "[A-Z][A-Z]")) 
ta person_id2_letters, m

gen person_id2_lettersNr=""
replace person_id2_lettersNr="99" if person_id2_letters=="CC"
replace person_id2_lettersNr="98" if person_id2_letters=="GC"
replace person_id2_lettersNr="97" if person_id2_letters=="KC"
replace person_id2_lettersNr="96" if person_id2_letters=="LC"
replace person_id2_lettersNr="95" if person_id2_letters=="UC"
ta person_id2_lettersNr person_id2_letters, m

gen person_id2=person_id2_lettersNr+person_id2_numbers
destring person_id2, replace 



*check whether the new id's that I generated are identical
sort person_id nthRec 
bysort person_id: gen tempNth=_n
sort person_id2 nthRec
bysort person_id2: gen tempNth2=_n
gen diff=1 if tempNth!=tempNth2
ta diff, m
ta tempNth tempNth2, m
browse person_id person_id2 person_id2_numbers person_id2_letters person_id2_lettersNr if diff==1
drop person_id2_numbers person_id2_letters person_id2_lettersNr diff tempNth tempNth2

xtset person_id2
*note unblanced outcome

numlabel, add
save "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_step3_complete_gee_seroconversionAnalyses.dta", replace
clear
