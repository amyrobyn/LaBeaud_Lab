insheet using "C:\Users\amykr\Box Sync\Amy Krystosik's Files\zika study- grenada\ZikaPregnancyCohort_DATA_2018-05-02_1503 (1).csv", comma names clear
*net get  dm0004_1.pkg
replace cbmi=mean_weight/((mean_length/100)*(mean_length/100) )

egen zhcaukwho = zanthro(mean_hc,hca,UKWHOterm), xvar(child_calculated_age) gender(gender) gencode(male=1, female=2)nocutoff ageunit(month) 
egen zwtukwho = zanthro(mean_weight,wa,UKWHOterm), xvar(child_calculated_age) gender(gender) gencode(male=1, female=2)nocutoff ageunit(month) 
egen zhtukwho = zanthro( mean_length,ha,UKWHOterm), xvar(child_calculated_age) gender(gender) gencode(male=1, female=2)nocutoff ageunit(month) 
egen zbmiukwho = zanthro(cbmi , ba ,UKWHOterm), xvar(child_calculated_age) gender(gender) gencode(male=1, female=2)nocutoff ageunit(month) 

egen zlen2 = zanthro(mean_length, ha ,UKWHOterm), xvar(child_calculated_age) gender(gender) gencode(male=1, female=2)nocutoff ageunit(month) 

egen zwfl2= zanthro(mean_weight, wl , WHO), xvar(mean_length) gender(gender) gencode(male=1, female=2)nocutoff  

*outsheet studyid gender age zwtukwho childweight  zhtukwho childheight  zbmiukwho childbmi  zhcaukwho  headcircum  if zbmiukwho  >5 & zbmiukwho  !=. |zbmiukwho  <-5 & zbmiukwho  !=. |zhcaukwho  <-5 & zhcaukwho  !=. |zhcaukwho  >5 & zhcaukwho  !=. using anthrotoreview.xls, replace
*table1, vars(zhcaukwho conts \ zwtukwho conts \ zhtukwho conts \ zbmiukwho  conts \)  by(coinfectiongroup) saving("`figures'anthrozscores.xls", replace ) missing test
*outsheet studyid gender age zwtukwho childweight  zhtukwho childheight  zbmiukwho childbmi  zhcaukwho  headcircum  using anthrozscoreslist.xls, replace

sum zwtukwho zhtukwho zbmiukwho zhcaukwho zlen2 zwfl2, d


outsheet using "C:\Users\amykr\Desktop\zika anthro.csv", comma replace
