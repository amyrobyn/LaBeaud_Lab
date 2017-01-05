/**************************************************************
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



I see a pretty map in your future�.:)

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

 
cd "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\CSVs nov29_16"
use elisas.dta, clear
use sammy, clear


drop if dup_visit >1

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



		keep studyid  id_wide site visit antigenused_ city Stanford_CHIKV_IGG cohort gender datesamplecollected_ dob  agemonths childage age gender  Stanford_CHIK~G Stanford_DENV~G visit datesamplecol~_ 

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

save denvchikvmalariagps
outsheet using "denvchikvmalariagps.csv", comma names replace