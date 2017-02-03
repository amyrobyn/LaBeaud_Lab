*compare elisa results from stanford and kenya by antigen used
cd "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\elisas\feb1 2017"

use "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\interviewdata\all_interviews", clear
drop id_childnumber 
*merge with elisa data
merge 1:1 id_wide visit using "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\elisas\feb1 2017\prevalent.dta"

tab antigenused_

tab stanforddenvigg_  igg_kenya_denv  if stanforddenvigg_  !="" | igg_kenya_denv  != ., m 
bysort  antigenused_: tab stanforddenvigg_  igg_kenya_denv  

rename igg_kenya_chikv kenya_chikvigg_ 
tab stanfordchikvigg_	kenya_chikvigg_  , m 

bysort  antigenused_: tab stanfordchikvigg_	kenya_chikvigg_ , m 
bysort  antigenused_: tab stanforddenvigg_	 igg_kenya_denv, m


foreach date in datesamplerun_  datesamplecollected_ interviewdate {
		gen `date'year = year(`date') 
		gen `date'month = month(`date') 

		*2016 july forward
		preserve
			keep if `date'year ==2016 & `date'month >=7 | `date'year ==2017
			tab stanfordchikvigg_	kenya_chikvigg_ , m 
			tab stanforddenvigg_	 igg_kenya_denv, m
		restore
}

tab antigenused_

format %td datesamplerun_  
tab datesamplerun_  
