function navData = rinexGPSNavRead(obj,filename)
% Function to read the GPS navigation rinex file to extract ephemeris
% Landon Boyd
% 10/04/2024

fileID = fopen(filename,'r');

% Read header
[ionoAlpha,ionoBeta,deltaUTC,leapSeconds,headerCount] = ...
    obj.readGPSNavHeader(fileID);

% Read ephemeris message. Best I can tell, the CORS data reports new
% ephemeris as soon as it is available -> every 2 hours
prnEphemTotal = countEphemEpochs(fileID);
prnEphemCount = ones(1,length(prnEphemTotal));

% Set up data structure for each issued ephemeris epoch
messageEphemeris = cell(1,length(prnEphemTotal));
for ii = 1:length(prnEphemTotal)
    messageEphemeris{ii} = zeros(prnEphemTotal(ii),1);
end

while ~feof(fileID)

    epochEphem = readGPSEphem(fileID);
    prnCount = prnEphemCount(epochEphem.prn);
    prnEphemCount(epochEphem.prn) = prnEphemCount(epochEphem.prn) + 1;
    messageEphemeris{prnCount,epochEphem.prn} = epochEphem;

end

navData = struct;
navData.ephemeris = messageEphemeris;
navData.ionoAlpha = ionoAlpha;
navData.ionoBeta = ionoBeta;

end

function prnEphemCount = countEphemEpochs(fileID)
% Function to scan an ephemeris RINEX file to determine how many epochs of
% issued ephemeris exist for each satellite. Currently only works for the
% GPS constellation

% Function assumes that the pointer of fileID is at the start of the first
% line of the first observation epoch

% Landon Boyd - 10/04/2024

ptr = ftell(fileID);
prnEphemCount = zeros(1,32);


while ~feof(fileID)

    % Get the first line with the PRN, skip the next 7 lines
    dataLine = fgetl(fileID);
    for ii = 1:7
        fgetl(fileID);
    end

    % Increase the ephemeris count
    idx = str2double(dataLine(1:2));
    prnEphemCount(idx) = prnEphemCount(idx) + 1;

end

% Reset file pointer
fseek(fileID,ptr,"bof");

end

function epochEphem = readGPSEphem(fileID)
% This function reads in the 8 lines of ephemeris for each satellite
% starting at where the pointer of fileID is located. Returns a structure
% of the ephemeris message in doubles

data = cell(8,1);
epochEphem = struct;
for ii = 1:8
    data{ii} = fgetl(fileID);
end

% Ephemeris Time
epochEphem.prn = str2double(data{1}(1:2));
year = 2000 + str2double(data{1}(4:5));
month = str2double(data{1}(7:8));
day = str2double(data{1}(10:11));
hour = str2double(data{1}(13:14));
minute = str2double(data{1}(16:17));
second = str2double(data{1}(19:22));
epochEphem.time = datetime(year,month,day,hour,minute,second);
epochEphem.TOC = GPSdatetime(epochEphem.time);

% Satellite Clock Offset
epochEphem.a0 = cast2double(data{1}(23:41));
epochEphem.a1 = cast2double(data{1}(42:60));
epochEphem.a2 = cast2double(data{1}(61:end));

% Line 2
epochEphem.IODE = cast2double(data{2}(1:22));
epochEphem.Crs = cast2double(data{2}(23:41));
epochEphem.deltaN = cast2double(data{2}(42:60));
epochEphem.M0 = cast2double(data{2}(61:end));

% Line 3
epochEphem.Cuc = cast2double(data{3}(1:22));
epochEphem.e = cast2double(data{3}(23:41));
epochEphem.Cus = cast2double(data{3}(42:60));
epochEphem.sqrtA = cast2double(data{3}(61:end));

% Line 4
epochEphem.TOE = cast2double(data{4}(1:22));
epochEphem.Cic = cast2double(data{4}(23:41));
epochEphem.OMEGA = cast2double(data{4}(42:60));
epochEphem.Cis = cast2double(data{4}(61:end));

% Line 5
epochEphem.i0 = cast2double(data{5}(1:22));
epochEphem.Crc = cast2double(data{5}(23:41));
epochEphem.omega = cast2double(data{5}(42:60));
epochEphem.OMEGADOT = cast2double(data{5}(61:end));

% Line 6
epochEphem.iDot = cast2double(data{6}(1:22));
epochEphem.L2Code = cast2double(data{6}(23:41));
epochEphem.week = cast2double(data{6}(42:60));
epochEphem.L2P = cast2double(data{6}(61:end));

% Line 7
epochEphem.SVAccuracy = cast2double(data{7}(1:22));
epochEphem.SVHealth = cast2double(data{7}(23:41));
epochEphem.TGD = cast2double(data{7}(42:60));
epochEphem.IODC = cast2double(data{7}(61:end));

% Line 8
epochEphem.transmissionTime = cast2double(data{7}(1:22));
epochEphem.fitInterval = cast2double(data{7}(23:41));

end

function doubleNum = cast2double(number)

% Replace 'D' with 'e'
number(number == 'D') = 'e';
doubleNum = str2double(number);

end

