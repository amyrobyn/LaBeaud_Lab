********data from box
clear
import excel "C:\Users\Data Section\Desktop\AIC_Monthly_Cleaning\Databases\Western Data_AIC_27Sep2016.xlsx", sheet("Western_AIC_Initial") firstrow

/*******issues with Hospital Names
rename HospitalName1 ohn
gen HospitalName1=""
replace HospitalName1="1" if ohn==1
replace HospitalName1="2" if ohn==2
replace HospitalName1="3" if ohn==3
replace HospitalName1="4" if ohn==4
replace HospitalName1="5" if ohn==5
replace HospitalName1="9" if ohn==9
replace HospitalName1="99" if ohn==99
order HospitalName1,after(DateHospitalized1)
label var HospitalName1 HospitalName1
drop ohn

rename HospitalName2 ohn
gen HospitalName2=""
replace HospitalName2="1" if ohn==1
replace HospitalName2="2" if ohn==2
replace HospitalName2="3" if ohn==3
replace HospitalName2="4" if ohn==4
replace HospitalName2="5" if ohn==5
replace HospitalName2="9" if ohn==9
replace HospitalName2="99" if ohn==99
order HospitalName2,after(DateHospitalized2)
label var HospitalName2 HospitalName2
drop ohn

rename HospitalName3 ohn
gen HospitalName3=""
replace HospitalName3="1" if ohn==1
replace HospitalName3="2" if ohn==2
replace HospitalName3="3" if ohn==3
replace HospitalName3="4" if ohn==4
replace HospitalName3="5" if ohn==5
replace HospitalName3="9" if ohn==9
replace HospitalName3="99" if ohn==99
order HospitalName3,after(DateHospitalized3)
label var HospitalName3 HospitalName3
drop ohn
rename HospitalName4 ohn
gen HospitalName4=""
replace HospitalName4="1" if ohn==1
replace HospitalName4="2" if ohn==2
replace HospitalName4="3" if ohn==3
replace HospitalName4="4" if ohn==4
replace HospitalName4="5" if ohn==5
replace HospitalName4="9" if ohn==9
replace HospitalName4="99" if ohn==99
order HospitalName4,after(DateHospitalized4)
label var HospitalName4 HospitalName4
drop ohn
rename HospitalName5 ohn
gen HospitalName5=""
replace HospitalName5="1" if ohn==1
replace HospitalName5="2" if ohn==2
replace HospitalName5="3" if ohn==3
replace HospitalName5="4" if ohn==4
replace HospitalName5="5" if ohn==5
replace HospitalName5="9" if ohn==9
replace HospitalName5="99" if ohn==99
order HospitalName5,after(DateHospitalized5)
label var HospitalName5 HospitalName5
drop ohn */



save Aic_Box,replace

*******New month data
clear
import excel "C:\Users\Data Section\Desktop\AIC_Monthly_Cleaning\Clean\AIC_Initial_Oct2016.xls", sheet("Sheet1") firstrow

****chest exam issue
gen ChestExamCoded=""
order ChestExamCoded,after (ChestExam)
replace ChestExamCoded="1" if ChestExam=="normal"
replace ChestExamCoded="2" if ChestExam=="rapid_breathing"
replace ChestExamCoded="3" if ChestExam=="rales"
replace ChestExamCoded="4" if ChestExam=="rhonchi"
replace ChestExamCoded="5" if ChestExam=="wheezes"
replace ChestExamCoded="6" if ChestExam=="flaring"


******changing variables to allow append
gen StudyID_copy=StudyID
rename SubmissionDate submissiondate
order StudyID_copy,before(submissiondate)
drop Hemoglobin
rename Hemoglobin_lb Hemoglobin
label var Hemoglobin Hemoglobin
drop SetOfPastMedHistory metainstanceID
rename DateHospitalized DateHospitalized1
rename DateHospitalized2 DateHospitalized
rename HospitalName HospitalName1
rename RedEye IF
save Aic_Oct2016,replace

clear
use Aic_Box
append using Aic_Oct2016,force

******droping and changing Names
drop  OthNodeExam
****Interview date issue
replace InterviewDate=date("05nov2015","DMY") if StudyID=="KFA0464"
replace InterviewDate=date("22feb2016","DMY") if StudyID=="KFA0564"
replace InterviewDate=date("17feb2014","DMY") if StudyID=="KFA0009"
replace Today=date("17feb2014","DMY") if StudyID=="KFA0009"
replace End=date("17feb2014","DMY") if StudyID=="KFA0009"
replace Start=date("17feb2014","DMY") if StudyID=="KFA0009"


replace InterviewerName="VICTORIA OKUTA" if InterviewerName=="VICTORIA_OKUTA"
replace InterviewerName="WINNIE ONYANGO" if InterviewerName=="WINNIE_ONYANGO"

save AIC_IniDatabase_Oct2016,replace
export excel using "C:\Users\Data Section\Desktop\AIC_Monthly_Cleaning\Western Data_AIC_27Sep2016.xlsx", sheet("Western_AIC_Initial") sheetmodify firstrow(varlabels) nolabel
