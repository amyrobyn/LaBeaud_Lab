/****************************************************
 *amy krystosik                  					*
 *u24 msambweni infection groups by age and sex     *
 *lebeaud lab               				        *
 *last updated august 14, 2016  						*
 ***************************************************/
cd "C:\Users\Amy\Box Sync\Amy Krystosik's Files\R01\longitudinal_data_chkv_and_dengue_cases-2016-07-14\longitudinal data chkv and dengue cases"
capture log close 
log using "msambweni_august14,2016.smcl", text replace 
set scrollbufsize 100000
set more 1

/**import all data files and convert the studyid to id_wide and id_visit
then save them to `datfile"_wide.csv**/ 
*update the stanford msambweni aic sheet. update stanford msambweni hcc sheets (milani and nganja). don't add the updated data from kenya until elysse merges it. 
foreach dataset in "C:\Users\Amy\Box Sync\Amy Krystosik's Files\R01\Elizas_aug102016\Msambweni  AIC.csv" "coastal data-katherine july_18_2016_coast_aic_init-katherine_coast_aic_init-katherine.csv" "coastal data-katherine july_18_2016_file1   4 coast_aicfu_18apr16.csv" "coastal data-katherine july_18_2016_file2  aic ukunda malaria....csv" "C:\Users\Amy\Box Sync\Amy Krystosik's Files\R01\Elizas_aug102016\NGANJA HCC.csv" "C:\Users\Amy\Box Sync\Amy Krystosik's Files\R01\Elizas_aug102016\MILALANI HCC.csv"{
		insheet using "`dataset'", clear
				**make id_wide. creating a new study id that we can use for longitudinal data over time. 7 digit child #
							*rename studyid1 to studyid and drop studyid2 which is childnum
								capture rename studyid2 childnum
								capture rename studyid1 studyid
							*drop if studyid==""
								drop if studyid==""
								replace studyid=lower(studyid)
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
						egen id_wide = concat(id_city id_cohort id_childnum)
						order studyid id_wide id_city id_cohort id_childnum id_visit
					*unique id
						rename *, lower
						replace id_wide = lower(id_wide) 
						bysort id_wide id_visit: gen freq_id_wide_visit = _n
						list id_wide id_visit freq_id_wide_visit if freq_id_wide_visit>1
		save "`dataset'.dta",  replace
	}	

**lab
	clear
	append using "C:\Users\Amy\Box Sync\Amy Krystosik's Files\R01\Elizas_aug102016\Msambweni  AIC.csv.dta" "C:\Users\Amy\Box Sync\Amy Krystosik's Files\R01\Elizas_aug102016\NGANJA HCC.csv.dta" "C:\Users\Amy\Box Sync\Amy Krystosik's Files\R01\Elizas_aug102016\MILALANI HCC.csv.dta", generate(append) force
*	append using "C:\Users\Amy\Box Sync\Amy Krystosik's Files\R01\Elizas_aug102016\Msambweni  AIC.csv.dta", generate(append) force
	drop if id_wide==""
	bysort id_wide : gen duplab = _n 
	replace duplab = duplab -1
	save lab.dta, replace

drop v31 v32 v33
*rename v23 stfdchikvigodb 
tostring *, replace force
**to long**
	reshape long stfdchikvigod dvigogd cvim dvp dvim cvigod cvigres  stfdcvigod stfdcvigres stfdchikviggod dvigres dvigod aliquot stfddvigod cvp  stfddvigres, i(id_wide id_visit duplab) j(lab_visit a b) string
	rename id_visit wrong_visit
	rename lab_visit id_visit
	rename dvigod denviggod 
	rename cvigod chikviggod  
	rename cvigres chikviggresult 
	rename dvigres denviggresults 
	rename cvp chikvpcr
	rename dvp denvpcr
	*rename stfdcvigod stfdchikviggod 
	*rename denviggod denviggod 
	*rename stfddvigod stfddenviggod 
	*rename dvigogd denviggod 
	rename stfdcvigres stfdchikviggresults 
	rename stfddvigres stfddenviggresults 

	*rename denviggoda denviggoda

	destring duplab, replace
	
	bysort id_wide id_visit : replace duplab = _n 
	drop if duplab >1

	
	replace id_visit = lower(id_visit)
	tostring id_visit, replace
	replace id_wide = lower(id_wide)
	tostring id_wide, replace

	save lab_long.dta, replace

**field
	clear
	append using "coastal data-katherine july_18_2016_coast_aic_init-katherine_coast_aic_init-katherine.csv.dta" "coastal data-katherine july_18_2016_file1   4 coast_aicfu_18apr16.csv.dta", generate(append) force
	bysort id_wide id_visit: gen freq_id_wide_appended = _n
	tab freq_id_wide_appended
	drop if freq_id_wide_appended >1

	replace id_visit = lower(id_visit)
	tostring id_visit, replace
	replace id_wide = lower(id_wide)
	tostring id_wide, replace

	save demography.dta, replace

**malaria
	clear
	use "coastal data-katherine july_18_2016_file2  aic ukunda malaria....csv.dta" 
	bysort id_wide id_visit: gen freq_malaria = _n
	drop if freq_malaria >1
	drop freq_id_wide 
	*drop studyid2
	tab gender
	encode gender, gen(gender01)
	drop gender
	rename gender01 gender
	replace gender = 0 if gender ==1
	replace gender = 1 if gender ==2
	save malaria.dta, replace

	
	
	
**merge**	
	use lab_long.dta, clear
		drop append
		drop freq_id_wide_visit
	merge 1:1 id_wide id_visit using demography.dta
	drop _merge
	save merged.dta, replace
	use merged.dta, replace
	destring childnum, replace force
	merge 1:1 id_wide id_visit using malaria.dta
		drop if _merge ==2
	save merged.dta, replace		

**epi analysis*****
				*make the infections groups: (dengue positive, chikv positivie, negative, coinfection), by lab (kenya and stanford) and by tests(pcr+/pcr+ igm+/pcr+ igg+/igg+)
						/*
				infection groups (9)				lab (2)			lab test (3)	total strata combos (54)
				dengue infected						kenya			pcr				
				chikv infected						stanford		pcr/igm	
				co-infected											pcr/igg	
				non-infected			
				dengue unknown chikv+			
				dengue unkonwn chikv- 			
				dengue + chikv unknown			
				dengue - chikv unknown			
				unknown dengue unknown chik			
						*/

				/* i want the following infection_groups: 
								dengue		
									+							-						missing/unequivocal
				chikv	+			coinfection					chikv+					chikv+ dengue unknown
						
						-			dengue +					not-infected			chikv- dengueunknown
					
					missing/
					unequivocal		dengue+ chikv unknown		dengue- chikvunknown	bothunknown

				*/

*use merged.dta, clear
tostring *, replace force
order id_wide id_visit 

foreach var of varlist stfd*{ 
	*tab `var'
	replace `var'=lower(`var')
}
foreach var of varlist stanford*{ 
	*tab `var'
	replace `var'=lower(`var')
}

foreach var of varlist *pcr*{ 
	tab `var'
	replace `var'=lower(`var')

}
foreach var of varlist *res*{ 
	tab `var'
	replace `var'=lower(`var')
}

foreach var of varlist *dv*{ 
	tab `var'
	replace `var'=lower(`var')
}
foreach var of varlist *dv*{ 
	tab `var'
	replace `var'=lower(`var')
}
foreach var of varlist *denv*{ 
	tab `var'
	replace `var'=lower(`var')
}
foreach var of varlist denv*{ 
	tab `var'
	replace `var'=lower(`var')
}

foreach var of varlist *cv*{ 
	tab `var'
	replace `var'=lower(`var')
}
foreach var of varlist chikv*{ 
	tab `var'
	replace `var'=lower(`var')
}


foreach var of varlist id_wide id_visit wrong_visit duplab studyid id_city id_cohort id_childnum datesamplecollected_initialvisit chikvpcr_initialvisit chikvigm_initialvisit denvpcr_initialvisit denvigm_initialvisit chikviggod_initialvisit chikviggresult_initialvisit stanfordchikvod_initialvisit stanfordchikviggresult_initialvi denviggod_initialvisit denvresult_initialvisit sample_initialvisit stanforddenvigg_initialvisit stanforddenvod_initialvisit followupaliquotid_onemonthfollow chikvpcr_onemonthfollowupvisit1 chikvigm_onemonthfollowupvisit1 denvpcr_onemonthfollowupvisit1 denvigm_onemonthfollowupvisit1 stanfordchikvod_onemonthfollowup stanfordchikviggresult_onemonthf chikvigg_onemonthfollowupvisit1 chikviggod_onemonthfollowupvisit denvigg_onemonthfollowupvisit1 denviggod_onemonthfollowupvisit1 _onemonthfollowupvisit1 sample_onemonthfollowupvisit1 stanforddenvigg_onemonthfollowup stanforddenvod_onemonthfollowupv datesamplewascollected_initialvi chikvigg_initialvisit denvigg_initialvisit followupaliquotid_followupvisit1 chikvigg_followupvisit1 chikviggod_followupvisit1 denvigg_followupvisit1 denviggod_followupvisit1 followupaliquotid_followupvisit2 chikvigg_followupvisit2 chikviggod_followupvisit2 denvigg_followupvisit2 denviggod_followupvisit2 followupaliquotid_followupvisit3 chikvigg_followupvisit3 chikviggod_followupvisit3 denvigg_followupvisit3 denviggod_followupvisit3 followupaliquotid_followupvisit4 chikvigg_followupvisit4 chikviggod_followupvisit4 denvigg_followupvisit4 denviggod_followupvisit4 followupaliquotid_followupvisit5 chikvigg_followupvisit5 chikviggod_followupvisit5 denvigg_followupvisit5 denviggod_followupvisit5 followupaliquotid_followupvisit6 chikvigg_followupvisit6 chikviggod_followupvisit6 denvigg_followupvisit6 denviggod_followupvisit6 followupaliquotid_followupvisit7 chikvigg_followupvisit7 chikviggod_followupvisit7 denvigg_followupvisit7 denviggod_followupvisit7 followupaliquotid_followupvisit8 chikvigg_followupvisit8 chikviggod_followupvisit8 denvigg_followupvisit8 denviggod_followupvisit8 followupaliquotid_followupvisit9 chikvigg_followupvisit9 chikviggod_followupvisit9 denvigg_followupvisit9 denviggod_followupvisit9 stfdchikvigod dvigogd cvim denvpcr dvim chikviggod chikviggresult stfdcvigod stfdchikviggresults stfdchikviggod denviggresults denviggod aliquot stfddvigod chikvpcr stfddenviggresults append childnum start end today hospitalsite hccparticipant hccid visittype childvillage childvillagev11 othchildvillage interviewername othinterviewername interviewdate childidnum ffthname informantrelation othinformantrelation dob age gender phonenumber othphonenumber childoccupation othchildoccupation numsiblings educlevel otheduclevel mumeduclevel othmumeduclevel rooftype othrooftype latrinetype othlatrinetype floortype othfloortype watersource lightsource othlightsource windows windowscoded windownum numroomhse numpplehse v46 othnumchild numsleeproom telephone radio television bicycle motorizedvehicle domesticworker childcontact outdooractivity mosquitobites mosquitocoil sleepbednet childtravel wheretravel nightaway everhospitalised numhospitalized counthosp reasonhospitalized1 datehospitalized1 hospitalname1 othhospitalname1 durationhospitalized1 reasonhospitalized2 datehospitalized2 hospitalname2 othhospitalname2 durationhospitalized2 reasonhospitalized3 datehospitalized3 hospitalname3 othhospitalname3 durationhospitalized3 reasonhospitalized4 datehospitalized4 hospitalname4 othhospitalname4 durationhospitalized4 reasonhospitalized5 datehospitalized5 hospitalname5 othhospitalname5 durationhospitalized5 eversurgery reasonsurgery datesurgery gestational breastfed durationbfed othdurationbfed childvaccination yellowfever dateyellowfever encephalitis dateencephalitis pastmedhist othpastmedhist malariapastmedhist pneumoniapastmedhist currenttakingmeds currentmeds othcurrentmeds paracetamolcurrentmeds everpregnant numdaysonset currentsymptoms fever chills sickfeeling shortnessofbreath generalbodyache itchiness redeyes jointpains musclepains bonepains headache painbehindeyes runnynose sorethroat cough earache lossofappetite funnytaste nausea vomiting diarrhea dizziness abdominalpain bloodystool bruises fits bloodyurine impairedmentalstatus bleedingums eyessensitivetolight bloodynose bloodyvomit stiffneck rash othcurrentsymptoms temperature childheight childweight headcircum heartrate resprate systolicbp diastolicbp pulseoximetry performvisualacuity leftvisualacuity rightvisualacuity headneckexam sclerallcterus v163 adenopathy otherhneck cliniciannoteshneck chestexam chestexamcoded cliniciannoteschest heartexam heartexamcoded cliniciannotesheart abdomenexam splenomegaly adbtenderness hepatomegaly abdlocation cliniciannotesabd nodeexam nodenormal nodeabnormal othnode othnodeexam cliniciannotesnode jointexam jointnormal jointabnormal jointlocation cliniciannotesjoint skinexam skinexamcoded othskinexam cliniciannotesskin neuroexam neuroexamcoded neuronormal neuroabnormal othneuroexam cliniciannotesneuro tourniquettest maltestordered othmaltestordered bsresults rdtresults labtests malariabloodsmear ovaparasites hemoglobin wbc neutropercent lymphpercent monopercent eosinopercent v214 mcv platelets othbloodcounts hb hivresult urinalysisresult abnormalurinalysisresult stoolovacyst othstoolovacyst othstooltestresult widalresult sicklecellresult othlabtests othlabresults primarydiag othprimarydiag primarybacterialdx secondarydiag othsecondarydiag secondarybacterialdx priviraldisease specifypriviraldisease othspecifypriviraldisease pribacterialdisease specifypribactdisease priparasiticdisease specifypriparadisease othspecifypriparadisease primarydiagv11 othprimarydiagv11 cliniciannotesprim v246 v247 v248 secviraldisease specifysecviraldisease othspecifysecviraldisease secbacterialdisease specifysecbactdisease secparasiticdisease specifysecparadisease othspecifysecparadisease freq_id_wide_visit visit funo v5 interviewdate2 age2 currentsick stageofdisease othstageofdisease healthimpacts othhealthimpacts medsprescribe othmedsprescribe outcome othoutcome outcomehospitalized locationhospital othlocationhospital datehospitalized version key freq_id_wide_appended initialdate2 initialdate2_format unformatted_dob childsname mothername fathername village nearestpoint spp1 countul1 pos_neg gametocytes1 expectedfollowupdate v19 actualfollowdate v21 followed treatment1 spp2 countul2 gametocytes2 treatment2 pos_neg1 notes freq_malaria _merge{ 
	replace `var'=lower(`var')
}

destring *age*, replace

gen ages = age
replace ages = age2 if ages==.
tab ages
drop age age2
rename ages age


destring *gender*, replace 

encode malariabloods~r , gen(malariabldsmrpos)
replace malariabldsmrpos = 0 if malariabldsmrpos == 1
replace malariabldsmrpos = 1 if malariabldsmrpos == 2
tab malariabldsmrpos  malariabloods~r
sum  malariabldsmrpos  malariabloods~r

save main2.dta, replace

**import and merge the RDT results
	import excel "RDT_results_aug2.xls", sheet("RDT_results_aug2") firstrow clear
				rename STUDY_ID studyid
				**make id_wide. creating a new study id that we can use for longitudinal data over time. 7 digit child #
							*rename studyid1 to studyid and drop studyid2 which is childnum
								capture rename studyid2 childnum
								capture rename studyid1 studyid
							*drop if studyid==""
								drop if studyid==""
								replace studyid=lower(studyid)
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
						egen id_wide = concat(id_city id_cohort id_childnum)
						order studyid id_wide id_city id_cohort id_childnum id_visit
					*unique id
						rename *, lower
						replace id_wide = lower(id_wide) 
						bysort id_wide id_visit: gen freq_id_wide_visit = _n
						list id_wide id_visit freq_id_wide_visit if freq_id_wide_visit>1
						tostring freq_id_wide_visit, replace
			save RDT_results_aug2.dta, replace
		use main2.dta, clear
			drop _merge
			merge 1:1 id_wide id_visit using RDT_results_aug2.dta
			/***none of these results match to currently available dataset as this is a msambweni only data set. 
			*/
		save main3.dta, replace

***do this over strata of stanford vs kenya and igg vs pcr. no igm in this dataset***
	use main3.dta, clear
		drop stfd* stanford* 
		save kenya_pcr_igg_only.dta, replace

	use main3.dta, clear
		drop stfd* stanford* *igg*
		save kenya_pcr_only.dta, replace

	use main3.dta, clear
		drop stfd* stanford* *pcr
		save kenya_igg_only.dta, replace

	use main3.dta, clear
		keep studyid id_wide stanford* stfd* age *gender* 
		save stfd_only.dta, replace

***this is the loop i can use with malaria results	
*foreach dataset in "kenya_pcr_igg_only.dta" "kenya_igg_only.dta" "kenya_pcr_only.dta" "main3.dta"{

**this is the loop i can use without malaira reults
foreach dataset in "stfd_only.dta"{

	use `dataset',clear
	gen infection_groups=""
	gen infection_group_deng =""
	gen infection_group_chikv =""


			foreach i of varlist *denv*{ 
				replace infection_group_deng= "dengue unknown" if `i'=="." & infection_group_deng =="."
				replace infection_group_deng= "dengue unknown" if `i'=="no serum" & infection_group_deng =="."
				replace infection_group_deng= "dengue unknown" if `i'=="equivocal" & infection_group_deng =="."
				replace infection_group_deng= "dengue unknown" if `i'=="not followed" & infection_group_deng =="."
				replace infection_group_deng= "dengue negative" if `i'=="neg"  & infection_group_deng !="dengue positive"
				replace infection_group_deng= "dengue negative" if `i'=="negative" & infection_group_deng !="dengue positive"
				replace infection_group_deng= "dengue positive" if `i'=="pos" 
				replace infection_group_deng= "dengue positive" if `i'=="positive" 
			}

			foreach i of varlist *chik*{
				replace infection_group_chikv= "chikv unknown" if `i'=="." & infection_group_chikv =="."
				replace infection_group_chikv= "chikv unknown" if `i'=="no serum" & infection_group_chikv =="."
				replace infection_group_chikv= "chikv unknown" if `i'=="equivocal" & infection_group_chikv =="."
				replace infection_group_chikv= "chikv unknown" if `i'=="not followed" & infection_group_chikv =="."
				replace infection_group_chikv= "chikv negative" if `i'=="neg" & infection_group_chikv !="chikv negative"
				replace infection_group_chikv= "chikv negative" if `i'=="negative" & infection_group_chikv !="chikv negative" 
				replace infection_group_chikv= "chikv positive" if `i'=="pos" 
				replace infection_group_chikv= "chikv positive" if `i'=="positive" 
			}


			replace infection_groups= "both unknown" if  infection_group_deng == "dengue unknown" & infection_group_chikv== "chikv unknown" 
			replace infection_groups= "dengue- chikv unknown" if  infection_group_deng == "dengue negative" & infection_group_chikv== "chikv unknown" 
			replace infection_groups= "chikv- dengue unknown" if  infection_group_deng == "dengue unknown" & infection_group_chikv== "chikv negative" 
			replace infection_groups= "dengue+ chikv unknown" if  infection_group_deng == "dengue positive" & infection_group_chikv== "chikv unknown" 
			replace infection_groups= "chikv+ dengue unknown" if  infection_group_deng == "dengue unknown" & infection_group_chikv== "chikv positive" 
			replace infection_groups= "no infection" if  infection_group_deng == "dengue negative" & infection_group_chikv== "chikv negative" 
			replace infection_groups= "dengue positive" if  infection_group_deng == "dengue positive" 
			replace infection_groups= "chikv positive" if  infection_group_chikv == "chikv positive" 
			replace infection_groups= "coinfection" if  infection_group_deng == "dengue positive" & infection_group_chikv== "chikv positive" 

			tab infection_groups
			tab infection_group_chikv
			tab infection_group_deng
				

			*table one over infection_group
			encode infection_groups, gen(groups)
			*destring age, replace
			*destring gender, replace
		*	table1, by(groups) vars(gender cat\age contn\malariabldsmrpos cat\) saving("table1_msambweni`dataset'.xls", replace) missing test
			table1, by(groups) vars(gender cat\age contn\) saving("table1_msambweni`dataset'.xls", replace) missing test

			*sum over infection_group
			by groups, sort : summarize age gender, format
			local sum = r(mean)
}
