*compare elisa results from stanford and kenya by antigen used
cd "C:\Users\amykr\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\CSVs nov29_16"
use "prevalent.dta", clear
tab antigenused_

rename denvigg_ kenya_denvigg_
tab stanforddenvigg_  kenya_denvigg_ if stanforddenvigg_  !="" | kenya_denvigg_ != "", m 
bysort  antigenused_: tab stanforddenvigg_  kenya_denvigg_

rename chikvigg_ kenya_chikvigg_ 
tab stanfordchikvigg_	kenya_chikvigg_  if stanfordchikvigg_	!="" | kenya_chikvigg_  != "", m 
bysort  antigenused_: tab stanfordchikvigg_	kenya_chikvigg_  

tab dengue_igg_sammy 
tab chikvpcrencode1 
tab denvpcr_encode3
