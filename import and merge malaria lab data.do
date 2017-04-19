/**************************************************************
 *amy krystosik                  							  *
 *malaria data import and clean*
 *lebeaud lab               				        		  *
 *last updated feb2, 2017  							  		  *
 **************************************************************/ 
cd "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\malaria"
capture log close 
log using "malaria  data.smcl", text replace 
set scrollbufsize 100000
set more 1

*import all data and save locally 

foreach dataset in "Initial" "1stFU" "2ndFU" "3rdFU"{
			import excel "C:\Users\amykr\Box Sync\DENV CHIKV project\Lab Data\Malaria Database\Malaria Latest\west\West HCC_Malaria Parasitemia Data_07oct2016.xlsx", sheet(`dataset') firstrow clear
			save "malaria_`dataset'", replace
}
				
foreach dataset in "Obama" "Chulaimbo-Mbaka_Oromo"{
	import excel "C:\Users\amykr\Box Sync\DENV CHIKV project\Lab Data\Malaria Database\Malaria Latest\west\West AIC Malaria Parasitemia Data.xls", sheet(`dataset') firstrow clear
	save "malaria_`dataset'", replace
}

insheet using "C:\Users\amykr\Box Sync\DENV CHIKV project\Lab Data\Malaria Database\Malaria Latest\coast\coast_hcc_malaria.csv", clear
		save malaria_coast_hcc, replace
import excel "C:\Users\amykr\Box Sync\DENV CHIKV project\Lab Data\Malaria Database\Malaria Latest\coast\3 AIC Ukunda Malaria Data Sep 2016 - 04Oct16.xls", sheet("Ukunda") firstrow clear
		save malaria_Ukunda_aic, replace
import excel "C:\Users\amykr\Box Sync\DENV CHIKV project\Lab Data\Malaria Database\Malaria Latest\coast\AICA Msambweni Malaria Data2016.xls", sheet("Msambweni data") firstrow clear
		save malaria_Msambweni, replace

**
		use malaria_coast_hcc, clear

		drop  id_wide id_city id_cohort id_visit id_childnumber
				gen dataset = "coast_hcc_malaria"
				rename *, lower
				ds, has(type string) 
				foreach v of varlist `r(varlist)' { 
					replace `v' = lower(`v') 
				}
			dropmiss, force
			rename density parasite_count
			destring _all, replace
			rename *, lower
	save malaria_coast_hcc, replace
	
	use malaria_Ukunda_aic, clear
				rename *, lower
						
		*gen id_wide
		rename   studyid1 studyid
		replace studyid= subinstr(studyid, "/", "",.)
		replace studyid= subinstr(studyid, " ", "",.)
		replace studyid= subinstr(studyid, "O", "0",.)


			*take visit out of id
									forval i = 1/3 { 
										gen id`i' = substr(studyid, `i', 1) 
									}
			*gen id_wid without visit						 
				rename id1 id_city  
				rename id2 id_cohort  
				rename id3 id_visit 
				tab id_visit 
				gen id_childnumber = ""
				replace id_childnumber = substr(studyid, +4, .)
				
		*end id_wide
		*start rehape the malaria follow up visit to be part of the long data
				gen visit_fu = ""
				replace visit_fu ="b" if id_visit =="A" 
				replace visit_fu ="c" if id_visit =="B" 
				replace visit_fu ="d" if id_visit =="C" 
				replace visit_fu ="e" if id_visit =="D" 
				replace visit_fu ="f" if id_visit =="E" 
				replace visit_fu ="g" if id_visit =="F" 
				replace visit_fu ="h" if id_visit =="G" 
				tab visit_fu id_visit , m
				
				egen studyid_fu = concat(id_city id_cohort visit_fu  id_childnum)
				preserve
					keep studyid_fu actualfollowdate followed spp2 countul2 gametocytes2 treatment2  pos_neg1 visit_fu  
					rename studyid_fu  studyid
					rename actualfollowdate  initialdate2
					rename spp2 spp1
					rename countul2 countul1
					rename gametocytes2 gametocytes1
					rename treatment2 treatment1
					rename  pos_neg1  pos_neg
					gen dataset = "ukunda_aic_fu" 
					save ukunda_aic_fu , replace
				restore
				drop studyid_fu  actualfollowdate followed spp2 countul2 gametocytes2 treatment2 studyid2  expectedfollowupdate id_cohort id_visit id_city id_childnumber id_cohort
		tostring pos_neg, replace
				append using ukunda_aic_fu 
				replace dataset = "malaria AIC Ukunda iniital" if  dataset ==""

				gen schizonts =. 
				replace schizonts=1 if gametocytes1 =="schizonts"|gametocytes1 =="schizouts"
				replace gametocytes1 ="." if gametocytes1 =="schizonts"
				replace gametocytes1 ="." if gametocytes1 =="schizouts"
				destring gametocytes1 , replace
				
		*end rehape the malaria follow up visit to be part of the long data
				ds, has(type string) 
				foreach v of varlist `r(varlist)' { 
					replace `v' = lower(`v') 
				}
				foreach var in date{
					capture gen `var'1 = date(`var', "MDY" ,2050)
					capture  format %td `var'1 
					capture drop `var'
					capture rename `var'1 `var'
					capture recast int `var'
				}

					foreach var in today date{
						capture gen `var'1 = date(`var', "DMY" ,2050)
						capture format %td `var'1 
						capture drop `var'
						capture rename `var'1 `var'
						capture recast int `var'
					}


				dropmiss, force
				replace spp1= subinstr(spp1, "/", "_",.)
				replace spp1= "pm_pf" if spp1 =="pf_pm" 
				replace spp1= "pm" if spp1 =="pm_pm" 
				tab spp1
				
				*repeat id's 
				duplicates tag studyid, gen(repeatids)
				outsheet using repeatids_ukunda.csv, comma replace names
				drop if repeatids >0
				drop repeatids 

				
				*missing data
				replace spp1 = "missing" if spp1==""
				replace spp1 = "none" if spp1=="0"
				replace spp1 = "ni" if spp1=="malaria pigments"
				tab spp1 , m
				
				reshape wide  countul1, j(spp1) i(studyid) string

				destring _all, replace
				rename countul1* *200
				tostring pos_neg, replace
	rename *, lower			
	save malaria_Ukunda_aic, replace

	use malaria_Msambweni, clear
				rename *, lower
				
		*gen id_wide
		rename   studyid1 studyid
			*gen id_wide
									forval i = 1/3 { 
										gen id`i' = substr(studyid, `i', 1) 
									}
			*gen id_wid without visit						 
				rename id1 id_city  
				rename id2 id_cohort  
				rename id3 id_visit 
				tab id_visit 
				gen id_childnumber = ""
				replace id_childnumber = substr(studyid, +4, .)

		*end id_wide
		*start rehape the malaria follow up visit to be part of the long data
				gen visit_fu = ""
				replace visit_fu ="b" if id_visit =="A" 
				replace visit_fu ="c" if id_visit =="B" 
				replace visit_fu ="d" if id_visit =="C" 
				replace visit_fu ="e" if id_visit =="D" 
				replace visit_fu ="f" if id_visit =="E" 
				replace visit_fu ="g" if id_visit =="F" 
				replace visit_fu ="h" if id_visit =="G" 
				tab visit_fu id_visit , m
				
				
				egen studyid_fu = concat(id_city id_cohort visit_fu  id_childnum)
				preserve
					keep studyid_fu actualfollowdate followed spp2 countul2 gametocytes2 treatment2 pos_neg1
					rename studyid_fu  studyid
					rename actualfollowdate  initialdate2
					rename spp2 spp1
					rename countul2 countul1
					rename gametocytes2 gametocytes1
					rename treatment2 treatment1
					rename  pos_neg1 pos_neg
				rename *, lower	
				gen dataset = "malaria_msambweni fu"
				save msambweni_aic_fu, replace
				restore
				drop studyid_fu  actualfollowdate followed spp2 countul2 gametocytes2 treatment2 studyid2  expectedfollowupdate id_cohort id_visit id_city id_childnumber pos_neg1 id_cohort
				append using msambweni_aic_fu 
							
				gen schizonts =. 
				replace schizonts=1 if gametocytes1 =="schizonts"
				replace gametocytes1 ="." if gametocytes1 =="schizonts"
				destring gametocytes1 , replace		
		*end rehape the malaria follow up visit to be part of the long data		
				ds, has(type string) 
				foreach v of varlist `r(varlist)' { 
					replace `v' = lower(`v') 
				}
				dropmiss, force

				replace spp1= subinstr(spp1, "/", "_",.)
				replace spp1= "pf" if spp1=="p_f"
				replace spp1= "pm" if spp1=="p_m"

				tab spp1

				*repeat id's 
				duplicates tag studyid, gen(repeatids)
				
				outsheet using repeatids_msambweni.csv, comma replace names
				drop if repeatids >0
				drop repeatids 

				reshape wide  countul1, j(spp1) i(studyid) string
				
				destring _all, replace
				rename countul1* *200

				foreach var in date{
					capture gen `var'1 = date(`var', "MDY" ,2050)
					capture  format %td `var'1 
					capture drop `var'
					capture rename `var'1 `var'
					capture recast int `var'
				}
					foreach var in today date{
						capture gen `var'1 = date(`var', "DMY" ,2050)
						capture format %td `var'1 
						capture drop `var'
						capture rename `var'1 `var'
						capture recast int `var'
					}
					
			tostring pos_neg, replace
		replace dataset = "malaria_msambweni initial" if  dataset ==""
		
		rename *, lower
		save malaria_Msambweni, replace

foreach dataset in "Obama" "Chulaimbo-Mbaka_Oromo"{
use "malaria_`dataset'"				
				gen dataset ="malaria_`dataset'"

				rename *, lower
				capture rename clientno studyid
				capture rename childid studyid
				ds, has(type string) 
				foreach v of varlist `r(varlist)' { 
					replace `v' = lower(`v') 
				}

				capture replace pf200= subinstr(pf200, ",", "",.)

				foreach var in date{
					capture gen `var'1 = date(`var', "MDY" ,2050)
					capture  format %td `var'1 
					capture drop `var'
					capture rename `var'1 `var'
					capture recast int `var'
				}

					foreach var in today date{
						capture gen `var'1 = date(`var', "DMY" ,2050)
						capture format %td `var'1 
						capture drop `var'
						capture rename `var'1 `var'
						capture recast int `var'
					}

				destring _all, replace
				ds, has(type string) 
				foreach v of varlist `r(varlist)' { 
					replace `v' = lower(`v') 
				}
				dropmiss, force
				dropmiss, force obs

				capture tostring studyid2, replace
				capture  tostring pos_neg, replace

		rename *, lower
		save "malaria_`dataset'", replace
		}

foreach dataset in "Initial" "1stFU" "2ndFU" "3rdFU"{
use "malaria_`dataset'"
gen dataset ="malaria_west_hcc_`dataset'"
				rename *, lower
				destring _all, replace
				ds, has(type string) 
					foreach v of varlist `r(varlist)' { 
							replace `v' = lower(`v') 
					}
				dropmiss, force
				dropmiss, force obs
				
				foreach var in today date{
					capture gen `var'1 = date(`var', "DMY" ,2050)
					capture format %td `var'1 
					capture drop `var'
					capture rename `var'1 `var'
					capture recast int `var'
				}
				foreach var in today date{
					capture gen `var'1 = date(`var', "MDY" ,2050)
					capture format %td `var'1 
					capture drop `var'
					capture rename `var'1 `var'
					capture recast int `var'
				}
			capture tostring pos_neg, replace
		rename *, lower
		save "malaria_`dataset'", replace
		}
use malaria_Msambweni, clear
append using "malaria_Obama" "malaria_Ukunda_aic" "malaria_1stFU" "malaria_2ndFU" "malaria_3rdFU" "malaria_Chulaimbo-Mbaka_Oromo" "malaria_coast_hcc" "malaria_Initial", gen(append)
		replace studyid= subinstr(studyid, "/", "",.)
		replace studyid= subinstr(studyid, "-", "",.)
		replace studyid= subinstr(studyid, "o", "0",.)
		replace studyid= subinstr(studyid, "cmb", "cf",.)

		*gen id_wide
											forval i = 1/3 { 
												gen id`i' = substr(studyid, `i', 1) 
											}
					*gen id_wid without visit						 
						rename id1 id_city  
						rename id2 id_cohort  
						rename id3 id_visit 
						tab id_visit 
						gen id_childnumber = ""
						replace id_childnumber = substr(studyid, +4, .)
						
					gen byte notnumeric = real(id_childnumber)==.	/*makes indicator for obs w/o numeric values*/
					tab notnumeric	/*==1 where nonnumeric characters*/
					list studyid id_childnumber if notnumeric==1	/*will show which have nonnumeric*/
		list dataset studyid id_visit if id_visit =="0"|id_visit =="1"|id_visit =="4"
					 
						
					gen suffix = "" 	
					foreach suffix in a b c d e f g h {
						replace suffix = "`suffix'" if strpos(id_childnumber, "`suffix'")
						replace id_childnumber = subinstr(id_childnumber, "`suffix'","", .)
						}
					destring id_childnumber, replace 	 
					tostring id_childnumber, replace
					egen id_childnumber2 = concat(id_childnumber suffix)
					drop id_childnumber
					rename id_childnumber2 id_childnumber
					
						egen id_wide = concat(id_city id_cohort id_childnum)
						order id_cohort id_city id_childnumber id_wide id_visit studyid
						duplicates drop
		*end id_wide
			
		encode gender, gen(sex)
		drop gender
		rename sex gender
		drop visit_fu
		rename id_visit visit
			gen visit_int = . 
			replace visit_int = 1 if visit =="a"
			replace visit_int = 2 if visit =="b"
			replace visit_int = 3 if visit =="c"
			replace visit_int = 4 if visit =="d"
			replace visit_int = 5 if visit =="e"
			replace visit_int = 6 if visit =="f"
			replace visit_int = 7 if visit =="g"
			replace visit_int = 8 if visit =="h"
			

		duplicates tag id_wide visit_int, gen (dup_id_wide_visit_int) 
		bysort id_wide visit: egen dupmax = max(dup_id_wide_visit_int)
		tab dupmax 
		list studyid id_wide visit_int if dupmax > 0
		outsheet using dup_id_wide_visit_int.csv if dupmax >0, comma names replace 
		drop if dupmax > 0
		isid id_wide visit_int

		foreach var in dob{
			gen `var'1 = date(`var', "MDY" ,2050)
			format %td `var'1 
			drop `var'
			rename `var'1 `var'
			recast int `var'
		}

			foreach var in today date{
				capture gen `var'1 = date(`var', "DMY" ,2050)
				capture format %td `var'1 
				capture drop `var'
				capture rename `var'1 `var'
				capture recast int `var'
			}

		order *200
		egen parasite_count2= rowtotal(pf200 pm200 po200 pv200 missing200 ni200 none200 pm_pf200 po_pf200)
		replace parasite_count2 = . if pf200 ==. & pm200 ==. & po200 ==. & pv200 ==. & ni200==. & none200==. & pm_pf200==. & po_pf200==.
		 
		compare parasite_count parasite_count2 
		replace parasite_count = parasite_count2  if parasite_count ==. 
		drop parasite_count2 

		gen  malariapositive_dum = .
		replace malariapositive_dum = 0 if parasite_count==0
		replace malariapositive_dum = 1 if parasite_count >0 & parasite_count<. 

		replace species = "neg" if species =="none"
		gen species_cat = species 
		replace species_cat = "pf" if pf200 >0 & pf200 <.
		replace species_cat = "pm" if pm200  >0 & pm200 <.
		replace species_cat = "po" if po200 >0 & po200 <.
		replace species_cat = "pv" if pv200 >0 & pv200 <.
		replace species_cat = "pm_pf" if pm_pf200  >0 & pm_pf200  <.
		replace species_cat = "po_pf" if po_pf200  >0 & po_pf200  <.
		replace species_cat = "ni" if ni200 >0 & ni200 <.
		replace species_cat = "none" if none200 >0 & none200 <.
		replace species_cat ="neg" if  parasite_count==0

		compare species_cat species 
		drop species
		order *200 

		replace id_cohort = "f" if id_cohort =="m"
		replace id_wide= subinstr(id_wide, "/", "",.)

		replace studyid= subinstr(studyid, "/", "",.)
		replace studyid= subinstr(studyid, " ", "",.)

		replace studyid = subinstr(studyid, "/", "",.)
		replace studyid = subinstr(studyid, " ", "",.)
		replace studyid = subinstr(studyid, "--", "",.)
		replace studyid = subinstr(studyid, "*", "",.)
		replace studyid = subinstr(studyid, "-", "",.)

		drop if studyid =="" & id_wide ==""
		drop id_childnumber
		tab id_city
		rename  id_city city 

		replace city ="chulaimbo" if city =="c"
		replace city = "kisumu" if city =="k"
		replace city ="msambweni" if city =="m" 
		replace city = "ukunda" if city =="w"
		replace city = "ukunda" if city =="u"

		*fix gametocytes
		replace gametocytes1 = "0" if gametocytes1=="none"
		replace gametocytes1 = "1" if gametocytes1=="gametocyte"

		destring gametocytes1 , replace
		replace gametocytes = gametocytes1 if gametocytes ==.
		drop gametocytes1

		rename  treatment1 malariatreatment1
		rename  parasitelevel  parasitelevel_desc
		bysort id_cohort city: tab species_cat
		tab gametocytes 

		replace species_cat = "pf/pm" if species_cat=="pfpm"
		replace species_cat = "pf/po" if species_cat=="pfpo"
		tab species_cat
		replace pos_neg = "1" if pos_neg == "pos" 
		replace pos_neg = "0" if pos_neg == "neg"
		destring  pos_neg , replace
		order pos_neg malariapositive_dum
		bysort id_cohort: sum  pos_neg malariapositive_dum

		
		replace city = "msambweni" if city =="g"
		replace city = "chulaimbo" if city =="r"
		replace city = "msambweni" if city =="l"
		tab city, m
		tostring pos_neg, replace 
		drop notes dob
		rename visit id_visit
		dropmiss, force
		dropmiss, obs force 
		drop if malariapositive_dum ==.
drop hospitalsite gender
rename dataset malaria_dataset
rename *, lower
save malaria, replace

merge 1:1 id_wide  id_visit using "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\all_interview_data\all_interviews"
tab dataset _merge
 
drop if _merge == 2

replace visit_type = visittype if visit_type ==.
		drop visittype
		gen acute = .
		replace acute = 1 if dataset =="Coast_AIC_Initial"|dataset =="West_AIC_INITIAL"|dataset =="West_AIC_INITIAL"
		replace acute = 1 if dataset =="Western_AIC_FU"
		replace acute = 0 if dataset =="coast_aic_fu"
		replace acute = 1 if visit_int == 1
		replace acute = 1 if visit_type ==1|visit_type ==2|visit_type ==4|visit_type ==5
		replace acute = 0 if visit_type ==3
		replace acute =99 if id_cohort =="c"

bysort acute id_cohort city: sum malariapositive_dum 

gen FEVER = . 
replace FEVER =1 if fevertemp ==1|fever ==1| fevertoday ==1 | FeverToday ==1
replace temp = temperature if temp ==.
drop temperature 
replace FEVER =1 if temp >=38 & temp !=.
replace FEVER =0 if temp <38 
tab fever

preserve
keep if city =="ukunda" 
keep if acute ==1 
keep if id_cohort =="f"
*aic ukunda acute
fsum malariapositive_dum   
restore

preserve
keep if city =="msambweni" 
keep if acute ==1 
keep if id_cohort =="f"
*aic msambweni acute
fsum malariapositive_dum   
restore


preserve
keep if city =="kisumu" 
keep if acute ==1 
keep if id_cohort =="f"
*aic kisumu initial
fsum malariapositive_dum   
restore

preserve
keep if city =="chulaimbo" 
keep if acute ==1 
keep if id_cohort =="f"
*aic chulaimbo initial
fsum malariapositive_dum   
restore

preserve
keep if acute ==1 
keep if id_cohort =="f"
*aic initial
fsum malariapositive_dum   
restore

preserve
keep if fever ==1
keep if acute ==1 
keep if id_cohort =="f"
*aic acute febrile
fsum malariapositive_dum   
restore	

preserve
keep if id_cohort =="c"
*hcc
fsum malariapositive_dum   
restore	

preserve
keep if id_cohort =="c"
*hcc by city 
bysort city: fsum malariapositive_dum   
restore	

bysort  malaria_dataset : fsum malariapositive_dum   
tab malaria_dataset 

preserve
keep if id_cohort =="c"
*hcc all comers
fsum malariapositive_dum   
ci malariapositive_dum   , binomial 
bysort id_visit: ci malariapositive_dum   , binomial 
restore	

preserve
keep if id_cohort =="f"
keep if acute ==1
*acute aic 
fsum malariapositive_dum   
ci malariapositive_dum   , binomial 
bysort city: ci malariapositive_dum   , binomial 
restore	

keep fever id_wide id_visit id_cohort  malariapositive_dum    pos_neg malariapositive_dum ni200 none200 pf200 pm200 po200 pv200 pm_pf200 po_pf200 malariatreatment1 malaria_dataset parasitelevel_desc gametocytes parasite_count species_cat sickle_result  city 
save malaria_merged, replace
