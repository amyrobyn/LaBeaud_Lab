/********************************************************************
 *amy krystosik                  							  		*
 *david coinfection by denv pcr and malaria microscopy, AIC visit B	*
 *lebeaud lab               				        		  		*
 *last updated feb 23, 2017  							  			*
 ********************************************************************/ 
capture log close 
log using "david_coinfection_severity_normalpop.smcl", text replace 
set scrollbufsize 100000
set more 1

capture log close 
log using "R01_nov2_16.smcl", text replace 
set scrollbufsize 100000
set more 1
cd "C:\Users\amykr\Box Sync\Amy Krystosik's Files\david coinfectin paper"
use "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\interviewdata\all_interviews", clear
*add in the pcr data from box and from googledoc. 
bysort id_wide visit: gen dup = _n
drop id_childnumber 
merge 1:1 id_wide visit using "C:\Users\amykr\Box Sync\Amy Krystosik's Files\david coinfectin paper\allpcr"
		*replace denvpcrresults_dum = 1 if denvpcrresults_dum>0 & denvpcrresults_dum<.
		save elisas_PCR_RDT, replace	
		rename _merge interview_elisa_pcr_match


merge 1:1 id_wide visit using "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\malaria prelim data dec 29 2016\malaria"
replace cohort = id_cohort if cohort ==""
tab visit cohort, m

*****************everyone except those who have visit c and no fever 
tab visit
drop if strpos(visit, "c") 
keep if visit == "b" & cohort =="f"
rename *temp* *childtemp*
drop if childtemp >=38
sum chikvpcrresults_dum denvpcrresults_dum malariapositive_dum

replace heartrate = heart_rate if heartrate ==.
drop heart_rate 
rename heartrate heart_rate 

*replace childheight = child_height if childheight ==.
*drop child_height 
*replace childweight = child_weight if childweight ==.
*drop child_weight 

*ask david about these
foreach var in heart_rate systolicbp  diastolicbp  pulseoximetry childtemp childweight childheight headcircum resprate hb hemoglobin { 
	replace `var'= . if `var'==999
	replace `var'= . if `var'==99
	replace `var'= . if `var'==98
	replace `var'= . if `var'==0

}
replace systolicbp = systolicbp/10 if systolicbp >200
replace childtemp = childtemp/10 if childtemp >50
replace childheight = childheight/10 if childheight >500
replace childheight = childheight *10 if childheight <20
replace childweight=childweight/10 if childweight>200


replace hb = hemoglobin if hb ==. 
replace hb = hb_result if hb ==.
drop hb_result hemoglobin  
sum heart_rate systolicbp  diastolicbp  pulseoximetry childtemp childweight childheight  resprate hb, d

gen sexlabel = "sex"
gen labelage = "age"
*replace childage  = age_calc if childage ==.
*replace childage = round(childage)
tab age, m
egen agegender = concat(labelage age sexlabel gender)
tab agegender
drop if strpos(agegender, ".")

levelsof agegender, local(levels) 
levelsof agegender, local(levels) 

replace headcircum  = head_circumference if headcircum  ==.
drop head_circumference 

sum heart_rate systolicbp  diastolicbp  childtemp resprate
order age gender heart_rate systolicbp  diastolicbp  childtemp resprate  pulseoximetry  childheight childweight headcircum  diagnosis_all meds labtests_all pcpdrugs hivmeds hivpastmedhist hivtest hivresult  
outsheet using "davidtoreview_vitalsranges.csv" if heart_rate >160 | heart_rate <80| resprate<20|resprate>50 |systolicbp <39 | systolicbp >131 |  diastolicbp  <16 | diastolicbp  >83 | childtemp <35|childtemp >38 | pulseoximetry  >100 | childheight <45 | childheight >200 |childweight <1|childweight >100 |headcircum  <30 |headcircum  >54 , replace comma names 

*ranges for each indicator to remove and to review by age

/*heart_rate - 
systolicbp  - 
diastolicbp  - 
childtemp - 
resprate - 
*/

foreach l of local levels {
	foreach var in heart_rate systolicbp  diastolicbp  pulseoximetry childtemp resprate{ 
		egen sd`var'`l' = sd(`var')  if agegender == "`l'"
		egen median`var'`l' = median(`var') if agegender == "`l'"
	}
}
keep sd* median* age gender agegender 
collapse (mean)  sd* median* , by(agegender)
save normal_population_aic_b, replace
use "C:\Users\amykr\Box Sync\Amy Krystosik's Files\david coinfectin paper\our_population"
drop if strpos(agegender, ".")
keep agegender
merge m:1 agegender using "C:\Users\amykr\Box Sync\Amy Krystosik's Files\david coinfectin paper\normal_population_aic_b"
drop _merge
duplicates drop 
save normal_population_aic_b, replace
