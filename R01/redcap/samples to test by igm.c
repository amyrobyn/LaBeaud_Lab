chikv_kenya_subset <-chikv_kenya_subset[!sapply(chikv_kenya_subset, function (x) all(is.na(x) | x == ""| x == "NA"))]
chikv_stfd <-chikv_stfd[!sapply(chikv_stfd, function (x) all(is.na(x) | x == ""| x == "NA"))]
chikv<-rbind.fill(chikv_kenya_subset, chikv_stfd)

n_occur <- data.frame(table(chikv$person_id))
dup_chikv<-chikv[chikv$person_id %in% n_occur$Var1[n_occur$Freq > 1],]

#combine rows and use first non missing values over duplicate person_id into one row. 
chikv<-chikv %>%
  group_by(person_id) %>%
  summarise_each(funs(ifelse(sum(is.na(.)==FALSE)==0, NA, .[which(is.na(.)==FALSE)])), matches("[A-Z]{1}"))


#remove denv vars
denv_vars<-grep("denv", names(chikv), value = TRUE)
chikv<-chikv[ , !(names(chikv) %in% denv_vars)]
#order the variables by assay and visit
#order alphabetically 
chikv<-chikv[,order(colnames(chikv))]
#order igg first
chikv<-chikv[order(-(grepl('result_igg_chikv_kenya', names(chikv)))+1L)]
chikv<-chikv[order(-(grepl('result_igg_chikv_stfd', names(chikv)))+1L)]

#export to csv
f <- "igm_samples_chikv_7-21-17.csv"
write.csv(as.data.frame(chikv), f )

denv_kenya_subset <-denv_kenya_subset[!sapply(denv_kenya_subset, function (x) all(is.na(x) | x == ""| x == "NA"))]
denv_stfd <-denv_stfd[!sapply(denv_stfd, function (x) all(is.na(x) | x == ""| x == "NA"))]
denv<-rbind.fill(denv_kenya_subset, denv_stfd)

n_occur <- data.frame(table(denv$person_id))
dup_denv<-denv[denv$person_id %in% n_occur$Var1[n_occur$Freq > 1],]
denv<-denv %>%
  group_by(person_id) %>%
  summarise_each(funs(ifelse(sum(is.na(.)==FALSE)==0, NA, .[which(is.na(.)==FALSE)])), matches("[A-Z]{1}"))

#remove denv vars
chikv_vars<-grep("chikv", names(denv), value = TRUE)
denv<-denv[ , !(names(denv) %in% chikv_vars)]
#order the variables by assay and visit
#order alphabetically 
denv<-denv[,order(colnames(denv))]
#order igg first
denv<-denv[order(-(grepl('result_igg_denv_kenya', names(denv)))+1L)]
denv<-denv[order(-(grepl('result_igg_denv_stfd', names(denv)))+1L)]
#export to csv
R01_lab_results_wide <-R01_lab_results_wide[!sapply(R01_lab_results_wide, function (x) all(is.na(x) | x == ""| x == "NA"))]

f <- "igm_samples_denv_7-21-17.csv"
write.csv(as.data.frame(denv), f )
