inp_fold <- "/home/mirko/CloudStation/HELCOM_Blues/PAM_hdf5/UNDERWATER_NOISE_MEASUREMENTS_DATA/HYDROPHONE DATA MAR2014/"


source("calc_tol_spl.R")
PAM_out_list <- calc_tol_spl(inp_fold)

source("write_hdf_file.R")
out_fold <- "/home/mirko/CloudStation/HELCOM_Blues/PAM_hdf5/PAM_output_R"
write_hdf_file(PAM_out_list, out_fold)
