function gnssData = rinexDataRead(filename,obsTypes)

fileID = fopen(filename,'r');

% Count through header lines --K
headerCount = 0;
while 1
   headerCount = headerCount+1;
   line = fgetl(fileID);

   if contains(line,"END OF HEADER")
       break;	
   end
end

% Try top predict how many entries we should be looking for. For the number
% of claimed observables, it would appear that each band reduces this
% number of actual entries in data by 1. I think this is because C1/P1 is
% listed as a single entry
numFields = length(obsTypes);
if ismember("L1",obsTypes)
    numFields = numFields - 1;
end
if ismember("L2",obsTypes)
    numFields = numFields - 1;
end
if ismember("L5",obsTypes)
    numFields = numFields - 1;
end

gnssData = {};
count = 1;
while ~feof(fileID)

    % Arrange data in a cell of structs
    currentData = struct;

    % Read in the epoch time and listed satellites
    line = split(fgetl(fileID));

    % All time values from epoch
    currentData.year = str2double(line{2});
    currentData.month = str2double(line{3});
    currentData.day = str2double(line{4});
    currentData.hour = str2double(line{5});
    currentData.minute = str2double(line{6});
    currentData.second = str2double(line{7});

    % Try and take apart the satellite term. For now I can only handle GPS
    % satellites, no Galileo or Glonass
    svList = split(replace(char(line{end}),'G',' '));
    
    % The first number of this term is the number of satellites observed,
    % remove it from the array
    numSats = str2double(svList{1});
    svList(1) = [];

    % Store observables in a table later. The extra column is to store SV
    % PRN later on
    observables = zeros(length(svList),numFields+1);

    % Count through all of the observables for each satellite in the epoch
    for ii = 1:numSats

        obsCount = 0    ;
        lineCount = 1   ;

        % Keep counting until we have all of the measurements we expect
        while obsCount < numFields

            % Get a line to read
            line = split(fgetl(fileID));

            % I'm not sure what the special number on the first line is but
            % I will know one day and then this part will have meaning
            if lineCount == 1
                line{3} = '';
            end

            % Count through all nonzero elements in order based of obsTypes
            for jj = 1:length(line)

                % If not an empty character vector or a letter then add to
                % our data matrix
                if ~(isempty(line{jj}))
                    observables(ii,obsCount+2) = str2double(line{jj});
                    obsCount = obsCount + 1;
                end
            end

            lineCount = lineCount + 1;
    
        end
        currentData.observables = observables;
    end
    
    gnssData{count} = currentData;
    count = count + 1
end

end