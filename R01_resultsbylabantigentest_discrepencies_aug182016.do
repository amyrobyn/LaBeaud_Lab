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
foreach dataset in "MILALANI HCC.csv" "MILALANI HCC_may4.csv" "Msambweni  AIC.csv" "Msambweni  AIC_infectiongroups.csv" "Msambweni  AIC_may4.csv" "NGANJA HCC.csv" "NGANJA HCC_may4.csv" "PCR DATABASE AUGUST 2016.csv" "Ukunda AIC.csv" "Ukunda AIC_may4.csv" "Ukunda HCC.csv" "Ukunda HCC_may4.csv" "CHULAIMBO AIC.csv" "CHULAIMBO HCC.csv" "KISUMU AIC.csv" "KISUMU HCC.csv" "Copy of ArbovirusCBC samples.csv"{ 
		insheet using "`dataset'", clear
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
	append using "Msambweni  AIC.csv.dta" "Msambweni  AIC_infectiongroups.csv.dta" "Msambweni  AIC_may4.csv.dta" "NGANJA HCC.csv.dta" "Ukunda AIC.csv.dta" "Ukunda HCC.csv.dta" "CHULAIMBO AIC.csv.dta" "CHULAIMBO HCC.csv.dta" "KISUMU AIC.csv.dta" "KISUMU HCC.csv.dta" "MILALANI HCC.csv.dta", generate(append) force
	save merged.dta, replace

foreach dataset in "MILALANI HCC_may4.csv.dta" "NGANJA HCC_may4.csv.dta" "PCR DATABASE AUGUST 2016.csv.dta" "PRNT_july 2016 _Ukunda.xls.dta" "PRNT LaBeaud RESULTS - july 2016.xls.dta" "Ukunda HCC_may4.csv.dta" "Ukunda AIC_may4.csv.dta" "RDT_results_aug2.xls.dta" "Copy of ArbovirusCBC samples.csv.dta" "DENGUE RDT RESULTS_august2.xls.dta"{
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
	bysort studyid: gen duplab = _n 
	replace duplab = duplab -1
	bysort studyid: replace duplab = _n 
save lab.dta, replace
		keep if duplab >1 
save dup.dta, replace
use lab.dta, replace
	drop if duplab >1
save lab.dta, replace
merge m:m studyid using "dup.dta", force	

tostring *, replace force
foreach var of varlist DATE studyid IgM IgG NSI date igm igg nsi wbc ne ly mo eo ba v12 v13 v14 v15 v16 rbc hgb hct mcv mch mchc rdw plt pct mpv pdw blasts atypically lymointerference microcytosis pltrbcinterference lymphocytosis leftshift monocytosis anemia smallnucleatedcell abnormalmchc eosinophilia neutrophilia leukocytosis neeointerference erythrocytosis lymphopenia thrombocytopenia thrombocytosis immaturegr neutropenia pltclumps basophilia hypochromia anisocytosis remarks v54 DATE_formatted NSI_Result datesamplecollected_initialvisit chikvpcr_initialvisit chikvigm_initialvisit denvpcr_initialvisit denvigm_initialvisit stanfordchikvod_initialvisit stanfordchikvigg_initialvisit chikvigg_initialvisit chikviggod_initialvisit denvigg_initialvisit denviggod_initialvisit stanforddenvigg_ stanforddenvod_ followupaliquotid_onemonthfollow chikvpcr_onemonthfollowupvisit1 chikvigm_onemonthfollowupvisit1 denvpcr_onemonthfollowupvisit1 denvigm_onemonthfollowupvisit1 stanfordchikvod_onemonthfollowup stanfordchikvigg_onemonthfollowu chikvigg_onemonthfollowupvisit1 chikviggod_onemonthfollowupvisit denvigg_onemonthfollowupvisit1 denviggod_onemonthfollowupvisit1 v26 v27 v28 chikvigg_onemonthfollowupvisit2 v30 denvigg_onemonthfollowupvisit2 denviggod_onemonthfollowupvisit2 v33 chikvigg_onemonthfollowupvisit3 v35 denvigg_onemonthfollowupvisit3 denviggod_onemonthfollowupvisit3 v38 chikvigg_onemonthfollowupvisit4 v40 denvigg_onemonthfollowupvisit4 denviggod_onemonthfollowupvisit4 villhouse personid child_name collectiondate_initialvisit aliquotid_initialvisit followupaliquotid_followupvisit1 dateofcollection_followupvisit1 aliquotid_followupvisit1 chikviggod_followupvisit1 chikvigg_followupvisit1 denviggod_followupvisit1 denvigg_followupvisit1 followupaliquotid_followupvisit2 chikvigg_followupvisit2 chikviggod_followupvisit2 denvigg_followupvisit2 denviggod_followupvisit2 followupaliquotid_followupvisit3 chikvigg_followupvisit3 chikviggod_followupvisit3 denvigg_followupvisit3 denviggod_followupvisit3 followupaliquotid_followupvisit4 chikvigg_followupvisit4 chikviggod_followupvisit4 denvigg_followupvisit4 denviggod_followupvisit4 followupaliquotid_followupvisit5 chikvigg_followupvisit5 chikviggod_followupvisit5 denvigg_followupvisit5 denviggod_followupvisit5 followupaliquotid_followupvisit6 chikvigg_followupvisit6 chikviggod_followupvisit6 denvigg_followupvisit6 denviggod_followupvisit6 followupaliquotid_followupvisit7 chikvigg_followupvisit7 chikviggod_followupvisit7 denvigg_followupvisit7 denviggod_followupvisit7 followupaliquotid_followupvisit8 chikvigg_followupvisit8 chikviggod_followupvisit8 denvigg_followupvisit8 denviggod_followupvisit8 followupaliquotid_followupvisit9 chikvigg_followupvisit9 chikviggod_followupvisit9 denvigg_followupvisit9 denviggod_followupvisit9 DENV2 WNV CHIKV ONNV datesamplecollected datepcrdone site aliquotid denvpcrresults denvserotype chikvpcrresults datesamplewascollected_initialvi chikviggresults_followupvisit2 datesamplewascollected_ chikvigg_ chikviggod_ denvigg_ denviggod_ chikviggresuilts_followupvisit2 append chikviggresult_initialvisit stanfordchikviggresult_initialvi denvresult_initialvisit sample_initialvisit stanforddenvigg_initialvisit stanforddenvod_initialvisit stanfordchikviggresult_onemonthf _onemonthfollowupvisit1 sample_onemonthfollowupvisit1 stanforddenvigg_onemonthfollowup stanforddenvod_onemonthfollowupv v31 v32 v22 v23 v24 v29 v34 v37 chikvigg_onemonthfollowupvisit5 v39 denvigg_onemonthfollowupvisit5 denviggod_onemonthfollowupvisit5 v42 chikvigg_onemonthfollowupvisit6 v44 denvigg_onemonthfollowupvisit6 denviggod_onemonthfollowupvisit6 v47 chikvigg_onemonthfollowupvisit7 v49 denvigg_onemonthfollowupvisit7 denviggod_onemonthfollowupvisit7 kenyachikvreading_initialvisit kenyadenvreading_initialvisit stanforddenvreading_initialvisit initialaliquotid_initialvisit stforddenviggod_initialvisit stforddenvigg_initialvisit stforddenviggod_onemonthfollowup stforddenvigg_onemonthfollowupvi datesamplerun_41725 followupid_followupvisit1 followupid_followupvisit2 datesamplerun_initialvisit chikvpcr_onemonthfollowupvisit chikvigm_onemonthfollowupvisit denvpcr_onemonthfollowupvisit denvigm_onemonthfollowupvisit chikvigg_onemonthfollowupvisit denvigg_onemonthfollowupvisit denviggod_onemonthfollowupvisit _onemonthfollowupvisit stfrddenviggod_onemonthfollowupv stfrddenvigg_onemonthfollowupvis dateofcollection_initialvisit dateofcollection_followupvisit2 duplab _merge{
	replace `var'=lower(`var')
}


	foreach var of varlist *pcr* *res* *denv* denv* *chikv* chikv* *nsi{ 
		tab `var' if strpos(`var', "neg")|strpos(`var', "pos")
	}

save main2.dta, replace


***do this over strata of stanford vs kenya and igg vs pcr. no igm in this dataset***
	use main2.dta, clear
		drop stanford* 
		save kenya_only.dta, replace
	use main2.dta, clear
		keep studyid stanford* 
		save stfd_only.dta, replace

*make infection groups for each
foreach dataset in "kenya_only.dta"  "stfd_only.dta" "main2.dta"{
	use `dataset',clear
	gen infection_groups=""
	gen infection_group_deng =""
	gen infection_group_chikv =""


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
			table1, vars(groups cat\) saving("table1_`dataset'.xls", replace) missing test

	
}
