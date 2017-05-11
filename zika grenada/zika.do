cd "C:\Users\amykr\Box Sync\Amy Krystosik's Files\zika study- grenada"

insheet using "C:\Users\amykr\Desktop\mom.csv", comma clear
dropmiss, force
save mom, replace

insheet using "C:\Users\amykr\Desktop\child.csv", comma clear
dropmiss, force
save child, replace

merge m:1  mother_record_id using mom

tab  delivery_date 

gen mom_pregant_outbreak = . 

gen delivery_date2= date(delivery_date , "DMY")
format delivery_date2 %td
tab delivery_date2

*replace mom_pregant_outbreak  =  1 

outsheet using merged.csv, comma  names replace
