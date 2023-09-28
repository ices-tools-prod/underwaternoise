## Set the user

user <- "lalander"

## Gets javascript web token
jwt <- token(user)
#passwd: uvqi8178UV
## Uploads a (test) file

## <- read.csv("Z:/KABAM/Resultat/hdf5_files_ices/hdf5/Hon1/ICES_SE_13076_210801_210816.h5")
##UploadFile(data, jwt)

## Loops through a list of files and uploads them using the API

## NMS
files <- list.files(path = "Z:/KABAM/Resultat/hdf5_files_ices/hdf5/NMS0/",pattern = "^(.*)h5$",full.names = TRUE)
files
lapply(files[1:22], UploadFile, jwt = jwt)
# # NMS1
files <- list.files(path = "Z:/KABAM/Resultat/hdf5_files_ices/hdf5/NMS1/",pattern = "^(.*)h5$",full.names = TRUE)
files
lapply(files[6:20], UploadFile, jwt = jwt)
lapply(files[21:27], UploadFile, jwt = jwt)# 

# ## Sun
files <- list.files(path = "Z:/KABAM/Resultat/hdf5_files_ices/hdf5/Sun1/",pattern = "^(.*)h5$",full.names = TRUE)
files
lapply(files[21:33], UploadFile, jwt = jwt)
# 
files <- list.files(path = "Z:/KABAM/Resultat/hdf5_files_ices/hdf5/Sun2/",pattern = "^(.*)h5$",full.names = TRUE)
files
lapply(files[17:35], UploadFile, jwt = jwt)

## Hon
files <- list.files(path = "Z:/KABAM/Resultat/hdf5_files_ices/hdf5/Hon1/",pattern = "^(.*)h5$",full.names = TRUE)
files
lapply(files[24:36], UploadFile, jwt = jwt)
lapply(files[45:50], UploadFile, jwt = jwt)
# Push files!

files <- list.files(path = "Z:/KABAM/Resultat/hdf5_files_ices/hdf5/Hon2/",pattern = "^(.*)h5$",full.names = TRUE)
files
lapply(files[1:6], UploadFile, jwt = jwt)
lapply(files[14:20], UploadFile, jwt = jwt)
##Needs to be pushed
#  

## Gets the list of file screenings 

list=screenings <- getListFileScreenings(jwt)
