/********************************************************************
 *amy krystosik                  							  		*
 *Repeat and incident malaria										*
 *lebeaud lab               				        		  		*
 *last updated march 28, 2017  							  			*
 ********************************************************************/ 
capture log close 
set more 1
set scrollbufsize 100000
cd "C:\Users\amykr\Box Sync\Amy Krystosik's Files\ASTMH 2017 abstracts\Repeat malaria infections (Melisa)- aic only"
log using "LOG repeat and incident malaria infections .smcl", text replace 
local figures "C:\Users\amykr\Box Sync\Amy Krystosik's Files\ASTMH 2017 abstracts\Repeat malaria infections (Melisa)- aic only\draft figures\"
local data "C:\Users\amykr\Box Sync\Amy Krystosik's Files\ASTMH 2017 abstracts\Repeat malaria infections (Melisa)- aic only\data\"

use "C:\Users\amykr\Box Sync\Amy Krystosik's Files\ASTMH 2017 abstracts\all linked and cleaned data\data\cleaned_merged_prevalence", replace
*How many kids have gametocytes overall?

/*Repeat malaria infections (Melisa)- aic only
Due to reinfection or maltreatment?
Amy Send melisa
Spatial climate, ses, village, season, year, Treatment, location, demographics, height weight, bednets, parasite species and density
Only kids with malaria
1st pos second non
1st pos second pos
How many kids have gametocytes?
*/

dropmiss, force
bysort id_wide: gen mal_freq = sum(malariapositive_dum)

preserve
	keep if malariapositive_dum ==1
	egen firstpos = min(visit_int), by(id_wide)
	keep id_wide visit_int firstpos 
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
	*table1, vars(cohort cat \ all_meds_antimalarial cat \ species_cat cat \ parasite_count_lab conts \ age conts \ gender cat\ city cat \site cat \ urban cat\ wealthindex conts \ ses_index_sum  conts  \ hygieneindex conts \ sesindeximprovedfloor_index cat \sesindeximprovedwater_index cat \sesindeximprovedlight_index cat \sesindextelephone cat\sesindexradio cat\sesindextelevision cat\sesindexbicycle cat\sesindexmotorizedvehicle cat\sesindexdomesticworker cat \sesindexownflushtoilet cat  \  mosquitocoil bin \ mosquitobites bin \ mosquito_exposure_index conts \ mosq_prevention_index conts \  malariatreatment1 cat \ malariatreatment2 cat \ ) by(mal_freq_max) saving("`figures'repeatmalaria_all.xls", replace ) missing test
restore

*rename past_med_history* pmh*
order id_wide visit_int 
drop *compl*

rename *1 *a
save temp, replace
		keep id_wide visit_int site city ses* season* year gender age z* *neg* mosq* parasite* species *dum* mom_educ urban wealthindex hygieneindex 
		order id_wide visit
		order malaria*
		
  		 rename malariapositive_dum2 all_malariapositive_dum
		 rename malariapositive_dum lab_malariapositive_dum
  		 rename all_malariapositive_dum malariapositive_dum
		 order id_wide visit_int
		local vars "lab_malariapositive_dum malariapositive_dum parasite_count_lab city age species parasite_count_hcc gender mosqbitefreq mosquitocoil mosquitobites mosquitoday mosquitonight mosquitobitefreq mosqbitedaytime mosqbitenight site zwtukwho zhtukwho zbmiukwho parasitelevel_desc pos_neg pos_nega zhcaukwho chikvpcrresults_dum denvpcrresults_dum year season season_label seasonyear zaicb_heart_rate zaicb_childtemp zlen zwei zwfl zbmi zhc urban mom_educ othoutcome_dum sesindeximprovedwater_index sesindeximprovedlight_index sesindextelephone sesindexradio sesindextelevision sesindexbicycle sesindexmotorizedvehicle sesindexdomesticworker sesindexownflushtoilet ses_index_sum wealthindex hygieneindex pastmedhist_dum mosquito_exposure_index sleepbednet_dum mosq_prevention_index ses_index_sum_pct parasite_count_all"
		reshape wide `vars', i(id_wide) j(visit_int)
		order malariapositive_dum*
	
******look for malaria positive at initial and malaria neg at follow up OR malaria pos at initial and fu********
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

		gen repeatmalaria_yes = .
		replace repeatmalaria_yes = 1 if aposbpos ==1|bposcpos==1|cposdpos==1| dposepos ==1|eposfpos ==1|fposgpos ==1

		gen repeatmalaria_no = .
		replace repeatmalaria_no = 1 if aposbneg ==1|bposcneg==1|cposdneg==1| dposeneg==1|eposfneg==1|fposgneg==1
		tab repeatmalaria_yes repeatmalaria_no, m
		
******look for incident malaria - neg at initial and pos at fu********
				gen incb= 1 if malariapositive_dum1==0 & malariapositive_dum2==1
		tab incb
				gen incc= 1 if malariapositive_dum1==0 & malariapositive_dum3==1| malariapositive_dum2==0 & malariapositive_dum3==1
		tab incc
				gen incd= 1 if malariapositive_dum1==0 & malariapositive_dum4==1| malariapositive_dum2==0 & malariapositive_dum4==1| malariapositive_dum3==0 & malariapositive_dum4==1
		tab incd
				gen ince= 1 if malariapositive_dum1==0 & malariapositive_dum5==1| malariapositive_dum2==0 & malariapositive_dum5==1| malariapositive_dum3==0 & malariapositive_dum5==1| malariapositive_dum4==0 & malariapositive_dum5==1
		tab ince
				gen incf= 1 if malariapositive_dum1==0 & malariapositive_dum6==1| malariapositive_dum2==0 & malariapositive_dum6==1| malariapositive_dum3==0 & malariapositive_dum6==1| malariapositive_dum4==0 & malariapositive_dum6==1| malariapositive_dum5==0 & malariapositive_dum6==1
		tab incf
				gen incg= 1 if malariapositive_dum1==0 & malariapositive_dum7==1| malariapositive_dum2==0 & malariapositive_dum7==1| malariapositive_dum3==0 & malariapositive_dum7==1| malariapositive_dum4==0 & malariapositive_dum7==1| malariapositive_dum5==0 & malariapositive_dum7==1| malariapositive_dum6==0 & malariapositive_dum7==1
		tab incg
				gen inch= 1 if malariapositive_dum1==0 & malariapositive_dum8==1| malariapositive_dum2==0 & malariapositive_dum8==1| malariapositive_dum3==0 & malariapositive_dum8==1| malariapositive_dum4==0 & malariapositive_dum8==1| malariapositive_dum5==0 & malariapositive_dum8==1| malariapositive_dum6==0 & malariapositive_dum8==1| malariapositive_dum7==0 & malariapositive_dum8==1
		tab inch

		sum malariapositive_dum*
		sum inc*
		
		gen incident_malaria= .
		replace incident_malaria= 1 if incb==1|incc==1|incd==1|ince==1|incf==1|incg==1|inch==1
		tab incident_malaria 
		
		preserve
			reshape long
			keep id_wide visit incident_malaria inc* 
			collapse (firstnm) inc* (max) visit, by(id_wide)
			tab incident_malaria 
			replace incident_malaria =0 if incident_malaria ==.
			tab incident_malaria 
			sum inc*
			rename visit maxvisit
			gen visit = . 
			replace visit = 2 if incb==1 
			replace visit = 3 if incc==1 
			replace visit = 4 if incd==1 
			replace visit = 5 if ince==1 
			replace visit = 6 if incf==1 
			replace visit = 7 if incg==1 
			replace visit = 8 if inch==1 
			*replace visit = maxvisit if incident_malaria == 0 & visit ==. 
			replace visit = 1 if incident_malaria == 0 & visit ==. 
			rename visit visit_int
			tab visit_int incident_malaria
			keep if incident_malaria !=.
			keep id_wide visit incident_malaria
			save "incident_malaria$S_DATE", replace 
			save "C:\Users\amykr\Box Sync\Amy Krystosik's Files\ASTMH 2017 abstracts\all linked and cleaned data\data\incident_malaria$S_DATE", replace 
		restore
