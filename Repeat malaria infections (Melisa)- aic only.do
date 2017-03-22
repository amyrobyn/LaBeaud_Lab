/********************************************************************
 *amy krystosik                  							  		*
 *melisa Repeat malaria infections (Melisa)- aic only				*
 *lebeaud lab               				        		  		*
 *last updated march 18, 2017  							  			*
 ********************************************************************/ 
capture log close 
set more 1
set scrollbufsize 100000
log using "LOG Repeat malaria infections (Melisa)- aic only.smcl", text replace 
cd "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\Repeat malaria infections (Melisa)- aic only"
local figures "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\Repeat malaria infections (Melisa)- aic only\draft figures\"
local data "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\Repeat malaria infections (Melisa)- aic only\data\"

use "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\all linked and cleaned data\data\cleaned_merged_data", replace
*How many kids have gametocytes overall?

replace gametocytes = gametocytes1 if gametocytes ==.
replace gametocytes = gametocytes2 if gametocytes ==.
drop gametocytes2  gametocytes2  
table1, vars(gametocytes conts \) by(cohort ) saving(gametocytes)
tabout gametocytes using gametocytes.xls , replace
tabout gametocytes site using gametocytes_site.xls , replace
tabout gametocytes  cohort using gametocytes_cohort.xls , replace

/*Repeat malaria infections (Melisa)- aic only
Due to reinfection or maltreatment?
Amy Send melisa
Spatial climate, ses, village, season, year, Treatment, location, demographics, height weight, bednets, parasite species and density
Only kids with malaria
1st pos second non
1st pos second pos
How many kids have gametocytes?
*/

keep if cohort ==1
dropmiss, force
bysort id_wide: gen mal_freq = sum(malariapositive_dum )

preserve
	keep if malariapositive_dum ==1
	egen firstpos = min(visit_int), by(id_wide)
	save firstpos , replace
restore 
merge 1:1 id_wide visit_int using firstpos 
drop _merge

tab firstpos, m 

bysort id_wide: egen mal_freq_max = max(mal_freq)
order mal_freq_max 


preserve 
keep if firstpos != . 
	keep if mal_freq >0 & mal_freq !=. 
	table1, vars(cohort cat \ all_meds_antimalarial cat \ species_cat cat \ parasite_count_lab conts \ age conts \ gender cat\ city cat \site cat \ urban cat\ wealthindex conts \ ses_index_sum  conts  \ hygieneindex conts \ sesindeximprovedfloor_index cat \sesindeximprovedwater_index cat \sesindeximprovedlight_index cat \sesindextelephone cat\sesindexradio cat\sesindextelevision cat\sesindexbicycle cat\sesindexmotorizedvehicle cat\sesindexdomesticworker cat \sesindexownflushtoilet cat  \  mosquitocoil bin \ mosquitobites bin \ mosquito_exposure_index conts \ mosq_prevention_index conts \  malariatreatment1 cat \ malariatreatment2 cat \ ) by(mal_freq_max) saving("`figures'repeatmalaria_all.xls", replace ) missing test
restore

*rename past_med_history* pmh*
order id_wide visit_int 

drop *compl*


rename *1 *a
save temp, replace
		keep id_wide visit_int site city ses* season* year gender age z* *neg* mosq* parasite* species *dum mom_educ urban wealthindex hygieneindex 

		order id_wide visit
		local vars "parasite_count_lab city gender age mosquitocoil mosquitobites pos_neg pos_nega site zhcaukwho zwtukwho zhtukwho zbmiukwho chikvpcrresults_dum denvpcrresults_dum parasitelevel_desc malariapositive_dum species_cat year season season_label seasonyear zaicb_heart_rate zaicb_childtemp zlen zwei zwfl zbmi zhc urban mom_educ othoutcome_dum sesindeximprovedfloor_index sesindeximprovedwater_index sesindeximprovedlight_index sesindextelephone sesindexradio sesindextelevision sesindexbicycle sesindexmotorizedvehicle sesindexdomesticworker sesindexownflushtoilet ses_index_sum wealthindex hygieneindex pastmedhist_dum mosquito_exposure_index sleepbednet_dum mosq_prevention_index"
		reshape wide `vars', i(id_wide) j(visit_int)

		order malariapositive_dum*

		gen aposbpos = 1 if malariapositive_dum1==1 & malariapositive_dum2==1
		gen aposbneg = 1 if malariapositive_dum1==1 & malariapositive_dum2==0
		gen bposcpos= 1 if malariapositive_dum2==1 & malariapositive_dum3==1
		gen bposcneg= 1 if malariapositive_dum2==1 & malariapositive_dum3==0
		gen cposdpos= 1 if malariapositive_dum3==1 & malariapositive_dum4==1
		gen cposdneg= 1 if malariapositive_dum3==1 & malariapositive_dum4==0
		gen dposepos= 1 if malariapositive_dum4==1 & malariapositive_dum5==1
		gen dposeneg= 1 if malariapositive_dum4==1 & malariapositive_dum5==0
		gen eposfpos= 1 if malariapositive_dum5==1 & malariapositive_dum6==1
		gen eposfneg= 1 if malariapositive_dum5==1 & malariapositive_dum6==0
		gen fposgpos= 1 if malariapositive_dum6==1 & malariapositive_dum7==1
		gen fposgneg= 1 if malariapositive_dum6==1 & malariapositive_dum7==0

		gen repeatmalaria = .
		replace repeatmalaria = 1 if aposbpos ==1|bposcpos==1|cposdpos==1| dposepos ==1|eposfpos ==1|fposgpos ==1
		replace repeatmalaria = 0 if aposbneg ==1|bposcneg==1|cposdneg==1| dposeneg==1|eposfneg==1|fposgneg==1

		tab repeatmalaria 
		keep if repeatmalaria !=.
		keep repeatmalaria id_wide malariapositive_dum* 
		tab repeatmalaria 
		
reshape long 
keep repeatmalaria id_wide malariapositive_dum* visit_int
collapse repeatmalaria (min) visit_int, by(id_wide) 
	tab repeatmalaria 
save repeatmalaria, replace
merge 1:1 id_wide visit_int using temp
bysort repeatmalaria: sum age gender city  zhcaukwho zwtukwho zhtukwho zbmiukwho zaicb_heart_rate zaicb_childtemp zlen zwei zwfl zbmi zhc parasite_count*   zbmiukwho   zhtukwho   zwtukwho   zhcaukwho   age gender city site urban wealthindex ses_index_sum hygieneindex sesindeximprovedfloor_index sesindeximprovedwater_index sesindeximprovedlight_index sesindextelephone sesindexradio sesindextelevision sesindexbicycle sesindexmotorizedvehicle sesindexdomesticworker sesindexownflushtoilet pastmedhist_dum 

tab repeatmalaria

table1 , vars(cohort cat \ all_meds_antimalarial cat \ species_cat cat \ parasite_count_lab conts \ age conts \ gender bin \ city cat \site cat \ urban bin \ wealthindex conts \ ses_index_sum  conts  \ hygieneindex conts \ sesindeximprovedfloor_index cat \sesindeximprovedwater_index cat \sesindeximprovedlight_index cat \sesindextelephone bin \sesindexradio bin \sesindextelevision bin\sesindexbicycle bin\sesindexmotorizedvehicle bin\sesindexdomesticworker cat \sesindexownflushtoilet cat  \  mosquitocoil bin \ mosquitobites bin \ mosquito_exposure_index conts \ mosq_prevention_index conts \  sleepbednet_dum cat \malariatreatmenta cat \ malariatreatment2 cat \ ) by(repeatmalaria) saving("`figures'repeatmalaria$S_DATE.xls", replace ) missing test

outsheet using repeatmalaria_raw.csv , comma names replace 
