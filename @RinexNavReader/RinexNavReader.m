% Manager for Rinex Navigation Message data
% Landon Boyd
% 10/04/2024
% Updated 10/24/2024

classdef RinexNavReader < handle

    properties(Access=public)
    
        ephemerisData
        ephemerisTimeTable
        obsData
        obsTimeTable
    
    end

    methods(Access=public)

        % Methods to initialize data 
        loadGPSNavData(obj,filename)
        loadGPSObsData(obj,filename)

        % Methods to insert new observables into the record
        dopplerMeasurements(obj)

        % Primary Handles the user will call for information
        ephemeris =                returnGPSEphem(obj,time)
        [observables,satPos,satVel,satClock,...
            TOW,time,satsInView] = returnGPSObs(obj,index)

    end

    methods(Access=protected,Hidden)
    
        % Under the hood rinex reading
        rinexGPSNavRead(obj,filename)
        rinexGPSObsRead(obj,filename)

        [satPos,satVel,satClock] = GPSEphemerisCalculation(obj,...
            ephemerisSet,transmitTime,transitTime);
        
        % Ionosphere
        delays = klobucharModel(obj,time,satPos)

    end


end