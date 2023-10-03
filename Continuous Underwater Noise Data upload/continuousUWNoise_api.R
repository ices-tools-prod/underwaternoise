library(dplyr)

## Set the user

user <- ""


## Gets javascript web token
jwt <- token(user)

## Uploads a file

file <- ""
res <- UploadFile(file, jwt)

## Loops through a list of files and uploads them using the API

files <- dir()
lapply(files, UploadFile, jwt = jwt)


## Gets the list of file screenings

screenings <- getListFileScreenings(jwt)

screeningDetails <- getListOfScreeningFilesDetails(jwt)


## Get screening messages per session

id <- screenings$datsuSessionID

getScreeningSessionMessages(id, jwt)

## Filter files that are clear for upload and that haven't been uploaded yet

filesToUpload <- screeningDetails %>% filter(fileValidForUpload == TRUE & fileUploadedToDB == FALSE)

## Push ok-ed files to the database 

res <- lapply(filesToUpload$tblFileScreeningID, pushFileDatabase, jwt = jwt)
