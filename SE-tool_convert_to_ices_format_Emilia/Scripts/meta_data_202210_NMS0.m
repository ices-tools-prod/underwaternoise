cd_root=pwd;
%%  Meta data
%Position data
time_period='202210';

pos_settings.position_name='Norra midsjöbanken';
pos_settings.position_id='NMS0';
pos_settings.station_code='13079';
pos_settings.tid=time_period;
pos_settings.latitud=56+04.68/60;
pos_settings.longitud=17+21.61/60;
pos_settings.measurement_height=4;   %m ö botten
pos_settings.water_depth='40 m';

instr_settings.fs=64000;
instr_settings.gain=0;   %Antagande beroende på firmware

%%  Meta data DSG010
instr_settings.instrument='Sylence';
instr_settings.instrument_id='Syl02';
instr_settings.dateformat='_yyyy-mm-dd_HH-MM-SS';%.yymmddHHMMSS=ST. ;yyyymmddTHHMMSS = DSG; '_yyyy-mm-dd_HH-MM-SS' = Sylence
instr_settings.manufacturer='RTsys';
instr_settings.serial='EA-SDALP_2111001 Ver3';
instr_settings.firmware='040.01.11';   
instr_settings.channel=1; 
instr_settings.hydrophone_manufacturer='HTI';
instr_settings.hydrophoneNr='785154';
instr_settings.hydrophone_type='LN';
instr_settings.sensitivity=-168;  %Jmft med DSG013 - 2022-09
instr_settings.gain=0; 
instr_settings.volt_correction=2.5;
instr_settings.setups='Autonomous';
instr_settings.decoupling='Yes';  %
%%%%%
instr_settings.kalib_struct = struct( ...
    'calibration_procedure', 'Comparison method', ...
    'reference_frequencies_levels','1-10 kHz', ...
    'calibration_file','Single value',...
    'Calibration_date','2022-10-03');

%--------------------------------------------------
%CHECK IF NAMES IS CORRECT:
names=[time_period '_' pos_settings.position_id '_' instr_settings.instrument_id];
disp(['Position info: ' names])
if ~isfolder([cd_root '\Metadata\' time_period '\' names '\' ])
    mkdir([cd_root '\Metadata\' time_period '\' names '\' ])
end

%%

% warning('HAR INTE ÄNDRAT DRIFT, SE ÖVER EXAKT')
instr_settings.drift= -2*60-20;%Sekunder. ANGE MINUS om loggerklockan ligger efter gps. Talet adderas till time-correction
instr_settings.clock_synk_date=datenum('2022-10-14 11:00','yyyy-mm-DD HH:MM');  %För att beräkna start-drift
instr_settings.deployment_day=datenum('2022-10-22 13:15','yyyy-mm-DD HH:MM');%Fyll i timmen efter deployment
instr_settings.pickup_day=datenum('2023-04-12 12:03','yyyy-mm-DD HH:MM'); %Fyll i timmen innan!
instr_settings.clock_end_date=datenum('2023-04-13 13:15','yyyy-mm-DD HH:MM');  


instr_settings.deployement_days_after_synk=instr_settings.deployment_day-instr_settings.clock_synk_date;
instr_settings.drift_days=instr_settings.clock_end_date-instr_settings.clock_synk_date;%Antal dagar driften beror av
instr_settings.utc_time_correction=0;    %EJ UTC, två timmars driv fram till 25 oktober
instr_settings.drift_info='';

% Settings for processing
proc_settings.wind=0; % if a Hann window is used change to wind=1, wind=0 mean no window, i.e. boxcar window;
proc_settings.noverlap=0; % if overlap is used set noverlap to the number of overlapping samples
proc_settings.max_level=0.9; % maximum level on the sensors in output wavefile, used for testing of clipping
proc_settings.min_level=-0.9; % minimum level on the sensors in output wavefile, used for testing of clipping
% proc_settings.zero_padding=1;   %Multiples of x. 1 = 1 times x in zeros length.
save([cd_root '\Metadata\' time_period '\' names '\' names '_settings.mat'],'instr_settings','pos_settings','proc_settings');

disp(['Meta_data_file created and save in ' cd_root 'Metadata\' time_period '\' names '\' names '_settings.mat'])

%%%
% DSG001 LS1	1	DSG Ocean	Loggerhead Instruments	Uvlabb/Nordsstream	437165 / 437095	-185.7  /-186
% DSG006 LS1	0	DSG Ocean	Loggerhead Instruments	Uvlabb/Erland	437084	-186.4
% DSG007 LS1	0	DSG Ocean	Loggerhead Instruments	BIAS	437431	-180.3
% DSG008 LS1	0	DSG Ocean	Loggerhead Instruments	BIAS	437428	-179.9
% DSG009 LS1	0	DSG Ocean	Loggerhead Instruments	BIAS	437433	-180.2
% DSG010 LS1	0	DSG Ocean	Loggerhead Instruments	BIAS	437438	-180.0
% DSG013 LS1	0	DSG Ocean	Loggerhead Instruments	BIAS	437430	-179.6
% DSG020 LS1 kort	0	DSG Ocean	Loggerhead Instruments	UV-labb	437864	-164,7
% DSG021 snap	0	DSG Ocean	Loggerhead Instruments	UV-labb	437863	-165,2
% DSG022 LS1 kort	0	DSG Ocean	Loggerhead Instruments	UV-labb	437866	-165,1
% DSG023 snap	0	DSG Ocean	Loggerhead Instruments	UV-labb	437865	-164,8
% SM2M007 Litium	0	SM2M Marine Recorder	Wildlife Acoustics	BIAS	681292 / 681715 (LN)	-163.8 / -164.6 (LN)
% SM2M011 Alkalina	0	SM2M Marine Recorder	Wildlife Acoustics	BIAS	681497	-164.2
% SDA1000	0	RTSys	RTSys	UV-labb	Reson	-164
% SDA014	1	RTSys	RTSYys	UV-labb	Flera hydrofoner	
% Soundtrap 01	0	Soundtrap 300 STD	Ocean instruments	UV-labb	integrerad	LG -185.4 / HG -172.9
% Soundtrap 02	0	Soundtrap 300 HF	Ocean instruments	UV-labb	integrerad	LG -186.4 / HG -174
% Soundtrap 03	0	Soundtrap 500 STD	Ocean instruments	UV-labb	#1098	-176,9
% Soundtrap 04	0	Soundtrap 500 HF	Ocean instruments	UV-labb	#6005 (står fel på hydrofonen)	-178,5

