/**************************************************************
 *amy krystosik                  							  *
 *R01 results and discrepencies by strata (lab, antigen, test)*
 *lebeaud lab               				        		  *
 *last updated September 15, 2016  							  *
 **************************************************************/
 /*to do
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

capture log close 
set scrollbufsize 100000
set more 1

log using "malaria prelim data.smcl", text replace 
set scrollbufsize 100000
set more 1

cd "C:\Users\amykr\Google Drive\labeaud\malaria prelim data dec 29 2016"
insheet using "AIC Ukunda malaria data April 2016.csv", comma name clear
ds, has(type string) 
foreach v of varlist `r(varlist)' { 
	replace `v' = lower(`v') 
}
dropmiss, force
save Ukunda, replace

insheet using "AICA Msambweni Malaria Data2016.csv", comma name clear
ds, has(type string) 
foreach v of varlist `r(varlist)' { 
	replace `v' = lower(`v') 
}
dropmiss, force
destring studyid2 countul2, replace force
save Msambweni, replace

insheet using "Malaria Parasitemia Data.csv", comma name clear
ds, has(type string) 
foreach v of varlist `r(varlist)' { 
	replace `v' = lower(`v') 
}
dropmiss, force
save Parasitemia, replace

insheet using "West HCC_Malaria Parasitemia Data_07oct2016.csv", comma name clear
ds, has(type string) 
foreach v of varlist `r(varlist)' { 
	replace `v' = lower(`v') 
}
dropmiss, force
save west, replace

append using "Parasitemia" "Ukunda" "Msambweni"

encode gender, gen(sex)
drop gender
rename sex gender
rename studyid2 childid


*take visit out of id
replace clientno = subinstr(clientno," ","",1) 
replace studyid = studyid1 if studyid =="" & studyid1 !=""
replace studyid =  clientno if studyid =="" & clientno !=""

 
						forval i = 1/3 { 
							gen id`i' = substr(studyid, `i', 1) 
						}
*gen id_wid without visit						 
	rename id1 city  
	rename id2 id_cohort 
	rename id3 visit
	tab visit
	
	gen id_childnumber = ""
	replace id_childnumber= substr(studyid, +4, .)
	order id_cohort city visit id_childnumber studyid
	egen id_wide = concat(city id_cohort id_childnumber)

	gen visit_int = . 
	replace visit_int = 1 if visit =="a"
	replace visit_int = 2 if visit =="b"
	replace visit_int = 3 if visit =="c"
	replace visit_int = 4 if visit =="d"
	replace visit_int = 5 if visit =="e"
	replace visit_int = 6 if visit =="f"
	replace visit_int = 7 if visit =="g"

	bysort id_wide visit_int: gen dup = _n
	drop if dup >1
isid id_wide visit_int
drop visit 
rename visit_int visit
	save malaria, replace

use "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\CSVs nov29_16\output\prevalent.dta", clear
keep studyid* Stanford* malaria* *malaria* rdt* site city id_wide visit
rename visit visit_int
isid id_wide visit_int
merge 1:1 id_wide visit_int using malaria
save malariadenguemerged, replace

*create village id
*take visit out of id
						forval i = 1/3 { 
							gen id`i' = substr(studyid, `i', 1) 
						}
*gen id_wid without visit						 
	rename id1 city  
	rename id2 id_cohort  
	rename id3 id_visit 
	tab id_visit 
	
	gen id_childnumber = ""
	replace id_childnumber = substr(studyid, +4, .)
	order id_cohort city id_visit id_childnumber studyid
	egen id_wide = concat(city id_cohort id_childnum)
	
gen villageid=""
replace villageid = substr(id_wide, +1, 1)
replace villageid = "3" if villageid =="g"
replace villageid = "4" if villageid =="l"
destring villageid, replace


gen houseid = ""
replace houseid = substr(studyid, +4, 4)

order studyid houseid villageid
drop _merge
save malariadenguemerged, replace

*****************merge with gis points

import excel "C:\Users\amykr\Box Sync/DENV CHIKV project/Coast Cleaned/Demography/Demography Latest/Msambweni_coordinates complete Nov 21 2016.xls", sheet("Sheet1") firstrow clear
gen houseid  = string(House,"%04.0f")
rename Village villageid
order houseid villageid
drop if villageid ==.
bysort houseid villageid: gen dup =_n
egen duphouse = concat(houseid dup) if dup>1
replace houseid = duphouse if dup>1
tostring villageid, replace
merge 1:m villageid houseid using malariadenguemerged
********************

*extract year from dob
gen dobyear = "."
replace dobyear = substr(dob, -4,.)
destring dobyear, replace
drop if dobyear <1990


*extract year from today
gen examyear = "."
replace examyear = substr(today, -4,.)
destring examyear , replace

gen exammonth = "."
replace exammonth = substr(today, 1,1)
replace exammonth = "4" if exammonth =="a"
replace exammonth = "5" if exammonth =="m"
destring exammonth, replace

gen examdate= mdy(exammonth, 1, examyear)
format examdate %td

encode spp1, gen(species)

foreach var in examdate dobyear{
sum `var' pos_neg if pos_neg=="pos"
sum `var' pos_neg1 if pos_neg=="pos"
}

foreach var in gender hospitalsite examdate dobyear species{ 
tab `var' pos_neg if pos_neg=="pos"
}

/*
Gender	Freq.	Percent	Cum.
			
f	679	52.07	52.07
m	625	47.93	100.00
			
Total	1,304	100.00

Variable	Obs	Mean	Std. Dev.	Min	Max
dobyear	377	2010.499	3.062405	1997	2014*/

	
	bysort  id_wide2: gen repeatoffender = _n if malariabloodsmear =="1"
sum repeatoffender if repeatoffender >1
*91 repeatoffender 


foreach var in examdate dobyear{
sum `var' pos_neg if pos_neg=="pos" & repeatoffender >1
sum `var' pos_neg1 if pos_neg=="pos" & repeatoffender >1
}

foreach var in gender hospitalsite examdate dobyear species city{ 
tab `var' pos_neg if pos_neg=="pos" & repeatoffender >1
}

tab repeatoffender malariabloodsmear

order malaria*
destring malariabloodsmear  malariapastmedhist, replace
encode pos_neg, gen(malariapos)
encode pos_neg1, gen(malariapos2)
replace malariapos = malariapos-1
replace malariapos2=malariapos2-1
drop pos_neg*

bysort city: sum malaria* Stanford*

export excel using "malaria prelim_raw", firstrow(variables) replace
