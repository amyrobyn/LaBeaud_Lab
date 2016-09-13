cd "C:\Users\Amy\Box Sync\DENV CHIKV project\Personalized Datasets\Amy\longitudinal_analysis_aug252016\output"
*coast
*aic
import excel "C:\Users\Amy\Box Sync\DENV CHIKV project\Coast Cleaned\AIC\AIC Latest\Coastal Data-Katherine aug_4_2016", sheet("Coast_AIC_Init-Katherine") firstrow clear
save "Coast_AIC_Init-Katherine", replace
import excel "C:\Users\Amy\Box Sync\DENV CHIKV project\Coast Cleaned\AIC\AIC Latest\Coastal Data-Katherine aug_4_2016", sheet("FILE1   4 coast_aicfu_18apr16") firstrow clear
save "FILE1   4 coast_aicfu_18apr16", replace
import excel "C:\Users\Amy\Box Sync\DENV CHIKV project\Coast Cleaned\AIC\AIC Latest\Coastal Data-Katherine aug_4_2016", sheet("FILE2  AIC Ukunda Malaria...  ") firstrow clear
save "FILE2  AIC Ukunda Malaria...", replace
*hcc
import excel "C:\Users\Amy\Box Sync\DENV CHIKV project\Coast Cleaned\HCC\HCC Follow-Up Data_20Jun15 - with Names not Merged", sheet("HCC Follow-up Msambweni") firstrow clear
save "HCC Follow-up Msambweni", replace
import excel "C:\Users\Amy\Box Sync\DENV CHIKV project\Coast Cleaned\HCC\HCC Follow-Up Data_20Jun15 - with Names not Merged", sheet("In Lab But No Data Msambweni") firstrow clear
save "In Lab But No Data Msambweni", replace
import excel "C:\Users\Amy\Box Sync\DENV CHIKV project\Coast Cleaned\HCC\HCC Initial Data_20Jun15 - without Names", sheet("In Data Missing Lab - Msambweni") firstrow clear
save "In Data Missing Lab - Msambweni", replace

*west
*aic
import excel "C:\Users\Amy\Box Sync\DENV CHIKV project\West Cleaned\AIC\AIC Latest\Western Data-Katherine aug_4_2016", sheet("Western_AIC_Init-Katherine") firstrow clear
save "Western_AIC_Init-Katherine", replace
import excel "C:\Users\Amy\Box Sync\DENV CHIKV project\West Cleaned\AIC\AIC Latest\Western Data-Katherine aug_4_2016", sheet("Western_AICFU-Katherine") firstrow clear
save "Western_AICFU-Katherine", replace
*hcc
import excel "C:\Users\Amy\Box Sync\DENV CHIKV project\West Cleaned\HCC\HCC Latest\HCC_Initial", sheet("Sheet1") firstrow clear
save "west_HCC_Initial", replace
import excel "C:\Users\Amy\Box Sync\DENV CHIKV project\West Cleaned\HCC\HCC Latest\HCC_1st Followup", sheet("Sheet1") firstrow clear
save "west_HCC_1st Followup", replace
import excel "C:\Users\Amy\Box Sync\DENV CHIKV project\West Cleaned\HCC\HCC Latest\HCC_2nd Followup", sheet("Sheet1") firstrow clear
save "west_HCC_2nd Followup", replace
import excel "C:\Users\Amy\Box Sync\DENV CHIKV project\West Cleaned\HCC\HCC Latest\HCC_3rd Followup", sheet("Sheet1") firstrow clear
save "west_HCC_3rd Followup", replace
