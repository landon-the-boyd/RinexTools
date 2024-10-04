function output = readConstellation(input)
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

% Read the number of satellites and erase
numSats = str2double(input(1:2));
input = input(3:end);

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