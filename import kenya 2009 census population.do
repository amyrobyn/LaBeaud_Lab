cd "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\elysse- apparent inapparent\data"
insheet using "C:\Users\amykr\Box Sync\ASTMH 2017 abstracts\elysse- apparent inapparent\data\2009 KENYA CENUS SUMMARY AGE-GENDER BIN 3-2017.csv", comma clear names
	foreach var of varlist  agegroup sex city{
		replace `var' = lower(`var')	
	}

	replace agegroup = "1" if agegroup =="0-4"
	replace agegroup = "2" if agegroup =="5-9"
	replace agegroup = "3" if agegroup =="10-14"
	replace agegroup = "4" if agegroup =="15-17"

	rename sex gender
	replace gender = "1" if gender =="females"
	replace gender = "0" if gender =="males"
	drop if gender == "total"
	destring gender agegroup, replace

	egen strata= concat(agegroup gender city)

	save pop, replace

*end merge kenya 2009 census
