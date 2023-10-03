write_hdf_file <- function(PAM_out_list, out_folder = getwd()) {
    # Create file name
    meta_data <- PAM_out_list$meta_data
    version <- 1.0
    beg_date <- substr(meta_data$Deployment_time, 1, (nchar(meta_data$Deployment_time)-5))
    end_date <- substr(meta_data$Recovery_time, 1, (nchar(meta_data$Recovery_time)-5))
    out_file_name <- paste0("ICES_HELCOM_", meta_data$StationCode, "_", 
                            meta_data$loc_short_name, "_", meta_data$depl_number, 
                            "_", beg_date, "_", end_date, "_v",
                            sprintf("%02i", version), ".h5")
    out_file_name <- file.path(out_folder, out_file_name)
    while (file.exists(out_file_name)) {
        version <- version + 1
        out_file_name <- paste0("ICES_HELCOM_", meta_data$StationCode, "_", 
                                meta_data$loc_short_name, "_", meta_data$depl_number, 
                                "_", beg_date, "_", end_date, "_v",
                                sprintf("%02i", version), ".h5")
        out_file_name <- file.path(out_folder, out_file_name)
    }
    # Create output file
    library(rhdf5)

    h5createFile(out_file_name)
    
    # Create and fill in the Data folder in file
    h5createGroup(out_file_name,"Data")
    
    time_chr <- as.array(paste0(strftime(PAM_out_list$time_vec, format = "%Y-%m-%d %H:%M:%S"), "Z"))
    h5write(time_chr, out_file_name,"Data/DateTime")
    h5write(t(PAM_out_list$tol_mat), out_file_name,"Data/LeqMeasurementsOfChannel1")
    
    # Create and fill in the FileInformation folder in file
    h5createGroup(out_file_name,"FileInformation")
    
    h5write(as.array(paste0(format(Sys.time(), "%Y-%m-%d %H:%M", tz = "UTC"), "Z")), out_file_name,"FileInformation/CreationDate")
    h5write(as.array(time_chr[1]), out_file_name,"FileInformation/StartDate")
    h5write(as.array(time_chr[length(time_chr)]), out_file_name,"FileInformation/EndDate")
    h5write(as.array(meta_data$Contact), out_file_name,"FileInformation/Contact")
    h5write(as.array(meta_data$CountryCode), out_file_name,"FileInformation/CountryCode")
    h5write(as.array(meta_data$Email), out_file_name,"FileInformation/Email")
    h5write(as.array(as.integer(meta_data$Institution)), out_file_name,"FileInformation/Institution")
    h5write(as.array(as.integer(meta_data$StationCode)), out_file_name,"FileInformation/StationCode")
    
    # Create and fill in the Metadata folder in file
    h5createGroup(out_file_name,"Metadata")
    
    h5write(as.array(as.integer(length(time_chr))), out_file_name,"Metadata/MeasurementTotalNo")
    freqs_count <- as.integer(length(PAM_out_list$nom_freqs))
    h5write(as.array(freqs_count), out_file_name,"Metadata/FrequencyCount")
    h5write(as.array(PAM_out_list$nom_freqs), out_file_name,"Metadata/FrequencyIndex")
    
    # AveragingTime <- names(which.max(table(PAM_out_list$time_vec[-1] - PAM_out_list$time_vec[-(length(PAM_out_list$time_vec)-1)])))
    h5write(as.array(as.integer(meta_data$AveragingTime)), out_file_name,"Metadata/AveragingTime")
    h5write(as.array(meta_data$CalibrationDateTime), out_file_name,"Metadata/CalibrationDateTime")
    h5write(as.array(meta_data$CalibrationProcedure), out_file_name,"Metadata/CalibrationProcedure")
    h5write(as.array(1L), out_file_name,"Metadata/ChannelCount")
    h5write(as.array(meta_data$Comments), out_file_name,"Metadata/Comments")
    h5write(as.array(meta_data$Comments), out_file_name,"Metadata/Comments")
    
    library(uuid)
    h5write(as.array(UUIDgenerate()), out_file_name,"Metadata/DataUUID")
    h5write(as.array(sprintf("%2i.0", version)), out_file_name,"Metadata/DatasetVersion")
    h5write(as.array("Hz"), out_file_name,"Metadata/FrequencyUnit")
    h5write(as.array(meta_data$HydrophoneSerialNumber), out_file_name,"Metadata/HydrophoneSerialNumber")
    h5write(as.array(meta_data$HydrophoneType), out_file_name,"Metadata/HydrophoneType")
    h5write(as.array(meta_data$MeasurementHeight), out_file_name,"Metadata/MeasurementHeight")
    h5write(as.array(meta_data$MeasurementPurpose), out_file_name,"Metadata/MeasurementPurpose")
    h5write(as.array(meta_data$MeasurementSetup), out_file_name,"Metadata/MeasurementSetup")
    h5write(as.array('SPL'), out_file_name,"Metadata/MeasurementUnit")
    h5write(as.array('MER'), out_file_name,"Metadata/ProcessingAlgorithm")
    h5write(as.array(meta_data$RecorderSerialNumber), out_file_name,"Metadata/RecorderSerialNumber")
    h5write(as.array(meta_data$RecorderType), out_file_name,"Metadata/RecorderType")
    h5write(as.array(meta_data$RigDesign), out_file_name,"Metadata/RigDesign")
    
    H5close()
}