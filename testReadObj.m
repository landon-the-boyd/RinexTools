clear
clc

addpath("Data\chcm\","Data\gtac068\","Data\nerc278\");

ephemerisfile = 'chcm2440.22n';
observationfile = 'chcm2440.22o';
currentTime = datetime("1-Sep-2022 12:10:00");
[TOW,~,~,~,~] = GPSdatetime(currentTime);


%%
% We identify the observation file and open it
% ephemerisData = RinexNavReader.rinexGPSNavRead(ephemerisfile);
% gnssData = RinexNavReader.rinexDataRead(observationfile);

ephemerisManager = RinexNavReader;
ephemerisManager.loadGPSNavData(ephemerisfile);
gnssData = ephemerisManager.rinexDataRead(observationfile);
currentEphemeris = ephemerisManager.returnParameterSet(currentTime);

%%

ephemerisManager.GPSEphemerisCalculation(currentEphemeris{1},TOW-0.07,0.07)