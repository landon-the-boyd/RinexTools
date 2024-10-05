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

    methods
    
        % Methods for if you intend to use the object as an ephemeris data
        % manager
        loadGPSNavData(obj,filename)

        % Rinex Navigation Message
        ephemerisData = rinexGPSNavRead(obj,filename)

        [ionoAlpha,ionoBeta,deltaUTC,leapSeconds,headerCount] = ...
            readGPSNavHeader(obj,fileID)

        ephemeris = returnParameterSet(obj,time)

        [satPos,satVel,satClock] = GPSEphemerisCalculation(obj,ephemerisSet,transmitTime,transitTime);

        % Methods for handling observation data files
        gnssData = rinexDataRead(obj,filename)

        loadObsData(obj,filename)

        [observables,satPos,satVel,satClock,TOW,time,satsInView] = returnEpoch(obj,index)

    end


end