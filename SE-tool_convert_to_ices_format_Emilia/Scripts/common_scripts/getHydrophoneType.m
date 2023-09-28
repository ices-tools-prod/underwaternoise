%getHydrophoneType

if strcmp(instr_settings.hydrophone_manufacturer,'HTI')
    switch instr_settings.hydrophone_type
        case 'STD'
            HydrophoneType='HTI96';
            disp('HTI-96-min')
        case 'Standard'
            HydrophoneType='HTI96';
            disp('HTI-96-min')
        case 'LN'
            HydrophoneType='HTI92';
            disp('HTI-92-WB')
    end
elseif strcmp(instr_settings.hydrophone_manufacturer,'OceanInstruments') || strcmp(instr_settings.hydrophone_manufacturer,'Ocean Instruments')
    switch instr_settings.instrument_id(1:4)
        case 'ST01' 
            HydrophoneType=['IR'];  %Integrated
            disp('Internal hydrophone')
        case 'ST02' 
            HydrophoneType=['IR'];  %Integrated
            disp('Internal hydrophone')
        otherwise
            HydrophoneType=['SEH']; %External
            disp('External hydrophone')
    end
else
    HydrophoneType=input('Write the hydrophone type (https://vocab.ices.dk/?ref=1584): ','s');
end

disp(['Hydrophone type: ' HydrophoneType])
