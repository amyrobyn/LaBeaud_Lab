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
replace month = 2.5 if month == 25
replace month = 3.5 if month == 35
set matsize 800
set emptycells drop
rename *_mt_* **

*prenatal infected vs uninfected for PnPs 19F
	preserve
	keep ab_pnps19f month infected_prenatal 
		gen log_ab_pnps19f = log(ab_pnps19f)
		mean log_ab_pnps19f, over(month infected_prenatal )
		ereturn display, eform(geo_mean)
	restore

*delivery infected vs uninfected for PnPs 7
	preserve
	keep ab_pnps7  month infected_delivery
		gen log_ab_pnps7 = log(ab_pnps7)
		mean log_ab_pnps7 , over(month infected_delivery )
		ereturn display, eform(geo_mean)
	restore

*delivery infected vs uninfected for Dpt
	preserve
	keep ab_dptcrm  month infected_delivery 
		gen log_ab_dptcrm = log(ab_dptcrm )
		mean log_ab_dptcrm , over(month infected_delivery )
		ereturn display, eform(geo_mean)
	restore

*ever infected vs uninfected for PnPs 6B
	preserve
	keep ab_pnps6b month ever_infected 
		gen log_ab_pnps6b= log(ab_pnps6b)
		mean log_ab_pnps6b, over(month ever_infected )
		ereturn display, eform(geo_mean)
	restore
stop
	*ever infected vs uninfected for PnPs 14
	preserve
	keep ab_pnps14 month ever_infected  
		gen log_ab_pnps14 = log(ab_pnps14)
		mean log_ab_pnps14 , over(month ever_infected)
		ereturn display, eform(geo_mean)
	restore

*ever infected vs uninfected for PnPs 18C
	preserve
	keep ab_pnps18c month ever_infected 
		gen log_ab_pnps18c= log(ab_pnps18c )
		mean log_ab_pnps18c, over(month ever_infected )
		ereturn display, eform(geo_mean)
	restore

*ever infected vs uninfected for PnPs 19F
	preserve
	keep ab_pnps19f month ever_infected 
		gen log_ab_pnps19f = log(ab_pnps19f )
		mean  log_ab_pnps19f  , over(month ever_infected)
		ereturn display, eform(geo_mean)
	restore
*malaria infected vs uninfected for PnPs 4
	preserve
	keep ab_pnps4 month ever_malaria 
		gen log_ab_pnps4  = log(ab_pnps4 )
		mean log_ab_pnps4 , over(month ever_malaria )
		ereturn display, eform(geo_mean)
	restore

*malaria infected vs uninfected for PnPs 5
	preserve
	keep ab_pnps5  month ever_malaria 
		gen log_ab_pnps5  = log(ab_pnps5)
		mean  log_ab_pnps5  , over(month ever_malaria)
		ereturn display, eform(geo_mean)
	restore
*malaria infected vs uninfected for PnPs 7
	preserve
	keep ab_pnps7  month ever_malaria 
		gen log_ab_pnps7  = log(ab_pnps7)
		mean  log_ab_pnps7  , over(month ever_malaria)
		ereturn display, eform(geo_mean)
	restore
*malaria infected vs uninfected for PnPs 14
	preserve
	keep ab_pnps14  month ever_malaria 
		gen log_ab_pnps14  = log(ab_pnps14)
		mean  log_ab_pnps14  , over(month ever_malaria)
		ereturn display, eform(geo_mean)
	restore
*malaria infected vs uninfected for Dpt
	preserve
	keep  ab_dptcrm month ever_malaria 
		gen log_ab_dptcrm= log(ab_dptcrm)
		mean  log_ab_dptcrm, over(month ever_malaria)
		ereturn display, eform(geo_mean)
	restore
*Schisto infected vs uninfected for Hib
	preserve
	keep  ab_hibprp month ever_schisto
		gen log_ab_hibprp= log(ab_hibprp)
		mean   log_ab_hibprp, over(month ever_schisto)
		ereturn display, eform(geo_mean)
	restore
*filaria infected vs uninfected for PnPs 5
	preserve
	keep  ab_pnps5 month ever_filaria
		gen log_ab_pnps5= log(ab_pnps5)
		mean   log_ab_pnps5, over(month ever_filaria)
		ereturn display, eform(geo_mean)
	restore

*filaria infected vs uninfected for PnPs 9v
	preserve
	keep  ab_pnps9v month ever_filaria
		gen log_ab_pnps9v= log(ab_pnps9v)
		mean   log_ab_pnps9v, over(month ever_filaria)
		ereturn display, eform(geo_mean)
	restore

*filaria infected vs uninfected for Hib
	preserve
	keep  ab_hibprp month ever_filaria
		gen log_ab_hibprp= log(ab_hibprp)
		mean   log_ab_hibprp, over(month ever_filaria)
		ereturn display, eform(geo_mean)
	restore
*hookworm infected vs uninfected for PnPs 14
	preserve
	keep  ab_pnps14 month ever_hookworm
		gen log_ab_pnps14 = log(ab_pnps14 )
		mean   log_ab_pnps14 , over(month ever_hookworm)
		ereturn display, eform(geo_mean)
	restore
*hookworm infected vs uninfected for PnPs 19F
	preserve
	keep  ab_pnps19f month ever_hookworm
		gen log_ab_pnps19f= log(ab_pnps19f)
		mean   log_ab_pnps19f , over(month ever_hookworm)
		ereturn display, eform(geo_mean)
	restore
*any sth infected vs uninfected for PnPs 14
	preserve
	keep  ab_pnps14 month ever_any_sth
		gen log_ab_pnps14 = log(ab_pnps14 )
		mean   log_ab_pnps14 , over(month ever_any_sth)
		ereturn display, eform(geo_mean)
	restore
*any sth infected vs uninfected for PnPs 18C
	preserve
	keep  ab_pnps18c month ever_any_sth
		gen log_ab_pnps18c = log(ab_pnps18c)
		mean   log_ab_pnps18c, over(month ever_any_sth)
		ereturn display, eform(geo_mean)
	restore
*any sth infected vs uninfected for PnPs 19F
	preserve
	keep  ab_pnps19f month ever_any_sth
		gen log_ab_pnps19f = log(ab_pnps19f)
		mean   log_ab_pnps19f, over(month ever_any_sth)
		ereturn display, eform(geo_mean)
	restore
*any sth infected vs uninfected for Dpt
	preserve
	keep ab_dptcrm month ever_any_sth 
		gen log_ab_dptcrm= log(ab_dptcrm)
		mean  log_ab_dptcrm, over(month ever_any_sth)
		ereturn display, eform(geo_mean)
	restore
*polyparasitic infected vs uninfected for PnPs 5
	preserve
	keep ab_pnps5 month ever_polyparasitic
		gen log_ab_pnps5= log(ab_pnps5)
		mean  log_ab_pnps5 , over(month ever_polyparasitic)
		ereturn display, eform(geo_mean)
	restore
*polyparasitic infected vs uninfected for PnPs 7
	preserve
	keep ab_pnps7 month ever_polyparasitic
		gen log_ab_pnps7= log(ab_pnps7)
		mean  log_ab_pnps7 , over(month ever_polyparasitic)
		ereturn display, eform(geo_mean)
	restore
*polyparasitic infected vs uninfected for PnPs 9V
	preserve
	keep ab_pnps9v month ever_polyparasitic
		gen log_ab_pnps9v= log(ab_pnps9v)
		mean  log_ab_pnps9v , over(month ever_polyparasitic)
		ereturn display, eform(geo_mean)
	restore
*polyparasitic infected vs uninfected for PnPs 19F
	preserve
	keep ab_pnps19f month ever_polyparasitic
		gen log_ab_pnps19f= log(ab_pnps19f)
		mean  log_ab_pnps19f, over(month ever_polyparasitic)
		ereturn display, eform(geo_mean)
	restore


stop
outsheet using long.csv, comma names replace

*xtset infected week
*twoway (line geo_mean week if infected==1, sort) (line geo_mean week if infected==0, sort), legend(on)

tostring infected, replace
replace infected = "Infected" if infected =="1"
replace infected = "Not" if infected =="0"
outsheet using "`dataset'_long.csv", comma names replace
