function delays = klobucharModel(obj,time,satPos)
% Implementation of the Klobuchar Model using GPS Ephemeris
% Landon Boyd
% 10/11/2024


lla0 = ecef2lla(obj.obsData.antPos');
AER = ecef2aer2(satPos,lla0);

% Convert E to semicircles
E = deg2rad(E) ./ pi;

psi = 0.0137./(1)




end