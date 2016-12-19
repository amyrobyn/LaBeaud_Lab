use "C:\Users\amykr\Downloads\output\output\prevalent.dta", clear

collapse (sum) Stanford_CHIKV_IGG Stanford_DENV_IGG, by(id_wide city)
gen denvexposed = . 
gen chikvexposed = . 
bysort id_wide: replace chikvexposed = 1 if Stanford_CHIKV_IGG >0 &Stanford_CHIKV_IGG<.
bysort id_wide: replace chikvexposed = 0 if Stanford_CHIKV_IGG ==0 
bysort id_wide: replace denvexposed  = 1 if Stanford_DENV_IGG >0 & Stanford_DENV_IGG<.
bysort id_wide: replace denvexposed  = 0 if Stanford_DENV_IGG ==0 

tab chikvexposed city, m
tab denvexposed city, m


export excel using "C:\Users\amykr\Downloads\output\nov29_exposed", firstrow(variables) replace
