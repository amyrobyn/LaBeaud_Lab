capture log close 
set scrollbufsize 100000
set more 1
log using "demography.smcl", text replace 

cd "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\demography"

import excel "C:\Users\amykr\Box Sync/DENV CHIKV project/Coast Cleaned/Demography/Demography Latest/Msambweni_coordinates complete Nov 21 2016.xls", sheet("Sheet1") firstrow clear
	duplicates drop
	dropmiss, force
	dropmiss, force obs
gen dataset = "Msambweni_demography"
rename *, lower

gen houseid  = house
	gen houseidstring = string(houseid ,"%04.0f")
	drop houseid house 
	rename houseidstring  houseid
	order houseid
	rename study_id  studyid  
	
		duplicates tag houseid, generate(dup)
		order houseid

		ds, has(type numeric)
		foreach var of var `r(varlist)'{
				gen ne`var' = .
				sort houseid `var'
				by houseid (`var'), sort: gen df`var' = `var'[1] != `var'[_N] if `var'[1] != . & `var'[_N]!=.  
				list houseid  `var' if df`var'  
				*replace ne`var' = 1 if df`var'  
			}

		ds, has(type string)
		foreach var of var `r(varlist)'{
				gen ne`var' = .
				sort houseid `var'
				by houseid  (`var'), sort: gen df`var' = `var'[1] != `var'[_N] if `var'[1] != "" & `var'[_N]!=""  
				list houseid  `var' if df`var'  
				replace ne`var' = 1 if df`var'  
			}

		egen count_row_different = rowtotal(df*)
		order count_row_different  studyid x y 
		gsort -count_row_different studyid
		outsheet using msambweni_duphouseid_gps_different_by_row.csv if dup>=1 & count_row_different >0, name comma replace 

	
	
	
tostring villhouse studyid numberofsleepers , replace
save xy1, replace

import excel "C:\Users\amykr\Box Sync/DENV CHIKV project/Coast Cleaned/Demography/Demography Latest/Ukunda_HCC_children_demography Mar17.xls", sheet("#LN00065") firstrow clear
rename name1	childname1	 
rename name2	childname2	
rename name3 	childname3	
rename name4 	childname4

duplicates drop
dropmiss, force
dropmiss, force obs
rename *, lower
egen houseid  = concat(villhouse personid)

duplicates examples houseid
duplicates tag houseid, generate(dup)
order houseid

ds, has(type numeric)
foreach var of var `r(varlist)'{
		gen ne`var' = .
		sort houseid `var'
		by houseid (`var'), sort: gen df`var' = `var'[1] != `var'[_N] if `var'[1] != . & `var'[_N]!=.  
        list houseid  `var' if df`var'  
		*replace ne`var' = 1 if df`var'  
	}

ds, has(type string)
foreach var of var `r(varlist)'{
		gen ne`var' = .
		sort houseid `var'
		by houseid  (`var'), sort: gen df`var' = `var'[1] != `var'[_N] if `var'[1] != "" & `var'[_N]!=""  
        list houseid  `var' if df`var'  
		replace ne`var' = 1 if df`var'  
	}

egen count_row_different = rowtotal(df*)
order count_row_different  studyid latitude	longitude
gsort -count_row_different studyid
outsheet using ukunda_duphouseid_gps_different_by_row.csv if dup>=1 & count_row_different >0, name comma replace 

lookfor date
foreach var in interviewdate today {
				gen `var'1 = date(`var', "DMY" ,2050)
				format %td `var'1 
				drop `var'
				rename `var'1 `var'
				recast int `var'
				}

drop dup
duplicates tag houseid, generate(dup)
outsheet dup latitude longitude interviewdate houseid using duphouseid_gps.csv if dup>=1 & count_row_different >0, name comma replace 
*keep if dup>=1 & count_row_different >0
*keep dup latitude longitude  interviewdate houseid 
save gps, replace
drop dup
bysort houseid: gen dup =_n
*reshape wide  count_row_different studyid latitude longitude villhouse personid today village interviewer firstname secondname thirdname familyname hh_dob age agemonths hh_gender language languageother tribe tribeother religion maritalstatus havechildren noofchildren ownrent hh_live_here hh_sleep_here yearsindistrict yrsinhouse rooms bedrooms numberofsleepers windows screens sleepbywindow own_bednet usebednet number_bednet childrenusebednet mosquito_control commununal_tv water_containers water_containersother floor roof cookingfuel drinkingwater light ownland livestock livestock_location livestock_type livestock_type_other attend_livestock attend_livestock_freq livestock_contact telephone radio television bicycle motorvehicle domesticservant toilet_latrine latrine_location latrine_distance name1 name2 name3 name4 surname relationship relationship_other dob child_status sex school live_here sleep_here nestudyid dfstudyid nevillhouse dfvillhouse nepersonid dfpersonid nedup dfdup nehouseid dfhouseid netoday dftoday nevillage dfvillage neinterviewdate dfinterviewdate neinterviewer dfinterviewer nefirstname dffirstname nesecondname dfsecondname nethirdname dfthirdname nefamilyname dffamilyname nehh_dob dfhh_dob neage dfage neagemonths dfagemonths nehh_gender dfhh_gender nelanguage dflanguage nelanguageother dflanguageother netribe dftribe netribeother dftribeother nereligion dfreligion nemaritalstatus dfmaritalstatus nehavechildren dfhavechildren nenoofchildren dfnoofchildren neownrent dfownrent nehh_live_here dfhh_live_here nehh_sleep_here dfhh_sleep_here neyearsindistrict dfyearsindistrict neyrsinhouse dfyrsinhouse nerooms dfrooms nebedrooms dfbedrooms nenumberofsleepers dfnumberofsleepers newindows dfwindows nescreens dfscreens nesleepbywindow dfsleepbywindow neown_bednet dfown_bednet neusebednet dfusebednet nenumber_bednet dfnumber_bednet nechildrenusebednet dfchildrenusebednet nemosquito_control dfmosquito_control necommununal_tv dfcommununal_tv newater_containers dfwater_containers newater_containersother dfwater_containersother nefloor dffloor neroof dfroof necookingfuel dfcookingfuel nedrinkingwater dfdrinkingwater nelight dflight neownland dfownland nelivestock dflivestock nelivestock_location dflivestock_location nelivestock_type dflivestock_type nelivestock_type_other dflivestock_type_other neattend_livestock dfattend_livestock neattend_livestock_freq dfattend_livestock_freq nelivestock_contact dflivestock_contact netelephone dftelephone neradio dfradio netelevision dftelevision nebicycle dfbicycle nemotorvehicle dfmotorvehicle nedomesticservant dfdomesticservant netoilet_latrine dftoilet_latrine nelatrine_location dflatrine_location nelatrine_distance dflatrine_distance nename1 dfname1 nename2 dfname2 nename3 dfname3 nename4 dfname4 nesurname dfsurname nerelationship dfrelationship nerelationship_other dfrelationship_other nedob dfdob nechild_status dfchild_status nesex dfsex neschool dfschool nelive_here dflive_here nesleep_here dfsleep_here nelatitude dflatitude nelongitude dflongitude interviewdate, i(houseid) j(dup)
*no more duplicates

order houseid
gen dataset = "ukunda_demography"
encode livestock , gen(livestock_int)
drop livestock 
rename livestock_int keep_livestock 
replace keep_livestock = keep_livestock -1
_strip_labels keep_livestock 

gen motor_vehicleint = . 
rename motorvehicle  motor_vehicle 
replace motor_vehicleint =0 if motor_vehicle =="no"
replace motor_vehicleint =1 if motor_vehicle =="yes"
replace motor_vehicleint =8 if motor_vehicle =="refused"
drop motor_vehicle
rename motor_vehicleint motor_vehicle

gen domestic_workerint = . 
rename  domesticservant domestic_worker 
replace domestic_workerint =0 if domestic_worker =="no"
replace domestic_workerint =1 if domestic_worker =="yes"
drop domestic_worker 
rename domestic_workerint domestic_worker
tostring studyid villhouse numberofsleepers , replace
rename village city

foreach var in hh_dob  dob {
				gen `var'1 = date(`var', "DMY" ,2000)
				format %td `var'1 
				drop `var'
				rename `var'1 `var'
				recast int `var'
				}

rename dob child_dob

	desc child_dob
	tab  child_dob
	gen child_dob_month = month( child_dob)
	gen child_dob_year= year( child_dob)
	gen child_dob_day = day( child_dob)

	tab child_dob_month 
	tab child_dob_year
	tab child_dob_day 

save xy2, replace

import excel "C:\Users\amykr\Box Sync\DENV CHIKV project\West Cleaned\Demography\Demography Latest/West Demography Database", sheet("Sheet1") firstrow clear
duplicates drop
	rename *, lower
	gen city = village
		tostring city, replace
		replace city = "chulaimbo" if city =="1"
		replace city = "kisumu" if city =="2"
	
	gen houseid  = house_number
	desc child_dob
	tab  child_dob
	gen child_dob_month = month( child_dob)
	gen child_dob_year= year( child_dob)
	gen child_dob_day = day( child_dob)

	tab child_dob_month 
	tab child_dob_year
	tab child_dob_day 

	egen village_house_child_id  = concat(city house_number chid_individualid)
	bysort village_house_child_id  : gen dup =_n

	list city house_number chid_individualid village_house_child_id   child_dob_year child_dob if child_dob_year <1999
	count if child_dob==. 
 	


	
						
					ds, has(type numeric)
					foreach var of var `r(varlist)'{
							gen ne`var' = .
							sort village_house_child_id  `var'
							by village_house_child_id  (`var'), sort: gen df`var' = `var'[1] != `var'[_N] if `var'[1] != . & `var'[_N]!=.  
							list village_house_child_id  `var' if df`var'  
							*replace ne`var' = 1 if df`var'  
						}

					ds, has(type string)
					foreach var of var `r(varlist)'{
							gen ne`var' = .
							sort village_house_child_id   `var'
							by village_house_child_id   (`var'), sort: gen df`var' = `var'[1] != `var'[_N] if `var'[1] != "" & `var'[_N]!=""  
							list village_house_child_id    `var' if df`var'  
							replace ne`var' = 1 if df`var'  
						}

					egen count_row_different = rowtotal(df*)
					order count_row_different  studyid house_latitude house_longitude
					gsort -count_row_different studyid
					order houseid city village_house_child_id chid_individualid compnumber

					outsheet using west_duphouseid_gps_different_by_row.csv if dup>=1 & count_row_different >0, name comma replace 


	
	gen houseidstring = string(houseid ,"%04.0f")
	drop houseid house_number
	rename houseidstring  houseid
	order houseid
	gen dataset = "west_demography"
	tostring studyid livestock_location attend_livestock, replace

save xy3, replace

tostring toilet_latrine latrine_location latrine_distance , replace 

append using xy1 xy2
replace city = lower(city)
rename village villageid
order houseid villageid
tab villageid 
*drop if villageid ==.

capture drop dup
bysort city villageid houseid : gen dup =_n
tab dup

egen duphouse = concat(houseid dup) if dup>1
tostring villageid windows, replace

foreach var in telephone radio bicycle {
gen `var'int=.
replace `var'int=1 if `var'=="yes"
replace `var'int=0 if `var'=="no"
replace `var'int=8 if `var'=="refused"
replace `var'int=8 if `var'=="ref"

drop `var'
rename `var'int `var'
}

gen site = ""
replace site = "West" if dataset =="west_demography"
replace site = "Coast" if dataset =="ukunda_demography"
replace site = "Coast" if dataset =="Msambweni_demography"

destring houseid villageid, replace

replace city = "chulaimbo" if villageid == 1 & dataset =="west_demography"
replace city = "kisumu" if villageid == 2 & dataset =="west_demography" 

replace city = "milani" if villageid == 4 & dataset =="Msambweni_demography"
replace city = "nganja" if villageid == 3 & dataset =="Msambweni_demography"

*are there villages in ukunda? there are repeat houses within and over villageid. 
replace city = "ukunda" if dataset =="ukunda_demography"	

order latitude longitude x y house_longitude house_latitude


dropmiss, force obs piasm  trim
dropmiss, force piasm  trim
rename *, lower
replace site = lower(site)
order city houseid
destring _all, replace
tostring studyid windows city, replace
tab city, m 


encode television , gen(television_int)
drop television 

*collapse (firstnm) latitude (firstnm) longitude (firstnm) x (firstnm) y (firstnm) house_longitude (firstnm) house_latitude (firstnm) villageid (firstnm) studyid (firstnm) today (firstnm) interviewdate (firstnm) interviewername (firstnm) compstatus (firstnm) compnumber (firstnm) compound_latitude (firstnm) compound_longitude (firstnm) compound_altitude (firstnm) compound_accuracy (firstnm) hoc_surname (firstnm) hoc_fname (firstnm) hoc_mname (firstnm) hoc_lname (firstnm) hoc_othername (firstnm) hoc_studyid (firstnm) hoc_gender (firstnm) hoc_dob (firstnm) hoc_age (firstnm) hoc_category (firstnm) hoc_language (firstnm) hoc_othlanguage (firstnm) hoc_tribe (firstnm) hoc_othtribe (firstnm) hoc_religion (firstnm) hoc_married (firstnm) hoc_other_married (firstnm) hoc_sleep_status (firstnm) house_altitude (firstnm) house_accuracy (firstnm) house_pic (firstnm) hoh_surname (firstnm) hoh_fname (firstnm) hoh_mname (firstnm) hoh_lname (firstnm) hoh_othername (firstnm) hoh_studyid (firstnm) hoh_gender (firstnm) hoh_dob (firstnm) hoh_age (firstnm) hoh_category (firstnm) hoh_language (firstnm) hoh_othlanguage (firstnm) hoh_tribe (firstnm) hoh_othtribe (firstnm) hoh_religion (firstnm) hoh_married (firstnm) hoh_other_married (firstnm) hoh_children (firstnm) hoh_num_children (firstnm) hoh_house (firstnm) hoh_other_house (firstnm) hoh_sleep_here (firstnm) hoh_live_here (firstnm) hoh_district_years (firstnm) hoh_house_years (firstnm) hoh_rooms (firstnm) hoh_bedrooms (firstnm) hoh_people_per_room (firstnm) hoh_windows (firstnm) hoh_screens (firstnm) sleep_close_window (firstnm) hoh_own_bednet (firstnm) hoh_number_bednet (firstnm) hoh_sleep_bednet (firstnm) hoh_kids_sleep_bednet (firstnm) hoh_mosquito_control (firstnm) hoh_communal_tv (firstnm) hoh_water_collection (firstnm) hoh_floor (firstnm) hoh_roof (firstnm) hoh_other_roof (firstnm) cooking_fuel (firstnm) water_source (firstnm) other_water_source (firstnm) light_source (firstnm) other_light_source (firstnm) land_ownership (firstnm) other_land (firstnm) keep_livestock (firstnm) livestock_location (firstnm) which_livestock (firstnm) which_other_livestock (firstnm) attend_livestock (firstnm) livestock_contact (firstnm) own_telephone (firstnm) own_radio (firstnm) own_tv (firstnm) own_bicycle (firstnm) motor_vehicle (firstnm) domestic_worker (firstnm) toilet_latrine (firstnm) other_toilet_latrine (firstnm) latrine_location (firstnm) latrine_location_other (firstnm) latrine_distance (firstnm) other_latrine_distance (firstnm) child_fname (firstnm) child_mname (firstnm) child_lname (firstnm) child_othername (firstnm) child_familyname (firstnm) child_relationship (firstnm) relationship_other (firstnm) chid_individualid (firstnm) child_dob (firstnm) child_age (firstnm) child_category (firstnm) child_status (firstnm) child_gender (firstnm) school_name (firstnm) live_here (firstnm) sleep_here (firstnm) dataset (firstnm) date (firstnm) datetime (firstnm) villagehouse (firstnm) person_id (firstnm) villhouse (firstnm) interviewer (firstnm) firstname (firstnm) secondname (firstnm) familyname (firstnm) sex (firstnm) monthborn (firstnm) yearborn (firstnm) language (firstnm) languageother (firstnm) tribe (firstnm) tribeother (firstnm) religion (firstnm) maritalstatus (firstnm) havechildren (firstnm) ownrent (firstnm) ownrentspecify (firstnm) yearsindistrict (firstnm) yrsindistspecify (firstnm) yearsinhouse (firstnm) yrsinhousespecify (firstnm) roomsinhouse (firstnm) bedroomsinhouse (firstnm) numberofsleepers (firstnm) numberofwindows (firstnm) sleepbywindow (firstnm) usebednet (firstnm) windowsscreened (firstnm) childrenusebednet (firstnm) nettreated (firstnm) flooring (firstnm) floorspecify (firstnm) roof (firstnm) roofspecify (firstnm) complete (firstnm) count_row_different (firstnm) personid (firstnm) thirdname (firstnm) age (firstnm) agemonths (firstnm) hh_gender (firstnm) noofchildren (firstnm) hh_live_here (firstnm) hh_sleep_here (firstnm) yrsinhouse (firstnm) rooms (firstnm) bedrooms (firstnm) windows (firstnm) screens (firstnm) own_bednet (firstnm) number_bednet (firstnm) mosquito_control (firstnm) commununal_tv (firstnm) water_containers (firstnm) water_containersother (firstnm) floor (firstnm) cookingfuel (firstnm) drinkingwater (firstnm) light (firstnm) ownland (firstnm) livestock_type (firstnm) livestock_type_other (firstnm) attend_livestock_freq (firstnm) name1 (firstnm) name2 (firstnm) name3 (firstnm) name4 (firstnm) surname (firstnm) relationship (firstnm) school (firstnm) dfstudyid (firstnm) dfvillhouse (firstnm) dfpersonid (firstnm) dfdup (firstnm) dfhouseid (firstnm) dftoday (firstnm) nevillage (firstnm) dfvillage (firstnm) dfinterviewdate (firstnm) neinterviewer (firstnm) dfinterviewer (firstnm) nefirstname (firstnm) dffirstname (firstnm) nesecondname (firstnm) dfsecondname (firstnm) nethirdname (firstnm) dfthirdname (firstnm) nefamilyname (firstnm) dffamilyname (firstnm) dfhh_dob (firstnm) dfage (firstnm) dfagemonths (firstnm) nehh_gender (firstnm) dfhh_gender (firstnm) nelanguage (firstnm) dflanguage (firstnm) nelanguageother (firstnm) dflanguageother (firstnm) netribe (firstnm) dftribe (firstnm) netribeother (firstnm) dftribeother (firstnm) nereligion (firstnm) dfreligion (firstnm) nemaritalstatus (firstnm) dfmaritalstatus (firstnm) nehavechildren (firstnm) dfhavechildren (firstnm) dfnoofchildren (firstnm) neownrent (firstnm) dfownrent (firstnm) nehh_live_here (firstnm) dfhh_live_here (firstnm) nehh_sleep_here (firstnm) dfhh_sleep_here (firstnm) dfyearsindistrict (firstnm) dfyrsinhouse (firstnm) dfrooms (firstnm) dfbedrooms (firstnm) dfnumberofsleepers (firstnm) dfwindows (firstnm) nescreens (firstnm) dfscreens (firstnm) nesleepbywindow (firstnm) dfsleepbywindow (firstnm) neown_bednet (firstnm) dfown_bednet (firstnm) neusebednet (firstnm) dfusebednet (firstnm) dfnumber_bednet (firstnm) nechildrenusebednet (firstnm) dfchildrenusebednet (firstnm) nemosquito_control (firstnm) dfmosquito_control (firstnm) necommununal_tv (firstnm) dfcommununal_tv (firstnm) newater_containers (firstnm) dfwater_containers (firstnm) newater_containersother (firstnm) dfwater_containersother (firstnm) nefloor (firstnm) dffloor (firstnm) neroof (firstnm) dfroof (firstnm) necookingfuel (firstnm) dfcookingfuel (firstnm) nedrinkingwater (firstnm) dfdrinkingwater (firstnm) nelight (firstnm) dflight (firstnm) neownland (firstnm) dfownland (firstnm) nelivestock (firstnm) dflivestock (firstnm) nelivestock_location (firstnm) dflivestock_location (firstnm) nelivestock_type (firstnm) dflivestock_type (firstnm) nelivestock_type_other (firstnm) dflivestock_type_other (firstnm) neattend_livestock (firstnm) dfattend_livestock (firstnm) neattend_livestock_freq (firstnm) dfattend_livestock_freq (firstnm) nelivestock_contact (firstnm) dflivestock_contact (firstnm) netelephone (firstnm) dftelephone (firstnm) neradio (firstnm) dfradio (firstnm) netelevision (firstnm) dftelevision (firstnm) nebicycle (firstnm) dfbicycle (firstnm) nemotorvehicle (firstnm) dfmotorvehicle (firstnm) nedomesticservant (firstnm) dfdomesticservant (firstnm) netoilet_latrine (firstnm) dftoilet_latrine (firstnm) nelatrine_location (firstnm) dflatrine_location (firstnm) nelatrine_distance (firstnm) dflatrine_distance (firstnm) nename1 (firstnm) dfname1 (firstnm) nename2 (firstnm) dfname2 (firstnm) nename3 (firstnm) dfname3 (firstnm) nename4 (firstnm) dfname4 (firstnm) nesurname (firstnm) dfsurname (firstnm) nerelationship (firstnm) dfrelationship (firstnm) nerelationship_other (firstnm) dfrelationship_other (firstnm) dfdob (firstnm) nechild_status (firstnm) dfchild_status (firstnm) nesex (firstnm) dfsex (firstnm) neschool (firstnm) dfschool (firstnm) nelive_here (firstnm) dflive_here (firstnm) nesleep_here (firstnm) dfsleep_here (firstnm) dflatitude (firstnm) dflongitude (firstnm) dup (firstnm) duphouse (firstnm) telephone (firstnm) radio (firstnm) bicycle (firstnm) site (firstnm) hh_dob (firstnm) dob (firstnm) television_int,  by(city houseid)
save temp, replace

/*desc studyid interviewername hoc_surname  hoc_fname  hoc_mname hoc_lname hoc_othername  hoc_othlanguage  hoc_othtribe hoc_other_married house_pic hoh_surname hoh_fname hoh_mname hoh_lname hoh_othername hoh_studyid  hoh_othlanguage hoh_othtribe hoh_other_married 
foreach var in  latitude longitude x y house_longitude house_latitude villageid  today interviewdate compstatus compnumber compound_latitude compound_longitude compound_altitude compound_accuracy hoc_studyid hoc_gender hoc_dob hoc_age hoc_category hoc_language hoc_tribe hoc_religion hoc_married  hoc_sleep_status house_altitude house_accuracy   hoh_gender hoh_dob hoh_age hoh_category hoh_language  hoh_tribe  hoh_religion hoh_married  hoh_children hoh_num_children hoh_house hoh_other_house hoh_sleep_here hoh_live_here hoh_district_years hoh_house_years hoh_rooms hoh_bedrooms hoh_people_per_room hoh_windows hoh_screens sleep_close_window hoh_own_bednet hoh_number_bednet hoh_sleep_bednet hoh_kids_sleep_bednet hoh_mosquito_control hoh_communal_tv hoh_water_collection hoh_floor hoh_roof hoh_other_roof cooking_fuel water_source other_water_source light_source other_light_source land_ownership other_land keep_livestock livestock_location which_livestock which_other_livestock attend_livestock livestock_contact own_telephone own_radio own_tv own_bicycle motor_vehicle domestic_worker toilet_latrine other_toilet_latrine latrine_location latrine_location_other latrine_distance other_latrine_distance child_fname child_mname child_lname child_othername child_familyname child_relationship relationship_other chid_individualid child_dob child_age child_category child_status child_gender school_name live_here sleep_here dataset date datetime villagehouse person_id villhouse interviewer firstname secondname familyname sex monthborn yearborn language languageother tribe tribeother religion maritalstatus havechildren ownrent ownrentspecify yearsindistrict yrsindistspecify yearsinhouse yrsinhousespecify roomsinhouse bedroomsinhouse numberofsleepers numberofwindows sleepbywindow usebednet windowsscreened childrenusebednet nettreated flooring floorspecify roof roofspecify complete count_row_different personid thirdname age agemonths hh_gender noofchildren hh_live_here hh_sleep_here yrsinhouse rooms bedrooms windows screens own_bednet number_bednet mosquito_control commununal_tv water_containers water_containersother floor cookingfuel drinkingwater light ownland livestock_type livestock_type_other attend_livestock_freq name1 name2 name3 name4 surname relationship school dfstudyid dfvillhouse dfpersonid dfdup dfhouseid dftoday nevillage dfvillage dfinterviewdate neinterviewer dfinterviewer nefirstname dffirstname nesecondname dfsecondname nethirdname dfthirdname nefamilyname dffamilyname dfhh_dob dfage dfagemonths nehh_gender dfhh_gender nelanguage dflanguage nelanguageother dflanguageother netribe dftribe netribeother dftribeother nereligion dfreligion nemaritalstatus dfmaritalstatus nehavechildren dfhavechildren dfnoofchildren neownrent dfownrent nehh_live_here dfhh_live_here nehh_sleep_here dfhh_sleep_here dfyearsindistrict dfyrsinhouse dfrooms dfbedrooms dfnumberofsleepers dfwindows nescreens dfscreens nesleepbywindow dfsleepbywindow neown_bednet dfown_bednet neusebednet dfusebednet dfnumber_bednet nechildrenusebednet dfchildrenusebednet nemosquito_control dfmosquito_control necommununal_tv dfcommununal_tv newater_containers dfwater_containers newater_containersother dfwater_containersother nefloor dffloor neroof dfroof necookingfuel dfcookingfuel nedrinkingwater dfdrinkingwater nelight dflight neownland dfownland nelivestock dflivestock nelivestock_location dflivestock_location nelivestock_type dflivestock_type nelivestock_type_other dflivestock_type_other neattend_livestock dfattend_livestock neattend_livestock_freq dfattend_livestock_freq nelivestock_contact dflivestock_contact netelephone dftelephone neradio dfradio netelevision dftelevision nebicycle dfbicycle nemotorvehicle dfmotorvehicle nedomesticservant dfdomesticservant netoilet_latrine dftoilet_latrine nelatrine_location dflatrine_location nelatrine_distance dflatrine_distance nename1 dfname1 nename2 dfname2 nename3 dfname3 nename4 dfname4 nesurname dfsurname nerelationship dfrelationship nerelationship_other dfrelationship_other dfdob nechild_status dfchild_status nesex dfsex neschool dfschool nelive_here dflive_here nesleep_here dfsleep_here dflatitude dflongitude dup duphouse telephone radio bicycle site hh_dob dob television_int{
use temp, clear
display "`var'"
collapse (firstnm) `var' ,  by(city houseid)
}
*/

duplicates tag houseid city, generate(duplicatehouseid)
tab duplicatehouseid dataset
order duplicate*
sort houseid city

sort city houseid child_dob_year child_dob_month child_dob 
order city houseid child_dob_year child_dob_month child_dob 
count if child_dob ==. 

replace child_dob_month = 99 if child_dob == .
replace child_dob_year= 99 if child_dob == .
replace child_dob_day= 99 if child_dob == .

	tab child_dob_month dataset, m
	tab child_dob_year, m
	tab child_dob_day , m

replace childname1 = child_fname   if childname1 ==""
	drop child_fname   
replace childname2 = child_mname  if childname2 ==""
	drop child_mname  
replace childname3 = child_lname    if childname3 ==""
	drop child_lname    
replace childname4 = child_familyname if childname4 ==""
	drop child_familyname 
gen space =" "
egen childname_long = concat(childname1 space childname2 space childname3 space childname4)
replace childname_long = lower(trim(itrim(childname_long)))

replace childname_long = subinstr(childname_long, "n/a", "", .)
replace childname_long = subinstr(childname_long, "n /a", "", .)
replace childname_long = lower(trim(itrim(childname_long)))
	replace childname1 = "99" if childname1 ==""
	replace childname2 = "99" if childname2 ==""
	replace childname3 = "99" if childname3 ==""
	replace childname4 = "99" if childname4 ==""
replace chid_individualid  =99 if chid_individualid ==. 
drop dup*
egen long_id =concat(city houseid chid_individualid child_dob_year child_dob_month child_dob_day  childname1 childname2 childname3 childname4)
duplicates tag city houseid chid_individualid child_dob_year child_dob_month child_dob_day   childname1 childname2 childname3 childname4, generate(dup_long)
order long_id dup_long city houseid chid_individualid child_dob_year child_dob_month child_dob_day  childname1 childname2 childname3 childname4 
sort dup_long city houseid chid_individualid child_dob_year child_dob_month child_dob_day  childname1 childname2 childname3 childname4 
drop df* ne*  count_row_different 
	duplicates drop
	dropmiss, force
	dropmiss, force obs

									ds, has(type numeric)
									foreach var of var `r(varlist)'{
											gen ne`var' = .
											sort long_id `var'
											by long_id  (`var'), sort: gen df`var' = `var'[1] != `var'[_N] if `var'[1] != . & `var'[_N]!=.  
											list long_id `var' if df`var'  
											*replace ne`var' = 1 if df`var'  
										}

									ds, has(type string)
									foreach var of var `r(varlist)'{
											gen ne`var' = .
											sort long_id `var'
											by long_id   (`var'), sort: gen df`var' = `var'[1] != `var'[_N] if `var'[1] != "" & `var'[_N]!=""  
											list long_id `var' if df`var'  
											replace ne`var' = 1 if df`var'  
										}

									egen count_row_different = rowtotal(df*)
									order count_row_different  studyid x y longitude latitude house_longitude house_latitude
									gsort -count_row_different studyid
									outsheet using all_duphouseid_gps_different_by_row.csv if dup_long >=1 & count_row_different >0, name comma replace 


drop if dup_long >0
isid city houseid chid_individualid child_dob_year child_dob_month child_dob_day childname1 childname2 childname3 childname4 

rename chid_individualid id_childnumber

save xy, replace

use xy, clear
keep if city == "milani"|city == "nganja" 
save hh_xy, replace

use xy, clear
keep if city != "milani" & city != "nganja" 
encode studyid, gen(id)

egen name_dob = concat (id_childnumber space child_dob_month space child_dob_year space childname_long)
save child_xy, replace

levelsof city, local(levels) 
foreach l of local levels {
	use child_xy, clear
	keep if city=="`l'"
	save child_xy`l', replace
}
