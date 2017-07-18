insheet using "C:\Users\amykr\Box Sync\Amy Krystosik's Files\zika study- grenada\ZikaPregnancyCohort_DATA_2017-07-10_1644.csv", comma names clear
*net get  dm0004_1.pkg


egen zhcaukwho = zanthro(mean_hc ,hca,UKWHOterm), xvar(child_calculated_age) gender(gender) gencode(male=1, female=2)nocutoff ageunit(month) 
egen zwtukwho = zanthro(childweight,wa,UKWHOterm), xvar(age) gender(gender) gencode(male=0, female=1)nocutoff ageunit(year) 
egen zhtukwho = zanthro(childheight,ha,UKWHOterm), xvar(age) gender(gender) gencode(male=0, female=1)nocutoff ageunit(year) 
egen zbmiukwho = zanthro(childbmi , ba ,UKWHOterm), xvar(age) gender(gender) gencode(male=0, female=1)nocutoff ageunit(year) 

*outsheet studyid gender age zwtukwho childweight  zhtukwho childheight  zbmiukwho childbmi  zhcaukwho  headcircum  if zbmiukwho  >5 & zbmiukwho  !=. |zbmiukwho  <-5 & zbmiukwho  !=. |zhcaukwho  <-5 & zhcaukwho  !=. |zhcaukwho  >5 & zhcaukwho  !=. using anthrotoreview.xls, replace
*table1, vars(zhcaukwho conts \ zwtukwho conts \ zhtukwho conts \ zbmiukwho  conts \)  by(coinfectiongroup) saving("`figures'anthrozscores.xls", replace ) missing test
*outsheet studyid gender age zwtukwho childweight  zhtukwho childheight  zbmiukwho childbmi  zhcaukwho  headcircum  using anthrozscoreslist.xls, replace

sum zwtukwho zhtukwho zbmiukwho zhcaukwho, d
