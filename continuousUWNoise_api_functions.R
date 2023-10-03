## Create the url
uri <- function(service, ...) {

  uri <-
    paste0(
      "https://underwaternoise.ices.dk/continuous/api/",
      service
    )

  uri <- httr::parse_url(uri)
  uri$query <- list(...)
  uri <- httr::build_url(uri)
  uri
}

## make a get request with a jwt token
get_uw <- function(service, jwt, ...) {
  res <-
    httr::GET(
      uri(service, ...),
      httr::add_headers(Authorization = paste("Bearer", jwt))
    )

  # return list of submissions
  httr::content(res, simplifyVector = TRUE)
}


## Get a token
token <- function(user) {
  res <-
    httr::POST(
      uri("token"),
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

## Upload a file
UploadFile <- function(fname, jwt) {
  file <- httr::upload_file(fname)

  res <-
    httr::POST(
      uri("UploadFile"),
      httr::add_headers(Authorization = paste("Bearer", jwt)),
      body = list(fileToUpload = file)
    )

  message(httr::content(res))

  # return response
  res
}


## Get a list of file screenings
getListFileScreenings <- function(jwt) {
  get_uw("getListFileScreenings", jwt)
}

## Get a list of screening file details
getListOfScreeningFilesDetails <- function(jwt) {
  get_uw("getListOfScreeningFilesDetails", jwt)
}

## Get screening messages per file ID
getScreeningSessionMessages <- function(id, jwt) {
  get_uw(paste0("getScreeningSessionMessages/", id), jwt)
}



## Push file to database per file ID
pushFileDatabase <- function(id, jwt) {
  res <-
    httr::POST(
      uri(paste0("pushFileDatabase/", id)),
      httr::add_headers(Authorization = paste("Bearer", jwt))
    )

  message(httr::content(res))

  # return response
  res
}
