setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/ASTMH 2017 abstracts/priyanka- fogarty nd")
complications<-read.csv("complications.csv")
complications$list_pregnancy_illness_category2<-complications$list_pregnancy_illness_category
complications$list_pregnancy_illness_category <- gsub("CHIKV|chikv|chikv|CHIKV", "", complications$list_pregnancy_illness_category)
complications$child_compl<-paste(complications$specify_after_birth_problems_category, complications$specify_first_few_months_category, sep=" ")
complications$mother_compl<-paste(complications$list_pregnancy_illness_category, complications$specify_complications_category, sep=" ")

# complications$list_pregnancy_illness_category ---------------------------
complications$list_pregnancy_illness_category<-tolower(complications$list_pregnancy_illness_category)

lev <- levels(factor(complications$list_pregnancy_illness_category))
lev <- unique(unlist(strsplit(lev, " ")))
mnames <- gsub(" ", "_", paste("preg_ill", lev, sep = "_"))
result <- matrix(data = "0", nrow = length(complications$list_pregnancy_illness_category), ncol = length(lev))
char.aic_symptom <- as.character(complications$list_pregnancy_illness_category)
for (i in 1:length(lev)) {
  result[grep(lev[i], char.aic_symptom, fixed = TRUE), i] <- "1"
}
result <- data.frame(result, stringsAsFactors = TRUE)
colnames(result) <- mnames
complications <- cbind(complications,result)

# complications$specify_complications_category ---------------------------
complications$specify_complications_category<-tolower(complications$specify_complications_category)

lev <- levels(factor(complications$specify_complications_category))
lev <- unique(unlist(strsplit(lev, " ")))
mnames <- gsub(" ", "_", paste("compl_", lev, sep = "_"))
result <- matrix(data = "0", nrow = length(complications$specify_complications_category), ncol = length(lev))
char.aic_symptom <- as.character(complications$specify_complications_category)
for (i in 1:length(lev)) {
  result[grep(lev[i], char.aic_symptom, fixed = TRUE), i] <- "1"
}
result <- data.frame(result, stringsAsFactors = TRUE)
colnames(result) <- mnames
complications <- cbind(complications,result)

# complications$specify_after_birth_problems_category ---------------------------
complications$specify_after_birth_problems_category<-tolower(complications$specify_after_birth_problems_category)
complications$specify_after_birth_problems_category <- gsub('seizures', 'seizure', complications$specify_after_birth_problems_category)

lev <- levels(factor(complications$specify_after_birth_problems_category))
lev <- unique(unlist(strsplit(lev, " ")))
mnames <- gsub(" ", "_", paste("abp_", lev, sep = "_"))
result <- matrix(data = "0", nrow = length(complications$specify_after_birth_problems_category), ncol = length(lev))
char.aic_symptom <- as.character(complications$specify_after_birth_problems_category)
for (i in 1:length(lev)) {
  result[grep(lev[i], char.aic_symptom, fixed = TRUE), i] <- "1"
}
result <- data.frame(result, stringsAsFactors = TRUE)
colnames(result) <- mnames
complications <- cbind(complications,result)

# complications$specify_first_few_months_category ---------------------------
complications$specify_first_few_months_category<-tolower(complications$specify_first_few_months_category)

lev <- levels(factor(complications$specify_first_few_months_category))
lev <- unique(unlist(strsplit(lev, " ")))
mnames <- gsub(" ", "_", paste("ffm_", lev, sep = "_"))
result <- matrix(data = "0", nrow = length(complications$specify_first_few_months_category), ncol = length(lev))
char.aic_symptom <- as.character(complications$specify_first_few_months_category)
for (i in 1:length(lev)) {
  result[grep(lev[i], char.aic_symptom, fixed = TRUE), i] <- "1"
}
result <- data.frame(result, stringsAsFactors = TRUE)
colnames(result) <- mnames
complications <- cbind(complications,result)

# complications$mother_compl---------------------------
complications$mother_compl<-tolower(complications$mother_compl)

lev <- levels(factor(complications$mother_compl))
lev <- unique(unlist(strsplit(lev, " ")))
mnames <- gsub(" ", "_", paste("mother_compl_", lev, sep = "_"))
result <- matrix(data = "0", nrow = length(complications$mother_compl), ncol = length(lev))
char.aic_symptom <- as.character(complications$mother_compl)
for (i in 1:length(lev)) {
  result[grep(lev[i], char.aic_symptom, fixed = TRUE), i] <- "1"
}
result <- data.frame(result, stringsAsFactors = TRUE)
colnames(result) <- mnames
complications <- cbind(complications,result)
# complications$child_compl---------------------------
complications$child_compl<-tolower(complications$child_compl)

lev <- levels(factor(complications$child_compl))
lev <- unique(unlist(strsplit(lev, " ")))
mnames <- gsub(" ", "_", paste("child_compl_", lev, sep = "_"))
result <- matrix(data = "0", nrow = length(complications$child_compl), ncol = length(lev))
char.aic_symptom <- as.character(complications$child_compl)
for (i in 1:length(lev)) {
  result[grep(lev[i], char.aic_symptom, fixed = TRUE), i] <- "1"
}
result <- data.frame(result, stringsAsFactors = TRUE)
colnames(result) <- mnames
complications <- cbind(complications,result)

# add up copmlications ----------------------------------------------------
names<-names(complications[ , grepl( "preg_ill_|ffm__|compl__|abp__|child_compl_|mother_compl_" , names( complications ) ) ])
  
as.numeric.factor <- function(x) {as.numeric(levels(x))[x]}
complications[names] <- sapply(complications[names],as.numeric.factor)
sapply(complications, class)

complications$preg_ill_sum <- as.integer(rowSums(complications[ , grep("preg_ill_" , names(complications))]))
complications$ffm__sum <- as.integer(rowSums(complications[ , grep("ffm__" , names(complications))]))
complications$compl__sum <- as.integer(rowSums(complications[ , grep("compl__" , names(complications))]))
complications$abp__sum <- as.integer(rowSums(complications[ , grep("abp__" , names(complications))]))
complications$child__compl_sum <- as.integer(rowSums(complications[ , grep("child_compl__" , names(complications))]))
complications$mother__compl_sum <- as.integer(rowSums(complications[ , grep("mother_compl__" , names(complications))]))

table(complications$abp__sum)
table(complications$compl__sum)
table(complications$ffm__sum)
table(complications$preg_ill_sum)

table(complications$child__compl_sum)
table(complications$mother__compl_sum)

#export ---------------------------
f <- "copmlications_dum.csv"
write.csv(as.data.frame(complications), f )#export to csv
save(complications,file="complications.dum.rda")    #save as r data frame for use in other analysis. 

#combine baby and mom outcomes for complications.
#reorder the symptoms vars

