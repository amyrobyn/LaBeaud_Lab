local output "C:\Users\amykr\Box Sync\U24 Project\data\"
cd "C:\Users\amykr\Box Sync\DENV CHIKV project\Lab Data\ELISA Database\ELISA Latest"
use elisa_merged, clear
replace city = "msambweni" if city =="milani"
replace city = "msambweni" if city =="nganja"

collapse (sum)  stanforddenvigg_ stanfordchikvigg_, by(id_wide city)
gen denvexposed = . 
gen chikvexposed = . 
bysort id_wide: replace chikvexposed = 1 if stanfordchikvigg_ > 0 & stanfordchikvigg_<. & stanforddenvigg_ ==0
bysort id_wide: replace chikvexposed = 0 if stanfordchikvigg_ == 0 

bysort id_wide: replace denvexposed  = 1 if stanforddenvigg_ >0 & stanforddenvigg_<. & stanfordchikvigg_ ==0
bysort id_wide: replace denvexposed  = 0 if stanforddenvigg_ ==0 

gen denv_chikv_exposed=.
bysort id_wide: replace denv_chikv_exposed= 1 if stanfordchikvigg_ >0 & stanfordchikvigg_<. & stanforddenvigg_ >0 & stanforddenvigg_<.
bysort id_wide: replace denv_chikv_exposed= 0 if stanforddenvigg_ ==0 & stanfordchikvigg_==0
tab denv_chikv_exposed city


gen chikv_denv_unexposed=.
bysort id_wide: replace chikv_denv_unexposed = 1 if stanforddenvigg_ ==0 & stanfordchikvigg_==0
bysort id_wide: replace chikv_denv_unexposed = 0 if stanforddenvigg_ >=1 & stanforddenvigg_ <. | stanfordchikvigg_>=1 & stanfordchikvigg_<.
tab chikv_denv_unexposed

tab chikvexposed city, m
tab denvexposed city, m

export excel using "`output'exposed", firstrow(variables) replace
outsheet id_wide denvexposed city using "`output'denv_igg_msambweni.csv" if city =="msambweni" & denvexposed==1 |city =="ukunda" & denvexposed==1, replace comma names
outsheet id_wide chikvexposed city using "`output'chikv_igg_msambweni.csv" if city =="msambweni" & chikvexposed ==1|city =="ukunda" & chikvexposed ==1,  replace comma names

ci denvexposed, bin
ci chikvexposed, bin
ci denv_chikv_exposed, bin
ci chikv_denv_unexposed, bin


gen site = "coast" if city =="msambweni"|city =="ukunda"
replace site = "west" if city !="msambweni" & city !="ukunda"
tab site

foreach group in denv_chikv_exposed chikv_denv_unexposed denvexposed chikvexposed{
tab `group' city if site =="coast"
}

