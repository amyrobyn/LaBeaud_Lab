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
				*list houseid  `var' if df`var'  
				*replace ne`var' = 1 if df`var'  
			}

		ds, has(type string)
		foreach var of var `r(varlist)'{
				gen ne`var' = .
				sort houseid `var'
				by houseid  (`var'), sort: gen df`var' = `var'[1] != `var'[_N] if `var'[1] != "" & `var'[_N]!=""  
				*list houseid  `var' if df`var'  
				replace ne`var' = 1 if df`var'  
			}

		egen count_row_different = rowtotal(df*)
		order count_row_different  studyid x y 
		gsort -count_row_different studyid
		outsheet using msambweni_duphouseid_gps_different_by_row.csv if dup>=1 & count_row_different >0, name comma replace 

	
	
	
tostring villhouse studyid numberofsleepers , replace
save msmbweni_xy1, replace

import excel "C:\Users\amykr\Box Sync/DENV CHIKV project/Coast Cleaned/Demography/Demography Latest/Ukunda_HCC_children_demography Mar17.xls", sheet("#LN00065") firstrow clear
	rename name1 childname1	 
	rename name2 childname2	
	rename name3 childname3	
	rename name4 childname4

duplicates drop
dropmiss, force
dropmiss, force obs
rename *, lower
rename studyid village_house_child
duplicates tag village_house_child, generate(dup_village_house_child)

ds, has(type numeric)
foreach var of var `r(varlist)'{
		gen ne`var' = .
		sort village_houseid_child `var'
		by village_houseid_child (`var'), sort: gen df`var' = `var'[1] != `var'[_N] if `var'[1] != . & `var'[_N]!=.  
        *list village_houseid_child `var' if df`var'  
		*replace ne`var' = 1 if df`var'  
	}

ds, has(type string)
foreach var of var `r(varlist)'{
		gen ne`var' = .
		sort village_houseid_child `var'
		by village_houseid_child (`var'), sort: gen df`var' = `var'[1] != `var'[_N] if `var'[1] != "" & `var'[_N]!=""  
        *list village_houseid_child `var' if df`var'  
		replace ne`var' = 1 if df`var'  
	}

egen count_row_different = rowtotal(df*)
order count_row_different studyid latitude longitude
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

save gps, replace

order village_houseid_child
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

save ukunda_xy2, replace

import excel "C:\Users\amykr\Box Sync\DENV CHIKV project\West Cleaned\Demography\Demography Latest/West Demography Database", sheet("Sheet1") firstrow clear
duplicates drop
	rename *, lower
	gen city = village
		tostring city, replace
	
	gen houseid  = house_number
	desc child_dob
	tab  child_dob
	gen child_dob_month = month( child_dob)
	gen child_dob_year= year( child_dob)
	gen child_dob_day = day( child_dob)

	tab child_dob_month 
	tab child_dob_year
	tab child_dob_day 

	egen village_houseid_child  = concat(city house_number chid_individualid)
	bysort village_houseid_child  : gen dup =_n
	replace city = "chulaimbo" if city =="1"
	replace city = "kisumu" if city =="2"

	list city house_number chid_individualid village_houseid_child child_dob_year child_dob if child_dob_year <1999
	count if child_dob==. 
 	
					
					ds, has(type numeric)
					foreach var of var `r(varlist)'{
							gen ne`var' = .
							sort village_houseid_child  `var'
							by village_houseid_child (`var'), sort: gen df`var' = `var'[1] != `var'[_N] if `var'[1] != . & `var'[_N]!=.  
							*list village_houseid_child `var' if df`var'  
							*replace ne`var' = 1 if df`var'  
						}

					ds, has(type string)
					foreach var of var `r(varlist)'{
							gen ne`var' = .
							sort village_houseid_child `var'
							by village_houseid_child (`var'), sort: gen df`var' = `var'[1] != `var'[_N] if `var'[1] != "" & `var'[_N]!=""  
							*list village_houseid_child `var' if df`var'  
							replace ne`var' = 1 if df`var'  
						}

					egen count_row_different = rowtotal(df*)
					order count_row_different  studyid house_latitude house_longitude
					gsort -count_row_different studyid
					order houseid city village_houseid_child chid_individualid compnumber

					outsheet using west_duphouseid_gps_different_by_row.csv if dup>=1 & count_row_different >0, name comma replace 

	
	gen houseidstring = string(houseid ,"%04.0f")
	drop houseid house_number
	rename houseidstring  houseid
	order houseid
	gen dataset = "west_demography"
	tostring studyid livestock_location attend_livestock, replace

tostring toilet_latrine latrine_location latrine_distance , replace 

save west_xy3, replace

append using xy1 xy2
replace city = lower(city)
rename village villageid
order houseid villageid
tab villageid 
*drop if villageid ==.

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

save temp, replace

sort houseid city village_houseid_child

sort city houseid village_houseid_child child_dob_year child_dob_month child_dob 
order city houseid village_houseid_child child_dob_year child_dob_month child_dob 
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
duplicates tag city houseid chid_individualid child_dob_year child_dob_month child_dob_day childname1 childname2 childname3 childname4, generate(dup_long)
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
											*list long_id `var' if df`var'  
											*replace ne`var' = 1 if df`var'  
										}

									ds, has(type string)
									foreach var of var `r(varlist)'{
											gen ne`var' = .
											sort long_id `var'
											by long_id   (`var'), sort: gen df`var' = `var'[1] != `var'[_N] if `var'[1] != "" & `var'[_N]!=""  
											*list long_id `var' if df`var'  
											replace ne`var' = 1 if df`var'  
										}

									egen count_row_different = rowtotal(df*)
									order count_row_different  studyid x y longitude latitude house_longitude house_latitude
									gsort -count_row_different studyid
									outsheet using all_duphouseid_gps_different_by_row.csv if dup_long >=1 & count_row_different >0, name comma replace 


rename chid_individualid id_childnumber
save xy, replace

use xy, clear
keep if city == "milani"|city == "nganja" 
save hh_xy, replace



use xy, clear
	tab city
	keep if city != "milani" & city != "nganja" 
	encode studyid, gen(id)
save child_xy, replace

*collapse to first non missing or first house. 
		destring *, replace
	collapse  (first) village_houseid_child (first) count_row_different (first) x (first) y (first) longitude (first) latitude (first) house_longitude (first) house_latitude (first) dup_long (first) child_dob_year (first) child_dob_month (first) child_dob_day (first) child_dob (first) villageid (first) compnumber (first) today (first) interviewdate (first) compstatus (first) compound_latitude (first) compound_longitude (first) compound_altitude (first) compound_accuracy (first) hoc_studyid (first) hoc_gender (first) hoc_dob (first) hoc_age (first) hoc_category (first) hoc_language (first) hoc_tribe (first) hoc_religion (first) hoc_married (first) hoc_sleep_status (first) house_altitude (first) house_accuracy (first) hoh_studyid (first) hoh_gender (first) hoh_dob (first) hoh_age (first) hoh_category (first) hoh_language (first) hoh_tribe (first) hoh_religion (first) hoh_married (first) hoh_children (first) hoh_num_children (first) hoh_house (first) hoh_sleep_here (first) hoh_live_here (first) hoh_district_years (first) hoh_house_years (first) hoh_rooms (first) hoh_bedrooms (first) hoh_people_per_room (first) hoh_windows (first) hoh_screens (first) sleep_close_window (first) hoh_own_bednet (first) hoh_number_bednet (first) hoh_sleep_bednet (first) hoh_kids_sleep_bednet (first) hoh_communal_tv (first) hoh_floor (first) hoh_roof (first) cooking_fuel (first) water_source (first) light_source (first) land_ownership (first) keep_livestock (first) own_telephone (first) own_radio (first) own_tv (first) own_bicycle (first) motor_vehicle (first) domestic_worker (first) child_othername (first) child_relationship (first) child_age (first) child_category (first) child_gender (first) school_name (first) date (first) datetime (first) villagehouse (first) person_id (first) villhouse (first) monthborn (first) yearborn (first) ownrentspecify (first) yearsindistrict (first) yrsindistspecify (first) yearsinhouse (first) yrsinhousespecify (first) roomsinhouse (first) bedroomsinhouse (first) numberofsleepers (first) numberofwindows (first) windowsscreened (first) flooring (first) floorspecify (first) roofspecify (first) complete (first) personid (first) age (first) agemonths (first) noofchildren (first) yrsinhouse (first) rooms (first) bedrooms (first) windows (first) number_bednet (first) hh_dob (first) telephone (first) radio (first) bicycle (first) television_int (first) space (first) nedup_long (first) dfdup_long (first) nehouseid (first) dfhouseid (first) nechid_individualid (first) dfchid_individualid (first) nechild_dob_year (first) dfchild_dob_year (first) nechild_dob_month (first) dfchild_dob_month (first) nechild_dob_day (first) dfchild_dob_day (first) nechild_dob (first) dfchild_dob (first) nelatitude (first) dflatitude (first) nelongitude (first) dflongitude (first) nex (first) dfx (first) ney (first) dfy (first) nehouse_longitude (first) dfhouse_longitude (first) nehouse_latitude (first) dfhouse_latitude (first) nevillageid (first) dfvillageid (first) necompnumber (first) dfcompnumber (first) netoday (first) dftoday (first) neinterviewdate (first) dfinterviewdate (first) necompstatus (first) dfcompstatus (first) necompound_latitude (first) dfcompound_latitude (first) necompound_longitude (first) dfcompound_longitude (first) necompound_altitude (first) dfcompound_altitude (first) necompound_accuracy (first) dfcompound_accuracy (first) nehoc_studyid (first) dfhoc_studyid (first) nehoc_gender (first) dfhoc_gender (first) nehoc_dob (first) dfhoc_dob (first) nehoc_age (first) dfhoc_age (first) nehoc_category (first) dfhoc_category (first) nehoc_language (first) dfhoc_language (first) nehoc_tribe (first) dfhoc_tribe (first) nehoc_religion (first) dfhoc_religion (first) nehoc_married (first) dfhoc_married (first) nehoc_sleep_status (first) dfhoc_sleep_status (first) nehouse_altitude (first) dfhouse_altitude (first) nehouse_accuracy (first) dfhouse_accuracy (first) nehoh_studyid (first) dfhoh_studyid (first) nehoh_gender (first) dfhoh_gender (first) nehoh_dob (first) dfhoh_dob (first) nehoh_age (first) dfhoh_age (first) nehoh_category (first) dfhoh_category (first) nehoh_language (first) dfhoh_language (first) nehoh_tribe (first) dfhoh_tribe (first) nehoh_religion (first) dfhoh_religion (first) nehoh_married (first) dfhoh_married (first) nehoh_children (first) dfhoh_children (first) nehoh_num_children (first) dfhoh_num_children (first) nehoh_house (first) dfhoh_house (first) nehoh_sleep_here (first) dfhoh_sleep_here (first) nehoh_live_here (first) dfhoh_live_here (first) nehoh_district_years (first) dfhoh_district_years (first) nehoh_house_years (first) dfhoh_house_years (first) nehoh_rooms (first) dfhoh_rooms (first) nehoh_bedrooms (first) dfhoh_bedrooms (first) nehoh_people_per_room (first) dfhoh_people_per_room (first) nehoh_windows (first) dfhoh_windows (first) nehoh_screens (first) dfhoh_screens (first) nesleep_close_window (first) dfsleep_close_window (first) nehoh_own_bednet (first) dfhoh_own_bednet (first) nehoh_number_bednet (first) dfhoh_number_bednet (first) nehoh_sleep_bednet (first) dfhoh_sleep_bednet (first) nehoh_kids_sleep_bednet (first) dfhoh_kids_sleep_bednet (first) nehoh_communal_tv (first) dfhoh_communal_tv (first) nehoh_floor (first) dfhoh_floor (first) nehoh_roof (first) dfhoh_roof (first) necooking_fuel (first) dfcooking_fuel (first) newater_source (first) dfwater_source (first) nelight_source (first) dflight_source (first) neland_ownership (first) dfland_ownership (first) nekeep_livestock (first) dfkeep_livestock (first) neown_telephone (first) dfown_telephone (first) neown_radio (first) dfown_radio (first) neown_tv (first) dfown_tv (first) neown_bicycle (first) dfown_bicycle (first) nemotor_vehicle (first) dfmotor_vehicle (first) nedomestic_worker (first) dfdomestic_worker (first) nechild_relationship (first) dfchild_relationship (first) nechild_age (first) dfchild_age (first) nechild_category (first) dfchild_category (first) nechild_gender (first) dfchild_gender (first) nedate (first) dfdate (first) nedatetime (first) dfdatetime (first) neperson_id (first) dfperson_id (first) nevillhouse (first) dfvillhouse (first) neyearborn (first) dfyearborn (first) neyrsindistspecify (first) dfyrsindistspecify (first) neyrsinhousespecify (first) dfyrsinhousespecify (first) neroomsinhouse (first) dfroomsinhouse (first) nebedroomsinhouse (first) dfbedroomsinhouse (first) nenumberofsleepers (first) dfnumberofsleepers (first) nenumberofwindows (first) dfnumberofwindows (first) nepersonid (first) dfpersonid (first) neage (first) dfage (first) neagemonths (first) dfagemonths (first) nenoofchildren (first) dfnoofchildren (first) neyrsinhouse (first) dfyrsinhouse (first) nerooms (first) dfrooms (first) nebedrooms (first) dfbedrooms (first) nenumber_bednet (first) dfnumber_bednet (first) nehh_dob (first) dfhh_dob (first) netelephone (first) dftelephone (first) neradio (first) dfradio (first) nebicycle (first) dfbicycle (first) netelevision_int (first) dftelevision_int (first) nelong_id (first) dflong_id (first) necity (first) dfcity (first) nechildname1 (first) dfchildname1 (first) nechildname2 (first) dfchildname2 (first) nechildname3 (first) dfchildname3 (first) nechildname4 (first) dfchildname4 (first) nevillage_houseid_child (first) dfvillage_houseid_child (first) nestudyid (first) dfstudyid (first) neinterviewername (first) dfinterviewername (first) nehoc_surname (first) dfhoc_surname (first) nehoc_fname (first) dfhoc_fname (first) nehoc_mname (first) dfhoc_mname (first) nehoc_lname (first) dfhoc_lname (first) nehoc_othername (first) dfhoc_othername (first) nehoc_othlanguage (first) dfhoc_othlanguage (first) nehoc_othtribe (first) dfhoc_othtribe (first) nehoc_other_married (first) dfhoc_other_married (first) nehouse_pic (first) dfhouse_pic (first) nehoh_surname (first) dfhoh_surname (first) nehoh_fname (first) dfhoh_fname (first) nehoh_mname (first) dfhoh_mname (first) nehoh_lname (first) dfhoh_lname (first) nehoh_othername (first) dfhoh_othername (first) nehoh_othlanguage (first) dfhoh_othlanguage (first) nehoh_othtribe (first) dfhoh_othtribe (first) nehoh_other_married (first) dfhoh_other_married (first) nehoh_other_house (first) dfhoh_other_house (first) nehoh_mosquito_control (first) dfhoh_mosquito_control (first) nehoh_water_collection (first) dfhoh_water_collection (first) nehoh_other_roof (first) dfhoh_other_roof (first) neother_water_source (first) dfother_water_source (first) neother_light_source (first) dfother_light_source (first) neother_land (first) dfother_land (first) nelivestock_location (first) dflivestock_location (first) newhich_livestock (first) dfwhich_livestock (first) newhich_other_livestock (first) dfwhich_other_livestock (first) neattend_livestock (first) dfattend_livestock (first) nelivestock_contact (first) dflivestock_contact (first) netoilet_latrine (first) dftoilet_latrine (first) neother_toilet_latrine (first) dfother_toilet_latrine (first) nelatrine_location (first) dflatrine_location (first) nelatrine_location_other (first) dflatrine_location_other (first) nelatrine_distance (first) dflatrine_distance (first) neother_latrine_distance (first) dfother_latrine_distance (first) nechild_othername (first) dfchild_othername (first) nerelationship_other (first) dfrelationship_other (first) nechild_status (first) dfchild_status (first) neschool_name (first) dfschool_name (first) nelive_here (first) dflive_here (first) nesleep_here (first) dfsleep_here (first) nedataset (first) dfdataset (first) nevillagehouse (first) dfvillagehouse (first) neinterviewer (first) dfinterviewer (first) nefirstname (first) dffirstname (first) nesecondname (first) dfsecondname (first) nefamilyname (first) dffamilyname (first) nesex (first) dfsex (first) nemonthborn (first) dfmonthborn (first) nelanguage (first) dflanguage (first) nelanguageother (first) dflanguageother (first) netribe (first) dftribe (first) netribeother (first) dftribeother (first) nereligion (first) dfreligion (first) nemaritalstatus (first) dfmaritalstatus (first) nehavechildren (first) dfhavechildren (first) neownrent (first) dfownrent (first) neownrentspecify (first) dfownrentspecify (first) neyearsindistrict (first) dfyearsindistrict (first) neyearsinhouse (first) dfyearsinhouse (first) nesleepbywindow (first) dfsleepbywindow (first) neusebednet (first) dfusebednet (first) newindowsscreened (first) dfwindowsscreened (first) nechildrenusebednet (first) dfchildrenusebednet (first) neflooring (first) dfflooring (first) nefloorspecify (first) dffloorspecify (first) neroof (first) dfroof (first) neroofspecify (first) dfroofspecify (first) necomplete (first) dfcomplete (first) nethirdname (first) dfthirdname (first) nehh_gender (first) dfhh_gender (first) nehh_live_here (first) dfhh_live_here (first) nehh_sleep_here (first) dfhh_sleep_here (first) newindows (first) dfwindows (first) nescreens (first) dfscreens (first) neown_bednet (first) dfown_bednet (first) nemosquito_control (first) dfmosquito_control (first) necommununal_tv (first) dfcommununal_tv (first) newater_containers (first) dfwater_containers (first) newater_containersother (first) dfwater_containersother (first) nefloor (first) dffloor (first) necookingfuel (first) dfcookingfuel (first) nedrinkingwater (first) dfdrinkingwater (first) nelight (first) dflight (first) neownland (first) dfownland (first) nelivestock_type (first) dflivestock_type (first) nelivestock_type_other (first) dflivestock_type_other (first) neattend_livestock_freq (first) dfattend_livestock_freq (first) nesurname (first) dfsurname (first) nerelationship (first) dfrelationship (first) neschool (first) dfschool (first) nesite (first) dfsite (first) nespace (first) dfspace (first) nechildname_long (first) dfchildname_long (first) other_latrine_distance (first) latrine_location_other (first) other_toilet_latrine (first) which_other_livestock (first) which_livestock (first) other_land (first) other_light_source (first) other_water_source (first) hoh_other_roof (first) hoh_water_collection (first) id (first) childname_long (first) site (first) school (first) relationship (first) surname (first) attend_livestock_freq (first) livestock_type_other (first) livestock_type (first) ownland (first) light (first) drinkingwater (first) cookingfuel (first) floor (first) water_containersother (first) water_containers (first) commununal_tv (first) mosquito_control (first) own_bednet (first) screens (first) hh_sleep_here (first) hh_live_here (first) hh_gender (first) thirdname (first) roof (first) childrenusebednet (first) usebednet (first) sleepbywindow (first) ownrent (first) havechildren (first) maritalstatus (first) religion (first) tribe (first) tribeother (first) language (first) languageother (first) sex (first) firstname (first) secondname (first) familyname (first) interviewer (first) dataset (first) sleep_here (first) live_here (first) child_status (first) relationship_other (first) latrine_distance (first) latrine_location (first) toilet_latrine (first) livestock_contact (first) attend_livestock (first) studyid (first) long_id (first) childname1 (first) childname2 (first) childname3 (first) childname4 (first) interviewername (first) hoc_surname (first) hoc_fname (first) hoc_mname (first) hoc_lname (first) hoc_othername (first) hoc_othlanguage (first) hoc_othtribe (first) hoc_other_married (first) house_pic (first) hoh_surname (first) hoh_fname (first) hoh_mname (first) hoh_lname (first) hoh_othername (first) hoh_othlanguage (first) hoh_othtribe (first) hoh_other_married (first) hoh_other_house (first) hoh_mosquito_control (first) livestock_location, by(city houseid id_childnumber)
		tab city 
		tab	houseid 
		tab id_childnumber
count if city  =="" | houseid ==. | id_childnumber ==.
list village_houseid_child if city  =="" | houseid ==. | id_childnumber ==.
		isid city houseid id_childnumber 
		list city houseid id_childnumber 
		isid village_houseid_child
		list village_houseid_child
		save collapsed_child_xy, replace
