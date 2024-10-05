function loadObsData(obj,filename)
% Function to load the data from a RINEX file into the object
% Landon Boyd 10/05/2024

obj.obsData = rinexDataRead(obj,filename);

end