/************************************************************** *amy krystosik                  							  * *R01 results and discrepencies by strata (lab, antigen, test)* *lebeaud lab               				        		  * *last updated September 15, 2016  							  * **************************************************************/ /*to do
 Des

I just met with Melisa. She is going to write a grant about malaria in the R01 cohorts due Feb 1. Can you take a quick peek at the malaria data in our AIC and HCC databases to get her some prelim data (who, when, where, why) for the grant? She will be e-mailing you soon! :)

Perfect. I would love to know how many malaria cases we have =   1,304   

the species percentages, malaria co-infection percentages
species, n, %
p/f	311	23.85
p/m	2	0.15
pf	298	22.85
pf/pm	1	0.08
pm	8	0.61
pm/pf	4	0.31
pm/pm	1	0.08
po	5	0.38
po/pf	1	0.08
ni	671	51.46
none	2	0.15

What season it is more common, 
?

what site. 
HospitalSi	Pos_neg
te	neg	pos	Total
			
3	626	614	1,240 
4	531	690	1,221 
			
Total	1,157	1,304	2,461 


And how many repeat offenders (positive at AIC visit 1 and also visit 2- or visit 3 and visit 4- they should clear their parasitemia, but some kids keep coming back with malaria. 
n = 91

How many of those do we have- when? where? why? spatial clustering? 

Pos_neg
Gender        pos	Total
	
f         34	34 
m         26	26 
	
Total         60	60 


HospitalSi   Pos_neg
te        pos	Total
	
3         43	43 
4         17	17 
	
Total         60	60 

no observations

Pos_neg
dobyear        pos	Total
	
2007          2	2 
2009          3	3 
2010          5	5 
2011          6	6 
2012          6	6 
2013         10	10 
2014          3	3 
	
Total         35	35 


Pos_neg
SPP1        pos	Total
	
ni         37	37 
p/f         11	11 
pf         11	11 
pm/pf          1	1 
	
Total         60	60 



I see a pretty map in your future….:)

*link these with the household data for gps points.


Some of the potential aims we discussed today were to: 
1) Describe the epidemiology of malaria infection in children of this cohort
- ages, where they live, basic demographics, environmental factors

2) Describe the demographics of children who suffer from repeat infections (AIC)
- are they spatially clustered, ages, where do they live
- how many of the A visit malaria kids have positive smears on the B visit? 

3) Look at characteristics of healthy kids over time (HCC)
- do they have subpatent malaria? 
- what are their demographics, where do they live? Is it age related? 

4) Subpatent malaria versus full malaria parasitemia 
- do they having varying levels of parasitemia on smears? 
- do the subpatent malaria kids have less malaria infections? 

Any thoughts/data you may have on this would be most appreciated - I have tons of reading to do to get oriented about the subject.  Thanks again and hope you have very happy holidays!

*/

 
 set graphics on
 local import "C:\Users\amykr/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/longitudinal_analysis_sept152016/"cd "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\CSVs nov29_16\output"
capture log close log using "R01_nov2_16.smcl", text replace set scrollbufsize 100000set more 1insheet using "C:\Users\amykr/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/CSVs nov29_16/chulaimbo aic.csv", comma clear namescapture drop *od* followupaliquotid_*
dropmiss, forcesave "chulaimbo_aic", replaceinsheet using "C:\Users\amykr/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/CSVs nov29_16/chulaimbo hcc.csv", comma clear namescapture drop *od* followupaliquotid_*
dropmiss, forcesave "chulaimbo_hcc", replaceinsheet using "C:\Users\amykr/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/CSVs nov29_16/kisumu aic.csv", comma clear namescapture drop *od* followupaliquotid_*
dropmiss, forcesave "kisuma_aic", replaceinsheet using "C:\Users\amykr/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/CSVs nov29_16/kisumu hcc.csv", comma clear namescapture drop *od* followupaliquotid_*
dropmiss, forcesave "kisumu_hcc", replaceinsheet using "C:\Users\amykr/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/CSVs nov29_16/milalani hcc.csv", comma clear namescapture drop *od* followupaliquotid_*
dropmiss, forcesave "milalani_hcc", replaceinsheet using "C:\Users\amykr/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/CSVs nov29_16/Msambweni  AIC.csv", comma clear namescapture drop *od* followupaliquotid_*dropmiss, forcesave "msambweni_aic", replaceinsheet using "C:\Users\amykr/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/CSVs nov29_16/nganja hcc.csv", comma clear namescapture drop *od* followupaliquotid_*dropmiss, forcesave "nganja_hcc", replaceinsheet using "C:\Users\amykr/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/CSVs nov29_16/ukunda aic.csv", comma clear namescapture drop *od* followupaliquotid_*dropmiss, forcesave "ukunda_aic", replaceinsheet using "C:\Users\amykr/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/CSVs nov29_16/ukunda hcc.csv", comma clear namescapture drop *od* followupaliquotid_*dropmiss, forcesave "ukunda_hcc", replaceclearforeach dataset in "chulaimbo_aic.dta" "kisumu_hcc.dta"  "chulaimbo_hcc.dta" "kisuma_aic.dta" "milalani_hcc.dta" "msambweni_aic.dta" "nganja_hcc.dta" "ukunda_aic.dta" "ukunda_hcc.dta"{use `dataset', clearcapture drop villhouse_acapture destring personid_a, replacesave `dataset', replace}append using "chulaimbo_aic.dta" "kisumu_hcc.dta"  "chulaimbo_hcc.dta" "kisuma_aic.dta" "milalani_hcc.dta" "msambweni_aic.dta" "nganja_hcc.dta" "ukunda_aic.dta"save temp, replacedropmiss*drop denvigg_e drop if studyid_a =="example"drop if studyid_a =="EXAMPLE"drop if studyid_a =="Example"
save appended_september20.dta, replacereplace studyid_a = followupid_b if studyid_a ==""	/*foreach var of varlist date*{		capture confirm string var `var'			if _rc==0 {						gen double my`var'= date(`var',"DMY")						format my`var' %td						drop `var'						}			else {						gen double my`var'= `var'						format my`var' %td						#drop `var'				}							}	ds my*, not	foreach var of var `r(varlist)'{		tostring `var', replace 		replace `var'=lower(`var')		rename `var', lower		}							ds my*, not	foreach var of var `r(varlist)'{		tostring `var', replace		replace `var'=lower(`var')		rename `var', lower	}	*/
			replace studyid_a =lower(studyid_a)			replace studyid_a= subinstr(studyid_a, ".", "",.) 			replace studyid_a= subinstr(studyid_a, "/", "",.)			replace studyid_a= subinstr(studyid_a, " ", "",.)*			drop if studyid_a==""			bysort  studyid_a: gen dup_merged = _n 	tab dup_merged	list studyid_a if dup_merged>1	tempfile merged	save merged, replace	*keep those that i dropped for duplicate and show to elysse	keep if dup_merged >1		export excel using "`save'dup", firstrow(variables) replace	use merged.dta, clear	gen dupkey = "dup" if dup_merged >1	egen studyid_adup = concat(studyid_a dupkey dup_merged) if dup_merged >1	replace studyid_a = studyid_adup if studyid_adup !=""	drop dupkey	drop if dup_merged >1	tempfile mergedsave merged, replace*take visit out of id						forval i = 1/3 { 							gen id`i' = substr(studyid_a, `i', 1) 						}*gen id_wid without visit						 	rename id1 city  	rename id2 id_cohort  	rename id3 id_visit 	tab id_visit 
		gen id_childnumber = ""	replace id_childnumber = substr(studyid_a, +4, .)	order id_cohort city id_visit id_childnumber studyid_a	egen id_wide = concat(city id_cohort id_childnum)ds, has(type string) foreach v of varlist `r(varlist)' { 	replace `v' = lower(`v') } tempfile widesave wide, replace	bysort id_wide: gen dup2 = _n 	save wide, replace		keep if dup2 >1		export excel using "dup2", firstrow(variables) replaceuse wide.dta, clear
	gen dupkey = "dup" if dup2 >1	egen id_widedup = concat(id_wide dupkey dup2) if dup2 >1	*replace id_wide = id_widedup if id_widedup !=""	drop if dup2>1
	*gen begindate = datesamplecollected_a if datesamplecollected_a !=.	reshape long chikvigg_ denvigg_  stanforddenvigg_  datesamplecollected_ datesamplerun_ studyid_ followupaliquotid_ chikviggod_ denviggod_ stanfordchikvod_  stanfordchikvigg_ stanforddenvod_ aliquotid_  chikvpcr_ chikvigm_ denvpcr_ denvigm_ stanforddenviggod_ followupid_ antigenused_ , i(id_wide) j(VISIT) string	*format datesamplecollected_* %td	*format begindate %td	tempfile long	save long, replace		use long.dta, clear	drop if id_wide==""/*	ds date*, not	foreach var of var `r(varlist)'{		tostring `var', replace 		replace `var'=lower(`var')		rename `var', lower
			}
	*/		capture drop _mergesave elisas, replace************************************add RDT data***********************************import excel "/Users/amykrystosik/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/longitudinal_analysis_sept152016/DENGUE RDT RESULTS Aug 30th august 2016.xls", sheet("Sheet3") firstrow clear*import excel "/Users/amykrystosik/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/RDT/sammy case control oct 23.xls", sheet("cases ") firstrow clear*insheet using "/Users/amykrystosik/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/RDT/sammy data oct 23.csv", comma clear namesinsheet using "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\RDT\sammy data nov4.csv", comma clear namesrename studynumber study_idrename igm dengueigm_sammyrename igg dengue_igg_sammytempfile ns1save ns1, replace*take visit out of id						forval i = 1/3 { 							gen id`i' = substr(study_id, `i', 1) 						}*gen id_wid without visit						 	gen city  = id1 	gen id_cohort = id2 	gen VISIT = id3	tab VISIT	gen id_childnumber = ""	replace id_childnumber = substr(study_id, +4, .)	order id_cohort city study_id id_childnumber 	egen id_wide = concat(city id_cohort id_childnum)	foreach var of varlist _all{		rename `var', lower}	ds *t*, not	foreach var of var `r(varlist)'{		tostring `var', replace 		replace `var'=lower(`var')		rename `var', lower		}		foreach var of varlist date*{		*capture destring `var', replace		capture gen double my`var'= date(`var',"DMY")		capture format my`var' %td		drop `var'}	ds my*, not	foreach var of var `r(varlist)'{		tostring `var', replace 		replace `var'=lower(`var')		rename `var', lower	}		ds my*, not	foreach var of var `r(varlist)'{	replace `var' =trim(itrim(lower(`var')))	}replace nsi = "0" if nsi =="n eg"save ns1, replace
rename visit VISITbysort id_wide VISIT: gen dup =_n
drop if dup>1
drop dupmerge 1:1 id_wide VISIT using elisas.dta
rename VISIT visitpreservekeep if _merge ==1 export excel using "sammyonly", firstrow(variables) replacerestorebysort dengueigm_sammy visit: tab stanforddenvigg_bysort dengueigm_sammy visit: tab denvigg_preservekeep if _merge ==1 |_merge ==3keep study_id nsi stanforddenvigg_ denvigg_ dengueigm_sammy dengue_igg_sammy visit _merge export excel using "sammy_comparison", firstrow(variables) replacekeep if _merge ==3save sammy_jael, replace
restorecapture drop _mergesave elisas_PCR_RDT, replace************************************add PRNT data**********************************import excel "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\longitudinal_analysis_sept152016/LaBeaud RESULTS - july 2016.xls", sheet("2016 PRNT-Msambweni Results") cellrange(A2:E154) firstrow cleartempfile PRNT_Msambweni save PRNT_Msambweni, replaceimport excel "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\longitudinal_analysis_sept152016/LaBeaud RESULTS - july 2016.xls", sheet("2016 PRNT-Ukunda Results") cellrange(A2:F80) firstrow cleartempfile PRNT_Ukundasave PRNT_Ukunda, replaceforeach dataset in "PRNT_Msambweni" "PRNT_Ukunda"{use "`dataset'", clear		replace ALIQUOTELISAID= subinstr(ALIQUOTELISAID, " ", "",.)		*take visit out of id								forval i = 1/3 { 									gen id`i' = substr(ALIQUOTELISAID, `i', 1) 								}		*gen id_wid without visit						 			gen city  = id1 			gen id_cohort = id2 			gen visit = id3			tab visit			gen id_childnumber = ""			replace id_childnumber = substr(ALIQUOTELISAID, +4, .)			destring id_childnumber, replace			gen str4 id_childnumber4 = string(id_childnumber,"%04.0f")						order id_cohort city ALIQUOTELISAID id_childnumber4 
			
			egen id_wide = concat(city id_cohort id_childnumber4)					*recode prnt values as pos(20+)/ neg	foreach var of varlist _all{		rename `var', lower}	foreach var of var _all{		tostring `var', replace 		replace `var'=lower(`var')		rename `var', lower		}		foreach var of var _all{		tostring `var', replace 		replace `var'=lower(`var')		rename `var', lower	}			foreach var of var _all{			replace `var' =trim(itrim(lower(`var')))	}		 foreach v of varlist  denv2 wnv chikv onnv{			  replace `v' = "pos" if `v' == "40"|`v' == ">80"|`v' == "20"			  replace `v' = "neg" if `v' == "10"|`v' == "<10"			  replace `v' = "" if `v' == "no sample"|`v' == "no sample received at cdc"|`v' == ""		   tab `v', m		   }   		   		   rename  denv2 denv_prnt		   rename  wnv wnv_prnt 		   rename  chikv chikv_prnt 		   rename  onnv onnv_prnt	save "`dataset'", replace}use "PRNT_Msambweni", clear*merge with elisas.dtacapture drop _mergemerge 1:m id_wide visit using elisas_PCR_RDT.dtadrop _mergetempfile elisas_PCR_RDT_PRNT1capture drop _mergesave elisas_PCR_RDT_PRNT1, replaceuse PRNT_Ukunda, clear*merge with elisas.dtacapture drop _mergemerge 1:m id_wide visit using elisas_PCR_RDT_PRNT1.dtadrop _mergetempfile elisas_PCR_RDT_PRNT2save elisas_PCR_RDT_PRNT2, replace*******declare data as panel data***********	ds my*, not	foreach var of var `r(varlist)'{		tostring `var', replace 		replace `var'=lower(`var')		replace `var' =trim(itrim(lower(`var')))		rename `var', lower	}	encode id_wide, gen(id)sort visitdrop if visit =="a2"encode visit, gen(visit_s)replace city ="c" if city =="r" bysort  id visit_s: gen dup_visit = _n 
drop if dup_visit >1xtset id visit_s	save longitudinal.dta, replace	   					replace city  = "Chulaimbo" if city == "c"						replace city  = "Msambweni" if city == "m"						replace city  = "Kisumu" if city == "k"						replace city  = "Ukunda" if city == "u"						replace city  = "Milani" if city == "l"						replace city  = "Nganja" if city == "g"					gen westcoast= "." 						replace westcoast = "Coast" if city =="Msambweni"|city =="Ukunda"|city =="Milani"|city =="Nganja"						replace westcoast = "West" if city =="Chulaimbo"|city =="Kisumu"					encode westcoast, gen(site)									drop stanforddenviggod_ stanfordchikvod_ stanforddenvod_foreach var of varlist stanford*{ 	replace `var' =trim(itrim(lower(`var')))	gen `var'_result =""	replace `var'_result = "neg" if strpos(`var', "neg")	replace `var'_result = "pos" if strpos(`var', "pos") 	drop `var'	rename `var'_result `var'	tab `var'}*simple prevalence/incidence by visitsave temp, replace*lagg igg by one visitdestring id visit_s, replace*xtset id visit_ssort id visit_s/*capture drop mydate_year mydate_month mydate_day*add year and month to merge with rain and vector dataforeach var of varlist my*{	gen `var'_year = year(`var')	gen `var'_month = month(`var')	gen `var'_day = day(`var')}rename  mydatesamplecollected__year yearrename mydatesamplecollected__month monthrename mydatesamplecollected__day day*/*merge m:1 year month day city using merged_enviro.dtacapture drop _merge*save lab_enviro, replacedrop visitrename visit_s visitcapture drop dup_mergeddrop v28

drop if visit ==2 
drop if visit >4
save lab, replace

use all_interviews.dta, clear
drop visit
encode id_visit, gen(visit)
*replace visit = visit +1
*replace visit = visit -1 if visit ==2
save all_interviews.dta, replace
*drop v18 v19 v20
merge 1:1 id_wide visit using lab.dta
drop _merge


*save lab_enviro_interviews, replace	foreach var in dengueigm_sammy nsi chikv_prnt denv_prnt denvpcr_ chikvpcr{			tab `var', gen(`var'encode)} capture gen igmns1pos=. replace igmns1 = 1 if dengueigm_sammyencode2 == 1 & nsiencode1 == 1  replace igmns1 = 0 if dengueigm_sammyencode2 == 0 & nsiencode1 == 0    *add time 0 so we can estimate the prevelance in the surival curve too. set dengue and chik =. /*capture drop x			expand 2 if visit == 1, gen(x)			gsort id visit -x			replace visit= visit- 1 if x == 1			foreach var of varlist *denv* {			tostring `var', replace 				replace `var'= "." if x == 1			}			foreach var of varlist *chikv* {			tostring `var', replace 				replace `var'= "." if x == 1				}			*/gen prevalentchikv = .gen prevalentdenv = .encode stanfordchikvigg_, gen(stanfordchikviggencode)rename stanfordchikviggencode CHIKVPOSreplace CHIKVPOS = . if CHIKVPOS==1replace CHIKVPOS = 1 if CHIKVPOS==3replace CHIKVPOS = 0 if CHIKVPOS==2tab CHIKVPOS, nolablabel define CHIKVPOS 0 "Negative" 1 "Positive", replaceencode stanforddenvigg_, gen(stanforddenviggencode)rename stanforddenviggencode DENVPOSreplace DENVPOS = . if DENVPOS ==1replace DENVPOS = 1 if DENVPOS ==3replace DENVPOS = 0 if DENVPOS ==2tab DENVPOS, nolablabel define DENVPOS 0 "Negative" 1 "Positive", replacedrop stanford* rename DENVPOS Stanford_DENV_IGGrename CHIKVPOS Stanford_CHIKV_IGGreplace prevalentdenv = 1 if  Stanford_DENV_IGG ==1 & visit ==1replace prevalentchikv = 1 if  Stanford_CHIKV_IGG ==1 & visit ==1replace id_cohort = "HCC" if id_cohort == "c"|id_cohort == "d"		replace id_cohort = "AIC" if id_cohort == "f"|id_cohort == "m" 		capture drop cohort		encode id_cohort, gen(cohort)		bysort cohort  city: sum Stanford_DENV_IGG Stanford_CHIKV_IGGsave prevalent, replace	*chikv matched prevalence	use prevalent, clear		keep if visit == 1 & Stanford_CHIKV_IGG!=.		save visit_a_chikv, replace	use prevalent, clear		keep if visit == 3 & Stanford_CHIKV_IGG!=.		save visit_b_chikv, replace				merge 1:1 id_wide using visit_a_chikv		rename _merge abvisit		keep abvisit visit id_wide		merge 1:1 id_wide visit using prevalent		keep if abvisit ==3 & Stanford_CHIKV_IGG!=.
		keep studyid  id_wide site visit antigenused_ city Stanford_CHIKV_IGG cohort gender datesamplecollected_ dob  agemonths childage age gender  Stanford_CHIK~G Stanford_DENV~G visit datesamplecol~_ 		export excel using "C:\Users\amykr\Box Sync/DENV CHIKV project/Personalized Datasets/Amy/CSVs nov216/prevalent_visitab_chikv", firstrow(variables) replace		*denv matched prevalence	use prevalent, clear		keep if visit == 1 & Stanford_DENV_IGG!=.		save visit_a_denv, replace	use prevalent, clear		keep if visit == 3 & Stanford_DENV_IGG!=.		save visit_b_denv, replace				merge 1:1 id_wide using visit_a_denv		rename _merge abvisit		keep abvisit id_wide visit		merge 1:1 id_wide visit using prevalent		keep if abvisit ==3 & Stanford_DENV_IGG!=.		keep studyid  id_wide site visit antigenused_ city Stanford_DENV_IGG cohort gender datesamplecollected_ dob agemonths childage age gender  Stanford_CHIK~G Stanford_DENV~G visit datesamplecol~_		export excel using "C:\Users\amykr\Box Sync/DENV CHIKV project/Personalized Datasets/Amy/CSVs nov216/prevalent_visitab_denv", firstrow(variables) replace		*denv prevlaneceuse prevalent, clear

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
drop pos_neg*

label values malariaresults malariaresults
label define malariaresult 0 "negative" 1 "+" 2 "++" 3 "+++" 4 "++++"

replace city = id_city if city ==""
replace city = "Chulaimbo" if city =="c"
replace city = "Kisumu" if city =="k"
replace city = "Mililani" if city =="l"
replace city = "Msambweni" if city =="m"
replace city = "Ukunda" if city =="u"
replace city = "Nganga" if city =="g"
 
sum malaria* Stanford*
tab malariaresults 
bysort city: sum malaria* Stanford*
bysort city: tab malariaresults 

bysort  id_wide: gen repeatoffender = _n if malariabloodsmear ==1
bysort id_wide : egen max=max(repeatoffender)
bysort id_wide : replace repeatoffender =. if repeatoffender!=max



sum repeatoffender if repeatoffender >1
order repeat id_wide visit malariabloodsmear
* 1675 repeat offenders from 2-7 visits. 
bysort city: sum repeatoffender if repeatoffender >1 
* 836 in chulaimbo,  838 in kisumu, 1 in r

foreach var in interviewdate2 {
gen `var'1 = date(`var', "MDY" ,2050)
format %td `var'1 
drop `var'
rename `var'1 `var'
recast int `var'
}


replace interviewdate = interviewdate2 if interviewdate ==.
drop interviewdate2 

gen agecalc = interviewdate - dob if interviewdate !=. & dob!=.
replace agecalc = agecalc/360
replace agecalc = . if agecalc < 0
gen agecalc2 = round(agecalc)
drop agecalc
rename agecalc2 agecalc
 
replace age2 = childage if age2==.
replace age2 = age if age2==.
replace age2 = agecalc if age2==.
drop age agecalc childage
rename age2 age

foreach var in datesamplecollected_ {
gen `var'1 = date(`var', "MDY" ,2050)
format %td `var'1 
drop `var'
rename `var'1 `var'
recast int `var'
}


replace interviewdate = datesamplecollected_ if interviewdate ==.

/*
*extract year from today
gen interviewyear= "."
replace interviewyear= substr(interviewdate, -2,.)
replace interviewyear = "." if interviewyear=="/a"

gen interviewmonth= "."
replace interviewmonth = "1" if strpos(interviewdate, "jan")
replace interviewmonth = "2" if strpos(interviewdate, "feb")
replace interviewmonth = "3" if strpos(interviewdate, "mar")
replace interviewmonth = "4" if strpos(interviewdate, "apr")
replace interviewmonth = "5" if strpos(interviewdate, "may")
replace interviewmonth = "6" if strpos(interviewdate, "jun")
replace interviewmonth = "7" if strpos(interviewdate, "jul")
replace interviewmonth = "8" if strpos(interviewdate, "aug")
replace interviewmonth = "9" if strpos(interviewdate, "sep")
replace interviewmonth = "10" if strpos(interviewdate, "oct")
replace interviewmonth = "11" if strpos(interviewdate, "nov")
replace interviewmonth = "12" if strpos(interviewdate, "dec")
replace interviewmonth= substr(interviewdate, 1,2) if interviewmonth=="."
replace interviewmonth = "." if interviewmonth =="n"

replace interviewmonth= substr(interviewdate, 1,1) if strpos(interviewdate, "/")|strpos(interviewdate, "-")
gen century = 20
egen interviewyearb = concat(century interviewyear) if interviewyear!="" & interviewyear!="."
replace interviewyear = interviewyearb
drop interviewyearb
replace interviewmonth = "." if interviewmonth =="n"

destring interviewmonth interviewyear, replace
*/

gen interviewmonth =month(interviewdate)
gen interviewyear =year(interviewdate)

gen season = . 
replace season =1 if interviewmonth >=1 & interviewmonth <=3 & season ==.
*label define 1 "hot no rain from mid december"
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
replace city = "Nganja" if city =="Nganga" 
replace city = "Mililani" if city =="Milani"
replace city = "Chulaimbo" if city =="r"

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

rename pos_neg malariapos_neg
rename pos_neg1 malariapos_neg1

save malariadenguemerged, replace

***
**create village and house id so we can merge with gis points
gen villageid=""
replace villageid = substr(id_wide, +1, 1)
replace villageid = "3" if villageid =="g"
replace villageid = "4" if villageid =="l"
destring villageid, replace

gen houseid2 = ""
replace houseid2 = substr(id_wide, -6, 3) if cohort ==3
destring houseid2, replace
replace houseid = houseid2 if houseid==. & houseid2!=.
order studyid houseid villageid
drop _merge
tostring houseid, replace
save malariadenguemerged, replace

*****************merge with gis points

import excel "C:\Users\amykr\Box Sync/DENV CHIKV project/Coast Cleaned/Demography/Demography Latest/Msambweni_coordinates complete Nov 21 2016.xls", sheet("Sheet1") firstrow clear

tostring Villhouse , replace
save xy2, replace
save xy1, replace

import excel "C:\Users\amykr\Box Sync/DENV CHIKV project/Coast Cleaned/Demography/Demography Latest/Ukunda demography_coordinates August 2016.xls", sheet("demo") firstrow clear
encode keep_livestock , gen(keep_livestock_int)
drop keep_livestock 
rename keep_livestock_int keep_livestock 

gen motor_vehicleint = . 
replace motor_vehicleint =0 if motor_vehicle =="no"
replace motor_vehicleint =1 if motor_vehicle =="yes"
replace motor_vehicleint =8 if motor_vehicle =="refused"
drop motor_vehicle
rename motor_vehicleint motor_vehicle

gen domestic_workerint = . 
replace domestic_workerint =0 if domestic_worker =="no"
replace domestic_workerint =1 if domestic_worker =="yes"
drop domestic_worker 
rename domestic_workerint domestic_worker
save xy2, replace

import excel "C:\Users\amykr\Box Sync\DENV CHIKV project\West Cleaned\Demography\Demography Latest/West Demography Database", sheet("Sheet1") firstrow clear
save xy3, replace

tostring toilet_latrine latrine_location latrine_distance , replace 

append using xy1 xy2
save xy, replace

gen houseid  = string(House,"%04.0f")
rename Village villageid
order houseid villageid
drop if villageid ==.
bysort houseid villageid: gen dup =_n
egen duphouse = concat(houseid dup) if dup>1
replace houseid = duphouse if dup>1
tostring villageid, replace
merge 1:1 villageid houseid using malariadenguemerged
******

stop


preserve
collapse (sum) Stanford_CHIKV_IGG Stanford_DENV_IGG, by(id_wide city)
gen denvexposed = . 
gen chikvexposed = . 
bysort id_wide: replace chikvexposed = 1 if Stanford_CHIKV_IGG >0 &Stanford_CHIKV_IGG<.
bysort id_wide: replace denvexposed  = 1 if Stanford_DENV_IGG >0 & Stanford_DENV_IGG<.
tab chikvexposed city, m
tab denvexposed city, m
restore


*keep if Stanford_DENV_IGG!=.keep studyid id_wide site visit antigenused_ city village Stanford_DENV_IGG cohort age prevalentdenv studyid_ igg_* pcr_* gender datesamplecollected_ dob agemonths childage gender  Stanford_CHIK~G Stanford_DENV~G visit datesamplecol~_ malaria*
*export excel using "/Users/amykrystosik/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/CSVs nov216/prevalent_denv", firstrow(variables) replacesave prevalentdenv, replace*denv incidenceuse prevalentdenv, cleardrop if prevalentdenv == 1 keep studyid id_wide site visit antigenused_ city village Stanford_DENV_IGG cohort age studyid_ igg_* pcr_* gender datesamplecollected_ dob agemonths childage gender  Stanford_CHIK~G Stanford_DENV~G visit datesamplecol~_*export excel using "/Users/amykrystosik/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/CSVs nov216/incidentdenv", firstrow(variables) replacesave incidentdenv, replace*chikv prevalenceuse prevalent, clear*keep if Stanford_CHIKV_IGG!=.keep studyid  id_wide site visit antigenused_ city village Stanford_CHIKV_IGG cohort age prevalentchikv studyid_ igg_* pcr_* gender datesamplecollected_ dob agemonths childage  gender  Stanford_CHIK~G Stanford_DENV~G visit datesamplecol~_
*export excel using "/Users/amykrystosik/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/CSVs nov216/prevalentchikv", firstrow(variables) replacesave prevalentchikv, replace*chikv incidenceuse prevalentchikv, cleardrop if prevalentchikv == 1 keep studyid id_wide site visit antigenused_ city village Stanford_CHIKV_IGG cohort age studyid_ igg_* pcr_* gender datesamplecollected_ dob agemonths childage gender  Stanford_CHIK~G Stanford_DENV~G visit datesamplecol~_*export excel using "/Users/amykrystosik/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/CSVs nov216/incidentchikv", firstrow(variables) replacesave incidentchikv, replace
/*************************************************survival and longitudinal analysis********************************************foreach dataset in  "incidentdenv" "prevalentdenv"{use `dataset', clear		label variable cohort "Cohort"		label variable city "City"		label define City 1 "Chulaimbo" 2 "Kisumu" 3 "Milani" 5 "Nganja" 6 "Ukunda"save `dataset', replacedrop if visit ==0foreach v of varlist Stanford_DENV_IGG igg_* pcr_*{	tabout visit city `v' using `v'_tab.xls, replace}}foreach dataset in "incidentchikv" "prevalentchikv" "incidentdenv" "prevalentdenv"{use `dataset', clear		label variable cohort "Cohort"		label variable city "City"
		
		replace city = "Msambweni" if city =="Milani" | city =="Nganja"
				*label define City 1 "Chulaimbo" 2 "Kisumu" 3 "Milani" 5 "Nganja" 6 "Ukunda"save `dataset', replacedrop if visit ==0foreach v of varlist Stanford_* {	tabout visit city `v' using `v'_tab.xls, replace}}foreach dataset in "incidentchikv" "prevalentchikv" "incidentdenv" "prevalentdenv"{
	use `dataset', clear	
	
	foreach failvar of varlist Stanford_* pcr_denv igg_*{
											**********survival***************											preserve
						keep if cohort ==2						stset visit, id(id) failure(`failvar')				stdescribe
					
				if r(N_fail) > 0{
				display "number of failure events = "r(N_fail)							
				
										stsum						sts graph, cumhaz risktable censored(single) title(`failvar') ylabel(minmax, format(%5.3f)) ymtick(##5, tlength(scheme tick)) xlabel(, format(%td)) xlabel(, angle(45)) xmtick(##5, tlength(scheme tick)) 								graph export "cumhaz`dataset'`failvar'date.tif", width(4000) replace						sts graph, cumhaz risktable censored(single) title(`failvar') by(city) ylabel(minmax, format(%5.3f)) ymtick(##5, tlength(scheme tick)) xlabel(, format(%td)) xlabel(, angle(45)) xmtick(##5, tlength(scheme tick)) 								graph export "cumhaz`dataset'`failvar'citydate.tif", width(4000) replace						sts graph, cumhaz risktable censored(single) title(`failvar') by(site) ylabel(minmax, format(%5.3f)) ymtick(##5, tlength(scheme tick)) xlabel(, format(%td)) xlabel(, angle(45)) xmtick(##5, tlength(scheme tick)) 								graph export "cumhaz`dataset'`failvar'sitedate.tif", width(4000) replace												sts graph, survival risktable censored(single) title(`failvar') ylabel(minmax, format(%5.3f)) ymtick(##5, tlength(scheme tick)) xlabel(, format(%td)) xlabel(, angle(45)) xmtick(##5, tlength(scheme tick)) 						graph export "survival`dataset'`failvar'date.tif", width(4000) replace						sts list, survival						sts graph, risktable censored(single) title(`failvar') by(site) ylabel(minmax, format(%5.3f)) ymtick(##5, tlength(scheme tick)) xlabel(, format(%td)) xlabel(, angle(45)) xmtick(##5, tlength(scheme tick)) 						graph export "survivalsite`dataset'`failvar'date.tif", width(4000) replace						sts graph, risktable censored(single) title(`failvar') by(city) ylabel(minmax, format(%5.3f)) ymtick(##5, tlength(scheme tick)) xlabel(, format(%td)) xlabel(, angle(45)) xmtick(##5, tlength(scheme tick)) 						graph export "survivalcity`dataset'`failvar'date.tif", width(4000) replace												stset visit, id(id) failure(`failvar')						stdescribe						stsum						sts graph, cumhaz risktable tmax(11) censored(single) title(`failvar') ylabel(minmax, format(%5.3f))  ymtick(##5,  tlength(scheme tick))						graph export "cumhaz`dataset'`failvar'visit.tif", width(4000) replace						sts graph, survival risktable tmax(11) censored(single) title(`failvar')  ylabel(minmax, format(%5.3f))ymtick(##5,  tlength(scheme tick))						graph export "survival`dataset'`failvar'visit.tif", width(4000) replace						sts list, survival						sts graph, risktable tmax(11)  censored(single) title(`failvar') by(site) ylabel(minmax, format(%5.3f))ymtick(##5,  tlength(scheme tick))						graph export "survivalsite`dataset'`failvar'visit.tif", width(4000) replace						sts graph, risktable tmax(11) censored(single) title(`failvar') by(city) ylabel(minmax, format(%5.3f))ymtick(##5,  tlength(scheme tick))						graph export "survivalcity`dataset'`failvar'visit.tif", width(4000) replace
						}											
			restore
			}			
							destring `failvar', replace 			preserve																capture keep if date ==.									capture keep date id									outsheet using no_dates`var', comma replace			restore
			preserve											*drop if `failvar' >= .
														di missing(`failvar')
														di `failvar'							collapse (mean) `failvar' (count) n=`failvar' (sd) sd`failvar'=`failvar', by(cohort visit)
							egen axis = axis(visit)							generate hi`failvar'= `failvar' + invttail(n-1,0.025)*(sd`failvar'/ sqrt(n))							generate lo`failvar'= `failvar'- invttail(n-1,0.025)*(sd`failvar'/ sqrt(n))										graph twoway ///						   || (bar `failvar' axis, sort )(rcap hi`failvar' lo`failvar' axis) ///						   || scatter `failvar' axis, ms(i) mlab(n) mlabpos(2) mlabgap(2) mlabangle(45) mlabcolor(black) mlabsize(4) ///						   || , by(cohort) ylabel(, format(%5.3f)) ymtick(#4,  tlength(scheme tick)) legend(label(1 "`failvar'") label(2 "95% CI")) xlabel(0 (1) 3)   title(`dataset' by cohort and visit)						 graph export "`dataset'`failvar'visitcohort1.tif", width(4000) replace 			restore							preserve									*drop if `failvar' == .
							di missing(`failvar')
							di `failvar'							collapse (mean) `failvar' (count) n=`failvar' (sd) sd`failvar'=`failvar', by(cohort city)							egen axis = axis(city)							generate hi`failvar'= `failvar' + invttail(n-1,0.025)*(sd`failvar'/ sqrt(n))							generate lo`failvar'= `failvar'- invttail(n-1,0.025)*(sd`failvar'/ sqrt(n))						graph twoway ///						   || (bar `failvar' axis, sort )(rcap hi`failvar' lo`failvar' axis) ///						   || scatter `failvar' axis, ms(i) mlab(n) mlabpos(2) mlabgap(2) mlabangle(45) mlabcolor(black) mlabsize(4) ///						   || , by(cohort) ylabel(, format(%5.4f)) ymtick(#4,  tlength(scheme tick)) legend(label(1 "`failvar'") label(2 "95% CI")) xlabel(1(1)4, valuelabel  angle(45))  title(`dataset' by cohort and city)							graph export "`dataset'`failvar'citycohort.tif", width(4000) replace 			restore					}
						else {						display "no failure events"			
				}	
										foreach dataset in "incidentdenv" "prevalentdenv"{	use `dataset', clearforeach failvar of varlist Stanford_* pcr_denv igg_*{
										**********survival***************							
									stdescribe
					
				if r(N_fail) > 0{
				display "number of failure events = "r(N_fail)							
				

			preserve 						keep if cohort ==2						stset visit, id(id) failure(`failvar')						stdescribe						stsum						sts graph, cumhaz risktable censored(single) title(`failvar') ylabel(minmax, format(%5.3f)) ymtick(##5, tlength(scheme tick)) xlabel(, format(%td)) xlabel(, angle(45)) xmtick(##5, tlength(scheme tick)) 								graph export "cumhaz`dataset'`failvar'date.tif", width(4000) replace						sts graph, cumhaz risktable censored(single) title(`failvar') by(city) ylabel(minmax, format(%5.3f)) ymtick(##5, tlength(scheme tick)) xlabel(, format(%td)) xlabel(, angle(45)) xmtick(##5, tlength(scheme tick)) 								graph export "cumhaz`dataset'`failvar'citydate.tif", width(4000) replace						sts graph, cumhaz risktable censored(single) title(`failvar') by(site) ylabel(minmax, format(%5.3f)) ymtick(##5, tlength(scheme tick)) xlabel(, format(%td)) xlabel(, angle(45)) xmtick(##5, tlength(scheme tick)) 								graph export "cumhaz`dataset'`failvar'sitedate.tif", width(4000) replace												sts graph, survival risktable censored(single) title(`failvar') ylabel(minmax, format(%5.3f)) ymtick(##5, tlength(scheme tick)) xlabel(, format(%td)) xlabel(, angle(45)) xmtick(##5, tlength(scheme tick)) 						graph export "survival`dataset'`failvar'date.tif", width(4000) replace						sts list, survival						sts graph, risktable censored(single) title(`failvar') by(site) ylabel(minmax, format(%5.3f)) ymtick(##5, tlength(scheme tick)) xlabel(, format(%td)) xlabel(, angle(45)) xmtick(##5, tlength(scheme tick)) 						graph export "survivalsite`dataset'`failvar'date.tif", width(4000) replace						sts graph, risktable censored(single) title(`failvar') by(city) ylabel(minmax, format(%5.3f)) ymtick(##5, tlength(scheme tick)) xlabel(, format(%td)) xlabel(, angle(45)) xmtick(##5, tlength(scheme tick)) 						graph export "survivalcity`dataset'`failvar'date.tif", width(4000) replace												stset visit, id(id) failure(`failvar')						stdescribe						stsum						sts graph, cumhaz risktable tmax(11) censored(single) title(`failvar') ylabel(minmax, format(%5.3f))  ymtick(##5,  tlength(scheme tick))						graph export "cumhaz`dataset'`failvar'visit.tif", width(4000) replace						sts graph, survival risktable tmax(11) censored(single) title(`failvar')  ylabel(minmax, format(%5.3f))ymtick(##5,  tlength(scheme tick))						graph export "survival`dataset'`failvar'visit.tif", width(4000) replace						sts list, survival						sts graph, risktable tmax(11)  censored(single) title(`failvar') by(site) ylabel(minmax, format(%5.3f))ymtick(##5,  tlength(scheme tick))						graph export "survivalsite`dataset'`failvar'visit.tif", width(4000) replace						sts graph, risktable tmax(11) censored(single) title(`failvar') by(city) ylabel(minmax, format(%5.3f))ymtick(##5,  tlength(scheme tick))						graph export "survivalcity`dataset'`failvar'visit.tif", width(4000) replace															restore 
									destring `failvar', replace 								preserve																capture keep if date ==.									capture keep date id									outsheet using no_dates`var', comma replace								restore															preserve									*drop if `failvar' == .
														di missing(`failvar')
														di `failvar'							collapse (mean) `failvar' (count) n=`failvar' (sd) sd`failvar'=`failvar', by(cohort visit)							egen axis = axis(visit)							generate hi`failvar'= `failvar' + invttail(n-1,0.025)*(sd`failvar'/ sqrt(n))							generate lo`failvar'= `failvar'- invttail(n-1,0.025)*(sd`failvar'/ sqrt(n))						graph twoway ///						   || (bar `failvar' axis, sort )(rcap hi`failvar' lo`failvar' axis) ///						   || scatter `failvar' axis, ms(i) mlab(n) mlabpos(2) mlabgap(2) mlabangle(45) mlabcolor(black) mlabsize(4) ///						   || , by(cohort) ylabel(, format(%5.3f)) ymtick(#4,  tlength(scheme tick)) legend(label(1 "`failvar'") label(2 "95% CI")) xlabel(0 (1) 3)   						 graph export "`dataset'`failvar'visitcohort1.tif", width(4000) replace 				restore								preserve									*drop if `failvar' == .
													di missing(`failvar')
														di `failvar'							collapse (mean) `failvar' (count) n=`failvar' (sd) sd`failvar'=`failvar', by(cohort city)							egen axis = axis(city)							generate hi`failvar'= `failvar' + invttail(n-1,0.025)*(sd`failvar'/ sqrt(n))							generate lo`failvar'= `failvar'- invttail(n-1,0.025)*(sd`failvar'/ sqrt(n))						graph twoway ///						   || (bar `failvar' axis, sort )(rcap hi`failvar' lo`failvar' axis) ///						   || scatter `failvar' axis, ms(i) mlab(n) mlabpos(2) mlabgap(2) mlabangle(45) mlabcolor(black) mlabsize(4) ///						   || , by(cohort) ylabel(, format(%5.4f)) ymtick(#4,  tlength(scheme tick)) legend(label(1 "`failvar'") label(2 "95% CI")) xlabel(1(1)4, valuelabel  angle(45))  title(`dataset' by cohort and city)							graph export "`dataset'`failvar'citycohort.tif", width(4000) replace 				restore				}				
			else {						display "no failure events"			
				}		
							}	
			}
