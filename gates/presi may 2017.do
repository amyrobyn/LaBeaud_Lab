/********************************************************************************************
 *Author: Amy Krystosik			               							  					*
 *Function: Noah Gates figures for Final May presenation 									*
 *Org: LaBeaud Lab, Stanford School of Medicine, Pediatrics 			  					*
 *Last updated: May 3, 2017  									  							*
 *Notes: 																					*
 *******************************************************************************************/ 

capture log close 
set scrollbufsize 100000
set more 1
set scrollbufsize 100000
cd "C:\Users\amykr\Box Sync\Amy Krystosik's Files\Gates\may_2017_presi\CSV files for graphing2\CSV files for graphing"
log using "presentation figures may 2017.smcl", text replace 

local dataset pnps5_all_malaria_v_uninfected


insheet using `dataset'.csv, clear comma names
gen dataset = "`dataset'"
save `dataset', replace


reshape long wk_ , i(child_id) j(week)

rename wk_ GMC
gen log_GMC = log(GMC)
mean log_GMC,  over(infection_status week)
ereturn display, eform(geo_mean)
stop 

destring *, replace

*xtset infected week
*twoway (line geo_mean week if infected==1, sort) (line geo_mean week if infected==0, sort), legend(on)

tostring infected, replace
replace infected = "Infected" if infected =="1"
replace infected = "Not" if infected =="0"
outsheet using "`dataset'_long.csv", comma names replace
