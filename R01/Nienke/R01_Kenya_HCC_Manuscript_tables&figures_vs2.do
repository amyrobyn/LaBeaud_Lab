*R01_Kenya_HCC_Manuscript_tables&figures_vs1

********************************************************************************
**Numbers extracted for tables and figures
********************************************************************************

********************************************************************************
** HCC - Descriptives
********************************************************************************
clear

use "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_step3_complete2.dta"
cd "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Tabout"

*Follow-up records
bysort person_id: gen followUpRecords=_n
ta followUpRecords, m
di 2868/3835
drop followUpRecords

browse person_id redcap_event_name gender_aic gender_hcc dem_child_gender gender2 date_complete date_complete2 if gender2==.
browse person_id redcap_event_name date_of_birth dem_child_dob dob date_complete date_complete2 age if age==.

*Age continously
summ ageyrs, d
display r(p50) r(p25) r(p75)

summ age2015yrs, d
display r(p50) r(p25) r(p75)

*Descriptives by inclusion period
summarize yr_dob2, detail
display r(p50) r(p25) r(p75)

ta flowHCC, m
ta flowHCC igg_tested, row

ta flowHCC if siteID==1, m
ta flowHCC igg_tested if siteID==1, row

ta flowHCC if siteID==2, m
ta flowHCC igg_tested if siteID==2, row

ta flowHCC if siteID==3, m
ta flowHCC igg_tested if siteID==3, row

ta flowHCC if siteID==4, m
ta flowHCC igg_tested if siteID==4, row

ta flowHCC2, m
ta flowHCC3, m

*Date of birth
summarize yr_dob2 if flowHCC2==0, detail
display r(p50) r(p25) r(p75)
summarize yr_dob2 if flowHCC2==1, detail
display r(p50) r(p25) r(p75)
summarize yr_dob2 if flowHCC2==2, detail
display r(p50) r(p25) r(p75)
summarize yr_dob2 if flowHCC2==3, detail
display r(p50) r(p25) r(p75)
summarize yr_dob2 if flowHCC2==4, detail
display r(p50) r(p25) r(p75)
summarize yr_dob2 if flowHCC2==5, detail
display r(p50) r(p25) r(p75)
summarize yr_dob2 if flowHCC2==6, detail
display r(p50) r(p25) r(p75)
kwallis yr_dob2 , by (flowHCC2)

*Age in 2015
summarize age2015yrs, detail
display r(p50) r(p25) r(p75)
summarize age2015yrs if flowHCC2==0, detail
display r(p50) r(p25) r(p75)
summarize age2015yrs if flowHCC2==1, detail
display r(p50) r(p25) r(p75)
summarize age2015yrs if flowHCC2==2, detail
display r(p50) r(p25) r(p75)
summarize age2015yrs if flowHCC2==3, detail
display r(p50) r(p25) r(p75)
summarize age2015yrs if flowHCC2==4, detail
display r(p50) r(p25) r(p75)
summarize age2015yrs if flowHCC2==5, detail
display r(p50) r(p25) r(p75)
summarize age2015yrs if flowHCC2==6, detail
display r(p50) r(p25) r(p75)
kwallis age2015yrs , by (flowHCC2)

*SES
gen ses2=ses*5
replace ses2=int(ses2)

summarize ses2, detail
display r(p50) r(p25) r(p75)

summarize ses2 if flowHCC2==0, detail
display r(p50) r(p25) r(p75)
summarize ses2 if flowHCC2==1, detail
display r(p50) r(p25) r(p75)
summarize ses2 if flowHCC2==2, detail
display r(p50) r(p25) r(p75)
summarize ses2 if flowHCC2==3, detail
display r(p50) r(p25) r(p75)
summarize ses2 if flowHCC2==4, detail
display r(p50) r(p25) r(p75)
summarize ses2 if flowHCC2==5, detail
display r(p50) r(p25) r(p75)
summarize ses2 if flowHCC2==6, detail
display r(p50) r(p25) r(p75)
kwallis ses2 , by (flowHCC2)

tabout age2015Cat gender2 sesCat3 siteID flowHCC2 using "DescriptivesByInclusionPeriod-HCC.xls", replace cells(freq col) stats(chi2) f(0c 0p)
gen one=1
tabout age2015Cat gender2 sesCat3 siteID one using "DescriptivesTot-HCC.xls", replace cells(freq col) stats(chi2) f(0c 0p)

misstable summ flowHCC2 date_complete2
misstable summ age2015Cat gender2 sesCat3 siteID if flowHCC3==0







































********************************************************************************
** HCC - Risk factor analyses - DENV
********************************************************************************
clear
use "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_step3_complete_seroprevalenceAnlyses.dta"
cd "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Tabout"

*In principle you can also do this anlyses on al first records,
*however to make it consistant within the manuscript I think it is easier
*to do it among those categorized as 'initial-visit'  and 'catch-up' visit

*did not include toiletPosT3 variable

*Check 
ta flowHCC2, m

*Drop all those samples without IgG data
ta denv_igg_y, m
drop if denv_igg_y==.
ta denv_igg_y, m

********************************************************************************
tabout ageCat gender2 sesCat3 siteID siteID2 siteID3 /// demographics
roofTypeT3 floorTypeT3 numRoomsCat3 nrWndCat3 lghtSrT3 drnkWtSrT3 toiletTypeT3 nrSibHCat3 /// house circumstances
outdoorActyT3 travel msqtBitesT3 msqtCoilT3 msqtNetT3 ///exposure and protective measures
denv_igg_y ///
using "DENVseroprevalenceByriskFactors-HCC.xls", replace cells(freq row) stats(chi2) f(0c 0p)

misstable summ ageCat gender2 sesCat3 siteID  siteID2 siteID3  /// demographics
roofTypeT3 floorTypeT3 numRoomsCat3 nrWndCat3 nrSibHCat3 lghtSrT3 drnkWtSrT3 toiletTypeT3 /// house circumstances
outdoorActyT3 travel msqtBitesT3 msqtCoilT3 msqtNetT3 ///exposure and protective measures
denv_igg_y

*Age continously
summ ageyrs, d
display r(p50) r(p25) r(p75)

mkspline ageSpl = ageyrs, cubic nknots(4) displayknots
mat knots = r(knots) 

xi: logistic denv_igg_y ageSpl1 ageSpl2 ageSpl3
test ageSpl2 ageSpl3 
test ageSpl1 ageSpl2 ageSpl3
xbrcspline ageSpl, values(2 4 8 12) ref(4) eform matknots(knots)

*All categorical variables

char ageCat[omit]3 //change the reference group for age
char siteID[omit]3

xi: logistic denv_igg_y i.ageCat
di e(p)

est clear
foreach var of varlist gender2 sesCat3 siteID siteID2 siteID3  /// demographics
roofTypeT3 floorTypeT3 numRoomsCat3 nrWndCat3 nrWndCat3 lghtSrT3 drnkWtSrT3 toiletTypeT3 nrSibHCat3 /// house circumstances
outdoorActyT3 travel msqtBitesT3 msqtCoilT3 msqtNetT3 ///exposure and protective measures
{
eststo: xi: logistic denv_igg_y i.`var'
di e(p)
}
*

eststo DENVspos_BiAn_Tot_HCC: appendmodels est1 est2 est3 est4 est5 est6 est7 est8 est9 est10 ///  
est11 est12 est13 est14 est15 est16 est17 est18 est19

estout DENVspos_BiAn_Tot_HCC using "DENV_BiAn_Tot_HCC.xls",  ///
cells("b(fmt(%9.2fc)) ci(par((   -  ))) p(fmt(%9.8fc))") ///
mlabel("Poisson log") label ///
collabels("") varlabels(_cons Constant) varwidth(10) modelwidth(10) prefoot("") ///
postfoot("CI in parentheses") legend style(tab) eform replace 


********************************************************************************
*Generate p-values

xi: logistic denv_igg_y i.gender2
test _Igender2_1

xi: logistic denv_igg_y i.sesCat3
test _IsesCat3_2 _IsesCat3_3

xi: logistic denv_igg_y i.siteID
test _IsiteID_1 _IsiteID_2 _IsiteID_4

xi: logistic denv_igg_y i.siteID2
test  _IsiteID2_2

xi: logistic denv_igg_y i.siteID3
test _IsiteID3_2

xi: logistic denv_igg_y i.roofTypeT3
test _IroofTypeT_2

xi: logistic denv_igg_y i.floorTypeT3
test _IfloorType_2 

xi: logistic denv_igg_y i.numRoomsCat3
test _InumRoomsC_2 _InumRoomsC_3

xi: logistic denv_igg_y i.nrWndCat3
test _InrWndCat3_1 _InrWndCat3_2 _InrWndCat3_3

xi: logistic denv_igg_y i.lghtSrT3
test _IlghtSrT3_2

xi: logistic denv_igg_y i.drnkWtSrT3
test _IdrnkWtSrT_2 _IdrnkWtSrT_3

xi: logistic denv_igg_y i.toiletTypeT3
test _ItoiletTyp_2 _ItoiletTyp_3

xi: logistic denv_igg_y i.nrSibHCat3
test _InrSibHCat_2 _InrSibHCat_3 

xi: logistic denv_igg_y i.outdoorActyT3
test _IoutdoorAc_1

xi: logistic denv_igg_y i.travel
test _Itravel_1 

xi: logistic denv_igg_y i.msqtBitesT3
test _ImsqtBites_1

xi: logistic denv_igg_y i.msqtCoilT3
test _ImsqtCoilT_1

xi: logistic denv_igg_y i.msqtNetT3
test _ImsqtNetT3_1


********************************************************************************
*Start MV-analyses
*Type of floor, number of rooms, and number of windows have too many missing to incude in analyses

xi: logistic denv_igg_y ageSpl1 ageSpl2 ageSpl3 i.siteID2 i.siteID3 i.roofTypeT3 i.toiletTypeT3 i.nrSibHCat3 i.outdoorActyT3
test  ageSpl1 ageSpl2 ageSpl3
test  _IsiteID2_2
test _IsiteID3_2
test _IroofTypeT_2
test _ItoiletTyp_2 _ItoiletTyp_3
test _InrSibHCat_2 _InrSibHCat_3
test _IoutdoorAc_1

*outdoorActyT3
xi: logistic denv_igg_y ageSpl1 ageSpl2 ageSpl3 i.siteID2 i.siteID3 i.roofTypeT3 i.toiletTypeT3 i.nrSibHCat3 
test  ageSpl1 ageSpl2 ageSpl3
test  _IsiteID2_2
test _IsiteID3_2
test _IroofTypeT_2
test _ItoiletTyp_2 _ItoiletTyp_3
test _InrSibHCat_2 _InrSibHCat_3

*toiletTypeT3
xi: logistic denv_igg_y ageSpl1 ageSpl2 ageSpl3 i.siteID2 i.siteID3 i.roofTypeT3 i.nrSibHCat3 
test  ageSpl1 ageSpl2 ageSpl3
test  _IsiteID2_2
test _IsiteID3_2
test _IroofTypeT_2
test _InrSibHCat_2 _InrSibHCat_3

*roofTypeT3
xi: logistic denv_igg_y ageSpl1 ageSpl2 ageSpl3 i.siteID2 i.siteID3 i.nrSibHCat3 
test  ageSpl1 ageSpl2 ageSpl3
test  _IsiteID2_2
test _IsiteID3_2
test _InrSibHCat_2 _InrSibHCat_3

*nrSibHCat3
xi: logistic denv_igg_y ageSpl1 ageSpl2 ageSpl3 i.siteID2 i.siteID3
xbrcspline ageSpl, values(2 4 8 12) ref(4) eform matknots(knots)
test  ageSpl1 ageSpl2 ageSpl3
test  _IsiteID2_2
test _IsiteID3_2

xi: logistic denv_igg_y i.siteID*ageSpl1 i.siteID*ageSpl2 i.siteID*ageSpl3
test  _IsitXageSp_2 _IsitXageSpa2 _IsitXageSpb2 

xi: logistic denv_igg_y i.siteID2*ageSpl1 i.siteID2*ageSpl2 i.siteID2*ageSpl3
test  _IsitXageSp_2 _IsitXageSpa2 _IsitXageSpb2 

xi: logistic denv_igg_y i.siteID3*ageSpl1 i.siteID3*ageSpl2 i.siteID3*ageSpl3
test  _IsitXageSp_2 _IsitXageSpa2 _IsitXageSpb2 
*rural versus urban was significant different

xi: logistic denv_igg_y ageSpl1 ageSpl2 ageSpl3 if siteID3==1
xbrcspline ageSpl, values(2 4 8 12) ref(4) eform matknots(knots)

xi: logistic denv_igg_y ageSpl1 ageSpl2 ageSpl3 if siteID3==2
xbrcspline ageSpl, values(2 4 8 12) ref(4) eform matknots(knots)

*At the rural site it increase much more by age than at the urban site

*Final model:
est clear
eststo: xi: logistic denv_igg_y ageSpl1 ageSpl2 ageSpl3 i.siteID2 i.siteID3
estout est1 using "DENVspos_mvAnalysis_tot.xls",  ///
cells("b(fmt(%9.2fc)) ci(par((   -  ))) p(fmt(%9.8fc))") ///
mlabel("Poisson log") label ///
collabels("") varlabels(_cons Constant) varwidth(10) modelwidth(10) prefoot("") ///
postfoot("CI in parentheses") legend style(tab) eform replace 










********************************************************************************
** HCC - Risk factor analyses - CHIKV
********************************************************************************
clear
use "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_step3_complete_seroprevalenceAnlyses.dta"
cd "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Tabout"

summ ageyrs, d
display r(p50) r(p25) r(p75)

*Check whether we are only doing the analyses among those at initial visit
ta flowHCC, m

*Age continously
summ ageyrs, d
display r(p50) r(p25) r(p75)

summ age2015yrs, d
display r(p50) r(p25) r(p75)

*Drop all those without CHIKV data, such that we create the splines among those with IgG data
ta chikv_igg_y, m
keep if chikv_igg_y!=.
ta chikv_igg_y, m

*did not include toiletPosT3
*notice for travel we are using the crude reported variable, without carryforward/bacward as it is a variable that changes over time

tabout ageCat gender2 sesCat3 siteID siteID2 siteID3 /// demographics
roofTypeT3 floorTypeT3 numRoomsCat3 nrWndCat3 lghtSrT3 drnkWtSrT3 toiletTypeT3 nrSibHCat3 /// house circumstances
outdoorActyT3 travel msqtBitesT3 msqtCoilT3 msqtNetT3 ///exposure and protective measures
chikv_igg_y ///
using "chikvseroprevalenceByriskFactors-HCC.xls", replace cells(freq row) stats(chi2) f(0c 0p) show(all)

misstable summ ageCat gender2 sesCat3 siteID siteID2 siteID3  /// demographics
roofTypeT3 floorTypeT3 numRoomsCat3 nrSibHCat3 nrWndCat3 lghtSrT3 drnkWtSrT3 toiletTypeT3 /// house circumstances
outdoorActyT3 travel msqtBitesT3 msqtCoilT3 msqtNetT3 ///exposure and protective measures
chikv_igg_y

*Age continously
summ age2015yrs, d
display r(p50) r(p25) r(p75)

mkspline ageSpl = ageyrs, cubic nknots(4) displayknots
mat knots = r(knots) 

xi: logistic chikv_igg_y ageSpl1 ageSpl2 ageSpl3
test ageSpl2 ageSpl3 
test ageSpl1 ageSpl2 ageSpl3
xbrcspline ageSpl, values(2 4 8 12) ref(4) eform matknots(knots)

*All categorical varaibles
char ageCat[omit]3 //change the reference group for age
xi: logistic chikv_igg_y i.ageCat
di e(p)

est clear
foreach var of varlist ageCat gender2 sesCat3 siteID siteID2 siteID3  /// demographics
roofTypeT3 floorTypeT3 numRoomsCat3 nrWndCat3 lghtSrT3 drnkWtSrT3 toiletTypeT3 nrSibHCat3 /// house circumstances
outdoorActyT3 travel msqtBitesT3 msqtCoilT3 msqtNetT3 ///exposure and protective measures
{
eststo: xi: logistic chikv_igg_y i.`var'
di e(p)
}
*

eststo chikvspos_BiAn_Tot_HCC: appendmodels est1 est2 est3 est4 est5 est6 est7 est8 est9 est10 ///  
est11 est12 est13 est14 est15 est16 est17 est18 est19

estout chikvspos_BiAn_Tot_HCC using "chikv_BiAn_Tot_HCC.xls",  ///
cells("b(fmt(%9.2fc)) ci(par((   -  ))) p(fmt(%9.8fc))") ///
mlabel("Poisson log") label ///
collabels("") varlabels(_cons Constant) varwidth(10) modelwidth(10) prefoot("") ///
postfoot("CI in parentheses") legend style(tab) eform replace 


********************************************************************************
*Generate p-values

xi: logistic chikv_igg_y i.ageCat
test _IageCat_2 _IageCat_3 _IageCat_4 _IageCat_5

xi: logistic chikv_igg_y i.gender2
test _Igender2_1

xi: logistic chikv_igg_y i.sesCat3
test _IsesCat3_2 _IsesCat3_3

xi: logistic chikv_igg_y i.siteID
test _IsiteID_2 _IsiteID_3 _IsiteID_4

xi: logistic chikv_igg_y i.siteID2
test _IsiteID_2 _IsiteID_3 _IsiteID_4


xi: logistic chikv_igg_y i.siteID3
test _IsiteID_2 _IsiteID_3 _IsiteID_4

xi: logistic chikv_igg_y i.roofTypeT3
test _IroofTypeT_2

xi: logistic chikv_igg_y i.floorTypeT3
test _IfloorType_2 

xi: logistic chikv_igg_y i.numRoomsCat3
test _InumRoomsC_2 _InumRoomsC_3

xi: logistic chikv_igg_y i.nrWndCat3
test _InrWndCat3_1 _InrWndCat3_2 _InrWndCat3_3

xi: logistic chikv_igg_y i.lghtSrT3
test _IlghtSrT3_2

xi: logistic chikv_igg_y i.drnkWtSrT3
test _IdrnkWtSrT_2 _IdrnkWtSrT_3

xi: logistic chikv_igg_y i.toiletTypeT3
test _ItoiletTyp_2 _ItoiletTyp_3

xi: logistic chikv_igg_y i.nrSibHCat3
test _InrSibHCat_2 _InrSibHCat_3 

xi: logistic chikv_igg_y i.outdoorActyT3
test _IoutdoorAc_1

xi: logistic chikv_igg_y i.travel
test   _Itravel_1 

xi: logistic chikv_igg_y i.msqtBitesT3
test _ImsqtBites_1

xi: logistic chikv_igg_y i.msqtCoilT3
test _ImsqtCoilT_1

xi: logistic chikv_igg_y i.msqtNetT3
test _ImsqtNetT3_1


********************************************************************************
*Start MV-analyses

*Did not include roofTypeT3, floorTypeT3, because halve was missing

xi: logistic chikv_igg_y ageSpl1 ageSpl2 ageSpl3 i.gender2 i.siteID2 i.siteID3 i.lghtSrT3 i.toiletTypeT3 i.msqtBitesT3 i.msqtCoilT3 i.msqtNetT3
test  ageSpl1 ageSpl2 ageSpl3
test _Igender2_1
test  _IsiteID2_2
test _IsiteID3_2
test _IlghtSrT3_2 
test _ItoiletTyp_2 _ItoiletTyp_3
test _ImsqtBites_1
test _ImsqtCoilT_1
test _ImsqtNetT3_1

*toiletTypeT3
xi: logistic chikv_igg_y ageSpl1 ageSpl2 ageSpl3 i.gender2 i.siteID2 i.siteID3 i.lghtSrT3 i.msqtBitesT3 i.msqtCoilT3 i.msqtNetT3
test  ageSpl1 ageSpl2 ageSpl3
test _Igender2_1
test  _IsiteID2_2
test _IsiteID3_2
test _IlghtSrT3_2 
test _ImsqtBites_1
test _ImsqtCoilT_1
test _ImsqtNetT3_1

*gender2
xi: logistic chikv_igg_y ageSpl1 ageSpl2 ageSpl3 i.siteID2 i.siteID3 i.lghtSrT3 i.msqtBitesT3 i.msqtCoilT3 i.msqtNetT3
test  ageSpl1 ageSpl2 ageSpl3
test  _IsiteID2_2
test _IsiteID3_2
test _IlghtSrT3_2 
test _ImsqtBites_1
test _ImsqtCoilT_1
test _ImsqtNetT3_1

*msqtNetT3
xi: logistic chikv_igg_y ageSpl1 ageSpl2 ageSpl3 i.siteID2 i.siteID3 i.lghtSrT3 i.msqtBitesT3 i.msqtCoilT3
test  ageSpl1 ageSpl2 ageSpl3
test  _IsiteID2_2
test _IsiteID3_2
test _IlghtSrT3_2 
test _ImsqtBites_1
test _ImsqtCoilT_1

*msqtBitesT3
xi: logistic chikv_igg_y ageSpl1 ageSpl2 ageSpl3 i.siteID2 i.siteID3 i.lghtSrT3 i.msqtCoilT3
test  ageSpl1 ageSpl2 ageSpl3
test  _IsiteID2_2
test _IsiteID3_2
test _IlghtSrT3_2 
test _ImsqtCoilT_1

*msqtCoilT3
xi: logistic chikv_igg_y ageSpl1 ageSpl2 ageSpl3 i.siteID2 i.siteID3 i.lghtSrT3
test  ageSpl1 ageSpl2 ageSpl3
test  _IsiteID2_2
test _IsiteID3_2
test _IlghtSrT3_2 

*Final model
xi: logistic chikv_igg_y ageSpl1 ageSpl2 ageSpl3 i.siteID2 i.siteID3
test  ageSpl1 ageSpl2 ageSpl3
test  _IsiteID2_2
test _IsiteID3_2

xbrcspline ageSpl, values(2 4 8 12) ref(4) eform matknots(knots)

xi: logistic chikv_igg_y i.siteID*ageSpl1  i.siteID*ageSpl2  i.siteID*ageSpl3
test  _IsitXageSp_2 _IsitXageSp_3 _IsitXageSp_4 _IsitXageSpa2 _IsitXageSpa3 _IsitXageSpa4 _IsitXageSpb2 _IsitXageSpb3 _IsitXageSpb4 

*Final model:
est clear
xi: logistic chikv_igg_y ageSpl1 ageSpl2 ageSpl3 i.siteID2 i.siteID3
estout est1 using "CHIKVspos_mvAnalysis_tot-HCC.xls",  ///
cells("b(fmt(%9.2fc)) ci(par((   -  ))) p(fmt(%9.8fc))") ///
mlabel("Poisson log") label ///
collabels("") varlabels(_cons Constant) varwidth(10) modelwidth(10) prefoot("") ///
postfoot("CI in parentheses") legend style(tab) eform replace 







********************************************************************************
** HCC - DENV seropositivity by age
********************************************************************************
clear
use "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_step3_complete_seroprevalenceAnlyses.dta"

drop if denv_igg_y==.

bysort ageyrs: egen prop_TOT = mean(denv_igg_y) 
ta ageyrs denv_igg_y , row
mkspline ageSpl = ageyrs, cubic nknots(4) displayknots

*test for interaciton with Site on a continous scale
xi: logistic denv_igg_y i.siteID*ageSpl1 i.siteID*ageSpl2 i.siteID*ageSpl3
test _IsitXageSp_2 _IsitXageSp_3 _IsitXageSp_4 _IsitXageSpa2 _IsitXageSpa3 _IsitXageSpa4 _IsitXageSpb2 _IsitXageSpb3 _IsitXageSpb4
*not significant, so it is okay to present it overall

*Generate syntax for figure
xi: logistic denv_igg_y  ageSpl1  ageSpl2 ageSpl3
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
, ylabel(0(0.1)0.5) ymtick(0(0.1)0.5) ytitle(Probability DENV seropositivity) ///
xtitle(age) ///
legend(ring(0) position(1) order(3 "Observed" 2 "Expected" 1 "95%CI") ///
cols(1)) xsize(5.25) ///
scheme(s2mono) ///
graphregion(color(white)) ///
plotregion(lcolor(black)) title(HCC - DENV) ///
name(Figure_HCC, replace) saving(Figure_HCC, replace)


********************************************************************************
** HCC - CHIKV seropositivity by age
********************************************************************************
clear
use "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_step3_complete_seroprevalenceAnlyses.dta"

drop if chikv_igg_y==.

bysort ageyrs: egen prop_TOT = mean(chikv_igg_y) 
ta ageyrs chikv_igg_y , row
mkspline ageSpl = ageyrs, cubic nknots(4) displayknots

*test for interaciton with Site on a continous scale
xi: logistic chikv_igg_y i.siteID*ageSpl1 i.siteID*ageSpl2 i.siteID*ageSpl3
test _IsitXageSp_2 _IsitXageSp_3 _IsitXageSp_4 _IsitXageSpa2 _IsitXageSpa3 _IsitXageSpa4 _IsitXageSpb2 _IsitXageSpb3 _IsitXageSpb4
*not significant, so it is okay to present it overall

*Generate syntax for figure
xi: logistic chikv_igg_y  ageSpl1  ageSpl2 ageSpl3
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
, ylabel(0(0.1)0.5) ymtick(0(0.1)0.5) ytitle(Probability CHIKV seropositivity) ///
xtitle(age) ///
legend(ring(0) position(1) order(3 "Observed" 2 "Expected" 1 "95%CI") ///
cols(1)) xsize(5.25) ///
scheme(s2mono) ///
graphregion(color(white)) ///
plotregion(lcolor(black)) title(HCC - CHIKV) ///
name(Figure_HCC, replace) saving(Figure_HCC, replace)




********************************************************************************
** HCC - Riskfactors for serconversion
********************************************************************************

clear
use "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_step3_complete_seroconversionAnlyses.dta"
cd "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Tabout\"

*Check who are in the dataset
ta flowHCC2, m
ta nthRecHCC2, m
ta flowHCC2 nthRecHCC2, m

ta denv_sconv_1stRec nthRecHCC2, m
ta denv_sconv_1stRec, m

*Drop those without labdata
ta denv_sconv_1stRec, m
drop if denv_sconv_1stRec==.
ta denv_sconv_1stRec, m

tabout ageCat gender2 sesCat3 siteID siteID2 siteID3 /// demographics
roofTypeT3 floorTypeT3 numRoomsCat3 nrWndCat3 lghtSrT3 drnkWtSrT3 toiletTypeT3 nrSibHCat3 /// house circumstances
outdoorActyT3 childTrav_denvT msqtBitesT3 msqtCoilT3 msqtNetT3 ///exposure and protective measures
denv_sconv_1stRec ///
using "DENVserconversionByriskFactors-HCC.xls", replace cells(freq row) stats(chi2) f(0c 0p)

misstable summ ageCat gender2 sesCat3 siteID siteID2 siteID3  /// demographics
roofTypeT3 floorTypeT3 numRoomsCat3 nrWndCat3 nrSibHCat3 nrWndCat3 lghtSrT3 drnkWtSrT3 toiletTypeT3 /// house circumstances
outdoorActyT3 childTrav_denvT msqtBitesT3 msqtCoilT3 msqtNetT3 ///exposure and protective measures
denv_sconv_1stRec

*******************************************************************************
**Make spline
summ age2015yrs, d
di r(p50) r(p25) r(p75)

mkspline ageSpl = ageyrs, cubic nknots(4) displayknots
mat knots = r(knots) 

logistic denv_sconv_1stRec ageSpl1 ageSpl2 ageSpl3
test ageSpl2 ageSpl3 // as this is not significant in principle it is not necessary to use splines, however as it gives flexibility in the analyses I will keep if
test ageSpl1 ageSpl2 ageSpl3

logisticdenv_sconv_1stRec ageyrs
test ageyrs

********************************************************************************
*Age output for table
logistic denv_sconv_1stRec ageSpl1 ageSpl2 ageSpl3
test ageSpl1 ageSpl2 ageSpl3
xbrcspline ageSpl, values(2 4 8 12) ref(4) eform matknots(knots)


*********************************************************************************
*Categorical variables
char ageCat[omit]3 //change the reference group for age

xi: logistic denv_sconv_1stRec i.ageCat
di e(p)

est clear
foreach var of varlist ageCat gender2 sesCat3 siteID siteID2 siteID3 /// demographics
roofTypeT3 floorTypeT3 numRoomsCat3 nrWndCat3 lghtSrT3 drnkWtSrT3 toiletTypeT3 nrSibHCat3 /// house circumstances
outdoorActyT3 childTrav_denvT msqtBitesT3 msqtCoilT3 msqtNetT3 ///exposure and protective measures
{
eststo: xi: logistic denv_sconv_1stRec i.`var'
di e(p)
}
*

eststo DENVspos_BiAn_Tot_HCC: appendmodels est1 est2 est3 est4 est5 est6 est7 est8 est9 est10 ///  
est11 est12 est13 est14 est15 est16 est17 

estout DENVspos_BiAn_Tot_HCC using "DENVsconv_BiAn_Tot_HCC.xls",  ///
cells("b(fmt(%9.2fc)) ci(par((   -  ))) p(fmt(%9.8fc))") ///
mlabel("Poisson log") label ///
collabels("") varlabels(_cons Constant) varwidth(10) modelwidth(10) prefoot("") ///
postfoot("CI in parentheses") legend style(tab) eform replace 


********************************************************************************
*Generate p-values

xi: logistic denv_sconv_1stRec i.ageCat
test _IageCat_1 _IageCat_2 _IageCat_4 _IageCat_5

xi: logistic denv_sconv_1stRec i.gender2
test _Igender2_1

xi: logistic denv_sconv_1stRec i.sesCat3
test _IsesCat3_2 _IsesCat3_3

xi: logistic denv_sconv_1stRec i.siteID
test _IsiteID_2 _IsiteID_3 _IsiteID_4

xi: logistic denv_sconv_1stRec i.siteID2
test _IsiteID2_2

xi: logistic denv_sconv_1stRec i.siteID3
test _IsiteID3_2 

xi: logistic denv_sconv_1stRec i.roofTypeT3
test _IroofTypeT_2

xi: logistic denv_sconv_1stRec i.floorTypeT3
test _IfloorType_2 

xi: logistic denv_sconv_1stRec i.numRoomsCat3
test _InumRoomsC_2 _InumRoomsC_3

xi: logistic denv_sconv_1stRec i.nrWndCat3
test _InrWndCat3_1 _InrWndCat3_2 _InrWndCat3_3

xi: logistic denv_sconv_1stRec i.lghtSrT3
test _IlghtSrT3_2

xi: logistic denv_sconv_1stRec i.drnkWtSrT3
test _IdrnkWtSrT_2 _IdrnkWtSrT_3

xi: logistic denv_sconv_1stRec i.toiletTypeT3
test _ItoiletTyp_2 _ItoiletTyp_3
char toiletTypeT3[omit]2 
xi: logistic denv_sconv_1stRec i.toiletTypeT3
test _ItoiletTyp_1 _ItoiletTyp_3
char toiletTypeT3[omit]1 

xi: logistic denv_sconv_1stRec i.nrSibHCat3
test _InrSibHCat_2 _InrSibHCat_3 

xi: logistic denv_sconv_1stRec i.outdoorActyT3
test _IoutdoorAc_1

xi: logistic denv_sconv_1stRec i.childTrav_denvT
test _IchildTrav_1

xi: logistic denv_sconv_1stRec i.msqtBitesT3
test _ImsqtBites_1

xi: logistic denv_sconv_1stRec i.msqtCoilT3
test _ImsqtCoilT_1

xi: logistic denv_sconv_1stRec i.msqtNetT3
test _ImsqtNetT3_1


********************************************************************************
*Start MV-analyses
*Type of floor, number of rooms, and number of windows have too many missing to incude in analyses

*p<0.20 for AIC I used p<0.10 because it had many more variables
*site, roof type, floor type (too many missing), number of rooms (too many missing), main sourc eof light, main sourc eof water
*toilet type, child travelled, 

*I believe that if you use rural VS west you should force in west versus coast in the model

xi: logistic denv_sconv_1stRec i.siteID2 i.siteID3 i.lghtSrT3 i.drnkWtSrT3 i.toiletTypeT3 i.childTrav_denvT
test _IsiteID2_2 
test _IsiteID3_2
test _IlghtSrT3_2
test _IdrnkWtSrT_2 _IdrnkWtSrT_3
test _ItoiletTyp_2 _ItoiletTyp_3
test _IchildTrav_1

*lghtSrT3
xi: logistic denv_sconv_1stRec i.siteID2 i.siteID3 i.drnkWtSrT3 i.toiletTypeT3 i.childTrav_denvT
test _IsiteID2_2 
test _IsiteID3_2
test _IdrnkWtSrT_2 _IdrnkWtSrT_3
test _ItoiletTyp_2 _ItoiletTyp_3
test _IchildTrav_1

*drnkWtSrT3
xi: logistic denv_sconv_1stRec i.siteID2 i.siteID3 i.toiletTypeT3 i.childTrav_denvT
test _IsiteID2_2 
test _IsiteID3_2
test _ItoiletTyp_2 _ItoiletTyp_3
test _IchildTrav_1

*toiletTypeT3
xi: logistic denv_sconv_1stRec i.siteID2 i.siteID3 i.childTrav_denvT
test _IsiteID2_2 
test _IsiteID3_2
test _IchildTrav_1

*Final model
xi: logistic denv_sconv_1stRec i.siteID2 i.siteID3 i.childTrav_denvT
test _IsiteID2_2 
test _IsiteID3_2


*Final model:
est clear
eststo: xi: logistic denv_sconv_1stRec i.siteID2 i.siteID3 i.childTrav_denvT
estout est1 using "DENVsconv_mvAnalysis_tot-HCC.xls",  ///
cells("b(fmt(%9.2fc)) ci(par((   -  ))) p(fmt(%9.8fc))") ///
mlabel("Poisson log") label ///
collabels("") varlabels(_cons Constant) varwidth(10) modelwidth(10) prefoot("") ///
postfoot("CI in parentheses") legend style(tab) eform replace 

ta  siteID3 denv_sconv_1stRec if siteID2==1, row
ta  siteID3 denv_sconv_1stRec if siteID2==2, row







********************************************************************************
** HCC - CHIKV - Riskfactors for serconversion
********************************************************************************

clear
use "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_step3_complete_seroconversionAnlyses.dta"
cd "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Tabout\"

***Drop 
ta chikv_sconv_1stRec, m
drop if chikv_sconv_1stRec==.
ta chikv_sconv_1stRec, m

*tabulate
tabout ageCat gender2 sesCat3 siteID siteID2 siteID3 /// demographics
roofTypeT3 floorTypeT3 numRoomsCat3 nrWndCat3 lghtSrT3 drnkWtSrT3 toiletTypeT3 nrSibHCat3 /// house circumstances
outdoorActyT3 childTrav_chikvT msqtBitesT3 msqtCoilT3 msqtNetT3 ///exposure and protective measures
chikv_sconv_1stRec ///
using "chikvserconversionByriskFactors-HCC.xls", replace cells(freq row) stats(chi2) f(0c 0p)

misstable summ ageCat gender2 sesCat3 siteID  siteID2 siteID3 /// demographics
roofTypeT3 floorTypeT3 numRoomsCat3 nrWndCat3 nrSibHCat3 nrWndCat3 lghtSrT3 drnkWtSrT3 toiletTypeT3 /// house circumstances
outdoorActyT3 childTrav_chikvT msqtBitesT3 msqtCoilT3 msqtNetT3 ///exposure and protective measures
chikv_sconv_1stRec

*******************************************************************************
**Make spline, Des want to use age as a continous variable
summ age2015yrs, d
di r(p50) r(p25) r(p75)

mkspline ageSpl = ageyrs, cubic nknots(4) displayknots
mat knots = r(knots) 

logistic chikv_sconv_1stRec ageSpl1 ageSpl2 ageSpl3 
test ageSpl2 ageSpl3 // as this is not significant in principle it is not necessary to use splines, however as it gives flexibility in the analyses I will keep if
test ageSpl1 ageSpl2 ageSpl3

logistic chikv_sconv_1stRec ageyrs
test ageyrs


********************************************************************************
*Age output for table
logistic chikv_sconv_1stRec ageSpl1 ageSpl2 ageSpl3
test ageSpl1 ageSpl2 ageSpl3
xbrcspline ageSpl, values(2 4 8 12) ref(4) eform matknots(knots)

*********************************************************************************
*Categorical variables

char ageCat[omit]3 //change the reference group for age

xi: logistic chikv_sconv_1stRec i.ageCat
di e(p)

est clear
foreach var of varlist ageCat gender2 sesCat3 siteID  siteID2 siteID3 /// demographics
roofTypeT3 floorTypeT3 numRoomsCat3 nrWndCat3 lghtSrT3 drnkWtSrT3 toiletTypeT3 nrSibHCat3 /// house circumstances
outdoorActyT3 childTrav_chikvT msqtBitesT3 msqtCoilT3 msqtNetT3 ///exposure and protective measures
{
eststo: xi: logistic chikv_sconv_1stRec i.`var'
di e(p)
}
*

eststo chikvspos_BiAn_Tot_HCC: appendmodels est1 est2 est3 est4 est5 est6 est7 est8 est9 est10 ///  
est11 est12 est13 est14 est15 est16 est17 est18 est19

estout chikvspos_BiAn_Tot_HCC using "chikvsconv_BiAn_Tot_HCC.xls",  ///
cells("b(fmt(%9.2fc)) ci(par((   -  ))) p(fmt(%9.8fc))") ///
mlabel("Poisson log") label ///
collabels("") varlabels(_cons Constant) varwidth(10) modelwidth(10) prefoot("") ///
postfoot("CI in parentheses") legend style(tab) eform replace 


********************************************************************************
*Generate p-values

xi: logistic chikv_sconv_1stRec i.ageCat
test _IageCat_1 _IageCat_2 _IageCat_4 _IageCat_5

xi: logistic chikv_sconv_1stRec i.gender2
test _Igender2_1

xi: logistic chikv_sconv_1stRec i.sesCat3
test _IsesCat3_2 _IsesCat3_3

xi: logistic chikv_sconv_1stRec i.siteID
test _IsiteID_2 _IsiteID_3 _IsiteID_4

xi: logistic chikv_sconv_1stRec i.siteID2
test _IsiteID

xi: logistic chikv_sconv_1stRec i.siteID3
test _IsiteID

xi: logistic chikv_sconv_1stRec i.roofTypeT3
test _IroofTypeT_2

xi: logistic chikv_sconv_1stRec i.floorTypeT3
test _IfloorType_2 

xi: logistic chikv_sconv_1stRec i.numRoomsCat3
test _InumRoomsC_2 _InumRoomsC_3

xi: logistic chikv_sconv_1stRec i.nrWndCat3
test _InrWndCat3_1 _InrWndCat3_2 _InrWndCat3_3

xi: logistic chikv_sconv_1stRec i.lghtSrT3
test _IlghtSrT3_2

xi: logistic chikv_sconv_1stRec i.drnkWtSrT3
test _IdrnkWtSrT_2 _IdrnkWtSrT_3

xi: logistic chikv_sconv_1stRec i.toiletTypeT3
test _ItoiletTyp_2 _ItoiletTyp_3
char toiletTypeT3[omit]2 
xi: logistic chikv_sconv_1stRec i.toiletTypeT3
test _ItoiletTyp_1 _ItoiletTyp_3
char toiletTypeT3[omit]1 

xi: logistic chikv_sconv_1stRec i.nrSibHCat3
test _InrSibHCat_2 _InrSibHCat_3 

xi: logistic chikv_sconv_1stRec i.outdoorActyT3
test _IoutdoorAc_1

xi: logistic chikv_sconv_1stRec i.childTrav_chikvT
test _IchildTrav_1

xi: logistic chikv_sconv_1stRec i.msqtBitesT3
test _ImsqtBites_1

xi: logistic chikv_sconv_1stRec i.msqtCoilT3
test _ImsqtCoilT_1

xi: logistic chikv_sconv_1stRec i.msqtNetT3
test _ImsqtNetT3_1


********************************************************************************
*Start MV-analyses
*Type of floor, number of rooms, and number of windows have too many missing to incude in analyses

*p<0.20 --> siteID, floor type, number of rooms, nr of windows, main light source, toilet type, number of siblings, child travelled

xi: logistic chikv_sconv_1stRec i.siteID2 i.siteID3 i.numRoomsCat3 i.lghtSrT3 i.nrWndCat3 i.nrSibHCat3 i.drnkWtSrT3 i.childTrav_chikvT
test _IsiteID2_2 
test _IsiteID3_2 
test _InumRoomsC_2 _InumRoomsC_3
test _IlghtSrT3_2 
test _InrWndCat3_1 _InrWndCat3_2 _InrWndCat3_3
test  _InrSibHCat_2  _InrSibHCat_3
test _IdrnkWtSrT_2 _IdrnkWtSrT_3
test  _IchildTrav_1 

*lghtSrT3
xi: logistic chikv_sconv_1stRec i.siteID2 i.siteID3 i.numRoomsCat3 i.nrWndCat3 i.nrSibHCat3 i.drnkWtSrT3 i.childTrav_chikvT
test _IsiteID2_2 
test _IsiteID3_2 
test _InumRoomsC_2 _InumRoomsC_3
test _InrWndCat3_1 _InrWndCat3_2 _InrWndCat3_3
test  _InrSibHCat_2  _InrSibHCat_3
test _IdrnkWtSrT_2 _IdrnkWtSrT_3
test  _IchildTrav_1 

*drnkWtSrT3
xi: logistic chikv_sconv_1stRec i.siteID2 i.siteID3 i.numRoomsCat3 i.nrWndCat3 i.nrSibHCat3 i.childTrav_chikvT
test _IsiteID2_2 
test _IsiteID3_2 
test _InumRoomsC_2 _InumRoomsC_3
test _InrWndCat3_1 _InrWndCat3_2 _InrWndCat3_3
test  _InrSibHCat_2  _InrSibHCat_3
test  _IchildTrav_1 

*nrWndCat3
xi: logistic chikv_sconv_1stRec i.siteID2 i.siteID3 i.numRoomsCat3 i.nrSibHCat3 i.childTrav_chikvT
test _IsiteID2_2 
test _IsiteID3_2 
test _InumRoomsC_2 _InumRoomsC_3
test  _InrSibHCat_2  _InrSibHCat_3
test  _IchildTrav_1 

*numRoomsCat3
xi: logistic chikv_sconv_1stRec i.siteID2 i.siteID3 i.nrSibHCat3 i.childTrav_chikvT
test _IsiteID2_2 
test _IsiteID3_2 
test  _InrSibHCat_2  _InrSibHCat_3
test  _IchildTrav_1 

*nrSibHCat3
xi: logistic chikv_sconv_1stRec i.siteID2 i.siteID3 i.childTrav_chikvT
test _IsiteID2_2 
test _IsiteID3_2 
test  _IchildTrav_1 

*Interaction
xi: logistic chikv_sconv_1stRec i.siteID*i.childTrav_chikvT
test _IsitXchi_2_1 _IsitXchi_3_1 _IsitXchi_4_1

bysort siteID: ta childTrav_chikvT chikv_sconv_1stRec, row
*You do have some power to show an association


*Final model:
est clear
eststo: xi: logistic chikv_sconv_1stRec i.siteID2 i.siteID3 i.childTrav_chikvT
estout est1 using "CHIKVsconv_mvAnalysis_tot-HCC.xls",  ///
cells("b(fmt(%9.2fc)) ci(par((   -  ))) p(fmt(%9.8fc))") ///
mlabel("Poisson log") label ///
collabels("") varlabels(_cons Constant) varwidth(10) modelwidth(10) prefoot("") ///
postfoot("CI in parentheses") legend style(tab) eform replace 





********************************************************************************
** HCC - DENV and CHIKV over time
********************************************************************************
clear
use "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_step3_complete2.dta"

drop if yr==1900

ta denv_igg_y, m
ta chikv_igg_y, m
ta yr denv_igg_y, row
ta yr chikv_igg_y, row

ta denv_sconv_1stRec, m
ta chikv_sconv_1stRec, m
ta yr denv_sconv_1stRec, row
ta yr chikv_sconv_1stRec, row

ta denv_sconv_y, m
ta chikv_sconv_y, m
ta yr denv_sconv_y, row
ta yr chikv_sconv_y, row

ta denv_serop_carFrw, m
ta chikv_serop_carFrw, m
ta yr denv_serop_carFrw, row
ta yr chikv_serop_carFrw, row

*Identify last record within a calendar-year and use that to estimate prevalence by year















********************************************************************************
** HCC - DENV over time
********************************************************************************
*stata does not know how to make _n in a subset of the dataset, so I am going to do a syntax more intensive way

clear
use "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_step3_complete2.dta"

ta yr, m
keep if yr==2014
ta yr, m

ta denv_serop_carFrw, m
drop if denv_serop_carFrw==.
ta denv_serop_carFrw, m

bysort person_id: gen n2014=_n

keep person_id redcap_event_name n2014

save "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_DENVnth2014.dta", replace

*2015
clear
use "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_step3_complete2.dta"

ta yr, m
keep if yr==2015
ta yr, m

ta denv_serop_carFrw, m
drop if denv_serop_carFrw==.
ta denv_serop_carFrw, m

bysort person_id: gen n2015=_n

keep person_id redcap_event_name n2015

save "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_DENVnth2015.dta" , replace

*2016
clear
use "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_step3_complete2.dta"

ta yr, m
keep if yr==2016
ta yr, m

ta denv_serop_carFrw, m
drop if denv_serop_carFrw==.
ta denv_serop_carFrw, m

bysort person_id: gen n2016=_n

keep person_id redcap_event_name n2016

save "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_DENVnth2016.dta" , replace

*2017
clear
use "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_step3_complete2.dta"

ta yr, m
keep if yr==2017
ta yr, m

ta denv_serop_carFrw, m
drop if denv_serop_carFrw==.
ta denv_serop_carFrw, m

bysort person_id: gen n2017=_n

keep person_id redcap_event_name n2017

save "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_DENVnth2017.dta" , replace

*2018
clear
use "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_step3_complete2.dta"

ta yr, m
keep if yr==2018
ta yr, m

ta denv_serop_carFrw, m
drop if denv_serop_carFrw==.
ta denv_serop_carFrw, m

bysort person_id: gen n2018=_n

keep person_id redcap_event_name n2018

save "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_DENVnth2018.dta" , replace
clear

********************************************************************************
**merge
use "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_step3_complete2.dta"

ta yr, m
drop if yr==1900
drop if yr==.
ta yr, m

ta denv_serop_carFrw, m
drop if denv_serop_carFrw==.
ta denv_serop_carFrw, m

drop _merge
merge m:1 person_id redcap_event_name using  "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_DENVnth2014.dta"
ta yr _merge, m

drop _merge
merge m:1 person_id redcap_event_name using  "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_DENVnth2015.dta"
ta yr _merge, m

drop _merge
merge m:1 person_id redcap_event_name using  "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_DENVnth2016.dta"
ta yr _merge, m

drop _merge
merge m:1 person_id redcap_event_name using  "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_DENVnth2017.dta"
ta yr _merge, m

drop _merge
merge m:1 person_id redcap_event_name using  "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_DENVnth2018.dta"
ta yr _merge, m

ta yr, m
drop if yr==1900
ta yr, m

egen N2014 = total(yr==2014), by(person_id)
egen N2015 = total(yr==2015), by(person_id)
egen N2016 = total(yr==2016), by(person_id)
egen N2017 = total(yr==2017), by(person_id)
egen N2018 = total(yr==2018), by(person_id)

browse person_id nthRecHCC2 yr n2014 N2014  n2015 N2015  n2016 N2016  n2017 N2017  n2018 N2018

gen keep=.
replace keep=1 if n2014==N2014
replace keep=1 if n2015==N2015
replace keep=1 if n2016==N2016
replace keep=1 if n2017==N2017
replace keep=1 if n2018==N2018
ta keep ,m
keep if keep==1
ta keep, m

ta denv_serop_carFrw yr, m col

save "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_DENViggYr_AllRecords.dta", replace
clear

*ALL RECORDS
*denv_serop |                           yr
*   _carFrw |      2014       2015       2016       2017       2018 |     Total
*-----------+-------------------------------------------------------+----------
*         0 |     2,603      2,493      2,283      2,059        963 |    10,401 
*           |     97.60      96.40      94.77      93.21      96.11 |     95.66 
*-----------+-------------------------------------------------------+----------
*         1 |        64         93        126        150         39 |       472 
*           |      2.40       3.60       5.23       6.79       3.89 |      4.34 
*-----------+-------------------------------------------------------+----------
*     Total |     2,667      2,586      2,409      2,209      1,002 |    10,873 
*           |    100.00     100.00     100.00     100.00     100.00 |    100.00 


clear
use "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_DENViggYr_AllRecords.dta"

collapse (mean) denv_spoc_hcc_bar = denv_serop_carFrw (semean) se = denv_serop_carFrw , by (yr)

generate lb = denv_spoc_hcc_bar - 1.96*se 
generate ub = denv_spoc_hcc_bar + 1.96*se  

twoway (bar denv_spoc_hcc_bar yr, barw(0.6)) || ///
	   (rcap lb ub yr)  ///
, ytitle(DENV seroprevalence (%))  xtitle(Year) title(HCC - DENV) ///
ytick(0(0.05)0.15) ylabel(0 .05 "5" .1 "10" .15 "15") ///
xsize(6) scheme(s2mono) graphregion(color(white)) ///
plotregion(lcolor(black)) legend(off) 

clear

clear
use "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_DENViggYr_AllRecords.dta"

ta age2015Cat, m
drop if age2015Cat==.
ta age2015Cat, m

collapse (mean) denv_spoc_hcc_bar = denv_serop_carFrw (semean) se = denv_serop_carFrw , by (yr age2015Cat)

generate lb = denv_spoc_hcc_bar - 1.96*se 
generate ub = denv_spoc_hcc_bar + 1.96*se  

replace lb=0 if lb<0

generate yrAge = yr    	if 	age2015Cat==1
replace  yrAge = yr+6  	if 	age2015Cat==2
replace  yrAge = yr+12  if  age2015Cat==3

sort yrAge

twoway (bar denv_spoc_hcc_bar yrAge if yr==2014) ///
       (bar denv_spoc_hcc_bar yrAge if yr==2015) ///
       (bar denv_spoc_hcc_bar yrAge if yr==2016) ///
       (bar denv_spoc_hcc_bar yrAge if yr==2017) ///
	   (bar denv_spoc_hcc_bar yrAge if yr==2018) ///
	   (rcap lb ub yrAge), ///
legend(ring(0) position(11) order(1 "2014" 2 "2015" 3 "2016" 4 "2017" 5 "2018")) ///
xlabel(2016 "0-4" 2022 "5-9" 2027 "10-15") ///
ytitle(DENV seroprevalence (%))  xtitle(Age cohort) title(HCC - DENV) ///
ytick(0(0.05)0.15) ylabel(0 .05 "5" .1 "10" .15 "15") ///
xsize(6) scheme(s2mono) graphregion(color(white)) ///
plotregion(lcolor(black)) 

clear













********************************************************************************
** HCC - chikv over time
********************************************************************************
*stata does not know how to make _n in a subset of the dataset, so I am going to do a syntax more intensive way

********************************************************************************
** HCC - chikv over time
********************************************************************************
*stata does not know how to make _n in a subset of the dataset, so I am going to do a syntax more intensive way

clear
use "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_step3_complete2.dta"

ta yr, m
keep if yr==2014
ta yr, m

ta chikv_serop_carFrw, m
drop if chikv_serop_carFrw==.
ta chikv_serop_carFrw, m

bysort person_id: gen n2014=_n

keep person_id redcap_event_name n2014

save "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_chikvnth2014.dta", replace

*2015
clear
use "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_step3_complete2.dta"

ta yr, m
keep if yr==2015
ta yr, m

ta chikv_serop_carFrw, m
drop if chikv_serop_carFrw==.
ta chikv_serop_carFrw, m

bysort person_id: gen n2015=_n

keep person_id redcap_event_name n2015

save "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_chikvnth2015.dta" , replace

*2016
clear
use "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_step3_complete2.dta"

ta yr, m
keep if yr==2016
ta yr, m

ta chikv_serop_carFrw, m
drop if chikv_serop_carFrw==.
ta chikv_serop_carFrw, m

bysort person_id: gen n2016=_n

keep person_id redcap_event_name n2016

save "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_chikvnth2016.dta" , replace

*2017
clear
use "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_step3_complete2.dta"

ta yr, m
keep if yr==2017
ta yr, m

ta chikv_serop_carFrw, m
drop if chikv_serop_carFrw==.
ta chikv_serop_carFrw, m

bysort person_id: gen n2017=_n

keep person_id redcap_event_name n2017

save "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_chikvnth2017.dta" , replace

*2018
clear
use "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_step3_complete2.dta"

ta yr, m
keep if yr==2018
ta yr, m

ta chikv_serop_carFrw, m
drop if chikv_serop_carFrw==.
ta chikv_serop_carFrw, m

bysort person_id: gen n2018=_n

keep person_id redcap_event_name n2018

save "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_chikvnth2018.dta" , replace
clear

********************************************************************************
**merge
use "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_step3_complete2.dta"

ta yr, m
drop if yr==1900
drop if yr==.
ta yr, m

ta chikv_serop_carFrw, m
drop if chikv_serop_carFrw==.
ta chikv_serop_carFrw, m

drop _merge
merge m:1 person_id redcap_event_name using  "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_chikvnth2014.dta"
ta yr _merge, m

drop _merge
merge m:1 person_id redcap_event_name using  "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_chikvnth2015.dta"
ta yr _merge, m

drop _merge
merge m:1 person_id redcap_event_name using  "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_chikvnth2016.dta"
ta yr _merge, m

drop _merge
merge m:1 person_id redcap_event_name using  "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_chikvnth2017.dta"
ta yr _merge, m

drop _merge
merge m:1 person_id redcap_event_name using  "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_chikvnth2018.dta"
ta yr _merge, m

ta yr, m
drop if yr==1900
ta yr, m

egen N2014 = total(yr==2014), by(person_id)
egen N2015 = total(yr==2015), by(person_id)
egen N2016 = total(yr==2016), by(person_id)
egen N2017 = total(yr==2017), by(person_id)
egen N2018 = total(yr==2018), by(person_id)

browse person_id nthRecHCC2 yr n2014 N2014  n2015 N2015  n2016 N2016  n2017 N2017  n2018 N2018

gen keep=.
replace keep=1 if n2014==N2014
replace keep=1 if n2015==N2015
replace keep=1 if n2016==N2016
replace keep=1 if n2017==N2017
replace keep=1 if n2018==N2018
ta keep ,m
keep if keep==1
ta keep, m

ta chikv_serop_carFrw yr, m col

save "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_chikviggYr_AllRecords.dta", replace
clear


*chikv_sero |                           yr
*  p_carFrw |      2014       2015       2016       2017       2018 |     Total
*-----------+-------------------------------------------------------+----------
*         0 |     2,554      2,407      2,202      1,976        947 |    10,086 
*           |     95.73      93.08      91.37      89.45      94.51 |     92.74 
*-----------+-------------------------------------------------------+----------
*         1 |       114        179        208        233         55 |       789 
*           |      4.27       6.92       8.63      10.55       5.49 |      7.26 
*-----------+-------------------------------------------------------+----------
*     Total |     2,668      2,586      2,410      2,209      1,002 |    10,875 
*           |    100.00     100.00     100.00     100.00     100.00 |    100.00 


clear
use "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_chikviggYr_AllRecords.dta"

collapse (mean) chikv_spoc_hcc_bar = chikv_serop_carFrw (semean) se = chikv_serop_carFrw , by (yr)

generate lb = chikv_spoc_hcc_bar - 1.96*se 
generate ub = chikv_spoc_hcc_bar + 1.96*se  

twoway (bar chikv_spoc_hcc_bar yr, barw(0.6)) || ///
	   (rcap lb ub yr)  ///
, ytitle(CHIKV seroprevalence (%))  xtitle(Year) title(HCC - CHIKV) ///
ytick(0(0.05)0.15) ylabel(0 .05 "5" .1 "10" .15 "15" ) ///
xsize(6) scheme(s2mono) graphregion(color(white)) ///
plotregion(lcolor(black)) legend(off) 


clear
use "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_CHIKViggYr_AllRecords.dta"

ta age2015Cat, m
drop if age2015Cat==.
ta age2015Cat, m

ta chikv_serop_carFrw, m

collapse (mean) chikv_spoc_hcc_bar = chikv_serop_carFrw (semean) se = chikv_serop_carFrw , by (yr age2015Cat)

generate lb = chikv_spoc_hcc_bar - 1.96*se 
generate ub = chikv_spoc_hcc_bar + 1.96*se  

replace lb=0 if lb<0

generate yrAge = yr    	if 	age2015Cat==1
replace  yrAge = yr+6  	if 	age2015Cat==2
replace  yrAge = yr+12  if  age2015Cat==3

sort yrAge

twoway (bar chikv_spoc_hcc_bar yrAge if yr==2014) ///
       (bar chikv_spoc_hcc_bar yrAge if yr==2015) ///
       (bar chikv_spoc_hcc_bar yrAge if yr==2016) ///
       (bar chikv_spoc_hcc_bar yrAge if yr==2017) ///
	   (bar chikv_spoc_hcc_bar yrAge if yr==2018) ///
	   (rcap lb ub yrAge), ///
legend(ring(0) position(11) order(1 "2014" 2 "2015" 3 "2016" 4 "2017" 5 "2018")) ///
xlabel(2016 "0-4" 2022 "5-9" 2027 "10-15") ///
ytitle(CHIKV seroprevalence (%))  xtitle(Age cohort) title(HCC - CHIKV) ///
ytick(0(0.05)0.15) ylabel(0 .05 "5" .1 "10" .15 "15") ///
xsize(6) scheme(s2mono) graphregion(color(white)) ///
plotregion(lcolor(black)) 

clear

































********************************************************************************
**DENV seroprevalence complete Cases
********************************************************************************

clear
use "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_step3_complete2.dta"

bysort person_id: gen N=_N
ta N, m

keep if N==7
ta N, m

*_N unequal to the flowHCC2 (visitF; ie I would expect the same n), this is inherent to this dataset

save "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_CompleteCase.dta", replace

clear
use "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_CompleteCase.dta"

ta yr, m
keep if yr==2014
ta yr, m

ta denv_serop_carFrw, m
drop if denv_serop_carFrw==.
ta denv_serop_carFrw, m

bysort person_id: gen n2014=_n

keep person_id redcap_event_name n2014

save "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_DENVnth2014.dta", replace

*2015
clear
use "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_CompleteCase.dta"

ta yr, m
keep if yr==2015
ta yr, m

ta denv_serop_carFrw, m
drop if denv_serop_carFrw==.
ta denv_serop_carFrw, m

bysort person_id: gen n2015=_n

keep person_id redcap_event_name n2015

save "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_DENVnth2015.dta" , replace

*2016
clear
use "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_CompleteCase.dta"

ta yr, m
keep if yr==2016
ta yr, m

ta denv_serop_carFrw, m
drop if denv_serop_carFrw==.
ta denv_serop_carFrw, m

bysort person_id: gen n2016=_n

keep person_id redcap_event_name n2016

save "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_DENVnth2016.dta" , replace

*2017
clear
use "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_CompleteCase.dta"

ta yr, m
keep if yr==2017
ta yr, m

ta denv_serop_carFrw, m
drop if denv_serop_carFrw==.
ta denv_serop_carFrw, m

bysort person_id: gen n2017=_n

keep person_id redcap_event_name n2017

save "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_DENVnth2017.dta" , replace

*2018
clear
use "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_CompleteCase.dta"

ta yr, m
keep if yr==2018
ta yr, m

ta denv_serop_carFrw, m
drop if denv_serop_carFrw==.
ta denv_serop_carFrw, m

bysort person_id: gen n2018=_n

keep person_id redcap_event_name n2018

save "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_DENVnth2018.dta" , replace
clear

********************************************************************************
**merge
use "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_CompleteCase.dta"

ta yr, m
drop if yr==1900
drop if yr==.
ta yr, m

ta denv_serop_carFrw, m
drop if denv_serop_carFrw==.
ta denv_serop_carFrw, m

drop _merge
merge m:1 person_id redcap_event_name using  "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_DENVnth2014.dta"
ta yr _merge, m

drop _merge
merge m:1 person_id redcap_event_name using  "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_DENVnth2015.dta"
ta yr _merge, m

drop _merge
merge m:1 person_id redcap_event_name using  "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_DENVnth2016.dta"
ta yr _merge, m

drop _merge
merge m:1 person_id redcap_event_name using  "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_DENVnth2017.dta"
ta yr _merge, m

drop _merge
merge m:1 person_id redcap_event_name using  "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_DENVnth2018.dta"
ta yr _merge, m

ta yr, m
drop if yr==1900
ta yr, m

egen N2014 = total(yr==2014), by(person_id)
egen N2015 = total(yr==2015), by(person_id)
egen N2016 = total(yr==2016), by(person_id)
egen N2017 = total(yr==2017), by(person_id)
egen N2018 = total(yr==2018), by(person_id)

browse person_id nthRecHCC2 yr n2014 N2014  n2015 N2015  n2016 N2016  n2017 N2017  n2018 N2018

gen keep=.
replace keep=1 if n2014==N2014
replace keep=1 if n2015==N2015
replace keep=1 if n2016==N2016
replace keep=1 if n2017==N2017
replace keep=1 if n2018==N2018
ta keep ,m
keep if keep==1
ta keep, m

ta denv_serop_carFrw yr, m col

save "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_DENViggYr_CompleteCase.dta", replace
clear

*COMPLEYR CASES

*denv_serop |                           yr
*   _carFrw |      2014       2015       2016       2017       2018 |     Total
*-----------+-------------------------------------------------------+----------
*         0 |       813        810        791        774        399 |     3,587 
*           |     97.48      96.20      93.61      91.60      95.45 |     94.79 
*-----------+-------------------------------------------------------+----------
*         1 |        21         32         54         71         19 |       197 
*           |      2.52       3.80       6.39       8.40       4.55 |      5.21 
*-----------+-------------------------------------------------------+----------
*     Total |       834        842        845        845        418 |     3,784 
*           |    100.00     100.00     100.00     100.00     100.00 |    100.00 


*ALL RECORDS
*denv_serop |                           yr
*   _carFrw |      2014       2015       2016       2017       2018 |     Total
*-----------+-------------------------------------------------------+----------
*         0 |     2,603      2,493      2,283      2,059        963 |    10,401 
*           |     97.60      96.40      94.77      93.21      96.11 |     95.66 
*-----------+-------------------------------------------------------+----------
*         1 |        64         93        126        150         39 |       472 
*           |      2.40       3.60       5.23       6.79       3.89 |      4.34 
*-----------+-------------------------------------------------------+----------
*     Total |     2,667      2,586      2,409      2,209      1,002 |    10,873 
*           |    100.00     100.00     100.00     100.00     100.00 |    100.00 


clear
use "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_DENViggYr_CompleteCase.dta"

collapse (mean) denv_spoc_hcc_bar = denv_serop_carFrw (semean) se = denv_serop_carFrw , by (yr)

generate lb = denv_spoc_hcc_bar - 1.96*se 
generate ub = denv_spoc_hcc_bar + 1.96*se  

twoway (bar denv_spoc_hcc_bar yr, barw(0.6)) || ///
	   (rcap lb ub yr)  ///
, ytitle(DENV prevalence (%))  xtitle(Year) title(AIC - DENV) ///
ytick(0(0.1)0.4) ylabel(0 .1 "10" .2 "20" .3 "30" .4 "40") ///
xsize(6) scheme(s2mono) graphregion(color(white)) ///
plotregion(lcolor(black)) legend(off) 





























********************************************************************************
** HCC - DENV seroconversion by age
********************************************************************************
clear
use "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_step3_complete_gee_seroconversionAnalyses.dta"

drop if denv_sconv_y==.

*we are using denv_sconv_y, rather than denv_sconv_1stRec, as age changes over time and seroconversion TOO!

bysort ageyrs: egen prop_TOT = mean(denv_sconv_y) 
ta ageyrs denv_sconv_y , row
mkspline ageSpl = ageyrs, cubic nknots(4) displayknots

*test for interaciton with Site on a continous scale
xi: xtgee denv_sconv_y  i.siteID*ageSpl1 i.siteID*ageSpl2 i.siteID*ageSpl3, family(binomial) corr(exc) eform 
test _IsitXageSp_2 _IsitXageSp_3 _IsitXageSp_4 _IsitXageSpa2 _IsitXageSpa3 _IsitXageSpa4 _IsitXageSpb2 _IsitXageSpb3 _IsitXageSpb4
*not significant, so it is okay to present it overall

*Generate syntax for figure
xi: xtgee denv_sconv_y   ageSpl1 ageSpl2 ageSpl3, family(binomial) corr(exc) eform 
test ageSpl1 ageSpl2 ageSpl3

predictnl phat = normal(_b[_cons] + _b[ageSpl1]*ageSpl1 + _b[ageSpl2]*ageSpl2 + _b[ageSpl3]*ageSpl3 ), se(phat_se) 

generate lb_phat = phat - 1.96*phat_se
generate ub_phat = phat + 1.96*phat_se

sort age
twoway 		 rarea lb_phat ub_phat ageyrs ,  color(gs10) ///
		|| 	line phat ageyrs , lpattern(longdash_dot) lwidth(medthick) color(gs0)    ///2
		|| 	scatter prop_TOT ageyrs , symbol(X) color(gs0) ///
, ylabel(0(0.1)0.5) ymtick(0(0.1)0.5) ytitle(Probability DENV seropositivity) ///
xtitle(age) ///
legend(ring(0) position(1) order(3 "Observed" 2 "Expected" 1 "95%CI") ///
cols(1)) xsize(5.25) ///
scheme(s2mono) ///
graphregion(color(white)) ///
plotregion(lcolor(black)) title(HCC - total study population - DENV seroconversion) ///
name(Figure_HCC, replace) saving(Figure_HCC, replace)



********************************************************************************
** HCC - CHIKV seroconversion by age
********************************************************************************
clear
use "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_HCC_step3_complete_gee_seroconversionAnalyses.dta"
ta chikv_sconv_y, m
drop if chikv_sconv_y==.
ta chikv_sconv_y, m

bysort ageyrs: egen prop_TOT = mean(chikv_sconv_y) 
ta ageyrs chikv_sconv_y , row
mkspline ageSpl = ageyrs, cubic nknots(4) displayknots

*test for interaciton with Site on a continous scale
xi: logistic chikv_sconv_y i.siteID*ageSpl1 i.siteID*ageSpl2 i.siteID*ageSpl3
test _IsitXageSp_2 _IsitXageSp_3 _IsitXageSp_4 _IsitXageSpa2 _IsitXageSpa3 _IsitXageSpa4 _IsitXageSpb2 _IsitXageSpb3 _IsitXageSpb4
*not significant, so it is okay to present it overall

*Generate syntax for figure
xi: xtgee chikv_sconv_y   ageSpl1 ageSpl2 ageSpl3, family(binomial) corr(exc) eform 
test ageSpl1 ageSpl2 ageSpl3

predictnl phat = normal(_b[_cons] + _b[ageSpl1]*ageSpl1 + _b[ageSpl2]*ageSpl2 + _b[ageSpl3]*ageSpl3 ), se(phat_se) 

generate lb_phat = phat - 1.96*phat_se
generate ub_phat = phat + 1.96*phat_se

sort age
twoway 		 rarea lb_phat ub_phat ageyrs ,  color(gs10) ///
		|| 	line phat ageyrs , lpattern(longdash_dot) lwidth(medthick) color(gs0)    ///2
		|| 	scatter prop_TOT ageyrs , symbol(X) color(gs0) ///
, ylabel(0(0.1)0.5) ymtick(0(0.1)0.5) ytitle(Probability CHIKV seroconversion) ///
xtitle(age) ///
legend(ring(0) position(1) order(3 "Observed" 2 "Expected" 1 "95%CI") ///
cols(1)) xsize(5.25) ///
scheme(s2mono) ///
graphregion(color(white)) ///
plotregion(lcolor(black)) title(HCC - total study population - CHIKV seropositivity) ///
name(Figure_HCC, replace) saving(Figure_HCC, replace)







