cd "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\CSVs nov29_16"
use "prevalent.dta", clear
collapse (sum) Stanford_CHIKV_IGG Stanford_DENV_IGG visit_s, by(id_wide city)
gen denvexposed = . 
gen chikvexposed = . 
bysort id_wide: replace chikvexposed = 1 if Stanford_CHIKV_IGG >0 &Stanford_CHIKV_IGG<.
bysort id_wide: replace chikvexposed = 0 if Stanford_CHIKV_IGG ==0 
bysort id_wide: replace denvexposed  = 1 if Stanford_DENV_IGG >0 & Stanford_DENV_IGG<.
bysort id_wide: replace denvexposed  = 0 if Stanford_DENV_IGG ==0 

tab chikvexposed city, m
tab denvexposed city, m

export excel using "nov29_exposed", firstrow(variables) replace

export excel id_wide visit_s denvexposed city using "denv_igg_msambweni" if city =="Msambweni" & denvexposed==1 |city =="Ukunda" & denvexposed==1, firstrow(variables) replace
export excel id_wide visit_s chikvexposed city using "chikv_igg_msambweni" if city =="Msambweni" & chikvexposed ==1|city =="Ukunda" & chikvexposed ==1, firstrow(variables) replace
