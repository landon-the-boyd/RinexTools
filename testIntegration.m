
addpath("Data\chcm\");
% Define observation, navigation and glonass filenames
obs = 'chcm2440.22o';
nav = 'chcm2440.22n';
gloNav = 'chcm2440.22g'

% For Reference
load("RCVRT_data.mat")
load("ephem.mat")




function gpsData = parseRinex()
end