
function run_write_to_ices(cd_root,load_path,plats)
% This script converts matlab struct data into ICES format. Prerequisites
% is to have a metadata files with correct information given, and a data
% file with data in the correct format. See examples for 


%Create save paths
save_all_struct_mat=[cd_root  '\Resultat\hdf5_files_ices\mat\' plats '\'];
if ~isfolder(save_all_struct_mat)
    mkdir(save_all_struct_mat)
end
save_all_struct_hdf5=[cd_root  '\Resultat\hdf5_files_ices\hdf5\' plats '\'];
if ~isfolder(save_all_struct_hdf5)
    mkdir(save_all_struct_hdf5)
end

%%%%%%%%%%%%%%%%%%%%%%
%Loading the deployment file
dir_structs=dir([load_path '/s_*.mat']);
if isempty(dir_structs)
    return
end
disp(['Loading ' dir_structs(1).name])
s_ex=load([dir_structs(1).folder '\' dir_structs(1).name]);
s=s_ex.s_1_3_oct_all;
% DATA Create ICES struct data values:
ices_struct.ters_centre= s.ters_center;
ices_struct.SPL_1_3_octave=s.SPL_1_3_oct;
ices_struct.time_vec=s.t;
disp(['Frequency from ' num2str(round(ices_struct.ters_centre(1))) '-' num2str(round(ices_struct.ters_centre(end)))])

% METADATA Get settings
instr_settings=s.instr_settings;
pos_settings=s.pos_settings;
%  ICES information needed for the format
ices_info.measurement_height=pos_settings.measurement_height;
ices_info.StationCode=pos_settings.station_code; %Define station code:
ices_info.MeasurementPurpose= 'HMON'; %HELCOM MONITORING
ices_info.MeasurementSetup= upper(instr_settings.setups(1:3));  %AUTONOMOUS
if strcmpi(instr_settings.decoupling,'yes')
    ices_info.RigDesign= 'MFB';  %'Mooring with floating buoy';
end
disp(['National monitoring, autonomous, mooring with floating buoy, at ' num2str(pos_settings.measurement_height) 'mab'])

%Check calibration:
try 
    kalibrering{1}=instr_settings.kalib_struct.calibration_procedure;
    kalibrering{2}=instr_settings.kalib_struct.Calibration_date;
catch MS
    disp(MS)
    kalibrering{1}='Factory';
    kalibrering{2}='2000-01-01';
    disp('No info on calibration')
end
kalibrering{2}=datetime(kalibrering{2});
disp('Continue? Press F5')
keyboard

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% WEBPAGE Checks the data already on the webpage
%Reads the data of the uploaded files on the ICES database
html=webread('https://underwaternoise.ices.dk/continuous/api/getListSubmissions');
i_pos=arrayfun(@(x) strcmp(x.stationCode,ices_info.StationCode),html);
html_currpos=html(i_pos);
for i_f=1:length(html_currpos)
    disp([num2str(i_f) ':' html_currpos(i_f).fileName])
end

%Optional: Previously ICES database had to have smaller files to be able to
%upload them. Thus we created one file per month. Now this has changed so
%there is no need to split the files in months. If this is what you need to do
%uncomment the following lines:
% %Loop over all months
% manader=unique(month(dtime));
% for monthidx=1:length(manader)
%     idx_thismonth=(month(dtime) == manader(monthidx));
%     ices_struct.SPL_1_3_octave=s.SPL_1_3_oct(startf:slutf,idx_thismonth);
%     ices_struct.time_vec=s.t(idx_thismonth);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Check status if file already exists in database
% If available, UU-ID number will be collected, and the version number will
% be changed.
ices_info=get_previous_structvals(ices_info,ices_struct,html_currpos,save_all_struct_mat);
disp('Continue? Press F5')
keyboard
%Process data:
disp('Adding data to ICES format...')
[filename,dset,DatumDateTime,DateTimeCell]=create_struct_hdf5_ICES(ices_struct,instr_settings,ices_info,kalibrering);
disp('Continue? Press F5')
keyboard
disp('Deleting old files')
save([save_all_struct_mat filename '.mat'], 'dset','DatumDateTime');
if isfile([filename '.h5'])
    delete([filename '.h5'])
end
if isfile([save_all_struct_hdf5 filename '.h5'])
    delete([save_all_struct_hdf5 filename '.h5'])
end
disp('Saving new files')
matlab_write_recursive_hdf5([save_all_struct_hdf5 filename '.h5'], '', dset);
hdf5write([save_all_struct_hdf5 filename '.h5'],'/Data/DateTime',DateTimeCell','WriteMode', 'append')    
disp(['Data saved for ' pos_settings.position_id ' med instrument ' instr_settings.instrument_id ', filnamn ' filename])
clear dset filename


end
