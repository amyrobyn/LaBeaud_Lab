/************************************************************** *amy krystosik                  							  * *R01 results and discrepencies by strata (lab, antigen, test)* *lebeaud lab               				        		  * *last updated Jan 5, 2016  							  * **************************************************************/
cd "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\CSVs nov29_16"
*merge elisas with rdt and pcr from sammy
use sammy, clearmerge 1:1 id_wide VISIT using elisas.dta
		rename VISIT visit
		drop id_visit		preserve			keep if _merge ==1 			export excel using "sammyonly", firstrow(variables) replace		restore
		bysort dengueigm_sammy visit: tab stanforddenvigg_		bysort dengueigm_sammy visit: tab denvigg_		preserve			keep if _merge ==1 |_merge ==3			keep study_id nsi stanforddenvigg_ denvigg_ dengueigm_sammy dengue_igg_sammy visit _merge 			export excel using "sammy_comparison", firstrow(variables) replace			keep if _merge ==3			save sammy_jael, replace		restore
		capture drop _merge		save elisas_PCR_RDT, replace		*******declare data as panel data***********		encode id_wide, gen(id)		encode visit, gen(visit_s)
		xtset id visit_s			save longitudinal.dta, replace
		*simple prevalence/incidence by visit			save temp, replace			destring id visit_s, replace			sort id visit_s			capture drop _merge		*	drop visit		*	rename visit_s visit			capture drop dup_merged			drop v28

		count if visit_s ==2 
		count if visit_s >4

save lab, replace

use all_interviews.dta, clear
merge 1:1 id_wide visit using lab.dta
*there are some lab visits that don't have a follow up in the interview data. those can be dropped if the don't have lab data. 
	drop if stanforddenvigg_ =="" & stanfordchikvigg_ =="" & malariabloodsmear ==. & chikvpcr_ =="" & denvpcr_=="" & rdt==. & malariaresults ==. & bsresults==. & rdtresults ==. & _merge==2 
	
foreach var in nsi denvpcr_ chikvpcr{			tab `var', gen(`var'encode)}gen prevalentchikv = .gen prevalentdenv = .
encode stanfordchikvigg_, gen(stanfordchikviggencode)
replace stanfordchikviggencode = stanfordchikviggencode-1rename stanfordchikviggencode Stanford_CHIKV_IGG
_strip_labels Stanford_CHIKV_IGG
encode stanforddenvigg_, gen(stanforddenviggencode)replace stanforddenviggencode= stanforddenviggencode-1
rename stanforddenviggencode Stanford_DENV_IGG
_strip_labels Stanford_DENV_IGG

replace prevalentdenv = 1 if  Stanford_DENV_IGG ==1 & visit =="a"replace prevalentchikv = 1 if  Stanford_CHIKV_IGG ==1 & visit =="a"replace id_cohort = "HCC" if id_cohort == "c"|id_cohort == "d"		replace id_cohort = "AIC" if id_cohort == "f"|id_cohort == "m" 		capture drop cohort		encode id_cohort, gen(cohort)		bysort cohort  city: sum Stanford_DENV_IGG Stanford_CHIKV_IGG
drop _merge

replace city = "Chulaimbo" if city =="c"
replace city = "Kisumu" if city =="u"
replace city = "Ukunda" if city =="k"
save prevalent, replace
*chikv matched prevalence	use prevalent, clear		keep if visit == "a" & Stanford_CHIKV_IGG!=.
		save visit_a_chikv, replace	use prevalent, clear		keep if visit == "b" & Stanford_CHIKV_IGG!=.		save visit_b_chikv, replace		merge 1:1 id_wide using visit_a_chikv		rename _merge abvisit		keep abvisit visit id_wide		merge 1:1 id_wide visit using prevalent		keep if abvisit ==3 & Stanford_CHIKV_IGG!=.
		keep studyid  id_wide site visit antigenused_ city Stanford_CHIKV_IGG cohort gender datesamplecollected_ dob  agemonths age gender  Stanford_CHIK~G Stanford_DENV~G visit datesamplecol~_ 		export excel using "C:\Users\amykr\Box Sync/DENV CHIKV project/Personalized Datasets/Amy/CSVs nov216/prevalent_visitab_chikv", firstrow(variables) replace		*denv matched prevalence	use prevalent, clear		keep if visit == "a" & Stanford_DENV_IGG!=.		save visit_a_denv, replace	use prevalent, clear		keep if visit == "b" & Stanford_DENV_IGG!=.		save visit_b_denv, replace
		merge 1:1 id_wide using visit_a_denv
		rename _merge abvisit		keep abvisit id_wide visit		
		merge 1:1 id_wide visit using prevalent		
		keep if abvisit ==3 & Stanford_DENV_IGG!=.		keep studyid  id_wide site visit antigenused_ city Stanford_DENV_IGG cohort gender datesamplecollected_ dob agemonths  age gender  Stanford_CHIK~G Stanford_DENV~G visit datesamplecol~_		export excel using "C:\Users\amykr\Box Sync/DENV CHIKV project/Personalized Datasets/Amy/CSVs nov216/prevalent_visitab_denv", firstrow(variables) replace		*denv prevlaneceuse prevalent, clear

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

order malaria*

destring malariabloodsmear  malariapastmedhist, replace
encode pos_neg, gen(malariapos)
encode pos_neg1, gen(malariapos2)
replace malariapos = malariapos-1
replace malariapos2=malariapos2-1
_strip_labels malariapos malariapos2
drop pos_neg*

label values malariaresults malariaresults
label define malariaresult 0 "negative" 1 "+" 2 "++" 3 "+++" 4 "++++"
 
sum malaria* Stanford*
tab malariaresults 

bysort city: sum malaria* Stanford*
bysort city: tab malariaresults 
isid id_wide visit
save malariatemp, replace

*malaria repeat offenders by bloodsmear
	use malariatemp, clear
		keep if visit == "a" & malariaresult >0 & malariaresult <.
		save visit_a_malaria, replace

	use malariatemp, clear
	tab visit malariaresult
		keep if visit == "b" & malariaresult >0 & malariaresult <.
	tab visit malariaresult
	save visit_b_malaria, replace
		merge 1:1 id_wide using visit_a_malaria
		keep if _merge==3
		rename _merge malariapos_ab
		keep malariapos_ab id_wide visit
		save abmalaria , replace
		
	use malariatemp, clear
		keep if visit == "c" & malariaresult >0 & malariaresult <.
		save visit_c_malaria, replace
		merge 1:1 id_wide using visit_b_malaria
		keep if _merge==3
		rename _merge malariapos_bc
		keep malariapos_bc id_wide visit
		save bcmalaria, replace
	
	use malariatemp, clear
		keep if visit == "d" & malariaresult >0 & malariaresult <. 
		save visit_d_malaria, replace
		merge 1:1 id_wide using visit_c_malaria
		keep if _merge==3
		rename _merge malariapos_cd
		keep malariapos_cd id_wide visit
		save cdmalaria, replace
	
	use malariatemp, clear
		keep if visit == "e" & malariaresult >0 & malariaresult <.
		save visit_e_malaria, replace
		merge 1:1 id_wide using visit_d_malaria
		keep if _merge==3
		rename _merge malariapos_de
		keep malariapos_de id_wide visit
		save demalaria, replace 

	use malariatemp, clear
		keep if visit == "f" & malariaresult >0 & malariaresult <.
		save visit_f_malaria, replace
		merge 1:1 id_wide using visit_e_malaria
		keep if _merge==3
		rename _merge malariapos_ef
		keep malariapos_ef id_wide visit
		save efmalaria, replace

	use malariatemp, clear
		keep if visit == "g" & malariaresult >0 & malariaresult <.
		save visit_g_malaria, replace
		merge 1:1 id_wide using visit_f_malaria
		keep if _merge==3
		rename _merge malariapos_fg
		keep malariapos_fg id_wide visit
		save fgmalaria, replace

	use malariatemp, clear
		keep if visit == "h" & malariaresult >0 & malariaresult <.
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
sum `var'  malariabloodsmear if  malariabloodsmear==1 
sum `var'  malariabloodsmear if  malariabloodsmear==1 
}


foreach var in gender hospitalsite age species city { 
tab `var'  malariabloodsmear if  malariabloodsmear ==1, m
}
*repeat offenders
foreach var in interviewdate age{
sum `var'  malariabloodsmear if  malariabloodsmear==1 & repeatoffender >1
sum `var'  malariabloodsmear if  malariabloodsmear==1 & repeatoffender >1
}

foreach var in gender hospitalsite age species city { 
tab `var'  malariabloodsmear if  malariabloodsmear ==1 & repeatoffender >1, m
}

tab repeatoffender malariabloodsmear
order malaria* species city gender hospitalsite interviewdate* age* repeatoffender 
save mergedjan42016, replace

*outsheet using " mergedjan42017.csv", comma names replace

***merge with lab malaria data
replace studyid = studyid_copy if studyid =="" & studyid_copy !=""
replace studyid = studyid1 if studyid =="" & studyid1 !=""
replace studyid = studyid2 if studyid =="" & studyid2 !=""
replace studyid = studyid_ if studyid =="" & studyid_ !=""
replace studyid = duplicateid_a if studyid =="" & duplicateid_a !=""
replace studyid = followupid if studyid =="" & followupid!=""	

merge 1:1 id_wide visit using "C:\Users\amykr\Google Drive\labeaud\malaria prelim data dec 29 2016\malaria"

*clean and merge malaria species
replace parasitelevel= subinstr(parasitelevel, "pos", "",.)
gen species2 =""
gen species3 =""
gen species4 =""
replace species2 = "pf" if strpos(parasitelevel, "pf")
replace species3 = "pm" if strpos(parasitelevel, "pm")
replace species4 = "po" if strpos(parasitelevel, "po")
egen speciesall = concat(species2 species3 species4)
replace species = speciesall if species==""
drop speciesall species2 species3 species4
replace species = "pf/pm" if species =="pfpm"
replace species = "pf/po" if species =="pfpo"

*clean and merge malaria results
gen malariaresults2=""

replace malariaresults2 = "0" if strpos(parasitelevel, "neg")

replace malariaresults2 = "1" if strpos(parasitelevel, "1")
replace malariaresults2 = "1" if strpos(parasitelevel, "+")

replace malariaresults2 = "2" if strpos(parasitelevel, "2")
replace malariaresults2 = "2" if strpos(parasitelevel, "++")

replace malariaresults2 = "3" if strpos(parasitelevel, "3")
replace malariaresults2 = "3" if strpos(parasitelevel, "+++")

replace malariaresults2 = "4" if strpos(parasitelevel, "4")
replace malariaresults2 = "4" if strpos(parasitelevel, "++++")
 
destring malariaresults2 , replace
replace malariaresults = malariaresults2 if malariaresults==.
drop malariaresults2

tab malariaresults species, m

label values malariaresults malariaresults 
label define malariaresults 0 "negative" 1 "+" 2 "++" 3 "+++" 4 "++++" 5 "+++++"

rename pos_neg malariapos_neg
rename pos_neg1 malariapos_neg1

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
drop _merge
tostring houseid , replace
save malariadenguemerged, replace

*****************merge with gis points
use xy, clear
merge 1:m villageid houseid using malariadenguemerged
drop if _merge ==1

replace city = "Chulaimbo" if city =="c"
replace city = "Kisumu" if city =="u"
replace city = "Ukunda" if city =="k"

*check with david to make sure this is true...
replace malariaresults=bsresults if malariaresults==.
drop bsresults 
save denvchikvmalariagps, replace
outsheet using "denvchikvmalariagps.csv", comma names replace

*clean symptoms
replace studyid = StudyID if studyid==""
replace studyid = Study_ID if studyid==""
replace interviewername= InterviewerName if interviewername==""
replace sex = Sex if sex ==""
drop Sex InterviewerName Study_ID StudyID
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
 egen all_symtoms = concat(symptms othersymptms fvrsymptms otherfvrsymptms) 

		foreach var of varlist all_symtoms { 			
		replace `var'= subinstr(`var', " ", "_",.)
		}

		foreach var of varlist all_symtoms { 			
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
		}
			foreach var of varlist all_symtoms { 			
			foreach symptom in "fever" "chiils" "headache" "vomiting" "diarrhea" "joint_pains" "muscle_pains" "feeling_sick" "abdominal_pain" "body_aches" "bone_pains" "pain_behind_eyes" "cough" "nausea" "loss_of_appetite" "other" "runny_nose" "dysuria" "rash" "bloody_nose" "bruises" "fits" "imp_mental" "funny_taste" "red_eyes" "earache" "sens_eyes" "short_breath" "sore_throat" "bleeding_gums" "bloody_vomit" "stiff_neck" "bloody_stool" "bloody_urine" "itchiness" "seizures" "anaemia"{
						tostring `var', replace
						replace `var'=trim(itrim(lower(`var')))
						gen `var'_`symptom'=0
						replace `var'_`symptom'= 1 if strpos(`var', "`symptom'")
						replace `var'= subinstr(`var', "`symptom'", "",.)
						order `var'_`symptom'
						tab `var'_`symptom'
						}
			}	
drop symptms othersymptms fvrsymptms otherfvrsymptms all_symtoms 

*clean cohort
replace id_cohort = "AIC" if id_cohort =="f" 
replace id_cohort = "HCC" if id_cohort =="c" 
drop cohort
rename id_cohort cohort

gen dmcoinf = .
replace dmcoinf = 1 if malariaresults==1 & denvpcr_encode3==1

foreach var in malariaresults denvpcr_encode3 dmcoinf{
	bysort  `var': sum all_symtoms_anaemia - all_symtoms_fever
}

gen group = .
replace group = 0 if malariaresults==0 & denvpcr_encode3 ==0
replace group = 1 if malariaresults==1
replace group = 2 if denvpcr_encode3 ==1
replace group = 3 if dmcoinf==1

gen selected = .
replace selected = 0 if malariaresults==0 & denvpcr_encode3 ==0
replace selected = 1 if malariaresults==1
replace selected = 1 if denvpcr_encode3 ==1
replace selected = 1 if dmcoinf==1

dropmiss, force
bysort group: sum  all_symtoms*
sum *fever *chiils *headache *vomiting *diarrhea *joint_pains* *muscle_pains *feeling_sick *abdominal_pain *body_aches 

table1, vars(all_symtoms_anaemia cat \ all_symtoms_seizures cat \ all_symtoms_itchiness cat \ all_symtoms_bloody_urine cat \ all_symtoms_bloody_stool cat \ all_symtoms_stiff_neck cat \ all_symtoms_bloody_vomit cat \ all_symtoms_bleeding_gums cat \ all_symtoms_sore_throat cat \ all_symtoms_short_breath cat \ all_symtoms_sens_eyes cat \ all_symtoms_earache cat \ all_symtoms_red_eyes cat \ all_symtoms_funny_taste cat \ all_symtoms_imp_mental cat \ all_symtoms_fits cat \ all_symtoms_bruises cat \ all_symtoms_bloody_nose cat \ all_symtoms_rash cat \ all_symtoms_dysuria cat \ all_symtoms_runny_nose cat \ all_symtoms_other cat \ all_symtoms_loss_of_appetite cat \ all_symtoms_nausea cat \ all_symtoms_cough cat \ all_symtoms_pain_behind_eyes cat \ all_symtoms_bone_pains cat \ all_symtoms_body_aches cat \ all_symtoms_abdominal_pain cat \ all_symtoms_feeling_sick cat \ all_symtoms_muscle_pains cat \ all_symtoms_joint_pains cat \ all_symtoms_diarrhea cat \ all_symtoms_vomiting cat \ all_symtoms_headache cat \ all_symtoms_chiils cat \ all_symtoms_fever cat \) by(group) saving("table1_symptoms_by_group.xls", replace ) missing test

graph bar  all_symtoms*, over(group)
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
encode species, gen(species_s)
bysort group: sum malariaresults ovaparasites repeatmalaria species_s outcomehospitalized durationhospitalized1 durationhospitalized2 numhospitalized 
table1 , vars( \malariaresults cat \ ovaparasites bin \ species_s cat \ outcomehospitalized cat \ durationhospitalized1 conts\ durationhospitalized2 conts\ numhospitalized cat\ ) by(group) saving("table3_severity_by_group.xls", replace ) missing test 
*repeatmalaria bin \ 
tab gametocytes group
tab species group 

bysort group: sum gametocytes ovaparasites repeatmalaria species outcomehospitalized 

*logit model for severity
local predictors group all_symtoms_anaemia all_symtoms_seizures all_symtoms_itchiness all_symtoms_bloody_urine all_symtoms_bloody_stool all_symtoms_stiff_neck all_symtoms_bloody_vomit all_symtoms_bleeding_gums all_symtoms_sore_throat all_symtoms_short_breath all_symtoms_sens_eyes all_symtoms_earache all_symtoms_red_eyes all_symtoms_funny_taste all_symtoms_imp_mental all_symtoms_fits all_symtoms_bruises all_symtoms_bloody_nose all_symtoms_rash all_symtoms_dysuria all_symtoms_runny_nose all_symtoms_other all_symtoms_loss_of_appetite all_symtoms_nausea all_symtoms_cough all_symtoms_pain_behind_eyes all_symtoms_bone_pains all_symtoms_body_aches all_symtoms_abdominal_pain all_symtoms_feeling_sick all_symtoms_muscle_pains all_symtoms_joint_pains all_symtoms_diarrhea all_symtoms_vomiting all_symtoms_headache all_symtoms_chiils all_symtoms_fever

logit outcomehospitalized `predictors', or
outreg2 using severitymodel.xls, replace eform
estimates store m1, title(Model 1)

ologit numhospitalized `predictors'
estimates store m2, title(Model 2)
outreg2 using severitymodel.xls, append eform

ologit durationhospitalized1  `predictors'
estimates store m3, title(Model 3)
outreg2 using severitymodel.xls, append eform

estout m1 m2 m3, eform cells(b(star fmt(3)) se(par fmt(2)))   ///
   legend label varlabels(_cons constant)               ///
   stats(r2 df_r bic, fmt(3 0 1) label(R-sqr dfres BIC))

encode city, gen(city_s)
*two step models. assuming you are malaria or dengue positive, are you hospitalized
dropmiss, force
logit outcomehospitalized group age gender i.city_s species_s all_symtoms_anaemia all_symtoms_feeling_sick all_symtoms_muscle_pains all_symtoms_joint_pains all_symtoms_diarrhea all_symtoms_vomiting all_symtoms_headache all_symtoms_chiils all_symtoms_fever all_symtoms_seizures all_symtoms_itchiness all_symtoms_bloody_urine all_symtoms_bloody_stool all_symtoms_stiff_neck all_symtoms_bloody_vomit all_symtoms_bleeding_gums all_symtoms_sore_throat all_symtoms_short_breath all_symtoms_sens_eyes all_symtoms_earache all_symtoms_red_eyes all_symtoms_funny_taste all_symtoms_imp_mental all_symtoms_fits all_symtoms_bruises all_symtoms_bloody_nose all_symtoms_rash all_symtoms_dysuria all_symtoms_runny_nose all_symtoms_other all_symtoms_loss_of_appetite all_symtoms_nausea all_symtoms_cough all_symtoms_pain_behind_eyes all_symtoms_bone_pains all_symtoms_body_aches all_symtoms_abdominal_pain, or
logit selected age gender i.city_s, or
heckprob outcomehospitalized species_s all_symtoms_anaemia all_symtoms_feeling_sick all_symtoms_muscle_pains all_symtoms_joint_pains all_symtoms_diarrhea all_symtoms_vomiting all_symtoms_headache all_symtoms_chiils all_symtoms_fever, select(selected= age gender i.city_s )
*mumeduclevel everhospitalised childtravel
