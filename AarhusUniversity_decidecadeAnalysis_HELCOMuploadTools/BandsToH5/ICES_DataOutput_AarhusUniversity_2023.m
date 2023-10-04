% Formated for the decidecade bands (TOLs) for HELCOM ICES database.

%
% Current Version by Emily T. Griffiths, 2020-2023.
% Aarhus University
% emilytgriffiths@ecos.au.dk
%

% Read in metadata for all files you would like to process.
load('AllMetaData_AUexample.mat');

% If, like me, you store all of the metadata for multiple deployments in
% the same project in one metadata file or database, you can use the script below to
% filter for date.  Here, I am looking for all files in 2021 and after
% (which is the date of our sample file). This is because the deployment
% date is part of the deployment ID.  You will need to adjust this section
% to match your own naming convention. 
depNames = fieldnames(AllMetaData_AUexample);
depTimes = datetime(extractAfter(depNames, '_'), 'InputFormat','yyyyMMdd');
forProcessing = depTimes < datetime(2021,01,01);
procData = rmfield(AllMetaData_AUexample, depNames(forProcessing));
fn = string(fieldnames(procData));

%These are the ICES ID codes for the different Danish Noise Monitoring
%stations. These will be different for you. Please write to ICES to ensure
%your stations have been properly loaded into their database, and have
%codes.
stationlist=[ "12870" "12869" "12868" "12867" "12866" "12865" "12864" "12863",
    "DKMst201" "DKMst105" "DKMst104" "DKMst103" "DKMst038" "DKMst037" "DKMst036" "DKMst035"]';


%%  Start Formatting!
   
for d = 1:numel(fn)
    deployment = procData.(fn(d)); %struct with one deployment's metadata.
    cd(deployment.outputLocation)

    an=dir(['./TOLdB_Allnoise_CL' num2str(round(deployment.ClipLevel)) '*' deployment.logger '.mat']);  % This script grabs the correct datafile, based on the provided logger number and clip level. For example, in this deployment, it was deployed alongside a ST00 (see comment). This line of code ensures we select the correct logger for processing based on the logger number and clip level.
    load([an.folder '\' an.name]);  % Load in data. A sample dataset is not provided.
    depSite = deployment.depSite;

    disp(['Processing ' num2str(d) ' of ' num2str(numel(fn)) ' - ' deployment.depID ' at ' datestr(now,'yyyy-mm-dd HH:MM:SS')]) % Status read out. 

    % This loop extracts all of the processed data from the struct, and
    % converts it into an array/table that can be easily ported into the
    % ICES standard.
    LeqMeasurementsOfChannel1 = []; % We do not have deployments with multiple channels uploaded to this database. If you used a multichannel device, you will need to run this loop per channel.
    DaTi=[];
    for  i = 1:length(allnoise.TOLdB)  
        data = allnoise.TOLdB(i);
        LeqMeasurementsOfChannel1 = vertcat(LeqMeasurementsOfChannel1, data{:});
        ts = allnoise.timestamps(i);
        %Reformat datetime data to format: 'YYYY-MM-DD HH:MM[:SS]'
        tformat=datestr(ts{:},'yyyy-mm-dd HH:MM:SS');
        DaTi=vertcat(DaTi, tformat);
    end
    
    dDT=datetime(DaTi, 'InputFormat','yyyy-MM-dd HH:mm:ss');
    
    
    %% IR data
    Email=deployment.sendto ;                                                                           %char(50)			E-mail of the author Creator of the HDF5 file/ who holds responsibility for data QA and creation of the submited hdf5 file.	
    %StartDate=char(DateTime(1,:))  ;                                                                   %datetime(21)			Measurement collection start date. Date of file creation. UTC DateTime in ISO 8601 format: YYYY-MM-DDThh:mm[:ss] or YYYY-MM-DD hh:mm[:ss].	
    %EndDate=char(DateTime(end,:) )  ;                                                                  %datetime(21)			Measurement collection end date. Date of file creation. UTC DateTime in ISO 8601 format: YYYY-MM-DDThh:mm[:ss] or YYYY-MM-DD hh:mm[:ss].	
    Institute='5123'  ;                                                                                 %char(6)			EDMO code of the measuring institution
    Contact = 'Jakob Tougaard';                                                                         %char(225)			Point of contact Contact of all future external queries/who submits/holds responsibility for submission	
    CountryCode = 'DK' ;                                                                                %char(4)			ISO country code
    StationCode  = char(stationlist(find(contains(stationlist(:,2), (deployment.depID(1:8)))),1))   ;   %char(10)			Station code The station code and its associated coordinates can be found in the ICES station dictionary.
    
    
    %% MD data
    % This loop is based on the assumption that only SM (Wildlife Acoustics)
    % units have in situ hydrophones, our DSG units use HTI-96-min hydrophones, 
    % and all other units we use are Sound Traps. This is true for the 
    % noise monitoring program in Denmark, but please check your own set up. 
    % Ref here: https://vocab.ices.dk/?ref=1584
    if strncmp(deployment.type,'SM',2)  %  Wildlife Acoutics
        HydrophoneType='IR'; 
    elseif strncmp(deployment.type,'DSG',3)
        HydriphoneType= 'HTI96';
    else
        HydrophoneType='SEH'; 
    end                                                                                                 %nvarchar(225)   Manufacturer and used hydrophone type/model e.g. 'Brüell&Kjaer 8106'. This field needs to be an array if there are multiple channels (one per channel).	
    
    if isempty(deployment.hydrophoneID)
        HydrophoneSerialNumber = '';
    else
        HydrophoneSerialNumber=deployment.hydrophoneID; 
    end                                                                                                 %nvarchar(50)			e.g. 'SN#1234'This field needs to be an array if there are multiple channels (one per channel).
           
    % For reference, see: https://vocab.ices.dk/?ref=1585
    if strncmp(deployment.type,'SM',2)          %  Wildlife Acoutics                                    %varchar(50)			Recorder/data logger type e.g. 'Soundtrap'
        if strncmp(deployment.type,'SM3',3) 
            RecorderType='WSM3M';
        else
            RecorderType = 'WSM2M';
        end
    elseif strncmp(deployment.type,'ST',2)      % Sound Traps
        if strncmp(deployment.type,'ST5',3)
            RecorderType='OIS5H';
        else
            RecorderType = 'OIS6H';
        end
    else  
        RecorderType='LHDS';                    %DSG
    end

    if deployment.logger == "n/a"
        RecorderSerialNumber= '';
    else
        RecorderSerialNumber=deployment.logger;                                                         %nvarchar(50)			Recorder serial number e.g. 'SN#2345'
    end

    MeasurementHeight=2;                                                                                %float(10)              Height above the seafloor, in meters.
    MeasurementPurpose= 'HMON';
    MeasurementSetup='AUT'  ;                                                                           %varchar(10)			Description of deployment. Mandatory in case the purpose is 'HELCOM monitoring'
    RigDesign='MFB' ;                                                                                   %varchar(10)			Description of deployment construction. Mandatory in case the purpose is 'HELCOM monitoring'.
    FrequencyCount=int64(size(LeqMeasurementsOfChannel1, 2));                                           %int(2)                 Number of frequency bands.
    FrequencyIndex=allnoise.fm(11:FrequencyCount+10) ;  ;                                               %float(10)              Decidecade band nominal center frequencies.
    FrequencyUnit='Hz' ;                                                                                %varchar(10)            Hz or kHz
    ChannelCount=int64(1)   ;                                                                           %int(2)         		Number of channels used
    MeasurementUnit='SPL'  ;                                                                            %varchar(10)			Unit in which the values are in e.g. dB re 1µPa

    sec=dDT(2)-dDT(1);
    AveragingTime=int64(seconds(sec) )  ;                                                               %int(5)             	Averaging time in seconds.           

    ProcessingAlgorithm='JOMO' ;                                                                        %nvarchar(225)			Algorithm used to process the data e.g. computation method for third octave band (fft, filter bank ...).	
    
    DatasetVersion='v1.0' ;                                                                             %nvarchar(255)			Indicates version of the submitted dataset. It should be changed upon resubmission.
    CalibrationProcedure='CPC'  ;                                                                       %nvarchar(255)			Method used to check the measuring chain. E.g. point calibration with pistonphone, functionality test with microphone and loudspeaker (frequency dependent), or other method used to check the measuring chain. E.g. point calibration with pistonphone, functionality test with microphone and loudspeaker (frequency dependent), or other. Mandatory in case the purpose is 'HELCOM monitoring'.	
    CalibrationDateTime   =datestr(deployment.timeGPSreset,'yyyy-mm-dd HH:MM:SS');                      %datetime(21)			Date of when the system was last calibrated. Mandatory in case 'CalibrationProcedure' is specified UTC DateTime in ISO 8601 format: YYYY-MM-DDThh:mm[:ss] or YYYY-MM-DD hh:mm[:ss].	
    Comments  = 'na';                                                                                   %char(255)          	Additional comments.
    
    
    %% Split the data by month, and start saving it.  
    % This step may not be necessary any more, as previous versions of the
    % ICES database had an issue with multiple month files. However, it is
    % very easy to split the data, and these files are small enough not to
    % cause issues during upload.

    cd('your saving directory');
    mons=unique(dDT.Month);
    for m = 1:length(mons)
        S=(dDT.Month==mons(m));        
        LMOC_byMo=LeqMeasurementsOfChannel1(S,:);
        DT_byMo=dDT(S,:);
        
        DataUUID=char(java.util.UUID.randomUUID);                                                       %nvarchar(255)			'Unique identification number, linking the data submission to the corresponding raw data. It should be used for resubmissions of the same data; matlab function available: uuid = char(java.util.UUID.randomUUID);'.	
        MeasurementTotalNo=int64(size(LMOC_byMo, 1));                                                   %int(5)                 Number of measurements. This field needs to be an array if there are multiple channels (one per channel).	
    
        % This filename is specific to AU filename convention. 
        ofilename=[depSite '\ICES_HELCOM_' deployment.depID '_Month' num2str(mons(m)) ];

        %Get TimeStamp in UTC that this file is created and format it to ISO 8601.
        t=datestr(now,'yyyy-mm-dd HH:MM:SS');
        t=datetime(t,'TimeZone', 'UTC+1');
        t.TimeZone='UTC';
        t=datestr(t,'yyyy-mm-dd HH:MM:SS');

        % Get the start and end date for the data when divided by month. 
        StartDate=datestr(DT_byMo(1,:),'yyyy-mm-dd HH:MM:SS' )  ;                                       %datetime(21)			Measurement collection start date. Date of file creation. UTC DateTime in ISO 8601 format: YYYY-MM-DDThh:mm[:ss] or YYYY-MM-DD hh:mm[:ss].	
        EndDate=datestr(DT_byMo(end,:),'yyyy-mm-dd HH:MM:SS' )  ;  

        %%  Create the three data structs seperately.
        
        DT=struct('LeqMeasurementsOfChannel1',LMOC_byMo');                                              %Equivalent continuous sound pressure level measurements over time for all covered frequency bands. One frequency per column. In case there are multiple channels, there should be an array of values for each channel. If there are 3 channels, there would be three arrays called LeqOfChannel1, LeqOfChannel2, LeqOfChannel3. In case of channel failure, report NAN values.	
                % 'DateTime',sDT, ...                                                                   %UTC DateTime in ISO 8601 format: YYYY-MM-DDThh:mm[:ss] or YYYY-MM-DD hh:mm[:ss].
                % Datetime is added later when the h5 file is already
                % created, due to a formatting issue. See below...

        IR=struct('Email', Email, ...	                                                                %E-mail of the author. Creator of the HDF5 file/ who holds responsibility for data QA and creation of the submited hdf5 file.	
                'CreationDate',t,...                                                                    UTC DateTime in ISO 8601 format: YYYY-MM-DDThh:mm[:ss] or YYYY-MM-DD hh:mm[:ss]	
                'StartDate',StartDate,...                                                               %Measurement collection start date. Date of file creation. UTC DateTime in ISO 8601 format: YYYY-MM-DDThh:mm[:ss] or YYYY-MM-DD hh:mm[:ss].	
                'EndDate', EndDate, ...                                                                 Measurement collection end date. Date of file creation. UTC DateTime in ISO 8601 format: YYYY-MM-DDThh:mm[:ss] or YYYY-MM-DD hh:mm[:ss].	
                'Institution',Institute,...                                                             %EDMO code of the measuring institution
                'Contact', Contact,...			                                                        % Point of contact Contact of all future external queries/who submits/holds responsibility for submission	
                'CountryCode', CountryCode,...                                                          %ISO country code
                'StationCode', StationCode);

        MD=struct('HydrophoneType', HydrophoneType,...                                                  %nvarchar(225)          Manufacturer and used hydrophone type/model e.g. 'Brüell&Kjaer 8106'. This field needs to be an array if there are multiple channels (one per channel).	
                'HydrophoneSerialNumber',HydrophoneSerialNumber,...                                     %nvarchar(50)			e.g. 'SN#1234'This field needs to be an array if there are multiple channels (one per channel).	
                'RecorderType',RecorderType, ...                                                        %varchar(50)			Recorder/data logger type e.g. 'Soundtrap'
                'RecorderSerialNumber',RecorderSerialNumber, ...                                        %nvarchar(50)			Recorder serial number e.g. 'SN#2345'
                'MeasurementHeight', MeasurementHeight, ...                                             %float(10)              Height above the seafloor, in meters.
                'MeasurementPurpose',MeasurementPurpose,...
                'MeasurementSetup',MeasurementSetup,...                                                 %varchar(10)			Description of deployment. Mandatory in case the purpose is 'HELCOM monitoring'
                'RigDesign', RigDesign,...                                                              %varchar(10)			Description of deployment construction. Mandatory in case the purpose is 'HELCOM monitoring'.
                'FrequencyCount', FrequencyCount,...                                                    %int(2)                 Number of frequency bands.
                'FrequencyIndex',FrequencyIndex',...                                                    %float(10)              Third octave band nominal center frequencies.
                'FrequencyUnit', FrequencyUnit,...                                                      %varchar(10)             Hz or kHz
                'ChannelCount', ChannelCount,...                                                        %int(2)         		Number of channels used
                'MeasurementTotalNo', MeasurementTotalNo,...                                            %int(5)                 Number of measurements. This field needs to be an array if there are multiple channels (one per channel).	
                'MeasurementUnit',MeasurementUnit,...                                                   %varchar(10)			Unit in which the values are in e.g. dB re 1µPa
                'AveragingTime',AveragingTime,...             	                                        %Averaging time in seconds.
                'ProcessingAlgorithm',ProcessingAlgorithm,...                                           %nvarchar(225)			Algorithm used to process the data e.g. computation method for third octave band (fft, filter bank ...).	
                'DataUUID', DataUUID,...                                                                %nvarchar(255)			'Unique identification number, linking the data submission to the corresponding raw data. It should be used for resubmissions of the same data; matlab function available: uuid = char(java.util.UUID.randomUUID);'.	
                'DatasetVersion', DatasetVersion,...                                                    %nvarchar(255)			Indicates version of the submitted dataset. It should be changed upon resubmission.
                'CalibrationProcedure', CalibrationProcedure,...                                        %nvarchar(255)			Method used to check the measuring chain. E.g. point calibration with pistonphone, functionality test with microphone and loudspeaker (frequency dependent), or other method used to check the measuring chain. E.g. point calibration with pistonphone, functionality test with microphone and loudspeaker (frequency dependent), or other. Mandatory in case the purpose is 'HELCOM monitoring'.	
                'CalibrationDateTime', CalibrationDateTime,...                                          %datetime(21)			Date of when the system was last calibrated. Mandatory in case 'CalibrationProcedure' is specified UTC DateTime in ISO 8601 format: YYYY-MM-DDThh:mm[:ss] or YYYY-MM-DD hh:mm[:ss].	
                'Comments',Comments);

        %Merge them into one struct for the H5 file.
        ICES_data=struct('Data',DT,...
            'FileInformation',IR,...
            'Metadata',MD);


        %Save a matlab version of your data.
        save([ofilename '.mat'], 'ICES_data', 'DT_byMo')

        %% creates and writes data to hdf5 file (file must not exits at time of function call)
        matlab_write_recursive_hdf5([ofilename '.h5'], '',ICES_data);

        %Add datetime in.
        DateTime=datestr(DT_byMo, 'yyyy-mm-dd HH:MM:SS');
        DIM0 = size(DateTime,1);
        SDIM = size(DateTime,2)+1;
        dims   = DIM0;
        %Open file using Read/Write option
        file_id = H5F.open([ofilename '.h5'],'H5F_ACC_RDWR','H5P_DEFAULT');
        gid = H5G.open(file_id,'/Data');

        %Create file and memory datatypes
        filetype = H5T.copy ('H5T_C_S1');
        H5T.set_size (filetype, SDIM-1);
        memtype = H5T.copy ('H5T_C_S1');
        H5T.set_size (memtype, SDIM-1);
        % Create dataspace.  Setting maximum size to [] sets the maximum
        % size to be the current size.
        %
        space_id = H5S.create_simple (1,fliplr(dims), []);
        % Create the dataset and write the string data to it.
        %
        dataset_id = H5D.create (gid, 'DateTime', filetype, space_id, 'H5P_DEFAULT');
        % Transpose the data to match the layout in the H5 file to match C
        % generated H5 file.
        H5D.write (dataset_id, memtype, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', DateTime .');
        %Close and release resources
        H5G.close(gid);
        H5D.close(dataset_id);
        H5S.close(space_id);
        H5T.close(filetype);
        H5T.close(memtype);
        H5F.close(file_id);
        cd('O:\Tech_MSFD-deskriptor11-Danmark\ICES database')
    end
    cd('O:\Tech_MSFD-deskriptor11-Danmark\ICES database')
    
end

