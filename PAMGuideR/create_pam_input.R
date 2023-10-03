#' Creates input parameters list for PAMGuide function
#'
#' Here are listed all the relevant input parameters for the PAMGuide function 
#' as a list. The function adds sensitivity and extracts parameters from first 
#' files. 
#'
#' @first_file_path The full path of one of the sound files to be processed
#' @SensitivityE2E The end-to-end sensitivity of the recording system and hydrophone
#' @returns List of input parameters for the PAMGuide function
create_pam_input <- function(first_file_path, SensitivityE2E) {
  file_i_info <- tuneR::readWave(first_file_path, header = TRUE)
  list(
    atype = "TOL", # TOL - third octave levels calculated
    batch = 0,  # 0 - no batch processing
    calib = 1,
    chunksize = "",
    ctype = "EE",  # EE - end to end calibration
    disppar = 1,
    envi = "Wat", # Wat - medium is water not air
    Fs = file_i_info$sample.rate, # Sample rate
    G = 0, # Gain
    hcut = file_i_info$sample.rate / 2, # High frequency limit
    lcut = 1, # Low frequency limit
    linlog = 0, # Linear logarithmic scale when plotting
    metadir = "",
    Mh = "",
    plottype = "None",
    N = file_i_info$sample.rate * 20, # 20 second time window analysis
    r = 0, # Overlap of data segments
    Si = SensitivityE2E, # End to end sensitivity
    timestring = "", # Time string for retrieving datetime from filename 'yymmddHHMMSS'
    vADC = "",  # Probably maximum voltage amplitude that will be digitised to the maximum amplitude in bit values
    welch = "",
    winname = "Rectangular", # Rectangular window function used
    writeout = 0,
    outdir = ""
  )
}