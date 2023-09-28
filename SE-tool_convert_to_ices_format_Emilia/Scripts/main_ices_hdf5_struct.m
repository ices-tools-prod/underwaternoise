% cd_root='C:\Users\FOI\Documents\';
clear
cd_root=pwd;
% addpath('C:\Scripts\Git\sol\matlab_common\ProcesseringLjuddata\')
% addpath('C:\Scripts\Git\sol\matlab_common\')
% addpath('C:\Scripts\Git\sol\matlab_common\PlotTools\')
addpath('common_scripts')
%% BEFORE 2021: all finished 2022-02-07
dir_metadata=dir([cd_root '\Metadata\*\**\*.mat']);
for i=1:length(dir_metadata)
    disp([num2str(i) ': ' dir_metadata(i).name])
end
keyboard
%%
for idx=1:length(dir_metadata)
    clear meta instr_settings pos_settings
    disp(dir_metadata(idx).name)
    meta=load(fullfile(dir_metadata(idx).folder,dir_metadata(idx).name));
    plats=meta.pos_settings.position_id;
    if strcmp(plats,'NM_syd2')
        continue
    end
    %Running results:
    i_=find(dir_metadata(idx).folder == '\');
    structname=dir_metadata(idx).folder(i_(end)+1:end);
    load_path=cd_root;
    run_write_to_ices(cd_root,load_path,plats)
end
