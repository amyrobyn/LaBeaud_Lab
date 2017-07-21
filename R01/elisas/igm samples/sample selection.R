library(xlsx)
setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/gina dabba")
chikv_kenya<-read.xlsx("igm samples reports.xlsx",  2)
chikv_kenya$chikv_kenya_seroconverter<-1

denv_kenya<-read.xlsx("igm samples reports.xlsx",  3)
denv_kenya$denv_kenya<-denv_kenya_seroconverter<-1

chikv_stfd<-read.xlsx("igm samples reports.xlsx",  4)
chikv_stfd$chikv_stfd_seroconverter<-1

denv_stfd<-read.xlsx("igm samples reports.xlsx",  1)
denv_stfd$denv_stfd_seroconverter<-1

#keep if Stanford results are: Negative to blank; Negative to repeat; Blank to positive; Blank to blank ; Repeat to positive; Repeat to blank; Repeat to repeat
denv
#ab
denv_kenya$negative_blank_visit_a_denv_stfd<-ifelse(denv_kenya$X.visit_a_arm_1..result_igg_denv_stfd.=='0' & is.na(denv_kenya$X.visit_b_arm_1..result_igg_denv_stfd.) & denv_kenya$X.visit_a_arm_1..result_igg_denv_kenya.=='0' & denv_kenya$X.visit_b_arm_1..result_igg_denv_kenya.=="1",1,0)
table(denv_kenya$negative_blank_visit_a_denv_stfd)
denv_kenya$negative_repeat_visit_a_denv_stfd<-ifelse(denv_kenya$X.visit_a_arm_1..result_igg_denv_stfd.=="0" & denv_kenya$X.visit_b_arm_1..result_igg_denv_stfd.=="98" & denv_kenya$X.visit_a_arm_1..result_igg_denv_kenya.=='0' & denv_kenya$X.visit_b_arm_1..result_igg_denv_kenya.=="1",1,0)
table(denv_kenya$negative_repeat_visit_a_denv_stfd)
denv_kenya$blank_positive_visit_a_denv_stfd<-ifelse(is.na(denv_kenya$X.visit_a_arm_1..result_igg_denv_stfd.) & denv_kenya$X.visit_b_arm_1..result_igg_denv_stfd.=="1" & denv_kenya$X.visit_a_arm_1..result_igg_denv_kenya.=='0' & denv_kenya$X.visit_b_arm_1..result_igg_denv_kenya.=="1",1,0)
table(denv_kenya$blank_positive_visit_a_denv_stfd)
denv_kenya$blank_blank_visit_a_denv_stfd<-ifelse(is.na(denv_kenya$X.visit_a_arm_1..result_igg_denv_stfd.) & is.na(denv_kenya$X.visit_b_arm_1..result_igg_denv_stfd. & denv_kenya$X.visit_a_arm_1..result_igg_denv_kenya.=='0' & denv_kenya$X.visit_b_arm_1..result_igg_denv_kenya.=="1"),1,0)
table(denv_kenya$blank_positive_visit_a_denv_stfd)
denv_kenya$repeat_positive_visit_a_denv_stfd<-ifelse(denv_kenya$X.visit_a_arm_1..result_igg_denv_stfd.=="98" & denv_kenya$X.visit_b_arm_1..result_igg_denv_stfd.=="1" & denv_kenya$X.visit_a_arm_1..result_igg_denv_kenya.=='0' & denv_kenya$X.visit_b_arm_1..result_igg_denv_kenya.=="1",1,0)
table(denv_kenya$blank_positive_visit_a_denv_stfd)
denv_kenya$repeat_blank_visit_a_denv_stfd<-ifelse(denv_kenya$X.visit_a_arm_1..result_igg_denv_stfd.=="98" & is.na(denv_kenya$X.visit_b_arm_1..result_igg_denv_stfd. & denv_kenya$X.visit_a_arm_1..result_igg_denv_kenya.=='0' & denv_kenya$X.visit_b_arm_1..result_igg_denv_kenya.=="1"),1,0)
table(denv_kenya$blank_positive_visit_a_denv_stfd)
denv_kenya$repeat_repeat_visit_a_denv_stfd<-ifelse(denv_kenya$X.visit_a_arm_1..result_igg_denv_stfd.=="98" & denv_kenya$X.visit_b_arm_1..result_igg_denv_stfd.=="98" & denv_kenya$X.visit_a_arm_1..result_igg_denv_kenya.=='0' & denv_kenya$X.visit_b_arm_1..result_igg_denv_kenya.=="1",1,0)
table(denv_kenya$blank_positive_visit_a_denv_stfd)

#bc
denv_kenya$negative_blank_visit_b_denv_stfd<-ifelse(denv_kenya$X.visit_b_arm_1..result_igg_denv_stfd.=='0' & is.na(denv_kenya$X.visit_c_arm_1..result_igg_denv_stfd.) & denv_kenya$X.visit_b_arm_1..result_igg_denv_kenya.=='0' & denv_kenya$X.visit_c_arm_1..result_igg_denv_kenya.=="1",1,0)
table(denv_kenya$negative_blank_visit_b_denv_stfd)
denv_kenya$negative_repeat_visit_b_denv_stfd<-ifelse(denv_kenya$X.visit_b_arm_1..result_igg_denv_stfd.=="0" & denv_kenya$X.visit_c_arm_1..result_igg_denv_stfd.=="98" & denv_kenya$X.visit_b_arm_1..result_igg_denv_kenya.=='0' & denv_kenya$X.visit_c_arm_1..result_igg_denv_kenya.=="1",1,0)
table(denv_kenya$negative_repeat_visit_b_denv_stfd)
denv_kenya$blank_positive_visit_b_denv_stfd<-ifelse(is.na(denv_kenya$X.visit_b_arm_1..result_igg_denv_stfd.) & denv_kenya$X.visit_c_arm_1..result_igg_denv_stfd.=="1" & denv_kenya$X.visit_b_arm_1..result_igg_denv_kenya.=='0' & denv_kenya$X.visit_c_arm_1..result_igg_denv_kenya.=="1",1,0)
table(denv_kenya$blank_positive_visit_b_denv_stfd)
denv_kenya$blank_blank_visit_b_denv_stfd<-ifelse(is.na(denv_kenya$X.visit_b_arm_1..result_igg_denv_stfd.) & is.na(denv_kenya$X.visit_c_arm_1..result_igg_denv_stfd. & denv_kenya$X.visit_b_arm_1..result_igg_denv_kenya.=='0' & denv_kenya$X.visit_c_arm_1..result_igg_denv_kenya.=="1"),1,0)
table(denv_kenya$blank_positive_visit_b_denv_stfd)
denv_kenya$repeat_positive_visit_b_denv_stfd<-ifelse(denv_kenya$X.visit_b_arm_1..result_igg_denv_stfd.=="98" & denv_kenya$X.visit_c_arm_1..result_igg_denv_stfd.=="1" & denv_kenya$X.visit_b_arm_1..result_igg_denv_kenya.=='0' & denv_kenya$X.visit_c_arm_1..result_igg_denv_kenya.=="1",1,0)
table(denv_kenya$blank_positive_visit_b_denv_stfd)
denv_kenya$repeat_blank_visit_b_denv_stfd<-ifelse(denv_kenya$X.visit_b_arm_1..result_igg_denv_stfd.=="98" & is.na(denv_kenya$X.visit_c_arm_1..result_igg_denv_stfd. & denv_kenya$X.visit_b_arm_1..result_igg_denv_kenya.=='0' & denv_kenya$X.visit_c_arm_1..result_igg_denv_kenya.=="1"),1,0)
table(denv_kenya$blank_positive_visit_b_denv_stfd)
denv_kenya$repeat_repeat_visit_b_denv_stfd<-ifelse(denv_kenya$X.visit_b_arm_1..result_igg_denv_stfd.=="98" & denv_kenya$X.visit_c_arm_1..result_igg_denv_stfd.=="98" & denv_kenya$X.visit_b_arm_1..result_igg_denv_kenya.=='0' & denv_kenya$X.visit_c_arm_1..result_igg_denv_kenya.=="1",1,0)
table(denv_kenya$blank_positive_visit_b_denv_stfd)

#cd
denv_kenya$negative_blank_visit_c_denv_stfd<-ifelse(denv_kenya$X.visit_c_arm_1..result_igg_denv_stfd.=='0' & is.na(denv_kenya$X.visit_d_arm_1..result_igg_denv_stfd.) & denv_kenya$X.visit_c_arm_1..result_igg_denv_kenya.=='0' & denv_kenya$X.visit_d_arm_1..result_igg_denv_kenya.=="1",1,0)
table(denv_kenya$negative_blank_visit_c_denv_stfd)
denv_kenya$negative_repeat_visit_c_denv_stfd<-ifelse(denv_kenya$X.visit_c_arm_1..result_igg_denv_stfd.=="0" & denv_kenya$X.visit_d_arm_1..result_igg_denv_stfd.=="98" & denv_kenya$X.visit_c_arm_1..result_igg_denv_kenya.=='0' & denv_kenya$X.visit_d_arm_1..result_igg_denv_kenya.=="1",1,0)
table(denv_kenya$negative_repeat_visit_c_denv_stfd)
denv_kenya$blank_positive_visit_c_denv_stfd<-ifelse(is.na(denv_kenya$X.visit_c_arm_1..result_igg_denv_stfd.) & denv_kenya$X.visit_d_arm_1..result_igg_denv_stfd.=="1" & denv_kenya$X.visit_c_arm_1..result_igg_denv_kenya.=='0' & denv_kenya$X.visit_d_arm_1..result_igg_denv_kenya.=="1",1,0)
table(denv_kenya$blank_positive_visit_c_denv_stfd)
denv_kenya$blank_blank_visit_c_denv_stfd<-ifelse(is.na(denv_kenya$X.visit_c_arm_1..result_igg_denv_stfd.) & is.na(denv_kenya$X.visit_d_arm_1..result_igg_denv_stfd. & denv_kenya$X.visit_c_arm_1..result_igg_denv_kenya.=='0' & denv_kenya$X.visit_d_arm_1..result_igg_denv_kenya.=="1"),1,0)
table(denv_kenya$blank_positive_visit_c_denv_stfd)
denv_kenya$repeat_positive_visit_c_denv_stfd<-ifelse(denv_kenya$X.visit_c_arm_1..result_igg_denv_stfd.=="98" & denv_kenya$X.visit_d_arm_1..result_igg_denv_stfd.=="1" & denv_kenya$X.visit_c_arm_1..result_igg_denv_kenya.=='0' & denv_kenya$X.visit_d_arm_1..result_igg_denv_kenya.=="1",1,0)
table(denv_kenya$blank_positive_visit_c_denv_stfd)
denv_kenya$repeat_blank_visit_c_denv_stfd<-ifelse(denv_kenya$X.visit_c_arm_1..result_igg_denv_stfd.=="98" & is.na(denv_kenya$X.visit_d_arm_1..result_igg_denv_stfd. & denv_kenya$X.visit_c_arm_1..result_igg_denv_kenya.=='0' & denv_kenya$X.visit_d_arm_1..result_igg_denv_kenya.=="1"),1,0)
table(denv_kenya$blank_positive_visit_c_denv_stfd)
denv_kenya$repeat_repeat_visit_c_denv_stfd<-ifelse(denv_kenya$X.visit_c_arm_1..result_igg_denv_stfd.=="98" & denv_kenya$X.visit_d_arm_1..result_igg_denv_stfd.=="98" & denv_kenya$X.visit_c_arm_1..result_igg_denv_kenya.=='0' & denv_kenya$X.visit_d_arm_1..result_igg_denv_kenya.=="1",1,0)
table(denv_kenya$blank_positive_visit_c_denv_stfd)

#de
denv_kenya$negative_blank_visit_d_denv_stfd<-ifelse(denv_kenya$X.visit_d_arm_1..result_igg_denv_stfd.=='0' & is.na(denv_kenya$X.visit_e_arm_1..result_igg_denv_stfd.) & denv_kenya$X.visit_d_arm_1..result_igg_denv_kenya.=='0' & denv_kenya$X.visit_e_arm_1..result_igg_denv_kenya.=="1",1,0)
table(denv_kenya$negative_blank_visit_d_denv_stfd)
denv_kenya$negative_repeat_visit_d_denv_stfd<-ifelse(denv_kenya$X.visit_d_arm_1..result_igg_denv_stfd.=="0" & denv_kenya$X.visit_e_arm_1..result_igg_denv_stfd.=="98" & denv_kenya$X.visit_d_arm_1..result_igg_denv_kenya.=='0' & denv_kenya$X.visit_e_arm_1..result_igg_denv_kenya.=="1",1,0)
table(denv_kenya$negative_repeat_visit_d_denv_stfd)
denv_kenya$blank_positive_visit_d_denv_stfd<-ifelse(is.na(denv_kenya$X.visit_d_arm_1..result_igg_denv_stfd.) & denv_kenya$X.visit_e_arm_1..result_igg_denv_stfd.=="1" & denv_kenya$X.visit_d_arm_1..result_igg_denv_kenya.=='0' & denv_kenya$X.visit_e_arm_1..result_igg_denv_kenya.=="1",1,0)
table(denv_kenya$blank_positive_visit_d_denv_stfd)
denv_kenya$blank_blank_visit_d_denv_stfd<-ifelse(is.na(denv_kenya$X.visit_d_arm_1..result_igg_denv_stfd.) & is.na(denv_kenya$X.visit_e_arm_1..result_igg_denv_stfd. & denv_kenya$X.visit_d_arm_1..result_igg_denv_kenya.=='0' & denv_kenya$X.visit_e_arm_1..result_igg_denv_kenya.=="1"),1,0)
table(denv_kenya$blank_positive_visit_d_denv_stfd)
denv_kenya$repeat_positive_visit_d_denv_stfd<-ifelse(denv_kenya$X.visit_d_arm_1..result_igg_denv_stfd.=="98" & denv_kenya$X.visit_e_arm_1..result_igg_denv_stfd.=="1" & denv_kenya$X.visit_d_arm_1..result_igg_denv_kenya.=='0' & denv_kenya$X.visit_e_arm_1..result_igg_denv_kenya.=="1",1,0)
table(denv_kenya$blank_positive_visit_d_denv_stfd)
denv_kenya$repeat_blank_visit_d_denv_stfd<-ifelse(denv_kenya$X.visit_d_arm_1..result_igg_denv_stfd.=="98" & is.na(denv_kenya$X.visit_e_arm_1..result_igg_denv_stfd. & denv_kenya$X.visit_d_arm_1..result_igg_denv_kenya.=='0' & denv_kenya$X.visit_e_arm_1..result_igg_denv_kenya.=="1"),1,0)
table(denv_kenya$blank_positive_visit_d_denv_stfd)
denv_kenya$repeat_repeat_visit_d_denv_stfd<-ifelse(denv_kenya$X.visit_d_arm_1..result_igg_denv_stfd.=="98" & denv_kenya$X.visit_e_arm_1..result_igg_denv_stfd.=="98" & denv_kenya$X.visit_d_arm_1..result_igg_denv_kenya.=='0' & denv_kenya$X.visit_e_arm_1..result_igg_denv_kenya.=="1",1,0)
table(denv_kenya$blank_positive_visit_d_denv_stfd)

#ef
denv_kenya$negative_blank_visit_e_denv_stfd<-ifelse(denv_kenya$X.visit_e_arm_1..result_igg_denv_stfd.=='0' & is.na(denv_kenya$X.visit_f_arm_1..result_igg_denv_stfd.) & denv_kenya$X.visit_e_arm_1..result_igg_denv_kenya.=='0' & denv_kenya$X.visit_f_arm_1..result_igg_denv_kenya.=="1",1,0)
table(denv_kenya$negative_blank_visit_e_denv_stfd)
denv_kenya$negative_repeat_visit_e_denv_stfd<-ifelse(denv_kenya$X.visit_e_arm_1..result_igg_denv_stfd.=="0" & denv_kenya$X.visit_f_arm_1..result_igg_denv_stfd.=="98" & denv_kenya$X.visit_e_arm_1..result_igg_denv_kenya.=='0' & denv_kenya$X.visit_f_arm_1..result_igg_denv_kenya.=="1",1,0)
table(denv_kenya$negative_repeat_visit_e_denv_stfd)
denv_kenya$blank_positive_visit_e_denv_stfd<-ifelse(is.na(denv_kenya$X.visit_e_arm_1..result_igg_denv_stfd.) & denv_kenya$X.visit_f_arm_1..result_igg_denv_stfd.=="1" & denv_kenya$X.visit_e_arm_1..result_igg_denv_kenya.=='0' & denv_kenya$X.visit_f_arm_1..result_igg_denv_kenya.=="1",1,0)
table(denv_kenya$blank_positive_visit_e_denv_stfd)
denv_kenya$blank_blank_visit_e_denv_stfd<-ifelse(is.na(denv_kenya$X.visit_e_arm_1..result_igg_denv_stfd.) & is.na(denv_kenya$X.visit_f_arm_1..result_igg_denv_stfd. & denv_kenya$X.visit_e_arm_1..result_igg_denv_kenya.=='0' & denv_kenya$X.visit_f_arm_1..result_igg_denv_kenya.=="1"),1,0)
table(denv_kenya$blank_positive_visit_e_denv_stfd)
denv_kenya$repeat_positive_visit_e_denv_stfd<-ifelse(denv_kenya$X.visit_e_arm_1..result_igg_denv_stfd.=="98" & denv_kenya$X.visit_f_arm_1..result_igg_denv_stfd.=="1" & denv_kenya$X.visit_e_arm_1..result_igg_denv_kenya.=='0' & denv_kenya$X.visit_f_arm_1..result_igg_denv_kenya.=="1",1,0)
table(denv_kenya$blank_positive_visit_e_denv_stfd)
denv_kenya$repeat_blank_visit_e_denv_stfd<-ifelse(denv_kenya$X.visit_e_arm_1..result_igg_denv_stfd.=="98" & is.na(denv_kenya$X.visit_f_arm_1..result_igg_denv_stfd. & denv_kenya$X.visit_e_arm_1..result_igg_denv_kenya.=='0' & denv_kenya$X.visit_f_arm_1..result_igg_denv_kenya.=="1"),1,0)
table(denv_kenya$blank_positive_visit_e_denv_stfd)
denv_kenya$repeat_repeat_visit_e_denv_stfd<-ifelse(denv_kenya$X.visit_e_arm_1..result_igg_denv_stfd.=="98" & denv_kenya$X.visit_f_arm_1..result_igg_denv_stfd.=="98" & denv_kenya$X.visit_e_arm_1..result_igg_denv_kenya.=='0' & denv_kenya$X.visit_f_arm_1..result_igg_denv_kenya.=="1",1,0)
table(denv_kenya$blank_positive_visit_e_denv_stfd)

#fg
denv_kenya$negative_blank_visit_f_denv_stfd<-ifelse(denv_kenya$X.visit_f_arm_1..result_igg_denv_stfd.=='0' & is.na(denv_kenya$X.visit_g_arm_1..result_igg_denv_stfd.) & denv_kenya$X.visit_f_arm_1..result_igg_denv_kenya.=='0' & denv_kenya$X.visit_g_arm_1..result_igg_denv_kenya.=="1",1,0)
table(denv_kenya$negative_blank_visit_f_denv_stfd)
denv_kenya$negative_repeat_visit_f_denv_stfd<-ifelse(denv_kenya$X.visit_f_arm_1..result_igg_denv_stfd.=="0" & denv_kenya$X.visit_g_arm_1..result_igg_denv_stfd.=="98" & denv_kenya$X.visit_f_arm_1..result_igg_denv_kenya.=='0' & denv_kenya$X.visit_g_arm_1..result_igg_denv_kenya.=="1",1,0)
table(denv_kenya$negative_repeat_visit_f_denv_stfd)
denv_kenya$blank_positive_visit_f_denv_stfd<-ifelse(is.na(denv_kenya$X.visit_f_arm_1..result_igg_denv_stfd.) & denv_kenya$X.visit_g_arm_1..result_igg_denv_stfd.=="1" & denv_kenya$X.visit_f_arm_1..result_igg_denv_kenya.=='0' & denv_kenya$X.visit_g_arm_1..result_igg_denv_kenya.=="1",1,0)
table(denv_kenya$blank_positive_visit_f_denv_stfd)
denv_kenya$blank_blank_visit_f_denv_stfd<-ifelse(is.na(denv_kenya$X.visit_f_arm_1..result_igg_denv_stfd.) & is.na(denv_kenya$X.visit_g_arm_1..result_igg_denv_stfd. & denv_kenya$X.visit_f_arm_1..result_igg_denv_kenya.=='0' & denv_kenya$X.visit_g_arm_1..result_igg_denv_kenya.=="1"),1,0)
table(denv_kenya$blank_positive_visit_f_denv_stfd)
denv_kenya$repeat_positive_visit_f_denv_stfd<-ifelse(denv_kenya$X.visit_f_arm_1..result_igg_denv_stfd.=="98" & denv_kenya$X.visit_g_arm_1..result_igg_denv_stfd.=="1" & denv_kenya$X.visit_f_arm_1..result_igg_denv_kenya.=='0' & denv_kenya$X.visit_g_arm_1..result_igg_denv_kenya.=="1",1,0)
table(denv_kenya$blank_positive_visit_f_denv_stfd)
denv_kenya$repeat_blank_visit_f_denv_stfd<-ifelse(denv_kenya$X.visit_f_arm_1..result_igg_denv_stfd.=="98" & is.na(denv_kenya$X.visit_g_arm_1..result_igg_denv_stfd. & denv_kenya$X.visit_f_arm_1..result_igg_denv_kenya.=='0' & denv_kenya$X.visit_g_arm_1..result_igg_denv_kenya.=="1"),1,0)
table(denv_kenya$blank_positive_visit_f_denv_stfd)
denv_kenya$repeat_repeat_visit_f_denv_stfd<-ifelse(denv_kenya$X.visit_f_arm_1..result_igg_denv_stfd.=="98" & denv_kenya$X.visit_g_arm_1..result_igg_denv_stfd.=="98" & denv_kenya$X.visit_f_arm_1..result_igg_denv_kenya.=='0' & denv_kenya$X.visit_g_arm_1..result_igg_denv_kenya.=="1",1,0)
table(denv_kenya$blank_positive_visit_f_denv_stfd)

#gh
denv_kenya$negative_blank_visit_g_denv_stfd<-ifelse(denv_kenya$X.visit_g_arm_1..result_igg_denv_stfd.=='0' & is.na(denv_kenya$X.visit_h_arm_1..result_igg_denv_stfd.) & denv_kenya$X.visit_g_arm_1..result_igg_denv_kenya.=='0' & denv_kenya$X.visit_h_arm_1..result_igg_denv_kenya.=="1",1,0)
table(denv_kenya$negative_blank_visit_g_denv_stfd)
denv_kenya$negative_repeat_visit_g_denv_stfd<-ifelse(denv_kenya$X.visit_g_arm_1..result_igg_denv_stfd.=="0" & denv_kenya$X.visit_h_arm_1..result_igg_denv_stfd.=="98" & denv_kenya$X.visit_g_arm_1..result_igg_denv_kenya.=='0' & denv_kenya$X.visit_h_arm_1..result_igg_denv_kenya.=="1",1,0)
table(denv_kenya$negative_repeat_visit_g_denv_stfd)
denv_kenya$blank_positive_visit_g_denv_stfd<-ifelse(is.na(denv_kenya$X.visit_g_arm_1..result_igg_denv_stfd.) & denv_kenya$X.visit_h_arm_1..result_igg_denv_stfd.=="1" & denv_kenya$X.visit_g_arm_1..result_igg_denv_kenya.=='0' & denv_kenya$X.visit_h_arm_1..result_igg_denv_kenya.=="1",1,0)
table(denv_kenya$blank_positive_visit_g_denv_stfd)
denv_kenya$blank_blank_visit_g_denv_stfd<-ifelse(is.na(denv_kenya$X.visit_g_arm_1..result_igg_denv_stfd.) & is.na(denv_kenya$X.visit_h_arm_1..result_igg_denv_stfd. & denv_kenya$X.visit_g_arm_1..result_igg_denv_kenya.=='0' & denv_kenya$X.visit_h_arm_1..result_igg_denv_kenya.=="1"),1,0)
table(denv_kenya$blank_positive_visit_g_denv_stfd)
denv_kenya$repeat_positive_visit_g_denv_stfd<-ifelse(denv_kenya$X.visit_g_arm_1..result_igg_denv_stfd.=="98" & denv_kenya$X.visit_h_arm_1..result_igg_denv_stfd.=="1" & denv_kenya$X.visit_g_arm_1..result_igg_denv_kenya.=='0' & denv_kenya$X.visit_h_arm_1..result_igg_denv_kenya.=="1",1,0)
table(denv_kenya$blank_positive_visit_g_denv_stfd)
denv_kenya$repeat_blank_visit_g_denv_stfd<-ifelse(denv_kenya$X.visit_g_arm_1..result_igg_denv_stfd.=="98" & is.na(denv_kenya$X.visit_h_arm_1..result_igg_denv_stfd. & denv_kenya$X.visit_g_arm_1..result_igg_denv_kenya.=='0' & denv_kenya$X.visit_h_arm_1..result_igg_denv_kenya.=="1"),1,0)
table(denv_kenya$blank_positive_visit_g_denv_stfd)
denv_kenya$repeat_repeat_visit_g_denv_stfd<-ifelse(denv_kenya$X.visit_g_arm_1..result_igg_denv_stfd.=="98" & denv_kenya$X.visit_h_arm_1..result_igg_denv_stfd.=="98" & denv_kenya$X.visit_g_arm_1..result_igg_denv_kenya.=='0' & denv_kenya$X.visit_h_arm_1..result_igg_denv_kenya.=="1",1,0)
table(denv_kenya$blank_positive_visit_g_denv_stfd)

###############chikv
#ab
chikv_kenya$negative_blank_visit_a_chikv_stfd<-ifelse(chikv_kenya$X.visit_a_arm_1..result_igg_chikv_stfd.=='0' & is.na(chikv_kenya$X.visit_b_arm_1..result_igg_chikv_stfd.) & chikv_kenya$X.visit_a_arm_1..result_igg_chikv_kenya.=='0' & chikv_kenya$X.visit_b_arm_1..result_igg_chikv_kenya.=="1",1,0)
table(chikv_kenya$negative_blank_visit_a_chikv_stfd)
chikv_kenya$negative_repeat_visit_a_chikv_stfd<-ifelse(chikv_kenya$X.visit_a_arm_1..result_igg_chikv_stfd.=="0" & chikv_kenya$X.visit_b_arm_1..result_igg_chikv_stfd.=="98" & chikv_kenya$X.visit_a_arm_1..result_igg_chikv_kenya.=='0' & chikv_kenya$X.visit_b_arm_1..result_igg_chikv_kenya.=="1",1,0)
table(chikv_kenya$negative_repeat_visit_a_chikv_stfd)
chikv_kenya$blank_positive_visit_a_chikv_stfd<-ifelse(is.na(chikv_kenya$X.visit_a_arm_1..result_igg_chikv_stfd.) & chikv_kenya$X.visit_b_arm_1..result_igg_chikv_stfd.=="1" & chikv_kenya$X.visit_a_arm_1..result_igg_chikv_kenya.=='0' & chikv_kenya$X.visit_b_arm_1..result_igg_chikv_kenya.=="1",1,0)
table(chikv_kenya$blank_positive_visit_a_chikv_stfd)
chikv_kenya$blank_blank_visit_a_chikv_stfd<-ifelse(is.na(chikv_kenya$X.visit_a_arm_1..result_igg_chikv_stfd.) & is.na(chikv_kenya$X.visit_b_arm_1..result_igg_chikv_stfd. & chikv_kenya$X.visit_a_arm_1..result_igg_chikv_kenya.=='0' & chikv_kenya$X.visit_b_arm_1..result_igg_chikv_kenya.=="1"),1,0)
table(chikv_kenya$blank_positive_visit_a_chikv_stfd)
chikv_kenya$repeat_positive_visit_a_chikv_stfd<-ifelse(chikv_kenya$X.visit_a_arm_1..result_igg_chikv_stfd.=="98" & chikv_kenya$X.visit_b_arm_1..result_igg_chikv_stfd.=="1" & chikv_kenya$X.visit_a_arm_1..result_igg_chikv_kenya.=='0' & chikv_kenya$X.visit_b_arm_1..result_igg_chikv_kenya.=="1",1,0)
table(chikv_kenya$blank_positive_visit_a_chikv_stfd)
chikv_kenya$repeat_blank_visit_a_chikv_stfd<-ifelse(chikv_kenya$X.visit_a_arm_1..result_igg_chikv_stfd.=="98" & is.na(chikv_kenya$X.visit_b_arm_1..result_igg_chikv_stfd. & chikv_kenya$X.visit_a_arm_1..result_igg_chikv_kenya.=='0' & chikv_kenya$X.visit_b_arm_1..result_igg_chikv_kenya.=="1"),1,0)
table(chikv_kenya$blank_positive_visit_a_chikv_stfd)
chikv_kenya$repeat_repeat_visit_a_chikv_stfd<-ifelse(chikv_kenya$X.visit_a_arm_1..result_igg_chikv_stfd.=="98" & chikv_kenya$X.visit_b_arm_1..result_igg_chikv_stfd.=="98" & chikv_kenya$X.visit_a_arm_1..result_igg_chikv_kenya.=='0' & chikv_kenya$X.visit_b_arm_1..result_igg_chikv_kenya.=="1",1,0)
table(chikv_kenya$blank_positive_visit_a_chikv_stfd)

#bc
chikv_kenya$negative_blank_visit_b_chikv_stfd<-ifelse(chikv_kenya$X.visit_b_arm_1..result_igg_chikv_stfd.=='0' & is.na(chikv_kenya$X.visit_c_arm_1..result_igg_chikv_stfd.) & chikv_kenya$X.visit_b_arm_1..result_igg_chikv_kenya.=='0' & chikv_kenya$X.visit_c_arm_1..result_igg_chikv_kenya.=="1",1,0)
table(chikv_kenya$negative_blank_visit_b_chikv_stfd)
chikv_kenya$negative_repeat_visit_b_chikv_stfd<-ifelse(chikv_kenya$X.visit_b_arm_1..result_igg_chikv_stfd.=="0" & chikv_kenya$X.visit_c_arm_1..result_igg_chikv_stfd.=="98" & chikv_kenya$X.visit_b_arm_1..result_igg_chikv_kenya.=='0' & chikv_kenya$X.visit_c_arm_1..result_igg_chikv_kenya.=="1",1,0)
table(chikv_kenya$negative_repeat_visit_b_chikv_stfd)
chikv_kenya$blank_positive_visit_b_chikv_stfd<-ifelse(is.na(chikv_kenya$X.visit_b_arm_1..result_igg_chikv_stfd.) & chikv_kenya$X.visit_c_arm_1..result_igg_chikv_stfd.=="1" & chikv_kenya$X.visit_b_arm_1..result_igg_chikv_kenya.=='0' & chikv_kenya$X.visit_c_arm_1..result_igg_chikv_kenya.=="1",1,0)
table(chikv_kenya$blank_positive_visit_b_chikv_stfd)
chikv_kenya$blank_blank_visit_b_chikv_stfd<-ifelse(is.na(chikv_kenya$X.visit_b_arm_1..result_igg_chikv_stfd.) & is.na(chikv_kenya$X.visit_c_arm_1..result_igg_chikv_stfd. & chikv_kenya$X.visit_b_arm_1..result_igg_chikv_kenya.=='0' & chikv_kenya$X.visit_c_arm_1..result_igg_chikv_kenya.=="1"),1,0)
table(chikv_kenya$blank_positive_visit_b_chikv_stfd)
chikv_kenya$repeat_positive_visit_b_chikv_stfd<-ifelse(chikv_kenya$X.visit_b_arm_1..result_igg_chikv_stfd.=="98" & chikv_kenya$X.visit_c_arm_1..result_igg_chikv_stfd.=="1" & chikv_kenya$X.visit_b_arm_1..result_igg_chikv_kenya.=='0' & chikv_kenya$X.visit_c_arm_1..result_igg_chikv_kenya.=="1",1,0)
table(chikv_kenya$blank_positive_visit_b_chikv_stfd)
chikv_kenya$repeat_blank_visit_b_chikv_stfd<-ifelse(chikv_kenya$X.visit_b_arm_1..result_igg_chikv_stfd.=="98" & is.na(chikv_kenya$X.visit_c_arm_1..result_igg_chikv_stfd. & chikv_kenya$X.visit_b_arm_1..result_igg_chikv_kenya.=='0' & chikv_kenya$X.visit_c_arm_1..result_igg_chikv_kenya.=="1"),1,0)
table(chikv_kenya$blank_positive_visit_b_chikv_stfd)
chikv_kenya$repeat_repeat_visit_b_chikv_stfd<-ifelse(chikv_kenya$X.visit_b_arm_1..result_igg_chikv_stfd.=="98" & chikv_kenya$X.visit_c_arm_1..result_igg_chikv_stfd.=="98" & chikv_kenya$X.visit_b_arm_1..result_igg_chikv_kenya.=='0' & chikv_kenya$X.visit_c_arm_1..result_igg_chikv_kenya.=="1",1,0)
table(chikv_kenya$blank_positive_visit_b_chikv_stfd)

#cd
chikv_kenya$negative_blank_visit_c_chikv_stfd<-ifelse(chikv_kenya$X.visit_c_arm_1..result_igg_chikv_stfd.=='0' & is.na(chikv_kenya$X.visit_d_arm_1..result_igg_chikv_stfd.) & chikv_kenya$X.visit_c_arm_1..result_igg_chikv_kenya.=='0' & chikv_kenya$X.visit_d_arm_1..result_igg_chikv_kenya.=="1",1,0)
table(chikv_kenya$negative_blank_visit_c_chikv_stfd)
chikv_kenya$negative_repeat_visit_c_chikv_stfd<-ifelse(chikv_kenya$X.visit_c_arm_1..result_igg_chikv_stfd.=="0" & chikv_kenya$X.visit_d_arm_1..result_igg_chikv_stfd.=="98" & chikv_kenya$X.visit_c_arm_1..result_igg_chikv_kenya.=='0' & chikv_kenya$X.visit_d_arm_1..result_igg_chikv_kenya.=="1",1,0)
table(chikv_kenya$negative_repeat_visit_c_chikv_stfd)
chikv_kenya$blank_positive_visit_c_chikv_stfd<-ifelse(is.na(chikv_kenya$X.visit_c_arm_1..result_igg_chikv_stfd.) & chikv_kenya$X.visit_d_arm_1..result_igg_chikv_stfd.=="1" & chikv_kenya$X.visit_c_arm_1..result_igg_chikv_kenya.=='0' & chikv_kenya$X.visit_d_arm_1..result_igg_chikv_kenya.=="1",1,0)
table(chikv_kenya$blank_positive_visit_c_chikv_stfd)
chikv_kenya$blank_blank_visit_c_chikv_stfd<-ifelse(is.na(chikv_kenya$X.visit_c_arm_1..result_igg_chikv_stfd.) & is.na(chikv_kenya$X.visit_d_arm_1..result_igg_chikv_stfd. & chikv_kenya$X.visit_c_arm_1..result_igg_chikv_kenya.=='0' & chikv_kenya$X.visit_d_arm_1..result_igg_chikv_kenya.=="1"),1,0)
table(chikv_kenya$blank_positive_visit_c_chikv_stfd)
chikv_kenya$repeat_positive_visit_c_chikv_stfd<-ifelse(chikv_kenya$X.visit_c_arm_1..result_igg_chikv_stfd.=="98" & chikv_kenya$X.visit_d_arm_1..result_igg_chikv_stfd.=="1" & chikv_kenya$X.visit_c_arm_1..result_igg_chikv_kenya.=='0' & chikv_kenya$X.visit_d_arm_1..result_igg_chikv_kenya.=="1",1,0)
table(chikv_kenya$blank_positive_visit_c_chikv_stfd)
chikv_kenya$repeat_blank_visit_c_chikv_stfd<-ifelse(chikv_kenya$X.visit_c_arm_1..result_igg_chikv_stfd.=="98" & is.na(chikv_kenya$X.visit_d_arm_1..result_igg_chikv_stfd. & chikv_kenya$X.visit_c_arm_1..result_igg_chikv_kenya.=='0' & chikv_kenya$X.visit_d_arm_1..result_igg_chikv_kenya.=="1"),1,0)
table(chikv_kenya$blank_positive_visit_c_chikv_stfd)
chikv_kenya$repeat_repeat_visit_c_chikv_stfd<-ifelse(chikv_kenya$X.visit_c_arm_1..result_igg_chikv_stfd.=="98" & chikv_kenya$X.visit_d_arm_1..result_igg_chikv_stfd.=="98" & chikv_kenya$X.visit_c_arm_1..result_igg_chikv_kenya.=='0' & chikv_kenya$X.visit_d_arm_1..result_igg_chikv_kenya.=="1",1,0)
table(chikv_kenya$blank_positive_visit_c_chikv_stfd)

#de
chikv_kenya$negative_blank_visit_d_chikv_stfd<-ifelse(chikv_kenya$X.visit_d_arm_1..result_igg_chikv_stfd.=='0' & is.na(chikv_kenya$X.visit_e_arm_1..result_igg_chikv_stfd.) & chikv_kenya$X.visit_d_arm_1..result_igg_chikv_kenya.=='0' & chikv_kenya$X.visit_e_arm_1..result_igg_chikv_kenya.=="1",1,0)
table(chikv_kenya$negative_blank_visit_d_chikv_stfd)
chikv_kenya$negative_repeat_visit_d_chikv_stfd<-ifelse(chikv_kenya$X.visit_d_arm_1..result_igg_chikv_stfd.=="0" & chikv_kenya$X.visit_e_arm_1..result_igg_chikv_stfd.=="98" & chikv_kenya$X.visit_d_arm_1..result_igg_chikv_kenya.=='0' & chikv_kenya$X.visit_e_arm_1..result_igg_chikv_kenya.=="1",1,0)
table(chikv_kenya$negative_repeat_visit_d_chikv_stfd)
chikv_kenya$blank_positive_visit_d_chikv_stfd<-ifelse(is.na(chikv_kenya$X.visit_d_arm_1..result_igg_chikv_stfd.) & chikv_kenya$X.visit_e_arm_1..result_igg_chikv_stfd.=="1" & chikv_kenya$X.visit_d_arm_1..result_igg_chikv_kenya.=='0' & chikv_kenya$X.visit_e_arm_1..result_igg_chikv_kenya.=="1",1,0)
table(chikv_kenya$blank_positive_visit_d_chikv_stfd)
chikv_kenya$blank_blank_visit_d_chikv_stfd<-ifelse(is.na(chikv_kenya$X.visit_d_arm_1..result_igg_chikv_stfd.) & is.na(chikv_kenya$X.visit_e_arm_1..result_igg_chikv_stfd. & chikv_kenya$X.visit_d_arm_1..result_igg_chikv_kenya.=='0' & chikv_kenya$X.visit_e_arm_1..result_igg_chikv_kenya.=="1"),1,0)
table(chikv_kenya$blank_positive_visit_d_chikv_stfd)
chikv_kenya$repeat_positive_visit_d_chikv_stfd<-ifelse(chikv_kenya$X.visit_d_arm_1..result_igg_chikv_stfd.=="98" & chikv_kenya$X.visit_e_arm_1..result_igg_chikv_stfd.=="1" & chikv_kenya$X.visit_d_arm_1..result_igg_chikv_kenya.=='0' & chikv_kenya$X.visit_e_arm_1..result_igg_chikv_kenya.=="1",1,0)
table(chikv_kenya$blank_positive_visit_d_chikv_stfd)
chikv_kenya$repeat_blank_visit_d_chikv_stfd<-ifelse(chikv_kenya$X.visit_d_arm_1..result_igg_chikv_stfd.=="98" & is.na(chikv_kenya$X.visit_e_arm_1..result_igg_chikv_stfd. & chikv_kenya$X.visit_d_arm_1..result_igg_chikv_kenya.=='0' & chikv_kenya$X.visit_e_arm_1..result_igg_chikv_kenya.=="1"),1,0)
table(chikv_kenya$blank_positive_visit_d_chikv_stfd)
chikv_kenya$repeat_repeat_visit_d_chikv_stfd<-ifelse(chikv_kenya$X.visit_d_arm_1..result_igg_chikv_stfd.=="98" & chikv_kenya$X.visit_e_arm_1..result_igg_chikv_stfd.=="98" & chikv_kenya$X.visit_d_arm_1..result_igg_chikv_kenya.=='0' & chikv_kenya$X.visit_e_arm_1..result_igg_chikv_kenya.=="1",1,0)
table(chikv_kenya$blank_positive_visit_d_chikv_stfd)

#ef
chikv_kenya$negative_blank_visit_e_chikv_stfd<-ifelse(chikv_kenya$X.visit_e_arm_1..result_igg_chikv_stfd.=='0' & is.na(chikv_kenya$X.visit_f_arm_1..result_igg_chikv_stfd.) & chikv_kenya$X.visit_e_arm_1..result_igg_chikv_kenya.=='0' & chikv_kenya$X.visit_f_arm_1..result_igg_chikv_kenya.=="1",1,0)
table(chikv_kenya$negative_blank_visit_e_chikv_stfd)
chikv_kenya$negative_repeat_visit_e_chikv_stfd<-ifelse(chikv_kenya$X.visit_e_arm_1..result_igg_chikv_stfd.=="0" & chikv_kenya$X.visit_f_arm_1..result_igg_chikv_stfd.=="98" & chikv_kenya$X.visit_e_arm_1..result_igg_chikv_kenya.=='0' & chikv_kenya$X.visit_f_arm_1..result_igg_chikv_kenya.=="1",1,0)
table(chikv_kenya$negative_repeat_visit_e_chikv_stfd)
chikv_kenya$blank_positive_visit_e_chikv_stfd<-ifelse(is.na(chikv_kenya$X.visit_e_arm_1..result_igg_chikv_stfd.) & chikv_kenya$X.visit_f_arm_1..result_igg_chikv_stfd.=="1" & chikv_kenya$X.visit_e_arm_1..result_igg_chikv_kenya.=='0' & chikv_kenya$X.visit_f_arm_1..result_igg_chikv_kenya.=="1",1,0)
table(chikv_kenya$blank_positive_visit_e_chikv_stfd)
chikv_kenya$blank_blank_visit_e_chikv_stfd<-ifelse(is.na(chikv_kenya$X.visit_e_arm_1..result_igg_chikv_stfd.) & is.na(chikv_kenya$X.visit_f_arm_1..result_igg_chikv_stfd. & chikv_kenya$X.visit_e_arm_1..result_igg_chikv_kenya.=='0' & chikv_kenya$X.visit_f_arm_1..result_igg_chikv_kenya.=="1"),1,0)
table(chikv_kenya$blank_positive_visit_e_chikv_stfd)
chikv_kenya$repeat_positive_visit_e_chikv_stfd<-ifelse(chikv_kenya$X.visit_e_arm_1..result_igg_chikv_stfd.=="98" & chikv_kenya$X.visit_f_arm_1..result_igg_chikv_stfd.=="1" & chikv_kenya$X.visit_e_arm_1..result_igg_chikv_kenya.=='0' & chikv_kenya$X.visit_f_arm_1..result_igg_chikv_kenya.=="1",1,0)
table(chikv_kenya$blank_positive_visit_e_chikv_stfd)
chikv_kenya$repeat_blank_visit_e_chikv_stfd<-ifelse(chikv_kenya$X.visit_e_arm_1..result_igg_chikv_stfd.=="98" & is.na(chikv_kenya$X.visit_f_arm_1..result_igg_chikv_stfd. & chikv_kenya$X.visit_e_arm_1..result_igg_chikv_kenya.=='0' & chikv_kenya$X.visit_f_arm_1..result_igg_chikv_kenya.=="1"),1,0)
table(chikv_kenya$blank_positive_visit_e_chikv_stfd)
chikv_kenya$repeat_repeat_visit_e_chikv_stfd<-ifelse(chikv_kenya$X.visit_e_arm_1..result_igg_chikv_stfd.=="98" & chikv_kenya$X.visit_f_arm_1..result_igg_chikv_stfd.=="98" & chikv_kenya$X.visit_e_arm_1..result_igg_chikv_kenya.=='0' & chikv_kenya$X.visit_f_arm_1..result_igg_chikv_kenya.=="1",1,0)
table(chikv_kenya$blank_positive_visit_e_chikv_stfd)

#fg
chikv_kenya$negative_blank_visit_f_chikv_stfd<-ifelse(chikv_kenya$X.visit_f_arm_1..result_igg_chikv_stfd.=='0' & is.na(chikv_kenya$X.visit_g_arm_1..result_igg_chikv_stfd.) & chikv_kenya$X.visit_f_arm_1..result_igg_chikv_kenya.=='0' & chikv_kenya$X.visit_g_arm_1..result_igg_chikv_kenya.=="1",1,0)
table(chikv_kenya$negative_blank_visit_f_chikv_stfd)
chikv_kenya$negative_repeat_visit_f_chikv_stfd<-ifelse(chikv_kenya$X.visit_f_arm_1..result_igg_chikv_stfd.=="0" & chikv_kenya$X.visit_g_arm_1..result_igg_chikv_stfd.=="98" & chikv_kenya$X.visit_f_arm_1..result_igg_chikv_kenya.=='0' & chikv_kenya$X.visit_g_arm_1..result_igg_chikv_kenya.=="1",1,0)
table(chikv_kenya$negative_repeat_visit_f_chikv_stfd)
chikv_kenya$blank_positive_visit_f_chikv_stfd<-ifelse(is.na(chikv_kenya$X.visit_f_arm_1..result_igg_chikv_stfd.) & chikv_kenya$X.visit_g_arm_1..result_igg_chikv_stfd.=="1" & chikv_kenya$X.visit_f_arm_1..result_igg_chikv_kenya.=='0' & chikv_kenya$X.visit_g_arm_1..result_igg_chikv_kenya.=="1",1,0)
table(chikv_kenya$blank_positive_visit_f_chikv_stfd)
chikv_kenya$blank_blank_visit_f_chikv_stfd<-ifelse(is.na(chikv_kenya$X.visit_f_arm_1..result_igg_chikv_stfd.) & is.na(chikv_kenya$X.visit_g_arm_1..result_igg_chikv_stfd. & chikv_kenya$X.visit_f_arm_1..result_igg_chikv_kenya.=='0' & chikv_kenya$X.visit_g_arm_1..result_igg_chikv_kenya.=="1"),1,0)
table(chikv_kenya$blank_positive_visit_f_chikv_stfd)
chikv_kenya$repeat_positive_visit_f_chikv_stfd<-ifelse(chikv_kenya$X.visit_f_arm_1..result_igg_chikv_stfd.=="98" & chikv_kenya$X.visit_g_arm_1..result_igg_chikv_stfd.=="1" & chikv_kenya$X.visit_f_arm_1..result_igg_chikv_kenya.=='0' & chikv_kenya$X.visit_g_arm_1..result_igg_chikv_kenya.=="1",1,0)
table(chikv_kenya$blank_positive_visit_f_chikv_stfd)
chikv_kenya$repeat_blank_visit_f_chikv_stfd<-ifelse(chikv_kenya$X.visit_f_arm_1..result_igg_chikv_stfd.=="98" & is.na(chikv_kenya$X.visit_g_arm_1..result_igg_chikv_stfd. & chikv_kenya$X.visit_f_arm_1..result_igg_chikv_kenya.=='0' & chikv_kenya$X.visit_g_arm_1..result_igg_chikv_kenya.=="1"),1,0)
table(chikv_kenya$blank_positive_visit_f_chikv_stfd)
chikv_kenya$repeat_repeat_visit_f_chikv_stfd<-ifelse(chikv_kenya$X.visit_f_arm_1..result_igg_chikv_stfd.=="98" & chikv_kenya$X.visit_g_arm_1..result_igg_chikv_stfd.=="98" & chikv_kenya$X.visit_f_arm_1..result_igg_chikv_kenya.=='0' & chikv_kenya$X.visit_g_arm_1..result_igg_chikv_kenya.=="1",1,0)
table(chikv_kenya$blank_positive_visit_f_chikv_stfd)

#gh
chikv_kenya$negative_blank_visit_g_chikv_stfd<-ifelse(chikv_kenya$X.visit_g_arm_1..result_igg_chikv_stfd.=='0' & is.na(chikv_kenya$X.visit_h_arm_1..result_igg_chikv_stfd.) & chikv_kenya$X.visit_g_arm_1..result_igg_chikv_kenya.=='0' & chikv_kenya$X.visit_h_arm_1..result_igg_chikv_kenya.=="1",1,0)
table(chikv_kenya$negative_blank_visit_g_chikv_stfd)
chikv_kenya$negative_repeat_visit_g_chikv_stfd<-ifelse(chikv_kenya$X.visit_g_arm_1..result_igg_chikv_stfd.=="0" & chikv_kenya$X.visit_h_arm_1..result_igg_chikv_stfd.=="98" & chikv_kenya$X.visit_g_arm_1..result_igg_chikv_kenya.=='0' & chikv_kenya$X.visit_h_arm_1..result_igg_chikv_kenya.=="1",1,0)
table(chikv_kenya$negative_repeat_visit_g_chikv_stfd)
chikv_kenya$blank_positive_visit_g_chikv_stfd<-ifelse(is.na(chikv_kenya$X.visit_g_arm_1..result_igg_chikv_stfd.) & chikv_kenya$X.visit_h_arm_1..result_igg_chikv_stfd.=="1" & chikv_kenya$X.visit_g_arm_1..result_igg_chikv_kenya.=='0' & chikv_kenya$X.visit_h_arm_1..result_igg_chikv_kenya.=="1",1,0)
table(chikv_kenya$blank_positive_visit_g_chikv_stfd)
chikv_kenya$blank_blank_visit_g_chikv_stfd<-ifelse(is.na(chikv_kenya$X.visit_g_arm_1..result_igg_chikv_stfd.) & is.na(chikv_kenya$X.visit_h_arm_1..result_igg_chikv_stfd. & chikv_kenya$X.visit_g_arm_1..result_igg_chikv_kenya.=='0' & chikv_kenya$X.visit_h_arm_1..result_igg_chikv_kenya.=="1"),1,0)
table(chikv_kenya$blank_positive_visit_g_chikv_stfd)
chikv_kenya$repeat_positive_visit_g_chikv_stfd<-ifelse(chikv_kenya$X.visit_g_arm_1..result_igg_chikv_stfd.=="98" & chikv_kenya$X.visit_h_arm_1..result_igg_chikv_stfd.=="1" & chikv_kenya$X.visit_g_arm_1..result_igg_chikv_kenya.=='0' & chikv_kenya$X.visit_h_arm_1..result_igg_chikv_kenya.=="1",1,0)
table(chikv_kenya$blank_positive_visit_g_chikv_stfd)
chikv_kenya$repeat_blank_visit_g_chikv_stfd<-ifelse(chikv_kenya$X.visit_g_arm_1..result_igg_chikv_stfd.=="98" & is.na(chikv_kenya$X.visit_h_arm_1..result_igg_chikv_stfd. & chikv_kenya$X.visit_g_arm_1..result_igg_chikv_kenya.=='0' & chikv_kenya$X.visit_h_arm_1..result_igg_chikv_kenya.=="1"),1,0)
table(chikv_kenya$blank_positive_visit_g_chikv_stfd)
chikv_kenya$repeat_repeat_visit_g_chikv_stfd<-ifelse(chikv_kenya$X.visit_g_arm_1..result_igg_chikv_stfd.=="98" & chikv_kenya$X.visit_h_arm_1..result_igg_chikv_stfd.=="98" & chikv_kenya$X.visit_g_arm_1..result_igg_chikv_kenya.=='0' & chikv_kenya$X.visit_h_arm_1..result_igg_chikv_kenya.=="1",1,0)
table(chikv_kenya$blank_positive_visit_g_chikv_stfd)

denv_kenya_subset<-subset(denv_kenya, 
       negative_blank_visit_a_denv_stfd=="1" | negative_repeat_visit_a_denv_stfd=="1" | blank_positive_visit_a_denv_stfd=="1"| blank_blank_visit_a_denv_stfd=="1"|repeat_positive_visit_a_denv_stfd=="1"| repeat_blank_visit_a_denv_stfd=="1" | repeat_repeat_visit_a_denv_stfd=="1"
       |negative_blank_visit_b_denv_stfd=="1" | negative_repeat_visit_b_denv_stfd=="1" | blank_positive_visit_b_denv_stfd=="1"| blank_blank_visit_b_denv_stfd=="1"|repeat_positive_visit_b_denv_stfd=="1"| repeat_blank_visit_b_denv_stfd=="1" | repeat_repeat_visit_b_denv_stfd=="1"
       |negative_blank_visit_c_denv_stfd=="1" | negative_repeat_visit_c_denv_stfd=="1" | blank_positive_visit_c_denv_stfd=="1"| blank_blank_visit_c_denv_stfd=="1"|repeat_positive_visit_c_denv_stfd=="1"| repeat_blank_visit_c_denv_stfd=="1" | repeat_repeat_visit_c_denv_stfd=="1"
       |negative_blank_visit_d_denv_stfd=="1" | negative_repeat_visit_d_denv_stfd=="1" | blank_positive_visit_d_denv_stfd=="1"| blank_blank_visit_d_denv_stfd=="1"|repeat_positive_visit_d_denv_stfd=="1"| repeat_blank_visit_d_denv_stfd=="1" | repeat_repeat_visit_d_denv_stfd=="1"
       |negative_blank_visit_e_denv_stfd=="1" | negative_repeat_visit_e_denv_stfd=="1" | blank_positive_visit_e_denv_stfd=="1"| blank_blank_visit_e_denv_stfd=="1"|repeat_positive_visit_e_denv_stfd=="1"| repeat_blank_visit_e_denv_stfd=="1" | repeat_repeat_visit_e_denv_stfd=="1"
       |negative_blank_visit_f_denv_stfd=="1" | negative_repeat_visit_f_denv_stfd=="1" | blank_positive_visit_f_denv_stfd=="1"| blank_blank_visit_f_denv_stfd=="1"|repeat_positive_visit_f_denv_stfd=="1"| repeat_blank_visit_f_denv_stfd=="1" | repeat_repeat_visit_f_denv_stfd=="1"
       |negative_blank_visit_g_denv_stfd=="1" | negative_repeat_visit_g_denv_stfd=="1" | blank_positive_visit_g_denv_stfd=="1"| blank_blank_visit_g_denv_stfd=="1"|repeat_positive_visit_g_denv_stfd=="1"| repeat_blank_visit_g_denv_stfd=="1" | repeat_repeat_visit_g_denv_stfd=="1"
)


chikv_kenya_subset<-subset(chikv_kenya,                            
                     negative_blank_visit_a_chikv_stfd=="1" | negative_repeat_visit_a_chikv_stfd=="1" | blank_positive_visit_a_chikv_stfd=="1"| blank_blank_visit_a_chikv_stfd=="1"|repeat_positive_visit_a_chikv_stfd=="1"| repeat_blank_visit_a_chikv_stfd=="1" | repeat_repeat_visit_a_chikv_stfd=="1"
                    |negative_blank_visit_b_chikv_stfd=="1" | negative_repeat_visit_b_chikv_stfd=="1" | blank_positive_visit_b_chikv_stfd=="1"| blank_blank_visit_b_chikv_stfd=="1"|repeat_positive_visit_b_chikv_stfd=="1"| repeat_blank_visit_b_chikv_stfd=="1" | repeat_repeat_visit_b_chikv_stfd=="1"
                    |negative_blank_visit_c_chikv_stfd=="1" | negative_repeat_visit_c_chikv_stfd=="1" | blank_positive_visit_c_chikv_stfd=="1"| blank_blank_visit_c_chikv_stfd=="1"|repeat_positive_visit_c_chikv_stfd=="1"| repeat_blank_visit_c_chikv_stfd=="1" | repeat_repeat_visit_c_chikv_stfd=="1"
                    |negative_blank_visit_d_chikv_stfd=="1" | negative_repeat_visit_d_chikv_stfd=="1" | blank_positive_visit_d_chikv_stfd=="1"| blank_blank_visit_d_chikv_stfd=="1"|repeat_positive_visit_d_chikv_stfd=="1"| repeat_blank_visit_d_chikv_stfd=="1" | repeat_repeat_visit_d_chikv_stfd=="1"
                    |negative_blank_visit_e_chikv_stfd=="1" | negative_repeat_visit_e_chikv_stfd=="1" | blank_positive_visit_e_chikv_stfd=="1"| blank_blank_visit_e_chikv_stfd=="1"|repeat_positive_visit_e_chikv_stfd=="1"| repeat_blank_visit_e_chikv_stfd=="1" | repeat_repeat_visit_e_chikv_stfd=="1"
                    #add these lines back in if there are f or g visits to include.
                    #|negative_blank_visit_f_chikv_stfd=="1" | negative_repeat_visit_f_chikv_stfd=="1" | blank_positive_visit_f_chikv_stfd=="1"| blank_blank_visit_f_chikv_stfd=="1"|repeat_positive_visit_f_chikv_stfd=="1"| repeat_blank_visit_f_chikv_stfd=="1" | repeat_repeat_visit_f_chikv_stfd=="1"
                    #|negative_blank_visit_g_chikv_stfd=="1" | negative_repeat_visit_g_chikv_stfd=="1" | blank_positive_visit_g_chikv_stfd=="1"| blank_blank_visit_g_chikv_stfd=="1"|repeat_positive_visit_g_chikv_stfd=="1"| repeat_blank_visit_g_chikv_stfd=="1" | repeat_repeat_visit_g_chikv_stfd=="1"
)

chikv<-merge(chikv_kenya_subset, chikv_stfd, by = "person_id", all=TRUE)
  #remove denv vars
  denv_vars<-grep("denv", names(chikv), value = TRUE)
  chikv<-chikv[ , !(names(chikv) %in% denv_vars)]
  #export to csv
  f <- "igm_samples_chikv_7-21-17.csv"
    write.csv(as.data.frame(chikv), f )
  
  
denv<-merge(denv_kenya_subset, denv_stfd, by = "person_id", all=TRUE)
  #remove denv vars
  chikv_vars<-grep("chikv", names(denv), value = TRUE)
  denv<-denv[ , !(names(denv) %in% chikv_vars)]
  #export to csv
    f <- "igm_samples_denv_7-21-17.csv"
    write.csv(as.data.frame(denv), f )