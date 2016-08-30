use prevalent.dta, clear
destring id time denvigg_encode2 chikvigg_encode2 stanfordchikvigg_encode2 stanforddenvigg_encode2 site city, replace

		label variable city "City"
		label define City 1 "Chulaimbo" 2 "Kisumu" 3 "Milani" 5 "Nganja" 6 "Ukunda"

		capture drop if id_cohort=="d"
		replace id_cohort = "HCC" if id_cohort == "c"
		replace id_cohort = "AIC" if id_cohort == "f"
		encode id_cohort, gen(cohort)
		label variable cohort "Cohort"
		label define Cohort 1 "HCC" 2 "AIC"

	collapse (mean) denvigg_encode2 (count) n=denvigg_encode2 (sd) sddenvigg_encode2=denvigg_encode2, by(city cohort site)
	egen axis = axis(city cohort site)
	generate hidenvigg_encode2= denvigg_encode2 + invttail(n-1,0.025)*(sddenvigg_encode2/ sqrt(n))
	generate lodenvigg_encode2= denvigg_encode2 - invttail(n-1,0.025)*(sddenvigg_encode2/ sqrt(n))
graph twoway ///
   || (bar denvigg_encode2 axis, sort )(rcap hidenvigg_encode2 lodenvigg_encode2 axis) ///
   || scatter denvigg_encode2 axis, ms(i) mlab(n) mlabpos(12) mlabgap(2) mlabangle(45) mlabcolor(black) ///
   || , by(cohort) yscale(range(0.00 `=r(max)')) 
   *xlabel(1 "Chulaimbo" 2 "Nganja" 3 "Milani" 4 "Kisumu" 5 "Msambweni" 6 "Ukunda", angle(45))  legend(label(1 "`failvar'") label(2 "95% CI"))
/*   
   
   			collapse (mean) mean`failvar'= `failvar' (sd) sd`failvar'=`failvar' (count) n=`failvar', by(city cohort) 
			generate hi`failvar'= mean`failvar'+ invttail(n-1,0.025)*(sd`failvar'/ sqrt(n))
			generate lo`failvar'= mean`failvar'- invttail(n-1,0.025)*(sd`failvar'/ sqrt(n))
			graph twoway (bar mean`failvar' city, sort) (rcap hi`failvar' lo`failvar' city), by(cohort) yscale(range(0.00 `=r(max)')) xlabel(1 "Chulaimbo" 2 "Kisumu" 3 "Milani" 5 "Nganja" 6 "Ukunda", angle(45))  legend(label(1 "`failvar'") label(2 "95% CI")) ///
			

