cd "C:\Users\amykr\Google Drive\labeaud\noah table 1 nov 10"
insheet using "noah table 1 nov 10.csv", comma clear

*recode infection groups into three categories
replace infectiongroup = 0 if totalinfections == 0
replace infectiongroup = 1 if totalinfections == 1
replace infectiongroup = 2 if totalinfections >1

*create histogram of each outcome/predictor
foreach var in  age householdexpendituresthousandksh useabednet hiv firstpregnancy bmi hgbgdl infantsex1male0female birthweightgm lengthcm headcircumferencecm dubowitzscore totalinfections infected uninfected infectiongroup{
histogram `var'
graph export `var'.tif, width(4000) replace
}

*create table 1 by infection groups.
table1, vars(age contn \ householdexpendituresthousandksh contn\ useabednet bin\ hiv bin\ firstpregnancy bin\ bmi contn\ hgbgdl contn\ infantsex1male0female bin\ birthweightgm contn\ lengthcm contn\ headcircumferencecm contn\ dubowitzscore contn\  bmi conts\lengthcm conts \ dubowitzscore conts\ ) by(infectiongroup) test    saving(noahtable1.xls, replace) 

