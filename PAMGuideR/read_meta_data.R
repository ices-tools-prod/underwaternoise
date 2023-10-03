#' Read sound measurement metadata
#' 
#' Reads the sound measurement metadata from the YAML files and adds the 
#' location name, deployment number by extracting them from the YAML file name
#' 
#' @file_path Path to folder where YAML file is.
#' @returns A list containing the sound measurement metadata.
#' @examples
#' read_meta_data("path_to_folder_with_YAML_meta_data")
read_meta_data <- function(file_path) {
  library(yaml)  # The yaml library is used to for reading the .yml metadata files
    # Make a list of all files ending with .yml
  yam_files <- list.files(file_path, include.dirs = TRUE, pattern = "*.yml$", recursive = TRUE)
  if (length(yam_files) == 0) {
      stop("No YAML metadata file in the folder.")
  }
  meta_data <- read_yaml(file.path(file_path, yam_files[1]))  # Read the meta data
  yaml_name <- substr(yam_files[1], 1, (nchar(yam_files[1]) - 4)) # Extract the file name
  #  Extract the short location name from file name
  loc_short <- paste0(substr(yaml_name, 1, 1), substr(yaml_name, nchar(yaml_name) - 5, nchar(yaml_name) - 4))
  #  Extract the deployment number from file name
  dep_numbr <- substr(yaml_name, nchar(yaml_name) - 2, nchar(yaml_name))
  meta_data[["loc_short_name"]] <- loc_short  # Add location name to meta data
  meta_data[["depl_number"]] <- dep_numbr  # Add deployment number to meta data
  meta_data
}
