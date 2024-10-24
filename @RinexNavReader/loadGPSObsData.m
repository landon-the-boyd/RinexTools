function loadGPSObsData(obj,filename)
% Function to load the data from a RINEX file into the object.
% Additionally, creates the observation timetable for efficient lookup of
% what satellites are in view
% Landon Boyd 
% 10/05/2024
% Updated 10/24/2024

obj.rinexGPSObsRead(filename);

% Create lookup table here

end