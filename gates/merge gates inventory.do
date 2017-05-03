*merge gates inventory lists for noah 11-21-16
cd "/Users/amykrystosik/Box Sync/Amy's Externally Shareable Files/gates inv"

import excel gates_inventory.xlsx, sheet("Sorting") firstrow clear
keep if Key!=""
save 1, replace

import excel "gates_inventory.xlsx", sheet("Sheet1") firstrow clear
keep if Key!=""
save 2, replace


import excel "gates_inventory.xlsx", sheet("Sheet2") firstrow clear
keep if Key!=""
save 3, replace


import excel "gates_inventory.xlsx", sheet("Sheet3") firstrow clear
keep if Key!=""
save 4, replace

import excel "gates_inventory.xlsx", sheet("Sheet4") firstrow clear
keep if Key!=""
save 5, replace

import excel "gates_inventory.xlsx", sheet("Sheet5") firstrow clear
keep if Key!=""
save 6, replace

use 1, clear
merge m:m Key using 2
rename _merge merge1
merge m:m Key using 3
rename _merge merge2
merge m:m Key using 4
rename _merge merge3
merge m:m Key using 5

rename _merge merge4
merge m:m Key using 6

outsheet using "merged.csv", comma replace names
