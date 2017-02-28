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
tostring villhouse , replace
save xy1, replace

import excel "C:\Users\amykr\Box Sync/DENV CHIKV project/Coast Cleaned/Demography/Demography Latest/Ukunda demography_coordinates August 2016.xls", sheet("demo") firstrow clear
duplicates drop
dropmiss, force
dropmiss, force obs
rename *, lower
egen houseid  = concat(villhouse person2)

duplicates examples houseid
duplicates tag houseid, generate(dup)
order houseid
rename head_of_household* hh*

rename habits_which_livestock_livestock habits_which_livestock
rename habits_which_livestock_livestoc1 habits_which_livestock1
rename habits_attend_livestock_attend_l habits_attend_livestock1
rename habits_attend_livestock_attend_0 habits_attend_livestock0
rename habits_livestock_contact_livesto habits_livestock_contact
rename habits_livestock_contact_livest0 habits_livestock_contact0
*renvars, trim(20)

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
order count_row_different  studyid gps*
gsort -count_row_different studyid
outsheet using duphouseid_gps_different_by_row.csv if dup>=1 & count_row_different >0, name comma replace 
lookfor date
recast int interviewdate 
drop dup
duplicates tag houseid, generate(dup)

outsheet dup gps* interviewdate houseid using duphouseid_gps.csv if dup>=1 & count_row_different >0, name comma replace 
keep if dup>=1 & count_row_different >0
keep dup gps* interviewdate houseid 
save gps, replace
drop dup
bysort houseid: gen dup =_n
rename gps_house_latitude lat 
rename gps_house_longitude lon
reshape wide  gps_compound_latitude gps_compound_longitude gps_compound_altitude gps_compound_accuracy lat lon gps_house_altitude gps_house_accuracy interviewdate , i(houseid) j(dup)

* save type1 and type2 observation separately
geodist lat1 lon1 lat2 lon2, gen(distance_km1)
geodist lat1 lon1 lat3 lon3, gen(distance_km2)
geodist lat2 lon2 lat3 lon3, gen(distance_km3)
sum d* 

outsheet houseid d* using dupsgps.csv, comma names replace
stop
collapse (first) studyid - gps_house_accuracy, by(houseid)


order houseid
gen dataset = "ukunda_demography"
encode keep_livestock , gen(keep_livestock_int)
drop keep_livestock 
rename keep_livestock_int keep_livestock 

gen motor_vehicleint = . 
replace motor_vehicleint =0 if motor_vehicle =="no"
replace motor_vehicleint =1 if motor_vehicle =="yes"
replace motor_vehicleint =8 if motor_vehicle =="refused"
drop motor_vehicle
rename motor_vehicleint motor_vehicle

gen domestic_workerint = . 
replace domestic_workerint =0 if domestic_worker =="no"
replace domestic_workerint =1 if domestic_worker =="yes"
drop domestic_worker 
rename domestic_workerint domestic_worker
save xy2, replace

import excel "C:\Users\amykr\Box Sync\DENV CHIKV project\West Cleaned\Demography\Demography Latest/West Demography Database", sheet("Sheet1") firstrow clear
duplicates drop
	rename *, lower
	gen city = village
		tostring city, replace
		replace city = "chulaimbo" if city =="1"
		replace city = "kisumu" if city =="2"
	
	gen houseid  = house_number
	gen houseidstring = string(houseid ,"%04.0f")
	drop houseid house_number
	rename houseidstring  houseid
	order houseid
	gen dataset = "west_demography"
save xy3, replace

tostring toilet_latrine latrine_location latrine_distance , replace 

append using xy1 xy2

rename village villageid
order houseid villageid
drop if villageid ==.
bysort villageid houseid : gen dup =_n
egen duphouse = concat(houseid dup) if dup>1
replace houseid = duphouse if dup>1
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
	 

	 
replace gps_house_latitude = y if gps_house_latitude==.
replace gps_house_latitude = x if gps_house_longitude==.

dropmiss, force obs piasm  trim
dropmiss, force piasm  trim
rename *, lower
replace site = lower(site)
order city houseid
collapse (first)  studyid - bicycle, by(city houseid)
destring _all, replace
tostring studyid windows city, replace
tab city, m 

save xy, replace
