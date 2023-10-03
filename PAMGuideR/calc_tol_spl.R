#' Wrapper function for running PAMGuide for TOL calculation
#' 
#' This function calculates the 1/3 octave band SPLs from a sound monitoring
#' deployment's sound files and composes the time
#'
#' @file_path The path to the folder where all sound files from sound monitoring
#' are located along with the yaml metadata file
#' @returns List that contains: 
#' 1. matrix of 1/3 octave SPL values;
#' 2. vector with associated time stamps;
#' 3. vector with nominal 1/3 octave band center frequencies;
#' 4. list with all meta data
calc_tol_spl <- function(file_path) {
  source("read_meta_data.R")  # Read meta data from YAML meta data file
  meta_data <- read_meta_data(file_path)

  source("create_file_list.R")  # Create a list of all sound file paths
  file_type <- "*.wav$"  # Sound file type to be searched
  file_list <- create_file_list(file_type, file_path)

  source("create_pam_input.R")  # Create list with inp params for PAMGuide function
  pam_input <- create_pam_input(file.path(file_path, file_list[1]), meta_data$SensitivityE2)
  meta_data[["AveragingTime"]] <- as.integer(pam_input$N / pam_input$Fs)

  source("PAMGuide.R")
  # Run PAMGuide on all the files one-by-one
  for (i in 1:length(file_list)) {
    message("File ", i, " of ", length(file_list))
    file_i <- file_list[i]
    pamg_out_matrix <- PAMGuide(file.path(file_path, file_i),
      atype = pam_input$atype, plottype = pam_input$plottype,
      envi = pam_input$envi, calib = pam_input$calib, ctype = pam_input$ctype,
      Si = pam_input$Si, Mh = pam_input$Mh, G = pam_input$G, vADC = pam_input$vADC,
      r = pam_input$r, N = pam_input$N, winname = pam_input$winname, lcut = pam_input$lcut,
      hcut = pam_input$hcut, timestring = pam_input$timestring, outdir = pam_input$outdir,
      outwrite = pam_input$writeout, disppar = pam_input$disppar, welch = pam_input$welch,
      chunksize = pam_input$chunksize, linlog = pam_input$linlog
    )

    # Create output time vector for one processed file
    last_file_sep <- max(unlist(gregexpr(.Platform$file.sep, file_i))) # Extract index of last file separator
    if (last_file_sep == -1) {
        file_name <- file_i  # If the file_i doesn't have any separators it's already the file name
    }
    else {
        file_name <- substr(file_i, last_file_sep, nchar(file_i)) # Extract the file name from longer path    
    }

    source("extr_time_frm_fname.R")  # As different recorders have time added differently to file name
    # The function extracts datetime recorder specifically 
    file_start_t <- extr_time_frm_fname(file_name, meta_data$RecorderType, meta_data$Data_timezone)
    file_time_vec <- file_start_t + pamg_out_matrix[-1, 1]
    
    tol_mat_i <- pamg_out_matrix[-1, -1]
    if (i == 1) {
      # Create nominal 1/3 octave band frequencies vector for output
      freq_vec <- pamg_out_matrix[1, -1]  # 1/3 oct. band center frequencies vector
      freq_table <- read.csv("Third_octs.txt", sep = "\t", header = TRUE)  # Read 1/3 oct. band table where nominal freqeuncies are located

      start_ind <- which.min(abs(freq_vec[1] - freq_table$Base_10_Calculated_Frequency))
      nom_freqs <- as.integer(freq_table$Nominal_Frequency[start_ind:(start_ind + length(freq_vec))])

      prev_len <- 0  # In first iteration previous length of output matrix equals 0
      # For memory allocation create empty matrix for all TOL data
      tol_mat_large <- matrix(0.0, nrow = nrow(tol_mat_i) * length(file_list), ncol = ncol(tol_mat_i))
      # In first iteration create larger time vector where in later steps will be appended
      time_vec_large <- file_time_vec
    }

    # Add PAM outputs into single matrix
    tol_mat_large[(prev_len + 1):(prev_len + nrow(tol_mat_i)), ] <- tol_mat_i
    prev_len <- prev_len + nrow(tol_mat_i)
    
    if (i != 1) {  # If not first iteration add time to longer time vector
      time_vec_large <- c(time_vec_large, file_time_vec)
    }
  }
  # Compose the output list
  list(
    "tol_mat" = tol_mat_large, "time_vec" = time_vec_large,
    "nom_freqs" = nom_freqs, "meta_data" = meta_data, "pam_input" = pam_input
  )
}