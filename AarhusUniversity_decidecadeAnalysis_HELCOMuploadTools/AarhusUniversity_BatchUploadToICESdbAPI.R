# Batch upload your datafiles to the ICES database, after they have been converted into the H5 format.
#
# Emily T. Griffiths 2021-2023
# Aarhus University
# emilytgriffiths@ecos.au.dk


library(jsonlite)
library(httr)

# Set username, password, and urls.
usr <- 'your ICES name'
pw <- 'your ICES password'
url <- "https://underwaternoise.ices.dk/continuous/api/"
Token='Token'
getListFileScreenings='getListFileScreenings'
UploadFile='UploadFile'


#Get Token
r <- httr::POST(paste0(url,Token), 
                body = list(UserName = usr, password = pw),
                encode = "form", verbose())



jsonlite::prettify(httr::content(r, "text"))
tkn=jsonlite::fromJSON(content(r, "text"), simplifyVector = FALSE)

## Get the file list of all the files to be uploaded.
files=list.files('O:/Tech_MSFD-deskriptor11-Danmark/ICES database/ICES R CODE/testingh5 from ICES', full.names = TRUE)

for (p in 1:length(files)){
  r2=POST(url=paste0(url,UploadFile), body = list(fileToUpload = httr::upload_file(files[p])),
          httr::add_headers('Authorization' = paste("Bearer", tkn$result$token, sep = " ")))
}

##  For one file to test -- Do not need to run after loop.

r2=POST(url=paste0(url,UploadFile), body = list(fileToUpload = httr::upload_file(files[1])),
          httr::add_headers('Authorization' = paste("Bearer", tkn$result$token, sep = " ")))

