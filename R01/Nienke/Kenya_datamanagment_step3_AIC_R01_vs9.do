*Kenya_datamanagment_step3_AIC_R01_vs9
set more off
*log using "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Log\Kenya_datamanagment_step3_AIC_R01_vs5.log", replace

*Author: C.J.Alberts 
*Funding: R01 NIH, entitled xxxx

clear
use "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_step2.dta"
count

ta cohortID, m
keep if cohortID==1
ta cohortID, m

*As far as I understand there should be no census data for the AIC cohort
ta visitLetter2, m
drop if visitLetter2=="t_"

*******************************************************************************
**Table of contents
*******************************************************************************
**Fever
**Acute case
**Flow variable
**House hold characteristics
**Self-reported exposure + protective behavior
**Severity disease
**Doctors reported symptoms during visit
**Self-reported travel behavior

********************************************************************************
**Fever
********************************************************************************
ta symptoms_aic, m
gen fever=""
replace fever="fever" if regexm(symptoms_aic, "fever")
ta fever, m

gen fever2=0
replace fever2=1 if fever=="fever"
replace temp="" if temp=="NA"
destring temp, replace
replace fever2=1 if temp>=38 & temp!=.
ta fever2 fever, m
ta fever fever2 , m
ta temp fever2 , m
ta fever2 pcr_tested, m

*******************************************************************************
**Acute case
******************************************************************************
gen acuteCase=0

******************************************************************************
*Categorized as acutely ill based on visity_type
ta visit_type, m
*1 Initial visit, first enrollment
*2 Initial visit, re-enrollment
*3 Scheduled one month follow-up
*4 Sick visit prior to scheduled follow up
*5 Repeat follow up (patient was febrile during scheduled follow up)

replace acuteCase=1 if visit_type=="1" 
replace acuteCase=1 if visit_type=="2"
replace acuteCase=1 if visit_type=="4"
replace acuteCase=1 if visit_type=="5"
ta acuteCase, m

******************************************************************************
*if they have information on an initial survey question (see odk aic inital and follow up forms), it is an initial visit and therefore acute.
ta kid_highest_level_education_aic, m
replace acuteCase=1 if kid_highest_level_education_aic!="NA" 

ta occupation_aic, m
replace acuteCase=1 if occupation_aic!="NA" 

ta oth_educ_level_aic, m
replace oth_educ_level_aic="NA" if oth_educ_level_aic==""

ta oth_educ_level_aic, m
replace acuteCase=1 if oth_educ_level_aic!="NA" 

ta mom_highest_level_education_aic, m
replace acuteCase=1 if mom_highest_level_education_aic!="NA"  

ta roof_type, m
replace acuteCase=1 if roof_type!="NA" 

ta pregnant, m
replace acuteCase=1 if pregnant!="NA" 

ta acuteCase, m

*if it is visit a,call it acute
replace acuteCase=1 if redcap_event_name=="visit_a_arm_1"
ta acuteCase, m

******************************************************************************
*Has had fever today
ta acuteCase fever , m
replace acuteCase=1 if fever=="fever"
ta temp acuteCase if temp>=38, m
replace acuteCase=1 if temp>=38 & temp!=.
ta acuteCase, m

*******************
*PCR tests executed
replace acuteCase=1 if denv_pcr_y!=.
replace acuteCase=1 if chikv_pcr_y!=.

ta acuteCase, m
ta visitLetter acuteCase, m
ta nthRec acuteCase, m


****************************************************************************
*Drop records with funny id's

drop if person_id=="UF164"
drop if person_id=="UF095"
drop if person_id=="KF024"

****************************************************************************
*Drop records with same dates
gen tDiff=.
sort person_id date_complete nthRec
by person_id: replace tDiff=date_complete[_n+1]-date_complete[_n] if date_complete!=.
ta tDiff, m

**browse person_id redcap_event_name date_complete igg_tested denv_igg_y chikv_igg_y tDiff if tDiff==0
**browse person_id redcap_event_name date_complete igg_tested denv_igg_y chikv_igg_y  tDiff 

*Note I am dropping the follow-up visit without pcr data, but with the same date!!!!
*So be aware about in which record you saved tDiff==0
sort person_id date_complete visitnr visitLetter2
count if tDiff[_n-1]==0 & pcr_tested[_n]==0
drop if tDiff[_n-1]==0 & pcr_tested[_n]==0

drop tDiff
gen tDiff=.
sort person_id date_complete nthRec
by person_id: replace tDiff=date_complete[_n+1]-date_complete[_n] if date_complete!=.
ta tDiff, m

*I am not dropping as long as they are not the first visit
ta visitLetter2 tDiff if tDiff==0, m
ta tDiff nthRec if tDiff==0, m
count if tDiff==0 & pcr_tested==0 & visitLetter2!="a_" & nthRec!=1
drop if tDiff==0 & pcr_tested==0 & visitLetter2!="a_" & nthRec!=1

drop tDiff
gen tDiff=.
sort person_id date_complete nthRec
by person_id: replace tDiff=date_complete[_n+1]-date_complete[_n] if date_complete!=.
ta tDiff, m

*Yay! all tDiff gone

****************************************************************************
*Generate nthRecAIC
sort person_id date_complete visitnr visitLetter2
by person_id: gen nthRecAIC=_n
ta nthRecAIC visitLetter , m
ta nthRecAIC acuteCase , m
*19 non-acute records as first recorde!


****************************************************************************
*For futher analyses there is no point in keeping records without dates
*as we have no clue to who they belong to
drop if date_complete==. & visitLetter!="a_"
drop if yr==1900 

ta acuteCase, m
ta visitLetter acuteCase, m
ta nthRec acuteCase, m

****************************************************************************
*Generate nthRecAIC
sort person_id date_complete visitnr visitLetter2
drop nthRecAIC
by person_id: gen nthRecAIC=_n
ta nthRecAIC visitLetter , m
ta nthRecAIC acuteCase , m
*17 non-acute records as first recorde!

*****************************************************************************
*Drop records of which the first visit is non-acute
ta acuteCase visitLetter, m
drop if acuteCase==0 & visitLetter=="a_"

ta acuteCase, m
ta visitLetter acuteCase, m
ta nthRec acuteCase, m

****************************************************************************
*Generate nthRecAIC
sort person_id date_complete visitnr visitLetter2
drop nthRecAIC
by person_id: gen nthRecAIC=_n
ta nthRecAIC visitLetter , m
ta nthRecAIC acuteCase , m
*17 non-acute records as first recorde!

list person_id visitLetter2 pcr_tested if nthRecAIC==1 & acuteCase==0
*All b-visits without pcr-data, if I drop them other non-acute visits will move up
*better strategy?

*****************************************************************************
*Drop records of which the first visit is non-acute
ta acuteCase visitLetter, m
drop if acuteCase==0 & nthRecAIC==1

****************************************************************************
*Generate nthRecAIC
sort person_id date_complete visitnr visitLetter2
drop nthRecAIC
by person_id: gen nthRecAIC=_n
ta nthRecAIC visitLetter , m
ta nthRecAIC acuteCase , m
*Seems to work! No non-acute visits popped-up in the first record.
*So will leave it like this now, another strategy is to account for 
*non-acute first visits in the below syntax (which I am not doing now).


****************************************************************************
*Generate total number of records per person
egen totRec = total(cohortID==1), by(person_id)
ta totRec, m

****************************************************************************
*Define the records for the 'independent' acute visits
****************************************************************************

****************************************************************************
*Generate time difference between 1st visit and follow-up visit
sort person_id date_complete nthRecAIC
by person_id: gen tstartAcute1=date_complete if nthRecAIC==1
by person_id: carryforward tstartAcute1, replace
format tstartAcute1 %td

sort person_id date_complete nthRecAIC
gen tstopAcute1=date_complete if nthRecAIC!=1
format tstopAcute1 %td

gen tdiffAcute1=(tstopAcute1 - tstartAcute1) 

****************************************************************************
*Generate Acute variable
gen Acute=.

****************************************************************************
*First Acute visit
replace Acute=1 if nthRecAIC==1 

gen Acute1=0
replace Acute1=1 if nthRecAIC==1 & acuteCase==1
ta Acute1, m

*only visits >14d and <84d
replace Acute=1 if tdiffAcute1>=14 & tdiffAcute1<=84
ta Acute acuteCase if tdiffAcute1>=14 & tdiffAcute1<=84

*b visits without a date but with igg data should be included
replace Acute=1 if visitLetter=="b_" & date_complete==. & igg_tested==1 

****************************************************************************
*Identify when 2nd Acute visit starts

gen tempAcute84d=0
sort person_id date_complete nthRecAIC
by person_id: replace tempAcute84d=1 if acuteCase==1 & tdiffAcute1>84 & tdiffAcute1!=.
ta tempAcute84d, m
**browse person_id date_complete tdiffAcute1 acuteCase Acute1 tempAcute84d if Acute84d==1
**browse person_id date_complete tdiffAcute1 acuteCase Acute1 tempAcute84d

gen tempfirstFilled=.
sort person_id date_complete nthRecAIC
by person_id: replace tempfirstFilled=nthRecAIC[_n+1] if tempAcute84d[_n+1]==1 & tempfirstFilled[_n]==. & nthRecAIC[_n]==1
by person_id: replace tempfirstFilled=nthRecAIC[_n+2] if tempAcute84d[_n+2]==1 & tempfirstFilled[_n]==. & nthRecAIC[_n]==1
by person_id: replace tempfirstFilled=nthRecAIC[_n+3] if tempAcute84d[_n+3]==1 & tempfirstFilled[_n]==. & nthRecAIC[_n]==1
by person_id: replace tempfirstFilled=nthRecAIC[_n+4] if tempAcute84d[_n+4]==1 & tempfirstFilled[_n]==. & nthRecAIC[_n]==1
by person_id: replace tempfirstFilled=nthRecAIC[_n+5] if tempAcute84d[_n+5]==1 & tempfirstFilled[_n]==. & nthRecAIC[_n]==1
by person_id: replace tempfirstFilled=nthRecAIC[_n+6] if tempAcute84d[_n+6]==1 & tempfirstFilled[_n]==. & nthRecAIC[_n]==1
by person_id: replace tempfirstFilled=nthRecAIC[_n+7] if tempAcute84d[_n+7]==1 & tempfirstFilled[_n]==. & nthRecAIC[_n]==1
ta tempfirstFilled, m
sort person_id date_complete nthRecAIC
bysort person_id: carryforward tempfirstFilled, replace
ta tempfirstFilled, m

**browse person_id date_complete visitnr tdiffAcute1 acuteCase Acute1 tempAcute84d tempfirstFilled if Acute84d==1
**browse person_id date_complete visitnr tdiffAcute1 acuteCase Acute1 tempAcute84d tempfirstFilled

gen Acute2=.
sort person_id date_complete nthRecAIC
by person_id: replace Acute2=acuteCase if tempfirstFilled==nthRecAIC
ta Acute2, m

**browse person_id date_complete nthRecAIC tempfirstFilled tdiffAcute1 acuteCase tempAcute84d  Acute2

*Generate time difference between 2nd Acute visit and follow-up visit
sort person_id date_complete nthRecAIC
by person_id: gen tstartAcute2=date_complete if Acute2==1
format tstartAcute2 %td
by person_id: carryforward tstartAcute2, replace

sort person_id date_complete nthRecAIC
gen tstopAcute2=date_complete 
format tstopAcute2 %td

gen tdiffAcute2=(tstopAcute2 - tstartAcute2) 

**browse person_id date_complete nthRecAIC tempfirstFilled tdiffAcute1 acuteCase tempAcute84d  Acute2 tstartAcute2 tstopAcute2 tdiffAcute2

****************************************************************************
*Second acute
replace Acute=2 if tempfirstFilled==nthRecAIC

*only visits >14d and <84 d
replace Acute=2 if tdiffAcute2>=14 & tdiffAcute2<=84
ta Acute acuteCase if tdiffAcute2>=14 & tdiffAcute2<=84

**browse person_id date_complete nthRecAIC tempfirstFilled tdiffAcute1 acuteCase Acute tempAcute84d  Acute2 tstartAcute2 tstopAcute2 tdiffAcute2 

****************************************************************************
*Identify when 3th Acute visit starts

gen tempAcute3_84d=0
sort person_id date_complete nthRecAIC
by person_id: replace tempAcute3_84d=1 if acuteCase==1 & tdiffAcute2>84 & tdiffAcute2!=.
ta tempAcute3_84d, m
**browse person_id date_complete tdiffAcute2 acuteCase tempAcute3_84d if tempAcute3_84d==1
**browse person_id date_complete tdiffAcute2 acuteCase tempAcute3_84d 

gen tempfirstFilled_Act3=.
sort person_id date_complete nthRecAIC
by person_id: replace tempfirstFilled_Act3=nthRecAIC[_n+1] if tempAcute3_84d[_n+1]==1 & tempfirstFilled_Act3[_n]==. & nthRecAIC[_n]==1
by person_id: replace tempfirstFilled_Act3=nthRecAIC[_n+2] if tempAcute3_84d[_n+2]==1 & tempfirstFilled_Act3[_n]==. & nthRecAIC[_n]==1
by person_id: replace tempfirstFilled_Act3=nthRecAIC[_n+3] if tempAcute3_84d[_n+3]==1 & tempfirstFilled_Act3[_n]==. & nthRecAIC[_n]==1
by person_id: replace tempfirstFilled_Act3=nthRecAIC[_n+4] if tempAcute3_84d[_n+4]==1 & tempfirstFilled_Act3[_n]==. & nthRecAIC[_n]==1
by person_id: replace tempfirstFilled_Act3=nthRecAIC[_n+5] if tempAcute3_84d[_n+5]==1 & tempfirstFilled_Act3[_n]==. & nthRecAIC[_n]==1
by person_id: replace tempfirstFilled_Act3=nthRecAIC[_n+6] if tempAcute3_84d[_n+6]==1 & tempfirstFilled_Act3[_n]==. & nthRecAIC[_n]==1
by person_id: replace tempfirstFilled_Act3=nthRecAIC[_n+7] if tempAcute3_84d[_n+7]==1 & tempfirstFilled_Act3[_n]==. & nthRecAIC[_n]==1
ta tempfirstFilled_Act3, m
sort person_id date_complete nthRecAIC
bysort person_id: carryforward tempfirstFilled_Act3, replace
ta tempfirstFilled_Act3, m

**browse person_id date_complete visitnr tdiffAcute1 acuteCase Acute1 tempAcute3_84d tempfirstFilled_Act3 if Acute84d==1
**browse person_id date_complete visitnr tdiffAcute1 acuteCase Acute1 tempAcute3_84d tempfirstFilled_Act3

gen Acute3=.
sort person_id date_complete nthRecAIC
by person_id: replace Acute3=acuteCase if tempfirstFilled_Act3==nthRecAIC
ta Acute3, m

**browse person_id date_complete nthRecAIC tempfirstFilled_Act3 tdiffAcute1 acuteCase tempAcute3_84d  Acute3

*Generate time difference between 2nd Acute visit and follow-up visit
sort person_id date_complete nthRecAIC
by person_id: gen tstartAcute3=date_complete if Acute3==1
format tstartAcute3 %td
by person_id: carryforward tstartAcute3, replace

sort person_id date_complete nthRecAIC
gen tstopAcute3=date_complete 
format tstopAcute3 %td

gen tdiffAcute3=(tstopAcute3 - tstartAcute3) 

**browse person_id date_complete nthRecAIC tempfirstFilled_Act3 tdiffAcute1 acuteCase tempAcute3_84d  Acute3 tstartAcute3 tstopAcute3 tdiffAcute3

****************************************************************************
*Third acute
replace Acute=3 if tempfirstFilled_Act3==nthRecAIC

*only visits >14d and <84 d
replace Acute=3 if tdiffAcute3>=14 & tdiffAcute3<=84
ta Acute acuteCase if tdiffAcute3>=14 & tdiffAcute3<=84

**browse person_id date_complete nthRecAIC tempfirstFilled_Act3 tdiffAcute1 acuteCase Acute nien tempAcute3_84d  Acute3 tstartAcute3 tstopAcute3 tdiffAcute3 

****************************************************************************
*Identify when Fourth Acute visit starts

gen tempAcute4_84d=0
sort person_id date_complete nthRecAIC
by person_id: replace tempAcute4_84d=1 if acuteCase==1 & tdiffAcute3>84 & tdiffAcute3!=.
ta tempAcute4_84d, m
**browse person_id date_complete tdiffAcute2 acuteCase tempAcute4_84d if tempAcute4_84d==1
**browse person_id date_complete tdiffAcute2 acuteCase tempAcute4_84d 

gen tempfirstFilled_Act4=.
sort person_id date_complete nthRecAIC
by person_id: replace tempfirstFilled_Act4=nthRecAIC[_n+1] if tempAcute4_84d[_n+1]==1 & tempfirstFilled_Act4[_n]==. & nthRecAIC[_n]==1
by person_id: replace tempfirstFilled_Act4=nthRecAIC[_n+2] if tempAcute4_84d[_n+2]==1 & tempfirstFilled_Act4[_n]==. & nthRecAIC[_n]==1
by person_id: replace tempfirstFilled_Act4=nthRecAIC[_n+3] if tempAcute4_84d[_n+3]==1 & tempfirstFilled_Act4[_n]==. & nthRecAIC[_n]==1
by person_id: replace tempfirstFilled_Act4=nthRecAIC[_n+4] if tempAcute4_84d[_n+4]==1 & tempfirstFilled_Act4[_n]==. & nthRecAIC[_n]==1
by person_id: replace tempfirstFilled_Act4=nthRecAIC[_n+5] if tempAcute4_84d[_n+5]==1 & tempfirstFilled_Act4[_n]==. & nthRecAIC[_n]==1
by person_id: replace tempfirstFilled_Act4=nthRecAIC[_n+6] if tempAcute4_84d[_n+6]==1 & tempfirstFilled_Act4[_n]==. & nthRecAIC[_n]==1
by person_id: replace tempfirstFilled_Act4=nthRecAIC[_n+7] if tempAcute4_84d[_n+7]==1 & tempfirstFilled_Act4[_n]==. & nthRecAIC[_n]==1
ta tempfirstFilled_Act4, m
sort person_id date_complete nthRecAIC
bysort person_id: carryforward tempfirstFilled_Act4, replace
ta tempfirstFilled_Act4, m

**browse person_id date_complete visitnr tdiffAcute1 acuteCase Acute1 tempAcute4_84d tempfirstFilled_Act4 if Acute84d==1
**browse person_id date_complete visitnr tdiffAcute1 acuteCase Acute1 tempAcute4_84d tempfirstFilled_Act4

gen Acute4=.
sort person_id date_complete nthRecAIC
by person_id: replace Acute4=acuteCase if tempfirstFilled_Act4==nthRecAIC
ta Acute4, m

**browse person_id date_complete nthRecAIC tempfirstFilled_Act4 tdiffAcute1 acuteCase tempAcute4_84d  Acute4

*Generate time difference between 2nd Acute visit and follow-up visit
sort person_id date_complete nthRecAIC
by person_id: gen tstartAcute4=date_complete if Acute4==1
format tstartAcute4 %td
by person_id: carryforward tstartAcute4, replace

sort person_id date_complete nthRecAIC
gen tstopAcute4=date_complete 
format tstopAcute4 %td

gen tdiffAcute4=(tstopAcute4 - tstartAcute4) 

**browse person_id date_complete nthRecAIC tempfirstFilled_Act4 tdiffAcute1 acuteCase tempAcute4_84d  Acute4 tstartAcute4 tstopAcute4 tdiffAcute4

****************************************************************************
*Fourth acute
replace Acute=4 if tempfirstFilled_Act4==nthRecAIC

*only visits >14d and <84 d
replace Acute=4 if tdiffAcute4>=14 & tdiffAcute4<=84
ta Acute acuteCase if tdiffAcute4>=14 & tdiffAcute4<=84

**browse person_id date_complete nthRecAIC tempfirstFilled_Act4 tdiffAcute1 acuteCase Acute nien tempAcute4_84d  Acute4 tstartAcute4 tstopAcute4 tdiffAcute4 

****************************************************************************
*Identify when 5th Acute visit starts

gen tempAcute5_84d=0
sort person_id date_complete nthRecAIC
by person_id: replace tempAcute5_84d=1 if acuteCase==1 & tdiffAcute4>84 & tdiffAcute4!=.
ta tempAcute5_84d, m
**browse person_id date_complete tdiffAcute2 acuteCase tempAcute5_84d if tempAcute5_84d==1
**browse person_id date_complete tdiffAcute2 acuteCase tempAcute5_84d 
*Empty

****************************************************************************
ta Acute, m
sort person_id date_complete nthRecAIC
**browse person_id visitLetter nthRecAIC Acute acuteCase date_complete tdiffAcute1 tdiffAcute2 tdiffAcute3 tdiffAcute4 if Acute==.
**browse person_id visitLetter nthRecAIC Acute acuteCase date_complete tdiffAcute1 tdiffAcute2 tdiffAcute3 tdiffAcute4 

****************************************************************************
gen AcuteT=.
replace AcuteT=1 if nthRecAIC==1
replace AcuteT=1 if nthRecAIC==tempfirstFilled
replace AcuteT=1 if nthRecAIC==tempfirstFilled_Act3
replace AcuteT=1 if nthRecAIC==tempfirstFilled_Act4
ta AcuteT, m

****************************************************************************
*First visit + follow-up visit
****************************************************************************

*Identify follow-up
gen flwAcute1=acuteCase if Acute==1
ta flwAcute1 Acute, m

*Now concatanate whether it was a 0 or a 1 visit
tostring flwAcute1, gen(flwAcute1_str)
ta flwAcute1 flwAcute1_str, m

gen flwAcute1_01=""
sort person_id date_complete nthRecAIC
by person_id: replace flwAcute1_01=flwAcute1_str[_n]
by person_id: replace flwAcute1_01=flwAcute1_01+flwAcute1_str[_n+1] if flwAcute1_01!=""
by person_id: replace flwAcute1_01=flwAcute1_01+flwAcute1_str[_n+2] if flwAcute1_01!=""
by person_id: replace flwAcute1_01=flwAcute1_01+flwAcute1_str[_n+3] if flwAcute1_01!=""
by person_id: replace flwAcute1_01=flwAcute1_01+flwAcute1_str[_n+4] if flwAcute1_01!=""
by person_id: replace flwAcute1_01=flwAcute1_01+flwAcute1_str[_n+5] if flwAcute1_01!=""
by person_id: replace flwAcute1_01=flwAcute1_01+flwAcute1_str[_n+6] if flwAcute1_01!=""
by person_id: replace flwAcute1_01=flwAcute1_01+flwAcute1_str[_n+7] if flwAcute1_01!=""
ta flwAcute1_01 nthRecAIC, m
ta flwAcute1_01 if nthRecAIC==1, m

ta flwAcute1_01 nthRecAIC, m
replace flwAcute1_01="" if nthRecAIC>1
ta flwAcute1_01 nthRecAIC, m

***browse person_id date_complete nthRec tstartAcute1 tstopAcute1 tdiffAcute1 acuteCase flwAcute1_01 flwAcute1_str nthRecAIC

*generate a variable for analyses that codes types of follow-up
sort person_id date_complete nthRecAIC

gen FlwVisAct1=0 if Acute==1
ta  flwAcute1_01 FlwVisAct1 if Acute==1, m

*non-acute follow-up
replace FlwVisAct1=1 if regexm(flwAcute1_01, "[1]+[0]") 
ta  flwAcute1_01 FlwVisAct1 if Acute==1, m

*follow-up with one acute
replace FlwVisAct1=2 if regexm(flwAcute1_01, "[1]+[1]") 
replace FlwVisAct1=2 if regexm(flwAcute1_01, "[1]+[0]+[1]") 
ta  flwAcute1_01 FlwVisAct1 if Acute==1, m

*Follow-up with >1 acute
replace FlwVisAct1=3 if regexm(flwAcute1_01, "[1]+[1]+[1]") 
replace FlwVisAct1=3 if regexm(flwAcute1_01, "[1]+[0]+[1]+[1]") 
replace FlwVisAct1=3 if regexm(flwAcute1_01, "[1]+[0]+[0]+[1]+[1]") 
ta  flwAcute1_01 FlwVisAct1 if Acute==1, m

ta FlwVisAct1 nthRecAIC, m
replace FlwVisAct1=. if nthRecAIC>1
ta FlwVisAct1 nthRecAIC, m

label define lbl_FlwVisAct1 0 "no follow-up" 1 "non-acute follow-up" 2 "1 acute follow-up" 3 ">1 acute follow-up"
label val FlwVisAct1 lbl_FlwVisAct1
ta FlwVisAct1 , m
ta FlwVisAct1 


****************************************************************************
*Second visit + follow-up visit
****************************************************************************

*Identify follow-up
gen flwAcute2=acuteCase if Acute==2
ta flwAcute2 Acute, m

*Now concatanate whether it was a 0 or a 1 visit
tostring flwAcute2, gen(flwAcute2_str)
ta flwAcute2 flwAcute2_str, m

gen flwAcute2_01=""
sort person_id date_complete nthRecAIC
by person_id: replace flwAcute2_01=flwAcute2_str[_n]
by person_id: replace flwAcute2_01=flwAcute2_01+flwAcute2_str[_n+1] if flwAcute2_01!=""
by person_id: replace flwAcute2_01=flwAcute2_01+flwAcute2_str[_n+2] if flwAcute2_01!=""
by person_id: replace flwAcute2_01=flwAcute2_01+flwAcute2_str[_n+3] if flwAcute2_01!=""
by person_id: replace flwAcute2_01=flwAcute2_01+flwAcute2_str[_n+4] if flwAcute2_01!=""
by person_id: replace flwAcute2_01=flwAcute2_01+flwAcute2_str[_n+5] if flwAcute2_01!=""
by person_id: replace flwAcute2_01=flwAcute2_01+flwAcute2_str[_n+6] if flwAcute2_01!=""
by person_id: replace flwAcute2_01=flwAcute2_01+flwAcute2_str[_n+7] if flwAcute2_01!=""
ta flwAcute2_01 nthRecAIC, m
ta flwAcute2_01 if  tempfirstFilled==nthRecAIC, m

ta flwAcute2_01 nthRecAIC, m
replace flwAcute2_01="" if tempfirstFilled!=nthRecAIC
ta flwAcute2_01 nthRecAIC, m

***browse person_id date_complete nthRec tstartAcute2 tstopAcute2 tdiffAcute2 acuteCase flwAcute2_01 flwAcute2_str nthRecAIC tempfirstFilled

*generate a variable for analyses that codes types of follow-up
sort person_id date_complete nthRecAIC

gen FlwVisAct2=0 if Acute==2
ta  flwAcute2_01 FlwVisAct2 if tempfirstFilled!=nthRecAIC, m

*non-acute follow-up
replace FlwVisAct2=1 if regexm(flwAcute2_01, "[1]+[0]") 
ta  flwAcute2_01 FlwVisAct2 if Acute==2, m

*follow-up with one acute
replace FlwVisAct2=2 if regexm(flwAcute2_01, "[1]+[1]") 
replace FlwVisAct2=2 if regexm(flwAcute2_01, "[1]+[0]+[1]") 
ta  flwAcute2_01 FlwVisAct2 if Acute==2, m

*Follow-up with >1 acute
replace FlwVisAct2=3 if regexm(flwAcute2_01, "[1]+[1]+[1]") 
replace FlwVisAct2=3 if regexm(flwAcute2_01, "[1]+[0]+[1]+[1]") 
replace FlwVisAct2=3 if regexm(flwAcute2_01, "[1]+[0]+[0]+[1]+[1]") 
ta  flwAcute2_01 FlwVisAct2 if Acute==2, m

ta FlwVisAct2 if tempfirstFilled!=nthRecAIC, m
ta FlwVisAct2 if tempfirstFilled==nthRecAIC, m
replace FlwVisAct2=. if tempfirstFilled!=nthRecAIC
ta FlwVisAct2 if tempfirstFilled!=nthRecAIC, m
ta FlwVisAct2 if tempfirstFilled==nthRecAIC, m

label define lbl_FlwVisAct2 0 "no follow-up" 1 "non-acute follow-up" 2 "1 acute follow-up" 3 ">1 acute follow-up"
label val FlwVisAct2 lbl_FlwVisAct2
ta FlwVisAct2 , m
ta FlwVisAct2 

****************************************************************************
*Third visit + follow-up visit
****************************************************************************

*Identify follow-up
gen flwAcute3=acuteCase if Acute==3
ta flwAcute3 Acute, m

*Now concatanate whether it was a 0 or a 1 visit
tostring flwAcute3, gen(flwAcute3_str)
ta flwAcute3 flwAcute3_str, m

gen flwAcute3_01=""
sort person_id date_complete nthRecAIC
by person_id: replace flwAcute3_01=flwAcute3_str[_n]
by person_id: replace flwAcute3_01=flwAcute3_01+flwAcute3_str[_n+1] if flwAcute3_01!=""
by person_id: replace flwAcute3_01=flwAcute3_01+flwAcute3_str[_n+2] if flwAcute3_01!=""
by person_id: replace flwAcute3_01=flwAcute3_01+flwAcute3_str[_n+3] if flwAcute3_01!=""
by person_id: replace flwAcute3_01=flwAcute3_01+flwAcute3_str[_n+4] if flwAcute3_01!=""
by person_id: replace flwAcute3_01=flwAcute3_01+flwAcute3_str[_n+5] if flwAcute3_01!=""
by person_id: replace flwAcute3_01=flwAcute3_01+flwAcute3_str[_n+6] if flwAcute3_01!=""
by person_id: replace flwAcute3_01=flwAcute3_01+flwAcute3_str[_n+7] if flwAcute3_01!=""
ta flwAcute3_01 if tempfirstFilled_Act3==nthRecAIC, m

ta flwAcute3_01, m
replace flwAcute3_01="" if tempfirstFilled_Act3!=nthRecAIC
ta flwAcute3_01, m

***browse person_id date_complete nthRec tstartAcute3 tstopAcute3 tdiffAcute3 acuteCase flwAcute3_01 flwAcute3_str nthRecAIC tempfirstFilled_Act3

*generate a variable for analyses that codes types of follow-up
sort person_id date_complete nthRecAIC

gen FlwVisAct3=0 if Acute==3
ta  flwAcute3_01 FlwVisAct3 if tempfirstFilled_Act3!=nthRecAIC, m

*non-acute follow-up
replace FlwVisAct3=1 if regexm(flwAcute3_01, "[1]+[0]") 
ta  flwAcute3_01 FlwVisAct3 if Acute==3, m

*follow-up with one acute
replace FlwVisAct3=2 if regexm(flwAcute3_01, "[1]+[1]") 
replace FlwVisAct3=2 if regexm(flwAcute3_01, "[1]+[0]+[1]") 
ta  flwAcute3_01 FlwVisAct3 if Acute==3, m

*Follow-up with >1 acute
replace FlwVisAct3=3 if regexm(flwAcute3_01, "[1]+[1]+[1]") 
replace FlwVisAct3=3 if regexm(flwAcute3_01, "[1]+[0]+[1]+[1]") 
replace FlwVisAct3=3 if regexm(flwAcute3_01, "[1]+[0]+[0]+[1]+[1]") 
ta  flwAcute3_01 FlwVisAct3 if Acute==3, m

ta FlwVisAct3 if tempfirstFilled_Act3!=nthRecAIC, m
ta FlwVisAct3 if tempfirstFilled_Act3==nthRecAIC, m
replace FlwVisAct3=. if tempfirstFilled_Act3!=nthRecAIC
ta FlwVisAct3 if tempfirstFilled_Act3!=nthRecAIC, m
ta FlwVisAct3 if tempfirstFilled_Act3==nthRecAIC, m

label define lbl_FlwVisAct3 0 "no follow-up" 1 "non-acute follow-up" 2 "1 acute follow-up" 3 ">1 acute follow-up"
label val FlwVisAct3 lbl_FlwVisAct3
ta FlwVisAct3 , m
ta FlwVisAct3 

****************************************************************************
*Fourth visit + follow-up visit
****************************************************************************

*Identify follow-up
gen flwAcute4=acuteCase if Acute==4
ta flwAcute4 Acute, m

*Now concatanate whether it was a 0 or a 1 visit
tostring flwAcute4, gen(flwAcute4_str)
ta flwAcute4 flwAcute4_str, m

gen flwAcute4_01=""
sort person_id date_complete nthRecAIC
by person_id: replace flwAcute4_01=flwAcute4_str[_n]
by person_id: replace flwAcute4_01=flwAcute4_01+flwAcute4_str[_n+1] if flwAcute4_01!=""
by person_id: replace flwAcute4_01=flwAcute4_01+flwAcute4_str[_n+2] if flwAcute4_01!=""
by person_id: replace flwAcute4_01=flwAcute4_01+flwAcute4_str[_n+3] if flwAcute4_01!=""
by person_id: replace flwAcute4_01=flwAcute4_01+flwAcute4_str[_n+4] if flwAcute4_01!=""
by person_id: replace flwAcute4_01=flwAcute4_01+flwAcute4_str[_n+5] if flwAcute4_01!=""
by person_id: replace flwAcute4_01=flwAcute4_01+flwAcute4_str[_n+6] if flwAcute4_01!=""
by person_id: replace flwAcute4_01=flwAcute4_01+flwAcute4_str[_n+7] if flwAcute4_01!=""
ta flwAcute4_01 if tempfirstFilled_Act4==nthRecAIC, m

ta flwAcute4_01, m
replace flwAcute4_01="" if tempfirstFilled_Act4!=nthRecAIC
ta flwAcute4_01, m

***browse person_id date_complete nthRec tstartAcute4 tstopAcute4 tdiffAcute4 acuteCase flwAcute4_01 flwAcute4_str nthRecAIC tempfirstFilled_Act4

*generate a variable for analyses that codes types of follow-up
sort person_id date_complete nthRecAIC

gen FlwVisAct4=0 if Acute==4
ta  flwAcute4_01 FlwVisAct4 if tempfirstFilled_Act4!=nthRecAIC, m

*non-acute follow-up
replace FlwVisAct4=1 if regexm(flwAcute4_01, "[1]+[0]") 
ta  flwAcute4_01 FlwVisAct4 if Acute==4, m

*follow-up with one acute
replace FlwVisAct4=2 if regexm(flwAcute4_01, "[1]+[1]") 
replace FlwVisAct4=2 if regexm(flwAcute4_01, "[1]+[0]+[1]") 
ta  flwAcute4_01 FlwVisAct4 if Acute==4, m

*Follow-up with >1 acute
replace FlwVisAct4=3 if regexm(flwAcute4_01, "[1]+[1]+[1]") 
replace FlwVisAct4=3 if regexm(flwAcute4_01, "[1]+[0]+[1]+[1]") 
replace FlwVisAct4=3 if regexm(flwAcute4_01, "[1]+[0]+[0]+[1]+[1]") 
ta  flwAcute4_01 FlwVisAct4 if Acute==4, m

ta FlwVisAct4 if tempfirstFilled_Act4!=nthRecAIC, m
ta FlwVisAct4 if tempfirstFilled_Act4==nthRecAIC, m
replace FlwVisAct4=. if tempfirstFilled_Act4!=nthRecAIC
ta FlwVisAct4 if tempfirstFilled_Act4!=nthRecAIC, m
ta FlwVisAct4 if tempfirstFilled_Act4==nthRecAIC, m

label define lbl_FlwVisAct4 0 "no follow-up" 1 "non-acute follow-up" 2 "1 acute follow-up" 3 ">1 acute follow-up"
label val FlwVisAct4 lbl_FlwVisAct4
ta FlwVisAct4 , m
ta FlwVisAct4 

********************************************************************************
**Generate total follow-up visits for every acute visit

gen FlwVisAct=.
ta FlwVisAct FlwVisAct1, m
replace FlwVisAct=FlwVisAct1 if nthRecAIC==1
ta FlwVisAct FlwVisAct2, m
replace FlwVisAct=FlwVisAct2 if nthRecAIC==tempfirstFilled
ta FlwVisAct FlwVisAct3, m
replace FlwVisAct=FlwVisAct3 if nthRecAIC==tempfirstFilled_Act3
ta FlwVisAct FlwVisAct4, m
replace FlwVisAct=FlwVisAct4 if nthRecAIC==tempfirstFilled_Act4
ta FlwVisAct, m
label define lbl_FlwVisAct 0 "no follow-up" 1 "non-acute follow-up" 2 "1 acute follow-up" 3 ">1 acute follow-up"
label val FlwVisAct lbl_FlwVisAct
ta FlwVisAct , m
ta FlwVisAct

********************************************************************************
**Generate nr of Acute visits within a person
gen nrAcuteT=.
ta Acute, m
*So first fill with 4 and expand; this the total nr of indepdent acute visits a person had
replace nrAcuteT=4 if Acute==4 & nrAcuteT==.
sort person_id date_complete nthRecAIC
by person_id: carryforward nrAcuteT, replace
gsort person_id -date_complete -nthRecAIC
by person_id: carryforward nrAcuteT, replace
sort person_id date_complete nthRecAIC
ta nrAcuteT, m
*browse person_id visitLetter Acute nrAcuteT

replace nrAcuteT=3 if Acute==3 & nrAcuteT==.
sort person_id date_complete nthRecAIC
by person_id: carryforward nrAcuteT, replace
gsort person_id -date_complete -nthRecAIC
by person_id: carryforward nrAcuteT, replace
sort person_id date_complete nthRecAIC
ta nrAcuteT, m

replace nrAcuteT=2 if Acute==2 & nrAcuteT==.
sort person_id date_complete nthRecAIC
by person_id: carryforward nrAcuteT, replace
gsort person_id -date_complete -nthRecAIC
by person_id: carryforward nrAcuteT, replace
sort person_id date_complete nthRecAIC
ta nrAcuteT, m

replace nrAcuteT=1 if Acute==1 & nrAcuteT==.
sort person_id date_complete nthRecAIC
by person_id: carryforward nrAcuteT, replace
gsort person_id -date_complete -nthRecAIC
by person_id: carryforward nrAcuteT, replace
sort person_id date_complete nthRecAIC
ta nrAcuteT, m

replace nrAcuteT=. if AcuteT==.

ta nrAcuteT, m
*not sure yet whether this will too correlated
*but my idea is that children that came in for 4 independent
*visits are more sick than children that only came for one.


********************************************************************************
**Prepare outcome for regression analyses
********************************************************************************
*meeting Des 13th Nov, independent on when they developped DENV or CHIKV infection
*we are going to use positive for DENV or CHIKV at any time in the study?
*but if it is seasonal dependent I am not sure how you want to do that?
*If I go by 1st, 2nd, 3th Rec Acute visit, based on my definition of <14 and >84 days
*than by using GEE we can explore the relation with time

*1st Acute: DENV pcr outcome for AIC taking all possible PCR outcomes during time gap >=14d and <=84d
gen denv_pcr_aic1=. 

replace denv_pcr_aic1=1 if denv_pcr_y==1 & Acute==1
sort person_id date_complete nthRecAIC
by person_id: carryforward denv_pcr_aic1 if Acute==1, replace
gsort person_id -date_complete -nthRecAIC
by person_id: carryforward denv_pcr_aic1 if Acute==1, replace
sort person_id date_complete nthRecAIC

replace denv_pcr_aic1=0 if denv_pcr_y==0 & Acute==1 & denv_pcr_aic1==.
sort person_id date_complete nthRecAIC
by person_id: carryforward denv_pcr_aic1 if Acute==1, replace
gsort person_id -date_complete -nthRecAIC
by person_id: carryforward denv_pcr_aic1 if Acute==1, replace
sort person_id date_complete nthRecAIC
ta denv_pcr_aic1, m

replace denv_pcr_aic1=. if nthRecAIC!=1
ta denv_pcr_aic1, m

**browse person_id date_complete nthRec Acute tdiffAcute1 denv_pcr_y denv_pcr_aic1

*2nd Acute: DENV pcr outcome for AIC taking all possible PCR outcomes during time gap >=14d and <=84d
gen denv_pcr_aic2=. 

replace denv_pcr_aic2=1 if denv_pcr_y==1 & Acute==2
sort person_id date_complete nthRecAIC
by person_id: carryforward denv_pcr_aic2 if Acute==2, replace
gsort person_id -date_complete -nthRecAIC
by person_id: carryforward denv_pcr_aic2 if Acute==2, replace
sort person_id date_complete nthRecAIC

replace denv_pcr_aic2=0 if denv_pcr_y==0 & Acute==2 & denv_pcr_aic2==.
sort person_id date_complete nthRecAIC
by person_id: carryforward denv_pcr_aic2 if Acute==2, replace
gsort person_id -date_complete -nthRecAIC
by person_id: carryforward denv_pcr_aic2 if Acute==2, replace
sort person_id date_complete nthRecAIC
ta denv_pcr_aic2, m

replace denv_pcr_aic2=. if nthRecAIC!=tempfirstFilled

ta denv_pcr_aic2, m

*Third Acute: DENV pcr outcome for AIC taking all possible PCR outcomes during time gap >=14d and <=84d
gen denv_pcr_aic3=. 

*Carryforward only replaces missings, so first fill in when pcr==pos
replace denv_pcr_aic3=1 if denv_pcr_y==1 & Acute==3
sort person_id date_complete nthRecAIC
by person_id: carryforward denv_pcr_aic3 if Acute==3, replace
gsort person_id -date_complete -nthRecAIC
by person_id: carryforward denv_pcr_aic3 if Acute==3, replace
sort person_id date_complete nthRecAIC
ta denv_pcr_aic3, m

replace denv_pcr_aic3=0 if denv_pcr_y==0 & Acute==3 & denv_pcr_aic3==.
sort person_id date_complete nthRecAIC
by person_id: carryforward denv_pcr_aic3 if Acute==3, replace
gsort person_id -date_complete -nthRecAIC
by person_id: carryforward denv_pcr_aic3 if Acute==3, replace
sort person_id date_complete nthRecAIC
ta denv_pcr_aic3, m

replace denv_pcr_aic3=. if nthRecAIC!=tempfirstFilled_Act3
ta denv_pcr_aic3, m

*Fourth Acute: DENV pcr outcome for AIC taking all possible PCR outcomes during time gap >=14d and <=84d
gen denv_pcr_aic4=. 

replace denv_pcr_aic4=1 if denv_pcr_y==1 & Acute==4
sort person_id date_complete nthRecAIC
by person_id: carryforward denv_pcr_aic4 if Acute==4, replace
gsort person_id -date_complete -nthRecAIC
by person_id: carryforward denv_pcr_aic4 if Acute==4, replace
sort person_id date_complete nthRecAIC

replace denv_pcr_aic4=0 if denv_pcr_y==0 & Acute==4 & denv_pcr_aic4==.
sort person_id date_complete nthRecAIC
by person_id: carryforward denv_pcr_aic4 if Acute==4, replace
gsort person_id -date_complete -nthRecAIC
by person_id: carryforward denv_pcr_aic4 if Acute==4, replace
sort person_id date_complete nthRecAIC
ta denv_pcr_aic4, m

replace denv_pcr_aic4=. if nthRecAIC!=tempfirstFilled_Act4
ta denv_pcr_aic4, m

*Total
ta denv_pcr_aic1 denv_pcr_aic2, m
ta denv_pcr_aic1 denv_pcr_aic3, m
ta denv_pcr_aic1 denv_pcr_aic4, m

gen denv_pcr_aicT=.
replace denv_pcr_aicT=0 if denv_pcr_aic1==0
replace denv_pcr_aicT=0 if denv_pcr_aic2==0
replace denv_pcr_aicT=0 if denv_pcr_aic3==0
replace denv_pcr_aicT=0 if denv_pcr_aic4==0

replace denv_pcr_aicT=1 if denv_pcr_aic1==1
replace denv_pcr_aicT=1 if denv_pcr_aic2==1
replace denv_pcr_aicT=1 if denv_pcr_aic3==1
replace denv_pcr_aicT=1 if denv_pcr_aic4==1
ta denv_pcr_aicT Acute, m
ta denv_pcr_aicT Acute, col

****************************************************************************
*1st Acute: DENV seroconversion during time gap >=14d and <=84d
gen denv_sconv_aic1=.

*browse person_id redcap_event_name date_complete nthRecAIC tdiffAcute1 Acute denv_igg_y denv_sconv_aic1 if denv_sconv_aic1==0
*browse person_id redcap_event_name date_complete nthRecAIC tdiffAcute1 Acute denv_igg_y denv_sconv_aic1

*Overwriting not allowed
 forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace denv_sconv_aic1=0 if nthRecAIC==1 &  denv_igg_y[_n]==0 & denv_igg_y[_n+`i']==0 & tdiffAcute1[_n+`i']>=14 & tdiffAcute1[_n+`i']<=84 & Acute1==1 & denv_sconv_aic1[_n]==.
}
forval k=1/8{
forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace denv_sconv_aic1=0 if nthRecAIC==1 &  denv_igg_y[_n+`k']==0 & denv_igg_y[_n+`k'+`i']==0 & tdiffAcute1[_n+`k'+`i']>=14 & tdiffAcute1[_n+`k'+`i']<=84 & Acute1==1 & denv_sconv_aic1[_n]==.
}
}
ta denv_sconv_aic1 nthRecAIC, m
*Notice person_id=UF0625, of which the 'first record" does not have IgG data, so I am using the second and the subsequent visit after that to measure seroconversion.

*I am using this to map whether a sample had a follow-up sample, but actually these persons need to be censored for analyses purpose
forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace denv_sconv_aic1=0 if nthRecAIC==1 &  denv_igg_y[_n]==1 & denv_igg_y[_n+`i']==1 & tdiffAcute1[_n+`i']>=14 & tdiffAcute1[_n+`i']<=84 & Acute1==1 & denv_sconv_aic1[_n]==.
}
forval k=1/8{
forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace denv_sconv_aic1=0 if nthRecAIC==1 &  denv_igg_y[_n+`k']==1 & denv_igg_y[_n+`k'+`i']==1 & tdiffAcute1[_n+`k'+`i']>=14 & tdiffAcute1[_n+`k'+`i']<=84 & Acute1==1 & denv_sconv_aic1[_n]==.
}
}
ta denv_sconv_aic1 nthRecAIC, m
ta denv_sconv_aic1 Acute1, m


forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace denv_sconv_aic1=0 if nthRecAIC==1 &  denv_igg_y[_n]==1 & denv_igg_y[_n+`i']==0 & tdiffAcute1[_n+`i']>=14 & tdiffAcute1[_n+`i']<=84 & Acute1==1 & denv_sconv_aic1[_n]==.
}
forval k=1/8{
forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace denv_sconv_aic1=0 if nthRecAIC==1 &  denv_igg_y[_n+`k']==1 & denv_igg_y[_n+`k'+`i']==0 & tdiffAcute1[_n+`k'+`i']>=14 & tdiffAcute1[_n+`k'+`i']<=84 & Acute1==1 & denv_sconv_aic1[_n]==.
}
}
ta denv_sconv_aic1 nthRecAIC, m
ta denv_sconv_aic1 Acute1, m

*overwriting okay as long as in between visits were missing and therefore next visit should be used
*13/Dec --> not sure why I decided before that in between visits should be missing
*I removed that code in this version, and I am just looking at a whether they had any seroconversion >14 days and <84 days
forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace denv_sconv_aic1=1 if nthRecAIC==1 &  denv_igg_y[_n]==0 & denv_igg_y[_n+`i']==1 & tdiffAcute1[_n+`i']>=14 & tdiffAcute1[_n+`i']<=84 & Acute1==1 
}
forval k=1/8{
forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace denv_sconv_aic1=1 if nthRecAIC==1 &  denv_igg_y[_n+`k']==0 & denv_igg_y[_n+`k'+`i']==1 & tdiffAcute1[_n+`k'+`i']>=14 & tdiffAcute1[_n+`k'+`i']<=84 & Acute1==1 
}
}
ta denv_sconv_aic1, m
*
* 
**browse person_id date_complete tdiffAcute1 nthRecAIC denv_igg_y denv_sconv_aic1
ta denv_sconv_aic1 if nthRec==1, m

*denv_sconv_ |
*       aic1 |      Freq.     Percent        Cum.
*------------+-----------------------------------
*          0 |      3,526       51.43       51.43
*          1 |         34        0.50       51.93
*          . |      3,296       48.07      100.00
*------------+-----------------------------------
*      Total |      6,856      100.00
*so 48% do not have igg follow-up data

*Seropositive at the beginning
gen denv_sPos1stRec_aic1=.
replace denv_sPos1stRec_aic1=1 if denv_igg_y==1 & nthRecAIC==1 
ta denv_sPos1stRec_aic1 denv_igg_y if nthRecAIC==1, m
sort person_id nthRecAIC
by person_id: carryforward denv_sPos1stRec_aic1, replace

*Censor individuals seropositive at intake
ta denv_igg_y denv_sconv_aic1 if  nthRecAIC==1, m 
*denv_igg_y=. & denv_sconv_aic1=0  -->  person_id=UF0625

gen denv_sconv_aic1_censrd=denv_sconv_aic1
replace denv_sconv_aic1_censrd=. if denv_sPos1stRec_aic1==1

*Notice that for the HCC I also censor after the first serconversion happens
*Due to the structure of this dataset that is not possible

gen denv_sconv_aic1_1Rec=denv_sconv_aic1 //is already stored in the first record

****************************************************************************
*2nd Acute: DENV seroconversion during time gap >=14d and <=84d
gen denv_sconv_aic2=.


**browse person_id visitLetter2 Acute nthRecAIC tempfirstFilled denv_igg_y tdiffAcute2 Acute2 denv_sconv_aic2 if denv_igg_y==1 & Acute==2
**browse person_id visitLetter2 Acute nthRecAIC tempfirstFilled denv_igg_y tdiffAcute2 Acute2 denv_sconv_aic2 
*Overwriting not allowed
 forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace denv_sconv_aic2=0 if nthRecAIC==tempfirstFilled &  denv_igg_y[_n]==0 & denv_igg_y[_n+`i']==0 & tdiffAcute2[_n+`i']>=14 & tdiffAcute2[_n+`i']<=84 & Acute2==1 & denv_sconv_aic2[_n]==.
}
forval k=1/8{
forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace denv_sconv_aic2=0 if nthRecAIC==tempfirstFilled &  denv_igg_y[_n+`k']==0 & denv_igg_y[_n+`k'+`i']==0 & tdiffAcute2[_n+`k'+`i']>=14 & tdiffAcute2[_n+`k'+`i']<=84 & Acute2==1 & denv_sconv_aic2[_n]==.
}
}
ta denv_sconv_aic2 nthRecAIC, m


*Seropositive at the beginning; censor later
forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace denv_sconv_aic2=0 if nthRecAIC==tempfirstFilled &  denv_igg_y[_n]==1 & denv_igg_y[_n+`i']==1 & tdiffAcute2[_n+`i']>=14 & tdiffAcute2[_n+`i']<=84 & Acute2==1 & denv_sconv_aic2[_n]==.
}
forval k=1/8{
forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace denv_sconv_aic2=0 if nthRecAIC==tempfirstFilled &  denv_igg_y[_n+`k']==1 & denv_igg_y[_n+`k'+`i']==1 & tdiffAcute2[_n+`k'+`i']>=14 & tdiffAcute2[_n+`k'+`i']<=84 & Acute2==1 & denv_sconv_aic2[_n]==.
}
}
ta denv_sconv_aic2 nthRecAIC, m
ta denv_sconv_aic2 Acute2, m


forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace denv_sconv_aic2=0 if nthRecAIC==tempfirstFilled &  denv_igg_y[_n]==1 & denv_igg_y[_n+`i']==0 & tdiffAcute2[_n+`i']>=14 & tdiffAcute2[_n+`i']<=84 & Acute2==1 & denv_sconv_aic2[_n]==.
}
forval k=1/8{
forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace denv_sconv_aic2=0 if nthRecAIC==tempfirstFilled &  denv_igg_y[_n+`k']==1 & denv_igg_y[_n+`k'+`i']==0 & tdiffAcute2[_n+`k'+`i']>=14 & tdiffAcute2[_n+`k'+`i']<=84 & Acute2==1 & denv_sconv_aic2[_n]==.
}
}
ta denv_sconv_aic2 nthRecAIC, m
ta denv_sconv_aic2 Acute2, m

*Actual seroconversion
forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace denv_sconv_aic2=1 if nthRecAIC==tempfirstFilled &  denv_igg_y[_n]==0 & denv_igg_y[_n+`i']==1 & tdiffAcute2[_n+`i']>=14 & tdiffAcute2[_n+`i']<=84 & Acute2==1 
}
forval k=1/8{
forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace denv_sconv_aic2=1 if nthRecAIC==tempfirstFilled &  denv_igg_y[_n+`k']==0 & denv_igg_y[_n+`k'+`i']==1 & tdiffAcute2[_n+`k'+`i']>=14 & tdiffAcute2[_n+`k'+`i']<=84 & Acute2==1 
}
}
ta denv_sconv_aic2, m
ta denv_sconv_aic2 denv_igg_y, m
*There are 5 invididuals that are Igg positive but are not categorized
*as serconverters, that is because they were already seropositive from the beginning
*person_id= MF0765; MF0994; MF1303; MF1549; UF1670

*Seropositive at the beginning
gen denv_sPos1stRec_aic2=.
replace denv_sPos1stRec_aic2=1 if denv_igg_y==1 & nthRecAIC==tempfirstFilled 
ta denv_sPos1stRec_aic2 denv_igg_y if nthRecAIC==tempfirstFilled, m
sort person_id nthRecAIC
by person_id: carryforward denv_sPos1stRec_aic2, replace

*Censor individuals seropositive at intake
ta denv_igg_y denv_sconv_aic2 if nthRecAIC==tempfirstFilled, m 

gen denv_sconv_aic2_censrd=denv_sconv_aic2
replace denv_sconv_aic2_censrd=. if denv_sPos1stRec_aic2==1

**browse person_id date_complete tdiffAcute2 nthRecAIC Acute2 denv_igg_y denv_sconv_aic2 
ta denv_sconv_aic2

*Store information in the first record 
gen denv_sconv_aic2_1Rec=denv_sconv_aic2
sort person_id date_complete nthRecAIC
by person_id: carryforward denv_sconv_aic2_1Rec, replace
gsort person_id -date_complete -nthRecAIC
by person_id: carryforward denv_sconv_aic2_1Rec, replace
sort person_id date_complete nthRecAIC
replace denv_sconv_aic2_1Rec=. if nthRecAIC!=1
ta denv_sconv_aic2, m


****************************************************************************
*3th Acute: DENV seroconversion during time gap >=14d and <=84d
gen denv_sconv_aic3=.

**browse person_id visitLetter2 Acute nthRecAIC tempfirstFilled_Act3 denv_igg_y tdiffAcute3 Acute3 denv_sconv_aic3 if denv_igg_y==1 &Acute==3
**browse person_id visitLetter2 Acute nthRecAIC tempfirstFilled_Act3 denv_igg_y tdiffAcute3 Acute3 denv_sconv_aic3 

*Overwriting not allowed
 forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace denv_sconv_aic3=0 if nthRecAIC==tempfirstFilled_Act3 &  denv_igg_y[_n]==0 & denv_igg_y[_n+`i']==0 & tdiffAcute3[_n+`i']>=14 & tdiffAcute3[_n+`i']<=84 & Acute3==1 & denv_sconv_aic3[_n]==.
}
forval k=1/8{
forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace denv_sconv_aic3=0 if nthRecAIC==tempfirstFilled_Act3 &  denv_igg_y[_n+`k']==0 & denv_igg_y[_n+`k'+`i']==0 & tdiffAcute3[_n+`k'+`i']>=14 & tdiffAcute3[_n+`k'+`i']<=84 & Acute3==1 & denv_sconv_aic3[_n]==.
}
}
ta denv_sconv_aic3 nthRecAIC, m


*Seropositive at the beginning; censor later
forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace denv_sconv_aic3=0 if nthRecAIC==tempfirstFilled_Act3 &  denv_igg_y[_n]==1 & denv_igg_y[_n+`i']==1 & tdiffAcute3[_n+`i']>=14 & tdiffAcute3[_n+`i']<=84 & Acute3==1 & denv_sconv_aic3[_n]==.
}
forval k=1/8{
forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace denv_sconv_aic3=0 if nthRecAIC==tempfirstFilled_Act3 &  denv_igg_y[_n+`k']==1 & denv_igg_y[_n+`k'+`i']==1 & tdiffAcute3[_n+`k'+`i']>=14 & tdiffAcute3[_n+`k'+`i']<=84 & Acute3==1 & denv_sconv_aic3[_n]==.
}
}
ta denv_sconv_aic3 nthRecAIC, m
ta denv_sconv_aic3 Acute3, m


forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace denv_sconv_aic3=0 if nthRecAIC==tempfirstFilled_Act3 &  denv_igg_y[_n]==1 & denv_igg_y[_n+`i']==0 & tdiffAcute3[_n+`i']>=14 & tdiffAcute3[_n+`i']<=84 & Acute3==1 & denv_sconv_aic3[_n]==.
}
forval k=1/8{
forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace denv_sconv_aic3=0 if nthRecAIC==tempfirstFilled_Act3 &  denv_igg_y[_n+`k']==1 & denv_igg_y[_n+`k'+`i']==0 & tdiffAcute3[_n+`k'+`i']>=14 & tdiffAcute3[_n+`k'+`i']<=84 & Acute3==1 & denv_sconv_aic3[_n]==.
}
}
ta denv_sconv_aic3 nthRecAIC, m
ta denv_sconv_aic3 Acute3, m

*Actual seroconversion
forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace denv_sconv_aic3=1 if nthRecAIC==tempfirstFilled_Act3 &  denv_igg_y[_n]==0 & denv_igg_y[_n+`i']==1 & tdiffAcute3[_n+`i']>=14 & tdiffAcute3[_n+`i']<=84 & Acute3==1 
}
forval k=1/8{
forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace denv_sconv_aic3=1 if nthRecAIC==tempfirstFilled_Act3 &  denv_igg_y[_n+`k']==0 & denv_igg_y[_n+`k'+`i']==1 & tdiffAcute3[_n+`k'+`i']>=14 & tdiffAcute3[_n+`k'+`i']<=84 & Acute3==1 
}
}
ta denv_sconv_aic3, m
ta denv_sconv_aic3 denv_igg_y if nthRecAIC==tempfirstFilled_Act3, m
*browse person_id nthRecAIC Acute denv_igg_y denv_sconv_aic3 if denv_sconv_aic3==1 & denv_igg_y==0
*person_id=MF0421 it is stored in nthRecAIC==tempfirstFilled_Act3, but the serconversion happens later
*browse person_id nthRecAIC Acute denv_igg_y denv_sconv_aic3 if denv_sconv_aic3==0 & denv_igg_y==1
*person_id=MF0421 was seropositive from the start

*Seropositive at the beginning
gen denv_sPos1stRec_aic3=.
replace denv_sPos1stRec_aic3=1 if denv_igg_y==1 & nthRecAIC==tempfirstFilled_Act3 
ta denv_sPos1stRec_aic3 denv_igg_y if nthRecAIC==tempfirstFilled_Act3, m
sort person_id nthRecAIC
by person_id: carryforward denv_sPos1stRec_aic3, replace

*Censor individuals seropositive at intake
ta denv_igg_y denv_sconv_aic3 if nthRecAIC==tempfirstFilled_Act3, m 

gen denv_sconv_aic3_censrd=denv_sconv_aic3
replace denv_sconv_aic3_censrd=. if denv_sPos1stRec_aic3==1

**browse person_id date_complete tdiffAcute3 nthRecAIC Acute3 denv_igg_y denv_sconv_aic3 
ta denv_sconv_aic3

*Store information in the first record 
gen denv_sconv_aic3_1Rec=denv_sconv_aic3
sort person_id date_complete nthRecAIC
by person_id: carryforward denv_sconv_aic3_1Rec, replace
gsort person_id -date_complete -nthRecAIC
by person_id: carryforward denv_sconv_aic3_1Rec, replace
sort person_id date_complete nthRecAIC
replace denv_sconv_aic3_1Rec=. if nthRecAIC!=1
ta denv_sconv_aic3, m

****************************************************************************

****************************************************************************
*4th Acute: DENV seroconversion during time gap >=14d and <=84d
gen denv_sconv_aic4=.

*Overwriting not allowed
 forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace denv_sconv_aic4=0 if nthRecAIC==tempfirstFilled_Act4 &  denv_igg_y[_n]==0 & denv_igg_y[_n+`i']==0 & tdiffAcute4[_n+`i']>=14 & tdiffAcute4[_n+`i']<=84 & Acute4==1 & denv_sconv_aic4[_n]==.
}
forval k=1/8{
forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace denv_sconv_aic4=0 if nthRecAIC==tempfirstFilled_Act4 &  denv_igg_y[_n+`k']==0 & denv_igg_y[_n+`k'+`i']==0 & tdiffAcute4[_n+`k'+`i']>=14 & tdiffAcute4[_n+`k'+`i']<=84 & Acute4==1 & denv_sconv_aic4[_n]==.
}
}
ta denv_sconv_aic4 nthRecAIC, m


*Seropositive at the beginning; censor later
forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace denv_sconv_aic4=0 if nthRecAIC==tempfirstFilled_Act4 &  denv_igg_y[_n]==1 & denv_igg_y[_n+`i']==1 & tdiffAcute4[_n+`i']>=14 & tdiffAcute4[_n+`i']<=84 & Acute4==1 & denv_sconv_aic4[_n]==.
}
forval k=1/8{
forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace denv_sconv_aic4=0 if nthRecAIC==tempfirstFilled_Act4 &  denv_igg_y[_n+`k']==1 & denv_igg_y[_n+`k'+`i']==1 & tdiffAcute4[_n+`k'+`i']>=14 & tdiffAcute4[_n+`k'+`i']<=84 & Acute4==1 & denv_sconv_aic4[_n]==.
}
}
ta denv_sconv_aic4 nthRecAIC, m
ta denv_sconv_aic4 Acute4, m


forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace denv_sconv_aic4=0 if nthRecAIC==tempfirstFilled_Act4 &  denv_igg_y[_n]==1 & denv_igg_y[_n+`i']==0 & tdiffAcute4[_n+`i']>=14 & tdiffAcute4[_n+`i']<=84 & Acute4==1 & denv_sconv_aic4[_n]==.
}
forval k=1/8{
forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace denv_sconv_aic4=0 if nthRecAIC==tempfirstFilled_Act4 &  denv_igg_y[_n+`k']==1 & denv_igg_y[_n+`k'+`i']==0 & tdiffAcute4[_n+`k'+`i']>=14 & tdiffAcute4[_n+`k'+`i']<=84 & Acute4==1 & denv_sconv_aic4[_n]==.
}
}
ta denv_sconv_aic4 nthRecAIC, m
ta denv_sconv_aic4 Acute4, m

*Actual seroconversion
forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace denv_sconv_aic4=1 if nthRecAIC==tempfirstFilled_Act4 &  denv_igg_y[_n]==0 & denv_igg_y[_n+`i']==1 & tdiffAcute4[_n+`i']>=14 & tdiffAcute4[_n+`i']<=84 & Acute4==1 
}
forval k=1/8{
forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace denv_sconv_aic4=1 if nthRecAIC==tempfirstFilled_Act4 &  denv_igg_y[_n+`k']==0 & denv_igg_y[_n+`k'+`i']==1 & tdiffAcute4[_n+`k'+`i']>=14 & tdiffAcute4[_n+`k'+`i']<=84 & Acute4==1 
}
}
ta denv_sconv_aic4, m
ta denv_sconv_aic4 denv_igg_y if nthRecAIC==tempfirstFilled_Act4, m

*Seropositive at the beginning
gen denv_sPos1stRec_aic4=.
replace denv_sPos1stRec_aic4=1 if denv_igg_y==1 & nthRecAIC==tempfirstFilled_Act4 
ta denv_sPos1stRec_aic4 denv_igg_y if nthRecAIC==tempfirstFilled_Act4, m
sort person_id nthRecAIC
by person_id: carryforward denv_sPos1stRec_aic4, replace

*Censor individuals seropositive at intake
ta denv_igg_y denv_sconv_aic4 if nthRecAIC==tempfirstFilled_Act4, m 

gen denv_sconv_aic4_censrd=denv_sconv_aic4
replace denv_sconv_aic4_censrd=. if denv_sPos1stRec_aic4==1

**browse person_id date_complete tdiffAcute4 nthRecAIC Acute4 denv_igg_y denv_sconv_aic4 
ta denv_sconv_aic4

*Store information in the first record of the visits belonging to Acute4
gen denv_sconv_aic4_1Rec=denv_sconv_aic4
sort person_id date_complete nthRecAIC
by person_id: carryforward denv_sconv_aic4_1Rec, replace
gsort person_id -date_complete -nthRecAIC
by person_id: carryforward denv_sconv_aic4_1Rec, replace
sort person_id date_complete nthRecAIC
replace denv_sconv_aic4_1Rec=. if nthRecAIC!=1
ta denv_sconv_aic4, m

********************************************************************************
**Serconversion total 
********************************************************************************
ta denv_sconv_aic1 denv_sconv_aic2, m
ta denv_sconv_aic1 denv_sconv_aic3, m
ta denv_sconv_aic1 denv_sconv_aic4, m
ta denv_sconv_aic2 denv_sconv_aic3, m
ta denv_sconv_aic2 denv_sconv_aic4, m
*All stored in another record

gen denv_sconv_aicT=.
replace denv_sconv_aicT=0 if denv_sconv_aic1_censrd==0
replace denv_sconv_aicT=1 if denv_sconv_aic1_censrd==1
ta denv_sconv_aic1, m
ta denv_sconv_aicT, m
replace denv_sconv_aicT=0 if denv_sconv_aic2_censrd==0 
replace denv_sconv_aicT=1 if denv_sconv_aic2_censrd==1 
ta denv_sconv_aic2, m
ta denv_sconv_aicT, m
replace denv_sconv_aicT=0 if denv_sconv_aic3_censrd==0
replace denv_sconv_aicT=1 if denv_sconv_aic3_censrd==1
ta denv_sconv_aic3, m
ta denv_sconv_aicT, m
replace denv_sconv_aicT=0 if denv_sconv_aic4_censrd==0
replace denv_sconv_aicT=1 if denv_sconv_aic4_censrd==1
ta denv_sconv_aic4, m
ta denv_sconv_aicT, m
ta denv_sconv_aicT  nthRecAIC, m

********************************************************************************
**Proportion positive
********************************************************************************
ta denv_pcr_aicT nthRecAIC, m

gen denv_pos_aic=.
replace denv_pos_aic=0 if denv_pcr_aicT==0
replace denv_pos_aic=1 if denv_pcr_aicT==1
ta denv_pos_aic denv_pcr_aicT, m

ta denv_pos_aic denv_sconv_aicT, m
ta denv_pcr_aicT denv_sconv_aicT, m
replace denv_pos_aic=1 if denv_sconv_aicT==1 & denv_pcr_aicT!=.
ta denv_pos_aic denv_sconv_aicT, m
ta denv_pos_aic, m
ta denv_pos_aic

*browse person_id date_comple nthRec denv_pcr_aicT denv_pos_aic denv_sconv_aicT
















********************************************************************************
**Prepare outcome for logistic regression analyses
********************************************************************************

*1st Acute: chikv pcr outcome for AIC taking all possible PCR outcomes during time gap >=14d and <=84d
gen chikv_pcr_aic1=. 

replace chikv_pcr_aic1=1 if chikv_pcr_y==1 & Acute==1
sort person_id date_complete nthRecAIC
by person_id: carryforward chikv_pcr_aic1 if Acute==1, replace
gsort person_id -date_complete -nthRecAIC
by person_id: carryforward chikv_pcr_aic1 if Acute==1, replace
sort person_id date_complete nthRecAIC

replace chikv_pcr_aic1=0 if chikv_pcr_y==0 & Acute==1 & chikv_pcr_aic1==.
sort person_id date_complete nthRecAIC
by person_id: carryforward chikv_pcr_aic1 if Acute==1, replace
gsort person_id -date_complete -nthRecAIC
by person_id: carryforward chikv_pcr_aic1 if Acute==1, replace
sort person_id date_complete nthRecAIC
ta chikv_pcr_aic1, m

replace chikv_pcr_aic1=. if nthRecAIC!=1
ta chikv_pcr_aic1, m

**browse person_id date_complete nthRec Acute tdiffAcute1 chikv_pcr_y chikv_pcr_aic1

*2nd Acute: chikv pcr outcome for AIC taking all possible PCR outcomes during time gap >=14d and <=84d
gen chikv_pcr_aic2=. 

replace chikv_pcr_aic2=1 if chikv_pcr_y==1 & Acute==2
sort person_id date_complete nthRecAIC
by person_id: carryforward chikv_pcr_aic2 if Acute==2, replace
gsort person_id -date_complete -nthRecAIC
by person_id: carryforward chikv_pcr_aic2 if Acute==2, replace
sort person_id date_complete nthRecAIC

replace chikv_pcr_aic2=0 if chikv_pcr_y==0 & Acute==2 & chikv_pcr_aic2==.
sort person_id date_complete nthRecAIC
by person_id: carryforward chikv_pcr_aic2 if Acute==2, replace
gsort person_id -date_complete -nthRecAIC
by person_id: carryforward chikv_pcr_aic2 if Acute==2, replace
sort person_id date_complete nthRecAIC
ta chikv_pcr_aic2, m

replace chikv_pcr_aic2=. if nthRecAIC!=tempfirstFilled

ta chikv_pcr_aic2, m

*Third Acute: chikv pcr outcome for AIC taking all possible PCR outcomes during time gap >=14d and <=84d
gen chikv_pcr_aic3=. 

*Carryforward only replaces missings, so first fill in when pcr==pos
replace chikv_pcr_aic3=1 if chikv_pcr_y==1 & Acute==3
sort person_id date_complete nthRecAIC
by person_id: carryforward chikv_pcr_aic3 if Acute==3, replace
gsort person_id -date_complete -nthRecAIC
by person_id: carryforward chikv_pcr_aic3 if Acute==3, replace
sort person_id date_complete nthRecAIC
ta chikv_pcr_aic3, m

replace chikv_pcr_aic3=0 if chikv_pcr_y==0 & Acute==3 & chikv_pcr_aic3==.
sort person_id date_complete nthRecAIC
by person_id: carryforward chikv_pcr_aic3 if Acute==3, replace
gsort person_id -date_complete -nthRecAIC
by person_id: carryforward chikv_pcr_aic3 if Acute==3, replace
sort person_id date_complete nthRecAIC
ta chikv_pcr_aic3, m

replace chikv_pcr_aic3=. if nthRecAIC!=tempfirstFilled_Act3
ta chikv_pcr_aic3, m


*Fourth Acute: chikv pcr outcome for AIC taking all possible PCR outcomes during time gap >=14d and <=84d
gen chikv_pcr_aic4=. 

replace chikv_pcr_aic4=1 if chikv_pcr_y==1 & Acute==4
sort person_id date_complete nthRecAIC
by person_id: carryforward chikv_pcr_aic4 if Acute==4, replace
gsort person_id -date_complete -nthRecAIC
by person_id: carryforward chikv_pcr_aic4 if Acute==4, replace
sort person_id date_complete nthRecAIC

replace chikv_pcr_aic4=0 if chikv_pcr_y==0 & Acute==4 & chikv_pcr_aic4==.
sort person_id date_complete nthRecAIC
by person_id: carryforward chikv_pcr_aic4 if Acute==4, replace
gsort person_id -date_complete -nthRecAIC
by person_id: carryforward chikv_pcr_aic4 if Acute==4, replace
sort person_id date_complete nthRecAIC
ta chikv_pcr_aic4, m

replace chikv_pcr_aic4=. if nthRecAIC!=tempfirstFilled_Act4
ta chikv_pcr_aic4, m

*Total
ta chikv_pcr_aic1 chikv_pcr_aic2, m
ta chikv_pcr_aic1 chikv_pcr_aic3, m
ta chikv_pcr_aic1 chikv_pcr_aic4, m

gen chikv_pcr_aicT=.
replace chikv_pcr_aicT=0 if chikv_pcr_aic1==0
replace chikv_pcr_aicT=0 if chikv_pcr_aic2==0
replace chikv_pcr_aicT=0 if chikv_pcr_aic3==0
replace chikv_pcr_aicT=0 if chikv_pcr_aic4==0

replace chikv_pcr_aicT=1 if chikv_pcr_aic1==1
replace chikv_pcr_aicT=1 if chikv_pcr_aic2==1
replace chikv_pcr_aicT=1 if chikv_pcr_aic3==1
replace chikv_pcr_aicT=1 if chikv_pcr_aic4==1
ta chikv_pcr_aicT Acute, m
ta chikv_pcr_aicT Acute, col

****************************************************************************
*1st Acute: chikv seroconversion during time gap >=14d and <=84d
gen chikv_sconv_aic1=.

*Overwriting not allowed
 forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace chikv_sconv_aic1=0 if nthRecAIC==1 &  chikv_igg_y[_n]==0 & chikv_igg_y[_n+`i']==0 & tdiffAcute1[_n+`i']>=14 & tdiffAcute1[_n+`i']<=84 & Acute1==1 & chikv_sconv_aic1[_n]==.
}
forval k=1/8{
forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace chikv_sconv_aic1=0 if nthRecAIC==1 &  chikv_igg_y[_n+`k']==0 & chikv_igg_y[_n+`k'+`i']==0 & tdiffAcute1[_n+`k'+`i']>=14 & tdiffAcute1[_n+`k'+`i']<=84 & Acute1==1 & chikv_sconv_aic1[_n]==.
}
}
ta chikv_sconv_aic1 nthRecAIC, m

*I am using this to map whether a sample had a follow-up sample, but actually these persons need to be censored for analyses purpose
forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace chikv_sconv_aic1=0 if nthRecAIC==1 &  chikv_igg_y[_n]==1 & chikv_igg_y[_n+`i']==1 & tdiffAcute1[_n+`i']>=14 & tdiffAcute1[_n+`i']<=84 & Acute1==1 & chikv_sconv_aic1[_n]==.
}
forval k=1/8{
forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace chikv_sconv_aic1=0 if nthRecAIC==1 &  chikv_igg_y[_n+`k']==1 & chikv_igg_y[_n+`k'+`i']==1 & tdiffAcute1[_n+`k'+`i']>=14 & tdiffAcute1[_n+`k'+`i']<=84 & Acute1==1 & chikv_sconv_aic1[_n]==.
}
}
ta chikv_sconv_aic1 nthRecAIC, m
ta chikv_sconv_aic1 Acute1, m

forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace chikv_sconv_aic1=0 if nthRecAIC==1 &  chikv_igg_y[_n]==1 & chikv_igg_y[_n+`i']==0 & tdiffAcute1[_n+`i']>=14 & tdiffAcute1[_n+`i']<=84 & Acute1==1 & chikv_sconv_aic1[_n]==.
}
forval k=1/8{
forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace chikv_sconv_aic1=0 if nthRecAIC==1 &  chikv_igg_y[_n+`k']==1 & chikv_igg_y[_n+`k'+`i']==0 & tdiffAcute1[_n+`k'+`i']>=14 & tdiffAcute1[_n+`k'+`i']<=84 & Acute1==1 & chikv_sconv_aic1[_n]==.
}
}
ta chikv_sconv_aic1 nthRecAIC, m
ta chikv_sconv_aic1 Acute1, m

*overwriting okay 
forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace chikv_sconv_aic1=1 if nthRecAIC==1 &  chikv_igg_y[_n]==0 & chikv_igg_y[_n+`i']==1 & tdiffAcute1[_n+`i']>=14 & tdiffAcute1[_n+`i']<=84 & Acute1==1 
}
forval k=1/8{
forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace chikv_sconv_aic1=1 if nthRecAIC==1 &  chikv_igg_y[_n+`k']==0 & chikv_igg_y[_n+`k'+`i']==1 & tdiffAcute1[_n+`k'+`i']>=14 & tdiffAcute1[_n+`k'+`i']<=84 & Acute1==1 
}
}
ta chikv_sconv_aic1, m
ta chikv_sconv_aic1
*
* 
**browse person_id date_complete tdiffAcute1 nthRecAIC chikv_igg_y chikv_sconv_aic1
ta chikv_sconv_aic1 if nthRec==1, m

*Seropositive at the beginning
gen chikv_sPos1stRec_aic1=.
replace chikv_sPos1stRec_aic1=1 if chikv_igg_y==1 & nthRecAIC==1 
ta chikv_sPos1stRec_aic1 chikv_igg_y if nthRecAIC==1, m
sort person_id nthRecAIC
by person_id: carryforward chikv_sPos1stRec_aic1, replace

*Censor individuals seropositive at intake
ta chikv_igg_y chikv_sconv_aic1 if  nthRecAIC==1, m 
*chikv_igg_y=. & chikv_sconv_aic1=0  -->  person_id=UF0625

gen chikv_sconv_aic1_censrd=chikv_sconv_aic1
replace chikv_sconv_aic1_censrd=. if chikv_sPos1stRec_aic1==1

gen chikv_sconv_aic1_1Rec=chikv_sconv_aic1 //is already stored in the first record

****************************************************************************
*2nd Acute: chikv seroconversion during time gap >=14d and <=84d
gen chikv_sconv_aic2=.


**browse person_id visitLetter2 Acute nthRecAIC tempfirstFilled chikv_igg_y tdiffAcute2 Acute2 chikv_sconv_aic2 if chikv_igg_y==1 & Acute==2
**browse person_id visitLetter2 Acute nthRecAIC tempfirstFilled chikv_igg_y tdiffAcute2 Acute2 chikv_sconv_aic2 
*Overwriting not allowed
 forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace chikv_sconv_aic2=0 if nthRecAIC==tempfirstFilled &  chikv_igg_y[_n]==0 & chikv_igg_y[_n+`i']==0 & tdiffAcute2[_n+`i']>=14 & tdiffAcute2[_n+`i']<=84 & Acute2==1 & chikv_sconv_aic2[_n]==.
}
forval k=1/8{
forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace chikv_sconv_aic2=0 if nthRecAIC==tempfirstFilled &  chikv_igg_y[_n+`k']==0 & chikv_igg_y[_n+`k'+`i']==0 & tdiffAcute2[_n+`k'+`i']>=14 & tdiffAcute2[_n+`k'+`i']<=84 & Acute2==1 & chikv_sconv_aic2[_n]==.
}
}
ta chikv_sconv_aic2 nthRecAIC, m


*Seropositive at the beginning; censor later
forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace chikv_sconv_aic2=0 if nthRecAIC==tempfirstFilled &  chikv_igg_y[_n]==1 & chikv_igg_y[_n+`i']==1 & tdiffAcute2[_n+`i']>=14 & tdiffAcute2[_n+`i']<=84 & Acute2==1 & chikv_sconv_aic2[_n]==.
}
forval k=1/8{
forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace chikv_sconv_aic2=0 if nthRecAIC==tempfirstFilled &  chikv_igg_y[_n+`k']==1 & chikv_igg_y[_n+`k'+`i']==1 & tdiffAcute2[_n+`k'+`i']>=14 & tdiffAcute2[_n+`k'+`i']<=84 & Acute2==1 & chikv_sconv_aic2[_n]==.
}
}
ta chikv_sconv_aic2 nthRecAIC, m
ta chikv_sconv_aic2 Acute2, m


forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace chikv_sconv_aic2=0 if nthRecAIC==tempfirstFilled &  chikv_igg_y[_n]==1 & chikv_igg_y[_n+`i']==0 & tdiffAcute2[_n+`i']>=14 & tdiffAcute2[_n+`i']<=84 & Acute2==1 & chikv_sconv_aic2[_n]==.
}
forval k=1/8{
forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace chikv_sconv_aic2=0 if nthRecAIC==tempfirstFilled &  chikv_igg_y[_n+`k']==1 & chikv_igg_y[_n+`k'+`i']==0 & tdiffAcute2[_n+`k'+`i']>=14 & tdiffAcute2[_n+`k'+`i']<=84 & Acute2==1 & chikv_sconv_aic2[_n]==.
}
}
ta chikv_sconv_aic2 nthRecAIC, m
ta chikv_sconv_aic2 Acute2, m

*Actual seroconversion
forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace chikv_sconv_aic2=1 if nthRecAIC==tempfirstFilled &  chikv_igg_y[_n]==0 & chikv_igg_y[_n+`i']==1 & tdiffAcute2[_n+`i']>=14 & tdiffAcute2[_n+`i']<=84 & Acute2==1 
}
forval k=1/8{
forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace chikv_sconv_aic2=1 if nthRecAIC==tempfirstFilled &  chikv_igg_y[_n+`k']==0 & chikv_igg_y[_n+`k'+`i']==1 & tdiffAcute2[_n+`k'+`i']>=14 & tdiffAcute2[_n+`k'+`i']<=84 & Acute2==1 
}
}
ta chikv_sconv_aic2, m
ta chikv_sconv_aic2 chikv_igg_y, m

*Seropositive at the beginning
gen chikv_sPos1stRec_aic2=.
replace chikv_sPos1stRec_aic2=1 if chikv_igg_y==1 & nthRecAIC==tempfirstFilled 
ta chikv_sPos1stRec_aic2 chikv_igg_y if nthRecAIC==tempfirstFilled, m
sort person_id nthRecAIC
by person_id: carryforward chikv_sPos1stRec_aic2, replace

*Censor individuals seropositive at intake
ta chikv_igg_y chikv_sconv_aic2 if nthRecAIC==tempfirstFilled, m 

gen chikv_sconv_aic2_censrd=chikv_sconv_aic2
replace chikv_sconv_aic2_censrd=. if chikv_sPos1stRec_aic2==1

**browse person_id date_complete tdiffAcute2 nthRecAIC Acute2 chikv_igg_y chikv_sconv_aic2 
ta chikv_sconv_aic2

*Store information in the first record 
gen chikv_sconv_aic2_1Rec=chikv_sconv_aic2
sort person_id date_complete nthRecAIC
by person_id: carryforward chikv_sconv_aic2_1Rec, replace
gsort person_id -date_complete -nthRecAIC
by person_id: carryforward chikv_sconv_aic2_1Rec, replace
sort person_id date_complete nthRecAIC
replace chikv_sconv_aic2_1Rec=. if nthRecAIC!=1
ta chikv_sconv_aic2, m


****************************************************************************
*3th Acute: chikv seroconversion during time gap >=14d and <=84d
gen chikv_sconv_aic3=.

**browse person_id visitLetter2 Acute nthRecAIC tempfirstFilled_Act3 chikv_igg_y tdiffAcute3 Acute3 chikv_sconv_aic3 if chikv_igg_y==1 &Acute==3
**browse person_id visitLetter2 Acute nthRecAIC tempfirstFilled_Act3 chikv_igg_y tdiffAcute3 Acute3 chikv_sconv_aic3 

*Overwriting not allowed
 forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace chikv_sconv_aic3=0 if nthRecAIC==tempfirstFilled_Act3 &  chikv_igg_y[_n]==0 & chikv_igg_y[_n+`i']==0 & tdiffAcute3[_n+`i']>=14 & tdiffAcute3[_n+`i']<=84 & Acute3==1 & chikv_sconv_aic3[_n]==.
}
forval k=1/8{
forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace chikv_sconv_aic3=0 if nthRecAIC==tempfirstFilled_Act3 &  chikv_igg_y[_n+`k']==0 & chikv_igg_y[_n+`k'+`i']==0 & tdiffAcute3[_n+`k'+`i']>=14 & tdiffAcute3[_n+`k'+`i']<=84 & Acute3==1 & chikv_sconv_aic3[_n]==.
}
}
ta chikv_sconv_aic3 nthRecAIC, m


*Seropositive at the beginning; censor later
forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace chikv_sconv_aic3=0 if nthRecAIC==tempfirstFilled_Act3 &  chikv_igg_y[_n]==1 & chikv_igg_y[_n+`i']==1 & tdiffAcute3[_n+`i']>=14 & tdiffAcute3[_n+`i']<=84 & Acute3==1 & chikv_sconv_aic3[_n]==.
}
forval k=1/8{
forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace chikv_sconv_aic3=0 if nthRecAIC==tempfirstFilled_Act3 &  chikv_igg_y[_n+`k']==1 & chikv_igg_y[_n+`k'+`i']==1 & tdiffAcute3[_n+`k'+`i']>=14 & tdiffAcute3[_n+`k'+`i']<=84 & Acute3==1 & chikv_sconv_aic3[_n]==.
}
}
ta chikv_sconv_aic3 nthRecAIC, m
ta chikv_sconv_aic3 Acute3, m


forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace chikv_sconv_aic3=0 if nthRecAIC==tempfirstFilled_Act3 &  chikv_igg_y[_n]==1 & chikv_igg_y[_n+`i']==0 & tdiffAcute3[_n+`i']>=14 & tdiffAcute3[_n+`i']<=84 & Acute3==1 & chikv_sconv_aic3[_n]==.
}
forval k=1/8{
forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace chikv_sconv_aic3=0 if nthRecAIC==tempfirstFilled_Act3 &  chikv_igg_y[_n+`k']==1 & chikv_igg_y[_n+`k'+`i']==0 & tdiffAcute3[_n+`k'+`i']>=14 & tdiffAcute3[_n+`k'+`i']<=84 & Acute3==1 & chikv_sconv_aic3[_n]==.
}
}
ta chikv_sconv_aic3 nthRecAIC, m
ta chikv_sconv_aic3 Acute3, m

*Actual seroconversion
forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace chikv_sconv_aic3=1 if nthRecAIC==tempfirstFilled_Act3 &  chikv_igg_y[_n]==0 & chikv_igg_y[_n+`i']==1 & tdiffAcute3[_n+`i']>=14 & tdiffAcute3[_n+`i']<=84 & Acute3==1 
}
forval k=1/8{
forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace chikv_sconv_aic3=1 if nthRecAIC==tempfirstFilled_Act3 &  chikv_igg_y[_n+`k']==0 & chikv_igg_y[_n+`k'+`i']==1 & tdiffAcute3[_n+`k'+`i']>=14 & tdiffAcute3[_n+`k'+`i']<=84 & Acute3==1 
}
}
ta chikv_sconv_aic3, m
ta chikv_sconv_aic3 chikv_igg_y if nthRecAIC==tempfirstFilled_Act3, m

*Seropositive at the beginning
gen chikv_sPos1stRec_aic3=.
replace chikv_sPos1stRec_aic3=1 if chikv_igg_y==1 & nthRecAIC==tempfirstFilled_Act3 
ta chikv_sPos1stRec_aic3 chikv_igg_y if nthRecAIC==tempfirstFilled_Act3, m
sort person_id nthRecAIC
by person_id: carryforward chikv_sPos1stRec_aic3, replace

*Censor individuals seropositive at intake
ta chikv_igg_y chikv_sconv_aic3 if nthRecAIC==tempfirstFilled_Act3, m 

gen chikv_sconv_aic3_censrd=chikv_sconv_aic3
replace chikv_sconv_aic3_censrd=. if chikv_sPos1stRec_aic3==1

**browse person_id date_complete tdiffAcute3 nthRecAIC Acute3 chikv_igg_y chikv_sconv_aic3 
ta chikv_sconv_aic3

*Store information in the first record 
gen chikv_sconv_aic3_1Rec=chikv_sconv_aic3
sort person_id date_complete nthRecAIC
by person_id: carryforward chikv_sconv_aic3_1Rec, replace
gsort person_id -date_complete -nthRecAIC
by person_id: carryforward chikv_sconv_aic3_1Rec, replace
sort person_id date_complete nthRecAIC
replace chikv_sconv_aic3_1Rec=. if nthRecAIC!=1
ta chikv_sconv_aic3, m

****************************************************************************

****************************************************************************
*4th Acute: chikv seroconversion during time gap >=14d and <=84d
gen chikv_sconv_aic4=.

*Overwriting not allowed
 forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace chikv_sconv_aic4=0 if nthRecAIC==tempfirstFilled_Act4 &  chikv_igg_y[_n]==0 & chikv_igg_y[_n+`i']==0 & tdiffAcute4[_n+`i']>=14 & tdiffAcute4[_n+`i']<=84 & Acute4==1 & chikv_sconv_aic4[_n]==.
}
forval k=1/8{
forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace chikv_sconv_aic4=0 if nthRecAIC==tempfirstFilled_Act4 &  chikv_igg_y[_n+`k']==0 & chikv_igg_y[_n+`k'+`i']==0 & tdiffAcute4[_n+`k'+`i']>=14 & tdiffAcute4[_n+`k'+`i']<=84 & Acute4==1 & chikv_sconv_aic4[_n]==.
}
}
ta chikv_sconv_aic4 nthRecAIC, m

*Seropositive at the beginning; censor later
forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace chikv_sconv_aic4=0 if nthRecAIC==tempfirstFilled_Act4 &  chikv_igg_y[_n]==1 & chikv_igg_y[_n+`i']==1 & tdiffAcute4[_n+`i']>=14 & tdiffAcute4[_n+`i']<=84 & Acute4==1 & chikv_sconv_aic4[_n]==.
}
forval k=1/8{
forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace chikv_sconv_aic4=0 if nthRecAIC==tempfirstFilled_Act4 &  chikv_igg_y[_n+`k']==1 & chikv_igg_y[_n+`k'+`i']==1 & tdiffAcute4[_n+`k'+`i']>=14 & tdiffAcute4[_n+`k'+`i']<=84 & Acute4==1 & chikv_sconv_aic4[_n]==.
}
}
ta chikv_sconv_aic4 nthRecAIC, m
ta chikv_sconv_aic4 Acute4, m

forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace chikv_sconv_aic4=0 if nthRecAIC==tempfirstFilled_Act4 &  chikv_igg_y[_n]==1 & chikv_igg_y[_n+`i']==0 & tdiffAcute4[_n+`i']>=14 & tdiffAcute4[_n+`i']<=84 & Acute4==1 & chikv_sconv_aic4[_n]==.
}
forval k=1/8{
forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace chikv_sconv_aic4=0 if nthRecAIC==tempfirstFilled_Act4 &  chikv_igg_y[_n+`k']==1 & chikv_igg_y[_n+`k'+`i']==0 & tdiffAcute4[_n+`k'+`i']>=14 & tdiffAcute4[_n+`k'+`i']<=84 & Acute4==1 & chikv_sconv_aic4[_n]==.
}
}
ta chikv_sconv_aic4 nthRecAIC, m
ta chikv_sconv_aic4 Acute4, m

*Actual seroconversion
forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace chikv_sconv_aic4=1 if nthRecAIC==tempfirstFilled_Act4 &  chikv_igg_y[_n]==0 & chikv_igg_y[_n+`i']==1 & tdiffAcute4[_n+`i']>=14 & tdiffAcute4[_n+`i']<=84 & Acute4==1 
}
forval k=1/8{
forval i=1/8{
sort person_id date_complete nthRecAIC
by person_id: replace chikv_sconv_aic4=1 if nthRecAIC==tempfirstFilled_Act4 &  chikv_igg_y[_n+`k']==0 & chikv_igg_y[_n+`k'+`i']==1 & tdiffAcute4[_n+`k'+`i']>=14 & tdiffAcute4[_n+`k'+`i']<=84 & Acute4==1 
}
}
ta chikv_sconv_aic4, m
ta chikv_sconv_aic4 chikv_igg_y if nthRecAIC==tempfirstFilled_Act4, m

*Seropositive at the beginning
gen chikv_sPos1stRec_aic4=.
replace chikv_sPos1stRec_aic4=1 if chikv_igg_y==1 & nthRecAIC==tempfirstFilled_Act4 
ta chikv_sPos1stRec_aic4 chikv_igg_y if nthRecAIC==tempfirstFilled_Act4, m
sort person_id nthRecAIC
by person_id: carryforward chikv_sPos1stRec_aic4, replace

*Censor individuals seropositive at intake
ta chikv_igg_y chikv_sconv_aic4 if nthRecAIC==tempfirstFilled_Act4, m 

gen chikv_sconv_aic4_censrd=chikv_sconv_aic4
replace chikv_sconv_aic4_censrd=. if chikv_sPos1stRec_aic4==1

**browse person_id date_complete tdiffAcute4 nthRecAIC Acute4 chikv_igg_y chikv_sconv_aic4 
ta chikv_sconv_aic4

*Store information in the first record of the visits belonging to Acute4
gen chikv_sconv_aic4_1Rec=chikv_sconv_aic4
sort person_id date_complete nthRecAIC
by person_id: carryforward chikv_sconv_aic4_1Rec, replace
gsort person_id -date_complete -nthRecAIC
by person_id: carryforward chikv_sconv_aic4_1Rec, replace
sort person_id date_complete nthRecAIC
replace chikv_sconv_aic4_1Rec=. if nthRecAIC!=1
ta chikv_sconv_aic4, m


********************************************************************************
**Serconversion total 
********************************************************************************
ta chikv_sconv_aic1 chikv_sconv_aic2, m
ta chikv_sconv_aic1 chikv_sconv_aic3, m
ta chikv_sconv_aic1 chikv_sconv_aic4, m
ta chikv_sconv_aic2 chikv_sconv_aic3, m
ta chikv_sconv_aic2 chikv_sconv_aic4, m
*All stored in another record

gen chikv_sconv_aicT=.
replace chikv_sconv_aicT=0 if chikv_sconv_aic1_censrd==0
replace chikv_sconv_aicT=1 if chikv_sconv_aic1_censrd==1
ta chikv_sconv_aic1, m
ta chikv_sconv_aicT, m
replace chikv_sconv_aicT=0 if chikv_sconv_aic2_censrd==0 
replace chikv_sconv_aicT=1 if chikv_sconv_aic2_censrd==1 
ta chikv_sconv_aic2, m
ta chikv_sconv_aicT, m
replace chikv_sconv_aicT=0 if chikv_sconv_aic3_censrd==0
replace chikv_sconv_aicT=1 if chikv_sconv_aic3_censrd==1
ta chikv_sconv_aic3, m
ta chikv_sconv_aicT, m
replace chikv_sconv_aicT=0 if chikv_sconv_aic4_censrd==0
replace chikv_sconv_aicT=1 if chikv_sconv_aic4_censrd==1
ta chikv_sconv_aic4, m
ta chikv_sconv_aicT, m
ta chikv_sconv_aicT  nthRecAIC, m

********************************************************************************
**Proportion positive
********************************************************************************
ta chikv_pcr_aicT nthRecAIC, m

gen chikv_pos_aic=.
replace chikv_pos_aic=0 if chikv_pcr_aicT==0
replace chikv_pos_aic=1 if chikv_pcr_aicT==1
ta chikv_pos_aic chikv_pcr_aicT, m

ta chikv_pcr_aicT chikv_sconv_aicT, m
replace chikv_pos_aic=1 if chikv_sconv_aicT==1 & chikv_pcr_aicT!=.
ta chikv_pos_aic, m

*browse person_id date_comple nthRec chikv_pcr_aicT chikv_pos_aic chikv_sconv_aicT


********************************************************************************
**Proportion co-infected
********************************************************************************

gen chikvDenv_pos_aic=.
replace chikvDenv_pos_aic=0 if denv_pos_aic==0 & chikv_pos_aic==0
replace chikvDenv_pos_aic=1 if denv_pos_aic==1 & chikv_pos_aic==0
replace chikvDenv_pos_aic=1 if denv_pos_aic==0 & chikv_pos_aic==1
replace chikvDenv_pos_aic=2 if denv_pos_aic==1 & chikv_pos_aic==1
label define lbl_chikvDenv_pos_aic 0 "neg" 1 "denvORchikv" 2 "both"
label val chikvDenv_pos_aic lbl_chikvDenv_pos_aic
ta chikvDenv_pos_aic, m
bysort denv_pos_aic: ta chikvDenv_pos_aic chikv_pos_aic, m




********************************************************************************
**DENV seropositivity
********************************************************************************

ta denv_igg_y, m
gen denv_igg_T=.
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace denv_igg_T=denv_igg_y if nthRecAIC==`i' & Acute==`k' & denv_igg_T==.
ta denv_igg_y denv_igg_T, m

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward denv_igg_T , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward denv_igg_T , replace
sort person_id date_complete nthRecAIC
}
}
* 
sort person_id Acute date_complete nthRecAIC 
browse person_id Acute date_complete nthRecAIC denv_igg_y denv_igg_T 

ta chikv_igg_y, m
gen chikv_igg_T=.
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace chikv_igg_T=chikv_igg_y if nthRecAIC==`i' & Acute==`k' & chikv_igg_T==.
ta chikv_igg_y chikv_igg_T, m

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward chikv_igg_T , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward chikv_igg_T , replace
sort person_id date_complete nthRecAIC
}
}
* 
sort person_id Acute date_complete nthRecAIC 
browse person_id Acute date_complete nthRecAIC chikv_igg_y chikv_igg_T 




save "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\Temporary.dta", replace
clear

use "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\Temporary.dta"












********************************************************************************
** House characteristics
********************************************************************************
*Variable names
*T=Total
*T2= missing and other category combined
*T3= missing category made really missing
*Cat=Continous variable categorized
*Cat3=Categorized variable of which missing group is made missing not as a separate cat
*So there is not Cat2, in which the "other"-group is combined with the missing group
*as this variables comes from a continous variable

*Roof type
ta roof_type, m
*1 Natural material
*2 Corrugated iron
*3 Plastic
*4 Other
*9 N/A
ta oth_roof_type, m
ta oth_roof_type roof_type , m

*I checked whether it would be better to use the reported roof_type
*of 1st, 2nd, 3th, 4th acute visit, rather than only from the 1st acute
*visit, and it gives almost the same answer; as using the roof_type reported
*during 1st, 2nd, 3th and 4th separately creates more missings (and
*as we assume roof_type should be constant over time we are using the
*first reported roof_type in the dataset

gen roofTypeT=.
forval i=1/8 {
sort person_id date_complete nthRecAIC
replace roofTypeT=1 if  roof_type=="1" & nthRecAIC==`i' & roofTypeT==.
replace roofTypeT=2 if  roof_type=="2" & nthRecAIC==`i' & roofTypeT==.
replace roofTypeT=3 if  roof_type=="3" & nthRecAIC==`i' & roofTypeT==.
replace roofTypeT=3 if  roof_type=="4" & nthRecAIC==`i' & roofTypeT==.
ta roofTypeT roof_type, m

sort person_id date_complete nthRecAIC
by person_id: carryforward roofTypeT, replace
gsort person_id -date_complete -nthRecAIC
by person_id: carryforward roofTypeT, replace
sort person_id date_complete nthRecAIC
ta roofTypeT, m
}
*I first fill-in with the other answers given, when nothing pops-up
ta roofTypeT, m
replace roofTypeT=4 if roofTypeT==. 
ta roofTypeT, m

label define lbl_roofType 1 "natural material" 2 "Iron" 3 "Plastic/Other" 4 "Missing"
label val roofTypeT lbl_roofType
ta roofTypeT, m

gen roofTypeT2=.
replace roofTypeT2=1 if roofTypeT==1
replace roofTypeT2=2 if roofTypeT==2
replace roofTypeT2=3 if roofTypeT==3
replace roofTypeT2=3 if roofTypeT==4
label define lbl_roofType2 1 "natural material" 2 "iron" 3 "Plastic/other/missing"
label val roofTypeT2 lbl_roofType2
ta roofTypeT2 roofTypeT, m

gen roofTypeT3=.
replace roofTypeT3=1 if roofTypeT==1
replace roofTypeT3=2 if roofTypeT==2
*replace roofTypeT3=3 if roofTypeT==3 //too small to be a separate category
label define lbl_roofType3 1 "natural material" 2 "iron" 3 "other;plastic"
label val roofTypeT3 lbl_roofType3
ta roofTypeT3 roofTypeT, m

*Check 
ta roofTypeT totRec, m 
ta roofTypeT AcuteT , m col

**browse person_id visitLetter nthRecAIC Acute roof_type roofTypeT  

********************************************************************************
*Floor type
ta floor_type			, m //What is the floor made out of?
ta oth_floor_type		, m 
ta floor_type oth_floor_type, m
*1 Dirt
*2 Wood
*3 Cement
*4 Tile
*5 Other
*9 N/A

gen floorTypeT=.
forval i=1/8 {
sort person_id date_complete nthRecAIC
replace floorTypeT=1 if  floor_type=="1" & nthRecAIC==`i' & floorTypeT==.
replace floorTypeT=1 if  floor_type=="2" & nthRecAIC==`i' & floorTypeT==.
replace floorTypeT=2 if  floor_type=="3" & nthRecAIC==`i' & floorTypeT==.
replace floorTypeT=2 if  floor_type=="4" & nthRecAIC==`i' & floorTypeT==.
replace floorTypeT=3 if  floor_type=="5" & nthRecAIC==`i' & floorTypeT==.
ta floorTypeT floor_type, m

sort person_id date_complete nthRecAIC
by person_id: carryforward floorTypeT, replace
gsort person_id -date_complete -nthRecAIC
by person_id: carryforward floorTypeT, replace
sort person_id date_complete nthRecAIC
ta floorTypeT, m
}
*
ta floorTypeT, m
replace floorTypeT=4 if floorTypeT==.
ta floorTypeT, m

ta floorTypeT floor_type, m
label define lbl_floorType 1 "soft" 2 "hard" 3 "other" 4 "missing"
label val floorTypeT lbl_floorType
ta floorTypeT, m

gen floorTypeT2=.
replace floorTypeT2=1 if floorTypeT==1
replace floorTypeT2=2 if floorTypeT==2
replace floorTypeT2=3 if floorTypeT==3
replace floorTypeT2=3 if floorTypeT==4
label define lbl_floorType2 1 "soft" 2 "hard" 3 "other/missing"
label val floorTypeT2 lbl_floorType2
ta floorTypeT2 floorTypeT, m

gen floorTypeT3=.
replace floorTypeT3=1 if floorTypeT==1
replace floorTypeT3=2 if floorTypeT==2
//replace floorTypeT3=3 if floorTypeT==3 //too small to be a separate category
label define lbl_floorType3 1 "soft" 2 "hard" //3 "other"
label val floorTypeT3 lbl_floorType3
ta floorTypeT3 floorTypeT, m

*Check 
ta floorTypeT totRec, m 
ta floorTypeT AcuteT , m col

********************************************************************************
**Number of rooms

*dmod$NumRooms <- ifelse(is.na(dmod$rooms_in_house), dmod$dem_hoh_rooms, ifelse(is.na(dmod$dem_hoh_rooms), dmod$rooms_in_house, NA))
ta rooms_in_house, m
replace rooms_in_house="" if rooms_in_house=="NA"
destring rooms_in_house, replace
ta rooms_in_house, m

gen numRoomsT=.
forval i=0/8{
sort person_id date_complete nthRecAIC
replace numRoomsT=rooms_in_house  if nthRecAIC==`i' & numRoomsT==.
*ta numRoomsT numRoomsT, m

sort person_id date_complete nthRecAIC
by person_id: carryforward numRoomsT, replace
gsort person_id -date_complete -nthRecAIC
by person_id: carryforward numRoomsT, replace
sort person_id date_complete nthRecAIC
ta numRoomsT, m
}
*
**browse person_id visitLetter date_complete nthRecAIC rooms_in_house if numRoomsT==.
**browse person_id visitLetter date_complete nthRecAIC rooms_in_house 

*I am assuming that more than 10 rooms is most likely a typo, so now categorized as missing
ta numRoomsT, m
replace numRoomsT=. if numRoomsT>=10
ta numRoomsT, m

*Var as category
gen numRoomsCat=.
replace numRoomsCat=1 if numRoomsT>=1 & numRoomsT<3
replace numRoomsCat=2 if numRoomsT>=3 & numRoomsT<7
replace numRoomsCat=3 if numRoomsT>=7 & numRoomsT<10
replace numRoomsCat=4 if numRoomsT==.
ta numRoomsT numRoomsCat , m
label define lbl_numRoomsCat 1 "1-2" 2 "3-6" 3 "7-9" 4 "missing"
label val numRoomsCat lbl_numRoomsCat
ta numRoomsCat, m

*vs when missing is made real missing
gen numRoomsCat3=.
replace numRoomsCat3=1 if numRoomsT>=1 & numRoomsT<3
replace numRoomsCat3=2 if numRoomsT>=3 & numRoomsT<7
replace numRoomsCat3=3 if numRoomsT>=7 & numRoomsT<10
label define lbl_numRoomsCat3 1 "1-2" 2 "3-6" 3 "7-9" 4 "missing"
label val numRoomsCat3 lbl_numRoomsCat3
ta numRoomsT numRoomsCat3, m
ta numRoomsCat3, m

*Check 
ta numRoomsCat totRec, m 
ta numRoomsCat AcuteT , m col

********************************************************************************
*Density in the house

*Number of people in the household
*dmod$NumPplHouse <- ifelse(is.na(dmod$number_people_in_house), dmod$dem_hoh_live_here, ifelse(is.na(dmod$dem_hoh_live_here), dmod$number_people_in_house, NA))
ta number_people_in_house, m
replace number_people_in_house="" 	if number_people_in_house=="NA"
destring number_people_in_house, replace
ta number_people_in_house, m

gen number_people_in_house_2=.
replace number_people_in_house_2=number_people_in_house
replace number_people_in_house_2=32 		if number_people_in_house==320
replace number_people_in_house_2=8 		if number_people_in_house==80
replace number_people_in_house_2=. 		if number_people_in_house>25
ta number_people_in_house_2, m

gen nrPlpHT=.
forval i=0/8{
sort person_id date_complete nthRecAIC
replace nrPlpHT=number_people_in_house_2  if nthRecAIC==`i' & nrPlpHT==.

sort person_id date_complete nthRecAIC
by person_id: carryforward nrPlpHT, replace
gsort person_id -date_complete -nthRecAIC
by person_id: carryforward nrPlpHT, replace
sort person_id date_complete nthRecAIC
ta nrPlpHT, m
}
*

gen nrPlpHCat=.
replace nrPlpHCat=1 if nrPlpHT>=1 & nrPlpHT<4
replace nrPlpHCat=2 if nrPlpHT==4
replace nrPlpHCat=3 if nrPlpHT==5
replace nrPlpHCat=4 if nrPlpHT==6
replace nrPlpHCat=5 if nrPlpHT>=7 & nrPlpHT!=.
replace nrPlpHCat=6 if nrPlpHCat==.
ta nrPlpHT nrPlpHCat, m
label define lbl_nrPlpH 1 "1-3" 2 "4" 3 "5" 4 "6" 5 ">=7" 6 "missing"
label val nrPlpHCat lbl_nrPlpH
ta nrPlpHCat, m

gen nrPlpHCat3=.
replace nrPlpHCat3=1 if nrPlpHT>=1 & nrPlpHT<4
replace nrPlpHCat3=2 if nrPlpHT==4
replace nrPlpHCat3=3 if nrPlpHT==5
replace nrPlpHCat3=4 if nrPlpHT==6
replace nrPlpHCat3=5 if nrPlpHT>=7 & nrPlpHT!=.
ta nrPlpHT nrPlpHCat3, m
label define lbl_nrPlpH3 1 "1-3" 2 "4" 3 "5" 4 "6" 5 ">=7" 
label val nrPlpHCat3 lbl_nrPlpH
ta nrPlpHCat3, m

*Check 
ta nrPlpHCat totRec, m 
ta nrPlpHCat AcuteT , m col

*******************************************************************************
*Number of windows
ta number_windows, m //How many windows are there in the house?
replace number_windows="" if number_windows=="NA"
destring number_windows, replace
ta number_windows, m

ta number_windows, m
replace number_windows=. if number_windows>=24
ta number_windows, m

gen nrWndCat=.
forval i=1/8{
sort person_id date_complete nthRecAIC
replace nrWndCat=0 if number_windows==0 & nthRecAIC==`i' & nrWndCat==. 
replace nrWndCat=1 if number_windows==1 & nthRecAIC==`i' & nrWndCat==. 
replace nrWndCat=2 if number_windows==2 & nthRecAIC==`i' & nrWndCat==. 
replace nrWndCat=3 if number_windows>=3 & number_windows!=. & nthRecAIC==`i' & nrWndCat==. 

sort person_id date_complete nthRecAIC
by person_id: carryforward nrWndCat, replace
gsort person_id -date_complete -nthRecAIC
by person_id: carryforward nrWndCat, replace
sort person_id date_complete nthRecAIC
ta nrWndCat, m
}
*
replace nrWndCat=4 if nrWndCat==.
label define lbl_nrWndCat 0 "0" 1 "1" 2 "2" 3 ">=3" 4 "missing"
label val nrWndCat lbl_nrWndCat
ta nrWndCat, m

gen nrWndCat3=.
replace nrWndCat3=0 if nrWndCat==0
replace nrWndCat3=1 if nrWndCat==1
replace nrWndCat3=2 if nrWndCat==2
replace nrWndCat3=3 if nrWndCat==3
ta nrWndCat3 nrWndCat, m
label define lbl_nrWndCat3 0 "0" 1 "1" 2 "2" 3 ">=3" 
label val nrWndCat3 lbl_nrWndCat3
ta nrWndCat3, m

gen diffnrWndCat=.
sort person_id nthRecAIC
by person_id: replace diffnrWndCat=1 if nrWndCat[_n]!=nrWndCat[_n+1] & nrWndCat[_n+1]!=. & nrWndCat[_n]!=3 & nrWndCat[_n+1]!=3
ta diffnrWndCat, m

*Check 
ta diffnrWndCat totRec, m 
ta diffnrWndCat AcuteT , m col

*******************************************************************************
*Main light source
ta light_source, m //What is the main source of light at night?
*1 Electricity line
*2 Paraffin
*3 Gas
*4 Firewood
*5 Charcoal
*6 Solar
*7 Other
*9 N/A

gen lghtSrT=.
forval i=1/8{
sort person_id date_complete nthRecAIC
*electricity/solar
replace lghtSrT=1 if light_source=="1" & nthRecAIC==`i' & lghtSrT==. 
replace lghtSrT=1 if light_source=="6" & nthRecAIC==`i' & lghtSrT==. 
*other sources
replace lghtSrT=2 if light_source=="2" & nthRecAIC==`i' & lghtSrT==. 
replace lghtSrT=2 if light_source=="3" & nthRecAIC==`i' & lghtSrT==. 
replace lghtSrT=2 if light_source=="4" & nthRecAIC==`i' & lghtSrT==. 
replace lghtSrT=2 if light_source=="5" & nthRecAIC==`i' & lghtSrT==. 
replace lghtSrT=2 if light_source=="7" & nthRecAIC==`i' & lghtSrT==. //other unknown

sort person_id date_complete nthRecAIC
by person_id: carryforward lghtSrT, replace
gsort person_id -date_complete -nthRecAIC
by person_id: carryforward lghtSrT, replace
sort person_id date_complete nthRecAIC
ta lghtSrT, m
}
replace lghtSrT=3 if lghtSrT==.
ta lghtSrT, m

label define lbl_lghtSrT 1 "elect/solar" 2 "other;paraffin/lantern" 3 "missing"
label val lghtSrT lbl_lghtSrT
ta lghtSrT, m

gen lghtSrT2=.
replace lghtSrT2=1 if lghtSrT==1
replace lghtSrT2=2 if lghtSrT==2
replace lghtSrT2=2 if lghtSrT==3
label define lbl_lghtSrT2 1 "elect/solar" 2 "other & missing"
label val lghtSrT2 lbl_lghtSrT2
ta lghtSrT2 lghtSrT, m
ta lghtSrT2, m

gen lghtSrT3=.
replace lghtSrT3=1 if lghtSrT==1
replace lghtSrT3=2 if lghtSrT==2
label define lbl_lghtSrT3 1 "elect/solar" 2 "other;paraffin/lantern" 
label val lghtSrT3 lbl_lghtSrT2
ta lghtSrT3 lghtSrT, m
ta lghtSrT3, m

gen difflghtSrT=.
sort person_id nthRecAIC
by person_id: replace difflghtSrT=1 if lghtSrT[_n]!=lghtSrT[_n+1] & lghtSrT[_n+1]!=. & lghtSrT[_n]!=3 & lghtSrT[_n+1]!=3
ta difflghtSrT, m
drop difflghtSrT

*Check 
ta lghtSrT totRec, m 
ta lghtSrT AcuteT , m col

********************************************************************************
*Drinking water
ta drinking_water_source, m //Drinking water source
*1 River or pond
*2 Rain water
*3 Public well or borehole
*4 Inside well
*5 Public tap or piped
*6 Water truck
*9 N/A

gen drnkWtSrT=.
forval i=1/8 {
*Natural source
sort person_id date_complete nthRecAIC
replace drnkWtSrT=1 if drinking_water_source=="1" & nthRecAIC==`i' & drnkWtSrT==. 
replace drnkWtSrT=1 if drinking_water_source=="2" & nthRecAIC==`i' & drnkWtSrT==. 
*Well
replace drnkWtSrT=2 if drinking_water_source=="3" & nthRecAIC==`i' & drnkWtSrT==. 
replace drnkWtSrT=2 if drinking_water_source=="4" & nthRecAIC==`i' & drnkWtSrT==. 
*Tap/piped
replace drnkWtSrT=3 if drinking_water_source=="5" & nthRecAIC==`i' & drnkWtSrT==. 
replace drnkWtSrT=3 if drinking_water_source=="6" & nthRecAIC==`i' & drnkWtSrT==. 

sort person_id date_complete nthRecAIC
by person_id: carryforward drnkWtSrT, replace
gsort person_id -date_complete -nthRecAIC
by person_id: carryforward drnkWtSrT, replace
sort person_id date_complete nthRecAIC
ta drnkWtSrT, m
}
ta drnkWtSrT, m
replace drnkWtSrT=4 if drnkWtSrT==.
ta drnkWtSrT, m

label define lbl_drnkWtSrT 1 "natural source" 2 "well" 3 "piped" 4 "missing"
label val drnkWtSrT lbl_drnkWtSrT
ta drnkWtSrT, m

gen drnkWtSrT3=.
replace drnkWtSrT3=1 if drnkWtSrT==1
replace drnkWtSrT3=2 if drnkWtSrT==2
replace drnkWtSrT3=3 if drnkWtSrT==3
label define lbl_drnkWtSrT3 1 "natural source" 2 "well" 3 "piped" 
label val drnkWtSrT3 lbl_drnkWtSrT3
ta drnkWtSrT3 drnkWtSrT, m

gen diffdrnkWtSrT=.
sort person_id nthRecAIC
by person_id: replace diffdrnkWtSrT=1 if drnkWtSrT[_n]!=drnkWtSrT[_n+1] & drnkWtSrT[_n+1]!=. & drnkWtSrT[_n]!=3 & drnkWtSrT[_n+1]!=3
ta diffdrnkWtSrT, m
drop diffdrnkWtSrT
*

********************************************************************************
*latrine use
ta latrine_type, m //What kind of latrine/toilet do they use?
*1 None
*2 Bush
*3 Pit latrine
*4 VIP latrine
*5 Flush toilet
*6 Other
*9 N/A


********************************************************************************
**Generate Type of toilet
gen toiletTypeT=.
forval i=1/8 {
*AIC
*flush toielet
sort person_id date_complete nthRecAIC
replace toiletTypeT=1 if latrine_type=="5"	& nthRecAIC==`i' & toiletTypeT==. 
*ventilated improved pit latrine (VIP)  or traditional pit latrine
replace toiletTypeT=2 if latrine_type=="3"	& nthRecAIC==`i' & toiletTypeT==. 
replace toiletTypeT=2 if latrine_type=="4"	& nthRecAIC==`i' & toiletTypeT==. 
*Outside + Bush + other
replace toiletTypeT=3 if latrine_type=="1" 	& nthRecAIC==`i' & toiletTypeT==. 
replace toiletTypeT=3 if latrine_type=="2"	& nthRecAIC==`i' & toiletTypeT==. 
replace toiletTypeT=3 if latrine_type=="6"	& nthRecAIC==`i' & toiletTypeT==. //added 6/12 so this will change the table, 6/12 not updated yet

ta toiletTypeT latrine_type, m
sort person_id date_complete nthRecAIC
by person_id: carryforward toiletTypeT, replace
gsort person_id -date_complete -nthRecAIC
by person_id: carryforward toiletTypeT, replace
sort person_id date_complete nthRecAIC
ta toiletTypeT, m
}
*
ta toiletTypeT, m
replace toiletTypeT=4 if toiletTypeT==.
ta toiletTypeT, m
label define lbl_toiletTypeT  1 "flush"  2 "VIP/pit" 3 "outside/bush/other" 4 "missing"
label val toiletTypeT lbl_toiletTypeT
ta toiletTypeT, m

gen toiletTypeT3=.
replace toiletTypeT3=1 if toiletTypeT==1
replace toiletTypeT3=2 if toiletTypeT==2
replace toiletTypeT3=3 if toiletTypeT==3
label define lbl_toiletTypeT3  1 "flush"  2 "VIP/pit" 3 "outside/bush"
label val toiletTypeT3 lbl_toiletTypeT3
ta toiletTypeT3 toiletTypeT, m

gen difftoiletTypeT=.
sort person_id nthRecAIC
by person_id: replace difftoiletTypeT=1 if toiletTypeT[_n]!=toiletTypeT[_n+1] & toiletTypeT[_n+1]!=. & toiletTypeT[_n]!=3 & toiletTypeT[_n+1]!=3
ta difftoiletTypeT, m
drop difftoiletTypeT
*

*******************************************************************************
*SES
*******************************************************************************

********************************************************************************
ta mom_highest_level_education_aic, m //What is the mom's highest level of  education?
replace mom_highest_level_education_aic="" if mom_highest_level_education_aic=="NA"
destring mom_highest_level_education_aic, replace
ta mom_highest_level_education_aic, m
*1 Primary school
*2 Secondary school
*3 Technical college
*4 Professional degree
*5 Other
*9 N/A

*When there was no education "N/A" was used, or sometimes even left blank
*So for now I am assuming that when no answer was given it means no education

gen momEducT=.
forval i=1/8{
sort person_id date_complete nthRecAIC
*replace momEducT=1 	if mom_highest_level_education_aic==9 & nthRecAIC==`i' & momEducT==. 
replace momEducT=2 	if mom_highest_level_education_aic==1 & nthRecAIC==`i' & momEducT==. 
replace momEducT=3 	if mom_highest_level_education_aic==2 & nthRecAIC==`i' & momEducT==. 
replace momEducT=4 	if mom_highest_level_education_aic==3 & mom_highest_level_education_aic==4 & nthRecAIC==`i' & momEducT==. 
ta momEducT mom_highest_level_education_aic, m

sort person_id date_complete nthRecAIC
by person_id: carryforward momEducT, replace
gsort person_id -date_complete -nthRecAIC
by person_id: carryforward momEducT, replace
sort person_id date_complete nthRecAIC
ta momEducT, m
}
ta momEducT, m
replace momEducT=1 if momEducT==.
ta momEducT, m
*Notice that I am blending the "other" category into no education (this category is too small to handle as one group)
*You can also choose to make them missing
*
label define  lbl_modEduc 1 "no educ" 2 "primary school" 3 "secondary school" 4 "technical+professional"
label val momEducT lbl_modEduc
ta momEducT, m

gen diffmomEducT=.
sort person_id nthRecAIC
by person_id: replace diffmomEducT=1 if momEducT[_n]!=momEducT[_n+1] & momEducT[_n+1]!=. & momEducT[_n]!=3 & momEducT[_n+1]!=3
ta diffmomEducT, m
drop diffmomEducT


*******************************************************************************
*Telephone
ta telephone, m //Do they own a telephone?
*1 Yes
*0 No
*8 Refused

gen telphnT=.
forval i=1/8{
sort person_id date_complete nthRecAIC
sort person_id date_complete nthRecAIC
replace telphnT=0 if telephone=="0"				 & nthRecAIC==`i' & telphnT==. 
replace telphnT=1 if telephone=="1"				 & nthRecAIC==`i' & telphnT==. 
ta telphnT telephone, m

sort person_id date_complete nthRecAIC
by person_id: carryforward telphnT, replace
gsort person_id -date_complete -nthRecAIC
by person_id: carryforward telphnT, replace
sort person_id date_complete nthRecAIC
ta telphnT, m
}
*
ta telphnT, m
replace telphnT=2 if telphnT==.
ta telphnT, m

label define lbl_telphnT 0 "no" 1 "yes" 2 "missing"
label val telphnT lbl_telphnT
ta telphnT, m

gen telphnT3=.
replace telphnT3=0 if telphnT==0
replace telphnT3=1 if telphnT==1
label define lbl_telphnT3 0 "no" 1 "yes" 
label val telphnT3 lbl_telphnT3
ta telphnT3 telphnT, m
ta telphnT3, m

gen difftelphnT=.
sort person_id nthRecAIC
by person_id: replace difftelphnT=1 if telphnT[_n]!=telphnT[_n+1] & telphnT[_n+1]!=. & telphnT[_n]!=3 & telphnT[_n+1]!=3
ta difftelphnT, m
drop difftelphnT

*******************************************************************************
*Radio
ta radio, m //Do they own a radio?
* 1 Yes
* 0 No
* 8 Refused

gen radioT=.
forval i=1/8{
sort person_id date_complete nthRecAIC
replace radioT=0 if radio=="0"	& nthRecAIC==`i' & radioT==. 
replace radioT=1 if radio=="1"	& nthRecAIC==`i' & radioT==. 
ta radioT radio, m

sort person_id date_complete nthRecAIC
by person_id: carryforward radioT, replace
gsort person_id -date_complete -nthRecAIC
by person_id: carryforward radioT, replace
sort person_id date_complete nthRecAIC
ta radioT, m
}
*
ta radioT, m
replace radioT=2 if radioT==.
ta radioT, m
label define lbl_radioT 0 "no" 1 "yes" 2 "missing"
label val radioT lbl_radioT
ta radioT, m

gen radioT3=.
replace radioT3=0 if radioT==0
replace radioT3=1 if radioT==1
label define lbl_radioT3 0 "no" 1 "yes" 
label val radioT3 lbl_radioT3
ta radioT3 radioT, m

gen diffradioT=.
sort person_id nthRecAIC
by person_id: replace diffradioT=1 if radioT[_n]!=radioT[_n+1] & radioT[_n+1]!=. & radioT[_n]!=3 & radioT[_n+1]!=3
ta diffradioT, m
drop diffradioT


*******************************************************************************
*Television
ta television, m //Do they own a television?
* 1 Yes
* 0 No
* 8 Refused

gen tvT=.
forval i=1/8{
sort person_id date_complete nthRecAIC
replace tvT=0 if television=="0" & nthRecAIC==`i' & tvT==. 
replace tvT=1 if television=="1" & nthRecAIC==`i' & tvT==. 
ta tvT television, m

sort person_id date_complete nthRecAIC
by person_id: carryforward tvT, replace
gsort person_id -date_complete -nthRecAIC
by person_id: carryforward tvT, replace
sort person_id date_complete nthRecAIC
ta tvT, m
}
*
ta tvT, m
replace tvT=2 if tvT==.
ta tvT, m

label define lbl_tvT 0 "no" 1 "yes" 2 "missing"
label val tvT lbl_tvT
ta tvT, m

gen tvT3=.
replace tvT3=0 if tvT==0
replace tvT3=1 if tvT==1
label define lbl_tvT3 0 "no" 1 "yes" 
label val tvT3 lbl_tvT3
ta tvT3 tvT, m

gen difftvT=.
sort person_id nthRecAIC
by person_id: replace difftvT=1 if tvT[_n]!=tvT[_n+1] & tvT[_n+1]!=. & tvT[_n]!=3 & tvT[_n+1]!=3
ta difftvT, m
drop difftvT


*******************************************************************************
*Bicycle
ta bicycle, m //Do they own a bicycle?
*1 Yes
*0 No
*8 Refused

gen bicycleT=.
forval i=1/8{
sort person_id date_complete nthRecAIC
replace bicycleT=0 if bicycle=="0"				& nthRecAIC==`i' & bicycleT==. 
replace bicycleT=1 if bicycle=="1"				& nthRecAIC==`i' & bicycleT==. 
ta bicycleT bicycle, m

sort person_id date_complete nthRecAIC
by person_id: carryforward bicycleT, replace
gsort person_id -date_complete -nthRecAIC
by person_id: carryforward bicycleT, replace
sort person_id date_complete nthRecAIC
ta bicycleT, m
}
*
ta bicycleT, m
replace bicycleT=2 if bicycleT==.
ta bicycleT, m
label define lbl_bicycleT 0 "no" 1 "yes" 2 "missing"
label val bicycleT lbl_bicycleT
ta bicycleT, m

gen bicycleT3=.
replace bicycleT3=0 if bicycleT==0
replace bicycleT3=1 if bicycleT==1
label define lbl_bicycleT3 0 "no" 1 "yes"
label val bicycleT3 lbl_bicycleT3
ta bicycleT3 bicycleT, m

gen diffbicycleT=.
sort person_id nthRecAIC
by person_id: replace diffbicycleT=1 if bicycleT[_n]!=bicycleT[_n+1] & bicycleT[_n+1]!=. & bicycleT[_n]!=3 & bicycleT[_n+1]!=3
ta diffbicycleT, m
drop diffbicycleT


*******************************************************************************
*MotorCycle
ta motor_vehicle, m //Do they own a motorized vehicle (i.e. automobile, scooter)? 
*1 Yes
*0 No
*8 Refused

gen motorT=.
forval i=1/8{
sort person_id date_complete nthRecAIC
replace motorT=0 if motor_vehicle=="0"	& nthRecAIC==`i' & motorT==. 
replace motorT=1 if motor_vehicle=="1"	& nthRecAIC==`i' & motorT==. 
ta motorT motor_vehicle, m

sort person_id date_complete nthRecAIC
by person_id: carryforward motorT, replace
gsort person_id -date_complete -nthRecAIC
by person_id: carryforward motorT, replace
sort person_id date_complete nthRecAIC
ta motorT, m
}
*
ta motorT, m
replace motorT=2 if motorT==.
ta motorT, m
label define lbl_motorT 0 "no" 1 "yes" 2 "missing"
label val motorT lbl_motorT
ta motorT, m

gen motorT3=.
replace motorT3=0 if motorT==0
replace motorT3=1 if motorT==1
label define lbl_motorT3 0 "no" 1 "yes" 
label val motorT3 lbl_motorT3
ta motorT3 motorT, m

gen diffmotorT=.
sort person_id nthRecAIC
by person_id: replace diffmotorT=1 if motorT[_n]!=motorT[_n+1] & motorT[_n+1]!=. & motorT[_n]!=3 & motorT[_n+1]!=3
ta diffmotorT, m
drop diffmotorT


*******************************************************************************
*Domestic worker
ta domestic_worker, m //Do they have a domestic worker?
*1 Yes 0 No 8 Refused

gen domesticT=.
forval i=1/8{
sort person_id date_complete nthRecAIC
replace domesticT=0 if domestic_worker=="0"	& nthRecAIC==`i' & domesticT==. 
replace domesticT=1 if domestic_worker=="1"	& nthRecAIC==`i' & domesticT==. 

sort person_id date_complete nthRecAIC
by person_id: carryforward domesticT, replace
gsort person_id -date_complete -nthRecAIC
by person_id: carryforward domesticT, replace
sort person_id date_complete nthRecAIC
ta domesticT, m
}
*
ta domesticT, m
replace domesticT=2 if domesticT==.
ta domesticT, m
label define lbl_domesticT 0 "no" 1 "yes" 2 "missing"
label val domesticT lbl_domesticT
ta domesticT , m

gen domesticT3=.
replace domesticT3=0 if domesticT==0
replace domesticT3=1 if domesticT==1
label define lbl_domesticT3 0 "no" 1 "yes" 
label val domesticT3 lbl_domesticT3
ta domesticT3 domesticT, m

gen diffdomesticT3=.
sort person_id nthRecAIC
by person_id: replace diffdomesticT3=1 if domesticT3[_n]!=domesticT3[_n+1] & domesticT3[_n+1]!=. & domesticT3[_n]!=3 & domesticT3[_n+1]!=3
ta diffdomesticT3, m
drop diffdomesticT3

********************************************************************************
***Amy's syntax on ses
*ses<-(malaria_climate[, grepl("telephone|radio|television|bicycle|motor_vehicle|domestic_worker", names(malaria_climate))])

egen ses=rmean(telphnT3 radioT3 tvT3 bicycleT3 motorT3 domesticT3)
**browse person_id telphnT3 radioT3 tvT3 bicycleT3 motorT3 domesticT3 ses if  telphnT3==. | telphnT3==. | bicycleT3==. | motorT3==. | domesticT3==.

gen sesCat=.
replace sesCat=1 if ses<0.25
replace sesCat=2 if ses>=0.25 & ses<0.75
replace sesCat=3 if ses>=0.75 & ses!=.
replace sesCat=4 if ses==.

label define lbl_sesCat 1 "0-2 assests" 2 "3 assets" 3 "4-5 assets" 4 "missing"
label val sesCat lbl_sesCat
ta sesCat, m

gen sesCat3=.
replace sesCat3=1 if ses<0.25
replace sesCat3=2 if ses>=0.25 & ses<0.75
replace sesCat3=3 if ses>=0.75 & ses!=.
label define lbl_sesCat3 1 "0-2 assests" 2 "3 assets" 3 "4-5 assets" 
label val sesCat3 lbl_sesCat3
ta ses sesCat3, m
ta sesCat3, m

gen diffses=.
sort person_id nthRecAIC
by person_id: replace diffses=1 if ses[_n]!=ses[_n+1] & ses[_n+1]!=. & ses[_n]!=3 & ses[_n+1]!=3
ta diffses, m
drop diffses










********************************************************************************
********************************************************************************
****Mosquito exposure and preventive behavior - DENV	
********************************************************************************
********************************************************************************
*These are variables that vary over time


********************************************************************************
*Outdoor activities
ta outdoor_activity_aic, m //Does the child usually work outdoors or do outdoor activities?

*0 No
*1 Yes
*8 Refused

gen outdoorActy_denvT=.
*Fill when denv_pcr==1
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace outdoorActy_denvT=0 if outdoor_activity_aic=="0" & denv_pcr_y==1 & outdoorActy_denvT==. & nthRecAIC==`i' & Acute==`k'
replace outdoorActy_denvT=1 if outdoor_activity_aic=="1" & denv_pcr_y==1 & outdoorActy_denvT==. & nthRecAIC==`i' & Acute==`k'
ta outdoorActy_denvT outdoorActy_denvT, m

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward outdoorActy_denvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward outdoorActy_denvT , replace
sort person_id date_complete nthRecAIC
ta outdoorActy_denvT, m
}
}
*
*Fill when denv_pcr==0
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace outdoorActy_denvT=0 if outdoor_activity_aic=="0" & denv_pcr_y==0 & outdoorActy_denvT==. & nthRecAIC==`i' & Acute==`k'
replace outdoorActy_denvT=1 if outdoor_activity_aic=="1" & denv_pcr_y==0 & outdoorActy_denvT==. & nthRecAIC==`i' & Acute==`k'
ta outdoorActy_denvT outdoorActy_denvT, m

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward outdoorActy_denvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward outdoorActy_denvT , replace
sort person_id date_complete nthRecAIC
ta outdoorActy_denvT, m
}
}
*
* now fill indepdent of denv_pcr_y status
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace outdoorActy_denvT=0 if outdoor_activity_aic=="0" & outdoorActy_denvT==. & nthRecAIC==`i' &  Acute==`k'
replace outdoorActy_denvT=1 if outdoor_activity_aic=="1" & outdoorActy_denvT==. & nthRecAIC==`i' &  Acute==`k'
ta outdoorActy_denvT outdoorActy_denvT, m

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute : carryforward outdoorActy_denvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute : carryforward outdoorActy_denvT , replace
sort person_id date_complete nthRecAIC
ta outdoorActy_denvT, m
}
}
*
ta outdoorActy_denvT outdoor_activity_aic, m
ta  outdoorActy_denvT, m
replace outdoorActy_denvT=2 if outdoorActy_denvT==.
ta outdoorActy_denvT, m

label define lbl_outdoorActy_denvT 0 "No" 1 "Yes" 2"missing"
label val outdoorActy_denvT lbl_outdoorActy_denvT
ta outdoorActy_denvT, m
*browse person_id  date_complete nthRecAIC Acute denv_pcr_y outdoor_activity_aic outdoorActy_denvT
*check MF0698 whether code wsa right

gen outdoorActy_denvT3=.
replace outdoorActy_denvT3=0 if outdoorActy_denvT==0
replace outdoorActy_denvT3=1 if outdoorActy_denvT==1
label define lbl_outdoorActy_denvT3 0 "No" 1 "Yes"
label val outdoorActy_denvT3 lbl_outdoorActy_denvT3
ta outdoorActy_denvT outdoorActy_denvT3, m

gen diffoutdoorActy_denvT=.
sort person_id nthRecAIC Acute
bysort person_id Acute: replace diffoutdoorActy_denvT=1 if outdoorActy_denvT[_n]!=outdoorActy_denvT[_n+1] & outdoorActy_denvT[_n+1]!=. 
ta diffoutdoorActy_denvT, m
drop diffoutdoorActy_denvT	

*browse person_id  date_complete nthRecAIC Acute denv_pcr_y outdoor_activity_aic outdoorActy_denvT diffoutdoorActy_denvT


********************************************************************************
*Self-reported mosquito bites

ta mosquito_bites_aic, m //Did the child get bitten by mosquitoes in the last 4 weeks?
*1 Yes
*0 No
*8 Refused

gen msqtBites_denvT=.
*Fill when denv_pcr==1
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace msqtBites_denvT=0 if mosquito_bites_aic=="0" & denv_pcr_y==1 & msqtBites_denvT==. & nthRecAIC==`i' & Acute==`k'
replace msqtBites_denvT=1 if mosquito_bites_aic=="1" & denv_pcr_y==1 & msqtBites_denvT==. & nthRecAIC==`i' & Acute==`k'
ta msqtBites_denvT msqtBites_denvT, m

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward msqtBites_denvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward msqtBites_denvT , replace
sort person_id date_complete nthRecAIC
ta msqtBites_denvT, m
}
}
*
*Fill when denv_pcr==0
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace msqtBites_denvT=0 if mosquito_bites_aic=="0" & denv_pcr_y==0 & msqtBites_denvT==. & nthRecAIC==`i' & Acute==`k'
replace msqtBites_denvT=1 if mosquito_bites_aic=="1" & denv_pcr_y==0 & msqtBites_denvT==. & nthRecAIC==`i' & Acute==`k'
ta msqtBites_denvT msqtBites_denvT, m

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward msqtBites_denvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward msqtBites_denvT , replace
sort person_id date_complete nthRecAIC
ta msqtBites_denvT, m
}
}
*
* now fill indepdent of denv_pcr_y status
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace msqtBites_denvT=0 if mosquito_bites_aic=="0" & msqtBites_denvT==. & nthRecAIC==`i' &  Acute==`k'
replace msqtBites_denvT=1 if mosquito_bites_aic=="1" & msqtBites_denvT==. & nthRecAIC==`i' &  Acute==`k'
ta msqtBites_denvT msqtBites_denvT, m

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute : carryforward msqtBites_denvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute : carryforward msqtBites_denvT , replace
sort person_id date_complete nthRecAIC
ta msqtBites_denvT, m
}
}
*
ta msqtBites_denvT mosquito_bites_aic, m
ta msqtBites_denvT, m
replace msqtBites_denvT=2 if msqtBites_denvT==.
ta msqtBites_denvT, m

label define lbl_msqtBites_denvT 0 "No" 1 "Yes" 2"missing"
label val msqtBites_denvT lbl_msqtBites_denvT
ta msqtBites_denvT, m
*browse person_id  date_complete nthRecAIC Acute denv_pcr_y mosquito_bites_aic msqtBites_denvT

gen msqtBites_denvT3=.
replace msqtBites_denvT3=0 if msqtBites_denvT==0
replace msqtBites_denvT3=1 if msqtBites_denvT==1
label define lbl_msqtBites_denvT3 0 "No" 1 "Yes"
label val msqtBites_denvT3 lbl_msqtBites_denvT3
ta msqtBites_denvT msqtBites_denvT3, m

gen diffmsqtBites_denvT=.
sort person_id nthRecAIC Acute
bysort person_id Acute: replace diffmsqtBites_denvT=1 if msqtBites_denvT[_n]!=msqtBites_denvT[_n+1] & msqtBites_denvT[_n+1]!=. 
ta diffmsqtBites_denvT, m
drop diffmsqtBites_denvT	

*browse person_id  date_complete nthRecAIC Acute denv_pcr_y mosquito_bites_aic msqtBites_denvT diffmsqtBites_denvT


*********************************************************************************
*Mosquito coil

ta mosquito_coil_aic, m //Does the child use a mosquito coil to avoid mosquitoes?
*1 Yes
*0 No
*8 Refused

gen msqtCoil_denvT=.
*Fill when denv_pcr==1
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace msqtCoil_denvT=0 if mosquito_coil_aic=="0" & denv_pcr_y==1 & msqtCoil_denvT==. & nthRecAIC==`i' & Acute==`k'
replace msqtCoil_denvT=1 if mosquito_coil_aic=="1" & denv_pcr_y==1 & msqtCoil_denvT==. & nthRecAIC==`i' & Acute==`k'
ta msqtCoil_denvT msqtCoil_denvT, m

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward msqtCoil_denvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward msqtCoil_denvT , replace
sort person_id date_complete nthRecAIC
ta msqtCoil_denvT, m
}
}
*
*Fill when denv_pcr==0
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace msqtCoil_denvT=0 if mosquito_coil_aic=="0" & denv_pcr_y==0 & msqtCoil_denvT==. & nthRecAIC==`i' & Acute==`k'
replace msqtCoil_denvT=1 if mosquito_coil_aic=="1" & denv_pcr_y==0 & msqtCoil_denvT==. & nthRecAIC==`i' & Acute==`k'
ta msqtCoil_denvT msqtCoil_denvT, m

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward msqtCoil_denvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward msqtCoil_denvT , replace
sort person_id date_complete nthRecAIC
ta msqtCoil_denvT, m
}
}
*
* now fill indepdent of denv_pcr_y status
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace msqtCoil_denvT=0 if mosquito_coil_aic=="0" & msqtCoil_denvT==. & nthRecAIC==`i' &  Acute==`k'
replace msqtCoil_denvT=1 if mosquito_coil_aic=="1" & msqtCoil_denvT==. & nthRecAIC==`i' &  Acute==`k'
ta msqtCoil_denvT msqtCoil_denvT, m

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute : carryforward msqtCoil_denvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute : carryforward msqtCoil_denvT , replace
sort person_id date_complete nthRecAIC
ta msqtCoil_denvT, m
}
}
*
ta msqtCoil_denvT mosquito_coil_aic, m
ta msqtCoil_denvT, m
replace msqtCoil_denvT=2 if msqtCoil_denvT==.
ta msqtCoil_denvT, m

label define lbl_msqtCoil_denvT 0 "No" 1 "Yes" 2"missing"
label val msqtCoil_denvT lbl_msqtCoil_denvT
ta msqtCoil_denvT, m
*browse person_id  date_complete nthRecAIC Acute denv_pcr_y mosquito_coil_aic msqtCoil_denvT

gen msqtCoil_denvT3=.
replace msqtCoil_denvT3=0 if msqtCoil_denvT==0
replace msqtCoil_denvT3=1 if msqtCoil_denvT==1
label define lbl_msqtCoil_denvT3 0 "No" 1 "Yes"
label val msqtCoil_denvT3 lbl_msqtCoil_denvT3
ta msqtCoil_denvT msqtCoil_denvT3, m

gen diffmsqtCoil_denvT=.
sort person_id nthRecAIC Acute
bysort person_id Acute: replace diffmsqtCoil_denvT=1 if msqtCoil_denvT[_n]!=msqtCoil_denvT[_n+1] & msqtCoil_denvT[_n+1]!=. 
ta diffmsqtCoil_denvT, m
drop diffmsqtCoil_denvT	

*browse person_id  date_complete nthRecAIC Acute denv_pcr_y mosquito_coil_aic msqtCoil_denvT diffmsqtCoil_denvT

********************************************************************************
**Mosquito NET

ta mosquito_net_aic, m //Does the child sleep under a mosquito net?
*1 Always
*2 Sometimes
*3 Rarely
*4 Never
*9 N/A

ta mosquito_net_aic, m
replace mosquito_net_aic="" if mosquito_net_aic=="NA"
replace mosquito_net_aic="" if mosquito_net_aic=="9"
destring(mosquito_net_aic), replace
ta mosquito_net_aic, m

gen msqtNet_denvT=.
*Fill when denv_pcr==1
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace msqtNet_denvT=mosquito_net_aic if denv_pcr_y==1 & msqtNet_denvT==. & nthRecAIC==`i' & Acute==`k'
ta msqtNet_denvT msqtNet_denvT, m

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward msqtNet_denvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward msqtNet_denvT , replace
sort person_id date_complete nthRecAIC
ta msqtNet_denvT, m
}
}
*
*Fill when denv_pcr==0
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace msqtNet_denvT=mosquito_net_aic if denv_pcr_y==0 & msqtNet_denvT==. & nthRecAIC==`i' & Acute==`k'
ta msqtNet_denvT msqtNet_denvT, m

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward msqtNet_denvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward msqtNet_denvT , replace
sort person_id date_complete nthRecAIC
ta msqtNet_denvT, m
}
}
*
* now fill indepdent of denv_pcr_y status
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace msqtNet_denvT=mosquito_net_aic if msqtNet_denvT==. & nthRecAIC==`i' &  Acute==`k'
ta msqtNet_denvT msqtNet_denvT, m

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute : carryforward msqtNet_denvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute : carryforward msqtNet_denvT , replace
sort person_id date_complete nthRecAIC
ta msqtNet_denvT, m
}
}
*
ta msqtNet_denvT, m
replace msqtNet_denvT=5 if msqtNet_denvT==.
ta msqtNet_denvT, m

label define lbl_msqtNet_denvT 1 "Always" 2 "Sometimes" 3 "Rarely" 4 "Never" 5 "missing"
label val msqtNet_denvT lbl_mosquitoNetT
ta msqtNet_denvT, m
*browse person_id  date_complete nthRecAIC Acute denv_pcr_y mosquito_coil_aic msqtNet_denvT

gen msqtNet_denvT3=.
replace msqtNet_denvT3=0 if msqtNet_denvT==1
replace msqtNet_denvT3=1 if msqtNet_denvT==2 |  msqtNet_denvT==3 |  msqtNet_denvT==4
label define lbl_msqtNet_denvT3 0 "Always protected" 1 "Sometimes-never protected"
label val msqtNet_denvT3 lbl_msqtNet_denvT3
ta msqtNet_denvT msqtNet_denvT3, m

gen diffmsqtNet_denvT=.
sort person_id nthRecAIC Acute
bysort person_id Acute: replace diffmsqtNet_denvT=1 if msqtNet_denvT[_n]!=msqtNet_denvT[_n+1] & msqtNet_denvT[_n+1]!=. 
ta diffmsqtNet_denvT, m
drop diffmsqtNet_denvT	

*browse person_id  date_complete nthRecAIC Acute denv_pcr_y mosquito_coil_aic msqtNet_denvT diffmsqtNet_denvT


*******************************************************************************
*Fever contact
ta fever_contact, m //Has the child been in contact with other people with similar symptoms in the last 15 days?
*1 Yes
*0 No
*8 Refused

replace fever_contact="" if fever_contact=="NA"
destring fever_contact, replace
ta fever_contact, m


gen feverCntct_denvT=.
*Fill when denv_pcr==1
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace feverCntct_denvT=0 if fever_contact==0 & denv_pcr_y==1 & feverCntct_denvT==. & nthRecAIC==`i' & Acute==`k'
replace feverCntct_denvT=1 if fever_contact==1 & denv_pcr_y==1 & feverCntct_denvT==. & nthRecAIC==`i' & Acute==`k'
ta feverCntct_denvT feverCntct_denvT, m

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward feverCntct_denvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward feverCntct_denvT , replace
sort person_id date_complete nthRecAIC
ta feverCntct_denvT, m
}
}
*
*Fill when denv_pcr==0
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace feverCntct_denvT=0 if fever_contact==0 & denv_pcr_y==0 & feverCntct_denvT==. & nthRecAIC==`i' & Acute==`k'
replace feverCntct_denvT=1 if fever_contact==1 & denv_pcr_y==0 & feverCntct_denvT==. & nthRecAIC==`i' & Acute==`k'
ta feverCntct_denvT feverCntct_denvT, m

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward feverCntct_denvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward feverCntct_denvT , replace
sort person_id date_complete nthRecAIC
ta feverCntct_denvT, m
}
}
*
* now fill indepdent of denv_pcr_y status
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace feverCntct_denvT=0 if fever_contact==0 & feverCntct_denvT==. & nthRecAIC==`i' &  Acute==`k'
replace feverCntct_denvT=1 if fever_contact==1 & feverCntct_denvT==. & nthRecAIC==`i' &  Acute==`k'
ta feverCntct_denvT feverCntct_denvT, m

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute : carryforward feverCntct_denvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute : carryforward feverCntct_denvT , replace
sort person_id date_complete nthRecAIC
ta feverCntct_denvT, m
}
}
*
ta feverCntct_denvT fever_contact, m
ta feverCntct_denvT, m
replace feverCntct_denvT=2 if feverCntct_denvT==.
ta feverCntct_denvT, m

label define lbl_feverCntct_denvT 0 "No" 1 "Yes" 2 "missing"
label val feverCntct_denvT lbl_feverCntct_denvT
ta feverCntct_denvT, m
*browse person_id  date_complete nthRecAIC Acute denv_pcr_y fever_contact feverCntct_denvT

gen feverCntct_denvT3=.
replace feverCntct_denvT3=0 if feverCntct_denvT==0
replace feverCntct_denvT3=1 if feverCntct_denvT==1
label define lbl_feverCntct_denvT3 0 "No" 1 "Yes"
label val feverCntct_denvT3 lbl_feverCntct_denvT3
ta feverCntct_denvT feverCntct_denvT3, m

gen difffeverCntct_denvT=.
sort person_id nthRecAIC Acute
bysort person_id Acute: replace difffeverCntct_denvT=1 if feverCntct_denvT[_n]!=feverCntct_denvT[_n+1] & feverCntct_denvT[_n+1]!=. 
ta difffeverCntct_denvT, m
drop difffeverCntct_denvT	

*browse person_id  date_complete nthRecAIC Acute denv_pcr_y fever_contact feverCntct_denvT difffeverCntct_denvT



















********************************************************************************
********************************************************************************
****Mosquito exposure and preventive behavior - CHIKV
********************************************************************************
********************************************************************************
*These are variables that vary over time


********************************************************************************
*Outdoor activities
ta outdoor_activity_aic, m //Does the child usually work outdoors or do outdoor activities?

*0 No
*1 Yes
*8 Refused

gen outdoorActy_chikvT=.
*Fill when denv_pcr==1
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace outdoorActy_chikvT=0 if outdoor_activity_aic=="0" & chikv_pcr_y==1 & outdoorActy_chikvT==. & nthRecAIC==`i' & Acute==`k'
replace outdoorActy_chikvT=1 if outdoor_activity_aic=="1" & chikv_pcr_y==1 & outdoorActy_chikvT==. & nthRecAIC==`i' & Acute==`k'
ta outdoorActy_chikvT outdoorActy_chikvT, m

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward outdoorActy_chikvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward outdoorActy_chikvT , replace
sort person_id date_complete nthRecAIC
ta outdoorActy_chikvT, m
}
}
*
*Fill when denv_pcr==0
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace outdoorActy_chikvT=0 if outdoor_activity_aic=="0" & chikv_pcr_y==0 & outdoorActy_chikvT==. & nthRecAIC==`i' & Acute==`k'
replace outdoorActy_chikvT=1 if outdoor_activity_aic=="1" & chikv_pcr_y==0 & outdoorActy_chikvT==. & nthRecAIC==`i' & Acute==`k'
ta outdoorActy_chikvT outdoorActy_chikvT, m

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward outdoorActy_chikvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward outdoorActy_chikvT , replace
sort person_id date_complete nthRecAIC
ta outdoorActy_chikvT, m
}
}
*
* now fill indepdent of denv_pcr_y status
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace outdoorActy_chikvT=0 if outdoor_activity_aic=="0" & outdoorActy_chikvT==. & nthRecAIC==`i' &  Acute==`k'
replace outdoorActy_chikvT=1 if outdoor_activity_aic=="1" & outdoorActy_chikvT==. & nthRecAIC==`i' &  Acute==`k'
ta outdoorActy_chikvT outdoorActy_chikvT, m

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute : carryforward outdoorActy_chikvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute : carryforward outdoorActy_chikvT , replace
sort person_id date_complete nthRecAIC
ta outdoorActy_chikvT, m
}
}
*
ta outdoorActy_chikvT outdoor_activity_aic, m
ta  outdoorActy_chikvT, m
replace outdoorActy_chikvT=2 if outdoorActy_chikvT==.
ta outdoorActy_chikvT, m

label define lbl_outdoorActy_chikvT 0 "No" 1 "Yes" 2"missing"
label val outdoorActy_chikvT lbl_outdoorActy_chikvT
ta outdoorActy_chikvT, m
*browse person_id  date_complete nthRecAIC Acute denv_pcr_y outdoor_activity_aic outdoorActy_chikvT
*check MF0698 whether code wsa right

gen outdoorActy_chikvT3=.
replace outdoorActy_chikvT3=0 if outdoorActy_chikvT==0
replace outdoorActy_chikvT3=1 if outdoorActy_chikvT==1
label define lbl_outdoorActy_chikvT3 0 "No" 1 "Yes"
label val outdoorActy_chikvT3 lbl_outdoorActy_chikvT3
ta outdoorActy_chikvT outdoorActy_chikvT3, m

gen diffoutdoorActy_chikvT=.
sort person_id nthRecAIC Acute
bysort person_id Acute: replace diffoutdoorActy_chikvT=1 if outdoorActy_chikvT[_n]!=outdoorActy_chikvT[_n+1] & outdoorActy_chikvT[_n+1]!=. 
ta diffoutdoorActy_chikvT, m
drop diffoutdoorActy_chikvT	

*browse person_id  date_complete nthRecAIC Acute denv_pcr_y outdoor_activity_aic outdoorActy_chikvT diffoutdoorActy_chikvT


********************************************************************************
*Self-reported mosquito bites

ta mosquito_bites_aic, m //Did the child get bitten by mosquitoes in the last 4 weeks?
*1 Yes
*0 No
*8 Refused

gen msqtBites_chikvT=.
*Fill when denv_pcr==1
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace msqtBites_chikvT=0 if mosquito_bites_aic=="0" & chikv_pcr_y==1 & msqtBites_chikvT==. & nthRecAIC==`i' & Acute==`k'
replace msqtBites_chikvT=1 if mosquito_bites_aic=="1" & chikv_pcr_y==1 & msqtBites_chikvT==. & nthRecAIC==`i' & Acute==`k'
ta msqtBites_chikvT msqtBites_chikvT, m

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward msqtBites_chikvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward msqtBites_chikvT , replace
sort person_id date_complete nthRecAIC
ta msqtBites_chikvT, m
}
}
*
*Fill when denv_pcr==0
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace msqtBites_chikvT=0 if mosquito_bites_aic=="0" & chikv_pcr_y==0 & msqtBites_chikvT==. & nthRecAIC==`i' & Acute==`k'
replace msqtBites_chikvT=1 if mosquito_bites_aic=="1" & chikv_pcr_y==0 & msqtBites_chikvT==. & nthRecAIC==`i' & Acute==`k'
ta msqtBites_chikvT msqtBites_chikvT, m

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward msqtBites_chikvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward msqtBites_chikvT , replace
sort person_id date_complete nthRecAIC
ta msqtBites_chikvT, m
}
}
*
* now fill indepdent of denv_pcr_y status
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace msqtBites_chikvT=0 if mosquito_bites_aic=="0" & msqtBites_chikvT==. & nthRecAIC==`i' &  Acute==`k'
replace msqtBites_chikvT=1 if mosquito_bites_aic=="1" & msqtBites_chikvT==. & nthRecAIC==`i' &  Acute==`k'
ta msqtBites_chikvT msqtBites_chikvT, m

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute : carryforward msqtBites_chikvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute : carryforward msqtBites_chikvT , replace
sort person_id date_complete nthRecAIC
ta msqtBites_chikvT, m
}
}
*
ta msqtBites_chikvT mosquito_bites_aic, m
ta msqtBites_chikvT, m
replace msqtBites_chikvT=2 if msqtBites_chikvT==.
ta msqtBites_chikvT, m

label define lbl_msqtBites_chikvT 0 "No" 1 "Yes" 2"missing"
label val msqtBites_chikvT lbl_msqtBites_chikvT
ta msqtBites_chikvT, m
*browse person_id  date_complete nthRecAIC Acute denv_pcr_y mosquito_bites_aic msqtBites_chikvT

gen msqtBites_chikvT3=.
replace msqtBites_chikvT3=0 if msqtBites_chikvT==0
replace msqtBites_chikvT3=1 if msqtBites_chikvT==1
label define lbl_msqtBites_chikvT3 0 "No" 1 "Yes"
label val msqtBites_chikvT3 lbl_msqtBites_chikvT3
ta msqtBites_chikvT msqtBites_chikvT3, m

gen diffmsqtBites_chikvT=.
sort person_id nthRecAIC Acute
bysort person_id Acute: replace diffmsqtBites_chikvT=1 if msqtBites_chikvT[_n]!=msqtBites_chikvT[_n+1] & msqtBites_chikvT[_n+1]!=. 
ta diffmsqtBites_chikvT, m
drop diffmsqtBites_chikvT	

*browse person_id  date_complete nthRecAIC Acute denv_pcr_y mosquito_bites_aic msqtBites_chikvT diffmsqtBites_chikvT


*********************************************************************************
*Mosquito coil

ta mosquito_coil_aic, m //Does the child use a mosquito coil to avoid mosquitoes?
*1 Yes
*0 No
*8 Refused

gen msqtCoil_chikvT=.
*Fill when denv_pcr==1
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace msqtCoil_chikvT=0 if mosquito_coil_aic=="0" & chikv_pcr_y==1 & msqtCoil_chikvT==. & nthRecAIC==`i' & Acute==`k'
replace msqtCoil_chikvT=1 if mosquito_coil_aic=="1" & chikv_pcr_y==1 & msqtCoil_chikvT==. & nthRecAIC==`i' & Acute==`k'
ta msqtCoil_chikvT msqtCoil_chikvT, m

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward msqtCoil_chikvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward msqtCoil_chikvT , replace
sort person_id date_complete nthRecAIC
ta msqtCoil_chikvT, m
}
}
*
*Fill when denv_pcr==0
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace msqtCoil_chikvT=0 if mosquito_coil_aic=="0" & chikv_pcr_y==0 & msqtCoil_chikvT==. & nthRecAIC==`i' & Acute==`k'
replace msqtCoil_chikvT=1 if mosquito_coil_aic=="1" & chikv_pcr_y==0 & msqtCoil_chikvT==. & nthRecAIC==`i' & Acute==`k'
ta msqtCoil_chikvT msqtCoil_chikvT, m

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward msqtCoil_chikvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward msqtCoil_chikvT , replace
sort person_id date_complete nthRecAIC
ta msqtCoil_chikvT, m
}
}
*
* now fill indepdent of denv_pcr_y status
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace msqtCoil_chikvT=0 if mosquito_coil_aic=="0" & msqtCoil_chikvT==. & nthRecAIC==`i' &  Acute==`k'
replace msqtCoil_chikvT=1 if mosquito_coil_aic=="1" & msqtCoil_chikvT==. & nthRecAIC==`i' &  Acute==`k'
ta msqtCoil_chikvT msqtCoil_chikvT, m

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute : carryforward msqtCoil_chikvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute : carryforward msqtCoil_chikvT , replace
sort person_id date_complete nthRecAIC
ta msqtCoil_chikvT, m
}
}
*
ta msqtCoil_chikvT mosquito_coil_aic, m
ta msqtCoil_chikvT, m
replace msqtCoil_chikvT=2 if msqtCoil_chikvT==.
ta msqtCoil_chikvT, m

label define lbl_msqtCoil_chikvT 0 "No" 1 "Yes" 2"missing"
label val msqtCoil_chikvT lbl_msqtCoil_chikvT
ta msqtCoil_chikvT, m
*browse person_id  date_complete nthRecAIC Acute denv_pcr_y mosquito_coil_aic msqtCoil_chikvT

gen msqtCoil_chikvT3=.
replace msqtCoil_chikvT3=0 if msqtCoil_chikvT==0
replace msqtCoil_chikvT3=1 if msqtCoil_chikvT==1
label define lbl_msqtCoil_chikvT3 0 "No" 1 "Yes"
label val msqtCoil_chikvT3 lbl_msqtCoil_chikvT3
ta msqtCoil_chikvT msqtCoil_chikvT3, m

gen diffmsqtCoil_chikvT=.
sort person_id nthRecAIC Acute
bysort person_id Acute: replace diffmsqtCoil_chikvT=1 if msqtCoil_chikvT[_n]!=msqtCoil_chikvT[_n+1] & msqtCoil_chikvT[_n+1]!=. 
ta diffmsqtCoil_chikvT, m
drop diffmsqtCoil_chikvT	

*browse person_id  date_complete nthRecAIC Acute denv_pcr_y mosquito_coil_aic msqtCoil_chikvT diffmsqtCoil_chikvT

********************************************************************************
**Mosquito NET

ta mosquito_net_aic, m //Does the child sleep under a mosquito net?
*1 Always
*2 Sometimes
*3 Rarely
*4 Never
*9 N/A

*Destringed for denv

gen msqtNet_chikvT=.
*Fill when denv_pcr==1
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace msqtNet_chikvT=mosquito_net_aic if chikv_pcr_y==1 & msqtNet_chikvT==. & nthRecAIC==`i' & Acute==`k'
ta msqtNet_chikvT msqtNet_chikvT, m

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward msqtNet_chikvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward msqtNet_chikvT , replace
sort person_id date_complete nthRecAIC
ta msqtNet_chikvT, m
}
}
*
*Fill when denv_pcr==0
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace msqtNet_chikvT=mosquito_net_aic if chikv_pcr_y==0 & msqtNet_chikvT==. & nthRecAIC==`i' & Acute==`k'
ta msqtNet_chikvT msqtNet_chikvT, m

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward msqtNet_chikvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward msqtNet_chikvT , replace
sort person_id date_complete nthRecAIC
ta msqtNet_chikvT, m
}
}
*
* now fill indepdent of denv_pcr_y status
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace msqtNet_chikvT=mosquito_net_aic if msqtNet_chikvT==. & nthRecAIC==`i' &  Acute==`k'
ta msqtNet_chikvT msqtNet_chikvT, m

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute : carryforward msqtNet_chikvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute : carryforward msqtNet_chikvT , replace
sort person_id date_complete nthRecAIC
ta msqtNet_chikvT, m
}
}
*
ta msqtNet_chikvT mosquito_coil_aic, m
ta msqtNet_chikvT, m
replace msqtNet_chikvT=5 if msqtNet_chikvT==.
ta msqtNet_chikvT, m

label define lbl_msqtNet_chikvT 1 "Always" 2 "Sometimes" 3 "Rarely" 4 "Never" 5 "missing"
label val msqtNet_chikvT lbl_mosquitoNetT
ta msqtNet_chikvT, m
*browse person_id  date_complete nthRecAIC Acute denv_pcr_y mosquito_coil_aic msqtNet_chikvT

gen msqtNet_chikvT3=.
replace msqtNet_chikvT3=0 if msqtNet_chikvT==1
replace msqtNet_chikvT3=1 if msqtNet_chikvT==2 |  msqtNet_chikvT==3 |  msqtNet_chikvT==4
label define lbl_msqtNet_chikvT3 0 "Always protected" 1 "Sometimes-never protected"
label val msqtNet_chikvT3 lbl_msqtNet_chikvT3
ta msqtNet_chikvT msqtNet_chikvT3, m

gen diffmsqtNet_chikvT=.
sort person_id nthRecAIC Acute
bysort person_id Acute: replace diffmsqtNet_chikvT=1 if msqtNet_chikvT[_n]!=msqtNet_chikvT[_n+1] & msqtNet_chikvT[_n+1]!=. 
ta diffmsqtNet_chikvT, m
drop diffmsqtNet_chikvT	

*browse person_id  date_complete nthRecAIC Acute denv_pcr_y mosquito_coil_aic msqtNet_chikvT diffmsqtNet_chikvT


*******************************************************************************
*Fever contact
ta fever_contact, m //Has the child been in contact with other people with similar symptoms in the last 15 days?
*1 Yes
*0 No
*8 Refused

*Already destringed for denv

gen feverCntct_chikvT=.
*Fill when denv_pcr==1
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace feverCntct_chikvT=0 if fever_contact==0 & chikv_pcr_y==1 & feverCntct_chikvT==. & nthRecAIC==`i' & Acute==`k'
replace feverCntct_chikvT=1 if fever_contact==1 & chikv_pcr_y==1 & feverCntct_chikvT==. & nthRecAIC==`i' & Acute==`k'
ta feverCntct_chikvT feverCntct_chikvT, m

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward feverCntct_chikvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward feverCntct_chikvT , replace
sort person_id date_complete nthRecAIC
ta feverCntct_chikvT, m
}
}
*
*Fill when denv_pcr==0
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace feverCntct_chikvT=0 if fever_contact==0 & chikv_pcr_y==0 & feverCntct_chikvT==. & nthRecAIC==`i' & Acute==`k'
replace feverCntct_chikvT=1 if fever_contact==1 & chikv_pcr_y==0 & feverCntct_chikvT==. & nthRecAIC==`i' & Acute==`k'
ta feverCntct_chikvT feverCntct_chikvT, m

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward feverCntct_chikvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward feverCntct_chikvT , replace
sort person_id date_complete nthRecAIC
ta feverCntct_chikvT, m
}
}
*
* now fill indepdent of denv_pcr_y status
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace feverCntct_chikvT=0 if fever_contact==0 & feverCntct_chikvT==. & nthRecAIC==`i' &  Acute==`k'
replace feverCntct_chikvT=1 if fever_contact==1 & feverCntct_chikvT==. & nthRecAIC==`i' &  Acute==`k'
ta feverCntct_chikvT feverCntct_chikvT, m

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute : carryforward feverCntct_chikvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute : carryforward feverCntct_chikvT , replace
sort person_id date_complete nthRecAIC
ta feverCntct_chikvT, m
}
}
*
ta feverCntct_chikvT fever_contact, m
ta feverCntct_chikvT, m
replace feverCntct_chikvT=2 if feverCntct_chikvT==.
ta feverCntct_chikvT, m

label define lbl_feverCntct_chikvT 0 "No" 1 "Yes" 2 "missing"
label val feverCntct_chikvT lbl_feverCntct_chikvT
ta feverCntct_chikvT, m
*browse person_id  date_complete nthRecAIC Acute denv_pcr_y fever_contact feverCntct_chikvT

gen feverCntct_chikvT3=.
replace feverCntct_chikvT3=0 if feverCntct_chikvT==0
replace feverCntct_chikvT3=1 if feverCntct_chikvT==1
label define lbl_feverCntct_chikvT3 0 "No" 1 "Yes"
label val feverCntct_chikvT3 lbl_feverCntct_chikvT3
ta feverCntct_chikvT feverCntct_chikvT3, m

gen difffeverCntct_chikvT=.
sort person_id nthRecAIC Acute
bysort person_id Acute: replace difffeverCntct_chikvT=1 if feverCntct_chikvT[_n]!=feverCntct_chikvT[_n+1] & feverCntct_chikvT[_n+1]!=. 
ta difffeverCntct_chikvT, m
drop difffeverCntct_chikvT	

*browse person_id  date_complete nthRecAIC Acute denv_pcr_y fever_contact feverCntct_chikvT difffeverCntct_chikvT
















































****************************************************************************
********************************************************************************
**Symptoms
********************************************************************************
********************************************************************************

ta symptoms_aic, m
ta oth_symptoms_aic, m


********************************************************************************
**Abnominal pain

*Variable stored in the record that it is found
gen abp_aic=0
replace abp_aic=1 if strpos(symptoms_aic, "abdomil_pain")
replace abp_aic=1 if strpos(symptoms_aic, "abdominal_pa")
replace abp_aic=1 if strpos(symptoms_aic, "abdomin")
replace abp_aic=1 if strpos(symptoms_aic, "abdomina")
replace abp_aic=1 if strpos(symptoms_aic, "abdominal_pai")
replace abp_aic=1 if strpos(symptoms_aic, "abdominal_p")
replace abp_aic=1 if strpos(symptoms_aic, "abdo")
replace abp_aic=1 if strpos(symptoms_aic, "abd")
replace abp_aic=1 if strpos(symptoms_aic, "abpin")
replace abp_aic=1 if strpos(symptoms_aic, "abpi")
replace abp_aic=1 if strpos(symptoms_aic, "abpal_p")
replace abp_aic=1 if strpos(symptoms_aic, "abp")
list abp_aic symptoms_aic in 1/20 if abp_aic==1
ta abp_aic, m

********************************************************************************
**Chills
*Variable stored in the record that it is found
gen chills_aic=0
replace chills_aic=1 if strpos(symptoms_aic, "chills")
replace chills_aic=1 if strpos(symptoms_aic, "chi")
list chills_aic symptoms_aic in 1/20 if chills_aic==1
ta chills_aic, m

********************************************************************************
**Diarrhea
*Variable stored in the record that it is found
gen diarrhea_aic=0
replace diarrhea_aic=1 if strpos(symptoms_aic, "dia")
replace diarrhea_aic=1 if strpos(symptoms_aic, "diar")
replace diarrhea_aic=1 if strpos(symptoms_aic, "diarrhea")
list diarrhea_aic symptoms_aic in 1/100 if diarrhea_aic==1
ta diarrhea_aic, m

********************************************************************************
**Rash
*Variable stored in the record that it is found
gen rash_aic=0
replace rash_aic=1 if strpos(symptoms_aic, "rash")
replace rash_aic=1 if strpos(symptoms_aic, "rass")
replace rash_aic=1 if strpos(symptoms_aic, "ras")
list rash_aic symptoms_aic in 1/100 if rash_aic==1
ta rash_aic, m

********************************************************************************
**Bleeding
*Variable stored in the record that it is found
gen bleeding_aic=0
replace bleeding_aic=1 if strpos(symptoms_aic, "bleeding_gums")
replace bleeding_aic=1 if strpos(symptoms_aic, "bloody_nose")
replace bleeding_aic=1 if strpos(symptoms_aic, "bloody_urine")
replace bleeding_aic=1 if strpos(symptoms_aic, "bloody_stool")
replace bleeding_aic=1 if strpos(symptoms_aic, "bloody_vomit")
replace bleeding_aic=1 if strpos(symptoms_aic, "bruises")
replace bleeding_aic=1 if strpos(symptoms_aic, "bleeding")
list bleeding_aic symptoms_aic if bleeding_aic==1
ta bleeding_aic, m

********************************************************************************
**Body Ache
*Variable stored in the record that it is found
gen body_ache_aic=0
replace body_ache_aic=1 if strpos(symptoms_aic, "body_ache")
replace body_ache_aic=1 if strpos(symptoms_aic, "muscle_pains")
replace body_ache_aic=1 if strpos(symptoms_aic, "bone_pains")
list symptoms_aic in 1/100 if body_ache_aic==1
ta body_ache_aic, m

********************************************************************************
**Nausea
*Variable stored in the record that it is found
gen nausea_aic=0
replace nausea_aic=1 if strpos(symptoms_aic, "nausea")
replace nausea_aic=1 if strpos(symptoms_aic, "nau")
list symptoms_aic in 1/100 if nausea_aic==1
ta nausea_aic, m

********************************************************************************
**Vomit
*Variable stored in the record that it is found
gen vomit_aic=0
replace vomit_aic=1 if strpos(symptoms_aic, "vomit")
replace vomit_aic=1 if strpos(symptoms_aic, "vom")
list symptoms_aic in 1/100 if vomit_aic==1
ta vomit_aic, m

********************************************************************************
**Impaired mental status
*Variable stored in the record that it is found
gen impMentalStatus_aic=0
replace impMentalStatus_aic=1 if strpos(symptoms_aic, "impaired_mental_status")
replace impMentalStatus_aic=1 if strpos(symptoms_aic, "impaired")
replace impMentalStatus_aic=1 if strpos(symptoms_aic, "mental")
list impMentalStatus_aic in 1/100 if impMentalStatus_aic==1
ta impMentalStatus_aic, m

********************************************************************************
**hepatomegaly
*Variable stored in the record that it is found
gen hepatomegaly_aic=0
replace hepatomegaly_aic=1 if strpos(symptoms_aic, "hepatomegaly")
replace hepatomegaly_aic=1 if strpos(symptoms_aic, "liver")
list hepatomegaly_aic in 1/100 if hepatomegaly_aic==1
ta hepatomegaly_aic, m //nobody is empty? also when searching for liver or enlargment of liver nothing is found

********************************************************************************
**Splenomegaly
*Variable stored in the record that it is found
gen splenomegaly_aic=0
replace splenomegaly_aic=1 if strpos(symptoms_aic, "splenomegaly")
replace splenomegaly_aic=1 if strpos(symptoms_aic, "splen")
replace splenomegaly_aic=1 if strpos(symptoms_aic, "spleen")
list splenomegaly_aic in 1/100 if splenomegaly_aic==1
ta splenomegaly_aic, m //nobody is empty? 

********************************************************************************
**Edema
*Variable stored in the record that it is found
gen edema_aic=0
replace edema_aic=1 if strpos(symptoms_aic, "edema")
list edema_aic in 1/100 if edema_aic==1
ta edema_aic, m //nobody is empty? 

********************************************************************************
*# dengue : probable and warning  (Amy syntax)
gen probDnv=0
replace probDnv=probDnv+1 if body_ache==1
replace probDnv=probDnv+1 if vomit==1
replace probDnv=probDnv+1 if nausea==1
replace probDnv=probDnv+1 if rash==1
replace probDnv=probDnv+1 if bleeding==1
*replace probDnv=probDnv+1 if hepatomegaly==1 //empty
replace probDnv=probDnv+1 if impMentalStatus==1
ta probDnv, m

*browse person_id nthRecAIC probDnv body_acheT vomitT nauseaT rashT bleedingT impMentalStatusT

gen denvWrn=0
replace denvWrn=denvWrn+1 if impMentalStatus==1
replace denvWrn=denvWrn+1 if bleeding==1
replace denvWrn=denvWrn+1 if vomit==1
replace denvWrn=denvWrn+1 if abp==1
replace denvWrn=denvWrn+1 if bleeding==1
*replace denvWrn=denvWrn+1 if hepatomegalyT==1
*replace denvWrn=denvWrn+1 if splenomegalyT==1 empty
*replace denvWrn=denvWrn+1 if edemaT==1 empty
ta denvWrn, m

ta probDnv denvWrn, m


********************************************************************************
*Expanded and extracted from the relevant record
*Desiree: please use symtomps from when DENV or CHIKV positive
*NA: also realize you want to do this separate for the 4 acute visits
*NA, 3-dec-18: also realize that this will be differetn for DENV or CHIKV!
********************************************************************************

********************************************************************************
*First fill for DENV
********************************************************************************

gen abp_denvT=.
*First fill only when denv_pcr_y===1
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace abp_denvT=abp_aic if denv_pcr_y==1 & nthRecAIC==`i' & abp_denvT==. & Acute==`k'

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward abp_denvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward abp_denvT , replace
sort person_id date_complete nthRecAIC
ta abp_denvT, m

}
}
*
*Fill only when denv_pcr_y===0
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace abp_denvT=abp_aic if denv_pcr_y==0 & nthRecAIC==`i' & abp_denvT==. & Acute==`k'

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward abp_denvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward abp_denvT , replace
sort person_id date_complete nthRecAIC
ta abp_denvT, m

}
}
*
* now fill indepdent of denv_pcr_y status
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace abp_denvT=abp_aic if nthRecAIC==`i' & abp_denvT==. & Acute==`k'

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward abp_denvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward abp_denvT , replace
sort person_id date_complete nthRecAIC
ta abp_denvT, m
}
}
ta abp_denvT denv_pcr_y, m
*browse person_id date_complete nthRecAIC Acute Acute abp_aic abp_denvT denv_pcr_y if denv_pcr_y==0 & abp_denvT==.
*browse person_id date_complete nthRecAIC Acute Acute abp_aic abp_denvT denv_pcr_y 

*person_id CF0272 --> is the perfect person to check whether the code ran correctly
*person_id==MF0697	date_complete==11sep2015 --> was not assigned an "acute" status and therefore abp is empty

label define lbl_abp_denvT 0 "no" 1 "yes"
label val abp_denvT lbl_abp_denvT
ta abp_denvT, m

gen diffabp_denvT=.
sort person_id nthRecAIC Acute
bysort person_id Acute: replace diffabp_denvT=1 if abp_denvT[_n]!=abp_denvT[_n+1] & abp_denvT[_n+1]!=. 
ta diffabp_denvT, m
drop diffabp_denvT	


********************************************************************************
**Chills

*Expanded and extracted from the relevant record
gen chills_denvT=.
*First fill only when denv_pcr_y===1
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace chills_denvT=chills_aic if denv_pcr_y==1 & nthRecAIC==`i' & chills_denvT==. & Acute==`k'

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward chills_denvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward chills_denvT , replace
sort person_id date_complete nthRecAIC
ta chills_denvT, m

}
}
*Fill only when denv_pcr_y===0
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace chills_denvT=chills_aic if denv_pcr_y==0 & nthRecAIC==`i' & chills_denvT==. & Acute==`k'

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward chills_denvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward chills_denvT , replace
sort person_id date_complete nthRecAIC
ta chills_denvT, m

}
}
* now fill indepdent of denv_pcr_y status
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace chills_denvT=chills_aic if nthRecAIC==`i' & chills_denvT==. & Acute==`k'

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward chills_denvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward chills_denvT , replace
sort person_id date_complete nthRecAIC
ta chills_denvT, m
}
}
ta chills_denvT denv_pcr_y, m
*browse person_id date_complete nthRecAIC Acute Acute chills_aic chills_denvT denv_pcr_y if denv_pcr_y==0 & chills_denvT==.
*browse person_id date_complete nthRecAIC Acute Acute chills_aic chills_denvT denv_pcr_y 

label define lbl_chills_denvT 0 "no" 1 "yes"
label val chills_denvT lbl_chills_denvT
ta chills_denvT, m

gen diffchills_denvT=.
sort person_id nthRecAIC Acute
bysort person_id Acute: replace diffchills_denvT=1 if chills_denvT[_n]!=chills_denvT[_n+1] & chills_denvT[_n+1]!=. 
ta diffchills_denvT, m
drop diffchills_denvT	


********************************************************************************
**Diarrhea

*Expanded and extracted from the relevant record
gen diarrhea_denvT=.
*First fill only when denv_pcr_y===1
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace diarrhea_denvT=diarrhea_aic if denv_pcr_y==1 & nthRecAIC==`i' & diarrhea_denvT==. & Acute==`k'

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward diarrhea_denvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward diarrhea_denvT , replace
sort person_id date_complete nthRecAIC
ta diarrhea_denvT diarrhea_aic, m

}
}
*Fill only when denv_pcr_y===0
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace diarrhea_denvT=diarrhea_aic if denv_pcr_y==0 & nthRecAIC==`i' & diarrhea_denvT==. & Acute==`k'

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward diarrhea_denvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward diarrhea_denvT , replace
sort person_id date_complete nthRecAIC
ta diarrhea_denvT diarrhea_aic, m

}
}
* now fill indepdent of denv_pcr_y status
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace diarrhea_denvT=diarrhea_aic if nthRecAIC==`i' & diarrhea_denvT==. & Acute==`k'

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward diarrhea_denvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward diarrhea_denvT , replace
sort person_id date_complete nthRecAIC
ta diarrhea_denvT, m
}
}
ta diarrhea_denvT denv_pcr_y, m
*browse person_id date_complete nthRecAIC Acute Acute diarrhea_aic diarrhea_denvT denv_pcr_y if denv_pcr_y==0 & diarrhea_denvT==.
*browse person_id date_complete nthRecAIC Acute Acute diarrhea_aic diarrhea_denvT denv_pcr_y 

label define lbl_diarrhea_denvT 0 "no" 1 "yes"
label val diarrhea_denvT lbl_diarrhea_denvT
ta diarrhea_denvT, m

gen diffdiarrhea_denvT=.
sort person_id nthRecAIC Acute
bysort person_id Acute: replace diffdiarrhea_denvT=1 if diarrhea_denvT[_n]!=diarrhea_denvT[_n+1] & diarrhea_denvT[_n+1]!=. 
ta diffdiarrhea_denvT, m
drop diffdiarrhea_denvT	

********************************************************************************
**Rash
*Expanded and extracted from the relevant record
gen rash_denvT=.
*First fill only when denv_pcr_y===1
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace rash_denvT=rash_aic if denv_pcr_y==1 & nthRecAIC==`i' & rash_denvT==. & Acute==`k'

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward rash_denvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward rash_denvT , replace
sort person_id date_complete nthRecAIC
ta rash_denvT rash_aic, m
}
}
*First fill only when denv_pcr_y===0
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace rash_denvT=rash_aic if denv_pcr_y==0 & nthRecAIC==`i' & rash_denvT==. & Acute==`k'

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward rash_denvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward rash_denvT , replace
sort person_id date_complete nthRecAIC
ta rash_denvT rash_aic, m
}
}
* now fill indepdent of denv_pcr_y status
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace rash_denvT=rash_aic if nthRecAIC==`i' & rash_denvT==. & Acute==`k'

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward rash_denvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward rash_denvT , replace
sort person_id date_complete nthRecAIC
ta rash_denvT, m
}
}
ta rash_denvT denv_pcr_y, m
*browse person_id date_complete nthRecAIC Acute Acute rash_aic rash_denvT denv_pcr_y if denv_pcr_y==0 & rash_denvT==.
*browse person_id date_complete nthRecAIC Acute Acute rash_aic rash_denvT denv_pcr_y 

label define lbl_rash_denvT 0 "no" 1 "yes"
label val rash_denvT lbl_rash_denvT
ta rash_denvT, m

gen diffrash_denvT=.
sort person_id nthRecAIC Acute
bysort person_id Acute: replace diffrash_denvT=1 if rash_denvT[_n]!=rash_denvT[_n+1] & rash_denvT[_n+1]!=. 
ta diffrash_denvT, m
drop diffrash_denvT	

********************************************************************************
**Bleeding
*Expanded and extracted from the relevant record
gen bleeding_denvT=.
*First fill only when denv_pcr_y===1
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace bleeding_denvT=bleeding_aic if denv_pcr_y==1 & nthRecAIC==`i' & bleeding_denvT==. & Acute==`k'

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward bleeding_denvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward bleeding_denvT , replace
sort person_id date_complete nthRecAIC
ta bleeding_denvT bleeding_aic, m

}
}
*First fill only when denv_pcr_y===0
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace bleeding_denvT=bleeding_aic if denv_pcr_y==0 & nthRecAIC==`i' & bleeding_denvT==. & Acute==`k'

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward bleeding_denvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward bleeding_denvT , replace
sort person_id date_complete nthRecAIC
ta bleeding_denvT bleeding_aic, m

}
}
* now fill indepdent of denv_pcr_y status
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace bleeding_denvT=bleeding_aic if nthRecAIC==`i' & bleeding_denvT==. & Acute==`k'

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward bleeding_denvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward bleeding_denvT , replace
sort person_id date_complete nthRecAIC
ta bleeding_denvT, m
}
}
ta bleeding_denvT denv_pcr_y, m
*browse person_id date_complete nthRecAIC Acute Acute bleeding_aic bleeding_denvT denv_pcr_y if denv_pcr_y==0 & bleeding_denvT==.
*browse person_id date_complete nthRecAIC Acute Acute bleeding_aic bleeding_denvT denv_pcr_y 

label define lbl_bleeding_denvT 0 "no" 1 "yes"
label val bleeding_denvT lbl_bleeding_denvT
ta bleeding_denvT, m

gen diffbleeding_denvT=.
sort person_id nthRecAIC Acute
bysort person_id Acute: replace diffbleeding_denvT=1 if bleeding_denvT[_n]!=bleeding_denvT[_n+1] & bleeding_denvT[_n+1]!=. 
ta diffbleeding_denvT, m
drop diffbleeding_denvT	

********************************************************************************
**Body Ache
*Expanded and extracted from the relevant record
gen body_ache_denvT=.
*First fill only when denv_pcr_y===1
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace body_ache_denvT=body_ache_aic if denv_pcr_y==1 & nthRecAIC==`i' & body_ache_denvT==. & Acute==`k'

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward body_ache_denvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward body_ache_denvT , replace
sort person_id date_complete nthRecAIC
ta body_ache_denvT body_ache_aic, m

}
}
*First fill only when denv_pcr_y===0
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace body_ache_denvT=body_ache_aic if denv_pcr_y==0 & nthRecAIC==`i' & body_ache_denvT==. & Acute==`k'

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward body_ache_denvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward body_ache_denvT , replace
sort person_id date_complete nthRecAIC
ta body_ache_denvT body_ache_aic, m

}
}
* now fill indepdent of denv_pcr_y status
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace body_ache_denvT=body_ache_aic if nthRecAIC==`i' & body_ache_denvT==. & Acute==`k'

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward body_ache_denvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward body_ache_denvT , replace
sort person_id date_complete nthRecAIC
ta body_ache_denvT, m
}
}
ta body_ache_denvT denv_pcr_y, m
*browse person_id date_complete nthRecAIC Acute Acute body_ache_aic body_ache_denvT denv_pcr_y if denv_pcr_y==0 & body_ache_denvT==.
*browse person_id date_complete nthRecAIC Acute Acute body_ache_aic body_ache_denvT denv_pcr_y 

label define lbl_body_ache_denvT 0 "no" 1 "yes"
label val body_ache_denvT lbl_body_ache_denvT
ta body_ache_denvT, m

gen diffbody_ache_denvT=.
sort person_id nthRecAIC Acute
bysort person_id Acute: replace diffbody_ache_denvT=1 if body_ache_denvT[_n]!=body_ache_denvT[_n+1] & body_ache_denvT[_n+1]!=. 
ta diffbody_ache_denvT, m
drop diffbody_ache_denvT	

********************************************************************************
**Nausea

*Expanded and extracted from the relevant record
gen nausea_denvT=.
*First fill only when denv_pcr_y===1
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace nausea_denvT=nausea_aic if denv_pcr_y==1 & nthRecAIC==`i' & nausea_denvT==. & Acute==`k'

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward nausea_denvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward nausea_denvT , replace
sort person_id date_complete nthRecAIC
ta nausea_denvT nausea_aic, m

}
}
*Fill only when denv_pcr_y===0
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace nausea_denvT=nausea_aic if denv_pcr_y==0 & nthRecAIC==`i' & nausea_denvT==. & Acute==`k'

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward nausea_denvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward nausea_denvT , replace
sort person_id date_complete nthRecAIC
ta nausea_denvT nausea_aic, m

}
}
* now fill indepdent of denv_pcr_y status
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace nausea_denvT=nausea_aic if nthRecAIC==`i' & nausea_denvT==. & Acute==`k'

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward nausea_denvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward nausea_denvT , replace
sort person_id date_complete nthRecAIC
ta nausea_denvT, m
}
}
ta nausea_denvT denv_pcr_y, m
*browse person_id date_complete nthRecAIC Acute Acute nausea_aic nausea_denvT denv_pcr_y if denv_pcr_y==0 & nausea_denvT==.
*browse person_id date_complete nthRecAIC Acute Acute nausea_aic nausea_denvT denv_pcr_y 

label define lbl_nausea_denvT 0 "no" 1 "yes"
label val nausea_denvT lbl_nausea_denvT
ta nausea_denvT, m

gen diffnausea_denvT=.
sort person_id nthRecAIC Acute
bysort person_id Acute: replace diffnausea_denvT=1 if nausea_denvT[_n]!=nausea_denvT[_n+1] & nausea_denvT[_n+1]!=. 
ta diffnausea_denvT, m
drop diffnausea_denvT	


********************************************************************************
**Vomit

*Expanded and extracted from the relevant record
gen vomit_denvT=.
*First fill only when denv_pcr_y===1
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace vomit_denvT=vomit_aic if denv_pcr_y==1 & nthRecAIC==`i' & vomit_denvT==. & Acute==`k'

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward vomit_denvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward vomit_denvT , replace
sort person_id date_complete nthRecAIC
ta vomit_denvT vomit_aic, m
}
}
*First fill only when denv_pcr_y===0
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace vomit_denvT=vomit_aic if denv_pcr_y==0 & nthRecAIC==`i' & vomit_denvT==. & Acute==`k'

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward vomit_denvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward vomit_denvT , replace
sort person_id date_complete nthRecAIC
ta vomit_denvT vomit_aic, m
}
}
* now fill indepdent of denv_pcr_y status
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace vomit_denvT=vomit_aic if nthRecAIC==`i' & vomit_denvT==. & Acute==`k'

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward vomit_denvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward vomit_denvT , replace
sort person_id date_complete nthRecAIC
ta vomit_denvT, m
}
}
ta vomit_denvT denv_pcr_y, m
*browse person_id date_complete nthRecAIC Acute Acute vomit_aic vomit_denvT denv_pcr_y if denv_pcr_y==0 & vomit_denvT==.
*browse person_id date_complete nthRecAIC Acute Acute vomit_aic vomit_denvT denv_pcr_y 

label define lbl_vomit_denvT 0 "no" 1 "yes"
label val vomit_denvT lbl_vomit_denvT
ta vomit_denvT, m

gen diffvomit_denvT=.
sort person_id nthRecAIC Acute
bysort person_id Acute: replace diffvomit_denvT=1 if vomit_denvT[_n]!=vomit_denvT[_n+1] & vomit_denvT[_n+1]!=. 
ta diffvomit_denvT, m
drop diffvomit_denvT	

********************************************************************************
**Impaired mental status

*Expanded and extracted from the relevant record
gen impMentalStatus_denvT=.
*First fill only when denv_pcr_y===1
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace impMentalStatus_denvT=impMentalStatus_aic if denv_pcr_y==1 & nthRecAIC==`i' & impMentalStatus_denvT==. & Acute==`k'

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward impMentalStatus_denvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward impMentalStatus_denvT , replace
sort person_id date_complete nthRecAIC
ta impMentalStatus_denvT impMentalStatus_aic, m
}
}
*Fill only when denv_pcr_y===0
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace impMentalStatus_denvT=impMentalStatus_aic if denv_pcr_y==1 & nthRecAIC==`i' & impMentalStatus_denvT==. & Acute==`k'

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward impMentalStatus_denvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward impMentalStatus_denvT , replace
sort person_id date_complete nthRecAIC
ta impMentalStatus_denvT impMentalStatus_aic, m
}
}
* now fill indepdent of denv_pcr_y status
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace impMentalStatus_denvT=impMentalStatus_aic if nthRecAIC==`i' & impMentalStatus_denvT==. & Acute==`k'

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward impMentalStatus_denvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward impMentalStatus_denvT , replace
sort person_id date_complete nthRecAIC
ta impMentalStatus_denvT, m
}
}
ta impMentalStatus_denvT denv_pcr_y, m
*browse person_id date_complete nthRecAIC Acute Acute impMentalStatus_aic impMentalStatus_denvT denv_pcr_y if denv_pcr_y==0 & impMentalStatus_denvT==.
*browse person_id date_complete nthRecAIC Acute Acute impMentalStatus_aic impMentalStatus_denvT denv_pcr_y 

label define lbl_impMentalStatus_denvT 0 "no" 1 "yes"
label val impMentalStatus_denvT lbl_impMentalStatus_denvT
ta impMentalStatus_denvT, m

gen diffimpMentalStatus_denvT=.
sort person_id nthRecAIC Acute
bysort person_id Acute: replace diffimpMentalStatus_denvT=1 if impMentalStatus_denvT[_n]!=impMentalStatus_denvT[_n+1] & impMentalStatus_denvT[_n+1]!=. 
ta diffimpMentalStatus_denvT, m
drop diffimpMentalStatus_denvT	

********************************************************************************
**Based on WHO guidelines:
** - probable_dengue
** - dengue_warning_signs

gen probDnv_denvT=.
*First fill only when denv_pcr_y===1
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace probDnv_denvT=probDnv  if denv_pcr_y==1 & nthRecAIC==`i' & probDnv_denvT==. & Acute==`k'

sort person_id date_complete nthRecAIC
by person_id: carryforward probDnv_denvT, replace
gsort person_id -date_complete -nthRecAIC
by person_id: carryforward probDnv_denvT, replace
sort person_id date_complete nthRecAIC
ta probDnv_denvT, m
}
}
ta probDnv_denvT denv_pcr_y, m
*Fill only when denv_pcr_y===0
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace probDnv_denvT=probDnv  if denv_pcr_y==0 & nthRecAIC==`i' & probDnv_denvT==. & Acute==`k'

sort person_id date_complete nthRecAIC
by person_id: carryforward probDnv_denvT, replace
gsort person_id -date_complete -nthRecAIC
by person_id: carryforward probDnv_denvT, replace
sort person_id date_complete nthRecAIC
ta probDnv_denvT, m
}
}
ta probDnv_denvT denv_pcr_y, m
* now fill indepdent of denv_pcr_y status
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace probDnv_denvT=probDnv  if nthRecAIC==`i' & probDnv_denvT==.  & Acute==`k'

sort person_id date_complete nthRecAIC
by person_id: carryforward probDnv_denvT, replace
gsort person_id -date_complete -nthRecAIC
by person_id: carryforward probDnv_denvT, replace
sort person_id date_complete nthRecAIC
ta probDnv_denvT, m
}
}
*
ta probDnv_denvT, m

gen diffprobDnv_denvT=.
sort person_id nthRecAIC Acute
bysort person_id Acute: replace diffprobDnv_denvT=1 if probDnv_denvT[_n]!=probDnv_denvT[_n+1] & probDnv_denvT[_n+1]!=. 
ta diffprobDnv_denvT, m
drop diffprobDnv_denvT	


*********************************************************************************
**Dengue early warning symptoms
*********************************************************************************

gen denvWrn_denvT=.
*First fill only when denv_pcr_y===1
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace denvWrn_denvT=denvWrn if denv_pcr_y==1 & nthRecAIC==`i' & denvWrn_denvT==.  & Acute==`k' 

sort person_id date_complete nthRecAIC
by person_id: carryforward denvWrn_denvT, replace
gsort person_id -date_complete -nthRecAIC
by person_id: carryforward denvWrn_denvT, replace
sort person_id date_complete nthRecAIC
ta denvWrn_denvT, m
}
}
ta denvWrn_denvT denv_pcr_y, m
*person_id RF0422 is a nice example to see that my codes works likes this :)
*******************************************************************************
*First fill only when denv_pcr_y===0
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace denvWrn_denvT=denvWrn if denv_pcr_y==0 & nthRecAIC==`i' & denvWrn_denvT==.  & Acute==`k' 

sort person_id date_complete nthRecAIC
by person_id: carryforward denvWrn_denvT, replace
gsort person_id -date_complete -nthRecAIC
by person_id: carryforward denvWrn_denvT, replace
sort person_id date_complete nthRecAIC
ta denvWrn_denvT, m
}
}
ta denvWrn_denvT denv_pcr_y, m

* now fill indepdent of denv_pcr_y status
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace denvWrn_denvT=denvWrn if nthRecAIC==`i' & denvWrn_denvT==.  & Acute==`k' 

sort person_id date_complete nthRecAIC
by person_id: carryforward denvWrn_denvT, replace
gsort person_id -date_complete -nthRecAIC
by person_id: carryforward denvWrn_denvT, replace
sort person_id date_complete nthRecAIC
ta denvWrn_denvT, m
}
}
*
ta denvWrn_denvT, m

gen diffdenvWrn_denvT=.
sort person_id nthRecAIC Acute
bysort person_id Acute: replace diffdenvWrn_denvT=1 if denvWrn_denvT[_n]!=denvWrn_denvT[_n+1] & denvWrn_denvT[_n+1]!=. 
ta diffdenvWrn_denvT, m
drop diffdenvWrn_denvT	









********************************************************************************
*First fill for CHIKV
********************************************************************************

gen abp_chikvT=.
*First fill only when chikv_pcr_y===1
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace abp_chikvT=abp_aic if chikv_pcr_y==1 & nthRecAIC==`i' & abp_chikvT==. & Acute==`k'

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward abp_chikvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward abp_chikvT , replace
sort person_id date_complete nthRecAIC
ta abp_chikvT, m

}
}
*First fill only when chikv_pcr_y===0
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace abp_chikvT=abp_aic if chikv_pcr_y==0 & nthRecAIC==`i' & abp_chikvT==. & Acute==`k'

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward abp_chikvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward abp_chikvT , replace
sort person_id date_complete nthRecAIC
ta abp_chikvT, m

}
}
*
* now fill indepdent of chikv_pcr_y status
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace abp_chikvT=abp_aic if nthRecAIC==`i' & abp_chikvT==. & Acute==`k'

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward abp_chikvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward abp_chikvT , replace
sort person_id date_complete nthRecAIC
ta abp_chikvT, m
}
}
ta abp_chikvT chikv_pcr_y, m
*browse person_id date_complete nthRecAIC Acute Acute abp_aic abp_chikvT chikv_pcr_y if chikv_pcr_y==0 & abp_chikvT==.
*browse person_id date_complete nthRecAIC Acute Acute abp_aic abp_chikvT chikv_pcr_y 

*person_id CF0272 --> is the perfect person to check whether the code ran correctly
*person_id==MF0697	date_complete==11sep2015 --> was not assigned an "acute" status and therefore abp is empty

label define lbl_abp_chikvT 0 "no" 1 "yes"
label val abp_chikvT lbl_abp_chikvT
ta abp_chikvT, m

gen diffabp_chikvT=.
sort person_id nthRecAIC Acute
bysort person_id Acute: replace diffabp_chikvT=1 if abp_chikvT[_n]!=abp_chikvT[_n+1] & abp_chikvT[_n+1]!=. 
ta diffabp_chikvT, m
drop diffabp_chikvT	

********************************************************************************
**Chills

*Expanded and extracted from the relevant record
gen chills_chikvT=.
*First fill only when chikv_pcr_y===1
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace chills_chikvT=chills_aic if chikv_pcr_y==1 & nthRecAIC==`i' & chills_chikvT==. & Acute==`k'

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward chills_chikvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward chills_chikvT , replace
sort person_id date_complete nthRecAIC
ta chills_chikvT, m

}
}
*Fill only when chikv_pcr_y===0
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace chills_chikvT=chills_aic if chikv_pcr_y==0 & nthRecAIC==`i' & chills_chikvT==. & Acute==`k'

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward chills_chikvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward chills_chikvT , replace
sort person_id date_complete nthRecAIC
ta chills_chikvT, m

}
}
* now fill indepdent of chikv_pcr_y status
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace chills_chikvT=chills_aic if nthRecAIC==`i' & chills_chikvT==. & Acute==`k'

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward chills_chikvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward chills_chikvT , replace
sort person_id date_complete nthRecAIC
ta chills_chikvT, m
}
}
ta chills_chikvT chikv_pcr_y, m
*browse person_id date_complete nthRecAIC Acute Acute chills_aic chills_chikvT chikv_pcr_y if chikv_pcr_y==0 & chills_chikvT==.
*browse person_id date_complete nthRecAIC Acute Acute chills_aic chills_chikvT chikv_pcr_y 

label define lbl_chills_chikvT 0 "no" 1 "yes"
label val chills_chikvT lbl_chills_chikvT
ta chills_chikvT, m

gen diffchills_chikvT=.
sort person_id nthRecAIC Acute
bysort person_id Acute: replace diffchills_chikvT=1 if chills_chikvT[_n]!=chills_chikvT[_n+1] & chills_chikvT[_n+1]!=. 
ta diffchills_chikvT, m
drop diffchills_chikvT	


********************************************************************************
**Diarrhea

*Expanded and extracted from the relevant record
gen diarrhea_chikvT=.
*First fill only when chikv_pcr_y===1
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace diarrhea_chikvT=diarrhea_aic if chikv_pcr_y==1 & nthRecAIC==`i' & diarrhea_chikvT==. & Acute==`k'

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward diarrhea_chikvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward diarrhea_chikvT , replace
sort person_id date_complete nthRecAIC
ta diarrhea_chikvT diarrhea_aic, m

}
}
*First fill only when chikv_pcr_y===0
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace diarrhea_chikvT=diarrhea_aic if chikv_pcr_y==0 & nthRecAIC==`i' & diarrhea_chikvT==. & Acute==`k'

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward diarrhea_chikvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward diarrhea_chikvT , replace
sort person_id date_complete nthRecAIC
ta diarrhea_chikvT diarrhea_aic, m

}
}
* now fill indepdent of chikv_pcr_y status
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace diarrhea_chikvT=diarrhea_aic if nthRecAIC==`i' & diarrhea_chikvT==. & Acute==`k'

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward diarrhea_chikvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward diarrhea_chikvT , replace
sort person_id date_complete nthRecAIC
ta diarrhea_chikvT, m
}
}
ta diarrhea_chikvT chikv_pcr_y, m
*browse person_id date_complete nthRecAIC Acute Acute diarrhea_aic diarrhea_chikvT chikv_pcr_y if chikv_pcr_y==0 & diarrhea_chikvT==.
*browse person_id date_complete nthRecAIC Acute Acute diarrhea_aic diarrhea_chikvT chikv_pcr_y 

label define lbl_diarrhea_chikvT 0 "no" 1 "yes"
label val diarrhea_chikvT lbl_diarrhea_chikvT
ta diarrhea_chikvT, m

gen diffdiarrhea_chikvT=.
sort person_id nthRecAIC Acute
bysort person_id Acute: replace diffdiarrhea_chikvT=1 if diarrhea_chikvT[_n]!=diarrhea_chikvT[_n+1] & diarrhea_chikvT[_n+1]!=. 
ta diffdiarrhea_chikvT, m
drop diffdiarrhea_chikvT	

********************************************************************************
**Rash
*Expanded and extracted from the relevant record
gen rash_chikvT=.
*First fill only when chikv_pcr_y===1
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace rash_chikvT=rash_aic if chikv_pcr_y==1 & nthRecAIC==`i' & rash_chikvT==. & Acute==`k'

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward rash_chikvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward rash_chikvT , replace
sort person_id date_complete nthRecAIC
ta rash_chikvT rash_aic, m

}
}
*Fill only when chikv_pcr_y===0
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace rash_chikvT=rash_aic if chikv_pcr_y==0 & nthRecAIC==`i' & rash_chikvT==. & Acute==`k'

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward rash_chikvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward rash_chikvT , replace
sort person_id date_complete nthRecAIC
ta rash_chikvT rash_aic, m
}
}
* now fill indepdent of chikv_pcr_y status
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace rash_chikvT=rash_aic if nthRecAIC==`i' & rash_chikvT==. & Acute==`k'

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward rash_chikvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward rash_chikvT , replace
sort person_id date_complete nthRecAIC
ta rash_chikvT, m
}
}
ta rash_chikvT chikv_pcr_y, m
*browse person_id date_complete nthRecAIC Acute Acute rash_aic rash_chikvT chikv_pcr_y if chikv_pcr_y==0 & rash_chikvT==.
*browse person_id date_complete nthRecAIC Acute Acute rash_aic rash_chikvT chikv_pcr_y 

label define lbl_rash_chikvT 0 "no" 1 "yes"
label val rash_chikvT lbl_rash_chikvT
ta rash_chikvT, m

gen diffrash_chikvT=.
sort person_id nthRecAIC Acute
bysort person_id Acute: replace diffrash_chikvT=1 if rash_chikvT[_n]!=rash_chikvT[_n+1] & rash_chikvT[_n+1]!=. 
ta diffrash_chikvT, m
drop diffrash_chikvT	

********************************************************************************
**Bleeding
*Expanded and extracted from the relevant record
gen bleeding_chikvT=.
*First fill only when chikv_pcr_y===1
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace bleeding_chikvT=bleeding_aic if chikv_pcr_y==1 & nthRecAIC==`i' & bleeding_chikvT==. & Acute==`k'

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward bleeding_chikvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward bleeding_chikvT , replace
sort person_id date_complete nthRecAIC
ta bleeding_chikvT bleeding_aic, m
}
}
*Fill only when chikv_pcr_y===0
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace bleeding_chikvT=bleeding_aic if chikv_pcr_y==0 & nthRecAIC==`i' & bleeding_chikvT==. & Acute==`k'

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward bleeding_chikvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward bleeding_chikvT , replace
sort person_id date_complete nthRecAIC
ta bleeding_chikvT bleeding_aic, m
}
}
* now fill indepdent of chikv_pcr_y status
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace bleeding_chikvT=bleeding_aic if nthRecAIC==`i' & bleeding_chikvT==. & Acute==`k'

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward bleeding_chikvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward bleeding_chikvT , replace
sort person_id date_complete nthRecAIC
ta bleeding_chikvT, m
}
}
ta bleeding_chikvT chikv_pcr_y, m
*browse person_id date_complete nthRecAIC Acute Acute bleeding_aic bleeding_chikvT chikv_pcr_y if chikv_pcr_y==0 & bleeding_chikvT==.
*browse person_id date_complete nthRecAIC Acute Acute bleeding_aic bleeding_chikvT chikv_pcr_y 

label define lbl_bleeding_chikvT 0 "no" 1 "yes"
label val bleeding_chikvT lbl_bleeding_chikvT
ta bleeding_chikvT, m

gen diffbleeding_chikvT=.
sort person_id nthRecAIC Acute
bysort person_id Acute: replace diffbleeding_chikvT=1 if bleeding_chikvT[_n]!=bleeding_chikvT[_n+1] & bleeding_chikvT[_n+1]!=. 
ta diffbleeding_chikvT, m
drop diffbleeding_chikvT	

********************************************************************************
**Body Ache
*Expanded and extracted from the relevant record
gen body_ache_chikvT=.
*First fill only when chikv_pcr_y===1
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace body_ache_chikvT=body_ache_aic if chikv_pcr_y==1 & nthRecAIC==`i' & body_ache_chikvT==. & Acute==`k'

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward body_ache_chikvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward body_ache_chikvT , replace
sort person_id date_complete nthRecAIC
ta body_ache_chikvT body_ache_aic, m

}
}
*Fill only when chikv_pcr_y===1
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace body_ache_chikvT=body_ache_aic if chikv_pcr_y==0 & nthRecAIC==`i' & body_ache_chikvT==. & Acute==`k'

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward body_ache_chikvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward body_ache_chikvT , replace
sort person_id date_complete nthRecAIC
ta body_ache_chikvT body_ache_aic, m

}
}
* now fill indepdent of chikv_pcr_y status
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace body_ache_chikvT=body_ache_aic if nthRecAIC==`i' & body_ache_chikvT==. & Acute==`k'

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward body_ache_chikvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward body_ache_chikvT , replace
sort person_id date_complete nthRecAIC
ta body_ache_chikvT, m
}
}
ta body_ache_chikvT chikv_pcr_y, m
*browse person_id date_complete nthRecAIC Acute Acute body_ache_aic body_ache_chikvT chikv_pcr_y if chikv_pcr_y==0 & body_ache_chikvT==.
*browse person_id date_complete nthRecAIC Acute Acute body_ache_aic body_ache_chikvT chikv_pcr_y 

label define lbl_body_ache_chikvT 0 "no" 1 "yes"
label val body_ache_chikvT lbl_body_ache_chikvT
ta body_ache_chikvT, m

gen diffbody_ache_chikvT=.
sort person_id nthRecAIC Acute
bysort person_id Acute: replace diffbody_ache_chikvT=1 if body_ache_chikvT[_n]!=body_ache_chikvT[_n+1] & body_ache_chikvT[_n+1]!=. 
ta diffbody_ache_chikvT, m
drop diffbody_ache_chikvT	

********************************************************************************
**Nausea

*Expanded and extracted from the relevant record
gen nausea_chikvT=.
*First fill only when chikv_pcr_y===1
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace nausea_chikvT=nausea_aic if chikv_pcr_y==1 & nthRecAIC==`i' & nausea_chikvT==. & Acute==`k'

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward nausea_chikvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward nausea_chikvT , replace
sort person_id date_complete nthRecAIC
ta nausea_chikvT nausea_aic, m

}
}
*Fill only when chikv_pcr_y===1
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace nausea_chikvT=nausea_aic if chikv_pcr_y==0 & nthRecAIC==`i' & nausea_chikvT==. & Acute==`k'

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward nausea_chikvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward nausea_chikvT , replace
sort person_id date_complete nthRecAIC
ta nausea_chikvT nausea_aic, m

}
}
* now fill indepdent of chikv_pcr_y status
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace nausea_chikvT=nausea_aic if nthRecAIC==`i' & nausea_chikvT==. & Acute==`k'

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward nausea_chikvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward nausea_chikvT , replace
sort person_id date_complete nthRecAIC
ta nausea_chikvT, m
}
}
ta nausea_chikvT chikv_pcr_y, m
*browse person_id date_complete nthRecAIC Acute Acute nausea_aic nausea_chikvT chikv_pcr_y if chikv_pcr_y==0 & nausea_chikvT==.
*browse person_id date_complete nthRecAIC Acute Acute nausea_aic nausea_chikvT chikv_pcr_y 

label define lbl_nausea_chikvT 0 "no" 1 "yes"
label val nausea_chikvT lbl_nausea_chikvT
ta nausea_chikvT, m

gen diffnausea_chikvT=.
sort person_id nthRecAIC Acute
bysort person_id Acute: replace diffnausea_chikvT=1 if nausea_chikvT[_n]!=nausea_chikvT[_n+1] & nausea_chikvT[_n+1]!=. 
ta diffnausea_chikvT, m
drop diffnausea_chikvT	

********************************************************************************
**Vomit

*Expanded and extracted from the relevant record
gen vomit_chikvT=.
*First fill only when chikv_pcr_y===1
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace vomit_chikvT=vomit_aic if chikv_pcr_y==1 & nthRecAIC==`i' & vomit_chikvT==. & Acute==`k'

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward vomit_chikvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward vomit_chikvT , replace
sort person_id date_complete nthRecAIC
ta vomit_chikvT vomit_aic, m
}
}
*First fill only when chikv_pcr_y===0
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace vomit_chikvT=vomit_aic if chikv_pcr_y==0 & nthRecAIC==`i' & vomit_chikvT==. & Acute==`k'

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward vomit_chikvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward vomit_chikvT , replace
sort person_id date_complete nthRecAIC
ta vomit_chikvT vomit_aic, m
}
}
* now fill indepdent of chikv_pcr_y status
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace vomit_chikvT=vomit_aic if nthRecAIC==`i' & vomit_chikvT==. & Acute==`k'

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward vomit_chikvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward vomit_chikvT , replace
sort person_id date_complete nthRecAIC
ta vomit_chikvT, m
}
}
ta vomit_chikvT chikv_pcr_y, m
*browse person_id date_complete nthRecAIC Acute Acute vomit_aic vomit_chikvT chikv_pcr_y if chikv_pcr_y==0 & vomit_chikvT==.
*browse person_id date_complete nthRecAIC Acute Acute vomit_aic vomit_chikvT chikv_pcr_y 

label define lbl_vomit_chikvT 0 "no" 1 "yes"
label val vomit_chikvT lbl_vomit_chikvT
ta vomit_chikvT, m

gen diffvomit_chikvT=.
sort person_id nthRecAIC Acute
bysort person_id Acute: replace diffvomit_chikvT=1 if vomit_chikvT[_n]!=vomit_chikvT[_n+1] & vomit_chikvT[_n+1]!=. 
ta diffvomit_chikvT, m
drop diffvomit_chikvT	

********************************************************************************
**Impaired mental status

*Expanded and extracted from the relevant record
gen impMentalStatus_chikvT=.
*First fill only when chikv_pcr_y===1
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace impMentalStatus_chikvT=impMentalStatus_aic if chikv_pcr_y==1 & nthRecAIC==`i' & impMentalStatus_chikvT==. & Acute==`k'

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward impMentalStatus_chikvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward impMentalStatus_chikvT , replace
sort person_id date_complete nthRecAIC
ta impMentalStatus_chikvT impMentalStatus_aic, m
}
}
*First fill only when chikv_pcr_y===0
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace impMentalStatus_chikvT=impMentalStatus_aic if chikv_pcr_y==0 & nthRecAIC==`i' & impMentalStatus_chikvT==. & Acute==`k'

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward impMentalStatus_chikvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward impMentalStatus_chikvT , replace
sort person_id date_complete nthRecAIC
ta impMentalStatus_chikvT impMentalStatus_aic, m
}
}
* now fill indepdent of chikv_pcr_y status
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace impMentalStatus_chikvT=impMentalStatus_aic if nthRecAIC==`i' & impMentalStatus_chikvT==. & Acute==`k'

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward impMentalStatus_chikvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward impMentalStatus_chikvT , replace
sort person_id date_complete nthRecAIC
ta impMentalStatus_chikvT, m
}
}
ta impMentalStatus_chikvT chikv_pcr_y, m
*browse person_id date_complete nthRecAIC Acute Acute impMentalStatus_aic impMentalStatus_chikvT chikv_pcr_y if chikv_pcr_y==0 & impMentalStatus_chikvT==.
*browse person_id date_complete nthRecAIC Acute Acute impMentalStatus_aic impMentalStatus_chikvT chikv_pcr_y 

label define lbl_impMentalStatus_chikvT 0 "no" 1 "yes"
label val impMentalStatus_chikvT lbl_impMentalStatus_chikvT
ta impMentalStatus_chikvT, m

gen diffimpMentalStatus_chikvT=.
sort person_id nthRecAIC Acute
bysort person_id Acute: replace diffimpMentalStatus_chikvT=1 if impMentalStatus_chikvT[_n]!=impMentalStatus_chikvT[_n+1] & impMentalStatus_chikvT[_n+1]!=. 
ta diffimpMentalStatus_chikvT, m
drop diffimpMentalStatus_chikvT	

********************************************************************************
**Based on WHO guidelines:
** - probable_dengue
** - dengue_warning_signs

gen probDnv_chikvT=.
*First fill only when chikv_pcr_y===1
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace probDnv_chikvT=probDnv if chikv_pcr_y==1 & nthRecAIC==`i' & probDnv_chikvT==. & Acute==`k'
ta probDnv_chikvT probDnv, m

sort person_id date_complete nthRecAIC
by person_id: carryforward probDnv_chikvT, replace
gsort person_id -date_complete -nthRecAIC
by person_id: carryforward probDnv_chikvT, replace
sort person_id date_complete nthRecAIC
}
}
*First fill only when chikv_pcr_y===0
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace probDnv_chikvT=probDnv if chikv_pcr_y==0 & nthRecAIC==`i' & probDnv_chikvT==. & Acute==`k'
ta probDnv_chikvT probDnv, m

sort person_id date_complete nthRecAIC
by person_id: carryforward probDnv_chikvT, replace
gsort person_id -date_complete -nthRecAIC
by person_id: carryforward probDnv_chikvT, replace
sort person_id date_complete nthRecAIC

}
}
* now fill indepdent of chikv_pcr_y status
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace probDnv_chikvT=probDnv if nthRecAIC==`i' & probDnv_chikvT==.  & Acute==`k'
ta probDnv_chikvT probDnv, m

sort person_id date_complete nthRecAIC
by person_id: carryforward probDnv_chikvT, replace
gsort person_id -date_complete -nthRecAIC
by person_id: carryforward probDnv_chikvT, replace
sort person_id date_complete nthRecAIC
}
}
*
gen diffprobDnv_chikvT=.
sort person_id nthRecAIC Acute
bysort person_id Acute: replace diffprobDnv_chikvT=1 if probDnv_chikvT[_n]!=probDnv_chikvT[_n+1] & probDnv_chikvT[_n+1]!=. 
ta diffprobDnv_chikvT, m
drop diffprobDnv_chikvT	



********************************************************************************
**Dengue early warning symptoms based on chikv-pcr-status
********************************************************************************

gen denvWrn_chikvT=.
*First fill only when chikv_pcr_y===1
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace denvWrn_chikvT=denvWrn if chikv_pcr_y==1 & nthRecAIC==`i' & denvWrn_chikvT==.  & Acute==`k' 
ta denvWrn_chikvT denvWrn, m

sort person_id date_complete nthRecAIC
by person_id: carryforward denvWrn_chikvT, replace
gsort person_id -date_complete -nthRecAIC
by person_id: carryforward denvWrn_chikvT, replace
sort person_id date_complete nthRecAIC

}
}
ta denvWrn_chikvT chikv_pcr_y, m
*person_id RF0422 is a nice example to see that my codes works likes this :)

*******************************************************************************
*First fill only when chikv_pcr_y===0
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace denvWrn_chikvT=denvWrn if chikv_pcr_y==0 & nthRecAIC==`i' & denvWrn_chikvT==.  & Acute==`k' 
ta denvWrn_chikvT denvWrn, m

sort person_id date_complete nthRecAIC
by person_id: carryforward denvWrn_chikvT, replace
gsort person_id -date_complete -nthRecAIC
by person_id: carryforward denvWrn_chikvT, replace
sort person_id date_complete nthRecAIC

}
}
* now fill indepdent of chikv_pcr_y status
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace denvWrn_chikvT=denvWrn if nthRecAIC==`i' & denvWrn_chikvT==.  & Acute==`k' 
ta denvWrn_chikvT denvWrn, m

sort person_id date_complete nthRecAIC
by person_id: carryforward denvWrn_chikvT, replace
gsort person_id -date_complete -nthRecAIC
by person_id: carryforward denvWrn_chikvT, replace
sort person_id date_complete nthRecAIC
ta denvWrn_chikvT, m
}
}
*
gen diffdenvWrn_chikvT=.
sort person_id nthRecAIC Acute
bysort person_id Acute: replace diffdenvWrn_chikvT=1 if denvWrn_chikvT[_n]!=denvWrn_chikvT[_n+1] & denvWrn_chikvT[_n+1]!=. 
ta diffdenvWrn_chikvT, m
drop diffdenvWrn_chikvT	































********************************************************************************
*Child traveled
********************************************************************************

ta child_travel, m //Has the child traveled more than 10km away from home in the last 6 months?
replace child_travel="" if child_travel=="NA"
replace child_travel="" if child_travel=="8"
destring child_travel, replace
des child_travel
ta child_travel, m
*1 Yes
*0 No
*8 Refused
ta stay_overnight_aic, m //Did the child spend at least one night in the travel destination?
*1 Yes
*0 No
*8 Refused

ta child_travel stay_overnight_aic, m //ignore the person that reports one overnight but no travelling

gen child_travel2=.
replace child_travel2=0 if child_travel==0
replace child_travel2=0 if child_travel==1 & stay_overnight_aic!="1" //categorize as zero if did not stay overnight
replace child_travel2=1 if child_travel==1 & stay_overnight_aic=="1"
bysort stay_overnight_aic: ta child_travel2 child_travel, m
*Only include if he/she stayed one night?
*12/12/2018--> travelling by itself might be a risk factor, does not need to stay overnight, change code

*This variables can change over time, so also use the variable of which the answer that corresponds to the positive visit

*Expanded and extracted from the relevant record
*Notice that a participant can be positive for denv and chikv during different visits
*so have to make this variable separate for denv or chikv

gen childTrave_denvT=.
*First fill only when denv_pcr_y===1
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace childTrave_denvT=child_travel if denv_pcr_y==1 & nthRecAIC==`i' & childTrave_denvT==. & Acute==`k'
ta childTrave_denvT child_travel, m

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward childTrave_denvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward childTrave_denvT , replace
sort person_id date_complete nthRecAIC
}
}
*First fill only when denv_pcr_y===0
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace childTrave_denvT=child_travel if denv_pcr_y==0 & nthRecAIC==`i' & childTrave_denvT==. & Acute==`k'
ta childTrave_denvT child_travel, m

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward childTrave_denvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward childTrave_denvT , replace
sort person_id date_complete nthRecAIC
}
}
* now fill indepdent of denv_pcr_y status
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace childTrave_denvT=child_travel if nthRecAIC==`i' & childTrave_denvT==. & Acute==`k'
ta childTrave_denvT child_travel, m

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward childTrave_denvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward childTrave_denvT , replace
sort person_id date_complete nthRecAIC
}
}
ta childTrave_denvT denv_pcr_y, m
*browse person_id date_complete nthRecAIC Acute Acute child_travel2 childTrave_denvT denv_pcr_y if denv_pcr_y==0 & childTrave_denvT==.
*browse person_id date_complete nthRecAIC Acute Acute child_travel2 childTrave_denvT denv_pcr_y 

label define lbl_childTrave_denvT 0 "no" 1 "yes"
label val childTrave_denvT lbl_childTrave_denvT
ta childTrave_denvT, m

gen diffchildTrave_denvT=.
sort person_id nthRecAIC
bysort person_id Acute: replace diffchildTrave_denvT=1 if childTrave_denvT[_n]!=childTrave_denvT[_n+1] & childTrave_denvT[_n+1]!=. 
ta diffchildTrave_denvT, m
drop diffchildTrave_denvT	


gen childTrave_chikvT=.
*First fill only when chikv_pcr_y===1
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace childTrave_chikvT=child_travel if chikv_pcr_y==1 & nthRecAIC==`i' & childTrave_chikvT==. & Acute==`k'
ta childTrave_chikvT child_travel, m

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward childTrave_chikvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward childTrave_chikvT , replace
sort person_id date_complete nthRecAIC
}
}
*Fill only when chikv_pcr_y===0
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace childTrave_chikvT=child_travel if chikv_pcr_y==0 & nthRecAIC==`i' & childTrave_chikvT==. & Acute==`k'
ta childTrave_chikvT child_travel, m

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward childTrave_chikvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward childTrave_chikvT , replace
sort person_id date_complete nthRecAIC

}
}
* now fill indepdent of denv_pcr_y status
forval k=1/4{
forval i=1/8 {
sort person_id Acute date_complete nthRecAIC 
replace childTrave_chikvT=child_travel if nthRecAIC==`i' & childTrave_chikvT==. & Acute==`k'
ta childTrave_chikvT child_travel, m

sort person_id Acute date_complete nthRecAIC 
bysort person_id Acute: carryforward childTrave_chikvT , replace
gsort person_id Acute -date_complete -nthRecAIC 
bysort person_id Acute: carryforward childTrave_chikvT , replace
sort person_id date_complete nthRecAIC

}
}
ta childTrave_chikvT denv_pcr_y, m
*browse person_id date_complete nthRecAIC Acute Acute childTravel child_travel2 childTrave_chikvT denv_pcr_y if denv_pcr_y==0 & childTrave_chikvT==.
*browse person_id date_complete nthRecAIC Acute Acute childTravel child_travel2 childTrave_chikvT denv_pcr_y 

label define lbl_childTrave_chikvT 0 "no" 1 "yes"
label val childTrave_chikvT lbl_childTrave_chikvT
ta childTrave_chikvT, m

gen diffchildTrave_chikvT=.
sort person_id nthRecAIC
bysort person_id Acute: replace diffchildTrave_chikvT=1 if childTrave_chikvT[_n]!=childTrave_chikvT[_n+1] & childTrave_chikvT[_n+1]!=. 
ta diffchildTrave_chikvT, m
drop diffchildTrave_chikvT

save "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\Temporary2.dta", replace

*******************************************************************************
**Keep only the records with the interesting information
********************************************************************************

gen keep=0
replace keep=1 if nthRecAIC==1
replace keep=1 if nthRecAIC==tempfirstFilled
replace keep=1 if nthRecAIC==tempfirstFilled_Act3
replace keep=1 if nthRecAIC==tempfirstFilled_Act4
ta keep, m
*browse person_id date_comple nthRecAIC tempfirstFilled tempfirstFilled_Act3 tempfirstFilled_Act4 keep

keep if keep==1
ta keep , m
ta Acute, m

drop abp_aic chills_aic diarrhea_aic rash_aic bleeding_aic body_ache_aic ///
nausea_aic vomit_aic impMentalStatus_aic denvWrn  probDnv 

numlabel, add
save "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_AIC_step3.dta", replace

*******************************************************************************
*Destring person_id for analyses purpose for gee analyses
*******************************************************************************
gen person_id2_numbers = regexs(0) if(regexm(person_id, "[0-9][0-9][0-9][0-9]$"))
gen person_id2_letters = regexs(0) if(regexm(person_id, "[A-Z][A-Z]"))

gen person_id2_lettersNr=""
replace person_id2_lettersNr="99" if person_id2_letters=="CF"
replace person_id2_lettersNr="98" if person_id2_letters=="KF"
replace person_id2_lettersNr="97" if person_id2_letters=="MF"
replace person_id2_lettersNr="96" if person_id2_letters=="RF"
replace person_id2_lettersNr="95" if person_id2_letters=="UF"
ta person_id2_lettersNr person_id2_letters, m

gen person_id2=person_id2_lettersNr+person_id2_numbers
destring person_id2, replace 

browse person_id person_id2 person_id2_numbers person_id2_letters person_id2_lettersNr

*check whether the new id's that I generated are identical
sort person_id nthRecAIC 
bysort person_id: gen tempNth=_n
sort person_id2 nthRecAIC
bysort person_id2: gen tempNth2=_n
gen diff=1 if tempNth!=tempNth2
ta diff, m
ta tempNth tempNth2, m
drop person_id2_numbers person_id2_letters person_id2_lettersNr diff tempNth tempNth2

xtset person_id2
*note unblanced outcome

numlabel, add
save "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_AIC_step3_gee.dta", replace
clear
