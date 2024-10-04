function loadGPSNavData(obj,filename)
% Function to load the ephemeris message into the object as well as create
% a matrix of ephemeris issue times so that the correct parameter set can
% be looked up efficiently

obj.ephemerisData = rinexGPSNavRead(obj,filename);

% To increase efficiency, I'm building a table of ephemeris set times here
% so that they can be looked up quickly
obj.ephemerisTimeTable = ...
    NaT(size(obj.ephemerisData.ephemeris,1),size(obj.ephemerisData.ephemeris,2));

for ii = 1:size(obj.ephemerisData.ephemeris,1)
    for jj = 1:size(obj.ephemerisData.ephemeris,2)

        try
            obj.ephemerisTimeTable(ii,jj) = ...
                obj.ephemerisData.ephemeris{ii,jj}.time;
        catch
        end
    end
end

end