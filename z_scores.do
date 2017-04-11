local data "C:\Users\amykr\Box Sync\Amy Krystosik's Files\ASTMH 2017 abstracts\all linked and cleaned data\data\"
insheet using "C:\Users\amykr\Box Sync\Amy Krystosik's Files\david coinfectin paper\who anthro\MySurvey_z_st.csv", clear 
save "`data'z_scores", replace
