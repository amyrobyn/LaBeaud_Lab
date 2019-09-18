*Kenya_datamanagment_step2_R01_vs16
set more off
*log using "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Log\Kenya_datamanagment_step2_R01_vs14.log", replace

*Author: C.J.Alberts 
*Funding: R01 NIH, entitled xxxx

clear
use "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_12Dec18.dta"
count

*******************************************************************************
**Table of contents
*******************************************************************************
**VisitLetter
**VisitLetter-2
**visitnr
**city
**site
**outcome variables - DENV/CHIKV IgG and PCR
**Gender
**Date of birth
**Blood drawn
*******************************************************************************

*******************************************************************************

*******************************************************************************
*Explore who are in the dataset and drop those that will not be included in the analyses
*******************************************************************************

*VisitLetter
gen SecondLetterPersonID=substr(person_id,2,1)
ta SecondLetterPersonID, m

*VisitLetter
gen visitLetter2=substr(redcap_event_name,7,2)
ta visitLetter2, m

*Mail april x, amy, drop u24
drop if visitLetter2=="u2"
*drop x2 visits as they don't have any lab information
drop if visitLetter2=="a2"
drop if visitLetter2=="b2"
drop if visitLetter2=="c2"
drop if visitLetter2=="d2"
ta visitLetter2, m

*Visitnr
gen visitnr=.
replace visitnr=0 if visitLetter2=="t_"
replace visitnr=1 if visitLetter2=="a_"
replace visitnr=2 if visitLetter2=="b_"
replace visitnr=3 if visitLetter2=="c_"
replace visitnr=4 if visitLetter2=="d_"
replace visitnr=5 if visitLetter2=="e_"
replace visitnr=6 if visitLetter2=="f_"
replace visitnr=7 if visitLetter2=="g_"
replace visitnr=8 if visitLetter2=="h_"
ta visitnr visitLetter2, m

*Drop if visitLetter2=="t_"

********************************************************************************
*Generate Site variable 
********************************************************************************
ta city, m
des city
replace city="" if city=="NA"
destring city, replace
ta city, m
des city
label define lbl_city 1 "Chulaimbo/Chulaimbo Health Centre" 					///
2 "Kisumu/Obama Childrens Hospital" 3 "Msambweni/Msambweni District Hospital" 	///
4 "Ukunda/Ukunda Health Centre" 5 "Mbaka Oromo"
label val city lbl_city
ta city, m

*As city has a lot of missings, I am going to use the first letter
*of the ID as proxy (I do know there are some discrepancies)

gen FirstLetterPersonID=substr(person_id,1,1)
ta FirstLetterPersonID, m
ta FirstLetterPersonID city, m


*C/R/CMB = Chulaimbo --> also contains mbaka oromo and chulaimbo health center
*K = Kisumu --> obama hostpital
*M/G/L = Msambwenid
*U = Ukunda
generate cityID=.
*Chulaimbo
replace cityID=1 if FirstLetterPersonID=="C"
replace cityID=1 if FirstLetterPersonID=="R"
replace cityID=1 if FirstLetterPersonID=="CMB"
*Kisumu
replace cityID=2 if FirstLetterPersonID=="K"
*Msambweni
replace cityID=3 if FirstLetterPersonID=="M"
replace cityID=3 if FirstLetterPersonID=="G"
replace cityID=3 if FirstLetterPersonID=="L"
*Ukundu
replace cityID=4 if FirstLetterPersonID=="U"
*Mbaka, this does not seem to have a code in the datalibrary
*based on the cross tab individuals categorized as R could go
*into Chulaimbo and Mbaka
*For now I only go by what is reported in city
label val cityID lbl_city
*replace cityID=5 if city==5
*These persons will for now be categorized as chulaimbo


*******************************************************************************
*Generate coast versus west
*******************************************************************************

gen siteID=.
*Urban west --> Kisumu
replace siteID=1 if cityID==2
*Rural west --> Chulaimbo
replace siteID=2 if cityID==1
*Urban Coast/east --> Ukundu
replace siteID=3 if cityID==4
*Rural Coast/east --> Msambweni
replace siteID=4 if cityID==3
label define lbl_siteID 1 "urban west" 2 "rural west" 3 "urban coast" 4 "rural coast"
label val siteID lbl_siteID
ta siteID cityID, m
ta siteID, m

gen siteID2=.
replace siteID2=1 if cityID==2
replace siteID2=1 if cityID==1
replace siteID2=2 if cityID==4
replace siteID2=2 if cityID==3
label define lbl_siteID2 1 "west" 2 "coast"
label val siteID2 lbl_siteID2
ta siteID2 cityID, m
ta siteID2, m

gen siteID3=.
replace siteID3=1 if siteID==1
replace siteID3=1 if siteID==3
replace siteID3=2 if siteID==2
replace siteID3=2 if siteID==4
label define lbl_siteID3 1 "urban" 2 "rural"
label val siteID3 lbl_siteID3
ta siteID3 siteID, m
ta siteID3, m

*******************************************************************************
*Generate cohort variable 
*******************************************************************************

ta cohort, m
des cohort
replace cohort="" if cohort=="NA"
destring cohort, replace
label define lbl_cohort 1 "AIC" 2 "HCC"
label val cohort lbl_cohort
ta cohort, m
*as this is incomplete I am going to generate cohort based on id

gen cohortID=.
replace cohortID=1 if SecondLetterPersonID=="F"
replace cohortID=2 if SecondLetterPersonID=="C"
label val cohortID lbl_cohort
ta cohortID SecondLetterPersonID, m
ta cohortID, m



*******************************************************************************
**Generate outcome variables
*******************************************************************************
label define lbl_posneg 0 "neg" 1 "pos"

*******************************************************************************
**Chikv - IgG 
*******************************************************************************
*raw variables
ta result_igg_chikv_kenya, m    //result_igg_chikv_kenya
ta result_igg_chikv_stfd, m		//Result IgG CHIKV Stanford
*0 Negative
*1 Positive
*98 Repeat

ta result_igg_chikv_kenya result_igg_chikv_stfd, m

ta result_igg_chikv_kenya 	siteID2 , m
ta result_igg_chikv_stfd 	siteID2 , m

*generate outcome, only stanford
gen chikv_igg_y=.
*First use stanford serology
replace chikv_igg_y=0 if result_igg_chikv_stfd=="0"
replace chikv_igg_y=1 if result_igg_chikv_stfd=="1"
ta chikv_igg_y result_igg_chikv_stfd, m //check
label var chikv_igg_y "CHIKV igg based on stfd"
label val chikv_igg_y lbl_posneg
ta chikv_igg_y, m

*******************************************************************************
**Chikv - PCR
*******************************************************************************
ta  result_pcr_chikv_stfd, m //Result PCR CHIKV Stanford
ta  result_pcr_chikv_kenya, m //Result PCR CHIKV Kenya
* 0 Negative
* 1 Positive

ta  chikv_result_ufi, m //Chikungunya virus result
*0 Negative
*1 Positive
*98 Equivocal

*tests done by melissa
ta chikv_result_ufi2, m

ta chikv_result_ufi chikv_result_ufi2, m

ta result_pcr_chikv_stfd siteID2 	if cohortID==1, m
ta result_pcr_chikv_kenya siteID2 	if cohortID==1, m
ta chikv_result_ufi siteID2 		if cohortID==1, m

*browse person_id redcap_event_name result_pcr_chikv_kenya date_tested_pcr_chikv_kenya if result_pcr_chikv_kenya!="NA"
*See e-mail David and Carren: Subject: 	Re: PCR data questions; Date: Sun, 18 Nov 2018 21:17:00 +0300
des date_tested_pcr_chikv_kenya
gen date_tested_pcr_chikv_kenya2 = date(date_tested_pcr_chikv_kenya, "YMD")
format date_tested_pcr_chikv_kenya2 %td
ta result_pcr_chikv_kenya if result_pcr_chikv_kenya!="NA" & date_tested_pcr_chikv_kenya2<date("20171121","YMD")
count if result_pcr_chikv_kenya!="NA" & date_tested_pcr_chikv_kenya2<date("20171121","YMD")
ta result_pcr_chikv_kenya if result_pcr_chikv_kenya!="NA" & date_tested_pcr_chikv_kenya2>=date("20171121","YMD") & date_tested_pcr_chikv_kenya2!=.
count if result_pcr_chikv_kenya!="NA" & date_tested_pcr_chikv_kenya2>=date("20171121","YMD") & date_tested_pcr_chikv_kenya2!=.
ta result_pcr_chikv_kenya if result_pcr_chikv_kenya!="NA" & date_tested_pcr_chikv_kenya2==.
count if result_pcr_chikv_kenya!="NA" & date_tested_pcr_chikv_kenya2==.

gen chikv_pcr_y=.
replace chikv_pcr_y=0 if result_pcr_chikv_stfd=="0"
replace chikv_pcr_y=0 if result_pcr_chikv_kenya=="0" & date_tested_pcr_chikv_kenya2>=date("20171121","YMD") & date_tested_pcr_chikv_kenya2!=.
replace chikv_pcr_y=0 if chikv_result_ufi=="0" 
replace chikv_pcr_y=0 if chikv_result_ufi2=="0" 

replace chikv_pcr_y=1 if result_pcr_chikv_stfd=="1"
replace chikv_pcr_y=1 if result_pcr_chikv_kenya=="1" & date_tested_pcr_chikv_kenya2>=date("20171121","YMD") & date_tested_pcr_chikv_kenya2!=.
replace chikv_pcr_y=1 if chikv_result_ufi=="1" 
replace chikv_pcr_y=1 if chikv_result_ufi2=="1" 

label var chikv_pcr_y "CHIKV pcr based on stfd and kenya"
label val chikv_pcr_y lbl_posneg
ta chikv_pcr_y result_pcr_chikv_stfd, m
ta chikv_pcr_y result_pcr_chikv_kenya, m
ta chikv_pcr_y chikv_result_ufi, m
ta chikv_pcr_y, m
ta chikv_pcr_y

gen chikvPCRtestYN=.
replace chikvPCRtestYN=0 if chikv_pcr_y==.
replace chikvPCRtestYN=1 if chikv_pcr_y!=.
label define lbl_chikvPCRtestYN 0 "not tested" 1 "tested"
label val chikvPCRtestYN lbl_chikvPCRtestYN
ta chikvPCRtestYN chikv_pcr_y, m
ta chikvPCRtestYN, m
ta chikvPCRtestYN visitLetter2, m col

*******************************************************************************
**DENV - IgG
*******************************************************************************
*raw variables
ta result_igg_denv_kenya , m 	//Result IgG DENV Kenya
ta result_igg_denv_stfd, m		//result_igg_denv_stfd
* 0 Negative
* 1 Positive
**by cohort
ta result_igg_denv_kenya , m
ta result_igg_denv_stfd, m
bysort cohortID: ta result_igg_denv_kenya 	siteID , m
bysort cohortID: ta result_igg_denv_stfd	siteID, m

gen denv_igg_y=.
replace denv_igg_y=0 if result_igg_denv_stfd=="0"
replace denv_igg_y=1 if result_igg_denv_stfd=="1"
ta denv_igg_y result_igg_denv_stfd, m //check
label var denv_igg_y "DENV igg based on stfd"
label val denv_igg_y lbl_posneg
ta denv_igg_y, m

*******************************************************************************
**DENV - PCR
*******************************************************************************
ta result_pcr_denv_stfd, m 	//Result PCR DENV Stanford
ta result_pcr_denv_kenya, m //Result PCR DENV Kenya
* 0 Negative
* 1 Positive
ta denv_result_ufi, m
*0 Negative
*1 Positive
*98 Equivocal

bysort cohortID: ta result_pcr_denv_kenya 	siteID, m
bysort cohortID: ta result_pcr_denv_stfd 	siteID, m //as already known, pcr is not done in the HCC cohort
bysort cohortID: ta denv_result_ufi 	siteID, m
*may 18th, the samples from the coast are not tested for pcr yet at stanford


*browse person_id redcap_event_name result_pcr_chikv_kenya date_tested_pcr_chikv_kenya if result_pcr_chikv_kenya!="NA"
*See e-mail David and Carren: Subject: 	Re: PCR data questions; Date: Sun, 18 Nov 2018 21:17:00 +0300
des date_tested_pcr_denv_kenya
gen date_tested_pcr_denv_kenya2 = date(date_tested_pcr_denv_kenya, "YMD")
format date_tested_pcr_denv_kenya2 %td
ta result_pcr_denv_kenya if result_pcr_denv_kenya!="NA" & date_tested_pcr_denv_kenya2<date("20171121","YMD")
count if result_pcr_denv_kenya!="NA" & date_tested_pcr_denv_kenya2<date("20171121","YMD")
ta result_pcr_denv_kenya if result_pcr_denv_kenya!="NA" & date_tested_pcr_denv_kenya2>=date("20171121","YMD") & date_tested_pcr_denv_kenya2!=.
count if result_pcr_denv_kenya!="NA" & date_tested_pcr_denv_kenya2>=date("20171121","YMD") & date_tested_pcr_denv_kenya2!=.
ta result_pcr_denv_kenya if result_pcr_denv_kenya!="NA" & date_tested_pcr_denv_kenya2==.
count if result_pcr_denv_kenya!="NA" & date_tested_pcr_denv_kenya2==.

gen denv_pcr_y=.
replace denv_pcr_y=0 if result_pcr_denv_stfd=="0"
replace denv_pcr_y=0 if result_pcr_denv_kenya=="0" 
replace denv_pcr_y=0 if denv_result_ufi=="0" 
replace denv_pcr_y=0 if denv_result_ufi2=="0" 
replace denv_pcr_y=1 if result_pcr_denv_stfd=="1"
replace denv_pcr_y=1 if result_pcr_denv_kenya=="1" 
replace denv_pcr_y=1 if denv_result_ufi=="1" 
replace denv_pcr_y=1 if denv_result_ufi2=="1" 
label var denv_pcr_y "DENV pcr based on stfd and kenya"
label val denv_pcr_y lbl_posneg
ta denv_pcr_y result_pcr_denv_stfd, m //check
ta denv_pcr_y result_pcr_denv_kenya, m //check
ta denv_pcr_y denv_result_ufi, m //check
ta denv_pcr_y, m
ta denv_pcr_y

gen denvPCRtestYN=.
replace denvPCRtestYN=0 if denv_pcr_y==.
replace denvPCRtestYN=1 if denv_pcr_y!=.
label define lbl_denvPCRtestYN 0 "not tested" 1 "tested"
label val denvPCRtestYN lbl_denvPCRtestYN
ta denvPCRtestYN denv_pcr_y, m
ta denvPCRtestYN, m

*******************************************************************************
*One overall variable whether pcr was tested Y/N
gen pcr_tested=0
replace pcr_tested=1 if denv_pcr_y!=.
replace pcr_tested=1 if chikv_pcr_y!=.
ta pcr_tested, m
ta pcr_tested chikv_pcr_y, m
ta pcr_tested denv_pcr_y, m

*******************************************************************************
*One overall variable whether igg was tested Y/N
gen igg_tested=0
replace igg_tested=1 if denv_igg_y!=.
replace igg_tested=1 if chikv_igg_y!=.
ta igg_tested, m
ta igg_tested chikv_igg_y, m
ta igg_tested denv_igg_y, m

*******************************************************************************


*******************************************************************************
**Create one overall date
*******************************************************************************
*browse person_id redcap_event_name dem_interviewdate interview_date_aic interview_date
rename interview_date interview_date_hcc
des dem_interviewdate interview_date_aic interview_date_hcc

*recategorize as empty
replace dem_interviewdate="" if dem_interviewdate=="NA" 
replace interview_date_aic="" if interview_date_aic=="NA"
replace interview_date_hcc="" if interview_date_hcc=="NA"

*convert variable from string into date-variables
gen dem_interviewdate2 = date(dem_interviewdate, "YMD")
format dem_interviewdate2 %td
gen interview_date_aic2 = date(interview_date_aic, "YMD")
format interview_date_aic2 %td
gen interview_date_hcc2 = date(interview_date_hcc, "YMD")
format interview_date_hcc2 %td
des dem_interviewdate2 interview_date_aic2 interview_date_hcc2

*Generate year variable
gen yr=.
*replace yr=year(dem_interviewdate2)
replace yr=year(interview_date_aic2) if yr==.
replace yr=year(interview_date_hcc2) if yr==.
replace yr=year(interview_date_hcc2) if yr==.
ta yr, m

*drop if yr==1900
*drop if yr==.
ta yr, m

*generate month variable
gen mth=.
*replace mth=month(dem_interviewdate2)
replace mth=month(interview_date_aic2) if mth==.
replace mth=month(interview_date_hcc2) if mth==.
ta mth, m

*generate day variable
gen day=.
*replace day=day(dem_interviewdate2)
replace day=day(interview_date_aic2) if day==.
replace day=day(interview_date_hcc2) if day==.
ta day, m

*generate one overall date-variable
gen date_complete=.
*replace date_complete=dem_interviewdate2
replace date_complete=interview_date_aic2 if date_complete==.
replace date_complete=interview_date_hcc2 if date_complete==.
replace date_complete=. if yr==1900
format date_complete %td
summ date_complete, d
	
*We want date to be empty for "t_" visit
replace date_complete=. if visitLetter2=="t_"
********************************************************************************
*Gender
********************************************************************************
ta gender_aic, m
replace gender_aic="" if gender_aic=="NA"

ta gender, m
rename gender gender_hcc
replace gender_hcc="" if gender_hcc=="NA"

ta dem_child_gender, m
replace dem_child_gender="" if dem_child_gender=="NA"
*This variable is empty

*according to dictionary
*0 = male
*1 = female

ta gender_hcc gender_aic, m //no overlap so does not need to do it separatly per cohort

gen gender=.
replace gender=0 if gender_hcc=="0" & gender==. 
replace gender=1 if gender_hcc=="1" & gender==. 
replace gender=0 if gender_aic=="0" & gender==. 
replace gender=1 if gender_aic=="1" & gender==. 
ta gender gender_aic, m
ta gender gender_hcc, m
*expand
sort person_id visitnr
bysort person_id: carryforward gender, replace
gsort person_id -visitnr
bysort person_id: carryforward gender, replace
sort person_id visitnr
ta gender, m

gen diffgender=.
sort person_id visitnr
by person_id: replace diffgender=1 if gender[_n]!=gender[_n+1] & gender[_n+1]!=. & visitnr!=0
ta diffgender, m
browse person_id visitnr gender diffgender

*As there are still some inconsistancies I am using the first gender reported
gen gender2=.
forval i=1/8{
sort person_id visitnr
by person_id: replace gender2=gender if gender2==. & visitnr==`i' 

*expand
sort person_id visitnr
bysort person_id: carryforward gender2, replace
gsort person_id -visitnr
bysort person_id: carryforward gender2, replace
sort person_id visitnr
}
*
ta gender2, m

gen diffgender2=.
sort person_id visitnr
by person_id: replace diffgender2=1 if gender2[_n]!=gender2[_n+1] & gender2[_n+1]!=.
ta diffgender2, m
drop diffgender2

drop gender
label define lbl_gender2 0 "male" 1 "female"
label val gender2 lbl_gender2
ta gender2, m


********************************************************************************
*Date of birth 
********************************************************************************
*browse person_id redcap_event_name dem_child_dob date_of_birth_aic date_of_birth
*Notice that everyone born before 1997 should be dropped from analyses!

*First change into date-variable

*Date of birth I
replace date_of_birth="" 		if date_of_birth=="NA"
gen date_of_birth2 = date(date_of_birth, "YMD")
format date_of_birth2 %td
gen yr_date_of_birth2=year(date_of_birth2)
summ yr_date_of_birth2, d

bysort person_id (date_of_birth2): gen diff_date_of_birth2=1 if  date_of_birth2[1]!=date_of_birth2[_N]
ta diff_date_of_birth2, m
drop diff_date_of_birth2

sort person_id visitnr
bysort person_id: carryforward date_of_birth2, gen(carryfrw_date_of_birth2)
gsort person_id -visitnr
bysort person_id: carryforward carryfrw_date_of_birth2, gen(carryfrw2_date_of_birth2)
format carryfrw2_date_of_birth2 %td
bysort cohortID: summ carryfrw2_date_of_birth2, d

*Date of birth II
replace dem_child_dob="" 		if dem_child_dob=="NA"
gen dem_child_dob2 = date(dem_child_dob, "YMD")
format dem_child_dob2 %td
gen yr_dem_child_dob2=year(dem_child_dob2)
summ yr_dem_child_dob2, d

bysort person_id (dem_child_dob): gen diffdem_child_dob=1 if dem_child_dob[1]!=dem_child_dob[_N]
ta diffdem_child_dob, m
drop diffdem_child_dob

sort person_id visitnr
bysort person_id: carryforward dem_child_dob2, gen(carryfrw_dem_child_dob2)
gsort person_id -visitnr
bysort person_id: carryforward carryfrw_dem_child_dob2, gen(carryfrw2_dem_child_dob2)
list person_id yr_dem_child_dob2 carryfrw2_dem_child_dob2 if carryfrw2_dem_child_dob2<1997
drop if person_id=="UC1046905"
drop if person_id=="UC2101205"

*Date of birth III
replace date_of_birth_aic="" 	if date_of_birth_aic=="NA"
gen date_of_birth_aic2 = date(date_of_birth_aic, "YMD")
format date_of_birth_aic2 %td
gen yr_date_of_birth_aic2=year(date_of_birth_aic2)
summ yr_date_of_birth_aic2, d

bysort person_id (date_of_birth_aic): gen diffdate_of_birth_aic=1 if date_of_birth_aic[1]!=date_of_birth_aic[_N]
ta diffdate_of_birth_aic, m
drop diffdate_of_birth_aic

sort person_id visitnr
bysort person_id: carryforward date_of_birth_aic2, gen(carryfrw_date_of_birth_aic2)
gsort person_id -visitnr
bysort person_id: carryforward carryfrw_date_of_birth_aic2, gen(carryfrw2_date_of_birth_aic2)
list person_id yr_date_of_birth_aic2 carryfrw2_date_of_birth_aic2 if carryfrw2_date_of_birth_aic2<1997
drop if person_id=="MF0018"
drop if person_id=="UF0116"
drop if person_id=="UF0232"

*Any other inconsisntancies
list date_of_birth2 dem_child_dob2 date_of_birth_aic2 if date_of_birth2!=dem_child_dob2 & date_of_birth2!=. & dem_child_dob2!=.
list date_of_birth2 dem_child_dob2 date_of_birth_aic2 if date_of_birth2!=date_of_birth_aic2 & date_of_birth2!=. & date_of_birth_aic2!=.
list date_of_birth2 dem_child_dob2 date_of_birth_aic2 if dem_child_dob2!=date_of_birth_aic2 & dem_child_dob2!=. & date_of_birth_aic2!=.

gen dob=.
format dob %td
replace dob=date_of_birth2 if dob==.
replace dob=date_of_birth_aic2 if dob==.
replace dob=dem_child_dob2 if dob==. //I am not sure if this is the right variable to use, but it is better than nothing therefore used as last one to fill
summ dob,d
sort person_id visitnr
bysort person_id: carryforward dob, gen(dob2)
gsort person_id -visitnr
bysort person_id: carryforward dob2, gen(dob3)
summ dob3, d
drop dob dob2
rename dob3 dob

gen diffdob=.
sort person_id visitnr
by person_id: replace diffdob=1 if dob[_n]!=dob[_n+1] & dob[_n+1]!=. & visitnr!=0
ta diffdob, m
browse person_id visitnr dob diffdob
*

*browse person_id visitnr nrRecHCC nrRecAIC dob2 diffdob2 date_of_birth dem_child_dob date_of_birth_aic

*Still too many inconsistancies, so I am using the old strategy in which I take the first birth reported in the dataset
sort person_id visitnr
gen dob2=.
forval i=1/8{
replace dob2=date_of_birth2 if dob2==. & visitnr==`i' 

*expand
sort person_id visitnr
bysort person_id: carryforward dob2, replace
gsort person_id -visitnr
bysort person_id: carryforward dob2, replace
sort person_id visitnr

replace dob2=date_of_birth_aic2 if  dob2==. & visitnr==`i' 

*expand
sort person_id visitnr
bysort person_id: carryforward dob2, replace
gsort person_id -visitnr
bysort person_id: carryforward dob2, replace
sort person_id visitnr

replace dob2=dem_child_dob2 if dob2==. & visitnr==`i' 

*expand
sort person_id visitnr
bysort person_id: carryforward dob2, replace
gsort person_id -visitnr
bysort person_id: carryforward dob2, replace
sort person_id visitnr
}
*
format dob2 %td

*Check for inconsistancies
gen diffdob2=.
sort person_id visitnr
by person_id: replace diffdob2=1 if dob2[_n]!=dob2[_n+1] & dob2[_n+1]!=. & visitnr!=0
ta diffdob2, m
*
drop diffdob dob

gen yr_dob2=year(dob2)
summ yr_dob2, d
ta yr_dob2 yr, m

*I am using 2015 as a reference, if we would use 2014 we would have kids who are -1
*we want just to have an age variable to be able to compare the calendar years for the descriptives
gen age2015yrs=2015-yr_dob2
ta age2015yrs, m

gen age2015Cat=.
replace age2015Cat=3 if yr_dob2>=1997 & yr_dob2<2006
replace age2015Cat=2 if yr_dob2>=2006 & yr_dob2<2011
replace age2015Cat=1 if yr_dob2>=2011 & yr_dob2!=.
label define lbl_age2015Cat 1 "0-4" 2 "5-9" 3 "10-15"
label val age2015Cat lbl_age2015Cat
ta yr_dob2 age2015Cat, m
ta age2015Cat, m

gen age2014Cat=.
replace age2014Cat=3 if yr_dob2>=1997 & yr_dob2<2005
replace age2014Cat=2 if yr_dob2>=2005 & yr_dob2<2010
replace age2014Cat=1 if yr_dob2>=2010 & yr_dob2!=.
label define lbl_age2014Cat 1 "0-4" 2 "5-9" 3 "10-15"
label val age2014Cat lbl_age2014Cat
ta yr_dob2 age2014Cat, m
ta age2014Cat, m

gen age=.
replace age=date_complete-dob2 //stata ignores missings
replace age=age/365.25
gen ageyrs=int(age)
summ ageyrs, d

gen ageCat=.
replace ageCat=1 if  ageyrs<3
replace ageCat=2 if  ageyrs>=3 & ageyrs<5 
replace ageCat=3 if  ageyrs>=5 & ageyrs<8
replace ageCat=4 if  ageyrs>=8 & ageyrs<13
replace ageCat=5 if  ageyrs>=13 & ageyrs!=.
label define lbl_ageyrsCnst 1 "0-2" 2 "3-4" 3 "5-7" 4 "8-12" 5 ">=13"
label val ageCat lbl_ageyrsCnst
ta ageyrs ageCat , m

********************************************************************************
**Blood drawn:
********************************************************************************
ta sample_igg_chikv_kenya, m //Is a sample available for testing?
ta result_igg_chikv_kenya, m //Result IgG CHIKV Kenya; 0=Neg, 1=Pos, 98=Repeat
ta sample_igg_denv_kenya, m
ta result_igg_denv_kenya, m

gen bloodDrawn=0
replace bloodDrawn=1 if sample_igg_chikv_kenya!="NA"
replace bloodDrawn=1 if result_igg_chikv_kenya!="NA"
replace bloodDrawn=1 if sample_igg_denv_kenya!="NA"
replace bloodDrawn=1 if result_igg_denv_kenya!="NA"
replace bloodDrawn=1 if denv_pcr_y!=.
replace bloodDrawn=1 if denv_igg_y!=.
replace bloodDrawn=1 if chikv_pcr_y!=.
replace bloodDrawn=1 if chikv_igg_y!=.

ta bloodDrawn sample_igg_chikv_kenya, m
ta bloodDrawn result_igg_chikv_kenya, m
ta bloodDrawn sample_igg_denv_kenya, m
ta bloodDrawn result_igg_denv_kenya, m

ta bloodDrawn denv_pcr_y, m
ta bloodDrawn denv_igg_y, m
ta bloodDrawn chikv_pcr_y, m
ta bloodDrawn chikv_igg_y, m

ta bloodDrawn, m	
ta bloodDrawn cohortID, m

drop if bloodDrawn==0 & visitLetter2!="t_"
ta visitLetter2, m
*We need "t_" visits as it contains SES data for HCC

********************************************************************************
**Create nthRec in full database 
********************************************************************************
save "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_temp.dta", replace
clear

use "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_temp.dta", replace
drop if visitLetter2=="t_"
sort person_id visitnr
bysort person_id: gen nthRec=_n
ta nthRec, m
ta nthRec visitLetter, m

keep person_id redcap_event_name nthRec

save "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_temp_nthRec.dta", replace
clear

use "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_temp.dta"

merge m:1 person_id redcap_event_name using "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_temp_nthRec.dta"
drop _merge

numlabel, add
save "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_step2.dta", replace
clear
