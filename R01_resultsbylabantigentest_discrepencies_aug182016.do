/**************************************************************
 *amy krystosik                  							  *
 *R01 results and discrepencies by strata (lab, antigen, test)*
 *lebeaud lab               				        		  *
 *last updated august 15, 2016  							  *
 **************************************************************/
cd "C:\Users\Amy\Box Sync\Amy Krystosik's Files\R01\lab results and discrepencies august 18"
capture log close 
log using "R01_discrepencies.smcl", text replace 
set scrollbufsize 100000
set more 1

**lab
foreach dataset in "MILALANI HCC.csv" "MILALANI HCC_may4.csv" "Msambweni  AIC.csv" "Msambweni  AIC_infectiongroups.csv" "Msambweni  AIC_may4.csv" "NGANJA HCC.csv" "NGANJA HCC_may4.csv" "PCR DATABASE AUGUST 2016.csv" "Ukunda AIC.csv" "Ukunda AIC_may4.csv" "Ukunda HCC.csv" "Ukunda HCC_may4.csv" "CHULAIMBO AIC.csv" "CHULAIMBO HCC.csv" "KISUMU AIC.csv" "KISUMU HCC.csv" "Copy of ArbovirusCBCDatabase_Updated_19th August 2016JS.csv" "C:\Users\Amy\Box Sync\Amy Krystosik's Files\R01\lab results and discrepencies august 18\surveys\West_HCC 2nd Followup Database_15Jul2016.csv" "C:\Users\Amy\Box Sync\Amy Krystosik's Files\R01\lab results and discrepencies august 18\surveys\West_HCC 3rd Followup_15Jul2016.csv" "C:\Users\Amy\Box Sync\Amy Krystosik's Files\R01\lab results and discrepencies august 18\surveys\West_HCC Initial Database_15Jul2016.csv" "C:\Users\Amy\Box Sync\Amy Krystosik's Files\R01\lab results and discrepencies august 18\surveys\Western Data-Katherine july_14_2016_Western_AIC_Init-Katherine.csv" "C:\Users\Amy\Box Sync\Amy Krystosik's Files\R01\lab results and discrepencies august 18\surveys\Western Data-Katherine july_14_2016_Western_AICFU-Katherine.csv" "C:\Users\Amy\Box Sync\Amy Krystosik's Files\R01\lab results and discrepencies august 18\surveys\Coastal Data-Katherine july_18_2016_Coast_AIC_Init-Katherine_Coast_AIC_Init-Katherine.csv" "C:\Users\Amy\Box Sync\Amy Krystosik's Files\R01\lab results and discrepencies august 18\surveys\Coastal Data-Katherine july_18_2016_FILE1   4 coast_aicfu_18apr16.csv" "C:\Users\Amy\Box Sync\Amy Krystosik's Files\R01\lab results and discrepencies august 18\surveys\Coastal Data-Katherine july_18_2016_FILE2  AIC Ukunda Malaria....csv" "C:\Users\Amy\Box Sync\Amy Krystosik's Files\R01\lab results and discrepencies august 18\surveys\West_HCC 1st Followup Database_15Jul2016.csv"{ 
		insheet using "`dataset'", clear
			capture drop studyid2
			capture rename studyid1 studyid
			capture rename sampleid studyid
			capture rename *id studyid
			capture rename *NUMBER studyid
			capture rename *ALIQUOT studyid
			
			replace studyid= subinstr(studyid, ".", "",.) 
			replace studyid= subinstr(studyid, "/", "",.)
			replace studyid= subinstr(studyid, " ", "",.)
		save "`dataset'.dta",  replace
	}

foreach dataset in "PRNT_july 2016 _Ukunda.xls" "PRNT LaBeaud RESULTS - july 2016.xls" "RDT_results_aug2.xls" "DENGUE RDT RESULTS_august2.xls"{ 
	import excel "`dataset'", clear firstrow
			capture rename sampleid studyid
			capture rename *id studyid
			capture rename *ID studyid
			capture rename *ALIQUOT studyid
			capture rename *NUMBER studyid

			replace studyid= subinstr(studyid, ".", "",.) 
			replace studyid= subinstr(studyid, "/", "",.)
			replace studyid= subinstr(studyid, " ", "",.)
	save "`dataset'.dta",  replace
	}

	clear
	append using "C:\Users\Amy\Box Sync\Amy Krystosik's Files\R01\lab results and discrepencies august 18\surveys\West_HCC 1st Followup Database_15Jul2016.csv.dta" "C:\Users\Amy\Box Sync\Amy Krystosik's Files\R01\lab results and discrepencies august 18\surveys\West_HCC 2nd Followup Database_15Jul2016.csv.dta" "C:\Users\Amy\Box Sync\Amy Krystosik's Files\R01\lab results and discrepencies august 18\surveys\West_HCC 3rd Followup_15Jul2016.csv.dta" "C:\Users\Amy\Box Sync\Amy Krystosik's Files\R01\lab results and discrepencies august 18\surveys\West_HCC Initial Database_15Jul2016.csv.dta" "C:\Users\Amy\Box Sync\Amy Krystosik's Files\R01\lab results and discrepencies august 18\surveys\Western Data-Katherine july_14_2016_Western_AIC_Init-Katherine.csv.dta" "C:\Users\Amy\Box Sync\Amy Krystosik's Files\R01\lab results and discrepencies august 18\surveys\Western Data-Katherine july_14_2016_Western_AICFU-Katherine.csv.dta" "C:\Users\Amy\Box Sync\Amy Krystosik's Files\R01\lab results and discrepencies august 18\surveys\Coastal Data-Katherine july_18_2016_Coast_AIC_Init-Katherine_Coast_AIC_Init-Katherine.csv.dta" "C:\Users\Amy\Box Sync\Amy Krystosik's Files\R01\lab results and discrepencies august 18\surveys\Coastal Data-Katherine july_18_2016_FILE1   4 coast_aicfu_18apr16.csv.dta" "C:\Users\Amy\Box Sync\Amy Krystosik's Files\R01\lab results and discrepencies august 18\surveys\Coastal Data-Katherine july_18_2016_FILE2  AIC Ukunda Malaria....csv.dta", generate(append) force
	save merged.dta, replace

foreach dataset in "MILALANI HCC_may4.csv.dta" "NGANJA HCC_may4.csv.dta" "PCR DATABASE AUGUST 2016.csv.dta" "PRNT_july 2016 _Ukunda.xls.dta" "PRNT LaBeaud RESULTS - july 2016.xls.dta" "Ukunda HCC_may4.csv.dta" "Ukunda AIC_may4.csv.dta" "RDT_results_aug2.xls.dta" "Copy of ArbovirusCBCDatabase_Updated_19th August 2016JS.csv.dta" "DENGUE RDT RESULTS_august2.xls.dta" "Msambweni  AIC.csv.dta" "Msambweni  AIC_infectiongroups.csv.dta" "Msambweni  AIC_may4.csv.dta" "NGANJA HCC.csv.dta" "Ukunda AIC.csv.dta" "Ukunda HCC.csv.dta" "CHULAIMBO AIC.csv.dta" "CHULAIMBO HCC.csv.dta" "KISUMU AIC.csv.dta" "KISUMU HCC.csv.dta" "MILALANI HCC.csv.dta"{
	use "`dataset'" 
	capture rename sampleid studyid
	capture rename *id studyid
	capture rename *ALIQUOT studyid
	
	replace studyid= subinstr(studyid, ".", "",.) 
	replace studyid= subinstr(studyid, "/", "",.)
	replace studyid= subinstr(studyid, " ", "",.)

	merge m:m studyid using "merged.dta", force	
	drop _merge
	save merged.dta, replace
}	
	drop if studyid==""
	bysort studyid: gen dup = _n 
	replace dup = dup -1
save lab.dta, replace
		keep if dup >=1 
save dup.dta, replace
use lab.dta, replace
	drop if dup >=1
save lab.dta, replace
merge m:m studyid using "dup.dta", force	

tostring *, replace force
foreach var of varlist   studyid datesamplewascollected_initialvi chikvigg_initialvisit chikviggod_initialvisit denvigg_initialvisit denviggod_initialvisit followupaliquotid_followupvisit1 chikvigg_followupvisit1 chikviggod_followupvisit1 denvigg_followupvisit1 denviggod_followupvisit1 followupaliquotid_followupvisit2 chikvigg_followupvisit2 chikviggod_followupvisit2 denvigg_followupvisit2 denviggod_followupvisit2 followupaliquotid_followupvisit3 chikvigg_followupvisit3 chikviggod_followupvisit3 denvigg_followupvisit3 denviggod_followupvisit3 followupaliquotid_followupvisit4 chikvigg_followupvisit4 chikviggod_followupvisit4 denvigg_followupvisit4 denviggod_followupvisit4 followupaliquotid_followupvisit5 chikvigg_followupvisit5 chikviggod_followupvisit5 denvigg_followupvisit5 denviggod_followupvisit5 followupaliquotid_followupvisit6 chikvigg_followupvisit6 chikviggod_followupvisit6 denvigg_followupvisit6 denviggod_followupvisit6 followupaliquotid_followupvisit7 chikvigg_followupvisit7 chikviggod_followupvisit7 denvigg_followupvisit7 denviggod_followupvisit7 followupaliquotid_followupvisit8 chikvigg_followupvisit8 chikviggod_followupvisit8 denvigg_followupvisit8 denviggod_followupvisit8 followupaliquotid_followupvisit9 chikvigg_followupvisit9 chikviggod_followupvisit9 denvigg_followupvisit9 denviggod_followupvisit9 dateofcollection_initialvisit initialaliquotid_initialvisit dateofcollection_followupvisit1 dateofcollection_followupvisit2 datesamplecollected_initialvisit datesamplerun_initialvisit chikvpcr_initialvisit chikvigm_initialvisit denvpcr_initialvisit denvigm_initialvisit stanfordchikvod_initialvisit stanfordchikvigg_initialvisit stforddenviggod_initialvisit stforddenvigg_initialvisit followupaliquotid_onemonthfollow chikvpcr_onemonthfollowupvisit chikvigm_onemonthfollowupvisit denvpcr_onemonthfollowupvisit denvigm_onemonthfollowupvisit stanfordchikvod_onemonthfollowup stanfordchikvigg_onemonthfollowu chikvigg_onemonthfollowupvisit chikviggod_onemonthfollowupvisit denvigg_onemonthfollowupvisit denviggod_onemonthfollowupvisit _onemonthfollowupvisit v29 v30 stfrddenviggod_onemonthfollowupv stfrddenvigg_onemonthfollowupvis datesamplerun_41725 followupid_followupvisit1 followupid_followupvisit2 chikvpcr_onemonthfollowupvisit1 chikvigm_onemonthfollowupvisit1 denvpcr_onemonthfollowupvisit1 denvigm_onemonthfollowupvisit1 chikvigg_onemonthfollowupvisit1 denvigg_onemonthfollowupvisit1 denviggod_onemonthfollowupvisit1 _onemonthfollowupvisit1 stforddenviggod_onemonthfollowup stforddenvigg_onemonthfollowupvi villhouse personid child_name collectiondate_initialvisit aliquotid_initialvisit aliquotid_followupvisit1 kenyachikvreading_initialvisit kenyadenvreading_initialvisit stanforddenvigg_initialvisit stanforddenvod_initialvisit stanforddenvreading_initialvisit v31 sample_onemonthfollowupvisit1 stanforddenvigg_onemonthfollowup stanforddenvod_onemonthfollowupv chikviggresult_initialvisit denvresult_initialvisit stanfordchikviggresult_onemonthf v16 v22 v23 v24 denvigg_onemonthfollowupvisit2 denviggod_onemonthfollowupvisit2 v27 chikvigg_onemonthfollowupvisit3 denvigg_onemonthfollowupvisit3 denviggod_onemonthfollowupvisit3 v32 chikvigg_onemonthfollowupvisit4 v34 denvigg_onemonthfollowupvisit4 denviggod_onemonthfollowupvisit4 v37 chikvigg_onemonthfollowupvisit5 v39 denvigg_onemonthfollowupvisit5 denviggod_onemonthfollowupvisit5 v42 chikvigg_onemonthfollowupvisit6 v44 denvigg_onemonthfollowupvisit6 denviggod_onemonthfollowupvisit6 v47 chikvigg_onemonthfollowupvisit7 v49 denvigg_onemonthfollowupvisit7 denviggod_onemonthfollowupvisit7 stanfordchikviggresult_initialvi sample_initialvisit v33 DATE IgM IgG NSI date igm igg nsi wbc ne ly mo eo ba v12 v13 v14 v15 rbc hgb hct mcv mch mchc rdw plt pct mpv pdw blasts atypically lymointerference microcytosis pltrbcinterference lymphocytosis leftshift monocytosis anemia smallnucleatedcell abnormalmchc eosinophilia neutrophilia leukocytosis neeointerference erythrocytosis lymphopenia thrombocytopenia thrombocytosis immaturegr neutropenia pltclumps basophilia hypochromia anisocytosis remarks v54 DATE_formatted DENV_NSI_Result stanforddenvigg_ stanforddenvod_ v26 v28 chikvigg_onemonthfollowupvisit2 v35 v38 v40 prnt_DENV2 prnt_WNV prnt_CHIKV prnt_ONNV datesamplecollected datepcrdone site aliquotid denvpcrresults denvserotype chikvpcrresults chikviggresults_followupvisit2 datesamplewascollected_ chikvigg_ chikviggod_ denvigg_ denviggod_ chikviggresuilts_followupvisit2 append today childvillage interviewdate interviewername othinterviewername houseid childindividualid csurname cfname csname ctname cfthname dob gender childage childheight childweight phonenumber childoccupation othchildoccupation educlevel otheduclevel mumeduclevel othmumeduclevel childtravel wheretravel nightaway lifestylechange fevertoday numillnessfever feversymptoms othfeversymptoms durationsymptom seekmedcare medtype wheremedseek othwheremedseek everhospitalised numhosp reasonhospitalized1 datehospitalized1 hospitalname1 othhospitalname1 durationhospitalized1 version start end followupvisitnum othfollowupvisitnum numofsiblings outdooractivity timeoutdoors mosquitobitefreq avoidmosquitoes wearinsectrepellant usemosqcoil usenetfreq childbitten mosqbitedaytime mosqbitenight watercollobjects watercolltype hospitalsite hccparticipant hccid visittype childvillagev11 othchildvillage childidnum ffthname informantrelation othinformantrelation age othphonenumber numsiblings rooftype othrooftype latrinetype othlatrinetype floortype othfloortype watersource lightsource othlightsource windows windowscoded windownum numroomhse numpplehse v46 othnumchild numsleeproom telephone radio television bicycle motorizedvehicle domesticworker childcontact mosquitobites mosquitocoil sleepbednet numhospitalized counthosp reasonhospitalized2 datehospitalized2 hospitalname2 othhospitalname2 durationhospitalized2 reasonhospitalized3 datehospitalized3 hospitalname3 othhospitalname3 durationhospitalized3 reasonhospitalized4 datehospitalized4 hospitalname4 othhospitalname4 durationhospitalized4 reasonhospitalized5 datehospitalized5 hospitalname5 othhospitalname5 durationhospitalized5 eversurgery reasonsurgery datesurgery gestational breastfed durationbfed othdurationbfed childvaccination yellowfever dateyellowfever encephalitis dateencephalitis pastmedhist othpastmedhist malariapastmedhist pneumoniapastmedhist currenttakingmeds currentmeds othcurrentmeds paracetamolcurrentmeds everpregnant numdaysonset currentsymptoms fever chills sickfeeling shortnessofbreath generalbodyache itchiness redeyes jointpain musclepains bonepains headache painbehindeyes runnynose sorethroat cough earache lossofappetite funnytaste nausea vomiting diarrhea dizziness abdominalpain bloodystool bruises fits bloodyurine impairedmentalstatus bleedinggums eyessensitivetolight bloodynose bloodyvomit stiffneck rash othcurrentsymptoms temperature headcircum heartrate resprate systolicbp diastolicbp pulseoximetry performvisualacuity leftvisualacuity rightvisualacuity headneckexam scleralicterus v163 adenopathy otherhneck cliniciannoteshneck chestexam chestexamcoded cliniciannoteschest heartexam heartexamcoded cliniciannotesheart abdomenexam splenomegaly abdtenderness hepatomegaly abdlocation cliniciannotesabd nodeexam nodenormal nodeabnormal othnode othernodeexam cliniciannotesnode jointexam jointnormal jointabnormal jointlocation cliniciannotesjoint skinexam skinexamcoded othskinexam cliniciannotesskin neuroexam neuroexamcoded neuronormal neuroabnormal othneuroexam cliniciannotesneuro tourniquettest maltestordered othmaltestordered bsresults rdtresults labtests malariabloodsmear ovaparasites hemoglobin neutropercent lymphpercent monopercent eosinopercent v214 platelets othbloodcounts hb hivresult urinalysisresult abnormalurinalysisresult stoolovacyst othstoolovacyst othstooltestresult widalresult sicklecellresult othlabtests othlabresults primarydiag othprimarydiag primarybacterialdx secondarydiag othsecondarydiag secondarybacterialdx priviraldisease specifypriviraldisease othspecifypriviraldisease pribacterialdisease specifypribactdisease priparasiticdisease specifypriparadisease othspecifypriparadisease primarydiagv11 othprimarydiagv11 cliniciannotesprim v246 v247 v248 secviraldisease specifysecviraldisease othspecifysecviraldisease secbacterialdisease specifysecbactdisease secparasiticdisease specifysecparadisease othspecifysecparadisease currentsick v36 jointpains v48 v50 v52 v56 v58 v60 v62 v64 v66 v68 v70 v72 v74 v76 v78 v80 v82 v84 v86 v88 v90 v92 v94 v110 spleonmegaly othnodeexam v151 labtestsother malariaresults stageofdisease othstageofdisease stageofdiseasecoded othstageofdiseasecoded healthimpacts othhealthimpacts medsprescribe antibiotic v187 antimalarial v189 antiparasitic v191 ibuprofen v193 paracetamol v195 othmedsprescribe outcome othoutcome outcomehospitalized locationhospital othlocationhospital datehospitalized key v205 bleedingums sclerallcterus adbtenderness visit funo v5 interviewdate2 age2 initialdate2 initialdate2_format unformatted_dob childsname mothername fathername village nearestpoint spp1 countul1 pos_neg gametocytes1 expectedfollowupdate v19 actualfollowdate v21 followed treatment1 spp2 countul2 gametocytes2 treatment2 pos_neg1 notes dup _merge{
	replace `var'=lower(`var')
}
foreach var of varlist *pcr* *res* *denv* denv* *chikv* chikv* *nsi{ 
		tab `var' if strpos(`var', "neg")|strpos(`var', "pos")
	}

**create site, village, cohort variables from studyid
						drop if studyid==""
						gen firstpart= reverse(studyid)
						order studyid firstpart
						replace firstpart = substr(studyid, strpos(studyid, ":") -7, .)
						replace firstpart = substr(firstpart, strpos(firstpart, ":") -7, .)
						drop firstpart
						gen firstpart= reverse(studyid)
						replace firstpart = substr(firstpart, strpos(firstpart, ":") -7, .)
						order studyid firstpart
						replace firstpart= reverse(firstpart)
						forval i = 1/3 { 
							gen firstpart_`i' = substr(firstpart, `i', 1) 
						}
						rename firstpart_1 id_city
						rename firstpart_2 id_cohort
						rename firstpart_3 id_visit
						drop firstpart
						gen id_childnum = substr(studyid, strpos(studyid, ":") + 4, .)
						
						order id_city - id_childnum
											 
											
						gen firstpart= reverse(studyid) if id_city== ""
						order studyid firstpart 
						replace firstpart = substr(studyid, strpos(studyid, ":") -4, .) if id_city== ""
						replace firstpart = substr(firstpart, strpos(firstpart, ":") -4, .) if id_city== ""
						drop firstpart
						gen firstpart= reverse(studyid) if id_city== ""
						replace firstpart = substr(firstpart, strpos(firstpart, ":") -4, .) if id_city== ""
						order studyid firstpart
						replace firstpart= reverse(firstpart) if id_city== ""
						forval i = 1/3 { 
							gen firstpart_`i' = substr(firstpart, `i', 1)  if id_city== ""
						}
						replace id_city = firstpart_1  if id_city== ""
						replace id_cohort = firstpart_2  if id_cohort== ""
						replace id_visit = firstpart_3 if id_visit== ""
						drop firstpart
						replace id_childnum = substr(studyid, strpos(studyid, ":") + 4, .) if id_city== ""

						egen id_wide = concat(id_city id_cohort id_childnum)

 foreach v of varlist _all {
      capture rename `v' `=lower("`v'")'
   }
   
   						replace id_city  = "Chulaimbo" if id_city == "c"|id_city == "r"
						replace id_city  = "Msambweni" if id_city == "m"
						replace id_city  = "Kisumu" if id_city == "k"
						replace id_city  = "Ukunda" if id_city == "u"
						replace id_city  = "Milani" if id_city == "l"
						replace id_city  = "Nganja" if id_city == "g"

 foreach v of varlist prnt* {
      replace `v' = "pos" if `v' == ">80"
	  replace `v' = "neg" if `v' == "10"|`v' == "20"|`v' == "40"|`v' == "<10"
	  replace `v' = "dengue unknown" if `v' == "no sample"|`v' == "no sample received at cdc"
   tab `v'
   }
   
   
save main2.dta, replace


*this can seperate incidence and prevalence data by test. 
	use main2.dta, clear
			foreach i of varlist *initial* { 
									replace `i' = lower(`i')
									keep if `i' != "pos" 
									keep if `i' != "positive"
				}
		save incident.dta, replace
		
	use main2.dta, clear
		save prevalence.dta, replace


**seperate by lab**	
foreach dataset in "incident"  "prevalence"{
	use `dataset',clear
		drop stanford* 
		save kenya_`dataset'.dta, replace

	use `dataset',clear
		keep studyid stanford* *id* *age *gender id_city id_cohort id_visit 
		save stfd_`dataset'.dta, replace
}

**gen assay var
foreach dataset in "kenya_incident" "stfd_incident" "kenya_prevalence" "stfd_prevalence"{
	use `dataset',clear
		capture keep studyid *pcr* *id* *age *gender id_city id_cohort id_visit
		capture save `dataset'_pcr.dta, replace
	use `dataset',clear
		capture keep studyid *nsi* *id* *age *gender id_city id_cohort id_visit
		capture save `dataset'_nsi.dta, replace
	use `dataset',clear
		capture keep studyid prnt* *id* *age *gender id_city id_cohort id_visit
		capture save `dataset'_prnt.dta, replace
	use `dataset',clear
		keep studyid *igg* *id* *age *gender id_city id_cohort id_visit
		save `dataset'_igg.dta, replace
	use `dataset',clear
		capture keep studyid *igm* *id* *age *gender id_city id_cohort id_visit
		capture save `dataset'_igm.dta, replace
}
*

*make infection groups for each

foreach dataset in "stfd_incident_prnt" "stfd_incident_pcr" "stfd_incident_nsi" "stfd_incident_igm" "stfd_incident_igg" "stfd_prevalence_prnt" "stfd_prevalence_pcr" "stfd_prevalence_nsi" "stfd_prevalence_igm" "stfd_prevalence_igg" "kenya_incident_prnt" "kenya_incident_pcr" "kenya_incident_nsi" "kenya_incident_igm" "kenya_incident_igg" "kenya_prevalence_prnt" "kenya_prevalence_pcr" "kenya_prevalence_nsi" "kenya_prevalence_igm" "kenya_prevalence_igg"{
	use `dataset',clear

	foreach i of varlist _all{ 
				tostring `i', replace force
				replace `i' = itrim(`i')
				replace `i' = "" if `i' ==" "
				replace `i' = "." if `i' ==""
			}

	gen infection_groups="."
	gen infection_group_deng ="."
	gen infection_group_chikv ="."


if infection_group_deng!="dengue positive" foreach i of varlist *denv* { 
				replace infection_group_deng= "dengue unknown" if `i'=="." & infection_group_deng =="."
				replace infection_group_deng= "dengue unknown" if `i'=="no serum" & infection_group_deng =="."
				replace infection_group_deng= "dengue unknown" if `i'=="equivocal" & infection_group_deng =="."
				replace infection_group_deng= "dengue unknown" if `i'=="not followed" & infection_group_deng =="."
				replace infection_group_deng= "dengue negative" if `i'=="neg"  & infection_group_deng !="dengue positive"
				replace infection_group_deng= "dengue negative" if `i'=="negative" & infection_group_deng !="dengue positive"
				replace infection_group_deng= "dengue positive" if `i'=="pos" 
				replace infection_group_deng= "dengue positive" if `i'=="positive" 
			}

if infection_group_chikv!="chikv positive" foreach i of varlist *chik*{
				replace infection_group_chikv= "chikv unknown" if `i'=="." & infection_group_chikv =="."
				replace infection_group_chikv= "chikv unknown" if `i'=="no serum" & infection_group_chikv =="."
				replace infection_group_chikv= "chikv unknown" if `i'=="equivocal" & infection_group_chikv =="."
				replace infection_group_chikv= "chikv unknown" if `i'=="not followed" & infection_group_chikv =="."
				replace infection_group_chikv= "chikv negative" if `i'=="neg" & infection_group_chikv !="chikv negative"
				replace infection_group_chikv= "chikv negative" if `i'=="negative" & infection_group_chikv !="chikv negative" 
				replace infection_group_chikv= "chikv positive" if `i'=="pos" 
				replace infection_group_chikv= "chikv positive" if `i'=="positive" 
			}


			replace infection_groups= "both unknown" if infection_group_deng == "dengue unknown" & infection_group_chikv== "chikv unknown"
			replace infection_groups= "dengue- chikv unknown" if  infection_group_chikv== "chikv unknown" & infection_group_deng == "dengue negative"
			replace infection_groups= "chikv- dengue unknown" if  infection_group_deng == "dengue unknown" & infection_group_chikv== "chikv negative" 
			replace infection_groups= "dengue+ chikv unknown" if  infection_group_chikv== "chikv unknown" & infection_group_deng == "dengue positive"
			replace infection_groups= "chikv+ dengue unknown" if  infection_group_deng == "dengue unknown" & infection_group_chikv== "chikv positive"
			replace infection_groups= "no infection" if  infection_group_deng == "dengue negative" & infection_group_chikv== "chikv negative" 
			replace infection_groups= "dengue positive chikv negative" if  infection_group_deng == "dengue positive" & infection_group_chikv== "chikv negative" 
			replace infection_groups= "chikv positive denv negative" if  infection_group_chikv == "chikv positive" & infection_group_deng == "dengue negative" 
			replace infection_groups= "coinfection" if  infection_group_deng == "dengue positive" & infection_group_chikv== "chikv positive" 

			tab infection_groups
			tab infection_group_chikv
			tab infection_group_deng
				

			*table one over infection_group
			encode infection_groups, gen(groups_`dataset')
			save `dataset'_2.dta, replace
}

*final prevelance
use "kenya_prevalence_igm_2.dta", clear
merge m:m studyid using "kenya_prevalence_igg_2", force
drop _merge
save final_prevalence.dta, replace


foreach dataset in "stfd_prevalence_prnt_2" "stfd_prevalence_pcr_2" "stfd_prevalence_nsi_2" "stfd_prevalence_igm_2" "stfd_prevalence_igg_2" "kenya_prevalence_prnt_2" "kenya_prevalence_pcr_2" "kenya_prevalence_nsi_2" {
	use "`dataset'" 	
	merge m:m studyid using "final_prevalence.dta", force	
	drop _merge
	save final_prevalence.dta, replace
}	
	drop if studyid==""
	bysort studyid: gen dup = _n 
	replace dup = dup -1
	tab studyid if dup >0
save final_prevalence.dta, replace

*final incidence
use "kenya_incident_igm_2", clear
merge m:m studyid using "kenya_incident_igg_2", force
drop _merge
save final_incidence.dta, replace

foreach dataset in "stfd_incident_prnt_2" "stfd_incident_pcr_2" "stfd_incident_nsi_2" "stfd_incident_igm_2" "stfd_incident_igg_2" "kenya_incident_prnt_2" "kenya_incident_pcr_2" "kenya_incident_nsi_2"{ 
	use "`dataset'" 	
	merge m:m studyid using "final_incidence.dta", force	
	drop _merge
	save final_incidence.dta, replace
}	
	drop if studyid==""
	bysort studyid: gen dup = _n 
	replace dup = dup -1
	tab studyid if dup >0
save final_incidence.dta, replace


use "final_prevalence", clear
export excel using "prevalence_merged.xls", sheetreplace firstrow(variables)
table1, by(id_city) vars(groups_kenya_prevalence_nsi cat \ groups_kenya_prevalence_pcr  cat \ groups_kenya_prevalence_prnt  cat \ groups_stfd_prevalence_igg  cat \ groups_stfd_prevalence_igm  cat \ groups_stfd_prevalence_nsi  cat \ groups_stfd_prevalence_pcr  cat \ groups_stfd_prevalence_prnt  cat \ groups_kenya_prevalence_igm  cat \ groups_kenya_prevalence_igg cat \) saving("table1_final_prevalence.xls", replace) missing test

use "final_incidence", clear 
export excel using "incidence_merged.xls", sheetreplace firstrow(variables)
table1, by(id_city) vars(groups_kenya_incident_nsi cat \ groups_kenya_incident_pcr cat \ groups_kenya_incident_prnt cat \ groups_stfd_incident_igg cat \ groups_stfd_incident_igm cat \ groups_stfd_incident_nsi cat \ groups_stfd_incident_pcr cat \ groups_stfd_incident_prnt cat \ groups_kenya_incident_igm cat \ groups_kenya_incident_igg cat \) saving("table1_final_incidence.xls", replace) missing test
