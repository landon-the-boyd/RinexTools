function [observables,satPos,satVel,satClock,TOW,time,satsInView] = returnEpoch(obj,index)
% Function that offers a clean interface to get all of the necessary data
% out of the object
% Landon Boyd
% 10/05/2024

TOW = obj.obsData.gnssData{index}.TOW;
time = obj.obsData.gnssData{index}.time;
satsInView = obj.obsData.gnssData{index}.constellation.GPS;
observables = obj.obsData.gnssData{index}.GPSObservables;
ephemerisSet = obj.returnParameterSet(time);

satPos = nan(length(satsInView),3);
satVel = nan(length(satsInView),3);
satClock = nan(length(satsInView),1);

for ii = 1:length(satsInView)
    [satPos(ii,:),satVel(ii,:),satClock(ii)] = ...
        obj.GPSEphemerisCalculation(ephemerisSet{satsInView(ii)},TOW,TOW-0.07);
end






end