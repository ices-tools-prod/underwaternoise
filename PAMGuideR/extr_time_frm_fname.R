extr_time_frm_fname <- function(file_name, rec_type, time_zone) {
  if (rec_type == "WSM2M") {
    file_time_chr <- substr(file_name, (nchar(file_name) - 18), (nchar(file_name) - 4))
    d_format <- "%Y%m%d_%H%M%S"
  }
  if (rec_type == "RTLSP") {
      file_time_chr <- substr(file_name, (nchar(file_name) - 22), (nchar(file_name) - 4))
      d_format <- "%Y%m%d_%H%M%S"
  }
  if (rec_type == "OIS5S") {
      file_time_chr <- substr(file_name, (nchar(file_name) - 22), (nchar(file_name) - 4))
      d_format <- "%Y%m%d_%H%M%S"
  }
  if (time_zone == "UTC") {
    as.POSIXct(file_time_chr, tz = time_zone, format = d_format)
  } else {
    # TODO add possibility to convert time to UTC when timezone not UTC
    stop("Time zone not UTC please write conversion")
  }
}
