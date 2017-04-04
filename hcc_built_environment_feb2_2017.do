/*************************************************************
 *amy krystosik                  							  *
 *built environement hcc									  *
 *lebeaud lab               				        		  *
 *last updated march 29, 2017 									  *
 **************************************************************/ 

/*Impact of built environment/home environment on vectorborne disease risk (Amy)
 Household information (windows, roof, water sources, etc.)
Vector abundance and rainfall/case (Amy)
*/

cd "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\built environement hcc"
capture log close 
log using "built environement hcc.smcl", text replace 
set scrollbufsize 100000
set more 1
local data "C:\Users\amykr\Box Sync\Amy Krystosik's Files\ASTMH 2017 abstracts\all linked and cleaned data\data\"

*incidence
use "`data'incident_malaria$S_DATE", clear
keep incident_malaria id_wide visit
save "incident_malaria$S_DATE", replace

use "`data'inc_chikv$S_DATE", clear
keep inc_chikv  id_wide visit
save "inc_chikv$S_DATE", replace

use "`data'inc_denv$S_DATE", clear
keep inc_denv id_wide visit
save "inc_denv$S_DATE", replace

use "C:\Users\amykr\Box Sync\Amy Krystosik's Files\ASTMH 2017 abstracts\all linked and cleaned data\data\cleaned_merged_prevalence$S_DATE", replace
merge 1:1 id_wide visit using "inc_denv$S_DATE"
drop _merge
merge 1:1 id_wide visit  using "inc_chikv$S_DATE"
drop _merge
merge 1:1 id_wide visit using "incident_malaria$S_DATE"
drop _merge

*hcc only 
keep if cohort ==2
capture drop id
encode id_wide, gen(id)		
lookfor year month
tab year month
gen survivaltime = ym(year, month) 
format %tm survivaltime  
tab survivaltime 

bysort city: tab month year

gen group = . 
replace group = 0 if stanforddenvigg_ == 0 & stanfordchikvigg_ ==0
replace group = 1 if stanforddenvigg_ == 1| stanfordchikvigg_ ==1 |malariapositive_dum2  ==1
replace group = 2 if stanforddenvigg_ == 1 & stanfordchikvigg_ ==1 
replace group = 3 if stanforddenvigg_ == 1 & malariapositive_dum2  ==1 
replace group = 4 if  stanfordchikvigg_ ==1 & malariapositive_dum2  ==1
replace group = 5 if stanforddenvigg_ == 1 & stanfordchikvigg_ ==1 & malariapositive_dum2  ==1
*keep if group !=. 
egen mal_denv_chikv_count = rowtotal(stanforddenvigg_ stanfordchikvigg_ malariapositive_dum2  )

*mosquito aedes
sum aedesaegyptiindoor aedessimpsoniindoor aedesaegyptioutdoor aedessimpsonioutdoor  aedesaegypti  aedessimpsoni  aedessppnotlisted  aedesaegyptiinside  aedesaegyptitotal 

*anopheles
sum anophelesgambiaeindoor anophelesfunestusindoor  anophelesgambiaeoutdoor anophelesfunestusoutdoor anophelescostaniindoor anophelesgambiae anophelesfunestus anophelesoutdoor 

*culex
sum culexsppindoor culexsppoutdoor culexspp 

*totals
sum indoortotal outdoortotal 

*yellow fever
sum masoni 

*culex
sum culexsppinside k culexsppoutside culexspptotal culexoutdoor 

*toxo
sum toxorhynchitesoutdoor  toxorhynchites 


*water
tab hoh_water_collecti 
gen water_cotainers = . 
replace water_cotainers = 1 if hoh_water_collecti !="" & water_cotainers ==.
replace water_cotainers = 1 if watercollectitems !="" & water_cotainers ==.
replace water_cotainers = watercollobjects if water_cotainers ==.
replace water_cotainers = objectwater if water_cotainers ==.
drop objectwater watercollobjects watercollectitems watercolltype  hoh_water_collecti 

*livestock
sum  livestock_location livestock_contact keep_livestock which_livestock which_other_livestock attend_livestock

foreach var in  livestock_location livestock_contact keep_livestock which_livestock which_other_livestock attend_livestock{
	tab `var'
}

*travel
sum childtravel wheretravel nightaway 

*activities
sum outdooractivity hrsoutdoors 
*child health
sum yellowfever childvaccination 

rename educlevel educ

foreach var in   tribe tribeother hoc_tribe hoc_othtribe hoh_tribe hoh_othtribe{
tab `var'
}

egen tribe2 = concat(tribe tribeother hoc_tribe hoc_othtribe hoh_tribe hoh_othtribe)
drop  tribe tribeother hoc_tribe hoc_othtribe hoh_tribe hoh_othtribe
rename tribe2 tribe
encode tribe, gen(tribe_int)

save builtenvironment, replace 

bysort group: sum age gender ses_index_sum tribe_int educ

outsheet using "built environemnt.csv", comma names replace

gen adult = .
replace adult = 0 if age <18
replace adult = 1 if age >=18

gen female = . 
replace female =1 if sex=="female"
replace female =0 if sex=="male"
replace female = gender  if female ==.

rename motor_vehicle  ownmoterbike

destring *, replace
gen ownland2= land_index
capture drop id
encode id_wide, gen(id)
stset id visit_int
preserve
	order gps*
	keep id_wide visit city cohort gps* *dum stanford*
	outsheet using "to_map__$S_DATE.csv", comma names replace
restore 
stop 
*here are two options for your logistic regression
/*
bysort group: sum age ses_index_sum_pct educ gender tribe_int 
*table1, by(group) vars(age conts \ses_index_sum_pct cat \educ cat \gender cat \tribe_int cat \) saving("table1a.xls", replace) test missing
*table1, vars(age conts \ses_index_sum_pct cate \educ cate \gender cate \tribe_int cate \) saving("table1b.xls", replace) test missing
*table1, by(group) vars(age contn \ses_index_sum_pct cat \educ cat \gender cat \tribe_int cat \) saving("table1c.xls", replace) test missing

*ownland2 ownmoterbike keep_livestock  aedesaegyptitotal   rainfallanomalies temprangeanomalies tempdewptdiffanomalies tempanomalies rhanomalies rhtempanomalies  
bysort group: sum group female adult  water_cotainers  mosquito_exposure_index  mosq_prevention_index  ses_index_sum

*logit group city_int female adult  water_cotainers  mosquito_exposure_index  mosq_prevention_index  ses_index_sum, or
bysort group: sum windows ownland2 ownmoterbike i.city_int female adult keep_livestock   water_cotainers  mosquito_exposure_index  mosq_prevention_index  aedesaegyptitotal  rainfallanomalies temprangeanomalies tempdewptdiffanomalies tempanomalies rhanomalies rhtempanomalies  ses_index_sum

*table1, by(group) vars(windows conts \ownland2 cat \ ownmoterbike cat\  city_int cat\ female cat\ adult cat\ keep_livestock   cat\ water_cotainers  cat\ mosquito_exposure_index  conts \ mosq_prevention_index  contn \ aedesaegyptitotal  contn \ rainfallanomalies contn \ temprangeanomalies contn \ tempdewptdiffanomalies contn \ tempanomalies contn \ rhanomalies contn \ rhtempanomalies  contn \ ses_index_sum contn \) saving("table1.xls", replace) test missing

bysort group: sum windows ownland2 ownmoterbike city_int female adult keep_livestock   mosquito_exposure_index  mosq_prevention_index  ses_index_sum 

*logit group windows ownland2 ownmoterbike i.city_int female adult keep_livestock   mosquito_exposure_index  mosq_prevention_index  ses_index_sum, or 
*bysort group: sum windows ownland2 ownmoterbike i.city_int female adult keep_livestock   mosquito_exposure_index  mosq_prevention_index  ses_index_sum
*outreg2 using logit1.xls, replace

*logit group  i.city_int ses_index_sum_pct  educ childage , or
*outreg2 using logit2.xls, append

gen groupdum =.
replace groupdum= 0 if group ==0
replace groupdum =1 if group >0 & group !=.
tab groupdum

/*table 1
table1, by(groupdum) vars(ownland2 cat \ ownmoterbike cat \ childvillage_int contn\ female cat \ adult cat \age  conts \ses_index_sum_pct cat \educ cat \gender cat \tribe_int contn \) saving("table2_mal_denv_chikv_count_$S_DATE.xls", replace) test 
bysort groupdum: sum ownland2 ownmoterbike childvillage female adult age ses_index_sum_pct educ gender tribe_int 
table1, by(mal_denv_chikv_count)  vars(ownland2 cat \ ownmoterbike cat \ childvillage cat \ female cat \ adult cat \age  conts \ses_index_sum_pct cat \educ cat \gender bin \tribe_int cat \) saving("table2_group_$S_DATE.xls", replace) test missing
*/
*/
/*incident data is not enough to run these multivariate models right now
foreach fail in  inc_den inc_chikv {
preserve
		 stset survivaltime, failure(`fail') id(id) 
		 *stsum
		 stcoxkm, by(site)
		 *bysort `fail': sum
		 stcox educ gender age aedesaegyptiindoor  aedesaegyptioutdoor   mosq_prevention_index  rainfallanomalies season i.site_int i.city_int
		 estat phtest
	restore
}

stset survivaltime, failure(incident_malaria) id(id_wide) 
	stsum
	stcoxkm, by(site)
	bysort incident_malaria: sum educ gender age aedesaegyptiindoor  ownmoterbike i.city_int female adult keep_livestock   temprangeanomalies rainfallanomalies
    stcox educ gender age aedesaegyptiindoor  ownmoterbike i.city_int female adult keep_livestock   temprangeanomalies rainfallanomalies
    estat phtest
*/

dropmiss, force
capture drop id
encode id_wide, gen(id)
encode site, gen(site_int)

preserve
	bysort id_wide: egen malariapositive_dummax = max(malariapositive_dum)
	bysort id_wide: egen stanforddenvigg_max = max(stanforddenvigg_)
	bysort id_wide: egen stanfordchikvigg_max = max(stanfordchikvigg_)

	keep if visit =="a"
	table1, by(malariapositive_dum)  vars(ownland2 cat \ ownmoterbike cat \ childvillage cat \ female cat \ adult cat \age  conts \educ cat \gender bin \tribe_int cat \) saving("visita_malariapositive_dum_$S_DATE.xls", replace) test missing
	table1, by(stanforddenvigg_ )  vars(ownland2 cat \ ownmoterbike cat \ childvillage cat \ female cat \ adult cat \age  conts \educ cat \gender bin \tribe_int cat \) saving("visita_stanforddenvigg_$S_DATE.xls", replace) test missing
	table1, by(stanfordchikvigg_ )  vars(ownland2 cat \ ownmoterbike cat \ childvillage cat \ female cat \ adult cat \age  conts \educ cat \gender bin \tribe_int cat \) saving("visita_stanfordchikvigg_$S_DATE.xls", replace) test missing

sum  hccsesindeximprovedfuel_index hccsesindeximprovedwater_index hccsesindeximprovedlight_index hccsesindextelephone hccsesindexradio hccsesindexown_tv hccsesindexbicycle hccsesindexmotor_vehicle hccsesindexdomestic_worker hccsesindexownflushtoilet hccsesindexlatrine_index hccsesindexland_index hccsesindexrooms hccsesindexbedrooms hccsesindeximprovedroof_index hccsesindeximprovedfloor_index

restore

tsset id_wide_int visit_int
xtdescribe
xttab stanforddenvigg_ 

xtlogit stanforddenvigg_ educ gender age aedesaegyptiindoor  aedesaegyptioutdoor   mosq_prevention_index  rainfallanomalies i.site_int, re

xtlogit stanfordchikvigg_ educ gender age aedesaegyptiindoor  aedesaegyptioutdoor   mosq_prevention_index  rainfallanomalies i.site_int, re

xtlogit malariapositive_dum  educ gender age aedesaegyptiindoor  ownmoterbike i.site_int female adult temprangeanomalies rainfallanomalies, re

bysort site cohort stanforddenvigg_ : fsum hccsesi~f_index hccsesi~r_index  numberofwindows sleepbywindow windowsscreened  hoh_windows sleep_close_w~w drinkingwater  other_water_s~e  light   flooring improvedfloor~x water_cotainers educ gender age aedesaegyptiindoor  aedesaegyptioutdoor   mosq_prevention_index  rainfallanomalies site_int

