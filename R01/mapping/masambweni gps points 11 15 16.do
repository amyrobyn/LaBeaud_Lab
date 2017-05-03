cd "C:\Users\amykr\Desktop\masambweni"

foreach dataset in  "Msambweni HCC Initial 06Nov16" "Msambweni HCC Follow two 06Nov16" "Msambweni HCC Follow three 06Nov16" "Msambweni HCC Follow one 06Nov16" "MILALANI HCCd" "MILALANI HCCc" "MILALANI HCCb" "MILALANI HCCa" "NGANJA HCCd" "NGANJA HCCc" "NGANJA HCCb" "NGANJA HCCa"{
insheet using "`dataset'.csv", comma clear name
save "`dataset'", replace
}
clear
append using  "Msambweni HCC Initial 06Nov16" "Msambweni HCC Follow two 06Nov16" "Msambweni HCC Follow three 06Nov16" "Msambweni HCC Follow one 06Nov16", force
merge m:m  studyid using "NGANJA HCCa"
drop _merge
save merged, replace
merge m:m  studyid using "NGANJA HCCb"
drop _merge
merge m:m  studyid using "NGANJA HCCc"
drop _merge
merge m:m  studyid using "NGANJA HCCd"

drop _merge
merge m:m  studyid using "MILALANI HCCa"

drop _merge
merge m:m  studyid using "MILALANI HCCb"

drop _merge
merge m:m  studyid using "MILALANI HCCc"

drop _merge
merge m:m  studyid using "MILALANI HCCd"


*keep  if site=="Msambweni"

replace stanfordchikvigg_c= "" if  stanfordchikvigg_c =="0.25"
foreach var in  stanfordchikvigg_a stanforddenvigg_a stanfordchikvigg_b stanforddenvigg_b stanfordchikvigg_c stanforddenvigg_c{
tab `var'
encode `var', gen(`var'int)
replace `var'int = `var'int-1
drop `var'
rename `var'int `var'
}

sum agemonth gender stanfordchikvigg_a stanforddenvigg_a stanfordchikvigg_b stanforddenvigg_b stanfordchikvigg_c stanforddenvigg_c  datesamplecollected_a
keep studyid agemonth gender stanfordchikvigg_a stanforddenvigg_a stanfordchikvigg_b stanforddenvigg_b stanfordchikvigg_c stanforddenvigg_c  datesamplecollected_a
order studyid stanfordchikvigg_a stanforddenvigg_a stanfordchikvigg_b stanforddenvigg_b stanfordchikvigg_c stanforddenvigg_c datesamplecollected_a agemonth gender 
 
outsheet using "C:\Users\amykr\Desktop\masambweni\masambweni_igg_nov15_2016.csv", comma nolabel replace
