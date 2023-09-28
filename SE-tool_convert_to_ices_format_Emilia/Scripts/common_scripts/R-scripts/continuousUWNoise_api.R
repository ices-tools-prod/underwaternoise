## Install HDF5 package

#install.packages("BiocManager")
#BiocManager::install("rhdf5")

## Load the HDF5 library
library(rhdf5)

## Set the user

user <- "joanar"

## Gets javascript web token
jwt <- token(user)

## Screens a file

path <- "P:/DP1/projects/Underwaternoise/Continuous/Format/First version/ICES-Continuous-Underwater-Noise-format/Sample.h5"
ScreenFile(path, jwt)

## Loops through a list of files and uploads them using the API

# files <- dir()
# lapply(files, UploadFile, jwt = jwt)


## Gets the list of file screenings 

screenings <- getListFileScreenings(jwt)
