*R01_Kenya_tables_figures_vs1

********************************************************************************
**Numbers extracted for tables and figures
********************************************************************************



********************************************************************************
** AIC - DENV prevalence figure
********************************************************************************
clear
use "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_AIC_step3.dta"

ta yr, m
drop if yr==.
ta yr, m

collapse (mean) denv_pos_aic_bar = denv_pos_aic (semean) se = denv_pos_aic , by (yr)

generate lb = denv_pos_aic_bar - 1.96*se 
generate ub = denv_pos_aic_bar + 1.96*se  

twoway (bar denv_pos_aic_bar yr, barw(0.6)) || ///
	   (rcap lb ub yr)  ///
, ytitle(DENV prevalence (%))  xtitle(Year) title(AIC - DENV) ///
ytick(0(0.1)0.4) ylabel(0 .1 "10" .2 "20" .3 "30" .4 "40") ///
xsize(6) scheme(s2mono) graphregion(color(white)) ///
plotregion(lcolor(black)) legend(off) 


********************************************************************************
** AIC - CHIKV prevalence figure
********************************************************************************
clear
use "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_AIC_step3.dta"

ta yr, m
drop if yr==.
ta yr, m

collapse (mean) chikv_pos_aic_bar = chikv_pos_aic (semean) se = denv_pos_aic , by (yr)

generate lb = chikv_pos_aic_bar - 1.96*se 
generate ub = chikv_pos_aic_bar + 1.96*se  

twoway (bar chikv_pos_aic_bar yr, barw(0.6)) || ///
	   (rcap lb ub yr)  ///
, ytitle(CHIKV prevalence (%)) xtitle(Year) title(AIC - CHIKV) ///
ytick(0(0.1)0.4) ylabel(0 .1 "10" .2 "20" .3 "30" .4 "40") ///
xsize(6) scheme(s2mono) graphregion(color(white)) ///
plotregion(lcolor(black)) legend(off) 


********************************************************************************
** AIC - Descriptives
********************************************************************************
clear
use "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_AIC_step3.dta"

*browse person_id redcap_event_name gender_aic gender_hcc dem_child_gender gender2 date_complete if gender2==.
*browse person_id redcap_event_name date_of_birth_aic  age  date_complete if age==.

cd "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Tabout"

*Flow diagram
ta Acute, m
ta Acute yr, m


ta FlwVisAct1
di 6856-2754

ta FlwVisAct2
di 513-259

ta FlwVisAct3
di 62-29

ta FlwVisAct4

*Flow diagram by site
ta Acute siteID, m

ta FlwVisAct1 if siteID==1
di 1479-768
ta FlwVisAct2 if siteID==1
di 29-18
ta FlwVisAct3 if siteID==1
ta FlwVisAct4 if siteID==1

ta FlwVisAct1 if siteID==2
di 853-334
ta FlwVisAct2 if siteID==2
di 118-57
ta FlwVisAct3 if siteID==2
ta FlwVisAct4 if siteID==2

ta FlwVisAct1 if siteID==3
di 2322-909
ta FlwVisAct2 if siteID==3
di 154-86
ta FlwVisAct3 if siteID==3
ta FlwVisAct4 if siteID==3

ta FlwVisAct1 if siteID==4
di 2202-743
ta FlwVisAct2 if siteID==4
di 212-98
ta FlwVisAct3 if siteID==4
di 23-9
ta FlwVisAct4 if siteID==4


*Descriptives by year
summarize ageyrs, detail
display r(p50) r(p25) r(p75)

summarize ageyrs if yr==2014, detail
display r(p50) r(p25) r(p75)
summarize ageyrs if yr==2015, detail
display r(p50) r(p25) r(p75)
summarize ageyrs if yr==2016, detail
display r(p50) r(p25) r(p75)
summarize ageyrs if yr==2017, detail
display r(p50) r(p25) r(p75)
summarize ageyrs if yr==2018, detail
display r(p50) r(p25) r(p75)
kwallis ageyrs , by (yr)

gen ses2=ses*5
replace ses2=int(ses2)

summarize ses2, detail
display r(p50) r(p25) r(p75)

summarize ses2 if yr==2014, detail
display r(p50) r(p25) r(p75)
summarize ses2 if yr==2015, detail
display r(p50) r(p25) r(p75)
summarize ses2 if yr==2016, detail
display r(p50) r(p25) r(p75)
summarize ses2 if yr==2017, detail
display r(p50) r(p25) r(p75)
summarize ses2 if yr==2018, detail
display r(p50) r(p25) r(p75)
kwallis ses2 , by (yr)

ta yr, m

tabout ageCat gender2 sesCat3 siteID yr using "DescriptivesByYear-AIC.xls", replace cells(freq col) stats(chi2) f(0c 0p)
gen one=1
tabout ageCat gender2 sesCat3 siteID yr one using "DescriptivesTot-AIC.xls", replace cells(freq col) stats(chi2) f(0c 0p)

misstable summ ageCat gender2 sesCat3 siteID yr

*Prevalence by year
ta  yr denv_pos_aic, row m
ta  yr chikv_pos_aic, row m
tabout denv_pos_aic chikv_pos_aic chikvDenv_pos_aic yr using "PrevalenceByYear-AIC.xls", replace cells(freq col) stats(chi2) f(0c 0p)
tabout denv_pos_aic chikv_pos_aic chikvDenv_pos_aic one using "PrevalenceTot-AIC.xls", replace cells(freq col) stats(chi2) f(0c 0p)
gen chikvDenv_pos_aic2=.
replace chikvDenv_pos_aic2=0 if chikvDenv_pos_aic==0 | chikvDenv_pos_aic==1
replace chikvDenv_pos_aic2=1 if chikvDenv_pos_aic==2
ta chikvDenv_pos_aic2 chikvDenv_pos_aic, m
bysort denv_pos_aic: ta chikv_pos_aic chikvDenv_pos_aic2, m
ta chikvDenv_pos_aic2 yr, col chi

misstable summ denv_pos_aic chikv_pos_aic chikvDenv_pos_aic yr

*Prevalence by year and by site
tabout denv_pos_aic chikv_pos_aic chikvDenv_pos_aic2 yr if siteID==1 using "PrevalenceByYearBySite-AIC-urbanWest.xls", replace cells(freq col) stats(chi2) f(0c 0p)
tabout denv_pos_aic chikv_pos_aic chikvDenv_pos_aic2 one if siteID==1 using "PrevalenceByYearBySite-AIC-urbanWes-Tot.xls", replace cells(freq col) stats(chi2) f(0c 0p)

ta chikv_pos_aic yr  if siteID==2, m
tabout denv_pos_aic chikv_pos_aic chikvDenv_pos_aic2 yr if siteID==2 using "PrevalenceByYearBySite-AIC-ruralWest.xls", replace cells(freq col) stats(chi2) f(0c 0p)
tabout denv_pos_aic chikv_pos_aic chikvDenv_pos_aic2 one if siteID==2 using "PrevalenceByYearBySite-AIC-ruralWest-Tot.xls", replace cells(freq col) stats(chi2) f(0c 0p)

tabout denv_pos_aic chikv_pos_aic chikvDenv_pos_aic2 yr if siteID==3 using "PrevalenceByYearBySite-AIC-urbanCoast.xls", replace cells(freq col) stats(chi2) f(0c 0p)
tabout denv_pos_aic chikv_pos_aic chikvDenv_pos_aic2 one if siteID==3 using "PrevalenceByYearBySite-AIC-urbanCoast-Tot.xls", replace cells(freq col) stats(chi2) f(0c 0p)

tabout denv_pos_aic chikv_pos_aic chikvDenv_pos_aic yr if siteID==4 using "PrevalenceByYearBySite-AIC-ruralCoast.xls", replace cells(freq col) stats(chi2) f(0c 0p)
tabout denv_pos_aic chikv_pos_aic chikvDenv_pos_aic one if siteID==4 using "PrevalenceByYearBySite-AIC-ruralCoast-Tot.xls", replace cells(freq col) stats(chi2) f(0c 0p)

*Prevalence by year and west versus coast
tabout denv_pos_aic chikv_pos_aic chikvDenv_pos_aic2 yr if siteID2==1 using "PrevalenceByYearBySite-AIC-TotWest.xls", replace cells(freq col) stats(chi2) f(0c 0p)
tabout denv_pos_aic chikv_pos_aic chikvDenv_pos_aic2 one if siteID2==1 using "PrevalenceByYearBySite-AIC-TotWest-Tot.xls", replace cells(freq col) stats(chi2) f(0c 0p)

tabout denv_pos_aic chikv_pos_aic chikvDenv_pos_aic yr if siteID2==2 using "PrevalenceByYearBySite-AIC-TotCoast.xls", replace cells(freq col) stats(chi2) f(0c 0p)
tabout denv_pos_aic chikv_pos_aic chikvDenv_pos_aic one if siteID2==2 using "PrevalenceByYearBySite-AIC-TotCoast-Tot.xls", replace cells(freq col) stats(chi2) f(0c 0p)

*CHIKV low level
ta mth chikv_pos_aic if yr==2014, row
ta mth chikv_pos_aic if yr==2015, row
ta mth chikv_pos_aic if yr==2016, row
ta mth chikv_pos_aic if yr==2017, row
ta mth chikv_pos_aic if yr==2018, row

*urban vs rural at the west
ta denv_pos_aic siteID if siteID2==1, col chi
ta chikv_pos_aic siteID if siteID2==1, col chi
ta chikvDenv_pos_aic2 siteID if siteID2==1, col chi

gen outbreak=0
replace outbreak=1 if yr==2017 & mth==11
replace outbreak=1 if yr==2017 & mth==12
replace outbreak=1 if yr==2017 & mth==13
replace outbreak=1 if yr==2018 & mth==1
replace outbreak=1 if yr==2018 & mth==2
replace outbreak=1 if yr==2018 & mth==3
replace outbreak=1 if yr==2018 & mth==4
ta outbreak mth if yr==2017, m
ta outbreak mth if yr==2018, m

ta chikv_pos_aic siteID if siteID2==1 & outbreak==0, col chi

*urban vs rural as the west
ta denv_pos_aic siteID if siteID2==1, col chi
ta chikv_pos_aic siteID if siteID2==1, col chi
ta chikvDenv_pos_aic2 siteID if siteID2==1, col chi

ta chikv_pos_aic siteID if siteID2==1 & outbreak==0, col chi

*urban vs rural as the coast
ta denv_pos_aic siteID if siteID2==2, col chi
ta chikv_pos_aic siteID if siteID2==2, col chi
ta chikvDenv_pos_aic2 siteID if siteID2==2, col chi

ta chikv_pos_aic siteID if siteID2==2 & outbreak==0, col chi

*west vs coast
ta denv_pos_aic siteID2  , col chi
ta chikv_pos_aic siteID2  , col chi
ta chikvDenv_pos_aic2 siteID2 , col chi

ta chikv_pos_aic siteID2 if outbreak==0, col chi

*Seropositivity/serconversion
ta denv_igg_y, m
ta chikv_igg_y, m

ta  Acute denv_igg_y, row
ta  Acute chikv_igg_y, row

ta Acute denv_sconv_aicT, row
ta Acute denv_sconv_aicT if denv_pcr_aicT==1, row
ta Acute chikv_sconv_aicT if chikv_pcr_aicT==1, row

*DENV by risk factors
summ ageyrs if denv_pos_aic!=., d
display r(p50) r(p25) r(p75)
tabout ageCat gender2 sesCat3 siteID siteID2 siteID3 /// demographics
roofTypeT3 floorTypeT3 numRoomsCat3 nrPlpHCat3 nrWndCat3 lghtSrT3 drnkWtSrT3 toiletTypeT3 /// house circumstances
outdoorActy_denvT3 childTrave_denvT msqtBites_denvT3 msqtCoil_denvT3 msqtNet_denvT3 feverCntct_denvT3 ///exposure and protective measures
nrAcuteT FlwVisAct //// severity
abp_denvT chills_denvT diarrhea_denvT rash_denvT bleeding_denvT /// symptoms
body_ache_denvT nausea_denvT vomit_denvT impMentalStatus_denvT /// symptoms
probDnv_denvT denvWrn_denvT ///WHO warning signs
denv_pos_aic ///
using "DENVByriskFactors-AIC.xls", replace cells(freq row) stats(chi2) f(0c 0p)

misstable summ ageCat gender2 sesCat3 siteID /// demographics
roofTypeT3 floorTypeT3 numRoomsCat3 nrPlpHCat3 nrWndCat3 lghtSrT3 drnkWtSrT3 toiletTypeT3 /// house circumstances
outdoorActy_denvT3 childTrave_denvT msqtBites_denvT3 msqtCoil_denvT3 msqtNet_denvT3 feverCntct_denvT3 ///exposure and protective measures
nrAcuteT FlwVisAct //// severity
abp_denvT chills_denvT diarrhea_denvT rash_denvT bleeding_denvT /// symptoms
body_ache_denvT nausea_denvT vomit_denvT impMentalStatus_denvT /// symptoms
probDnv_denvT denvWrn_denvT ///WHO warning signs
denv_pos_aic chikv_pos_aic if denv_pos_aic!=.

*CHIKV by risk factors
summ ageyrs if chikv_pos_aic!=., d
display r(p50) r(p25) r(p75)
tabout ageCat gender2 sesCat3 siteID siteID2 siteID3  /// demographics
roofTypeT3 floorTypeT3 numRoomsCat3 nrPlpHCat3 nrWndCat3 lghtSrT3 drnkWtSrT3 toiletTypeT3 /// house circumstances
outdoorActy_chikvT3 childTrave_chikvT msqtBites_chikvT3 msqtCoil_chikvT3 msqtNet_chikvT3 feverCntct_chikvT3 ///exposure and protective measures
nrAcuteT FlwVisAct //// severity
abp_chikvT chills_chikvT diarrhea_chikvT rash_chikvT bleeding_chikvT /// symptoms
body_ache_chikvT nausea_chikvT vomit_chikvT impMentalStatus_chikvT /// symptoms
probDnv_chikvT denvWrn_chikvT ///WHO warning signs
chikv_pos_aic ///
using "CHIKVByriskFactors-AIC.xls", replace cells(freq row) stats(chi2) f(0c 0p)

misstable summ ageCat gender2 sesCat3 siteID /// demographics
roofTypeT3 floorTypeT3 numRoomsCat3 nrPlpHCat3 nrWndCat3 lghtSrT3 drnkWtSrT3 toiletTypeT3 /// house circumstances
outdoorActy_denvT3 childTrave_denvT msqtBites_denvT3 msqtCoil_denvT3 msqtNet_denvT3 feverCntct_denvT3 ///exposure and protective measures
nrAcuteT FlwVisAct //// severity
abp_denvT chills_denvT diarrhea_denvT rash_denvT bleeding_denvT /// symptoms
body_ache_denvT nausea_denvT vomit_denvT impMentalStatus_denvT /// symptoms
probDnv_denvT denvWrn_denvT ///WHO warning signs
denv_pos_aic chikv_pos_aic if chikv_pos_aic!=.


*******************************************************************************
*AIC - DENV -risk factor analyses
*******************************************************************************

*******************************************************************************
*Compare standard logistic regression versus GEE - part I
*******************************************************************************

clear
use "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_AIC_step3.dta"
logistic denv_pos_aic i.sesCat

clear
use "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_AIC_step3_gee.dta"
xi: xtgee denv_pos_aic i.sesCat, family(binomial) corr(ind) eform  //independent correlation should give the same results as standard analyses
test _IsesCat_2 _IsesCat_3 _IsesCat_4

xi: xtgee denv_pos_aic i.sesCat, family(binomial) corr(exc) eform 
test _IsesCat_2 _IsesCat_3 _IsesCat_4

*GEE analyses is hardly different from standard logistic regression








*******************************************************************************
*AIC - DENV -risk factor analyses - part II
*******************************************************************************
clear
use "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_AIC_step3_gee.dta"

cd "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Tabout"

*Drop if DENV is missing
ta denv_pos_aic, m
drop if denv_pos_aic==.
ta denv_pos_aic, m

*Check
*sort person_id2 date_complete nthRecAIC
*bysort person_id2: gen nthRecGEE=_n 
*ta nthRecGEE Acute, m

*egen totRec2 = total(cohortID==1), by(person_id)
*ta totRec2, m
*ta totRec2 Acute, m

*sort person_id date_complete nthRecAIC
*browse person_id person_id2 date_complete Acute nthRecAIC nthRecGEE totRec2

*xi: xtgee denv_pos_aic i.ageCat, family(binomial) corr(exc) eform 
*gen esample=1 if e(sample)==1
*drop if esample!=1
*bysort person_id2: gen nien2=_n
*bysort nien2: ta denv_pos_aic ageCat
*bysort nthRecGEE: ta denv_pos_aic ageCat
*Groups do not match the size of individuals in 1st acute
*because of missing data

*******************************************************************************
**Make spline, Des want to use age as a continous variable
summ ageyrs, d
di r(p50) r(p25) r(p75)

mkspline ageSpl = ageyrs, cubic nknots(4) displayknots
mat knots = r(knots) 

xi: xtgee denv_pos_aic ageSpl1 ageSpl2 ageSpl3, family(binomial) corr(exc) eform 
test ageSpl2 ageSpl3 // as this is not significant in principle it is not necessary to use splines, however as it gives flexibility in the analyses I will keep if
test ageSpl1 ageSpl2 ageSpl3
test ageSpl1=ageSpl2=ageSpl3=0

xi: xtgee denv_pos_aic ageyrs, family(binomial) corr(exc) eform 
test ageyrs


********************************************************************************
*Age output for table
xi: xtgee denv_pos_aic ageSpl1 ageSpl2 ageSpl3, family(binomial) corr(exc) eform 
test ageSpl1 ageSpl2 ageSpl3
xbrcspline ageSpl, values(2 4 8 12) ref(4) eform matknots(knots)

est clear

foreach var of varlist ageCat gender2 sesCat3 siteID siteID2 siteID3  /// demographics
yr mth /// season
roofTypeT3 floorTypeT3 numRoomsCat3 nrPlpHCat3 nrWndCat3 lghtSrT3 drnkWtSrT3 toiletTypeT3 /// house circumstances
outdoorActy_denvT3 childTrave_denvT msqtBites_denvT3 msqtCoil_denvT3 msqtNet_denvT3 feverCntct_denvT3 ///exposure and protective measures
nrAcuteT FlwVisAct //// severity
abp_denvT chills_denvT diarrhea_denvT rash_denvT bleeding_denvT /// symptoms
body_ache_denvT nausea_denvT vomit_denvT impMentalStatus_denvT /// symptoms
probDnv_denvT denvWrn_denvT ///WHO warning signs
{
eststo: xi: xtgee denv_pos_aic i.`var', family(binomial) corr(exc) eform 
di e(p)
}
*

eststo DENV_BiAn_Tot: appendmodels est1 est2 est3 est4 est5 est6 est7 est8 est9 est10 ///  
est11 est12 est13 est14 est15 est16 est17 est18 est19 est20 ///  
est21 est22 est23 est24 est25 est26 est27 est28 est29 est30 ///  
est31 est32 est33 est34 est35

estout DENV_BiAn_Tot using "DENV_BiAn_Tot.xls",  ///
cells("b(fmt(%9.2fc)) ci(par((   -  ))) p(fmt(%9.8fc))") ///
mlabel("Poisson log") label ///
collabels("") varlabels(_cons Constant) varwidth(10) modelwidth(10) prefoot("") ///
postfoot("CI in parentheses") legend style(tab) eform replace 


*Extract p-values

xi: xtgee denv_pos_aic i.gender2, family(binomial) corr(exc) eform 
test _Igender2_1

xi: xtgee denv_pos_aic i.sesCat3, family(binomial) corr(exc) eform 
test _IsesCat3_2 _IsesCat3_3

xi: xtgee denv_pos_aic i.siteID, family(binomial) corr(exc) eform 
test  _IsiteID_2  _IsiteID_3  _IsiteID_4

xi: xtgee denv_pos_aic i.siteID2, family(binomial) corr(exc) eform 
test  _IsiteID2_2

xi: xtgee denv_pos_aic i.siteID3, family(binomial) corr(exc) eform 
test  _IsiteID3_2

xi: xtgee denv_pos_aic i.yr, family(binomial) corr(exc) eform 
test _Iyr_2015 _Iyr_2016 _Iyr_2017 _Iyr_2018

xi: xtgee denv_pos_aic i.mth, family(binomial) corr(exc) eform 
test _Imth_2 _Imth_3 _Imth_4 _Imth_5 _Imth_6 _Imth_7 _Imth_8 _Imth_9 _Imth_10 _Imth_11 _Imth_12

xi: xtgee denv_pos_aic i.roofTypeT3, family(binomial) corr(exc) eform 
test _IroofTypeT_2

xi: xtgee denv_pos_aic i.floorTypeT3, family(binomial) corr(exc) eform 
test _IfloorType_2

xi: xtgee denv_pos_aic i.numRoomsCat3, family(binomial) corr(exc) eform 
test _InumRoomsC_2 _InumRoomsC_3

xi: xtgee denv_pos_aic i.nrPlpHCat3, family(binomial) corr(exc) eform 
test _InrPlpHCat_2 _InrPlpHCat_3 _InrPlpHCat_4 _InrPlpHCat_5

xi: xtgee denv_pos_aic i.nrWndCat3, family(binomial) corr(exc) eform 
test _InrWndCat3_1 _InrWndCat3_2 _InrWndCat3_3

xi: xtgee denv_pos_aic i.lghtSrT3, family(binomial) corr(exc) eform 
test _IlghtSrT3_2 

xi: xtgee denv_pos_aic i.drnkWtSrT3, family(binomial) corr(exc) eform 
test _IdrnkWtSrT_2 _IdrnkWtSrT_3

xi: xtgee denv_pos_aic i.toiletTypeT3, family(binomial) corr(exc) eform 
test _ItoiletTyp_2 _ItoiletTyp_3

xi: xtgee denv_pos_aic i.outdoorActy_denvT3, family(binomial) corr(exc) eform 
test _IoutdoorAc_1

xi: xtgee denv_pos_aic i.childTrave_denvT, family(binomial) corr(exc) eform 
test _IchildTrav_1

xi: xtgee denv_pos_aic i.msqtBites_denvT3, family(binomial) corr(exc) eform 
test _ImsqtBites_1

xi: xtgee denv_pos_aic i.msqtCoil_denvT3, family(binomial) corr(exc) eform 
test _ImsqtCoil__1

xi: xtgee denv_pos_aic i.msqtNet_denvT3, family(binomial) corr(exc) eform 
test _ImsqtNet_d_1

xi: xtgee denv_pos_aic i.feverCntct_denvT3, family(binomial) corr(exc) eform 
test _IfeverCntc_1

xi: xtgee denv_pos_aic i.nrAcuteT, family(binomial) corr(exc) eform 
test _InrAcuteT_2 _InrAcuteT_3 _InrAcuteT_4

xi: xtgee denv_pos_aic i.FlwVisAct, family(binomial) corr(exc) eform 
test _IFlwVisAct_1 _IFlwVisAct_2 _IFlwVisAct_3

xi: xtgee denv_pos_aic i.abp_denvT, family(binomial) corr(exc) eform 
test _Iabp_denvT_1

xi: xtgee denv_pos_aic i.chills_denvT, family(binomial) corr(exc) eform 
test _Ichills_de_1

xi: xtgee denv_pos_aic i.diarrhea_denvT, family(binomial) corr(exc) eform 
test _Idiarrhea__1 

xi: xtgee denv_pos_aic i.rash_denvT, family(binomial) corr(exc) eform 
test _Irash_denv_1

xi: xtgee denv_pos_aic i.bleeding_denvT, family(binomial) corr(exc) eform 
test _Ibleeding__1

xi: xtgee denv_pos_aic i.body_ache_denvT, family(binomial) corr(exc) eform 
test _Ibody_ache_1

xi: xtgee denv_pos_aic i.nausea_denvT, family(binomial) corr(exc) eform 
test _Inausea_de_1

xi: xtgee denv_pos_aic i.vomit_denvT, family(binomial) corr(exc) eform 
test _Ivomit_den_1

xi: xtgee denv_pos_aic i.impMentalStatus_denvT, family(binomial) corr(exc) eform 
test _IimpMental_1

xi: xtgee denv_pos_aic i.probDnv_denvT, family(binomial) corr(exc) eform 
test  _IprobDnv_d_1 _IprobDnv_d_2 _IprobDnv_d_3 _IprobDnv_d_4

xi: xtgee denv_pos_aic i.denvWrn_denvT, family(binomial) corr(exc) eform 
test _IdenvWrn_d_1 _IdenvWrn_d_2 _IdenvWrn_d_3 _IdenvWrn_d_4

*Run mv analyses
xi: xtgee denv_pos_aic ageSpl1 ageSpl2 ageSpl3, family(binomial) corr(exc) eform 
test ageSpl1 ageSpl2 ageSpl3

est clear
xi: xtgee denv_pos_aic ageSpl1 ageSpl2 ageSpl3 i.siteID2 i.siteID3 i.roofTypeT3 i.lghtSrT3 i.drnkWtSrT3 ///
i.toiletTypeT3 i.outdoorActy_denvT3 i.msqtNet_denvT3 i.FlwVisAct ///
i.abp_denvT i.chills_denvT i.bleeding_denvT i.nausea_denvT i.impMentalStatus_denvT, family(binomial) corr(exc) eform 
test ageSpl1 ageSpl2 ageSpl3
test _IsiteID2_2
test _IsiteID3_2
test _IroofTypeT_2
test _IlghtSrT3_2
test _IdrnkWtSrT_2 _IdrnkWtSrT_3
test _ItoiletTyp_2 _ItoiletTyp_3
test _IoutdoorAc_1
test _ImsqtNet_d_1
test _IFlwVisAct_1 _IFlwVisAct_2 _IFlwVisAct_3
test _Iabp_denvT_1
test _Ichills_de_1
test _Ibleeding__1
test _Inausea_de_1
test _IimpMental_1

*drnkWtSrT3
xi: xtgee denv_pos_aic ageSpl1 ageSpl2 ageSpl3 i.siteID2 i.siteID3 i.roofTypeT3 i.lghtSrT3 ///
i.toiletTypeT3 i.outdoorActy_denvT3 i.msqtNet_denvT3 i.FlwVisAct ///
i.abp_denvT i.chills_denvT i.bleeding_denvT i.nausea_denvT i.impMentalStatus_denvT, family(binomial) corr(exc) eform 
test ageSpl1 ageSpl2 ageSpl3
test _IsiteID2_2
test _IsiteID3_2
test _IroofTypeT_2
test _IlghtSrT3_2
test _ItoiletTyp_2 _ItoiletTyp_3
test _IoutdoorAc_1
test _ImsqtNet_d_1
test _IFlwVisAct_1 _IFlwVisAct_2 _IFlwVisAct_3
test _Iabp_denvT_1
test _Ichills_de_1
test _Ibleeding__1
test _Inausea_de_1
test _IimpMental_1

*siteID3
xi: xtgee denv_pos_aic ageSpl1 ageSpl2 ageSpl3 i.siteID2 i.roofTypeT3 i.lghtSrT3 ///
i.toiletTypeT3 i.outdoorActy_denvT3 i.msqtNet_denvT3 i.FlwVisAct ///
i.abp_denvT i.chills_denvT i.bleeding_denvT i.nausea_denvT i.impMentalStatus_denvT, family(binomial) corr(exc) eform 
test ageSpl1 ageSpl2 ageSpl3
test _IsiteID2_2
test _IroofTypeT_2
test _IlghtSrT3_2
test _ItoiletTyp_2 _ItoiletTyp_3
test _IoutdoorAc_1
test _ImsqtNet_d_1
test _IFlwVisAct_1 _IFlwVisAct_2 _IFlwVisAct_3
test _Iabp_denvT_1
test _Ichills_de_1
test _Ibleeding__1
test _Inausea_de_1
test _IimpMental_1

*abp_denvT
xi: xtgee denv_pos_aic ageSpl1 ageSpl2 ageSpl3 i.siteID2 i.roofTypeT3 i.lghtSrT3 ///
i.toiletTypeT3 i.outdoorActy_denvT3 i.msqtNet_denvT3 i.FlwVisAct ///
i.chills_denvT i.bleeding_denvT i.nausea_denvT i.impMentalStatus_denvT, family(binomial) corr(exc) eform 
test ageSpl1 ageSpl2 ageSpl3
test _IsiteID2_2
test _IroofTypeT_2
test _IlghtSrT3_2
test _ItoiletTyp_2 _ItoiletTyp_3
test _IoutdoorAc_1
test _ImsqtNet_d_1
test _IFlwVisAct_1 _IFlwVisAct_2 _IFlwVisAct_3
test _Ichills_de_1
test _Ibleeding__1
test _Inausea_de_1
test _IimpMental_1

*chills_denvT
xi: xtgee denv_pos_aic ageSpl1 ageSpl2 ageSpl3 i.siteID2 i.roofTypeT3 i.lghtSrT3 ///
i.toiletTypeT3 i.outdoorActy_denvT3 i.msqtNet_denvT3 i.FlwVisAct ///
i.bleeding_denvT i.nausea_denvT i.impMentalStatus_denvT, family(binomial) corr(exc) eform 
test ageSpl1 ageSpl2 ageSpl3
test _IsiteID2_2
test _IroofTypeT_2
test _IlghtSrT3_2
test _ItoiletTyp_2 _ItoiletTyp_3
test _IoutdoorAc_1
test _ImsqtNet_d_1
test _IFlwVisAct_1 _IFlwVisAct_2 _IFlwVisAct_3
test _Ibleeding__1
test _Inausea_de_1
test _IimpMental_1

*ageSpl1 ageSpl2 ageSpl3
xi: xtgee denv_pos_aic  i.siteID2 i.roofTypeT3 i.lghtSrT3 ///
i.toiletTypeT3 i.outdoorActy_denvT3 i.msqtNet_denvT3 i.FlwVisAct ///
i.bleeding_denvT i.nausea_denvT i.impMentalStatus_denvT, family(binomial) corr(exc) eform 
test _IsiteID2_2
test _IroofTypeT_2
test _IlghtSrT3_2
test _ItoiletTyp_2 _ItoiletTyp_3
test _IoutdoorAc_1
test _ImsqtNet_d_1
test _IFlwVisAct_1 _IFlwVisAct_2 _IFlwVisAct_3
test _Ibleeding__1
test _Inausea_de_1
test _IimpMental_1

*nausea_denvT
xi: xtgee denv_pos_aic  i.siteID2 i.roofTypeT3 i.lghtSrT3 ///
i.toiletTypeT3 i.outdoorActy_denvT3 i.msqtNet_denvT3 i.FlwVisAct ///
i.bleeding_denvT i.impMentalStatus_denvT, family(binomial) corr(exc) eform 
test _IsiteID2_2
test _IroofTypeT_2
test _IlghtSrT3_2
test _ItoiletTyp_2 _ItoiletTyp_3
test _IoutdoorAc_1
test _ImsqtNet_d_1
test _IFlwVisAct_1 _IFlwVisAct_2 _IFlwVisAct_3
test _Ibleeding__1
test _IimpMental_1


*Final model:
est clear
eststo: xi: xtgee denv_pos_aic  i.siteID2 i.roofTypeT3 i.lghtSrT3 ///
i.toiletTypeT3 i.outdoorActy_denvT3 i.msqtNet_denvT3 i.FlwVisAct ///
i.bleeding_denvT i.impMentalStatus_denvT, family(binomial) corr(exc) eform 
test _IsiteID2_2
test _IroofTypeT_2
test _IlghtSrT3_2
test _ItoiletTyp_2 _ItoiletTyp_3
test _IoutdoorAc_1
test _ImsqtNet_d_1
test _IFlwVisAct_1 _IFlwVisAct_2 _IFlwVisAct_3
test _Ibleeding__1
test _IimpMental_1

estout est1 using "DENV_mvAnalysis_tot.xls",  ///
cells("b(fmt(%9.2fc)) ci(par((   -  ))) p(fmt(%9.8fc))") ///
mlabel("Poisson log") label ///
collabels("") varlabels(_cons Constant) varwidth(10) modelwidth(10) prefoot("") ///
postfoot("CI in parentheses") legend style(tab) eform replace 


*Test for interaction in the final model? Site=west vs coast
xi: xtgee denv_pos_aic  i.siteID2 , family(binomial) corr(exc) eform 

xi: xtgee denv_pos_aic  i.siteID2*i.roofTypeT3 , family(binomial) corr(exc) eform 

xi: xtgee denv_pos_aic  i.siteID2*i.lghtSrT3  , family(binomial) corr(exc) eform 
xi: xtgee denv_pos_aic  i.lghtSrT3  if siteID2==1 , family(binomial) corr(exc) eform 
xi: xtgee denv_pos_aic  i.lghtSrT3  if siteID2==2 , family(binomial) corr(exc) eform 


xi: xtgee denv_pos_aic  i.siteID2*i.toiletTypeT3 , family(binomial) corr(exc) eform 
test _IsitXtoi_2_2  _IsitXtoi_2_3

xi: xtgee denv_pos_aic  i.siteID2*i.outdoorActy_denvT3 , family(binomial) corr(exc) eform 

xi: xtgee denv_pos_aic  i.outdoorActy_denvT3 if siteID2==1, family(binomial) corr(exc) eform 
xi: xtgee denv_pos_aic  i.outdoorActy_denvT3 if siteID2==2, family(binomial) corr(exc) eform 

xi: xtgee denv_pos_aic  i.siteID2*i.msqtNet_denvT3 

xi: xtgee denv_pos_aic  i.siteID2*i.FlwVisAct  
test _IsitXFlw_2_1 _IsitXFlw_2_2 _IsitXFlw_2_3

xi: xtgee denv_pos_aic  i.siteID2*i.bleeding_denvT 
test _IsitXble_2_1 

xi: xtgee denv_pos_aic  i.siteID2*i.impMentalStatus_denvT

*Test for interaction in the final model? site - four categories
xi: xtgee denv_pos_aic  i.siteID , family(binomial) corr(exc) eform 

xi: xtgee denv_pos_aic  i.siteID*i.roofTypeT3 , family(binomial) corr(exc) eform 
test _IsitXroo_2_2 _IsitXroo_3_2 _IsitXroo_4_2

xi: xtgee denv_pos_aic  i.siteID*i.toiletTypeT3 , family(binomial) corr(exc) eform 
test _IsitXtoi_2_2 _IsitXtoi_2_3 _IsitXtoi_3_2 _IsitXtoi_3_3 _IsitXtoi_4_2 _IsitXtoi_4_3

*xi: xtgee denv_pos_aic  i.siteID*i.outdoorActy_denvT3 , family(binomial) corr(exc) eform 
*no convergence

xi: xtgee denv_pos_aic  i.siteID*i.msqtNet_denvT3  , family(binomial) corr(exc) eform 
test _IsitXmsq_2_1 _IsitXmsq_3_1 _IsitXmsq_4_1

xi: xtgee denv_pos_aic i.msqtNet_denvT3 if siteID==1 , family(binomial) corr(exc) eform 
xi: xtgee denv_pos_aic i.msqtNet_denvT3 if siteID==2 , family(binomial) corr(exc) eform 
xi: xtgee denv_pos_aic i.msqtNet_denvT3 if siteID==3 , family(binomial) corr(exc) eform 
xi: xtgee denv_pos_aic i.msqtNet_denvT3 if siteID==4 , family(binomial) corr(exc) eform 
*All in the same direction, and not extremely different

xi: xtgee denv_pos_aic  i.siteID*i.FlwVisAct  
test _IsitXFlw_2_1 _IsitXFlw_2_2 _IsitXFlw_2_3 _IsitXFlw_3_1 _IsitXFlw_3_2 _IsitXFlw_3_3  _IsitXFlw_4_1 _IsitXFlw_4_2 _IsitXFlw_4_3 

xi: xtgee denv_pos_aic i.FlwVisAct if siteID==1 , family(binomial) corr(exc) eform 
xi: xtgee denv_pos_aic i.FlwVisAct if siteID==2 , family(binomial) corr(exc) eform 
xi: xtgee denv_pos_aic i.FlwVisAct if siteID==3 , family(binomial) corr(exc) eform 
xi: xtgee denv_pos_aic i.FlwVisAct if siteID==4 , family(binomial) corr(exc) eform 
*same

xi: xtgee denv_pos_aic  i.siteID*i.bleeding_denvT 
test _IsitXble_2_1 _IsitXble_3_1 _IsitXble_4_1

xi: xtgee denv_pos_aic i.bleeding_denvT if siteID==1 , family(binomial) corr(exc) eform 
xi: xtgee denv_pos_aic i.bleeding_denvT if siteID==2 , family(binomial) corr(exc) eform 
xi: xtgee denv_pos_aic i.bleeding_denvT if siteID==3 , family(binomial) corr(exc) eform 
xi: xtgee denv_pos_aic i.bleeding_denvT if siteID==4 , family(binomial) corr(exc) eform 
*At the rural site the effect is significantly stronger

bysort siteID: ta bleeding_denvT denv_pos_aic, row
*The snumbers are way too small to really say something statistically about this, could also be by chance
*rural coast has 3 or 4 patients that reported bleeding

xi: xtgee denv_pos_aic  i.siteID*i.impMentalStatus_denvT
test _IsitXimp_2_1 _IsitXimp_3_1 _IsitXimp_4_1

clear
















*******************************************************************************
*AIC - chikv -risk factor analyses
*******************************************************************************
clear
use "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_AIC_step3_gee.dta"

cd "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Tabout"

ta chikv_pos_aic, m
drop if chikv_pos_aic==.
ta chikv_pos_aic, m

*sort person_id2 date_complete nthRecAIC
*bysort person_id2: gen nthRecGEE=_n 
*ta nthRecGEE Acute, m

*egen totRec2 = total(cohortID==1), by(person_id)
*ta totRec2, m
*ta totRec2 Acute, m

*sort person_id date_complete nthRecAIC
*browse person_id person_id2 date_complete Acute nthRecAIC nthRecGEE totRec2

*xi: xtgee chikv_pos_aic i.ageCat, family(binomial) corr(exc) eform 
*gen esample=1 if e(sample)==1
*drop if esample!=1
*bysort person_id2: gen nien2=_n
*bysort nien2: ta chikv_pos_aic ageCat
*bysort nthRecGEE: ta chikv_pos_aic ageCat
*Groups do not match number of 1st Acute visits,
*because of unblanced data
*Not sure whether this is the most clean strategy


*******************************************************************************
**Make spline, Des want to use age as a continous variable
summ ageyrs, d
di r(p50) r(p25) r(p75)

mkspline ageSpl = ageyrs, cubic nknots(4) displayknots
mat knots = r(knots) 

xi: xtgee chikv_pos_aic ageSpl1 ageSpl2 ageSpl3, family(binomial) corr(exc) eform 
test ageSpl2 ageSpl3 // as this is not significant in principle it is not necessary to use splines, however as it gives flexibility in the analyses I will keep if
test ageSpl1 ageSpl2 ageSpl3

xi: xtgee chikv_pos_aic ageyrs, family(binomial) corr(exc) eform 
test ageyrs


********************************************************************************
*Age output for table
xi: xtgee denv_pos_aic ageSpl1 ageSpl2 ageSpl3, family(binomial) corr(exc) eform 
test ageSpl1 ageSpl2 ageSpl3
xbrcspline ageSpl, values(2 4 8 12) ref(4) eform matknots(knots)


********************************************************************************
*Output for categorical variables

est clear

foreach var of varlist ageCat gender2 sesCat3 siteID siteID2 siteID3  /// demographics
yr mth /// season
roofTypeT3 floorTypeT3 numRoomsCat3 nrPlpHCat3 nrWndCat3 lghtSrT3 drnkWtSrT3 toiletTypeT3 /// house circumstances
outdoorActy_chikvT3 childTrave_chikvT msqtBites_chikvT3 msqtCoil_chikvT3 msqtNet_chikvT3 feverCntct_chikvT3 ///exposure and protective measures
nrAcuteT FlwVisAct //// severity
abp_chikvT chills_chikvT diarrhea_chikvT rash_chikvT bleeding_chikvT /// symptoms
body_ache_chikvT nausea_chikvT vomit_chikvT impMentalStatus_chikvT /// symptoms
probDnv_chikvT denvWrn_chikvT ///WHO warning signs
{
eststo: xi: xtgee chikv_pos_aic i.`var', family(binomial) corr(exc) eform 
di e(p)
}
*

eststo chikv_BiAn_Tot: appendmodels est1 est2 est3 est4 est5 est6 est7 est8 est9 est10 ///  
est11 est12 est13 est14 est15 est16 est17 est18 est19 est20 ///  
est21 est22 est23 est24 est25 est26 est27 est28 est29 est30 ///  
est31 est32 est33 est34 est35

estout chikv_BiAn_Tot using "chikv_BiAn_Tot.xls",  ///
cells("b(fmt(%9.2fc)) ci(par((   -  ))) p(fmt(%9.8fc))") ///
mlabel("Poisson log") label ///
collabels("") varlabels(_cons Constant) varwidth(10) modelwidth(10) prefoot("") ///
postfoot("CI in parentheses") legend style(tab) eform replace 


*Extract p-values

xi: xtgee chikv_pos_aic i.ageCat, family(binomial) corr(exc) eform 
test _IageCat_2 _IageCat_3 _IageCat_4 _IageCat_5

xi: xtgee chikv_pos_aic i.gender2, family(binomial) corr(exc) eform 
test _Igender2_1

xi: xtgee chikv_pos_aic i.sesCat3, family(binomial) corr(exc) eform 
test _IsesCat3_2 _IsesCat3_3

xi: xtgee chikv_pos_aic i.siteID, family(binomial) corr(exc) eform 
test  _IsiteID_2  _IsiteID_3  _IsiteID_4

xi: xtgee chikv_pos_aic i.siteID2, family(binomial) corr(exc) eform 
test  _IsiteID2_2

xi: xtgee chikv_pos_aic i.siteID3, family(binomial) corr(exc) eform 
test  _IsiteID3_2

xi: xtgee chikv_pos_aic i.yr, family(binomial) corr(exc) eform 
test _Iyr_2015 _Iyr_2016 _Iyr_2017 _Iyr_2018

xi: xtgee chikv_pos_aic i.mth, family(binomial) corr(exc) eform 
test _Imth_2 _Imth_3 _Imth_4 _Imth_5 _Imth_6 _Imth_7 _Imth_8 _Imth_9 _Imth_10 _Imth_11 _Imth_12

xi: xtgee chikv_pos_aic i.roofTypeT3, family(binomial) corr(exc) eform 
test _IroofTypeT_2

xi: xtgee chikv_pos_aic i.floorTypeT3, family(binomial) corr(exc) eform 
test _IfloorType_2

xi: xtgee chikv_pos_aic i.numRoomsCat3, family(binomial) corr(exc) eform 
test _InumRoomsC_2 _InumRoomsC_3

xi: xtgee chikv_pos_aic i.nrPlpHCat3, family(binomial) corr(exc) eform 
test _InrPlpHCat_2 _InrPlpHCat_3 _InrPlpHCat_4 _InrPlpHCat_5

xi: xtgee chikv_pos_aic i.nrWndCat3, family(binomial) corr(exc) eform 
test _InrWndCat3_1 _InrWndCat3_2 _InrWndCat3_3

xi: xtgee chikv_pos_aic i.lghtSrT3, family(binomial) corr(exc) eform 
test _IlghtSrT3_2 

xi: xtgee chikv_pos_aic i.drnkWtSrT3, family(binomial) corr(exc) eform 
test _IdrnkWtSrT_2 _IdrnkWtSrT_3

xi: xtgee chikv_pos_aic i.toiletTypeT3, family(binomial) corr(exc) eform 
test _ItoiletTyp_2 _ItoiletTyp_3

xi: xtgee chikv_pos_aic i.outdoorActy_chikvT3, family(binomial) corr(exc) eform 
test _IoutdoorAc_1

xi: xtgee chikv_pos_aic i.childTrave_chikvT, family(binomial) corr(exc) eform 
test _IchildTrav_1

xi: xtgee chikv_pos_aic i.msqtBites_chikvT3, family(binomial) corr(exc) eform 
test _ImsqtBites_1

xi: xtgee chikv_pos_aic i.msqtCoil_chikvT3, family(binomial) corr(exc) eform 
test _ImsqtCoil__1

xi: xtgee chikv_pos_aic i.msqtNet_chikvT3, family(binomial) corr(exc) eform 
test _ImsqtNet_c_1

xi: xtgee chikv_pos_aic i.feverCntct_chikvT3, family(binomial) corr(exc) eform 
test _IfeverCntc_1

xi: xtgee chikv_pos_aic i.nrAcuteT, family(binomial) corr(exc) eform 
test _InrAcuteT_2 _InrAcuteT_3 _InrAcuteT_4

xi: xtgee chikv_pos_aic i.FlwVisAct, family(binomial) corr(exc) eform 
test _IFlwVisAct_1 _IFlwVisAct_2 _IFlwVisAct_3

xi: xtgee chikv_pos_aic i.abp_chikvT, family(binomial) corr(exc) eform 
test _Iabp_chikv_1

xi: xtgee chikv_pos_aic i.chills_chikvT, family(binomial) corr(exc) eform 
test _Ichills_ch_1

xi: xtgee chikv_pos_aic i.diarrhea_chikvT, family(binomial) corr(exc) eform 
test _Idiarrhea__1 

xi: xtgee chikv_pos_aic i.rash_chikvT, family(binomial) corr(exc) eform 
test _Irash_chik_1

xi: xtgee chikv_pos_aic i.bleeding_chikvT, family(binomial) corr(exc) eform 
test _Ibleeding__1

xi: xtgee chikv_pos_aic i.body_ache_chikvT, family(binomial) corr(exc) eform 
test _Ibody_ache_1

xi: xtgee chikv_pos_aic i.nausea_chikvT, family(binomial) corr(exc) eform 
test _Inausea_ch_1 

xi: xtgee chikv_pos_aic i.vomit_chikvT, family(binomial) corr(exc) eform 
test _Ivomit_chi_1

xi: xtgee chikv_pos_aic i.impMentalStatus_chikvT, family(binomial) corr(exc) eform 
test _IimpMental_1

xi: xtgee chikv_pos_aic i.probDnv_chikvT, family(binomial) corr(exc) eform 
test  _IprobDnv_c_1 _IprobDnv_c_2 _IprobDnv_c_3 _IprobDnv_c_4

xi: xtgee chikv_pos_aic i.denvWrn_chikvT, family(binomial) corr(exc) eform 
test  _IdenvWrn_c_1 _IdenvWrn_c_2 _IdenvWrn_c_3 _IdenvWrn_c_4

********************************************************************************
*Run mv analyses
********************************************************************************
*Age output for table
xi: xtgee denv_pos_aic ageSpl1 ageSpl2 ageSpl3, family(binomial) corr(exc) eform 
test ageSpl1 ageSpl2 ageSpl3
xbrcspline ageSpl, values(2 4 8 12) ref(4) eform matknots(knots)


********************************************************************************
*Output for categorical variables

xi: xtgee chikv_pos_aic ageSpl1 ageSpl2 ageSpl3 i.sesCat3 i.siteID2 ///
i.nrPlpHCat3 i.nrWndCat3 i.outdoorActy_chikvT3 i.childTrave_chikvT i.msqtBites_chikvT3 ///
i.msqtNet_chikvT3 i.chills_chikvT i.body_ache_chikvT i.nausea_chikvT i.vomit_chikvT i.denvWrn_chikvT , family(binomial) corr(exc) eform 

test ageSpl1 ageSpl2 ageSpl3
test _IsesCat3_2 _IsesCat3_3
test _IsiteID2_2
test _InrPlpHCat_2 _InrPlpHCat_3 _InrPlpHCat_4 _InrPlpHCat_5
test _InrWndCat3_1 _InrWndCat3_2 _InrWndCat3_3
test _IoutdoorAc_1
test _IchildTrav_1
test _ImsqtBites_1
test _ImsqtNet_c_1
test _Ichills_ch_1
test _Ibody_ache_1
test _Inausea_ch_1
test _Ivomit_chi_1
test _IdenvWrn_c_1 _IdenvWrn_c_2 _IdenvWrn_c_3 _IdenvWrn_c_4

*childTrave_chikvT
xi: xtgee chikv_pos_aic ageSpl1 ageSpl2 ageSpl3 i.sesCat3 i.siteID2 ///
i.nrPlpHCat3 i.nrWndCat3 i.outdoorActy_chikvT3 i.msqtBites_chikvT3 ///
i.msqtNet_chikvT3 i.chills_chikvT i.body_ache_chikvT i.nausea_chikvT i.vomit_chikvT i.denvWrn_chikvT , family(binomial) corr(exc) eform 

test ageSpl1 ageSpl2 ageSpl3
test _IsesCat3_2 _IsesCat3_3
test _IsiteID2_2
test _InrPlpHCat_2 _InrPlpHCat_3 _InrPlpHCat_4 _InrPlpHCat_5
test _InrWndCat3_1 _InrWndCat3_2 _InrWndCat3_3
test _IoutdoorAc_1
test _ImsqtBites_1
test _ImsqtNet_c_1
test _Ichills_ch_1
test _Ibody_ache_1
test _Inausea_ch_1
test _Ivomit_chi_1
test _IdenvWrn_c_1 _IdenvWrn_c_2 _IdenvWrn_c_3 _IdenvWrn_c_4

*nrPlpHCat3
xi: xtgee chikv_pos_aic ageSpl1 ageSpl2 ageSpl3 i.sesCat3 i.siteID2 ///
i.nrWndCat3 i.outdoorActy_chikvT3 i.msqtBites_chikvT3 ///
i.msqtNet_chikvT3 i.chills_chikvT i.body_ache_chikvT i.nausea_chikvT i.vomit_chikvT i.denvWrn_chikvT , family(binomial) corr(exc) eform 


test ageSpl1 ageSpl2 ageSpl3
test _IsesCat3_2 _IsesCat3_3
test _IsiteID2_2
test _InrWndCat3_1 _InrWndCat3_2 _InrWndCat3_3
test _IoutdoorAc_1
test _ImsqtBites_1
test _ImsqtNet_c_1
test _Ichills_ch_1
test _Ibody_ache_1
test _Inausea_ch_1
test _Ivomit_chi_1
test _IdenvWrn_c_1 _IdenvWrn_c_2 _IdenvWrn_c_3 _IdenvWrn_c_4

*i.denvWrn_chikvT
xi: xtgee chikv_pos_aic ageSpl1 ageSpl2 ageSpl3 i.sesCat3 i.siteID2 ///
i.nrWndCat3 i.outdoorActy_chikvT3 i.msqtBites_chikvT3 ///
i.msqtNet_chikvT3 i.chills_chikvT i.body_ache_chikvT i.nausea_chikvT i.vomit_chikvT  , family(binomial) corr(exc) eform 

test ageSpl1 ageSpl2 ageSpl3
test _IsesCat3_2 _IsesCat3_3
test _IsiteID2_2
test _InrWndCat3_1 _InrWndCat3_2 _InrWndCat3_3
test _IoutdoorAc_1
test _ImsqtBites_1
test _ImsqtNet_c_1
test _Ichills_ch_1
test _Ibody_ache_1
test _Inausea_ch_1
test _Ivomit_chi_1

*vomit_chikvT
xi: xtgee chikv_pos_aic ageSpl1 ageSpl2 ageSpl3 i.sesCat3 i.siteID2 ///
i.nrWndCat3 i.outdoorActy_chikvT3 i.msqtBites_chikvT3 ///
i.msqtNet_chikvT3 i.chills_chikvT i.body_ache_chikvT i.nausea_chikvT , family(binomial) corr(exc) eform 

test ageSpl1 ageSpl2 ageSpl3
test _IsesCat3_2 _IsesCat3_3
test _IsiteID2_2
test _InrWndCat3_1 _InrWndCat3_2 _InrWndCat3_3
test _IoutdoorAc_1
test _ImsqtBites_1
test _ImsqtNet_c_1
test _Ichills_ch_1
test _Ibody_ache_1
test _Inausea_ch_1

*nrWndCat3
xi: xtgee chikv_pos_aic ageSpl1 ageSpl2 ageSpl3 i.sesCat3 i.siteID2 ///
i.outdoorActy_chikvT3 i.msqtBites_chikvT3 ///
i.msqtNet_chikvT3 i.chills_chikvT i.body_ache_chikvT i.nausea_chikvT , family(binomial) corr(exc) eform 

test ageSpl1 ageSpl2 ageSpl3
test _IsesCat3_2 _IsesCat3_3
test _IsiteID2_2
test _IoutdoorAc_1
test _ImsqtBites_1
test _ImsqtNet_c_1
test _Ichills_ch_1
test _Ibody_ache_1
test _Inausea_ch_1

*body_ache_chikvT
xi: xtgee chikv_pos_aic ageSpl1 ageSpl2 ageSpl3 i.sesCat3 i.siteID2 ///
i.outdoorActy_chikvT3 i.msqtBites_chikvT3 ///
i.msqtNet_chikvT3 i.chills_chikvT i.nausea_chikvT , family(binomial) corr(exc) eform 

test ageSpl1 ageSpl2 ageSpl3
test _IsesCat3_2 _IsesCat3_3
test _IsiteID2_2
test _IoutdoorAc_1
test _ImsqtBites_1
test _ImsqtNet_c_1
test _Ichills_ch_1
test _Inausea_ch_1


*Final model
xi: xtgee chikv_pos_aic ageSpl1 ageSpl2 ageSpl3 i.sesCat3 i.siteID2 ///
i.outdoorActy_chikvT3 i.msqtBites_chikvT3 ///
i.msqtNet_chikvT3 i.chills_chikvT i.nausea_chikvT , family(binomial) corr(exc) eform 

test ageSpl1 ageSpl2 ageSpl3
test _IsesCat3_2 _IsesCat3_3
test _IsiteID2_2
test _IoutdoorAc_1
test _ImsqtBites_1
test _ImsqtNet_c_1
test _Ichills_ch_1
test _Inausea_ch_1

xbrcspline ageSpl, values(2 4 8 12) ref(4) eform matknots(knots)


est clear
eststo: xi: xtgee chikv_pos_aic ageSpl1 ageSpl2 ageSpl3 i.sesCat3 i.siteID2 ///
i.outdoorActy_chikvT3 i.msqtBites_chikvT3 ///
i.msqtNet_chikvT3 i.chills_chikvT i.nausea_chikvT , family(binomial) corr(exc) eform 

estout est1 using "DENV_mvAnalysis_tot.xls",  ///
cells("b(fmt(%9.2fc)) ci(par((   -  ))) p(fmt(%9.8fc))") ///
mlabel("Poisson log") label ///
collabels("") varlabels(_cons Constant) varwidth(10) modelwidth(10) prefoot("") ///
postfoot("CI in parentheses") legend style(tab) eform replace 

*I tested for interaction at a bi-variable level to avoid any influence from other variables

*Test for interaction:
xi: xtgee chikv_pos_aic i.siteID2*ageSpl1 i.siteID2*ageSpl2 i.siteID2*ageSpl3 , family(binomial) corr(exc) eform 
test _IsitXageSp_2  _IsitXageSpa2  _IsitXageSpb2

xi: xtgee chikv_pos_aic i.siteID2*i.sesCat3 , family(binomial) corr(exc) eform 
test _IsitXses_2_2 _IsitXses_2_3

xi: xtgee chikv_pos_aic i.siteID2*i.outdoorActy_chikvT3 , family(binomial) corr(exc) eform 
test _IsitXout_2_1

xi: xtgee chikv_pos_aic i.siteID2*i.msqtBites_chikvT3 , family(binomial) corr(exc) eform 
test _IsitXmsq_2_1

xi: xtgee chikv_pos_aic i.msqtBites_chikvT3 if siteID2==1, family(binomial) corr(exc) eform 
xi: xtgee chikv_pos_aic i.msqtBites_chikvT3 if siteID2==2, family(binomial) corr(exc) eform 
*Mosquito bites was a better predictor at the coast

xi: xtgee chikv_pos_aic i.siteID2*i.msqtNet_chikvT3 , family(binomial) corr(exc) eform 
test _IsitXmsq_2_1

xi: xtgee chikv_pos_aic i.siteID2*i.chills_chikvT , family(binomial) corr(exc) eform 
test _IsitXchi_2_1 

xi: xtgee chikv_pos_aic i.chills_chikvT if siteID2==1 , family(binomial) corr(exc) eform 
xi: xtgee chikv_pos_aic i.chills_chikvT if siteID2==2 , family(binomial) corr(exc) eform 

xi: xtgee chikv_pos_aic i.siteID2*i.nausea_chikvT , family(binomial) corr(exc) eform 

xi: xtgee chikv_pos_aic i.nausea_chikvT if siteID2==1 , family(binomial) corr(exc) eform 
xi: xtgee chikv_pos_aic i.nausea_chikvT if siteID2==2 , family(binomial) corr(exc) eform 

*last two interactions are (borderline-)significant but I am ignoring those as the direction does not seem to make sense

*Test for interaction:
xi: xtgee chikv_pos_aic i.siteID*ageSpl1 i.siteID*ageSpl2 i.siteID*ageSpl3 , family(binomial) corr(exc) eform 
test _IsitXageSp_2  _IsitXageSpa2  _IsitXageSpb2

xi: xtgee chikv_pos_aic i.siteID*i.sesCat3 , family(binomial) corr(exc) eform 
test _IsitXses_2_2 _IsitXses_2_3 _IsitXses_3_2 _IsitXses_3_3 _IsitXses_4_2 _IsitXses_4_3

xi: xtgee chikv_pos_aic i.sesCat3 if siteID==1 , family(binomial) corr(exc) eform 
test _IsesCat3_2 _IsesCat3_3
xi: xtgee chikv_pos_aic i.sesCat3 if siteID==2 , family(binomial) corr(exc) eform 
test _IsesCat3_2 _IsesCat3_3
xi: xtgee chikv_pos_aic i.sesCat3 if siteID==3 , family(binomial) corr(exc) eform 
test _IsesCat3_2 _IsesCat3_3
xi: xtgee chikv_pos_aic i.sesCat3 if siteID==4 , family(binomial) corr(exc) eform 
test _IsesCat3_2 _IsesCat3_3

bysort siteID: ta sesCat3 chikv_pos_aic, row
*only at the rural coast the odds decreases with ses
*at the other sites it increases with ses
*if you test by site, it is only significant at the urban coast site
*and it has a parabolic shape there
*Justin: maybe consider analysing ses continously?

xi: xtgee chikv_pos_aic i.siteID*i.outdoorActy_chikvT3 , family(binomial) corr(exc) eform 
test _IsitXout_2_1

*xi: xtgee chikv_pos_aic i.siteID*i.msqtBites_chikvT3 , family(binomial) corr(exc) eform 
*Did not converge

xi: xtgee chikv_pos_aic i.siteID*i.msqtNet_chikvT3 , family(binomial) corr(exc) eform 
test _IsitXmsq_2_1 _IsitXmsq_3_1 _IsitXmsq_4_1

xi: xtgee chikv_pos_aic i.msqtNet_chikvT3 if siteID==1, family(binomial) corr(exc) eform 
xi: xtgee chikv_pos_aic i.msqtNet_chikvT3 if siteID==2, family(binomial) corr(exc) eform 
xi: xtgee chikv_pos_aic i.msqtNet_chikvT3 if siteID==3, family(binomial) corr(exc) eform 
xi: xtgee chikv_pos_aic i.msqtNet_chikvT3 if siteID==4, family(binomial) corr(exc) eform 
*All same directions
bysort siteID: ta msqtNet_chikvT3 chikv_pos_aic, row
*has enough power to show a difference in association, but the association just does not make sense
*preferably we would NOT find any association
*think what to do with this

xi: xtgee chikv_pos_aic i.siteID*i.chills_chikvT , family(binomial) corr(exc) eform 
test _IsitXchi_2_1 _IsitXchi_3_1 _IsitXchi_4_1

xi: xtgee chikv_pos_aic i.chills_chikvT if siteID==1 , family(binomial) corr(exc) eform 
xi: xtgee chikv_pos_aic i.chills_chikvT if siteID==2 , family(binomial) corr(exc) eform 
xi: xtgee chikv_pos_aic i.chills_chikvT if siteID==3 , family(binomial) corr(exc) eform 
xi: xtgee chikv_pos_aic i.chills_chikvT if siteID==4 , family(binomial) corr(exc) eform 

xi: xtgee chikv_pos_aic i.siteID*i.nausea_chikvT , family(binomial) corr(exc) eform 
test _IsitXnau_2_1  _IsitXnau_3_1  _IsitXnau_4_1 

xi: xtgee chikv_pos_aic i.nausea_chikvT if siteID==1 , family(binomial) corr(exc) eform 
xi: xtgee chikv_pos_aic i.nausea_chikvT if siteID==2 , family(binomial) corr(exc) eform 
xi: xtgee chikv_pos_aic i.nausea_chikvT if siteID==3 , family(binomial) corr(exc) eform //only significant
xi: xtgee chikv_pos_aic i.nausea_chikvT if siteID==4 , family(binomial) corr(exc) eform 

clear










































********************************************************************************
** AIC - DENV 
********************************************************************************
clear
use "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_AIC_step3.dta"
set autotabgraphs on
cd "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Figures"

bysort mth: egen prop_TOT = mean(denv_pos_aic) 
mkspline mthplT = mth, cubic nknots(4) displayknots
xi: logistic denv_pos_aic mthplT1 mthplT2 mthplT3 
predict p_TOT 			 , p
predict logodds_TOT 	 , xb
predict stderr_TOT 	 , stdp
generate lodds_ub_TOT = logodds_TOT + 1.96*stderr_TOT  		
generate lodds_lb_TOT = logodds_TOT - 1.96*stderr_TOT  		
generate p_ub_TOT = exp(lodds_ub_TOT)/(1+exp(lodds_ub_TOT))  
generate p_lb_TOT = exp(lodds_lb_TOT)/(1+exp(lodds_lb_TOT))  
twoway 		 rarea p_lb_TOT p_ub_TOT mth ,  color(gs10) ///
		|| 	line p_TOT mth , lpattern(longdash_dot) lwidth(medthick) color(gs0)    ///2
		|| 	scatter prop_TOT mth , symbol(X) color(gs0) ///
, ylabel(0(0.2)1) ymtick(0(0.1)1) ytitle(Probability DENV positivity) ///
xtitle(Month)  xlabel(1 "jan" 2 "feb" 3 "mar" 4 "apr" 5 "may" 6 "jun" 7 "jul" ///
8 "aug" 9 "sep" 10 "okt" 11 "nov" 12 "dec", angle(35)) /// xscale(log) xlabel(0 5 10 15 20) xmtick(0(5)20)
legend(ring(0) position(1) order(2 "2014" 5 "2015" 8 "2016" 11 "2017" ) ///
cols(1)) xsize(5.25) ///
scheme(s2mono) ///
graphregion(color(white)) ///
plotregion(lcolor(black)) title(Acutely ill cohort ) ///
name(Figure_AIC, replace) saving(Figure_AIC, replace)

*Interaction with site is significant
xi: logistic denv_pos_aic i.siteID2*mthplT1 i.siteID2*mthplT2 i.siteID2*mthplT3
test _IsitXmthpl_2 _IsitXmthpla2 _IsitXmthplb2

*Interaction with years is significant
xi: logistic denv_pos_aic i.yr*mthplT1 i.yr*mthplT2 i.yr*mthplT3
test _IyrXmth_2015 _IyrXmth_2016 _IyrXmth_2017 _IyrXmth_2018 ///
_IyrXmtha2015 _IyrXmtha2016 _IyrXmtha2017 _IyrXmtha2018 ///
_IyrXmthb2015 _IyrXmthb2016 _IyrXmthb2017 _IyrXmthb2018


*********************************************************************************
** AIC - DENV - Coast
*********************************************************************************
clear
use "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_AIC_step3.dta"
set autotabgraphs on
cd "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Figures"

ta siteID2, m
keep if siteID2==1
ta siteID2, m

bysort yr: ta mth denv_pos_aic, row

mkspline mthplT = mth, cubic nknots(4) displayknots

bysort mth: egen prop_2014 = mean(denv_pos_aic) if yr==2014
xi: logistic denv_pos_aic mthplT1 mthplT2 mthplT3 if yr==2014
predict p_2014 			if yr==2014 , p
predict logodds_2014 	if yr==2014 , xb
predict stderr_2014 	if yr==2014 , stdp
generate lodds_ub_2014 = logodds_2014 + 1.96*stderr_2014  		if yr==2014
generate lodds_lb_2014 = logodds_2014 - 1.96*stderr_2014  		if yr==2014
generate p_ub_2014 = exp(lodds_ub_2014)/(1+exp(lodds_ub_2014))  if yr==2014
generate p_lb_2014 = exp(lodds_lb_2014)/(1+exp(lodds_lb_2014))  if yr==2014

bysort mth: egen prop_2015 = mean(denv_pos_aic) if yr==2015
xi: logistic denv_pos_aic mthplT1 mthplT2 mthplT3 if yr==2015
predict p_2015 			if yr==2015 , p
predict logodds_2015 	if yr==2015 , xb
predict stderr_2015 	if yr==2015 , stdp
generate lodds_ub_2015 = logodds_2015 + 1.96*stderr_2015  		if yr==2015
generate lodds_lb_2015 = logodds_2015 - 1.96*stderr_2015  		if yr==2015
generate p_ub_2015 = exp(lodds_ub_2015)/(1+exp(lodds_ub_2015))  if yr==2015
generate p_lb_2015 = exp(lodds_lb_2015)/(1+exp(lodds_lb_2015))  if yr==2015

bysort mth: egen prop_2016 = mean(denv_pos_aic) if yr==2016
xi: logistic denv_pos_aic mthplT1 mthplT2 mthplT3 if yr==2016
predict p_2016 			if yr==2016 , p
predict logodds_2016 	if yr==2016 , xb
predict stderr_2016 	if yr==2016 , stdp
generate lodds_ub_2016 = logodds_2016 + 1.96*stderr_2016  		if yr==2016
generate lodds_lb_2016 = logodds_2016 - 1.96*stderr_2016  		if yr==2016
generate p_ub_2016 = exp(lodds_ub_2016)/(1+exp(lodds_ub_2016))  if yr==2016
generate p_lb_2016 = exp(lodds_lb_2016)/(1+exp(lodds_lb_2016))  if yr==2016

bysort mth: egen prop_2017 = mean(denv_pos_aic) if yr==2017
xi: logistic denv_pos_aic mthplT1 mthplT2 mthplT3 if yr==2017
predict p_2017 			if yr==2017 , p
predict logodds_2017 	if yr==2017 , xb
predict stderr_2017 	if yr==2017 , stdp
generate lodds_ub_2017 = logodds_2017 + 1.96*stderr_2017  		if yr==2017
generate lodds_lb_2017 = logodds_2017 - 1.96*stderr_2017  		if yr==2017
generate p_ub_2017 = exp(lodds_ub_2017)/(1+exp(lodds_ub_2017))  if yr==2017
generate p_lb_2017 = exp(lodds_lb_2017)/(1+exp(lodds_lb_2017))  if yr==2017

*bysort mth: egen prop_2018 = mean(denv_pos_aic) if yr==2018
*xi: logistic denv_pos_aic mthplT1 mthplT2 mthplT3 if yr==2018
*predict p_2018 			if yr==2018 , p
*predict logodds_2018 	if yr==2018 , xb
*predict stderr_2018 	if yr==2018 , stdp
*generate lodds_ub_2018 = logodds_2018 + 1.96*stderr_2018  		if yr==2018
*generate lodds_lb_2018 = logodds_2018 - 1.96*stderr_2018  		if yr==2018
*generate p_ub_2018 = exp(lodds_ub_2018)/(1+exp(lodds_ub_2018))  if yr==2018
*generate p_lb_2018 = exp(lodds_lb_2018)/(1+exp(lodds_lb_2018))  if yr==2018

sort mth
twoway 	/// 2014
		 rarea p_lb_2014 p_ub_2014 mth ,  color(gs10) ///
		|| 	line p_2014 mth , lpattern(longdash_dot) lwidth(medthick) color(gs0)    ///2
		|| 	scatter prop_2014 mth , symbol(X) color(gs0) ///
		/// 2015
		|| rarea p_lb_2015 p_ub_2015 mth ,  color(gs10) /// 
		|| 	line p_2015 mth , lpattern(shortdash) lwidth(medthick) color(gs0)    ///5
		|| 	scatter prop_2015 mth , symbol(Oh) color(gs0) ///
		/// 2016
		|| rarea p_lb_2016 p_ub_2016 mth ,  color(gs10) /// 
		|| 	line p_2016 mth , lpattern(shortdash_dot) lwidth(medthick) color(gs0)    ///8
		|| 	scatter prop_2016 mth , symbol(Dh) color(gs0) /// 
		/// 2017
		||  rarea p_lb_2017 p_ub_2017 mth ,  color(gs10) /// 
		|| 	line p_2017 mth , lpattern(dash) lwidth(medthick) color(gs0)    ///11
		|| 	scatter prop_2017 mth , symbol(Th) color(gs0) /// 
		/// 2018
		///|| rarea p_lb_2018 p_ub_2018 mth ,  color(gs10) /// 
		///|| 	line p_2018 mth , lpattern(shortdas) lwidth(medthick) color(gs0)    ///9
		///|| 	scatter prop_2018 mth , symbol(Sh) color(gs0) ///
, ylabel(0(0.2)1) ymtick(0(0.1)1) ytitle(Probability DENV positivity) ///
xtitle(Month)  xlabel(1 "jan" 2 "feb" 3 "mar" 4 "apr" 5 "may" 6 "jun" 7 "jul" ///
8 "aug" 9 "sep" 10 "okt" 11 "nov" 12 "dec", angle(35)) /// xscale(log) xlabel(0 5 10 15 20) xmtick(0(5)20)
legend(ring(0) position(1) order(2 "2014" 5 "2015" 8 "2016" 11 "2017" ) ///
cols(1)) xsize(5.25) ///
scheme(s2mono) ///
graphregion(color(white)) ///
plotregion(lcolor(black)) title(AIC - west - DENV) ///
name(Figure_AICwest_denv, replace) saving(Figure_AICwest_denv, replace)


********************************************************************************
** AIC - DENV - Coast
********************************************************************************
clear
use "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_AIC_step3.dta"
set autotabgraphs on
cd "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Figures"

ta siteID2, m
keep if siteID2==2
ta siteID2, m

bysort yr: ta mth denv_pos_aic, row

 
mkspline mthplT = mth, cubic nknots(4) displayknots

*bysort mth: egen prop_2014 = mean(denv_pos_aic) if yr==2014
*xi: logistic denv_pos_aic mthplT1 mthplT2 mthplT3 if yr==2014
*predict p_2014 			if yr==2014 , p
*predict logodds_2014 	if yr==2014 , xb
*predict stderr_2014 	if yr==2014 , stdp
*generate lodds_ub_2014 = logodds_2014 + 1.96*stderr_2014  		if yr==2014
*generate lodds_lb_2014 = logodds_2014 - 1.96*stderr_2014  		if yr==2014
*generate p_ub_2014 = exp(lodds_ub_2014)/(1+exp(lodds_ub_2014))  if yr==2014
*generate p_lb_2014 = exp(lodds_lb_2014)/(1+exp(lodds_lb_2014))  if yr==2014

bysort mth: egen prop_2015 = mean(denv_pos_aic) if yr==2015
xi: logistic denv_pos_aic mthplT1 mthplT2 mthplT3 if yr==2015
predict p_2015 			if yr==2015 , p
predict logodds_2015 	if yr==2015 , xb
predict stderr_2015 	if yr==2015 , stdp
generate lodds_ub_2015 = logodds_2015 + 1.96*stderr_2015  		if yr==2015
generate lodds_lb_2015 = logodds_2015 - 1.96*stderr_2015  		if yr==2015
generate p_ub_2015 = exp(lodds_ub_2015)/(1+exp(lodds_ub_2015))  if yr==2015
generate p_lb_2015 = exp(lodds_lb_2015)/(1+exp(lodds_lb_2015))  if yr==2015

*bysort mth: egen prop_2016 = mean(denv_pos_aic) if yr==2016
*xi: logistic denv_pos_aic mthplT1 mthplT2 mthplT3 if yr==2016
*predict p_2016 			if yr==2016 , p
*predict logodds_2016 	if yr==2016 , xb
*predict stderr_2016 	if yr==2016 , stdp
*generate lodds_ub_2016 = logodds_2016 + 1.96*stderr_2016  		if yr==2016
*generate lodds_lb_2016 = logodds_2016 - 1.96*stderr_2016  		if yr==2016
*generate p_ub_2016 = exp(lodds_ub_2016)/(1+exp(lodds_ub_2016))  if yr==2016
*generate p_lb_2016 = exp(lodds_lb_2016)/(1+exp(lodds_lb_2016))  if yr==2016

bysort mth: egen prop_2017 = mean(denv_pos_aic) if yr==2017
xi: logistic denv_pos_aic mthplT1 mthplT2 mthplT3 if yr==2017
predict p_2017 			if yr==2017 , p
predict logodds_2017 	if yr==2017 , xb
predict stderr_2017 	if yr==2017 , stdp
generate lodds_ub_2017 = logodds_2017 + 1.96*stderr_2017  		if yr==2017
generate lodds_lb_2017 = logodds_2017 - 1.96*stderr_2017  		if yr==2017
generate p_ub_2017 = exp(lodds_ub_2017)/(1+exp(lodds_ub_2017))  if yr==2017
generate p_lb_2017 = exp(lodds_lb_2017)/(1+exp(lodds_lb_2017))  if yr==2017

*bysort mth: egen prop_2018 = mean(denv_pos_aic) if yr==2018
*xi: logistic denv_pos_aic mthplT1 mthplT2 mthplT3 if yr==2018
*predict p_2018 			if yr==2018 , p
*predict logodds_2018 	if yr==2018 , xb
*predict stderr_2018 	if yr==2018 , stdp
*generate lodds_ub_2018 = logodds_2018 + 1.96*stderr_2018  		if yr==2018
*generate lodds_lb_2018 = logodds_2018 - 1.96*stderr_2018  		if yr==2018
*generate p_ub_2018 = exp(lodds_ub_2018)/(1+exp(lodds_ub_2018))  if yr==2018
*generate p_lb_2018 = exp(lodds_lb_2018)/(1+exp(lodds_lb_2018))  if yr==2018

sort mth
twoway 	/// 2014
		/// 	rarea p_lb_2014 p_ub_2014 mth ,  color(gs10) ///
		/// || 	line p_2014 mth , lpattern(longdash_dot) lwidth(medthick) color(gs0)    ///2
		/// || 	scatter prop_2014 mth , symbol(X) color(gs0) ///
		/// 2015
		|| 	rarea p_lb_2015 p_ub_2015 mth ,  color(gs10) /// 
		|| 	line p_2015 mth , lpattern(shortdash) lwidth(medthick) color(ggs0)    ///2
		|| 	scatter prop_2015 mth , symbol(Oh) color(gs0) ///
		/// 2016
		///|| 	rarea p_lb_2016 p_ub_2016 mth ,  color(gs10) /// 
		///|| 	line p_2016 mth , lpattern(shortdash_dot) lwidth(medthick) color(gs0)    ///5
		///|| 	scatter prop_2016 mth , symbol(Dh) color(gs0) /// 
		/// 2017
		|| 	rarea p_lb_2017 p_ub_2017 mth ,  color(gs10) /// 
		|| 	line p_2017 mth , lpattern(dash) lwidth(medthick) color(gs0)    ///4
		|| 	scatter prop_2017 mth , symbol(Th) color(gs0) /// 
		/// 2018
		///|| 	rarea p_lb_2018 p_ub_2018 mth ,  color(gs10) /// 
		///|| 	line p_2018 mth , lpattern(shortdas) lwidth(medthick) color(gs0)    ///9
		///|| 	scatter prop_2018 mth , symbol(Sh) color(gs0) ///
, ylabel(0(0.2)1) ymtick(0(0.1)1) ytitle(Probability DENV positivity) ///
xtitle(Month)  xlabel(1 "jan" 2 "feb" 3 "mar" 4 "apr" 5 "may" 6 "jun" 7 "jul" ///
8 "aug" 9 "sep" 10 "okt" 11 "nov" 12 "dec", angle(35)) /// xscale(log) xlabel(0 5 10 15 20) xmtick(0(5)20)
legend(ring(0) position(1) order( 2 "2015" 5 "2017") ///
cols(1)) xsize(5.25) ///
scheme(s2mono) ///
graphregion(color(white)) ///
plotregion(lcolor(black)) title(AIC - coast - DENV ) ///
name(Figure_AICcoast_denv, replace) saving(Figure_AICcoast_denv, replace)



*********************************************************************************
** AIC - chikv - Coast
*********************************************************************************
clear
use "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_AIC_step3.dta"
set autotabgraphs on
cd "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Figures"

ta siteID2, m
keep if siteID2==1
ta siteID2, m

ta  yr chikv_pos_aic, row
bysort yr: ta mth chikv_pos_aic  , row

mkspline mthplT = mth, cubic nknots(4) displayknots

bysort mth: egen prop_2014 = mean(chikv_pos_aic) if yr==2014
xi: logistic chikv_pos_aic mthplT1 mthplT2 mthplT3 if yr==2014
predict p_2014 			if yr==2014 , p
predict logodds_2014 	if yr==2014 , xb
predict stderr_2014 	if yr==2014 , stdp
generate lodds_ub_2014 = logodds_2014 + 1.96*stderr_2014  		if yr==2014
generate lodds_lb_2014 = logodds_2014 - 1.96*stderr_2014  		if yr==2014
generate p_ub_2014 = exp(lodds_ub_2014)/(1+exp(lodds_ub_2014))  if yr==2014
generate p_lb_2014 = exp(lodds_lb_2014)/(1+exp(lodds_lb_2014))  if yr==2014

*bysort mth: egen prop_2015 = mean(chikv_pos_aic) if yr==2015
*xi: logistic chikv_pos_aic mthplT1 mthplT2 mthplT3 if yr==2015
*predict p_2015 			if yr==2015 , p
*predict logodds_2015 	if yr==2015 , xb
*predict stderr_2015 	if yr==2015 , stdp
*generate lodds_ub_2015 = logodds_2015 + 1.96*stderr_2015  		if yr==2015
*generate lodds_lb_2015 = logodds_2015 - 1.96*stderr_2015  		if yr==2015
*generate p_ub_2015 = exp(lodds_ub_2015)/(1+exp(lodds_ub_2015))  if yr==2015
*generate p_lb_2015 = exp(lodds_lb_2015)/(1+exp(lodds_lb_2015))  if yr==2015

bysort mth: egen prop_2016 = mean(chikv_pos_aic) if yr==2016
xi: logistic chikv_pos_aic mthplT1 mthplT2 mthplT3 if yr==2016
predict p_2016 			if yr==2016 , p
predict logodds_2016 	if yr==2016 , xb
predict stderr_2016 	if yr==2016 , stdp
generate lodds_ub_2016 = logodds_2016 + 1.96*stderr_2016  		if yr==2016
generate lodds_lb_2016 = logodds_2016 - 1.96*stderr_2016  		if yr==2016
generate p_ub_2016 = exp(lodds_ub_2016)/(1+exp(lodds_ub_2016))  if yr==2016
generate p_lb_2016 = exp(lodds_lb_2016)/(1+exp(lodds_lb_2016))  if yr==2016

*bysort mth: egen prop_2017 = mean(chikv_pos_aic) if yr==2017
*xi: logistic chikv_pos_aic mthplT1 mthplT2 mthplT3 if yr==2017
*predict p_2017 			if yr==2017 , p
*predict logodds_2017 	if yr==2017 , xb
*predict stderr_2017 	if yr==2017 , stdp
*generate lodds_ub_2017 = logodds_2017 + 1.96*stderr_2017  		if yr==2017
*generate lodds_lb_2017 = logodds_2017 - 1.96*stderr_2017  		if yr==2017
*generate p_ub_2017 = exp(lodds_ub_2017)/(1+exp(lodds_ub_2017))  if yr==2017
*generate p_lb_2017 = exp(lodds_lb_2017)/(1+exp(lodds_lb_2017))  if yr==2017

*bysort mth: egen prop_2018 = mean(chikv_pos_aic) if yr==2018
*xi: logistic chikv_pos_aic mthplT1 mthplT2 mthplT3 if yr==2018
*predict p_2018 			if yr==2018 , p
*predict logodds_2018 	if yr==2018 , xb
*predict stderr_2018 	if yr==2018 , stdp
*generate lodds_ub_2018 = logodds_2018 + 1.96*stderr_2018  		if yr==2018
*generate lodds_lb_2018 = logodds_2018 - 1.96*stderr_2018  		if yr==2018
*generate p_ub_2018 = exp(lodds_ub_2018)/(1+exp(lodds_ub_2018))  if yr==2018
*generate p_lb_2018 = exp(lodds_lb_2018)/(1+exp(lodds_lb_2018))  if yr==2018

sort mth
twoway 	/// 2014
		 rarea p_lb_2014 p_ub_2014 mth ,  color(gs10) ///
		|| 	line p_2014 mth , lpattern(longdash_dot) lwidth(medthick) color(gs0)    ///2
		|| 	scatter prop_2014 mth , symbol(X) color(gs0) ///
		/// 2015
		/// || rarea p_lb_2015 p_ub_2015 mth ,  color(gs10) /// 
		/// || 	line p_2015 mth , lpattern(shortdash) lwidth(medthick) color(gs0)    ///5
		/// || 	scatter prop_2015 mth , symbol(Oh) color(gs0) ///
		/// 2016
		|| rarea p_lb_2016 p_ub_2016 mth ,  color(gs10) /// 
		|| 	line p_2016 mth , lpattern(shortdash_dot) lwidth(medthick) color(gs0)    ///5
		|| 	scatter prop_2016 mth , symbol(Dh) color(gs0) /// 
		/// 2017
		/// ||  rarea p_lb_2017 p_ub_2017 mth ,  color(gs10) /// 
		/// || 	line p_2017 mth , lpattern(dash) lwidth(medthick) color(gs0)    ///11
		/// || 	scatter prop_2017 mth , symbol(Th) color(gs0) /// 
		/// 2018
		///|| rarea p_lb_2018 p_ub_2018 mth ,  color(gs10) /// 
		///|| 	line p_2018 mth , lpattern(shortdas) lwidth(medthick) color(gs0)    ///9
		///|| 	scatter prop_2018 mth , symbol(Sh) color(gs0) ///
, ylabel(0(0.2)1) ymtick(0(0.1)1) ytitle(Probability chikv positivity) ///
xtitle(Month)  xlabel(1 "jan" 2 "feb" 3 "mar" 4 "apr" 5 "may" 6 "jun" 7 "jul" ///
8 "aug" 9 "sep" 10 "okt" 11 "nov" 12 "dec", angle(35)) /// xscale(log) xlabel(0 5 10 15 20) xmtick(0(5)20)
legend(ring(0) position(1) order(2 "2014" 5 "2016"  ) ///
cols(1)) xsize(5.25) ///
scheme(s2mono) ///
graphregion(color(white)) ///
plotregion(lcolor(black)) title(AIC - west - CHIKV) ///
name(Figure_AICwest_chikv, replace) saving(Figure_AICwest_chikv, replace)


********************************************************************************
** AIC - chikv - Coast
********************************************************************************
clear
use "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_AIC_step3.dta"
set autotabgraphs on
cd "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Figures"

ta siteID2, m
keep if siteID2==2
ta siteID2, m

ta  yr chikv_pos_aic, row

mkspline mthplT = mth, cubic nknots(4) displayknots

bysort mth: egen prop_2014 = mean(chikv_pos_aic) if yr==2014
xi: logistic chikv_pos_aic mthplT1 mthplT2 mthplT3 if yr==2014
predict p_2014 			if yr==2014 , p
predict logodds_2014 	if yr==2014 , xb
predict stderr_2014 	if yr==2014 , stdp
generate lodds_ub_2014 = logodds_2014 + 1.96*stderr_2014  		if yr==2014
generate lodds_lb_2014 = logodds_2014 - 1.96*stderr_2014  		if yr==2014
generate p_ub_2014 = exp(lodds_ub_2014)/(1+exp(lodds_ub_2014))  if yr==2014
generate p_lb_2014 = exp(lodds_lb_2014)/(1+exp(lodds_lb_2014))  if yr==2014

bysort mth: egen prop_2015 = mean(chikv_pos_aic) if yr==2015
xi: logistic chikv_pos_aic mthplT1 mthplT2 mthplT3 if yr==2015
predict p_2015 			if yr==2015 , p
predict logodds_2015 	if yr==2015 , xb
predict stderr_2015 	if yr==2015 , stdp
generate lodds_ub_2015 = logodds_2015 + 1.96*stderr_2015  		if yr==2015
generate lodds_lb_2015 = logodds_2015 - 1.96*stderr_2015  		if yr==2015
generate p_ub_2015 = exp(lodds_ub_2015)/(1+exp(lodds_ub_2015))  if yr==2015
generate p_lb_2015 = exp(lodds_lb_2015)/(1+exp(lodds_lb_2015))  if yr==2015

*bysort mth: egen prop_2016 = mean(chikv_pos_aic) if yr==2016
*xi: logistic chikv_pos_aic mthplT1 mthplT2 mthplT3 if yr==2016
*predict p_2016 			if yr==2016 , p
*predict logodds_2016 	if yr==2016 , xb
*predict stderr_2016 	if yr==2016 , stdp
*generate lodds_ub_2016 = logodds_2016 + 1.96*stderr_2016  		if yr==2016
*generate lodds_lb_2016 = logodds_2016 - 1.96*stderr_2016  		if yr==2016
*generate p_ub_2016 = exp(lodds_ub_2016)/(1+exp(lodds_ub_2016))  if yr==2016
*generate p_lb_2016 = exp(lodds_lb_2016)/(1+exp(lodds_lb_2016))  if yr==2016

bysort mth: egen prop_2017 = mean(chikv_pos_aic) if yr==2017
xi: logistic chikv_pos_aic mthplT1 mthplT2 mthplT3 if yr==2017
predict p_2017 			if yr==2017 , p
predict logodds_2017 	if yr==2017 , xb
predict stderr_2017 	if yr==2017 , stdp
generate lodds_ub_2017 = logodds_2017 + 1.96*stderr_2017  		if yr==2017
generate lodds_lb_2017 = logodds_2017 - 1.96*stderr_2017  		if yr==2017
generate p_ub_2017 = exp(lodds_ub_2017)/(1+exp(lodds_ub_2017))  if yr==2017
generate p_lb_2017 = exp(lodds_lb_2017)/(1+exp(lodds_lb_2017))  if yr==2017

bysort mth: egen prop_2018 = mean(chikv_pos_aic) if yr==2018
replace prop_2018=. if yr==2018 & mth==6
replace prop_2018=. if yr==2018 & mth==7
replace prop_2018=. if yr==2018 & mth==8
replace prop_2018=. if yr==2018 & mth==9
replace prop_2018=. if yr==2018 & mth==10
replace prop_2018=. if yr==2018 & mth==11
replace prop_2018=. if yr==2018 & mth==12
xi: logistic chikv_pos_aic mthplT1 mthplT2 mthplT3 if yr==2018 & mth<6
predict p_2018 			 if yr==2018 & mth<6, p
predict logodds_2018 	 if yr==2018 & mth<6, xb
predict stderr_2018 	 if yr==2018 & mth<6, stdp
generate lodds_ub_2018 = logodds_2018 + 1.96*stderr_2018  		 if yr==2018 & mth<6
generate lodds_lb_2018 = logodds_2018 - 1.96*stderr_2018  		 if yr==2018 & mth<6
generate p_ub_2018 = exp(lodds_ub_2018)/(1+exp(lodds_ub_2018))   if yr==2018 & mth<6
generate p_lb_2018 = exp(lodds_lb_2018)/(1+exp(lodds_lb_2018))   if yr==2018 & mth<6

sort mth
twoway 	/// 2014
		|| rarea p_lb_2014 p_ub_2014 mth ,  color(gs10) ///
		|| 	line p_2014 mth , lpattern(longdash_dot) lwidth(medthick) color(gs0)    ///2
		|| 	scatter prop_2014 mth , symbol(X) color(gs0) ///
		/// 2015
		|| rarea p_lb_2015 p_ub_2015 mth ,  color(gs10) /// 
		|| 	line p_2015 mth , lpattern(shortdash) lwidth(medthick) color(gs0)    ///5
		|| 	scatter prop_2015 mth , symbol(Oh) color(gs0) ///
		/// 2016
		/// rarea p_lb_2016 p_ub_2016 mth ,  color(gs10) /// 
		/// || 	line p_2016 mth , lpattern(shortdash_dot) lwidth(medthick) color(gs0)    ///5
		/// || 	scatter prop_2016 mth , symbol(Dh) color(gs0) /// 
		/// 2017
		|| rarea p_lb_2017 p_ub_2017 mth ,  color(gs10) /// 
		|| 	line p_2017 mth , lpattern(dash) lwidth(medthick) color(gs0)    ///8
		|| 	scatter prop_2017 mth , symbol(Th) color(gs0) /// 
		/// 2018
		|| rarea p_lb_2018 p_ub_2018 mth ,  color(gs10) /// 
		|| 	line p_2018 mth , lpattern(shortdas) lwidth(medthick) color(gs0)    ///11
		|| 	scatter prop_2018 mth , symbol(Sh) color(gs0) ///
, ylabel(0(0.2)1) ymtick(0(0.1)1) ytitle(Probability chikv positivity) ///
xtitle(Month)  xlabel(1 "jan" 2 "feb" 3 "mar" 4 "apr" 5 "may" 6 "jun" 7 "jul" ///
8 "aug" 9 "sep" 10 "okt" 11 "nov" 12 "dec", angle(35)) /// xscale(log) xlabel(0 5 10 15 20) xmtick(0(5)20)
legend(ring(0) position(1) order(2 "2014" 5 "2015" 8 "2017" 11 "2018") ///
cols(1)) xsize(5.25) ///
scheme(s2mono) ///
graphregion(color(white)) ///
plotregion(lcolor(black)) title(AIC - coast - CHIKV) ///
name(Figure_AICcoast_chikv, replace) saving(Figure_AICcoast_chikv, replace)















********************************************************************************
** AIC - DENV by age
********************************************************************************
clear
use "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_AIC_step3.dta"

drop if denv_pos_aic==.

*ta Acute, m
*keep if Acute==1
*ta Acute, m

bysort ageyrs: egen prop_TOT = mean(denv_pos_aic) 
ta ageyrs denv_igg_y , row
mkspline ageSpl = ageyrs, cubic nknots(4) displayknots

*test for interaciton with Site on a continous scale
xi: logistic denv_pos_aic i.siteID*ageSpl1 i.siteID*ageSpl2 i.siteID*ageSpl3
test _IsitXageSp_2 _IsitXageSp_3 _IsitXageSp_4 _IsitXageSpa2 _IsitXageSpa3 _IsitXageSpa4 _IsitXageSpb2 _IsitXageSpb3 _IsitXageSpb4
*not significant, so it is okay to present it overall

*Generate syntax for figure
xi: logistic denv_pos_aic  ageSpl1  ageSpl2 ageSpl3
test ageSpl1 ageSpl2 ageSpl3
predict p_TOT 			 , p
predict logodds_TOT 	 , xb
predict stderr_TOT 	 , stdp
generate lodds_ub_TOT = logodds_TOT + 1.96*stderr_TOT  		
generate lodds_lb_TOT = logodds_TOT - 1.96*stderr_TOT  		
generate p_ub_TOT = exp(lodds_ub_TOT)/(1+exp(lodds_ub_TOT))  
generate p_lb_TOT = exp(lodds_lb_TOT)/(1+exp(lodds_lb_TOT))  
sort age
twoway 		 rarea p_lb_TOT p_ub_TOT ageyrs ,  color(gs10) ///
		|| 	line p_TOT ageyrs , lpattern(longdash_dot) lwidth(medthick) color(gs0)    ///2
		|| 	scatter prop_TOT ageyrs , symbol(X) color(gs0) ///
, ylabel(0(0.1)0.5) ymtick(0(0.1)0.5) ytitle(Probability DENV positivity) ///
xtitle(age) ///
legend(ring(0) position(1) order(3 "Observed" 2 "Expected" 1 "95%CI") ///
cols(1)) xsize(5.25) ///
scheme(s2mono) ///
graphregion(color(white)) ///
plotregion(lcolor(black)) title(AIC - DENV) ///
name(Figure_HCC, replace) saving(Figure_HCC, replace)



********************************************************************************
** AIC - CHIKV by age
********************************************************************************
clear
use "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_AIC_step3.dta"

drop if chikv_pos_aic==.

*ta Acute, m
*keep if Acute==1
*ta Acute, m

bysort ageyrs: egen prop_TOT = mean(chikv_pos_aic) 
ta ageyrs chikv_pos_aic , row
mkspline ageSpl = ageyrs, cubic nknots(4) displayknots

*test for interaciton with Site on a continous scale
xi: logistic chikv_pos_aic i.siteID*ageSpl1 i.siteID*ageSpl2 i.siteID*ageSpl3
test _IsitXageSp_2 _IsitXageSp_3 _IsitXageSp_4 _IsitXageSpa2 _IsitXageSpa3 _IsitXageSpa4 _IsitXageSpb2 _IsitXageSpb3 _IsitXageSpb4
*not significant, so it is okay to present it overall

*Generate syntax for figure
xi: logistic chikv_pos_aic  ageSpl1  ageSpl2 ageSpl3
test ageSpl1 ageSpl2 ageSpl3
predict p_TOT 			 , p
predict logodds_TOT 	 , xb
predict stderr_TOT 	 , stdp
generate lodds_ub_TOT = logodds_TOT + 1.96*stderr_TOT  		
generate lodds_lb_TOT = logodds_TOT - 1.96*stderr_TOT  		
generate p_ub_TOT = exp(lodds_ub_TOT)/(1+exp(lodds_ub_TOT))  
generate p_lb_TOT = exp(lodds_lb_TOT)/(1+exp(lodds_lb_TOT))  
sort age
twoway 		 rarea p_lb_TOT p_ub_TOT ageyrs ,  color(gs10) ///
		|| 	line p_TOT ageyrs , lpattern(longdash_dot) lwidth(medthick) color(gs0)    ///2
		|| 	scatter prop_TOT ageyrs , symbol(X) color(gs0) ///
, ylabel(0(0.1)0.5) ymtick(0(0.1)0.5) ytitle(Probability CHIKV positivity) ///
xtitle(age) ///
legend(ring(0) position(1) order(3 "Observed" 2 "Expected" 1 "95%CI") ///
cols(1)) xsize(5.25) ///
scheme(s2mono) ///
graphregion(color(white)) ///
plotregion(lcolor(black)) title(AIC - CHIKV) ///
name(Figure_HCC, replace) saving(Figure_HCC, replace)

