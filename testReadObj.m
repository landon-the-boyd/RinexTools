clear
clc

addpath("Data\chcm\","Data\gtac068\","Data\nerc278\");

ephemerisfile = 'chcm2440.22n';
observationfile = 'chcm2440.22o';


%%
% We identify the observation file and open it
% ephemerisData = RinexNavReader.rinexGPSNavRead(ephemerisfile);
% gnssData = RinexNavReader.rinexDataRead(observationfile);

ephemerisManager = RinexNavReader;
ephemerisManager.loadGPSNavData(ephemerisfile);
gnssData = ephemerisManager.rinexDataRead(observationfile);