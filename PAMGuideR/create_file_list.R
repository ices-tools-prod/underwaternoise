#' Create list of sound files in folder
#'
#' Creates a list of all sound files of certain file_type not from folders
#' Deployment, Recovery, Calibration, Error, and Trash where files before deployment,
#' after recovery, during calibration and otherwise erroneous are stored.
#'
#' @file_type The file type to be searched for mostly "*.wav$" or ".flac$"
#' @file_path Path to folder where the sound files are located.
#' @returns A list sound full sound file paths from one deployment.
create_file_list <- function(file_type, file_path) {
  files_i <- list.files(
    path = file_path, pattern = file_type, all.files = TRUE,
    recursive = TRUE, include.dirs = TRUE
  )
  rem_pattern <- ".*Deployment.*|.*Recovery.*|.*Calibration.*|.*Error.*|.*Trash.*"
  files_i <- files_i[!grepl(rem_pattern, files_i)]
  if (length(files_i) == 0) {
      stop("No sound files of type in the given folder.")
  }
  files_i
}