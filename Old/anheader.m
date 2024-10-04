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
        
        % Check for end of line and for empty entries and number of
        % signals. We don't want any of those...
        if ~(isempty(dataCells{ii})) && ...
                (isnan(str2double(dataCells{ii})))
            newData{end+1} = dataCells{ii};
        end
    end

end
