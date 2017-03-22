/*************************************************************
 *amy krystosik                  							  *
 *built environement hcc									  *
 *lebeaud lab               				        		  *
 *last updated feb 2, 2017 									  *
 **************************************************************/ 

 /*
 Impact of built environment/home environment on vectorborne disease risk (Amy)
Household information (windows, roof, water sources, etc.)
DV notes: cleaning village location data
Vector abundance and rainfall/case (Amy)
*/

capture log close 
log using "built environement hcc.smcl", text replace 
set scrollbufsize 100000
set more 1

cd "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\built environement hcc"
use "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\all linked and cleaned data\data\cleaned_merged_data", replace

bysort city: tab month year

gen group = . 
replace group = 0 if stanforddenvigg_ == 0 & stanfordchikvigg_ ==0
replace group = 1 if stanforddenvigg_ == 1| stanfordchikvigg_ ==1
replace group = 2 if stanforddenvigg_ == 1 & stanfordchikvigg_ ==1
*keep if group !=. 

gen group2 = . 
replace group2 = 0 if denvigg_ == 0 & chikvigg_ ==0
replace group2 = 1 if denvigg_ == 1| chikvigg_ ==1
replace group2 = 2 if denvigg_ == 1 & chikvigg_ ==1



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
tab head_of_household_water_collecti 
tab head_of_household_water_collect0 
gen water_cotainers = . 

replace water_cotainers = 0 if head_of_household_water_collecti ==""|head_of_household_water_collecti =="n/a"
replace water_cotainers = 1 if head_of_household_water_collecti !="" & water_cotainers ==.

replace water_cotainers = 0 if head_of_household_water_collect0 ==""|head_of_household_water_collect0 =="n/a" & water_cotainers ==.
replace water_cotainers = 1 if head_of_household_water_collect0 !="" & water_cotainers ==.

replace water_cotainers = 0 if watercolltype  ==""| watercolltype =="n/a" & water_cotainers ==.
replace water_cotainers = 1 if watercolltype  !="" & water_cotainers ==.

replace water_cotainers = 0 if watercollectitems ==""| watercollectitems  =="n/a" & water_cotainers ==.
replace water_cotainers = 1 if watercollectitems !="" & water_cotainers ==.


replace water_cotainers = watercollobjects if water_cotainers ==.
replace water_cotainers = objectwater if water_cotainers ==.

drop objectwater watercollobjects watercollectitems watercolltype  head_of_household_water_collect0 head_of_household_water_collecti 

*livestock
sum keep_livestock  habits_livestock_location habits_which_livestock_livestock habits_which_livestock_livestoc1 habits_attend_livestock_attend_l habits_attend_livestock_attend_0 habits_livestock_contact_livesto habits_livestock_contact_livest0 

foreach var in keep_livestock  habits_livestock_location habits_which_livestock_livestock habits_which_livestock_livestoc1 habits_attend_livestock_attend_l habits_attend_livestock_attend_0 habits_livestock_contact_livesto habits_livestock_contact_livest0 {
	tab `var'
}

*travel
sum childtravel wheretravel nightaway 

*activities
sum outdooractivity hrsoutdoors 
*child health
sum yellowfever childvaccination 

rename educlevel educ

foreach var in  hoc_tribe hoc_othtribe hoh_tribe hoh_othtribe tribe tribeother hh_tribe hh_tribe_other{
tab `var'
}
egen tribe2 = concat( hoc_tribe hoc_othtribe hoh_tribe hoh_othtribe tribe tribeother hh_tribe hh_tribe_other)
drop hoc_tribe hoc_othtribe hoh_tribe hoh_othtribe tribe tribeother hh_tribe hh_tribe_other 
rename tribe2 tribe
encode tribe, gen(tribe_int)

save builtenvironment, replace 

xtile ses_index_sum_pct =  ses_index_sum, n(4)


bysort group: sum age gender ses_index_sum tribe_int educ
egen village_elisa = concat(village group)


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
replace land_index = "0none" if land_index =="none"
replace land_index = "1rent" if land_index =="rent"
replace land_index = "2family" if land_index =="family"
replace land_index = "3own" if land_index =="own"

encode land_index, gen(ownland2)

*here are two options for your logistic regression

bysort group: sum age ses_index_sum_pct educ gender tribe_int 
table1, by(group) vars(age conts \ses_index_sum_pct cat \educ cat \gender cat \tribe_int cat \) saving("table1a.xls", replace) test missing
table1, vars(age conts \ses_index_sum_pct cate \educ cate \gender cate \tribe_int cate \) saving("table1b.xls", replace) test missing
table1, by(group) vars(age contn \ses_index_sum_pct cat \educ cat \gender cat \tribe_int cat \) saving("table1c.xls", replace) test missing

replace group2 = 1 if group2 == 2
*ownland2 ownmoterbike keep_livestock  aedesaegyptitotal   rainfallanomalies temprangeanomalies tempdewptdiffanomalies tempanomalies rhanomalies rhtempanomalies  
bysort group: sum group2 female adult  water_cotainers  mosquito_exposure_index  mosq_prevention_index  ses_index_sum

logit group2 group2 city_int female adult  water_cotainers  mosquito_exposure_index  mosq_prevention_index  ses_index_sum, or
bysort group2: sum windows ownland2 ownmoterbike i.city_int female adult keep_livestock   water_cotainers  mosquito_exposure_index  mosq_prevention_index  aedesaegyptitotal  rainfallanomalies temprangeanomalies tempdewptdiffanomalies tempanomalies rhanomalies rhtempanomalies  ses_index_sum

table1, by(group) vars(windows conts \ownland2 cat \ ownmoterbike cat\  city_int cat\ female cat\ adult cat\ keep_livestock   cat\ water_cotainers  cat\ mosquito_exposure_index  conts \ mosq_prevention_index  contn \ aedesaegyptitotal  contn \ rainfallanomalies contn \ temprangeanomalies contn \ tempdewptdiffanomalies contn \ tempanomalies contn \ rhanomalies contn \ rhtempanomalies  contn \ ses_index_sum contn \) saving("table1.xls", replace) test missing

logit group2 windows ownland2 ownmoterbike i.city_int female adult keep_livestock   mosquito_exposure_index  mosq_prevention_index  ses_index_sum, or 
bysort group: sum windows ownland2 ownmoterbike i.city_int female adult keep_livestock   mosquito_exposure_index  mosq_prevention_index  ses_index_sum

outreg2 using logit1.xls, replace

logit group2  i.city_int ses_index_sum_pct  educ childage , or
outreg2 using logit2.xls, append

*table 1
table1, by(group) vars(ownland2 cat \ ownmoterbike cat \ villagestring cat \ female cat \ adult cat \childage  conts \ses_index_sum_pct cate \educ cate \gender cate \tribe_int cate \) saving("table2.xls", replace) test missing
