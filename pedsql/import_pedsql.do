*************************************************************
 *amy krystosik                  							  *
 *pedsQL 									  *
 *lebeaud lab               				        		  *
 *last updated april 26, 2017 									  *
 **************************************************************/ 

cd "C:\Users\amykr\Box Sync\Amy Krystosik's Files\pedsql"
capture log close 
log using "pedsql.smcl", text replace 
set scrollbufsize 100000
set more 1

insheet using "C:\Users\amykr\Box Sync\08.17.16 PedQL Data Upload\All Datasets\pedsql dataset\pedsql_init_fu_merge.csv", clear comma names
	rename idcodetwo studyid
save pedsql_init_fu_merge_west, replace

foreach sheet in Ukundaparent Ukundachild Msambweniparent msambwenichild{
	import excel using "C:\Users\amykr\Box Sync\Amy Krystosik's Files\pedsql\Copy of PedSQLdatabase Feb 2016.xls", clear sheet(`sheet') firstrow
	rename ParticipantId studyid
	save `sheet', replace
}
use pedsql_init_fu_merge_west
append using Ukundaparent Ukundachild Msambweniparent msambwenichild

rename *, lower
				ds, has(type string) 
				foreach v of varlist `r(varlist)' { 
					replace `v' = lower(`v') 
					replace `v' = "." if `v' =="na"
					destring `v', replace
					
				}
				
*gen id_wide
		replace studyid= subinstr(studyid, "/", "",.)
		replace studyid= subinstr(studyid, " ", "",.)
		replace studyid= subinstr(studyid, "O", "0",.)

*take visit out of id
									forval i = 1/3 { 
										gen id`i' = substr(studyid, `i', 1) 
									order id`i'
									}

*gen id_wid without visit						 
				rename id1 id_city  
				rename id2 id_cohort  
				rename id3 id_visit 
				tab id_visit 
				gen id_childnumber = ""
				replace id_childnumber = substr(studyid, +4, .)
				destring id_childnumber , replace force 
				egen id_wide = concat(id_city id_cohort id_childnum)
				order id_wide  

*COME BACK AND FIX THIS. I REMOVED ANY DUPLICATE ID'S
duplicates tag  id_wide, gen(dups)
tab dups
*drop if dups>0
*COME BACK AND FIX THIS. I REMOVED ANY DUPLICATE ID'S
rename age agegroup
fsum 
save pedsql, replace 
keep if id_city =="u"|id_city =="m"
save pedsql_coast, replace 
