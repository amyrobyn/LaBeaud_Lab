cd "C:\Users\amykr\Box Sync\Amy Krystosik's Files\ASTMH 2017 abstracts\DENV igg compare to rdt"
capture log close
set more 1
set scrollbufsize 100000
log using "rdt to elisa comparison.smcl", text replace 
insheet using "Copy of DENGUE RDT RESULTS 20th Feb 2017 - AMY.csv", comma names clear


*compare rdt igm and stanford igg at initial - should be same
fsum stanford_igg_initial_dum rdt_igm_dum
tab  stanford_igg_initial_dum rdt_igm_dum, m
diagt stanford_igg_initial_dum rdt_igm_dum

*compare rdt igg and stanford igg at fu
fsum stanford_igg_fu_dum stanford_igg_initial_dum rdt_igg_dum
diagt stanford_igg_fu_dum rdt_igg_dum
tab stanford_igg_fu_dum rdt_igg_dum

*compare rdt igg and stanford igg initial 
fsum stanford_igg_fu_dum stanford_igg_initial_dum rdt_igg_dum
diagt stanford_igg_initial_dum  rdt_igg_dum
tab stanford_igg_initial_dum  rdt_igg_dum

*compare rdt igm to igg at fu for all comers 
	fsum  stanford_igg_fu_dum  rdt_igm_dum 
	tab   stanford_igg_fu_dum  rdt_igm_dum , m

	diagt  stanford_igg_fu_dum  rdt_igm_dum 	

*compare rdt igm to igg at fu for seroconverters (those neg at initial and positive at follow up) 
preserve
	bysort stanford_igg_initial_dum :  tab stanford_igg_fu_dum rdt_igm_dum, m

	keep if stanford_igg_initial_dum==0

	fsum  stanford_igg_fu_dum  rdt_igm_dum 
	tab   stanford_igg_fu_dum  rdt_igm_dum , m

*	diagt  stanford_igg_fu_dum  rdt_igm_dum 	**fails as there are no seroconverters. . . 
restore	
