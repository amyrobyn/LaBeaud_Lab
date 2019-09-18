*Kenya_datamanagment_step1_R01_vs5

*Author: C.J.Alberts 
*Funding: R01 NIH, entitled xxxx
*Date: 8th of May 2018
*vs4: Data downloaded 16 June
*Objective: datamanagment

set more off
*log using "C:\Users\Nienke\Documents\Kenya\Stata\Log\Kenya_datamanagment_step1_R01_vs5.log" ,replace

*******************************************************************************
**Table of contents
*******************************************************************************
**Chapter 1: Import dataset 
**Chatper 2: Get an understanding of which participants are in the dataset
*******************************************************************************

********************************************************************************
**Chapter 1: Transform csv dataset into STATA
********************************************************************************
clear
import delimit "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_12Dec18.csv", delimiters(",") bindquotes(strict)

count

*Notice that I am only downloading ~8.300 records, that is because I don't have any access to the U24 data

********************************************************************************
**Chatper 2: Get an understanding of which participants are in the dataset
********************************************************************************

bysort person_id: gen temp2=_n
ta temp2, m

bysort v1: gen temp3=_n
ta temp3, m

drop temp2 temp3
	
save "C:\Users\Nienke\Documents\Stfd_Kenya_VBD\STATA\Dta\R01_AllData_12Dec18.dta", replace
clear
*log close
