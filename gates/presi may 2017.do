/********************************************************************************************
 *Author: Amy Krystosik			               							  					*
 *Function: Noah Gates figures for Final May presenation 									*
 *Org: LaBeaud Lab, Stanford School of Medicine, Pediatrics 			  					*
 *Last updated: May 8, 2017  									  							*
 *Notes: 																					*
 *******************************************************************************************/ 

capture log close 
set scrollbufsize 100000
set more 1
set scrollbufsize 100000
cd "C:\Users\amykr\Box Sync\Amy Krystosik's Files\Gates\may_2017_presi\CSV files for graphing2\CSV files for graphing"
log using "presentation figures may 2017.smcl", text replace 

insheet using "C:\Users\amykr\Box Sync\Amy Krystosik's Files\Gates\gates data for amy v2.csv", comma clear names

foreach months in 25 30 35 36 6 12 18 24 0{
rename *`months'_months *_months_`months'
}
rename *months* *mt*
rename *__* *_*

foreach antibody in  pnps1_mt_ pnps4_mt_ pnps5_mt_ pnps6b_mt_ pnps7_mt_ pnps9v_mt_ pnps14_mt_ pnps18c_mt_ pnps19f_mt_ pnps23f_mt_ dptcrm_mt_ hibprp_mt_{
rename `antibody'* ab_`antibody'* 
}

reshape long ab_pnps1_mt_ ab_pnps4_mt_ ab_pnps5_mt_ ab_pnps6b_mt_ ab_pnps7_mt_ ab_pnps9v_mt_ ab_pnps14_mt_ ab_pnps18c_mt_ ab_pnps19f_mt_ ab_pnps23f_mt_ ab_dptcrm_mt_ ab_hibprp_mt_, i(child_id) j(month)

rename  *_mt_*  **
reshape long ab_, i(child_id month) j(ab) s
rename ab_ ab_ug_ml
outsheet using long.csv, comma names replace

gen log_ab_ug_ml = log(ab_ug_ml)
set matsize 800
mean log_ab_ug_ml ,  over(month  infected_prenatal infected_delivery ever_infected ever_malaria ever_schisto ever_hookworm ever_filaria ever_any_sth ever_polyparasitic)
ereturn display, eform(geo_mean)

destring *, replace

*xtset infected week
*twoway (line geo_mean week if infected==1, sort) (line geo_mean week if infected==0, sort), legend(on)

tostring infected, replace
replace infected = "Infected" if infected =="1"
replace infected = "Not" if infected =="0"
outsheet using "`dataset'_long.csv", comma names replace
