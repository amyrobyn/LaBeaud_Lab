/********************************************************************
 *amy krystosik                  							  		*
 *ellyse astmh abstract 2017- apprent and innaparent denv and chikv	*
 *lebeaud lab               				        		  		*
 *last updated march 14, 2017  							  			*
 ********************************************************************/ 
capture log close 
set more 1
set scrollbufsize 100000
log using "elysse_tropmed2017_apparent_inapparent.smcl", text replace 
cd "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\elysse- apparent inapparent"
local figures "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\elysse- apparent inapparent\figures\"
local data "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\elysse- apparent inapparent\data\"

use "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\interviewdata\all_interviews", clear
*add in the pcr data from box and from googledoc. 
bysort id_wide visit: gen dup = _n
merge 1:1 id_wide visit using "C:\Users\amykr\Box Sync\DENV CHIKV project\Lab Data\ELISA Database\ELISA Latest\elisa_merged"
drop _merge

*fix the studyid's that are missing or wrong
encode id_wide, gen(id_wide_int)
encode visit, gen(visit_int)
xtset id_wide_int visit_int
by id_wide_int : carryforward id_childnumber id_cohort id_city id_cohort, replace
by id_wide_int : carryforward id_childnumber id_cohort id_city id_cohort, replace
order id_childnumber id_cohort id_city id_visit id_city studyid id_wide
gen id_childnumber2 = substr(id_wide , +3, .) if studyid==""
destring id_childnumber2 , replace force
replace id_childnumber =id_childnumber2  if studyid==""

egen studyid2 =concat(id_city id_cohort visit id_childnumber) if studyid ==""
replace studyid =studyid2 if studyid ==""
drop id_childnumber2  studyid2 
*done fixing id's
outsheet dataset id_wide studyid id_city visit id_cohort stanford* using "`data'missing.csv" if id_cohort =="", comma names replace

*fix temperature
replace temperature = temp if temperature ==.
drop temp

rename stanforddenvigg_ sdenvigg
rename stanfordchikvigg_ schikvigg
save temp, replace

foreach outcome in sdenvigg schikvigg{
use temp, replace

*`outcome' pos at first
preserve
	keep if cohort ==1
	keep if  `outcome' ==1 & temp >=38
	sort visit
	bysort id_wide: gen visit`outcome' = _n
	keep id_wide visit visit`outcome' `outcome' temp 
	gen firstvisitpos`outcome' = 1 if visit`outcome' ==1
	tab visit firstvisitpos`outcome'
	sum
	keep id_wide visit firstvisitpos`outcome'
	keep if firstvisitpos`outcome'==1
	save firstvisitpos`outcome', replace 
restore 
capture drop _merge
merge 1:1 id_wide visit using firstvisitpos`outcome'
drop _merge 
by id_wide: carryforward firstvisitpos`outcome', gen(all_firstvisitpos`outcome')

*den neg at first
preserve
	keep if id_cohort =="f"
	keep if  `outcome' ==0
	sort visit
	bysort id_wide: gen visit`outcome' = _n
	keep id_wide visit visit`outcome' `outcome' temp 
	gen firstvisitneg`outcome'= 1 if visit`outcome' ==1
	tab visit firstvisitneg`outcome'
	sum
	keep id_wide visit firstvisitneg`outcome'
	keep if firstvisitneg`outcome'==1
	save firstvisitneg`outcome', replace 
restore 
merge 1:1 id_wide visit using firstvisitneg`outcome'
drop _merge
by id_wide : carryforward firstvisitneg`outcome', gen(firstvisitneg_all`outcome')

*`outcome' neg at first and pos at 2nd
preserve
	keep if firstvisitneg_all`outcome'==1 & `outcome' ==1 & temp >=38 
	sort visit
	bysort id_wide: gen visit`outcome' = _n
	keep id_wide visit visit`outcome' `outcome' temp firstvisitneg`outcome' firstvisitneg_all`outcome'
	gen secondvisitpos`outcome'= 1 
	tab visit secondvisitpos`outcome'
	sum
	keep id_wide visit secondvisitpos`outcome'
	keep if secondvisitpos`outcome'==1
	save secondvisitpos`outcome', replace 
restore 
merge 1:1 id_wide visit using secondvisitpos`outcome'
drop _merge

preserve
	by id_wide: carryforward secondvisitpos`outcome', gen(secondvisitpos`outcome'_all)
	sum secondvisitpos`outcome' firstvisitneg`outcome' firstvisitpos`outcome'
	gen apparent`outcome' = . 
	replace apparent`outcome'= 1 if secondvisitpos`outcome' == 1 | firstvisitpos`outcome'==1
	bysort id_wide: carryforward apparent`outcome', gen(apparent`outcome'_subj)
save temp2, replace
		keep apparent`outcome' id_wide visit 
		keep if apparent`outcome'== 1 
		save visit_apparent`outcome', replace
use temp2, clear	
	collapse(mean) apparent`outcome', by (id_wide)
	bysort id_wide: replace apparent`outcome' = 0 if apparent`outcome'==.
	tab apparent`outcome'
keep id_wide apparent`outcome'
save apparent`outcome', replace
restore
}

*merge the apparent with full data
	use apparentsdenvigg, clear
	merge m:1 id_wide using apparentschikvigg
	capture drop _merge
	save apparent, replace
**start innaparent
foreach outcome in sdenvigg schikvigg{
use temp, replace

*`outcome' neg at first and pos at 2nd
*first positive visit
preserve
	keep if `outcome' ==1 & id_cohort =="c"
	sort visit
	bysort id_wide: gen visit`outcome' = _n
	gen secondvisitpos`outcome'= 1 
	tab visit secondvisitpos`outcome'
	keep id_wide visit secondvisitpos`outcome' visit_int 
	keep if secondvisitpos`outcome'==1
	gen posvisit = visit_int 
	save secondvisitpos`outcome', replace 
restore 
capture drop _merge
merge 1:1 id_wide visit using secondvisitpos`outcome'
capture drop _merge
by id_wide : carryforward secondvisitpos`outcome', gen(secondvisitpos_all`outcome')


*if ever positive, where they negative at previous visit 
preserve
	keep if  `outcome' ==0 & secondvisitpos`outcome'==1 & visit_int == posvisit -1
	sort visit
	bysort id_wide: gen visit`outcome' = _n
	keep id_wide visit `outcome' temp 
	gen firstvisitneg`outcome'= 1 
	tab visit firstvisitneg`outcome'
	keep id_wide visit firstvisitneg`outcome'
	keep if firstvisitneg`outcome'==1
	save firstvisitneg`outcome', replace 
restore 
capture drop _merge
merge 1:1 id_wide visit using firstvisitneg`outcome'
capture drop _merge

preserve
	by id_wide: carryforward firstvisitneg`outcome', gen(firstvisitneg_all`outcome')
	sum secondvisitpos`outcome' firstvisitneg`outcome' 
	gen inapparent`outcome' = . 
	replace inapparent`outcome'= 1 if secondvisitpos`outcome' == 1
	
save temp2, replace
		keep inapparent`outcome' id_wide visit 
		keep if inapparent`outcome' == 1 
		save visit_inapparent`outcome', replace
use temp2, clear
	
	bysort id_wide: carryforward inapparent`outcome', gen(inapparent`outcome'_subj)
	collapse(mean) inapparent`outcome', by (id_wide)
	bysort id_wide: replace inapparent`outcome' = 0 if inapparent`outcome'==.
	tab inapparent`outcome'
keep id_wide inapparent`outcome'
save inapparent`outcome', replace
restore
}
	*merge the inapparent with full data
	use temp, clear
	capture drop _merge
	merge m:1 id_wide using inapparentsdenvigg
	capture drop _merge
	merge m:1 id_wide using inapparentschikvigg
	capture drop _merge
	save inapparent, replace
**end innaparent
capture drop _merge
merge m:1 id_wide using apparent
save fulldataset, replace

foreach var in visit_inapparentsdenvigg visit_inapparentschikvigg visit_apparentschikvigg visit_apparentsdenvigg{
	use `var', clear
	gen `var' = visit 
	save `var', replace

	use fulldataset, clear
	drop _merge
	merge 1:1 id_wide visit using `var'
	encode `var', gen(`var'_dum)
	replace `var'_dum = 1 if `var'_dum!=.
	replace `var'_dum = 0 if `var'_dum==.
	save fulldataset, replace
}

sum visit_inapparentsdenvigg_dum visit_inapparentschikvigg_dum visit_apparentschikvigg_dum visit_apparentsdenvigg_dum
foreach var in visit_inapparentsdenvigg visit_inapparentschikvigg visit_apparentschikvigg visit_apparentsdenvigg{
tab `var'
}

	replace temp = 38.5 if temp ==385
	replace fevertemp =1 if temp>=38  & temp !=.

	tab numillnessfever
gen fever_6ms =. 
replace fever_6ms=1 if 	numillnessfever > 0 & numillnessfever != . 
replace fever_6ms=1 if 	fevertoday == 1 

foreach disease in visit_inapparentsdenvigg_dum visit_inapparentschikvigg_dum {
	gen `disease'_f = . 
	replace `disease'_f = 1 if fever_6ms ==1 & `disease' >= 1 & `disease' !=.
}

list studyid id_wide visit inapparentsdenvigg inapparentschikvigg visit_inapparentsdenvigg_dum visit_inapparentschikvigg_dum numillnessfever  if visit_inapparentsdenvigg_dum !=.| visit_inapparentschikvigg_dum !=.
count if visit_inapparentsdenvigg_dum_f ==1
count if visit_inapparentschikvigg_dum_f ==1

replace hb = hb_result if hb==.
drop hb_result 

gen sexlabel = "sex"
gen agelabel = "age"
egen agegender = concat(agelabel age sexlabel gender)
drop if strpos(agegender, ".")
drop _merge
merge m:1 agegender using "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\CSVs nov29_16\normal_population_aic_b"
drop if age>18
drop heart_rate 
rename heartrate heart_rate 

replace headcircum  = head_circumference if headcircum  ==.
drop head_circumference 
foreach var in heart_rate systolicbp  diastolicbp  pulseoximetry temp resprate { 
		replace `var'= . if `var'==999
		gen z`var'=.
}

foreach var in childweight childheight hb headcirc{ 
		replace `var'= . if `var'==999
		replace `var'= . if `var'==0		
}

*ask david about these
replace systolicbp = systolicbp/10 if systolicbp >200
replace temperature = temperature/10 if temperature >50
replace childheight = childheight/10 if childheight >500
replace childheight = childheight *10 if childheight <20
replace childweight=childweight/10 if childweight>200

foreach var in heart_rate systolicbp  diastolicbp  pulseoximetry temperature resprate{ 
		replace `var'=. if `var'==0
}

foreach var in heart_rate systolicbp  diastolicbp  pulseoximetry temperature resprate{ 
		replace `var'=. if `var'<15
}
	
levelsof agegender, local(levels) 
foreach l of local levels {
	foreach var in heart_rate systolicbp  diastolicbp  pulseoximetry resprate{ 
		replace z`var' = (`var' - median`var'`l')/sd`var'`l' if agegender=="`l'"  
	}
}
sum z*

sum heart_rate systolicbp  diastolicbp  pulseoximetry temperature childweight childheight  resprate hb  headcircum  
sum heart_rate systolicbp  diastolicbp  pulseoximetry temperature childweight childheight  resprate hb  headcircum  , d
sum z*, d


**symptoms
 rename currentsymptoms symptms
 rename othcurrentsymptoms othersymptms 
 rename feversymptoms fvrsymptms
 rename othfeversymptoms otherfvrsymptms
 egen all_symptoms = concat(symptms othersymptms fvrsymptms otherfvrsymptms) 
 
gen symptomstoreview = all_symptoms
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
**end symptoms**

*medsprescribe to dummies
egen all_meds = concat(medsprescribe othmedsprescribe) 
gen medstoreview = all_meds 
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
outsheet medsprescribe othmedsprescribe  TOCATEGORIZE using allmeds.xls, replace 
restore
drop medsprescribe othmedsprescribe 
*end meds

/*
all possible combinations of visit_inapparentsdenvigg_dum visit_inapparentschikvigg_dum visit_apparentschikvigg_dum visit_apparentsdenvigg_dum
four digits with 0 as neg and 1 as positive
  */
egen group = concat(visit_inapparentsdenvigg_dum visit_inapparentschikvigg_dum visit_apparentschikvigg_dum visit_apparentsdenvigg_dum)

replace outcomehospitalized = . if outcomehospitalized ==8
replace outcome= . if outcome==99|outcome==6

gen othoutcome_dum = .
replace othoutcome_dum  = 3 if othoutcome!=""
replace othoutcome_dum  = 1 if strpos(othoutcome, "nutritional")
replace outcome = othoutcome_dum  if outcome ==.
tab outcome outcomehospitalized , m

bysort group: tab symptomcount outcomehospitalized , chi2      
bysort group: sum symptomcount outcomehospitalized , detail


dropmiss, force
bysort group: sum  all_symptoms*
order all_symptoms_*
*graph bar    all_symptoms_halitosis - all_symptoms_general_pain, over(group)
*graph export symptmsbygroup.tif,  width(4000) replace

replace interviewdate = interviewdate2 if interviewdate ==.
replace interviewdate = interview_date if interviewdate ==. 
drop interviewdate2 interview_date 
replace scleralicterus = sclerallcterus if scleralicterus  ==.
drop sclerallcterus interviewdate 
replace currently_sick  = "0" if currently_sick =="no"
replace currently_sick  = "1" if currently_sick =="yes"
destring currently_sick  , replace
replace currentsick = currently_sick if currentsick ==.
drop currently_sick 
replace temperature = temp if temperature ==.
drop temp

foreach var in date_of_birth{
				gen `var'1 = date(`var', "MDY" ,2050)
				format %td `var'1 
				drop `var'
				rename `var'1 `var'
				recast int `var'
}

*severity
replace outcomehospitalized  = . if outcomehospitalized ==8
bysort group: sum numhospitalized durationhospitalized1 durationhospitalized2 durationhospitalized3 durationhospitalized4 durationhospitalized5 

drop _merge

table1, vars(zhcaukwho conts \ zwtukwho conts \ zhtukwho conts \ zbmiukwho  conts \)  by(group) saving("anthrozscores.xls", replace ) missing test
sum zwtukwho zhtukwho zbmiukwho zhcaukwho, d

save pre_z, replace
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
save z_scores, replace

use pre_z
merge 1:1 studyid using z_scores

sum  zlen zwei zwfl zbmi zhc 

encode city, gen(city_s)
*tables
table1 , vars(age contn \ gender bin \ city cat \ outcome cat \ outcomehospitalized bin \  heart_rate conts \ zhcaukwho conts \ zwtukwho conts \ zhtukwho conts \ zbmiukwho conts \ zheart_rate conts \ zsystolicbp conts \ zdiastolicbp conts \ zpulseoximetry conts \ zresprate conts \ zlen conts \ zwei conts \ zwfl conts \ zbmi conts \ zhc conts \ scleralicterus cat \ splenomegaly  cat \  hivmeds bin \ hivpastmedhist bin \) by(group) saving("`figures'table2_by_group.xls", replace ) missing test 
table1, vars(all_symptoms_halitosis bin \  all_symptoms_edema bin \  all_symptoms_appetite_change bin \  all_symptoms_constipation cat \  all_symptoms_behavior_change bin \  all_symptoms_altms bin \  all_symptoms_abnormal_gums cat \  all_symptoms_jaundice cat \  all_symptoms_constitutional bin \  all_symptoms_asthma cat \  all_symptoms_lethergy cat \  all_symptoms_dysphagia bin \  all_symptoms_dysphrea bin  \  all_symptoms_anaemia cat \  all_symptoms_seizure bin \  all_symptoms_itchiness bin \  all_symptoms_bleeding_symptom bin \  all_symptoms_sore_throat bin \  all_symptoms_sens_eyes cat \  all_symptoms_earache bin \  all_symptoms_funny_taste bin \  all_symptoms_imp_mental cat \  all_symptoms_mucosal_bleed_brs bin \  all_symptoms_bloody_nose cat \  all_symptoms_rash bin \  all_symptoms_dysuria bin \  all_symptoms_nausea bin \  all_symptoms_respiratory bin \  all_symptoms_aches_pains bin \  all_symptoms_abdominal_pain bin \  all_symptoms_diarrhea bin \  all_symptoms_vomiting bin \  all_symptoms_chiils  bin \  all_symptoms_fever bin \  all_symptoms_eye_symptom bin \  all_symptoms_other cat \  ) by(group) saving("`figures'symptoms_by_group.xls", replace) missing test
table1, vars(all_meds_antifungal bin \ all_meds_supplement bin \ all_meds_allergy bin \ all_meds_expectorant cat\ all_meds_antihelmenthic bin \ all_meds_antipyretic bin \ all_meds_antimalarial bin \ all_meds_antibacterial bin \ all_meds_bronchospasm bin \ all_meds_topical  bin \ all_meds_antiamoeba bin \    all_meds_none bin \   all_meds_gerd bin \   all_meds_painmed bin \ all_meds_sulphate bin \ all_meds_cough bin \ all_meds_iv bin \ all_meds_ors bin \ all_meds_admit bin \ all_meds_othermed bin \  ) by(group) saving("`figures'meds_by_group.xls", replace) missing test
outsheet using "`data'rawdata.csv", comma names replace

save "`data'data", replace

local data "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\elysse- apparent inapparent\data\"
preserve
	keep if  visit_inapparentsdenvigg_dum_f ==1 |visit_inapparentschikvigg_dum_f ==1
	outsheet studyid id_wide visit visit_inapparentsdenvigg_dum_f visit_inapparentschikvigg_dum_f  fevertoday numillnessfever fever_6ms  symptomstoreview  medstoreview durationsymptom everhospitali reasonhospita* othhospitalna* seekmedcare medtype wheremedseek othwheremedseek counthosp durationhospi* hospitalname* datehospitali* numhospitalized outcome outcomehospitalized all_symptoms*  using "`data'toreview.csv", names comma replace 
restore



