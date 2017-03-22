/********************************************************************
 *amy krystosik                  							  		*
 *specifity and sensitvity by lab- from july 2016 through march 2017* 
 *elisa for chikv and denv.											*
 *lebeaud lab               				        		  		*
 *last updated march 20, 2017  							  			*
 ********************************************************************/ 

cd "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\elisas\compare july 16 and marhc 17"

capture log close 
log using "elisa_compare_july2016_march2017.smcl", text replace 
set scrollbufsize 100000
set more 1
		
		use "prevalentstanforddenvigg_march2017", clear
		merge 1:1 id_wide visit using "prevalentstanforddenvigg_july2016"
		*keep if _merge==1
		save prevalentstanfordchikvigg_aug2016-march2017, replace
		local outcomemarch stanforddenvigg_march2017  
		local outcomejuly stanforddenvigg_july2016 
		tabout `outcomemarch' `outcomejuly' using "`outcome1'comparison.xls", replace
		compare `outcomemarch' `outcomejuly'
		egen discordant = concat(`outcomemarch' `outcomejuly') if `outcomemarch' !=. & `outcomejuly' !=. & `outcomemarch' != `outcomejuly'
		tabout discordant using discordant`outcomejuly'.xls, replace
		keep if  `outcomejuly'==. |  `outcomejuly' != `outcomemarch' & `outcomemarch' !=.
		keep `outcomemarch' id_wide visit 
		save prevalent`outcomemarch', replace
		
		use "prevalentstanfordchikvigg_march2017", clear
		merge 1:1 id_wide visit using "prevalentstanfordchikvigg_july2016"
		*keep if _merge==1
		save prevalentstanfordchikvigg_aug2016-march2017, replace
		local outcomemarch stanfordchikvigg_march2017 
		local outcomejuly stanfordchikvigg_july2016 
		tabout `outcomemarch' `outcomejuly' using "`outcome1'comparison.xls", replace
		compare `outcomemarch' `outcomejuly'
		egen discordant = concat(`outcomemarch' `outcomejuly') if `outcomemarch' !=. & `outcomejuly' !=. & `outcomemarch' != `outcomejuly'
		tabout discordant using discordant`outcomejuly'.xls, replace
		keep if  `outcomejuly'==. |  `outcomejuly' != `outcomemarch' & `outcomemarch' !=.
		keep `outcomemarch' id_wide visit 
		save prevalent`outcomemarch', replace
		
		use "prevalentchikvigg_march2017", clear
		merge 1:1 id_wide visit using "prevalentchikvigg_july2016"
		*keep if _merge==1
		save prevalentchikvigg_aug2016-march2017, replace
		local outcomemarch chikvigg_march2017  
		local outcomejuly chikvigg_july2016 
		tabout `outcomemarch' `outcomejuly' using "`outcome1'comparison.xls", replace
		compare `outcomemarch' `outcomejuly'
		egen discordant = concat(`outcomemarch' `outcomejuly') if `outcomemarch' !=. & `outcomejuly' !=. & `outcomemarch' != `outcomejuly'
		tabout discordant using discordant`outcomejuly'.xls, replace
		keep if  `outcomejuly'==. |  `outcomejuly' != `outcomemarch' & `outcomemarch' !=.
		keep `outcomemarch' id_wide visit 
		save prevalent`outcomemarch', replace

		
		use "prevalentdenvigg_march2017", clear
		merge 1:1 id_wide visit using "prevalentdenvigg_july2016"
		*keep if _merge==1
		local outcomemarch denvigg_march2017  
		local outcomejuly denvigg_july2016  
		tabout `outcomemarch' `outcomejuly' using "`outcome1'comparison.xls", replace
		compare `outcomemarch' `outcomejuly'
		egen discordant = concat(`outcomemarch' `outcomejuly') if `outcomemarch' !=. & `outcomejuly' !=. & `outcomemarch' != `outcomejuly'
		tabout discordant using discordant`outcomejuly'.xls, replace
		keep if  `outcomejuly'==. |  `outcomejuly' != `outcomemarch' & `outcomemarch' !=.
		keep `outcomemarch' id_wide visit 
		save prevalent`outcomemarch', replace

use "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\elisas\march 2017\prevalent", clear
merge 1:1 id_wide visit using "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\elisas\compare july 16 and marhc 17\prevalentdenvigg_march2017"
drop _merge
merge 1:1 id_wide visit using "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\elisas\compare july 16 and marhc 17\prevalentchikvigg_march2017"
drop _merge
merge 1:1 id_wide visit using "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\elisas\compare july 16 and marhc 17\prevalentstanforddenvigg_march2017"
drop _merge
merge 1:1 id_wide visit using "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\elisas\compare july 16 and marhc 17\prevalentstanfordchikvigg_march2017"

save prevalent_march2017, replace

order stanfordchikvigg_march2017 stanforddenvigg_march2017 chikvigg_march2017 denvigg_march2017
sum stanfordchikvigg_march2017 stanforddenvigg_march2017 chikvigg_march2017 denvigg_march2017
keep if stanfordchikvigg_march2017 !=. | stanforddenvigg_march2017 !=. | chikvigg_march2017 !=. | denvigg_march2017!=. 

label variable stanfordchikvigg_march2017  "STANFORD CHIKV IGG AUG 2016 TO MARCH 2017"
label define stanfordchikvigg_march2017   0 "NEG" 1 "POS" , modify
label values stanfordchikvigg_march2017    stanfordchikvigg_march2017   
tab stanfordchikvigg_march2017    

label variable stanforddenvigg_march2017 "STANFORD DENV IGG AUG 2016 TO MARCH 2017"
label define stanforddenvigg_march2017  0 "NEG" 1 "POS" , modify
label values stanforddenvigg_march2017  stanforddenvigg_march2017 
tab stanforddenvigg_march2017  

label variable chikvigg_march2017  "KENYAN CHIKV IGG AUG 2016 TO MARCH 2017"
label define chikvigg_march2017  0 "NEG" 1 "POS" , modify
label values chikvigg_march2017  chikvigg_march2017 
tab chikvigg_march2017  

label variable denvigg_march2017 "KENYAN DENV IGG AUG 2016 TO MARCH 2017"
label define denvigg_march2017  0 "NEG" 1 "POS" , modify
label values denvigg_march2017  denvigg_march2017 
tab denvigg_march2017 

save compare_elisa_stanford_kenya_march2017, replace
table1, vars(stanfordchikvigg_march2017 bin \ stanforddenvigg_march2017 bin \ chikvigg_march2017 bin \ denvigg_march2017 bin \) by(site) saving(prev_bycity.xls, replace) 
table1, vars(stanfordchikvigg_march2017 bin \ stanforddenvigg_march2017 bin \ chikvigg_march2017 bin \ denvigg_march2017 bin \) by(city) saving(prev_bycity.xls, replace) 
table1, vars(stanfordchikvigg_march2017 bin \ stanforddenvigg_march2017 bin \ chikvigg_march2017 bin \ denvigg_march2017 bin \) by(visit) saving(prev_byvisit.xls, replace) 
table1, vars(stanfordchikvigg_march2017 bin \ stanforddenvigg_march2017 bin \ chikvigg_march2017 bin \ denvigg_march2017 bin \) by(cohort) saving(prev_bycohort.xls, replace) 
egen cohortcity =concat(cohort city)
table1, vars(stanfordchikvigg_march2017 bin \ stanforddenvigg_march2017 bin \ chikvigg_march2017 bin \ denvigg_march2017 bin \) by(cohortcity) saving(prev_bycohort_city.xls, replace) 

replace antigenused_ = "idenv10-2016/ichik10-2016" if strpos(antigenused_, "idenv10-2016/ichik10-20")
replace antigenused_ = "missing" if strpos(antigenused_, "no")
replace antigenused_ = "missing" if antigenused_==""
tab antigenused_ 

*sensitivity and specificity by strata
capture drop strata
egen strata = concat(site)
		levelsof strata, local(levels) 
		foreach l of local levels {
		preserve
				keep if strata== "`l'"
				display "*********************************`l' denvigg******************************"
					diagt stanforddenvigg_march2017 denvigg_march2017, prev(2.5%) 
					tab stanforddenvigg_march2017 denvigg_march2017, col m chi2

				display "*********************************`l' chikvvigg******************************"
					diagt stanfordchikvigg_march2017 chikvigg_march2017, prev(2.5%) 
					tab stanfordchikvigg_march2017  chikvigg_march2017, col m chi2
		restore
		}

count if stanforddenvigg_march2017 != denvigg_march2017 & denvigg_march2017 !=. & stanforddenvigg_march2017 !=.
outsheet stanforddenvigg_march2017 denvigg_march2017 studyid id_wide visit site city    antigenused_  datesamplerun_ using discordant_bylab_denvigg_march2017.csv if stanforddenvigg_march2017 != denvigg_march2017 & denvigg_march2017 !=. & stanforddenvigg_march2017 !=., comma names replace nolab

count if stanfordchikvigg_march2017 != chikvigg_march2017 & chikvigg_march2017 !=. & stanfordchikvigg_march2017 !=.
outsheet stanfordchikvigg_march2017 chikvigg_march2017  studyid id_wide visit site city    antigenused_  datesamplerun_  using discordant_bylab_chikvigg_march2017.csv if stanfordchikvigg_march2017 != chikvigg_march2017 & chikvigg_march2017 !=. & stanfordchikvigg_march2017 !=., comma names replace nolab


bysort antigenused_ : sum stanfordchikvigg_march2017 stanforddenvigg_march2017 chikvigg_march2017 denvigg_march2017
table1, vars(stanfordchikvigg_march2017 bin \ stanforddenvigg_march2017 bin \ chikvigg_march2017 bin \ denvigg_march2017 bin \) by(antigenused_) saving(prev_by_antigen.xls, replace)  missing

tab datesamplerun_

*list the pos and neg by  lab.
		list studyid stanfordchikvigg_march2017 stanforddenvigg_march2017 chikvigg_march2017 denvigg_march2017 if stanfordchikvigg_march2017 ==1 | stanforddenvigg_march2017 ==1 | chikvigg_march2017 ==1 | denvigg_march2017==1 
*list the pos and neg studyid
		list studyid stanfordchikvigg_march2017 stanforddenvigg_march2017 chikvigg_march2017 denvigg_march2017 if studyid =="ufa1214"

*count number of pos and neg in sample.
		count if stanfordchikvigg_march2017 ==1 | stanforddenvigg_march2017 ==1 | chikvigg_march2017 ==1 | denvigg_march2017==1 
		count if stanfordchikvigg_march2017 ==0 | stanforddenvigg_march2017 ==0 | chikvigg_march2017 ==0 | denvigg_march2017==0 
		foreach var in stanfordchikvigg_march2017 stanforddenvigg_march2017 chikvigg_march2017 denvigg_march2017 {
		tab `var'
		}


		use prevalent_march2017, clear
			keep if visit =="a"
			keep id_wide visit stanfordchikvigg_march2017 stanforddenvigg_march2017 chikvigg_march2017 denvigg_march2017
			order visit id_wide
			list if id_wide =="cc105004"
			reshape wide stanfordchikvigg_march2017 stanforddenvigg_march2017 chikvigg_march2017 denvigg_march2017, i(id_wide) j(visit) s
			save visita.dta, replace

		use prevalent_march2017, clear
			keep if visit =="b"
			keep id_wide visit stanfordchikvigg_march2017 stanforddenvigg_march2017 chikvigg_march2017 denvigg_march2017
			order visit id_wide
			list if id_wide =="cc105004"
			reshape wide stanfordchikvigg_march2017 stanforddenvigg_march2017 chikvigg_march2017 denvigg_march2017, i(id_wide) j(visit) s
			save visitb.dta, replace
		use visita, clear
		mer 1:1 id_wide using visitb.dta
		drop _merge
*denv_ab
		preserve
			keep if  stanforddenvigg_march2017a !=. & stanforddenvigg_march2017b !=. 
			table1, vars(stanforddenvigg_march2017a bin\ stanforddenvigg_march2017b  bin\ ) saving(stanforddenvigg_march2017_ab.xls, replace)
		restore
		sum stanforddenvigg_march2017a stanforddenvigg_march2017b if  stanforddenvigg_march2017a !=. & stanforddenvigg_march2017b !=. , 
		tab stanforddenvigg_march2017a stanforddenvigg_march2017b 
		*save sero-reverters
		outsheet id_wide stanforddenvigg_march2017a stanforddenvigg_march2017b using discordantstanforddenvigg_march2017.xls if stanforddenvigg_march2017a !=stanforddenvigg_march2017b & stanforddenvigg_march2017a != . & stanforddenvigg_march2017b != . , replace

*chikv_ab
		preserve
			keep if  stanfordchikvigg_march2017a !=. & stanfordchikvigg_march2017b !=. 
			table1, vars(stanfordchikvigg_march2017a bin \  stanfordchikvigg_march2017b bin \ ) saving(stanfordchikvigg_march2017b_ab.xls, replace)
		restore
		sum stanfordchikvigg_march2017a stanfordchikvigg_march2017b if  stanfordchikvigg_march2017a !=. & stanfordchikvigg_march2017b !=. 
		tab stanfordchikvigg_march2017a stanfordchikvigg_march2017b 
		*save sero-reverters
		outsheet id_wide stanfordchikvigg_march2017a stanfordchikvigg_march2017b  using discordantstanfordchikvigg_march2017.xls if stanfordchikvigg_march2017a !=stanfordchikvigg_march2017b & stanfordchikvigg_march2017a  != . & stanfordchikvigg_march2017b != . , replace

