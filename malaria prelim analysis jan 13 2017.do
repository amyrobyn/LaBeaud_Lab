/**************************************************************
 *amy krystosik                  							  *
 *R01 results and discrepencies by strata (lab, antigen, test)*
 *lebeaud lab               				        		  *
 *last updated Jan 5, 2016  							  *
 **************************************************************/
cd "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\CSVs nov29_16"
*merge elisas with rdt and pcr from sammy
use sammy, clear
destring _all, replace
ds, has(type string) 
			foreach v of varlist `r(varlist)' { 
				replace `v' = lower(`v') 
			}
tostring id_childnumber, replace
merge 1:1 id_wide VISIT using elisas.dta
		ds, has(type string) 
			foreach v of varlist `r(varlist)' { 
				replace `v' = lower(`v') 
			}

		rename VISIT visit
		drop id_visit
		preserve
			keep if _merge ==1 
			export excel using "sammyonly", firstrow(variables) replace
		restore

		bysort dengueigm_sammy visit: tab stanforddenvigg_
		bysort dengueigm_sammy visit: tab denvigg_

		preserve
			keep if _merge ==1 |_merge ==3
			keep study_id nsi stanforddenvigg_ denvigg_ dengueigm_sammy dengue_igg_sammy visit _merge 
			export excel using "sammy_comparison", firstrow(variables) replace

			keep if _merge ==3
			
			ds, has(type string) 
			foreach v of varlist `r(varlist)' { 
				replace `v' = lower(`v') 
			}

			
			save sammy_jael, replace
		restore

		capture drop _merge
		save elisas_PCR_RDT, replace

		*******declare data as panel data***********
		encode id_wide, gen(id)
		encode visit, gen(visit_s)
		xtset id visit_s	
		save longitudinal.dta, replace

		*simple prevalence/incidence by visit
			save temp, replace
			destring id visit_s, replace
			sort id visit_s

			capture drop _merge

		*	drop visit
		*	rename visit_s visit
			capture drop dup_merged
			drop v28

		count if visit_s ==2 
		count if visit_s >4
			
			ds, has(type string) 
			foreach v of varlist `r(varlist)' { 
				replace `v' = lower(`v') 
			}

save lab, replace

use all_interviews.dta, clear
destring _all, replace
ds, has(type string) 
			foreach v of varlist `r(varlist)' { 
				replace `v' = lower(`v') 
			}
merge 1:1 id_wide visit using lab.dta
*there are some lab visits that don't have a follow up in the interview data. those can be dropped if the don't have lab data. 
	drop if stanforddenvigg_ =="" & stanfordchikvigg_ =="" & chikvpcr_ =="" & denvpcr_=="" & rdt==. & _merge==2 
	
foreach var in nsi denvpcr_ chikvpcr{
			tab `var', gen(`var'encode)
}

gen prevalentchikv = .
gen prevalentdenv = .
encode stanfordchikvigg_, gen(stanfordchikviggencode)
replace stanfordchikviggencode = stanfordchikviggencode-1
rename stanfordchikviggencode Stanford_CHIKV_IGG
_strip_labels Stanford_CHIKV_IGG

encode stanforddenvigg_, gen(stanforddenviggencode)
replace stanforddenviggencode= stanforddenviggencode-1
rename stanforddenviggencode Stanford_DENV_IGG
_strip_labels Stanford_DENV_IGG


replace prevalentdenv = 1 if  Stanford_DENV_IGG ==1 & visit =="a"
replace prevalentchikv = 1 if  Stanford_CHIKV_IGG ==1 & visit =="a"

replace id_cohort = "HCC" if id_cohort == "c"|id_cohort == "d"
		replace id_cohort = "AIC" if id_cohort == "f"|id_cohort == "m" 
		capture drop cohort
		encode id_cohort, gen(cohort)
		
bysort cohort  city: sum Stanford_DENV_IGG Stanford_CHIKV_IGG
drop _merge

replace city = "Chulaimbo" if city =="c"
replace city = "Kisumu" if city =="u"
replace city = "Ukunda" if city =="k"

save prevalent, replace

*chikv matched prevalence
	use prevalent, clear
		ds, has(type string) 
			foreach v of varlist `r(varlist)' { 
				replace `v' = lower(`v') 
			}

		keep if visit == "a" & Stanford_CHIKV_IGG!=.
		save visit_a_chikv, replace
	use prevalent, clear
		keep if visit == "b" & Stanford_CHIKV_IGG!=.
		save visit_b_chikv, replace
		merge 1:1 id_wide using visit_a_chikv
		rename _merge abvisit
		keep abvisit visit id_wide
		merge 1:1 id_wide visit using prevalent
		keep if abvisit ==3 & Stanford_CHIKV_IGG!=.
		keep studyid  id_wide site visit antigenused_ city Stanford_CHIKV_IGG cohort gender datesamplecollected_ dob  agemonths age gender  Stanford_CHIK~G Stanford_DENV~G visit datesamplecol~_ 

		export excel using "C:\Users\amykr\Box Sync/DENV CHIKV project/Personalized Datasets/Amy/CSVs nov216/prevalent_visitab_chikv", firstrow(variables) replace
	
	*denv matched prevalence
	use prevalent, clear
		keep if visit == "a" & Stanford_DENV_IGG!=.
		save visit_a_denv, replace
	use prevalent, clear
		keep if visit == "b" & Stanford_DENV_IGG!=.
		save visit_b_denv, replace

		merge 1:1 id_wide using visit_a_denv
		rename _merge abvisit
		keep abvisit id_wide visit
		
		merge 1:1 id_wide visit using prevalent		
		keep if abvisit ==3 & Stanford_DENV_IGG!=.
		keep studyid  id_wide site visit antigenused_ city Stanford_DENV_IGG cohort gender datesamplecollected_ dob agemonths  age gender  Stanford_CHIK~G Stanford_DENV~G visit datesamplecol~_
		export excel using "C:\Users\amykr\Box Sync/DENV CHIKV project/Personalized Datasets/Amy/CSVs nov216/prevalent_visitab_denv", firstrow(variables) replace
		
*denv prevlanece
use prevalent, clear

rename denvpcr_ pcr_denv
rename chikvpcr_ pcr_chikv
rename denvigg_ igg_kenya_denv
rename chikvigg_ igg_kenya_chikv
rename dengue_igg_sammy igg_sammy_denv

foreach var in igg_kenya_chikv igg_kenya_denv pcr_chikv pcr_denv igg_sammy_denv{
capture drop dos`var'
encode `var', gen(dos`var')
drop `var'
rename dos`var' `var' 
}
replace igg_kenya_chikv = . if igg_kenya_chikv<402
replace igg_kenya_chikv = . if igg_kenya_chikv==403|igg_kenya_chikv == 404|igg_kenya_chikv == 405| igg_kenya_chikv == 406
replace igg_kenya_chikv = 408 if igg_kenya_chikv==409


save  prevalent, replace

*outsheet using " mergedjan42017.csv", comma names replace

***merge with lab malaria data
replace studyid = studyid_copy if studyid =="" & studyid_copy !=""
replace studyid = studyid1 if studyid =="" & studyid1 !=""
replace studyid = studyid2 if studyid =="" & studyid2 !=""
replace studyid = studyid_ if studyid =="" & studyid_ !=""
replace studyid = duplicateid_a if studyid =="" & duplicateid_a !=""
replace studyid = followupid if studyid =="" & followupid!=""	

drop bs*
drop malaria*
drop rdt
drop species

destring _all, replace
ds, has(type string) 
			foreach v of varlist `r(varlist)' { 
				replace `v' = lower(`v') 
			}

merge 1:1 id_wide visit using "C:\Users\amykr\Google Drive\labeaud\malaria prelim data dec 29 2016\malaria"

order malaria*

destring _all, replace 
sum malaria* Stanford*
bysort city: sum malaria* Stanford*
bysort city: tab malariapositive_dum
isid id_wide visit
drop _merge
save malariatemp, replace

*malaria repeat offenders by bloodsmear
	use malariatemp, clear
		keep if visit == "a" & malariapositive_dum >0 & malariapositive_dum <.
		save visit_a_malaria, replace

	use malariatemp, clear
	tab visit malariapositive_dum
		keep if visit == "b" & malariapositive_dum >0 & malariapositive_dum <.
	tab visit malariapositive_dum
	save visit_b_malaria, replace
	
		
		merge 1:1 id_wide using visit_a_malaria
		keep if _merge==3
		rename _merge malariapos_ab
		keep malariapos_ab id_wide visit
		save abmalaria , replace
		
	use malariatemp, clear
		keep if visit == "c" & malariapositive_dum >0 & malariapositive_dum <.
		save visit_c_malaria, replace
		merge 1:1 id_wide using visit_b_malaria
		keep if _merge==3
		rename _merge malariapos_bc
		keep malariapos_bc id_wide visit
		save bcmalaria, replace
	
	use malariatemp, clear
		keep if visit == "d" & malariapositive_dum >0 & malariapositive_dum <. 
		save visit_d_malaria, replace
		merge 1:1 id_wide using visit_c_malaria
		keep if _merge==3
		rename _merge malariapos_cd
		keep malariapos_cd id_wide visit
		save cdmalaria, replace
	
	use malariatemp, clear
		keep if visit == "e" & malariapositive_dum >0 & malariapositive_dum <.
		save visit_e_malaria, replace
		merge 1:1 id_wide using visit_d_malaria
		keep if _merge==3
		rename _merge malariapos_de
		keep malariapos_de id_wide visit
		save demalaria, replace 

	use malariatemp, clear
		keep if visit == "f" & malariapositive_dum >0 & malariapositive_dum <.
		save visit_f_malaria, replace
		merge 1:1 id_wide using visit_e_malaria
		keep if _merge==3
		rename _merge malariapos_ef
		keep malariapos_ef id_wide visit
		save efmalaria, replace

	use malariatemp, clear
		keep if visit == "g" & malariapositive_dum >0 & malariapositive_dum <.
		save visit_g_malaria, replace
		merge 1:1 id_wide using visit_f_malaria
		keep if _merge==3
		rename _merge malariapos_fg
		keep malariapos_fg id_wide visit
		save fgmalaria, replace

	use malariatemp, clear
		keep if visit == "h" & malariapositive_dum >0 & malariapositive_dum <.
		save visit_h_malaria, replace
		merge 1:1 id_wide using visit_h_malaria
		keep if _merge==3
		rename _merge malariapos_gh
		keep malariapos_gh id_wide visit
		save ghmalaria, replace

use malariatemp, clear
foreach dataset in ghmalaria fgmalaria efmalaria demalaria cdmalaria bcmalaria abmalaria{
		merge 1:1 id_wide visit using "`dataset'"
		capture drop _merge
		save merged, replace
		}
		egen repeatoffender =rowtotal(malariapos_gh malariapos_fg malariapos_ef malariapos_de malariapos_cd malariapos_bc malariapos_ab)
	bysort city: sum repeatoffender if repeatoffender >1 


foreach var in datesamplecollected_ {
gen `var'1 = date(`var', "MDY" ,2050)
format %td `var'1 
drop `var'
rename `var'1 `var'
recast int `var'
}


replace interviewdate = datesamplecollected_ if interviewdate ==.


gen interviewmonth =month(interviewdate)
gen interviewyear =year(interviewdate)

gen season = . 
replace season =1 if interviewmonth >=1 & interviewmonth <=3 & season ==.
*label define 1 "hot no rain"
replace season =2 if interviewmonth >=4 & interviewmonth <=6 & season ==.
*label define 2 "long rains"
replace season =3 if interviewmonth >=7 & interviewmonth <=10 & season ==.
*label define 3 "less rain cool season"
replace season =4 if interviewmonth >=11 & interviewmonth <=12 & season ==.
*label define 4 "short rains"

*malaria positives
foreach var in interviewdate age{
sum `var'  malariapositive_dum if  malariapositive_dum==1 
sum `var'  malariapositive_dum if  malariapositive_dum==1 
}


foreach var in gender hospitalsite age city { 
tab `var'  malariapositive_dum if  malariapositive_dum==1, m
}
*repeat offenders
foreach var in interviewdate age{
sum `var'  malariapositive_dum if  malariapositive_dum==1 & repeatoffender >1
sum `var'  malariapositive_dum if  malariapositive_dum==1 & repeatoffender >1
}

foreach var in gender hospitalsite age city { 
tab `var'  malariapositive_dum if  malariapositive_dum ==1 & repeatoffender >1, m
}

tab repeatoffender malariapositive_dum
order malaria* city gender hospitalsite interviewdate* age* repeatoffender 
save mergedjan42016, replace

tab malariapositive_dum
save malariadenguemerged, replace

***
**create village and house id so we can merge with gis points
gen villageid=""
replace villageid = substr(id_wide, +1, 1)
replace villageid = "1" if villageid =="c"
replace villageid = "2" if villageid =="k"

replace villageid = "1" if villageid =="u"
replace villageid = "2" if villageid =="u"

replace villageid = "3" if villageid =="g"
replace villageid = "4" if villageid =="l"
destring villageid, replace

gen houseid2 = ""
replace houseid2 = substr(id_wide, -6, 3) if cohort ==3
replace houseid2= substr(id_wide, 3, 4) if houseid2==""
destring houseid2 , replace force
replace houseid = houseid2 if houseid==. & houseid2!=.

destring houseid, replace
gen houseidstring = string(houseid ,"%04.0f")
drop houseid
rename houseidstring  houseid
order houseid

order studyid houseid villageid

destring houseid villageid, replace force
*replace these when i get the villgae id's
save malariadenguemerged, replace

*****************merge with gis points
use xy, clear
destring _all, replace
ds, has(type string) 
			foreach v of varlist `r(varlist)' { 
				replace `v' = lower(`v') 
			}
tostring windows, replace
merge m:m villageid houseid using malariadenguemerged
drop if _merge ==1

replace city = "Chulaimbo" if city =="c"
replace city = "Kisumu" if city =="u"
replace city = "Ukunda" if city =="k"

*check with david to make sure this is true...
save denvchikvmalariagps, replace
*outsheet using "denvchikvmalariagps.csv", comma names replace

*clean symptoms
replace studyid = StudyID if studyid==""
replace studyid = Study_ID if studyid==""
replace interviewername= InterviewerName if interviewername==""
replace sex = Sex if sex ==""
drop Sex InterviewerName Study_ID StudyID clientno ClientNo parasitelevel

ds, has(type string)
	foreach var of var `r(varlist)'{
		replace `var' =trim(itrim(lower(`var')))
		rename `var', lower
	}		
	
	
**************david's severity models*************	
use denvchikvmalariagps, clear

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
			foreach symptom in "fever" "chiils" "headache" "vomiting" "diarrhea" "joint_pains" "muscle_pains" "feeling_sick" "abdominal_pain" "body_aches" "bone_pains" "pain_behind_eyes" "cough" "nausea" "loss_of_appetite" "other" "runny_nose" "dysuria" "rash" "bloody_nose" "bruises" "fits" "imp_mental" "funny_taste" "red_eyes" "earache" "sens_eyes" "short_breath" "sore_throat" "bleeding_gums" "bloody_vomit" "stiff_neck" "bloody_stool" "bloody_urine" "itchiness" "seizure" "anaemia" "dysphrea" "ache" "neck_pain" "dysphagia" "pain" "enanthem"{
						tostring `var', replace
						replace `var'=trim(itrim(lower(`var')))
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
						gen all_symptoms_`symptom'=0
						replace all_symptoms_`symptom'= 1 if strpos(all_symptoms, "`symptom'")
						
						moss strvar [if] [in] match(["]pattern["]) [ regex prefix(prefix) suffix(suffix) maximum(#) compact ]
					
					replace all_symptoms= subinstr(all_symptoms, "`symptom'", "",.)
						order all_symptoms_`symptom'
						tab all_symptoms_`symptom'
		}						

tab all_symptoms 			
drop all_symptoms 
order all_symptoms_*

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


sum  all_symptoms_halitosis all_symptoms_edema all_symptoms_decreased_appetite all_symptoms_constipation all_symptoms_behavior_change all_symptoms_altms all_symptoms_abnormal_gums all_symptoms_jaundice all_symptoms_asthma all_symptoms_lethergy all_symptoms_enanthem all_symptoms_dysphagia all_symptoms_neck_pain all_symptoms_dysphrea all_symptoms_anaemia all_symptoms_seizure all_symptoms_itchiness all_symptoms_bloody_urine all_symptoms_bloody_stool all_symptoms_stiff_neck all_symptoms_bloody_vomit all_symptoms_bleeding_gums all_symptoms_sore_throat all_symptoms_short_breath all_symptoms_sens_eyes all_symptoms_earache all_symptoms_red_eyes all_symptoms_funny_taste all_symptoms_imp_mental all_symptoms_fits all_symptoms_bruises all_symptoms_bloody_nose all_symptoms_rash all_symptoms_dysuria all_symptoms_runny_nose all_symptoms_loss_of_appetite all_symptoms_nausea all_symptoms_cough all_symptoms_pain_behind_eyes all_symptoms_bone_pains all_symptoms_body_aches all_symptoms_abdominal_pain all_symptoms_feeling_sick all_symptoms_muscle_pains all_symptoms_joint_pains all_symptoms_diarrhea all_symptoms_vomiting all_symptoms_headache all_symptoms_fever

egen symptomcount = rowtotal(all_symptoms_*)

*clean cohort
replace id_cohort = "AIC" if id_cohort =="f" 
replace id_cohort = "HCC" if id_cohort =="c" 
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

table1, vars(all_symptoms_anaemia cat \ all_symptoms_seizure cat \ all_symptoms_itchiness cat \ all_symptoms_bloody_urine cat \ all_symptoms_bloody_stool cat \ all_symptoms_stiff_neck cat \ all_symptoms_bloody_vomit cat \ all_symptoms_bleeding_gums cat \ all_symptoms_sore_throat cat \ all_symptoms_short_breath cat \ all_symptoms_sens_eyes cat \ all_symptoms_earache cat \ all_symptoms_red_eyes cat \ all_symptoms_funny_taste cat \ all_symptoms_imp_mental cat \ all_symptoms_fits cat \ all_symptoms_bruises cat \ all_symptoms_bloody_nose cat \ all_symptoms_rash cat \ all_symptoms_dysuria cat \ all_symptoms_runny_nose cat \ all_symptoms_other cat \ all_symptoms_loss_of_appetite cat \ all_symptoms_nausea cat \ all_symptoms_cough cat \ all_symptoms_pain_behind_eyes cat \ all_symptoms_bone_pains cat \ all_symptoms_body_aches cat \ all_symptoms_abdominal_pain cat \ all_symptoms_feeling_sick cat \ all_symptoms_muscle_pains cat \ all_symptoms_joint_pains cat \ all_symptoms_diarrhea cat \ all_symptoms_vomiting cat \ all_symptoms_headache cat \ all_symptoms_chiils cat \ all_symptoms_fever cat \) by(group) saving("table1_symptoms_by_group.xls", replace ) missing test

graph bar   all_symptoms_pain - all_symptoms_bloody_stool, over(group)
graph export symptmsbygroup.tif,  width(4000) replace

* clean age
replace Age =. if Age <0 | Age>18
replace age = Age if age ==.
drop Age

*temperature
replace temperature = 38.5 if temperature ==385

table1 , vars(temperature conts \ age contn \ gender cat \city cat \cohort cat \ season cat \) by(group) saving("table2_by_group.xls", replace ) missing test 

*severity
replace outcomehospitalized  = . if outcomehospitalized ==8
bysort group: sum numhospitalized durationhospitalized1 durationhospitalized2 durationhospitalized3 durationhospitalized4 durationhospitalized5 

rename repeatoffender repeatmalaria
bysort group: sum malariapositive_dum ovaparasites repeatmalaria outcomehospitalized durationhospitalized1 durationhospitalized2 numhospitalized 
table1 , vars( \malariapositive_dum cat \ ovaparasites bin \ outcomehospitalized cat \ durationhospitalized1 conts\ durationhospitalized2 conts\ numhospitalized cat\ ) by(group) saving("table3_severity_by_group.xls", replace ) missing test 
*repeatmalaria bin \ 
tab gametocytes group

bysort group: sum gametocytes ovaparasites repeatmalaria outcomehospitalized 

*logit model for severity
	
	global predictors  "group all_symptoms_anaemia all_symptoms_seizure all_symptoms_itchiness all_symptoms_bloody_urine all_symptoms_bloody_stool all_symptoms_stiff_neck all_symptoms_bloody_vomit all_symptoms_bleeding_gums all_symptoms_sore_throat all_symptoms_short_breath all_symptoms_sens_eyes all_symptoms_earache all_symptoms_red_eyes all_symptoms_funny_taste all_symptoms_imp_mental all_symptoms_fits all_symptoms_bruises all_symptoms_bloody_nose all_symptoms_rash all_symptoms_dysuria all_symptoms_runny_nose all_symptoms_other all_symptoms_loss_of_appetite all_symptoms_nausea all_symptoms_cough all_symptoms_pain_behind_eyes all_symptoms_bone_pains all_symptoms_body_aches all_symptoms_abdominal_pain all_symptoms_feeling_sick all_symptoms_muscle_pains all_symptoms_joint_pains all_symptoms_diarrhea all_symptoms_vomiting all_symptoms_headache all_symptoms_chiils all_symptoms_fever"
	global factors  "all_symptoms_bleeding_gums all_symptoms_loss_of_appetite all_symptoms_nausea all_symptoms_cough all_symptoms_pain_behind_eyes all_symptoms_bone_pains all_symptoms_body_aches all_symptoms_abdominal_pain all_symptoms_feeling_sick all_symptoms_muscle_pains all_symptoms_joint_pains all_symptoms_diarrhea all_symptoms_vomiting all_symptoms_headache all_symptoms_chiils all_symptoms_fever"
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
logit outcomehospitalized group age gender i.city_s all_symptoms_anaemia all_symptoms_feeling_sick all_symptoms_muscle_pains all_symptoms_joint_pains all_symptoms_diarrhea all_symptoms_vomiting all_symptoms_headache all_symptoms_chiils all_symptoms_fever all_symptoms_seizures all_symptoms_itchiness all_symptoms_bloody_urine all_symptoms_bloody_stool all_symptoms_stiff_neck all_symptoms_bloody_vomit all_symptoms_bleeding_gums all_symptoms_sore_throat all_symptoms_short_breath all_symptoms_sens_eyes all_symptoms_earache all_symptoms_red_eyes all_symptoms_funny_taste all_symptoms_imp_mental all_symptoms_fits all_symptoms_bruises all_symptoms_bloody_nose all_symptoms_rash all_symptoms_dysuria all_symptoms_runny_nose all_symptoms_other all_symptoms_loss_of_appetite all_symptoms_nausea all_symptoms_cough all_symptoms_pain_behind_eyes all_symptoms_bone_pains all_symptoms_body_aches all_symptoms_abdominal_pain, or
logit selected age gender i.city_s, or
heckprob outcomehospitalized all_symptoms_anaemia all_symptoms_feeling_sick all_symptoms_muscle_pains all_symptoms_joint_pains all_symptoms_diarrhea all_symptoms_vomiting all_symptoms_headache all_symptoms_chiils all_symptoms_fever, select(selected= age gender i.city_s )
*mumeduclevel everhospitalised childtravel
