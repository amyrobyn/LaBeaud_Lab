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
	tostring infection_group, gen(Disease)
	replace Disease ="None" if Disease =="0"
	replace Disease ="DenV" if Disease =="1"
	replace Disease ="ChikV" if Disease =="2"
	replace Disease ="Coinfection" if Disease =="3"

	bysort Disease: sum age gender ses_index_sum

save ukunda, replace 
rename head_of_household_* hh_*
rename head_of_compound_* hc_*
gen sleepsinhouse =  hh_bedrooms*hh_people_per_roo

sum childheight childweight educlevel mumeduclevel  hc_hoc_tribe hc_hoc_religion hh_screens hh_sleep_window hh_own_bednet hh_nunber_bednet hh_sleep_bednet hh_kids_sleep_bed hh_mosquito_contr hh_communal_tv hh_water_collecti hh_floor hh_roof habits_cooking_fuel habits_water_source gender age ses_index_sum counthsehold sleepsinhouse hh_rooms hh_sleep_bednet hh_sleep_bednet hh_kids_sleep_bed hh_screens hh_floor hh_roof habits_water_source habits_land habits_ses_motor_vehicle habits_ses_bicycle habits_toilet_latrine habits_latrine_location habits_latrine_distance
foreach var of varlist educlevel mumeduclevel hc_hoc_tribe hc_hoc_religion hh_screens hh_sleep_window hh_own_bednet hh_nunber_bednet hh_sleep_bednet hh_kids_sleep_bed hh_mosquito_contr hh_communal_tv hh_water_collecti hh_floor hh_roof habits_cooking_fuel habits_water_source gender age ses_index_sum counthsehold sleepsinhouse hh_rooms habits_land habits_ses_motor_vehicle habits_ses_bicycle habits_toilet_latrine habits_latrine_location habits_latrine_distance childheight childweight {
		capture confirm string var `var'
			if _rc==0 {
						encode `var', gen("`var'_int")
}
						}

						
*gen extra ses vars
replace hh_floor_int = 0 if hh_floor_int ==2|hh_floor_int ==3
replace hh_floor_int = 1 if hh_floor_int ==1
replace hh_floor_int = 2 if hh_floor_int ==4
*label define hh_floor_int 0 "low", add
label define hh_floor_int 1 "medium", modify
label define hh_floor_int 2 "High", modify
label define hh_floor_int 3 "", modify
label define hh_floor_int 4 "", modify

replace hh_roof_int = 0 if hh_roof_int==2|hh_roof_int ==3
replace hh_roof_int= 1 if hh_roof_int==1
replace hh_roof_int = 2 if hh_roof_int==4
*label define hh_roof_int 0 "low", add
label define hh_roof_int 1 "medium", modify
label define hh_roof_int 2 "High", modify
label define hh_roof_int 3 "", modify
label define hh_roof_int 4 "", modify

replace habits_cooking_fuel_int= 0 if habits_cooking_fuel_int==1|habits_cooking_fuel_int==2
replace habits_cooking_fuel_int= 1 if habits_cooking_fuel_int==4
replace habits_cooking_fuel_int= 2 if habits_cooking_fuel_int==3
*label define  habits_cooking_fuel_int 0 "low", add
label define  habits_cooking_fuel_int 1 "medium", modify
label define  habits_cooking_fuel_int 2 "High", modify
label define  habits_cooking_fuel_int 3 "", modify
label define  habits_cooking_fuel_int 4 "", modify

replace habits_land_int = 0 if habits_land_int ==2
replace habits_land_int= 1 if habits_land_int ==4
replace habits_land_int= 2 if habits_land_int ==1
replace habits_land_int= 3 if habits_land_int ==3
*label define  habits_land_int 0 "low", add
label define  habits_land_int 1 "medium", modify
label define  habits_land_int 2 "High", modify
label define  habits_land_int 3 "Highest", modify
label define  habits_land_int 4 "", modify


replace habits_latrine_location_int = 0 if habits_latrine_location_int ==2
replace habits_latrine_location_int = 1 if habits_latrine_location_int ==3
replace habits_latrine_location_int = 2 if habits_latrine_location_int  ==4
replace habits_latrine_location_int  = 3 if habits_latrine_location_int ==1
*label define  habits_latrine_location_int 0 "none", add
label define  habits_latrine_location_int  1 "low", modify
label define  habits_latrine_location_int 2 "med", modify
label define  habits_latrine_location_int  3 "high", modify
label define  habits_latrine_location_int  4 "", modify

replace habits_water_source_int = . if habits_water_source_int==3
replace habits_water_source_int = 3 if habits_water_source_int==6
replace habits_water_source_int = 4 if habits_water_source_int==5
replace habits_water_source_int = 5 if habits_water_source_int==4
label define  habits_latrine_location_int  1 "low", modify
label define  habits_latrine_location_int 2 "", modify
label define  habits_latrine_location_int  3 "", modify
label define  habits_latrine_location_int  4 "", modify
label define  habits_latrine_location_int  4 "high", modify

egen ses_index_sum2= rowtotal(indexhabits_ses_telephone - indexhabits_ses_domestic_worker habits_land_int habits_cooking_fuel_int hh_roof_int hh_floor_int habits_latrine_location_int habits_water_source_int)

xtile ses_index_sum2_pct =  ses_index_sum2, n(4)
*tab ses_index_sum2_pct, gen(ses_index_sum2_quart)

gen ed_cate = educlevel 
replace ed_cate= 5 if ed_cate ==9

*mosquito index
sum hh_screens_int hh_sleep_window_int hh_own_bednet_int hh_sleep_bednet_int hh_kids_sleep_bed_int hh_mosquito_contr_int

replace hh_kids_sleep_bed_int = 4 if hh_kids_sleep_bed_int == 1 
replace hh_kids_sleep_bed_int = 0 if hh_kids_sleep_bed_int == 2 
replace hh_kids_sleep_bed_int = 1 if hh_kids_sleep_bed_int == 3 
replace hh_kids_sleep_bed_int = 2 if hh_kids_sleep_bed_int == 4

gen hh_mosquito_contr_dum =.
replace hh_mosquito_contr_dum = 0 if hh_mosquito_contr_int==3|hh_mosquito_contr_int==4|hh_mosquito_contr_int==5
replace hh_mosquito_contr_dum = 1 if hh_mosquito_contr_int==1|hh_mosquito_contr_int==2|hh_mosquito_contr_int==5|hh_mosquito_contr_int==6|hh_mosquito_contr_int==7|hh_mosquito_contr_int==8|hh_mosquito_contr_int==9


foreach var in hh_sleep_window_int hh_own_bednet_int hh_sleep_bednet_int{
tab `var', gen("dum`var'")
}
egen mosqcontrol_index= rowtotal(hh_screens_int  hh_mosquito_contr_dum hh_kids_sleep_bed_int dumhh_sleep_window_int2 dumhh_own_bednet_int2 dumhh_sleep_bednet_int2)
xtile mosqcontrol_indexpct =  mosqcontrol_index, n(4)
*tab mosqcontrol_indexpct, gen(mosqcontrol_index_quart)

gen hh_water_collecti_dum=1
replace hh_water_collecti_dum =0 if hh_water_collecti_int  ==16|hh_water_collecti_int ==17
replace hh_water_collecti_dum =. if hh_water_collecti_int  == . 

*ed in two cates
table1, by(Disease) vars(gender cate\age contn\ed_cate cate\ ses_index_sum2_pct cate\childheight conts\ childweight conts\ mosqcontrol_indexpct cate \ hh_water_collecti_dum cate \) saving("table1_ukunda_disease2.xls", replace) test missing
table1, by(chikv) vars(gender cate\age contn\ed_cate cate\ ses_index_sum2_pct cate\childheight conts\ childweight conts\ mosqcontrol_indexpct cate \ hh_water_collecti_dum cate \) saving("table1_ukunda_chikv2.xls", replace) test missing
table1, by(denv) vars(gender cate\age contn\ed_cate cate\ ses_index_sum2_pct cate\childheight conts\ childweight conts\ mosqcontrol_indexpct cate \ hh_water_collecti_dum cate \) saving("table1_ukunda_denv2.xls", replace) test missing
table1, vars(gender cate\age contn\ed_cate cate\ ses_index_sum2_pct cate\childheight conts\ childweight conts\ mosqcontrol_indexpct cate \ hh_water_collecti_dum cate \) saving("table1_ukunda_total2.xls", replace) test missing
export excel using "ukunda", firstrow(variables) replace
