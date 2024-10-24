% Manager for Rinex Navigation Message data
% Landon Boyd
% 10/04/2024

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

        % Primary Handles the user will call for information
        ephemeris = returnParameterSet(obj,time)
        dopplerMeasurements(obj)
        [observables,satPos,satVel,satClock,TOW,time,satsInView] = returnEpoch(obj,index)

    end

    methods(Access=protected,Hidden)
    
        % This method kicks off all ephemeris loading and managing
        rinexGPSNavRead(obj,filename)

        [satPos,satVel,satClock] = GPSEphemerisCalculation(obj,ephemerisSet,transmitTime,transitTime);

        % Methods for handling observation data files
        gnssData = rinexGPSObsRead(obj,filename)

        % Ionosphere
        delays = klobucharModel(obj,time,satPos)

    end


end