function gnssData = rinexDataRead(filename,obsTypes)

fileID = fopen(filename,'r');
lineCount = 0;

% Count through header lines --K
headerCount = 0;
while 1
   headerCount = headerCount+1;
   epochHeaderLine1 = fgetl(fileID);
   lineCount = lineCount + 1;

   if contains(epochHeaderLine1,"END OF HEADER")
       break;	
   end
end

% Try to predict how many entries we should be looking for. For the number
% of claimed observables, it would appear that each band reduces this
% number of actual entries in data by 1. I think this is because C1/P1 is
% listed as a single entry

% Alternate approach, just count three extra fields for each band (carrier, rangea and signal strength)
numFields = 0;%length(obsTypes);
if ismember("L1",obsTypes)
    numFields = numFields + 3;
end
if ismember("L2",obsTypes)
    numFields = numFields + 3;
end
if ismember("L5",obsTypes)
    numFields = numFields  + 3;
end

gnssData = {};
count = 1;

while ~feof(fileID)

    % Arrange data in a cell of structs
    currentData = struct;
    currentData.obsTypes = obsTypes;

    % Storage for observables later
    currentData.GPSObservables = [];
    currentData.GLOObservables = [];
    currentData.GALObservables = [];

    % Read in the epoch time and listed satellites
    epochHeaderLine1 = split(fgetl(fileID));
    lineCount = lineCount + 1;

    % Sometimes spurious lines just appear and we have to filter them out
    while length(epochHeaderLine1) < 5 || contains(epochHeaderLine1{end},'COMMENT')
        epochHeaderLine1 = split(fgetl(fileID));
        lineCount = lineCount + 1;
    end

    % All time values from epoch
    currentData.year = str2double(epochHeaderLine1{2});
    currentData.month = str2double(epochHeaderLine1{3});
    currentData.day = str2double(epochHeaderLine1{4});
    currentData.hour = str2double(epochHeaderLine1{5});
    currentData.minute = str2double(epochHeaderLine1{6});
    currentData.second = str2double(epochHeaderLine1{7});

    % Second element is number of observables. It is the first two
    % characters of the last element in the epochHeaderLine
    numSats = epochHeaderLine1{end};
    numSats = str2double(numSats(1:2));

    % Constellation description is the last element of the array, and is
    % possibly continues on the next line
    constellation = epochHeaderLine1{end};

    % If more than 9 observables, must grab two lines instead of one
    if numSats > 9
        epochHeaderLine2 = split(fgetl(fileID));
        lineCount = lineCount + 1;

        % Join our additional constellation data to what we already have
        constellation = [constellation,epochHeaderLine2{end}];
    end

    % Read in the constellation term and save
    satDescription = readConstellation(constellation);
    currentData.constellation = satDescription;

    % Set flags
    GPSTrue = ~isempty(satDescription.GPS);
    GLOTrue = ~isempty(satDescription.GLO);
    GALTrue = ~isempty(satDescription.GAL);

    % Everything is temporarily stored
    satData = [];

    % A primary assumption here is that the CORS file lists in order GPS,
    % GLONASS and then Galileo
    for ii = 1:length(satDescription.GPS)
    
        [satData(ii,:),lineCount] = readSatEopch(fileID,obsTypes,lineCount);

    end

    currentData.GPSObservables = satData;
    satData = [];

    for ii = 1:length(satDescription.GLO)

        [satData(ii,:),lineCount] = readSatEopch(fileID,obsTypes,lineCount);

    end

    currentData.GLOObservables = satData;
    satData = [];

    for ii = 1:length(satDescription.GAL)

        [satData(ii,:),lineCount] = readSatEopch(fileID,obsTypes,lineCount);

    end

    currentData.GALObservables = satData;
    
    gnssData{count} = currentData;
    count = count + 1;
    lineCount;

end
gnssData = gnssData';

end