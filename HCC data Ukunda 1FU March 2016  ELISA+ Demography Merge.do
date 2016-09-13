/****************************************************
 *amy krystosik                  					*
 *HCC data Ukunda 1FU March 2016  ELISA+ Demography Merge    *
 *lebeaud lab               				        *
 *last updated july 21, 2016  						*
 ***************************************************/

cd "C:\Users\Amy\Box Sync\Amy Krystosik's Files\elysse ukunda hcc demography"
capture log close 
log using "HCC data Ukunda 1FU March 2016  ELISA+ Demography Merge_july21,2016.smcl", text replace 
set scrollbufsize 100000
set more 1

*import data
	insheet using "HCC data Ukunda 1FU March 2016  ELISA+ Demography Merge.csv", comma clear
	sum

foreach var of varlist _all{
capture replace `var'=trim(itrim(lower(`var')))
capture replace `var' = "" if `var'==""
rename *, lower
}

**ses index
			sum *ses*
			foreach var of varlist *ses*{
						capture tostring `var', replace
			}
			foreach var of varlist *ses*{
						replace `var'=trim(itrim(lower(`var')))
						gen index`var' ="."
						replace index`var' = "1" if `var' == "yes" 
						replace index`var' = "0" if `var' == "no" |`var' == "none" 
						destring index`var', replace
			}
			
			sum
			egen ses_index_sum= rowtotal(indexhabits_ses_telephone - indexhabits_ses_domestic_worker)

*infectiongroups*
	gen infection_groups=.
	replace infection_group = 0 if chikv==0
	replace infection_group = 0 if denv ==0 
	replace infection_group = 1 if denv ==1 
	replace infection_group = 2 if chikv ==1
	replace infection_group = 3 if chikv ==1 & denv ==1
	tostring infection_group, gen(disease)
	replace disease ="none" if disease =="0"
	replace disease ="denv" if disease =="1"
	replace disease ="chikv" if disease =="2"
	replace disease ="coinfection" if disease =="3"

	bysort disease: sum age gender ses_index_sum

save ukunda, replace 
rename head_of_household_* hh_*
rename head_of_compound_* hc_*
gen sleepsinhouse =  hh_bedrooms*hh_people_per_roo

*gen extra ses vars
replace hh_floor = "0" if hh_floor =="dirt_earth"
replace hh_floor = "1" if hh_floor =="cemented"
replace hh_floor = "2" if hh_floor =="tile"
replace hh_floor = "" if hh_floor =="other"

replace hh_roof = "0" if hh_roof=="natural_material"
replace hh_roof= "1" if hh_roof=="corrugated_iron"
replace hh_roof = "2" if hh_roof=="roofing_tiles"
replace hh_roof = "" if hh_roof =="other"

replace habits_cooking_fuel= "0" if habits_cooking_fuel=="charcoal"|habits_cooking_fuel=="firewood"
replace habits_cooking_fuel= "1" if habits_cooking_fuel=="paraffin"
replace habits_cooking_fuel= "2" if habits_cooking_fuel=="gas"
replace habits_cooking_fuel = "" if habits_cooking_fuel=="other"


replace habits_land = "0" if habits_land =="none"
replace habits_land= "1" if habits_land=="rent"
replace habits_land= "2" if habits_land=="family"
replace habits_land= "3" if habits_land=="own"
replace habits_land= "" if habits_land=="other"


replace habits_latrine_location = "0" if habits_latrine_location =="no_toilet"
replace habits_latrine_location = "1" if habits_latrine_location =="outside_nowater"
replace habits_latrine_location = "2" if habits_latrine_location =="outside_water"
replace habits_latrine_location = "3" if habits_latrine_location =="inside_house"
replace habits_latrine_location = "" if habits_latrine_location =="other"

replace habits_water_source= "0" if habits_water_source=="borehole"|habits_water_source=="borehole_pump"
replace habits_water_source= "1" if habits_water_source=="public_well"
replace habits_water_source= "2" if habits_water_source=="piped_public"
replace habits_water_source= "3" if habits_water_source=="piped_house"
replace habits_water_source= "" if habits_water_source=="other"


foreach var of varlist educlevel mumeduclevel hc_hoc_tribe hc_hoc_religion hh_screens hh_sleep_window hh_own_bednet hh_nunber_bednet hh_sleep_bednet hh_kids_sleep_bed hh_mosquito_contr hh_communal_tv hh_water_collecti hh_floor hh_roof habits_cooking_fuel habits_water_source gender age ses_index_sum counthsehold sleepsinhouse hh_rooms habits_land habits_ses_motor_vehicle habits_ses_bicycle habits_toilet_latrine habits_latrine_location habits_latrine_distance childheight childweight {
		capture confirm string var `var'
			if _rc==0 {
						destring `var', replace 
}
						}

						
sum indexhabits_ses_telephone - indexhabits_ses_domestic_worker habits_land habits_cooking_fuel  hh_roof  hh_floor habits_latrine_location habits_water_source

egen ses_index_sum2= rowtotal(indexhabits_ses_telephone - indexhabits_ses_domestic_worker habits_land habits_cooking_fuel  hh_roof  hh_floor habits_latrine_location habits_water_source)
xtile ses_index_sum2_pct =  ses_index_sum2, n(4)

gen ed_cate = educlevel 
replace ed_cate= 5 if ed_cate ==9

*mosquito index

replace hh_screens = "0" if hh_screens== "no"
replace hh_screens= "1" if hh_screens== "some" 
replace hh_screens= "2" if hh_screens== "yes"

replace hh_kids_sleep_bed= "0" if hh_kids_sleep_bed== "none" 
replace hh_kids_sleep_bed= "2" if hh_kids_sleep_bed== "all"
replace hh_kids_sleep_bed = "1" if hh_kids_sleep_bed== "some"

gen hh_mosquito_contr_dum ="1"
replace hh_mosquito_contr_dum = "0" if hh_mosquito_contr==" n/a"|hh_mosquito_contr=="none"|hh_mosquito_contr=="none n/a"
replace hh_mosquito_contr_dum = "" if hh_mosquito_contr==""


foreach var in hh_sleep_window hh_own_bednet hh_sleep_bednet{
tab `var', gen("dum`var'")
}

foreach var of varlist hh_mosquito_contr_dum educlevel mumeduclevel hc_hoc_tribe hc_hoc_religion hh_screens hh_sleep_window hh_own_bednet hh_nunber_bednet hh_sleep_bednet hh_kids_sleep_bed hh_mosquito_contr hh_communal_tv hh_water_collecti hh_floor hh_roof habits_cooking_fuel habits_water_source gender age ses_index_sum counthsehold sleepsinhouse hh_rooms habits_land habits_ses_motor_vehicle habits_ses_bicycle habits_toilet_latrine habits_latrine_location habits_latrine_distance childheight childweight {
		capture confirm string var `var'
			if _rc==0 {
						destring `var', replace 
}
						}

sum hh_screens  hh_mosquito_contr_dum hh_kids_sleep_bed dumhh_sleep_window2 dumhh_own_bednet2 dumhh_sleep_bednet2
egen mosqcontrol_index= rowtotal(hh_screens  hh_mosquito_contr_dum hh_kids_sleep_bed dumhh_sleep_window2 dumhh_own_bednet2 dumhh_sleep_bednet2)
gen mosqcontrol_index0 = mosqcontrol_index if mosqcontrol_index ==0
replace mosqcontrol_index =. if mosqcontrol_index==0
xtile mosqcontrol_indexpct =  mosqcontrol_index, n(3)
replace mosqcontrol_indexpct =  mosqcontrol_index0 if mosqcontrol_index0 !=.

gen hh_water_collecti_dum="1"
replace hh_water_collecti_dum ="0" if hh_water_collecti =="n/a"
replace hh_water_collecti_dum ="" if hh_water_collecti =="" 
destring hh_water_collecti_dum, replace 

*ed in two cates
table1, by(disease) vars(gender cate\age contn\ed_cate cate\ ses_index_sum2_pct cate\childheight conts\ childweight conts\ mosqcontrol_indexpct cate \ hh_water_collecti_dum cate \) saving("table1_ukunda_disease2.xls", replace) test missing
table1, by(chikv) vars(gender cate\age contn\ed_cate cate\ ses_index_sum2_pct cate\childheight conts\ childweight conts\ mosqcontrol_indexpct cate \ hh_water_collecti_dum cate \) saving("table1_ukunda_chikv2.xls", replace) test missing
table1, by(denv) vars(gender cate\age contn\ed_cate cate\ ses_index_sum2_pct cate\childheight conts\ childweight conts\ mosqcontrol_indexpct cate \ hh_water_collecti_dum cate \) saving("table1_ukunda_denv2.xls", replace) test missing
table1, vars(gender cate\age contn\ed_cate cate\ ses_index_sum2_pct cate\childheight conts\ childweight conts\ mosqcontrol_indexpct cate \ hh_water_collecti_dum cate \) saving("table1_ukunda_total2.xls", replace) test missing
export excel using "ukunda", firstrow(variables) replace
