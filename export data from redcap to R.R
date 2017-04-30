install.packages("REDCapR")
library(REDCapR)

#export data from redcap to R (must be connected via cisco VPN)
ds <- redcap_read(
  redcap_uri  = "https://redcap.stanford.edu/api/",
  token       = "USE YOUR TOKEN HERE"
)$data

