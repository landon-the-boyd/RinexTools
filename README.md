# RinexTools
Landon Boyd
10/2024

RinexTools contains the MATLAB RinexNavReader object, which is designed to read Rinex v2.11 files from NOAA CORS network stations. While MATLAB has a built-in functionality to read RINEX files, it is limited to v.3. This object has the following capabilities.

RinexNavReader loads in navigation or observable data with the following lines
```
rinexReader = RinexNavReader;
rinexReader.loadGPSNavData(filename);
rinexReader.loadGPSObsData(filename);
```

Once data is loaded, you can call the data by observation epoch index, and ephemeris by MATLAB datetime. If more than one ephemeris message exists for your RINEX nav file, the object will choose the most recent broadcast ephemeris.
```
[observables,satPos,satVel,satClock,...
            TOW,time,satsInView] = rinexReader.returnGPSObs(1); % Get first observation epoch
ephemeris = rinexReader.returnGPSEphem(time); % Get ephemeris for all satellites in the file
```

Additionally, some CORS networks don't provide a Doppler shift observable. The Class has a built in method to differentiate carrier phase to provide one. Note, this Doppler shift will experience jumps based off cycle slip, but it is better than nothing.
```
rinexReader.dopplerMeasurements();
```

A GPS ephemeris to ECEF calculation tool is also included.
```
[satPos,satVel,satClock] = rinexReader.GPSEphemerisCalculation(ephemerisSet,transmitTime,transitTime);