function gnssData = rinexDataRead(filename,obsTypes)

fileID = fopen(filename,'r');

% Count through header lines --K
headerCount = 0;
while 1
   headerCount = headerCount+1;
   epochHeaderLine1 = fgetl(fileID);

   if contains(epochHeaderLine1,"END OF HEADER")
       break;	
   end
end

% Try top predict how many entries we should be looking for. For the number
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

    % A primary assumption here is that the CORS file lists in order GPS,
    % GLONASS and then Galileo
    for ii = 1:length(satDescription.GPS)
        % Get the two lines of data and parse
        dataLine1 = split(fgetl(fileID));
        dataLine2 = split(fgetl(fileID));

        % For some reason the first element is always an empty character
        % array. Also I dont knwo what the number at the beginning of the
        % observation list is but I can use it later if I want it
        dataLine1 = dataLine1(2:end);
        dataLine2 = dataLine2(2:end);


        % Convert to a number
        obsData = str2double([dataLine1;dataLine2]);

        % Extract message for the satellite in question
        satStruct = matchRinexData(obsData,obsTypes)

    end

    for ii = 1:length(satDescription.GLO)
        % Get the two lines of data and parse
        dataLine1 = split(fgetl(fileID));
        dataLine2 = split(fgetl(fileID));

        % For some reason the first element is always an empty character
        % array. Also I dont knwo what the number at the beginning of the
        % observation list is but I can use it later if I want it
        dataLine1 = dataLine1(2:end);
        dataLine2 = dataLine2(2:end);


        % Convert to a number
        obsData = str2double([dataLine1;dataLine2]);

        % Remove the loss of lock indicator
        obsData(obsData < 10) = [];


        % Store
        currentData.GLOObservables(ii,:) = obsData';

    end





%     % Store observables in a table later. The extra column is to store SV
%     % PRN later on
%     observables = zeros(length(svList),numFields+1);

    


%     % Count through all of the observables for each satellite in the epoch
%     for ii = 1:numSats
% 
%         obsCount = 0    ;
%         lineCount = 1   ;
% 
%         % Keep counting until we have all of the measurements we expect
%         while obsCount < numFields
% 
%             % Get a line to read
%             line = split(fgetl(fileID));
% 
%             % I'm not sure what the special number on the first line is but
%             % I will know one day and then this part will have meaning
%             if lineCount == 1
%                 line{3} = '';
%             end
% 
%             % Count through all nonzero elements in order based of obsTypes
%             for jj = 1:length(line)
% 
%                 % If not an empty character vector or a letter then add to
%                 % our data matrix
%                 if ~(isempty(line{jj}))
%                     observables(ii,obsCount+2) = str2double(line{jj});
%                     obsCount = obsCount + 1;
%                 end
%             end
% 
%             lineCount = lineCount + 1;
%     
%         end
%         currentData.observables = observables;
%     end
    
    gnssData{count} = currentData;
    count = count + 1
end

end