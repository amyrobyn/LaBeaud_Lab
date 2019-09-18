cd "/Users/amykrystosik/Box Sync/Amy Krystosik's Files/elysse coastal village map"
/*
import excel "Coastal villages complete DB with results march 2014.xlsx", sheet("Milalani") firstrow clear
save Milalani, replace
import excel "Coastal villages complete DB with results march 2014.xlsx", sheet("Nganja") firstrow clear
save Nganja, replace
import excel "Coastal villages complete DB with results march 2014.xlsx", sheet("Vuga") firstrow clear
save Vuga, replace
import excel "Coastal villages complete DB with results march 2014.xlsx", sheet("Jego") firstrow clear
save Jego, replace
import excel "Coastal villages complete DB with results march 2014.xlsx", sheet("Magodzoni") firstrow clear
save Magodzoni, replace
import excel "Coastal villages complete DB with results march 2014.xlsx", sheet("Kinango") firstrow clear
save Kinango, replace

clear
append using "Kinango" "Magodzoni" "Jego" "Milalani" "Nganja" "Vuga", gen(append) force

save coastal.dta, replace*/
use coastal, clear

export excel Householdlongitude Householdlatitude Study_ID ElisaID AliquotID House Person_ID VillageHouse Nut_WHO_Study_ID WHO_Study_ID using "gps", firstrow(variables) replace
