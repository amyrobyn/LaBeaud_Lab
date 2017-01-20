/**************************************************************
 *amy krystosik                  							  *
 *R01 results and discrepencies by strata (lab, antigen, test)*
 *lebeaud lab               				        		  *
 *last updated Jan 5, 2016  							  *
 **************************************************************/ 
capture log close 
log using "david_coinfection_severity.smcl", text replace 
set scrollbufsize 100000
set more 1

cd "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\CSVs nov29_16"

**************david's severity models*************	
use denvchikvmalariagps, clear
*outsheet using " malariamergedjan192017.csv", comma names replace

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
		replace `var'= subinstr(`var', "impaired_mental_status","imp_mental" ,.)
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


		}
			foreach var of varlist all_symptoms  { 			
			foreach symptom in "fever" "chiils" "headache" "vomiting" "diarrhea" "joint_pains" "muscle_pains" "feeling_sick" "abdominal_pain" "body_aches" "bone_pains" "pain_behind_eyes" "cough" "nausea" "loss_of_appetite" "other" "runny_nose" "dysuria" "rash" "bloody_nose" "bruises" "imp_mental" "funny_taste" "red_eyes" "earache" "sens_eyes" "sore_throat" "bleeding_gums" "bloody_vomit" "bloody_stool" "bloody_urine" "itchiness" "seizure" "anaemia" "dysphrea" "ache" "neck_pain" "dysphagia" "pain" "enanthem"{
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

replace all_symptoms= subinstr(all_symptoms, "," ,"",.)

foreach symptom in "body_rushes" "boggy_pus_discharging_swelling_on_butt" "chicken_box" "chicken_pox" "constipation" "difficulty_in_urination" "dry_lips" "ear_discharge" "eye_discharge" "_flue"  "_flu," "_flu"  "_foul_smelly_stool" "_ful_micturation" "_fungal_skin_infection" "_infra_auricular_sweling" "_jiggers" "_kidney_problem" "_measles" "_neckswelling" "_pus_ear_discharge" "_restless" "_ringworms" "_running_nose" "_sickle_cell" "_sickler" "_small_pox" "_sores_on_the_neck" "_sprained_wrist" "_strutles" "_swollen_inguinal_lymhnodes" "_tearing_eyes" "_tinea_corporis" "_urine_retention" "_whitish_eye_discharge" "_worms_in_his_stool" "body_rushes" "chicken_pox" "eye_discharge" "_tooth_" "boils" "burn"  "_worms"  "_wound" {		
				replace all_symptoms = subinstr(all_symptoms, "`symptom'", "other2",.)
			}
			
foreach symptom in "lethergy" "asthma" "chills" "jaundice" "abnormal_gums" "altms" "behavior_change" "constipation" "decreased_appetite" "edema" "halitosis" "other2" {
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

order all_symptoms_chills all_symptoms_chiils
egen all_symptoms_chills3 = rowtotal(all_symptoms_chills all_symptoms_chiils)
drop all_symptoms_chills all_symptoms_chiils
rename all_symptoms_chills3 all_symptoms_chills 


order all_symptoms_ache all_symptoms_pain
egen all_symptoms_general_pain= rowtotal(all_symptoms_ache all_symptoms_pain)
drop all_symptoms_ache all_symptoms_pain


egen symptomcount = rowtotal(all_symptoms_*)

*clean cohort
replace id_cohort = "AIC" if id_cohort =="f" 
replace id_cohort = "HCC" if id_cohort =="c" 
replace id_cohort = "AIC" if id_cohort =="aic" 
replace id_cohort = "HCC" if id_cohort =="hcc" 
drop cohort
rename id_cohort cohort

gen dmcoinf = .
replace dmcoinf = 1 if malariapositive_dum==1 & denvpcr_encode3==1

foreach var in malariapositive_dum denvpcr_encode3 dmcoinf{
	bysort  `var': sum all_symptoms_*
}

gen group = .
replace group = 0 if malariapositive_dum==0 & denvpcr_encode3 ==0
replace group = 1 if malariapositive_dum==1
replace group = 2 if denvpcr_encode3 ==1
replace group = 3 if dmcoinf==1

replace outcomehospitalized = . if outcomehospitalized ==8
bysort group: tab symptomcount outcomehospitalized , chi2      
bysort group: sum symptomcount outcomehospitalized , detail


gen selected = .
replace selected = 0 if malariapositive_dum==0 & denvpcr_encode3 ==0
replace selected = 1 if malariapositive_dum==1
replace selected = 1 if denvpcr_encode3 ==1
replace selected = 1 if dmcoinf==1

dropmiss, force
bysort group: sum  all_symptoms*

table1, vars(all_symptoms_anaemia cat \ all_symptoms_seizure cat \ all_symptoms_itchiness cat \ all_symptoms_bloody_urine cat \ all_symptoms_bloody_stool cat \ all_symptoms_bloody_vomit cat \ all_symptoms_bleeding_gums cat \ all_symptoms_sore_throat cat \ all_symptoms_sens_eyes cat \ all_symptoms_earache cat \ all_symptoms_red_eyes cat \ all_symptoms_funny_taste cat \ all_symptoms_imp_mental cat \ all_symptoms_bruises cat \ all_symptoms_bloody_nose cat \ all_symptoms_rash cat \ all_symptoms_dysuria cat \ all_symptoms_runny_nose cat \ all_symptoms_other cat \ all_symptoms_loss_of_appetite cat \ all_symptoms_nausea cat \ all_symptoms_cough cat \ all_symptoms_pain_behind_eyes cat \ all_symptoms_bone_pains cat \ all_symptoms_body_aches cat \ all_symptoms_abdominal_pain cat \ all_symptoms_feeling_sick cat \ all_symptoms_muscle_pains cat \ all_symptoms_joint_pains cat \ all_symptoms_diarrhea cat \ all_symptoms_vomiting cat \ all_symptoms_headache cat \ all_symptoms_fever cat \) by(group) saving("table1_symptoms_by_group.xls", replace ) missing test
order all_symptoms_*
graph bar    all_symptoms_halitosis - all_symptoms_general_pain, over(group)
graph export symptmsbygroup.tif,  width(4000) replace

* clean age
replace Age =. if Age <0 | Age>18
replace age = Age if age ==.
drop Age

*temperature
replace temperature = 38.5 if temperature ==385

replace scleralicterus = sclerallcterus if scleralicterus  ==.

table1 , vars(temperature conts \ age contn \ gender cat \city cat \cohort cat \ season cat \ heartrate conts \ scleralicterus bin \ splenomegaly  bin \ all_symptoms_joint_pains  bin \ all_symptoms_altms bin \) by(group) saving("table2_by_group.xls", replace ) missing test 

*severity
replace outcomehospitalized  = . if outcomehospitalized ==8
bysort group: sum numhospitalized durationhospitalized1 durationhospitalized2 durationhospitalized3 durationhospitalized4 durationhospitalized5 

rename repeatoffender repeatmalaria
bysort group: sum malariapositive_dum ovaparasites repeatmalaria outcomehospitalized durationhospitalized1 durationhospitalized2 numhospitalized 
table1 , vars( \malariapositive_dum cat \ ovaparasites bin \ outcomehospitalized cat \ durationhospitalized1 conts\ durationhospitalized2 conts\ numhospitalized cat\ ) by(group) saving("table3_severity_by_group.xls", replace ) missing test 
*repeatmalaria bin \ 
tab gametocytes group

bysort group: sum gametocytes ovaparasites repeatmalaria outcomehospitalized 
outsheet using "C:\Users\amykr\Box Sync\Amy Krystosik's Files\david coinfectin paper\denvchikvmalariagps_symptoms.csv", comma names replace

foreach result in malariaresults rdtresults bsresults{
tab `result' malariapositive_dum, m
}
tab labtests malariabloodsmear 
rename malariabloodsmear malariabloodsmeardone2
replace malariabloodsmeardone = malariabloodsmeardone2 if malariabloodsmeardone ==.  

sum malariapositive malariapositive_dum 

*logit model for severity
	
	global predictors  "group all_symptoms_anaemia all_symptoms_seizure all_symptoms_itchiness all_symptoms_bloody_urine all_symptoms_bloody_stool all_symptoms_bloody_vomit all_symptoms_bleeding_gums all_symptoms_sore_throat all_symptoms_sens_eyes all_symptoms_earache all_symptoms_red_eyes all_symptoms_funny_taste all_symptoms_imp_mental all_symptoms_bruises all_symptoms_bloody_nose all_symptoms_rash all_symptoms_dysuria all_symptoms_runny_nose all_symptoms_other all_symptoms_loss_of_appetite all_symptoms_nausea all_symptoms_cough all_symptoms_pain_behind_eyes all_symptoms_bone_pains all_symptoms_body_aches all_symptoms_abdominal_pain all_symptoms_feeling_sick all_symptoms_muscle_pains all_symptoms_joint_pains all_symptoms_diarrhea all_symptoms_vomiting all_symptoms_headache  all_symptoms_fever"
	global factors  "all_symptoms_bleeding_gums all_symptoms_loss_of_appetite all_symptoms_nausea all_symptoms_cough all_symptoms_pain_behind_eyes all_symptoms_bone_pains all_symptoms_body_aches all_symptoms_abdominal_pain all_symptoms_feeling_sick all_symptoms_muscle_pains all_symptoms_joint_pains all_symptoms_diarrhea all_symptoms_vomiting all_symptoms_headache all_symptoms_fever"
	factor outcomehospitalized ${factors}, pcf
	rotate
	pca outcomehospitalized ${predictors}
corr ${predictors}
 
logit outcomehospitalized ${factors}, or
outreg2 using severitymodel.xls, replace eform
estimates store m1, title(Model 1)

ologit numhospitalized ${factors}
estimates store m2, title(Model 2)
outreg2 using severitymodel.xls, append eform

ologit durationhospitalized1  ${factors}
estimates store m3, title(Model 3)
outreg2 using severitymodel.xls, append eform

estout m1 m2 m3, eform cells(b(star fmt(3)) se(par fmt(2)))   ///
   legend label varlabels(_cons constant)               ///
   stats(r2 df_r bic, fmt(3 0 1) label(R-sqr dfres BIC))

encode city, gen(city_s)
*two step models. assuming you are malaria or dengue positive, are you hospitalized
dropmiss, force
logit outcomehospitalized group age gender i.city_s all_symptoms_anaemia all_symptoms_feeling_sick all_symptoms_muscle_pains all_symptoms_joint_pains all_symptoms_diarrhea all_symptoms_vomiting all_symptoms_headache all_symptoms_fever all_symptoms_seizure all_symptoms_itchiness all_symptoms_bloody_urine all_symptoms_bloody_stool all_symptoms_bloody_vomit all_symptoms_bleeding_gums all_symptoms_sore_throat all_symptoms_sens_eyes all_symptoms_earache all_symptoms_red_eyes all_symptoms_funny_taste all_symptoms_imp_mental all_symptoms_bruises all_symptoms_bloody_nose all_symptoms_rash all_symptoms_dysuria all_symptoms_runny_nose all_symptoms_other all_symptoms_loss_of_appetite all_symptoms_nausea all_symptoms_cough all_symptoms_pain_behind_eyes all_symptoms_bone_pains all_symptoms_body_aches all_symptoms_abdominal_pain, or
logit selected age gender i.city_s, or
heckprob outcomehospitalized all_symptoms_anaemia all_symptoms_feeling_sick all_symptoms_muscle_pains all_symptoms_joint_pains all_symptoms_diarrhea all_symptoms_vomiting all_symptoms_headache all_symptoms_fever, select(selected= age gender i.city_s )
*mumeduclevel everhospitalised childtravel

