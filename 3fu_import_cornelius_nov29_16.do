clear
capture log close
log using hcc_MonthlyUpdate
set more off
cd "C:\Users\Data Section\Desktop\HCC 3rd Followup\Kisumu\Stata files"
**//importing data**//
import excel "C:\Users\Data Section\Desktop\HCC 3rd Followup\Kisumu\Raw\HCC_followup_survey_v1_7_1.xlsx", sheet("HCC_followup_survey_v1_7_1") firstrow
sort KEY
save ksm_3rd_1,replace
clear
import excel "C:\Users\Data Section\Desktop\HCC 3rd Followup\Kisumu\Raw\HCC_followup_survey_v1_7_1_hospitalization.csv.xlsx", sheet("HCC_followup_survey_v1_7_1_hosp") firstrow
rename KEY child_key
rename PARENT_KEY KEY
sort KEY
save ksm_3rd_2,replace
**/merging datasets*//
clear
use ksm_3rd_1
merge KEY using ksm_3rd_2
save hcc_ksm_3fu,replace
tab _merge
drop _merge
**//generating a unique_key**//
gen lead="KCD" 
egen A=concat(lead demographic_informationhouse_num),format(%04.0f) punct("/")
egen StudyID=concat(A demographic_informationstudy_ID),format(%03.0f) punct("/")
drop lead A
save hcc_ksm_3fu,replace
****////checking duplicates****/////
unab vlist:_all
sort `vlist'
quietly by `vlist':gen dup=cond(_N==1,0,_n)
tab dup
****droping duplicates on all variables
drop if dup>1
******chacking for duplicates based on unique key
drop dup
sort StudyID
quietly by StudyID:gen dup=cond(_N==1,0,_n)
tab dup
*****dups on HCC_ID
sort demographic_informationHCC_ID
quietly by demographic_informationHCC_ID:gen dup2=cond(_N==1,0,_n)
tab dup2
****///////making Corrections on duplicates
replace StudyID="KCD/0069/006" if demographic_informationHCC_ID=="KCD0069006" 
replace demographic_informationstudy_ID=6 if demographic_informationHCC_ID=="KCD0069006"
replace demographic_informationHCC_ID="KCD0611003" if StudyID=="KCD/0611/003"
replace StudyID="KCD/0783/005" if demographic_informationHCC_ID=="KCD0783005" 
replace demographic_informationstudy_ID=5 if demographic_informationHCC_ID=="KCD0783005"
replace StudyID="KCD/0972/004" if demographic_informationHCC_ID=="KCD0972004" 
replace demographic_informationstudy_ID=4 if demographic_informationHCC_ID=="KCD0972004"

drop if demographic_informationHCC_ID=="LCD0001001"

replace StudyID="KCD/0777/005" if StudyID=="KCD/0777/004" & V=="Christine"
replace demographic_informationHCC_ID="KCD0777005" if StudyID=="KCD/0777/005"
replace demographic_informationstudy_ID=5 if StudyID=="KCD/0777/005"

replace StudyID="KCD/0973/003" if StudyID=="KCD/0943/003" & V=="Regan"
replace demographic_informationHCC_ID="KCD0973003" if StudyID=="KCD/0973/003"
replace demographic_informationhouse_num=973 if StudyID=="KCD/0973/003"

drop dup dup2

replace StudyID="KCD/0101/005" if StudyID=="KCD/0101/003"
replace demographic_informationstudy_ID=5 if StudyID=="KCD/0101/005"

replace StudyID="KCD/0561/004" if StudyID=="KCD/0561/006"
replace demographic_informationstudy_ID=4 if StudyID=="KCD/0561/004"

replace StudyID="KCD/1026/004" if StudyID=="KCD/1026/003"
replace demographic_informationstudy_ID=4 if StudyID=="KCD/1026/004"

save hcc_ksm_3fu,replace

**********************************************************************************


*******////// Renaming the Variables //////////////////////////////////////////

** drop variables that won't be used
drop SubmissionDate deviceid subscriberid phonenumber demographic_informationgpsLatitu ///
demographic_informationgpsLongiu demographic_informationgpsAltitu demographic_informationgpsAccuru ///
metainstanceID SETOFhospitalization child_key KEY

** study id
order StudyID, before(start)
label variable StudyID "study id"
drop demographic_informationHCC_ID

** a variable to indicate the version used
generate version = "v1.7.1"
label variable version "version of form"

** child village
generate ChildVillage = .
replace ChildVillage = 1 if demographic_informationvillage == "chulaimbo"
replace ChildVillage = 2 if demographic_informationvillage == "kisumu"
replace ChildVillage = 3 if demographic_informationvillage == "msambweni"
replace ChildVillage = 4 if demographic_informationvillage == "ukunda"
replace ChildVillage = 9 if demographic_informationvillage == "n/a"
order ChildVillage, after(today)
label variable ChildVillage "village"
drop demographic_informationvillage
replace ChildVillage=2 if ChildVillage==1

** interview date
rename demographic_informationinterview InterviewDate
label variable InterviewDate "interview date"

** interviewer name
rename J InterviewerName
label variable InterviewerName "interviewer's name"

rename K OthInterviewerName
label variable OthInterviewerName "specify other interviewer's name"

** house number
rename demographic_informationhouse_num HouseID
label variable HouseID "house number/id"

** child id
rename demographic_informationstudy_ID ChildIndividualID
label variable ChildIndividualID "child individual id"

** follow-up visit number
generate FollowupVisitNum = .
replace FollowupVisitNum = 1 if demographic_informationwhich_fol == "first"
replace FollowupVisitNum = 2 if demographic_informationwhich_fol == "second"
replace FollowupVisitNum = 3 if demographic_informationwhich_fol == "third"
replace FollowupVisitNum = 4 if demographic_informationwhich_fol == "fourth"
replace FollowupVisitNum = 5 if demographic_informationwhich_fol == "fifth"
replace FollowupVisitNum = 6 if demographic_informationwhich_fol == "sixth"
replace FollowupVisitNum = 7 if demographic_informationwhich_fol == "seventh"
replace FollowupVisitNum = 8 if demographic_informationwhich_fol == "eighth"
replace FollowupVisitNum = 9 if demographic_informationwhich_fol == "ninth"
replace FollowupVisitNum = 10 if demographic_informationwhich_fol == "tenth"
order FollowupVisitNum, after(ChildIndividualID)
label variable FollowupVisitNum "followup visit #"
drop demographic_informationwhich_fol

replace FollowupVisitNum=3 if FollowupVisitNum!=3

** specify other visit number
rename T OthFollowupVisitNum
label variable OthFollowupVisitNum "specify other f-up visit #"

** child's surname
rename demographic_informationchild_nam CSurname
label variable CSurname "child's surname"

** child's first name
rename V CFName
label variable CFName "child's first name"

** child's second name
rename W CSName
label variable CSName "child's second name"

** child's third name
rename X CTName
label variable CTName "child's third name"

** child's fourth name
rename Y CFthName
label variable CFthName "child's fourth name"

** date of birth
rename demographic_informationdate_of_b DoB
label variable DoB "child's date of birth"

** child's sex
generate Gender = .
replace Gender = 0 if demographic_informationgender == "male"
replace Gender = 1 if demographic_informationgender == "female"
order Gender, after(DoB)
label variable Gender "child's gender"
drop demographic_informationgender

** child's height
rename demographic_informationchild_hei ChildHeight
label variable ChildHeight "child's height (cm)"

** child's weight
rename demographic_informationchild_wei ChildWeight
label variable ChildWeight "child's weight (kg)"

** phone number
rename demographic_informationphone_num PhoneNumber
label variable PhoneNumber "phone number"

** child's occupation
generate ChildOccupation = .
replace ChildOccupation = 1 if demographic_informationoccupatio == "no_school_yet"
replace ChildOccupation = 2 if demographic_informationoccupatio == "madrassa"
replace ChildOccupation = 3 if demographic_informationoccupatio == "nursery_school"
replace ChildOccupation = 4 if demographic_informationoccupatio == "primary_school_student"
replace ChildOccupation = 5 if demographic_informationoccupatio == "secondary_school_student"
replace ChildOccupation = 6 if demographic_informationoccupatio == "other_student"
replace ChildOccupation = 7 if demographic_informationoccupatio == "housewife"
replace ChildOccupation = 8 if demographic_informationoccupatio == "herder"
replace ChildOccupation = 9 if demographic_informationoccupatio == "business_person"
replace ChildOccupation = 10 if demographic_informationoccupatio == "other"
replace ChildOccupation = 99 if demographic_informationoccupatio == "n/a"
order ChildOccupation, after(PhoneNumber)
label variable ChildOccupation "child's occupation"
drop demographic_informationoccupatio

** specify other child's occupation
rename AF OthChildOccupation
label variable OthChildOccupation "specify other child's occupation"

** child's education
generate EducLevel = .
replace EducLevel = 1 if demographic_informationkid_highe == "primary_school"
replace EducLevel = 2 if demographic_informationkid_highe == "secondary_school"
replace EducLevel = 3 if demographic_informationkid_highe == "college"
replace EducLevel = 4 if demographic_informationkid_highe == "professional_degree"
replace EducLevel = 5 if demographic_informationkid_highe == "other"
replace EducLevel = 9 if demographic_informationkid_highe == "n/a"
order EducLevel, after(OthChildOccupation)
label variable EducLevel "child's education"
drop demographic_informationkid_highe

** specify other child's education
rename AH OthEducLevel
label variable OthEducLevel "specify other child's education"

** mother's education
generate MumEducLevel = .
replace MumEducLevel = 1 if demographic_informationmom_highe == "primary_school"
replace MumEducLevel = 2 if demographic_informationmom_highe == "secondary_school"
replace MumEducLevel = 3 if demographic_informationmom_highe == "college"
replace MumEducLevel = 4 if demographic_informationmom_highe == "professional_degree"
replace MumEducLevel = 5 if demographic_informationmom_highe == "other"
replace MumEducLevel = 9 if demographic_informationmom_highe == "n/a"
order MumEducLevel, after(OthEducLevel)
label variable MumEducLevel "mothers's education"
drop demographic_informationmom_highe

** specify other mother's education
rename AJ OthMumEducLevel
label variable OthMumEducLevel "specify other mother's education"

** child travelled
generate ChildTravel = .
replace ChildTravel = 1 if backgroundtravel == "yes"
replace ChildTravel = 0 if backgroundtravel == "no"
replace ChildTravel = 8 if backgroundtravel == "refused"
order ChildTravel, after(OthMumEducLevel)
label variable ChildTravel "child travelled 10km or more in the last 6 mo"
drop backgroundtravel

** where child travelled
rename backgroundwhere WhereTravel
label variable WhereTravel "where child travelled"

** child spent more than one night 
generate NightAway = .
replace NightAway = 1 if backgroundstay_overnight == "yes"
replace NightAway = 0 if backgroundstay_overnight == "no"
replace NightAway = 8 if backgroundstay_overnight == "refused"
order NightAway, after(WhereTravel)
label variable NightAway "child spent more than one night at destination"
drop backgroundstay_overnight

** lifestyle changes
rename home_lifestyle_changes LifestyleChange
label variable LifestyleChange "lifestyle changes in last 6 mo"

** child with fever today
generate FeverToday = .
replace FeverToday = 1 if illnessillness_today == "yes"
replace FeverToday = 0 if illnessillness_today == "no"
replace FeverToday = 8 if illnessillness_today == "refused"
order FeverToday, after(LifestyleChange)
label variable FeverToday "child with fever today"
drop illnessillness_today

** number of fever illnesses
rename illnessnumber_illnesses NumIllnessFever
label variable NumIllnessFever "no. of illnesses with fever in past 6mo"

** symptoms of illness with fever
rename illnesssymptoms FeverSymptoms
label variable FeverSymptoms "symptoms of illnesses with fever in past 6mo"

** specify other illness with fever
rename illnesssymptoms_other OthFeverSymptoms
label variable OthFeverSymptoms "specify other symptoms"

** duration of symptoms
generate DurationSymptom = .
replace DurationSymptom = 1 if illnessduration == "0_3_days"
replace DurationSymptom = 2 if illnessduration == "4_7_days"
replace DurationSymptom = 3 if illnessduration == "2_weeks"
replace DurationSymptom = 4 if illnessduration == "3_weeks"
replace DurationSymptom = 5 if illnessduration == "4_weeks"
replace DurationSymptom = 6 if illnessduration == "5_weeks"
replace DurationSymptom = 7 if illnessduration == "6_weeks"
replace DurationSymptom = 8 if illnessduration == "more_6_weeks"
replace DurationSymptom = 77 if illnessduration == "don't_know"
replace DurationSymptom = 99 if illnessduration == "n/a"
order DurationSymptom, after(OthFeverSymptoms)
label variable DurationSymptom "duration of symptoms"
drop illnessduration

** child sought medical care
generate SeekMedCare = .
replace SeekMedCare = 1 if seek_medical_care == "yes"
replace SeekMedCare = 0 if seek_medical_care == "no"
replace SeekMedCare = 8 if seek_medical_care == "refused"
order SeekMedCare, after(DurationSymptom)
label variable SeekMedCare "child sought medical care"
drop seek_medical_care

** type of medical care sought
generate MedType = .
replace MedType = 1 if medical_caretype_medical_care == "traditional_healer"
replace MedType = 2 if medical_caretype_medical_care == "pharmacist"
replace MedType = 3 if medical_caretype_medical_care == "community_health_worker"
replace MedType = 4 if medical_caretype_medical_care == "nurse"
replace MedType = 5 if medical_caretype_medical_care == "physician"
replace MedType = 9 if medical_caretype_medical_care == "n/a"
order MedType, after(SeekMedCare)
label variable MedType "type of medical care"
drop medical_caretype_medical_care

** where medical care was sought
generate WhereMedSeek = .
replace WhereMedSeek = 1 if medical_carehospital == "chulaimbo_hc"
replace WhereMedSeek = 2 if medical_carehospital == "obama_childresn_hospital"
replace WhereMedSeek = 3 if medical_carehospital == "msambweni_dh"
replace WhereMedSeek = 4 if medical_carehospital == "ukunda_hc"
replace WhereMedSeek = 5 if medical_carehospital == "other"
replace WhereMedSeek = 9 if medical_carehospital == "n/a"
order WhereMedSeek, after(MedType)
label variable WhereMedSeek "where medical care was sought"
drop medical_carehospital

** specify other medicare care sought
rename medical_carehospital_other OthWhereMedSeek
label variable OthWhereMedSeek "specify other medical care sought"

** ever hospitalised
generate EverHospitalised = .
replace EverHospitalised = 1 if hospitalized == "yes"
replace EverHospitalised = 0 if hospitalized == "no"
replace EverHospitalised = 8 if hospitalized == "refused"
order EverHospitalised, after(OthWhereMedSeek)
label variable EverHospitalised "child ever hospitalised"
drop hospitalized

******number of hospitalizations
rename number_hospitalizations NumHosp
order NumHosp,after(EverHospitalised)

** reason for hospitalization
rename reason ReasonHospitalized1
order ReasonHospitalized1, after(NumHosp)
label variable ReasonHospitalized1 "reason hospitalised for illness 1"

** date hospitalized
rename when DateHospitalized1
order DateHospitalized1, after(ReasonHospitalized1)
label variable DateHospitalized1 "datehospitalised for illness 1"

** where hospitalized
generate HospitalName1 = .
replace HospitalName1 = 1 if where == "obama_childresn_hospital"
replace HospitalName1 = 2 if where == "chulaimbo_hc"
replace HospitalName1 = 3 if where == "msambweni_dh"
replace HospitalName1 = 4 if where == "ukunda_hc"
replace HospitalName1 = 5 if where == "other"
replace HospitalName1 = 9 if where == "n/a"
order HospitalName1, after(DateHospitalized1)
label variable HospitalName1 "hospital hospitalised for illness 1"
drop where

** specify other hospital
rename where_other OthHospitalName1
label variable OthHospitalName1 "reason hospitalised foAr illness 1"

** duration of hospitalization
generate DurationHospitalized1 = .
replace DurationHospitalized1 = 1 if duration == "0_3_days"
replace DurationHospitalized1 = 2 if duration == "4_7_days"
replace DurationHospitalized1 = 3 if duration == "2_weeks"
replace DurationHospitalized1 = 4 if duration == "3_weeks"
replace DurationHospitalized1 = 5 if duration == "4_weeks"
replace DurationHospitalized1 = 6 if duration == "5_weeks"
replace DurationHospitalized1 = 7 if duration == "6_weeks"
replace DurationHospitalized1 = 8 if duration == "more_6_weeks"
replace DurationHospitalized1 = 77 if duration == "don't_know"
order DurationHospitalized1, after(OthHospitalName1)
label variable DurationHospitalized1 "duration child hospitalised for illness 1"
drop duration

**********Cleaning the data
replace InterviewDate=date("06sep2016","DMY") if StudyID=="KCD/1000/003"
replace StudyID="KCD/1001/003" if StudyID=="KCD/1000/003"
replace HouseID=1001 if StudyID=="KCD/1001/003"

replace InterviewDate=date("06sep2016","DMY") if StudyID=="KCD/0294/003"
replace InterviewDate=date("06sep2016","DMY") if StudyID=="KCD/0383/005"
replace InterviewDate=date("06sep2016","DMY") if StudyID=="KCD/0293/004"
replace InterviewDate=date("29aug2016","DMY") if StudyID=="KCD/0386/003"

******correction on houseID
replace StudyID="KCD/1202/003" if StudyID=="KCD/2002/003"
replace HouseID=1202 if StudyID=="KCD/1202/003"
replace StudyID="KCD/1202/004" if StudyID=="KCD/2002/004"
replace HouseID=1202 if StudyID=="KCD/1202/004"
replace StudyID="KCD/1202/005" if StudyID=="KCD/2002/005"
replace HouseID=1202 if StudyID=="KCD/1202/005"
replace StudyID="KCD/1202/006" if StudyID=="KCD/2002/006"
replace HouseID=1202 if StudyID=="KCD/1202/006"

*****DoB Issue
replace DoB=date("01jan2005","DMY") if StudyID=="KCD/0149/004"
replace DoB=date("01aug2004","DMY") if StudyID=="KCD/1266/003"
replace DoB=date("01jan2011","DMY") if StudyID=="KCD/1101/004"
replace DoB=date("26aug2009","DMY") if StudyID=="KCD/1077/004"

******Height & weight issues
replace ChildHeight=121 if StudyID=="KCD/1253/004"
replace ChildHeight=133 if StudyID=="KCD/1252/004"
replace ChildWeight=21 if StudyID=="KCD/1252/004"
replace ChildHeight=112 if StudyID=="KCD/0013/003"
replace ChildWeight=20 if StudyID=="KCD/0013/003"
replace ChildHeight=110 if StudyID=="KCD/0250/005"
replace ChildWeight=20 if StudyID=="KCD/0250/005"

replace ChildHeight=158 if StudyID=="KCD/0415/003"
replace ChildWeight=62 if StudyID=="KCD/0415/003"

replace ChildHeight=158 if StudyID=="KCD/0820/003"
replace ChildWeight=48 if StudyID=="KCD/0820/003"

replace ChildHeight=98 if StudyID=="KCD/0867/005"
replace ChildWeight=15 if StudyID=="KCD/0867/005"

replace ChildHeight=133 if StudyID=="KCD/1020/003"
replace ChildWeight=22 if StudyID=="KCD/1020/003"

replace ChildHeight=137 if StudyID=="KCD/0657/004"
replace ChildWeight=30 if StudyID=="KCD/0657/004"

replace ChildHeight=135 if StudyID=="KCD/0155/005"
replace ChildWeight=25 if StudyID=="KCD/0155/005"

replace ChildHeight=111 if StudyID=="KCD/0267/004"
replace ChildWeight=19 if StudyID=="KCD/0267/004"

replace ChildHeight=148 if StudyID=="KCD/0213/003"

replace ChildHeight=106 if StudyID=="KCD/0053/006"
replace ChildWeight=18 if StudyID=="KCD/0053/006"

replace ChildHeight=139 if StudyID=="KCD/0865/004"
replace ChildWeight=37 if StudyID=="KCD/0865/004"

replace ChildHeight=133 if StudyID=="KCD/0865/005"
replace ChildWeight=23 if StudyID=="KCD/0865/005"

replace ChildHeight=142 if StudyID=="KCD/0367/004"
replace ChildWeight=32 if StudyID=="KCD/0367/004"

replace ChildHeight=109 if StudyID=="KCD/0523/003"

replace ChildHeight=139 if StudyID=="KCD/1193/004"
replace ChildWeight=30 if StudyID=="KCD/1193/004"

replace ChildWeight=16 if StudyID=="KCD/0065/004"

replace ChildHeight=158 if StudyID=="KCD/0111/004"
replace ChildWeight=44 if StudyID=="KCD/0111/004"

replace ChildWeight=25 if StudyID=="KCD/0415/005"
replace ChildWeight=35 if StudyID=="KCD/0409/003"
replace ChildWeight=33 if StudyID=="KCD/1123/005"
replace ChildWeight=40 if StudyID=="KCD/0383/005"

******PhoneNumber
replace PhoneNumber=. if PhoneNumber<=718


save hcc_ksm_3fu_varRenamed,replace

export excel using "C:\Users\Data Section\Desktop\HCC 3rd Followup\Kisumu\Cleaning\HCC_Kisumu_3FU_06oct2016.xls", sheetmodify firstrow(variables) nolabel


log close




