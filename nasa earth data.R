library(httr)
library(jsonlite)

secret <- base64_enc(paste("amykrystosik", "kD2QOqkSj2fXQIE", sep = ":"))
response <- POST("https://lpdaacsvc.cr.usgs.gov/appeears/api/login", 
                 add_headers("Authorization" = paste("Basic", gsub("\n", "", secret)),
                             "Content-Type" = "application/x-www-form-urlencoded;charset=UTF-8"), 
                 body = "grant_type=client_credentials")
token_response <- prettify(toJSON(content(response), auto_unbox = TRUE))
token_response

