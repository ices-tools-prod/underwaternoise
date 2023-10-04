function [newDTall, docDrift] = clockDrift(timeGPSreset, timeClockstop, timeGPSstop, docDrift, DT_all, n)
%%Interpolate datetimes to match the GPS timestamps and account for clock
%drift in the recorders. Returns a vector of adjusted datetimes. 

%% Definition of variables:

    %timeGPSreset -  Should be present for all deployments. This was the
    %time that the unit was synced with a GPS before deployment.
    
    %timeClockstop - Time on the unit when the data was offloaded.
    
    %timeGPSstop - Time according to the GPS or time.is when data was
    %offloaded.
    
    %docDrift - Drift in seconds (positive or negative) if timeGPSstop is
    %not documented.
    
    %DT_all - Datetime series you wish to adjust for Clock Drift
    
    %n - length of vectors you would like to interpolate over. Default is
    %5000.
    
    if isnat(timeGPSreset)
        error('Not enough information to adjust for Clock Drift. \nFunction requires time unit was synced with GPS time before deployment. \nInclude time timeGPSreset variable.')
    end

    if isnat(timeGPSstop)
        error('Not enough information to adjust for Clock Drift. \nFunction requires either the GPS time the unit stopped, or the difference in seconds between the time the unit and the GPS time. \nInclude timeGPSstop variable.')
    end
    
    if isnat(timeClockstop)
        error('Not enough information to adjust for Clock Drift. \nFunction requires internal time of deployed unit to calculate the difference in Clock Drift. \nInclude the timeClockstop variable.')
    end
    

    
    if  nargin < 6 || isempty(n)
        n=5000;
    end
    
    if isempty (docDrift)
        docDrift = timeGPSstop - timeClockstop;
    end


    %Create linear vectors of fixed length to interpolate on.
    timeGPSdiff=datenum(linspace(timeGPSreset,timeGPSstop,n));
    timeClockdiff=datenum(linspace(timeGPSreset,timeClockstop,n));
    %Convert date times to datenum
    DTall_num=datenum(DT_all);
    %Interpolate!
    newDTall=datetime(interp1(timeClockdiff,timeGPSdiff,DTall_num),'ConvertFrom','datenum');
end
