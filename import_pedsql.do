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

rename *, lower
				ds, has(type string) 
				foreach v of varlist `r(varlist)' { 
					replace `v' = lower(`v') 
					replace `v' = "." if `v' =="na"
					destring `v', replace
					
				}
				
*gen id_wide
rename idcodetwo studyid
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
				egen id_wide = concat(id_city id_cohort id_childnum)
				order id_wide  

*COME BACK AND FIX THIS. I REMOVED ANY DUPLICATE ID'S
duplicates tag  id_wide, gen(dups)
tab dups
drop if dups>0
*COME BACK AND FIX THIS. I REMOVED ANY DUPLICATE ID'S

fsum 
save pedsql, replace 
