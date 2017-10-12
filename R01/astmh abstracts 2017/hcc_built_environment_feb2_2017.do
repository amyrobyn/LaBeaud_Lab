/*************************************************************
 *amy krystosik                  							  *
 *built environement hcc +aic 									  *
 *lebeaud lab               				        		  *
 *last updated april 17, 2017 									  *
 **************************************************************/ 

/*Impact of built environment/home environment on vectorborne disease risk (Amy)
 Household information (windows, roof, water sources, etc.)
Vector abundance and rainfall/case (Amy)
*/
cd "C:\Users\amykr\Box Sync\Amy Krystosik's Files\DENV CHIKV project IDENTIFIED september 1 2017 backup\Personalized Datasets\Amy Krystosik\built environement hcc"
capture log close 
log using "built environement hcc.smcl", text replace 
set scrollbufsize 100000
set more 1
local data "C:\Users\amykr\Box Sync\Amy Krystosik's Files\ASTMH 2017 abstracts\all linked and cleaned data\data\"

*incidence
use "`data'incident_malaria12 Apr 2017", clear
keep incident_malaria id_wide visit
save "incident_malaria12 Apr 2017", replace

use "`data'inc_chikv12 Apr 2017", clear
keep inc_chikv  id_wide visit
save "inc_chikv12 Apr 2017", replace

use "`data'inc_denv12 Apr 2017", clear
keep inc_denv id_wide visit
save "inc_denv12 Apr 2017", replace

local data "C:\Users\amykr\Box Sync\Amy Krystosik's Files\ASTMH 2017 abstracts\all linked and cleaned data\data\"
use "`data'cleaned_merged_prevalence12 Apr 2017", clear
capture drop inc_chikv incident_malaria inc_denv
merge 1:1 id_wide visit using "inc_denv12 Apr 2017"
drop _merge
merge 1:1 id_wide visit  using "inc_chikv12 Apr 2017"
drop _merge
merge 1:1 id_wide visit using "incident_malaria12 Apr 2017"
drop _merge

*hcc only 
*keep if cohort ==2
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

*aedes
sum ttl_aedessppindoorhlc ttl_aedes_spp_outdoorhlc ttl_aedessppindoorlarval ttl_aedes_spp_outdoorlarval ttl_aedessppindoorovitrap ttl_aedes_spp_outdoorovitrap ttl_aedessppindoorprokopack ttl_aedes_spp_outdoorprokopack ttl_aedessppindoorpupae ttl_aedes_spp_outdoorpupae ttl_aedessppsentinel

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

bysort group: sum age gender tribe_int educ

*outsheet using "built environemnt.csv", comma names replace

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

capture drop id
encode id_wide, gen(id)
encode site, gen(site_int)
preserve
	keep if cohort ==2 	
	*table1, by(incident_malaria)  vars(ownland2 cat \ ownmoterbike cat \ childvillage cat \ female cat \ age  conts \educ cat \gender bin \tribe_int cat \) saving("visita_malariapositive_dum_$S_DATE.xls", replace) test missing
	table1, by(inc_denv )  vars(hcc_ses_improvedroof_index bin\ hcc_ses_improvedfloor_index bin\ hcc_ses_telephone_dum bin\ hcc_ses_radio_dum bin\ hcc_ses_bicycle_dum bin\ hccses_index_sum conts\ hcc_ses_radio bin\ hcc_ses_bicycle cat \  ownland2 cat \ ownmoterbike cat \ childvillage cat \ female cat \ age  conts \educ cat \gender bin \) saving("visita_stanforddenvigg_$S_DATE.xls", replace) test missing
	table1, by(inc_chikv )  vars( hcc_ses_improvedroof_index bin\ hcc_ses_improvedfloor_index bin\ hcc_ses_telephone_dum bin\ hcc_ses_radio_dum bin\ hcc_ses_bicycle_dum bin\ hccses_index_sum conts\ hcc_ses_radio bin\ hcc_ses_bicycle cat \  ownland2 cat \ ownmoterbike cat \ childvillage cat \ female cat \ adult cat \age  conts \educ cat \gender bin \) saving("visita_stanfordchikvigg_$S_DATE.xls", replace) test missing
restore

egen aedes_ind_immature = rowtotal(ttl_aedessppindoorlarval ttl_aedessppindoorovitrap ttl_aedessppindoorpupae )
egen aedes_outdoor_immature =   rowtotal(ttl_aedes_spp_outdoorlarval ttl_aedes_spp_outdoorovitrap ttl_aedes_spp_outdoorpupae )
egen aedes_indoor_mature=rowtotal(ttl_aedessppindoorhlc   ttl_aedessppindoorprokopack )
egen aedes_outdoor_mature = rowtotal(ttl_aedes_spp_outdoorhlc ttl_aedes_spp_outdoorprokopack )

tsset id_wide_int visit_int
xtdescribe
xttab inc_chikv   
xttab incident_malaria 
xttab inc_denv 
sum inc_chikv   incident_malaria inc_denv

capture drop l1*

foreach var in ttlrainfall rainfallanoma avgtemp avgmaxtemp avgmintemp avgtemprange avgrh avgdewpt  aedes_outdoor_mature aedes_indoor_mature aedes_outdoor_immature aedes_ind_immature  ttl_aedessppindoorhlc ttl_aedes_spp_outdoorhlc ttl_aedessppindoorlarval ttl_aedes_spp_outdoorlarval ttl_aedessppindoorovitrap ttl_aedes_spp_outdoorovitrap ttl_aedessppindoorprokopack ttl_aedes_spp_outdoorprokopack ttl_aedessppindoorpupae ttl_aedes_spp_outdoorpupae ttl_aedessppsentinel{
sum `var', d
gen l1`var' = l1.`var' /*DENV: first lag didn't work for rain and temp (inversely associated with seroconversion) try it with the second lag*/
order l1`var' 
}
	table1, by(inc_denv) vars(l1ttl_aedessppsentinel conts \ l1ttl_aedes_spp_outdoorpupae conts \ l1ttl_aedessppindoorpupae conts \ l1ttl_aedes_spp_outdoorprokopack conts \ l1ttl_aedessppindoorprokopack conts \ l1ttl_aedes_spp_outdoorovitrap conts \ l1ttl_aedessppindoorovitrap conts \ l1ttl_aedes_spp_outdoorlarval conts \ l1ttl_aedessppindoorlarval conts \ l1ttl_aedes_spp_outdoorhlc conts \ l1ttl_aedessppindoorhlc conts \ l1aedes_ind_immature conts \ l1aedes_outdoor_immature conts \ l1aedes_indoor_mature conts \ l1aedes_outdoor_mature conts \ l1avgdewpt conts \ l1avgrh conts \ l1avgtemprange conts \ l1avgmintemp conts \ l1avgmaxtemp conts \ l1avgtemp conts \ l1rainfallanoma conts \ l1ttlrainfall  conts \ aedes_ind_immature conts \ aedes_outdoor_immature conts \ aedes_indoor_mature conts \ aedes_outdoor_mature conts \  ttl_aedessppindoorhlc conts \  ttl_aedes_spp_outdoorhlc conts \  ttl_aedessppindoorlarval conts \  ttl_aedes_spp_outdoorlarval conts \  ttl_aedessppindoorovitrap conts \  ttl_aedes_spp_outdoorovitrap conts \  ttl_aedessppindoorprokopack conts \  ttl_aedes_spp_outdoorprokopack conts \  ttl_aedessppindoorpupae conts \  ttl_aedes_spp_outdoorpupae conts \  ttl_aedessppsentinel conts \ ttlrainfall conts \  rainfallanoma conts \  avgtemp conts \  avgmaxtemp conts \  avgmintemp conts \   avgtemprange conts \  avgrh conts \   avgdewpt conts \   hcc_ses_improvedroof_index bin\ hcc_ses_improvedfloor_index bin\ hcc_ses_telephone_dum bin\ hcc_ses_radio_dum bin\ hcc_ses_bicycle_dum bin\ hccses_index_sum conts\ hcc_ses_radio bin\ hcc_ses_bicycle cat \  ownland2 cat \ ownmoterbike cat \ childvillage cat \ female cat \ age  conts \educ cat \gender bin \) test missing
	table1, by(inc_chikv) vars(l1ttl_aedessppsentinel conts \ l1ttl_aedes_spp_outdoorpupae conts \ l1ttl_aedessppindoorpupae conts \ l1ttl_aedes_spp_outdoorprokopack conts \ l1ttl_aedessppindoorprokopack conts \ l1ttl_aedes_spp_outdoorovitrap conts \ l1ttl_aedessppindoorovitrap conts \ l1ttl_aedes_spp_outdoorlarval conts \ l1ttl_aedessppindoorlarval conts \ l1ttl_aedes_spp_outdoorhlc conts \ l1ttl_aedessppindoorhlc conts \ l1aedes_ind_immature conts \ l1aedes_outdoor_immature conts \ l1aedes_indoor_mature conts \ l1aedes_outdoor_mature conts \ l1avgdewpt conts \ l1avgrh conts \ l1avgtemprange conts \ l1avgmintemp conts \ l1avgmaxtemp conts \ l1avgtemp conts \ l1rainfallanoma conts \ l1ttlrainfall  conts \ aedes_ind_immature conts \ aedes_outdoor_immature conts \ aedes_indoor_mature conts \ aedes_outdoor_mature conts \  ttl_aedessppindoorhlc conts \  ttl_aedes_spp_outdoorhlc conts \  ttl_aedessppindoorlarval conts \  ttl_aedes_spp_outdoorlarval conts \  ttl_aedessppindoorovitrap conts \  ttl_aedes_spp_outdoorovitrap conts \  ttl_aedessppindoorprokopack conts \  ttl_aedes_spp_outdoorprokopack conts \  ttl_aedessppindoorpupae conts \  ttl_aedes_spp_outdoorpupae conts \  ttl_aedessppsentinel conts \  ttlrainfall conts \  rainfallanoma conts \  avgtemp conts \  avgmaxtemp conts \  avgmintemp conts \ avgtemprange conts \  avgrh conts \ avgdewpt conts \  hcc_ses_improvedroof_index bin\ hcc_ses_improvedfloor_index bin\ hcc_ses_telephone_dum bin\ hcc_ses_radio_dum bin\ hcc_ses_bicycle_dum bin\ hccses_index_sum conts\ hcc_ses_radio bin\ hcc_ses_bicycle cat \  ownland2 cat \ ownmoterbike cat \ childvillage cat \ female cat \ age  conts \educ cat \gender bin \) test missing

/*
xtlogit inc_denv educ gender age mosquito_exposure_index mosquito_prevention_index rainfallanomalies i.site_int avgtemp avgmaxtemp avgmintemp avgtemprange avgrh avgdewpt rainfallanomalies ttlrainfall ttl_aedessppindoorhlc ttl_aedes_spp_outdoorhlc ttl_aedessppindoorlarval ttl_aedes_spp_outdoorlarval ttl_aedessppindoorovitrap ttl_aedes_spp_outdoorovitrap ttl_aedessppindoorprokopack ttl_aedes_spp_outdoorprokopack ttl_aedessppindoorpupae ttl_aedes_spp_outdoorpupae ttl_aedessppsentinel aedes_ind_immature aedes_outdoor_immature aedes_indoor_mature aedes_outdoor_mature, re
xtlogit inc_chikv    educ gender age   mosquito_exposure_index mosquito_prevention_index rainfallanomalies i.site_int avgtemp avgmaxtemp avgmintemp avgtemprange avgrh avgdewpt rainfallanomalies ttlrainfall ttl_aedessppindoorhlc ttl_aedes_spp_outdoorhlc ttl_aedessppindoorlarval ttl_aedes_spp_outdoorlarval ttl_aedessppindoorovitrap ttl_aedes_spp_outdoorovitrap ttl_aedessppindoorprokopack ttl_aedes_spp_outdoorprokopack ttl_aedessppindoorpupae ttl_aedes_spp_outdoorpupae ttl_aedessppsentinel aedes_ind_immature aedes_outdoor_immature aedes_indoor_mature aedes_outdoor_mature, re
xtlogit incident_malaria  educ gender age ownmoterbike i.site_int female adult temprangeanomalies rainfallanomalies avgtemp avgmaxtemp avgmintemp avgtemprange avgrh avgdewpt rainfallanomalies ttlrainfall ttl_aedessppindoorhlc ttl_aedes_spp_outdoorhlc ttl_aedessppindoorlarval ttl_aedes_spp_outdoorlarval ttl_aedessppindoorovitrap ttl_aedes_spp_outdoorovitrap ttl_aedessppindoorprokopack ttl_aedes_spp_outdoorprokopack ttl_aedessppindoorpupae ttl_aedes_spp_outdoorpupae ttl_aedessppsentinel aedes_ind_immature aedes_outdoor_immature aedes_indoor_mature aedes_outdoor_mature, re
bysort site cohort stanforddenvigg_ : fsum hccses_index_ quartile_hccs pct_hccses_in numberofwindows sleepbywindow windowsscreened  hoh_windows sleep_close_w~w drinkingwater  other_water_s~e  light   flooring improvedfloor~x water_cotainers educ gender age mosquito_exposure_index mosquito_prevention_index rainfallanomalies site_int
*/

xtile quartile_aedes_outdoor_immature = aedes_outdoor_immature , nquantiles(4)
xtile quartile_aedes_indoor_mature = aedes_indoor_mature, nquantiles(4)

xtlogit inc_denv  quartile_aedes_outdoor_immature quartile_aedes_indoor_mature , or
xtlogit inc_denv  aedes_outdoor_immature aedes_indoor_mature rainfallanoma avgtemp avgrh avgdewpt gender age , or

xtlogit inc_chikv aedes_outdoor_immature aedes_indoor_mature rainfallanoma avgtemp avgrh avgdewpt gender age 
xtlogit inc_chikv  quartile_aedes_outdoor_immature quartile_aedes_indoor_mature , or
