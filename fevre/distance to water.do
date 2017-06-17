import excel "C:\Users\amykr\Box Sync\Amy Krystosik's Files\Elysse chikv hotspots\distance to water tab3.xls", sheet("distance to water tab3") firstrow

gen case = .
replace case = 0 if allfever_ProjectCHIKV == 0 | allfever_ProjectDENV ==0
replace case = 1 if allfever_ProjectCHIKV == 1 | allfever_ProjectDENV ==1

bysort case: sum   distance_waterNEAR_DIST , d
bysort case: sum  distance_water3NEAR_DIST , d

table1, vars( distance_water3NEAR_DIST conts \  distance_waterNEAR_DIST conts \  ) by(case) test 
