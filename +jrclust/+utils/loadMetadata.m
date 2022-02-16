function S = loadMetadata(metafile)
    %LOADMETADATA convert SpikeGLX metadata to struct
    %   TODO: build into Config workflow to cut down on specified parameters

    % get absolute path of metafile
    metafile_ = jrclust.utils.absPath(metafile);
    if isempty(metafile_)
        error('could not find meta file %s', metafile);
    end

    try
        S = jrclust.utils.metaToStruct(metafile_);
    catch ME
        error('could not read meta file %s: %s', metafile, ME.message);
    end

    S.adcBits = 16;
    S.probe = '';
    S.isImec = 0;

    %convert new fields to old fields
    if isfield(S, 'niSampRate') % SpikeGLX
        S.nChans = S.nSavedChans;
        S.sampleRate = S.niSampRate;
        S.rangeMax = S.niAiRangeMax;
        S.rangeMin = S.niAiRangeMin;
        S.gain = S.niMNGain;
        try
            S.outputFile = S.fileName;
            S.sha1 = S.fileSHA1;
            S.probe = 'imec2';
        catch
            S.outputFile = '';
            S.sha1 = [];
        end
    elseif isfield(S, 'imSampRate') % IMEC probe
        S.nChans = S.nSavedChans;
        S.sampleRate = S.imSampRate;
        S.rangeMax = S.imAiRangeMax;
        S.rangeMin = S.imAiRangeMin;
        switch S.imDatPrb_type
            case {21,24}
                S.adcBits = 14; % 10 bit adc but 16 bit saved
            otherwise
                S.adcBits = 10; % 10 bit adc but 16 bit saved
        end

        % read data from ~imroTbl
        imroTbl = strsplit(S.imroTbl(2:end-1), ')(');
        imroTblHeader = cellfun(@str2double, strsplit(imroTbl{1}, ','));
        if numel(imroTblHeader) == 3 % 3A with option
            S.probeOpt = imroTblHeader(2);
            %S.probe = sprintf('imec3_opt%d', S.probeOpt);
        else
            S.probeOpt = [];
        end

        % parse first entry in imroTbl
        imroTblChan = cellfun(@str2double, strsplit(imroTbl{2}, ' '));

        S.gain = imroTblChan(4);
        S.gainLFP = imroTblChan(5);
        
        switch S.imDatPrb_type
            case {21,24}
                S.gain = zeros(size(S.gain))+80;
                S.gainLFP = zeros(size(S.gainLFP));                
            otherwise
        end        

        S.isImec = 1;
    end

    %number of bits of ADC [was 16 in Chongxi original]
    try
        S.scale = ((S.rangeMax - S.rangeMin)/(2^S.adcBits))/S.gain * 1e6; %uVolts
    catch
        S.scale = 1;
    end

    S.bitScaling = S.scale;
    if isfield(S, 'gainLFP')
        S.bitScalingLFP = S.scale * S.gain / S.gainLFP;
    end
end
