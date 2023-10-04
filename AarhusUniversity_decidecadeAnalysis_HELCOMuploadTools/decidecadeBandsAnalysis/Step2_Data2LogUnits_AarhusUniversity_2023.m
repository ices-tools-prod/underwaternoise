% Organise decidecade levels as a structure, convert to decibles, and apply clip level.
%
% Current Version by Emily T. Griffiths, 2020-2023.
% emilytgriffiths@ecos.au.dk
%
% Originally Developed by Pernille Meyer Sørensen, 2018. 
% Modified and improved by Line Hermannsen and Mia L. K. Nielsen, 2018-2020.


clear all
close all


%%  Call in functions
addpath(genpath('O:\Monitering\Analysis\scripts')); %Example directory

% Call in metadata for the deployment you would like to process as a excel
% or database table. 
mdT=readtable('noiseMonitoring_metadata.xlsx');

%Limit your data to the deployment you would like to process. Or, you can
%convert this script into a loop with: for d = 1:length(mdT); R=mdT(d,:);
R = mdT(8,:);

% Call in linear data from Step 1.
cd(char(R.outputLocation))
name=char(R.resultnameTOLraw);
load(name);

%ClipLevel 
%Calibration
calMicSerial=R.CalMic;

Vrms=R.CalV;
CaliFile=char(R.CalFile);
toneRange = str2num(cell2mat(R.CalFileLimits));
sm = R.sensVPa *10^-6;
Inputmic= 20*log10(Vrms/sm);
[sig,fs] = audioread(CaliFile) ;
samples = [toneRange(1)*fs,toneRange(2)*fs];
sigf=sig(samples(1):samples(2));
[sig1,d] = bandpass(sigf,[100 1000],fs);
signal =  20*log10(sqrt(mean(sig1.^2)));

ClipLevel=Inputmic-signal;

for  i = 1:length(results.datafiles)
    if isempty(results.datafiles(i).bands_1s)
        allnoise.TOLdB{i} = nan ;
        allnoise.minTOLdB{i} = nan ;
        allnoise.maxTOLdB{i} = nan ;
        allnoise.timestamps{i} = nan ;
        allnoise.bb{i} = nan ;
    elseif ~isfield(results.datafiles,'minSPL_1s') 
        allnoise.TOLdB{i} = 10*log10(results.datafiles(i).bands_1s(:,11:end))+ClipLevel;
        allnoise.timestamps{i} = results.datafiles(i).timestamps_1s(:);
        allnoise.bb{i} = 10*log10(results.datafiles(i).broadband(:))+ClipLevel;% broadband 10-10000Hz (11 = 10Hz, 41 = 10000Hz).
        allnoise.fm=results.fm;
    else
        allnoise.TOLdB{i} = 10*log10(results.datafiles(i).bands_1s(:,11:end))+ClipLevel;
        allnoise.minTOLdB{i} = 10*log10(results.datafiles(i).minSPL_1s(:,11:end))+ClipLevel;
        allnoise.maxTOLdB{i} = 10*log10(results.datafiles(i).maxSPL_1s(:,11:end))+ClipLevel;
        allnoise.timestamps{i} = results.datafiles(i).timestamps_1s(:);
        allnoise.bb{i} = 10*log10(results.datafiles(i).broadband_1s(:))+ClipLevel;% broadband 10-10000Hz (11 = 10Hz, 41 = 10000Hz).
        allnoise.fm=results.fm;
    end
end

save(strcat('TOLdB_CL',num2str(round(ClipLevel)),'_',name),'allnoise','-v7.3');


