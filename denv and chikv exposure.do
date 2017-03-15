local output "C:\Users\amykr\Box Sync\U24 Project\data\"
cd "C:\Users\amykr\Box Sync\DENV CHIKV project\Lab Data\ELISA Database\ELISA Latest"
use elisa_merged, clear
collapse (sum)  stanforddenvigg_ stanfordchikvigg_, by(id_wide city)
gen denvexposed = . 
gen chikvexposed = . 
bysort id_wide: replace chikvexposed = 1 if stanfordchikvigg_ > 0 & stanfordchikvigg_<.
bysort id_wide: replace chikvexposed = 0 if stanfordchikvigg_ == 0 
bysort id_wide: replace denvexposed  = 1 if stanforddenvigg_ >0 & stanforddenvigg_<.
bysort id_wide: replace denvexposed  = 0 if stanforddenvigg_ ==0 

replace city = "msambweni" if city =="milani"
replace city = "msambweni" if city =="nganja"

tab chikvexposed city, m
tab denvexposed city, m

export excel using "`output'exposed", firstrow(variables) replace
outsheet id_wide denvexposed city using "`output'denv_igg_msambweni.csv" if city =="msambweni" & denvexposed==1 |city =="ukunda" & denvexposed==1, replace comma names
outsheet id_wide chikvexposed city using "`output'chikv_igg_msambweni.csv" if city =="msambweni" & chikvexposed ==1|city =="ukunda" & chikvexposed ==1,  replace comma names

ci denvexposed, bin
ci chikvexposed, bin
