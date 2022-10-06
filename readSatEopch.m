function [epochData,lineCount] = readSatEopch(fileID, obsTypes,lineCount)

% Get the two lines of data and parse
dataLine1 = split(fgetl(fileID));
dataLine2 = split(fgetl(fileID));
lineCount = lineCount + 2;

% For some reason the first element is always an empty character
% array. Also I dont knwo what the number at the beginning of the
% observation list is but I can use it later if I want it
dataLine1 = dataLine1(2:end);
dataLine2 = dataLine2(2:end);


% Convert to a number
obsData = str2double([dataLine1;dataLine2]);

% Extract message for the satellite in question
epochData = matchRinexData(obsData,obsTypes);

end