% CPC 	Closed pressure chamber/pistonphone (250 Hz) 	CalibrationProcedure 	False 	2020-02-14 	2020-02-14
% CPCM 	Closed pressure chamber/pistonphone (multiple frequencies) 	CalibrationProcedure 	False 	2020-02-14 	2020-02-14
% ELE 	Electric 	CalibrationProcedure 	False 	2020-02-14 	2020-02-14
% FFA 	Free field in air 	CalibrationProcedure 	False 	2020-02-14 	2020-02-14
% HP 	Hydrostatic pressure 	CalibrationProcedure 	False 	2020-02-14 	2020-02-14
% OTH 	Other 	CalibrationProcedure 	False 	2020-02-14 	2020-02-14
% OWC 	Open water calibration 	CalibrationProcedure 	False 	2020-02-14 	2020-02-14
% SWT 	Standing wave tank 	CalibrationProcedure 	False 	2020-02-14 	2020-02-14
% TC 	Tank calibration 	CalibrationProcedure 	False 	2020-02-14 	2020-02-14
switch kalibrering{1}(1:5)
    case 'Pisto'
        CalibrationProcedure='CPC';
        disp('Pistophone calibration, CPC')
    case 'Free '
        CalibrationProcedure='OWC'; %'Open water calibration'
        disp('Open water calibration, OWC')
    case 'Facto'
        CalibrationProcedure='TC'; %'Tank' Antar jag, på hti säger de Comparison method vilket egentligen är frifält, men det finns inte som alternativ
        disp('Tank calibration, TC')
    otherwise
        CalibrationProcedure='OWC'; 
        disp('Calibration in tanklabb, OWC')
end
