function ephemeris = returnGPSEphem(obj,time)
% Function to take a datetime object and return the most recent ephemeris
% for all satellites
% Landon Boyd 10/04/2024

% Traverse time table to get best parameter set for all satellites
ephemeris = cell(1,length(obj.ephemerisData.ephemeris));

for ii = 1:length(obj.ephemerisData.ephemeris)

    deltaTime = hours(time - obj.ephemerisTimeTable(:,ii));
    [deltaTime,idx] = min(deltaTime(deltaTime >= 0));

    if ~isnan(deltaTime)
        ephemeris{ii} = obj.ephemerisData.ephemeris{idx,ii};
    end

    if deltaTime > 4
        warning("Most Recent ephemeris set for PRN %d is %0.4f hours old",ii,deltaTime)
    end
end

end