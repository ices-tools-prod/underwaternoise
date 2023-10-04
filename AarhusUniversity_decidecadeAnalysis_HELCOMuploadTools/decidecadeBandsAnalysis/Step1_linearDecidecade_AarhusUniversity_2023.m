% For each recording this script will extract timestamps and decidecade SPLs 
% per 1 sec in filter bands, including 63Hz, 125Hz and 2kHz, as well as allow 
% quantification over the entire frequency band 10-10000Hz. 
%
% Current Version by Emily T. Griffiths, 2020-2023.
% emilytgriffiths@ecos.au.dk
%
% Originally Developed by Jakob Tougaard and Pernille Meyer Sørensen, 2018. 
% Modified and improved by Line Hermannsen and Mia L. K. Nielsen, 2018-2020.

clear all
close all

restoredefaultpath;matlabrc %to fix eval problem

%%  Call in functions
addpath(genpath('O:\Monitering\Analysis\scripts')); %Example directory

% Call in metadata for the deployment you would like to process as a excel
% or database table. 
mdT=readtable('noiseMonitoring_metadata.xlsx');

%Limit your data to the deployment you would like to process. Or, you can
%convert this script into a loop with: for d = 1:length(mdT); R=mdT(d,:);
R = mdT(8,:);

%% File Information %%
%%Read in files%%
%Collect all the files in a directory.
cd(cell2mat(R.wavFileDir));
fulldir = dir('*.wav');
fullFileNames={fulldir.name}';


%%Currently set up for Wildlife Acoustics, Loggerhead Instruments, and
%%Ocean Instruments only. It is important that this collects the date
%%correctly, which is why it is in this script. Alter if necessary.
if strncmp(type,'SM',2)  %  Wildlife Acoutics
    rawDate=extractBetween(fullFileNames,'_', '.');
    DT_all=datetime(rawDate, 'InputFormat','yyyyMMdd_HHmmss');
else    % Everyone else, as they all use the ST Host Software
    rawDate=extractBetween(fullFileNames,'.', '.');
    DT_all=datetime(rawDate, 'InputFormat','yyMMddHHmmss');
end

%If there is clock drift data available, adjust the timestamps of our data
%to adjust for clock drift. 
if R.clockDriftP == 0
    newDTall = DT_all;
else
    DTi=(DT_all >= R.TimeSync);
    DT_all=DT_all(DTi,:);
    newDTall = clockDrift(R.TimeSync, R.offloadTime, R.offloadUTC, DT_all=DT_all);
end
 

%Date of the First and Last file in directory compared to the date of the
%deployment and retrieval.  Collect only the deployment data.

DTfirstFile=newDTall(1);
DTlastFile=newDTall(end);

DTdep = datestr(R.dataStart + 1, 'yyyy-mm-dd HH:MM:SS');
DTret = datestr(R.dataEnd, 'yyyy-mm-dd HH:MM:SS');


%What file starts useful data? Was the unit turned on before deployment or
%after? Did the logger turn off before or after retrieval? These if
%statements grab only the data that is useful from the deployment, and
%discards the rest so it isn't included in this analysis.
if DTfirstFile > DTdep
    DTstart=DTfirstFile;
else
    DTstart=DTdep;
end

if DTlastFile<DTret
    DTslut=DTlastFile;
else
    DTslut=DTret;
end

%Index your datetime based on these parameters.
DTinx=(newDTall >= DTstart & newDTall <= DTslut);

%Select only files with data for futher analysis. 
DateTime=newDTall(DTinx,:);
files=fullFileNames(DTinx,:);
filesdata=fulldir(DTinx,:);


%File name
resultname=[cell2mat(R.depID) '_' datestr(DTstart, 'yyyymmdd') '_to_' datestr(DTslut, 'yyyymmdd') '_' cell2mat(R.loggerName) ]; %save results in mat file with this name

filters = computefilters([filesdata(1).folder '\' filesdata(1).name]);                    % Construct the filters (42 of which 11-42 are functional) 
w=filters.w;  

% Get the median duration of the files in the directory. 
% Extract the seconds per sample information for this deployment.  This
% will be a consistent number based on the sample rate
dur=cell(size(filesdata));
for f = 1:length(filesdata)
    wav=audioinfo([filesdata(f).folder '\' filesdata(f).name]);
    inSec=extractBefore(char(seconds(wav.Duration)),' ');
    [dur{f}]=inSec;
end

duration=str2double(dur);

%Index the files that are less than 1% in length from the median duration.
%Remove them from analysis. These files can be reported at the end of this
%script.
Linx=(duration > duration*0.01);
filesdata=filesdata(Linx,:);
Nfiles=length(filesdata);

%%preallocate your final file.
datafiles(length(filesdata)).bands_1s=deal([]);             % Saves bands_1s
datafiles(length(filesdata)).filename=deal([]);             % Saves filename
datafiles(length(filesdata)).datetime=deal([]);             % Saves time stamp from filename
datafiles(length(filesdata)).timestamps_1s=deal([]);        % Saves time stamps for each 1 sec segment
datafiles(length(filesdata)).minSPL_1s=deal([]);            % saves min SPL found for each 1 sec segment
datafiles(length(filesdata)).maxSPL_1s=deal([]);            % saves max SPL found for each 1 sec segment  
datafiles(length(filesdata)).broadband_1s=deal([]);         % Saves the broadband 10 - 10000Hz 1 sec averages
datafiles(length(filesdata)).negclipped=deal([]);           % Saves results of clipping test; positive clipping
datafiles(length(filesdata)).posclipped=deal([]);




%% Construct the results struct.
results=struct;
results.bands=filters.bands;                       % Filter bands.
results.fc=filters.fc;                             % Band center frequencies.
results.fm=filters.fm;                             % Precise band center frequencies.
results.bwcorr=filters.bwcorr;                     % Window correction factor; ratio between Hann-weighted, 0% overlap and unweighted.
results.station=R.Station;                         % The station name.
results.broadband = filters.bb;                    % Broadband filter

    % OBS: if the loop does not work with the parallels change parfor into for:
    % parfor

% make a directory for your survey. This step is optional.
mkdir([cell2mat(R.outputLocation) '\' cell2mat(R.depSurvey)])
cd([cell2mat(R.outputLocation) '\' cell2mat(R.depSurvey)])

for fileno = 1:length(filesdata)
    pause(5)  % This helps your computer keep up with the calculation without running out of memory.
    tic
    display([filesdata(fileno).name ' file ' num2str(fileno) ' of ',num2str(Nfiles) ' total']) % Displays the filenumber that is be processed
    [sig,sr] = audioread([filesdata(fileno).folder '\' filesdata(fileno).name]) ;      % Reads the file, output: signal (sig) and sample rate (sr).
    sig1 = sig - mean(sig);                         % Removes DC offset - doesn't make that big of a difference
    samples = length(sig1);                         % The no. of samples per file
    n_segments = floor(samples/sr);                 % Number of 1 second segments (e.g.  57600000 samples / 32000 samples/sec = 1800 1 sec segments (1800 / 60 sec = 30 minutes)

    data = reshape(sig1(1:sr*n_segments),sr,n_segments);                            % Reshape to segmentwise columns. Each column corresponds to a second, and each row is a sample.
    ps = 2*abs(fft(repmat(w,1,n_segments)/sr.*data,[],1).^2)*filters.window_corr;   % Repmat makes a sr*n_segments array with each column containing the hann window (filters.w)

    % Decidecade levels per 1 s segments:
    bands_1s=NaN(n_segments,filters.xmax+1);    % no of 1 sec segments * filters (decidecade bands)

    lowcut=11;          % Lower ten TOL bands are not used in this analysis.
    for n=lowcut:filters.xmax+1                                                 % There's no reason to use filters at the really low frequencies - these are skipped, hence 11:42.
        bands_1s(:,n)=sum(sqrt(ps(filters.bands(:,n),:).^2))';                  % Average rms within each 1 sec band.
    end
    
    data_1s = reshape(bands_1s,1,n_segments,filters.xmax+1);   
    
    min_1s = squeeze(sqrt(min(data_1s(:,:,:).^2)))';                                % Squeeze function removes singleton dimensions (see illustration dd = randn(2,1,3), squeeze(dd).). Sqrt and .^2 are necessary to ensure values are positive.
    max_1s = squeeze(sqrt(max(data_1s(:,:,:).^2)))';
    freqs=[NaN(1,10) filters.fc(11:filters.xmax+1)];                                % Decidecade bands analysed, NaNs for low-frequencies not analyzed
    
    broadband = zeros(n_segments,1) ;                                               % Calculation of Broadband rms
    broadband(:,1) = sum(sqrt(ps(filters.bb(:,1),:).^2))';

    % Checking for clipping in the recordings:
    clipped_1s = zeros(2,n_segments);                                               % A signal is considered to be clipped if the amplitude is more than 90% of the clipping level
    for k = 1:size(data,2)
        clipped_1s(1,k) = sum(data(:,k)<-0.9);
        clipped_1s(2,k) = sum(data(:,k)>0.9);
    end
    clipped_1s = clipped_1s';

    % Timestamps.
    %This is generated automatically.  The duration from each sound file is
    %used to generate timestamps for 1s, 20s, and 5 min. One second is
    %removed because the duration is inclusive of the first timestamp.
    t1 = DateTime(fileno);
    
    % Timestamps for each 1 sec bin.
    timestamps_1s=t1:seconds(1):t1+seconds(duration(fileno)-1);
 
    % Save all variables
    datafiles(fileno).bands_1s=bands_1s;                % Saves bands_1s
    datafiles(fileno).filename=filesdata(fileno).name;  % Saves filename
    datafiles(fileno).datetime=DateTime(fileno,:);      % Saves time stamp from filename
    datafiles(fileno).timestamps_1s=timestamps_1s;      % Saves time stamps for each 1 sec segment
    datafiles(fileno).minSPL_1s=min_1s;                 % saves min SPL found for each 1 sec segment
    datafiles(fileno).maxSPL_1s=max_1s;                 % saves max SPL found for each 1 sec segment  
    datafiles(fileno).broadband_1s=broadband;           % Saves the broadband 10 - 10000Hz 1 sec averages
    datafiles(fileno).negclipped=clipped_1s(:,1);       % Saves results of clipping test; positive clipping
    datafiles(fileno).posclipped=clipped_1s(:,2);       % Saves results of clipping test; negative clipping
    toc
end
    
    
    results.datafiles = datafiles;
    save([resultname '.mat'], 'results', '-v7.3')
    
%     % Check if values look alright
%     10*log10(bands_20s(1,11:end))+ 168 %To check levels - should be around 70-140 dB re 1uPa
