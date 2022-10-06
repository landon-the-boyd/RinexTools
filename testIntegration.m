%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Setup
clear
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Define Inputs
addpath("Data\chcm\");
% Define observation, navigation and glonass filenames
obs = 'chcm2440.22o';
nav = 'chcm2440.22n';
gloNav = 'chcm2440.22g';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Gather Information
% Gather ephemeris from package we downloaded
ephem = rinexe(nav);

% Read the header elements
[obsTypes, antHEN] = anheader(obs);

% Read the observables for GPS
gnssData = rinexDataRead(obs,obsTypes);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Translate and Save
% Traverse obsTypes and write them to RCVR_data
% Make ObsTypes a thing that gets passed with every cell of gnssData
RCVR_data = formatData(obsTypes,ephem,gnssData);


function outVar = formatData(obsTypes,ephem,gnssData)

outVar = cell(length(gnssData),1);

% Generate the output structure that we desire
for ii = 1:length(gnssData)

    % We have to traverse obsTypes initially to set the values for struct
    % fields
    for jj = 1:length(obsTypes)

        switch obsTypes{jj}

            case 'L1' % L1 phase measurement
                dataStruct.obs.L1.carr = [];
                dataStruct.obs.L1.dopp = [];
            case 'L2'
                dataStruct.obs.L2.carr = [];
                dataStruct.obs.L2.dopp = [];
            case 'L5'
                dataStruct.obs.L5.carr = [];
                dataStruct.obs.L5.dopp = [];
            case {'C1','P1'}
                dataStruct.obs.L1.psr = [];
            case {'C2','P2'}
                dataStruct.obs.L2.psr = [];
            case {'C5','P5'}
                dataStruct.obs.L5.psr = [];
            case 'S1'
                dataStruct.obs.L1.cno = [];
            case 'S2'
                dataStruct.obs.L2.cno = [];
            case 'S5'
                dataStruct.obs.L5.cno = [];
            otherwise
                error('Format specifier ' + obsTypes{ii} + ' not recognized')
        end
    end

    % C1 and P1 are duplicates and mess up the counting, remove them
    for jj = 1:length(obsTypes)-1

        arr1 = obsTypes{jj};
        arr2 = obsTypes{jj+1};

        % Mark duplicates. If theres a P-C duo on the same band then delete
        % one
        if (arr1(1) == 'C' && arr2(1) == 'P') && (str2double(arr1(2)) == str2double(arr2(2)))
            obsTypes{jj+1} = 'erase';
        end
    end
    obsTypes(ismember(obsTypes,'erase')) = [];

    % Traverse obsTypes and generate fields in dataStruct. If the field
    % doesnt exist then generate it
    for jj = 1:length(obsTypes)

        
        svList = gnssData{ii}.constellation.GPS;
        svData = gnssData{ii}.GPSObservables(:,jj);

        switch obsTypes{jj}

            case 'L1' % L1 phase measurement
                dataStruct.obs.L1.carr(ii,:) = populateNan(svList,svData);
            case 'L2'
                dataStruct.obs.L2.carr(ii,:) = populateNan(svList,svData);
            case 'L5'
                dataStruct.obs.L5.carr(ii,:) = populateNan(svList,svData);
            case {'C1','P1'}
                dataStruct.obs.L1.psr(ii,:) = populateNan(svList,svData);
            case {'C2','P2'}
                dataStruct.obs.L2.psr(ii,:) = populateNan(svList,svData);
            case {'C5','P5'}
                dataStruct.obs.L5.psr(ii,:) = populateNan(svList,svData);
            case 'S1'
                dataStruct.obs.L1.cno(ii,:) = populateNan(svList,svData);
            case 'S2'
                dataStruct.obs.L2.cno(ii,:) = populateNan(svList,svData);
            case 'S5'
                dataStruct.obs.L5.cno(ii,:) = populateNan(svList,svData);
            otherwise
                error('Format specifier ' + obsTypes{ii} + ' not recognized')

        end


    end

    % Construct GPS Time
    year = num2str(gnssData{ii}.year);
    month = dateFill(num2str(gnssData{ii}.month));
    day = dateFill(num2str(gnssData{ii}.day));
    hour = dateFill(num2str(gnssData{ii}.hour));
    minute = dateFill(num2str(gnssData{ii}.minute));
    second = num2str(gnssData{ii}.minute);

    dateString = strcat("20",year,"-",month,"-",day," ",hour,":",minute,":",second);
    [tow, day, gpsWeek, rollover, leapSecond] = GPSdatetime(datetime(dateString));


    dataStruct.ephem = ephem;
    dataStruct.gpsWeek = gpsWeek;
    outVar{ii} = dataStruct;
end

end

function output = populateNan(svList,svData)

output = zeros(1,32);

% Assumption that the data is counting upwards from 1 to 32
for ii = 1:32
    lia = ismember(ii,svList);

    if ismember(ii,svList)
        output(ii) = svData(lia);
    else
        output(ii) = nan;
    end
end

end

function output = dateFill(input)

if length(input) < 2
    output = strcat("0",input);
else
    output = input;
end

end