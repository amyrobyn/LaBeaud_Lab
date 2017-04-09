/********************************************************************************************
 *Author: Amy Krystosik, MPH PhD               							  					*
 *Function: merge aic and hcc interviews with lab data, gps data, vector and climate data	*
 *Org: LaBeaud Lab, Stanford School of Medicine, Pediatrics 			  					*
 *Last updated: march 28, 2017  									  						*
 *Notes: any data without unique id was dropped from this analysis 							*
 *******************************************************************************************/ 

capture log close 
log using "LOG all linked and cleaned data.smcl", text replace 
set scrollbufsize 100000
set more 1
set scrollbufsize 100000
cd "C:\Users\amykr\Box Sync\Amy Krystosik's Files\ASTMH 2017 abstracts\all linked and cleaned data"
local figures "C:\Users\amykr\Box Sync\Amy Krystosik's Files\ASTMH 2017 abstracts\all linked and cleaned data\figures\"
local data "C:\Users\amykr\Box Sync\Amy Krystosik's Files\ASTMH 2017 abstracts\all linked and cleaned data\data\"

use "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\interviewdata\all_interviews", clear

*add in the pcr data from box and from googledoc. 
duplicates tag id_wide visit, gen (dup_id_wide_visit) 
isid id_wide visit
drop id_childnumber 
merge 1:1 id_wide visit using "C:\Users\amykr\Box Sync\DENV CHIKV project\Lab Data\PCR Database\PCR Latest\allpcr"
		*replace denvpcrresults_dum = 1 if denvpcrresults_dum>0 & denvpcrresults_dum<.
		save "`data'elisas_PCR_RDT$S_DATE", replace	
		rename _merge interview_elisa_pcr_match


merge 1:1 id_wide visit using "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\malaria prelim data dec 29 2016\malaria"
replace cohort = id_cohort if cohort ==""
drop _merge cohort
merge 1:1 id_wide visit using "C:\Users\amykr\Box Sync\DENV CHIKV project\Lab Data\ELISA Database\ELISA Latest\elisa_merged"

gen anna_seroc_denv=.
*	foreach studyid in "cfa0327" "cfa0328" "cfa0332" "rfa0427" "rfa0428" "cfa0285" "mfa0537" "mfa0598" "mfa0703" "mfa0933" "ufa0570"{
	foreach id_wide in "cf327" "cf328" "cf332" "rf427" "rf428" "cf285" "mf537" "mf598" "mf703" "mf933" "uf570"{
	replace anna_seroc_denv= 1 if id_wide == "`id_wide'"
}

gen anna_seroc_denv_pcr=.
	foreach id_wide in "cf313" {
	replace anna_seroc_denv_pcr= 1 if id_wide == "`id_wide'"
}

gen jimmy_seroc_chikv=.
replace studyid = lower(studyid)
list studyid if strpos(studyid, "ufa0572")
foreach id_wide in "uf572" "uf599" "uf840" "mf563" "kf433"{
	replace jimmy_seroc_chikv= 1 if id_wide == "`id_wide'"
}

bysort visit: tab jimmy_seroc_chikv stanfordchikvigg_, m
bysort visit: tab anna_seroc_denv stanforddenvigg_ 
 
drop _merge
replace hb = hb_result if hb==.
drop hb_result 


*fix childtemp
rename *temp* *childtemp*
replace childtemp = childtemperature if childtemp ==.
drop childtemperature 
tab childtemp , m

replace childtemp = childtemp /10 if childtemp >50 

replace feverchildtemp =0 if childtemp <38
replace feverchildtemp =0 if fevertoday==0  
replace feverchildtemp =0 if fever==0  

replace feverchildtemp =1 if childtemp >=38  & childtemp !=.
replace feverchildtemp =1 if fevertoday==1  
replace feverchildtemp =1 if fever==1  

tab feverchildtemp, m
order studyid id_wide visit cohort feverchildtemp fever* *temp fever* *fever* 
gen fever_6ms =. 
replace fever_6ms=1 if 	numillnessfever > 0 & numillnessfever != . 
replace fever_6ms=1 if 	fevertoday == 1 

replace fever_6ms=0 if 	numillnessfever == 0 
replace fever_6ms=0 if 	fevertoday == 0

*fix the studyid's that are missing or wrong
encode id_wide, gen(id_wide_int)
drop visit_int
encode visit, gen(visit_int)
xtset id_wide_int visit_int

by id_wide_int : carryforward id_childnumber id_cohort id_city id_cohort dob  child_name cfname cmname  clname   csname    csurname  ctname   cfthname  childsname  date_of_birth , replace
order id_childnumber id_cohort id_city id_visit id_city studyid id_wide
gen id_childnumber2 = substr(id_wide , +3, .) if studyid==""
replace id_childnumber2 = substr(id_wide , +3, .) if length(studyid)<5
destring id_childnumber2 , replace force
replace id_childnumber =id_childnumber2  if studyid==""
replace id_childnumber =id_childnumber2  if length(studyid)<5

egen studyid2 =concat(id_city id_cohort visit id_childnumber) if studyid ==""
replace studyid =studyid2 if studyid ==""
drop id_childnumber2  
*more fixing id's
gen id_childnumber2 = substr(id_wide , +3, .)
drop notnumeric 
gen byte notnumeric = real(id_childnumber2)==.	/*makes indicator for obs w/o numeric values*/
tab notnumeric	/*==1 where nonnumeric characters*/
list id_childnumber2 if notnumeric==1	/*will show which have nonnumeric*/
	
gen suffix = "" 
	replace suffix = "a" if strpos(id_childnumber2, "a")
	replace id_childnumber2 = subinstr(id_childnumber2, "a","", .)

	replace suffix = "b" if strpos(id_childnumber2, "b")
	replace id_childnumber2 = subinstr(id_childnumber2, "b","", .)

	replace suffix = "c" if strpos(id_childnumber2, "c")
	replace id_childnumber2 = subinstr(id_childnumber2, "c","", .)
gen byte notnumeric2 = real(id_childnumber2)==.	/*makes indicator for obs w/o numeric values*/
tab notnumeric2 
list studyid id_wide id_childnumber2 if notnumeric2 ==1
drop if studyid == "missing"
destring id_childnumber2, replace 


gen studyid3= substr(studyid, 1, 3)
egen studyid4 = concat(studyid3 id_childnumber2 )
replace id_childnumber =id_childnumber2 if id_childnumber==.
compare id_childnumber id_childnumber2 
drop id_childnumber2

count if studyid4 != studyid
replace studyid = studyid4 if length(studyid)<5
*done fixing id's 2

***start***houseid to merge demography** hcc only
	save hcc_aic, replace
		keep if cohort ==1
		tostring id_childnumber, replace
		save aic, replace
	use hcc_aic, clear
	keep if cohort ==2
	dropmiss, force
	dropmiss, obs force
		
	gen age_days = age*365	
	gen dob_gen = interviewdate - age_days 
	format dob_gen %td
	format  dob_gen %tddd-Mon-YY
	compare dob_gen dob 
	replace dob = dob_gen if dob ==. 
	order dob_gen dob interviewdate age age_days
	

	gen child_dob_month = month(dob)
	gen child_dob_year= year(dob)
	gen child_dob_day = day(dob)
	count if dob ==. & child_name =="" & cfname  =="" & clname ==""

	tab child_dob_month , m
	tab child_dob_year, m
	tab child_dob_day , m

	
			gen houseid2 = ""
			replace houseid2 = substr(studyid, 4, . ) 
			order houseid* city studyid id_wide
			gsort -city
			destring houseid2 , replace force 

			tostring houseid2, replace
			replace houseid2= reverse(houseid2)
			
			replace houseid2 = substr(houseid2, 3, . ) if city =="ukunda"
			replace houseid2 = substr(houseid2, 4, . ) if city !="ukunda"
			replace houseid2= reverse(houseid2)
			destring houseid2, replace 
			

			list studyid id_wide houseid2  houseid  if houseid2 != houseid & houseid!=. & city =="milani"
			list studyid id_wide houseid2  houseid  if houseid2 != houseid & houseid!=. & city =="nganja"

			order studyid houseid houseid2 city
			destring houseid houseid2, replace 
			
			replace houseid = houseid2 if houseid==. & houseid2!=.
			replace houseid = houseid2 if city =="ukunda"

			count if houseid==. & cohort ==2
			replace houseid =. if cohort ==1

			count if cohort==2
			count if houseid ==. & cohort==2

			*merge with demography data
			*rename childnumber id_childnumber
			replace csname	= csurname	if csname	==""
			drop csname	
			
gen childname1  = 	cfname	 
	drop cfname	  
gen childname2 = cmname	
	drop cmname	 
gen childname3 = clname	
	drop clname	   
gen childname4 = csurname
	drop csurname
	gen space = " "
egen childname_long = concat(childname1 space childname2 space childname3 space childname4) 
	replace childname4 = "99" if childname4 ==""
	replace childname3 = "99" if childname3 ==""
	replace childname2 = "99" if childname2 ==""
	replace childname1 = "99" if childname1 ==""
tostring id_childnumber, replace
save child_to_link_w_demography, replace
merge m:1 city houseid using "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\demography\hh_xy"
rename _merge hhmerge
drop if hhmerge==2 
isid id_wide visit
compare childname_long  child_name  
replace child_name   = childname_long  if child_name   ==""
capture drop similscore
order childname_long  child_name  hhmerge 

gen child_in_house_num = id_childnumber 
tostring child_in_house_num , replace 
replace child_in_house_num = reverse(child_in_house_num )
replace child_in_house_num = substr(child_in_house_num, 1, 2) 
replace child_in_house_num = reverse(child_in_house_num )
tab child_in_house_num if child_in_house_num !="99"
list dataset studyid id_wide child_in_house_num   id_childnumber  if child_in_house_num =="00"
tab dataset if child_in_house_num =="99"

destring child_in_house_num, replace
rename id_childnumber house_child_num
rename child_in_house_num id_childnumber 
capture drop id
encode id_wide, gen(id)
save child, replace

duplicates tag city houseid id_childnumber visit, gen(city_houseid_id_child_visit_dup)
tab city_houseid_id_child_visit_dup city
drop if city_houseid_id_child_visit_dup>0
isid city houseid id_childnumber visit

order city_houseid_id_child_visit_dup city houseid id_childnumber visit id_wide studyid
gsort -city_houseid_id_child_visit_dup

dropmiss, force piasm trim
dropmiss, force piasm obs trim
destring *, replace 

isid city houseid id_childnumber visit
tostring villageid id_childnumber, replace
merge m:1 city houseid id_childnumber using "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\demography\child_xy"

rename _merge childmerge
tab childmerge hhmerge, m

label variable childmerge  "demography information at child level, merge status"
label variable hhmerge "demography information at household level, merge status"
label define childmerge  1 "No demography data" 3 "merged with demography data" , modify
label values childmerge  childmerge  
label define hhmerge  1 "No demography data" 3 "merged with demography data" , modify
label values hhmerge  hhmerge   

label variable childmerge  "demography information at child level"
label define season  1 "hot no rain from mid december" 2 "long rains" 3 "less rain cool season" 4 "short rains", modify
label values season season season season 
tab season , nolab

tab childmerge city, m
order hhmerge childmerge city houseid id_childnumber child_dob_year child_dob_month child_dob_day childname1 childname2 childname3
outsheet studyid id_wide city houseid id_childnumber  childmerge hhmerge  using "C:\Users\amykr\Box Sync\DENV CHIKV project\West Cleaned\Demography\Demography Latest\west_unmatched_hcc_demography.csv" if childmerge !=3  & hhmerge !=3 & site =="west", comma names replace
outsheet studyid id_wide city houseid id_childnumber childmerge hhmerge  using "C:\Users\amykr\Box Sync\DENV CHIKV project\Coast Cleaned\Demography\Demography Latest\coast_unmatched_hcc_demography.csv" if childmerge !=3  & hhmerge !=3 & site =="coast", comma names replace

drop if childmerge ==2
outsheet dataset id_wide studyid id_city visit id_cohort stanford* using "`data'missing.csv" if id_cohort =="", comma names replace
tostring windows childvillage, replace

	replace childrenusebednet = lower(childrenusebednet )
	replace childrenusebednet = "1" if childrenusebednet =="all"
	replace childrenusebednet = "1" if childrenusebednet =="yes"
	replace childrenusebednet = "0" if childrenusebednet =="none"
	replace childrenusebednet = "0" if childrenusebednet =="no"
	replace childrenusebednet = "2" if childrenusebednet =="some"
	replace childrenusebednet = "8" if childrenusebednet =="refused"
	destring childrenusebednet , replace 
	replace hoh_kids_sleep_bednet = childrenusebednet if hoh_kids_sleep_bednet ==.
	replace hoh_kids_sleep_bednet = sleepbednet if hoh_kids_sleep_bednet ==.
	drop childrenusebednet sleepbednet 
	tab hoh_kids_sleep_bednet , m
	
	tab own_bednet  
	replace own_bednet  = "1" if own_bednet  =="yes"
	replace own_bednet  = "0" if own_bednet  =="no"
	destring own_bednet  , replace 
	replace hoh_own_bednet = own_bednet  if hoh_own_bednet ==.
	tab hoh_own_bednet , m
	lookfor bednet
	drop own_bednet  

	replace hoh_number_bednet = number_bednet if hoh_number_bednet ==.
		drop number_bednet 

	replace usebednet = lower(usebednet )
	replace usebednet= "1" if usebednet=="yes"
	replace usebednet= "0" if usebednet=="no"
	destring usebednet, replace 
	replace hoh_sleep_bednet = usebednet if hoh_sleep_bednet ==.
	tab hoh_sleep_bednet 
	tab usenetfreq 
	replace hoh_sleep_bednet = usenetfreq if hoh_sleep_bednet ==.
	drop usebednet usenetfreq

append using aic

			tab city 
			drop if city =="a"

*cohort
replace cohort =2 if id_cohort == "c"
replace cohort = 1 if id_cohort == "f"


replace interviewdate = interviewdate2  if interviewdate ==.
replace interviewdate = interview_date if interviewdate ==.
compare interviewdate interview_date 
compare interviewdate interviewdate2 
drop interviewdate2 interview_date 

gen year = year(interviewdate)
gen month= month(interviewdate)

*merge with vector data
merge m:1 city month year using "C:\Users\amykr\Box Sync\Amy Krystosik's Files\vector\merged_vector_climate" 
rename _merge vector_climate

**now that all the data is merged, carryfoward all the values from baseline***
lookfor visit_int id


*season
gen season = .
label variable season "Seasons"
replace season =1 if month >=1 & month  <=3
replace season =2 if month >=4 & month  <=6
replace season =3 if month >=7 & month  <=10
replace season =4 if month >=11 & month  <=12

label define season  1 "hot no rain from mid december" 2 "long rains" 3 "less rain cool season" 4 "short rains", modify
label values season season season season 
tab season , nolab

gen year_label = "_y_"
gen season_label = "s_"
egen seasonyear = concat(season_label  season year_label  year)
tab seasonyear , m

gen sexlabel = "sex"
gen agelabel = "age"
egen agegender = concat(agelabel age sexlabel gender)
drop if strpos(agegender, ".")
merge m:1 agegender using "C:\Users\amykr\Box Sync\Amy Krystosik's Files\david coinfectin paper\normal_population_aic_b"
drop if age>18
drop heart_rate 
rename heartrate heart_rate 
*replace childheight = child_height if childheight ==.
*drop child_height 
*replace childweight = child_weight if childweight ==.
*drop child_weight
replace headcircum  = head_circumference if headcircum  ==.
drop head_circumference 

rename childtemp childtemp

foreach var in heart_rate systolicbp  diastolicbp  pulseoximetry childtemp resprate { 
		replace `var'= . if `var'==999
		gen zaicb_`var'=.
}

foreach var in childweight childheight hb headcirc{ 
		replace `var'= . if `var'==999
		replace `var'= . if `var'==0		
}

*ask david about these
replace systolicbp = systolicbp/10 if systolicbp >200
replace childheight = childheight/10 if childheight >500
replace childheight = childheight *10 if childheight <20
replace childweight=childweight/10 if childweight>200


	foreach var in heart_rate systolicbp  diastolicbp  pulseoximetry childtemp resprate{ 
		replace `var'=. if `var'==0
	}

	foreach var in heart_rate systolicbp  diastolicbp  pulseoximetry childtemp resprate{ 
		replace `var'=. if `var'<15
	}
	
levelsof agegender, local(levels) 
foreach l of local levels {
capture	foreach var in heart_rate systolicbp  diastolicbp  pulseoximetry childtemp resprate{ 
capture	replace zaicb_`var' = (`var' - median`var'`l')/sd`var'`l' if agegender=="`l'"  
	}
}
sum zaicb*

sum heart_rate systolicbp  diastolicbp  pulseoximetry childtemp childweight childheight resprate hb  headcircum  
sum heart_rate systolicbp  diastolicbp  pulseoximetry childtemp childweight childheight resprate hb  headcircum, d
sum zaicb*, d


*add in doctor visit bs and rdt result
gen malariapositive_dum2 = malariapositive_dum  
replace malariapositive_dum2 =1 if bsresult > 0 & bsresult <. & malariapositive_dum2 ==.
replace malariapositive_dum2 =1 if rdtresult > 0 & rdtresult <. & malariapositive_dum2  ==.
tab malariapositive_dum2 malariapositive_dum, m 

tab malariapositive_dum malariapositive_dum2 

tab denvpcrresults_dum malariapositive_dum, m 
tab denvpcrresults_dum malariapositive_dum2, m 

gsort -denvpcrresults_dum 

bysort city: list id_wide visit denvpcrresults_dum malariapositive_dum if malariapositive_dum2 ==1 |denvpcrresults_dum ==1, clean

*symptoms to dummies
 rename currentsymptoms symptms
 rename othcurrentsymptoms othersymptms 
 rename feversymptoms fvrsymptms
 rename othfeversymptoms otherfvrsymptms
 egen all_symptoms = concat(symptms othersymptms fvrsymptms otherfvrsymptms) 
 gen symptomstoreview =all_symptoms 

		foreach var of varlist all_symptoms { 			
		replace `var'= subinstr(`var', " ", "_",.)
		}

		foreach var of varlist all_symptoms  { 			
		replace `var'= subinstr(`var', "general_body_ache" ,"body_aches" ,.)
		replace `var'= subinstr(`var', "none" ,"" ,.)
		replace `var'= subinstr(`var', "dizziness" ,"nausea",.)
		replace `var'= subinstr(`var', "sick_feeling" ,"feeling_sick" ,.)
		replace `var'= subinstr(`var', "impaired_mental_status","altms" ,.)
		replace `var'= subinstr(`var', 	"shortness_of_breath","short_breath" ,.)
		replace `var'= subinstr(`var', "eyes_sensitive_to_light" ,"sens_eyes"  ,.)
		replace `var'= subinstr(`var', "aneamia" ,"anaemia"  ,.)
		replace `var'= subinstr(`var', "malaise" ,"body_aches"  ,.)
		replace `var'= subinstr(`var', "pain_on_urination" ,"dysuria"  ,.)
		replace `var'= subinstr(`var', "pain_while_passing_urine" ,"dysuria"  ,.)
		
		replace all_symptoms= subinstr(all_symptoms, "mouth_sores" ,"enanthem"  ,.)
		replace all_symptoms= subinstr(all_symptoms, "oral_sores" ,"enanthem"  ,.)
		replace all_symptoms= subinstr(all_symptoms, "thrush" ,"enanthem"  ,.)
		replace all_symptoms= subinstr(all_symptoms, "oral_lesion" ,"enanthem"  ,.)
		replace all_symptoms= subinstr(all_symptoms, "mouth_sore" ,"enanthem",.)
		replace all_symptoms= subinstr(all_symptoms, "enanthem" ,"rash",.)
		
		replace all_symptoms= subinstr(all_symptoms, "convulsions" ,"seizure"  ,.)
		replace all_symptoms= subinstr(all_symptoms, "convulsion" ,"seizure"  ,.)

		replace all_symptoms= subinstr(all_symptoms, "epilepsy" ,"seizure"  ,.)
		replace all_symptoms= subinstr(all_symptoms, "fits" ,"seizure"  ,.)

		replace all_symptoms= subinstr(all_symptoms, "stiff_neck" ,"neck_pain"  ,.)

		replace all_symptoms= subinstr(all_symptoms, "short_breath" ,"dysphrea"  ,.)
		replace all_symptoms= subinstr(all_symptoms, "breath" ,"dysphrea"  ,.)
		
		replace all_symptoms= subinstr(all_symptoms, "stomachache" ,"abdominal_pain"  ,.)
		replace all_symptoms= subinstr(all_symptoms, "stomachache" ,"abdominal_pain"  ,.) 
		
		
		replace all_symptoms= subinstr(all_symptoms, "inflamed_tonsils" ,"sore_throat",.)
		replace all_symptoms= subinstr(all_symptoms, "tonsilitis" ,"sore_throat",.)
		replace all_symptoms= subinstr(all_symptoms, "tonsils" ,"sore_throat",.)
		replace all_symptoms= subinstr(all_symptoms, "tonsolitis" ,"sore_throat",.)
		replace all_symptoms= subinstr(all_symptoms, "tonsillitis" ,"sore_throat",.)
		
		replace all_symptoms= subinstr(all_symptoms, "post_inflammation_skin_lesions" ,"rash",.)

		replace all_symptoms= subinstr(all_symptoms, "bloody_urine" ,"bleeding_symptom",.)
		replace all_symptoms= subinstr(all_symptoms, "bloody_stool" ,"bleeding_symptom",.)
		replace all_symptoms= subinstr(all_symptoms, "bloody_vomit" ,"bleeding_symptom",.)
		replace all_symptoms= subinstr(all_symptoms, "bleeding_gums" ,"bleeding_symptom",.)
		replace all_symptoms= subinstr(all_symptoms, "bloody_nose" ,"bleeding_symptom",.)

		replace all_symptoms= subinstr(all_symptoms, "bone_pains" ,"aches_pains",.)
		replace all_symptoms= subinstr(all_symptoms, "body_aches" ,"aches_pains",.)
		replace all_symptoms= subinstr(all_symptoms, "joint_pains" ,"aches_pains",.)
		replace all_symptoms= subinstr(all_symptoms, "muscle_pains" ,"aches_pains",.)
		replace all_symptoms= subinstr(all_symptoms, "neck_pain" ,"aches_pains",.)

		replace all_symptoms= subinstr(all_symptoms, "bruises" , "mucosal_bleed_brs",.)
		replace all_symptoms= subinstr(all_symptoms, "cough"  , "respiratory",.)
		
		replace all_symptoms= subinstr(all_symptoms, "headache" ,"headache/eye_pain",.)

		replace all_symptoms= subinstr(all_symptoms, "loss_of_appetite" ,"appetite_change",.)
		replace all_symptoms= subinstr(all_symptoms, "red_eyes" ,"eye_symptom",.)
		replace all_symptoms= subinstr(all_symptoms, "sens_eyes" ,"eye_symptom",.)

		replace all_symptoms= subinstr(all_symptoms, "runny_nose" ,"respiratory",.)

		}
			foreach var of varlist all_symptoms  { 			
			foreach symptom in "eye_symptom" "fever" "chiils"  "vomiting" "diarrhea" "abdominal_pain" "aches_pains"  "respiratory" "nausea" "other" "dysuria" "rash" "bloody_nose" "mucosal_bleed_brs" "imp_mental" "funny_taste" "earache" "sens_eyes" "sore_throat" "bleeding_symptom" "itchiness" "seizure" "anaemia" "dysphrea" "ache"  "dysphagia" "pain" {
						tostring `var', replace
						replace `var'=trim(itrim(lower(`var')))
						moss `var', match(`symptom') prefix(`symptom')

						gen `var'_`symptom'=0
						replace `var'_`symptom'= 1 if strpos(`var', "`symptom'")
						replace `var'= subinstr(`var', "`symptom'", "",.)
						order `var'_`symptom'
						tab `var'_`symptom'
						}
			}	
drop symptms othersymptms fvrsymptms otherfvrsymptms 

replace all_symptoms= subinstr(all_symptoms, "__", "_",.)
replace all_symptoms= subinstr(all_symptoms, "__", "_",.)
replace all_symptoms= subinstr(all_symptoms, "__", "_",.)
replace all_symptoms= subinstr(all_symptoms, "__", "_",.)
replace  all_symptoms  = "" if all_symptoms =="_"
tab all_symptoms 			

		replace all_symptoms= subinstr(all_symptoms, "red_gums" ,"abnormal_gums"  ,.) 
		replace all_symptoms= subinstr(all_symptoms, "tooth_and_swelling_on_the_gum" ,"abnormal_gums",.)

		replace all_symptoms= subinstr(all_symptoms, "fainting" ,"AltMS",.)
		replace all_symptoms= subinstr(all_symptoms, "hallucination" ,"AltMS",.)
		replace all_symptoms= subinstr(all_symptoms, "lethargy" ,"AltMS",.)
		
		replace all_symptoms= subinstr(all_symptoms, "irritability" ,"behavior_change",.)
		replace all_symptoms= subinstr(all_symptoms, "refusal_to_feed" ,"behavior_change",.)
		replace all_symptoms= subinstr(all_symptoms, "refusal_to_play" ,"behavior_change",.)

		replace all_symptoms= subinstr(all_symptoms, "cold_extremities" ,"chills",.)
		replace all_symptoms= subinstr(all_symptoms, "shivering" ,"chills",.)

		replace all_symptoms= subinstr(all_symptoms, "failure_to_pass_stool_for_1_day" ,"constipation",.)
		replace all_symptoms= subinstr(all_symptoms, "failure_to_pass_stool" ,"constipation",.)

		replace all_symptoms= subinstr(all_symptoms, "fast_ing" ,"decreased_appetite",.)
		replace all_symptoms= subinstr(all_symptoms, "fast_ig" ,"decreased_appetite",.)
		replace all_symptoms= subinstr(all_symptoms, "decreased_appetite" ,"appetite_change",.)
		
		replace all_symptoms= subinstr(all_symptoms, "flu" ,"other2",.)
		
		replace all_symptoms= subinstr(all_symptoms, "abdominal_swelling" ,"edema",.)
		replace all_symptoms= subinstr(all_symptoms, "bilateral_swelling_of_the_chin" ,"edema",.)
		replace all_symptoms= subinstr(all_symptoms, "body_swelling" ,"edema",.)
		replace all_symptoms= subinstr(all_symptoms, "boggy_swelling_of_rt_foot" ,"edema",.)
		replace all_symptoms= subinstr(all_symptoms, "swelling_on_the_left_ear" ,"edema",.)
		replace all_symptoms= subinstr(all_symptoms, "swelling_on_the_left_thumb" ,"edema",.)
		replace all_symptoms= subinstr(all_symptoms, "swelling_on_the_neck" ,"edema",.)
		replace all_symptoms= subinstr(all_symptoms, "swelling_on_the_right_chin" ,"edema",.)
		replace all_symptoms= subinstr(all_symptoms, "swelling_on_the_right_thigh" ,"edema",.)
		replace all_symptoms= subinstr(all_symptoms, "swollen_body" ,"edema",.)
		replace all_symptoms= subinstr(all_symptoms, "swollen_face" ,"edema",.)
		replace all_symptoms= subinstr(all_symptoms, "swollen_thumb" ,"edema",.)
		replace all_symptoms= subinstr(all_symptoms, "swelling_of_body" ,"edema",.)
		replace all_symptoms= subinstr(all_symptoms, "puffiness_of_the_face" ,"edema",.)
		replace all_symptoms= subinstr(all_symptoms, "intraorbital_swellin" ,"edema",.)

		replace all_symptoms= subinstr(all_symptoms, "bad_smell_from_the_mouth" ,"halitosis",.)
		replace all_symptoms= subinstr(all_symptoms, "foul_smell_from_the_mouth" ,"halitosis",.)
		replace all_symptoms= subinstr(all_symptoms, "mouth_odour" ,"halitosis",.)
		replace all_symptoms= subinstr(all_symptoms, "strong_foul_smell_from_the_mouth" ,"halitosis",.)

		replace all_symptoms= subinstr(all_symptoms, "chills" ,"constitutional",.)
		replace all_symptoms= subinstr(all_symptoms, "feeling_sick" ,"constitutional",.)

		replace all_symptoms= subinstr(all_symptoms, "pain_behind_eyes" ,"headache/eye_pain",.)



replace all_symptoms= subinstr(all_symptoms, "," ,"",.)

foreach symptom in "body_rushes" "boggy_pus_discharging_swelling_on_butt" "chicken_box" "chicken_pox" "constipation" "difficulty_in_urination" "dry_lips" "ear_discharge" "eye_discharge" "_flue"  "_flu," "_flu"  "_foul_smelly_stool" "_ful_micturation" "_fungal_skin_infection" "_infra_auricular_sweling" "_jiggers" "_kidney_problem" "_measles" "_neckswelling" "_pus_ear_discharge" "_restless" "_ringworms" "_running_nose" "_sickle_cell" "_sickler" "_small_pox" "_sores_on_the_neck" "_sprained_wrist" "_strutles" "_swollen_inguinal_lymhnodes" "_tearing_eyes" "_tinea_corporis" "_urine_retention" "_whitish_eye_discharge" "_worms_in_his_stool" "body_rushes" "chicken_pox" "eye_discharge" "_tooth_" "boils" "burn"  "_worms"  "_wound" {		
				replace all_symptoms = subinstr(all_symptoms, "`symptom'", "other2",.)
			}
			
foreach symptom in "lethergy" "asthma" "constitutional" "jaundice" "abnormal_gums" "altms" "behavior_change" "constipation" "appetite_change" "edema" "halitosis" "other2" {
						tostring all_symptoms, replace
						replace all_symptoms=trim(itrim(lower(all_symptoms)))
						moss all_symptoms, match(`symptom') prefix(`symptom')

						gen all_symptoms_`symptom'=0
						replace all_symptoms_`symptom'= 1 if strpos(all_symptoms, "`symptom'")					
						replace all_symptoms= subinstr(all_symptoms, "`symptom'", "",.)
						order all_symptoms_`symptom'
						tab all_symptoms_`symptom'
		}						
drop all_symptoms 
order all_symptoms_* 
order *count

order all_symptoms_other  all_symptoms_other2
egen all_symptoms_other3 = rowtotal(all_symptoms_other  all_symptoms_other2)
drop all_symptoms_other2 all_symptoms_other
rename all_symptoms_other3 all_symptoms_other


egen symptomcount = rowtotal(all_symptoms_*)
** *david medication
*medsprescribe to dummies
egen all_meds = concat(medsprescribe othmedsprescribe malariatreatment1 malariatreatment2) 
gen medstoreview  = all_meds  
replace all_meds=lower(all_meds)
replace all_meds=trim(itrim(all_meds))
		foreach var of varlist all_meds { 			
		replace `var'= subinstr(`var', " ", "_",.)
		}
		foreach var of varlist all_meds  { 			
		foreach antibiotic in  "chloramphenicol" "teo" "t.e.o" "flagyl" "flaggyl" "ciproxin" "augumentin" "cefxime" "ciproxin" "chlamphenicol" "cefixime" "ciproxin" "ciprofloxin" "intravenous_metronidazole" "nitrofurantion" "ciprofloxacin" "flagyla"  "gentamicin" "metronidazole" "floxapen" "flucloxacill" "trinidazole" "vedrox" "ampiclox" "cloxacillin" "ampicillin" "albendaxole" "albedazole" "tinidazole" "tetracycline" "augmentin" "amoxicillin" "ceftriaxone" "penicillian" "septrin" "antibiotic" "ceftrizin" "cotrimoxazole" "cefuroxime" "erythromycin" "gentamycin" "cipro"{
		replace all_meds= subinstr(all_meds, "`antibiotic'" ,"antibacterial",.)
		}

		foreach item in "im_quinine" "artesunate" "artesun" "sp" "quinine" "coartem" "quinnie" "atersunate" "quinnine" "paludrin" "quinnie" "duocotecxin" "pheramine" "artsun" "atesunate" "atesa" "artesinate" "doxycline"{
		replace all_meds= subinstr(all_meds, "`item'" ,"antimalarial",.)
		}

		replace all_meds= subinstr(all_meds, "albendazole" ,"antihelmenthic",.)
		replace all_meds= subinstr(all_meds, "abz" ,"antihelmenthic",.)
		replace all_meds= subinstr(all_meds, "mebendazole" ,"antihelmenthic",.)

		foreach item in "guaifenesin" "xpen" "expectants" "expectant" "tricoff" "expectant" "expectants" "expectant" "expectant"{
		replace all_meds= subinstr(all_meds, "`item'" ,"expectorant",.)
		}

		foreach item in "syrup" "unibrolcoldcap" "unibrol" "tricohist" "trichohist" "cold_cap" "ascoril"{
		replace all_meds= subinstr(all_meds, "`item'" ,"cough",.)
		} 
		
		foreach item in "cetrizine hydrochloride" "chlorepheramine" "chlore" "hydrocrt" "hydrocortisone" "cetrizine" "piriton" "priton" "hydroctisone_cream" "hydroctisone" "hydroctione" "cpm" "pitriton" "probeta-n" {
		replace all_meds= subinstr(all_meds, "`item'" ,"allergy",.)
		}

		foreach item in "calamine_lotion" "cream" "lotion" "eye_ointment"{
		replace all_meds= subinstr(all_meds, "`item'" ,"topical",.)
		}

		foreach item in "zinc_tablet" "vitamin" "vit" "zinc" "multisupplement" "supplement" "ranferon" "ferrous_sulphate" "mult" "folic_acid" "folic" "ferrous" "haemoton"{
		replace all_meds= subinstr(all_meds, "`item'" ,"supplement",.)
		}

		foreach item in "paracentamol" "paracetamol" "ibuprofen" "diclofenac" "calpol"{
		replace all_meds= subinstr(all_meds, "`item'" ,"antipyretic",.)
		}

		foreach item in "ketoconazole" "griseofulvin" "clotrimazole" "clotrimazone" "grisofluvin" "graeofulvin" "graseofulvin" "greseofulvin" "nystatin_oral_mouth_paint"{
		replace all_meds= subinstr(all_meds, "`item'" ,"antifungal",.)
		}

		foreach item in "other" {
		replace all_meds= subinstr(all_meds, "`item'" ,"othermed",.)
		}


		foreach item in "admission" "admitted" "admit" {
		replace all_meds= subinstr(all_meds, "`item'" ,"admit",.)
		}
		
		foreach item in "iv" "i.v." "ivs"  "i.v.s." "i.v"{
		replace all_meds= subinstr(all_meds, "`item'" ,"iv",.)
		}

		foreach item in "ors"  "o.r.s"{
		replace all_meds= subinstr(all_meds, "`item'" ,"ors",.)
		}
		
		foreach item in "sulphate" {
		replace all_meds= subinstr(all_meds, "`item'" ,"sulphate",.)
		}


		foreach item in "voline_gel" "voltaren" "dinac" "duclofenac"{
		replace all_meds= subinstr(all_meds, "`item'" ,"painmed",.)
		}

		foreach item in "ventolin" "ventoli" "sabutanol" "salbutamol" "albutol"{
		replace all_meds= subinstr(all_meds, "`item'" ,"bronchospasm",.)
		}

		
		foreach item in "plasil"{
		replace all_meds= subinstr(all_meds, "`item'" ,"gerd",.)
		}

		foreach item in "none"{
		replace all_meds= subinstr(all_meds, "`item'" ,"none",.)
		}

		foreach item in "diloxanide"{
		replace all_meds= subinstr(all_meds, "`item'" ,"antiamoeba",.)
		}

		}

		foreach var of varlist all_meds{ 			
			foreach med in "antibacterial" "antimalarial" "antipyretic"  "antihelmenthic" "expectorant" "allergy" "supplement"  "antifungal" "othermed" "admit" "ors" "iv" "cough" "sulphate" "painmed" "bronchospasm" "topical" "gerd" "none" "antiamoeba"{ 
						tostring `var', replace
						replace `var'=trim(itrim(lower(`var')))
						moss `var', match(`med') prefix(`med')

						gen `var'_`med'=0
						replace `var'_`med'= 1 if strpos(`var', "`med'")
						replace `var'= subinstr(`var', "`med'", "",.)
						order `var'_`med'
						tab `var'_`med'
						}
			}	

replace all_meds= subinstr(all_meds, "inj", "",.)
replace all_meds= subinstr(all_meds, "for", "",.)
replace all_meds= subinstr(all_meds, ".", "",.)
replace all_meds= subinstr(all_meds, "'", "",.)
replace all_meds= subinstr(all_meds, "__", "_",.)
replace all_meds= subinstr(all_meds, "__", "_",.)
replace all_meds= subinstr(all_meds, "__", "_",.)
replace all_meds= subinstr(all_meds, "__", "_",.)
replace all_meds= subinstr(all_meds, "_", "",.)
replace all_meds= subinstr(all_meds, "_", "",.)
replace all_meds= subinstr(all_meds, ",", "",.)
replace all_meds= subinstr(all_meds, ",", "",.)
replace all_meds= subinstr(all_meds, ",", "",.)
replace all_meds= subinstr(all_meds, "+", "",.)
replace all_meds= subinstr(all_meds, "and", "",.)
replace all_meds= subinstr(all_meds, "intravenous", "",.)
replace all_meds= subinstr(all_meds, "im", "",.)
replace all_meds= subinstr(all_meds, "s", "",.)
replace all_meds  = "" if all_meds =="_"
replace all_meds  = "" if all_meds =="_"
replace all_meds  = "" if strlen(all_meds) <3
tab all_meds 			
preserve
	keep if all_meds !=""
	rename all_meds TOCATEGORIZE
	outsheet medsprescribe othmedsprescribe  TOCATEGORIZE using "`data'allmeds.xls", replace 
restore
drop medsprescribe othmedsprescribe 

gen dmcoinf = .
replace dmcoinf = 1 if malariapositive_dum==1 & denvpcrresults_dum==1
gen dmcoinf2 = .
replace dmcoinf2 = 1 if malariapositive_dum2==1 & denvpcrresults_dum==1

foreach var in malariapositive_dum denvpcrresults_dum dmcoinf{
	bysort  `var': sum all_symptoms_*
}

*group 0 is neg; 1 is malaria pos; 2 is denv pos; 3 is coinfection. 
gen coinfectiongroup = .
replace coinfectiongroup = 0 if malariapositive_dum ==0 & denvpcrresults_dum ==0
replace coinfectiongroup = 1 if malariapositive_dum==1
replace coinfectiongroup = 2 if denvpcrresults_dum==1
replace coinfectiongroup  = 3 if dmcoinf==1

gen coinfectiongroup2 = .
replace coinfectiongroup2 = 0 if malariapositive_dum2 ==0 & denvpcrresults_dum ==0
replace coinfectiongroup2 = 1 if malariapositive_dum2==1
replace coinfectiongroup2 = 2 if denvpcrresults_dum==1
replace coinfectiongroup2 = 3 if dmcoinf2==1

replace outcomehospitalized = . if outcomehospitalized ==8
replace outcome= . if outcome==99

gen othoutcome_dum = .
replace othoutcome_dum  = 3 if othoutcome!=""
replace othoutcome_dum  = 1 if strpos(othoutcome, "nutritional")
replace outcome = othoutcome_dum  if outcome ==.
tab outcome outcomehospitalized , m
lookfor fever
bysort feverchildtemp: tab outcomehospitalized  malariapositive_dum
gen discordantoutcome =1  if outcome ==1 & outcomehospitalized ==1 |  outcome ==2 & outcomehospitalized ==1

preserve
	keep if discordantoutcome ==1
	outsheet studyid id_wide visit discordantoutcome outcome outcomehospitalized dataset using "`data'discordant_hospital_outcomes.csv", names comma replace 
restore

bysort coinfectiongroup: tab symptomcount outcomehospitalized , chi2      
bysort coinfectiongroup: sum symptomcount outcomehospitalized , detail

dropmiss, force
bysort coinfectiongroup: sum  all_symptoms*
order all_symptoms_*
*graph bar    all_symptoms_halitosis - all_symptoms_general_pain, over(group)
*graph export symptmsbygroup.tif,  width(4000) replace

replace scleralicterus = sclerallcterus if scleralicterus  ==.
drop sclerallcterus interviewdate 
replace currently_sick  = "0" if currently_sick =="no"
replace currently_sick  = "1" if currently_sick =="yes"
destring currently_sick  , replace
replace currentsick = currently_sick if currentsick ==.
drop currently_sick 

foreach var in date_of_birth  {
				gen `var'1 = date(`var', "MDY" ,2050)
				format %td `var'1 
				drop `var'
				rename `var'1 `var'
				recast int `var'
				}


*severity
replace outcomehospitalized  = . if outcomehospitalized ==8
bysort coinfectiongroup: sum numhospitalized durationhospitalized1 durationhospitalized2 durationhospitalized3 durationhospitalized4 durationhospitalized5 
bysort outcomehospitalized: sum malariapositive_dum malariapositive_dum2 coinfectiongroup coinfectiongroup2
drop _merge

/*net get  dm0004_1.pkg
egen zhcaukwho = zanthro(headcircum,hca,UKWHOterm), xvar(age) gender(gender) gencode(male=0, female=1)nocutoff ageunit(year) 
egen zwtukwho = zanthro(childweight,wa,UKWHOterm), xvar(age) gender(gender) gencode(male=0, female=1)nocutoff ageunit(year) 
egen zhtukwho = zanthro(childheight,ha,UKWHOterm), xvar(age) gender(gender) gencode(male=0, female=1)nocutoff ageunit(year) 
egen zbmiukwho = zanthro(childbmi , ba ,UKWHOterm), xvar(age) gender(gender) gencode(male=0, female=1)nocutoff ageunit(year) 

*outsheet studyid gender age zwtukwho childweight  zhtukwho childheight  zbmiukwho childbmi  zhcaukwho  headcircum  if zbmiukwho  >5 & zbmiukwho  !=. |zbmiukwho  <-5 & zbmiukwho  !=. |zhcaukwho  <-5 & zhcaukwho  !=. |zhcaukwho  >5 & zhcaukwho  !=. using anthrotoreview.xls, replace
*table1, vars(zhcaukwho conts \ zwtukwho conts \ zhtukwho conts \ zbmiukwho  conts \)  by(coinfectiongroup) saving("`figures'anthrozscores.xls", replace ) missing test
*outsheet studyid gender age zwtukwho childweight  zhtukwho childheight  zbmiukwho childbmi  zhcaukwho  headcircum  using anthrozscoreslist.xls, replace
*/
sum zwtukwho zhtukwho zbmiukwho zhcaukwho, d

save "`data'pre_z", replace
preserve
		replace gender = gender +1
		gen agemons = age*12
		rename childweight weight 
		rename childheight height
		rename headcircum head	

		foreach var in gender agemons {
		keep if `var'!=.
		}

		keep if height >= 45 & height <= 109
		keep if weight >0.9 & weight < 58
		keep if head >25 & head <64
		keep if agemons <= 60

		dropmiss, force
		dropmiss, obs force

		gen region = site
		gen measure = "h"
		gen oedema = "n"

		rename gender GENDER
		rename weight WEIGHT
		rename height HEIGHT
		rename head HEAD
restore


insheet using "C:\Users\amykr\Box Sync\Amy Krystosik's Files\david coinfectin paper\who anthro\MySurvey_z_st.csv", clear 
save "`data'z_scores", replace

use "`data'pre_z"
merge 1:1 studyid using "`data'z_scores"
drop _merge
sum  zlen zwei zwfl zbmi zhc 

foreach result in malariaresults rdtresults bsresults{
tab `result' malariapositive_dum, m
}

tab labtests malariabloodsmear 
sum parasite_count malariapositive_dum 

encode city, gen(city_s)


*urban
gen urban = .
	replace urban = 0 if city =="chulaimbo"
	replace urban = 1 if city =="kisumu"
	replace urban = 0 if city =="msambweni"
	replace urban = 1 if city =="ukunda"

**mom educ***
gen mom_educ = mumeduclevel
replace mom_educ = 0 if strpos( othmumeduclevel, "did not")
replace mom_educ = 0 if strpos( othmumeduclevel, "didn't")
replace mom_educ = 0 if strpos( othmumeduclevel, "has not")
replace mom_educ = 0 if strpos( othmumeduclevel, "no")
replace mom_educ = 0 if strpos( othmumeduclevel, "never")
replace mom_educ = 0 if strpos( othmumeduclevel, "not")
replace mom_educ = 0 if strpos( othmumeduclevel, "nursery")

replace mom_educ = 2 if strpos( othmumeduclevel, "1")
replace mom_educ = 2 if strpos( othmumeduclevel, "2")
replace mom_educ = 2 if strpos( othmumeduclevel, "3")
replace mom_educ = 2 if strpos( othmumeduclevel, "4")
replace mom_educ = 2 if strpos( othmumeduclevel, "5")
replace mom_educ = 2 if strpos( othmumeduclevel, "6")
replace mom_educ = 2 if strpos( othmumeduclevel, "7")
replace mom_educ = 2 if strpos( othmumeduclevel, "seven")

replace mom_educ = 3 if strpos( othmumeduclevel, "madrasa")
replace mom_educ = 3 if strpos( othmumeduclevel, "madrassa")
replace mom_educ = 3 if strpos( othmumeduclevel, "madarasa")

replace mom_educ = . if mom_educ ==5| mom_educ ==9| mom_educ ==99
tab mom_educ, m 

gen mom_educ_dum = mom_educ
replace mom_educ_dum = 1 if mom_educ ==0 | mom_educ==1 
replace mom_educ_dum = 2 if mom_educ ==2 | mom_educ==3 | mom_educ==4
replace mom_educ_dum = mom_educ_dum-1 
drop mom_educ
rename mom_educ_dum mom_educ 
**end mom educ**

**severe malaria**
drop othoutcome_dum 
gen othoutcome_dum = .
replace othoutcome_dum  = 1 if othoutcome!=""
replace othoutcome_dum  = 0 if strpos(othoutcome, "nutritional")
gen outcomehospitalized_all = .

replace outcomehospitalized_all = 0 if outcome == 1
replace outcomehospitalized_all = 0 if outcome == 2
replace outcomehospitalized_all = 0 if othoutcome_dum == 0
replace outcomehospitalized_all = 0 if outcomehospitalized == 0

replace outcomehospitalized_all = 1 if outcome == 3
replace outcomehospitalized_all = 1 if outcome == 4
replace outcomehospitalized_all = 1 if outcome == 5
replace outcomehospitalized_all = 1 if othoutcome_dum == 1
replace outcomehospitalized_all = 1 if outcomehospitalized == 1

gen severemalaria = .
replace severemalaria = 0 if malariapositive_dum == 1 & outcomehospitalized_all ==0 & feverchildtemp ==1
replace severemalaria = 1 if malariapositive_dum == 1 & outcomehospitalized_all ==1 & feverchildtemp ==1
tab severemalaria
**end severe malaria **


**SES Index for aic**
		**ses index
duplicates tag id_wide visit , gen(id_wide_visit_dup)
drop if id_wide_visit_dup>0
isid id_wide visit 
preserve
	keep if cohort ==1
				

						foreach var of varlist  floortype rooftype watersource lightsource  telephone radio television bicycle motorizedvehi domesticworker latrinetype {
							capture tostring `var', replace
							tab `var'
						}

						foreach var of varlist _all{
							capture replace `var'=trim(itrim(lower(`var')))
							capture replace `var' = "" if `var'==""
							rename *, lower
						}
				tostring floortype , replace
				replace flooring  = floortype if flooring  =="."
					replace flooring = "3" if flooring =="Cement"
					replace flooring = "1" if flooring =="Dirt/Cement"
					replace flooring = "1" if flooring =="Dirt/Earth"
					replace flooring = "." if flooring =="No"
					replace flooring = "." if flooring =="Yes"
					destring flooring, replace
				drop floortype
				destring flooring, replace
				gen improvedfloor= .
				replace improvedfloor= 0 if flooring ==1
				replace improvedfloor= 1 if flooring ==2|flooring ==3|flooring ==4

				destring watersource, replace
				gen improvedwater=.
				replace improvedwater=0 if watersource == 1
				replace improvedwater=1 if watersource == 2
				replace improvedwater=2 if watersource == 3
				replace improvedwater=3 if watersource == 4|watersource == 5|watersource == 6

				tostring lightsource light_source   light, replace 
				replace lightsource = light_source if lightsource ==""
				drop light_source 
				tostring light lightsource , replace
				replace light = lightsource if light==""
				tab light
						
				gen improvedlight= .
				replace improvedlight= 0 if light=="4" |light=="lantern"|light=="tin lamp"|light=="Lantern"
				replace improvedlight= 1 if light=="5"| light=="2"
				replace improvedlight= 2 if light=="8"	
				replace improvedlight= 3 if light=="3"| light=="1"| light=="6"|light=="Electricity line"|light=="electricity"

		destring latrinetype , replace
		gen ownflushtoilet = .
		replace ownflushtoilet = 0 if latrinetype  == 0
		replace ownflushtoilet = 1 if latrinetype  == 3
		replace ownflushtoilet = 2 if latrinetype  == 4
		replace ownflushtoilet = 2 if latrinetype  == 5
				
foreach var of varlist improvedfloor improvedwater improvedlight telephone radio television bicycle motorizedvehicle domesticworker ownflushtoilet {
										tostring `var', replace
										replace `var'=lower(`var')
										gen aic_sesindex`var' =`var'
										replace aic_sesindex`var' = "1" if `var' == "yes" 
										replace aic_sesindex`var' = "0" if `var' == "no" |`var' == "none" 
										destring aic_sesindex`var', replace force
				gen aic_sesindex`var'_dum = .
				replace aic_sesindex`var'_dum =1 if aic_sesindex`var'==1
				replace aic_sesindex`var'_dum =0 if aic_sesindex`var'==0				
				}
							
		order aic_sesindex*
		keep id_wide visit aic_sesindeximprovedfloor_dum - aic_sesindexownflushtoilet_dum
		save aic_sesindex, replace
restore
**AIC SES Index End
merge 1:1 id_wide visit using aic_sesindex
drop _merge


*remove outliers for z scores
foreach var of varlist z*{
replace `var' = . if abs(`var') >5
}



********start medical history***
gen  pastmedhist_dum = .
replace pastmedhist_dum = 1 if pastmedhist!=""
replace pastmedhist_dum = 0 if pastmedhist==""

tabout pastmedhist using pastmedhist.xls, replace

gen pmh = pastmedhist 
	foreach var of varlist pmh{ 			
	replace `var'= subinstr(`var', " ", "_",.)
}
save temp, replace
use temp, clear
rename diarrheacount diarrheacount_old
rename asthmacount  asthmacount_old
*rename malariacount malariacount_old
		foreach var of varlist pmh{ 			
			foreach symptom in "asthma" "cardio_illness"  "tuberculosis" "meningitis" "hiv" "seizure_disorder" "diabetes" "diarrhea" "malaria" "intestinal_worms"  "pneumonia" "sickle_cell" "other_resp" {
									tostring `var', replace
									replace `var'=trim(itrim(lower(`var')))
									moss `var', match(`symptom') prefix(`symptom'b)
									gen `var'`symptom'=0
									replace `var'`symptom'= 1 if strpos(`var', "`symptom'")
									replace `var'= subinstr(`var', "`symptom'", "",.)
									order `var'`symptom'
									tab `var'`symptom'
									}
					}	
bysort severemalaria: sum  pmhother_resp pmhsickle_cell pmhpneumonia pmhintestinal_worms pmhmalaria pmhdiarrhea pmhdiabetes pmhseizure_disorder pmhhiv pmhmeningitis pmhtuberculosis pmhcardio_illness pmhasthma
*past medical history- break out
********end medical history***

**mosquito exposure index
*clean up mosqbitfreq
	tostring  mosquitobitefreq mosqbitefreq, replace
	replace mosqbitefreq = mosquitobitefreq if  mosqbitefreq  =="."|mosquitobitefreq ==""
	tab mosqbitefreq 
	drop mosquitobitefreq 
	replace mosqbitefreq ="1" if mosqbitefreq =="daily"
	replace mosqbitefreq ="2" if mosqbitefreq =="every_other_day"
	replace mosqbitefreq ="3" if mosqbitefreq =="weekly"
	replace mosqbitefreq ="5" if mosqbitefreq =="monthly"
	replace mosqbitefreq ="6" if mosqbitefreq =="every_other_month"
	replace mosqbitefreq ="8" if mosqbitefreq =="refused"
	destring mosqbitefreq , replace 
	tab mosqbitefreq 
*clean up mosquitocoil 
	replace mosquitocoil = usemosqcoil if mosquitocoil ==.
	drop usemosqcoil 

*clean up mosquitoday mosquitonight 
	replace mosqbitedaytime = mosquitoday if mosqbitedaytime ==.
	drop mosquitoday 
	
	replace mosqbitenight = mosquitonight if mosqbitenight ==.
	drop mosquitonight 
bysort cohort visit: fsum mosqbitedaytime mosqbitenight mosqbitefreq mosquitocoil mosquitobites mosquito_control avoidmosquitoes hoh_mosquito_control

drop id
encode id_wide, gen(id)
drop visit_int
encode visit, gen(visit_int)
xtset id visit_int

*mosquito prevention index
gen windows_protect = . 
	replace windows_protect= 1 if strpos(windows, "air_conditioning")
	replace windows_protect= 0 if strpos(windows, "no_windows")
	replace windows_protect= 0 if strpos(windows, "no-windows")
	replace windows_protect= 1 if strpos(windows, "windows_with_screens")
	replace windows_protect= 0 if strpos(windows, "windows_with_screens windows_without_sc")
	replace windows_protect = 0 if strpos(windows, "windows_without_screens")
	replace windows_protect= 1 if strpos(windows, "windows_without_screens air_conditionin")
	replace windows_protect= 0 if strpos(windows, "windows_without_screens no-windows")

	replace hoh_mosquito_control= mosquito_control if hoh_mosquito_control==""
		drop mosquito_control 
	replace hoh_mosquito_control= subinstr(hoh_mosquito_control, "mosquito","mosq", .)
	replace hoh_mosquito_control= subinstr(hoh_mosquito_control, "burning","brn", .)
	replace hoh_mosquito_control= subinstr(hoh_mosquito_control, "repellent","rplnt", .)
	replace hoh_mosquito_control= subinstr(hoh_mosquito_control, "sprays","spr", .)
	replace hoh_mosquito_control= subinstr(hoh_mosquito_control, "n/a","", .)
	replace hoh_mosquito_control= subinstr(hoh_mosquito_control, " ","_", .)
	replace hoh_mosquito_control= "none" if hoh_mosquito_control== "n/a"|hoh_mosquito_control== "none"|hoh_mosquito_control== "none_n/a"

tab hoh_mosquito_control


gen mosq_cont = hoh_mosquito_control
		foreach var of varlist mosq_cont { 			
			foreach mosquito_control in "burning_herbs" "fire" "mosquito_coil" "sprays" "repellent"{
						replace `var'=trim(itrim(lower(`var')))
						moss `var', match(`mosquito_control') prefix(`mosquito_control')

						gen `var'_`mosquito_control'=.
						replace `var'_`mosquito_control'= 1 if strpos(`var', "`mosquito_control'")
						replace `var'= subinstr(`var', "`mosquito_control'", "",.)
						order `var'_`mosquito_control'
						tab `var'_`mosquito_control'
						}
			}	
foreach var in mosquitocoil sleepbednet windows_protect mosquitobites outdooractivity mosqbitedaytime mosqbitenight mosqbitefreq avoidmosquitoes  mosq_cont_repellent mosq_cont_sprays mosq_cont_mosquito_coil mosq_cont_fire mosq_cont_burning_herbs{
	gen `var'd = .
	replace `var'd = 1 if `var'==1
	replace `var'd = 0 if `var'==0
}

********end mosquito***

**hcc ses index**
		foreach var of varlist motor_vehicle domestic_worker toilet_latrine latrine_location latrine_distance hoh_communal_tv own_tv  telephone radio bicycle rooftype othrooftype latrinetype othlatrinetype floortype othfloortype watersource lightsource othlightsource windownum numroomhse numpplehse television motorizedvehicle domesticworker {
					capture tostring `var', replace
					tab `var'
					}

					foreach var of varlist _all{
					capture replace `var'=trim(itrim(lower(`var')))
					rename *, lower
					}

		tostring cookingfuel cooking_fuel, replace
		replace cookingfuel = cooking_fuel if cookingfuel ==""
		replace cookingfuel = "1" if cookingfuel =="electricity"
		replace cookingfuel = "2" if cookingfuel =="paraffin"
		replace cookingfuel = "3" if cookingfuel =="gas"
		replace cookingfuel = "4" if cookingfuel =="wood"
		replace cookingfuel = "4" if cookingfuel =="firewood"
		replace cookingfuel = "5" if cookingfuel =="charcoal"
		replace cookingfuel = "6" if cookingfuel =="solar"
		replace cookingfuel = "7" if cookingfuel =="other"
		replace cookingfuel = "88" if cookingfuel =="refused"
		destring cookingfuel, replace  

		gen improvedfuel_index = .
		replace improvedfuel_index= 1 if cookingfuel==1
		replace improvedfuel_index= 1 if cookingfuel==2
		replace improvedfuel_index= 1 if cookingfuel==3
		replace improvedfuel_index= 0 if cookingfuel==4
		replace improvedfuel_index= 1 if cookingfuel==5
		replace improvedfuel_index= 1 if cookingfuel==6
		replace improvedfuel_index= 0 if cookingfuel==7
		tab improvedfuel_index

		tab water_source 
		tab drinkingwater
		replace drinkingwater="1" if drinkingwater	=="piped water in house" 
		replace drinkingwater="2" if drinkingwater	=="piped water in public tap" 
		replace drinkingwater="2" if drinkingwater	=="piped_public" 
		replace drinkingwater="3" if drinkingwater	=="public open well" 
		replace drinkingwater="3" if drinkingwater	=="public_well" 
		replace drinkingwater="7" if drinkingwater	=="borehole well" 
		replace drinkingwater="8" if drinkingwater	=="borehole_pump" 
		replace drinkingwater="9" if drinkingwater	=="other" 
		destring drinkingwater, replace 
		replace drinkingwater = water_source  if drinkingwater ==.

		gen improvedwater_index = .
		replace improvedwater_index = 1 if drinkingwater==1
		replace improvedwater_index = 1 if drinkingwater==1
		replace improvedwater_index = 1 if drinkingwater==1
		replace improvedwater_index = 0 if drinkingwater==4
		replace improvedwater_index = 0 if drinkingwater==5
		replace improvedwater_index = 0 if drinkingwater==6
		replace improvedwater_index = 0 if drinkingwater==7
		replace improvedwater_index = 0 if drinkingwater==8
		replace improvedwater_index = 0 if drinkingwater==9
		tab improvedwater_index 
		
	tab light	
replace light = "1" if light =="electricity"
replace light = "1" if light =="electricity line"
replace light = "3" if light =="lantern"
replace light = "4" if light =="tin lamp"
replace light = "9" if light =="other"
destring light, replace
replace light = light_source  if light ==.
		gen improvedlight_index = .
		replace improvedlight_index = 1 if light ==1
		replace improvedlight_index = 1 if light ==2
		replace improvedlight_index = 0 if light ==3
		replace improvedlight_index = 0 if light ==4
		replace improvedlight_index = 0 if light ==5
		replace improvedlight_index = 1 if light ==6
		replace improvedlight_index = 0 if light ==7
		replace improvedlight_index = 0 if light ==8
		replace improvedlight_index = 0 if light ==9
		tab improvedlight_index 

		tab latrine_location 
		replace latrine_location ="1" if latrine_location =="inside house"
		replace latrine_location ="4" if latrine_location =="no toilet"
		replace latrine_location ="3" if latrine_location =="outside_no wate"
		replace latrine_location ="3" if latrine_location =="outside_nowater"
		replace latrine_location ="2" if latrine_location =="outside_water"
		replace latrine_location ="2" if latrine_location =="outside_with wa"
		destring latrine_location , replace 
		
		gen latrine_index = .
		replace latrine_index = 0 if latrine_location ==4
		replace latrine_index = 0 if latrine_location ==3
		replace latrine_index = 1 if latrine_location ==1
		replace latrine_index = 1 if latrine_location ==2
		
replace toilet_latrine= "1" if toilet_latrine=="own_flush"
replace toilet_latrine= "1" if toilet_latrine=="flush toilet"
replace toilet_latrine= "3" if toilet_latrine=="pit latrine"
replace toilet_latrine= "3" if toilet_latrine=="traditional_pit_latrine"
replace toilet_latrine= "5" if toilet_latrine=="none"
destring toilet_latrine, replace

gen ownflushtoilet = .
replace  ownflushtoilet = 1 if toilet_latrine==1
replace  ownflushtoilet = 0 if toilet_latrine==2|toilet_latrine==3|toilet_latrine==4|toilet_latrine==5|toilet_latrine==6
tab ownflushtoilet 

rename land  land_index 
*house
		foreach var in rooms bedrooms hoh_roof { 
		tab `var'
		}


	replace flooring = "." if flooring=="yes"
	replace flooring = "." if flooring=="no"

	tostring hoh_floor flooring floorspecify , replace 
	replace hoh_floor = flooring if hoh_floor =="."| hoh_floor ==""
	replace hoh_floor = floorspecify if hoh_floor =="."|hoh_floor ==""
	replace hoh_floor = floortype if hoh_floor =="."| hoh_floor ==""
	replace hoh_floor = "." if hoh_floor =="yes"| hoh_floor =="no"
	replace hoh_floor = flooring if hoh_floor =="."| hoh_floor ==""
	replace hoh_floor = floorspecify if hoh_floor =="."|hoh_floor ==""
	replace hoh_floor = floortype if hoh_floor =="."| hoh_floor ==""

	replace hoh_floor = "4" if hoh_floor =="cement"
	replace hoh_floor = "4" if hoh_floor =="cement"
	replace hoh_floor = "1" if hoh_floor =="dirt/cement"
	replace hoh_floor = "1" if hoh_floor =="dirt/earth"
	replace hoh_floor = "1" if hoh_floor =="dirt/earth"
	destring hoh_floor , replace
	tab hoh_floor  cohort, m

	drop flooring floorspecify floortype
	rename hoh_floor flooring
	gen improvedfloor_index = .
	tab flooring
	replace improvedfloor_index= 1 if flooring== 2| flooring== 3|flooring== 4
	replace improvedfloor_index= 0 if flooring== 1

		foreach var in roof hoh_roof hoh_roof roofspecify rooftype{
		tab `var'
		}
		tostring roof hoh_roof roofspecify rooftype, replace
		replace roof = hoh_roof if roof =="."|roof ==""|roof =="0"|roof =="4"
		replace roof = roofspecify  if roof =="."|roof ==""|roof =="0"|roof =="4"
		replace roof = rooftype if roof =="."|roof ==""|roof =="0"|roof =="4"
		drop hoh_roof hoh_roof roofspecify rooftype othrooftype
		replace roof = "2" if roof == "corrugated iron"
		replace roof = "1" if roof == "natural material"
		destring roof, replace
		tab roof, m
		
		gen improvedroof_index = .
		replace improvedroof_index = 1 if roof==3 
		replace improvedroof_index = 0 if roof ==1|roof ==2 
		tab improvedroof_index 


replace rooms = hoh_rooms if rooms ==.
replace rooms = roomsinhouse if rooms ==.
drop hoh_rooms  roomsinhouse 
tab rooms cohort , m

replace bedrooms = hoh_bedrooms if bedrooms ==.
replace bedrooms = bedroomsinhouse if bedrooms ==.
drop hoh_bedrooms  bedroomsinhouse 
tab bedrooms cohort, m

		 
foreach var of varlist improvedfuel_index improvedwater_index improvedlight_index telephone radio own_tv bicycle motor_vehicle domestic_worker ownflushtoilet latrine_index land_index rooms bedrooms improvedroof_index improvedfloor_index{
								tostring `var', replace
								replace `var'=lower(`var')
								gen hcc_ses_`var' =`var'
								*drop `var'
								replace hcc_ses_`var' = "1" if `var' == "yes" 
								replace hcc_ses_`var' = "0" if `var' == "no" |`var' == "none" 
								destring hcc_ses_`var', replace force
					}
					
			ds, has(type string) 
			foreach var of varlist `r(varlist)' { 
				replace `var' = "0" if strpos(`var', "no")
				replace `var' = "0" if strpos(`var', "none")
				replace `var' = "1" if strpos(`var', "some")
				replace `var' = "2" if strpos(`var', "yes")
				replace `var' = "2" if strpos(`var', "all")
				destring `var', replace
			}

				sum hcc_ses_*

foreach var in childtravel nightaway  keep_livestock  outdooractivity mosquitocoil mosquitobites mosqbitedaytime mosqbitenight hcc_ses_improvedfuel_index hcc_ses_improvedwater_index hcc_ses_improvedlight_index hcc_ses_telephone hcc_ses_radio hcc_ses_own_tv hcc_ses_bicycle hcc_ses_motor_vehicle hcc_ses_domestic_worker hcc_ses_ownflushtoilet hcc_ses_latrine_index hcc_ses_land_index  hcc_ses_improvedroof_index hcc_ses_improvedfloor_index{
			gen `var'_dum = . 
			replace `var'_dum = 1 if `var' == 1
			replace `var'_dum = 0 if `var' == 0
		}

**end hcc ses index**
*use allt he baseline data to fill in for each visit & then create indices 
bysort id_wide (visit): carryforward hcc_ses_improvedfuel_index_dum hcc_ses_improvedwater_index_dum hcc_ses_improvedlight_index_dum hcc_ses_telephone_dum hcc_ses_radio_dum hcc_ses_own_tv_dum hcc_ses_bicycle_dum hcc_ses_motor_vehicle_dum hcc_ses_domestic_worker_dum hcc_ses_ownflushtoilet_dum hcc_ses_latrine_index_dum hcc_ses_land_index_dum hcc_ses_rooms hcc_ses_bedrooms hcc_ses_improvedroof_index_dum hcc_ses_improvedfloor_index_dum gender city cohort latitude longitude house_longitude house_latitude amy_city_id amy_compound_id amy_house_id amy_child_id compstatus compnumber compound_latitude compound_longitude compound_altitude compound_accuracy hoc_surname hoc_fname hoc_mname hoc_lname hoc_othername hoc_studyid hoc_gender hoc_dob hoc_age hoc_category hoc_language hoc_othlanguage hoc_tribe hoc_othtribe hoc_religion hoc_married hoc_other_married hoc_sleep_status house_number house_altitude house_accuracy house_pic hoh_surname hoh_fname hoh_mname hoh_lname hoh_othername hoh_studyid hoh_gender hoh_dob hoh_age hoh_category hoh_language hoh_othlanguage hoh_tribe hoh_othtribe hoh_religion hoh_married hoh_other_married hoh_children hoh_num_children hoh_house hoh_other_house hoh_sleep_here hoh_live_here hoh_district_years hoh_house_years 	hoh_people_per_room hoh_windows hoh_screens sleep_close_window hoh_own_bednet hoh_number_bednet hoh_sleep_bednet hoh_kids_sleep_bednet hoh_mosquito_control hoh_communal_tv hoh_water_collection  cooking_fuel water_source other_water_source light_source mosqbitefreq  mosquitocoil mosquitobites  mosqbitedaytime mosqbitenight avoidmosquitoes hoh_mosquito_control hoh_mosquito_control  mosq_cont_mosquito_coil mosquitocoil mosquito_coilcount mosquitocoild mosq_cont_mosquito_coild mosquitocoil_dum mosq_cont_repellent mosq_cont_sprays mosq_cont_fire mosq_cont_burning_herbs mosqbitefreq mosquitobites mosqbitedaytime mosqbitenight mosq_cont mosquitobitesd mosqbitedaytimed mosqbitenightd mosqbitefreqd mosq_cont_repellentd mosq_cont_spraysd mosq_cont_fired mosq_cont_burning_herbsd mosquitobites_dum mosqbitedaytime_dum mosqbitenight_dum, replace

			*aic ses_index_sum
			order aic*
				egen aic_ses_index_sum= rowtotal(aic_sesindex*)
					pctile pct_aic_ses_index = aic_ses_index_sum, nq(4)
					xtile quart_aic_ses_index = aic_ses_index_sum, nquantiles(4)
				egen wealthindex= rowtotal(aic_sesindeximprovedfloor_dum aic_sesindeximprovedlight aic_sesindextelephone  aic_sesindextelevision_dum aic_sesindexbicycle_dum aic_sesindexmotorizedvehicle_dum aic_sesindexdomesticworker_dum aic_sesindexradio_dum)
					pctile pct_wealthindex = wealthindex, nq(4)
					xtile quart_wealthindex = wealthindex, nquantiles(4)
				egen hygieneindex= rowtotal( aic_sesindexownflushtoilet_dum aic_sesindeximprovedwater_dum)
					pctile pct_hygieneindex= hygieneindex, nq(4)
					xtile quart_hygieneindex = hygieneindex, nquantiles(4)


				egen mosquito_exposure_index = rowtotal(mosqbitedaytime mosqbitenight mosqbitefreq mosquitobites outdooractivity avoidmosquitoes)  
					pctile pct_mosq_exp_index = mosquito_exposure_index , nq(4)
					xtile quart_mosq_exp_index = mosquito_exposure_index , nquantiles(4)
				egen mosquito_prevention_index = rowtotal(mosquitocoil avoidmosquitoes mosquitocoil sleepbednet windows_protect mosq_cont_repellent mosq_cont_sprays mosq_cont_mosquito_coil mosq_cont_fire mosq_cont_burning_herbs)
					pctile pct_mosq_prev_index = mosquito_prevention_index , nq(4)
					xtile quart_mosq_prev_index = mosquito_prevention_index , nquantiles(4)
			*hccses_index_sum
				egen hccses_index_sum= rowtotal(hcc_ses_improvedfuel_index_dum hcc_ses_improvedwater_index_dum hcc_ses_improvedlight_index_dum hcc_ses_telephone_dum hcc_ses_radio_dum hcc_ses_own_tv_dum hcc_ses_bicycle_dum hcc_ses_motor_vehicle_dum hcc_ses_domestic_worker_dum hcc_ses_ownflushtoilet_dum hcc_ses_latrine_index_dum hcc_ses_land_index_dum hcc_ses_rooms hcc_ses_bedrooms hcc_ses_improvedroof_index_dum hcc_ses_improvedfloor_index_dum)  if hcc_ses_improvedfuel_index !=.|hcc_ses_improvedwater_index !=.|hcc_ses_improvedlight_index !=.|hcc_ses_telephone !=.|hcc_ses_radio !=.|hcc_ses_own_tv !=.|hcc_ses_bicycle !=.|hcc_ses_motor_vehicle !=.|hcc_ses_domestic_worker !=.|hcc_ses_ownflushtoilet !=.|hcc_ses_latrine_index !=.|hcc_ses_land_index !=.|hcc_ses_rooms !=.|hcc_ses_bedrooms !=.|hcc_ses_improvedroof_index !=.|hcc_ses_improvedfloor_index!=.
				tab hccses_index_sum, m
				pctile pct_hccses_index= hccses_index_sum, nq(4)
				xtile quartile_hccses_index = hccses_index_sum, nquantiles(4)
*done creating indices

		
replace childvillage = village if childvillage ==""
drop village

*fix parasite count
compare parasite_count density
rename density parasite_count_hcc
rename parasite_count parasite_count_lab

replace gender1 = gender1 -1 
replace gender = gender1 if gender ==.
drop gender1

*shorten names 
rename *past_med_history* *pmh*

*merge kenya 2009 census data
replace city = "msambweni" if city =="nganja"
replace city = "msambweni" if city =="milani"
replace city = "chulaimbo" if city =="r"
replace city = "ukunda" if city =="w"
replace city = "ukunda" if city =="w"

	egen strata= concat(agegroup gender city)
	merge m:1 strata using "C:\Users\amykr\Box Sync\Amy Krystosik's Files\ASTMH 2017 abstracts\all linked and cleaned data\pop"
	drop _merge
tab strata

	egen max_anna_seroc_denv = max(anna_seroc_denv), by(id_wide)
	egen max_jimmy_seroc_chikv  = max(jimmy_seroc_chikv), by(id_wide)

	drop jimmy_seroc_chikv anna_seroc_denv
	rename max_jimmy_seroc_chikv  jimmy_seroc_chikv 
	rename max_anna_seroc_denv anna_seroc_denv

bysort visit: tab jimmy_seroc_chikv stanfordchikvigg_, m
list studyid if jimmy_seroc_chikv ==1 & stanfordchikvigg_!=1
list id_wide if jimmy_seroc_chikv ==1 & stanfordchikvigg_!=1 & visit_int>1
order id_wide visit studyid jimmy_seroc_chikv stanfordchikvigg_ anna_seroc_denv stanforddenvigg_ 

bysort visit : tab anna_seroc_denv stanforddenvigg_ 
list studyid if anna_seroc_denv ==1 & stanforddenvigg_ !=1 
list id_wide if anna_seroc_denv ==1 & stanforddenvigg_ !=1

*apparent is aic cohort: first febrile episode + fever- take everyone that fails
*innapparent is hcc cohort: seroconversion with no fever- take only the failures after the first visit (incident, not prevalent)
*third group is hcc cohort: seroconversion with fever- take only the failures after the first visit (incident, not prevalent)
	gen apparent_groups= . 
	replace apparent_groups= 1 if cohort == 1 & feverchildtemp==1
	replace apparent_groups= 2 if cohort == 2 & fever_6ms ==0
	replace apparent_groups= 3 if cohort == 2 & fever_6ms ==1 |cohort == 2 & fever_6ms ==.
	tab apparent_groups
	*collapse these two groups 
	gen collapsed_apparent_groups = apparent_groups  
	replace collapsed_apparent_groups =2 if collapsed_apparent_groups ==3
	
compare parasite_count_lab parasite_count_hcc 
gen parasite_count_all=.	
replace parasite_count_all= parasite_count_lab if parasite_count_all==.
replace parasite_count_all= parasite_count_hcc if parasite_count_all==.
replace malariapositive_dum2 =1 if parasite_count_all >0 & parasite_count_lab !=.
replace malariapositive_dum2 =0 if parasite_count_all ==0 


*convert visit to time in months
gen time = . 
replace time = visit_int*1 if cohort ==1

replace time = 1 if visit_int ==1 & cohort ==2 
replace time = 6 if visit_int ==2 & cohort ==2 
replace time = 12 if visit_int ==3 & cohort ==2 

merge 1:1 id_wide visit_int using "C:\Users\amykr\Box Sync\Amy Krystosik's Files\ASTMH 2017 abstracts\all linked and cleaned data\data\incident_malaria$S_DATE"
drop if _merge ==2
drop _merge

order latitude longitude *latitude *longitude x y point_x point_y
capture gen gps_x_long = .
replace gps_x_long = point_x if gps_x_long ==.
replace gps_x_long = longitude if gps_x_long ==.
replace gps_x_long = house_longitude if gps_x_long ==.
capture gen gps_y_lat = .
replace gps_y_lat = point_y if gps_y_lat ==.
replace gps_y_lat = latitude if gps_y_lat ==.
replace gps_y_lat = house_latitude if gps_y_lat ==.

list gps_y_lat point_y latitude house_latitude gps_y_lat point_x longitude house_longitude in 1/100, clean

save "`data'cleaned_merged_prevalence$S_DATE", replace

drop *dup
order studyid  hhmerge childmerge id_wide city houseid id_childnumber visit cohort id*  *igg* *pcr* *dum  age gender parasite*
bysort id_wide (visit): carryforward cohort age gender city site year season month seasonyear mosquito_exposure_index  mosqbitefreq mosquitocoil mosquitobites   mosqbitedaytime mosqbitenight  avoidmosquitoes hoh_mosquito_control hoh_*  hcc_ses_improvedfuel_index_dum hcc_ses_improvedwater_index_dum hcc_ses_improvedlight_index_dum hcc_ses_telephone_dum hcc_ses_radio_dum hcc_ses_own_tv_dum hcc_ses_bicycle_dum hcc_ses_motor_vehicle_dum hcc_ses_domestic_worker_dum hcc_ses_ownflushtoilet_dum hcc_ses_latrine_index_dum hcc_ses_land_index_dum hcc_ses_improvedroof_index_dum hcc_ses_improvedfloor_index_dum hcc_ses_improvedfuel_index hcc_ses_improvedwater_index hcc_ses_improvedlight_index hcc_ses_telephone hcc_ses_radio hcc_ses_own_tv hcc_ses_bicycle hcc_ses_motor_vehicle hcc_ses_domestic_worker hcc_ses_ownflushtoilet hcc_ses_latrine_index hcc_ses_land_index hcc_ses_rooms hcc_ses_bedrooms hcc_ses_improvedroof_index hcc_ses_improvedfloor_index , replace

 local data "C:\Users\amykr\Box Sync\Amy Krystosik's Files\ASTMH 2017 abstracts\all linked and cleaned data\data\"
outsheet using "`data'cleaned_merged_prevalence$S_DATE.csv", replace names comma

********************************************************************start incidence***************************************************************

					**gen incident data based on igg and pcr results. 
					capture gen inc_denv= 0 if denvpcrresults_dum==0 |stanforddenvigg_==0
					replace inc_denv= 1 if denvpcrresults_dum==1 |stanforddenvigg_==1

					capture gen inc_chikv= 0 if chikvpcrresults_dum ==0 | stanfordchikvigg_==0
					replace inc_chikv = 1 if chikvpcrresults_dum ==1 | stanfordchikvigg_==1

			save temp, replace

			**************************************************************
*find the minimum visit that is tested.
*denv
preserve 
		keep if stanforddenvigg_ !=. 
		sort id_wide visit, stable 
		egen minvisit_igg = min(visit_int), by(id_wide)
		save minvisit_igg, replace 
restore
 
merge m:m id_wide using minvisit_igg
	*keep incident cases
	bysort id_wide: gen initial_stanforddenvigg_neg =1 if stanforddenvigg_ == 0 & visit_int == minvisit_igg
	egen max_initial_igg  = max(initial_stanforddenvigg_neg), by(id_wide)
	drop initial_stanforddenvigg_neg
	rename max_initial_igg   initial_stanforddenvigg_neg
	
	keep if initial_stanforddenvigg_neg ==1 | denvpcrresults_dum==1 
	order inc_denv inc_chikv minvisit_igg
	sum inc_denv inc_chikv minvisit_igg
 
save "`data'inc_denv$S_DATE", replace
outsheet using "`data'inc_denv_w_PCR_$S_DATE.csv", comma replace names

*chikv
use temp, clear
	preserve 
		keep if stanfordchikvigg_ !=. 
		bysort id_wide: egen minvisit_igg = min(visit_int)
		save minvisit_igg, replace 
	restore
		merge m:m id_wide using minvisit_igg
	*keep incident cases
	bysort id_wide: gen initial_stanfordchikvigg_neg =1 if stanfordchikvigg_ == 0 & visit_int == minvisit_igg
	egen max_initial_igg = max(initial_stanfordchikvigg_neg), by(id_wide)
	drop initial_stanfordchikvigg_neg
	rename max_initial_igg   initial_stanfordchikvigg_neg

	keep if initial_stanfordchikvigg_neg ==1 | chikvpcrresults_dum==1 
sum inc_denv inc_chikv minvisit_igg
save "`data'inc_chikv$S_DATE", replace
outsheet using "`data'inc_chikv_w_PCR_$S_DATE.csv", comma replace names


*malaria
use temp, clear
	preserve 
	tab incident_malaria
		keep if  incident_malaria!=. 
		tab incident_malaria visit_int
	save "`data'incident_malaria$S_DATE", replace
	outsheet using "`data'inc_malaria_$S_DATE.csv", comma replace names
restore
tab incident_malaria cohort

foreach outcome in inc_denv incident_malaria inc_chikv{
	use `outcome', clear
	stset time, failure(`outcome') id(id_wide) 
	sts list
	sts list, by(cohort) 
	sts list, by(site cohort) 
	sts list, by(site) 
	sts list, by(urban) 
	sts list, by(city) 

**/Active disease from CHIKV and DENV were associated with SES, gender, X and Y. */
preserve
		keep if cohort ==1
			table1,	vars(season cat \cohort cat \  urban bin\ gender bin \ site cat \ age conts \ city cat ) by(`outcome') missing test saving("`figures'INCIDENCE_$S_DATE.xls", sheet("AIC_`outcome'_W_PCR") sheetreplace) 
restore

preserve
	keep if cohort ==2
		table1,	vars(season cat \cohort cate \ gender bine \ age conts \ city cate ) by(`outcome') missing test saving("`figures'INCIDENCE_$S_DATE.xls", sheet("HCC_`outcome'_W_PCR") sheetreplace) 
restore
}

***************************************************end incidence******************************************************************



***************************************************start Prevalence******************************************************************

use "`data'cleaned_merged_prevalence$S_DATE", clear
**gen prevalence data based on igg only . 
capture drop id
encode id_wide, gen(id)
stset id visit_int

**malaria prevalence**
		stgen no_malaria= always( malariapositive_dum2==0 |malariapositive_dum2==. )
		stgen when_malaria= when(malariapositive_dum2==1)
		stgen prev_malaria= ever(malariapositive_dum2==1)

		tab prev_malaria
		tab no_malaria

		gen malaria_prev = .
		replace malaria_prev = 1 if prev_malaria==1
		replace malaria_prev = 0 if no_malaria ==1
		tab malaria_prev 
		keep if malaria_prev !=.
save "`data'prev_malaria_w_PCR$S_DATE", replace
outsheet using "`data'prev_malaria_w_PCR_$S_DATE.csv", comma replace names
 
preserve
keep if cohort ==1
			*denv
			table1,	vars(malariapositive_dum2  bin \ season cat \cohort cat \  urban bin\ gender bin \ site cat \ age conts \ city cat cat) by(prev_malaria) missing test saving("`figures'PREVALENCE_$S_DATE.xls", sheet("AIC_PREV_malaria_W_PCR") sheetreplace) 
restore

preserve
	keep if cohort ==2
		*denv
		table1,	vars(malariapositive_dum2  bin \season cat \cohort cate \ gender bine \ age conts \ city cate \ ) by(prev_malaria) missing test saving("`figures'PREVALENCE_$S_DATE.xls", sheet("HCC_PREV_malaria_W_PCR") sheetreplace) 
restore


**denv prevalence**
use "`data'cleaned_merged_prevalence$S_DATE", clear

capture drop id
encode id_wide, gen(id)
stset id visit_int
		stgen no_denv = always(stanforddenvigg_==0 & denvpcrresults_dum==0|stanforddenvigg_==0 & denvpcrresults_dum==.|stanforddenvigg_==. & denvpcrresults_dum==0)
		stgen when_denv = when(stanforddenvigg_==1 | denvpcrresults_dum==1)
		stgen prev_denv = ever(stanforddenvigg_==1 | denvpcrresults_dum==1)

		tab prev_denv 
		tab no_denv 

		gen denv_prev = .
		replace denv_prev = 1 if prev_denv ==1
		replace denv_prev = 0 if no_denv ==1
		tab denv_prev 
		keep if denv_prev !=.
save "`data'prev_denv_w_PCR$S_DATE", replace
outsheet using "`data'prev_denv_w_PCR_$S_DATE.csv", comma replace names
 
preserve
keep if cohort ==1
			*denv
			table1,	vars(malariapositive_dum2  bin \ season cat \cohort cat \  urban bin\  gender bin \ site cat \ age conts \ city cat ) by(prev_denv) missing test saving("`figures'PREVALENCE_$S_DATE.xls", sheet("AIC_PREV_DENV_W_PCR") sheetreplace) 
restore

preserve
	keep if cohort ==2
		*denv
		table1,	vars(malariapositive_dum2  bin \season cat \cohort cate \ gender bine \ age conts \ city cate \ ) by(prev_denv) missing test saving("`figures'PREVALENCE_$S_DATE.xls", sheet("HCC_PREV_DENV_W_PCR") sheetreplace) 
restore

 

 
 **chikv prevalence**
use "`data'cleaned_merged_prevalence$S_DATE", clear

capture drop id 
encode id_wide, gen(id)
stset id visit_int

		stgen no_chikv = always(stanfordchikvigg_==0 & chikvpcrresults_dum==0 | stanfordchikvigg_==0 & chikvpcrresults_dum==.| stanfordchikvigg_==. & chikvpcrresults_dum==0)
		stgen when_chikv = when(stanfordchikvigg_==1 | chikvpcrresults_dum==1)
		stgen prev_chikv  = ever(stanfordchikvigg_==1 | chikvpcrresults_dum==1)

		tab prev_chikv 
		tab no_chikv  

		gen chikv_prev = .
		replace chikv_prev = 1 if prev_chikv ==1
		replace chikv_prev = 0 if no_chikv ==1
		tab chikv_prev 
		keep if chikv_prev !=.
		tab prev_chikv cohort

save "`data'prev_chikv_w_PCR$S_DATE", replace
outsheet using "`data'prev_chikv_w_PCR_$S_DATE.csv", comma replace names

preserve
keep if cohort ==1
			*chikv
			table1,	vars(malariapositive_dum2  bin \ season cat \cohort cat \  urban bin\ gender bin \ site cat \ age conts \ city cat  \) by(prev_chikv) missing test saving("`figures'PREVALENCE_$S_DATE.xls", sheet("AIC_PREV_CHIKV_W_PCR") sheetreplace) 
restore

preserve
	keep if cohort ==2
		*chikv
		table1,	vars(malariapositive_dum2  bin \ season cat \cohort cate \ gender bine \ age conts \ city cate \ ) by(prev_chikv) missing test saving("`figures'PREVALENCE_$S_DATE.xls", sheet("HCC_PREV_CHIKV_W_PCR") sheetreplace) 
restore
***************************************************end Prevalence******************************************************************
