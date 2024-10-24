function dopplerMeasurements(obj)
% Function that calculates a Doppler observable from a CORS file that only
% has carrier ranges. Observation data must be loaded before this method is
% run
% Landon Boyd
% 10/12/2024

numEpochs = length(obj.obsData.obsTimes);

L1Present = any(obj.obsData.obsTypes == "L1");
L2Present = any(obj.obsData.obsTypes == "L2");
L5Present = any(obj.obsData.obsTypes == "L5");


idx = nan(1,3);
if L1Present
    idx(1) = find(obj.obsData.obsTypes == "L1");
    % obj.obsData.obsTypes{end+1} = 'D1';
end
if L2Present
    idx(2) = find(obj.obsData.obsTypes == "L2");
    % obj.obsData.obsTypes{end+1} = 'D2';
end
if L5Present
    idx(3) = find(obj.obsData.obsTypes == "L5");
    % obj.obsData.obsTypes{end+1} = 'D5';
end

idx(isnan(idx)) = [];

for ii = 1:numEpochs-1 % Doppler is forward differenced

    time1 = obj.obsData.obsTimes(ii);
    time2 = obj.obsData.obsTimes(ii+1);
    sats1 = obj.obsData.gnssData{ii}.constellation.GPS;
    sats2 = obj.obsData.gnssData{ii+1}.constellation.GPS;
    obs1 = obj.obsData.gnssData{ii}.GPSObservables(:,idx);
    obs2 = obj.obsData.gnssData{ii+1}.GPSObservables(:,idx);

    % % Find satellites that are in only 1 of the epochs and remove
    % [~,idx3] = setdiff(sats1,sats2);
    % [~,idx4] = setdiff(sats2,sats1);
    % 
    % sats1Temp = sats1;
    % sats2Temp = sats2;
    % sats1Temp(idx3) = [];
    % sats2Temp(idx4) = [];
    % 
    
    % Format next epoch of sats and pad observations if number of sats
    % isn't the same
    [sats1Temp,idx4] = reconstructSet(sats2,sats1,nan);
    [sats2Temp,idx3] = reconstructSet(sats1,sats2,nan);
    obs1Temp = matrixRowInsert(obs1,idx4,nan);
    obs2Temp = matrixRowInsert(obs2,idx3,nan);

    % % Find satellites that are in both epochs. This step is still necessary
    % % because even though the set of satellites is the same, the order
    % % might have changed
    % [~,idx1] = intersect(sats1,sats2Temp);
    % [~,idx2] = intersect(sats2Temp,sats1);
    % 
    % 

    % Get time difference
    dt = seconds(time2 - time1);

    % Calculate Doppler and assign to observables idx1 and idx2 contain the
    % location of the common satellites in both arrays. idx contains the
    % location of the carrier phase measurements. Because its a forward
    % difference, we only care about satellites that are present at the
    % current epoch, so any satellites that appear later must be removed
    % here
    dopplerShift = (obs2Temp - obs1Temp) ./ dt;
    dopplerShift(idx4,:) = [];
    newObs = [obj.obsData.gnssData{ii}.GPSObservables,dopplerShift];
    obj.obsData.gnssData{ii}.GPSObservables = newObs;

end

end

function [output,newIdx] = reconstructSet(set1,set2,marker)
% Function to repopulate a list of numbers based on the elements of another
% list, leaving marker as the filler value for elements not present. This
% function assumes that even though set1 and set2 don't have the same
% elements, they are ordered by the same scheme.
% Example : set1 = [1 2 3];
%           set2 = [2 3];
%           marker = nan;
%           reconstructSet(set1,set2,marker) = [nan 2 3]
% Landon Boyd
% 10/15/2024

arguments
    set1 (1,:)
    set2 (1,:)
    marker (1,1)
end

% Find elements in 1 not in 2
[~,ia] = setdiff(set1,set2);
ia = sort(ia);

for ii = 1:length(ia)
    set2 = [set2(1:ia(ii)-1),marker,set2(ia(ii):end)];
end

output = set2;
newIdx = ia;

end

function output = matrixRowInsert(set,newIdx,marker)
% matrixInsert traverses a matrix and inserts elements of type marker at
% each newIdx
% Landon Boyd
% 10/15/2024

numCol = size(set,2);

for ii = 1:length(newIdx)
    set = [set(1:newIdx(ii)-1,:);marker*ones(1,numCol);set(newIdx(ii):end,:)];
end

output = set;

end
