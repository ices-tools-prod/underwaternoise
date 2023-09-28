## Create the url

get_uri <- function(service) {
  paste0(
    "https://underwaternoise.ices.dk/continuous/api/",
    service
  )
}

## Get a token
token <- function(user) {
  res <-
    httr::POST(
      get_uri("token"),
      body =
        list(
          UserName = user,
          password = askpass::askpass(paste("Enter password for user,", user, ":"))
        ),
      encode = "form"
    )
  
  res_content <- httr::content(res)
  
  res_content$result$token
}

## Get a list of file screenings 
getListFileScreenings <- function(jwt) {
  res <-
    httr::GET(
      get_uri("getListFileScreenings"),
      httr::add_headers(Authorization = paste("Bearer", jwt))
    )
  
  # return list of submissions
  httr::content(res)
}

## Upload a file
UploadFile <- function(fname, jwt) {
  file <- httr::upload_file(fname)
  
  res <-
    httr::POST(
      get_uri("UploadFile"),
      httr::add_headers(Authorization = paste("Bearer", jwt)),
      body = list(fileToUpload = file)
    )
  
  message(httr::content(res))
  
  # return response
  res
}
