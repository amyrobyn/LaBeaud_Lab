setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/ASTMH 2017 abstracts/priyanka- fogarty nd")
complications<-read.csv("complications.csv")

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

names<-names(complications[ , grepl( "preg_ill_|ffm__|compl__|abp__" , names( complications ) ) ])

as.numeric.factor <- function(x) {as.numeric(levels(x))[x]}
complications[names] <- sapply(complications[names],as.numeric.factor)
sapply(complications, class)

complications$preg_ill_sum <- as.integer(rowSums(complications[ , grep("preg_ill_" , names(complications))]))
complications$ffm__sum <- as.integer(rowSums(complications[ , grep("ffm__" , names(complications))]))
complications$compl__sum <- as.integer(rowSums(complications[ , grep("compl__" , names(complications))]))
complications$abp__sum <- as.integer(rowSums(complications[ , grep("abp__" , names(complications))]))

table(complications$abp__sum)
table(complications$compl__sum)
table(complications$ffm__sum)
table(complications$preg_ill_sum)

#export ---------------------------
f <- "copmlications_dum.csv"
write.csv(as.data.frame(complications), f )#export to csv
save(complications,file="complications.dum.rda")    #save as r data frame for use in other analysis. 

