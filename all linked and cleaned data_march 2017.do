/********************************************************************
 *amy krystosik                  							  		*
 *david coinfection by denv pcr and malaria microscopy, AIC visit A	*
 *lebeaud lab               				        		  		*
 *last updated feb 21, 2017  							  			*
 ********************************************************************/ 
capture log close 
log using "all linked and cleaned data.smcl", text replace 
set scrollbufsize 100000
set more 1
set scrollbufsize 100000
cd "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\all linked and cleaned data"
local figures "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\all linked and cleaned data\draft_figures_tables"
local data "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\all linked and cleaned data\data\"

use "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\interviewdata\all_interviews", clear
*add in the pcr data from box and from googledoc. 
bysort id_wide visit: gen dup = _n
drop id_childnumber 
merge 1:1 id_wide visit using "C:\Users\amykr\Box Sync\DENV CHIKV project\Lab Data\PCR Database\PCR Latest\allpcr"
		*replace denvpcrresults_dum = 1 if denvpcrresults_dum>0 & denvpcrresults_dum<.
		save elisas_PCR_RDT, replace	
		rename _merge interview_elisa_pcr_match


merge 1:1 id_wide visit using "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\malaria prelim data dec 29 2016\malaria"
replace cohort = id_cohort if cohort ==""
drop _merge cohort
merge 1:1 id_wide visit using "C:\Users\amykr\Box Sync\DENV CHIKV project\Lab Data\ELISA Database\ELISA Latest\elisa_merged"
drop _merge
replace hb = hb_result if hb==.
drop hb_result 


*fix the studyid's that are missing or wrong
encode id_wide, gen(id_wide_int)
drop visit_int
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
replace temp = 38.5 if temp ==385
replace fevertemp =1 if temp>=38  & temp !=.
replace fevertemp =0 if temperature <38

gen fever_6ms =. 
replace fever_6ms=1 if 	numillnessfever > 0 & numillnessfever != . 
replace fever_6ms=1 if 	fevertoday == 1 

replace fever_6ms=0 if 	numillnessfever == 0 
replace fever_6ms=1 if 	fevertoday == 0

*cohort
replace cohort =2 if id_cohort == "c"
replace cohort = 1 if id_cohort == "f"


gen sexlabel = "sex"
gen agelabel = "age"
egen agegender = concat(agelabel age sexlabel gender)
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

tab malariapositive_dum malariapositive_dum2 

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

*symptoms to dummies
 rename currentsymptoms symptms
 rename othcurrentsymptoms othersymptms 
 rename feversymptoms fvrsymptms
 rename othfeversymptoms otherfvrsymptms
 egen all_symptoms = concat(symptms othersymptms fvrsymptms otherfvrsymptms) 

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
egen all_meds = concat(medsprescribe othmedsprescribe) 

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

gen dmcoinf = .
replace dmcoinf = 1 if malariapositive_dum==1 & denvpcrresults_dum==1
gen dmcoinf2 = .
replace dmcoinf2 = 1 if malariapositive_dum2==1 & denvpcrresults_dum==1

foreach var in malariapositive_dum denvpcrresults_dum dmcoinf{
	bysort  `var': sum all_symptoms_*
}

*group 0 is neg; 1 is malaria pos; 2 is denv pos; 3 is coinfection. 
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

*outsheet city studyid id_wide visit denvpcrresults_dum malariapositive_dum malariapositive_dum2  davidcoinfection group group2 using coinfection.xls, replace


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

*outsheet city studyid id_wide visit denvpcrresults_dum malariapositive_dum malariapositive_dum2  davidcoinfection davidcoinfection2  group  using coinfection2.xls, replace

preserve 
		keep davidcoinfection2 group studyid id_wide denvpcrresults_dum malariapositive_dum
		order davidcoinfection2 group studyid id_wide denvpcrresults_dum malariapositive_dum
		sort davidcoinfection2
restore


replace outcomehospitalized = . if outcomehospitalized ==8
replace outcome= . if outcome==99|outcome==6

gen othoutcome_dum = .
replace othoutcome_dum  = 3 if othoutcome!=""
replace othoutcome_dum  = 1 if strpos(othoutcome, "nutritional")
replace outcome = othoutcome_dum  if outcome ==.
tab outcome outcomehospitalized , m
gen discordantoutcome =1  if outcome ==1 & outcomehospitalized ==1 |  outcome ==2 & outcomehospitalized ==1
preserve
	keep if discordantoutcome ==1
	outsheet studyid id_wide visit discordantoutcome outcome outcomehospitalized dataset using discordantoutcomes.csv, names comma replace 
restore

bysort group: tab symptomcount outcomehospitalized , chi2      
bysort group: sum symptomcount outcomehospitalized , detail


gen selected = .
replace selected = 0 if malariapositive_dum==0 & denvpcrresults_dum==0
replace selected = 1 if malariapositive_dum==1
replace selected = 1 if denvpcrresults_dum==1
replace selected = 1 if dmcoinf==1

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

foreach var in date_of_birth  {
				gen `var'1 = date(`var', "MDY" ,2050)
				format %td `var'1 
				drop `var'
				rename `var'1 `var'
				recast int `var'
				}


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
*outsheet studyid gender age zwtukwho childweight  zhtukwho childheight  zbmiukwho childbmi  zhcaukwho  headcircum  if zbmiukwho  >5 & zbmiukwho  !=. |zbmiukwho  <-5 & zbmiukwho  !=. |zhcaukwho  <-5 & zhcaukwho  !=. |zhcaukwho  >5 & zhcaukwho  !=. using anthrotoreview.xls, replace
table1, vars(zhcaukwho conts \ zwtukwho conts \ zhtukwho conts \ zbmiukwho  conts \)  by(group) saving("anthrozscores.xls", replace ) missing test
*outsheet studyid gender age zwtukwho childweight  zhtukwho childheight  zbmiukwho childbmi  zhcaukwho  headcircum  using anthrozscoreslist.xls, replace
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

*outsheet studyid GENDER agemons GENDER WEIGHT HEIGHT site measure oedema HEAD using "C:\Users\amykr\Box Sync\Amy Krystosik's Files\david coinfectin paper\denvchikvmalariagps_symptoms.csv", comma names replace
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

*outsheet using "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\priyanka malaria aic visit a\data\priyankamalariaaicvisita.csv", replace comma names
*tables

table1 , vars(age conts \ gender bin \ city cat \ outcome cat \ outcomehospitalized bin \  heart_rate conts \ zhcaukwho conts \ zwtukwho conts \ zhtukwho conts \ zbmiukwho conts \ zheart_rate conts \ zsystolicbp conts \ zdiastolicbp conts \ zpulseoximetry conts \ ztemperature conts \ zresprate conts \ zlen conts \ zwei conts \ zwfl conts \ zbmi conts \ zhc conts \ scleralicterus cat \ splenomegaly  cat \  hivmeds bin \ hivpastmedhist bin \) by(stanforddenvigg_ ) saving("`figures'table1bystanforddenvigg.xls", replace ) missing test 
table1 , vars(age conts \ gender bin \ city cat \ outcome cat \ outcomehospitalized bin \  heart_rate conts \ zhcaukwho conts \ zwtukwho conts \ zhtukwho conts \ zbmiukwho conts \ zheart_rate conts \ zsystolicbp conts \ zdiastolicbp conts \ zpulseoximetry conts \ ztemperature conts \ zresprate conts \ zlen conts \ zwei conts \ zwfl conts \ zbmi conts \ zhc conts \ scleralicterus cat \ splenomegaly  cat \  hivmeds bin \ hivpastmedhist bin \) by(stanfordchikvigg_ ) saving("`figures'table1bystanforddenvigg.xls", replace ) missing test 

table1 , vars(age conts \ gender bin \ city cat \ stanforddenvigg_ cat \  stanfordchikvigg_ cat \  zwtukwho conts \ zhtukwho conts \ zbmiukwho conts \) by(cohort) saving("`figures'table1bycohrt.xls", replace ) missing test 
table1 , vars(age conts \ gender bin \ city cat \ stanforddenvigg_ cat \  stanfordchikvigg_ cat \  zwtukwho conts \ zhtukwho conts \ zbmiukwho conts \) by(site) saving("`figures'table1bysite.xls", replace ) missing test 

table1, vars(all_symptoms_halitosis bin \  all_symptoms_edema bin \  all_symptoms_appetite_change bin \  all_symptoms_constipation cat \  all_symptoms_behavior_change bin \  all_symptoms_altms bin \  all_symptoms_abnormal_gums cat \  all_symptoms_jaundice cat \  all_symptoms_constitutional bin \  all_symptoms_asthma cat \  all_symptoms_lethergy cat \  all_symptoms_dysphagia bin \  all_symptoms_dysphrea bin  \  all_symptoms_anaemia cat \  all_symptoms_seizure bin \  all_symptoms_itchiness bin \  all_symptoms_bleeding_symptom bin \  all_symptoms_sore_throat bin \  all_symptoms_sens_eyes cat \  all_symptoms_earache bin \  all_symptoms_funny_taste bin \  all_symptoms_imp_mental cat \  all_symptoms_mucosal_bleed_brs bin \  all_symptoms_bloody_nose cat \  all_symptoms_rash bin \  all_symptoms_dysuria bin \  all_symptoms_nausea bin \  all_symptoms_respiratory bin \  all_symptoms_aches_pains bin \  all_symptoms_abdominal_pain bin \  all_symptoms_diarrhea bin \  all_symptoms_vomiting bin \  all_symptoms_chiils  bin \  all_symptoms_fever bin \  all_symptoms_eye_symptom bin \  all_symptoms_other cat \  ) by(cohort) saving("`figures'symptoms_by_cohort.xls", replace) missing test
table1, vars(all_meds_antifungal bin \ all_meds_supplement bin \ all_meds_allergy bin \ all_meds_expectorant cat\ all_meds_antihelmenthic bin \ all_meds_antipyretic bin \ all_meds_antimalarial bin \ all_meds_antibacterial bin \ all_meds_bronchospasm bin \ all_meds_topical  bin \ all_meds_antiamoeba bin \    all_meds_none bin \   all_meds_gerd bin \   all_meds_painmed bin \ all_meds_sulphate bin \ all_meds_cough bin \ all_meds_iv bin \ all_meds_ors bin \ all_meds_admit bin \ all_meds_othermed bin \  ) by(site) saving("`figures'meds_by_site.xls", replace) missing test

outsheet using "`data'cleanedandmegeddata.csv", replace comma names
