function gnssData = rinexDataRead(filename)

[obsTypes, antHEN] = anheader(filename);

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

    % Either 1, 2 or 3 characters for number of satellites. This code is
    % wonky, but is a consequence of choosing to build this whole library
    % on the >>split command
    numSats = epochHeaderLine1{end};
    if ~isnan(str2double(numSats(1:3)))
        numSats = str2double(numSats(1:3));
    elseif ~isnan(str2double(numSats(1:2)))
        numSats = str2double(numSats(1:2));
    else
        numSats = str2double(numSats(1));
    end

    % Constellation description is the last element of the array, and is
    % possibly continues on the next line
    constellation = epochHeaderLine1{end};

    % If more than 12 satellites, must grab two lines instead of one
    if numSats > 12
        epochHeaderLine2 = split(fgetl(fileID));
        lineCount = lineCount + 1;

        % Join our additional constellation data to what we already have
        constellation = [constellation,epochHeaderLine2{end}];
    end

    % Read in the constellation term and save
    satDescription = readConstellation(numSats,constellation);
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

        [satData(ii,:),lineCount] = readSatEpoch(fileID,obsTypes,lineCount);

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

function [obsTypes, antHEN] = anheader(file)
% ANHEADER Analyzes the header of a RINEX file and outputs
%	       the list of observation types and antenna offset.
%	       End of file is flagged 1, else 0. Likewise for the types.
%	       Typical call: anheader('pta.96o')

% Kai Borre 09-12-96
% Copyright (c) by Kai Borre
% $Revision: 1.0 $   $Date: 1997/09/23  $
% Adapted Landon Boyd
% 2022/10/03

fid = fopen(file,'rt');

% Gobbling the header
while 1
    line = fgetl(fid);

    if contains(line,'END OF HEADER')
        break;
    end

    if (line == -1)
        eof = 1;
        break;
    end

    % Antenna Height and eccentricities
    if contains(line,'ANTENNA: DELTA H/E/N')
        antHEN = split(line);
        antHEN = [str2double(antHEN{2}),str2double(antHEN{3}),...
            str2double(antHEN{4})];
    end

    % Pull down observation types
    if contains(line,'# / TYPES OF OBSERV')

        obsLine = split(line);
        numObs = str2double(obsLine{2});

        % Cell array to store observation types data
        obsTypes = {};

        % If more than 9 types of obsersvations, must read more than 1 line
        % of data. Hopefully I'll never need more than 3 lines
        if (numObs < 9)
            obsTypes = readObsLine(line,obsTypes);
        elseif (numObs > 9) && (numObs < 18)
            % Get the lines we want
            line1 = line;
            line2 = fgetl(fid);

            % Read data
            obsTypes = readObsLine(line1,obsTypes);
            obsTypes = readObsLine(line2,obsTypes);
        elseif (numObs > 18) && (numObs < 27)
            % Get the lines we want
            line1 = line;
            line2 = fgetl(fid);
            line3 = fgetl(fid);

            % Read data
            obsTypes = readObsLine(line1,obsTypes);
            obsTypes = readObsLine(line2,obsTypes);
            obsTypes = readObsLine(line3,obsTypes);
        end

    end
end

end

function newData = readObsLine(line,data)
% line - string to analyze for more data
% data - original cell array. New discoveries will be appended
%        to the end of this array and returned

line = erase(line,"# / TYPES OF OBSERV");
dataCells = split(line);
newData = data; % add on to this
% Iterate through line
for ii = 1:length(dataCells)

    % Changing this to a switch statement. Currently only supporting GPS on
    % L1 and L2. Eventually each of these could potentially trigger
    % different response which is why I've put them in a switch
    switch dataCells{ii}
        case 'C1'
            newData{end+1} = dataCells{ii};
        case 'C2'
            newData{end+1} = dataCells{ii};
        case 'L1'
            newData{end+1} = dataCells{ii};
        case 'L2'
            newData{end+1} = dataCells{ii};
        case 'S1'
            newData{end+1} = dataCells{ii};
        case 'S2'
            newData{end+1} = dataCells{ii};
        case 'D1'
            newData{end+1} = dataCells{ii};
        case 'D2'
            newData{end+1} = dataCells{ii};
        otherwise
    end

end

end

function output = readConstellation(numSats,input)
% readConstellation.m is a MATLAB function to read the constellation
% identifying string in a RINEX 2.11 file and output the types and numbers
% of satellites present in the file
% Inputs:
%       - input - a character array of the format specifier in the header
% Outputs:
%       - output - a struct with fields for GPS, GLONASS and Galileo
%
% example: readConstellation('22G01G13G14G15G17G19G21G24G30R03R04R11R12R13R21R23E05E09E24E26E31E33')
constellationIDs = 'GRE';

output = struct;
output.GPS = [];
output.GLO = [];
output.GAL = [];

if numSats > 99
    input = input(4:end);
elseif numSats > 9
    input = input(3:end);
else
    input = input(2:end);
end

for ii = 1:numSats

    % Read sat type and erase
    satType = input(1);
    input = input(2:end);

    % Read satellite number and erase
    switch satType
        case constellationIDs(1)
            output.GPS(end+1) = str2double(input(1:2));
            input = input(3:end);
        case constellationIDs(2)
            output.GLO(end+1) = str2double(input(1:2));
            input = input(3:end);
        case constellationIDs(3)
            output.GAL(end+1) = str2double(input(1:2));
            input = input(3:end);
    end

end

end

function [epochData,lineCount] = readSatEpoch(fileID,obsTypes,lineCount)
% This function reads the observables from a single satellite out of the
% field of the Rinex observation file. The older version made some
% assumptions that caused it to break on some types of files, so this one
% is hopefully more robust
% Landon Boyd
% 10/05/2024

if length(obsTypes) > 5
    obsData = [fgetl(fileID),fgetl(fileID)];
    lineCount = lineCount + 2;
else
    obsData = fgetl(fileID);
    lineCount = lineCount + 1;
end

epochData = str2double(split(obsData));

% For some reason, some observables have an integer after them and I'm
% dubious as to whether thats an LLI flag or a signal strength indicator.
% Either way I'm removing it for now and if I need it later this is where
% it can be found

for ii = 1:length(epochData)
    if ((epochData(ii) < 11))
        epochData(ii) = nan;
    end
end

epochData(isnan(epochData)) = [];

if length(epochData) ~= length(obsTypes)
    warning("Observation mismatch has occured, possible error in RINEX file")
    epochData = nan(1,length(obsTypes));
end


end

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

function output = matchRinexData(data,obsTypes)

% Set logical limits
phaseLim = 150000000;
codeLim = 30000000;
SNRLim = 70;
LLILim = 10;

% C1 and P1 are duplicates and mess up the counting, remove them
for ii = 1:length(obsTypes)-1

    arr1 = obsTypes{ii};
    arr2 = obsTypes{ii+1};

    % Mark duplicates. If theres a P-C duo on the same band then delete
    % one
    if (arr1(1) == 'C' && arr2(1) == 'P') && (str2double(arr1(2)) == str2double(arr2(2)))
        obsTypes{ii+1} = 'erase';
    end
end

obsTypes(ismember(obsTypes,'erase')) = [];

% Count through the data
for ii = 1:length(obsTypes)

    found = 0;
    switch obsTypes{ii}

        case 'L1' % L1 phase measurement
            % Find the L1 phase in the data and remove it
            for jj = 1:length(data)
                if (data(jj) <= phaseLim) && (data(jj) >= codeLim)
                    satStruct.L1phase = data(jj);
                    found = 1;
                    break
                end
            end
            if ~found
                satStruct.L1phase = 0;
            end

        case 'L2'
            % Find the L2 phase in the data and remove it
            for jj = 1:length(data)
                if (data(jj) <= phaseLim) && (data(jj) >= codeLim)
                    satStruct.L2phase = data(jj);
                    found = 1;
                    break
                end
            end
            if ~found
                satStruct.L2phase = 0;
            end

        case 'L5'
            % Find the L5 phase in the data and remove it
            for jj = 1:length(data)
                if (data(jj) <= phaseLim) && (data(jj) >= codeLim)
                    satStruct.L5phase = data(jj);
                    found = 1;
                    break
                end
            end
            if ~found
                satStruct.L5phase = 0;
            end

        case {'C1','P1'}
            % Find the L1 psuedorange data and remove it
            for jj = 1:length(data)
                if (data(jj) <= codeLim) && (data(jj) >= SNRLim)
                    satStruct.L1psr = data(jj);
                    found = 1;
                    break
                end
            end
            if ~found
                satStruct.L1psr  = 0;
            end

        case {'C2','P2'}
            % Find the L2 psuedorange data and remove it
            for jj = 1:length(data)
                if (data(jj) <= codeLim) && (data(jj) >= SNRLim)
                    satStruct.L2psr = data(jj);
                    found = 1;
                    break
                end
            end
            if ~found
                satStruct.L2psr  = 0;
            end

        case {'C5','P5'}
            % Find the L2 psuedorange data and remove it
            for jj = 1:length(data)
                if (data(jj) <= codeLim) && (data(jj) >= SNRLim)
                    satStruct.L5psr = data(jj);
                    found = 1;
                    break
                end
            end
            if ~found
                satStruct.L5psr  = 0;
            end

        case 'S1'
            % Find the L1 SNR data and remove it
            for jj = 1:length(data)
                if (data(jj) <= SNRLim) && (data(jj) >= LLILim)
                    satStruct.L1SNR = data(jj);
                    found = 1;
                    break
                end
            end
            if ~found
                satStruct.L1SNR = 0;
            end

        case 'S2'
            % Find the L1 SNR data and remove it
            for jj = 1:length(data)
                if (data(jj) <= SNRLim) && (data(jj) >= LLILim)
                    satStruct.L2SNR = data(jj);
                    found = 1;
                    break
                end
            end
            if ~found
                satStruct.L2SNR = 0;
            end

        case 'S5'
            % Find the L1 SNR data and remove it
            for jj = 1:length(data)
                if (data(jj) <= SNRLim) && (data(jj) >= LLILim)
                    satStruct.L5SNR = data(jj);
                    found = 1;
                    break
                end
            end
            if ~found
                satStruct.L5SNR = 0;
            end

        otherwise
            error('Format specifier ' + obsTypes{ii} + ' not recognized')

    end

    % Delete entry we just processed if we found a match
    if found
        data(jj) = nan;
    end

end

% Convert output to a matrix so that it can be used in the outer function
field = fieldnames(satStruct);

for ii = 1:length(field)
    output(ii) = satStruct.(field{ii});
end

end