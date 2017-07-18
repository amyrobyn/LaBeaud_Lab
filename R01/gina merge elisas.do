cd "C:\Users\amykr\Downloads"
insheet using "tested.csv", clear case names
save tested, replace

insheet using "chikv.csv", clear case names
save chikv, replace


insheet using "denv.csv", clear case names
save denv, replace

merge m:1 id using "chikv"
rename _merge tested_vs_chikv
export excel using "merged_chikv", firstrow(variables) nolabel replace

use tested, clear
merge m:1 id using "denv"
rename _merge tested_vs_denv
export excel using "merged_denv", firstrow(variables) nolabel replace
