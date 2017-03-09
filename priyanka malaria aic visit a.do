/********************************************************************
 *amy krystosik                  							  		*
 *priyanka malaria microscopy, AIC all visits						*
 *lebeaud lab               				        		  		*
 *last updated feb 21, 2017  							  			*
 ********************************************************************/ 
capture log close 
log using "priyankamalariaaicvisita.smcl", text replace 
set scrollbufsize 100000
set more 1
cd "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\priyanka malaria aic visit a\data"
use "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\interviewdata\all_interviews", clear
*add in the pcr data from box and from googledoc. 
bysort id_wide visit: gen dup = _n
drop id_childnumber 
merge 1:1 id_wide visit using "C:\Users\amykr\Box Sync\Amy Krystosik's Files\david coinfectin paper\data\allpcr"
		*replace denvpcrresults_dum = 1 if denvpcrresults_dum>0 & denvpcrresults_dum<.
		save elisas_PCR_RDT, replace	
		rename _merge interview_elisa_pcr_match

merge 1:1 id_wide visit using "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\malaria prelim data dec 29 2016\malaria"
replace cohort = id_cohort if cohort ==""
*keep if visit == "a" & cohort =="f"
keep if cohort =="f"
tab visit 
drop _merge
replace hb = hb_result if hb==.
drop hb_result 


gen sexlabel = "sex"
gen agelabel = "age"
egen agegender = concat(agelabel age sexlabel gender)
count if strpos(agegender, ".")
drop if strpos(agegender, ".")
merge m:1 agegender using "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\CSVs nov29_16\normal_population_aic_b"
drop if age>18

drop heart_rate 
rename heartrate heart_rate 
*replace childheight = child_height if childheight ==.
*drop child_height 
*replace childweight = child_weight if childweight ==.
*drop child_weight 

replace headcircum  = head_circumference if headcircum  ==.
drop head_circumference 
foreach var in heart_rate systolicbp  diastolicbp  pulseoximetry temperature resprate { 
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
	foreach var in heart_rate systolicbp  diastolicbp  pulseoximetry temperature resprate{ 
	replace z`var' = (`var' - median`var'`l')/sd`var'`l' if agegender=="`l'"  
	}
}
sum z*

sum heart_rate systolicbp  diastolicbp  pulseoximetry temperature childweight childheight  resprate hb  headcircum  
sum heart_rate systolicbp  diastolicbp  pulseoximetry temperature childweight childheight  resprate hb  headcircum  , d
sum z*, d


*add in doctor visit bs and rdt result
gen malariapositive_dum2 = malariapositive_dum  
replace malariapositive_dum2 =1 if bsresult > 0 & bsresult <. & malariapositive_dum2 ==.
replace malariapositive_dum2 =1 if rdtresult > 0 & rdtresult <. & malariapositive_dum2  ==.
tab malariapositive_dum2 malariapositive_dum, m 

tab denvpcrresults_dum malariapositive_dum, m 
tab denvpcrresults_dum malariapositive_dum2, m 

gsort -denvpcrresults_dum 

bysort city: list id_wide visit denvpcrresults_dum malariapositive_dum if malariapositive_dum2 ==1 |denvpcrresults_dum ==1, clean

**************david's severity models*************	
gen davidcoinfection =.
		foreach id_wide in cf201 cf241 cf247 kf189 kf204 kf337 cf196 cf205 cf211 cf246 cf248 cf256 cf257 cf265 cf273 cf313 cf340 rf496 cf193 cf200 cf210 cf236 cf243 cf268 cf271 cf300 cf348 cf385 kf185 kf202 kf342 cf245 kf184 {
					replace davidcoinfection = 1 if id_wide =="`id_wide'" & visit =="a"
		}

		foreach id_wide in cf305 cf272 kf184{
			replace davidcoinfection = 1 if id_wide =="`id_wide'" & visit =="c"
		}

tab denvpcrresults_dum  davidcoinfection 
tab malariapositive_dum davidcoinfection 

 rename currentsymptoms symptms
 rename othcurrentsymptoms othersymptms 
 rename feversymptoms fvrsymptms
 rename othfeversymptoms otherfvrsymptms
 egen all_symptoms = concat(symptms othersymptms) 

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

foreach symptom in "body_rushes" "boggy_pus_discharging_swelling_on_butt" "chicken_box" "chicken_pox" "constipation" "difficulty_in_urination" "dry_lips" "ear_discharge" "eye_discharge" "_flue"  "_flu," "_flu"  "_foul_smelly_stool" "_ful_micturation" "_fungal_skin_infection" "_infra_auricular_sweling" "_jiggers" "_kidney_problem" "_measles" "_neckswelling" "_pus_ear_discharge" "_restless" "_ringworms" "_running_nose" "_sickle_cell" "_sickler" "_small_pox" "_sores_on_the_neck" "_sprained_wrist" "_strutles" "...(line truncated)...
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

gen dmcoinf = .
replace dmcoinf = 1 if malariapositive_dum==1 & denvpcrresults_dum==1
gen dmcoinf2 = .
replace dmcoinf2 = 1 if malariapositive_dum2==1 & denvpcrresults_dum==1

foreach var in malariapositive_dum denvpcrresults_dum dmcoinf{
	bysort  `var': sum all_symptoms_*
}

gen group = .
replace group = 0 if malariapositive_dum ==0 & denvpcrresults_dum ==0
replace group = 1 if malariapositive_dum==1
replace group = 2 if denvpcrresults_dum==1
replace group = 3 if dmcoinf==1
tab davidcoinfection group, m

gen group2 = .
replace group2 = 0 if malariapositive_dum2 ==0 & denvpcrresults_dum ==0
replace group2 = 1 if malariapositive_dum2==1
replace group2 = 2 if denvpcrresults_dum==1
replace group2 = 3 if dmcoinf2==1
tab davidcoinfection group2, m

outsheet city studyid id_wide visit denvpcrresults_dum malariapositive_dum malariapositive_dum2  davidcoinfection group group2 using coinfection.xls, replace


foreach studyid in "cfa236" "kfa00337" "kfa00185" "cfa00256" "kfc00184" "kfa00204" "kfa00202" "cfa00205" "cfa00385" "cfa00211" "cfa00201" "cfa00273" "kfa00189" "cfa00348" "cfa00300" "cfa00248" "cfa00313" "cfa00257" "rfa00496" "cfa00196" "cfa00246" "cfa00200" "cfa00243" "cfa00268" "kfa00342" "cfa00265" "cfa00247" "cfa00241" "cfa00340" "cfa00271" "cfa00193" "cfa00245" "cfa00210"{
list if studyid == "`studyid'"
}

foreach studyid in "cfa236" "kfa337" "kfa185" "cfa256" "kfc184" "kfa204" "kfa202" "cfa205" "cfa385" "cfa211" "cfa201" "cfa273" "kfa189" "cfa348" "cfa3" "cfa248" "cfa313" "cfa257" "rfa496" "cfa196" "cfa246" "cfa2" "cfa243" "cfa268" "kfa342" "cfa265" "cfa247" "cfa241" "cfa340" "cfa271" "cfa193" "cfa245" "cfa210"{
list if studyid == "`studyid'"
}

gen davidcoinfection2 =.
foreach studyid in "cf236" "kf337" "kf185" "cf256" "kfc184" "kf204" "kf202" "cf205" "cf385" "cf211" "cf201" "cf273" "kf189" "cf348" "cf3" "cf248" "cf313" "cf257" "rf496" "cf196" "cf246" "cf2" "cf243" "cf268" "kf342" "cf265" "cf247" "cf241" "cf340" "cf271" "cf193" "cf245" "cf210"{
replace davidcoinfection2 = 1 if id_wide== "`studyid'"
}

outsheet city studyid id_wide visit denvpcrresults_dum malariapositive_dum malariapositive_dum2  davidcoinfection davidcoinfection2  group  using coinfection2.xls, replace

preserve 
		keep davidcoinfection2 group studyid id_wide denvpcrresults_dum malariapositive_dum
		order davidcoinfection2 group studyid id_wide denvpcrresults_dum malariapositive_dum
		sort davidcoinfection2
restore


replace outcomehospitalized = . if outcomehospitalized ==8
bysort group: tab symptomcount outcomehospitalized , chi2      
bysort group: sum symptomcount outcomehospitalized , detail


gen selected = .
replace selected = 0 if malariapositive_dum==0 & denvpcrresults_dum==0
replace selected = 1 if malariapositive_dum==1
replace selected = 1 if denvpcrresults_dum==1
replace selected = 1 if dmcoinf==1

dropmiss, force
bysort group: sum  all_symptoms*

table1, vars(all_symptoms_halitosis cat \  all_symptoms_edema cat \  all_symptoms_appetite_change cat \  all_symptoms_constipation cat \  all_symptoms_behavior_change cat \  all_symptoms_altms cat \  all_symptoms_abnormal_gums cat \  all_symptoms_jaundice cat \  all_symptoms_constitutional cat \  all_symptoms_asthma cat \  all_symptoms_lethergy cat \  all_symptoms_dysphagia cat \  all_symptoms_dysphrea cat \  all_symptoms_anaemia cat \  all_symptoms_seizure cat \  all_symptoms_itchiness cat \  all_symptoms_...(line truncated)...

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

foreach var in date_of_birth  {
				gen `var'1 = date(`var', "MDY" ,2050)
				format %td `var'1 
				drop `var'
				rename `var'1 `var'
				recast int `var'
				}
table1 , vars(temperature conts \ age contn \ gender cat \city cat \cohort cat \ heart_rate conts \ scleralicterus cat \ splenomegaly  cat \) by(group) saving("table2_by_group.xls", replace ) missing test 

*severity
replace outcomehospitalized  = . if outcomehospitalized ==8

bysort group: sum numhospitalized durationhospitalized1 durationhospitalized2 durationhospitalized3 durationhospitalized4 durationhospitalized5 


*table1 , vars( \malariapositive_dum cat \ ovaparasites cat\ outcomehospitalized cat \ durationhospitalized1 conts\ durationhospitalized2 conts\ numhospitalized cat\  consecutivemalariapos  cat\) by(group) saving("table3_severity_by_group.xls", replace ) missing test 
*repeatmalaria bin \ 

bysort outcomehospitalized: sum malariapositive_dum malariapositive_dum2 group group2

*bysort group: sum gametocytes ovaparasites repeatmalaria outcomehospitalized 
drop _merge

/*
net get  dm0004_1.pkg
egen zhcaukwho = zanthro(headcircum,hca,UKWHOterm), xvar(age) gender(gender) gencode(male=0, female=1)nocutoff ageunit(year) 
egen zwtukwho = zanthro(childweight,wa,UKWHOterm), xvar(age) gender(gender) gencode(male=0, female=1)nocutoff ageunit(year) 
egen zhtukwho = zanthro(childheight,ha,UKWHOterm), xvar(age) gender(gender) gencode(male=0, female=1)nocutoff ageunit(year) 
egen zbmiukwho = zanthro(childbmi , ba ,UKWHOterm), xvar(age) gender(gender) gencode(male=0, female=1)nocutoff ageunit(year) 
*/
outsheet studyid gender age zwtukwho childweight  zhtukwho childheight  zbmiukwho childbmi  zhcaukwho  headcircum  if zbmiukwho  >5 & zbmiukwho  !=. |zbmiukwho  <-5 & zbmiukwho  !=. |zhcaukwho  <-5 & zhcaukwho  !=. |zhcaukwho  >5 & zhcaukwho  !=. using anthrotoreview.xls, replace
table1, vars(zhcaukwho conts \ zwtukwho conts \ zhtukwho conts \ zbmiukwho  conts \)  by(group) saving("anthrozscores.xls", replace ) missing test
outsheet studyid gender age zwtukwho childweight  zhtukwho childheight  zbmiukwho childbmi  zhcaukwho  headcircum  using anthrozscoreslist.xls, replace
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

		outsheet studyid GENDER agemons GENDER WEIGHT HEIGHT site measure oedema HEAD using "C:\Users\amykr\Box Sync\Amy Krystosik's Files\david coinfectin paper\denvchikvmalariagps_symptoms.csv", comma names replace
restore

insheet using "C:\Users\amykr\Box Sync\Amy Krystosik's Files\david coinfectin paper\who anthro\MySurvey_z_st.csv", clear 
save z_scores, replace
use pre_z
merge 1:1 studyid using z_scores
sum  zlen zwei zwfl zbmi zhc 


foreach result in malariaresults rdtresults bsresults{
tab `result' malariapositive_dum, m
}

tab labtests malariabloodsmear 
sum malariapositive malariapositive_dum 
encode city, gen(city_s)
		

local demograhpics dob date_of_birth  gender age  childoccupation educlevel otheduclevel mumeduclevel numsiblings childtravel wheretravel nightaway outdooractivity mosquitocoil sleepbednet mosquitobites everhospitalised reasonhospitalized1 reasonhospitalized2 counthosp othmumeduclevel othchildoccupation numhospitalized 
local symptoms symptomcount all_symptoms*
local severity outcome outcomehospitalized datehospit*alized 
local onset stageofdisease othstageofdisease stageofdiseasecoded  numdaysonset date_symptom_onset 
local medical_history childcontact eversurgery reasonsurgery datesurgery gestational breastfed durationbfed othdurationbfed childvaccination yellowfever encephalitis pastmedhist othpastmedhist everpregnant hivpastmedhist 
local meds currenttakingmeds currentmeds meds  othcurrentmeds hivmeds pcpdrugs antibiotic antimalarial antiparasitic ibuprofen paracetamol 
local exams hivtest cliniciannoteshneck abdlocation othnodeexam cliniciannotesnode urinalysisresult stoolovacyst othoutcome datehospitalized2 hospitalname2 durationhospitalized2 reasonhospitalized3 datehospitalized3 hospitalname3 durationhospitalized3 reasonhospitalized4 datehospitalized4 hospitalname4 durationhospitalized4 reasonhospitalized5 datehospitalized5 hospitalname5 durationhospitalized5 malariapastmedhist pneumoniapastmedhist paracetamolcurrentmeds redeyes bleedingums  adbtenderness hepatomegaly deviceid setofpast_med_historypast_hospit dateyellowfever cliniciannoteschest cliniciannotesheart cliniciannotesjoint cliniciannotesneuro hivresult othstoolovacyst sicklecellresult secondarybacterialdx   
local vitals calculated_fever headcircum resp_rate systolic_pressure diastolic_pressure pulse_ox can_visual_acuity  head_neck_exam chest_examchest heart_examheart abd_abdomen node_examnodes jointsjoints jointsjoint_location skin_examskin neuro_examneuro tourniquet_test mal_test malaria_results labslabs_ordered primary_diagnosis secondary_diagnosis health_impacts health_impacts_other meds_prescribed meds_prescribed_other nearestpoint spp1 countul1 gametocytes1 treatment1 spp2 countul2 treatment2 temperature ...(line truncated)...
local infection_groups chikvpcrresults_dum denvpcrresults_dum  malariapositive malariapositive_dum malariapositive_dum2  species_cat  pf200 pm200 po200 pv200 ni200 none200 parasitelevel   group group2  

order `infection_groups' `severity' `demograhpics' `symptoms' `onset'  `medical_history'  `meds' `exams' `vitals'  
outsheet `infection_groups' `severity' `demograhpics' `symptoms' `onset'  `medical_history'  `meds' `exams' `vitals'  using priyanka_aic_visita.xls, replace

foreach group in `infection_groups' `severity' `demograhpics' `symptoms' `onset'  `medical_history'  `meds' `exams' `vitals'  {
	sum `group'
}

tab outcome

gen othoutcome_dum = 0
replace othoutcome_dum  = 1 if othoutcome!=""
replace othoutcome_dum  = 0 if strpos(othoutcome, "nutritional")

gen outcomehospitalized_all = 0
replace outcomehospitalized_all = 1 if outcome == 3
replace outcomehospitalized_all = 1 if outcome == 4
replace outcomehospitalized_all = 1 if outcome == 5
replace outcomehospitalized_all = 1 if othoutcome_dum == 1
replace outcomehospitalized_all = 1 if outcomehospitalized == 1

gen severemalaria = .
keep if temperature >=38

replace severemalaria = 0 if malariapositive_dum == 1 & outcomehospitalized_all ==0
replace severemalaria = 1 if malariapositive_dum == 1 & outcomehospitalized_all ==1
tab severemalaria visit

bysort id_wide : gen dupmalaria_a = _n if malariapositive_dum==1 & visit =="a"
replace dupmalaria_a = 0 if dupmalaria_a ==.
egen max_dupmalaria_a  = max(dupmalaria_a ), by(id_wide) 
list studyid id_wide max_dupmalaria_a  malariapositive_dum  visit if max_dupmalaria_a  >1 & max_dupmalaria_a  !=.

bysort id_wide: gen dupmalaria = _n if  malariapositive_dum==1
bysort visit: tab dupmalaria outcomehospitalized_all
bysort age malariapositive_dum outcomehospitalized_all: sum childweight childheight

drop if dupmalaria >1 & dupmalaria  !=.


replace systolicbp = . if systolicbp < 40
gen systolicbp70 = . 
replace systolicbp70 = 1 if  systolicbp < 70 
replace systolicbp70 = 0 if  systolicbp >= 70 & systolicbp <.
**SES Index**
		**ses index
					foreach var of varlist  floortype rooftype watersource light telephone radio television bicycle motorizedvehi domesticworker latrinetype {
					capture tostring `var', replace
					tab `var'
					}

					foreach var of varlist _all{
					capture replace `var'=trim(itrim(lower(`var')))
					capture replace `var' = "" if `var'==""
					rename *, lower
					}

		rename floortype flooring
		destring flooring, replace
		gen improvedfloor_index = .
		replace improvedfloor_index= 0 if flooring ==1
		replace improvedfloor_index= 1 if flooring ==2|flooring ==3|flooring ==4

		destring watersource, replace
		gen improvedwater_index =.
		replace improvedwater_index =0 if watersource == 1
		replace improvedwater_index =1 if watersource == 2
		replace improvedwater_index =2 if watersource == 3
		replace improvedwater_index =3 if watersource == 4|watersource == 5|watersource == 6

		destring light, replace
		
		replace light = 2 if strpos(othlightsource, "paraffin") 
		replace light = 2 if strpos(othlightsource, "candles") 
		replace light = 8  if strpos(othlightsource, "torch") 
		replace light = 8  if strpos(othlightsource, "electric rechargable lamp") 
		
		gen improvedlight_index = .
		replace improvedlight_index = 0 if light==4
		replace improvedlight_index = 1 if light==5| light==2
		replace improvedlight_index = 2 if light==8	
		replace improvedlight_index = 3 if light==3| light==1| light==6

destring latrinetype , replace
replace latrinetype = 0  if strpos(othlatrinetype , "neighbors") 
replace latrinetype = 3  if strpos(othlatrinetype , "have both pit latrine and flas") 
gen ownflushtoilet = .
replace ownflushtoilet = 0 if latrinetype  == 0
replace ownflushtoilet = 1 if latrinetype  == 3
replace ownflushtoilet = 2 if latrinetype  == 4
replace ownflushtoilet = 2 if latrinetype  == 5
		
		foreach var of varlist improvedfloor_index  improvedwater_index improvedlight_index telephone radio television bicycle  motorizedvehicle domesticworker ownflushtoilet {
								tostring `var', replace
								replace `var'=lower(`var')
								gen sesindex`var' =`var'
								replace sesindex`var' = "1" if `var' == "yes" 
								replace sesindex`var' = "0" if `var' == "no" |`var' == "none" 
								destring sesindex`var', replace force
					}
					
				order sesindex*
				sum  sesindeximprovedfloor_index - sesindexownflushtoilet
				egen ses_index_sum= rowtotal(sesindeximprovedfloor_index - sesindexownflushtoilet)
				bysort severemalaria: tab ses_index_sum


egen wealthindex= rowtotal(sesindeximprovedfloor_index  sesindeximprovedlight_index  sesindextelephone sesindexradio sesindextelevision sesindexbicycle  sesindexmotorizedvehicle sesindexdomesticworker )
egen hygieneindex= rowtotal(sesindeximprovedwater_index sesindexownflushtoilet )


foreach var in wealthindex ses_index_sum hygieneindex{
	tab `var' severemalaria , chi2
}

tabout wealthindex severemalaria using "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\priyanka malaria aic visit a\data\wealthindex.xls", c(row col) replace
**SES Index End

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

/**mosq index**
**end mos index**/

gen urban = .
	replace urban = 0 if city =="chulaimbo"
	replace urban = 1 if city =="kisumu"
	replace urban = 0 if city =="msambweni"
	replace urban = 1 if city =="ukunda"

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
********stop medical history***

replace childvillage = village if childvillage ==""
drop village
encode city, gen(city_int)
encode site, gen(site_int)
encode childvillage, gen(village_int)

tabout childvillage using village.xls , replace

table1 , vars( splenomegaly  bin\ age contn \ gender bin\city cat \ zheart_rate conts \ zsystolicbp conts \ zdiastolicbp conts \ zpulseoximetry conts \ ztemperature conts \ zresprate conts \ hb conts \  all_symptoms_altms bin\  all_symptoms_jaundice cat\  all_symptoms_bleeding_symptom bin\  all_symptoms_imp_mental cat\  all_symptoms_mucosal_bleed_brs bin\  all_symptoms_bloody_nose cat\  all_symptoms_fever bin\  scleralicterus bin\ systolicbp70 bin\) by(severemalaria) saving("severmalaria.xls", replace ) mis...(line truncated)...

table1, vars( parasite_count  conts \ zbmiukwho conts \ zhtukwho conts \  zwtukwho conts \  zhcaukwho conts \  mom_educ cat \ age contn \ gender bin \ city cat \ site cat \ urban cat \ wealthindex contn \ ses_index_sum  contn  \ hygieneindex contn \ sesindeximprovedfloor_index cat \sesindeximprovedwater_index cat \sesindeximprovedlight_index cat \sesindextelephone cat \sesindexradio cat \sesindextelevision cat \sesindexbicycle cat \sesindexmotorizedvehicle cat \sesindexdomesticworker cat \sesindexownflushto...(line truncated)...

logit severemalaria parasite_count age gender pastmedhist_dum  hivmeds zbmiukwho zhtukwho zwtukwho zhcaukwho mom_educ i.city_int i.site_int urban wealthindex hygieneindex , or
outreg using logit2.doc, replace

logit severemalaria parasite_count age gender pastmedhist_dum  hivmeds zbmiukwho zhcaukwho mom_educ i.city_int wealthindex hygieneindex , or
outreg using logit1.doc, replace

outsheet using "finaldataset.csv", comma names replace

