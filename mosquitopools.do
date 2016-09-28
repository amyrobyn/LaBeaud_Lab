import excel "/Users/amykrystosik/Box Sync/Amy Krystosik's Files/mosquito_pools/Master Mosquito Leg Pooling Database_krystosikSeptember28_16.xlsx", sheet("Pool Database") firstrow case(lower) clear
save "/Users/amykrystosik/Box Sync/Amy Krystosik's Files/mosquito_pools/pools.dta", replace
import excel "/Users/amykrystosik/Box Sync/Amy Krystosik's Files/mosquito_pools/Master Mosquito Leg Pooling Database_krystosikSeptember28_16.xlsx", sheet("aedes Results 1 -454") firstrow case(lower) clear
save "/Users/amykrystosik/Box Sync/Amy Krystosik's Files/mosquito_pools/aedes1-454.dta", replace
import excel "/Users/amykrystosik/Box Sync/Amy Krystosik's Files/mosquito_pools/Master Mosquito Leg Pooling Database_krystosikSeptember28_16.xlsx", sheet("anopheles results 1-454") firstrow case(lower) clear
save "/Users/amykrystosik/Box Sync/Amy Krystosik's Files/mosquito_pools/anopheles1-454.dta", replace
import excel "/Users/amykrystosik/Box Sync/Amy Krystosik's Files/mosquito_pools/Master Mosquito Leg Pooling Database_krystosikSeptember28_16.xlsx", sheet("Results 459-739") firstrow case(lower) clear
save "/Users/amykrystosik/Box Sync/Amy Krystosik's Files/mosquito_pools/results459-739.dta", replace
import excel "/Users/amykrystosik/Box Sync/Amy Krystosik's Files/mosquito_pools/Master Mosquito Leg Pooling Database_krystosikSeptember28_16.xlsx", sheet("Results 740-860") firstrow case(lower) clear
save "/Users/amykrystosik/Box Sync/Amy Krystosik's Files/mosquito_pools/results740-860.dta", replace

use "/Users/amykrystosik/Box Sync/Amy Krystosik's Files/mosquito_pools/pools.dta", clear
merge 1:1 bigpoolnumber using  "/Users/amykrystosik/Box Sync/Amy Krystosik's Files/mosquito_pools/aedes1-454.dta"
save merged, replace

append using "merged" "/Users/amykrystosik/Box Sync/Amy Krystosik's Files/mosquito_pools/anopheles1-454.dta""/Users/amykrystosik/Box Sync/Amy Krystosik's Files/mosquito_pools/results459-739.dta" "/Users/amykrystosik/Box Sync/Amy Krystosik's Files/mosquito_pools/results740-860.dta", generate(append) force
sum
save "/Users/amykrystosik/Box Sync/Amy Krystosik's Files/mosquito_pools/mergedpools.dta", replace
dropmiss
export excel using "/Users/amykrystosik/Box Sync/Amy Krystosik's Files/mosquito_pools/mergedpools.xls", firstrow(variables) replace
