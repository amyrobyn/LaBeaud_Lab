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
rename study_id  studyid  
tostring studyid numberofsleepers , replace
gen city = village
tostring city, replace
replace city = "milani" if city== "4" & dataset =="Msambweni_demography"
replace city = "nganja" if city== "3" & dataset =="Msambweni_demography"
desc city houseid 
duplicates tag houseid city, generate(houseid_city_dup)
tab houseid_city_dup
outsheet using msambweni_houseid_city_dup.csv if houseid_city_dup>0, comma names replace
drop if houseid_city_dup>0
isid city houseid 
tostring villhouse village, replace
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
order village_house_child dup_village_house_child
gsort -dup_village_house_child
tab dup_village_house_child
gen city ="Ukunda"
gen houseid =villhouse
order houseid 
tostring houseid , replace
replace houseid = substr(houseid, 2, .)
destring houseid , replace
rename personid id_childnumber 
isid city houseid id_childnumber 

desc city houseid id_childnumber 
list city houseid id_childnumber 

lookfor date
foreach var in interviewdate today {
				gen `var'1 = date(`var', "DMY" ,2050)
				format %td `var'1 
				drop `var'
				rename `var'1 `var'
				recast int `var'
				}


order village_house_child
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
tostring village_house_child villhouse numberofsleepers , replace

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
tostring villhouse village, replace
save ukunda_xy2, replace

import excel "C:\Users\amykr\Box Sync\DENV CHIKV project\West Cleaned\Demography\Demography Latest/West Demography Database", sheet("Sheet1") firstrow clear
duplicates drop
	rename *, lower
	gen city = village
	tostring city, replace
	
	gen houseid  = house_number
	gen id_childnumber = chid_individualid
	duplicates tag city houseid id_childnumber , gen(city_houseid_id_childnumber_dup)
	tab city_houseid_id_childnumber_dup
	outsheet using west_city_houseid_id_childnumber_dup.csv if city_houseid_id_childnumber_dup>0, comma names replace
	drop if city_houseid_id_childnumber_dup>0
	replace city = "chulaimbo" if city =="1"
	replace city = "kisumu" if city =="2"

isid city houseid id_childnumber 
desc city houseid id_childnumber 
list city houseid id_childnumber 


	gen child_dob_month = month( child_dob)
	gen child_dob_year= year( child_dob)
	gen child_dob_day = day( child_dob)

	tab child_dob_month 
	tab child_dob_year
	tab child_dob_day 


	list city house_number chid_individualid child_dob_year child_dob if child_dob_year <1999
	count if child_dob==. 
	egen village_house_child = concat(city houseid id_childnumber) 
	
	gen dataset = "west_demography"
	tostring studyid livestock_location attend_livestock, replace

tostring village toilet_latrine latrine_location latrine_distance , replace 
save west_xy3, replace

append using msmbweni_xy1 ukunda_xy2


replace city = lower(city)
rename village villageid
order houseid villageid
tab villageid 

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

sort houseid city village_house_child

sort city houseid village_house_child child_dob_year child_dob_month child_dob 
order city houseid village_house_child child_dob_year child_dob_month child_dob 
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
	duplicates drop
	dropmiss, force
	dropmiss, force obs

save xy, replace
	keep if city == "milani"|city == "nganja" 
	duplicates tag city houseid , gen(city_houseid_dup)
	tab city_houseid_dup
	outsheet using city_houseid_dup.csv if city_houseid_dup >0, replace comma names
	duplicates drop
	drop if city_houseid_dup >0
	isid city houseid 
	save hh_xy, replace

use xy, clear
	tab city
	keep if city != "milani" & city != "nganja" 
	encode studyid, gen(id)
	destring *, replace
	isid city houseid id_childnumber 
	desc city houseid id_childnumber 
save child_xy, replace
