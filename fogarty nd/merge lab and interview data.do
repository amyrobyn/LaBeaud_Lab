cd "C:\Users\amykr\Box Sync\Fogarty ND CHIKV study\REDCap\elisa"

*merge lab and interview data
insheet using "C:\Users\amykr\Downloads\FogartyNDCHIKV_DATA_2017-05-15_1247.csv", clear
save records, replace
insheet using "C:\Users\amykr\Downloads\Book1.csv", comma clear
	
	preserve
		keep if strpos(participant_id, "C1")
			replace participant_id = subinstr(participant_id, "C1", "", .) 
			foreach var in  sampleid rep1chikv isr reading testresult {
			rename `var' `var'_child
		}
		save elisa_child, replace
	restore

	drop if strpos(participant_id, "C1")
	drop if participant_id ==""
			foreach var in  sampleid rep1chikv isr reading testresult {
			rename `var' `var'_mother
		}

	save elisa_mother, replace

merge 1:1  participant_id using elisa_child
save elisa, replace
