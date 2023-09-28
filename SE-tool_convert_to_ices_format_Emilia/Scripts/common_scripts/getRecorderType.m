%getHydrophoneType
%Ã„NDRA FÃ–R ATT ANPASSA TILL KODER:
% OIS3H 	OceanInstruments SOUNDTRAP 300 HF 	RecorderType 	False 	2020-02-14 	2020-02-14
% OIS3S 	OceanInstruments SOUNDTRAP 300 STD 	RecorderType 	False 	2020-02-14 	2020-02-14
% OIS5H 	OceanInstruments SOUNDTRAP 500 HF 	RecorderType 	False 	2020-02-14 	2020-02-14
% OIS5S 	OceanInstruments SOUNDTRAP 500 STD 	RecorderType 	False 	2020-02-14 	2020-02-14

%%
if contains(instr_settings.instrument,'Soundtrap')
    switch instr_settings.instrument_id(1:4)
        case 'ST01'
            added_number='300';  %Integrated
            disp([instr_settings.manufacturer ' SOUNDTRAP ' added_number ' ' instr_settings.instrument_id])   %OceanInstruments SOUNDTRAP 300 STD
            RecorderType='OIS3S';
        case 'ST02' 
            added_number='300';  %Integrated
            disp([instr_settings.manufacturer ' SOUNDTRAP ' added_number ' ' instr_settings.instrument_id])   %OceanInstruments SOUNDTRAP 300 HF
            RecorderType='OIS3H';
        case 'ST10'
            added_number='500';  %Integrated
            disp([instr_settings.manufacturer ' SOUNDTRAP ' added_number ' ' instr_settings.instrument_id])   %OceanInstruments SOUNDTRAP 500 HF
            RecorderType='OIS5H';
        case 'ST11'
            added_number='500';  %Integrated
            disp([instr_settings.manufacturer ' SOUNDTRAP ' added_number ' ' instr_settings.instrument_id])   %OceanInstruments SOUNDTRAP 500 HF
            RecorderType='OIS5H';
        otherwise
            added_number='500';  %Integrated
            disp([instr_settings.manufacturer ' SOUNDTRAP ' added_number ' ' instr_settings.instrument_id])   %OceanInstruments SOUNDTRAP 500 HF
            RecorderType='OIS5S';
    end
elseif contains(instr_settings.manufacturer,'Loggerhead')
    if strcmp(instr_settings.instrument,'DST-ST')
        RecorderType='LHDS';%'Loggerhead LS1/LS2';
    else
        RecorderType='LHL';%'Loggerhead LS1/LS2';
    end
    disp([instr_settings.manufacturer ' ' instr_settings.instrument_id ' ' instr_settings.hydrophone_type])   %OceanInstruments SOUNDTRAP 500 HF
elseif contains(instr_settings.manufacturer,'Wild')
    RecorderType='WSM2M';%'Wildlife SM2M';
    disp([instr_settings.manufacturer '  ' instr_settings.instrument_id])   %OceanInstruments SOUNDTRAP 500 HF
elseif contains(instr_settings.instrument,'Sylence')
    RecorderType='RTSLP';%'Wildlife SM2M';
    disp([instr_settings.manufacturer '  ' instr_settings.instrument_id])   %Sylence LP
else
    RecorderType=input('Write the recorder type, check list here: https://vocab.ices.dk/?ref=1585 ','s');
end

disp(['RecorderType type: ' RecorderType])
