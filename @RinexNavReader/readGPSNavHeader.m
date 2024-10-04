function [ionoAlpha,ionoBeta,deltaUTC,leapSeconds,headerCount] = ...
            readGPSNavHeader(obj,fileID)
% Function to read the information from the header that I care about
% Landon Boyd
% 10/04/2024

line = fgetl(fileID);
label = line(61:80);
headerCount = 1;

ionoAlpha = [0,0,0];
ionoBeta = [0,0,0];
deltaUTC = [0,0,0,0];
leapSeconds = 0;

while label ~= "END OF HEADER"


    line = fgetl(fileID);
    label = line(61:end);
    headerCount = headerCount + 1;

    switch label
        case "ION ALPHA"
            alphaText = {line(1:16),line(17:27),line(28:39),line(40:54)};
            for ii = 1:4
                ionoAlpha(ii) = cast2double(alphaText{ii});
            end
        case "ION BETA"
            betaText = {line(1:16),line(17:27),line(28:39),line(40:54)};
            for ii = 1:4
                ionoBeta(ii)= cast2double(betaText{ii});
            end
        case "DELTA-UTC: A0,A1,T,W"
            warning("No Delta UTC Definition")
        case "LEAP SECONDS"
            warning("No Leap Second Definition");
        otherwise
    end

end

end

function doubleNum = cast2double(number)

% Replace 'D' with 'e'
number(number == 'D') = 'e';
doubleNum = str2double(number);

end