clear
capture log close
log using AIC_Monthly_Update,text replace
set more off

cd "C:\Users\Data Section\Desktop\AIC_Monthly_Cleaning\Stata Files"

*****importing Chulaimbo dataset one
import excel "C:\Users\Data Section\Desktop\AIC_Monthly_Cleaning\Databases\ch_AIC_initial_survey_v1_9_1.xlsx", sheet("AIC_initial_survey_v1_9_1") firstrow
sort KEY
save Aic_cc_one,replace

*******importing the set of hospitalization
clear
import excel "C:\Users\Data Section\Desktop\AIC_Monthly_Cleaning\Databases\ch_AIC_initial_survey_v1_9_1_past_med_history_past_hospitalization.xlsx", sheet("AIC_initial_survey_v1_9_1_past_") firstrow
rename KEY Child_key
rename PARENT_KEY KEY
sort KEY
save Aic_cc_two,replace

**********merging the datasets
clear
use Aic_cc_one
merge KEY using Aic_cc_two 
save AIC_CC,replace 
tab _merge

********saving Chulaimbo Dataset
drop _merge


****************/////////Harmonizing variables with Richard"s

rename 	demographic_informationPatient_I	StudyID
rename 	start	Start
rename 	end	End
rename 	today	Today
rename 	demographic_informationhospital_	HospitalSite
rename 	demographic_informationHCC	HCCParticipant
rename 	demographic_informationHCC_ID	HCCID
rename 	demographic_informationvisit_typ	VisitType
rename 	demographic_informationvillage	ChildVillage
rename 	demographic_informationinterview	InterviewerName
rename 	N OthInterviewerName
rename 	O	InterviewDate

rename 	demographic_informationchild_na ChidSurname	
rename 	Q	ChildFirstName
rename 	R ChildSecondName
rename 	S ChildThirdName 
rename 	T ChildFourthName
rename 	demographic_informationmother_na MotherSurname
rename 	V MotherFirstName
rename 	W MotherSecondName
rename  X MotherThirdName
rename 	Y MotherFourthName
rename 	demographic_informationfather_na FatherSurname
rename 	AA FatherFirstName
rename  AB FatherSecondName
rename 	AC FatherThirdName
rename 	AD FatherFourthName
rename 	demographic_informationphone_num	PhoneNumber 
	

rename 	demographic_informationInformant	InformantRelation
rename 	AF OthInformantRelation
rename 	demographic_informationdate_of_b	DoB
rename 	demographic_informationgender	Gender
rename 	demographic_informationoccupatio	ChildOccupation
rename  AK	OthChildOccupation
rename 	demographic_informationkid_highe	EducLevel
rename 	AM	OthEducLevel
rename 	demographic_informationmom_highe	MumEducLevel
rename 	AO	OthMumEducLevel
rename 	demographic_informationroof_type	RoofType
rename 	AQ	OthRoofType
rename 	demographic_informationlatrine_t	LatrineType
rename 	AS	OthLatrineType
rename 	demographic_informationfloor_typ	FloorType
rename  AU	OthFloorType
rename 	demographic_informationdrinking_	WaterSource
rename 	demographic_informationlight_sou	LightSource
rename 	AX	OthLightSource
rename 	demographic_informationwindows	Windows
rename 	demographic_informationnumber_wi	WindowNum
rename 	demographic_informationrooms_in_	NumRoomHse
rename 	demographic_informationnumber_pe	NumPpleHse
rename 	demographic_informationnumber_si	NumSiblings

**********where the loops begin **********/
rename 	demographic_informationnumber_sl	NumSleepRoom
rename 	demographic_informationSEStelep	Telephone
rename 	demographic_informationSESradio	Radio
rename 	demographic_informationSEStv	Television
rename 	demographic_informationSESbicyc	Bicycle
rename 	demographic_informationSESmotor	MotorizedVehicle
rename 	demographic_informationSESdomes	DomesticWorker
rename 	backgroundfever_contact	ChildContact
rename 	backgroundoutdoor_activity	OutdoorActivity
rename 	backgroundmosquito_bites	MosquitoBites
rename 	backgroundmosquito_coil	MosquitoCoil
rename 	backgroundmosquito_net	SleepBednet
rename 	backgroundchild_travel	ChildTravel
rename 	backgroundwhere	WhereTravel
rename 	backgroundstay_overnight	NightAway
rename 	past_med_historyever_hospitalize	EverHospitalised
rename SETOFpast_med_historypast_hosp SetOfPastMedHistory
rename 	number_hospitalizations	NumHospitalized
rename 	reason	ReasonHospitalized1
rename 	when_hospitalized	DateHospitalized
rename 	where_hospitalized	HospitalName

rename 	duration	DurationHospitalized1

rename 	past_med_historyever_had_surgery	EverSurgery
rename 	past_med_historywhy	ReasonSurgery
rename 	past_med_historywhen_surgery	DateSurgery
rename 	past_med_historyterm	Gestational
rename 	past_med_historybreast_fed	BreastFed
rename 	past_med_historyhow_long	DurationBFed
rename 	past_med_historyhow_long_other	OthDurationBFed
rename 	past_med_historyimmunizations	ChildVaccination
rename 	past_med_historyyellow_fever	YellowFever
rename 	past_med_historywhen_vaccinated_	DateYellowFever
rename 	past_med_historyjapanese_encepha	Encephalitis
rename 	CF	DateEncephalitis
rename 	past_med_historypast_medical_his	PastMedHist
rename  CH	OthPastMedHist
rename 	past_med_historycurrently_taking	CurrentTakingMeds
rename 	past_med_historycurrent_medicati	CurrentMeds
rename 	CK	OthCurrentMeds
rename 	past_med_historypregnant	EverPregnant
rename 	current_diseasedate_symptom_onse	NumDaysOnset
rename 	current_diseasesymptoms	CurrentSymptoms
rename 	current_diseasesymptoms_other	OthCurrentSymptoms
rename 	physical_examtemp	Temperature
rename 	physical_examchild_height	ChildHeight
rename 	physical_examchild_weight	ChildWeight
rename 	physical_examhead_circumference	HeadCircum
rename 	physical_examheart_rate	HeartRate
rename 	physical_examresp_rate	RespRate
rename 	physical_examblood_pressuresyst	SystolicBP
rename 	physical_examblood_pressuredias	DiastolicBP
rename 	physical_exampulse_ox	PulseOximetry
rename 	physical_examcan_visual_acuity	PerformVisualAcuity
rename 	physical_examvisual_acuity_left	LeftVisualAcuity
rename 	physical_examvisual_acuity_right	RightVisualAcuity
rename 	physical_examhead_neck_examhead	HeadNeckExam
rename 	physical_examhead_neck_examclin	ClinicianNotesHNeck
rename 	physical_examchest_examchest	ChestExam
rename 	physical_examchest_examclinicia	ClinicianNotesChest
rename 	physical_examheart_examheart	HeartExam
rename 	physical_examheart_examclinicia	ClinicianNotesHeart
rename 	physical_examabdomen_examabdome	AbdomenExam
rename 	physical_examabdomen_examlocati	AbdLocation
rename 	physical_examabdomen_examclinic	ClinicianNotesAbd
rename 	physical_examnode_examnodes	NodeExam
rename 	physical_examnode_examnodes_oth	OthNodeExam
rename 	physical_examnode_examclinician	ClinicianNotesNode
rename 	physical_examjointsjoints	JointExam
rename 	physical_examjointsjoint_locati	JointLocation
rename 	physical_examjointsclinician_no	ClinicianNotesJoint
rename 	physical_examskin_examskin	SkinExam
rename 	physical_examskin_examskin_othe	OthSkinExam
rename 	physical_examskin_examclinician	ClinicianNotesSkin
rename 	physical_examneuro_examneuro	NeuroExam
rename 	physical_examneuro_examneuro_ot	OthNeuroExam
rename 	physical_examneuro_examclinicia	ClinicianNotesNeuro
rename 	physical_examtourniquet_test	TourniquetTest
rename 	severity_criteriaLab_testsmal_t	MalTestOrdered
rename 	DZ	OthMalTestOrdered
rename 	severity_criteriaLab_testsmalar	BSResults
rename 	severity_criteriaLab_testsRDT_r	RDTResults
rename  severity_criteriaLab_testslabs	LabTests
rename  severity_criteriaLab_testshemog	WBC
rename 	EE	NeutroPercent
rename 	EF	LymphPercent
rename 	EG	MonoPercent
rename 	EH	EosinoPercent
rename 	EI	Hemoglobin
rename 	EJ	MCV
rename 	EK	Platelets
rename 	EL	OthBloodCounts
rename 	severity_criteriaLab_testsHb_re	Hb
rename 	severity_criteriaLab_testsHIV_r	HIVResult
rename 	severity_criteriaLab_testsUAUA	UrinalysisResult
rename 	severity_criteriaLab_testsUAab	AbnormalUrinalysisResult
rename 	severity_criteriaLab_testsStool	StoolOvaCyst
rename 	ER	OthStoolOvaCyst
rename 	severity_criteriaLab_testswidal	WidalResult
rename 	severity_criteriaLab_testssickl	SickleCellResult
rename 	severity_criteriaLab_testsOther	OthLabTests
rename 	EV	OthLabResults
rename 	severity_criteriaprimary_diagnos	PrimaryDiag
rename 	EX	OthPrimaryDiag
rename 	severity_criteriabacteria_dx	PrimaryBacterialDX
rename 	severity_criteriasecondary_diagn	SecondaryDiag
rename  FA	OthSecondaryDiag
rename 	severity_criteriasec_bact_dx	SecondaryBacterialDX
rename 	severity_criteriaHealth_impacts	HealthImpacts
rename 	severity_criteriaHealth_impacts_	OthHealthImpacts
rename 	severity_criteriameds_prescribed	MedsPrescribe
rename 	FF	OthMedsPrescribe
rename 	severity_criteriaoutcome	Outcome
rename 	severity_criteriaoutcome_other	OthOutcome
rename 	severity_criteriahospitalization	OutcomeHospitalized
rename  FJ	LocationHospital
rename 	FK	OthLocationHospital
rename 	FL	DateHospitalized2
generate Version="v1.9.1"	



save AIC_Chulaimbo_Initial,replace

export excel using "C:\Users\Data Section\Desktop\AIC_Monthly_Cleaning\Cleaning\Aic_Initial_Chulaimbo.xls", sheetmodify firstrow(variables)

********************Importing Obama datasets
clear 
import excel "C:\Users\Data Section\Desktop\AIC_Monthly_Cleaning\Databases\Ob_AIC_initial_survey_v1_9_1.xlsx", sheet("AIC_initial_survey_v1_9_1") firstrow
sort KEY
save Aic_ob_one,replace
*********set of hospitalization
clear
import excel "C:\Users\Data Section\Desktop\AIC_Monthly_Cleaning\Databases\Ob_AIC_initial_survey_v1_9_1_past_med_history_past_hospitalization.xlsx", sheet("AIC_initial_survey_v1_9_1_past_") firstrow
rename KEY Child_key
rename PARENT_KEY KEY
sort KEY
save Aic_ob_two,replace

**********merging the datasets
clear
use Aic_ob_one
merge KEY using Aic_ob_two 
save AIC_OB,replace 
tab _merge

drop _merge
save AIC_Obama_Initial,replace

*********Changing unmatched variable names 
rename 	demographic_informationPatient_I	StudyID
rename 	start	Start
rename 	end	End
rename 	today	Today
rename 	demographic_informationhospital_	HospitalSite
rename 	demographic_informationHCC	HCCParticipant
rename 	demographic_informationHCC_ID	HCCID
rename 	demographic_informationvisit_typ	VisitType
rename 	demographic_informationvillage	ChildVillage
rename 	demographic_informationinterview	InterviewerName
rename 	N OthInterviewerName
rename 	O	InterviewDate

rename 	demographic_informationchild_na ChidSurname	
rename 	Q	ChildFirstName
rename 	R ChildSecondName
rename 	S ChildThirdName 
rename 	T ChildFourthName
rename 	demographic_informationmother_na MotherSurname
rename 	V MotherFirstName
rename 	W MotherSecondName
rename  X MotherThirdName
rename 	Y MotherFourthName
rename 	demographic_informationfather_na FatherSurname
rename 	AA FatherFirstName
rename  AB FatherSecondName
rename 	AC FatherThirdName
rename 	AD FatherFourthName
rename 	demographic_informationphone_num	PhoneNumber 
	

rename 	demographic_informationInformant	InformantRelation
rename 	AF OthInformantRelation
rename 	demographic_informationdate_of_b	DoB
rename 	demographic_informationgender	Gender
rename 	demographic_informationoccupatio	ChildOccupation
rename  AK	OthChildOccupation
rename 	demographic_informationkid_highe	EducLevel
rename 	AM	OthEducLevel
rename 	demographic_informationmom_highe	MumEducLevel
rename 	AO	OthMumEducLevel
rename 	demographic_informationroof_type	RoofType
rename 	AQ	OthRoofType
rename 	demographic_informationlatrine_t	LatrineType
rename 	AS	OthLatrineType
rename 	demographic_informationfloor_typ	FloorType
rename  AU	OthFloorType
rename 	demographic_informationdrinking_	WaterSource
rename 	demographic_informationlight_sou	LightSource
rename 	AX	OthLightSource
rename 	demographic_informationwindows	Windows
rename 	demographic_informationnumber_wi	WindowNum
rename 	demographic_informationrooms_in_	NumRoomHse
rename 	demographic_informationnumber_pe	NumPpleHse
rename 	demographic_informationnumber_si	NumSiblings

**********where the loops begin **********/
rename 	demographic_informationnumber_sl	NumSleepRoom
rename 	demographic_informationSEStelep	Telephone
rename 	demographic_informationSESradio	Radio
rename 	demographic_informationSEStv	Television
rename 	demographic_informationSESbicyc	Bicycle
rename 	demographic_informationSESmotor	MotorizedVehicle
rename 	demographic_informationSESdomes	DomesticWorker
rename 	backgroundfever_contact	ChildContact
rename 	backgroundoutdoor_activity	OutdoorActivity
rename 	backgroundmosquito_bites	MosquitoBites
rename 	backgroundmosquito_coil	MosquitoCoil
rename 	backgroundmosquito_net	SleepBednet
rename 	backgroundchild_travel	ChildTravel
rename 	backgroundwhere	WhereTravel
rename 	backgroundstay_overnight	NightAway
rename 	past_med_historyever_hospitalize	EverHospitalised
rename SETOFpast_med_historypast_hosp SetOfPastMedHistory
rename 	number_hospitalizations	NumHospitalized
rename 	reason	ReasonHospitalized1
rename 	when_hospitalized	DateHospitalized
rename 	where_hospitalized	HospitalName

rename 	duration	DurationHospitalized1

rename 	past_med_historyever_had_surgery	EverSurgery
rename 	past_med_historywhy	ReasonSurgery
rename 	past_med_historywhen_surgery	DateSurgery
rename 	past_med_historyterm	Gestational
rename 	past_med_historybreast_fed	BreastFed
rename 	past_med_historyhow_long	DurationBFed
rename 	past_med_historyhow_long_other	OthDurationBFed
rename 	past_med_historyimmunizations	ChildVaccination
rename 	past_med_historyyellow_fever	YellowFever
rename 	past_med_historywhen_vaccinated_	DateYellowFever
rename 	past_med_historyjapanese_encepha	Encephalitis
rename 	CF	DateEncephalitis
rename 	past_med_historypast_medical_his	PastMedHist
rename  CH	OthPastMedHist
rename 	past_med_historycurrently_taking	CurrentTakingMeds
rename 	past_med_historycurrent_medicati	CurrentMeds
rename 	CK	OthCurrentMeds
rename 	past_med_historypregnant	EverPregnant
rename 	current_diseasedate_symptom_onse	NumDaysOnset
rename 	current_diseasesymptoms	CurrentSymptoms
rename 	current_diseasesymptoms_other	OthCurrentSymptoms
rename 	physical_examtemp	Temperature
rename 	physical_examchild_height	ChildHeight
rename 	physical_examchild_weight	ChildWeight
rename 	physical_examhead_circumference	HeadCircum
rename 	physical_examheart_rate	HeartRate
rename 	physical_examresp_rate	RespRate
rename 	physical_examblood_pressuresyst	SystolicBP
rename 	physical_examblood_pressuredias	DiastolicBP
rename 	physical_exampulse_ox	PulseOximetry
rename 	physical_examcan_visual_acuity	PerformVisualAcuity
rename 	physical_examvisual_acuity_left	LeftVisualAcuity
rename 	physical_examvisual_acuity_right	RightVisualAcuity
rename 	physical_examhead_neck_examhead	HeadNeckExam
rename 	physical_examhead_neck_examclin	ClinicianNotesHNeck
rename 	physical_examchest_examchest	ChestExam
rename 	physical_examchest_examclinicia	ClinicianNotesChest
rename 	physical_examheart_examheart	HeartExam
rename 	physical_examheart_examclinicia	ClinicianNotesHeart
rename 	physical_examabdomen_examabdome	AbdomenExam
rename 	physical_examabdomen_examlocati	AbdLocation
rename 	physical_examabdomen_examclinic	ClinicianNotesAbd
rename 	physical_examnode_examnodes	NodeExam
rename 	physical_examnode_examnodes_oth	OthNodeExam
rename 	physical_examnode_examclinician	ClinicianNotesNode
rename 	physical_examjointsjoints	JointExam
rename 	physical_examjointsjoint_locati	JointLocation
rename 	physical_examjointsclinician_no	ClinicianNotesJoint
rename 	physical_examskin_examskin	SkinExam
rename 	physical_examskin_examskin_othe	OthSkinExam
rename 	physical_examskin_examclinician	ClinicianNotesSkin
rename 	physical_examneuro_examneuro	NeuroExam
rename 	physical_examneuro_examneuro_ot	OthNeuroExam
rename 	physical_examneuro_examclinicia	ClinicianNotesNeuro
rename 	physical_examtourniquet_test	TourniquetTest
rename 	severity_criteriaLab_testsmal_t	MalTestOrdered
rename 	DZ	OthMalTestOrdered
rename 	severity_criteriaLab_testsmalar	BSResults
rename 	severity_criteriaLab_testsRDT_r	RDTResults
rename  severity_criteriaLab_testslabs	LabTests
rename  severity_criteriaLab_testshemog	WBC
rename 	EE	NeutroPercent
rename 	EF	LymphPercent
rename 	EG	MonoPercent
rename 	EH	EosinoPercent
rename 	EI	Hemoglobin
rename 	EJ	MCV
rename 	EK	Platelets
rename 	EL	OthBloodCounts
rename 	severity_criteriaLab_testsHb_re	Hb
rename 	severity_criteriaLab_testsHIV_r	HIVResult
rename 	severity_criteriaLab_testsUAUA	UrinalysisResult
rename 	severity_criteriaLab_testsUAab	AbnormalUrinalysisResult
rename 	severity_criteriaLab_testsStool	StoolOvaCyst
rename 	ER	OthStoolOvaCyst
rename 	severity_criteriaLab_testswidal	WidalResult
rename 	severity_criteriaLab_testssickl	SickleCellResult
rename 	severity_criteriaLab_testsOther	OthLabTests
rename 	EV	OthLabResults
rename 	severity_criteriaprimary_diagnos	PrimaryDiag
rename 	EX	OthPrimaryDiag
rename 	severity_criteriabacteria_dx	PrimaryBacterialDX
rename 	severity_criteriasecondary_diagn	SecondaryDiag
rename  FA	OthSecondaryDiag
rename 	severity_criteriasec_bact_dx	SecondaryBacterialDX
rename 	severity_criteriaHealth_impacts	HealthImpacts
rename 	severity_criteriaHealth_impacts_	OthHealthImpacts
rename 	severity_criteriameds_prescribed	MedsPrescribe
rename 	FF	OthMedsPrescribe
rename 	severity_criteriaoutcome	Outcome
rename 	severity_criteriaoutcome_other	OthOutcome
rename 	severity_criteriahospitalization	OutcomeHospitalized
rename  FJ	LocationHospital
rename 	FK	OthLocationHospital
rename 	FL	DateHospitalized2
generate Version="v1.9.1"	




******saving the changes 
save AIC_Obama_Initial,replace

export excel using "C:\Users\Data Section\Desktop\AIC_Monthly_Cleaning\Cleaning\Aic_Kisumu_VarRenamed_Cont_Update.xls", sheetmodify firstrow(variables)

********appending the two Initial Datasets
clear
use AIC_Chulaimbo_Initial
append using AIC_Obama_Initial,force
save AIC_Initial_Dataset_v1.9.1_Upto_11Nov2016,replace

export excel using "C:\Users\Data Section\Desktop\AIC_Monthly_Cleaning\Cleaning\Ksm_Chulaimbo_Initial_merged16Nov2016.xls", sheetmodify firstrow(variables)

*******removing data already Handled before
drop if Today<=date("30Sep2016","DMY")
save AIC_Initial_Dataset_Oct2016,replace

*******checking for duplicates
unab vlist:_all
sort `vlist'
quietly by `vlist':gen dup=cond(_N==1,0,_n)
tab dup
*****droping duplicates
drop if dup>1


***checking for duplicates on StudyID
drop dup
sort StudyID
quietly by StudyID:gen dup=cond(_N==1,0,_n)
tab dup
***droping duplicate 
drop if dup>1
drop dup


********making changes on incorrect information


*****saving the final dataset
save AIC_Initial_Dataset_Oct2016,replace
export excel using "C:\Users\Data Section\Desktop\AIC_Monthly_Cleaning\Cleaning\AIC_Initial_Dataset_Oct2016.xls", sheetmodify firstrow(variables)

*********//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
**************LABELING AND CODING VARIABLES

*******HospitalSite
rename HospitalSite Site
gen HospitalSite=.
replace HospitalSite=1 if Site=="Obama"
replace HospitalSite=5 if Site=="Mbaka_oromo"
label define Hospital 1 "Obama" 5 "Mbaka_oromo"
label values HospitalSite Hospital
order HospitalSite,after(Today)
drop Site

**********HCC Patient YesNoRe
rename HCCParticipant HCCp
gen HCCParticipant=.
replace HCCParticipant=1 if HCCp=="yes"
replace HCCParticipant=0 if HCCp=="no"
replace HCCParticipant=8 if HCCp=="refused"
label define YesNoRe 1 "yes" 0 "no" 8 "refused"
label values HCCParticipant YesNoRe
order HCCParticipant,after(HospitalSite)
drop HCCp

////////////////////////ENCODING
******visit type
rename VisitType VT
generate VisitType=.
replace VisitType=1 if VT=="initial"
replace VisitType=2 if VT=="reenroll"
label define vstype 1 "initial" 2 "reenroll"
label values VisitType vstype
order VisitType,after(HCCID)
drop VT

*****Informanlation
rename InformantRelation IR
gen InformantRelation=.
replace InformantRelation=1 if 	IR=="child_patient" 
replace InformantRelation=2 if 	IR=="mother"
replace InformantRelation=3 if 	IR=="father"
replace InformantRelation=4 if 	IR=="sister"
replace InformantRelation=5 if 	IR=="brother"
replace InformantRelation=6 if 	IR=="aunt" 
replace InformantRelation=7 if 	IR=="uncle"
replace InformantRelation=8 if 	IR=="grandmother"
replace InformantRelation=9 if 	IR=="grandfather"
replace InformantRelation=10 if IR=="other"
label define InfRe 1 "child_patient" 2 "mother" 3 "father" 4 "sister" 5 "brother" 6 "aunt" 7 "uncle" 8 "grandmother" 9 "grandfather" 10 "other"
label values InformantRelation InfRe
drop IR
order InformantRelation,after(FatherFourthName)

**********Child's gender
rename Gender sex
gen Gender=.
replace Gender=0 if sex=="male"
replace Gender=1 if sex=="female"
order Gender,after (DoB)
drop sex
label define sex 1 "female" 0 "male"
label values Gender sex

******Child occupation
rename ChildOccupation CO
gen ChildOccupation=.
replace ChildOccupation=1 if CO=="no_school_yet"
replace ChildOccupation=2 if CO=="madrassa"
replace ChildOccupation=3 if CO=="nursery_school"
replace ChildOccupation=4 if CO=="primary_school_student"
replace ChildOccupation=5 if CO=="secondary_school_student"
replace ChildOccupation=6 if CO=="other_student"
replace ChildOccupation=7 if CO=="house_wife"
replace ChildOccupation=8 if CO=="herder" 
replace ChildOccupation=9 if CO=="business_person"
replace ChildOccupation=10 if CO=="other"
replace ChildOccupation=99 if CO=="n/a"
order ChildOccupation,after (PhoneNumber)
label define Co 1 "no_school_yet" 2 "madrassa" 3 "nursery_school" 4 "primary_school_student" 5 "secondary_school_student" 6 "other_student" 7 "house_wife" 8 "herder" 9 "business_person" 10 "other" 99 "n/a"
label values ChildOccupation Co
drop CO

******education level
rename EducLevel EdLe
gen EducLevel=.
replace EducLevel=1 if EdLe=="primary_school"
replace EducLevel=2 if EdLe=="secondary_school"
replace EducLevel=3 if EdLe=="college"
replace EducLevel=4 if EdLe=="professional_degree"
replace EducLevel=5 if EdLe=="other"
replace EducLevel=9 if EdLe=="n/a"
order EducLevel,before(OthEducLevel)
label define EduLev 1 "primary_school" 2 "secondary_school" 3 "college" 4 "professional_degree" 5 "other" 9 "n/a"
label values EducLevel EduLev
drop EdLe
     *****mother
	 rename MumEducLevel MumEd
	 gen MumEducLevel=.
     replace MumEducLevel=1 if MumEd=="primary_school"
     replace MumEducLevel=2 if MumEd=="secondary_school"
     replace MumEducLevel=3 if MumEd=="college"
     replace MumEducLevel=4 if MumEd=="professional_degree"
     replace MumEducLevel=5 if MumEd=="other"
     replace MumEducLevel=9 if MumEd=="n/a"
	 
	 order MumEducLevel,after(OthEducLevel)
	 label values MumEducLevel EduLev
	 drop MumEd
	 
*******roof type
rename RoofType RT
gen RoofType=.
replace RoofType=1 if RT=="natural_material"
replace RoofType=2 if RT=="corrugated_iron"
replace RoofType=3 if RT=="plastic"
replace RoofType=4 if RT=="other"
replace RoofType=9 if RT=="n/a"
order RoofType,after(OthMumEducLevel)
label define RfTyp 1 "natural_material" 2 "corrugated_iron" 3 "plastic" 4 "other" 9 "n/a"
label values RoofType RfTyp
drop RT

****Latrine type
rename LatrineType LT
gen LatrineType=.
replace LatrineType=1 if LT=="none"
replace LatrineType=2 if LT=="bush"
replace LatrineType=3 if LT=="pit_latrine"
replace LatrineType=4 if LT=="VIP_latrine"
replace LatrineType=5 if LT=="flush_toilet"
replace LatrineType=6 if LT=="other" 
replace LatrineType=9 if LT=="n/a"
order LatrineType,after(OthRoofType)
label define LTTyp 1 "none" 2 "bush" 3 "pit_latrine" 4 "VIP_latrine" 5 "flush_toilet" 6 "other" 9 "n/a"
label values LatrineType LTTyp
drop LT
********Floor type
rename FloorType FT
gen FloorType=.
replace FloorType=1 if  FT=="dirt"
replace FloorType=2 if  FT=="wood"
replace FloorType=3 if  FT=="cement"
replace FloorType=4 if  FT=="tile"
replace FloorType=5 if  FT=="other"
replace FloorType=9 if  FT=="n/a"
order FloorType,after(OthLatrineType)
label define FlTyp 1 "dirt" 2 "wood" 3 "cement" 4 "tile" 5 "other" 9 "n/a"
label values FloorType FlTyp
drop FT

******** water source
rename WaterSource WS
gen WaterSource=.
replace WaterSource=1 if WS=="river_pond"
replace WaterSource=2 if WS=="rain"
replace WaterSource=3 if WS=="publicwell_borehole"
replace WaterSource=4 if WS=="inside_well"
replace WaterSource=5 if WS=="publictap_piped"
replace WaterSource=6 if WS=="water_truck"
replace WaterSource=9 if WS=="n/a"
order WaterSource,after (OthFloorType)
label define WatSrce 1 "river_pond" 2 "rain" 3 "publicwell_borehole" 4 "inside_well" 5 "publictap_piped" 6 "water_truck" 9 "n/a"
label values WaterSource watSrce
drop WS

********light source
rename LightSource LS
gen  LightSource=.
replace  LightSource=1 if LS=="electricity_line"
replace  LightSource=2 if LS=="paraffin"
replace  LightSource=3 if LS=="gas"
replace  LightSource=4 if LS=="firewood"
replace  LightSource=5 if LS=="charcoal"
replace  LightSource=6 if LS=="solar"
replace  LightSource=7 if LS=="other"
replace  LightSource=8 if LS=="n/a"
order LightSource,after(WaterSource)
label define LightSrce 1 "electricity_line" 2 "paraffin" 3 "gas" 4 "firewood" 5 "charcoal" 6 "solar" 7 "other" 8 "n/a"
label values LightSource LightSrce
drop LS

********Telephone
rename Telephone tel
gen Telephone=.
replace Telephone=1 if tel=="yes"
replace Telephone=0 if tel=="no"
replace Telephone=8 if tel=="refused"
order Telephone,after(NumSleepRoom)
label values Telephone YesNoRe 
drop tel

*********Radio
rename Radio red
gen Radio=.
replace Radio=1 if red=="yes"
replace Radio=0 if red=="no"
replace Radio=8 if red=="refused"
order Radio,after(Telephone)
label values Radio YesNoRe 
drop red
***********Television
rename Television tv
gen Television=.
replace Television=1 if tv=="yes"
replace Television=0 if tv=="no"
replace Television=8 if tv=="refused"
order Television,after(Radio)
label values Television YesNoRe 
drop tv
*********Bicycle
rename Bicycle bk
gen Bicycle=.
replace Bicycle=1 if bk=="yes"
replace Bicycle=0 if bk=="no"
replace Bicycle=8 if bk=="refused"
order Bicycle,after(Television)
label values Bicycle YesNoRe 
drop bk
**********Motorvehicle
rename MotorizedVehicle mv
gen MotorizedVehicle=.
replace MotorizedVehicle=1 if mv=="yes"
replace MotorizedVehicle=0 if mv=="no"
replace MotorizedVehicle=8 if mv=="refused"
order MotorizedVehicle,after(Bicycle)
label values MotorizedVehicle YesNoRe 
drop mv
*****Domestic worker
rename DomesticWorker dw
gen DomesticWorker=.
replace DomesticWorker=1 if dw=="yes"
replace DomesticWorker=0 if dw=="no"
replace DomesticWorker=8 if dw=="refused"
order DomesticWorker,after(MotorizedVehicle)
label values DomesticWorker YesNoRe 
drop dw
******child contact
rename ChildContact chc
gen ChildContact=.
replace ChildContact=1 if chc=="yes"
replace ChildContact=0 if chc=="no"
replace ChildContact=8 if chc=="refused"
order ChildContact,after(DomesticWorker)
label values ChildContact YesNoRe 
drop chc
******Outdoor activity
rename OutdoorActivity OA
gen OutdoorActivity=.
replace OutdoorActivity=1 if OA=="yes"
replace OutdoorActivity=0 if OA=="no"
replace OutdoorActivity=8 if OA=="refused"
order OutdoorActivity,after(ChildContact)
label values OutdoorActivity YesNoRe 
drop OA
******Mosquito bites
rename MosquitoBites Mb
gen MosquitoBites=.
replace MosquitoBites=1 if Mb=="yes"
replace MosquitoBites=0 if Mb=="no"
replace MosquitoBites=8 if Mb=="refused"
order MosquitoBites,after(OutdoorActivity)
label values MosquitoBites YesNoRe 
drop Mb
******Mosquito coil
rename MosquitoCoil Mc
gen MosquitoCoil=.
replace MosquitoCoil=1 if Mc=="yes"
replace MosquitoCoil=0 if Mc=="no"
replace MosquitoCoil=8 if Mc=="refused"
order MosquitoCoil,after(MosquitoBites)
label values MosquitoCoil YesNoRe 
drop Mc
*******sleep bednet
rename SleepBednet sb
gen SleepBednet=.
replace SleepBednet=1 if sb=="always"
replace SleepBednet=2 if sb=="sometimes"
replace SleepBednet=3 if sb=="rarely"
replace SleepBednet=4 if sb=="never"
replace SleepBednet=5 if sb=="n/a"
order SleepBednet,after(MosquitoCoil)
label define slpbt 1 "always" 2 "sometimes" 3 "rarely" 4 "never" 5 "n/a"
label values SleepBednet slpbt
drop sb
*******child travel
rename ChildTravel CT
gen ChildTravel=.
replace ChildTravel=1 if CT=="yes"
replace ChildTravel=0 if CT=="no"
replace ChildTravel=8 if CT=="refused"
order ChildTravel,after(SleepBednet)
label values ChildTravel YesNoRe 
drop CT
******night away
rename NightAway na
gen NightAway=.
replace NightAway=1 if na=="yes"
replace NightAway=0 if na=="no"
replace NightAway=8 if na=="refused"
order NightAway,after(WhereTravel)
label values NightAway YesNoRe 
drop na
******ever hospitalised
rename EverHospitalised eh
gen EverHospitalised=.
replace EverHospitalised=1 if eh=="yes"
replace EverHospitalised=0 if eh=="no"
replace EverHospitalised=8 if eh=="refused"
order EverHospitalised,after(WhereTravel)
label values EverHospitalised YesNoRe 
drop eh
****ever surgery
rename EverSurgery ES
gen EverSurgery=.
replace EverSurgery=1 if ES=="yes"
replace EverSurgery=0 if ES=="no"
replace EverSurgery=8 if ES=="refused"
order EverSurgery,after(SetOfPastMedHistory)
label values EverSurgery YesNoRe 
drop ES
*******
order ReasonSurgery,after (EverSurgery)
order DateSurgery,after (ReasonSurgery)
****gestetional
rename Gestational GS
gen Gestational=.
replace Gestational=1 if GS=="full_term"
replace Gestational=2 if GS=="preterm"
replace Gestational=7 if GS=="do_not_know"
label define gestation 1 "full_term" 2 "preterm" 7 "do_not_know"
label values Gestational gestation
order Gestational,after(DateSurgery)
drop GS
******breastfed
rename BreastFed BF
gen BreastFed=.
replace BreastFed=1 if BF=="yes"
replace BreastFed=0 if BF=="no"
replace BreastFed=8 if BF=="refused"
order BreastFed,after(Gestational)
label values BreastFed YesNoRe 
order BreastFed,after(Gestational)
drop BF
*****duration brest fed
rename DurationBFed DB
gen DurationBFed=.
replace DurationBFed=1 if  DB=="1mo"
replace DurationBFed=2 if  DB=="2mo"
replace DurationBFed=3 if  DB=="3mo"
replace DurationBFed=4 if  DB=="4mo"
replace DurationBFed=5 if  DB=="5mo"
replace DurationBFed=6 if  DB=="6mo"
replace DurationBFed=7 if  DB=="7mo"
replace DurationBFed=8 if  DB=="8mo"
replace DurationBFed=9 if  DB=="9mo"
replace DurationBFed=10 if  DB=="10mo"
replace DurationBFed=11 if  DB=="11mo"
replace DurationBFed=12 if  DB=="12mo"
replace DurationBFed=13 if  DB=="12mo_to_18mo"
replace DurationBFed=14 if  DB=="18mo"
replace DurationBFed=15 if  DB=="other"
replace DurationBFed=77 if  DB=="do_not_know"
order DurationBFed,after (BreastFed)
label define durBrFed 1 "1mo" 2 "2mo" 3 "3mo" 4 "4mo" 5 "5mo" 6 "6mo" 7 "7mo" 8 "8mo" 9 "9mo" 10 "10mo" 11 "11mo" 12 "12mo" 13 "12mo_to_18mo" 14 "18mo" 15 "other" 77 "do_not_know"
label values DurationBFed durbrFed
order DurationBFed,after(BreastFed)
drop DB
*****yellowfever
rename YellowFever yf
gen YellowFever=.
replace YellowFever=1 if yf=="yes"
replace YellowFever=0 if yf=="no"
replace YellowFever=8 if yf=="refused"
order YellowFever,after(ChildVaccination)
label values YellowFever YesNoRe 
drop yf
******** Encephalitis 
rename Encephalitis ence
gen Encephalitis=.
replace Encephalitis=1 if ence=="yes"
replace Encephalitis=0 if ence=="no"
replace Encephalitis=8 if ence=="refused"
order Encephalitis,after(ChildVaccination)
label values Encephalitis YesNoRe 
drop ence
******Currently taking medics
rename CurrentTakingMeds medic
gen CurrentTakingMeds=.
replace CurrentTakingMeds=1 if medic=="yes"
replace CurrentTakingMeds=0 if medic=="no"
replace CurrentTakingMeds=8 if medic=="refused"
order CurrentTakingMeds,after(OthPastMedHist)
label values CurrentTakingMeds YesNoRe 
drop medic
******Ever been pregnant
rename EverPregnant preg
gen EverPregnant=.
replace EverPregnant=1 if preg=="yes"
replace EverPregnant=0 if preg=="no"
replace EverPregnant=8 if preg=="refused"
order EverPregnant,after(OthPastMedHist)
label values EverPregnant YesNoRe 
drop preg
*****perform visual acuity
rename PerformVisualAcuity VA
gen PerformVisualAcuity=.
replace PerformVisualAcuity=1 if VA=="yes" 
replace PerformVisualAcuity=2 if VA=="no_sick" 
replace PerformVisualAcuity=3 if VA=="no_young" 
replace PerformVisualAcuity=4 if VA=="no_other"
order PerformVisualAcuity,after(PulseOximetry)
label define VisualAc 1 "yes" 2 "no_sick" 3 "no_young" 4 "no_other"
label values PerformVisualAcuity VisualAc
drop VA
*******Tourniquest
rename TourniquetTest TQ
gen TourniquetTest=.
replace TourniquetTest=1 if TQ=="positive"
replace TourniquetTest=2 if TQ=="10"
replace TourniquetTest=3 if TQ=="normal"
replace TourniquetTest=4 if TQ=="not_done"
order TourniquetTest,after(ClinicianNotesNeuro)
label define TGT 1 "positive" 2 "10" 3 "normal" 4 "not_done"
label values TourniquetTest TGT
drop TQ
*******Malaria results
rename BSResults Bs
gen BSResults=.
replace BSResults=0 if Bs=="Negative"
replace BSResults=2 if Bs=="2"
replace BSResults=3 if Bs=="3"
replace BSResults=4 if Bs=="4"
order BSResults,after(OthMalTestOrdered)
drop Bs
******Primary diagnosis
rename PrimaryDiag PD
gen PrimaryDiag=.
replace PrimaryDiag=0 if PD=="primary_diagnosis"
replace PrimaryDiag=1 if PD=="malaria"
replace PrimaryDiag=2 if PD=="CHIK"
replace PrimaryDiag=3 if PD=="DEN"
replace PrimaryDiag=4 if PD=="influenza"
replace PrimaryDiag=5 if PD=="common_cold"
replace PrimaryDiag=6 if PD=="measles"
replace PrimaryDiag=7 if PD=="bacterial"
replace PrimaryDiag=8 if PD=="other"
order PrimaryDiag,after(OthLabResults)
drop PD 

*****secondary diagnosis
rename SecondaryDiag PD
gen SecondaryDiag=.
replace SecondaryDiag=0 if PD=="primary_diagnosis"
replace SecondaryDiag=1 if PD=="malaria"
replace SecondaryDiag=2 if PD=="CHIK"
replace SecondaryDiag=3 if PD=="DEN"
replace SecondaryDiag=4 if PD=="influenza"
replace SecondaryDiag=5 if PD=="common_cold"
replace SecondaryDiag=6 if PD=="measles"
replace SecondaryDiag=7 if PD=="bacterial"
replace SecondaryDiag=8 if PD=="other"
order SecondaryDiag,after(PrimaryBacterialDX)
drop PD 
****Outcome
rename Outcome Outcme
gen Outcome=.
replace Outcome=1 if Outcme=="sent_home_no_followup"
replace Outcome=2 if Outcme=="sent_home_followup"
replace Outcome=3 if Outcme=="referred_district"
replace Outcome=4 if Outcme=="referred_provincial"
replace Outcome=5 if Outcme=="death"
replace Outcome=6 if Outcme=="other"
order Outcome,after(OthMedsPrescribe)
label define outcme 1 "sent_home_no_followup" 2 "sent_home_followup" 3 "referred_district" 4 "referred_provincial" 5 "death" 6 "other"
label values Outcome outcme
drop Outcme
********location hospital
rename LocationHospital LH
gen LocationHospital=.
replace LocationHospital=1 if LH=="obama"
replace LocationHospital=2 if LH=="chulaimbo"
replace LocationHospital=3 if LH=="msambweni"
replace LocationHospital=4 if LH=="ukunda"
replace LocationHospital=5 if LH=="other"
replace LocationHospital=9 if LH=="n/a"
order LocationHospital,after(OutcomeHospitalized)
drop LH
*****duration Hospitalized1
rename DurationHospitalized1 DH
gen DurationHospitalized1=.
replace DurationHospitalized1=1 if DH=="0_3_days"
replace DurationHospitalized1=2 if DH=="4_7_days"
replace DurationHospitalized1=3 if DH=="2_weeks"
replace DurationHospitalized1=4 if DH=="3_weeks"
replace DurationHospitalized1=5 if DH=="4_weeks"
replace DurationHospitalized1=6 if DH=="5_weeks"
replace DurationHospitalized1=7 if DH=="6_weeks"
replace DurationHospitalized1=8 if DH=="more_6_weeks"
replace DurationHospitalized1=77 if DH=="do_not_know"
order DurationHospitalized1,after(HospitalName)
drop DH

*******outcome hospitalized
rename OutcomeHospitalized OH
gen OutcomeHospitalized=.
replace OutcomeHospitalized=1 if OH=="yes"
replace OutcomeHospitalized=0 if OH=="no"
replace OutcomeHospitalized=8 if OH=="refused"
order OutcomeHospitalized,after(OthOutcome)
label values OutcomeHospitalized YesNoRe
drop OH

*******droping varibales
drop  Child_key

save AIC_Initial_Dataset_Oct2016_coded,replace




******/////////////////////////////////////////////////////////////////////////
****Spliting and coding String variables

***Spliting current symptoms
split CurrentSymptoms,generate (Symptom_)

******recoding the symptoms
gen Fever=.
replace Fever=1 if Symptom_1=="fever" | Symptom_2=="fever" | ///
Symptom_3=="fever" | Symptom_4=="fever" | ///
Symptom_5=="fever" | Symptom_6=="fever" | ///
Symptom_7=="fever" | Symptom_8=="fever" | ///
Symptom_9=="fever"  
replace Fever=0 if Fever==.
order Fever,after (CurrentSymptoms)


gen Chills=""
replace Chills="1" if Symptom_1=="chiils" | Symptom_2=="chiils" | ///
Symptom_3=="chiils" | Symptom_4=="chiils" | ///
Symptom_5=="chiils" | Symptom_6=="chiils" | ///
Symptom_7=="chiils" | Symptom_8=="chiils" | ///
Symptom_9=="chiils" 
replace Chills="0" if Chills==""
order Chills,after(Fever)

gen SickFeeling=.
replace SickFeeling=1 if Symptom_1=="sick_feeling" | Symptom_2=="sick_feeling" | ///
Symptom_3=="sick_feeling" | Symptom_4=="sick_feeling" | ///
Symptom_5=="sick_feeling" | Symptom_6=="sick_feeling" | ///
Symptom_7=="sick_feeling" | Symptom_8=="sick_feeling" | ///
Symptom_9=="sick_feeling" 
replace SickFeeling=0 if SickFeeling==.
order SickFeeling,after(Chills)

gen GeneralBodyAche=.
replace GeneralBodyAche=1 if Symptom_1=="general_body_ache" | Symptom_2=="general_body_ache" | ///
Symptom_3=="general_body_ache" | Symptom_4=="general_body_ache" | ///
Symptom_5=="general_body_ache" | Symptom_6=="general_body_ache" | ///
Symptom_7=="general_body_ache" | Symptom_8=="general_body_ache" | ///
Symptom_9=="general_body_ache" 
replace GeneralBodyAche=0 if GeneralBodyAche==.
order GeneralBodyAche,after(SickFeeling)


gen JointPain=.
replace JointPain=1 if Symptom_1=="joint_pain" | Symptom_2=="joint_pain" | ///
Symptom_3=="joint_pain" | Symptom_4=="joint_pain" | ///
Symptom_5=="joint_pain" | Symptom_6=="joint_pain" | ///
Symptom_7=="joint_pain" | Symptom_8=="joint_pain" | ///
Symptom_9=="joint_pain" 
replace JointPain=0 if JointPain==.
order JointPain,after(GeneralBodyAche)

gen Headache=.
replace Headache=1 if Symptom_1=="headache" | Symptom_2=="headache" | ///
Symptom_3=="headache" | Symptom_4=="headache" | ///
Symptom_5=="headache" | Symptom_6=="headache" | ///
Symptom_7=="headache" | Symptom_8=="headache" | ///
Symptom_9=="headache" 
replace Headache=0 if Headache==.
order Headache,after(JointPain)

gen RunnyNose=.
replace RunnyNose=1 if Symptom_1=="runny_nose" | Symptom_2=="runny_nose" | ///
Symptom_3=="runny_nose" | Symptom_4=="runny_nose" | ///
Symptom_5=="runny_nose" | Symptom_6=="runny_nose" | ///
Symptom_7=="runny_nose" | Symptom_8=="runny_nose" | ///
Symptom_9=="runny_nose" 
replace RunnyNose=0 if RunnyNose==.
order RunnyNose,after(Headache)


gen Cough=""
replace Cough="1" if Symptom_1=="cough" | Symptom_2=="cough" | ///
Symptom_3=="cough" | Symptom_4=="cough" | ///
Symptom_5=="cough" | Symptom_6=="cough" | ///
Symptom_7=="cough" | Symptom_8=="cough" | ///
Symptom_9=="cough" 
replace Cough="0" if Cough==""
order Cough,after(RunnyNose)

gen LossOfAppetite=.
replace LossOfAppetite=1 if Symptom_1=="loss_of_appetite" | Symptom_2=="loss_of_appetite" | ///
Symptom_3=="loss_of_appetite" | Symptom_4=="loss_of_appetite" | ///
Symptom_5=="loss_of_appetite" | Symptom_6=="loss_of_appetite" | ///
Symptom_7=="loss_of_appetite" | Symptom_8=="loss_of_appetite" | ///
Symptom_9=="loss_of_appetite" 
replace LossOfAppetite=0 if LossOfAppetite==.
order LossOfAppetite,after(Cough)

gen Vomiting=.
replace Vomiting=1 if Symptom_1=="vomiting" | Symptom_2=="vomiting" | ///
Symptom_3=="vomiting" | Symptom_4=="vomiting" | ///
Symptom_5=="vomiting" | Symptom_6=="vomiting" | ///
Symptom_7=="vomiting" | Symptom_8=="vomiting" | ///
Symptom_9=="vomiting" 
replace Vomiting=0 if Vomiting==.
order Vomiting,after(LossOfAppetite)

gen AbdominalPain=""
replace AbdominalPain="1" if Symptom_1=="abdominal_pain" | Symptom_2=="abdominal_pain" | ///
Symptom_3=="abdominal_pain" | Symptom_4=="abdominal_pain" | ///
Symptom_5=="abdominal_pain" | Symptom_6=="abdominal_pain" | ///
Symptom_7=="abdominal_pain" | Symptom_8=="abdominal_pain" | ///
Symptom_9=="abdominal_pain" 
replace AbdominalPain="0" if AbdominalPain==""
order AbdominalPain,after(Vomiting)


gen ShortnessOfBreath=.
replace ShortnessOfBreath=1 if Symptom_1=="shortness_of_breath" | Symptom_2=="shortness_of_breath" | ///
Symptom_3=="shortness_of_breath" | Symptom_4=="shortness_of_breath" | ///
Symptom_5=="shortness_of_breath" | Symptom_6=="shortness_of_breath" | ///
Symptom_7=="shortness_of_breath" | Symptom_8=="shortness_of_breath" | ///
Symptom_9=="shortness_of_breath" 
replace ShortnessOfBreath=0 if ShortnessOfBreath==.
order ShortnessOfBreath,after(SickFeeling)

gen Itchiness=.
replace Itchiness=1 if Symptom_1=="itchiness" | Symptom_2=="itchiness" | ///
Symptom_3=="itchiness" | Symptom_4=="itchiness" | ///
Symptom_5=="itchiness" | Symptom_6=="itchiness" | ///
Symptom_7=="itchiness" | Symptom_8=="itchiness" | ///
Symptom_9=="itchiness" 
replace Itchiness=0 if Itchiness==.
order Itchiness,after(GeneralBodyAche)

gen RedEyes=.
replace RedEyes=1 if Symptom_1=="red_eyes" | Symptom_2=="red_eyes" | ///
Symptom_3=="red_eyes" | Symptom_4=="red_eyes" | ///
Symptom_5=="red_eyes" | Symptom_6=="red_eyes" | ///
Symptom_7=="red_eyes" | Symptom_8=="red_eyes" | ///
Symptom_9=="red_eyes" 
replace RedEyes=0 if RedEyes==.
order RedEyes,after(Itchiness)

gen MusclePains=.
replace MusclePains=1 if Symptom_1=="muscle_pains" | Symptom_2=="muscle_pains" | ///
Symptom_3=="muscle_pains" | Symptom_4=="muscle_pains" | ///
Symptom_5=="muscle_pains" | Symptom_6=="muscle_pains" | ///
Symptom_7=="muscle_pains" | Symptom_8=="muscle_pains" | ///
Symptom_9=="muscle_pains" 
replace MusclePains=0 if MusclePains==.
order MusclePains,after(JointPain)

gen BonePains=.
replace BonePains=1 if Symptom_1=="bone_pains" | Symptom_2=="bone_pains" | ///
Symptom_3=="bone_pains" | Symptom_4=="bone_pains" | ///
Symptom_5=="bone_pains" | Symptom_6=="bone_pains" | ///
Symptom_7=="bone_pains" | Symptom_8=="bone_pains" | ///
Symptom_9=="bone_pains" 
replace BonePains=0 if BonePains==.
order BonePains,after(MusclePains)

gen PainBehindEyes=.
replace PainBehindEyes=1 if Symptom_1=="pain_behind_eyes" | Symptom_2=="pain_behind_eyes" | ///
Symptom_3=="pain_behind_eyes" | Symptom_4=="pain_behind_eyes" | ///
Symptom_5=="pain_behind_eyes" | Symptom_6=="pain_behind_eyes" | ///
Symptom_7=="pain_behind_eyes" | Symptom_8=="pain_behind_eyes" | ///
Symptom_9=="pain_behind_eyes" 
replace PainBehindEyes=0 if PainBehindEyes==.
order PainBehindEyes,after(Headache)

gen SoreThroat=.
replace SoreThroat=1 if Symptom_1=="sore_throat" | Symptom_2=="sore_throat" | ///
Symptom_3=="sore_throat" | Symptom_4=="sore_throat" | ///
Symptom_5=="sore_throat" | Symptom_6=="sore_throat" | ///
Symptom_7=="sore_throat" | Symptom_8=="sore_throat" | ///
Symptom_9=="sore_throat" 
replace SoreThroat=0 if SoreThroat==.
order SoreThroat,after(RunnyNose)

gen EarAche=.
replace EarAche=1 if Symptom_1=="earache" | Symptom_2=="earache" | ///
Symptom_3=="earache" | Symptom_4=="earache" | ///
Symptom_5=="earache" | Symptom_6=="earache" | ///
Symptom_7=="earache" | Symptom_8=="earache" | ///
Symptom_9=="earache" 
replace EarAche=0 if EarAche==.
order EarAche,after(Cough)

gen FunnyTaste=.
replace FunnyTaste=1 if Symptom_1=="funny_taste" | Symptom_2=="funny_taste" | ///
Symptom_3=="funny_taste" | Symptom_4=="funny_taste" | ///
Symptom_5=="funny_taste" | Symptom_6=="funny_taste" | ///
Symptom_7=="funny_taste" | Symptom_8=="funny_taste" | ///
Symptom_9=="funny_taste" 
replace FunnyTaste=0 if FunnyTaste==.
order FunnyTaste,after(LossOfAppetite)

gen Nausea=.
replace Nausea=1 if Symptom_1=="nausea" | Symptom_2=="nausea" | ///
Symptom_3=="nausea" | Symptom_4=="nausea" | ///
Symptom_5=="nausea" | Symptom_6=="nausea" | ///
Symptom_7=="nausea" | Symptom_8=="nausea" | ///
Symptom_9=="nausea" 
replace Nausea=0 if Nausea==.
order Nausea,after(FunnyTaste)

gen Diarrhea=.
replace Diarrhea=1 if Symptom_1=="diarrhea" | Symptom_2=="diarrhea" | ///
Symptom_3=="diarrhea" | Symptom_4=="diarrhea" | ///
Symptom_5=="diarrhea" | Symptom_6=="diarrhea" | ///
Symptom_7=="diarrhea" | Symptom_8=="diarrhea" | ///
Symptom_9=="diarrhea" 
replace Diarrhea=0 if Diarrhea==.
order Diarrhea,after(Vomiting)

gen Dizziness=.
replace Dizziness=1 if Symptom_1=="dizziness" | Symptom_2=="dizziness" | ///
Symptom_3=="dizziness" | Symptom_4=="dizziness" | ///
Symptom_5=="dizziness" | Symptom_6=="dizziness" | ///
Symptom_7=="dizziness" | Symptom_8=="dizziness" | ///
Symptom_9=="dizziness" 
replace Dizziness=0 if Dizziness==.
order Dizziness,after(Diarrhea)

gen BloodyStool=.
replace BloodyStool=1 if Symptom_1=="bloody_stool" | Symptom_2=="bloody_stool" | ///
Symptom_3=="bloody_stool" | Symptom_4=="bloody_stool" | ///
Symptom_5=="bloody_stool" | Symptom_6=="bloody_stool" | ///
Symptom_7=="bloody_stool" | Symptom_8=="bloody_stool" | ///
Symptom_9=="bloody_stool" 
replace BloodyStool=0 if BloodyStool==.
order BloodyStool,after(AbdominalPain)

gen Bruises=.
replace Bruises=1 if Symptom_1=="bruises" | Symptom_2=="bruises" | ///
Symptom_3=="bruises" | Symptom_4=="bruises" | ///
Symptom_5=="bruises" | Symptom_6=="bruises" | ///
Symptom_7=="bruises" | Symptom_8=="bruises" | ///
Symptom_9=="bruises" 
replace Bruises=0 if Bruises==.
order Bruises,after(BloodyStool)

gen Fits=.
replace Fits=1 if Symptom_1=="fits" | Symptom_2=="fits" | ///
Symptom_3=="fits" | Symptom_4=="fits" | ///
Symptom_5=="fits" | Symptom_6=="fits" | ///
Symptom_7=="fits" | Symptom_8=="fits" | ///
Symptom_9=="fits" 
replace Fits=0 if Fits==.
order Fits,after(Bruises)

gen BloodyUrine=.
replace BloodyUrine=1 if Symptom_1=="bloody_urine" | Symptom_2=="bloody_urine" | ///
Symptom_3=="bloody_urine" | Symptom_4=="bloody_urine" | ///
Symptom_5=="bloody_urine" | Symptom_6=="bloody_urine" | ///
Symptom_7=="bloody_urine" | Symptom_8=="bloody_urine" | ///
Symptom_9=="bloody_urine" 
replace BloodyUrine=0 if BloodyUrine==.
order BloodyUrine,after(Fits)

gen ImpairedMentalStatus=.
replace ImpairedMentalStatus=1 if Symptom_1=="impaired_mental_status" | Symptom_2=="impaired_mental_status" | ///
Symptom_3=="impaired_mental_status" | Symptom_4=="impaired_mental_status" | ///
Symptom_5=="impaired_mental_status" | Symptom_6=="impaired_mental_status" | ///
Symptom_7=="impaired_mental_status" | Symptom_8=="impaired_mental_status" | ///
Symptom_9=="impaired_mental_status" 
replace ImpairedMentalStatus=0 if ImpairedMentalStatus==.
order ImpairedMentalStatus,after(BloodyUrine)

gen BleedingGums=.
replace BleedingGums=1 if Symptom_1=="bleeding_gums" | Symptom_2=="bleeding_gums" | ///
Symptom_3=="bleeding_gums" | Symptom_4=="bleeding_gums" | ///
Symptom_5=="bleeding_gums" | Symptom_6=="bleeding_gums" | ///
Symptom_7=="bleeding_gums" | Symptom_8=="bleeding_gums" | ///
Symptom_9=="bleeding_gums" 
replace BleedingGums=0 if BleedingGums==.
order BleedingGums,after(ImpairedMentalStatus)

gen EyesSensitiveToLight=.
replace EyesSensitiveToLight=1 if Symptom_1=="eyes_sensitive_to_light" | Symptom_2=="eyes_sensitive_to_light" | ///
Symptom_3=="eyes_sensitive_to_light" | Symptom_4=="eyes_sensitive_to_light" | ///
Symptom_5=="eyes_sensitive_to_light" | Symptom_6=="eyes_sensitive_to_light" | ///
Symptom_7=="eyes_sensitive_to_light" | Symptom_8=="eyes_sensitive_to_light" | ///
Symptom_9=="eyes_sensitive_to_light" 
replace EyesSensitiveToLight=0 if EyesSensitiveToLight==.
order EyesSensitiveToLight,after(BleedingGums)

gen BloodyNose=.
replace BloodyNose=1 if Symptom_1=="bloody_nose" | Symptom_2=="bloody_nose" | ///
Symptom_3=="bloody_nose" | Symptom_4=="bloody_nose" | ///
Symptom_5=="bloody_nose" | Symptom_6=="bloody_nose" | ///
Symptom_7=="bloody_nose" | Symptom_8=="bloody_nose" | ///
Symptom_9=="bloody_nose"
replace BloodyNose=0 if BloodyNose==.
order BloodyNose,after(EyesSensitiveToLight)


gen BloodyVomit=.
replace BloodyVomit=1 if Symptom_1=="bloody_vomit" | Symptom_2=="bloody_vomit" | ///
Symptom_3=="bloody_vomit" | Symptom_4=="bloody_vomit" | ///
Symptom_5=="bloody_vomit" | Symptom_6=="bloody_vomit" | ///
Symptom_7=="bloody_vomit" | Symptom_8=="bloody_vomit" | ///
Symptom_9=="bloody_vomit" 
replace BloodyVomit=0 if BloodyVomit==.
order BloodyVomit,after(BloodyNose)


gen StiffNeck=.
replace StiffNeck=1 if Symptom_1=="stiff_neck" | Symptom_2=="stiff_neck" | ///
Symptom_3=="stiff_neck" | Symptom_4=="stiff_neck" | ///
Symptom_5=="stiff_neck" | Symptom_6=="stiff_neck" | ///
Symptom_7=="stiff_neck" | Symptom_8=="stiff_neck" | ///
Symptom_9=="stiff_neck" 
replace StiffNeck=0 if StiffNeck==.
order StiffNeck,after(BloodyNose)

gen Rash=.
replace Rash=1 if Symptom_1=="rash" | Symptom_2=="rash" | ///
Symptom_3=="rash" | Symptom_4=="rash" | ///
Symptom_5=="rash" | Symptom_6=="rash" | ///
Symptom_7=="rash" | Symptom_8=="rash" | ///
Symptom_9=="rash" 
replace Rash=0 if Rash==.
order Rash,after(StiffNeck)

*******/////////////////////////////////////////////////////////////


******droping splits
drop Symptom_1 Symptom_2 Symptom_3 Symptom_4 Symptom_5 ///
Symptom_6 Symptom_7 Symptom_8 Symptom_9 

******changing names to uppercase
replace InterviewerName=upper(InterviewerName)
replace OthInterviewerName=upper(OthInterviewerName)
replace ChildVillage=upper(ChildVillage)

********droping unmatched variables 
drop ChidSurname ChildFirstName ChildSecondName ChildThirdName /// 
ChildFourthName MotherSurname MotherFirstName MotherSecondName /// 
MotherThirdName MotherFourthName FatherSurname FatherFirstName FatherSecondName FatherThirdName FatherFourthName SETOFpast_hospitalization

**---------------------------------------------------------------------------------------------------------------------------------------------------------------
*********windows
gen WindowsCoded=""
order WindowsCoded,after(Windows)
replace WindowsCoded="1" if Windows=="windows_without_screens"
replace WindowsCoded="2" if Windows=="windows_with_screens"
replace WindowsCoded="3" if Windows=="no_windows"

*******Past medical History malaria
split PastMedHist, gen (mal_)
gen MalariaPastMedHist=""
order MalariaPastMedHist,after(OthPastMedHist)
replace MalariaPastMedHist="1" if mal_1=="malaria" | mal_2=="malaria" ///
| mal_3=="malaria" 
replace MalariaPastMedHist="0" if MalariaPastMedHist==""

**********Past medical history pneumonia
gen PneumoniaPastMedHist=.
order PneumoniaPastMedHist,after(MalariaPastMedHist)
replace PneumoniaPastMedHist=1 if mal_1=="pneumonia" | mal_2=="pneumonia" ///
| mal_3=="pneumonia" 
replace PneumoniaPastMedHist=0 if PneumoniaPastMedHist==.

drop mal_1 mal_2 mal_3 


*******current Medication
split CurrentMeds,gen (med_)
gen ParacetamolCurrentMeds=""
order ParacetamolCurrentMeds,after(OthCurrentMeds)
replace ParacetamolCurrentMeds="1" if med_1=="paracetamol" | ///
med_2=="paracetamol"
replace ParacetamolCurrentMeds="0" if ParacetamolCurrentMeds==""
drop  med_1 med_2

*******Head neck Exam
split HeadNeckExam,gen (hn_)
gen ScleralIcterus=""
order ScleralIcterus,after (HeadNeckExam)
replace ScleralIcterus="1" if hn_1=="icteric_sclerae" | hn_2=="icteric_sclerae"  
replace ScleralIcterus="0" if ScleralIcterus==""

gen RedEye=.
order RedEye,after (ScleralIcterus)
replace RedEye=1 if hn_1=="red_eyes" | hn_2=="red_eyes" 
replace RedEye=0 if RedEye==.

gen Adenopathy=.
order Adenopathy,after (RedEye)
replace Adenopathy=1 if hn_1=="large_lymph_nodes" | hn_2=="large_lymph_nodes"  
replace Adenopathy=0 if Adenopathy==.


gen OtherHNeck=""
order OtherHNeck,after (Adenopathy)

drop hn_1 hn_2 

********/////HeartExam
gen HeartExamCoded=.
order HeartExamCoded,after(HeartExam)
replace HeartExamCoded=1 if HeartExam=="normal"
replace HeartExamCoded=2 if HeartExam=="rapid_rate"
replace HeartExamCoded=3 if HeartExam=="gallop"

**********////abdomen exam
gen Splenomegaly=.
order Splenomegaly,after(AbdomenExam)
replace Splenomegaly=1 if AbdomenExam=="splenomegaly"
replace Splenomegaly=0 if Splenomegaly==.

gen AbdTenderness=.
order AbdTenderness,after(Splenomegaly)
replace AbdTenderness=1 if AbdomenExam=="tenderness_to_palpation"
replace AbdTenderness=0 if AbdTenderness==.

gen Hepatomegaly=.
order Hepatomegaly,after(AbdTenderness)
replace Hepatomegaly=1 if AbdomenExam=="hepatomegaly"
replace Hepatomegaly=0 if Hepatomegaly==.

*******Node Exam
gen NodeNormal=.
order NodeNormal,after (NodeExam)
replace NodeNormal=1 if NodeExam=="normal"
replace NodeNormal=0 if NodeNormal==.

gen NodeAbnormal=""
order NodeAbnormal,after(NodeNormal)
replace NodeAbnormal="1" if NodeNormal==0
replace NodeAbnormal="0" if NodeAbnormal==""

gen OthNode=""
order OthNode,after (NodeAbnormal)

********JointExam
gen JointNormal=.
order JointNormal,after(JointExam)
replace JointNormal=1 if JointExam=="normal"
replace JointNormal=0 if JointNormal==.

gen JointAbnormal=""
order JointAbnormal,after(JointNormal)
replace JointAbnormal="1" if JointNormal==0
replace JointAbnormal="0" if JointNormal==1


**********skin exam
gen SkinExamCoded=""
order SkinExamCoded,after(SkinExam)
replace SkinExamCoded="1" if SkinExam=="normal"
replace SkinExamCoded="2" if SkinExam=="maculopapular" | ///
SkinExam=="papular" | SkinExam=="macular"
replace SkinExamCoded="3" if SkinExam=="bruises" | ///
SkinExam=="petechiae"
replace SkinExamCoded="4" if SkinExam=="jaundice"
replace SkinExamCoded="5" if SkinExam=="localized_rash" ///
| SkinExam=="generalized_rash" | SkinExam=="other"

replace SkinExamCoded="5 2" if SkinExam=="generalized_rash papular"
replace SkinExamCoded="5 2" if SkinExam=="localized_rash papular"


********Neuro Exam
gen NeuroExamCoded=""
order NeuroExamCoded,after(NeuroExam)
replace NeuroExamCoded="1" if NeuroExam=="normal"
replace NeuroExamCoded="2" if NeuroExam=="lethargic" 
replace NeuroExamCoded="6" if NeuroExam=="alert_time"
/*replace NeuroExamCoded="1 6 2" if NeuroExam=="normal alert_time lethargic"
replace NeuroExamCoded="1 3" if NeuroExam=="normal decreased_strength"*/

gen NeuroNormal=.
order NeuroNormal, after(NeuroExamCoded)
replace NeuroNormal=1 if NeuroExam=="normal"
replace NeuroNormal=0 if NeuroNormal==.

gen NeuroAbnormal=""
order NeuroAbnormal,after (NeuroNormal)
replace NeuroAbnormal=NeuroExam if NeuroExam!="normal"

******Lab Tests
split LabTests,gen (lb_)
gen MalariaBloodSmear=""
order MalariaBloodSmear,after (LabTests)
replace MalariaBloodSmear="1" if lb_1=="malaria_blood_smear" | ///
lb_2=="malaria_blood_smear"  
replace MalariaBloodSmear="0" if MalariaBloodSmear==""

gen OvaParasites=.
order OvaParasites,after (MalariaBloodSmear)
replace OvaParasites=1 if lb_1=="ova_cysts" | ///
lb_2=="ova_cysts" 
replace OvaParasites=0 if OvaParasites==.

gen Hemoglobin_lb=.
order Hemoglobin_lb,after (OvaParasites)
replace Hemoglobin_lb=1 if lb_1=="Hb" | ///
lb_2=="Hb" 
replace Hemoglobin_lb=0 if Hemoglobin_lb==.

drop lb_1 lb_2 

*******Medicine Prescribe
split MedsPrescribe,gen (med_)

gen Antibiotic=.
order Antibiotic,after (MedsPrescribe)
replace Antibiotic=1 if med_1=="Amoxicillin" | med_2=="Amoxicillin" | med_3=="Amoxicillin" ///
| med_4=="Amoxicillin" 
replace Antibiotic=0 if Antibiotic==.

gen Antimalarial=""
order Antimalarial,after (Antibiotic)
replace Antimalarial="1" if med_1=="Coartem" | med_2=="Coartem" | med_3=="Coartem" ///
| med_4=="Coartem" 
replace  Antimalarial="0" if Antimalarial==""


gen Antiparasitic=.
order Antiparasitic,after (Antimalarial)
replace Antiparasitic=1 if med_1=="Albendazole" | med_2=="Albendazole" | med_3=="Albendazole" ///
| med_4=="Albendazole" 
replace  Antiparasitic=0 if Antiparasitic==.

gen Ibuprofen=""
order Ibuprofen,after (Antiparasitic)
replace Ibuprofen="1" if med_1=="ibuprofen" | med_2=="ibuprofen" | med_3=="ibuprofen" ///
| med_4=="ibuprofen" 
replace  Ibuprofen="0" if Ibuprofen==""

gen Paracetamol=""
order Paracetamol,after (Ibuprofen)
replace Paracetamol="1" if med_1=="paracetamol" | med_2=="paracetamol" | med_3=="paracetamol" ///
| med_4=="paracetamol" 
replace  Paracetamol="0" if Paracetamol==""

drop med_1 med_2 med_3 med_4 

********chest exam
gen ChestExamCoded=""
order ChestExamCoded,after (ChestExam)
replace ChestExamCoded="1" if ChestExam=="normal"
replace ChestExamCoded="2" if ChestExam=="rapid_breathing"
replace ChestExamCoded="3" if ChestExam=="rales"
replace ChestExamCoded="4" if ChestExam=="rhonchi"
replace ChestExamCoded="5" if ChestExam=="wheezes"
replace ChestExamCoded="6" if ChestExam=="flaring"



*****////////checking for errors and making changes (October 2016)***
replace InterviewDate=date("10nov2016","DMY") if StudyID=="KFA0833"
replace InterviewDate=date("10nov2016","DMY") if StudyID=="RFA0672"




save Final_AIC_Initial_Oct2016,replace

export excel using "C:\Users\Data Section\Desktop\AIC_Monthly_Cleaning\Clean\AIC_Initial_Oct2016.xls", sheetreplace firstrow(variables) nolabel


log close

