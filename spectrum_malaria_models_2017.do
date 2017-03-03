cd "C:\Users\amykr\Box Sync\Amy Krystosik's Files\spectrum population health 2017\colombia anopheles data"
insheet using "mosquitoes by house_cleaned_MARCH 27.csv", comma clear
save "colombia_anopheles_HLC", replace
gen id = _n

drop v34 v35 v36 v37 v38 v39 v40 v41 v42 v43 v44 v45 v46 v47 v48 v49 v50 v51 v52 v53 v54 v55 v56 

rename  mosq_abm_intra  mosq_abmintra
rename *peri peri_*
rename *intra intra_*

local i = 1
foreach species in arg ppp abm cal ntv nei dar tri neo ran abt osw {
	rename *mosq_`species' *mosq`i' 
      local i = `i' + 1
 }
 
reshape long  peri_mosq intra_mosq ,i(id) j(species)

gen species_s = ""
local i = 1
foreach species in arg ppp abm cal ntv nei dar tri neo ran abt osw {
	replace species_s = "`species'" if species == `i' 
	local i = `i' + 1
}

gen morning = . 
replace morning = 1 if am_pm=="a"
replace morning = 0 if am_pm=="p"

rename fecha clt_date
foreach var in clt_date{
				gen `var'1 = date(`var', "MDY" ,2050)
				format %td `var'1 
				drop `var'
				rename `var'1 `var'
				recast int `var'
}

gen clt_month = month(clt_date)
gen clt_year = year(clt_date)
rename latitud lat
rename longitud lon
rename altura alt
outsheet using "workingdata.csv", comma names replace
