/**************************************************************
cd "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\CSVs nov29_16"
*merge elisas with rdt and pcr from sammy
use sammy, clear
rename VISIT visit
drop id_visit
bysort dengueigm_sammy visit: tab stanforddenvigg_
capture drop _merge
drop if dup_visit >1


drop if visit ==2 
drop if visit >4
	save lab, replace

use all_interviews.dta, clear
merge 1:1 id_wide visit using lab.dta
*there are some lab visits that don't have a follow up in the interview data. 
stop
drop _merge
	
		keep studyid  id_wide site visit antigenused_ city Stanford_CHIKV_IGG cohort gender datesamplecollected_ dob  agemonths age gender  Stanford_CHIK~G Stanford_DENV~G visit datesamplecol~_ 
		rename _merge abvisit
		merge 1:1 id_wide visit using prevalent		
		keep if abvisit ==3 & Stanford_DENV_IGG!=.

rename denvpcr_ pcr_denv
rename chikvpcr_ pcr_chikv
rename denvigg_ igg_kenya_denv
rename chikvigg_ igg_kenya_chikv
rename dengue_igg_sammy igg_sammy_denv

foreach var in igg_kenya_chikv igg_kenya_denv pcr_chikv pcr_denv igg_sammy_denv{
capture drop dos`var'
encode `var', gen(dos`var')
drop `var'
rename dos`var' `var' 
}
replace igg_kenya_chikv = . if igg_kenya_chikv<402
replace igg_kenya_chikv = . if igg_kenya_chikv==403|igg_kenya_chikv == 404|igg_kenya_chikv == 405| igg_kenya_chikv == 406
replace igg_kenya_chikv = 408 if igg_kenya_chikv==409


save  prevalent, replace

order malaria*
destring malariabloodsmear  malariapastmedhist, replace
encode pos_neg, gen(malariapos)
encode pos_neg1, gen(malariapos2)
replace malariapos = malariapos-1
replace malariapos2=malariapos2-1
drop pos_neg*

label values malariaresults malariaresults
label define malariaresult 0 "negative" 1 "+" 2 "++" 3 "+++" 4 "++++"
 
sum malaria* Stanford*
tab malariaresults 
bysort city: sum malaria* Stanford*
bysort city: tab malariaresults 

bysort  id_wide: gen repeatoffender = _n if malariabloodsmear ==1
bysort id_wide : egen max=max(repeatoffender)
bysort id_wide : replace repeatoffender =. if repeatoffender!=max



sum repeatoffender if repeatoffender >1
order repeat id_wide visit malariabloodsmear
bysort city: sum repeatoffender if repeatoffender >1 


foreach var in datesamplecollected_ {
gen `var'1 = date(`var', "MDY" ,2050)
format %td `var'1 
drop `var'
rename `var'1 `var'
recast int `var'
}


replace interviewdate = datesamplecollected_ if interviewdate ==.


gen interviewmonth =month(interviewdate)
gen interviewyear =year(interviewdate)

gen season = . 
replace season =1 if interviewmonth >=1 & interviewmonth <=3 & season ==.
*label define 1 "hot no rain from mid december"
replace season =2 if interviewmonth >=4 & interviewmonth <=6 & season ==.
*label define 2 "long rains"
replace season =3 if interviewmonth >=7 & interviewmonth <=10 & season ==.
*label define 3 "less rain cool season"
replace season =4 if interviewmonth >=11 & interviewmonth <=12 & season ==.
*label define 4 "short rains"

*malaria positives
foreach var in interviewdate age{
sum `var'  malariabloodsmear if  malariabloodsmear==1 
sum `var'  malariabloodsmear if  malariabloodsmear==1 
}


foreach var in gender hospitalsite age species city { 
tab `var'  malariabloodsmear if  malariabloodsmear ==1, m
}
*repeat offenders
foreach var in interviewdate age{
sum `var'  malariabloodsmear if  malariabloodsmear==1 & repeatoffender >1
sum `var'  malariabloodsmear if  malariabloodsmear==1 & repeatoffender >1
}

foreach var in gender hospitalsite age species city { 
tab `var'  malariabloodsmear if  malariabloodsmear ==1 & repeatoffender >1, m
}

tab repeatoffender malariabloodsmear
order malaria* species city gender hospitalsite interviewdate* age* repeatoffender 
save mergedjan42016, replace

*outsheet using " mergedjan42017.csv", comma names replace

***merge with lab malaria data
replace studyid = studyid_copy if studyid =="" & studyid_copy !=""
replace studyid = studyid1 if studyid =="" & studyid1 !=""
replace studyid = studyid2 if studyid =="" & studyid2 !=""
replace studyid = studyid_ if studyid =="" & studyid_ !=""
replace studyid = duplicateid_a if studyid =="" & duplicateid_a !=""
replace studyid = followupid if studyid =="" & followupid!=""	

merge 1:1 id_wide visit using "C:\Users\amykr\Google Drive\labeaud\malaria prelim data dec 29 2016\malaria"

rename pos_neg malariapos_neg
rename pos_neg1 malariapos_neg1

save malariadenguemerged, replace

***
**create village and house id so we can merge with gis points
gen villageid=""
replace villageid = substr(id_wide, +1, 1)
replace villageid = "1" if villageid =="c"
replace villageid = "2" if villageid =="k"

replace villageid = "1" if villageid =="u"
replace villageid = "2" if villageid =="u"

replace villageid = "3" if villageid =="g"
replace villageid = "4" if villageid =="l"
destring villageid, replace

gen houseid2 = ""
replace houseid2 = substr(id_wide, -6, 3) if cohort ==3
replace houseid2= substr(id_wide, 3, 4) if houseid2==""
destring houseid2 , replace force
replace houseid = houseid2 if houseid==. & houseid2!=.

destring houseid, replace
gen houseidstring = string(houseid ,"%04.0f")
drop houseid
rename houseidstring  houseid
order houseid

order studyid houseid villageid
drop _merge
tostring houseid , replace
save malariadenguemerged, replace

*****************merge with gis points
use xy, clear
merge 1:m villageid houseid using malariadenguemerged
drop if _merge ==1

save denvchikvmalariagps, replace
outsheet using "denvchikvmalariagps.csv", comma names replace