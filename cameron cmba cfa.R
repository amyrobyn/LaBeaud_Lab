setwd("C:/Users/amykr/Box Sync/Amy Krystosik's Files/Data Managment/redcap/ro1 lab results long")
load("R01_lab_results 2018-03-21 .rda")  

ids.you.want.to.keep <- c("CF0433", "CF0440", "CF0442", "CF0443", "CF0444", "RF0404", "RF0436","RF0528", "RF0529")
subset_dataframe<-subset(R01_lab_results, (c(person_id) %in% ids.you.want.to.keep))
subset_dataframe$person_id <- gsub('CF0433', 'RF0433', subset_dataframe$person_id)
subset_dataframe$person_id <- gsub('CF0440', 'RF0440', subset_dataframe$person_id)
subset_dataframe$person_id <- gsub('CF0442', 'RF0442', subset_dataframe$person_id)
subset_dataframe$person_id <- gsub('CF0443', 'RF0443', subset_dataframe$person_id)
subset_dataframe$person_id <- gsub('CF0444', 'RF0444', subset_dataframe$person_id)
subset_dataframe$person_id <- gsub('RF0404', 'CF0404', subset_dataframe$person_id)
subset_dataframe$person_id <- gsub('RF0436', 'CF0436', subset_dataframe$person_id)
subset_dataframe$person_id <- gsub('RF0528', 'CF0528', subset_dataframe$person_id)
subset_dataframe$person_id <- gsub('RF0529', 'CF0529', subset_dataframe$person_id)

table(subset_dataframe$person_id)

write.csv(as.data.frame(subset_dataframe), "subset_dataframe.csv")

Redcap.token <- readLines("Redcap.token.R01.txt") # Read API token from folder
REDcap.URL  <- 'https://redcap.stanford.edu/api/'
library(REDCapR)


redcap_write(subset_dataframe, batch_size = 1, interbatch_delay = 2,
             continue_on_error = FALSE, redcap_uri=REDcap.URL, token=Redcap.token, verbose = TRUE,
             config_options = NULL)