/********************************************************************
 *amy krystosik                  							  		*
 *priyanka malaria microscopy, AIC visit A	*
 *lebeaud lab               				        		  		*
 *last updated feb 21, 2017  							  			*
 ********************************************************************/ 
capture log close 
log using "priyankamalariaaicvisita.smcl", text replace 
set scrollbufsize 100000
set more 1
cd "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\CSVs nov29_16"

use priyankamalariaaicvisita, clear

*all_symptoms* malariapositive_dum malariapositive_dum2 group group2 outcomehospitalized species malariapositive gametocytes1 gametocytes2 dob gender age childheight childweight everhospitalised reasonhospitalized1 othhospitalname1 reasonhospitalized2 durationhospitalized1 currentsick numdaysonset temperature headcircum heart_rate resprate  headneckexam chestexam heartexam abdomenexam nodeexam jointexam jointlocation skinexam othskinexam cliniciannotesskin neuroexam tourniquettest hb othlabtests othlabresults primarydiag othprimarydiag primarybacterialdx secondarydiag othsecondarydiag healthimpacts othhealthimpacts medsprescribe othmedsprescribe outcome outcomehospitalized childvaccination yellowfever encephalitis pastmedhist othpastmedhist currenttakingmeds currentmeds othcurrentmeds cliniciannoteshneck abdlocation othnodeexam cliniciannotesnode urinalysisresult stoolovacyst othoutcome malariapastmedhist pneumoniapastmedhist paracetamolcurrentmeds cliniciannoteschest cliniciannotesheart cliniciannotesjoint cliniciannotesneuro hivresult othstoolovacyst sicklecellresult secondarybacterialdx city  

local demograhpics dob date_of_birth  gender age  childoccupation educlevel otheduclevel mumeduclevel numsiblings childtravel wheretravel nightaway outdooractivity mosquitocoil sleepbednet mosquitobites everhospitalised reasonhospitalized1 reasonhospitalized2 counthosp othmumeduclevel othchildoccupation numhospitalized 
local symptoms symptomcount all_symptoms*
local severity outcome outcomehospitalized datehospit*alized 
local onset stageofdisease othstageofdisease stageofdiseasecoded  numdaysonset date_symptom_onset 
local medical_history childcontact eversurgery reasonsurgery datesurgery gestational breastfed durationbfed othdurationbfed childvaccination yellowfever encephalitis pastmedhist othpastmedhist everpregnant hivpastmedhist 
local meds currenttakingmeds currentmeds meds  othcurrentmeds hivmeds pcpdrugs antibiotic antimalarial antiparasitic ibuprofen paracetamol 
local exams hivtest cliniciannoteshneck abdlocation othnodeexam cliniciannotesnode urinalysisresult stoolovacyst othoutcome datehospitalized2 hospitalname2 durationhospitalized2 reasonhospitalized3 datehospitalized3 hospitalname3 durationhospitalized3 reasonhospitalized4 datehospitalized4 hospitalname4 durationhospitalized4 reasonhospitalized5 datehospitalized5 hospitalname5 durationhospitalized5 malariapastmedhist pneumoniapastmedhist paracetamolcurrentmeds redeyes bleedingums  adbtenderness hepatomegaly deviceid setofpast_med_historypast_hospit dateyellowfever cliniciannoteschest cliniciannotesheart cliniciannotesjoint cliniciannotesneuro hivresult othstoolovacyst sicklecellresult secondarybacterialdx   
local vitals calculated_fever head_circumference resp_rate systolic_pressure diastolic_pressure pulse_ox can_visual_acuity visual_acuity_left visual_acuity_right head_neck_exam chest_examchest heart_examheart abd_abdomen node_examnodes jointsjoints jointsjoint_location skin_examskin neuro_examneuro tourniquet_test mal_test malaria_results labslabs_ordered primary_diagnosis secondary_diagnosis health_impacts health_impacts_other meds_prescribed meds_prescribed_other nearestpoint spp1 countul1 gametocytes1 treatment1 spp2 countul2 treatment2 temperature fevertemp  zheart_rate zsystolicbp zdiastolicbp zpulseoximetry ztemperature zchildweight zchildheight zresprate headcircum heart_rate resprate systolicbp diastolicbp pulseoximetry performvisualacuity leftvisualacuity rightvisualacuity headneckexam chestexam heartexam abdomenexam cliniciannotesabd nodeexam jointexam jointlocation skinexam othskinexam cliniciannotesskin neuroexam tourniquettest maltestordered bsresults rdtresults labtests hb othlabtests othlabresults primarydiag othprimarydiag primarybacterialdx secondarydiag othsecondarydiag healthimpacts othhealthimpacts medsprescribe othmedsprescribe 
local infection_groups chikvpcrresults_dum denvpcrresults_dum  malariapositive malariapositive_dum malariapositive_dum2  species_cat  pf200 pm200 po200 pv200 ni200 none200 parasitelevel   group group2  

order `infection_groups' `severity' `demograhpics' `symptoms' `onset'  `medical_history'  `meds' `exams' `vitals'  
outsheet `infection_groups' `severity' `demograhpics' `symptoms' `onset'  `medical_history'  `meds' `exams' `vitals'  using priyanka_aic_visita.xls, replace

foreach group in `infection_groups' `severity' `demograhpics' `symptoms' `onset'  `medical_history'  `meds' `exams' `vitals'  {
	sum `group'
}

gen severemalaria = .
replace severemalaria = 0 if malariapositive_dum == 1 & outcomehospitalized ==0
replace severemalaria = 1 if malariapositive_dum == 1 & outcomehospitalized ==1
tab severemalaria 

bysort age malariapositive_dum outcomehospitalized: sum childweight childheight
replace headcircum = head_circumference if headcircum ==.
drop head_circumference 

replace systolicbp = . if systolicbp < 40
gen systolicbp70 = . 
replace systolicbp70 = 1 if  systolicbp < 70 
replace systolicbp70 = 0 if  systolicbp >= 70 & systolicbp <.

*make % for age and weight for childweight childheight headcircum
table1 , vars( splenomegaly  bin\ age contn \ gender bin\city cat \ zheart_rate conts \ zsystolicbp conts \ zdiastolicbp conts \ zpulseoximetry conts \ ztemperature conts \ zchildweight conts \ zchildheight conts \ zresprate conts \ headcircum conts \ hb conts \  all_symptoms_altms bin\  all_symptoms_jaundice cat\  all_symptoms_bleeding_symptom bin\  all_symptoms_imp_mental cat\  all_symptoms_mucosal_bleed_brs bin\  all_symptoms_bloody_nose cat\  all_symptoms_fever bin\  scleralicterus bin\ systolicbp70 bin\) by(severemalaria) saving("severmalaria.xls", replace ) missing test  

logit severemalaria age gender 

