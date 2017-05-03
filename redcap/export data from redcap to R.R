#install.packages("REDCapR")
library(REDCapR)

Redcap.token <- readLines("Redcap.token.txt") # Read API token from folder
REDcap.URL  <- 'https://redcap.stanford.edu/api/'


#export data from redcap to R (must be connected via cisco VPN)
ds <- redcap_read(
  redcap_uri  = REDcap.URL,
  token       = Redcap.token
)$data

table(ds$result_igg_denv_stfd, ds$result_igg_denv_kenya)
table(ds$result_igg_chikv_stfd, ds$result_igg_chikv_kenya)