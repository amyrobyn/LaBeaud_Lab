/**************************************************************
 *amy krystosik                  							  *
 *Clinical Misdiagnosis of Malaria and Chikungunya Fever among Febrile Kenyan Children*
 *lebeaud lab               				        		  *
 *last updated march 21, 2017  							  		  *
 **************************************************************/ 
cd "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\malaria\Misdiagnosis of Malaria and CHIKV, Kenya"
capture log close 
log using "Jesse_samples.smcl", text replace 
set scrollbufsize 100000
set more 1

insheet using "Numbers for Parasitemia.csv", clear comma names
rename  studyno  studyid
		replace studyid= lower(studyid)
		replace studyid = subinstr(studyid, ".", "",.) 
		replace studyid = subinstr(studyid, "/", "",.)
		replace studyid = subinstr(studyid, " ", "",.)
			

				*take visit out of id
							forval i = 1/3 { 
								gen id`i' = substr(studyid, `i', 1) 
							}
		*gen id_wid without visit						 
			rename id1 id_city  
			rename id2 id_cohort  
			rename id3 id_visit 
			tab id_visit 
			gen id_childnumber = ""
			replace id_childnumber = substr(studyid, +4, .)
			
		gen byte notnumeric = real(id_childnumber)==.	/*makes indicator for obs w/o numeric values*/
		tab notnumeric	/*==1 where nonnumeric characters*/
		list id_childnumber if notnumeric==1	/*will show which have nonnumeric*/
				
		gen suffix = "" 	
		foreach suffix in a b c d e f g h {
			replace suffix = "`suffix'" if strpos(id_childnumber, "`suffix'")
			replace id_childnumber = subinstr(id_childnumber, "`suffix'","", .)
			}
		destring id_childnumber, replace 	 
		tostring id_childnumber, replace
		egen id_childnumber2 = concat(id_childnumber suffix)
		drop id_childnumber
		rename id_childnumber2 id_childnumber
			order id_cohort id_city id_visit id_childnumber studyid
			egen id_wide = concat(id_city id_cohort id_childnum)
		drop suffix

rename  studyid jesse_studyno  
		
save "Numbers for Parasitemia", replace 

use "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\malaria\malaria_merged", clear
keep if id_cohort =="f"
save malaria_merged_aic, replace

use "Numbers for Parasitemia", clear
merge 1:1 id_wide id_visit using malaria_merged_aic

order studyid id_wide id_visit *id id* _merge 
gsort -_merge 
outsheet using "merge1_malaria_Jesse_W_$S_DATE.csv", comma names replace 
