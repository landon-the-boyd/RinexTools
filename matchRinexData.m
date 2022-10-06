function output = matchRinexData(data,obsTypes)

% Set logical limits
phaseLim = 150000000;
codeLim = 30000000;
SNRLim = 70;
LLILim = 10;

% C1 and P1 are duplicates and mess up the counting, remove them
for ii = 1:length(obsTypes)-1

    arr1 = obsTypes{ii};
    arr2 = obsTypes{ii+1};

    % Mark duplicates. If theres a P-C duo on the same band then delete
    % one
    if (arr1(1) == 'C' && arr2(1) == 'P') && (str2double(arr1(2)) == str2double(arr2(2)))
        obsTypes{ii+1} = 'erase';
    end
end

obsTypes(ismember(obsTypes,'erase')) = [];

% Count through the data
for ii = 1:length(obsTypes)

    found = 0;
    switch obsTypes{ii}

        case 'L1' % L1 phase measurement
            % Find the L1 phase in the data and remove it
            for jj = 1:length(data)
                if (data(jj) <= phaseLim) && (data(jj) >= codeLim)
                    satStruct.L1phase = data(jj);
                    found = 1;
                    break
                end
            end
            if ~found
                satStruct.L1phase = 0;
            end

        case 'L2'
            % Find the L2 phase in the data and remove it
            for jj = 1:length(data)
                if (data(jj) <= phaseLim) && (data(jj) >= codeLim)
                    satStruct.L2phase = data(jj);
                    found = 1;
                    break
                end
            end
            if ~found
                satStruct.L2phase = 0;
            end

        case 'L5'
            % Find the L5 phase in the data and remove it
            for jj = 1:length(data)
                if (data(jj) <= phaseLim) && (data(jj) >= codeLim)
                    satStruct.L5phase = data(jj);
                    found = 1;
                    break
                end
            end
            if ~found
                satStruct.L5phase = 0;
            end

        case {'C1','P1'}
            % Find the L1 psuedorange data and remove it
            for jj = 1:length(data)
                if (data(jj) <= codeLim) && (data(jj) >= SNRLim)
                    satStruct.L1psr = data(jj);
                    found = 1;
                    break
                end
            end
            if ~found
                satStruct.L1psr  = 0;
            end

        case {'C2','P2'}
            % Find the L2 psuedorange data and remove it
            for jj = 1:length(data)
                if (data(jj) <= codeLim) && (data(jj) >= SNRLim)
                    satStruct.L2psr = data(jj);
                    found = 1;
                    break
                end
            end
            if ~found
                satStruct.L2psr  = 0;
            end

        case {'C5','P5'}
            % Find the L2 psuedorange data and remove it
            for jj = 1:length(data)
                if (data(jj) <= codeLim) && (data(jj) >= SNRLim)
                    satStruct.L5psr = data(jj);
                    found = 1;
                    break
                end
            end
            if ~found
                satStruct.L5psr  = 0;
            end

        case 'S1'
            % Find the L1 SNR data and remove it
            for jj = 1:length(data)
                if (data(jj) <= SNRLim) && (data(jj) >= LLILim)
                    satStruct.L1SNR = data(jj);
                    found = 1;
                    break
                end
            end
            if ~found
                satStruct.L1SNR = 0;
            end

        case 'S2'
            % Find the L1 SNR data and remove it
            for jj = 1:length(data)
                if (data(jj) <= SNRLim) && (data(jj) >= LLILim)
                    satStruct.L2SNR = data(jj);
                    found = 1;
                    break
                end
            end
            if ~found
                satStruct.L2SNR = 0;
            end

        case 'S5'
            % Find the L1 SNR data and remove it
            for jj = 1:length(data)
                if (data(jj) <= SNRLim) && (data(jj) >= LLILim)
                    satStruct.L5SNR = data(jj);
                    found = 1;
                    break
                end
            end
            if ~found
                satStruct.L5SNR = 0;
            end

        otherwise
            error('Format specifier ' + obsTypes{ii} + ' not recognized')

    end

    % Delete entry we just processed if we found a match
    if found
        data(jj) = nan;
    end

end

% Convert output to a matrix so that it can be used in the outer function
field = fieldnames(satStruct);

for ii = 1:length(field)
    output(ii) = satStruct.(field{ii});
end