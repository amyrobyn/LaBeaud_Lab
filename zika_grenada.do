cd "C:\Users\amykr\Box Sync\zika study- grenada"
insheet using "C:\Users\amykr\Box Sync\zika study- grenada\zika_march_27_2017.csv", comma clear
	rename v143 participantidnumber_b 
	replace participantidnumber_b = amys_u_id if participantidnumber_b ==. 
	dropmiss, force
	dropmiss, force obs piasm
	isid participantidnumber_b 
	duplicates tag participantidnumber_b , gen(participantidnumber_dup)
	tab participantidnumber_b 
	list participantidnumber_b if participantidnumber_b >0
	drop participantidnumber 
	rename participantidnumber_b participantidnumber 
save zika, replace

insheet using "C:\Users\amykr\Box Sync\zika study- grenada\lab results.csv", comma clear
	rename participant_id  participantidnumber 
	tostring testresultsigm, replace
	dropmiss, force
	dropmiss, force obs piasm
	isid participantidnumber 
save lab_results, replace

use zika
	merge 1:1 participantidnumber using lab_results

	sum
	dropmiss, force
	dropmiss, force obs
	duplicates drop
order  participantidnumber
count if  participantidnumber ==.
isid  amys_u_id

tab notyetdelivered
tab testresultsigm
gen PCR = .
replace PCR = 0 if testresultsigm=="0 (PCR only)"
replace PCR = 1 if testresultsigm=="1 (PCR only)"

replace testresultsigm="." if testresultsigm=="0 (PCR only)"| testresultsigm=="1 (PCR only)"
destring testresultsigm, replace  
gen zika_neg  = 1 if testresultsigm ==0
gen zika_pos_recent =1 if testresultsigm ==1
gen zika_possible_pos=1 if testresultsigm ==2 
gen zika_dengue_possible_pos=1 if testresultsigm ==3
gen arbovirus_possible_recent  =1 if testresultsigm ==4
gen chikv_possible_recent_ =1  if testresultsigm ==5
gen flavivirus_possible_recent=1  if testresultsigm ==6
gen flavivirus_past =1 if testresultsigm ==7

/*how many babies have already been delivered and the numbers of 
ZIKV positive moms and say we are going to try to recover the babies who haven’t delivered.
*/

gen zika_igm = .
replace zika_igm = 1 if zika_pos_recent==1 
replace zika_igm = 0 if zika_neg  == 1

tab zika_igm notyetdelivered, m
tab zika_during_preg notyetdelivered
tab zika_during_preg_when
tab zika_during_preg PCR, m

tab testresultspcrblood
	gen pcr_denv_pos = .
	replace pcr_denv_pos  = 1 if testresultspcrblood==1

	gen pcr_chikv_pos = .
	replace pcr_chikv_pos  = 1 if testresultspcrblood==2

	gen pcr_zika_pos = .
	replace pcr_zika_pos  = 1 if testresultspcrblood==3
tab pcr_zika_pos  
fsum
outsheet using "zika_cleaned_$S_DATE.csv", comma replace names
