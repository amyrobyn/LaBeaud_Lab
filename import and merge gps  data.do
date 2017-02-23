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

order houseid
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
