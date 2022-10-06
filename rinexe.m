function rinexe(ephemerFile, outputfile)
% RINEXE Reads a RINEX Navigation Message file and
%	     reformats the data into a matrix with 21
%	     rows and a column for each satellite.
%	     The matrix is stored in a MATLAB variable
%        by the name of outputfile

% Typical call: rinexe('pta.96n','matlabVar')

% Kai Borre 04-18-96
% Copyright (c) by Kai Borre
% $Revision: 1.0 $  $Date: 1997/09/24  $
% Adapted Landon Boyd
% 2022/10/03

% Units are either seconds, meters, or radians
fileID = fopen(ephemerFile);
head_lines = 0;

% We skip header
while 1
   head_lines = head_lines+1;
   line = fgetl(fileID);

   if contains(line,"END OF HEADER")
       break;	
   end
end

% Count how many lines of ephemeris
noeph = -1;
while 1
   noeph = noeph+1;
   line = fgetl(fileID);
   if line == -1
       break;  
   end
end

% 8 Lines of ephemeris to a block
noeph = noeph/8;
frewind(fileID);

% Skip Header
for i = 1:head_lines
    line = fgetl(fileID); 
end

% Set aside memory for the input
svprn	= zeros(1,noeph);
weekno	= zeros(1,noeph);
t0c	    = zeros(1,noeph);
tgd	    = zeros(1,noeph);
aodc	= zeros(1,noeph);
toe	    = zeros(1,noeph);
af2	    = zeros(1,noeph);
af1	    = zeros(1,noeph);
af0	    = zeros(1,noeph);
aode	= zeros(1,noeph);
deltan	= zeros(1,noeph);
M0	    = zeros(1,noeph);
ecc	    = zeros(1,noeph);
roota	= zeros(1,noeph);
toe	    = zeros(1,noeph);
cic	    = zeros(1,noeph);
crc	    = zeros(1,noeph);
cis	    = zeros(1,noeph);
crs	    = zeros(1,noeph);
cuc	    = zeros(1,noeph);
cus	    = zeros(1,noeph);
Omega0	= zeros(1,noeph);
omega	= zeros(1,noeph);
i0	    = zeros(1,noeph);
Omegadot= zeros(1,noeph);
idot	= zeros(1,noeph);
accuracy= zeros(1,noeph);
health	= zeros(1,noeph);
fit	    = zeros(1,noeph);


for i = 1:noeph
    % Line 1
    line = fgetl(fileID);
    svprn(i) = str2num(line(1:2));
    year     = line(3:6);
    month    = line(7:9);
    day      = line(10:12);
    hour     = line(13:15);
    minute   = line(16:18);
    second   = line(19:22);
    af0(i)   = str2num(line(23:41));
    af1(i)   = str2num(line(42:60));
    af2(i)   = str2num(line(61:79));

    % Line 2
    line = fgetl(fileID);
    IODE        = line(4:22);
    crs(i)      = str2num(line(23:41));
    deltan(i)   = str2num(line(42:60));
    M0(i)       = str2num(line(61:79));

    % Line 3
    line = fgetl(fileID);
    cuc(i)      = str2num(line(4:22));
    ecc(i)      = str2num(line(23:41));
    cus(i)      = str2num(line(42:60));
    roota(i)    = str2num(line(61:79));

    % Line 4
    line = fgetl(fileID);
    toe(i)      = str2num(line(4:22));
    cic(i)      = str2num(line(23:41));
    Omega0(i)   = str2num(line(42:60));
    cis(i)      = str2num(line(61:79));

    % Line 5
    line = fgetl(fileID);
    i0(i) =  str2num(line(4:22));
    crc(i) = str2num(line(23:41));
    omega(i) = str2num(line(42:60));
    Omegadot(i) = str2num(line(61:79));

    % Line 6
    line = fgetl(fileID);
    idot(i)     = str2num(line(4:22));
    codes       = str2num(line(23:41));
    weekno      = str2num(line(42:60));
    L2flag      = str2num(line(61:79));

    % Line 7
    line = fgetl(fileID);
    svaccur     = str2num(line(4:22));
    svhealth    = str2num(line(23:41));
    tgd(i)      = str2num(line(42:60));
    iodc        = line(61:79);

    % Line 8
    line = fgetl(fileID);	
    tom(i) = str2num(line(4:22));
    spare = line(23:41);

end

% Close ephemeris
fclose(fileID);

%  Description of variable eph.
eph(1,:)  = svprn;
eph(2,:)  = af2;
eph(3,:)  = M0;
eph(4,:)  = roota;
eph(5,:)  = deltan;
eph(6,:)  = ecc;
eph(7,:)  = omega;
eph(8,:)  = cuc;
eph(9,:)  = cus;
eph(10,:) = crc;
eph(11,:) = crs;
eph(12,:) = i0;
eph(13,:) = idot;
eph(14,:) = cic;
eph(15,:) = cis;
eph(16,:) = Omega0;
eph(17,:) = Omegadot;
eph(18,:) = toe;
eph(19,:) = af0;
eph(20,:) = af1;
eph(21,:) = toe;

% Organize the ephemeris into a struct
ephStruct = struct;
satPresent = unique(eph(1,:));

% Create a field for each satellite present
for ii = 1:length(satPresent)
    name = ("prn" + num2str(satPresent(ii)));
    ephStruct.(name) = [];
end

for ii = 1:size(eph,2)
    prn = eph(1,ii);
    name = ("prn"+prn);

    ephStruct.(name) = [ephStruct.(name),eph(:,ii)];

end

% Save data in matlab file
save(outputfile,"eph")
end